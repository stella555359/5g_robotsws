*** Settings ***
Documentation     author: ruiyu.han
...               contact: ruiyu,han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB008278

Library           OperatingSystem
Library           Collections
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009355/Resource/resource.py
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009355/Resource/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Library           taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot

*** Variables ***
${vendor}   HBTE
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuation_port_numbers[1]}
${att_api_port}              ${tl.attenuator[0].port}


*** Keywords ***
Case Setup for CB009355
    [Arguments]    ${x2_enb_mrbtsId}=default   ${gnbmode}=SA
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    Wait Until Keyword Succeeds    5min    20s      COAM WEBUI Login
    COAM Login
    Upload Swconfig File    swconfig_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/swconfig.txt
    CI_interface.Common Suite Setup
    wait until keyword succeeds    15min    1min   Check onair and x2 meantime    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}

Case Teardown for CB009355
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM LOGIN
    run keyword and ignore error    COAM LOGOUT
    Run Keyword If    "${log_status}" == "FAIL"    run keyword and ignore error    Save Snapshot logs On COAM    IP_WEBUI=${WEBUI_ADDR}
#    Run Keyword If    "${log_status}" == "FAIL"    run keyword and ignore error    Screenshot for case fail
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_0
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_1
    CI_interface.Common Case Teardown

Set L3 CALL param CB009355
    [Arguments]    ${runame}    ${framestruct}
    set test variable    ${ue_index}    ${L3CALL_Set['${runame}']['${framestruct}']['ue_index']}
    set test variable   ${dl_tp_ratio}    ${L3CALL_Set['${runame}']['${framestruct}']['dl_tp_ratio']}
    set test variable   ${ul_tp_ratio}    ${L3CALL_Set['${runame}']['${framestruct}']['ul_tp_ratio']}
    set test variable   ${peak_tp_dl}    ${L3CALL_Set['${runame}']['${framestruct}']['peak_tp_dl']}
    set test variable   ${peak_tp_ul}    ${L3CALL_Set['${runame}']['${framestruct}']['peak_tp_ul']}
    set test variable   ${duration}    ${L3CALL_Set['${runame}']['${framestruct}']['duration']}

PEAK L3 CALL Process CB009355
    [Arguments]    ${runame}    ${framestruct}    ${L3CALL_CELLID_list}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block other cells except L3CALL   l3call_cell_list=${L3CALL_CELLID_list}
    ${dl_expect_custom}    evaluate    ${peak_tp_dl}*${dl_tp_ratio}
    ${ul_expect_custom}    evaluate    ${peak_tp_ul}*${ul_tp_ratio}
    ${nrdimvalue_exist}    get variable value    ${nrdim_Value['${runame}']['${framestruct}']}
    ${dl_expect}    ${ul_expect}    run keyword if    ${nrdimvalue_exist}!=${None}    Get Expected Throughput by NRDIM
    ...    cellid=${L3CALL_CELLID_LIST[0]}     Nrdim_param_dic=${nrdim_Value['${runame}']['${framestruct}']}
    ...    ELSE    set variable   ${dl_expect_custom}  ${ul_expect_custom}
    ${Send_Tput_DL}   set variable   ${peak_tp_dl}
    ${send_tp_ul}     evaluate    ${peak_tp_ul}*5
    ${Send_Tput_UL}   set variable   ${send_tp_ul}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    wait until keyword succeeds   3x    20s  Call Setup and check tput   method=PEAK
    ...   tput=${Send_Tput_DL}   tput_expect=${dl_expect}
    ...   peak_ul=${Send_Tput_UL}   ul_expect=${ul_expect}
    ...   duration=${duration}
    [Teardown]    UnBlock other cells except L3CALL     l3call_cell_list=${L3CALL_CELLID_list}

SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
    [Arguments]    ${reset_flag}    ${framestruct}    ${L3CALL_CELLID_list}     ${runame}=AZHL    ${reset_times}=2
    Return From Keyword If   ${reset_flag.count('FALSE')} >0
    Log To Console   BTS Site Reset Start ...
    FOR   ${index}    IN RANGE    ${reset_times}
       COAM WEBUI Whether Close Start Up View Window
       selenium_coam.reset_site
       Sleep   5m
       Wait Until Keyword Succeeds   20m   1m   Check onair and x2 meantime   runame=${runame}
       Log To Console   BTS Site Reset Number: ${index + 1}
    END
    Log To Console   BTS Site Reset Finish...
    Start Capture Wireshark at gNB    nglogname=axis_1
    Wait Until Keyword Succeeds   3x   10s   PEAK L3 CALL Process CB009355
    ...    runame=${runame}    framestruct=${framestruct}    L3CALL_CELLID_list=${L3CALL_CELLID_list}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_1

Modify disableSchedAssistRfCooling to false in Venfor file
     [Arguments]    ${runame}    ${framestruct}    ${x2_enb_mrbtsId}=default   ${gnbmode}=SA
     log to console    Modify disableSchedAssistRfCooling to false in Venfor file
     ${command}   Catenate   SEPARATOR=
    ...   cd ${OUTPUT_DIR};
    ...   sudo sed -i 's|<p name="disableSchedAssistRfCooling">.*</p>
    ...   |<p name="disableSchedAssistRfCooling">true</p>
    ...   |g' vendor_lte.xml
     coam.download_vendor_file    target_file_name=${OUTPUT_DIR}/vendor_lte.xml    connection=COAM
     sleep    3s
     RUN    ls ${OUTPUT_DIR}
     RUN    ${command}
     ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_lte.xml
     Run keyword if   '${result}'=='Validation failed!'
     ...   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_lte.xml
     sleep   5s
     COAM WEBUI Whether Close Start Up View Window
     selenium_coam.load_commissioning_file_and_check_load_status
     ...   file_path=${OUTPUT_DIR}/${runame}_${framestruct}.xml   timeout=${120}
    selenium_coam.validate_plan
    ${status}    Run Keyword And Return Status    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
    Run Keyword If    ${status}==${False}    Fail    /n***Activate plan failed!***/n
    run keyword and ignore error
    ...    Wait Until Keyword Succeeds   90s   5s   Validate IP Reachability from Test PC    ip_addr=${asik_addr}  exp_status=${False}
    check mplane and onair meantime during 15min    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}
