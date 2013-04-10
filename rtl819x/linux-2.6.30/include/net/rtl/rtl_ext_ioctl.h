#ifndef	__RTL_EXT_IOCTL_H__
#define	__RTL_EXT_IOCTL_H__

#include <rtl_types.h>

/* Modified by Einsn for expand ioctl apis 20130407 */
#ifdef RTL_EXT_IOCTL

#define SIOCEXTPRIVATE SIOCDEVPRIVATE + 12

/* copy from rtl865x_tblAsicDrv_advancedCounterParam_t */
typedef struct  
{
	/*here is in counters  definition*/
	uint64 ifInOctets;
	uint32 ifInUcastPkts;
	uint64 etherStatsOctets;
	uint32 etherStatsUndersizePkts;
	uint32 etherStatsFraments;
	uint32 etherStatsPkts64Octets;
	uint32 etherStatsPkts65to127Octets;
	uint32 etherStatsPkts128to255Octets;
	uint32 etherStatsPkts256to511Octets;
	uint32 etherStatsPkts512to1023Octets;
	uint32 etherStatsPkts1024to1518Octets;
	uint32 etherStatsOversizePkts;
	uint32 etherStatsJabbers;
	uint32 etherStatsMulticastPkts;
	uint32 etherStatsBroadcastPkts;
	uint32 dot1dTpPortInDiscards;
	uint32 etherStatusDropEvents;
	uint32 dot3FCSErrors;
	uint32 dot3StatsSymbolErrors;
	uint32 dot3ControlInUnknownOpcodes;
	uint32 dot3InPauseFrames;

	/*here is out counters  definition*/
	uint64 ifOutOctets;
	uint32 ifOutUcastPkts;
	uint32 ifOutMulticastPkts;
	uint32 ifOutBroadcastPkts;
	uint32 ifOutDiscards;
	uint32 dot3StatsSingleCollisionFrames;
	uint32 dot3StatsMultipleCollisionFrames;
	uint32 dot3StatsDefferedTransmissions;
	uint32 dot3StatsLateCollisions;
	uint32 dot3StatsExcessiveCollisions;
	uint32 dot3OutPauseFrames;
	uint32 dot1dBasePortDelayExceededDiscards;
	uint32 etherStatsCollisions;

	/*here is whole system couters definition*/
	uint32 dot1dTpLearnedEntryDiscards;
	uint32 etherStatsCpuEventPkts;
	
}mib_counter_t;


/* phy operation */
typedef struct {
    uint32 phy;
    uint32 reg;
    uint32 data;
}cmd_phy_reg_t;

/* port pattern */

typedef struct {
    uint32 pid;
    uint32 pattern;
    uint32 pattern_mask;
    uint32 operation;
}cmd_port_pattern_t;


typedef struct {
    uint32 pid;
    uint32 ingress_rate;
    uint32 egress_rate;
}cmd_port_rate_t;

typedef struct {
    uint32 pid;
    uint32 force_mode;
    uint32 force_link;
    uint32 force_speed;
    uint32 force_duplex;
    uint32 capality;
    uint32 autoneg;
    uint32 speed;
    uint32 duplex;
}cmd_port_mode_t;

typedef struct {
    uint32 pid;
    uint32 reset_in;
    uint32 reset_out;
    mib_counter_t counters;
}cmd_mib_counter_t;

typedef struct {
    uint32 pid;
    uint32 link;
    uint32 speed;
    uint32 duplex;
}cmd_port_status_t;

/* port simple */
typedef struct {
    uint32 pid;
    uint32 value;
}cmd_port_simple_t;

/* port storm control */
typedef struct {
    uint32 rate; // global for all ports
    uint32 pid;
    uint32 broadcast;
    uint32 multicast;
    uint32 unicast;
}cmd_port_storm_t;

/* port mirror */
typedef struct {
    uint32 rx_mask;
    uint32 tx_mask;
    uint32 dest_mask;    
}cmd_port_mirror_t;

/* vlan */
typedef struct {
    uint32 vid;
    uint32 port_mask;
    uint32 untag_mask;
    uint32 fid;
}cmd_vlan_t;


typedef enum{
/* Port Flowctrl */
   EXT_CMD_SET_PORT_FLOWCTRL,
   EXT_CMD_GET_PORT_FLOWCTRL,
   
/* Port Speed & duplex */
   EXT_CMD_SET_PORT_MODE,
   EXT_CMD_GET_PORT_MODE,
 
/* Port shutdown */
   EXT_CMD_SET_PORT_ENABLE,
   EXT_CMD_GET_PORT_ENABLE,
   
/* Port RateLimit */   
   EXT_CMD_SET_PORT_RATELIMIT,
   EXT_CMD_GET_PORT_RATELIMIT,

/* Port MIBs */
   EXT_CMD_RESET_MIB_COUNTER,
   EXT_CMD_GET_MIB_COUNTER,

/* Port Link Status */
   EXT_CMD_GET_PORT_LINK_STATUS, 

/* Port PVID */
   EXT_CMD_SET_PVID,
   EXT_CMD_GET_PVID,
   
/* Port Priority */
   EXT_CMD_SET_PORT_PRIOPRITY,
   EXT_CMD_GET_PORT_PRIOPRITY,

/* Port Accept Fram type */
   EXT_CMD_SET_PORT_FRAME_TYPE,
   EXT_CMD_GET_PORT_FRAME_TYPE,

/* Port IngressFilter */
   EXT_CMD_SET_PORT_INGRESS_FILTER,
   EXT_CMD_GET_PORT_INGRESS_FILTER,

/* VLAN Tag ignore */
   EXT_CMD_SET_VLAN_TAG_IGNORE,
   EXT_CMD_GET_VLAN_TAG_IGNORE,

/* VLAN */
   EXT_CMD_SET_VLAN,
   EXT_CMD_GET_VLAN,
   EXT_CMD_DEL_VLAN,

/* Port Mirror */
   EXT_CMD_GET_PORT_MIRROR,
   EXT_CMD_SET_PORT_MIRROR,
   
/* Port Storm */
    EXT_CMD_GET_PORT_STORM,
    EXT_CMD_SET_PORT_STORM,

/* PHY operation */
    EXT_CMD_GET_PHY_REG,
    EXT_CMD_SET_PHY_REG,

/* Port pattern */
   EXT_CMD_GET_PORT_PATTERN,
   EXT_CMD_SET_PORT_PATTERN,

/* Modified by Einsn for EOC features 20130409 */
#ifdef RTL_EOC_SUPPORT
/* EOC special */
  EXT_CMD_SET_CABLE_MASK,
  EXT_CMD_GET_CABLE_MASK,
  EXT_CMD_SET_MGMT_VLAN,
  EXT_CMD_GET_MGMT_VLAN,
#endif
/* End */

   EXT_CMD_NUM 
}ext_req_cmd_t;


struct ext_req{
    int32     ret;
    ext_req_cmd_t cmd;
    union {
        uint32 value;
        cmd_port_simple_t port_simple;
        cmd_port_status_t port_status;
        cmd_port_mode_t port_mode;
        cmd_port_rate_t port_rate;
        cmd_port_storm_t port_storm;
        cmd_port_mirror_t port_mirror;
        cmd_port_pattern_t port_pattern;
        cmd_mib_counter_t mib_counter;
        cmd_phy_reg_t phy_reg;
        cmd_vlan_t vlan;
        eoc_mgmt_vlan_t mgmt_vlan;
    }data;
};


#endif /* RTL_EXT_IOCTL */
/* End */

#endif /* __RTL_EXT_IOCTL_H__ */
