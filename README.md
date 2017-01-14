### Bind Config — DNS Server

BIND is the most widely used Domain Name System (DNS) software on the Internet. On Unix-like operating systems it is the de facto standard. The software was originally designed at the University of California Berkeley (UCB) in the early 1980s. The name originates as an acronym of Berkeley Internet Name Domain, reflecting the application's use within UCB. The software consists, most prominently, of the DNS server component, called `named`, a contracted form of name daemon. In addition the suite contains various administration tools, and a DNS resolver interface library.

— https://www.internic.net/zones/  
— https://source.isc.org/git/bind9  
— https://en.wikipedia.org/wiki/BIND

### Bind Keys

The current copy of the `bind.keys` file can be found [here](https://www.isc.org/downloads/bind/bind-keys/). When `named` starts, it needs certain information before it can respond to recursive queries, such as how to reach the root servers. If `named` is configured to do DNSSEC validation, it also needs to have starting trust anchors. While all of this information is configurable via the `named.conf` file, ISC has tried to make the configuration files simpler by compiling in this information so that it doesn't have to be set in the `named.conf` file.

For root hints _(initial priming of root servers)_, BIND has had this for years. If you don't put a hints file in `named.conf`, `named` will use the compiled in hints. However, configuring trust anchors for DNSSEC validation has required added trusted-keys statements explicitly into the `named.conf` file. ISC now has a bind.keys file that contains the root key and the DLV key.

### Installation

```shell
brew install bind
git clone https://github.com/cixtor/bindconfig
make -C bindconfig install
sudo brew services start bind
sudo brew services list
```

Additional actions are available in the _Makefile_ to uninstall the configuration files, be sure to stop the DNS service before executing this task. Also, you can test if the installation process worked by calling `make test` or update the content of the root DNS zone file by executing `make update`. Check the syntax of the existing DNS zone files located in `./zones/*.db` by executing `make check`, you can add more of these files to support your own domain names and then restart the DNS service to push the information live.

### Configure DNS Resolution

- Open "System Preferences.app" > Network > Advanced > DNS
- Then insert a new entry on the "DNS Servers" panel — 127.0.0.1
- Drag the new entry to the top of the list to make it primary
- Click OK, then "Apply" to redirect the traffic to the local DNS
- Verify configuration with `cat /etc/resolv.conf`

### Verify DNS Resolution

After the execution of this command — `dig +nocmd +nocomments cixtor.test.`

You should be able to see the DNS records defined at `./zones/cixtor.test.db`

If the output of this command is empty or contains errors you can troubleshoot the problem by executing `named` in foreground mode. Pay attention to warnings and error messages with the "[...] loaded file" signature as the most common issues are related to missing files or permissions.

### Verify DNS Cache

After the execution of this command — `dig +nocmd +nocomments google.com.`

You will notice that the *"Query time"* will be lower with subsequent calls.
