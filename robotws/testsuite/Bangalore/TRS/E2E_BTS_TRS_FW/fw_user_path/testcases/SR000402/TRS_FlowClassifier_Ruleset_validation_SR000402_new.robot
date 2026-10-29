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
Suite Teardown    Post-conditions for test teardown

***variables***
${lte_uplane1}  10.0.1.2
${lte_uplane2}  10.0.1.2

*** Test Cases ***
[1][2.0] TRS_FlowClassifier_Ruleset_validation_SR000402
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=true     timeout=400     alias=default
    Sleep    300
    Call Setup  lte=Plain_config_CUS:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Verify BTS status   should_be_onair=${True}
    Sleep     10
    Configure Single_FSTSCH and verify traffic
    Stop calls
    Configure Multiple_FSTSCH
    Configure FLOWCL_1
    Make call and verify wireshark for flowcl
    Modify flowcl and verify traffic
    Deletion of FLOWCL moc
***Keywords***
Configure Single_FSTSCH and verify traffic
    Perform Recommissioning     type=delta      delta_file=${delta_enable_1FSTSCH}     timeout=300
    Sleep    30
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep       60
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   700
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark           ${pcap_file}        ip.addr==${lte_uplane1}      10000
    Perform Recommissioning		type=delta		delta_file=Deletion_1FSTSCH.xml		timeout=600
    Stop calls
Configure Multiple_FSTSCH
    Perform Recommissioning		type=delta		delta_file=Addition_4FSTSCH.xml		timeout=600
    Sleep   30

Configure FLOWCL_1
    Perform Recommissioning		type=delta		delta_file=Addition_FLOWCL.xml		timeout=600

Make call and verify wireshark for flowcl
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   320
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    1000
	Stop calls
Configure FLOWCL_2
    ${output}=	Run Keyword And Expect Error	*It is required that the set of MOs FLOWCL-* 		Perform Recommissioning
    ...		type=delta		delta_file=Addition_FLOWCL2.xml		timeout=600	skip_parameter_relation_errors=${False}
Deletion of FLOWCL moc
    Perform Recommissioning     type=delta      delta_file=Deletion_FLOWCL.xml     timeout=600
    Sleep   300
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   320
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    15
    Stop calls
Modify flowcl and verify traffic
    Perform Recommissioning		type=delta		delta_file=Modify_FLOWCL.xml		timeout=600
    Sleep   60
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   220
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    2000
    Stop calls
Make call and verify wireshark
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    20
	Stop calls

Verify Data Rate in wireshark
    [Arguments]         ${pcap_file}        ${filter}       ${expected_data_rate}
    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${pcap_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
	${cal_1}=		Evaluate	${expected_data_rate}*0.2
    ${higher_limit}=        Evaluate        ${expected_data_rate}+${cal_1}
    ${lower_limit}=         Evaluate            ${expected_data_rate}-${cal_1}
    Should Be True      ${lower_limit}<${data_rate}<${higher_limit}

Make call and verify throughput
	[Arguments]			${shaper_rate1}				${shaper_rate2}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep       60
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1   cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start  ue=1     dir=ul     Mbps=20     protocol=udp
    Sleep   60
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=2 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start  ue=2    dir=ul  Mbps=20     protocol=udp
    Sleep   60

    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
	Verify Data Rate in wireshark			${pcap_file}		ip.addr==${lte_uplane1}			${shaper_rate1}
	Verify Data Rate in wireshark			${pcap_file}		ip.addr==${lte_uplane2}			${shaper_rate2}

Stop calls
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_stop ue=1 dir=ul
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=1

