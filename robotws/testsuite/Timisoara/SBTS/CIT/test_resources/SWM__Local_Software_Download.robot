*** Settings ***
Documentation
    ...  TC should perform software download without activation.
    ...  After that BTS state shall be verified.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_DOWNLOAD_TIMEOUT}  600  # Given in seconds; That is a timeout for SW download and activation (without reset)


*** Keywords ***
TC__SWM__Local_Software_Download
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7167
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7167 - Initial creation
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 10.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17435 - swpackage_search_status comparison changed from True to PASS
    ...  - 28.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26945 - skip to check the passive partition for SM ASIK.
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_Download_TAT-7167.png#
    ...

    Set Tags  CA-SWM  PHASE-CIT  OWNER-kamil.osak@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001486_RP000938  FEATURE-RP001145_RP000938  FEATURE-RP001809
    ...  FEATURE-RP002035  FEATURE-RP001966  FEATURE-RP002179

    Step1: Find Path To SW Package
    Step2: Check SW Versions Before Sw Download
    Step3: SW Download
    Step4: Check Sw Versions After Sw Download And Verify Them
    Step5: Check BTS State


Step1: Find Path To SW Package
    Log Step Header  step1: Find path to SW package
    ${swpackage_search_status}  ${target_sw_path}  Run Keyword And Ignore Error
    ...  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Run Keyword If  '${swpackage_search_status}'!='PASS'
    ...  Set Test Norun  SW package search failed
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Set Test Norun  No sw package available
    Set Test Variable  ${TARGET_SW_PATH}
    ${chosen_sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    Set Test Variable  ${CHOSEN_SW_RELEASE_NAME}
    Log  Chosen software package is: ${CHOSEN_SW_RELEASE_NAME}  console=true


Step2: Check SW Versions Before Sw Download
    Log Step Header  step2: Check SW versions
    ${active_sw_before}  Infomodel Get Active SW Version
    ${passive_sw_before}  Infomodel Get Passive SW Version
    ${planned_sw_before}  Infomodel Get Planned SW Version
    Set Test Variable  ${ACTIVE_SW_BEFORE}
    Set Test Variable  ${PASSIVE_SW_BEFORE}
    Set Test Variable  ${PLANNED_SW_BEFORE}
    Log  Active software package is: ${ACTIVE_SW_BEFORE}  console=true
    Log  Passive software package is: ${PASSIVE_SW_BEFORE}  console=true
    Log  Planned software package is: ${PLANNED_SW_BEFORE}  console=true


Step3: SW Download
    Log Step Header  step3: SW download
    Log  Will now perform software download  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  False  timeout=${SW_DOWNLOAD_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software download failed: ${sw_update_msg}


Step4: Check Sw Versions After Sw Download And Verify Them
    Log Step Header  step4: Check sw versions after sw download and verify them
    ${active_sw_after}  Infomodel Get Active SW Version
    ${passive_sw_after}  Infomodel Get Passive SW Version
    ${planned_sw_after}  Infomodel Get Planned SW Version
    Log  Active software package is: ${active_sw_after}, expected: ${ACTIVE_SW_BEFORE}  console=true
    Log  Passive software package is: ${passive_sw_after}, expected: ${PASSIVE_SW_BEFORE}  console=true
    Log  Planned software package is: ${planned_sw_after}, expected: ${CHOSEN_SW_RELEASE_NAME}  console=true

    ${active_sw_check_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${ACTIVE_SW_BEFORE}  ${active_sw_after}
    ${passive_sw_check_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${PASSIVE_SW_BEFORE}  ${passive_sw_after}
    ${planned_sw_check_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${CHOSEN_SW_RELEASE_NAME}  (?i).*${planned_sw_after}(?!T[12]).*
    Run Keyword If  ${active_sw_check_status}==${FALSE}
    ...  Set Test Failed  Active software has a unexpected value
    ${smods}  Get FSM Info
    FOR  ${smod}  IN  @{smods}
        ${is_asik}  Set Variable If  'ASIK' in '${smod}[productName]'  ${TRUE}  ${FALSE}
        Exit For Loop If  ${is_asik}
    END
    ${passive_sw_check_status}  Set Variable If  ${is_asik}  ${TRUE}  ${passive_sw_check_status}
    Run Keyword If  ${passive_sw_check_status}==${FALSE}
    ...  Set Test Failed  Passive software has a unexpected value
    Run Keyword If  ${planned_sw_check_status}==${FALSE}
    ...  Set Test Failed  Planned software has a unexpected value


Step5: Check BTS State
    Log Step Header  step5: Check BTS State
    Verify BTS States


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
