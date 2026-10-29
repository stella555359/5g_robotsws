*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Resource          ../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${SNAPSHOT_FLAG}    pass:False,fail:True
${SOS_REPORT_FLAG}    pass:False,fail:True
${SKIP_ON_AIR}    ${True}
${AP_BIP_FLAG}    ${False}
${GNB_BIP_FLAG}   ${False}
${AUTO_ANALYSIS_FLAG}    ${False}
${EMIL_FLAG}  ${True}
${BTSLOG_FLAG}  ${True}
${AP_UDPLOG_FLAG}  ${True}

${TTITRACE_FLAG_CU}  ${False}
${TTITRACE_FLAG_DU1}  ${False}
${TTITRACE_FLAG_DU2}  ${False}
${TTITRACE_FLAG_DU3}  ${False}
${TTITRACE_FLAG_DU4}  ${False}
${UTE_WIRESHARK_FLAG}  ${True}

${config_path}    ${CURDIR}/../resources_aic/configuration_file/trunk/Aic_AP_LO_CONF_ransharing_local
${tl_type}        tdd_sa_cmwv_ransharing_local/FS/1du/1cell
${wts_git_path}    ${config_path}/${tl_type}
${DU_NUMBER}    du


*** Test Cases ***
Capture Logs Aic
    Log To Console    ${EMPTY}
    ${color}=  Evaluate  "\\033[33m"
    Log To Console    ${color}\############################################
    Log To Console    ${color}You can start your testing now
    Log To Console    ${color}Press CTRL-C for only one time if finished...
    Log To Console    ${color}\############################################
    Sleep    10h

*** Keywords ***
Suite Setup
    Run Keyword If  "${DU_NUMBER.lower()}"!="du" and "${DU_NUMBER.lower()}"!="2du" and "${DU_NUMBER.lower()}"!="4du"
    ...  Log To Console With Time Prefix
    ...  "Inputed DU_NUMBER variable is illegal, [du, 2du, 4du] for your choice, default is du"  WARN
    Run Keyword If  "${DU_NUMBER.lower()}"!="du" and "${DU_NUMBER.lower()}"!="2du" and "${DU_NUMBER.lower()}"!="4du"  Fail

    Common Suite Setup Aic    ${DU_NUMBER}
    ${cu_state}  Get Cu State
    ${du_state}  Get Du State
    Set Suite Variable  ${cu_state}
    Set Suite Variable  ${du_state}
    ${du2_state}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Du2 State
    ${du3_state}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Du3 State
    ${du4_state}  Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Du4 State
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Set Suite Variable  ${du2_state}
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Set Suite Variable  ${du3_state}
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Set Suite Variable  ${du4_state}

    ${color}=  Evaluate  "\\033[33m"
    Run Keyword If  '${DU_NUMBER.lower()}'=='du'  Log To Console  ${color}\Capture Logs Of 1Du Scenario
    Run Keyword If  '${DU_NUMBER.lower()}'=='du'  Capture Logs Of 1Du Scenario
    Run Keyword If  '${DU_NUMBER.lower()}'=='2du'  Log To Console  ${color}\Capture Logs Of 2Du Scenario
    Run Keyword If  '${DU_NUMBER.lower()}'=='2du'  Capture Logs Of 2Du Scenario
    Run Keyword If  '${DU_NUMBER.lower()}'=='4du'  Log To Console  ${color}\Capture Logs Of 4Du Scenario
    Run Keyword If  '${DU_NUMBER.lower()}'=='4du'  Capture Logs Of 4Du Scenario

Test Setup
    Common Test Setup And Start To Capture Logs Aic
    Get Cu Scf  scf_tar_path=${SAVE LOG DIRECTORY}/scf_before_test_cu.xml
    Get Du Scf  scf_tar_path=${SAVE LOG DIRECTORY}/  scf_file_name=scf_before_test_du.xml
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'  Get Du2 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/
    ...  scf_file_name=scf_before_test_du2.xml
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'  Get Du3 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/
    ...  scf_file_name=scf_before_test_du3.xml
    Run Keyword If  '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'  Get Du4 Scf  scf_tar_path=${SAVE LOG DIRECTORY}/
    ...  scf_file_name=scf_before_test_du4.xml

Test Teardown
    Common Test Teardown And Stop Capture Logs Aic

Suite Teardown
    Execute Cmd On Pc    ls -ltR ${SUITE_LOG_DIRECTORY}
    Common Suite Teardown Aic
    Log To Console    All logs are In ${SUITE_LOG_DIRECTORY}
    Log To Console    \####################################

Generate Cfg And Start WTS
    _Get Iphy Info Aic
    Get Cu Scf  scf_tar_path=./scf_cu.xml
    Get Du Scf  scf_tar_path=./  scf_file_name=scf_du.xml
    ${cutype}  Get Scf Parameter Value Cu  gNbCuType  ./scf_cu.xml
    Generate Default Cfg Aic  30  ${WTS_DIR}  ${AUTO_CFG}  ${wts_git_path}/wts.cfg  ./scf_cu.xml  ./scf_du.xml  ${cutype}
    Teardown Cfg Aic
    Start Wts And Wait Until Gnb Onair Aic    ${AUTO_CFG}    ${DEBUG_LOG_LEVEL}

Capture Logs Of 1Du Scenario
    ${1du_onair_check_cond1}  Catenate  "${cu_state.lower()}"=="enabled" and "${DU_NUMBER.lower()}"=="du" and "${du_state.lower()}"=="onair"
    ${1du_onair_check_cond2}  Catenate  ("${cu_state.lower()}"!="enabled" or "${du_state.lower()}"!="onair") and ${SKIP_ON_AIR} is not ${True}
    Run Keyword If  ${1du_onair_check_cond1}  Debug Enter Into Egate Aic  ELSE  Run Keyword If  ${1du_onair_check_cond2}  Generate Cfg And Start WTS

Capture Logs Of 2Du Scenario
    ${2du_onair_check_cond1}  Catenate  "${cu_state.lower()}"=="enabled" and "${du_state.lower()}"=="onair" and "${du2_state.lower()}"=="onair"
    ${2du_onair_check_cond2}  Catenate  ("${cu_state.lower()}"!="enabled" or "${du_state.lower()}"!="onair" or "${du2_state.lower()}"!="onair")
    ...  and ${SKIP_ON_AIR} is not ${True}
    Run Keyword If  ${2du_onair_check_cond1}  Debug Enter Into Egate Aic  ELSE  Run Keyword If  ${2du_onair_check_cond2}  Generate Cfg And Start WTS

Capture Logs Of 4Du Scenario
    ${4du_onair_check_cond1}  Catenate  "${cu_state.lower()}"=="enabled" and "${du_state.lower()}"=="onair" and "${du2_state.lower()}"=="onair"
    ...  and "${du3_state.lower()}"=="onair" and "${du4_state.lower()}"=="onair"
    ${4du_onair_check_cond2}  Catenate  ("${cu_state.lower()}"!="enabled" or "${du_state.lower()}"!="onair" or "${du2_state.lower()}"!="onair"
    ...  or "${du_state.lower()}"!="onair" or "${du2_state.lower()}"!="onair")
    ...  and ${SKIP_ON_AIR} is not ${True}
    Run Keyword If  ${4du_onair_check_cond1}  Debug Enter Into Egate Aic  ELSE  Run Keyword If  ${4du_onair_check_cond2}  Generate Cfg And Start WTS

