#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

/// DNS query handling strategy
/// - Virtual: Use a virtual DNS server to handle DNS queries, also known as Fake-IP mode
/// - OverTcp: Use TCP to send DNS queries to the DNS server
/// - Direct: Do not handle DNS by relying on DNS server bypassing
enum class Tun2proxyDns {
  Tun2proxyDns_Virtual = 0,
  Tun2proxyDns_OverTcp,
  Tun2proxyDns_Direct,
};

enum class Tun2proxyVerbosity {
  Tun2proxyVerbosity_Off = 0,
  Tun2proxyVerbosity_Error,
  Tun2proxyVerbosity_Warn,
  Tun2proxyVerbosity_Info,
  Tun2proxyVerbosity_Debug,
  Tun2proxyVerbosity_Trace,
};

extern "C" {

/// # Safety
///
/// Run the tun2proxy component with some arguments.
/// Parameters:
/// - proxy_url: the proxy url, e.g. "socks5://127.0.0.1:1080"
/// - tun_fd: the tun file descriptor, it will be owned by tun2proxy
/// - packet_information: whether exists packet information in tun_fd
/// - tun_mtu: the tun mtu
/// - dns_strategy: the dns strategy, see ArgDns enum
/// - verbosity: the verbosity level, see ArgVerbosity enum
int tun2proxy_with_fd_run(const char *proxy_url,
                          int tun_fd,
                          bool packet_information,
                          unsigned short tun_mtu,
                          Tun2proxyDns dns_strategy,
                          Tun2proxyVerbosity verbosity);

/// # Safety
///
/// Shutdown the tun2proxy component.
int tun2proxy_with_fd_stop();

/// # Safety
///
/// Run the tun2proxy component with some arguments.
/// Parameters:
/// - proxy_url: the proxy url, e.g. "socks5://127.0.0.1:1080"
/// - tun: the tun device name, e.g. "utun5"
/// - bypass: the bypass IP/CIDR, e.g. "123.45.67.0/24"
/// - dns_strategy: the dns strategy, see ArgDns enum
/// - root_privilege: whether to run with root privilege
/// - verbosity: the verbosity level, see ArgVerbosity enum
int tun2proxy_with_name_run(const char *proxy_url,
                            const char *tun,
                            const char *bypass,
                            Tun2proxyDns dns_strategy,
                            bool _root_privilege,
                            Tun2proxyVerbosity verbosity);

/// # Safety
///
/// Shutdown the tun2proxy component.
int tun2proxy_with_name_stop();

/// # Safety
///
/// set dump log info callback.
void tun2proxy_set_log_callback(void (*callback)(Tun2proxyVerbosity, const char*, void*),
                                void *ctx);

}  // extern "C"
