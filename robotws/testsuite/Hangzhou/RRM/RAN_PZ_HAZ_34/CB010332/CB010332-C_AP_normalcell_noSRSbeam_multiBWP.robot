*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/10cells_ecpri_100M/2_AEQE_4_AWHQN
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    True

${SRS_config_in_RRCreconfig_FILTER}
...    (((nr-rrc.criticalExtensions == 0) ) && (nr-rrc.srs_Config == 1)) && (nr-rrc.c1 == 0)


${SmallBWP_80M_PowersavingBWP_UE}    SEPARATOR=
...    E1A00000074E7A031E00038520001E080080C04983200021E16003120D00980C0301C032A36146B04050D012CB28988
...    8007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D012CB289888007AD8202020E1DE3
...    8720C38002064F1F570004F001C0013C002A3626EB04050D012CB289888007AD8202020E1DE38720C38002064F1F570
...    004F001C0013C002A36276B04050D012CB289888007AD8202020E1DE38720C38002064F1F55000005000000208389A0
...    0000020E2600000000101346C0000B0100880441EC3E000C000A070500703009801C001A0F8000000000000394B4000
...    4000025965400D29AA1E000E001600000008010023162600020406080A0C0E10162022242632424A4C4E5094



*** Test Cases ***
CB010332-C-IWK3_ET_01_02_pSRS positioning coexistence with multi BWP with pSRS config
    [Documentation]
    [Tags]    TC01    owner-lishuo.geng
    log to console    step: attach UE to cell-4 with periodic SRS config for small bwp and powersaving bwp
    delta commission parameters and wait cells onair    ${CSRS_Less_Then_PowersavingBWP}
    UE ICS And Wait BWP Switch To PowerSaving BWP    ue_id=1    cell_id=4    ue_nr_capabilities=${SmallBWP_80M_PowersavingBWP_UE}
    Set SRS Configuration    id=1    num_periodic=0    type=periodic
    start to capture wireshark log    tag=1_for_smallbwp_powersavingbwp
    trigger Positioning Request For UE    ue_id=1
    log to console    step:check SRS resource allocation for UE-1 on cell4
    ${srs_info}    create list
    ...                           SRS-Resource/resourceType=[RE]periodic .*,[RE]periodic .*
    ...                           SRS-Resource/c-SRS=0,0
    download and check wireshark fields    tag=1_for_smallbwp_powersavingbwp
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE1
    Send Throuput and check Throuput    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
    delta commission parameters and wait cells onair    ${CSRS_More_Then_PowersavingBWP_Less_Then_SmallBWP}
    log to console    step: attach UE to cell-4 with periodic SRS config for small bwp but not for powersaving bwp
    UE ICS And Wait BWP Switch To Samll BWP    ue_id=1    cell_id=4    ue_nr_capabilities=${SmallBWP_80M_PowersavingBWP_UE}
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1    UE 1: UDP UL
    sleep    3s
    start to capture wireshark log    tag=2_for_smallbwp_powersavingbwp
    trigger Positioning Request For UE    ue_id=1
    Execute Egate Command    trf_data_stop trf_id=1 ue=81    fail_regexp=Bwp switch received from bwpId 1 to 2
    log to console    step:check SRS resource allocation for UE-1 on cell4
    ${srs_info}    create list
    ...                           SRS-Resource/resourceType=[RE]periodic .*    #,[RE]aperiodic .*
    ...                           SRS-Resource/c-SRS=51    #,1
    download and check wireshark fields    tag=2_for_smallbwp_powersavingbwp
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE1
    Send Throuput and check Throuput    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
    log to console    step: attach UE to cell-4 with aperiodic SRS config for small bwp and powersaving bwp
    delta commission parameters and wait cells onair    ${CSRS_More_Then_SmallBWP}
    start to capture wireshark log    tag=3_for_smallbwp_powersavingbwp
    UE ICS And Wait BWP Switch To PowerSaving BWP    ue_id=1    cell_id=4    ue_nr_capabilities=${SmallBWP_80M_PowersavingBWP_UE}
    trigger Positioning Request For UE and Expect Failure    ue_id=1
    log to console    step:check SRS resource allocation for UE-1 on cell4
    ${srs_info}    create list
    ...                           SRS-Resource/resourceType=[RE]aperiodic .*,[RE]aperiodic .*
    ...                           SRS-Resource/c-SRS=1,1
    download and check wireshark fields    tag=3_for_smallbwp_powersavingbwp
    ...                                    filter=${SRS_config_in_RRCreconfig_FILTER}
    ...                                    check_fields=${srs_info}
    log to console    step: send 10M traffic for UE1
    Send Throuput and check Throuput    ue_id=1
    Release Ues    ue_type=sa    ue_id=1
*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh

UE ICS And Wait BWP Switch To PowerSaving BWP
    [Arguments]    ${ue_id}    ${cell_id}    ${ue_nr_capabilities}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    UE now in NG RM Reg
 	Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    Bwp switch received from bwpId 1 to 2
    Should Contain    ${ret1}    Initial Context Setup Successful
    Should Contain    ${ret1}    locationAndBandwidth 16499
    Should Contain    ${ret1}    locationAndBandwidth 31624

UE ICS And Wait BWP Switch To Samll BWP
    [Arguments]    ${ue_id}    ${cell_id}    ${ue_nr_capabilities}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    ${cell_id}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    UE now in NG RM Reg
     Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    QoS Routing Table
    Should Contain    ${ret1}    Initial Context Setup Successful
    Should Contain    ${ret1}    locationAndBandwidth 16499
    Should Contain    ${ret1}    locationAndBandwidth 31624

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

trigger Positioning Request For UE and Expect Failure
    #lmf_ue_send_pos_info_req id=1 ue=1 nrppa_transaction_id=1 req_srs_obj_id=1
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${srs_obj_id}=1
    ...    ${pass_regexp}=LMF Received Positioning Information Failure with NRPPATransactionId
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    req_srs_obj_id=${srs_obj_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}