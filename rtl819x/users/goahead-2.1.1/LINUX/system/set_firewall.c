/*
 *      Utiltiy function for setting firewall filter
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include <arpa/inet.h>

#include "../apmib.h"
#include "sysconf.h"
#include "sys_utility.h"
int setFirewallIptablesRules(int argc, char** argv);
char Iptables[]="iptables";
char INPUT[]= "INPUT";
char OUTPUT[]= "OUTPUT";
char FORWARD[]= "FORWARD";
char PREROUTING[]="PREROUTING";
char POSTROUTING[]= "POSTROUTING";
char ACCEPT[]= "ACCEPT";
char DROP[]= "DROP";
char RET[]= "RETURN";
char LOG[]= "LOG";
char MASQUERADE[]="MASQUERADE";
char REDIRECT[]="REDIRECT";
char MARK[]="MARK";
// iptables operations, manupilations, matches, options etc.
char ADD[]= "-A";
char DEL[]= "-D";
char FLUSH[]= "-F";
char INSERT[]="-I";
char NEW[]= "-N";
char POLICY[]= "-P";
char X[]= "-X";
char Z[]= "-Z";
char _dest[]= "-d";
char in[]= "-i";
char jump[]= "-j";
char match[]= "-m";
char out[]= "-o";
char _protocol[]= "-p";
char _src[]= "-s";
char _table[]= "-t";
char nat_table[]= "nat";
char mangle_table[]= "mangle";
char NOT[]= "!";
char _mac[]= "mac";
char mac_src[]= "--mac-source";
char mac_dst[]= "--mac-destination";
char dport[]= "--dport";
char sport[]= "--sport";
char syn[]= "--syn";
char ALL[]= "ALL";
char DNAT[]= "DNAT";
char icmp_type[]="--icmp-type";
char echo_request[]="echo-request";
char echo_reply[]="echo-reply";
char mstate[]="state";
char state[]="--state";
char _udp[]="udp";
char _tcp[]="tcp";
char _icmp[]="icmp";
char RELATED_ESTABLISHED[]= "RELATED,ESTABLISHED";
char tcp_flags[]="--tcp-flags";
char MSS_FLAG1[]="SYN,RST";
char MSS_FLAG2[]="SYN";
char clamp[]="--clamp-mss-to-pmtu";
char TCPMSS[]="TCPMSS";
char ip_range[]="iprange";
char src_rnage[]="--src-range";
char dst_rnage[]="--dst-range";
char set_mark[]="--set-mark";

static const char _tc[] = "tc";
static const char _qdisc[] = "qdisc";
static const char _add[] = "add";
static const char _dev[] = "dev";
static const char _root[] = "root";
static const char _handle[] = "handle";
static const char _htb[] = "htb";
static const char _default[] = "default";
static const char _classid[] = "classid";
static const char _rate[] = "rate";
static const char _ceil[] = "ceil";
static const char _sfq[] = "sfq";
static const char _perturb[] = "perturb";
static const char _class[] = "class";
static const char _filter[] = "filter";
static const char _protocol2[] = "protocol";
static const char _ip[] = "ip";
static const char _prio[] = "prio";
static const char _fw[] = "fw";
static const char _parent[] = "parent";
static const char _quantum[] = "quantum";
static const char _r2q[] = "r2q";

extern int apmib_initialized;
extern int getInAddr( char *interface, int type, void *pAddr );
extern int isFileExist(char *file_name);


#ifdef CONFIG_RTK_VOIP
int set_voip_parameter(char* pInterface){

	int slic_number = 0;
	int dect_number = 0;
	int fxo_number = 0;
	char rtp_port[20]={0};
	char sip_port[10]={0};
	int index;
	voipCfgParam_t  voipCfgParam;


	printf("int set_voip_parameter....\n");
	apmib_get(MIB_VOIP_CFG, (void*)&voipCfgParam);
	slic_number = SLIC_CH_NUM;

	dect_number = DECT_CH_NUM;

	fxo_number = DAA_CH_NUM;

	for(index = 0; index < slic_number+dect_number+fxo_number; index++){
		//iptables -A INPUT -i eth1 -p udp --dport 5060 -j ACCEPT
		sprintf(sip_port,"%d", voipCfgParam.ports[index].sip_port);
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, in, pInterface, _protocol, _udp, dport,sip_port ,jump,ACCEPT, NULL_STR);

		// iptables -I PREROUTING -t nat -i eth1 -p udp --dport 5060 -j ACCEPT
		RunSystemCmd(NULL_FILE, Iptables, INSERT, PREROUTING, _table, nat_table , in, pInterface, _protocol, _udp, dport,sip_port ,jump,ACCEPT, NULL_STR);

		sprintf(rtp_port,"%d:%d",voipCfgParam.ports[index].media_port,voipCfgParam.ports[index].media_port+3);
		//iptables -I PREROUTING -t nat -i eth1 -p udp --dport 9000:9003 -j ACCEPT
		RunSystemCmd(NULL_FILE, Iptables, INSERT, PREROUTING, _table, nat_table , in, pInterface, _protocol, _udp, dport, rtp_port ,jump,ACCEPT, NULL_STR);
	}


	#ifdef CONFIG_RTL_HARDWARE_NAT
		//printf("hw_nat %d \n", voipCfgParam.hwnat_enable);
		if(voipCfgParam.hwnat_enable)
			RunSystemCmd("/proc/hw_nat", "echo", "1", NULL_STR);
		else
			RunSystemCmd("/proc/hw_nat", "echo", "0", NULL_STR);
	#endif
}
#endif


int set_QoS(int operation, int wan_type, int wisp_wan_id)
{
#ifdef   HOME_GATEWAY
	char *br_interface="br0";
	char tmp_args[32]={0}, tmp_args1[32]={0}, tmp_args2[32]={0};
	char tmp_args3[64]={0}, tmp_args4[32]={0};
	char *tmpStr=NULL;
	int wan_pkt_mark=13, lan_pkt_mark=53;
	char iface[20], *pInterface="eth1", *pInterface2=NULL;
	int i, QoS_Enabled=0;
	int QoS_Auto_Uplink=0, QoS_Manual_Uplink=0;
	int QoS_Auto_Downlink=0, QoS_Manual_Downlink=0;
	int QoS_Rule_EntryNum=0;
	char PROC_QOS[128]={0};
	int uplink_speed=102400, downlink_speed=102400;
	IPQOS_T entry;
	int get_wanip=0;
	struct in_addr wanaddr;

#ifdef CONFIG_RTL_8198
	uplink_speed=1024000;
	downlink_speed=1024000;
#endif

	RunSystemCmd(NULL_FILE, Iptables, FLUSH, _table, mangle_table, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, X, _table, mangle_table, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, Z, _table, mangle_table, NULL_STR);
	if(operation == WISP_MODE){
		sprintf(iface, "wlan%d", wisp_wan_id);
		pInterface = iface;
		if (wan_type == PPPOE || wan_type == PPTP /*|| wan_type == L2TP */)
				pInterface="ppp0";
	}else{
		if(operation == GATEWAY_MODE){
			if (wan_type == PPPOE || wan_type == PPTP || wan_type == USB3G /*|| wan_type == L2TP*/)
				pInterface="ppp0";
		}
	}

	if(wan_type == L2TP)//wantype is l2tp
		pInterface2="ppp0";

	get_wanip = getInAddr(pInterface, IP_ADDR_T, (void *)&wanaddr);
	if( get_wanip ==0){   //get wan ip fail
		printf("No wan ip currently!\n");
		return 0;
	}

	apmib_get( MIB_QOS_ENABLED, (void *)&QoS_Enabled);
	apmib_get( MIB_QOS_AUTO_UPLINK_SPEED, (void *)&QoS_Auto_Uplink);
	apmib_get( MIB_QOS_MANUAL_UPLINK_SPEED, (void *)&QoS_Manual_Uplink);
	apmib_get( MIB_QOS_MANUAL_DOWNLINK_SPEED, (void *)&QoS_Manual_Downlink);
	apmib_get( MIB_QOS_AUTO_DOWNLINK_SPEED, (void *)&QoS_Auto_Downlink);
	apmib_get( MIB_QOS_RULE_TBL_NUM, (void *)&QoS_Rule_EntryNum);

	RunSystemCmd(NULL_FILE, "tc", "qdisc", "del", "dev", br_interface, "root", NULL_STR);

	//To avoid rule left when wan changed
	RunSystemCmd(NULL_FILE, "tc", "qdisc", "del", "dev", "eth1", "root", NULL_STR);
	RunSystemCmd(NULL_FILE, "tc", "qdisc", "del", "dev", "ppp0", "root", NULL_STR);

	if((strcmp(pInterface, "eth1")!=0)&&(strcmp(pInterface, "ppp0")!=0))
		RunSystemCmd(NULL_FILE, "tc", "qdisc", "del", "dev", pInterface, "root", NULL_STR);

	sprintf(PROC_QOS, "%s", "0,");

	if(QoS_Enabled==1){
		sprintf(PROC_QOS, "%s", "1,");
	}

	// echo /proc/qos should before tc rules because of qos patch (CONFIG_RTL_QOS_PATCH in kernel)
	RunSystemCmd("/proc/qos", "echo", PROC_QOS, NULL_STR);

	if(QoS_Enabled==1){
		if(QoS_Auto_Uplink==0){
			uplink_speed=QoS_Manual_Uplink;
			if(uplink_speed < 100)
				uplink_speed=100;
		}

		// patch for uplink QoS accuracy
#if 0
#ifdef CONFIG_RTL_8198
		if(uplink_speed > 160000)
			uplink_speed=160000;
#else
		if(uplink_speed > 75000)
			uplink_speed=75000;
#endif
#endif

		if(QoS_Auto_Downlink==0){
			downlink_speed=QoS_Manual_Downlink;
			if(downlink_speed < 100)
				downlink_speed=100;
		}
		// patch for downlink QoS accuracy
#if 0
#ifdef CONFIG_RTL_8198
		if(downlink_speed > 130000)
			downlink_speed=130000;
#else
		if(downlink_speed > 70000)
			downlink_speed=70000;
#endif
#endif

		/* total bandwidth section--uplink*/
		RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface, _root, _handle, "2:0", _htb, _default, "2", _r2q, "64", NULL_STR);
		//tc qdisc add dev $WAN root handle 2:0 htb default 2 r2q 64
		sprintf(tmp_args, "%dkbit", uplink_speed);
		RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface, _parent, "2:0", _classid, "2:1", _htb, _rate, tmp_args, _ceil, tmp_args,  _quantum, "30000", NULL_STR);
		//TC_CMD="tc class add dev $WAN parent 2:0 classid 2:1 htb rate ${UPLINK_SPEED}kbit ceil ${UPLINK_SPEED}kbit"
		RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface, _parent, "2:1", _classid, "2:2", _htb, _rate, "1kbit", _ceil, tmp_args, _prio, "256",  _quantum, "30000", NULL_STR);
    		//TC_CMD="tc class add dev $WAN parent 2:1 classid 2:2 htb rate 1kbit ceil ${UPLINK_SPEED}kbit prio 256 quantum 30000"
    		RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface, _parent, "2:2", _handle, "102:", _sfq, _perturb, "10", NULL_STR);
    		//TC_CMD="tc qdisc add dev $WAN parent 2:2 handle 102: sfq perturb 10"

#if 1
		if((pInterface2!=NULL)&&strcmp(pInterface2, "ppp0")==0)//wantype is l2tp
		{
			RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface2, _root, _handle, "3:0", _htb, _default, "2", _r2q, "64", NULL_STR);
			//tc qdisc add dev $WAN2 root handle 3:0 htb default 2 r2q 64
			sprintf(tmp_args, "%dkbit", uplink_speed);
			RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface2, _parent, "3:0", _classid, "3:1", _htb, _rate, tmp_args, _ceil, tmp_args,  _quantum, "30000", NULL_STR);
			//TC_CMD="tc class add dev $WAN2 parent 3:0 classid 3:1 htb rate ${UPLINK_SPEED}kbit ceil ${UPLINK_SPEED}kbit"
			RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface2, _parent, "3:1", _classid, "3:2", _htb, _rate, "1kbit", _ceil, tmp_args, _prio, "256",  _quantum, "30000", NULL_STR);
	    		//TC_CMD="tc class add dev $WAN2 parent 3:1 classid 3:2 htb rate 1kbit ceil ${UPLINK_SPEED}kbit prio 256 quantum 30000"
	    		RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface2, _parent, "3:2", _handle, "302:", _sfq, _perturb, "10", NULL_STR);
	    		//TC_CMD="tc qdisc add dev $WAN2 parent 3:2 handle 302: sfq perturb 10"
		}
#endif

		/* total bandwidth section--downlink*/
    		RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, br_interface, _root, _handle, "5:0", _htb, _default, "2", _r2q, "64",NULL_STR);
    		//tc qdisc add dev $BRIDGE root handle 5:0 htb default 5 r2q 64
    		sprintf(tmp_args, "%dkbit", downlink_speed);
    		RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, br_interface, _parent, "5:0", _classid, "5:1", _htb, _rate, tmp_args, _ceil, tmp_args,  _quantum, "30000", NULL_STR);
    		//TC_CMD="tc class add dev $BRIDGE parent 5:0 classid 5:1 htb rate ${DOWNLINK_SPEED}kbit ceil ${DOWNLINK_SPEED}kbit"
    		RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, br_interface, _parent, "5:1", _classid, "5:2", _htb, _rate, "1kbit", _ceil, tmp_args, _prio, "256", _quantum, "30000", NULL_STR);
		//TC_CMD="tc class add dev $BRIDGE parent 5:1 classid 5:5 htb rate 1kbit ceil ${DOWNLINK_SPEED}kbit prio 256 quantum 30000"
		RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, br_interface, _parent, "5:2", _handle, "502:", _sfq, _perturb, "10", NULL_STR);
		//TC_CMD="tc qdisc add dev $BRIDGE parent 5:5 handle 502: sfq perturb 10"
//		sprintf(PROC_QOS, "%s", "1,");

		if(QoS_Rule_EntryNum > 0){
			for (i=1; i<=QoS_Rule_EntryNum; i++) {
				*((char *)&entry) = (char)i;
				apmib_get(MIB_QOS_RULE_TBL, (void *)&entry);
				if(entry.enabled > 0){
					if(entry.bandwidth > 0){/*UPlink*/
						sprintf(tmp_args, "%d", wan_pkt_mark);

						if(entry.mode == 5 || entry.mode == 6){
							/*this qos rule is set by IP address*/
							tmpStr = inet_ntoa(*((struct in_addr *)entry.local_ip_start));
							sprintf(tmp_args1, "%s", tmpStr);
							tmpStr = inet_ntoa(*((struct in_addr *)entry.local_ip_end));
							sprintf(tmp_args2, "%s", tmpStr);
							sprintf(tmp_args3, "%s-%s",tmp_args1, tmp_args2);

							RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, mangle_table , match, ip_range, src_rnage, tmp_args3, jump, MARK,  set_mark, tmp_args, NULL_STR);
						}else{
							sprintf(tmp_args3, "%02x:%02x:%02x:%02x:%02x:%02x",entry.mac[0], entry.mac[1], entry.mac[2], entry.mac[3], entry.mac[4], entry.mac[5]);
							RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, mangle_table , match, _mac, mac_src, tmp_args3, jump, MARK, set_mark, tmp_args, NULL_STR);
						}

						sprintf(tmp_args1, "2:%d", wan_pkt_mark);
						sprintf(tmp_args2, "%ldkbit", entry.bandwidth);
						sprintf(tmp_args3, "%dkbit", uplink_speed);
						sprintf(tmp_args4, "1%d:", wan_pkt_mark);
						if(entry.mode == 5 || entry.mode == 9){
							RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface, _parent, "2:1", _classid, tmp_args1, _htb, _rate, tmp_args2, _ceil, tmp_args3, _prio, "2",  _quantum, "30000",NULL_STR);
							//TC_CMD="tc class add dev $WAN parent 2:1 classid 2:$wan_pkt_mark htb rate ${bandwidth}kbit ceil ${UPLINK_SPEED}kbit prio 2 quantum 30000"
						}else{
							RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface, _parent, "2:1", _classid, tmp_args1, _htb, _rate, "1kbit", _ceil, tmp_args2, _prio, "2" , _quantum, "30000", NULL_STR);
							//TC_CMD="tc class add dev $WAN parent 2:1 classid 2:$wan_pkt_mark htb rate 1kbit ceil ${bandwidth}kbit prio 2 quantum 30000"
						}

						RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface, _parent, tmp_args1, _handle, tmp_args4, _sfq, _perturb, "10", NULL_STR);
						//TC_CMD="tc qdisc add dev $WAN parent 2:$wan_pkt_mark handle 1$wan_pkt_mark: sfq perturb 10"

						RunSystemCmd(NULL_FILE, _tc, _filter, _add, _dev, pInterface, _parent, "2:0", _protocol2, _ip, _prio, "100", _handle, tmp_args, _fw, _classid, tmp_args1, NULL_STR);
						//TC_CMD="tc filter add dev $WAN parent 2:0 protocol ip prio 100 handle $wan_pkt_mark fw classid 2:$wan_pkt_mark"

#if 1
						sprintf(tmp_args1, "3:%d", wan_pkt_mark);
						sprintf(tmp_args2, "%ldkbit", entry.bandwidth);
						sprintf(tmp_args3, "%dkbit", uplink_speed);
						sprintf(tmp_args4, "3%d:", wan_pkt_mark);
						if((pInterface2!=NULL)&&strcmp(pInterface2, "ppp0")==0)//wantype is l2tp
						{
							if(entry.mode == 5 || entry.mode == 9){
								RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface2, _parent, "3:1", _classid, tmp_args1, _htb, _rate, tmp_args2, _ceil, tmp_args3, _prio, "2",  _quantum, "30000",NULL_STR);
								//TC_CMD="tc class add dev $WAN2 parent 3:1 classid 3:$wan_pkt_mark htb rate ${bandwidth}kbit ceil ${UPLINK_SPEED}kbit prio 2 quantum 30000"
							}else{
								RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, pInterface2, _parent, "3:1", _classid, tmp_args1, _htb, _rate, "1kbit", _ceil, tmp_args2, _prio, "2" , _quantum, "30000", NULL_STR);
								//TC_CMD="tc class add dev $WAN2 parent 3:1 classid 3:$wan_pkt_mark htb rate 1kbit ceil ${bandwidth}kbit prio 2 quantum 30000"
							}

							RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, pInterface2, _parent, tmp_args1, _handle, tmp_args4, _sfq, _perturb, "10", NULL_STR);
							//TC_CMD="tc qdisc add dev $WAN2 parent 3:$wan_pkt_mark handle 3$wan_pkt_mark: sfq perturb 10"

							RunSystemCmd(NULL_FILE, _tc, _filter, _add, _dev, pInterface2, _parent, "3:0", _protocol2, _ip, _prio, "100", _handle, tmp_args, _fw, _classid, tmp_args1, NULL_STR);
							//TC_CMD="tc filter add dev $WAN2 parent 3:0 protocol ip prio 100 handle $wan_pkt_mark fw classid 3:$wan_pkt_mark"
						}
#endif

						wan_pkt_mark = wan_pkt_mark+1;
					}

					if(entry.bandwidth_downlink > 0){/*DOWNlink*/
						sprintf(tmp_args, "%d", lan_pkt_mark);
						if(entry.mode == 5 || entry.mode == 6){
							/*this qos rule is set by IP address*/
							tmpStr = inet_ntoa(*((struct in_addr *)entry.local_ip_start));
							sprintf(tmp_args1, "%s", tmpStr);
							tmpStr = inet_ntoa(*((struct in_addr *)entry.local_ip_end));
							sprintf(tmp_args2, "%s", tmpStr);
							sprintf(tmp_args3, "%s-%s",tmp_args1, tmp_args2);

							RunSystemCmd(NULL_FILE, Iptables, ADD, POSTROUTING, _table, mangle_table , match, ip_range, dst_rnage, tmp_args3, jump, MARK,  set_mark, tmp_args, NULL_STR);
						}else{
							sprintf(tmp_args3, "%02x:%02x:%02x:%02x:%02x:%02x",entry.mac[0], entry.mac[1], entry.mac[2], entry.mac[3], entry.mac[4], entry.mac[5]);
							RunSystemCmd(NULL_FILE, Iptables, ADD, POSTROUTING, _table, mangle_table , match, _mac, mac_dst, tmp_args3, jump, MARK, set_mark, tmp_args, NULL_STR);
						}

						sprintf(tmp_args1, "5:%d", lan_pkt_mark);
						sprintf(tmp_args2, "%ldkbit", entry.bandwidth_downlink);
						sprintf(tmp_args3, "%dkbit", downlink_speed);
						sprintf(tmp_args4, "5%d:", lan_pkt_mark);


						if(entry.mode == 5 || entry.mode == 9){
							RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, br_interface, _parent, "5:1", _classid, tmp_args1, _htb, _rate, tmp_args2, _ceil, tmp_args3, _prio, "2", _quantum, "30000",NULL_STR);
							//TC_CMD="tc class add dev $BRIDGE parent 5:1 classid 5:$lan_pkt_mark htb rate ${bandwidth_dl}kbit ceil ${DOWNLINK_SPEED}kbit prio 2 quantum 30000"
						}else{
							RunSystemCmd(NULL_FILE, _tc, _class, _add, _dev, br_interface, _parent, "5:1", _classid, tmp_args1, _htb, _rate, "1kbit", _ceil, tmp_args2, _prio, "2" ,_quantum, "30000", NULL_STR);
							//TC_CMD="tc class add dev $BRIDGE parent 5:1 classid 5:$lan_pkt_mark htb rate 1kbit ceil ${bandwidth_dl}kbit prio 2 quantum 30000"
						}
						RunSystemCmd(NULL_FILE, _tc, _qdisc, _add, _dev, br_interface, _parent, tmp_args1, _handle, tmp_args4, _sfq, _perturb, "10", NULL_STR);
						//TC_CMD="tc qdisc add dev $BRIDGE parent 5:$lan_pkt_mark handle 5$lan_pkt_mark: sfq perturb 10"
						RunSystemCmd(NULL_FILE, _tc, _filter, _add, _dev, br_interface, _parent, "5:0", _protocol2, _ip, _prio, "100", _handle, tmp_args, _fw, _classid, tmp_args1, NULL_STR);
						//TC_CMD="tc filter add dev $BRIDGE parent 5:0 protocol ip prio 100 handle $lan_pkt_mark fw classid 5:$lan_pkt_mark"
						lan_pkt_mark = lan_pkt_mark+1;
					}
				}
			}
		}
	}

//	RunSystemCmd("/proc/qos", "echo", PROC_QOS, NULL_STR);
#endif
	return 0;
}
int setURLFilter(void)
{
	char keywords[500];
	char cmdBuffer[500];
	char tmp1[40];
	URLFILTER_T entry;
	int entryNum=0, index;
	//printf("set urlfilter\n");
	apmib_get(MIB_URLFILTER_TBL_NUM, (void *)&entryNum);
	sprintf(keywords, "%d ", entryNum);
	for (index=1; index<=entryNum; index++) {
		memset(&entry, '\0', sizeof(entry));
		*((char *)&entry) = (char)index;
		apmib_get(MIB_URLFILTER_TBL, (void *)&entry);
		if(!strncmp(entry.urlAddr,"http://",7))
			sprintf(tmp1, "%s ", entry.urlAddr+7);
		else
			sprintf(tmp1, "%s ", entry.urlAddr);
#if defined(CONFIG_RTL_FAST_FILTER)
		memset(cmdBuffer, 0, sizeof(cmdBuffer));
		sprintf(cmdBuffer, "rtk_cmd filter add --url-key %s", tmp1);
		system(cmdBuffer);
#else
		strcat(keywords, tmp1);
#endif
	}
	//sprintf(cmdBuffer, "%s", keywords);
	//RunSystemCmd("/proc/url_filter", "echo", cmdBuffer, NULL_STR);//disable h/w nat when url filter enabled
#if defined(CONFIG_RTL_FAST_FILTER)
#else
	sprintf(cmdBuffer, "add:0#3 3 %s", keywords);
	RunSystemCmd("/proc/filter_table", "echo", cmdBuffer, NULL_STR);
#endif

	return 0;
}


int setDoS(unsigned long enabled, int op)
{
	char cmdBuffer[500];
	unsigned char ipbuf[10];
	unsigned char maskbuf[10];
	unsigned int *dst, *mask;
	unsigned int synsynflood=0;
	unsigned int sysfinflood=0;
	unsigned int sysudpflood=0;
	unsigned int sysicmpflood=0;
	unsigned int pipsynflood=0;
	unsigned int pipfinflood=0;
	unsigned int pipudpflood=0;
	unsigned int pipicmpflood=0;
	unsigned int blockTime=0;


	apmib_get(MIB_DOS_SYSSYN_FLOOD, (void *)&synsynflood);
	apmib_get(MIB_DOS_SYSFIN_FLOOD, (void *)&sysfinflood);
	apmib_get(MIB_DOS_SYSUDP_FLOOD, (void *)&sysudpflood);
	apmib_get(MIB_DOS_SYSICMP_FLOOD, (void *)&sysicmpflood);
	apmib_get(MIB_DOS_PIPSYN_FLOOD, (void *)&pipsynflood);
	apmib_get(MIB_DOS_PIPFIN_FLOOD, (void *)&pipfinflood);
	apmib_get(MIB_DOS_PIPUDP_FLOOD, (void *)&pipudpflood);
	apmib_get(MIB_DOS_PIPICMP_FLOOD, (void *)&pipicmpflood);
	apmib_get(MIB_DOS_BLOCK_TIME, (void *)&blockTime);


  	apmib_get(MIB_IP_ADDR,  (void *)ipbuf);
  	dst = (unsigned int *)ipbuf;
  	apmib_get( MIB_SUBNET_MASK,  (void *)maskbuf);
  	mask = (unsigned int *)maskbuf;
  	if(op==2){
  		sprintf(cmdBuffer, "echo \" 2 %X %X %ld %d %d %d %d %d %d %d %d %d\" >  /proc/enable_dos", *dst, *mask, enabled, synsynflood, sysfinflood, sysudpflood, sysicmpflood, pipsynflood, pipfinflood, pipudpflood, pipicmpflood, blockTime);
  		  system(cmdBuffer);
  	}else{
  		sprintf(cmdBuffer, "echo \" 0 %X %X %ld %d %d %d %d %d %d %d %d %d\" >  /proc/enable_dos", (*dst & 0xFFFFFF00), *mask, enabled, synsynflood, sysfinflood, sysudpflood, sysicmpflood, pipsynflood, pipfinflood, pipudpflood, pipicmpflood, blockTime);
  		  system(cmdBuffer);
	}
return 0;


}

int setIpFilter(void)
{
	int entryNum=0, index;
	IPFILTER_T entry;
	char ipAddr[30];
	char *tmpStr;
#if defined(CONFIG_RTL_FAST_FILTER)
	char protocol[10];
	char cmdBuffer[120];
#endif

	apmib_get(MIB_IPFILTER_TBL_NUM, (void *)&entryNum);

	for(index=1; index <= entryNum ; index++) {
		memset(&entry, '\0', sizeof(entry));
		*((char *)&entry) = (char)index;
		apmib_get(MIB_IPFILTER_TBL, (void *)&entry);

		tmpStr = inet_ntoa(*((struct in_addr *)entry.ipAddr));
		sprintf(ipAddr, "%s", tmpStr);
#if defined(CONFIG_RTL_FAST_FILTER)
		memset(protocol, 0, sizeof(protocol));
		memset(cmdBuffer, 0, sizeof(cmdBuffer));
		if(entry.protoType==PROTO_TCP){
			sprintf(protocol, "tcp");
		}
		else if(entry.protoType==PROTO_UDP){
			sprintf(protocol, "udp");
		}
		else if(entry.protoType==PROTO_BOTH)	{
			sprintf(protocol, "tcp_udp");
		}
		sprintf(cmdBuffer, "rtk_cmd filter add --ip-src %s --protocol %s", ipAddr, protocol);
		system(cmdBuffer);
#else

		if(entry.protoType==PROTO_TCP){
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, _src, ipAddr, jump, DROP, NULL_STR);
		}
		if(entry.protoType==PROTO_UDP){
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, _src, ipAddr, jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _udp, dport, "53:53", _src, ipAddr, jump, DROP, NULL_STR);
		}
		if(entry.protoType==PROTO_BOTH)	{
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, _src, ipAddr, jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, _src, ipAddr, jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _udp, dport, "53:53", _src, ipAddr, jump, DROP, NULL_STR);
		}
#endif

	}
	return 0;
}

int setMACFilter(void)
{
	char macEntry[30];
	int entryNum=0, index;
	MACFILTER_T entry;
	char cmdBuffer[80];

	apmib_get(MIB_MACFILTER_TBL_NUM, (void *)&entryNum);

	for (index=1; index<=entryNum; index++) {
		memset(&entry, '\0', sizeof(entry));
		*((char *)&entry) = (char)index;
		apmib_get(MIB_MACFILTER_TBL, (void *)&entry);
		sprintf(macEntry,"%02X:%02X:%02X:%02X:%02X:%02X", entry.macAddr[0], entry.macAddr[1], entry.macAddr[2], entry.macAddr[3], entry.macAddr[4], entry.macAddr[5]);
#if defined(CONFIG_RTL_FAST_FILTER)
		memset(cmdBuffer, 0, sizeof(cmdBuffer));
		sprintf(cmdBuffer, "rtk_cmd filter add --mac-src %s", macEntry);
		system(cmdBuffer);
#else
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, match, "mac" ,mac_src, macEntry, jump, DROP, NULL_STR);
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, match, "mac" ,mac_src, macEntry, jump, DROP, NULL_STR);
#endif

		memset(cmdBuffer, 0, sizeof(cmdBuffer));
		sprintf(cmdBuffer, "rtk_cmd igmp_delete %02X:%02X:%02X:%02X:%02X:%02X", entry.macAddr[0], entry.macAddr[1], entry.macAddr[2], entry.macAddr[3], entry.macAddr[4], entry.macAddr[5]);
		system(cmdBuffer);
	}

	return 0;

}



int setPortFilter(void)
{
	char PortRange[30];
	//int DNS_Filter=0;
	int entryNum=0,index;
	PORTFILTER_T entry;
#if defined(CONFIG_RTL_FAST_FILTER)
	char protocol[10];
	char cmdBuffer[120];
#endif
	apmib_get(MIB_PORTFILTER_TBL_NUM, (void *)&entryNum);
	for (index=1; index<=entryNum; index++) {
		memset(&entry, '\0', sizeof(entry));
		*((char *)&entry) = (char)index;
		apmib_get(MIB_PORTFILTER_TBL, (void *)&entry);
		sprintf(PortRange, "%d:%d", entry.fromPort, entry.toPort);
#if defined(CONFIG_RTL_FAST_FILTER)
		memset(protocol, 0, sizeof(protocol));
		memset(cmdBuffer, 0, sizeof(cmdBuffer));

		if(entry.protoType==PROTO_TCP){
			sprintf(protocol, "tcp");
		}
		else if(entry.protoType==PROTO_UDP){
			sprintf(protocol, "udp");
		}
		else if(entry.protoType==PROTO_BOTH){
			sprintf(protocol, "tcp_udp");
		}
		sprintf(cmdBuffer, "rtk_cmd filter add --port-range-dst %d:%d --protocol %s", entry.fromPort, entry.toPort, protocol);
		system(cmdBuffer);
#else

		if(entry.protoType==PROTO_TCP){
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, dport, PortRange, jump, DROP, NULL_STR);
		}
		if(entry.protoType==PROTO_UDP){
			if(entry.fromPort<53 && entry.toPort >= 53)
				RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "53:53", jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, PortRange, jump, DROP, NULL_STR);
		}
		if(entry.protoType==PROTO_BOTH)	{
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, dport, PortRange, jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, PortRange, jump, DROP, NULL_STR);
			if(entry.fromPort<53 && entry.toPort >= 53)
				RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "53:53", jump, DROP, NULL_STR);
		}
#endif
		/*
		if(DNS_Filter==0){
			if(entry.fromPort<= 53 &&  entry.toPort >= 53){
				if(entry.protoType==PROTO_BOTH || (entry.protoType==PROTO_UDP)){
					RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _udp, dport, "53", jump, DROP, NULL_STR);
				}
			}
			DNS_Filter=1;
		}
		*/

	}
	return 0;
}

int setPortForward(char *pIfaceWan, char *pIpaddrWan)
{
	char PortRange[60];
	char ip[30];
	char *tmpStr;
	int entryNum=0, index;
	PORTFW_T entry;
	int l2tp_vpn=0;
	int pptp_vpn=0;
	int ipsec_vpn=0;
#if defined(CONFIG_RTL_FAST_FILTER)
	char protocol[10];
	char cmdBuffer[120];
#endif

	apmib_get(MIB_PORTFW_TBL_NUM, (void *)&entryNum);
	for (index=1; index<=entryNum; index++) {
		memset(&entry, '\0', sizeof(entry));
		*((char *)&entry) = (char)index;
		apmib_get(MIB_PORTFW_TBL, (void *)&entry);

		tmpStr =	inet_ntoa(*((struct in_addr *)entry.ipAddr));
		sprintf(ip, "%s", tmpStr);

		sprintf(PortRange, "%d:%d", entry.fromPort, entry.toPort);
#if 0 //defined(CONFIG_RTL_FAST_FILTER)
		memset(protocol, 0, sizeof(protocol));
		memset(cmdBuffer, 0, sizeof(cmdBuffer));

		if(entry.protoType ==PROTO_TCP){
			sprintf(protocol, "tcp");
		}
		else if(entry.protoType ==PROTO_UDP){
			sprintf(protocol, "udp");
		}
		else if(entry.protoType ==PROTO_BOTH){
			sprintf(protocol, "tcp_udp");
		}
		sprintf(cmdBuffer, "rtk_cmd filter add --ip-dst %s --port-dst-range %d:%d --protocol %s --policy fastpath", ip, entry.fromPort, entry.toPort, protocol);
		system(cmdBuffer);
#else
		if(entry.fromPort<80 && entry.toPort>80)
			RunSystemCmd(NULL_FILE, Iptables, DEL, INPUT, _protocol, _tcp, dport, "80:80", in, pIfaceWan, _dest, pIpaddrWan, jump, DROP, NULL_STR);

		if(entry.protoType ==PROTO_TCP){
			RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, _tcp, dport, PortRange,_dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pIfaceWan, _dest, ip, _protocol, _tcp, dport, PortRange, jump , ACCEPT, NULL_STR);
		}
		if(entry.protoType ==PROTO_UDP){
			RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, _udp, dport, PortRange,_dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pIfaceWan, _dest, ip, _protocol, _udp, dport, PortRange, jump , ACCEPT, NULL_STR);


		}
		if(entry.protoType ==PROTO_BOTH){
			RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, _tcp, dport, PortRange,_dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pIfaceWan, _dest, ip, _protocol, _tcp, dport, PortRange, jump , ACCEPT, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, _udp, dport, PortRange,_dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pIfaceWan, _dest, ip, _protocol, _udp, dport, PortRange, jump , ACCEPT, NULL_STR);

		}
#endif
		if(pptp_vpn==0){
			if(entry.fromPort<= 1723 &&  entry.toPort >= 1723){
				if(entry.protoType==PROTO_BOTH || (entry.protoType==PROTO_TCP)){
					RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, in, pIfaceWan, _protocol, "gre", _dest, pIpaddrWan , jump, DNAT, "--to", ip, NULL_STR);
					RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, "gre", in, pIfaceWan, jump, ACCEPT, NULL_STR);
				}
			}

			pptp_vpn=1;
		}

		if(l2tp_vpn==0){
			if(entry.fromPort<= 1701 &&  entry.toPort >= 1701){
				if(entry.protoType==PROTO_BOTH || (entry.protoType==PROTO_UDP)){
						RunSystemCmd("/proc/nat_l2tp", "echo", "0", NULL_STR);
				}
			}
			l2tp_vpn=1;
		}
		if(ipsec_vpn==0){
			if(entry.fromPort<= 500 &&  entry.toPort >= 500){
				if(entry.protoType==PROTO_BOTH || (entry.protoType==PROTO_UDP)){
					RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, "esp", _dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
					RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, _protocol, _udp, dport,"4500", _dest, pIpaddrWan, jump, DNAT, "--to", ip, NULL_STR);
					RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport,"4500", jump, ACCEPT, NULL_STR);
					RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, "esp", in, pIfaceWan, jump, ACCEPT, NULL_STR);
				}
			}
			ipsec_vpn=1;
		}
	}
	return 0;
}






int setFirewallIptablesRules(int argc, char** argv)
{
	int opmode=-1;
	int wan_dhcp=-1;
	char iface[20], *pInterface="eth1";
	char *pInterface_wanPhy="eth1";
	char Interface_wanPhy[20]="eth1";
	int wlaniface=0, get_wanip=0;
	struct in_addr wanaddr;
	char IpAddr[30], *strIp;
	char WanIpAddr[30], *strWanIp;
	char WanPhyIpAddr[30];
	char IpAddrBuf[30];
	int intVal=0, natEnabled=0;
	int intVal1=0;
	int intVal2 = 0;
	unsigned long	dos_enabled = 0;
	int dyn_rt_support=0;
	int intVal_num=0;
	int hw_nat_support=0;
	int my_wan_type = 0;
	char wan_type[8];

	printf("Init Firewall Rules....\n");
	memset(WanPhyIpAddr,'\0',30);
	apmib_get(MIB_OP_MODE, (void *)&opmode);
	apmib_get(MIB_WAN_DHCP, (void *)&wan_dhcp);
	if(opmode == WISP_MODE){
		apmib_get(MIB_WISP_WAN_ID, (void *)&wlaniface);
		sprintf(iface, "wlan%d", wlaniface);
		pInterface = iface;
		pInterface_wanPhy=iface;
		if (wan_dhcp == PPPOE || wan_dhcp == PPTP || wan_dhcp == L2TP )
				pInterface="ppp0";
	}else{
		if(opmode == GATEWAY_MODE){
			if (wan_dhcp == PPPOE || wan_dhcp == PPTP || wan_dhcp == L2TP || wan_dhcp == USB3G)
				pInterface="ppp0";
		}
	}
	get_wanip = getInAddr(pInterface, IP_ADDR_T, (void *)&wanaddr);
	if( get_wanip ==0){   //get wan ip fail
		printf("No wan ip currently!\n");
		return 0;
	}else{
		strWanIp = inet_ntoa(wanaddr);
		strcpy(WanIpAddr, strWanIp);
	}

	//flush fast natp table
	//RunSystemCmd("/proc/net/flush_conntrack", "echo", "1", NULL_STR);
	RunSystemCmd("/proc/fast_nat", "echo", "2", NULL_STR);//clean conntrack table before set new rules
	RunSystemCmd(NULL_FILE, Iptables, FLUSH, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables,_table, nat_table, FLUSH, POSTROUTING, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables,_table, nat_table, FLUSH, PREROUTING, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, FLUSH, _table, mangle_table, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, FLUSH, INPUT, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, FLUSH, OUTPUT, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, FLUSH, FORWARD, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, POLICY, OUTPUT, ACCEPT, NULL_STR);

	if(opmode != BRIDGE_MODE){
		RunSystemCmd(NULL_FILE, Iptables, POLICY, INPUT, DROP, NULL_STR);
	}else{
		RunSystemCmd(NULL_FILE, Iptables, POLICY, INPUT, ACCEPT, NULL_STR);
	}
	if(opmode != 3){
		RunSystemCmd(NULL_FILE, Iptables, POLICY, FORWARD, DROP, NULL_STR);
	}else{
		RunSystemCmd(NULL_FILE, Iptables, POLICY, FORWARD, ACCEPT, NULL_STR);
	}

	RunSystemCmd("/proc/sys/net/ipv4/ip_forward", "echo", "1", NULL_STR);
	//#redefine url and schedule filter


	if(isFileExist("/bin/routed")){
		dyn_rt_support=1;
	}
	if(isFileExist("/proc/hw_nat")){
		hw_nat_support=1;
	}
	if(dyn_rt_support ==1 && opmode != BRIDGE_MODE){
		apmib_get(MIB_NAT_ENABLED, (void *)&natEnabled);
		if(natEnabled==0){
			RunSystemCmd(NULL_FILE, Iptables, POLICY, INPUT, ACCEPT, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, POLICY, FORWARD, ACCEPT, NULL_STR);
			RunSystemCmd("/proc/fast_nat", "echo", "0", NULL_STR);//disable fastpath when nat is disabled
			return 0;
		}
	}
	if(opmode == BRIDGE_MODE)
		return 0;

	//url filter setting
	apmib_get(MIB_URLFILTER_ENABLED,  (void *)&intVal);
	apmib_get(MIB_URLFILTER_TBL_NUM,  (void *)&intVal_num);

#if defined(CONFIG_RTL_FAST_FILTER)
	system("rtk_cmd filter flush");
#else
	RunSystemCmd("/proc/filter_table", "echo", "flush", NULL_STR);
	RunSystemCmd("/proc/filter_table", "echo", "init", "3",  NULL_STR);
#endif

	if(intVal !=0 && intVal_num>0){
//		RunSystemCmd("/proc/url_filter", "echo", " ", NULL_STR);
		setURLFilter();
#if defined(CONFIG_RTL_HW_NAPT)
		if(opmode==0){
			RunSystemCmd("/proc/hw_nat", "echo", "0", NULL_STR);//disable h/w nat when url filter enabled
		}
#endif
	}else{
//		RunSystemCmd("/proc/url_filter", "echo", "0", NULL_STR);//disable url filter
#if defined(CONFIG_RTL_FAST_FILTER)
#else
		RunSystemCmd("/proc/filter_table", "echo", "flush", NULL_STR);
#endif
#if defined(CONFIG_RTL_HW_NAPT)
		if(opmode==0){
			RunSystemCmd("/proc/hw_nat", "echo", "1", NULL_STR);//enable h/w nat when url filter disable
		}
#endif

	}

#if defined(CONFIG_RTL_HW_NAPT)
	RunSystemCmd("/proc/hw_nat", "echo", "9", NULL_STR);
	my_wan_type = 0;
	my_wan_type = wan_dhcp + 80;
	sprintf(wan_type, "%d", my_wan_type);
	RunSystemCmd("/proc/hw_nat", "echo", wan_type, NULL_STR);
#else
	RunSystemCmd("/proc/sw_nat", "echo", "9", NULL_STR);
#endif

	intVal = 0;
	apmib_get( MIB_WEB_WAN_ACCESS_ENABLED, (void *)&intVal);
	if(intVal==1){
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _tcp,  dport, "80:80", in, pInterface, _dest, WanIpAddr, jump, ACCEPT, NULL_STR);
	}else{
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _tcp,  dport, "80:80", in, pInterface, _dest, WanIpAddr, jump, DROP, NULL_STR);
	}


	// SNMP setting
#ifdef CONFIG_SNMP
	intVal = 0;
	apmib_get(MIB_SNMP_ENABLED, (void *)&intVal);
	if (intVal == 1) {
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _udp, dport, "161:161", in, pInterface, _dest, WanIpAddr, jump, ACCEPT, NULL_STR);
		/*???where script*/
		RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table, nat_table, in, pInterface, _protocol, _udp, dport, "161", _dest, WanIpAddr, jump, REDIRECT, "--to-port", "161", NULL_STR);
	}
#endif

	//ip filter setting
	intVal = 0;
	apmib_get(MIB_IPFILTER_ENABLED,  (void *)&intVal);
	apmib_get(MIB_IPFILTER_TBL_NUM,  (void *)&intVal_num);
	if(intVal ==1 && intVal_num>0){
			//set ip filter
			setIpFilter();
	}

	intVal = 0;
	apmib_get(MIB_MACFILTER_ENABLED,  (void *)&intVal);
	apmib_get(MIB_MACFILTER_TBL_NUM, (void *)&intVal_num);
	if(intVal==1 && intVal_num>0){
		//set mac filter
		setMACFilter();
	}

	intVal=0;
	apmib_get(MIB_PORTFILTER_ENABLED,  (void *)&intVal);
	apmib_get(MIB_PORTFILTER_TBL_NUM, (void *)&intVal_num);
	if(intVal==1 && intVal_num>0){
		setPortFilter();
	}


	apmib_get(MIB_PORTFW_ENABLED,  (void *)&intVal);
	apmib_get(MIB_PORTFW_TBL_NUM, (void *)&intVal_num);
	if(intVal==1 && intVal_num>0){
		setPortForward(pInterface, WanIpAddr);
	}

#if 0
	// Move to set_init
	apmib_get(MIB_CUSTOM_PASSTHRU_ENABLED, (void *)&intVal);
	RunSystemCmd("/proc/custom_Passthru", "echo", (intVal & 0x1)?"1":"0", NULL_STR);
#endif

	apmib_get(MIB_VPN_PASSTHRU_L2TP_ENABLED, (void *)&intVal);
	if(intVal ==0){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "1701", jump, DROP, NULL_STR);
	}
	else if(intVal == 1){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "1701", jump, ACCEPT, NULL_STR);
	}
	apmib_get(MIB_VPN_PASSTHRU_PPTP_ENABLED, (void *)&intVal2);
	if(intVal2 ==0){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, dport, "1723", jump, DROP, NULL_STR);
	}
	else if(intVal2 == 1){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, dport, "1723", jump, ACCEPT, NULL_STR);
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _tcp, sport, "1723", jump, ACCEPT, NULL_STR);
	}

	if((intVal == 1) || (intVal2 == 1)){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _icmp, jump, ACCEPT, NULL_STR);
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pInterface_wanPhy, jump, ACCEPT, NULL_STR);
	}

	apmib_get(MIB_VPN_PASSTHRU_IPSEC_ENABLED, (void *)&intVal);
	if(intVal ==0){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "500", jump, DROP, NULL_STR);
	}else{
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, dport, "500", in ,pInterface, out, "br0", jump, ACCEPT, NULL_STR);
	}
	apmib_get( MIB_DMZ_ENABLED, (void *)&intVal);
	if(intVal ==1){
		apmib_get( MIB_DMZ_HOST,  (void *)IpAddrBuf);
		strIp = inet_ntoa(*((struct in_addr *)IpAddrBuf));
		if(strcmp(strIp, "0.0.0.0")){
			strcpy(IpAddr, strIp);
			RunSystemCmd(NULL_FILE, Iptables, ADD, PREROUTING, _table , nat_table, _protocol, ALL, _dest, WanIpAddr, jump, DNAT, "--to", IpAddr, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, DEL, INPUT, _protocol, _tcp, dport, "80:80", in, pInterface, _dest, WanIpAddr, jump, DROP, NULL_STR);
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pInterface, _dest, IpAddr, _protocol, ALL, jump, ACCEPT, NULL_STR);
		}
	}

	intVal = 0;
	apmib_get( MIB_PING_WAN_ACCESS_ENABLED, (void *)&intVal);
	if(intVal==1){
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _icmp, icmp_type, echo_request,  in, pInterface, _dest, WanIpAddr, jump, ACCEPT, NULL_STR);
	}else{
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, _icmp, icmp_type, echo_request,  in, pInterface, _dest, WanIpAddr, jump, DROP, NULL_STR);
	}

	intVal = 0;
	apmib_get( MIB_IGMP_PROXY_DISABLED, (void *)&intVal);
	if(intVal==0){
		RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, "2", in, pInterface, jump, ACCEPT, NULL_STR);
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, match, _udp, in, pInterface, "--destination" , "224.0.0.0/4", jump, ACCEPT, NULL_STR);
		apmib_get( MIB_WAN_DHCP, (void *)&intVal);
		//if wan is pptp(4) or l2tp(6), add this rule to permit multicast transter from wan to lan
		if(intVal==4 || intVal==6){
			RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, _udp, match, _udp, in, Interface_wanPhy, "--destination" , "224.0.0.0/4", jump, ACCEPT, NULL_STR);
		}
	}

	RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, in, NOT, pInterface, jump, ACCEPT, NULL_STR);

	RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, match, mstate, state, RELATED_ESTABLISHED, jump, ACCEPT, NULL_STR);
	//iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
	RunSystemCmd(NULL_FILE, Iptables, INSERT, FORWARD, _protocol, _tcp, tcp_flags, MSS_FLAG1, MSS_FLAG2, jump, TCPMSS, clamp, NULL_STR);

	RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, _protocol, "50", in, pInterface, out, "br0", jump, ACCEPT, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, "br0", jump, ACCEPT, NULL_STR);
	RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pInterface, match, mstate, state, RELATED_ESTABLISHED, jump, ACCEPT, NULL_STR);
	/*when layered driver enable, permit all icmp packet but icmp request...*/
	RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, _protocol, "2", in, pInterface, jump, ACCEPT, NULL_STR);



	if(wan_dhcp==4){
		RunSystemCmd(NULL_FILE, Iptables, ADD, FORWARD, in, pInterface_wanPhy, match, mstate, state, RELATED_ESTABLISHED, jump, ACCEPT, NULL_STR);
	}
	if(dyn_rt_support ==1){
		apmib_get(MIB_NAT_ENABLED, (void *)&natEnabled);
#if defined(CONFIG_ROUTE)
		apmib_get(MIB_RIP_ENABLED, (void *)&intVal);
		apmib_get(MIB_RIP_WAN_RX, (void *)&intVal1);
#endif
		if(natEnabled==1 && intVal==1){
			if(intVal1==1){
				RunSystemCmd(NULL_FILE, Iptables, ADD, INPUT, in, pInterface, _protocol, _udp, dport, "520", jump, ACCEPT, NULL_STR);
			}
		}
	}

	RunSystemCmd("/tmp/firewall_igd", "echo", "1", NULL_STR);//disable fastpath when port filter is enabled
	apmib_get(MIB_DOS_ENABLED, (void *)&dos_enabled);
	if(dos_enabled > 0){
#if defined(CONFIG_RTL_HW_NAPT)
	if(opmode == GATEWAY_MODE)
		RunSystemCmd("/proc/hw_nat", "echo", "0", NULL_STR);
#endif
	}
	setDoS(dos_enabled, opmode);

	if(wan_dhcp==PPTP){
		RunSystemCmd(NULL_FILE, Iptables, _table, nat_table, ADD, POSTROUTING, out, pInterface_wanPhy, jump, MASQUERADE, NULL_STR);
	}

	if(wan_dhcp == L2TP){
		RunSystemCmd(NULL_FILE, Iptables, _table, nat_table, ADD, POSTROUTING, out, pInterface_wanPhy, jump, MASQUERADE, NULL_STR);
	}

	RunSystemCmd(NULL_FILE, Iptables, _table, nat_table, ADD, POSTROUTING, out, pInterface, jump, MASQUERADE, NULL_STR);
/*
	RunSystemCmd("/proc/sys/net/ipv4/ip_conntrack_max", "echo", "1280", NULL_STR);
	RunSystemCmd("/proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established", "echo", "600", NULL_STR);
	RunSystemCmd("/proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout", "echo", "60", NULL_STR);
	RunSystemCmd("/proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_time_wait", "echo", "5", NULL_STR);
	RunSystemCmd("/proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_close", "echo", "5", NULL_STR);
*/

//hyking:packet from wan is NOT allowed
#if 0 //defined(CONFIG_RTL_LAYERED_DRIVER_ACL)
	RunSystemCmd(NULL_FILE, "iptables", ADD, INPUT, jump, ACCEPT, NULL_STR);
#else
	RunSystemCmd(NULL_FILE, "iptables", ADD, INPUT, "!", in, pInterface, jump, ACCEPT, NULL_STR);
#endif

	//RunSystemCmd("/proc/sys/net/ipv4/conf/eth1/arp_ignore", "echo", "1", NULL_STR);
	set_QoS(opmode, wan_dhcp, wlaniface);

#ifdef CONFIG_RTK_VOIP
	set_voip_parameter(pInterface);
#endif
	return 0;

}












