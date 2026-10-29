*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Library    taf.sbts.oam.coam.admin
Library    OperatingSystem
Library    ute_async
##Library    hran_tools
##Library    hran_file_operations


*** Variables ***
${Target SW name}        ${None}                         # SW package name. If not given, TC will choose newest package in a directory.
#${Target SW dir}         /home/ute/btsauto/TARGET_SW
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SLEEP_BEFORE_CANCEL}   60                              # Interval (in seconds) before sw update initiation and cancel
${DOWNLOAD_TIMEOUT}      600                             # Timeout for SW download; KW: 'taf.sbts.oam.coam.admin.Update Software'
${RM_DETECTION_TIMEOUT}  15 min                         # Timeout for all connected RMs detection (in minutes)


*** Keywords ***
TC__SWM__Local_Software_Download_Cancel
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-6687
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  TC for SW download cancel. There are optional parameters:
    ...
    ...  1. Target SW name - SW package name. If not given, TC will choose newest package in a directory
    ...  2. Target SW dir - Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 06.01.2018 - TAT-6687 - initial creation
    ...  - 07.11.2018 - TAT-12753 - Symlink this TC to SBTS18/CI
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 17.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17733 - Decreases {SLEEP BEFORE CANCEL} default value and unmarks SW_Activation
    ...  - 24.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18860 - Add RMODs check as precondition
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6687_cancel.png/

    Set Tags    CA-SWM    PHASE-CIT    OWNER-kamil.osak@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    GROUP_IN_CHARGE-WRO_7_Vrf    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP001307_RP000923    FEATURE-RP0001145_RP000923

    step1: Find path to SW package
    step2: Check SW versions before sw download cancel
    step3: SW download initiation and cancel
    step4: Verify SW versions after sw download cancel
    step5: BTS states verification
#    SWM_SW_update_connection_check
#    Recover BTS

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  step1: Find path to SW package
    ${Target SW path}  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    Set test variable  ${Target SW path}
    Set test variable  ${Target SW name}
    Log  Chosen software package is: ${Target SW path}  console=${TRUE}
    Log  Waiting for all RMODs to be detected  console=${TRUE}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s  Check if all radio modules are available
    Run keyword if    not ${status}  Set test blocked  Not all radio modules are available

step2: Check SW versions before sw download cancel
    [Documentation]    Short description.
    Log Step Header  step2: Check SW versions before cancel
    ${Active SW before}   Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive SW before}  Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    set test variable  ${Active SW before}
    set test variable  ${Passive SW before}
    Log  Active software package is: ${Active SW before}  console=${TRUE}
    Log  Passive software package is: ${Passive SW before}  console=${TRUE}
    ${SW Release Name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${Target SW path}
    Run Keyword If  '${Passive SW before}'==''  Set Test Restriction  Passive sw version was not readable
    Log  chosen: ${SW Release Name} active: ${Active SW before}  console=${TRUE}
    hran_general.Check if SW already exists on BTS  ${SW Release Name}  ${Active SW before}  ${Passive SW before}

step3: SW download initiation and cancel
    [Documentation]    Short description.
    Log Step Header  step3: SW update and cancel
    Log  Will now initiate software update and cancel it after ${SLEEP_BEFORE_CANCEL}s.  console=${TRUE}
    taf.sbts.oam.coam.admin.Setup admin  bts_host=${SMOD1['TRS_IP']}  bts_port=443  use_ssl=${TRUE}  update_interval=1000  alias=sw_update
    ${task}    taf.sbts.oam.coam.admin.Run keyword in background
    ...    Update software    sw_package=${Target SW path}  should_activate=${FALSE}
    ...    timeout=${DOWNLOAD_TIMEOUT}  alias=sw_update
    Sleep    ${SLEEP_BEFORE_CANCEL}
    set test variable   ${Download_cancel_expect_time}    180
    ${download_cancel_start}    Get Current date
    ${abort_verdict}  ${abort_output}  Run keyword and ignore error    taf.sbts.oam.coam.admin.Abort software update  alias=sw_update
    Run keyword if    not '${abort_verdict}'=='PASS'  Set test failed  SW download cancel failed
    Run keyword and expect error    AdminApiProcedureFailureException*
    ...    taf.sbts.oam.coam.admin.Collect keyword result    ${task}
    ${download_cancel_end}    Get Current date
    Run keyword and continue on failure  taf.sbts.oam.coam.admin.Teardown admin  alias=sw_update
    Operation_KPI_Check    ${download_cancel_end}    ${download_cancel_start}    ${Download_cancel_expect_time}    CANCEL_SW_MANAGEMENT_BTS_KPI

step4: Verify SW versions after sw download cancel
    [Documentation]    Short description.
    Log Step Header  step4: Check SW versions after cancel
    ${Active SW after}   Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive SW after}  Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    Log  Active software package is: ${Active SW after}  console=${TRUE}
    Log  Passive software package is: ${Passive SW after}  console=${TRUE}
    Should match  ${Active SW before}  ${Active SW after}
    Should match  ${Passive SW before}  ${Passive SW after}

step5: BTS states verification
    [Documentation]    Short description.
    Log Step Header  step5: sBTS states verification
    Verify BTS states

SWM_SW_update_connection_check
    [Documentation]    Short description.
    Log Step Header  SW update connection check
    Start async  taf.sbts.oam.coam.admin  taf.sbts.oam.coam.admin.Update software  sw_package=${Target SW path}  should_activate=${FALSE}
    Sleep  5
    Run     mv ${Target SW path} /home/ute/btsauto/
    Check fault 27
    Run     mv /home/ute/btsauto/SBTS* ${Target SW dir}
    Stop Async

Check fault 27
    [Documentation]    Short description.
    Log Step Header  Check fault 27
    wait until keyword succeeds   20min  30s  Check faults on admin  27  Minor

Check faults on admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${faultId}: <description>
    ...        ${severity}: <description>
    [Arguments]   ${faultId}   ${severity}
    ${EXPECTED_ALARM1}     Create Dictionary  faultId=${faultId}  severity=${severity}
    ${EXPECTED_ALARMs}            Create List  ${EXPECTED_ALARM1}
    Admin Check Active Alarms  expected_patterns=${EXPECTED_ALARMs}

Recover BTS
    [Documentation]    Short description.
    Reset testline

Reset testline
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.run keyword in background    Reset  timeout=300
    log to console with time  Check if reset is performed
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for reset  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after Reset
    Log  BTS is stable after Reset.  console=${TRUE}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup    modules_check=${FALSE}    cells_check=${FALSE}    alarms_check=${FALSE}
    #expected_BTS_status=^(?!.*NotCommissioned).*

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown    collect_snapshot=never
