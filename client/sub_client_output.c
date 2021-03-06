/*
Copyright (c) 2009-2020 Roger Light <roger@atchoo.org>

All rights reserved. This program and the accompanying materials
are made available under the terms of the Eclipse Public License v1.0
and Eclipse Distribution License v1.0 which accompany this distribution.
 
The Eclipse Public License is available at
   http://www.eclipse.org/legal/epl-v10.html
and the Eclipse Distribution License is available at
  http://www.eclipse.org/org/documents/edl-v10.php.
 
Contributors:
   Roger Light - initial implementation and documentation.
*/

#include "config.h"

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifndef WIN32
#include <unistd.h>
#else
#include <process.h>
#include <winsock2.h>
#define snprintf sprintf_s
#endif

#ifdef __APPLE__
#  include <sys/time.h>
#endif

#include <mosquitto.h>
#include "client_shared.h"

extern struct mosq_config cfg;

static int get_time(struct tm **ti, long *ns)
{
#ifdef WIN32
	SYSTEMTIME st;
#elif defined(__APPLE__)
	struct timeval tv;
#else
	struct timespec ts;
#endif
	time_t s;

#ifdef WIN32
	s = time(NULL);

	GetLocalTime(&st);
	*ns = st.wMilliseconds*1000000L;
#elif defined(__APPLE__)
	gettimeofday(&tv, NULL);
	s = tv.tv_sec;
	*ns = tv.tv_usec*1000;
#else
	if(clock_gettime(CLOCK_REALTIME, &ts) != 0){
		err_printf(&cfg, "Error obtaining system time.\n");
		return 1;
	}
	s = ts.tv_sec;
	*ns = ts.tv_nsec;
#endif

	*ti = localtime(&s);
	if(!(*ti)){
		err_printf(&cfg, "Error obtaining system time.\n");
		return 1;
	}

	return 0;
}


static void write_payload_timestamp(const unsigned char *payload, int payloadlen, int hex)
{
        static struct timeval creation_time;
        memcpy(&creation_time.tv_sec, &payload[0], 8);
        memcpy(&creation_time.tv_usec, &payload[8], 8);
        static struct timeval arrival_time;
        gettimeofday(&arrival_time, NULL);
	fprintf(stdout, "%ld %ld", arrival_time.tv_sec-creation_time.tv_sec, arrival_time.tv_usec-creation_time.tv_usec);
}

static void write_payload(const unsigned char *payload, int payloadlen, int hex)
{
	int i;

	if(hex == 0){
		(void)fwrite(payload, 1, (size_t )payloadlen, stdout);
	}else if(hex == 1){
		for(i=0; i<payloadlen; i++){
			fprintf(stdout, "%02x", payload[i]);
		}
	}else if(hex == 2){
		for(i=0; i<payloadlen; i++){
			fprintf(stdout, "%02X", payload[i]);
		}
	}
}


static void write_json_payload(const char *payload, int payloadlen)
{
	int i;

	for(i=0; i<payloadlen; i++){
		if(payload[i] == '"' || payload[i] == '\\' || (payload[i] >=0 && payload[i] < 32)){
			printf("\\u%04x", payload[i]);
		}else{
			fputc(payload[i], stdout);
		}
	}
}


static void json_print(const struct mosquitto_message *message, const struct tm *ti, bool escaped)
{
	char buf[100];

	snprintf(buf, 100, "%ld", time(NULL));
	printf("{\"tst\":%s,\"topic\":\"%s\",\"qos\":%d,\"retain\":%d,\"payloadlen\":%d,", buf, message->topic, message->qos, message->retain, message->payloadlen);
	if(message->qos > 0){
		printf("\"mid\":%d,", message->mid);
	}
	if(escaped){
		fputs("\"payload\":\"", stdout);
		write_json_payload(message->payload, message->payloadlen);
		fputs("\"}", stdout);
	}else{
		fputs("\"payload\":", stdout);
		write_payload(message->payload, message->payloadlen, 0);
		fputs("}", stdout);
	}
}


static void formatted_print(const struct mosq_config *lcfg, const struct mosquitto_message *message)
{
	size_t len;
	int i;
	struct tm *ti = NULL;
	long ns;
	char strf[3];
	char buf[100];

	len = strlen(lcfg->format);

	for(i=0; i<len; i++){
		if(lcfg->format[i] == '%'){
			if(i < len-1){
				i++;
				switch(lcfg->format[i]){
					case '%':
						fputc('%', stdout);
						break;

					case 'I':
						if(!ti){
							if(get_time(&ti, &ns)){
								err_printf(lcfg, "Error obtaining system time.\n");
								return;
							}
						}
						if(strftime(buf, 100, "%FT%T%z", ti) != 0){
							fputs(buf, stdout);
						}
						break;

					case 'j':
						if(!ti){
							if(get_time(&ti, &ns)){
								err_printf(lcfg, "Error obtaining system time.\n");
								return;
							}
						}
						json_print(message, ti, true);
						break;

					case 'J':
						if(!ti){
							if(get_time(&ti, &ns)){
								err_printf(lcfg, "Error obtaining system time.\n");
								return;
							}
						}
						json_print(message, ti, false);
						break;

					case 'l':
						printf("%d", message->payloadlen);
						break;

					case 'm':
						printf("%d", message->mid);
						break;

					case 'p':
						write_payload(message->payload, message->payloadlen, 0);
						break;

					case 'q':
						fputc(message->qos + 48, stdout);
						break;

					case 'r':
						if(message->retain){
							fputc('1', stdout);
						}else{
							fputc('0', stdout);
						}
						break;

					case 't':
						fputs(message->topic, stdout);
						break;

					case 'U':
						if(!ti){
							if(get_time(&ti, &ns)){
								err_printf(lcfg, "Error obtaining system time.\n");
								return;
							}
						}
						if(strftime(buf, 100, "%s", ti) != 0){
							printf("%s.%09ld", buf, ns);
						}
						break;

					case 'x':
						write_payload(message->payload, message->payloadlen, 1);
						break;

					case 'X':
						write_payload(message->payload, message->payloadlen, 2);
						break;
				}
			}
		}else if(lcfg->format[i] == '@'){
			if(i < len-1){
				i++;
				if(lcfg->format[i] == '@'){
					fputc('@', stdout);
				}else{
					if(!ti){
						if(get_time(&ti, &ns)){
							err_printf(lcfg, "Error obtaining system time.\n");
							return;
						}
					}

					strf[0] = '%';
					strf[1] = lcfg->format[i];
					strf[2] = 0;

					if(lcfg->format[i] == 'N'){
						printf("%09ld", ns);
					}else{
						if(strftime(buf, 100, strf, ti) != 0){
							fputs(buf, stdout);
						}
					}
				}
			}
		}else if(lcfg->format[i] == '\\'){
			if(i < len-1){
				i++;
				switch(lcfg->format[i]){
					case '\\':
						fputc('\\', stdout);
						break;

					case '0':
						fputc('\0', stdout);
						break;

					case 'a':
						fputc('\a', stdout);
						break;

					case 'e':
						fputc('\033', stdout);
						break;

					case 'n':
						fputc('\n', stdout);
						break;

					case 'r':
						fputc('\r', stdout);
						break;

					case 't':
						fputc('\t', stdout);
						break;

					case 'v':
						fputc('\v', stdout);
						break;
				}
			}
		}else{
			fputc(lcfg->format[i], stdout);
		}
	}
	if(lcfg->eol){
		fputc('\n', stdout);
	}
	fflush(stdout);
}


void print_message(struct mosq_config *cfg, const struct mosquitto_message *message)
{
	if(cfg->format){
		formatted_print(cfg, message);
	}else if(cfg->verbose){
                // Chao: What I did here is a horrible hack, where I abused the semantics
                //       of argument "verbose" for outputing timestamp information.
                //       This rough hack is solely for the purpose of differentiating
                //       the original write_payload(...) with write_payload_timestamp(...).
                //       The original version is commented out as below.
                //       The original version may be invoked if we disabled the verbose flag.
		if(message->payloadlen){
			write_payload_timestamp(message->payload, message->payloadlen, false);
			if(cfg->eol){
				printf("\n");
			}
			fflush(stdout);
		}
                /*
		if(message->payloadlen){
			printf("%s ", message->topic);
			write_payload(message->payload, message->payloadlen, false);
			if(cfg->eol){
				printf("\n");
			}
		}else{
			if(cfg->eol){
				printf("%s (null)\n", message->topic);
			}
		}
		fflush(stdout);
                */
	}else{
		if(message->payloadlen){
			write_payload(message->payload, message->payloadlen, false);
			if(cfg->eol){
				printf("\n");
			}
			fflush(stdout);
		}
	}
}

