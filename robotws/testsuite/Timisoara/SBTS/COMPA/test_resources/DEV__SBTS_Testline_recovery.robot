*** Settings ***
Documentation
    ...  Test case mentioned for recovery action. When PDU is properly defined inside interfaces.yaml, then power reset
    ...  procedure is launched (each PDU socket is turned off and on). If PDU type is not defined properly then
    ...  ADMIN site reset procedure is performed. Afterwards basic check of modules and cells is launched.
    ...
    ...  If default timeout is too short for your configuration please add RECOVERY_TIMEOUT_OVERRIDE
    ...  parameter to env_config_1.yaml file of your station in global parameters section
    ...  e.g. "RECOVERY_TIMEOUT_OVERRIDE:  30 min"

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${ONAIR_TIMEOUT}  15 minutes  # Timeout for BTS to reach onAir after power on


*** Keywords ***
TC__DEV__SBTS_Testline_recovery
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5479
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6043 - change TC name
    ...  - 07.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6968 - Power off/on does not need connection to BTS
    ...  - 08.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7386 - Change log in step2
    ...  - 08.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7380 - Create Test case flowchart
    ...  - 12.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9081 - Added support for RECOVERY_TIMEOUT_OVERRIDE parameter
    ...  - 25.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14867 - Added site reset as workaround
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23766 - Library setup
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7380_DEV__SBTS_Testline_recovery.png#
    ...

    Set Tags  CA-STATE  OWNER-tomasz.1.filipek@nokia.com  AUTHOR-tomasz.1.filipek@nokia.com  MAINTAINTER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18

    ${pdus_status}  Check if all modules in interfaces.Yaml Have Proper PDU Defined
    Set Test Variable  ${PDUS_STATUS}
    Run Keyword If  ${PDUS_STATUS}
    ...  Power Reset Procedure
    ...  ELSE
    ...  Site Reset Procedure
    Step 3: Check If All Modules And Cells Are Working


Check If All Modules In Interfaces.Yaml Have Proper PDU Defined
    Log  Check if all modules in interfaces.yaml have proper PDU defined  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        ${pdu_status}  Run Keyword And Return Status
        ...  Pdu Get Type  ${distname}
        Return From Keyword If  ${pdu_status} == ${False}  ${False}
    END

    [Return]  ${True}


Power Reset Procedure
    Log  Power reset procedure  console=true
    Step 1: Power Off BTS
    Step 2: Power On BTS


Site Reset Procedure
    Log  Step 2: ADMIN Site reset procedure  console=true
    Start Admin
    coam.Reset Site  600


Step 1: Power Off BTS
    Log  Step1: Power off BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface Off  ${distname}
        Log  Interface ${distname} turned off  console=true
        Sleep  1
    END


Step 2: Power On BTS
    Log  Step2: Power on BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface On  ${distname}
        Log  Interface ${distname} turned on  console=true
        Sleep  1
    END


Step 3: Check If All Modules And Cells Are Working
    Log  Step 3: Check if all modules and cells are working  console=true
    Sleep  500s
    Run Keyword If  ${PDUS_STATUS}
    ...  Start Admin
    ${onair_timeout}  Get Variable Value  ${RECOVERY_TIMEOUT_OVERRIDE}  ${ONAIR_TIMEOUT}
    Log  Check BTS and Cells states after reset wait until states will be correct for ${onair_timeout}  console=true
    Wait Until Keyword Succeeds  ${onair_timeout}  30 seconds
    ...  Check BTS And Cells States after Reset


Check BTS And Cells States ${when} Reset
    Log  Checking states all cells and modules ${when} reset  console=true
    Admin Check SBTS cells, modules and alarms TAF


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  admin_launch=${FALSE}  infomodel_launch=${FALSE}
    ...  tc_name=DEV__SBTS_Testline_recovery


TC Teardown
    Common Test Teardown
