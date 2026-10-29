*** Settings ***
Documentation
    ...  TC should perform software activation.
    ...  After that BTS state shall be verified.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_ACTIVATION_TIMEOUT}  150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  420  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${PING_STABLE_TIMEOUT}  365  # Timeout for ping to regain stable status
${BTS_ON_AIR_TIMEOUT}  15  # Timeout for BTS on Air (in minutes)
${TEST_TIMEOUT}  30  # Test timeout (in minutes)


*** Keywords ***
TC__SWM__Local_Software_Activation
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7168
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7168 - Initial creation
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 11.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17439 - Add admin and infomodel reset option after update, KWs 'refreshment'
    ...  - 18.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17895 - Change ${Ping loss timeout} default value to 420
    ...                                                              and stable ping min_up to 360
    ...  - 21.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18219 - Add variable $Test_Timeout and change default value to 30  minutes
    ...  - 10.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18424 - Checking visibility of MNL_R object before checking SW Version.
    ...  - 04.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25300 - Timeout variable added
    ...  - 12.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26285 - Unavailable stable ping fix
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_Activation_TAT-7168.png#
    [Timeout]  ${TEST_TIMEOUT} minutes

    Set Tags  CA-SWM  PHASE-CIT  OWNER-kamil.osak@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001486_RP000938  FEATURE-RP001145_RP000938  FEATURE-RP001809
    ...  FEATURE-RP002035  FEATURE-RP001966  FEATURE-RP002179

    Step1: Find Path To SW Package
    Step2: Check SW Versions Before Sw Activation
    Step3: SW Activation
    Step4: Check If BTS OnAir
    Step5: Check SW Versions After SW Activation And Verify Them
    Step6: Check Active Alarms


Step1: Find Path To SW Package
    Log Step Header  step1: Find path to SW package

    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Fail  Target path could not be established
    Set Test Variable  ${TARGET_SW_PATH}  ${target_sw_path}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true


Step2: Check SW Versions Before Sw Activation
    Log Step Header  step2: Check SW versions

    ${software_info}  Get Software Info
    ${sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    Log  TARGET_SW Release Name: ${sw_release_name}  console=true
    ${sw_number}  Should Match Regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Set Test Variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set Test Variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}

    Set Tags  SW_BEFORE_ACTIVATION_active-${ACTIVE_SW_BEFORE}
    Set Tags  SW_BEFORE_ACTIVATION_passive-${PASSIVE_SW_BEFORE}

    ${planned_sw_before}  Infomodel Get Planned SW Version
    Set Test Variable  ${PLANNED_SW_BEFORE}  ${planned_sw_before}
    Log  Active software package is: ${ACTIVE_SW_BEFORE}  console=true
    Log  Passive software package is: ${PASSIVE_SW_BEFORE}  console=true
    Log  Planned software package is: ${PLANNED_SW_BEFORE}  console=true
    ${planned_sw_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${PLANNED_SW_BEFORE}  None
    Run Keyword If  ${planned_sw_status}
    ...  Set Test Norun  No Planned Software on BTS!
    Log  Checking if TARGET SW is present on active, passive (it shouldn't) or planned partition (it should)...  console=true
    Should Not Contain  ${ACTIVE_SW_BEFORE}  ${sw_number}
    Should Not Contain  ${PASSIVE_SW_BEFORE}  ${sw_number}
    Should Contain  ${PLANNED_SW_BEFORE}  ${sw_number}
    Log  TARGET SW not present on active and passive, but present on planned partition  console=true


Step3: SW Activation
    Log Step Header  step3: SW activation
    Log  Will now perform software update  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  timeout=${SW_ACTIVATION_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Fail  Software activation failed: ${sw_update_msg}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=true
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${FALSE}
    ...  Fail  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=true
    Log  Waiting for stable ping...  console=true
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    Run Keyword If  ${ping_stable_status}==${FALSE}
    ...  Fail  Ping has not been available for ${PING_STABLE_TIMEOUT} seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=true
    Wait Until Keyword Succeeds  5 min  10 sec
    ...  Fail If Connection With Admin Is Not Available
    Wait Until Keyword Succeeds  5 min  10 sec
    ...  Fail If Connection To Infomodel Is Not Available


Step4: Check If BTS OnAir
    Log Step Header  step4: Check if BTS onAir
    Log  Will now check if BTS is OnAir, timeout=${BTS_ON_AIR_TIMEOUT}min, interval=10sec  console=true
    Wait Until Keyword Succeeds  ${BTS_ON_AIR_TIMEOUT} min  10 sec
    ...  Admin Check All Required State
    Log Important Message  BTS is OnAir, all cells and modules are in expected states


Step5: Check SW Versions After SW Activation And Verify Them
    Log Step Header  step5: Check SW versions after SW activation and verify them
    Checking MNL_R Status
    ${software_info}  Get Software Info
    Set Test Variable  ${ACTIVE_SW_AFTER}  ${software_info['Active SW version']}
    Set Test Variable  ${PASSIVE_SW_AFTER}  ${software_info['Passive SW version']}
    Set Tags  SW_AFTER_ACTIVATION_active-${ACTIVE_SW_AFTER}
    Set Tags  SW_AFTER_ACTIVATION_passive-${PASSIVE_SW_AFTER}
    ${planned_sw_after}  Infomodel Get Planned SW Version
    Set Test Variable  ${PLANNED_SW_AFTER}  ${planned_sw_after}
    Log  Active software package is: ${ACTIVE_SW_AFTER}, expected: ${PLANNED_SW_BEFORE}  console=true
    Log  Passive software package is: ${PASSIVE_SW_AFTER}, expected: ${ACTIVE_SW_BEFORE}  console=true
    Log  Planned software package is: ${PLANNED_SW_AFTER}, expected: None  console=true
    Should Contain  ${ACTIVE_SW_AFTER}  ${PLANNED_SW_BEFORE}
    Should Contain  ${PASSIVE_SW_AFTER}  ${ACTIVE_SW_BEFORE}
    Log Important Message  SW builds on active and passive partition are as expected


Step6: Check Active Alarms
    Log Step Header  step6: Check active alarms
    ${alarm_check}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF
    Run Keyword If  ${alarm_check}==${FALSE}
    ...  Set Test Restriction  Reading active alarms failed


Fail If Connection With Admin Is Not Available
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword
    ${admin_reset_status}  Run Keyword And Return Status
    ...  Reset Admin
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword
    Fail  ${admin_reset_status}


Fail If Connection To Infomodel Is Not Available
    ${status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Check Infomodel Object  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run Keyword If  ${status}
    ...  Return From Keyword
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    ${status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Check Infomodel Object  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run Keyword If  ${status}
    ...  Return From Keyword
    Fail  ${infomodel_reset_status}


TC Setup
    Common Test Setup  tc_name=SWM__Local_Software_Activation


TC Teardown
    Common Test Teardown
