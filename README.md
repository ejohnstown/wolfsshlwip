# MAKEFILE EXAMPLE #

This example uses the sources from wolfSSL v5.3.0 and wolfSSH v1.4.10.
Fetch the additional sources with the command:

```
    git submodule update --init
```

Running **make** should produce **libwolfssl.a** and the **testsuite**
application. It will also copy some keys from the the wolfSSH directory into
the **keys** directory. This Makefile does not do any dependency tracking
beyond the source file for an object.

The file **user_settings.h** controls the build settings. Directions for
changing the math library used are in the file.

This has been tested on both an M1 Mac mini with macOS and on an AMD based
Ubuntu computer. Both are 64-bit.

## Fallout

So. I tried using the the lwip-linux example directly with wolfSSH trying to
use the LwIP native interface. It doesn't work that way.

The lwip-linux example does not build using LwIP's POSIX interface. It is using
the native interface. Moreso, it is just using the TCP layer interface. The
native functions `lwip_read()` and `lwip_send()` aren't available. The
example application included is getting data from a PCB with tcp_recv and
the notifying the TCP stack that data was received using tcp_recvd.

I was also getting static because of `ip_addr` and `timeval` getting
redeclared. For the time value, I set the flag that disabled the typedef.
Around the delarations of `in_addr` and `in6_addr` in inet.h, I put an
if-0 guard. timeval turns up in the wolfSSH porting types as does the
addresses.

I am adding some new I/O callbacks that will be using the PCB structs to
get and send data. Those are received from PCAP or sent through them. It's
all handled in LwIP and the PCAP code it is wrapping.
