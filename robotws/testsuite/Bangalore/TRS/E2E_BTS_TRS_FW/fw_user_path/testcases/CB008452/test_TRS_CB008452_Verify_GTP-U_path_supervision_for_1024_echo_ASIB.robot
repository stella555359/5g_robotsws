*** Settings ***
Documentation
...     [Author]        "Priyanka"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
#Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Common_LTE4623_Operations.robot
Resource        ${CURDIR}/../resources/Common_LTE4727_Operations.robot

*** Test Cases ***

[1][1.0] CB008452-Verify_Max_AMF_and _GTPUpath_supervision_for_UnSupervisedLink _Configuration_ASIB
    Perform Commissioning       scf_file=${cb008452_asib}   verify_bts_status=False     timeout=600
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature
    ...    operation=update     value=true      timeout=600
    BuiltIn.Sleep    100
    Call Setup      5g=Dual_Stack_6operator_5g:data   parallel=${False}    verify_attach=${False}   attach=${False}    timeout=600
    BuiltIn.Sleep    400
    Block    operation=Cell    rat=NR
    Sleep    120
    Unblock    operation=Cell    rat=NR
    Sleep    120
    Wait Until Keyword Succeeds    5 min    30          Verify Alarm        faultid=7305    occurrences=${26}     should_exist=${True}
    Perform Recommissioning        type=delta             delta_file=${Block_IPv6_AMFs}          timeout=600
    Make SA Call and Verify for 6 Operator      ipV4
    Perform Recommissioning        type=delta             delta_file=${Block_IPv4_AMFs}          timeout=600
    Make SA Call and Verify for 6 Operator      ipV6
    Perform Recommissioning        type=delta             delta_file=${UnBlock_IPv4IPv6_AMFs}          timeout=600
    Traffic Capture Start   capture_device=vm_eth3_interface_8452        alias=gtp_unsupervised
    Send GTPU Echo Request     ${Unsupervised_sgw_ipaddress}/22    ${Enb1_Ip}    2152    2152    GTP    1   ${GTP_Expect_Script}
    ${file2}=        Traffic Capture Stop        alias=gtp_unsupervised

***Keywords***
Add routes on VM
    Run 	sudo ip a a 10.0.1.121 dev eth3
    Run		sudo ip a a 10.0.1.131 dev eth3
    Run		sudo ip a a 10.0.1.132 dev eth3
    Run		sudo ip a a 10.0.1.135 dev eth3
    Run		sudo ip a a 10.0.1.136 dev eth3
    Run		sudo ip a a 10.0.1.137 dev eth3
    Run		sudo ip a a 10.0.1.5 dev eth3
    Run		sudo ip a a 10.0.1.7 dev eth3
    Run		sudo ip a a 10.0.1.9 dev eth3
    Run		sudo ip a a 10.0.1.11 dev eth3
    Run		sudo ip a a 10.0.1.13 dev eth3
    Run		sudo ip a a 10.0.1.15 dev eth3
    Run		sudo ip a a fc00::1/120 dev eth3
    Run		sudo ip a a fc00::5/120 dev eth3
    Run		sudo ip a a fc00::7/120 dev eth3
    Run		sudo ip a a fc00::9/120 dev eth3
    Run		sudo ip a a fc00::13/120 dev eth3
    Run		sudo ip a a fc00::15/120 dev eth3
    Run		sudo ip a a fc00::29/120 dev eth3

Make SA Call and Verify for 6 Operator
       [Arguments]        ${IP_Version}
	Sleep  30
	FOR  ${operator}   IN RANGE   1   7
        ${operator_str}= 	Convert To String	${operator}
		 Set Suite Variable      ${operator}        ${operator}
	    Set Suite Variable      ${operator_str}        ${operator_str}
	    Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${AMF}    6
	     ...     ELSE      set suite variable     ${AMF}    0
	    ${served_amf}=    	Evaluate       ${operator}+${AMF}
		 Traffic capture start           capture_device=lmp_pc_all_interface
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}
	    Stop traffic and detach UE          ${operator}
	 	 ${pcap_file}=       Traffic capture stop
	    Get AMF IP Address      ${served_amf}
	    Get NG-U IP Address     ${operator}           ${IP_Version}
        Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_5g_sa_attach_response_${IP_Version}
        ...    filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_ul_${IP_Version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_dl_${IP_Version}      filter_file_name=${traffic_filter_file_name}
        Sleep    30
    END

Attach UE with operator specific qci and send ul dl traffic
    [Arguments]          ${operator}
	Configure UE       5g=Dual_Stack_6operator_5g:data   command=ue_register  id=${operator}  profile=${operator}
    sleep  10
	Configure UE       5g=Dual_Stack_6operator_5g:data   command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  10
    Configure UE       5g=Dual_Stack_6operator_5g:data   command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}
    ...    gw=${operator}
    sleep  10
    Configure UE       5g=Dual_Stack_6operator_5g:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=20
    sleep  10
    Configure UE       5g=Dual_Stack_6operator_5g:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10

Stop traffic and detach UE
    [Arguments]          ${operator}
	Configure UE       5g=Dual_Stack_6operator_5g:data   command=ue_pdu_session_release  ue=${operator}    pdu=${operator}
    Sleep   50
    Configure UE       5g=Dual_Stack_6operator_5g:data   command=ue_deregister  id=${operator}  ue_deregister_type=switch_off
    Sleep   10

Get AMF IP Address
	[Arguments]          ${served_amf}
	${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}-${served_amf}
    ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
	Set Suite Variable    ${amf_ip}      ${amf_ip}

Get NG-U IP Address
 	[Arguments]          ${operator}        ${IP_Version}
	${index}=    Evaluate      ${operator}-1
	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${nguplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngUplane
	${nguplane_add}=   Get from list       ${nguplane_list}        ${index}
	${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ${IP_Version}AddressDN1
	${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
	${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
    Set Suite Variable     ${nguplane_ip}      ${nguplane_ip}

Install scapy
    Run     sudo -E pip install scapy

Send GTPU Echo Request
    [Arguments]     ${sgw_addr}    ${Destination_IP}       ${Source_port}      ${Destination_port}     ${protocol}     ${count}     ${expect_Script}
    Run             sudo expect ${expect_Script} ${sgw_addr} ${Destination_IP} ${Source_port} ${Destination_port} ${protocol} ${count}
Copy GTP-U text file to ENB
    [Arguments]     ${text_file}
    Put File for ENodeB   ${text_file}  ${destination_path_in_gnb}

Download Alarm File from eNB

    ${alarms}=      Get Active Alarms
    Set Suite Variable      ${Active_alarms}        ${alarms}
    @{SEM_alarms}=      Create List
    ${Dict}=    Create Dictionary
    ${len}=     Get Length      ${alarms}
    :FOR    ${i}    IN RANGE    0   ${len}
    \       Log Dictionary      @{alarms}[${i}]
    \       ${val}=     Get From Dictionary     @{alarms}[${i}]     faultName
    \       Append To List      ${SEM_alarms}       ${val}
    \       Set To Dictionary   ${Dict}     ${i}    ${val}

    Set Suite Variable      ${SEM_alarms}       ${SEM_alarms}
    Set Suite Variable      ${Dict}     ${Dict}
#    [Teardown]     Teardown Admin