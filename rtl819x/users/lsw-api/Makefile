
#CC		= mips-uclibc-gcc
#STRIP		= mips-uclibc-strip

COPT		= -Os 
CFLAGS		= ${COPT} 
ifeq ($(CONFIG_RSDK_rsdk-1.5.0-4181-EB-2.6.30-0.9.30.2),y)
CFLAGS 		+= -mips16
endif
ifeq ($(CONFIG_RSDK_rsdk-1.5.0-4181-EB-2.6.30-0.9.30.3),y)
CFLAGS 		+= -mips16
endif
LDFLAGS		=

LINUXDIR=$(shell pwd)/../../linux-2.6.30

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -I. -Wall -DCONFIG_HEXICOM_ECM201A 
CFLAGS += -I$(LINUXDIR)/include
CFLAGS += -I$(LINUXDIR)/include/net/rtl

LIBSWAPI=libswapi.a 
APPTEST=test


all: $(LIBSWAPI) $(APPTEST)


$(LIBSWAPI):lsw_api.o $(LINUXDIR)/include/net/rtl/rtl_ext_ioctl.h
	$(AR) -r $@ $<

$(APPTEST):$(LIBSWAPI) test.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ test.o $(LIBSWAPI) 

%.o:%.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(LIBSWAPI) $(APPTEST)

.PHONY=clean all

#romfs:
#	$(ROMFSINST) reload /bin/reload

