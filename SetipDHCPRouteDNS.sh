#!/bin/bash
#yum
#yum install dhcp -y
cd /root/Desktop/
#FIND DHCPD.conf
set_ip()
{
	echo "Remember ethernet! "
	ip add show | grep eth | awk {'print $2'}
	read -p "Input eth(input only number) " eth
	read -p "Input IP address: " ip
	cd /etc/sysconfig/network-scripts/
	touch ifcfg-eth$eth 
	echo "IPADDR=$ip " > ifcfg-eth$eth
	echo "DEVICE=eth$eth " >> ifcfg-eth$eth
	echo "NETMASK=255.255.255.0" >> ifcfg-eth$eth
	echo "ONBOOT=yes" >> ifcfg-eth$eth
	echo "BOOTPROTO=none" >> ifcfg-eth$eth
	mac=$(ifconfig eth$eth | grep HWaddr | awk {'print $5'})
	echo "HWADDR=$mac" >> ifcfg-eth$eth
	service network restart
	clear
	echo "Perfect!!"
	ip add show | grep eth$eth 
	sleep 5
	return 0
}
conf_dhcp()
{
if [ -e /etc/init.d/dhcpd ]; then
	echo "You have already installed DHCP "
	read -p "Do you want to remove DHCP? [y/n]" yes
		if [ $yes = 'y' ];then
			yum remove dhcp -y
		elif [ $yes = 'n' ];then
			cp -rf /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample /etc/dhcp/dhcpd.conf
			read -p "Enter the IP DNS " dnsip
			read -p "Enter the number of times the network is DHCP : " n
			for (( i = 0; i < $n; i++ ))
			do 
			ip add show | grep eth | awk {'print $2'}
			read -p "Enter the IP option router: " ip1
			read -p "Enter the number range that will be granted to DHCP from: " ipfr
			read -p "Enter the number range that will be granted to DHCP to: " ipto
			echo $ip1 > /root/nhap.txt
			ipcut=$(cut -f 4 --complement -d "." /root/nhap.txt)
			echo "#NETWORK $i" >> /etc/dhcp/dhcpd.conf
			echo "subnet $ipcut.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
			echo "	range $ipcut.$ipfr $ipcut.$ipto; " >> /etc/dhcp/dhcpd.conf
			echo "	option domain-name-servers $dnsip; " >> /etc/dhcp/dhcpd.conf		
			echo '	option domain-name "internal.example.org";' >> /etc/dhcp/dhcpd.conf
			echo "	option routers $ip1;" >> /etc/dhcp/dhcpd.conf
			echo "	option broadcast-address $ipcut.255;" >> /etc/dhcp/dhcpd.conf
			echo "	default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
			echo " 	max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
			echo "}" >> /etc/dhcp/dhcpd.conf
			done
		else
			echo "You just choose y[yes] or n[no] ?, run again "
			exit
		fi
else	
	yum install dhcp -y
	cp -rf /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample /etc/dhcp/dhcpd.conf
	read -p "Enter the IP DNS " dnsip1
	read -p "Enter the number of times the network is DHCP : " n
	for (( i = 0; i < $n; i++ ))
	do 
		ip add show | grep eth | awk {'print $2'}
		read -p "Enter the IP option router: " ip1
		read -p "Enter the number range that will be granted to DHCP from: " ipfr
		read -p "Enter the number range that will be granted to DHCP to: " ipto
		echo $ip1 > /root/nhap.txt
		ipcut=$(cut -f 4 --complement -d "." /root/nhap.txt)
		echo "#NETWORK $i" >> /etc/dhcp/dhcpd.conf
		echo "subnet $ipcut.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
		echo "	range $ipcut.$ipfr $ipcut.$ipto; " >> /etc/dhcp/dhcpd.conf
		echo "	option domain-name-servers $dnsip1; " >> /etc/dhcp/dhcpd.conf		
		echo '	option domain-name "internal.example.org";' >> /etc/dhcp/dhcpd.conf
		echo "	option routers $ip1;" >> /etc/dhcp/dhcpd.conf
		echo "	option broadcast-address $ipcut.255;" >> /etc/dhcp/dhcpd.conf
		echo "	default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
		echo " 	max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
		echo "}" >> /etc/dhcp/dhcpd.conf
	done
fi	
return 0
}
#ROUTE
route()
{
	ip add show | grep eth | awk {'print $2'}
	read -p "Enter the network you want to route: " network
	read -p "Enter the gateway : " gww
	read -p "Enter the eth [only number] " ethh
	touch /etc/sysconfig/network-scripts/route-eth$ethh
	echo "$network/24 via $gww dev eth$ethh" > /etc/sysconfig/network-scripts/route-eth$ethh
	/etc/init.d/network restart
	clear
	return 0
}
#Menu 
#DNS
#Check file named 
conf_dns()
{
if [ -e /etc/init.d/named ];then
	echo "You have already install DNS "
	read -p "Do you want to uninstall DNS? [y/n] " traloi
	if [ $traloi = 'y' ];then
		yum remove bind* -y
	elif [ $traloi = 'n' ];then
		read -p "Enter your IP DNS: " ipdns
		read -p "Enter you domain name server [DNS]: " dnns
		read -p "Enter your network you want to connect DNS " -e -i any networkk
		ipdnss=$( grep "listen-on port" /etc/named.conf | awk {'print $5'} | cut -f 1 -d ";" )	
		sed -i "s/$ipdnss/$ipdns/g" /etc/named.conf
		networrk=$( grep "allow-query" /etc/named.conf | awk {'print $3'} | cut -f 1 -d ";" )
		sed -i "s/$networkk/$networrk/g" /etc/named.conf
		echo "zone "$dnns" IN { " > /etc/named.rfc1912.zones
		echo "		type master; " >> /etc/named.rfc1912.zones
		echo "		file \"rev.$dnns\";"  >> /etc/named.rfc1912.zones
		echo "		allow-update {none; };" >> /etc/named.rfc1912.zones
		echo "};" >> /etc/named.rfc1912.zones
		touch /root/ip.txt
		echo "$ipdns" > /root/ip.txt
		show=$( cut -f 1 -d "." /root/ip.txt )
		show1=$( cut -f 2 -d "." /root/ip.txt )
		show2=$( cut -f 3 -d "." /root/ip.txt )
		rm -rf /root/ip.txt
		echo "zone ""$show2.$show1.$show.in-addr.arpa"" IN {" >> /etc/named.rfc1912.zones
		echo "		type master;" >> /etc/named.rfc1912.zones
		echo "		file \"rev.$dnns\";" >> /etc/named.rfc1912.zones
		echo " 	 	allow-update {none; };" >> /etc/named.rfc1912.zones
		echo "};" >> /etc/named.rfc1912.zones			
	else
		echo "You just choose y or n? agains "
	fi
else
	yum install bind* -y
		read -p "Enter your IP DNS: " ipdns
		read -p "Enter you domain name server [DNS]: " dnns
		read -p "Enter your network you want to connect DNS " -e -i any networkk
		ipdnss=$( grep "listen-on port" /etc/named.conf | awk {'print $5'} | cut -f 1 -d ";" )	
		sed -i "s/$ipdnss/$ipdns/g" /etc/named.conf
		networrk=$( grep "allow-query" /etc/named.conf | awk {'print $3'} | cut -f 1 -d ";" )
		sed -i "s/$networkk/$networrk/g" /etc/named.conf
		echo "zone "$dnns" IN { " > /etc/named.rfc1912.zones
		echo "		type master; " >> /etc/named.rfc1912.zones
		echo "		file ""rev.$dnns;" >> /etc/named.rfc1912.zones
		echo "		allow-update {none; };" >> /etc/named.rfc1912.zones
		echo "};" >> /etc/named.rfc1912.zones
		touch /root/ip.txt
		echo "$ipdns" > /root/ip.txt
		show=$( cut -f 1 -d "." /root/ip.txt )
		show1=$( cut -f 2 -d "." /root/ip.txt )
		show2=$( cut -f 3 -d "." /root/ip.txt )
		rm -rf /root/ip.txt
		echo "};" >> /etc/named.conf
		echo "zone ""$show2.$show1.$show.in-addr.arpa"" IN {" >> /etc/named.rfc1912.zones
		echo "		type master;" >> /etc/named.rfc1912.zones
		echo "		file "rev.$dnns";" >> /etc/named.rfc1912.zones
		echo " 	 	allow-update {none; };" >> /etc/named.rfc1912.zones
		echo "};" >> /etc/named.rfc1912.zones	
fi
#Tao zone fw
#touch /var/named/fw.$dnns

return 0
}
while :
do 
clear
	echo "--------------------MENU---------------------"
	echo ""
	echo "What do you want to do?"
	echo "	1) Set an IP address"
	echo "	2) Configure DHCP"
	echo "	3) Route "
	echo "	4) Configure DNS "
	echo " 	5) EXIT "
	read -p "Select an option [1-5]: " opt
	case $opt in
		1)
		set_ip
		;;
		2)
		conf_dhcp
		;;
		3)
		route
		;;
		4)
		conf_dns
		;;
		5)
		exit;;
	esac
	done


