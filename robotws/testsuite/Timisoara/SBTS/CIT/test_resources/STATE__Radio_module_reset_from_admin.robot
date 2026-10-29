*** Settings ***
Documentation
    ...  Expected radio states before and after reset:
    ...   availabilityStatus=Online,
    ...   blockingState=Unblocked,
    ...   operationalState=Enabled
    ...
    ...  Expected cell states before and after reset:
    ...   availabilityStatus=Online,
    ...   blockingState=Unblocked,
    ...   administrativeState=Unlocked,
    ...   operationalState=Enabled
    ...
    ...  step1:
    ...  Radio reset from ADMIN
    ...  step2:
    ...  SBTS is restored

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # Serial number reseted radio module, if empty reset all radio modules.
${RESET_TIMEOUT}  180  # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESETTYPE}  Warm  # reset_type (string) for KW Unit Reset Cp – Soft|Hard|Warm, if SW is SBTS17 please use Hard
${BCF_VERIFICATION_TIMEOUT}  5 minutes  # Timeout for verification of BCF states (TRX, sectors, OAM link should have state WO)


*** Keywords ***
TC__STATE__Radio_module_reset_from_admin
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6816
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6816 - Initial creation
    ...  - 09.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8279 - Added ute_admin before keyword Reset Unit
    ...           and switch from infomodel to abstraction layer
    ...  - 06.12.2017 - https://jira3.int.net.nokia.com/browse/TAT-8516 - Added sleep 60s after reset.
    ...  - 04.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12424 - accepted alarms due RP001063
    ...  - 13.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13127 - add timeout for radio reset due to problem with radio reset
    ...  - 11.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13611 - increase Sleep to 2 min after reset
    ...  - 25.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15222 - Fixed when ${RMOD_SERIAL_NUMBER} is wrong
    ...  - 29.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15533 - Added needs parametr for KW Unit Reset Cp
    ...  - 01.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15604 - Fixed logic for reset single rmod
    ...  - 10.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15679 - Added input parametr resetType for KW Unit Reset Cp
    ...  - 30.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-12333 - BCF state verification after RMOD reset
    ...  - 07.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16061 - Add open/close connection to BSC
    ...  - 04.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-17807 - Increase default value ${RESET_TIMEOUT}
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6816.png#

    Set Tags  CA-STATE  OWNER-rafal.wisniewski@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step1 Radio Reset From ADMIN
    Step2 SBTS Is Restored


Step1 Radio Reset From ADMIN
    Log  \nStep1 check all required states and radio reset from ADMIN.\n  console=true
    Run Keyword And Ignore Error
    ...  Log All Tx Power

    Admin Check All Required State

    ${alarms_msg}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    Run Keyword If  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    Run Keyword If  '${RMOD_SERIAL_NUMBER}'
    ...  _Reset Radio Module
    ...  ELSE
    ...  _Reset All Radio Modules

    ${gncels}  Get Parameters For All  GNCEL
    Run Keyword If  ${gncels}
    ...  Verify BCF States


Step2 SBTS Is Restored
    Log  \nStep2 check all reqiuired states after reset.\nTimeout 10 min\n  console=true
    Sleep  120s
    Wait Until Keyword Succeeds  9 minutes  20 sec
    ...  Admin Check All Required State
    ${alarms_msg}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    Run Keyword If  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    Run Keyword And Ignore Error
    ...  Log All Tx Power


_Reset All Radio Modules
    ${param}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{param}
        Log  Reset radio with dist name: ${rmod.id}  console=true
        Unit Reset Cp  dist_name=${rmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}
    END


_Reset Radio Module
    ${rmod}  _Get Radio Module With Given Serial Number  ${RMOD_SERIAL_NUMBER}
    Log  Reset radio with dist name: ${rmod.id}  console=true
    Unit Reset Cp  dist_name=${rmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}


_Get Radio Module With Given Serial Number
    [Arguments]  ${serial_number}

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  '${serial_number}'=='${rmod.serialNumber}'
        ...  Return From Keyword  ${rmod}
    END
    Set Test Failed  ${serial_number} is wrong, please set correct RMOD_SERIAL_NUMBER  fail_fast=${True}


Verify BCF States
    Log  Verifying BCF state (TRXs, sectors, OAM link)  console=true
    ${bcf_id}  Infomodel Get BCF ID
    hran_bsc.Bsc SSH Connection  ${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    Wait Until Keyword Succeeds  ${BCF_VERIFICATION_TIMEOUT}  20 sec
    ...  _BCF States Checker  ${bcf_id}

    [Teardown]  hran_bsc.Close All Connections


_BCF States Checker
    [Arguments]  ${bcf_id}

    ${sectors_state}  hran_bsc.Get Sectors State  ${bcf_id}  operational
    ${sectors_state}  Evaluate  all([state[1]=='WO' for state in ${sectors_state}])

    ${trxs_state}  hran_bsc.Get TRXs State  ${bcf_id}  operational
    ${trxs_state}  Evaluate  all([state[1]=='WO' for state in ${trxs_state}])

    ${om_link_state}  hran_bsc.Get OM Link State  ${bcf_id}
    ${om_link_state}  Evaluate  '${om_link_state}'=='WO'

    Should Be True  ${sectors_state} and ${trxs_state} and ${om_link_state}


TC Setup
    Common Test Setup  alarms_check=${False}


TC Teardown
    Common Test Teardown
