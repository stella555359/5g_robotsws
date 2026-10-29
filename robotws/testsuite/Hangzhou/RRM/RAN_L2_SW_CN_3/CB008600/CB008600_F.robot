# @Time    : 2025/7/17 10:01
# @Author  : Chen Jian
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008600_F.robot
# @Software: PyCharm
# @Doc     : robot for CB008600_F AP TCs
*** Settings ***

Documentation
...    author: Chen Jian
...    Contact: jian.1.chen@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB008600:Delay-critical GBR services

Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
...    AND    Start DCAP Containers in UTE
Test Teardown    Run Keywords    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
...    AND    Common Test Teardown    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO
Resource    CB008600_check_counter.robot
Resource    CB008600_check_emil.robot
Library    taf.config.scf    WITH NAME    scf
Variables   assert_emil_value.py

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{CUSTOM_PROFILE}    cp_5g
@{CUSTOM_PROFILE_SYSLOG}    cp_5g    condor5gSyslog
@{CUSTOM_PROFILE_L2}    L2Ps_Component    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
${qfi1_tp}    50

#For F201
&{F112_COMMON_VARIABLES}    SCFC_NAME=F_112.xml    AIRPHONE_NAME=8600_A_ap.xml    WTS_NAME=F_112_wts.cfg
...    GNBCUTYPE=SA    GNB_SWCONFIG_NAME=F_112_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{F_112_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=4    3s
...    set_pdu_param ue\=4 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=4 nwslice\=1 gw\=4    3s
...    ue_pdu_session_modify ue\=4 pdu\=1 qosflows_to_add\=4 by\=amf    3s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=dl trf_id\=1 size\=300 period_ms\=10    3s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=ul trf_id\=1 size\=300 period_ms\=10    10s
@{F_112_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    trf_data_stop ue\=4 pdu\=1 qfi\=2 dir\=dl    3s
...    trf_data_stop ue\=4 pdu\=1 qfi\=2 dir\=ul    3s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=dl trf_id\=1 size\=300 period_ms\=10    3s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=ul trf_id\=1 size\=300 period_ms\=10    10s

#For F201
&{F201_COMMON_VARIABLES}    SCFC_NAME=F_201.xml    AIRPHONE_NAME=F_201_ap.xml    WTS_NAME=F_201_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=CA_111_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{F201_EXPECTED_BWP_TYPE_LIST}
...    POWER_SAVING
...    DEDICATED
...    POWER_SAVING
...    DEDICATED
...    POWER_SAVING

#For F202
&{F202_COMMON_VARIABLES}    SCFC_NAME=F_202.xml    AIRPHONE_NAME=F_201_ap.xml    WTS_NAME=F_202_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=F_202_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{F_202_AP_CMDS_WITH_SLEEP_TIME}
...    ue_register id\=1    3s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    3s
...    set_pdu_param ue\=1 pdu\=2 default_qos_flow\=3 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=1    3s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600    3s
...    smf_param id\=1 additional_qosflows_to_activate\=5    3s
...    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=1    3s
...    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl period_ms\=10 size\=64 burst\=1 seconds\=10    10s
...    ue_pdu_session_release pdu\=2 ue\=1 by\=ue    3s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    3s

#For F305
&{F305_COMMON_VARIABLES}    SCFC_NAME=F_305.xml    AIRPHONE_NAME=F_305_ap.xml    WTS_NAME=F_305_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=F_305_swconfig_bts.txt    AP_SWCONFIG_NAME=F_305_swconfig_ap.txt
@{F_305_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    5s
...    set_pdu_param ue\=1 pdu\=1 default_qos_flow\=4 trf_type\=internal    5s
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1    5s
...    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=7 by\=amf    5s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul burst\=5 period_ms\=30 trf_id\=1    5s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul burst\=5 period_ms\=30 trf_id\=1    5s
@{F_305_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    trf_data_stop ue\=1 pdu\=1 qfi\=1    5s
...    trf_data_stop ue\=1 pdu\=1 qfi\=2    5s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    5s

*** Test Cases ***
CB008600-F_112_Group4_IWK20_Single_UE_with_DC-GBR_and_large_PDB_QoS_and_Configured_Grant
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/11 11:27
    [Tags]    F_112
    Airphone Set Common Test Variables    common_variables=${F112_COMMON_VARIABLES}    need_swconfig=True
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001

    Wait Until Keyword Succeeds    3x    15s    F112 Need Retry

CB008600-F_201_IWK4_Successful_Setup_of_DC-GBR_When_UE_is_in_Power_Saving_BWP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/10 16:54
    [Tags]    F_201
    Airphone Set Common Test Variables    common_variables=${F201_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    F201 Need Retry

CB008600-F_202_IWK5_Unsuccessful_Setup_of_DC-GBR_Bearer_due_to_UE_being_Configured_with_Small_BWP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/10 16:54
    [Tags]    F_202
    Airphone Set Common Test Variables    common_variables=${F202_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    F202 Need Retry

CB008600-F_305_UPD007_Release_of_an_only_nonDC-GBR_influences_srPayloadSize_used_when_DC-GBR_is_in_deprioritized_state
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/14 14:28
    [Tags]    F_305
    Airphone Set Common Test Variables    common_variables=${F305_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    F305 Need Retry

*** Keywords ***
Batch Execute AP CMDS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:22
    [Arguments]    ${cmd_list}    ${wait_time}=3s
    FOR    ${cmd}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Batch Execute AP CMDS With Sleep Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/30 13:27
    [Arguments]    ${cmd_list}
    FOR    ${cmd}    ${wait_time}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Check Syslog For F112
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/11 16:32
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=M5_DCAP
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${syslog_files}    find_special_file_from_folder    ${dcap_folder}    syslog.log
    Set Test Variable    ${SYSLOG_FILE}    ${syslog_files[-1]}

    ${entering_state}    get_cg_related_results    syslog_file=${SYSLOG_FILE}
    List Should Contain Value    ${entering_state}    CGACTIVATED
    List Should Not Contain Value    ${entering_state}    CGDEACTIVATED

F112 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/12 14:28
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE_SYSLOG}    is_ute_cloud=True
    Batch Execute AP CMDS With Sleep Time    ${F_112_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=50
    airphone_execute_egate_command
    ...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=ul trf_id\=2 size\=1400 period_ms\=10 packets\=2000
    Sleep    1s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${len}    check_priorityIndex    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    Should Be True    ${len} > 0

    Batch Execute AP CMDS With Sleep Time    ${F_112_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    Check Syslog For F112

Check Syslog For F201
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/12 17:23
    ${results}    get_switched_bwp_type_timestamp    syslog_file=${SYSLOG_FILE}
    ${switched_bwptype_list}    Get Dictionary Values    ${results}
    Lists Should Be Equal    ${switched_bwptype_list[-5:]}    ${F201_EXPECTED_BWP_TYPE_LIST}
    ${switched_bwptype_timestamp_list}    Get Dictionary Keys    ${results}
    [Return]    ${switched_bwptype_timestamp_list}

F201 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/20 17:42
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE_SYSLOG}    is_ute_cloud=True
    @{ue_list}    Create List    1
    Airphone Multi-UE SA Attach    ue_list=${ue_list}    pdu_id=1    trf_type=internal
    Sleep    10s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=175 seconds\=3600
    Sleep    10s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl period_ms\=100 size\=100 burst\=1
    Sleep    10s
    airphone_execute_egate_command    trf_data_stop pdu\=1 trf_id\=2 ue\=1
    Sleep    10s

    # dc-GBR modify pdu session
    ${time}    Get Current Date    time_zone=UTC
    ${1st_add_dc_gbr_time}    Convert Date    ${time}    epoch
    airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=3 by\=amf
    Sleep    10s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl period_ms\=10 size\=64 burst\=1 seconds\=10
    Sleep    10s
    ${time}    Get Current Date    time_zone=UTC
    ${1st_del_dc_gbr_time}    Convert Date    ${time}    epoch
    airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=3 by\=amf
    Sleep    10s
    # dc-GBR PduSessionResourceSetupRequest
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=2 default_qos_flow\=3 trf_type\=internal
    Sleep    10s
    ${time}    Get Current Date    time_zone=UTC
    ${2st_add_dc_gbr_time}    Convert Date    ${time}    epoch
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=1
    Sleep    10s
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl period_ms\=10 size\=64 burst\=1 seconds\=10
    Sleep    10s
    ${time}    Get Current Date    time_zone=UTC
    ${2st_del_dc_gbr_time}    Convert Date    ${time}    epoch
    airphone_execute_egate_command    ue_pdu_session_release pdu\=2 ue\=1 by\=ue
    Sleep    10s
    airphone_execute_egate_command    ue_deregister id\=1 ue_deregister_type\=switch_off
    Check Emil For F201
    ${switched_bwptype_timestamp_list}    Check Syslog For F201
    Should Be True    ${1st_del_dc_gbr_time} > ${switched_bwptype_timestamp_list[-4]} > ${1st_add_dc_gbr_time}
    Should Be True    ${2st_add_dc_gbr_time} > ${switched_bwptype_timestamp_list[-3]} > ${1st_del_dc_gbr_time}
    Should Be True    ${2st_del_dc_gbr_time} > ${switched_bwptype_timestamp_list[-2]} > ${2st_add_dc_gbr_time}
    Should Be True    ${switched_bwptype_timestamp_list[-1]} > ${2st_del_dc_gbr_time}

F202 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/31 11:08
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Batch Execute AP CMDS With Sleep Time    ${F_202_AP_CMDS_WITH_SLEEP_TIME}
    Check Emil For F202
    Wait Until Next 5 Min    extra_sleep_time=60
    Check Counters For F202

F305 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/16 16:29
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Batch Execute AP CMDS With Sleep Time    ${F_305_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=7 by\=amf

    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=51
    Sleep    2s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${totalScheduledBytes}    get_totalScheduledBytes_with_target_ul_priorityIndex    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    @{except_result}    Create List    ${1000}
    Should Be True    ${totalScheduledBytes} > ${except_result}

    Batch Execute AP CMDS With Sleep Time    ${F_305_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    Check Emil For F305

Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}

Verify DL and UL traffic is normal From AP
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/11 17:51
    ...    unit for expect_tput: Mbps
    [Arguments]    ${ue_id}   ${pdu_id}    ${qfi_id}    ${expect_tput}
    ${sa_dl_tput}=    Airphone SA Get Throughput    ue_id=${ue_id}    direction=DL    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${sa_ul_tput}=    Airphone SA Get Throughput    ue_id=${ue_id}    direction=UL    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${dl_assert_status}=    Evaluate    ${expect_tput}*1000*0.95<int(${sa_dl_tput})
    ${ul_assert_status}=    Evaluate    ${expect_tput}*1000*0.95<int(${sa_ul_tput})
    Should Be True    ${dl_assert_status}
    Should Be True    ${ul_assert_status}

Airphone Multi-UE SA Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${pdu_id}=1    ${trf_type}=internal    ${sleep_time}=3s
    FOR    ${ue_id}    IN    @{ue_list}
        Airphone SA Attach    ue_id=${ue_id}
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=${pdu_id} ue\=${ue_id}
        Sleep    ${sleep_time}
    END

Airphone UE SA Attach And Traffic With Period_ms
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/27 17:05
    [Arguments]    ${ue_id}    ${period_ms}    ${size}    ${burst}    ${qfi}=1    ${default_qos_flow}=False
    ...    ${sleep_time}=1s
    Run Keyword And Ignore Error    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    Sleep    ${sleep_time}
    airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=1 trf_type\=internal
    Sleep    ${sleep_time}
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=${ue_id}
    Sleep    ${sleep_time}
    IF    ${default_qos_flow} != False
        airphone_execute_egate_command
        ...    ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=${default_qos_flow} by\=amf
        Sleep    ${sleep_time}
    END
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=${qfi} dir\=dl period_ms\=${period_ms} size\=${size} burst\=${burst}
    Sleep    ${sleep_time}
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=${qfi} dir\=ul period_ms\=${period_ms} size\=${size} burst\=${burst}
    Sleep    ${sleep_time}

Airphone UE SA Attach With Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 10:54
    [Arguments]    ${ue_id}    ${registration_type}=False    ${default_qos_flow}=False
    ...    ${pdu_id}=1    ${nwslice}=1    ${trf_type}=internal    ${sleep_time}=3s
    IF    '${registration_type}' == 'EmergencyRegistration'
        airphone_execute_egate_command    ue_register id\=${ue_id} registration_type\=EmergencyRegistration
    ELSE
        Airphone SA Attach    ue_id=${ue_id}
    END
    Sleep    ${sleep_time}

    IF    ${default_qos_flow} != False
        airphone_execute_egate_command
        ...    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} default_qos_flow\=${default_qos_flow} trf_type\=${trf_type}
    ELSE
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
    END
    Sleep    ${sleep_time}

    Airphone Pdu Session Setup    ${ue_id}    ${pdu_id}    ${nwslice}    ${ue_id}
    Sleep    ${sleep_time}
    Airphone SA Detach    ${ue_id}
    Sleep    ${sleep_time}

Airphone Multi-UE SA Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${pdu_id}=1    ${qfi_id}=1
    FOR    ${ue_id}    IN    @{ue_list}
        airphone_execute_egate_command    trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id}
        airphone_execute_egate_command    ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    END

Get UE Rnti List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:54
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UEs   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UEs/egate_console.log.001   crnti: (\\d+)
    [Return]    ${rnti_list}

Airphone Start DL&UL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 16:00
    [Arguments]    ${ue_id}    ${dl_mbps}    ${ul_mbps}    ${pdu_id}=1    ${qfi_id}=1    ${trf_id}=1
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir\=ul mbps\=${ul_mbps} trf_id\=${trf_id}
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir\=dl mbps\=${dl_mbps} trf_id\=${trf_id}
    Sleep   3s

Airphone Multi-UE SA Traffic Summary
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${direction}=DL    ${pdu_id}=1    ${qfi_id}=1
    ${sum_tp}    Set Variable    0
    FOR    ${ue_id}    IN    @{ue_list}
        ${dl_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=${direction}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
        ${sum_tp}    Evaluate    ${sum_tp} + ${dl_tp}
    END
    [Return]    ${sum_tp}

Airphone Verify UE DL&UL TP Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/20 13:21
    [Arguments]    ${ue_id}    ${except_dl_tp}    ${except_ul_tp}    ${pdu_id}=1    ${qfi_id}=1
    ${dl_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=dl    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${ul_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=ul    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    # convert kbps to Mbps
    ${dl_tp}    Evaluate    ${dl_tp}/1000
    ${ul_tp}    Evaluate    ${ul_tp}/1000
    ${dl_result}=    Is Values Close    ${dl_tp}    ${except_dl_tp}    tolerance_percent=10
    Should Be True    ${dl_result}
    ${ul_result}=    Is Values Close    ${ul_tp}    ${except_ul_tp}    tolerance_percent=10
    Should Be True    ${ul_result}
    Log To Console    ue_id(${ue_id}) dl_tp:${dl_tp}mbps ul_tp:${ul_tp}mbps
    [Return]    ${dl_tp}    ${ul_tp}

Airphone Set Common Test Variables
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 16:48
    [Arguments]    ${common_variables}    ${need_swconfig}=False
    Set Test Variable    ${SCFC_NAME}            ${common_variables["SCFC_NAME"]}
    Set Test Variable    ${AIRPHONE_NAME}        ${common_variables["AIRPHONE_NAME"]}
    Set Test Variable    ${WTS_NAME}             ${common_variables["WTS_NAME"]}
    Set Test Variable    ${GNBCUTYPE}            ${common_variables["GNBCUTYPE"]}
    IF    ${need_swconfig}
        Set Test Variable    ${GNB_SWCONFIG_NAME}        ${common_variables["GNB_SWCONFIG_NAME"]}
        Set Test Variable    ${AP_SWCONFIG_NAME}        ${common_variables["AP_SWCONFIG_NAME"]}
    END
