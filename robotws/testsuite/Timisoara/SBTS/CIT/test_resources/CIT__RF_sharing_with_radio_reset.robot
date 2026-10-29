*** Settings ***
Documentation
    ...  In Step1: RF sharing activation
    ...  In Step2: Rmod reset
    ...  In Step3: Sbts is restored

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # Serial number of reseted radio module- must be given
${RESET_TIMEOUT}  600  # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESETTYPE}  Warm  # reset_type (string) for KW Unit Reset Cp – Soft|Hard|Warm, if SW is SBTS17 please use Hard
${BCF_VERIFICATION_TIMEOUT}  5 minutes  # Timeout for verification of BCF states (TRX, sectors, OAM link should have state WO)
${RECOVERY_TIMEOUT}  9 minutes  # Timeout for SBTS to recover
${RF_SHARING_ENABLED_PARAMETER_DISTNAME}  ${EMPTY}  # dist name of rf sharing enabled parameter- must be given


*** Keywords ***
TC__CIT__RF_sharing_with_radio_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25001
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...   16.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25001 - Test creation

    Set Tags  CA-CIT  AUTHOR-iasmin.tomici@nokia.com  OWNER-edwin-marius.macra@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT

    Step1 Activate RF Sharing Parameter
    Step2 Reset Rmod
    Step3 SBTS Is Restored


Step1 Activate RF Sharing Parameter
    ${rmod_check}  _Get Radio Module With Given Serial Number  ${RMOD_SERIAL_NUMBER}
    Log  Step1: Set RF sharing enabled parameter on true  console=true
    Change Parameter RF Sharing Value  true  rfSharingEnabled


Step2 Reset Rmod
    Log  \nStep2 check all required states and radio reset from ADMIN.\n  console=true
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Admin Check All Required State
    ${alarms_msg}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    Run Keyword If  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    Reset Radio Module


Step3 SBTS Is Restored
    Log  \nStep3 check all reqiuired states after reset.\n  console=true
    Sleep  120s  This sleep is for SBTS to recover
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20 sec
    ...  Admin Check All Required State
    ${alarms_msg}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    Run Keyword If  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    Run Keyword And Ignore Error
    ...  Log All Tx Power


Change Parameter RF Sharing Value
    [Documentation]
    ...  This keyword change RF sharing enabled parameter.
    [Arguments]  ${value}  ${parameter_name}

    Log  ${parameter_name} will be changed to ${value}  console=true
    coam.Perform Parameter Recommissioning  ${RF_SHARING_ENABLED_PARAMETER_DISTNAME}  ${parameter_name}  update  ${value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300


Reset Radio Module
    ${rmod}  _Get Radio Module With Given Serial Number  ${RMOD_SERIAL_NUMBER}
    Log  Reset radio with dist name: ${rmod.id}  console=true
    coam.Reset Unit  dist_name=${rmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}


_Get Radio Module With Given Serial Number
    [Arguments]  ${serial_number}

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  '${serial_number}'=='${rmod.serialNumber}'
        ...  Return From Keyword  ${rmod}
    END
    Fail  ${serial_number} is wrong, please set correct RMOD_SERIAL_NUMBER


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
