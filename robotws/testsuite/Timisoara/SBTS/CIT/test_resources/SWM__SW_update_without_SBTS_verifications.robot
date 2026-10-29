*** Settings ***
Documentation
    ...  TC should perform software update without SBTS verifications

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  3600  # Given in seconds; That is a timeout for SW download and activation (without reset)
${ONAIR_TIMEOUT}  900


*** Keywords ***
TC__SWM__SW_update_without_SBTS_verifications
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27408 - Intial creation
    ...  **********************

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  AUTHOR-iasmin.tomici@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  SW-SBTS  SW-FDSW
    ...  SW-FSM3

    Step1: Find Path To SW Package
    Step2: SW Update
    Sleep  ${ONAIR_TIMEOUT}


Step1: Find Path To SW Package
    Log Step Header  Step1: Find path to SW package
    Wait Until Keyword Succeeds  5 min  15 sec
    ...  Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True
    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Fail  Target path could not be established
    Set Test Variable  ${TARGET_SW_PATH}  ${target_sw_path}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true


Step2: SW Update
    Log Step Header  Step2: SW update
    Log  Will now perform software update  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  timeout=${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Fail  Software update failed: ${sw_update_msg}
    Teardown Admin
