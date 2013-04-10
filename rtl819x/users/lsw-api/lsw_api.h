#ifndef __LSW_API_H__
#define __LSW_API_H__

#include <stdint.h>

int rtl8198_set_vlan(uint32_t vlan, uint32_t port_mask, uint32_t untag_mask, uint32_t fid);


#endif /* __LSW_API_H__ */
