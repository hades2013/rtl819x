
//#include <linux/types.h>
#include <linux/string.h>
//#include <linux/ctype.h>

#if defined(RTL8196B)	
#include <asm/rtl8196.h>
#endif
#if defined(RTL8198)	
#include <asm/rtl8198.h>
#endif

#define simple_strtoul strtoul


#define SHA256_DIGEST_LENGTH 256/8
#define size_MacId 6
#define size_SerNum 32

int do_manufacture_set (int argc, char *argv[]);

#ifdef CONFIG_MACAUTH

/* crypto.h */
#define SHA256_DIGEST_LENGTH 256/8


typedef struct sha256 

{
	uint32_t count [2];
	uint32_t state [8];
	uint8_t block [64];
	uint8_t extra [64];
}

SHA256;


/*====================================================================*
 *   constants;
 *--------------------------------------------------------------------*/

#define HPAVKEY_CHAR_MIN 0x20
#define HPAVKEY_CHAR_MAX 0x7E
#define HPAVKEY_PHRASE_MIN 12
#define HPAVKEY_PHRASE_MAX 64
#define HPAVKEY_DIGEST_LEN 32
#define HPAVKEY_SHA_LEN 32
#define HPAVKEY_DAK_LEN 16
#define HPAVKEY_NMK_LEN 16
#define HPAVKEY_NID_LEN 7

#define HPAVKEY_SHA 0
#define HPAVKEY_DAK 1
#define HPAVKEY_NMK 2
#define HPAVKEY_NID 3

#define HPAVKEY_VERBOSE (1 << 0)
#define HPAVKEY_SILENCE (1 << 1)
#define HPAVKEY_ENFORCE (1 << 2)

/* crypto.c */

static void SHA256Block (struct sha256 * sha256, const void * memory);


static void SHA256Reset (struct sha256 * sha256)

{
	memset (sha256, 0, sizeof (struct sha256));
	sha256->state [0] = 0x6A09E667;
	sha256->state [1] = 0xBB67AE85;
	sha256->state [2] = 0x3C6EF372;
	sha256->state [3] = 0xA54FF53A;
	sha256->state [4] = 0x510E527F;
	sha256->state [5] = 0x9B05688C;
	sha256->state [6] = 0x1F83D9AB;
	sha256->state [7] = 0x5BE0CD19;
	sha256->extra [0] = 0x80;
	return;
}

static void SHA256Write (struct sha256 * sha256, const void * memory, size_t extent)

{
	if (extent)
	{
		char * buffer = (char *)(memory);
		unsigned left = sha256->count [0] & 0x3F;
		unsigned fill = sizeof (sha256->block) - left;
		sha256->count [0] += (uint32_t)(extent);
		sha256->count [0] &= 0xFFFFFFFF;
		if (sha256->count [0] < extent)
		{
			sha256->count [1]++;
		}
		if ((left) && (extent >= fill))
		{
			memcpy (sha256->block + left, buffer, fill);
			SHA256Block (sha256, sha256->block);
			extent -= fill;
			buffer += fill;
			left = 0;
		}
		while (extent >= sizeof (sha256->block))
		{
			SHA256Block (sha256, buffer);
			extent -= sizeof (sha256->block);
			buffer += sizeof (sha256->block);
		}
		if (extent)
		{
			memcpy (sha256->block + left, buffer, extent);
		}
	}
	return;
}


#define  SHR(word,bits) ((word & 0xFFFFFFFF) >> bits)
#define ROTR(word,bits) (SHR(word,bits) | (word << (32 - bits)))

static void SHA256Block (struct sha256 * sha256, const void * memory)

{
	static const uint32_t K [sizeof (sha256->block)] =
	{
		0x428A2F98,
		0x71374491,
		0xB5C0FBCF,
		0xE9B5DBA5,
		0x3956C25B,
		0x59F111F1,
		0x923F82A4,
		0xAB1C5ED5,
		0xD807AA98,
		0x12835B01,
		0x243185BE,
		0x550C7DC3,
		0x72BE5D74,
		0x80DEB1FE,
		0x9BDC06A7,
		0xC19BF174,
		0xE49B69C1,
		0xEFBE4786,
		0x0FC19DC6,
		0x240CA1CC,
		0x2DE92C6F,
		0x4A7484AA,
		0x5CB0A9DC,
		0x76F988DA,
		0x983E5152,
		0xA831C66D,
		0xB00327C8,
		0xBF597FC7,
		0xC6E00BF3,
		0xD5A79147,
		0x06CA6351,
		0x14292967,
		0x27B70A85,
		0x2E1B2138,
		0x4D2C6DFC,
		0x53380D13,
		0x650A7354,
		0x766A0ABB,
		0x81C2C92E,
		0x92722C85,
		0xA2BFE8A1,
		0xA81A664B,
		0xC24B8B70,
		0xC76C51A3,
		0xD192E819,
		0xD6990624,
		0xF40E3585,
		0x106AA070,
		0x19A4C116,
		0x1E376C08,
		0x2748774C,
		0x34B0BCB5,
		0x391C0CB3,
		0x4ED8AA4A,
		0x5B9CCA4F,
		0x682E6FF3,
		0x748F82EE,
		0x78A5636F,
		0x84C87814,
		0x8CC70208,
		0x90BEFFFA,
		0xA4506CEB,
		0xBEF9A3F7,
		0xC67178F2
	};
	unsigned pass;
	unsigned word;
	uint32_t H [sizeof (sha256->state)/sizeof (uint32_t)];
	uint32_t W [sizeof (sha256->block)];
	uint8_t * buffer = (uint8_t *)(memory);
	for (word = 0; word < 16; word++)
	{
		W [word] = 0;
		W [word] |= (uint32_t)(*buffer++) << 24;
		W [word] |= (uint32_t)(*buffer++) << 16;
		W [word] |= (uint32_t)(*buffer++) << 8;
		W [word] |= (uint32_t)(*buffer++) << 0;;
	}
	for (word = word; word < sizeof (sha256->block); word++)
	{
		uint32_t s0 = ROTR (W [word-15], 7) ^ ROTR (W [word-15], 18) ^ SHR (W [word-15], 3);
		uint32_t s1 = ROTR (W [word- 2], 17) ^ ROTR (W [word- 2], 19) ^ SHR (W [word- 2], 10);
		W [word] = W [word - 16] + s0 + W [word - 7] + s1;
	}
	for (word = 0; word < (sizeof (sha256->state) / sizeof (uint32_t)); word++)
	{
		H [word] = sha256->state [word];
	}
	for (pass = 0; pass < sizeof (sha256->block); pass++)
	{
		uint32_t s2 = ROTR (H [0], 2) ^ ROTR (H [0], 13) ^ ROTR (H [0], 22);
		uint32_t maj = (H [0] & H [1]) ^ (H [0] & H [2]) ^ (H [1] & H [2]);
		uint32_t t2 = s2 + maj;
		uint32_t s3 = ROTR (H [4], 6) ^ ROTR (H [4], 11) ^ ROTR (H [4], 25);
		uint32_t ch = (H [4] & H [5]) ^ ((~ H [4]) & H [6]);
		uint32_t t1 = H [7] + s3 + ch + K [pass] + W [pass];
		for (word = (sizeof (sha256->state) / sizeof (uint32_t)) - 1; word > 0; word--)
		{
			H [word] = H [word-1];
		}
		H [0] = t1 + t2;
		H [4] += t1;
	}
	for (word = 0; word < (sizeof (sha256->state) / sizeof (uint32_t)); word++)
	{
		sha256->state [word] += H [word];
	}
	return;
}

static void encode (volatile uint8_t memory [], uint32_t number)

{
	*memory++ = (uint8_t)(number >> 24);
	*memory++ = (uint8_t)(number >> 16);
	*memory++ = (uint8_t)(number >> 8);
	*memory++ = (uint8_t)(number >> 0);
	return;
}

static void SHA256Fetch (struct sha256 * sha256, volatile uint8_t digest [])

{
	unsigned word;
	uint8_t bits [8];
	uint32_t upper = (sha256->count [0] >> 29) | (sha256->count [1] << 3);
	uint32_t lower = (sha256->count [0] << 3);
	uint32_t final = (sha256->count [0] & 0x3F);
	uint32_t extra = (final < 56)? (56 - final): (120 - final);
	encode (&bits [0], upper);
	encode (&bits [4], lower);
	SHA256Write (sha256, sha256->extra, extra);
	SHA256Write (sha256, bits, sizeof (bits));
	for (word = 0; word < sizeof (sha256->state) / sizeof (uint32_t); word++)
	{
		encode (digest, sha256->state [word]);
		digest += sizeof (uint32_t);
	}
	memset (sha256, 0, sizeof (struct sha256));
	return;
}


void HPAVKeyDAK (uint8_t DAK [], const char * string)

{
	struct sha256 sha256;
	uint8_t digest [SHA256_DIGEST_LENGTH];
	const uint8_t secret [] =
	{
		0x08,
		0x85,
		0x6D,
		0xAF,
		0x7C,
		0xF5,
		0x81,
		0x85
	};
	int count = 999;
	SHA256Reset (&sha256);
	SHA256Write (&sha256, (uint8_t *)(string), strlen (string));
	SHA256Write (&sha256, secret, sizeof (secret));
	SHA256Fetch (&sha256, digest);
	while (count-- > 0)
	{
		SHA256Reset (&sha256);
		SHA256Write (&sha256, digest, sizeof (digest));
		SHA256Fetch (&sha256, digest);
	}
	memcpy (DAK, digest, HPAVKEY_DAK_LEN);
	return;
}

/* end of crypto.c */

#define hexToUpCase(h)  (((h) > 9) ? ('A' + ((h) - 10)) : ((h) + '0'))
#if 0
static void mac_auth_code_u4(unsigned char *mac, char *authcode)
{
    uint8_t DAK[HPAVKEY_DAK_LEN];    
    const char *phase1 = "AuthorisedForCVNCHINAliuchuansen@hexicomtech.com";
    char phase[200];

    int i;
    char *p;

    p = phase;
    
    for (i = 0; i < 6; i ++)
    {
        *p++ = hexToUpCase((mac[i] >> 4) & 0x0f);
        *p++ = hexToUpCase((mac[i] >> 0) & 0x0f);
    }
    *p = '\0';
    
    //strcat(phase, phase1);  
    strcpy(p, phase1);
    HPAVKeyDAK(DAK, phase);

    p = authcode;
    
    for (i = 0; i < 16; i ++)
    {
        *p++ = hexToUpCase((DAK[i] >> 4) & 0x0f);
        *p++ = hexToUpCase((DAK[i] >> 0) & 0x0f);
    }
    *p = '\0';
        
}
#endif
static void mac_auth_code_u2(unsigned char *mac, char *authcode)
{
    uint8_t DAK[HPAVKEY_DAK_LEN];    
    const char *phase1 = "AuthenticationOfHexicomEOCMaster-2Modules";
    char phase[200];

    int i;
    char *p;

    p = phase;
    
    for (i = 0; i < 6; i ++)
    {
        *p++ = hexToUpCase((mac[i] >> 4) & 0x0f);
        *p++ = hexToUpCase((mac[i] >> 0) & 0x0f);
    }
    *p = '\0';
    
    //strcat(phase, phase1);  
    strcpy(p, phase1);
    HPAVKeyDAK(DAK, phase);

    p = authcode;
    
    for (i = 0; i < 16; i ++)
    {
        *p++ = hexToUpCase((DAK[i] >> 4) & 0x0f);
        *p++ = hexToUpCase((DAK[i] >> 0) & 0x0f);
    }
    *p = '\0';
        
}


static int mac_auth(unsigned char *mac, char *in_auth)
{
    char authcode[100];

   #if 0
    /*@ check if u4 got */
    mac_auth_code_u4(mac, authcode);

    if (!strncmp(in_auth, authcode, strlen(authcode))){
        return 4;
    }
    #endif
    /*@ check if u2 got */
    mac_auth_code_u2(mac, authcode);

    if (!strncmp(in_auth, authcode, strlen(authcode))){
        return 2;
    }
        
    return 0;
}

#endif 

/*
 * getnext -- get the next token
 *
 * Parameters:
 *   src: pointer to the start of the source string
 *   separater: the symbol used to separate the token
 *   dest: destination of the next token to be placed
 *
 * Returns:
 *   length of token (-1 when failed)
 */
int getnext (char *src,int separator,char *dest)
{
    char *c;
    int len = 0;

    if ( (src == NULL) || (dest == NULL) ) {
        return -1;
    }

    c = strchr(src, separator);
    if (c == NULL) {
        strcpy(dest, src);
        return -1;
    }
    len = c - src;
    strncpy(dest, src, len);
    dest[len] = '\0';
    return len + 1;
}

int str_to_mac (unsigned char *mac,char *str)
{
    int     len;
    char    *ptr = str;
    char    buf[128], tmp[128];
    int     i;

    for (i = 0; i < 5; ++i)
    {
        if ((len = getnext(ptr, ':', buf)) == -1 &&
            (len = getnext(ptr, '-', buf)) == -1)
        {
            return -1; /* parse error */
        }

        if (len != 3) return -1;

        strcpy(tmp, "");
        strcpy(tmp, buf);

        if (NULL != strtok(tmp, "0123456789ABCDEFabcdef")) return -1;

        mac[i] = simple_strtoul(buf, NULL, 16);
        ptr += len;
    }

    if (strlen(ptr) != 2) return -1;
    strcpy(tmp, "");
    strcpy(tmp, ptr);

    if (NULL != strtok(tmp, "0123456789ABCDEFabcdef")) return -1;

    mac[5] = simple_strtoul(ptr, NULL, 16);

    return 0;
}
int Check_MAC(unsigned char *mac_addr)
{
    unsigned char MAC_buf[size_MacId];
    int valid_flag=1;
    
    memset(MAC_buf,0xff,size_MacId);//check all 0xff MAC
    if(!memcmp(mac_addr,MAC_buf,size_MacId))
    {
    	valid_flag=0;
    }
    memset(MAC_buf,0x00,size_MacId);//check all 0 MAC
    if(!memcmp(mac_addr,MAC_buf,size_MacId))
    {
    	valid_flag=0;
    }
    if((mac_addr[0])&0x01)//check multicast MAC
    {
    	valid_flag=0;		
    }
    
    return valid_flag;
}

extern char eth0_mac[6];

static int macfinish = 0;
#define MACFINISH_MAC  0
#define MACFINISH_SN   1
#define MACFINISH_HVER 2

extern void wdt_enable();

void macfinish_do(void)
{
    if (macfinish == 0x7)
    {
        wdt_enable();
    }
}
int do_manufacture_set (int argc, char *argv[])
{    
    int len=0;
    unsigned char mac[size_MacId] = {0};
    char authcode[100];
    char  SerialNoGet[size_SerNum+1]={0};
   unsigned char tmp[26] = {0};
    if (
//#ifdef CONFIG_MACAUTH        
//        (argc == 4) 
//#else 
        (argc == 3) 
//#endif 
        && (0 == strcmp("mac",argv[0])))
    {
        if (0 == str_to_mac(mac,argv[1]))
        {
            if (Check_MAC(mac))
            {
#ifdef CONFIG_MACAUTH
                //mac_auth(mac, authcode);
                len = strlen(argv[2]);
                
               // if (strncmp(argv[2], authcode, len > size_SerNum ? size_SerNum : len)){
               //     printf("invalid AuthCode\n");
               //     return 0;
               // }         
                if (!mac_auth(mac, argv[2])){
                    printf("invalid Auth\n");
                    return 0;
                }
                flashwrite(CONFIG_AUTHCODE,(unsigned long)authcode,len);              
               
#endif                                    
                flashwrite(CONFIG_ETHADDR,(unsigned long)mac,6); 

                macfinish |= (1<<MACFINISH_MAC);                
                printf("OK\n");
             //   macfinish_do();
            }
            else
            {
                printf("not allowed\n");
                return 0; 
            }
        }
        else
        {
            printf("MAC err\n");
            return 0; 
        }
    }
    else if ((argc == 2) && (0 == strcmp("sn", argv[0])))
    {
        len = strlen(argv[1]);
        flashwrite(CONFIG_SN,(unsigned long)argv[1],len > size_SerNum ? size_SerNum : len);     
        macfinish |= (1<<MACFINISH_SN);
       // macfinish_do();
        printf("OK\n");
    }
      else if ((argc == 2) && (0 == strcmp("hver", argv[0])))
    {
        len = strlen(argv[1]);
      flashwrite(CONFIG_HAEDVERSION,(unsigned long)argv[1], 
        len > CONFIG_HAEDVERSION_LEN ? CONFIG_HAEDVERSION_LEN : len); 
      macfinish |= (1<<MACFINISH_HVER);
     // macfinish_do();
        printf("OK\n");
      //flashread((unsigned long)tmp,CONFIG_HAEDVERSION,strlen(argv[1]));
      //tmp[7] = 0;
      //printf("hver:%s\n",tmp);
    }
    else
    {        
   //     printf("Usage: \n manufacture mac xx:xx:xx:xx:xx:xx [xxxxxxxxxxxxxxxx]\n"
   //         " manufacture hver xxxxxx\n"
   //         " manufacture sn xxxxxx\n");
        printf("err cmd\n");
        return 0; 
    }
    macfinish_do();

	return 1;
    
}


