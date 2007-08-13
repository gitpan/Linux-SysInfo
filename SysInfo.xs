/* This file is part of the Linux::SysInfo Perl module.
 * See http://search.cpan.org/dist/Linux-SysInfo/
 * Vincent Pit - 2007 */

#include <linux/version.h> /* LINUX_VERSION_CODE, KERNEL_VERSION() */
#include <sys/sysinfo.h>   /* <struct sysinfo>, sysinfo(), SI_LOAD_SHIFT */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define __PACKAGE__ "Linux::SysInfo"

/* --- Extended fields ----------------------------------------------------- */

#if ((defined(__i386__) || defined(__x86_64__)) && (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 3, 23))) || (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 3, 48))
# define LS_HAS_EXTENDED 1
#else
# define LS_HAS_EXTENDED 0
#endif

/* --- Keys ---------------------------------------------------------------- */

#define LS_KEY(K)            (ls_key_##K##_sv)
#if PERL_API_REVISION >= 5 && PERL_API_VERSION >= 9 && PERL_API_SUBVERSION >= 5
/* From 5.9.5, newSVpvn_share doesn't seem to fill the UV field of the key SV
 * properly (the SV actually doesn't even look like a UV). That's why we have
 * to keep the hash in another variable. */
# define LS_HASH(K)          (ls_key_##K##_hash)
# define LS_KEY_DECLARE(K)   STATIC SV *LS_KEY(K) = NULL; \
                             STATIC U32 LS_HASH(K) = 0
# define LS_KEY_DEFINE(K)    PERL_HASH(LS_HASH(K), #K, sizeof(#K)-1); \
                             LS_KEY(K) = newSVpvn_share(#K, sizeof(#K)-1, \
			                                LS_HASH(K));
# define LS_KEY_STORE(H,K,V) hv_store_ent((H), LS_KEY(K), (V), LS_HASH(K))
#else
/* This won't work for 5.9.3 (5.9.4 ?), neither will the previous one.
 * If you want to bleed, upgrade your blead! */
# define LS_KEY_DECLARE(K)   STATIC SV *LS_KEY(K) = NULL
# define LS_KEY_DEFINE(K)    LS_KEY(K) = newSVpvn_share(#K, sizeof(#K)-1, 0)
# define LS_KEY_STORE(H,K,V) hv_store_ent((H), LS_KEY(K), (V), SvUVX(LS_KEY(K)))
#endif

LS_KEY_DECLARE(uptime);
LS_KEY_DECLARE(load1);
LS_KEY_DECLARE(load5);
LS_KEY_DECLARE(load15);
LS_KEY_DECLARE(totalram);
LS_KEY_DECLARE(freeram);
LS_KEY_DECLARE(sharedram);
LS_KEY_DECLARE(bufferram);
LS_KEY_DECLARE(totalswap);
LS_KEY_DECLARE(freeswap);
LS_KEY_DECLARE(procs);
#if LS_HAS_EXTENDED
LS_KEY_DECLARE(totalhigh);
LS_KEY_DECLARE(freehigh);
LS_KEY_DECLARE(mem_unit);
#endif /* LS_HAS_EXTENDED */

/* --- XS ------------------------------------------------------------------ */

MODULE = Linux::SysInfo              PACKAGE = Linux::SysInfo

PROTOTYPES: ENABLE

BOOT:
{
 HV *stash;
 stash = gv_stashpv(__PACKAGE__, TRUE);
 newCONSTSUB(stash, "LS_HAS_EXTENDED", newSViv(LS_HAS_EXTENDED));

 LS_KEY_DEFINE(uptime);
 LS_KEY_DEFINE(load1);
 LS_KEY_DEFINE(load5);
 LS_KEY_DEFINE(load15);
 LS_KEY_DEFINE(totalram);
 LS_KEY_DEFINE(freeram);
 LS_KEY_DEFINE(sharedram);
 LS_KEY_DEFINE(bufferram);
 LS_KEY_DEFINE(totalswap);
 LS_KEY_DEFINE(freeswap);
 LS_KEY_DEFINE(procs);
#if LS_HAS_EXTENDED
 LS_KEY_DEFINE(totalhigh);
 LS_KEY_DEFINE(freehigh);
 LS_KEY_DEFINE(mem_unit);
#endif /* LS_HAS_EXTENDED */
}

SV *sysinfo()
PREINIT:
 struct sysinfo si;
 NV l;
 HV *h;
CODE:
 if (sysinfo(&si) == -1) {
  XSRETURN_UNDEF;
 }

 h = newHV();

 LS_KEY_STORE(h, uptime,    newSViv(si.uptime));

 l = ((NV) si.loads[0]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 LS_KEY_STORE(h, load1,     newSVnv(l));
 l = ((NV) si.loads[1]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 LS_KEY_STORE(h, load5,     newSVnv(l));
 l = ((NV) si.loads[2]) / ((NV) (((U32) 1) << ((U32) SI_LOAD_SHIFT)));
 LS_KEY_STORE(h, load15,    newSVnv(l));

 LS_KEY_STORE(h, totalram,  newSVuv(si.totalram));
 LS_KEY_STORE(h, freeram,   newSVuv(si.freeram));
 LS_KEY_STORE(h, sharedram, newSVuv(si.sharedram));
 LS_KEY_STORE(h, bufferram, newSVuv(si.bufferram));
 LS_KEY_STORE(h, totalswap, newSVuv(si.totalswap));
 LS_KEY_STORE(h, freeswap,  newSVuv(si.freeswap));
 LS_KEY_STORE(h, procs,     newSVuv(si.procs));
#if LS_HAS_EXTENDED
 LS_KEY_STORE(h, totalhigh, newSVuv(si.totalhigh));
 LS_KEY_STORE(h, freehigh,  newSVuv(si.freehigh));
 LS_KEY_STORE(h, mem_unit,  newSVuv(si.mem_unit));
#endif /* LS_HAS_EXTENDED */

 RETVAL = newRV_noinc((SV *) h);
OUTPUT:
 RETVAL

