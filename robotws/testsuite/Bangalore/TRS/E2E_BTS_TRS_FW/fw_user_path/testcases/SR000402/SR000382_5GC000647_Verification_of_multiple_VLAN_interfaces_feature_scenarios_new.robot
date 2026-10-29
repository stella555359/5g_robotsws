*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "bintw"
...     [Maintenance]                   "TRS I & V Tools Bangalore Team"
...     [Date]                          "* "
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
[1][1.0] SR000382_5GC000647_Verification of multiple VLAN interfaces feature scenarios
    Precondition
    Bring setup onair
    Send traffic and verify throughput
    Stop calls

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
    ...      supported_bands=1:false,2:false,3:false,4:false,42:false ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4|42:a:a-4
    ...      category_dl=17 category_ul=19 ul_64QAM_supported=on freq_gaps=true dl_256QAM_supported=on supported_ul256qam=all
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=100 protocol=udp
    Sleep   60
    ${pcap_file}=       Traffic Capture Stop        alias=eth3_pcap
Stop calls
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_stop ue=1 dir=ul
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=1
