# =============================================================================
# mk/urls.mk — базовые URL для скачивания исходников
#
# Подключение: include ../mk/urls.mk (из profiles.mk)
#
# Переопределение:
#   В config.local.mk проекта задайте нужную переменную:
#     GITHUB_URL = https://nexus.corp/repository/github-proxy
#     GNU_URL    = https://nexus.corp/repository/gnu-proxy
#
#   При рекурсивной сборке зависимостей переменные передаются
#   через export, поэтому достаточно переопределить один раз
#   в config.local.mk корневого проекта.
# =============================================================================

# --- GitHub ---
GITHUB_URL      ?= https://github.com

# --- GNU FTP (bison, gawk, gcc, glibc, libidn2, libunistring, libstdcxx) ---
GNU_URL         ?= https://ftp.gnu.org/gnu

# --- GnuPG (libgcrypt, libgpg-error) ---
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

# --- SourceForge (pcre) ---
SOURCEFORGE_URL ?= https://sourceforge.net/projects

# --- Sourceware (bzip2) ---
SOURCEWARE_URL  ?= https://sourceware.org/pub

# --- Tukaani (xz/liblzma) ---
XZ_MIRROR       ?= https://tukaani.org/xz

# --- Pagure (libaio) ---
LIBAIO_URL      ?= https://pagure.io/libaio/archive

# --- Debian (dpkg) ---
DEBIAN_MIRROR   ?= http://deb.debian.org/debian

# --- Oberhumer (lzo) ---
LZO_URL         ?= http://www.oberhumer.com/opensource/lzo/download

# --- Hadrons (libmd) ---
HADRONS_MIRROR  ?= https://archive.hadrons.org

# =============================================================================
# Export: передача переменных в рекурсивные sub-make вызовы
# =============================================================================
export GITHUB_URL GNU_URL GNUPG_FTP_URL CURL_URL ZLIB_URL OPENSSL_URL \
       OPENLDAP_URL KERBEROS_URL KERNEL_URL LIBCAP_URL SOURCEFORGE_URL \
       SOURCEWARE_URL XZ_MIRROR LIBAIO_URL DEBIAN_MIRROR LZO_URL \
       HADRONS_MIRROR
