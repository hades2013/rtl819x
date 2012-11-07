#include $(DIR_USERS)/.config
include $(DIR_LINUX)/.config

CFLAGS += -Os
export CFLAGS

all : $(EXEC)
ifeq ($(CONFIG_RTL_NFBI_MDIO),y)
ifeq ($(CONFIG_RTL8192CD),y)	
	make -C rtl_device
else
	make -C device
endif
endif

romfs :
ifeq ($(CONFIG_RTL_NFBI_MDIO),y)
ifeq ($(CONFIG_RTL8192CD),y)	
	make -C rtl_device romfs
else
	make -C device romfs
endif	
endif

clean:
ifeq ($(CONFIG_RTL_NFBI_MDIO),y)
ifeq ($(CONFIG_RTL8192CD),y)	
	make -C rtl_device clean
else
	make -C device clean
endif	
endif
