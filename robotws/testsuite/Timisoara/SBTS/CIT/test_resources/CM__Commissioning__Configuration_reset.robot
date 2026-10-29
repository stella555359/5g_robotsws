*** Settings ***
Documentation
    ...  This TC performs BTS Configuration Reset. It is destined for single core configurations.
    ...  While it will work for dual core, verification part in unsufficient and shall be enhanced in the near future.
    ...  With that enhancement domain reset and IP set reset will be checked, as well as proceduralState for a second SMOD.
    ...  TC shall not proceed if BTS is already NotCommissioned at the beginning (TC will be blocked).
    ...  TC shall pass when configuration reset is performed and BTS becomes NotCommissioned.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${REPAIR_CENTER_RESET}  False  # If it's True, configuration reset is performed on both partitions. Default on False.
${CONFIGURATION_RESET_TIMEOUT}  500  # Timeout for Configuration Reset execution - for removing commissioning, reset, status returning
${RM_DETECTION_TIMEOUT}  10 min  # Timeout for all connected RMs detection (in minutes)
${SMOD2_CHECK_TIMEOUT}  5 min  # Timeout for checking SMOD2 in Admin
${REMOVE_OPERATOR_CERTIFICATES}  True  # If it's true, operator certificates will be removed
${REMOVE_USER_ACCOUNT_CREDENTIALS}  True  # If it's true, user credentials will be removed


*** Keywords ***
TC__CM__Commissioning__Configuration_reset
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  10.10.2017 - initial creation
    ...  02.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071 - add verify BTS proceduralState in Common Test Setup, delete Extended setup
    ...  08.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9111 - New parameter added to choose which way configutation reset perform
    ...  16.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9674 - In step 2 wait untill bts proceduralState==NotCommissioned (timeout 1 min)
    ...  14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14473 - Corrected RMs detected prcedure
    ...  14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15092 - Corrected SMOD2 dectection/synchronization procedure
    ...  29.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15562 - Add input parametr ${SMOD2_CHECK_TIMEOUT}
    ...  16.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19392 - skip wait for all rmod
    ...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25580 - Configuration reset KW changed for CB007500
    ...  10.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25745 - Variables added to the test
    ...  26.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-29810 - Add timeout and admin reconnection

    Set Tags  CA-SWM  PHASE-CIT  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  OWNER-michal.adamus@nokia.com
    ...  AUTHOR-jaroslaw.piszczala@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  FEATURE-OM_GEN_SFS_RNWINT.4825  FEATURE-LTE_OPR_REQ_5443

    Step1: Perform Configuration Reset
    Step2: Verify BTS State


Step1: Perform Configuration Reset
    Log  ${\n} Step1: Perform configuration reset  console=true
    rfrl_rc.Reset Bts Configuration  remove_operator_certificates=${REMOVE_OPERATOR_CERTIFICATES}
    ...  remove_user_account_credentials=${REMOVE_USER_ACCOUNT_CREDENTIALS}  repair_center_reset=${REPAIR_CENTER_RESET}
    ...  timeout=${CONFIGURATION_RESET_TIMEOUT}  wait_for_admin_connection_timeout=${CONFIGURATION_RESET_TIMEOUT}  reset_admin_connection=True
    Log  Configuration reset has passed.  console=true


Step2: Verify BTS State
    Log  ${\n} Step2: Verify BTS state  console=true
    Reset Admin And Infomodel Connection If Broken TAF  allowed_to_set_restriction=${FALSE}
    Log  Will now check active alarms presence  console=true
    ${alarm_reading_status}  Run Keyword And Return Status  Admin Check Active Alarms TAF
    IF  ${alarm_reading_status}
        Log  Active alarm reading is possible!  console=true
    ELSE
        Set Test Restriction  Active alarm reading was not possible!
    END
    Log  Will now verify that proceduralState of the BTS equals NotCommissioned  console=true
    Wait Until Keyword Succeeds  1 min  20 sec  Check If BTS ProceduralState Is NotCommissioned
    Log  Will now verify that SMODs properly detected  console=true
    IF  ${SMOD2_EXISTS}  Wait Until Keyword Succeeds  ${SMOD2_CHECK_TIMEOUT}  30 sec  Check SMOD2 In Admin  block_test_on_fiasco=${FALSE}
    Log  Will now verify that all expected RMODs detected  console=true
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20 sec  Check If All RMs Detected


Check If BTS ProceduralState Is NotCommissioned
    ${bts_state}  Get Mrbts State  timeout=600
    Log  BTS proceduralState is: ${bts_state}  console=true
    Should Match Regexp  ${bts_state}  (?i)NotCommissioned


TC Setup
    Common Test Setup  modules_check=${False}  cells_check=${False}  alarms_check=${True}  expected_bts_status=^(?!.*NotCommissioned).*
    ...  tc_name=CM__Commissioning__Configuration_reset


TC Teardown
    Common Test Teardown
