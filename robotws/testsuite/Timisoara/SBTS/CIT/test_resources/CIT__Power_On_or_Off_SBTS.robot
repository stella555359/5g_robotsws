*** Settings ***
Documentation
    ...  This TC is created to perform power on or power off.
    ...  Power on/off is performed on every units.
    ...  Check ping to be reacheable/ to not be reacheable.
    ...  In case of power on, SBTS must be onAir.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${POWER_OPERATION}  On  # Power operation. Can be: On or Off
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to be recovered
${ADMIN_STARTED_STATUS}  ${False}


*** Keywords ***
TC__CIT__Power_On_or_Off_SBTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23592
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23592 - Initial TAT
    ...  29.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23603 - Additional check for alarms in case of power on

    Set Tags  CA-CIT  OWNER-bogdan.boldurean@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  PHASE-CIT

    Step1: Power ${POWER_OPERATION} SBTS
    Step2: Check SBTS


Step1: Power ${power_operation} SBTS
    Log  Step1: Power ${power_operation} SBTS  console=True
    FOR  ${unit}  IN  @{INTERFACES}
        Run Keyword If  '${power_operation}'=='On'
        ...  Pdu BTS Interface On  ${unit}
        ...  ELSE
        ...  Pdu BTS Interface Off  ${unit}
        Log  Interface ${unit} turned ${power_operation}  console=True
        Sleep  10s
    END


Step2: Check SBTS
    Log  Step2: Check SBTS  console=true
    Run Keyword If  '${POWER_OPERATION}'=='On'
    ...  Run Keywords
    ...  Check Ping Status To Be Reachable
    ...  AND
    ...  Check SBTS To Be OnAir And Verify Active Alarms
    ...  ELSE
    ...  Check Ping Status To Be Not Reachable


Check Ping Status To Be Not Reachable
    Log  Check Ping Status to be not reachable  console=true
    ${ping_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    Run Keyword If  ${ping_status}
    ...  Log  BTS loose ping, power off was perfomed![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  BTS didn't loose ping, power off not perfomed![NOK]


Check Ping Status To Be Reachable
    Log  Check Ping Status to be reachable  console=true
    ${ping_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${RECOVERY_TIMEOUT}
    Run Keyword If  ${ping_status}==${False}
    ...  Fail  Ping has not been regained within timeout


Check SBTS To Be OnAir And Verify Active Alarms
    Log  Check SBTS to be onAir and verify active alarms  console=true
    ${admin_started_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  20
    ...  Start Admin  bts_host=${SMOD1['TRS_IP']}
    Set Test Variable  ${ADMIN_STARTED_STATUS}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Run Keyword If  ${status}
    ...  Log  All cells and modules are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells or modules are onAir![NOK]
    Log  Verify active alarms!  console=true
    ${list_of_active_alarms}  Admin Check Active Alarms TAF
    ${length}  Get Length  ${list_of_active_alarms}
    Run Keyword If  ${length}>0
    ...  Fail  Unexpected alarms exist: ${list_of_active_alarms}


Recovery Action
    Log  Reset Site will be performed as a recovery action!  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  admin_launch=${FALSE}  infomodel_launch=${FALSE}


TC Teardown
    Run Keyword If  ${ADMIN_STARTED_STATUS}
    ...  Run Keywords
    ...  Run Keyword If Test Failed
    ...  CIT__Power_On_or_Off_SBTS.Recovery Action
    ...  AND
    ...  Common Test Teardown
