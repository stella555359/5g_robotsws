*** Settings ***

Documentation
...     Feature:        CB010412
...     author:         nowami.muktapuram@nokia.com 
...     maintainer:     nowami.muktapuram@nokia.com            
...     INTRODUCTION:   CB010412
...     TEST SET NAME:  CB010312_1_Compare_L2_scheduler_performance_in_low_load_with_and_without_feature_in_FR1_for_TDD
...     TESTING SPLIT:     See CB010412 testplan
...     CONTACTS:          I_MN_RAN_RD_VRF_BLR1_T09_GMS <I_MN_RAN_RD_VRF_BLR1_T09@internal.nsn.com>
...     REFERENCES:        CB010412 CFAM
...     Requirement ID:     5G_RAN_USR_RRM_20055;5G_RAN_USR_RRM_19818




Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Library             ../CB010312/resources/verify_cs2_list.py
Resource           ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot



Suite Setup         Run keywords  Test Suite Setup
...                 AND           AIC Software Build Info
...                 AND           Fetch Taf Library used in TL
...                 AND           Log to console    vDU delta commissioning
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${150}
...                 AND           Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND           log to console   loading cfg file....
...                 AND           Configure UTE ETH3 IPs
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep   120s


Suite Teardown         Run keyword and continue on failure        Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/SANSA_2Cell_72ues.cfg
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
${delta_vdu}    ${CURDIR}/config/SBTS24R2/Delta_configuration_scf_10312.xml


*** Test Cases ***
[1]CB010312_1_Compare_L2_scheduler_performance_in_low_load_with_and_without_feature_in_FR1_for_TDD

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console     ${LOG_PATH}
    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable     ${TESTCASE_LOG_PATH}
    ${CURRENT_SYSLOG_PATH}    Set Variable    ${TESTCASE_LOG_PATH}/Syslog_vDU
    set test variable       ${CURRENT_SYSLOG_PATH}
    Run Keyword And Continue on Failure   Start Syslog Monitoring
    Run Keyword And Continue on Failure   Start CPRT F1 Monitoring
    log to console    start data...
    Run Keyword And Continue on Failure   Register UES and send data    1  72
    Run Keyword And Continue on Failure   Stop and Collect CPRT F1 Monitoring
    Run Keyword And Continue on Failure   Stop and Collect Syslog Monitoring
    Sleep   5s
    ${cells}  create list   NRCELL-1
    Run Keyword and continue on failure    Start L2Ps TTI logs from vDU    ${cells}
    sleep  0.5s
    ${tti}=    Stop L2Ps TTI logs from vDU    test_scenario=New1
    Run Keyword and continue on failure    Decode TTI Trace    New1
    Run Keyword and continue on failure    Validate CS2 list after 10312 flag enabled    ${tti}[ttitrace]
    sleep    600s
    Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Sync With Measurement Period    "vDU"
    Run Keyword and continue on failure    Verify UL and DL ScheduledUes with counter_vDU    M55308C17002    M55308C18002    *MRBTS*


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

Verify UL and DL ScheduledUes with counter_vDU
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}      ${pi_file_pattern}
    ${path}   Set Variable    /home/ute/test_results/CB010312ScheduledUEs/${TEST_NAME}/gnb_pm_counters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Should Be True    ${actual_pm_values_1}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_1}<=6
    Log to console     Counter is equal to 5
    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_2}<=6


Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}

Stop traffic and deregister UEs
    Stop MultiUE Data Traffic for SA     1  72
    MultiUE Deregister should be Successful   1  72

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

