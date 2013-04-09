#ifndef	RTL_NIC_H
#define	RTL_NIC_H

#ifdef CONFIG_RTL_STP
#include <net/rtl/rtk_stp.h>
#endif

#include "rtl865x_netif.h"
/************************************
*	feature enable/disable
*************************************/
#define RX_TASKLET	1
#define TX_TASKLET	1
#define LINK_TASKLET 1
#define RTL819X_PRIV_IOCTL_ENABLE 1 	/* mark_add */
#define CONFIG_RTL_PHY_PATCH		1
#define RTK_QUE			1
#if defined(CONFIG_NET_WIRELESS_AGN) || defined (CONFIG_RTL8192SE) || defined(CONFIG_RTL8192CD) || defined(CONFIG_RTL8192CD_MODULE)
#define BR_SHORTCUT	1
#endif

/*
*#define	CONFIG_RTL_MULTI_LAN_DEV	1
*/

#if defined(CONFIG_POCKET_AP_SUPPORT)
#define	CONFIG_POCKET_ROUTER_SUPPORT
#endif

#if defined(CONFIG_RTL_ETH_PRIV_SKB)
	#if defined(CONFIG_RTL_819X)
		#define MAX_ETH_SKB_NUM	(\
			NUM_RX_PKTHDR_DESC \
			+ NUM_RX_PKTHDR_DESC1 \
			+ NUM_RX_PKTHDR_DESC2 \
			+ NUM_RX_PKTHDR_DESC3 \
			+ NUM_RX_PKTHDR_DESC4 \
			+ NUM_RX_PKTHDR_DESC5 \
			+ MAX_PRE_ALLOC_RX_SKB + 128)
	#else
		#define MAX_ETH_SKB_NUM	(\
			NUM_RX_PKTHDR_DESC \
			+ NUM_RX_PKTHDR_DESC1 \
			+ NUM_RX_PKTHDR_DESC2 \
			+ NUM_RX_PKTHDR_DESC3 \
			+ NUM_RX_PKTHDR_DESC4 \
			+ NUM_RX_PKTHDR_DESC5 \
			+ MAX_PRE_ALLOC_RX_SKB + 256)
	#endif
#define ETH_SKB_BUF_SIZE	(SKB_DATA_ALIGN(CROSS_LAN_MBUF_LEN+sizeof(struct skb_shared_info)+160+NET_SKB_PAD))
#define ETH_MAGIC_CODE		"819X"
#define ETH_MAGIC_LEN		4
#endif

struct re865x_priv
{
	u16			ready;
	u16			addIF;
	u16			devnum;
	u32			sec_count;
	u32			sec;
#if defined(CONFIG_RTK_VLAN_SUPPORT) || defined (CONFIG_RTL_MULTI_LAN_DEV)
	struct	net_device	*dev[ETH_INTF_NUM];
#else
	struct	net_device	*dev[ETH_INTF_NUM];
#endif
#ifdef CONFIG_RTL_STP
	struct	net_device	*stp_port[MAX_RE865X_STP_PORT];
#endif
#if defined(CONFIG_RTL_CUSTOM_PASSTHRU)
	struct	net_device	*pdev;
#endif
	//spinlock_t		lock;
	void			*regs;
	struct tasklet_struct	rx_tasklet;
	struct timer_list timer;	/* Media monitoring timer. */
	unsigned long		linkchg;	
};

struct dev_priv {
	u32			id;            /* VLAN id, not vlan index */
	u32			portmask;     /* member port mask */
	u32			portnum;     	/* number of member ports */
	u32			netinit;
	struct net_device	*dev;
	struct net_device   *dev_prev;
	struct net_device   *dev_next;
#ifdef RX_TASKLET
	struct tasklet_struct   rx_dsr_tasklet;
#endif

#ifdef TX_TASKLET
	struct tasklet_struct   tx_dsr_tasklet;
#endif

	struct tasklet_struct   link_dsr_tasklet;

#if defined(CONFIG_RTK_VLAN_SUPPORT)
	struct vlan_info	vlan_setting;
#endif

#ifdef CP_VLAN_TAG_USED
	struct vlan_group	*vlgrp;
#endif
	spinlock_t			lock;
	u32			msg_enable;
	u32 			opened;
	u32			irq_owner; //record which dev request IRQ
	struct net_device_stats net_stats;
#if defined(DYNAMIC_ADJUST_TASKLET) || defined(CONFIG_RTL8186_TR) || defined(BR_SHORTCUT) || defined(CONFIG_RTL8196C_REVISION_B) || defined(CONFIG_RTL_8198)
    struct timer_list expire_timer; 
#endif

#ifdef CONFIG_RTL8196C_GREEN_ETHERNET
    struct timer_list expire_timer2; 
#endif
};

typedef struct __rtlInterruptRxData
{
	#if defined (CONFIG_RTK_VOIP_QOS) && !defined (CONFIG_RTK_VOIP_ETHERNET_DSP_IS_HOST)
	unsigned long	voip_rx_start_time;
  	int				voip_rx_cnt;
  	#endif
}	rtlInterruptRxData;

/*	define return value		*/
#define	RTL_RX_PROCESS_RETURN_SUCCESS		0
#define	RTL_RX_PROCESS_RETURN_CONTINUE		-1
#define	RTL_RX_PROCESS_RETURN_BREAK		-2


#if defined (CONFIG_RTL_UNKOWN_UNICAST_CONTROL)
#define	RTL_MAC_RECORD_NUM		4	/* Must be 2's orders */
#define	RTL_MAC_THRESHOLD		128	/* threshold for block unkown unicast */
#define	RTL_MAC_TIMEOUT			10*HZ	/* unkown unicast restriction time */
#define	RTL_MAC_REFILL_TOKEN		25000	/* per second refill token number */
typedef	struct __rtlMacRecord
{
	uint8		enable;
	uint8		cnt;
	uint8		mac[ETHER_ADDR_LEN];
	struct timer_list	timer;
}	rtlMacRecord;
#endif

#if defined(RTL819X_PRIV_IOCTL_ENABLE)
#define RTL819X_IOCTL_READ_PORT_STATUS			(SIOCDEVPRIVATE + 0x01)	
#define RTL819X_IOCTL_READ_PORT_STATS	              (SIOCDEVPRIVATE + 0x02)	

struct lan_port_status {
    unsigned char link;
    unsigned char speed;
    unsigned char duplex;
    unsigned char nway;    	
}; 

struct port_statistics  {
	unsigned int  rx_bytes;		
 	unsigned int  rx_unipkts;		
       unsigned int  rx_mulpkts;			
	unsigned int  rx_bropkts;		
 	unsigned int  rx_discard;		
       unsigned int  rx_error;			
	unsigned int  tx_bytes;		
 	unsigned int  tx_unipkts;		
       unsigned int  tx_mulpkts;			
	unsigned int  tx_bropkts;		
 	unsigned int  tx_discard;		
       unsigned int  tx_error;			   
};
#endif

#if defined(CONFIG_RTK_VLAN_SUPPORT) || defined (CONFIG_RTL_MULTI_LAN_DEV)
#define	RTL_LANVLANID_1		9
#define	RTL_LANVLANID_2		10
#define	RTL_LANVLANID_3		11
#define	RTL_LANVLANID_4		12
#define RTL_LANVLANID_5		13
#endif
#define	RTL_PPTPL2TP_VLANID	999

//flowing name in protocol stack DO NOT duplicate
#define RTL_PS_BR0_DEV_NAME RTL_BR_NAME
#define RTL_PS_ETH_NAME	"eth"
#define RTL_PS_WLAN_NAME	RTL_WLAN_NAME
#define RTL_PS_PPP_NAME	"ppp"
#define RTL_PS_LAN_P0_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_ETH_NAME,0)
#define RTL_PS_WAN0_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_ETH_NAME,1)
#define RTL_PS_PPP0_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_PPP_NAME,0)
#define RTL_PS_PPP1_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_PPP_NAME,1)
#define RTL_PS_WLAN0_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_WLAN_NAME,0)
#define RTL_PS_WLAN1_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_WLAN_NAME,1)

#if defined(CONFIG_RTL_MULTIPLE_WAN)
#define RTL_MULTIWAN_ADD 1
#define RTL_MULTIWAN_DEL 2
//#define RTL_PS_WAN1_DEV_NAME RTL_DEV_NAME_NUM(RTL_PS_ETH_NAME,2)
#endif

#if defined(CONFIG_RTL_PUBLIC_SSID)
#define RTL_LAN_DEVICE_NAME "br0"
#define RTL_GW_WAN_DEVICE_NAME "br1"
#define RTL_WISP_WAN_DEVICE_NAME "wlan0"
#define RTL_BR_WAN_DEVICE_NAME "br0"
#endif

//Used by fastpath mac-based qos under IMPROVE_QOS 
#define QOS_LAN_DEV_NAME RTL_PS_BR0_DEV_NAME

#ifdef CONFIG_RTL_LAYERED_DRIVER
struct rtl865x_vlanConfig {
	uint8 			ifname[IFNAMSIZ];
	uint8			isWan;
	uint16			if_type;
	uint16			vid;
	uint16			fid;
	uint32			memPort;
	uint32			untagSet;
	uint32			mtu;
	ether_addr_t		mac;
	uint8			is_slave;
};
#define RTL865X_CONFIG_END					{ "", 0, 0, 0, 0, 0, 0, 0, {{0}}, 0 }

#define GATEWAY_MODE				0
#define BRIDGE_MODE					1
#define WISP_MODE					2
//#define MULTIPLE_VLAN_BRIDGE_MODE 3
//#define MULTIPLE_VLAN_WISP_MODE 4
#define CONFIG_CHECK(expr) do {\
	if(((int32)expr)!=SUCCESS){\
		rtlglue_printf("Error >>> %s:%d failed !\n", __FUNCTION__,__LINE__);\
			return FAILED;\
	}\
}while(0)

#define INIT_CHECK(expr) do {\
	if(((int32)expr)!=SUCCESS){\
		rtlglue_printf("Error >>> %s:%d failed !\n", __FUNCTION__,__LINE__);\
			return FAILED;\
	}\
}while(0)
#endif

typedef struct _ps_drv_netif_mapping_s
{
	uint32 valid:1, //entry enable?
		flags;	//reserverd
	struct net_device *ps_netif; //linux ps network interface
	char drvName[MAX_IFNAMESIZE];//netif name in driver
	
}ps_drv_netif_mapping_t;

int32 rtl865x_changeOpMode(int mode);

#if defined(CONFIG_RTL_ETH_PRIV_SKB)
int is_rtl865x_eth_priv_buf(unsigned char *head);
void free_rtl865x_eth_priv_buf(unsigned char *head);
#endif

ps_drv_netif_mapping_t* rtl_get_ps_drv_netif_mapping_by_psdev(struct net_device *dev);
int rtl_add_ps_drv_netif_mapping(struct net_device *dev, const char *name);
int rtl_del_ps_drv_netif_mapping(struct net_device *dev);

#if defined(CONFIG_RTK_VLAN_SUPPORT) && defined(CONFIG_RTK_VLAN_FOR_CABLE_MODEM)
extern struct net_device* get_dev_by_vid(int vid);
#endif
extern struct net_device *get_shortcut_dev(unsigned char *da);
#define CONFIG_RTL_NIC_HWSTATS

int32 rtl865x_changeOpMode(int mode);

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

#endif
