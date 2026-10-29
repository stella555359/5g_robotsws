*** Settings ***
Documentation
    ...  TC for updating RMOD software when fault 23 is present. There are optional parameters:
    ...  1. SW Update Timeout - Given in seconds; That is a timeout for SW download and Activation until reset
    ...  2. proceduralStatus Check Number - Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s
    ...  3. Target SW dir - Directory in which TC should look for sw package compatible with active software of the bts. If not given,
    ...  '/home/ute/btsauto/TARGET_SW' shall be used
    ...  TC timeout: 30 min

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SW_UPDATE_TIMEOUT}  400  # Given in seconds; That is a timeout for SW download and Activation (probably without reset - will be clarified)
${PROCEDURAL_STATUS_CHECK_NUMBER}  60  # Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW'
# shall be used
${PING_STABLE_TIMEOUT}  400  # Timeout for ping until target is stable


*** Keywords ***
TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 29.11.2017 - initial creation
    ...  - 26.02.2018 - TAT 8602
    ...  - 11.04.2018 - TAT-9691
    ...  - 24.08.2018 - TAT-11919
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17943 - Moves KW:'Check if all radio modules are available'
    ...           to ca_swm_general.robot
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29216 - Fix syntax error and ping stable timeout
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_update_for_new_RF_uncommissioned_TAT_8350.png#
    [Timeout]  30 minutes

    Set Tags  CA-SWM  PHASE-CIT  GROUP_IN_CHARGE-WRO_7_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  OWNER-mariusz.bak@nokia.com
    ...  AUTHOR-jaroslaw.piszczala@nokia.com  MAINTAINER-tomasz.zadworny@nokia.com  FEATURE-RP001486_RP000912  FEATURE-RP001145_RP000912

    Preconditions
    Step1: Check If Fault 23 Is Present
    Step2: Check SW Versions
    Step3: Find Path To SW Package
    Step4: Update SW
    Step5: Check If BTS ProceduralStatus Is NotCommissioned
    Step6: Check If Fault 23 Absent
    Step7: Check SW Versions


Preconditions
    Log In Frame  Preconditions
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3m  20s
    ...  Check If All Radio Modules Are Available
    IF  ${status}==${FALSE}  Fail  Not all radio modules are available


Step1: Check If Fault 23 Is Present
    Log Step Header  step1: Check if fault 23 is present
    ${active_alarms}  coam.Get Active Alarms
    ${radios_with_fault_23_dn_list}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        IF  ${alarm}[faultId] == ${FAULT_23}[fault_id]  Append To List  ${radios_with_fault_23_dn_list}  ${alarm}[notifier]
    END
    ${fault_23_presence_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${radios_with_fault_23_dn_list}
    IF  ${fault_23_presence_status}==${FALSE}  Fail  No fault 23 found!
    Log  Fault 23 has been detected for following RMODs: ${radios_with_fault_23_dn_list}  console=true
    Set Test Variable  ${RADIOS_WITH_FAULT_23_DN_LIST}


Step${step_number}: Check SW Versions
    Log Step Header  step${step_number}: Check SW versions
    ${active_sw}  Infomodel Get Active SW Version
    Set Global Variable  ${ACTIVE_SW}
    ${passive_sw}  Infomodel Get Passive SW Version
    Log  Active software package is: ${ACTIVE_SW}  console=true
    Log  Passive software package is: ${passive_sw}  console=true
    IF  '${ACTIVE_SW}'==''  Log  Active sw version was not readable  level=ERROR  console=true
    IF  '${passive_sw}'==''  Log  Passive sw version was not readable  level=WARN  console=true
    IF  '${step_number}'=='2'  Set Global Variable  ${ACTIVE_SW_BEFORE_UPDATE}  ${ACTIVE_SW}
    IF  '${step_number}'=='7'  Should Be Equal  ${ACTIVE_SW_BEFORE_UPDATE}  ${ACTIVE_SW}


Step3: Find Path To SW Package
    Log Step Header  step3: Find path to SW package
    ${active_sw_pattern}  Get Regexp Matches  ${ACTIVE_SW}  \\S+_(\\S+_\\d+_\\d+_\\d+)  1
    ${package_name}  OperatingSystem.List Files In Directory  ${TARGET_SW_DIR}  *${active_sw_pattern[0]}*
    Should Not Be Empty  ${package_name}  Required package not present in ${TARGET_SW_DIR}
    ${sw_path}  Join Path  ${TARGET_SW_DIR}  ${package_name[0]}
    OperatingSystem.File Should Exist  ${sw_path}
    Set Global Variable  ${SW_PATH}
    Log  SW package found at: ${SW_PATH}  console=true


Step4: Update SW
    Log Step Header  step4: Update SW
    Log  Will now perform software update  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    IF  '${sw_update_result}'=='FAIL'  Fail  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods reset  console=true
    Log  Wait until rmods operationalState Disabled  console=true
    Wait Until Keyword Succeeds  3 min  30 sec
    ...  Check Rmods OperationalState  (?i)Disabled  ${RADIOS_WITH_FAULT_23_DN_LIST}
    Log  Wait until rmods operationalState Enabled  console=true
    Wait Until Keyword Succeeds  10 min  30 sec
    ...  Check Rmods OperationalState  (?i)Enabled  ${RADIOS_WITH_FAULT_23_DN_LIST}
    Sleep  300
    ${smod_ping_stable}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    IF  ${smod_ping_stable}
      Log  SMOD is stable during RMODs update  console=true
    ELSE
      Fail  SMOD lost ping during RMODs update [NOK]
    END

Step5: Check If BTS ProceduralStatus Is NotCommissioned
    Log Step Header  step5: Check if BTS proceduralStatus is NotCommissioned
    Log  Will check proceduralStatus maximum of ${PROCEDURAL_STATUS_CHECK_NUMBER} times with 10s interval.  console=true
    FOR  ${run}  IN RANGE  1  ${PROCEDURAL_STATUS_CHECK_NUMBER}
        ${bts_procedural_status}  Get Mrbts State
        ${matches}  Run Keyword And Return Status
        ...  Should Match Regexp  ${bts_procedural_status}  (?i)NotCommissioned
        IF  ${matches}
          Log  BTS proceduralStatus: NotCommissioned Check attempt: ${run}  console=true
          RETURN
        END

        Sleep  10
    END
    Set Test Failed  BTS proceduralStatus has not acchieved expected value within timeout


Step6: Check If Fault 23 Absent
    Log Step Header  step6: Check if fault 23 absent
    Sleep  20
    ${active_alarms}  coam.Get Active Alarms
    ${radios_with_fault_23_dn_list}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        IF  ${alarm}[faultId] == ${FAULT_23}[fault_id]  Append To List  ${radios_with_fault_23_dn_list}  ${alarm}[notifier]
    END
    ${verification_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${radios_with_fault_23_dn_list}
    IF  ${verification_status}==${FALSE}  Fail  Fault 23 has been detected for following RMODS: ${radios_with_fault_23_dn_list}. Test failed.
    Log  Fault 23 has not been detected.  console=true


Check Rmods OperationalState
    [Arguments]  ${state}  ${radios_with_fault_23}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${radio_with_fault_23}  IN  @{radios_with_fault_23}
        ${status}  Loop Over Rmods  ${radio_with_fault_23}  ${rmods_parameters}  ${state}
        IF  ${status}==${FALSE}  Fail  Rmods state not ${state}
    END


Loop Over Rmods
    [Arguments]  ${radio_with_fault_23}  ${rmods_parameters}  ${state}

    FOR  ${rmod_parameters}  IN  @{rmods_parameters}
        ${radio_with_fault_23_cut}  Get Regexp Matches  ${radio_with_fault_23}  EQM_R-[0-9]+\/APEQM_R-[0-9]+\/RMOD_R-[0-9]+
        IF  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}'
          Log  ${rmod_parameters['id']} : ${rmod_parameters['operationalState']}  console=true
        END
        ${matches}  Run Keyword And Return Status
        ...  Should Match Regexp  ${rmod_parameters['operationalState']}  ${state}
        Return From Keyword If  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}' and '${matches}' == '${True}'  ${True}
    END

    [Return]  ${False}


TC Setup
    ${ignored_alarm}  Create Dictionary  faultId=23
    ${ignored_alarms}  Create List  ${ignored_alarm}
    Common Test Setup  modules_check=${False}  cells_check=${False}  alarms_check=${True}  ignored_alarms=${ignored_alarms}
    ...  expected_bts_status=(?i)NotCommissioned  tc_name=SWM__SW_update_for_new_RF_unit_uncommissioned


TC Teardown
    Common Test Teardown
