all:
	@echo "builded"
clean:
	@echo "It's cleaned"

romfs:
	$(ROMFSINST) /bin/aeUdpClient
ifdef CONFIG_RTL_WAPI_SUPPORT
ifdef CONFIG_RTL_WAPI_LOCAL_AS_SUPPORT
	$(ROMFSINST) /bin/aseUdpServer
endif
endif

