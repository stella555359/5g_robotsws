*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "bintw"
...     [Maintenance]                   "TRS I & V Tools Bangalore Team"
...     [Scenario]                      "To verify L2 QoS"
...     [Date]                          "* "
...     [Description]                   "To verify L2 QoS and verify shaping in wireshark"
...     [QC_Path]                       "QC_Path in Test Plan"
...     [QC_ID]                         "QC_ID in Tiest Lab for reporting"



Library         ta_emss

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/FSTSCH_Counters.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

*** Test Cases ***
[1][1.0] TRS_5GC000913_Verification_of_5GC000913_1_to_1_first_level_sheduler_mapping_IPv4
    Precondition
    Bring setup onair
    Send traffic and verify throughput
    Stop calls
    Configure Single_FSTSCH
    Verify throughput for FSTSCH
    Verify DSCP value
    Change sir rate
    Perform reset and verify changed sir throughput
    Modify firstlevelstatistics
    Verify FSTSCH_BE counters
    Verify FSTSCH_EF1 counters
    Verify FSTSCH_EF2 counters
    Verify FSTSCH_EF3 counters
    Verify FSTSCH_AF1 counters
    Verify FSTSCH_AF2 counters
    Verify FSTSCH_AF3 counters
    Verify FSTSCH_AF4 counters
    Configure SLS and verify throughput
***Keywords***
Precondition
    Perform Commissioning       scf_file=${base_scf_402}   verify_bts_status=true     timeout=400     alias=default
    Sleep    700

Bring setup onair
    Call Setup  lte=Plain_config_CUS:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Verify BTS status   should_be_onair=${True}
    Sleep     10

Send traffic and verify throughput
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...     supported_bands=1:false,2:false,3:false,4:false,42:false ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4
    ...     category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   100
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    100

Configure Single_FSTSCH
    Perform Recommissioning     type=delta      rat=lte     delta_file=${delta_enable_FSTSCH_75}     timeout=300
    Sleep    30
Verify throughput for FSTSCH
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...     supported_bands=1:false,2:false,3:false,4:false,42:false ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4
    ...     category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   120
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    75
    Stop calls
Change sir rate
    Perform Recommissioning     type=param      param_path=FSTSCH-1:sir     operation=update    value=50000     timeout=300
    Sleep   60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...     supported_bands=1:false,2:false,3:false,4:false,42:false ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4
    ...     category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   220

    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    50
    Stop calls

Perform reset and verify changed sir throughput
    Reset Bts       should_be_onair=${False}      wait_for=300
    Sleep   300
    Bring setup onair
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...      supported_bands=1:false,2:false,3:false,4:false,42:false
    ...     ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4 category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true
    ...      dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   60
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    50
    Stop calls


Configure SLS and verify throughput
##add configure ethif step
    Perform Recommissioning     type=param      rat=lte      param_path=ETHIF-1:sirTotal    operation=update    value=25000  timeout=300
    Sleep   60
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...       supported_bands=1:false,2:false,3:false,4:false,42:false
    ...      ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4 category_dl=17 category_ul=19 ul_64QAM_supported=on
    ...      freq_gaps=true dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   60
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    Verify Data Rate in wireshark   ${pcap_file}    gtp    25
    Stop calls

Verify DSCP value
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_param id=1 release=15 category=12
    ...      supported_bands=1:false,2:false,3:false,4:false,42:false
    ...      ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4 category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true
    ...      dl_256QAM_supported=on supported_ul256qam=all

    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   60
    Sleep   100
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
    ${count}=    Run  tshark -r ${pcap_file} -Y "ip.src==10.0.1.2 && ip.dsfield.dscp == ${def_dscp_qci_9}"|wc -l 2>/dev/null
    Should be True     ${count}>0
    Stop calls

Stop calls
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_stop ue=1 dir=ul
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=1

Modify firstlevelstatistics
     Perform Recommissioning     type=param  param_path=PMTNLINT-1:firstLevelSchedulerStatisticsInterval    operation=update
     ...    value=5min     timeout=300
    Sleep   300
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
