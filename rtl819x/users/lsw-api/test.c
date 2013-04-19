



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
// rtl8198_set_vlan(7, 0x12f, 0x01, 0);  
 ret = rtl8198_set_port_rate_limit(6, 0, 100*1024);

 printf("done %d\n", ret);

 return 0;
}
