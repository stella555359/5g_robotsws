*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library            random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot



Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${PATH_Storage}    /home/ute/CNI112690

*** Keywords ***
bts_reset_on_webem_after_PCIe_issues_on_primary_core
  [Arguments]  ${asik_alias}=ASIK Master
  ${command}  Set Variable  pcotool -n REG_PWRSEQ_CTRL -m 0x04000000 0x04000000
  connection_alias_store.Connect to Common Unit Master    alias=${asik_alias}
  csn.Send Command    command=${command}    connection=${asik_alias}    timeout=60
  Check all cells info should be onair
  Perform BTS Site Reset
  Wait For Expect Fault Present    faultId=251    timeout=600
  # Run Keyword And Continue On Failure  RU Should Be Power Off  ru_index=${1}
  # Run Keyword And Continue On Failure  RU Should Be Power Off  ru_index=${2}
  ${smod_status}  Run Keyword And Return Status  COAM Check GNB ASIK status
  ${bbmod_status}  Run Keyword And Return Status  COAM Check GNB ABIL status
  Should be true    ${smod_status}==${False}
  Should be true    ${bbmod_status}==${False}
  # Wait For Expect Fault Present    faultId=4352    timeout=600
    ${ALLOWED_FAULT}    Copy List    ${exist_fault}
    Set Suite Variable    ${ALLOWED_FAULT}
    add fault to the allowed fault list    faultId=${251}
    add fault to the allowed fault list    faultId=${4352}
    add fault to the allowed fault list    faultId=${4367}
    ${exist_fault1}    Copy List    ${ALLOWED_FAULT}
  Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault1}    file_path=${TS_CASE_LOG_PATH}
  [Teardown]  Restore environment

Restore environment
  Perform Site Power Off
  Perform Site Power Off  unit_index=${1}
  sleep    180s
  Perform Site Power On  unit_index=${1}
  Perform Site Power On
  sleep    180s
  Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
  Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
  ${status}  Run Keyword And Return Status  Wait For Expect Fault Present    faultId=6450    timeout=60
  Run keyword If  ${status}  Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}
  csn.reset_cache







