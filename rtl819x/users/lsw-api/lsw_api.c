/*
Copyright (c) 2011,  Shenzhen Hexicom Technologies Co., Ltd.
All rights reserved.

File         : lsw_api.c
Status       : Current
Description  :	

Author       : Einsn Liu
Contact      : liuchuansen@hexicomtech.com

Revision     : 2012-09-18
Description  : Primary beta released
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>

#include <rtl_ext_ioctl.h>

#include "lsw_api.h"


#define DBG_ASSERT(bool, fmt, ...) do { if(!(bool)) { fprintf(stderr, "\nFAIL [%s,%s,%d]: " fmt, __FILE__, __FUNCTION__, __LINE__ , ##__VA_ARGS__); fprintf(stderr, "\r\n"); } } while(0)

static const char *local_ifname = "eth0";

static int rtl8198_ext_ioctl(const char *ifname, struct ext_req *req)
{
    int sock, ret;
    struct ifreq ifr;

    sock = socket(AF_INET, SOCK_STREAM, 0);

    if(sock < 0) {
        DBG_ASSERT(0, "socket() return %d", sock);
        return -1;        
    } 

    memset(&ifr, 0, sizeof(struct ifreq));
    strncpy(ifr.ifr_name, ifname, sizeof(ifr.ifr_name) - 1);
    ifr.ifr_data = (void*)req;    
    ret = ioctl(sock, SIOCEXTPRIVATE, &ifr);
    if(ret < 0) {
        DBG_ASSERT(0, "socket() return %d", sock);
        return -1;
    }
    
    close(sock);
    return 0;
}



/* Port Flowctrl */
/* port: 0-5 */
int rtl8198_set_port_flowctrl(uint32_t port, uint32_t rx, uint32_t tx)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_FLOWCTRL;
    req.data.port_simple.pid = port;
    
    if (rx){
        req.data.port_simple.value |= (1 << 0);
    }
    if (tx){
        req.data.port_simple.value |= (1 << 1);
    }

    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);   

    return (ret == 0) ? req.ret : ret;   
}

/* port: 0-5 */
int rtl8198_get_port_flowctrl(uint32_t port, uint32_t *rx, uint32_t *tx)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_FLOWCTRL;
    req.data.port_simple.pid = port;
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);    

    if (rx){
        *rx = (req.data.port_simple.value & 0x01) ? 1 : 0;
    }
    if (tx){
        *tx = (req.data.port_simple.value & 0x02) ? 1 : 0;
    }    
    return (ret == 0) ? req.ret : ret;   
}  

/* Port Speed & duplex */

 /* port: 0-5 */
int rtl8198_set_port_mode(uint32_t port, rtl8198_port_mode_t *mode)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_MODE;
    req.data.port_mode.pid = port;
    req.data.port_mode.force_mode = mode->force_mode;
    req.data.port_mode.force_link = mode->force_link;
    req.data.port_mode.force_speed = mode->force_speed;
    req.data.port_mode.force_duplex = mode->force_duplex;
    req.data.port_mode.capality = mode->capality;
    req.data.port_mode.autoneg = mode->autoneg;
    req.data.port_mode.speed = mode->speed;
    req.data.port_mode.duplex = mode->duplex;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);    
    return (ret == 0) ? req.ret : ret;   
}

/* port: 0-5 */
int rtl8198_get_port_mode(uint32_t port, rtl8198_port_mode_t *mode)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_MODE;
    req.data.port_mode.pid = port;
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);
    if (!ret && !req.ret && mode){
        mode->force_mode = req.data.port_mode.force_mode;
        mode->force_link = req.data.port_mode.force_link;
        mode->force_speed = req.data.port_mode.force_speed;
        mode->force_duplex = req.data.port_mode.force_duplex;
        mode->capality = req.data.port_mode.capality;
        mode->autoneg = req.data.port_mode.autoneg;
        mode->speed = req.data.port_mode.speed;
        mode->duplex = req.data.port_mode.duplex;
    }
    
    return (ret == 0) ? req.ret : ret;   
}

/* Port shutdown */
/* port: 0-5 */
int rtl8198_set_port_enable(uint32_t port, uint32_t enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_ENABLE;
    req.data.port_simple.pid = port;
    req.data.port_simple.value = enable;
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);
    
    return (ret == 0) ? req.ret : ret;   
}

/* port: 0-5 */
int rtl8198_get_port_enable(uint32_t port, uint32_t *enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_ENABLE;
    req.data.port_simple.pid = port;
    ret = rtl8198_ext_ioctl(local_ifname, &req);
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);

    if (!ret && !req.ret && enable){
        *enable = req.data.port_simple.value;
    }
    
    return (ret == 0) ? req.ret : ret;   
}   

/* Port RateLimit */   
/* port 0 - 5 */
/* unit turn to 1 kbps 0 -disabled */
int rtl8198_set_port_rate_limit(uint32_t port, uint32_t ingress_rate, uint32_t egress_rate)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_RATELIMIT;
    req.data.port_rate.pid = port;
    /* ingress_rate unit 16Kbps 0 disable */
    /* egress_rate unit 64Kbps  3FFF disable */    
    req.data.port_rate.ingress_rate = ingress_rate / 16;
    if (egress_rate == 0){
       req.data.port_rate.egress_rate = 0x3fff;   
    }else {
       req.data.port_rate.egress_rate = egress_rate / 64; 
    }    
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_rate_limit(uint32_t port, uint32_t *ingress_rate, uint32_t *egress_rate)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_RATELIMIT;
    req.data.port_rate.pid = port;
    /* ingress_rate unit 16Kbps 0 disable */
    /* egress_rate unit 64Kbps  3FFF disable */  
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);    
    if (!ret && !req.ret){
        if (ingress_rate){
            *ingress_rate = req.data.port_rate.ingress_rate * 16;
        }
        if (egress_rate){
            if (req.data.port_rate.egress_rate == 0x3fff){
                *egress_rate = 0;
            }else {
                *egress_rate = req.data.port_rate.egress_rate * 64;
            }
        }
    }
    
    return (ret == 0) ? req.ret : ret;   
}

/* Port MIBs */
/* port : 0 - 8 */
int rtl8198_reset_port_counters(uint32_t port, uint32_t reset_in, uint32_t reset_out)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_RESET_MIB_COUNTER;
    req.data.mib_counter.pid = port;
    req.data.mib_counter.reset_in = reset_in;
    req.data.mib_counter.reset_out = reset_out;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);      
    return (ret == 0) ? req.ret : ret;   
}

/* port : 0 - 8 */
int rtl8198_get_port_counters(uint32_t port, uint64_t *mibs)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_MIB_COUNTER;
    req.data.mib_counter.pid = port;
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && mibs){
        /* In */
        mibs[RTLMIBS_IfInOctets] =                    req.data.mib_counter.counters.ifInOctets;
        mibs[RTLMIBS_IfInUcastPkts] =                 req.data.mib_counter.counters.ifInUcastPkts;
        mibs[RTLMIBS_EtherStatsOctets] =              req.data.mib_counter.counters.etherStatsOctets;
        mibs[RTLMIBS_EtherStatsUnderSizePkts] =       req.data.mib_counter.counters.etherStatsUndersizePkts;
        mibs[RTLMIBS_EtherStatsFragments] =           req.data.mib_counter.counters.etherStatsFraments;
        mibs[RTLMIBS_EtherStatsPkts64Octets] =        req.data.mib_counter.counters.etherStatsPkts64Octets;
        mibs[RTLMIBS_EtherStatsPkts65to127Octets] =   req.data.mib_counter.counters.etherStatsPkts65to127Octets;
        mibs[RTLMIBS_EtherStatsPkts128to255Octets] =  req.data.mib_counter.counters.etherStatsPkts128to255Octets;
        mibs[RTLMIBS_EtherStatsPkts256to511Octets] =  req.data.mib_counter.counters.etherStatsPkts256to511Octets;
        mibs[RTLMIBS_EtherStatsPkts512to1023Octets] = req.data.mib_counter.counters.etherStatsPkts512to1023Octets;
        mibs[RTLMIBS_EtherStatsPkts1024to1518Octets] = req.data.mib_counter.counters.etherStatsPkts1024to1518Octets;
        mibs[RTLMIBS_EtherOversizeStats] =            req.data.mib_counter.counters.etherStatsOversizePkts;
        mibs[RTLMIBS_EtherStatsJabbers] =             req.data.mib_counter.counters.etherStatsJabbers;
        mibs[RTLMIBS_EtherStatsMulticastPkts] =       req.data.mib_counter.counters.etherStatsMulticastPkts;
        mibs[RTLMIBS_EtherStatsBroadcastPkts] =       req.data.mib_counter.counters.etherStatsBroadcastPkts;
        mibs[RTLMIBS_Dot1dTpPortInDiscards] =         req.data.mib_counter.counters.dot1dTpPortInDiscards;
        mibs[RTLMIBS_EtherStatsDropEvents] =          req.data.mib_counter.counters.etherStatusDropEvents;
        mibs[RTLMIBS_Dot3StatsFCSErrors] =            req.data.mib_counter.counters.dot3FCSErrors;
        mibs[RTLMIBS_Dot3StatsSymbolErrors] =         req.data.mib_counter.counters.dot3StatsSymbolErrors;
        mibs[RTLMIBS_Dot3ControlInUnknownOpcodes] =   req.data.mib_counter.counters.dot3ControlInUnknownOpcodes;
        mibs[RTLMIBS_Dot3InPauseFrames] =             req.data.mib_counter.counters.dot3InPauseFrames;
        /* Out */
        mibs[RTLMIBS_IfOutOctets] =                   req.data.mib_counter.counters.ifOutOctets;
        mibs[RTLMIBS_IfOutUcastPkts] =                req.data.mib_counter.counters.ifOutUcastPkts;
        mibs[RTLMIBS_IfOutMulticastPkts] =            req.data.mib_counter.counters.ifOutMulticastPkts;
        mibs[RTLMIBS_IfOutBroadcastPkts] =            req.data.mib_counter.counters.ifOutBroadcastPkts;
        mibs[RTLMIBS_Dot1dTpPortInDiscards] =         req.data.mib_counter.counters.ifOutDiscards;
        mibs[RTLMIBS_Dot3StatsSingleCollisionFrames] =   req.data.mib_counter.counters.dot3StatsSingleCollisionFrames;
        mibs[RTLMIBS_Dot3StatsMultipleCollisionFrames] = req.data.mib_counter.counters.dot3StatsMultipleCollisionFrames;
        mibs[RTLMIBS_Dot3StatsDeferredTransmissions] =   req.data.mib_counter.counters.dot3StatsDefferedTransmissions;
        mibs[RTLMIBS_Dot3StatsLateCollisions] =       req.data.mib_counter.counters.dot3StatsLateCollisions;
        mibs[RTLMIBS_Dot3StatsExcessiveCollisions] =  req.data.mib_counter.counters.dot3StatsExcessiveCollisions;
        mibs[RTLMIBS_Dot3OutPauseFrames] =            req.data.mib_counter.counters.dot3OutPauseFrames;
        mibs[RTLMIBS_Dot1dBasePortDelayExceededDiscards] =  req.data.mib_counter.counters.dot1dBasePortDelayExceededDiscards;
        mibs[RTLMIBS_EtherStatsCollisions] =          req.data.mib_counter.counters.etherStatsCollisions;
        /* System */
        mibs[RTLMIBS_InOampduPkts] =                  req.data.mib_counter.counters.dot1dTpLearnedEntryDiscards;
        mibs[RTLMIBS_PktgenPkts] =                    req.data.mib_counter.counters.etherStatsCpuEventPkts;    
    }
    return (ret == 0) ? req.ret : ret;   
}

/* Port Link Status */
/* port : 0 - 8 */
int rtl8198_get_port_link_status(uint32_t port, uint32_t *link, uint32_t *speed, uint32_t *duplex)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_LINK_STATUS;
    req.data.port_status.pid = port;    
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);   
    if (!ret && !req.ret){
        if (link) *link = req.data.port_status.link;
        if (speed) *speed = req.data.port_status.speed;
        if (duplex) *duplex = req.data.port_status.duplex;        
    }
    return (ret == 0) ? req.ret : ret;   
}


/* Port PVID */

int rtl8198_set_port_pvid(uint32_t port, uint32_t pvid)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PVID;
    req.data.port_simple.pid = port;
    req.data.port_simple.value = pvid;
    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);      
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_pvid(uint32_t port, uint32_t *pvid)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PVID;
    req.data.port_simple.pid = port;
    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && pvid){
        *pvid = req.data.port_simple.value;
    }
    return (ret == 0) ? req.ret : ret;   
}   

/* Port Priority */

int rtl8198_set_port_priority(uint32_t port, uint32_t priority)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_PRIOPRITY;
    req.data.port_simple.pid = port;
    req.data.port_simple.value = priority;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_priority(uint32_t port, uint32_t *priority)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_PRIOPRITY;
    req.data.port_simple.pid = port;

    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && priority){
        *priority = req.data.port_simple.value;
    }    
    return (ret == 0) ? req.ret : ret;   
}

/* Port Accept Fram type */

int rtl8198_set_port_frame_type(uint32_t port, uint32_t frame_type)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_FRAME_TYPE;
    req.data.port_simple.pid = port;
    req.data.port_simple.value = frame_type;

    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_frame_type(uint32_t port, uint32_t *frame_type)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_FRAME_TYPE;
    req.data.port_simple.pid = port;

    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && frame_type){
        *frame_type = req.data.port_simple.value;
    }     
    return (ret == 0) ? req.ret : ret;   
}

/* Port IngressFilter */

int rtl8198_set_port_ingress_filter(uint32_t port, uint32_t enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_INGRESS_FILTER;
    req.data.port_simple.pid = port;
    req.data.port_simple.value = enable;

    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_ingress_filter(uint32_t port, uint32_t *enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_INGRESS_FILTER;
    req.data.port_simple.pid = port;

    ret = rtl8198_ext_ioctl(local_ifname, &req);
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && enable){
        *enable = req.data.port_simple.value;
    }   
    
    return (ret == 0) ? req.ret : ret;   
}

/* VLAN Tag ignore */

int rtl8198_set_vlan_tag_ignore(uint32_t enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_VLAN_TAG_IGNORE;
    req.data.value = enable;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_vlan_tag_ignore(uint32_t *enable)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_VLAN_TAG_IGNORE;

    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret && enable){
        *enable = req.data.value;
    } 
    
    return (ret == 0) ? req.ret : ret;   
}

/* VLAN */


int rtl8198_set_vlan(uint32_t vlan, uint32_t port_mask, uint32_t untag_mask, uint32_t fid)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_VLAN;
    req.data.vlan.vid = vlan;
    req.data.vlan.port_mask = port_mask;
    req.data.vlan.untag_mask = untag_mask;
    req.data.vlan.fid = fid;
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;
}

int rtl8198_get_vlan(uint32_t vlan, uint32_t *port_mask, uint32_t *untag_mask, uint32_t *fid)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_VLAN;
    req.data.vlan.vid = vlan;
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret){
        if (port_mask) *port_mask = req.data.vlan.port_mask;
        if (untag_mask) *untag_mask = req.data.vlan.untag_mask;
        if (fid) *fid = req.data.vlan.fid;      
    }     
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_del_vlan(uint32_t vlan)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_DEL_VLAN;
    req.data.vlan.vid = vlan;

    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}    

/* Port Mirror */
/* port : 0- 8 */
int rtl8198_set_port_mirror(uint32_t rx_ports, uint32_t tx_ports, uint32_t monitor_ports)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_MIRROR;
    req.data.port_mirror.rx_mask = rx_ports;
    req.data.port_mirror.tx_mask = tx_ports;
    req.data.port_mirror.dest_mask = monitor_ports;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_mirror(uint32_t *rx_ports, uint32_t *tx_ports, uint32_t *monitor_ports)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_MIRROR;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    if (!ret && !req.ret){
        if (rx_ports) *rx_ports = req.data.port_mirror.rx_mask;
        if (tx_ports) *tx_ports = req.data.port_mirror.tx_mask;
        if (monitor_ports) *monitor_ports = req.data.port_mirror.dest_mask;      
    }        
    return (ret == 0) ? req.ret : ret;   
}   
/* Port Storm */
/* port: 0-8 */
int rtl8198_set_port_storm(uint32_t port, uint32_t rate, uint32_t bcast_en, uint32_t mcast_en, uint32_t ucast_en)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_STORM;
    req.data.port_storm.pid = port;
    req.data.port_storm.rate = rate;
    req.data.port_storm.broadcast = bcast_en;
    req.data.port_storm.multicast = mcast_en;
    req.data.port_storm.unicast = ucast_en;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

/* port: 0-8 */
int rtl8198_get_port_storm(uint32_t port, uint32_t *rate, uint32_t *bcast_en, uint32_t *mcast_en, uint32_t *ucast_en)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_STORM;
    req.data.port_storm.pid = port;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  

    if (!ret && !req.ret){
        if (rate) *rate = req.data.port_storm.rate;
        if (bcast_en) *bcast_en = req.data.port_storm.broadcast;
        if (mcast_en) *mcast_en = req.data.port_storm.multicast;      
        if (ucast_en) *ucast_en = req.data.port_storm.unicast;        
    } 
    
    return (ret == 0) ? req.ret : ret;   
}

/* PHY operation */

int rtl8198_set_phy_register(uint32_t phy, uint32_t reg, uint32_t data)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PHY_REG;
    req.data.phy_reg.phy = phy;
    req.data.phy_reg.phy = reg;    
    req.data.phy_reg.data = data;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_phy_register(uint32_t phy, uint32_t reg, uint32_t *data)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PHY_REG;

    ret = rtl8198_ext_ioctl(local_ifname, &req);   
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    if (!ret && !req.ret){
        if (data) *data = req.data.phy_reg.data;
    }     
    return (ret == 0) ? req.ret : ret;   
}

/* Port pattern */

int rtl8198_set_port_pattern(uint32_t port, uint32_t pattern, uint32_t pattern_mask, uint32_t operation)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_PORT_PATTERN;
    req.data.port_pattern.pid = port;
    req.data.port_pattern.pattern = pattern;
    req.data.port_pattern.pattern_mask = pattern_mask;    
    req.data.port_pattern.pattern = operation;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_port_pattern(uint32_t port, uint32_t *pattern, uint32_t *pattern_mask, uint32_t *operation)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_PORT_PATTERN;
    req.data.port_pattern.pid = port;

    ret = rtl8198_ext_ioctl(local_ifname, &req);
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    if (!ret && !req.ret){
        if (pattern) *pattern = req.data.port_pattern.pattern;
        if (pattern_mask) *pattern_mask = req.data.port_pattern.pattern_mask;    
        if (operation) *operation = req.data.port_pattern.pattern;
    }      
    return (ret == 0) ? req.ret : ret;   
}


int rtl8198_set_cable_mask(uint32_t cable_mask)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_CABLE_MASK;
    req.data.value = cable_mask;

    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_cable_mask(uint32_t *cable_mask)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_CABLE_MASK;
    ret = rtl8198_ext_ioctl(local_ifname, &req); 
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  

    if (!ret && !req.ret){
        if (cable_mask) *cable_mask = req.data.value;
    }
        
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_set_mgmt_vlan(uint32_t vlan_mode, uint32_t mgmt_vlan, uint32_t mgmt_pri, uint32_t mgmt_ports)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_SET_MGMT_VLAN;
    req.data.mgmt_vlan.mode = vlan_mode;
    req.data.mgmt_vlan.vlan = mgmt_vlan;
    req.data.mgmt_vlan.pri = mgmt_pri;
    req.data.mgmt_vlan.port_mask = mgmt_ports;
    
    ret = rtl8198_ext_ioctl(local_ifname, &req);    
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  
    
    return (ret == 0) ? req.ret : ret;   
}

int rtl8198_get_mgmt_vlan(uint32_t *vlan_mode, uint32_t *mgmt_vlan, uint32_t *mgmt_pri, uint32_t *mgmt_ports)
{
    int ret;
    struct ext_req req;
    memset(&req, 0, sizeof(req));
    req.cmd = EXT_CMD_GET_MGMT_VLAN;

    ret = rtl8198_ext_ioctl(local_ifname, &req);  
    DBG_ASSERT((!ret && !req.ret), "ret: %d, req.ret:%d", ret, req.ret);  

    if (!ret && !req.ret){
        if (vlan_mode) *vlan_mode = req.data.mgmt_vlan.mode;
        if (mgmt_vlan) *mgmt_vlan = req.data.mgmt_vlan.vlan;
        if (mgmt_pri) *mgmt_pri = req.data.mgmt_vlan.pri;
        if (mgmt_ports) *mgmt_ports = req.data.mgmt_vlan.port_mask;    
    }
    
    return (ret == 0) ? req.ret : ret;   
}




