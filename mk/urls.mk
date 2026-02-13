# =============================================================================
# mk/urls.mk — базовые URL для скачивания исходников
#
# Подключение: include ../mk/urls.mk (из profiles.mk)
#
# Два уровня переопределения:
#   1. Базовые URL (домен + общий путь) — меняют все проекты с этого источника:
#        GITHUB_URL = https://nexus.corp/repository/github-proxy
#        GNU_URL    = https://nexus.corp/repository/gnu-proxy
#
#   2. Попроектные URL (_SRC_URL) — меняют только один проект:
#        GCC_SRC_URL = https://my-mirror/gcc-sources
#        BROTLI_SRC_URL = https://my-mirror/brotli
#
#   В config.local.mk проекта задайте нужные переменные.
#   При рекурсивной сборке зависимостей переменные передаются
#   через export, поэтому достаточно переопределить один раз
#   в config.local.mk корневого проекта.
# =============================================================================

# =============================================================================
# Базовые URL (домен + общий путь)
# =============================================================================

# --- GitHub ---
GITHUB_URL      ?= https://github.com

# --- GNU FTP ---
GNU_URL         ?= https://ftp.gnu.org/gnu

# --- GnuPG ---
GNUPG_FTP_URL   ?= https://gnupg.org/ftp/gcrypt

# --- Curl ---
CURL_URL        ?= https://curl.se/download

# --- Zlib ---
ZLIB_URL        ?= https://zlib.net

# --- OpenSSL ---
OPENSSL_URL     ?= https://www.openssl.org/source

# --- OpenLDAP ---
OPENLDAP_URL    ?= https://www.openldap.org/software/download/OpenLDAP/openldap-release

# --- Kerberos ---
KERBEROS_URL    ?= https://kerberos.org/dist/krb5

# --- Kernel.org (glibc kernel headers) ---
KERNEL_URL      ?= https://cdn.kernel.org/pub/linux/kernel

# --- Libcap (kernel.org) ---
LIBCAP_URL      ?= https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2

# --- SourceForge ---
SOURCEFORGE_URL ?= https://sourceforge.net/projects

# --- Sourceware ---
SOURCEWARE_URL  ?= https://sourceware.org/pub

# --- Tukaani (xz/liblzma) ---
XZ_MIRROR       ?= https://tukaani.org/xz

# --- Pagure (libaio) ---
LIBAIO_URL      ?= https://pagure.io/libaio/archive

# --- Debian ---
DEBIAN_MIRROR   ?= http://deb.debian.org/debian

# --- Oberhumer (lzo) ---
LZO_URL         ?= http://www.oberhumer.com/opensource/lzo/download

# --- Hadrons (libmd) ---
HADRONS_MIRROR  ?= https://archive.hadrons.org

# =============================================================================
# Попроектные URL (_SRC_URL)
#
# Каждый проект имеет свою переменную: <PROJECT>_SRC_URL
# По умолчанию составляется из базового URL + путь к проекту.
# Можно переопределить для индивидуального проксирования.
# =============================================================================

# --- GNU-проекты ---
BISON_SRC_URL       ?= $(GNU_URL)/bison
GAWK_SRC_URL        ?= $(GNU_URL)/gawk
GCC_SRC_URL         ?= $(GNU_URL)/gcc
GLIBC_SRC_URL       ?= $(GNU_URL)/glibc
LIBIDN2_SRC_URL     ?= $(GNU_URL)/libidn
LIBUNISTRING_SRC_URL ?= $(GNU_URL)/libunistring

# --- GCC-производные (libstdcxx использует gcc source) ---
LIBSTDCXX_SRC_URL   ?= $(GCC_SRC_URL)

# --- GnuPG-проекты ---
LIBGCRYPT_SRC_URL   ?= $(GNUPG_FTP_URL)/libgcrypt
LIBGPG_ERROR_SRC_URL ?= $(GNUPG_FTP_URL)/libgpg-error

# --- GitHub-проекты ---
BROTLI_SRC_URL      ?= $(GITHUB_URL)/google/brotli
BUILDAH_SRC_URL     ?= $(GITHUB_URL)/containers/buildah
E2FSPROGS_SRC_URL   ?= $(GITHUB_URL)/tytso/e2fsprogs
GIT_SRC_URL         ?= $(GITHUB_URL)/git/git
GOLANG_SRC_URL      ?= $(GITHUB_URL)/golang/go
LIBBTRFS_SRC_URL    ?= $(GITHUB_URL)/kdave/btrfs-progs
LIBDEVMAPPER_SRC_URL ?= $(GITHUB_URL)/lvmteam/lvm2
LIBLZ4_SRC_URL      ?= $(GITHUB_URL)/lz4/lz4
LIBMOUNT_SRC_URL    ?= $(GITHUB_URL)/util-linux/util-linux
LIBSECCOMP_SRC_URL  ?= $(GITHUB_URL)/seccomp/libseccomp
LIBSELINUX_SRC_URL  ?= $(GITHUB_URL)/SELinuxProject/selinux
LIBSSH2_SRC_URL     ?= $(GITHUB_URL)/libssh2/libssh2
LIBSYSTEMD_SRC_URL  ?= $(GITHUB_URL)/systemd/systemd
LIBUDEV_SRC_URL     ?= $(LIBSYSTEMD_SRC_URL)
NGHTTP2_SRC_URL     ?= $(GITHUB_URL)/nghttp2/nghttp2
NGHTTP3_SRC_URL     ?= $(GITHUB_URL)/ngtcp2/nghttp3
NGTCP2_SRC_URL      ?= $(GITHUB_URL)/ngtcp2/ngtcp2
ZSTD_SRC_URL        ?= $(GITHUB_URL)/facebook/zstd

# --- Прочие ---
BZIP2_SRC_URL       ?= $(SOURCEWARE_URL)/bzip2
DPKG_SRC_URL        ?= $(DEBIAN_MIRROR)/pool/main/d/dpkg
LIBMD_SRC_URL       ?= $(HADRONS_MIRROR)/software/libmd
PCRE_SRC_URL        ?= $(SOURCEFORGE_URL)/pcre/files/pcre

# =============================================================================
# Export: передача переменных в рекурсивные sub-make вызовы
# =============================================================================
export GITHUB_URL GNU_URL GNUPG_FTP_URL CURL_URL ZLIB_URL OPENSSL_URL \
       OPENLDAP_URL KERBEROS_URL KERNEL_URL LIBCAP_URL SOURCEFORGE_URL \
       SOURCEWARE_URL XZ_MIRROR LIBAIO_URL DEBIAN_MIRROR LZO_URL \
       HADRONS_MIRROR

export BISON_SRC_URL GAWK_SRC_URL GCC_SRC_URL GLIBC_SRC_URL \
       LIBIDN2_SRC_URL LIBUNISTRING_SRC_URL LIBSTDCXX_SRC_URL \
       LIBGCRYPT_SRC_URL LIBGPG_ERROR_SRC_URL

export BROTLI_SRC_URL BUILDAH_SRC_URL E2FSPROGS_SRC_URL GIT_SRC_URL \
       GOLANG_SRC_URL LIBBTRFS_SRC_URL LIBDEVMAPPER_SRC_URL LIBLZ4_SRC_URL \
       LIBMOUNT_SRC_URL LIBSECCOMP_SRC_URL LIBSELINUX_SRC_URL \
       LIBSSH2_SRC_URL LIBSYSTEMD_SRC_URL LIBUDEV_SRC_URL \
       NGHTTP2_SRC_URL NGHTTP3_SRC_URL NGTCP2_SRC_URL ZSTD_SRC_URL

export BZIP2_SRC_URL DPKG_SRC_URL LIBMD_SRC_URL PCRE_SRC_URL
