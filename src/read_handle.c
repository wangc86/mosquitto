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
#include <stdio.h>
#include <string.h>

#include "mosquitto_broker_internal.h"
#include "mqtt_protocol.h"
#include "memory_mosq.h"
#include "packet_mosq.h"
#include "read_handle.h"
#include "send_mosq.h"
#include "sys_tree.h"
#include "util_mosq.h"


int handle__packet(struct mosquitto_db *db, struct mosquitto *context)
{
	if(!context) return MOSQ_ERR_INVAL;

	switch((context->in_packet.command)&0xF0){
		case CMD_PINGREQ:
//printf("handle_pingreq\n");
			return handle__pingreq(context);
		case CMD_PINGRESP:
//printf("handle_pingresp\n");
			return handle__pingresp(context);
		case CMD_PUBACK:
			return handle__pubackcomp(db, context, "PUBACK");
		case CMD_PUBCOMP:
			return handle__pubackcomp(db, context, "PUBCOMP");
		case CMD_PUBLISH:
//printf("handle_publish\n");
			return handle__publish(db, context);
		case CMD_PUBREC:
			return handle__pubrec(db, context);
		case CMD_PUBREL:
			return handle__pubrel(db, context);
		case CMD_CONNECT:
//printf("handle_connect\n");
			return handle__connect(db, context);
		case CMD_DISCONNECT:
//printf("handle_disconnect\n");
			return handle__disconnect(db, context);
		case CMD_SUBSCRIBE:
//printf("handle_subscribe\n");
			return handle__subscribe(db, context);
		case CMD_UNSUBSCRIBE:
//printf("handle_unscribe\n");
			return handle__unsubscribe(db, context);
#ifdef WITH_BRIDGE
		case CMD_CONNACK:
			return handle__connack(db, context);
		case CMD_SUBACK:
			return handle__suback(context);
		case CMD_UNSUBACK:
			return handle__unsuback(context);
#endif
		case CMD_AUTH:
			return handle__auth(db, context);
		default:
			/* If we don't recognise the command, return an error straight away. */
			return MOSQ_ERR_PROTOCOL;
	}
}

