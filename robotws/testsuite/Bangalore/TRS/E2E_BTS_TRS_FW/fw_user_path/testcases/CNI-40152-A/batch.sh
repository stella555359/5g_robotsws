#robot -L trace -b trace.txt -v bts_id:3914 Firewall_ICMPv4_Ingress_RateLimiting.robot

#sleep 20

robot -L trace -b trace.txt -v bts_id:3914 Firewall_RateLimiting_Mplane_ARP_SCTP.robot

sleep 20 

#robot -L trace -b trace.txt -v bts_id:3914 Firewall_spoof_prevention_stateless_statefull.robot

#sleep 20

robot -L trace -b trace.txt -v bts_id:3914 Firewall_ICMPv4_Ingress_RateLimiting_netact.robot


sleep 20


#robot -L trace -b trace.txt -v bts_id:3914 Firewall_ICMPv6_Ingress_RateLimiting.robot  

#sleep 20

robot -L trace -b trace.txt -v bts_id:3914 Firewall_ICMPv6_NDP_Ingress_RateLimiting.robot

