



#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lsw_api.h"


int main(int argc, char **argv)
{
 int ret;
 printf("how are you..\n");

// rtl8198_set_vlan(8, 0x12f, 0, 0);
// rtl8198_set_vlan(9, 0x12e, 0, 0);  
//rtl8198_set_vlan(1, 0x12f, 0x12f, 0); 
//rtl8198_del_vlan(100); 
//    ret = rtl8198_set_vlan(1, 0x12f, 0x12f, 0); 
/*
    ret = rtl8198_set_port_ingress_filter(0,0);
    ret = rtl8198_set_port_frame_type(0, 0);
    ret = rtl8198_set_port_pvid(0, 1);
*/
// ret = rtl8198_set_port_rate_limit(6, 0, 100*1024);

 //ret = rtl8198_set_cable_mask(1<< 5);

 ret = rtl8198_set_port_priority(0,7);
 ret = rtl8198_set_port_priority(1,7);
 ret = rtl8198_set_port_priority(5,7);
 ret = rtl8198_set_port_priority(8,7);

 printf("done %d\n", ret);

 return 0;
}
