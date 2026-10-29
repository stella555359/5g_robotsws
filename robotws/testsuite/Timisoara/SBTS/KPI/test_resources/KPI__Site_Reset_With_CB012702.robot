*** Settings ***
Documentation
    ...  1. The tester creates the "hpd_debug_config.txt" file in /ffs/run/config/ and signs it.
    ...  It contains a mask value of the FSP slots for which only EVT_DETECT will be reported.
    ...  2. The tester will trigger a site reset.
    ...  3. On the next startup, LFS hpd on the FCT will read the "hpd_debug_config.txt" file at startup and store all FSPs for which only
    ...  EVT_DETECT will be reported.
    ...  4.  FID 10 appears on faulty BBMOD with operational state: disabled, for RMOD which are mapped on BBMOD faulty,
    ...  FID 10 rise with operational state: disabled and cells remain with disabled/failed state.
    ...  5.  After the test is done, the tester removes the "hpd_debug_config.txt" file in /ffs/run/config/
    ...  and triggers a site reset so LFS hpd returns to nominal behavior.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${BBMOD_SERIAL_NUMBER}  ${EMPTY}  # Mandatory, serial number for BBMOD must be given
${ALARM_TIMEOUT}  600  # Timeout for alarms to appear.
${RESET_TIMEOUT}  900  # Timeout in seconds for SBTS to recover to operational state after site reset


*** Keywords ***
TC__KPI__Site_Reset_With_CB012702
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28864
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  12.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28864 - Test creation
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-iulian_catalin.lazar@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB012702

    Step0: TC Preconditions
    Step1: Trigger FSP
    Step2: Perform Site Reset
    Step3: Check Alarm And All Affected Required State
    Step4: Calculate Kpi1a Duration
    Step5: Remove File And Perform Site Reset
    Step6: Check If SBTS Status Is Onair


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true
    ${bbmods}    coam.Get Managed Objects  BBMOD_R
    ${bbmod_obj}    Set Variable    ${None}
    FOR  ${bbmod}  IN  @{bbmods}
        IF  '${bbmod}[parameters][serialNumber]'=='${BBMOD_SERIAL_NUMBER}'
            ${bbmod_obj}  Set Variable  ${bbmod}
            Log  Serial number for BBMOD is correct!  console=true
            BREAK
        ELSE
            CONTINUE
        END
        Fail  Serial number for BBMOD is wrong! Please provide another one!
    END
    Set Test Variable  ${BBMOD_OBJ}  ${bbmod_obj}
    ${vertical_position}  Evaluate  ${BBMOD_OBJ}[parameters][verticalPosition]-2
    ${horizontal_position}  Set Variable  ${BBMOD_OBJ}[parameters][horizontalPosition]
    ${slot0}  Create List  0x02  0x04  0x08
    ${slot4}  Create List  0x20  0x40  0x80
    ${HPD_DETECT_ONLY_MASK}  Set Variable If  ${horizontal_position}==1  ${slot0}[${vertical_position}]  ${slot4}[${vertical_position}]
    Set Test Variable  ${HPD_DETECT_ONLY_MASK}
    ${AFFECTED_RMOD}  Get Affected RMODs from BBMOD
    Set Test Variable  ${AFFECTED_RMOD}
    ${affected_cells_distnames}  Get Cell Mapping By Module Id  ${BBMOD_OBJ}[distName]
    Set Test Variable  ${AFFECTED_CELLS_DISTNAMES}
    ${unaffected_cells_distnames}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells_distnames}  @{affected_cells_distnames}
    Set Test Variable  ${UNAFFECTED_CELLS_DISTNAMES}


Step1: Trigger FSP
    Log  \nStep1: Trigger FSP  console=true
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt= >
    SSHLibrary.Write  cd /ffs/run/config/
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo "hpd_detect_only_mask=${HPD_DETECT_ONLY_MASK}" > hpd_debug_config.txt
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  crasign hpd_debug_config.txt
    SSHLibrary.Read Until Prompt


Step2: Perform Site Reset
    Log  \nStep2: Perform Site Reset  console=true
    coam.Reset Site  timeout=600


Step3: Check Alarm And All Affected Required State
    Log  \nStep3: Check Alarm And All Affected Required State  console=true
    Check Alarm On BBMOD To Be Active
    Check Alarm On RMODs To Be Active
    Assert  BBMOD  ${BBMOD_OBJ}[distName]  operationalState=${DISABLED}  timeout=${ALARM_TIMEOUT}
    Log  BBMOD:${BBMOD_OBJ}[distName] are disabled.[OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30s
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS_DISTNAMES}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Log  Cells on ${BBMOD_OBJ}[distName] are disabled.[OK]  console=true
    FOR  ${rmod}  IN  @{AFFECTED_RMOD}
        Assert  RMOD  ${rmod}  operationalState=${DISABLED}, availabilityStatus=${NOT_INSTALLED}  timeout=${ALARM_TIMEOUT}
    END
    Log  RMODs on ${BBMOD_OBJ}[distName] are disabled.[OK]  console=true
    Wait Until Keyword Succeeds  ${RESET_TIMEOUT}  60s
    ...  Check Parameters Status For Cells  ${UNAFFECTED_CELLS_DISTNAMES}  operationalState=${ENABLED}


Step4: Calculate Kpi1a Duration
    Log  \nStep4: Calculate Kpi1a Duration  console=true
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    ${kpi1a}  Calculate Kpi1a  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  cell_dist_names=${UNAFFECTED_CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1a}[kpi1a][-1][delta]  kpi1a
    Save Delta Results  kpi1a


Step5: Remove File And Perform Site Reset
    Log  \nStep5: Remove File And Perform Site Reset  console=true
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt= >
    SSHLibrary.Write  cd /ffs/run/config/
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  rm hpd_debug_config.txt hpd_debug_config.txt.p7
    SSHLibrary.Read Until Prompt
    coam.Reset Site  timeout=600


Step6: Check If SBTS Status Is Onair
    Log  \nStep6: Check If SBTS Status Is Onair  console=true
    Wait Until Keyword Succeeds  ${RESET_TIMEOUT}  60  Admin Check All Required State
    Log  SBTS is onAir.  console=true


Get Affected RMODs from BBMOD
    ${cablink_list}  coam.Get Managed Objects  CABLINK_R
    ${rmods}  Create List
    FOR  ${cablink}  IN  @{cablink_list}
        IF  '${cablink}[parameters][firstEndpointDN]'=='${BBMOD_OBJ}[distName]'
            Append To List  ${rmods}  ${cablink}[parameters][secondEndpointDN]
        END
    END

    RETURN  ${rmods}


Check Alarm On BBMOD To Be Active
    ${fault_status_bbmod}  Run Keyword And Return Status  Assert Alarm Active  parameters=severity=Minor, alarmId=7115, faultId=10,
    ...  alarmName="BASE STATION INFORMATION", faultName="No connection to unit", alarmingResource=${BBMOD_OBJ}[distName]  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_bbmod}
        Log  Fault 10 is active on ${BBMOD_OBJ}[distName] [OK]  console=${TRUE}
    ELSE
        Fail  Fault 10 is not active on ${BBMOD_OBJ}[distName] [NOK]
    END


Check Alarm On RMODs To Be Active
    FOR  ${rmod}  IN  @{AFFECTED_RMOD}
        ${check_RMOD_alarm}  Run Keyword And Return Status  Assert Alarm Active  parameters=severity=Critical, alarmId=7116, faultId=10,
        ...  alarmName="BASE STATION SERVICE PROBLEM", faultName="No connection to unit", alarmingResource="${rmod}"  timeout=100
        IF  ${check_RMOD_alarm}
            Log  Fault 10 is active on RMOD:${rmod} [OK]  console=true
        ELSE
            Fail  Fault 10 is not active on RMOD:${rmod} [NOK]
        END
    END


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
