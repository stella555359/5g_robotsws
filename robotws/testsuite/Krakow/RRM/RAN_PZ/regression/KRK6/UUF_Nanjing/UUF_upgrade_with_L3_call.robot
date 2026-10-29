*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Mikołaj Borkowski
...   contact: mikolaj.borkowski@nokia.com
...   maintainer: mikolaj.borkowski@nokia.com


Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            ute_ue    WITH NAME    ue
Library            DateTime  WITH NAME    dt

Test Timeout       100h


*** Variables ***
${ITERATION_SITE_RESET}                    30
${ITERATION_SW_UPGRADE_ROLLBACK}           10

${SOURCE_SW}                               SBTS25R2_ENB_0000_000437_000000
${TARGET_SW}                               SBTS00_ENB_9999_250519_000002

${SITE_RESET_TEST_QC_ID}                   None
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          None

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383
@{CUSTOM_ALLOWED_ALARMS}                   62003    7114    7509    4479
${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${True}
${QC_REPORT}                               ${False}
${STOP_TEST_AFTER_FAIL}                    ${False}
${RESTORE_TO_TARGET_SW}                    ${False}

@{CUSTOMERS}                               Generic
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_RRM

&{GNB}                                     node_alias=9SK154
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
@{NODES}                                   ${GNB}


*** Test Cases ***
SW_upgrade_rollback_with_OAM_KPI
    ue.Require UE    S22    REAL_UE
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=UE Attach and Start traffic
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    [Teardown]    Test Teardown with UE

E2E_TL_Activation_Reset_Test
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

*** Keywords ***

UE Attach and Start traffic
    [Arguments]    ${cells}
	Log Action to Console    Available cells: ${cells}
    Start And Verify DL and UL Data Transmission  ue_type=S22    max_allowed_data_loss=10%    data_transfer_time=60s
    ...    apn=5gsakrk2
    ...    dl_throughput=200 Mbits/sec    dl_throughput_for_verify=200 Mbits/sec
    ...    ul_throughput=100 Mbits/sec    ul_throughput_for_verify=100 Mbits/sec

Test Teardown with UE
    [Documentation]    Teardown with UE detach
    Log Action to Console    End test
    Run Keyword and Ignore Error    ue.Detach Ue    S22

Start And Verify DL and UL Data Transmission
    [Arguments]    ${dl_throughput}   ${ul_throughput}   ${data_transfer_time}    ${apn}    ${ue_type}
    ...    ${dl_throughput_for_verify}  ${ul_throughput_for_verify}   ${max_allowed_data_loss}
    ...    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Start, await, stop and verify average throughput for DL
    ...                :param dl_throughput: Value of the DL throughput
    ...                :param data_transfer_time: Time of a data transfer
    ...                :param ue_type: Type of the UE
    ...                :param max_allowed_data_loss: Maximal allowed data loss
    ...                :param dl_throughput_for_verify: Minimal value of the DL throughput to pass a test case
    ...                :param dl_dt_name: Iperf param to start DL tput
    Attach Ue
    Log Action To Console    Start DL data transmission
    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_type}    apn=${apn}
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${dl_throughput}
    ...                       packet=1350B    buffer_server=4M
    ...                       iperf_len=1320B
    Sleep    2s
    Log Action To Console    Start UL data transmission
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_type}    apn=${apn}
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${ul_throughput}
    ...                       packet=1350B    buffer_client=4M
    Sleep    2s
    Log Action To Console    Await DL data transmission finish
    ue.Await Data Transfer Finish    ${dl_dt_name}
    Log Action To Console    Await UL data transmission finish
    ue.Await Data Transfer Finish    ${ul_dt_name}
    Log Action To Console    Stop DL data transmission
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    Log Action To Console    Stop UL data transmission
    ue.Stop Data Transfer    dt_name=${ul_dt_name}
     Log Action To Console    Verify DL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}
    ...                                                deviation=${max_allowed_data_loss}
    ...                                                tput=${dl_throughput_for_verify}
     Log Action To Console    Verify UL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}
    ...                                                deviation=${max_allowed_data_loss}
    ...                                                tput=${ul_throughput_for_verify}
    ue.Detach Ue    ${ue_type}

Attach Ue
    [Documentation]    Performs 5G attach to CELL 60 of gNB.
    Log Action To Console   Attach UE to 5G cell 60
    ue.Attach Ue    S22
    Sleep    3s
    ${CURRENT_NR_CELL_ID}=    Get Ue Info    S22   CELL_ID
    Run Keyword If    1282466 != ${CURRENT_NR_CELL_ID}    Fail    msg=Ue did not attach to expected cell.
    Log Action To Console     UE attached to NRCELL ID ${CURRENT_NR_CELL_ID}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${True}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date    exclude_millis=yes
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console   [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}
