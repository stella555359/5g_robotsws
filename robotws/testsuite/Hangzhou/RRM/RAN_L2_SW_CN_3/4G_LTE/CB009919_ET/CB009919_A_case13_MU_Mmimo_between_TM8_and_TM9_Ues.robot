# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     run keywords  Common Test Teardown  AND  enable_ue1_and_ue2_tm9_mode
# Force Tags    CB009919    CRT
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_mmimo.robot
# 
# *** Variables ***
# ${inactivityTimer}          text|300|//*[@name\="inactivityTimer"]
# ${actTmSwitch}              text|false|//*[@name\="actTmSwitch"]
# ${tddFrameConf}             text|1|//*[@name\="tddFrameConf"]
# ${tddSpecSubfConf}          text|7|//*[@name\="tddSpecSubfConf"]
# ${actDlMuMimo}              text|true|//*[@name\="actDlMuMimo"]
# ${actUlMuMimo}              text|true|//*[@name\="actUlMuMimo"]
# ${actDownSampling}          text|false|//*[@name\="actDownSampling"]
# ${dlMaxNumLayerPerMuRBG}    text|16|//*[@name\="dlMaxNumLayerPerMuRBG"]
# ${ulMaxNumLayerPerMuPRB}    text|8|//*[@name\="ulMaxNumLayerPerMuPRB"]
# ${actDlNewtxSchedBasedOnBuffer}    text|false|//*[@name\="actDlNewtxSchedBasedOnBuffer"]
# ${actDlRetxSchedBasedOnPdcchCap}    text|false|//*[@name\="actDlRetxSchedBasedOnPdcchCap"]
# ${srsActivation}            text|true|//*[@name\="srsActivation"]
# ${actBfFallback}            text|false|//*[@name\="actBfFallback"]
# ${mMimoAntArrayMode}        text|Full 64TRX Array (4x8x2)|//*[@name\="mMimoAntArrayMode"]
# @{TM_mode}    text|Closed Loop MIMO (8x2)|//*[@name\='dlMimoMode']    text|true|//*[@name\='actFastMimoSwitch']    text|false|//*[@name\='actCMAS']
# ${prodCodePlanned}          text|475124B.M01|//*[contains(@distName, 'RMOD-1')]/*[@name='prodCodePlanned']
# ${actUlLnkAdp}              text|eUlLa|//*[@name\="actUlLnkAdp"]
# ${actUlpcMethod}            text|PuschCLPucchCL|//*[@name\="actUlpcMethod"]
# ${ulpcLowqualSch}           text|21|//*[@name\="ulpcLowqualSch"]
# ${ulpcUpqualSch}            text|28|//*[@name\="ulpcUpqualSch"]
# ${chBw}                     text|10 MHz|//*[@name\="chBw"]
# @{2SRSUpPts_1SRSUL}    text|sc0|//*[@name\="srsSubfrConf"]    text|false|//*[@name\="actUpPtsBlanking"]    text|true|//*[@name\="srsOnTwoSymUpPts"]
# @{modify_list}    ${inactivityTimer}    ${actTmSwitch}    ${tddFrameConf}    ${tddSpecSubfConf}    ${actDlMuMimo}    ${actUlMuMimo}
# ...               ${srsActivation}    ${actBfFallback}    ${mMimoAntArrayMode}    @{TM_mode}    ${actDownSampling}    ${ulMaxNumLayerPerMuPRB}
# ...               ${dlMaxNumLayerPerMuRBG}    ${prodCodePlanned}    ${actUlLnkAdp}    ${actUlpcMethod}    ${ulpcLowqualSch}    ${ulpcUpqualSch} 
# ...               @{2SRSUpPts_1SRSUL}    ${chBw}    ${actDlNewtxSchedBasedOnBuffer}    ${actDlRetxSchedBasedOnPdcchCap} 
# ${target_ip}    10.69.67.202
# ${scfc_configuration1}      ${CURDIR}/../../resources/KISS/configuration_file/SCFC_ABIO_1cell_TM8_for_bts2317_SBTS00.xml
# 
# *** Test Cases ***
# CB009919_A_case13_MU_Mmimo_between_TM8_and_TM9_Ues
#     [Tags]    QC_282523
#     Step1:Set parameter and wait for onair
#     Step2:UEs attach to cell and traffic
#     Step8:PM counter check
#     Step9:Detach all UE
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start enb syslog'1-1'
#     Establish cell with bandwidth 20M and frameconfigure 1 7
#     Stop and collect enb syslog
#     Start enb syslog'1-2'
#     Run Keyword And Ignore Error    Reboot ENB And Wait Disconnection
#     Wait ENB Connection
#     ${bts_onair}    bts_should_be_onair    timeout=1500
#     ${cell_onair}   cell_should_be_onair    timeout=600
#     Should Be True    ${bts_onair}
#     Should Be True    ${cell_onair}
#     Stop and collect enb syslog
#     Start enb syslog'1-3'
#     ${status}=    cpe_disable_tm9_and_reboot_waiting_for_disconnect    ${ue1_id}
#     should_be_true    ${status}
#     ${status}=    cpe_disable_tm9_and_reboot_waiting_for_disconnect    ${ue2_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue3_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue4_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue5_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue6_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue7_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue8_id}
#     should_be_true    ${status}
#     Stop and collect enb syslog
#     Wait Throughput Timer    60
# 
# Establish cell with bandwidth 20M and frameconfigure 1 7
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIR}/SCFC_1.xml
#     copy_file          ${scfc_configuration1}     ${scfc_path}
#     Add csiRsConfigInfo extend parameter    ${scfc_path}
#     Add parameter in all cell_tdd level             ${scfc_path}                       <p name="activatedMimoTM">TM9</p>
#     Add parameter in all cell_tdd level             ${scfc_path}                       <p name="csiRepSubmode">submode1</p>
#     initialize_scfc_via_env_variable      ${scfc_path}    ${scfc_path}
#     modify_scfc_and_full_commission    ${scfc_path}    ${modify_list}
# 
# Step2:UEs attach to cell and traffic
#     Start enb syslog'2'
#     cpe_ue_attach    ${ue1_id}
#     cpe_ue_attach    ${ue2_id}
#     cpe_ue_attach    ${ue3_id}
#     cpe_ue_attach    ${ue4_id}
#     Wait Throughput Timer    10
#     override_cqi     ${ue1_id}      14
#     override_cqi     ${ue2_id}      14
#     override_cqi     ${ue3_id}      14
#     override_cqi     ${ue4_id}      14
#     cpe_send_dl_throughput    host_ip=${ue1_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue2_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue3_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue4_id}    throughput_size=100M
#     cpe_send_ul_throughput    host_ip=${ue1_id}    send_target_ip=${target_ip}    throughput_size=20M
#     cpe_send_ul_throughput    host_ip=${ue2_id}    send_target_ip=${target_ip}    throughput_size=20M
#     cpe_send_ul_throughput    host_ip=${ue3_id}    send_target_ip=${target_ip}    throughput_size=20M
#     cpe_send_ul_throughput    host_ip=${ue4_id}    send_target_ip=${target_ip}    throughput_size=20M
#     Wait Throughput Timer    20
#     # start_capture_ttitrace'2'
#     Wait Throughput Timer    5
#     # Save_and_Decode_ttitrace_'2'
#     Stop and collect enb syslog
# 
# Step8:PM counter check
#     Start enb syslog'8'
#     ${remian_time}    get_counter_file_remaining_time
#     ${remian_time}    evaluate    ${remian_time}+900
#     Wait Throughput Timer  ${remian_time}
#     # start_capture_ttitrace'8'
#     Wait Throughput Timer    5
#     # Save_and_Decode_ttitrace_'8'
#     ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}    source_path=/tmp/
#     Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}  source_path=/tmp/  suffix=gz
#     Stop and collect enb syslog
#     ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIR}/*.xz
#     ...    ELSE    remove_file    ${TEST_LOG_DIR}/*.gz
#     ${counter_file}    list files in directory    ${TEST_LOG_DIR}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     ${Count_M8012C26}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C26    1
#     ${Count_M8012C23}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C23    1
#     set_test_variable    ${Count_M8012C26}
#     set_test_variable    ${Count_M8012C23}
#     log    4UE\_OTA\_total\_pm\_counter\_dl\_CA\_throughput\_open\_ulmumimo ${Count_M8012C26}    console=${True}
#     log    4UE\_OTA\_total\_pm\_counter\_ul\_CA\_throughput\_open\_ulmumimo ${Count_M8012C23}    console=${True}
#     Should Be True    ${Count_M8012C23}>10000
#     Should Be True    ${Count_M8012C26}>90000
# 
# Step9:Detach all UE
#     Start enb syslog'9'
#     cpe_ue_detach    host_ip=${ue1_id}
#     cpe_ue_detach    host_ip=${ue2_id}
#     cpe_ue_detach    host_ip=${ue3_id}
#     cpe_ue_detach    host_ip=${ue4_id}
#     Stop and collect enb syslog
# 
# enable_ue1_and_ue2_tm9_mode
#     ${status}=    cpe_ensable_tm9_and_reboot_waiting_for_disconnect     ${ue1_id}
#     should_be_true     ${status}
#     ${status}=    cpe_ensable_tm9_and_reboot_waiting_for_disconnect     ${ue2_id}
#     should_be_true     ${status}
# 
# Wait Throughput Timer
#     [Arguments]    ${time}
#     Sleep    ${time}