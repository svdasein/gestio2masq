require "gestio2masq/version"
require 'mysql2'
require 'ipaddress'
require 'pp'
require 'json'

module Gestio2masq

	mysql = Mysql2::Client.new(:host => config['sqlhost'],
		 								:username => config['sqluser'],
		 								:password => config['sqlpass'],
		 								:database => config['database']
	)

	networksData = mysql.query('select * from net',:symbolize_keys => true)
	rangesData = mysql.query('select * from ranges',:symbolize_keys => true)
	hostsData = mysql.query('select * from host order by hostname',:symbolize_keys => true)
	hostsXData = mysql.query('select custom_host_column_entries.*,custom_host_columns.name from custom_host_column_entries,custom_host_columns where custom_host_columns.id = custom_host_column_entries.cc_id',:symbolize_keys => true)
	netsXData = mysql.query('select custom_net_column_entries.*,custom_net_columns.name from custom_net_column_entries,custom_net_columns where custom_net_columns.id = custom_net_column_entries.cc_id',:symbolize_keys => true)

	networks = Hash.new
	networksData.each { |net|
		netsXData.select { |each| each[:net_id] == net[:red_num] } .each { |entry|
			net[entry[:name].to_sym] = entry[:entry]
		}
		net[:bitmask] = IPAddress.parse("#{net[:red]}/#{net[:BM]}").netmask
		networks[net[:red_num]] = net
	}

	rangesEntries = Array.new
	rangesData.each { |range|
		network = networks[range[:red_num].to_i]
		startIp = IPAddress::IPv4.parse_u32(range[:start_ip].to_i)
		endIp = IPAddress::IPv4.parse_u32(range[:end_ip].to_i)
		rangesEntries.push("dhcp-range=#{network[:optiontag]},#{startIp},#{endIp},#{network[:bitmask]},#{network[:dynleasetime]}")
	}

	hostsEntries = Array.new
	dhcpHostsEntries = Array.new
	cnamesEntries = Array.new
	hostsData.each { |host|
		host[:ipaddress] = IPAddress::IPv4.parse_u32(host[:ip].to_i)
		hostsXData.select { |each| each[:host_id] == host[:id] } .each { |entry|
			host[entry[:name].to_sym] = entry[:entry]
		}
		host[:network] = networks[host[:red_num]]
		if host[:hostname].size > 0
			if host[:MAC]
				# static dhcp assignment
				if host[:optiontag]
					dhcpHostsEntries.push("#{host[:MAC]},set:#{host[:optiontag]},#{host[:hostname].split('.').shift},#{host[:ipaddress]},#{host[:network][:leasetime]}")
				else
					dhcpHostsEntries.push("#{host[:MAC]},#{host[:hostname].split('.').shift},#{host[:ipaddress]},#{host[:network][:leasetime]}")
				end
			end
			# hostname
			hostsEntries.push("#{host[:ipaddress]}\t#{host[:hostname]}.#{host[:network][:domain]}")
			if host[:CNAMEs]
				host[:CNAMEs].split(':').each { |cname|
					cnamesEntries.push("cname=#{cname},#{host[:hostname]}.#{host[:network][:domain]}")
				}
			end
		end
	}
	puts "="*80
	puts "RANGES"
	File.new('/etc/dnsmasq.d/ranges','w').puts(rangesEntries.join("\n"))
	puts(rangesEntries.join("\n"))
	puts "="*80
	puts "CNAMES"
	File.new('/etc/dnsmasq.d/cnames','w').puts(cnamesEntries.join("\n"))
	puts(cnamesEntries.join("\n"))
	puts "="*80
	puts "DHCP HOSTS"
	File.new('/etc/dnsmasq-dhcp-hosts.conf','w').puts(dhcpHostsEntries.join("\n"))
	puts(dhcpHostsEntries.join("\n"))
	puts "="*80
	puts "HOSTS"
	File.new('/etc/dnsmasq-hosts.conf','w').puts(hostsEntries.join("\n"))
	puts(hostsEntries.join("\n"))

end
