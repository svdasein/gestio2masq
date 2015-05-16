# Gestio2masq
[![Gem Version](https://badge.fury.io/rb/gestio2masq.svg)](http://badge.fury.io/rb/gestio2masq)

gestio2masq generates [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) configuration files from IPAM data in
a [GestióIP](http://www.gestioip.net/) mysql database.



## Installation & Configuration

First, install it:

    $ git clone https://github.com/svdasein/gestio2masq.git
    $ cd gestio2masq
    $ bundle install
    
or

    $ gem install gestio2masq
    
Once installed, copy the example config file to /etc/ and edit.  The config file is self documenting :->

###gestio2masq requires some custom fields in gestioip.

You can define these via the web interface in Manage/Custom Columns.

####Add the following _network_ fields:

####_domain_

The domain name that will fully qualify your host names in a given network

####_leasetime_

The static assignment lease time for this network

####_dynleasetime_

The dynamic pool lease time for this network

####_optiontag_

A unique dnsmasq tag string.  Options for a given network will be tagged with this string in dnsmasq configuration.

####Add the following _host_ fields:

####_MAC_

Specify this for a host if you want to do static dhcp assignments.  Format is 00:00:00:00:00:00

####_CNAMEs_

Colon separated list of *fully qualified* cnames.  e.g. host.mydomain.net:alias.myotherdomain.net

####_optiontag_

If you want to do some custom things for particular hosts in your dnsmasq config, you can specify the tag
you used to identify that stuff here.



### You'll also need to set up dnsmasq so that it uses the files generated by gestio2masq

gestio2masq generates the following files:

    destdir/dnsmasq.d/ranges
    destdir/dnsmasq.d/cnames
    destdir/dnsmasq-dhcp-hosts.conf
    destdir/dnsmasq-hosts.conf


The first two files will be auto-loaded if you launch dnsmasq with ```-7 destdir/dnsmasq.d```

The last two need to be pointed to explicitly in your dnsmasq.conf file.

Example:

```
interface=eth0                                                                                                                                                                      
no-resolv                                                                                                                                                                          
expand-hosts
stop-dns-rebind
log-dhcp
domain=my.net
local=/my.net/
domain-needed
server=8.8.8.8
cache-size=1000
clear-on-reload
dhcp-leasefile=/var/lib/dhcp/dnsmasq.leases

#This is where you define the stuff that host optiontags map to:
#(If you don't do per-host tags this isn't required)
dhcp-optsfile=/etc/dnsmasq-dhcp-opts.conf

#generated by gestio2masq

addn-hosts=/etc/dnsmasq-hosts.conf
dhcp-hostsfile=/etc/dnsmasq-dhcp-hosts.conf
```


## Usage

    $ gestio2masq
    $ service dnsmasq restart (or equiv)

    $ gestio2masq --help
    Options:
        -c, --config=<s>      Config file path
        -t, --destdir=<s>     Destination dir
        -h, --sqlhost=<s>     Database host
        -d, --database=<s>    Database name
        -u, --sqluser=<s>     Database user
        -p, --sqlpass=<s>     Database password
        -v, --verbose         Verbose output
        -e, --help            Show this message


## IRC

**\#gestio2masq** on Freenode

## Contributing

1. Fork it ( https://github.com/svdasein/gestio2masq/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
