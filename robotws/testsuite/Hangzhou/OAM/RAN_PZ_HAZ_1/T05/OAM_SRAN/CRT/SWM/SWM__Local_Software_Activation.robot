*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Library    OperatingSystem


*** Variables ***
${Target SW name}                             ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${Target SW dir}          /home/ute/btsauto/TARGET_SW  # Directory sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW Activation wo download Timeout}              300  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    60  # Test timeout (in minutes)


*** Keywords ***
TC__SWM__Local_Software_Activation
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7168
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC should perform software activation.
    ...  After that BTS state shall be verified.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7168 - Initial creation
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 11.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17439 - Add admin and infomodel reset option after update, KWs 'refreshment'
    ...  - 18.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17895 - Change ${Ping loss timeout} default value to 420 and stable ping
    ...  min_up to 360
    ...  - 21.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18219 - Add variable $Test_Timeout and change default value to 30  minutes
    ...  - 10.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18424 - Checking visibility of MNL_R object before checking SW Version.
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_Activation_TAT-7168.png#

    [Timeout]    ${Test_Timeout} minutes
    Set Tags    CA-SWM    PHASE-CIT    OWNER-kamil.osak@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    GROUP_IN_CHARGE-WRO_7_Vrf    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP001486_RP000938    FEATURE-RP001145_RP000938    FEATURE-RP001809    FEATURE-RP002035
    ...    FEATURE-RP001966    FEATURE-RP002179

    Remove SWDLreport.txt
    Sleep  60
    step1: Find path to SW package
    step2: Check SW versions before sw activation
    step3: SW activation
    step4: Check if BTS onAir
    step5: Check SW versions after SW activation and verify them
    step6: Check active alarms
    Check SWDLReport

step1: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  step1: Find path to SW package

    ${Target SW path}  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${Target SW path}'== ${None}   Fail  Target path could not be established
    Set test variable  ${TARGET_SW_PATH}  ${Target SW path}
    Log  Chosen software package is: ${Target SW path}  console=${TRUE}

step2: Check SW versions before sw activation
    [Documentation]    Short description.
    Log Step Header  step2: Check SW versions

    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    ${sw_release_name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    Log  TARGET_SW Release Name: ${sw_release_name}  console=${TRUE}
    ${sw_number}  Should match regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Set test variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set test variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}

    Set tags  SW_BEFORE_ACTIVATION_active-${ACTIVE_SW_BEFORE}
    Set tags  SW_BEFORE_ACTIVATION_passive-${PASSIVE_SW_BEFORE}

    ${Planned SW before}  Infomodel Get Planned SW Version
    Set test variable  ${PLANNED_SW_BEFORE}  ${Planned SW before}
    Log  Active software package is: ${ACTIVE_SW_BEFORE}  console=${TRUE}
    Log  Passive software package is: ${PASSIVE_SW_BEFORE}  console=${TRUE}
    Log  Planned software package is: ${PLANNED_SW_BEFORE}  console=${TRUE}
    ${Planned_sw_status}  Run keyword and return status  Should be equal as strings  ${PLANNED_SW_BEFORE}  None
    Run keyword if  ${Planned_sw_status}  Set test norun  No Planned Software on BTS!
    Log  Checking if TARGET SW is present on active, passive (it shouldn't) or planned partition (it should)...  console=${TRUE}
    Should not contain  ${ACTIVE_SW_BEFORE}  ${sw_number}
    Should not contain  ${PASSIVE_SW_BEFORE}  ${sw_number}
    Should contain  ${PLANNED_SW_BEFORE}  ${sw_number}
    Log  TARGET SW not present on active and passive, but present on planned partition  console=${TRUE}

step3: SW activation
    [Documentation]    Short description.
    Log Step Header  step3: SW activation
    Log  Will now perform software update  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_PATH}  True  timeout=${SW Activation wo download Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software activation failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
    Wait until keyword succeeds  5 min  10 sec  Fail if connection to infomodel is not available

step4: Check if BTS onAir
    [Documentation]    Short description.
    Log Step Header  step4: Check if BTS onAir
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

step5: Check SW versions after SW activation and verify them
    [Documentation]    Short description.
    Log Step Header  step5: Check SW versions after SW activation and verify them
    Checking MNL_R status
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Set test variable  ${ACTIVE_SW_AFTER}  ${software_info['Active SW version']}
    Set test variable  ${PASSIVE_SW_AFTER}  ${software_info['Passive SW version']}
    Set tags  SW_AFTER_ACTIVATION_active-${ACTIVE_SW_AFTER}
    Set tags  SW_AFTER_ACTIVATION_passive-${PASSIVE_SW_AFTER}
    ${Planned SW after}  Infomodel Get Planned SW Version
    Set test variable  ${PLANNED_SW_AFTER}  ${Planned SW after}
    Log  Active software package is: ${ACTIVE_SW_AFTER}, expected: ${PLANNED_SW_BEFORE}  console=${TRUE}
    Log  Passive software package is: ${PASSIVE_SW_AFTER}, expected: ${ACTIVE_SW_BEFORE}  console=${TRUE}
    Log  Planned software package is: ${PLANNED_SW_AFTER}, expected: None  console=${TRUE}
    Should contain  ${ACTIVE_SW_AFTER}  ${PLANNED_SW_BEFORE}
    Should contain  ${PASSIVE_SW_AFTER}  ${ACTIVE_SW_BEFORE}
    Log Important Message  SW builds on active and passive partition are as expected

step6: Check active alarms
    [Documentation]    Short description.
    Log Step Header  step6: Check active alarms
    ${alarm_check}  Run keyword and return status  Check SOAM Active Alarms
    Run keyword if    not ${alarm_check}  Set Test Restriction  Reading active alarms failed

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Fail if connection to infomodel is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    ${infomodel_reset_status}  Run keyword and return status  ute_admin_infomodel.Reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   ute_admin_infomodel.Check infomodel object    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1
    Run keyword if  ${status}  Return from keyword
    Fail  ${infomodel_reset_status}

Remove SWDLreport.txt
    [Documentation]    Short description.
    Log To Console   Remove SWDLreport.txt from ENB
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  rm /ffs/run/config/SWDLreport.txt

Check SWDLReport
    [Documentation]    Short description.
    Log To Console    SWDLreport.txt should not contain following prints:
    Set Connection Parameters  192.168.255.1  user=toor4nsn  password=oZPS0POrRieRtu
    Run Remote Linux Command  grep "Distributing file" /rom/config/SWDLreport.txt | grep -v "(FRM-" | wc -l
    Run Remote Linux Command  grep "Downloading file" /rom/config/SWDLreport.txt | grep -v "(FRM-" | wc -l
