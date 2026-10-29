*** Settings ***
Documentation         Suite description
...    Author:        anna.maciejewska@nokia.com
...    Maintainer:    anna.maciejewska@nokia.com

Resource    ../../../Resources/Setup/setup_and_teardown.robot




Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

${SKIP_TRUCK_ROLL}=    ${TRUE}
${CHECK_SWCONFIG}=     ${FALSE}


*** Test Cases ***

[1]Pronto reproduction
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=live
    ...  AND  Set Test Variable  ${TIMEOUT}    360000    #Timeout for waiting for fault 10, value in seconds
    ...  AND  Set Test Variable  ${RMOD_SN}    F7164310616    # rmod serial number, which will be monitored
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}    400   #timeout for site reset operation
    ...  AND  Set Test Variable  ${Step1}    True     # if You want to skip this step, set this variable to False
    ...  AND  Set Test Variable  ${Step2}    True    # if You want to skip this step, set this variable to False
    ...  AND  Set Test Variable  ${Step3}    True    # if You want to skip this step, set this variable to False
    ...  AND  Set Test Variable  ${Step4}    True    # if You want to skip this step, set this variable to False
    Pronto Reproduction
    [Teardown]  Configuration Postcondition

*** Keywords ***
Pronto Reproduction
    Set Tags    AUTHOR-anna.maciejewska@nokia.com  MAINTAINER-anna.maciejewska@nokia.com
    Common Test Setup    tools_to_setup=ADMIN
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Run keyword If  ${Step1}  Step1 Set flags on radiomodule, reboot rmod and wait for OnAir
    Run keyword If  ${Step2}  Step2 Sleep 8 minutes and perform snapshot
    Run keyword If  ${Step3}  Step3 Wait for fault 10, perform site reset and gather snapshot
    Run keyword If  ${Step4}  Step4 Remove flags and reboot rmod
    [Teardown]  Run Keywords  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Step4 Remove flags and reboot rmod  AND
    ...  Common Test Teardown


Step1 Set flags on radiomodule, reboot rmod and wait for OnAir
   Logging With Timestamp
    ...  message=Step1 Set flags on radiomodule
    ...  style=STEP
    ...  frame=True
    &{flags1}  Create dictionary    0x120=0x1  0x10045=0x1000000
    Set RD Flags On RMOD   ${RMOD_SN}  ${flags1}
    admin.Add Allowed Alarm  faultId=10  connection=${BTS_ID}
    STATE Verify BTS states
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}


Step2 Sleep 8 minutes and perform snapshot
   Logging With Timestamp
    ...  message=Step2 Sleep 8 minutes and perform snapshot
    ...  style=STEP
    ...  frame=True
    Logging With Timestamp
    ...  message=Sleep 8 minutes...
    Sleep  480s
    Logging Session Save Snapshot    ${CFG.test_logs_path}/TestFiles/first_snapshot  ${BTS_ID}


Step3 Wait for fault 10, perform site reset and gather snapshot
   Logging With Timestamp
    ...  message=Step3 Wait for fault 10 perform site reset and gather snapshot
    ...  style=STEP
    ...  frame=True
   Logging With Timestamp
    ...  message=Waiting for fault 10 appearance.
    ${status}    Run Keyword And Return Status    admin.Assert Alarm Active  faultId=10  severity=Critical  timeout=${TIMEOUT}  connection=${BTS_ID}
    IF  ${status}
      Logging With Timestamp
      ...  message=Fault 10 appeared. Perform Site Reset
      admin.Reset Site
      ...  connection=${BTS_ID}
      ...  wait_for_reconnection=True
      ...  detailed_output=True
      ...  graceful_cell_shutdown=True
      ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

      CM BTS Admin Not Available
      ...  node=${BTS_ID}
      ...  timeout=120

      Logging With Timestamp
      ...  message=Site Reset is done. BTS states verification.

      STATE Verify BTS states
      ...  node_id=${BTS_ID}
      ...  expected_BTS_status=OnAir
      ...  HW_check=${TRUE}
      ...  cells_check=${TRUE}
      ...  scf_check=${FALSE}
      ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

      Logging Session Save Snapshot    ${CFG.test_logs_path}/TestFiles/second_snapshot  ${BTS_ID}
      Fail   Fault 10 appeared. Site reset done. Snapshot gathered.
    ELSE
      Logging With Timestamp
      ...  message=Fault 10 didn't occur within tiemout ${TIMEOUT}
    END


Step4 Remove flags and reboot rmod
   Logging With Timestamp
    ...  message=Step4 Remove flags and reboot rmod
    ...  style=STEP
    ...  frame=True
    radio.Open Connection To Radio Module    ${RMOD_SN}
    radio.Send Command  flash -r RADP
    Sleep    3s
    radio.Send Command  Mcu -r 1 6
    Sleep    10s
    radio.Close Ssh Connection
    Sleep    5s
    Log To Console  ${\n}RMOD is rebooting now !${\n}
    admin.Add Allowed Alarm  faultId=10  connection=${BTS_ID}
    STATE Verify BTS states
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}



Set RD Flags On RMOD
    [Arguments]  ${rmod_sn}  ${flags}
    [Documentation]
    ...  KW sets desired flags to RMOD using rad -mpw command
    ...  After that RMOD reboot is preformed.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Log to console  Opening connection to RU with SN ${rmod_sn}!${\n}
    radio.Open Connection To Radio Module    ${rmod_sn}

    FOR  ${flag}  ${value}  IN ZIP  ${flags.keys()}  ${flags.values()}
        radio.Send Command  rad -pw ${flag} ${value}
        ${output8}  radio.Read Output
        ${domain}   Set variable If  '${flag}'=='0x120'  0  1
        ${output}  radio.Read Until Regexp    written succesfully for domain ${domain}
        Log To Console  ${output}
    END

    radio.Send Command  Mcu -r 1 6
    Sleep    10s
    radio.Close Ssh Connection
    Sleep    5s
    Log To Console  ${\n}RMOD is rebooting now !${\n}



