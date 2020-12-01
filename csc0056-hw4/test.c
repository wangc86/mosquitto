#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <time.h>

int main(void)
{
  static struct timeval arrival_time;
  gettimeofday(&arrival_time, NULL);
  printf("%ld %ld\n", arrival_time.tv_sec, arrival_time.tv_usec);
  char str[17];
  memcpy(&str[0], &arrival_time.tv_sec, 8);
  memcpy(&str[8], &arrival_time.tv_usec, 8);
  str[16] = '\0';
//  printf("%ld %ld %ld\n", sizeof(char), sizeof(time_t), sizeof(suseconds_t));
  static struct timeval a_time;
  memcpy(&a_time.tv_sec, &str[0], 8);
  memcpy(&a_time.tv_usec, &str[8], 8);
  printf("%ld %ld\n", a_time.tv_sec, a_time.tv_usec);

  srand(time(NULL));
  printf("%d\n", rand() % RAND_MAX + 1);
  printf("%d\n", rand() % RAND_MAX + 1);
  printf("%d\n", rand() % RAND_MAX + 1);

  return 0;
}
