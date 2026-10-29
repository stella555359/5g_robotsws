*** Settings ***

Documentation
...     [Date]                  "15-06-2022"
...     [Author]                "Bibhukinkar Behera"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"


#Resource  setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

***Keywords***
Bring setup onair
    Call Setup      5g=airphone:data  parallel=${False}  verify_attach=${False}   attach=${False}  ipv4_or_6=ipv4
	Call Setup      5g=airphone:data  parallel=${False}  verify_attach=${False}   attach=${False}  ipv4_or_6=ipv4

Randomise dscp values
    [Arguments]         ${count}
	${rand_dscp_values}=         Evaluate    random.sample(range(0, 64),${count})  random
    ${dscp_values}=         Create List
	FOR 	${i}  IN RANGE	${count}
		Run Keyword if		${rand_dscp_values}[0]<10	Append to list		${dscp_values}   ${rand_dscp_values}[0]
	...	ELSE		append to list	    ${dscp_values}		${rand_dscp_values}[0]
	END
    Set Suite Variable      ${dscp_values}
Randomise '${num}' scheduling weights
	${Queue_value}=     Evaluate    random.sample(${DSCP2QMAP_weights},${num})       random
	Set Suite variable		${Queue_value}

Randomise '${num}' FSTSCH id
	${random_fstsch}=     Evaluate    random.sample(range(1,45),${num})       random
	Set Suite variable		${random_fstsch}

send traffic in 5g
    [Arguments]     ${lua_profile}    ${ue_id}   ${bearer_id}    ${direction}    ${rate}      ${trafficid}      ${bandwidth}
     Configure UE      5g=${lua_profile}:data    command=trf_data_start  ue=${ue_id}  id=${bearer_id}  dir=${direction}
    ...		trf_id=${trafficid}  ${rate}=${bandwidth}

Attach 2 UE with different bearer
    [Arguments]     ${lua_profile}    ${ue1_id}   ${ue2_id}    ${bearer_id}
    Configure UE       5g=${lua_profile}:data    command=ue_attach  id=${ue1_id}  profile=1
    Configure UE       5g=${lua_profile}:data    command=bearer_add  ue=${ue1_id}  id=${bearer_id}  filter=1  precedence=1
    Configure UE       5g=${lua_profile}:data    command=enb_ue_dc_start  ue=${ue1_id}  target_gnb=2  target_cells=1
    ...		bearer=2,${bearer_id}  type=split_scg
    Configure UE       5g=${lua_profile}:data    command=ue_attach  id=${ue2_id}  profile=1
    Configure UE       5g=${lua_profile}:data    command=enb_ue_dc_start  ue=${ue2_id}  target_gnb=2  target_cells=1  bearer=2  type=split_scg
    Sleep   5

Detach UE
    [Arguments]         ${rat}      ${lua_profile}      ${ue_id}
	Configure UE       ${rat}=${lua_profile}:data    command=ue_detach  id=${ue_id}

Pump traffic for both UE
    Configure UE       5g=airphone:data  command=trf_data_start  ue=1  id=8  dir=ul  trf_id=2  mbps=5
    Configure UE       5g=airphone:data  command=trf_data_start  ue=2  id=2  dir=ul  trf_id=2  mbps=5
    Sleep    10

Capture wireshark
    [Arguments]         ${device}       ${cap_filter}
	Traffic capture start           capture_device=${device}    capture_filter=${cap_filter}
	Sleep   60
    ${pcap_file}=       Traffic capture stop
    Set Suite Variable          ${pcap_file}

Verify shaping for both UE
    [Arguments]     ${ue1_shaper_rate}     ${ue2_shaper_rate}
	Run  tshark -r ${pcap_file} -Y "ip.src==${ue_id1}" -w ${EXECDIR}/ue1_ul_capture 2>/dev/null
    ${data_rate_ue1_ul}=  Run  capinfos ${EXECDIR}/ue1_ul_capture -i | tail -1 | awk '{ print $4 }'
    ${bit_rate}=  Run  capinfos ${EXECDIR}/ue1_ul_capture -i | tail -1 | awk '{ print $5 }'
    ${status}=      Run Keyword and return status        Should contain      ${bit_rate}     Mbps
    ${status1}=      Run Keyword and return status        Should contain      ${bit_rate}     kbps


#    ${bit_rate}=     Run Keyword if      ('${status}'=='False' and '${status1}'=='False')
    ...		Run  capinfos ${EXECDIR}/ue1_ul_capture -i | tail -1 | awk '{ print $5 }'         ELSE         Set Variable           ${bit_rate}
    ${status2}=      Run Keyword and return status        Should contain      ${bit_rate}     bits/s
    ${data_rate_ue1_ul}=       Run Keyword If      '${status}'=='True'         Remove string        ${data_rate_ue1_ul}      ,   Mbps
    ...       ELSE IF          '${status1}'=='True'         Remove string        ${data_rate_ue1_ul}      ,        kbps
    ...       ELSE IF          '${status2}'=='True' and ${data_rate_ue1_ul}!=0        Remove string        ${data_rate_ue1_ul}       ,    bits/s
    ...       ELSE              Set Variable      ${data_rate_ue1_ul}

	${data_rate_ue1_ul}=        Run Keyword If      '${status}'=='True'                 Evaluate          ${data_rate_ue1_ul}*1000
	...		ELSE         Set Variable      ${data_rate_ue1_ul}

#	${status}=        Run Keyword and return status        Should Be True      ${data_rate_ue1_ul}>${ue1_shaper_rate} - 5
    ${data_status}=        Run Keyword and return status       Run Keyword If      ${data_rate_ue1_ul}<=100 and ${data_rate_ue1_ul}>=0 and
    ...		${ue1_shaper_rate}!=0          Should Be True   ${data_rate_ue1_ul}<${ue1_shaper_rate} + 100
    ...       ELSE IF         ${data_rate_ue1_ul}<=1000 and ${data_rate_ue1_ul}>100 and ${ue1_shaper_rate}!=0          Should Be True
    ...      ${data_rate_ue1_ul}<${ue1_shaper_rate} + 100
    ...       ELSE IF         ${data_rate_ue1_ul}>1000 and ${ue1_shaper_rate}!=0          Should Be True
    ...      ${data_rate_ue1_ul}<${ue1_shaper_rate} + 1000
    ...       ELSE                    Should Be True      ${data_rate_ue1_ul}==${ue1_shaper_rate}

	Should Be True         '${data_status}'=='True'

#	${status}=        Run Keyword and return status        Should Be True      ${data_rate_ue1_ul}>${ue1_shaper_rate} - 5
	${data_status}=        Run Keyword and return status       Run Keyword If      ${data_rate_ue1_ul}<=100 and ${data_rate_ue1_ul}>=0
	...	and ${ue1_shaper_rate}!=0          Should Be True      ${data_rate_ue1_ul}>${ue1_shaper_rate} - 100
	...     ELSE IF              ${data_rate_ue1_ul}<=1000 and ${data_rate_ue1_ul}>100 and ${ue1_shaper_rate}!=0
	...	Should Be True      ${data_rate_ue1_ul}>${ue1_shaper_rate} - 100
	...     ELSE IF              ${data_rate_ue1_ul}>1000 and ${ue1_shaper_rate}!=0          Should Be True
	...     ${data_rate_ue1_ul}>${ue1_shaper_rate} - 1000
	...       ELSE                   Should Be True      ${data_rate_ue1_ul}==${ue1_shaper_rate}

	Should Be True         '${data_status}'=='True'


    Run  tshark -r ${pcap_file} -Y "ip.src==${ue_id2}" -w ${EXECDIR}/ue2_ul_capture 2>/dev/null
    ${data_rate_ue2_ul}=  Run  capinfos ${EXECDIR}/ue2_ul_capture -i | tail -1 | awk '{ print $4 }'
    ${bit_rate}=  Run  capinfos ${EXECDIR}/ue2_ul_capture -i | tail -1 | awk '{ print $5 }'
    ${status}=      Run Keyword and return status        Should contain      ${bit_rate}     Mbps
    ${status1}=      Run Keyword and return status        Should contain      ${bit_rate}     kbps


#    ${bit_rate}=     Run Keyword if      ('${status}'=='False' and '${status1}'=='False')
    ...		Run  capinfos ${EXECDIR}/ue2_ul_capture -i | tail -1 | awk '{ print $5 }'         ELSE         Set Variable           ${bit_rate}
    ${status2}=      Run Keyword and return status        Should contain      ${bit_rate}     bits/s
    ${data_rate_ue2_ul}=       Run Keyword If      '${status}'=='True'         Remove string        ${data_rate_ue2_ul}      ,   Mbps
    ...       ELSE IF          '${status1}'=='True'         Remove string        ${data_rate_ue2_ul}      ,        kbps
    ...       ELSE IF          '${status2}'=='True' and ${data_rate_ue2_ul}!=0        Remove string        ${data_rate_ue2_ul}       ,    bits/s
    ...       ELSE             Set Variable      ${data_rate_ue2_ul}


    ${data_rate_ue2_ul}=        Run Keyword If      '${status}'=='True'                 Evaluate          ${data_rate_ue2_ul}*1000
    ...     ELSE         Set Variable      ${data_rate_ue2_ul}

#   ${status}=        Run Keyword and return status        Should Be True      ${data_rate_ue2_ul}>${ue2_shaper_rate} - 5
    ${data_status}=        Run Keyword and return status       Run Keyword If      ${data_rate_ue2_ul}<=100 and ${data_rate_ue2_ul}>=0 and
    ...		${ue2_shaper_rate}!=0          Should Be True   ${data_rate_ue2_ul}<${ue2_shaper_rate} + 100
    ...       ELSE IF         ${data_rate_ue2_ul}<=1000 and ${data_rate_ue2_ul}>100 and ${ue2_shaper_rate}!=0
    ...		Should Be True      ${data_rate_ue2_ul}<${ue2_shaper_rate} + 100
    ...       ELSE IF         ${data_rate_ue2_ul}>1000 and ${ue2_shaper_rate}!=0          Should Be True
    ...      ${data_rate_ue2_ul}<${ue2_shaper_rate} + 1000
    ...       ELSE           Should Be True      ${data_rate_ue2_ul}==${ue2_shaper_rate}

    Should Be True         '${data_status}'=='True'

#    ${status}=        Run Keyword and return status        Should Be True      ${data_rate_ue2_ul}>${ue1_shaper_rate} - 5
    ${data_status}=        Run Keyword and return status       Run Keyword If      ${data_rate_ue2_ul}<=100 and ${data_rate_ue2_ul}>=0 and
    ...		${ue2_shaper_rate}!=0          Should Be True      ${data_rate_ue2_ul}>${ue2_shaper_rate} - 100
    ...		ELSE IF		${data_rate_ue2_ul}<=1000 and ${data_rate_ue2_ul}>100 and ${ue2_shaper_rate}!=0
    ...		Should Be True      ${data_rate_ue2_ul}>${ue2_shaper_rate} - 100
    ...       	ELSE IF              ${data_rate_ue2_ul}>1000 and ${ue2_shaper_rate}!=0          Should Be True
    ...		${data_rate_ue2_ul}>${ue2_shaper_rate} - 1000
    ...		ELSE           Should Be True      ${data_rate_ue2_ul}==${ue2_shaper_rate}

    Should Be True         '${data_status}'=='True'

	Run 	rm ${EXECDIR}/ue2_ul_capture ${EXECDIR}/ue1_ul_capture

Verify throughput is attained
    [Arguments]         ${total_shaper_rate}
	Run  tshark -r ${pcap_file} -Y "ip.src==${ue_id1} || ip.src==${ue_id2}" -w ${EXECDIR}/ue_ul_capture 2>/dev/null
	${total_rate_ul}=  Run  capinfos ${EXECDIR}/ue_ul_capture -i | tail -1 | awk '{ print $4 }'
    ${bit_rate}=  Run  capinfos ${EXECDIR}/ue_ul_capture -i | tail -1 | awk '{ print $5 }'
    ${status}=      Run Keyword and return status        Should contain      ${bit_rate}     Mbps
    ${status1}=      Run Keyword and return status        Should contain      ${bit_rate}     kbps
    ${status2}=      Run Keyword and return status        Should contain      ${bit_rate}     bits/s
    ${total_rate_ul}=       Run Keyword If      ${status}==${True}         Remove string       ${total_rate_ul}    ,   Mbps
    ...       ELSE IF          ${status1}==${True}         Remove string        ${total_rate_ul}      ,    kbps
    ...       ELSE           ${status2}==${True}         Remove string        ${total_rate_ul}       ,   bits/s

	${total_rate_ul}=        Run Keyword If      ${status}==${True}                 Evaluate          ${total_rate_ul}*1000
	...		ELSE         Set Variable      ${total_rate_ul}
	Should Be True      ${total_rate_ul}<${total_shaper_rate} + 200
	Should Be True      ${total_rate_ul}>${total_shaper_rate} - 200

Calculate the bandwidth assigned for each UE
    [Arguments]             ${total_sir}        ${weight1}      ${weight2}
    ${weight_dict}     Create Dictionary      AF4=10000.0  	AF3=1000.0		AF2=100.00		AF1=10.0	BE=1.0
    ...		EF3=${total_sir}
	${ue1_weight}=	   Get From Dictionary			${weight_dict}		${weight1}
	${ue2_weight}=	   Get From Dictionary			${weight_dict}		${weight2}

	${total_weight}=        Evaluate       ${ue1_weight} + ${ue2_weight}
	${ue1_dist_trf}=        Run Keyword If    '${weight1}'=='EF3'       Evaluate    ${total_sir}
	...     ELSE IF      '${weight2}'=='EF3'    Set Variable   0
	...	ELSE      Evaluate        (${ue1_weight}/${total_weight})*${total_sir}.0
#    ${ue1_dist_trf}=        Run Keyword If      ${ue1_dist_trf}<10 and ${ue1_dist_trf}>0
	...	Evaluate      ${ue1_dist_trf}*1000                ELSE      Set variable     ${ue1_dist_trf}
    ${ue2_dist_trf}=        Run Keyword If    '${weight2}'=='EF3'       Evaluate    ${total_sir}
	...     ELSE IF      '${weight1}'=='EF3'    Set Variable   0
	...	ELSE      Evaluate        (${ue2_weight}/${total_weight})*${total_sir}.0
#    ${ue2_dist_trf}=        Run Keyword If      ${ue2_dist_trf}<10 and ${ue2_dist_trf}>0
	...      Evaluate      ${ue2_dist_trf}*1000                ELSE      Set Variable     ${ue2_dist_trf}
    Set Suite Variable     ${ue1_dist_trf}      ${ue1_dist_trf}
    Set Suite Variable     ${ue2_dist_trf}      ${ue2_dist_trf}

Brinup non-collapsed 4 VLAN configuration
    ${ipv6_addresses}=		Create List		fc00::3:16/126		fc00::3:1a/126        fc00::3:1e/126   fc00::3:22/126
	${ipv6_brd_address}=	Create List		fc00::3:18		fc00::3:1c		fc00::3:20    fc00::3:24
	${ipv4_addresses}=		Create List		10.0.3.233		10.0.3.237		10.0.3.241		10.0.3.245
	FOR 	${i}	IN RANGE	0    4
			Run		sudo ip link add link eth3 name eth3.${tl.vlan_ids}[${i}] type vlan id ${tl.vlan_ids}[${i}]
		Run		sudo ip -6 addr add ${ipv6_addresses}[${i}] brd ${ipv6_brd_address}[${i}] dev eth3.${tl.vlan_ids}[${i}]
			Run		sudo ip addr add ${ipv4_addresses}[${i}]/30 dev eth3.${tl.vlan_ids}[${i}]
			Run		sudo ip link set dev eth3.${tl.vlan_ids}[${i}] up
    END

	Run		sudo ip -6 route add fc00::3:7 via fc00::3:17 dev eth3.${tl.vlan_ids}[0]
	Run		sudo ip -6 route add fc00::3:b via fc00::3:1b dev eth3.${tl.vlan_ids}[1]
	Run		sudo ip -6 route add fc00::3:f via fc00::3:1f dev eth3.${tl.vlan_ids}[2]
	Run		sudo ip -6 route add fc00::3:13 via fc00::3:23 dev eth3.${tl.vlan_ids}[3]
	Run		sudo ifconfig eth3 inet6 add fc00::1/116

	Run		sudo ip route add 10.0.3.210 via 10.0.3.234 dev eth3.${tl.vlan_ids}[0]
	Run		sudo ip route add 10.0.3.214 via 10.0.3.238 dev eth3.${tl.vlan_ids}[1]
	Run		sudo ip route add 10.0.3.218 via 10.0.3.242 dev eth3.${tl.vlan_ids}[2]
	Run		sudo ip route add 10.0.3.222 via 10.0.3.246 dev eth3.${tl.vlan_ids}[3]

Bringup simulated core ips on VM
    Run         sudo ip a a 10.0.1.121/24 dev eth3
    Run         sudo ip a a 10.0.1.131/24 dev eth3
    Run         sudo ip a a 10.0.1.132/24 dev eth3
    Run         sudo ip a a 10.0.1.133/24 dev eth3
    Run         sudo ip a a 10.0.1.134/24 dev eth3
    Run         sudo ip a a 10.0.1.135/24 dev eth3
    Run         sudo ip a a 10.0.1.136/24 dev eth3

    Run     sudo ifconfig eth3 inet6 add fc00::1/116
    Run     sudo ifconfig eth3 inet6 add fc00::121/116
    Run     sudo ifconfig eth3 inet6 add fc00::131/116
    Run     sudo ifconfig eth3 inet6 add fc00::132/116
    Run     sudo ifconfig eth3 inet6 add fc00::133/116
    Run     sudo ifconfig eth3 inet6 add fc00::134/116
    Run     sudo ifconfig eth3 inet6 add fc00::135/116
    Run     sudo ifconfig eth3 inet6 add fc00::136/116

Bringup collapsed 4 VLAN configuration
    ${ipv6_addresses}=		Create List		fc00::3:6/126		fc00::3:a/126        fc00::3:e/126   fc00::3:12/126
	${ipv4_brd_address}=	Create List		10.0.3.211		10.0.3.215		10.0.3.219    10.0.3.223
	${ipv4_addresses}=		Create List		10.0.3.209		10.0.3.213		10.0.3.217		10.0.3.221
	FOR	${i}	IN RANGE	4
			Run		sudo ip link add link eth3 name eth3.${tl.vlan_ids}[${i}] type vlan id ${tl.vlan_ids}[${i}]
           Run     sudo ip addr add ${ipv4_addresses}[${i}]/30 brd ${ipv4_brd_address}[${i}] dev eth3.${tl.vlan_ids}[${i}]
           Run     sudo ip -6 addr add ${ipv6_addresses}[${i}] dev eth3.${tl.vlan_ids}[${i}]
			Run		sudo ip link set dev eth3.${tl.vlan_ids}[${i}] up
    END

Bringdown VLANS on VM
    [Arguments]         ${vlans}
    ${length}=      Get Length      ${vlans}
    FOR    ${i}    IN RANGE        ${length}
           Run     sudo ip link delete eth3.${vlans}[${i}]
    END
