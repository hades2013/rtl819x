

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>

#include <rtl_ext_ioctl.h>

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
    return (ret == 0) ? req.ret : ret;
}



