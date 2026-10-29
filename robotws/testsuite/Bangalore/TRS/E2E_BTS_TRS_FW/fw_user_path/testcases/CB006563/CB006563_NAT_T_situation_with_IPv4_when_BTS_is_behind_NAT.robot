*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "26:10:2021"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006563"
...     [Validated_TestLine]        "3297 NAT server IP - 10.45.138.174, Secgw ip - 10.43.255.224"


Library           Collections
Resource          taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
Resource    	${CURDIR}/../resources/Common_IPSEC_Operations.robot


Library           SSHLibrary
Library           ute_pdu


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


***Variables***
${SCf_3297_NAT}       SCFC_3297_NAT_Scenario_1.xml
${filter_file_name}        /home/ute/fw_user_path/testcases/CB006563/resources/traffic_filters.json
***Test Cases***

[1][2.0] TRS_NAT-T situation with IPv4 when BTS is behind NAT device_CB006563
     Perform Commissioning       scf_file=${SCf_NAT}   verify_bts_status=False     timeout=800     alias=default
     Peform delta Commissioning - set flag to false
     Sleep  60
     Check Dpd alarms
     enable NAT-T flag
     Sleep  60
     Check ipsec tunnel status
     check rekeying part

*** Keywords ***
Peform delta Commissioning - set flag to false
    Perform Recommissioning     type=param     param_path=MRBTS-3792/MNL-1/MNLENT-1/FEATCADM-1:actNatT    operation=update
    ...        value=false     timeout=300


Check ipsec tunnel status
    Verify Ipsec Tunnels Status

check rekeying part
#Step1
    ${numbers}=    Evaluate    random.sample(range(1, 7), 1)    random
    Execute command on ENodeB		 ipsec statusall | grep "conn[2]" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_1}=		Set Variable	${stdout}
    Set Suite Variable      ${key_1}      ${key_1}
#Step2
    Sleep  400
    Execute command on ENodeB		 ipsec statusall | grep "conn[2]" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_2}=		Set Variable	${stdout}
    Set Suite Variable      ${key_2}      ${key_2}
    Should Not Be Equal		${key_1}    		${key_2}

enable NAT-T flag
    Perform Recommissioning     type=param     param_path=MRBTS-3792/MNL-1/MNLENT-1/FEATCADM-1:actNatT    operation=update
    ...        value=true     timeout=300


Check Dpd alarms
    [Arguments]		${occurrences}=4    	${alias}=default
	Verify Alarm		faultid=61030		occurrences=${occurrences}	alias=${alias}   should_exist=${True}

Verify Ipsec Tunnels Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
     	${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
     END

verify NAT-D packets
    Traffic Capture Start        capture_device=oam_device    mode=file     measurement_point=Transport_Interface  uplane_capturing=True
    ...   timeout=180     alias=default
    Sleep       60
    ${pcap_file}=  Traffic Capture Stop    mode=file   alias=default
    Run  mv ${pcap_file} ${EXECDIR}/gtp.pcap
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_isakmp_packets  filter_file_name=${filter_file_name}
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_UDP_packets  filter_file_name=${filter_file_name}