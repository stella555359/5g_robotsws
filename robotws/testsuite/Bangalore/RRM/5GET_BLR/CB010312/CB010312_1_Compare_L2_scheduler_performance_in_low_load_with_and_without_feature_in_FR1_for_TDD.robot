*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB010312/CB010312_L2_scheduler_performance_in_low_load_FR1_TDD.yml
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...
...             author:            Nowami Muktapuram, nowami.muktapuram@nokia.com
...             maintainer:        Nowami Muktapuram, nowami.muktapuram@nokia.com
...
...             INTRODUCTION:      USCB010312-A#B2: Verification of L2 scheduler performance in low load in FR1
...             TEST SET NAME:     CB010312_1_Compare_L2_scheduler_performance_in_low_load_ with_and_
...                                without_feature_in_FR1_for_TDD.
...                                This scenario is to verify that the CS2 list reduction in low load (i.e. when max.
...                                proposed CS1 size from overload control is not reduced) does degrade the system
...                                performance. The purpose for the DL performance verification too is with CB010312,
...                                a minor change is done in DL overload control in the scheduling fairness mechanism
...                                i.e., DL CS2 list reduction functionality is modified when scheduler is not in high load.
...             TESTING SPLIT:     See CB0010312 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB0010312 CFAM
...             Requirement ID:     5G_RAN_USR_RRM_19818


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         resources/CB010312_keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ./resources/verify_cs2_list.py
Resource         ../resources/robot/common_log_collection.robot


Suite Setup         Run keywords    Prepare TL with all config files     
...                  AND     Suite setup from scratch
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   72

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TDD_72_ues_basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${epc_log_path}    /tmp/
${PM_dir1}
${PM_dir2}
${counter_value_cell1}
${SCFC}=                   Bangalore/RRM/ET/CB010312/CB010312_L2_scheduler_performance_in_low_load_FR1_TDD.xml
${AP_XML}=                       Bangalore/RRM/ET/CNI85011/CNI85011_5G_B2_3_iphy.xml



*** Test Cases ***
[1]CB010312_1_Compare_L2_scheduler_performance_in_low_load_with_and_without_feature_in_FR1_for_TDD
    [Documentation]
    Start Log     btslog    cprt
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UES and send data    1  72
    Stop Log    btslog     cprt     test_scenario=10312_enabled
    Capture TTI Traces and Convert to CSV Mode    ${LOG_PATH}    10312_enabled
    Validate CS2 list after 10312 flag enabled    ${LOG_PATH}/ttitrace_streaming/10312_enabled
    Verify UL and DL ScheduledUes with counter

*** Keywords ***
Register UES and send data
   [Arguments]   ${Start_ue}    ${END_ue}
   FOR    ${UE}   IN RANGE   ${Start_ue}   ${END_ue}+${1}
        UE Register should be Successful    ue_id=${UE}    gw_id=${UE}
        Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     dl_rate=2      pdu_id=1     trf_id=1
        Trigger UL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=2      pdu_id=1     trf_id=1
   END

Validate CS2 list after 10312 flag enabled
    [Arguments]   ${csv_file_path}
    ${Check}    Verify cs2list_DL_10312_on     ${csv_file_path}/output_dl_formated.csv
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   cslist is not matching
    ${Check1}   Verify cs2list_UL_10312_on     ${csv_file_path}/output_ul_formated.csv
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   cslist is not matching

Verify cs2list_DL_10312_on
    [Arguments]   ${csv_file_path}
    ${Result}    verify_cs2_list.check_cs2_list_DL_10312_on    ${csv_file_path}
    [Return]   ${Result}

Verify cs2list_UL_10312_on
    [Arguments]   ${csv_file_path}
    ${Result}    verify_cs2_list.check_cs2_list_UL_10312_on    ${csv_file_path}
    [Return]   ${Result}

Verify UL and DL ScheduledUes with counter
    sleep   300
    Verify fdm max dl Counters   8
    Verify fdm max ul Counters   6

Verify fdm max dl Counters
     [Arguments]    ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl counter
     log to console     Verify the DL counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     Should Be True      ${counter_dl}==${dl_expected}

Verify fdm max ul Counters
     [Arguments]    ${ul_expected}
     [Documentation]    This keyword is to verify the FDM ul counter
     log to console     Verify the UL counter
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_ul}==${ul_expected}

Get Counter Value With Admin
     [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Perform Delta Commision to disable 10312 flag
    log to console   Disabling 10312 feature...
    Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS_CB010312.json
    gnb.Perform gNB reboot
    log to console   reboot done.
    sleep    120
    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Stop traffic and deregister UEs
    Stop MultiUE Data Traffic for SA     1  72
    MultiUE Deregister should be Successful   1  72
