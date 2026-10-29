*** Settings ***
Documentation    TC__CBTS_SBTS__LOGS__Stability
Variables    tc_variables/cbts_sbts__logs__stability_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${STABILITY_PERIOD}         60       # Stability period for BTS check (in minutes)
${CHECK_INTERVAL}           10       # Repeating interval for BTS check during stability period (in minutes)
                                     # Select STABILITY_PERIOD = 0 and CHECK_INTERVAL = 0 for just one run of the checks with no waiting time
${CHECK_SW_VERSION_CBTS}    True     # Only for cloud BTS. Flag for checking active CU and VDU SW. Possible values (by default True): True or False
${CHECK_SW_VERSION_SBTS}    True     # Only for classical BTS. Flag for checking active BTS SW. Possible values (by default True): True or False
${Target_SW_name_BTS1_CU}   Current  # Only for cloud BTS. Name of BTS1 CU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS1 CU SW is compared with current BTS1 CU SW found in common setup step
                                     # - name of BTS1 CU SW specified by user: running BTS1 CU SW is compared with BTS1 CU SW specified by user
${Target_SW_name_BTS1_VDU}  Current  # Only for cloud BTS. Name of BTS1 VDU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS1 VDU SW is compared with current BTS1 CU SW found in common setup step
                                     # - name of BTS1 VDU SW specified by user: running BTS1 VDU SW is compared with BTS1 VDU SW specified by user
${Target_SW_name_BTS1}      Current  # Only for classical BTS. Name of BTS1 SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS1 SW is compared with current BTS1 SW found in common setup step
                                     # - name of BTS1 SW specified by user: running BTS1 SW is compared with BTS1 SW specified by user
${Target_SW_name_BTS2_CU}   Current  # Only for cloud BTS. Name of BTS2 CU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS2 CU SW is compared with current BTS2 CU SW found in common setup step
                                     # - name of BTS2 CU SW specified by user: running BTS2 CU SW is compared with BTS2 CU SW specified by user
${Target_SW_name_BTS2_VDU}  Current  # Only for cloud BTS. Name of BTS2 VDU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS2 VDU SW is compared with current BTS2 CU SW found in common setup step
                                     # - name of BTS2 VDU SW specified by user: running BTS2 VDU SW is compared with BTS2 VDU SW specified by user
${Target_SW_name_BTS2}      Current  # Only for classical BTS. Name of BTS2 SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS2 SW is compared with current BTS2 SW found in common setup step
                                     # - name of BTS2 SW specified by user: running BTS2 SW is compared with BTS2 SW specified by user
${Target_SW_name_BTS3_CU}   Current  # Only for cloud BTS. Name of BTS3 CU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS3 CU SW is compared with current BTS3 CU SW found in common setup step
                                     # - name of BTS3 CU SW specified by user: running BTS3 CU SW is compared with BTS3 CU SW specified by user
${Target_SW_name_BTS3_VDU}  Current  # Only for cloud BTS. Name of BTS3 VDU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS3 VDU SW is compared with current BTS3 CU SW found in common setup step
                                     # - name of BTS3 VDU SW specified by user: running BTS3 VDU SW is compared with BTS3 VDU SW specified by user
${Target_SW_name_BTS3}      Current  # Only for classical BTS. Name of BTS3 SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS3 SW is compared with current BTS3 SW found in common setup step
                                     # - name of BTS3 SW specified by user: running BTS3 SW is compared with BTS3 SW specified by user
${Target_SW_name_BTS4_CU}   Current  # Only for cloud BTS. Name of BTS4 CU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS4 CU SW is compared with current BTS4 CU SW found in common setup step
                                     # - name of BTS4 CU SW specified by user: running BTS4 CU SW is compared with BTS4 CU SW specified by user
${Target_SW_name_BTS4_VDU}  Current  # Only for cloud BTS. Name of BTS4 VDU SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS4 VDU SW is compared with current BTS4 CU SW found in common setup step
                                     # - name of BTS4 VDU SW specified by user: running BTS4 VDU SW is compared with BTS4 VDU SW specified by user
${Target_SW_name_BTS4}      Current  # Only for classical BTS. Name of BTS4 SW build to be checked. Possible values (by default Current):
                                     # - Current: running BTS4 SW is compared with current BTS4 SW found in common setup step
                                     # - name of BTS4 SW specified by user: running BTS4 SW is compared with BTS4 SW specified by user

*** Keywords ***
TC__CBTS_SBTS__LOGS__Stability
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27538
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case which implements a wait period during which, a periodic check of every BTS is done
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27538 - [CBTS] New test case for CBTS_SBTS Logs Stability
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27890 - [CBTS] Add ${tech_preset_list} in TC Setup for CBTS_SBTS tests
    ...

    Set Tags    CA-LOGS    OWNER-liana.ferescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    FOR  ${INDEX}  IN RANGE  1  10000
        Log  =========================================================  console=True
        Log  Start BTS stability check cycle: ${INDEX}  console=True
        Log  =========================================================  console=True
        Step 1: Check all BTS states
        Step 2: Check all BTS alarms
        Step 3: Check all BTS SW version
        Step 4: Check final number and state of Cells and RMs
        Check stability period info
        Exit For Loop If  ${STABILITY_PERIOD_elapsed}
    END

TC Preconditions

    Run Keyword If  ${STABILITY_PERIOD} < ${CHECK_INTERVAL}  Run Keywords
    ...  Log  Please select test argument \${STABILITY_PERIOD} value (minutes) greater than \${CHECK_INTERVAL} (minutes) or let default values
    ...  console=True
    ...  AND  Fail  Improper value for argument! console=True

    Get Current Time  start
    ${STABILITY_PERIOD_sec}=  Evaluate  ${STABILITY_PERIOD} * 60
    ${CHECK_INTERVAL_sec}=  Evaluate  ${CHECK_INTERVAL} * 60
    Set Test Variable  ${STABILITY_PERIOD_sec}
    Set Test Variable  ${CHECK_INTERVAL_sec}
    Set Test Variable  ${STABILITY_PERIOD_elapsed}  ${False}

    Log  =========================================================  console=True
    Log  Stability period for BTS check: ${STABILITY_PERIOD} minutes  console=True
    Log  BTS check interval: ${CHECK_INTERVAL} minutes  console=True
    Log  =========================================================  console=True

Step ${index}: Check all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  '${alias}' == 'Slave'  BTS2  '${alias}' == 'Slave1'  BTS3
        ...  '${alias}' == 'Slave2'  BTS4
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check cloud ${BTS} state *****  console=True
        ...  AND  Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
        ...  AND  Log  ${BTS} site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check classical ${BTS} state *****  console=True
        ...  AND  Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        ...  AND  Log  ${BTS} site - Procedural State: OnAir, Blocking State: Unblocked  console=True

    END

Step ${index}: Check all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  '${alias}' == 'Slave'  BTS2  '${alias}' == 'Slave1'  BTS3
        ...  '${alias}' == 'Slave2'  BTS4
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check cloud ${BTS} alarms *****  console=True
        ...  AND  Get and Check Alarms CBTS  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check classical ${BTS} alarms *****  console=True
        ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check all BTS SW version
    [Documentation]
    ...  BTS running SW is compared with BTS current SW get in common setup or based on user info.

    Log  Step ${index}: Check all BTS SW version  console=True

    Run Keyword If  '${CHECK_SW_VERSION_CBTS.capitalize()}' != 'True' and '${CHECK_SW_VERSION_SBTS.capitalize()}' != 'True'  Run Keywords
    ...  Log  Checking SW version on all BTS skipped!  console=True
    ...  AND  Return From Keyword
    ...  ELSE IF  '${CHECK_SW_VERSION_CBTS.capitalize()}' != 'True'
    ...  Log  Checking SW version on cloud BTS skipped!  console=True
    ...  ELSE IF  '${CHECK_SW_VERSION_SBTS.capitalize()}' != 'True'
    ...  Log  Checking SW version on clasical BTS skipped!  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${CHECK_SW_VERSION_CBTS.capitalize()}' == 'True' and '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Check cloud BTS running SW  ${alias}
        ...  ELSE IF  '${CHECK_SW_VERSION_SBTS.capitalize()}' == 'True' and '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Check classical BTS running SW  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check cloud BTS running SW
    [Documentation]
    ...  Check if running SW versions on cloud BTS CU and VDU are aligned with expected versions.
    ...
    [Arguments]  ${alias}

    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  '${alias}' == 'Slave'  BTS2  '${alias}' == 'Slave1'  BTS3  '${alias}' == 'Slave2'  BTS4
    Log  ***** Check cloud ${BTS} SW version *****  console=True

    ${Target_SW_CU}=  Set Variable If  '${Target_SW_name_${BTS}_CU}' == 'Current'  ${${alias}_CU_SW_version_initial}  ${Target_SW_name_${BTS}_CU}
    Log  Expected running ${BTS} CU SW: ${Target_SW_CU}  console=True

    ${cu_alias}=  Set Variable  ${alias} CU
    ${CU_SW_active}=  CU Get SW Version  connection=${cu_alias}
    Log  Active running ${BTS} CU SW: ${CU_SW_active}  console=True

    ${CU_SW_status}=  Run Keyword And Return Status  Should Match Regexp  ${Target_SW_CU}  (?i).*${CU_SW_active}.*
    Run Keyword If  ${CU_SW_status}
    ...  Log  ${BTS} CU SW: ${Target_SW_CU} is running on cloud BTS CU, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${BTS} CU SW: ${Target_SW_CU} is not running on cloud BTS CU!  level=ERROR
    ...  AND  Fail  Target SW CU is not running on cloud BTS CU!

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${Target_SW_VDU}=  Set Variable If  '${Target_SW_name_${BTS}_VDU}' == 'Current'  ${${alias}_VDU${index+1}_SW_version_initial}
        ...  ${Target_SW_name_${BTS}_VDU}
        Log  Expected running ${BTS} VDU SW: ${Target_SW_CU}  console=True

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${VDU_SW_active}=  VDU Get SW Version  vdu_connection=${vdu_alias}
        Log  Active running ${BTS} VDU SW: ${VDU_SW_active}  console=True

        ${VDU_SW_status}=  Run Keyword And Return Status  Should Match Regexp  ${Target_SW_VDU}  (?i).*${VDU_SW_active}.*
        Run Keyword If  ${VDU_SW_status}
        ...  Log  ${BTS} VDU${index+1} SW: ${Target_SW_VDU} is running on cloud BTS VDU${index+1}, as expected!  console=True
        ...  ELSE  Run Keywords
        ...  Log  ${BTS} VDU${index+1} SW: ${Target_SW_VDU} is not running on cloud BTS VDU${index+1}!  level=ERROR
        ...  AND  Fail  Target SW VDU is not running on cloud BTS VDU${index+1}!

    END

Check classical BTS running SW
    [Documentation]
    ...  Check if running SW version on classical BTS is aligned with expected version.
    ...
    [Arguments]  ${alias}

    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  '${alias}' == 'Slave'  BTS2  '${alias}' == 'Slave1'  BTS3  '${alias}' == 'Slave2'  BTS4
    Log  ***** Check classical ${BTS} SW version *****  console=True

    ${Target_SW}=  Set Variable If  '${Target_SW_name_${BTS}}' == 'Current'  ${${alias}_active_SW_version_initial}  ${Target_SW_name_${BTS}}
    Log  Expected running ${BTS} SW: ${Target_SW}  console=True

    ${BTS_SW_info}=  coam.Get Software Info  connection=${alias}
    ${BTS_SW_active}=  Get From Dictionary  ${BTS_SW_info}  Active SW version
    Log  Active running ${BTS} SW: ${BTS_SW_active}  console=True

    ${BTS_SW_status}=  Run Keyword And Return Status  Should Match Regexp  ${Target_SW}  (?i).*${BTS_SW_active}.*
    Run Keyword If  ${BTS_SW_status}
    ...  Log  ${BTS} SW: ${Target_SW} is running on classical BTS, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${BTS} SW: ${Target_SW} is not running on classical BTS!  level=ERROR
    ...  AND  Fail  Target SW is not running on classical BTS!

Check stability period info
    Get Current Time  end
    ${STABILITY_PERIOD_elapsed_sec}=  DateTime.Subtract Date From Date  ${time_end}  ${time_start}  number
    Run Keyword If  ${STABILITY_PERIOD_elapsed_sec} > ${STABILITY_PERIOD_sec}  Run Keywords
    ...  Set Test Variable  ${STABILITY_PERIOD_elapsed}  ${True}
    ...  AND  Return From Keyword
    ${STABILITY_PERIOD_remained_sec}=  Evaluate  ${STABILITY_PERIOD_sec} - ${STABILITY_PERIOD_elapsed_sec}
    Log  Remained stability period check: ${STABILITY_PERIOD_remained_sec} seconds  console=True
    Log  Wait for ${CHECK_INTERVAL_sec} seconds till next check  console=True
    Sleep  ${CHECK_INTERVAL} minutes

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
