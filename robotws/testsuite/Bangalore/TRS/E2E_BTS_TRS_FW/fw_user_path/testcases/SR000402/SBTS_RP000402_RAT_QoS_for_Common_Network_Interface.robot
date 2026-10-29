*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Spandana N"
...     [Maintenance]                   "TRS I & V Tools Bangalore Team"
...     [Scenario]                      "To verify L2 QoS"
...     [Date]                          "* "
...     [Description]                   "To verify L2 QoS and verify shaping in wireshark"
...     [QC_Path]                       "QC_Path in Test Plan"
...     [QC_ID]                         "QC_ID in Tiest Lab for reporting"



Library         ta_emss

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown



***variables***
${lte_uplane1}  10.0.1.2
${lte_uplane2}  10.0.1.2

*** Test Cases ***
[1][1.0] SBTS_RP000402_RAT QoS for Common Network Interface

    Precondition
    Bring setup onair
    Send traffic and verify throughput
    Stop calls
    Configure Single_FSTSCH
    Verify throughput for FSTSCH
    Verify DSCP value
    Change sir rate
    Perform reset and verify changed sir throughput
    Configure SLS and verify throughput

***Keywords***
Precondition
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=true     timeout=400     alias=default
    Sleep    700

Bring setup onair
    Call Setup  5g=asoe_vlan:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Verify BTS status   should_be_onair=${True}
    Sleep     100

Send traffic and verify throughput
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    20

Configure Single_FSTSCH
    Perform Recommissioning     type=delta      rat=5g     delta_file=${delta_enable_1FSTSCH}     timeout=300
    Sleep    30
Verify throughput for FSTSCH
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    10
    Stop calls

Change sir rate
    Perform Recommissioning     type=param      rat=5g      param_path=FSTSCH-1:sir     operation=update    value=5000       timeout=300
    Sleep   60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap

    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    5
    Stop calls


Perform reset and verify changed sir throughput
    Reset Bts       should_be_onair=${False}      wait_for=300
    Sleep   300
    Bring setup onair
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap

    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    5
    Stop calls


Configure SLS and verify throughput
##add configure ethif step
    Perform Recommissioning     type=param      rat=5g      param_path=ETHIF-1:sirTotal    operation=update    value=2000  timeout=300
    Sleep   60

    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap

    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap

    Verify Data Rate in wireshark   ${pcap_file}    gtp    2
    Stop calls
Verify DSCP value
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      5g=asoe_vlan:data     command=enb_x2_link_up	enb=1	target=2
	Sleep	10
    Configure UE      5g=asoe_vlan:data     command=ue_register		id=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    Sleep   10
	Configure UE      5g=asoe_vlan:data     command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    Sleep   10
    Configure UE      5g=asoe_vlan:data     command=trf_data_start	ue=1	pdu=1	qfi=1	dir=ul	trf_id=1	mbps=20
	Sleep	120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    ${count}=    Run  tshark -r ${pcap_file} -Y "ip.src==10.0.1.2 && ip.dsfield.dscp == ${def_dscp_qci}"|wc -l 2>/dev/null
    Should be True     ${count}>0
    Stop calls

Stop calls
    Configure UE      5g=asoe_vlan:data     command=trf_data_stop       ue=1    dir=ul
    Configure UE      5g=asoe_vlan:data     command=ue_deregister       id=l
Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
	${cal_1}=		Evaluate	${expected_data_rate}*0.1
    ${higher_limit}=        Evaluate        ${expected_data_rate}+${cal_1}
    ${lower_limit}=         Evaluate            ${expected_data_rate}-${cal_1}
    Should Be True      ${lower_limit}<${data_rate}<${higher_limit}
