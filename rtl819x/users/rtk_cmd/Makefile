all:	rtk_cmd

#CC	= mips-uclibc-gcc
#STRIP	= mips-uclibc-strip

CFLAGS	= -Wall -Os -I$(DIR_LINUX)/include/
IFLAGS	=
LDFLAGS = -Wall -Os -I$(DIR_LINUX)/include/
SOURCES = rtk_cmd.c rtk_filter.c rtk_igmp_delete.c

ifeq ($(SLINK),1)
CFLAGS  += -ffunction-sections -fdata-sections
LDFLAGS += --static -Wl,--gc-sections
endif


DEBUG	= -Wall -Os

rtk_cmd:       $(SOURCES:.c=.o)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(STRIP) $@
romfs:
	$(ROMFSINST) /bin/rtk_cmd

clean:
	rm -f rtk_cmd *.o 

