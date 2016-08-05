/*
Copyright (c) 2011,  Shenzhen Hexicom Technologies Co., Ltd.
All rights reserved.

File         : lsw_api.h
Status       : Current
Description  :	

Author       : Einsn Liu
Contact      : liuchuansen@hexicomtech.com

Revision     : 2012-09-18
Description  : Primary beta released
*/

#ifndef __LSW_API_H__
#define __LSW_API_H__

#include <stdint.h>


#ifndef PORT_SPEED_10M
#define PORT_SPEED_10M 0
#endif 

#ifndef PORT_SPEED_100M
#define PORT_SPEED_100M 1
#endif 

#ifndef PORT_SPEED_1000M
#define PORT_SPEED_1000M 2
#endif 

/* speed & duplex 
enum{
    PORT_SPEED_10M = 0,
    PORT_SPEED_100M = 1,
    PORT_SPEED_1000M = 2,    
};        
*/


enum{
    PORT_DUPLEX_HALF = 0,
    PORT_DUPLEX_FULL = 1,
};        


/* capality */
enum 
{
	PORT_DOWN=0,
	HALF_DUPLEX_10M,
	HALF_DUPLEX_100M,
	HALF_DUPLEX_1000M,
	DUPLEX_10M,
	DUPLEX_100M,
	DUPLEX_1000M,
	PORT_AUTO
};


typedef struct {
    uint32_t force_mode;
    uint32_t force_link;
    uint32_t force_speed;
    uint32_t force_duplex;
    uint32_t capality;
    uint32_t autoneg;
    uint32_t speed;
    uint32_t duplex;
}rtl8198_port_mode_t;



/* 
port mibs 
copy from  rtk_api.h 
*/
typedef enum 
{
    RTLMIBS_IfInOctets = 0,
    RTLMIBS_Dot3StatsFCSErrors,
    RTLMIBS_Dot3StatsSymbolErrors,
    RTLMIBS_Dot3InPauseFrames,
    RTLMIBS_Dot3ControlInUnknownOpcodes,        
    RTLMIBS_EtherStatsFragments,
    RTLMIBS_EtherStatsJabbers,
    RTLMIBS_IfInUcastPkts,
    RTLMIBS_EtherStatsDropEvents,
    RTLMIBS_EtherStatsOctets,
    RTLMIBS_EtherStatsUnderSizePkts,
    RTLMIBS_EtherOversizeStats,
    RTLMIBS_EtherStatsPkts64Octets,
    RTLMIBS_EtherStatsPkts65to127Octets,
    RTLMIBS_EtherStatsPkts128to255Octets,
    RTLMIBS_EtherStatsPkts256to511Octets,
    RTLMIBS_EtherStatsPkts512to1023Octets,
    RTLMIBS_EtherStatsPkts1024to1518Octets,
    RTLMIBS_EtherStatsMulticastPkts,
    RTLMIBS_EtherStatsBroadcastPkts,    
    RTLMIBS_IfOutOctets,
    RTLMIBS_Dot3StatsSingleCollisionFrames,
    RTLMIBS_Dot3StatsMultipleCollisionFrames,
    RTLMIBS_Dot3StatsDeferredTransmissions,
    RTLMIBS_Dot3StatsLateCollisions,
    RTLMIBS_EtherStatsCollisions,
    RTLMIBS_Dot3StatsExcessiveCollisions,
    RTLMIBS_Dot3OutPauseFrames,
    RTLMIBS_Dot1dBasePortDelayExceededDiscards,
    RTLMIBS_Dot1dTpPortInDiscards,
    RTLMIBS_IfOutUcastPkts,
    RTLMIBS_IfOutMulticastPkts,
    RTLMIBS_IfOutBroadcastPkts,
    RTLMIBS_OutOampduPkts,
    RTLMIBS_InOampduPkts,
    RTLMIBS_PktgenPkts,
    RTLMIBS_PORT_CNTR_END
}rtl8198_port_mibs_t;


typedef enum{
   Port_AcceptFrameType_All = 0,
   Port_AcceptFrameType_TaggedOnly,
   Port_AcceptFrameType_Untagged,
   Port_AcceptFrameType_End
}Port_AcceptFrameType_t;


int rtl8198_set_port_flowctrl(uint32_t port, uint32_t rx, uint32_t tx);
int rtl8198_get_port_flowctrl(uint32_t port, uint32_t *rx, uint32_t *tx);
int rtl8198_set_port_mode(uint32_t port, rtl8198_port_mode_t *mode);
int rtl8198_get_port_mode(uint32_t port, rtl8198_port_mode_t *mode);
int rtl8198_set_port_enable(uint32_t port, uint32_t enable);
int rtl8198_get_port_enable(uint32_t port, uint32_t *enable);
int rtl8198_set_port_rate_limit(uint32_t port, uint32_t ingress_rate, uint32_t egress_rate);
int rtl8198_get_port_rate_limit(uint32_t port, uint32_t *ingress_rate, uint32_t *egress_rate);
int rtl8198_reset_port_counters(uint32_t port, uint32_t reset_in, uint32_t reset_out);
int rtl8198_get_port_counters(uint32_t port, uint64_t *mibs);
int rtl8198_get_port_link_status(uint32_t port, uint32_t *link, uint32_t *speed, uint32_t *duplex);
int rtl8198_set_port_pvid(uint32_t port, uint32_t pvid);
int rtl8198_get_port_pvid(uint32_t port, uint32_t *pvid);
int rtl8198_set_port_priority(uint32_t port, uint32_t priority);
int rtl8198_get_port_priority(uint32_t port, uint32_t *priority);
int rtl8198_set_port_frame_type(uint32_t port, uint32_t frame_type);
int rtl8198_get_port_frame_type(uint32_t port, uint32_t *frame_type);
int rtl8198_set_port_ingress_filter(uint32_t port, uint32_t enable);
int rtl8198_get_port_ingress_filter(uint32_t port, uint32_t *enable);
int rtl8198_set_vlan_tag_ignore(uint32_t enable);
int rtl8198_get_vlan_tag_ignore(uint32_t *enable);
int rtl8198_set_vlan(uint32_t vlan, uint32_t port_mask, uint32_t untag_mask, uint32_t fid);
int rtl8198_get_vlan(uint32_t vlan, uint32_t *port_mask, uint32_t *untag_mask, uint32_t *fid);
int rtl8198_del_vlan(uint32_t vlan);
int rtl8198_set_port_mirror(uint32_t rx_ports, uint32_t tx_ports, uint32_t monitor_ports);
int rtl8198_get_port_mirror(uint32_t *rx_ports, uint32_t *tx_ports, uint32_t *monitor_ports);
int rtl8198_set_port_storm(uint32_t port, uint32_t rate, uint32_t bcast_en, uint32_t mcast_en, uint32_t ucast_en);
int rtl8198_get_port_storm(uint32_t port, uint32_t *rate, uint32_t *bcast_en, uint32_t *mcast_en, uint32_t *ucast_en);
int rtl8198_set_phy_register(uint32_t phy, uint32_t reg, uint32_t data);
int rtl8198_get_phy_register(uint32_t phy, uint32_t reg, uint32_t *data);
int rtl8198_set_port_pattern(uint32_t port, uint32_t pattern, uint32_t pattern_mask, uint32_t operation);
int rtl8198_get_port_pattern(uint32_t port, uint32_t *pattern, uint32_t *pattern_mask, uint32_t *operation);
int rtl8198_set_cable_mask(uint32_t cable_mask);
int rtl8198_get_cable_mask(uint32_t *cable_mask);
int rtl8198_set_mgmt_vlan(uint32_t vlan_mode, uint32_t mgmt_vlan, uint32_t mgmt_pri, uint32_t mgmt_ports);
int rtl8198_get_mgmt_vlan(uint32_t *vlan_mode, uint32_t *mgmt_vlan, uint32_t *mgmt_pri, uint32_t *mgmt_ports);
int rtl8198_set_gpio(uint32_t port, uint32_t pin, uint32_t data);
int rtl8198_get_gpio(uint32_t port, uint32_t pin, uint32_t *data);
int rtl8198_init_gpio(uint32_t port, uint32_t pin, uint32_t direction);

#ifndef GPIO_ID
#define GPIO_ID(port,pin) ((uint32)port<<8|(uint32)pin)
#endif


#endif /* __LSW_API_H__ */
