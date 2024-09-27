// A simple example of taking timestamps using gettimeofday

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h> // for sleep()

void timestamp(struct timeval *tv) {
	if (gettimeofday(tv, NULL)) {
		perror("gettimeofday");
		exit(EXIT_FAILURE);
	}
}

int main(void){
	struct timeval t_begin, t_end;
	timestamp(&t_begin);
	sleep(1);
	timestamp(&t_end);
	long latency = t_end.tv_sec*1000000+t_end.tv_usec
			- (t_begin.tv_sec*1000000+t_begin.tv_usec);
	fprintf(stderr, "latency = %ld us\n", latency);
	//printf("%ld\n", sizeof(long));
	return 0;
}
