*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/10cells_ecpri_100M/2_AEQE_4_AWHQN
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    True
@{PARAMS_IN_SWCONFIG}
# L1 flag
...    0x8000A8=0
...    0x8000A7=0
...    0x02A5=2
#L2 PS flag
...    0x580291=1
${SRS_config_in_RRCreconfig_FILTER}
...    (((nr-rrc.criticalExtensions == 0) ) && (nr-rrc.srs_Config == 1)) && (nr-rrc.c1 == 0)

${N78DLUL_N77DLUL_1SRSport}    SEPARATOR=
...    E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603806546C28D6080A1A0259651311000F
...    5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4CD6080A1A0259651311000F5B0404041C3BC70E
...    418700040C9E3EAE0009E00380027800546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE
...    0009E00380027800546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000004107
...    13400000041C4C0000000020268D8000160201100883D87C001800140E0A00E06013003800341F00000000000007
...    2A680008000000000001A55143C001C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA
...    1280

${N78DLUL_N77DLUL_4SRSport}    SEPARATOR=
...    E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603806546C28D6080A1A0259651311000F
...    5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4CD6080A1A0259651311000F5B0404041C3BC70E
...    418700040C9E3EAE0009E00380027800546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE
...    0009E00380027800546C4ED6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAA00000A0000004107
...    13400000041C4C0000000020268D8000160201100883D87C001800140E0A00E06013003800341F00000000000007
...    2A680008000000001001A55743C001C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA
...    1280

@{fault_list}    5512    4282

*** Test Cases ***
CB010332-A-B4_ET_01_01_UE access network with pSRS for positioning with Frame 1208
    [Documentation]
    [Tags]    TC01    owner-lishuo.geng
    log to console    step: attach 1 port UE-1 to cell-3
    Attach One UE with 1 SRS port    ue_id=1    target_cells=3
    Set SRS Configuration    id=1    num_periodic=0    type=periodic
    start to capture wireshark log    tag=1_for_1port_UE_with_pSRS
    trigger Positioning Request For UE    ue_id=1
    log to console    step:check SRS resource allocation for UE-1 on cell3
    ${srs_info}    create list
    ...                           SRS-Resource/nrofSRS-Ports=[RE]port1 .*
    ...                           SRS-Resource/transmissionComb=[RE]n2 .*
    ...                           SRS-Resource/combOffset-n2=0
    ...                           SRS-Resource/cyclicShift-n2=0
    ...                           SRS-Resource/startPosition=0
    ...                           SRS-Resource/nrofSymbols=[RE]n1 .*
    ...                           SRS-Resource/resourceType=[RE]periodic .*
    ...                           SRS-Resource/periodic/periodicityAndOffset-p/sl5=3
    ...                           SRS-Resource/c-SRS=0
    ...                           SRS-Resource/b-SRS=0
    ...                           SRS-Resource/sequenceId=52
    ...                           SRS-Resource/freqDomainPosition=0
    ...                           SRS-ResourceSet/resourceType=[RE]periodic .*
    ...                           SRS-ResourceSet/usage=[RE]codebook .*
    download and check wireshark fields    tag=1_for_1port_UE_with_pSRS
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE1
    Send Throuput and check Throuput    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
    log to console    step: attach 2 port UE-2 to cell-4
    Attach One UE with 2 SRS ports    ue_id=2    target_cells=4
    start to capture wireshark log    tag=2_for_2port_UE_with_pSRS
    trigger Positioning Request For UE    ue_id=2
    log to console    step:check SRS resource allocation for UE-2 on cell4
    ${srs_info}    create list
    ...                           SRS-Resource/nrofSRS-Ports=[RE]ports2 .*
    ...                           SRS-Resource/transmissionComb=[RE]n2 .*
    ...                           SRS-Resource/combOffset-n2=1
    ...                           SRS-Resource/cyclicShift-n2=1
    ...                           SRS-Resource/startPosition=0
    ...                           SRS-Resource/nrofSymbols=[RE]n1 .*
    ...                           SRS-Resource/resourceType=[RE]periodic .*
    ...                           SRS-Resource/periodic/periodicityAndOffset-p/sl2560=3
    ...                           SRS-Resource/c-SRS=0
    ...                           SRS-Resource/b-SRS=0
    ...                           SRS-Resource/sequenceId=53
    ...                           SRS-Resource/freqDomainPosition=0
    ...                           SRS-ResourceSet/resourceType=[RE]periodic .*
    ...                           SRS-ResourceSet/usage=[RE]codebook .*
    download and check wireshark fields    tag=2_for_2port_UE_with_pSRS
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE2
    Send Throuput and check Throuput    ue_id=2
    Release Ues    ue_type=sa    ue_id=2
    log to console    step: attach 4 port UE-3 to cell-5
    Attach One UE with 4 SRS ports    ue_id=3    target_cells=5
    start to capture wireshark log    tag=3_for_4port_UE_with_pSRS
    trigger Positioning Request For UE    ue_id=3
    log to console    step:check SRS resource allocation for UE-3 on cell5
    ${srs_info}    create list
    ...                           SRS-Resource/nrofSRS-Ports=[RE]ports2 .*
    ...                           SRS-Resource/transmissionComb=[RE]n4 .*
    ...                           SRS-Resource/combOffset-n4=2
    ...                           SRS-Resource/cyclicShift-n4=0
    ...                           SRS-Resource/startPosition=0
    ...                           SRS-Resource/nrofSymbols=[RE]n1 .*
    ...                           SRS-Resource/resourceType=[RE]periodic .*
    ...                           SRS-Resource/periodic/periodicityAndOffset-p/sl20=3
    ...                           SRS-Resource/c-SRS=63
    ...                           SRS-Resource/b-SRS=0
    ...                           SRS-Resource/sequenceId=54
    ...                           SRS-Resource/freqDomainPosition=0
    ...                           SRS-ResourceSet/resourceType=[RE]periodic .*
    ...                           SRS-ResourceSet/usage=[RE]codebook .*
    download and check wireshark fields    tag=3_for_4port_UE_with_pSRS
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE3
    Send Throuput and check Throuput    ue_id=3
    Release Ues    ue_type=sa    ue_id=3
    log to console    step: attach 4 port UE-4 to cell-6
    Attach One UE with 4 SRS ports    ue_id=4    target_cells=6
    start to capture wireshark log    tag=4_for_4port_UE_with_pSRS
    trigger Positioning Request For UE    ue_id=4
    log to console    step:check SRS resource allocation for UE-4 on cell6
    ${srs_info}    create list
    ...                           SRS-Resource/nrofSRS-Ports=[RE]ports2 .*
    ...                           SRS-Resource/transmissionComb=[RE]n4 .*
    ...                           SRS-Resource/combOffset-n4=3
    ...                           SRS-Resource/cyclicShift-n4=1
    ...                           SRS-Resource/startPosition=0
    ...                           SRS-Resource/nrofSymbols=[RE]n1 .*
    ...                           SRS-Resource/resourceType=[RE]periodic .*
    ...                           SRS-Resource/periodic/periodicityAndOffset-p/sl2560=3
    ...                           SRS-Resource/c-SRS=63
    ...                           SRS-Resource/b-SRS=0
    ...                           SRS-Resource/sequenceId=55
    ...                           SRS-Resource/freqDomainPosition=0
    ...                           SRS-ResourceSet/resourceType=[RE]periodic .*
    ...                           SRS-ResourceSet/usage=[RE]codebook .*
    download and check wireshark fields    tag=4_for_4port_UE_with_pSRS
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE4
    Send Throuput and check Throuput    ue_id=4
    Release Ues    ue_type=sa    ue_id=4

CB010332-A-B3_ET_01_01_Cell Setup with fault due to lack of radio capability
        [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       Fault 4282 Configuration and hardware mismatch should be raised if activate FAF on cell deployed in unsupported RU
    ...    2. Test Case Steps:
    ...      1) configure actHPPosMethodOptList=UL-TDOA on NRCELL-2 (AEQE), check fault 4282 raised
    ...      2) configure actHPPosMethodOptList=disabled on NRCELL-2 (AEQE), check fault 4282 cancelled
    [Tags]    B301    owner-zhiguo.li
    FM FAULT SHOULD NOT EXIST    fault_id=${fault_list}
    OnlineParamChange    ${Activate_ULTDOA}    check_onair=${True}
    FM FAULT SHOULD NOT EXIST    fault_id=${fault_list}
    OnlineParamChange    ${Deactivate_ULTDOA}
    FM FAULT SHOULD NOT EXIST    fault_id=${fault_list}
    [Teardown]    LOCAL TEST TEARDOWN AND STOP CAPTURE LOGS

*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh

Attach One UE with 2 SRS ports
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

Attach One UE with 1 SRS port
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${N78DLUL_N77DLUL_1SRSport}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

Attach One UE with 4 SRS ports
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${N78DLUL_N77DLUL_4SRSport}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}


Send Throuput and check Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1    UE ${ue_id}: UDP UL
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput for cell    ue_id=${ue_id}

Verify Throuput for cell
    [Arguments]    ${ue_id}=1    ${ul}=90    ${pdu_id}=1
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/100>${ul}

OnlineParamChange
    [Arguments]    ${Online_Param}    ${check_onair}=${True}
    Delta Commission Parameters    ${Online_Param}
    Run Keyword If    ${check_onair}    Cells Should Be OnAir

Local Test Teardown And Stop Capture Logs
    OnlineParamChange    ${Deactivate_ULTDOA}
    Common Test Teardown And Stop Capture Logs

Set SRS Configuration
    #lmf_srs_trans_char_cfg object_id=1 num_periodic_transmissions=1 resource_type=periodic
    [Arguments]    ${id}=1    ${num_periodic}=1    ${type}=periodic
    Execute Egate Command    lmf_srs_trans_char_cfg object_id=${id} num_periodic_transmissions=${num_periodic} resource_type=${type}

trigger Positioning Request For UE
    #lmf_ue_send_pos_info_req id=1 ue=1 nrppa_transaction_id=1 req_srs_obj_id=1
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${srs_obj_id}=1
    ...    ${pass_regexp}=LMF Received Positioning Information Response
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    req_srs_obj_id=${srs_obj_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}