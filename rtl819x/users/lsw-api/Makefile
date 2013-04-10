
LINUXDIR=$(shell pwd)/../../linux-2.6.30

CROSS_COMPILE=mips-linux-

CC=$(CROSS_COMPILE)gcc
AR=$(CROSS_COMPILE)ar

T=libswapi.a test

OBJS=lsw_api.o

CFLAGS=-Wall -Os 
CFLAGS+= -I$(LINUXDIR)/include
CFLAGS+= -I$(LINUXDIR)/include/net/rtl

all:$T

$T:$(OBJS)
	$(AR) -r $@ $<

test:$T test.o
	$(CC) $(CFLAGS) -o $@ $<


%.o:%.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf *.o $T

.PHONY=clean all
