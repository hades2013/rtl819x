LINUX_ARCH = LINUX
DIR_WLAN = $(DIR_LINUX)/drivers/net/wireless/rtl8192cd

all:
	@echo "" > ./.diff_config; 

	@if [ -e .kernel_config ]; then \
		diff .kernel_config $(DIR_LINUX)/.config > .diff_config; \
		if [ -s .diff_config ]; then \
		        cp $(DIR_LINUX)/.config .kernel_config; \
			make -C $(LINUX_ARCH) clean; \
                fi; \
        else \
                cp $(DIR_LINUX)/.config ./.kernel_config; \
	fi;

	@echo "" > ./.diff_wlan_mib;
	@if [ -e .wlan_mib_h ]; then \
		diff .wlan_mib_h $(DIR_WLAN)/ieee802_mib.h > .diff_wlan_mib; \
		if [ -s .diff_wlan_mib ]; then \
			cp $(DIR_WLAN)/ieee802_mib.h .wlan_mib_h; \
			make -C $(LINUX_ARCH) clean; \
		fi; \
	else \
		cp $(DIR_WLAN)/ieee802_mib.h ./.wlan_mib_h; \
	fi;

	make -C $(LINUX_ARCH)
	
clean:
	make -C $(LINUX_ARCH) clean

romfs:
	make -C $(LINUX_ARCH) romfs

