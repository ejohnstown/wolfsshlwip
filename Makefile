ifeq ($(BUILD),debug)
    DEBUG = -O0 -g -DDEBUG_WOLFSSH
endif
CFLAGS = $(DEBUG)
LDFLAGS = -lpcap -lm -pthread
CPPFLAGS = $(INCDIRS) -DWOLFSSL_USER_SETTINGS

WOLFSSH = wolfssh
SSHDIR = $(WOLFSSH)/src
SSHINC = -I$(WOLFSSH)
OBJSSH = $(OBJ)/$(WOLFSSH)
SSHOBJS = \
  $(OBJSSH)/agent.o $(OBJSSH)/keygen.o \
  $(OBJSSH)/port.o $(OBJSSH)/wolfsftp.o \
  $(OBJSSH)/internal.o $(OBJSSH)/log.o \
  $(OBJSSH)/ssh.o $(OBJSSH)/wolfterm.o \
  $(OBJSSH)/io.o $(OBJSSH)/wolfscp.o

WOLFSSL = wolfssl
CRYPTDIR = $(WOLFSSL)/wolfcrypt/src
CRYPTINC =-I$(WOLFSSL)
OBJCRYPT = $(OBJ)/$(WOLFSSL)
CRYPTOBJS = \
  $(OBJCRYPT)/aes.o $(OBJCRYPT)/dh.o \
  $(OBJCRYPT)/integer.o $(OBJCRYPT)/tfm.o \
  $(OBJCRYPT)/sha.o $(OBJCRYPT)/sha256.o \
  $(OBJCRYPT)/sha512.o $(OBJCRYPT)/hash.o \
  $(OBJCRYPT)/ecc.o $(OBJCRYPT)/rsa.o \
  $(OBJCRYPT)/memory.o $(OBJCRYPT)/random.o \
  $(OBJCRYPT)/hmac.o $(OBJCRYPT)/wolfmath.o \
  $(OBJCRYPT)/asn.o $(OBJCRYPT)/coding.o \
  $(OBJCRYPT)/signature.o $(OBJCRYPT)/wc_port.o \
  $(OBJCRYPT)/sp_int.o $(OBJCRYPT)/sp_c64.o \
  $(OBJCRYPT)/sp_c32.o

LWIP = lwip-linux/lwip-2.0.2
LWIPDIR = $(LWIP)/src
LWIPINC = -I$(LWIPDIR) -I$(LWIPDIR)/include -I$(LWIPDIR)/../test/linux
OBJLWIP = $(OBJ)/$(LWIP)
LWIPOBJS= \
  $(OBJLWIP)/api/netbuf.o $(OBJLWIP)/api/api_msg.o \
  $(OBJLWIP)/api/api_lib.o $(OBJLWIP)/api/netifapi.o \
  $(OBJLWIP)/api/netdb.o $(OBJLWIP)/api/sockets.o \
  $(OBJLWIP)/api/err.o $(OBJLWIP)/api/tcpip.o \
  $(OBJLWIP)/core/def.o $(OBJLWIP)/core/ip.o \
  $(OBJLWIP)/core/memp.o $(OBJLWIP)/core/stats.o \
  $(OBJLWIP)/core/tcp_out.o $(OBJLWIP)/core/dns.o \
  $(OBJLWIP)/core/netif.o $(OBJLWIP)/core/sys.o \
  $(OBJLWIP)/core/timeouts.o $(OBJLWIP)/core/inet_chksum.o \
  $(OBJLWIP)/core/pbuf.o $(OBJLWIP)/core/tcp.o \
  $(OBJLWIP)/core/udp.o $(OBJLWIP)/core/init.o \
  $(OBJLWIP)/core/mem.o $(OBJLWIP)/core/raw.o \
  $(OBJLWIP)/core/tcp_in.o $(OBJLWIP)/core/ipv4/autoip.o \
  $(OBJLWIP)/core/ipv4/dhcp.o $(OBJLWIP)/core/ipv4/etharp.o \
  $(OBJLWIP)/core/ipv4/icmp.o $(OBJLWIP)/core/ipv4/igmp.o \
  $(OBJLWIP)/core/ipv4/ip4.o $(OBJLWIP)/core/ipv4/ip4_addr.o \
  $(OBJLWIP)/core/ipv4/ip4_frag.o $(OBJLWIP)/core/ipv6/dhcp6.o \
  $(OBJLWIP)/core/ipv6/ethip6.o $(OBJLWIP)/core/ipv6/icmp6.o \
  $(OBJLWIP)/core/ipv6/inet6.o $(OBJLWIP)/core/ipv6/ip6.o \
  $(OBJLWIP)/core/ipv6/ip6_addr.o $(OBJLWIP)/core/ipv6/ip6_frag.o \
  $(OBJLWIP)/core/ipv6/mld6.o $(OBJLWIP)/core/ipv6/nd6.o \
  $(OBJLWIP)/arch/if.o $(OBJLWIP)/arch/netif.o \
  $(OBJLWIP)/netif/ethernet.o

INCDIRS = -I. $(SSHINC) $(CRYPTINC) $(LWIPINC)
OBJ = obj

.PHONY: clean all

all: $(OBJ) libwolfssh.a testsuite keys/server-key-rsa.der

testsuite: $(OBJ)/testsuite.o $(OBJ)/echoserver.o $(OBJ)/client.o libwolfssh.a
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

libwolfssh.a: $(SSHOBJS) $(CRYPTOBJS) $(LWIPOBJS)
	$(AR) $(ARFLAGS) $@ $^

# to build wolfSSH sources
$(OBJSSH)/%.o: $(SSHDIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

# to build wolfCrypt sources
$(OBJCRYPT)/%.o: $(CRYPTDIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

# to build LwIP sources
$(OBJLWIP)/%.o: $(LWIPDIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

# to build application sources
$(OBJ)/testsuite.o: $(WOLFSSH)/tests/testsuite.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OBJ)/echoserver.o: $(WOLFSSH)/examples/echoserver/echoserver.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OBJ)/client.o: $(WOLFSSH)/examples/client/client.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

keys/server-key-rsa.der:
	@mkdir -p keys
	@cp $(WOLFSSH)/keys/server-key-rsa.der keys
	@cp $(WOLFSSH)/keys/server-key-rsa.pem keys

$(OBJ):
	@mkdir -p $(OBJSSH) $(OBJCRYPT) $(OBJLWIP) \
		$(OBJLWIP)/netif $(OBJLWIP)/core/ipv6 $(OBJLWIP)/core/ipv4 \
		$(OBJLWIP)/core $(OBJLWIP)/arch $(OBJLWIP)/apps/tftp \
		$(OBJLWIP)/apps/sntp $(OBJLWIP)/apps/snmp $(OBJLWIP)/apps/netbiosns \
		$(OBJLWIP)/apps/mqtt $(OBJLWIP)/apps/mdns $(OBJLWIP)/apps/lwiperf \
		$(OBJLWIP)/apps/httpd $(OBJLWIP)/api

clean:
	@rm -rf libwolfssh.a testsuite $(OBJ)
