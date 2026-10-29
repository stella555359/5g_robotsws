*** Settings ***
Resource    ../../common_resources/ca_CIT_general.robot

*** Variables ***
${REPAIR_CENTER_RESET}              False       #If it's True, configuration reset is performed on both partitions. Default on False.
${Configuration Reset Timeout}      500         #Timeout for Configuration Reset execution - for removing commissioning, reset, status returning
${RM_DETECTION_TIMEOUT}             10 min      #Timeout for all connected RMs detection (in minutes)
${SMOD2_CHECK_TIMEOUT}              5 min       #Timeout for checking SMOD2 in Admin
${BBMOD_SERIAL_NUMBER}                          # Serial number of reseted bbmod- must be given
${RESET_TIMEOUT}                    600         # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESETTYPE}                        Warm        # reset_type (string) for KW Unit Reset Cp – Soft|Hard|Warm, if SW is SBTS17 please use Hard
${SCF_FILE}
${RECOVERY_TIMEOUT}                 800         # timeout in seconds for waiting until cells reach expected states

*** Keywords ***
TC__CIT__BBMOD_reset_during_cell_establishing
    [Documentation]
    ...  ********************
    ...  Basic information
    ...  ********************
    ...  The SBTS is uncomissioned, and it will be performed a commissioning with prepared SCF
    ...  and also it will be performed BBMOD reset before cells reach 'onAir' state.
    ...
    ...
    ...  *********************
    ...  History of changes
    ...  *********************
    ...
    ...  - 26.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25002 - Test creation

    Set Tags    CA-CIT    AUTHOR-iasmin.tomici@nokia.com    OWNER-edwin-marius.macra@nokia.com
    ...    MAINTAINER-iasmin.tomici@nokia.com    GROUP_IN_CHARGE-TIM_2_Vrf    PHASE-CIT

    step1: Perform configuration reset
    step2: Verify BTS state
    step3: Recommision with BBMOD reset during cell establishing

step1: Perform configuration reset
    Log  ${\n} Step1: Perform configuration reset  console=${True}
    rc.Reset Bts Configuration  remove_operator_certificates=True
    ...                         remove_user_account_credentials=True
    ...                         repair_center_reset=${REPAIR_CENTER_RESET}
    ...                         timeout=${Configuration Reset Timeout}
    Log  Configuration reset has passed.  console=${True}

step2: Verify BTS state
    Log  ${\n} Step2: Verify BTS state  console=${True}
    Reset admin and infomodel connection if broken TAF   allowed_to_set_restriction=${FALSE}
    Log  Will now check active alarms presence  console=${True}
    ${alarm_reading_status}  Run keyword and return status  Admin Check Active Alarms TAF
    Run Keyword Unless    ${alarm_reading_status}    Set Test Restriction    Active alarm reading was not possible!
    Log  Will now verify that proceduralState of the BTS equals NotCommissioned  console=${True}
    Wait Until Keyword Succeeds  1 min  20 sec  Check if BTS proceduralState is NotCommissioned
    Log  Will now verify that SMODs properly detected  console=${True}
    Run keyword if    ${SMOD2_exists}    Wait until keyword succeeds
    ...  ${SMOD2_CHECK_TIMEOUT}  30 sec    Check SMOD2 in Admin   block_test_on_fiasco=${FALSE}
    Log  Will now verify that all expected RMODs detected  console=${True}
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20 sec  Check if all RMs detected

step3: Recommision with BBMOD reset during cell establishing
    Log  ${\n} Step3: Recommision with BBMOD reset during cell establishing  console=${True}
    ${BTS_ID}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${cell_class_list}  Create list
    ${cell_types_dict}  Create dictionary  LTE=LNCEL  NR=NRCEL  WCDMA=WNCEL  GSM=GNCEL
    FOR  ${rat}  IN  @{cell_types_dict}
        Run keyword if  ${SCF_COUNT_${rat}}
        ...  Append to list  ${cell_class_list}  ${cell_types_dict}[${rat}]
    END
    coam.Perform commissioning  ${BTS_ID}  ${SCF_FILE}  skip_parameter_relation_errors=True
    FOR  ${cell_class}  IN  @{cell_class_list}
        ${status}  Run keyword and return status  Wait until keyword succeeds  500  5  coam.Assert Any  ${cell_class}  availabilityStatus=${Failed_}
        Run keyword if  ${status}
        ...  Run keywords
        ...  Reset BBMOD
        ...  AND
        ...  Exit for loop
    END
    Verify all cells are onair

Check if BTS proceduralState is NotCommissioned
    ${BTS state}  Get Mrbts State  timeout=600
    Log  BTS proceduralState is: ${BTS state}  console=${True}
    Should Match Regexp  ${BTS state}  (?i)NotCommissioned

Reset BBMOD
    ${bbmod}=  Get BBMOD with given serial number  ${BBMOD_SERIAL_NUMBER}
    Log  Reset bbmod with dist name: ${bbmod.id}  console=yes
    coam.Reset Unit    dist_name=${bbmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}

Get BBMOD with given serial number
    [Arguments]  ${serial_number}
    ${bbmods}=    Get Parameters For All    BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        Run Keyword If    '${serial_number}'=='${bbmod.serialNumber}'  Return from keyword  ${bbmod}
    END
    Fail  ${serial_number} is wrong, please set correct BBMOD_SERIAL_NUMBER

Verify all cells are onair
    Log  Check cells states after commissioning  console=${TRUE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
