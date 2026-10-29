*** Settings ***
Documentation
    ...  TC for SW download cancel. There are optional parameters:
    ...  1. Target SW name - SW package name. If not given, TC will choose newest package in a directory
    ...  2. Target SW dir - Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SLEEP_BEFORE_CANCEL}  90  # Interval (in seconds) before sw update initiation and cancel
${DOWNLOAD_TIMEOUT}  600  # Timeout for SW download; KW: 'ute_admin.Update Software'
${RM_DETECTION_TIMEOUT}  15 min  # Timeout for all connected RMs detection (in minutes)


*** Keywords ***
TC__SWM__Local_Software_Download_Cancel
    [Documentation]
    ...
    ...  *********************
    ...  History of changes
    ...  *********************
    ...  06.01.2018 - TAT-6687 - initial creation
    ...  07.11.2018 - TAT-12753 - Symlink this TC to SBTS18/CI
    ...  30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  17.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17733 - Decreases {SLEEP BEFORE CANCEL} default value and unmarks SW_Activation
    ...  24.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18860 - Add RMODs check as precondition
    ...  15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27192 - Skip check between Passive SW before and Passive SW after for ASIK smod
    ...  19.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30399 - Add release to sw update admin connection

    Set Tags  CA-SWM  PHASE-CIT  OWNER-delia.margulescu@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step1: Find Path To SW Package
    Step2: Check SW Versions Before Sw Download Cancel
    Step3: SW Download Initiation And Cancel
    Step4: Verify SW Versions After Sw Download Cancel
    Step5: BTS States Verification


Step1: Find Path To SW Package
    Log Step Header  step1: Find path to SW package
    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    IF  '${target_sw_path}'== ${None}  Fail
    Set Test Variable  ${TARGET_SW_PATH}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true
    Log  Waiting for all RMODs to be detected  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20s
    ...  Check If All Radio Modules Are Available
    IF  ${status}==${FALSE}
    ...  Set Test Blocked  Not all radio modules are available


Step2: Check SW Versions Before Sw Download Cancel
    Log Step Header  step2: Check SW versions before cancel
    ${software_info}  Get Software Info
    Set Test Variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set Test Variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}
    Log  Active software package is: ${ACTIVE_SW_BEFORE}  console=true
    Log  Passive software package is: ${PASSIVE_SW_BEFORE}  console=true
    ${sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    IF  '${PASSIVE_SW_BEFORE}'==''
    ...  Set Test Restriction  Passive sw version was not readable
    Log  chosen: ${sw_release_name} active: ${ACTIVE_SW_BEFORE}  console=true
    Check If SW Already Exists On BTS  ${sw_release_name}  ${ACTIVE_SW_BEFORE}  ${PASSIVE_SW_BEFORE}


Step3: SW Download Initiation And Cancel
    Log Step Header  step3: SW update and cancel
    Log  Will now initiate software update and cancel it after ${SLEEP_BEFORE_CANCEL}s.  console=true
    ${branch}  Set Variable If  '_9999_' in '${ACTIVE_SW_BEFORE}'  SBTS00  ${ENB_BRANCH}
    Setup Admin  bts_host=${SMOD1['TRS_IP']}  bts_port=443  use_ssl=${TRUE}  update_interval=1000  alias=sw_update
    ...  release=${branch}
    ${task}  Run Keyword In Background  Update software  sw_package=${TARGET_SW_PATH}  should_activate=${FALSE}  timeout=${DOWNLOAD_TIMEOUT}
    ...  alias=sw_update
    Sleep  ${SLEEP_BEFORE_CANCEL}
    ${abort_verdict}  ${abort_output}  Run Keyword And Ignore Error
    ...  Abort Software Update  timeout=180  connection=sw_update  detailed_output=true
    IF  '${abort_verdict}'!='PASS'
    ...  Set Test Failed  SW download cancel failed
    Run Keyword And Expect Error  AdminApiProcedureFailureException*
    ...  Collect Keyword Result  ${task}
    [Teardown]  Run Keyword And Continue On Failure  Teardown Admin  alias=sw_update


Step4: Verify SW Versions After Sw Download Cancel
    Log Step Header  step4: Check SW versions after cancel
    ${software_info}  Get Software Info
    Log  Active software package is: ${software_info['Active SW version']}  console=true
    Log  Passive software package is: ${software_info['Passive SW version']}  console=true
    Should Match  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    ${smods}  Get FSM Info
    FOR  ${smod}  IN  @{smods}
        ${is_asik}  Set Variable If  'ASIK' in '${smod}[productName]'  ${TRUE}  ${FALSE}
        IF  ${is_asik}  BREAK
    END
    IF  '${is_asik}'=='${FALSE}'  Should Match  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}


Step5: BTS States Verification
    Log Step Header  step5: sBTS states verification
    Verify BTS States


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  expected_bts_status=^(?!.*NotCommissioned).*


TC Teardown
    Common Test Teardown  collect_snapshot=never
