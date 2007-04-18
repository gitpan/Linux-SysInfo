#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <linux/version.h> /* LINUX_VERSION_CODE, KERNEL_VERSION() */
#include <sys/sysinfo.h>   /* <struct sysinfo>, sysinfo(), SI_LOAD_SHIFT */

#if ((defined(__i386__) || defined(__x86_64__)) && (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 3, 23))) || (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 3, 48))
# define SYSINFO_EXTENDED 1
#else
# define SYSINFO_EXTENDED 0
#endif

typedef struct {
 const char* key;
 U32 klen;
 U32 hash;
} sysinfo_key;

#define SYSINFO_KEY_SET_HASH(S) PERL_HASH((S).hash, (S).key, (S).klen)
#define SYSINFO_KEY_STORE(H,S,V) hv_store((H), (S).key, (S).klen, (V), (S).hash)

static sysinfo_key key_uptime    = { "uptime",    6, 0 };
static sysinfo_key key_load1     = { "load1",     5, 0 };
static sysinfo_key key_load5     = { "load5",     5, 0 };
static sysinfo_key key_load15    = { "load15",    6, 0 };
static sysinfo_key key_totalram  = { "totalram",  8, 0 };
static sysinfo_key key_freeram   = { "freeram",   7, 0 };
static sysinfo_key key_sharedram = { "sharedram", 9, 0 };
static sysinfo_key key_bufferram = { "bufferram", 9, 0 };
static sysinfo_key key_totalswap = { "totalswap", 9, 0 };
static sysinfo_key key_freeswap  = { "freeswap",  8, 0 };
static sysinfo_key key_procs     = { "procs",     5, 0 };
#if SYSINFO_EXTENDED
static sysinfo_key key_totalhigh = { "totalhigh", 9, 0 };
static sysinfo_key key_freehigh  = { "freehigh",  8, 0 };
static sysinfo_key key_mem_unit  = { "mem_unit",  8, 0 };
#endif /* SYSINFO_EXTENDED */

MODULE = Linux::SysInfo              PACKAGE = Linux::SysInfo

PROTOTYPES: ENABLE

BOOT:
{
 SYSINFO_KEY_SET_HASH(key_uptime);
 SYSINFO_KEY_SET_HASH(key_load1);
 SYSINFO_KEY_SET_HASH(key_load5);
 SYSINFO_KEY_SET_HASH(key_load15);
 SYSINFO_KEY_SET_HASH(key_totalram);
 SYSINFO_KEY_SET_HASH(key_freeram);
 SYSINFO_KEY_SET_HASH(key_sharedram);
 SYSINFO_KEY_SET_HASH(key_bufferram);
 SYSINFO_KEY_SET_HASH(key_totalswap);
 SYSINFO_KEY_SET_HASH(key_freeswap);
 SYSINFO_KEY_SET_HASH(key_procs);
#if SYSINFO_EXTENDED
 SYSINFO_KEY_SET_HASH(key_totalhigh);
 SYSINFO_KEY_SET_HASH(key_freehigh);
 SYSINFO_KEY_SET_HASH(key_mem_unit);
#endif /* SYSINFO_EXTENDED */
}

SV *
sysinfo()
PREINIT:
 struct sysinfo si;
 NV l;
 HV* h;
CODE:
 if (sysinfo(&si) == -1) {
  XSRETURN_UNDEF;
 }

 h = newHV(); /* mortalized in RETVAL */

 SYSINFO_KEY_STORE(h, key_uptime,    newSViv(si.uptime));

 l = ((NV) si.loads[0]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 SYSINFO_KEY_STORE(h, key_load1,     newSVnv(l));
 l = ((NV) si.loads[1]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 SYSINFO_KEY_STORE(h, key_load5,     newSVnv(l));
 l = ((NV) si.loads[2]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 SYSINFO_KEY_STORE(h, key_load15,    newSVnv(l));

 SYSINFO_KEY_STORE(h, key_totalram,  newSVuv(si.totalram));
 SYSINFO_KEY_STORE(h, key_freeram,   newSVuv(si.freeram));
 SYSINFO_KEY_STORE(h, key_sharedram, newSVuv(si.sharedram));
 SYSINFO_KEY_STORE(h, key_bufferram, newSVuv(si.bufferram));
 SYSINFO_KEY_STORE(h, key_totalswap, newSVuv(si.totalswap));
 SYSINFO_KEY_STORE(h, key_freeswap,  newSVuv(si.freeswap));
 SYSINFO_KEY_STORE(h, key_procs,     newSVuv(si.procs));
#if SYSINFO_EXTENDED
 SYSINFO_KEY_STORE(h, key_totalhigh, newSVuv(si.totalhigh));
 SYSINFO_KEY_STORE(h, key_freehigh,  newSVuv(si.freehigh));
 SYSINFO_KEY_STORE(h, key_mem_unit,  newSVuv(si.mem_unit));
#endif /* SYSINFO_EXTENDED */

 RETVAL = newRV_noinc((SV *) h);
OUTPUT:
 RETVAL

SV *
LS_HAS_EXTENDED()
CODE:
 RETVAL = newSViv(SYSINFO_EXTENDED); /* mortalized in RETVAL */
OUTPUT:
 RETVAL
