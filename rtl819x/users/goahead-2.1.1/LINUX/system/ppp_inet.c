/*
 */
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "sysconf.h"
#include "sys_utility.h"



static int isDaemon=0;
static int WanType=0;
static int ConnectType=0;


int main(int argc, char *argv[])
{
	int i;
	int cnt;//patch for l2tp dial-on-demand wantype

	for(i=1; i<argc; i++)
	{
		if(argv[i][0]!='-')
		{
			fprintf(stderr, "%s: Unknown option\n", argv[i]);
		}
		else switch(argv[i][1])
		{
		case 'c':
			ConnectType = atoi(argv[++i]);
			break;
		case 't':
			WanType = atoi(argv[++i]);
			break;
		case 'x':
			isDaemon = 1;
			break;
		default:
			fprintf(stderr, "%s: Unknown option\n", argv[i]);
		}
	}

	if(isDaemon==1){
		if (daemon(0, 1) == -1) {
			perror("ppp_inet fork error");
			return 0;
		}
	}

	cnt=0;//patch for l2tp dial-on-demand wantype
	for (;;) {
		if((isFileExist(PPP_CONNECT_FILE)==0) && (isFileExist(PPP_PATCH_FILE)==0)){
			sleep(3);	//To avoid ppp1
			system("killall -9 udhcpd 2> /dev/null");
			system("rm -f /var/run/udhcpd.pid 2> /dev/null");
			//printf("\r\n __[%s-%u]\r\n",__FILE__,__LINE__);
			if(WanType==3){
				if(isFileExist("/var/disc")==0){
					RunSystemCmd(PPP_CONNECT_FILE, "echo", "pass", NULL_STR);
					system("pppd &");
				}
			}

			if(WanType==4){
				if(isFileExist("/var/disc")==0){
					RunSystemCmd(PPP_CONNECT_FILE, "echo", "pass", NULL_STR);
					system("pppd call rpptp &");
				}
			}

			if(WanType==6){
				if(isFileExist("/var/disc")==0){
					RunSystemCmd(PPP_CONNECT_FILE, "echo", "pass", NULL_STR);
					system("echo \"c client\" > /var/run/l2tp-control &");
				}
			}
        #ifdef RTK_USB3G
            if(WanType==16){
                if(isFileExist("/var/disc")==0){
                    RunSystemCmd(PPP_CONNECT_FILE, "echo", "pass", NULL_STR);
                    system("pppd file /var/usb3g.option &");
                }
            }
        #endif /* #ifdef RTK_USB3G */
		system("udhcpd \"/var/udhcpd.conf\"");
		}else{
			if(WanType==6 && ConnectType==1){
				if(isFileExist(PPPD_PID_FILE)==0){

					//patch for l2tp dial-on-demand wantype
					//after 3 times, restart l2tpd
					if(cnt<3){
						cnt++;
					}else{
						RunSystemCmd(NULL_FILE, "killall", "-9", "l2tpd", NULL_STR);
						sleep(1);
						system("l2tpd &");
					}

			  		unlink(PPP_CONNECT_FILE); /*force start pppd*/
	  			}
	  		}
  		}

		if(ConnectType==2)
			break;
		sleep(5);
	}
	return 0;
}



