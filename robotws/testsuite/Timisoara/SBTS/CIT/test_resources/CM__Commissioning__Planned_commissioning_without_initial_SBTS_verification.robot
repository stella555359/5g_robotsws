*** Settings ***
Documentation
    ...  Is the same test as CM__Commissioning__Planned_commissioning.robot but without initial SBTS verification
    ...  TC for SBTS commissioning from given SCF file via ADMIN API.
    ...  Additionally when parameter IPSEC_INSTALL is set to TRUE then IPSec certificate installation will be performed
    ...  after commissioning. Certificates should be stored inside /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates
    ...  directory. Only .p12 and .pem certs are supported.
    ...  User can also decide to check only alarms after commissioning procedure. To enable this, please set variable
    ...  ${POST_CHECK_ONLY_ALARMS} to ${TRUE}. User can also choose which alarms should be ignored by passing the alarms
    ...  keywords to ${POST_ALARMS_IGNORED_PATTERN} (i.e faultId=49, severity=Major would ignore all alarms which contains
    ...  these fields)

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${COMMISSIONING_PATH}  ${EMPTY}  # Absolute path to commissioning file
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}  600  # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
${STARTUP_TIMEOUT}  15  # In minute: Timeout for BTS to startup after reset, default value 15 min
${POST_CHECK_ONLY_ALARMS}  ${FALSE}  # Should post verification verify only alarms (True, False)
${POST_ALARMS_IGNORED_PATTERN}  ${EMPTY}  # Comma separated alarm patterns which should be ignored.
# Keywords: - severity, faultId, faultName, notifier, number (i.e. faultId=49, severity=Major)
${ALT_SCF_PATH}  ${EMPTY}  # Alternative SCF file path for parser in case SIR file is used for commissioning
${ONAIR_TIMEOUT}  900


*** Keywords ***
TC__CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27423
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27423 - Test creation
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27801 - Set COMMISSIONING_PATH if not given
    ...  *******************

    Set Tags  CA-CM  OWNER-daniel.cozma@nokia.com  AUTHOR-iasmin.tomici@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-COMPA  PHASE-CIT

    Step 1: Check Commissioning File Presence
    Step 2: SBTS Commissioning
    Step 3: Check SBTS State After Commissioning
    Sleep  ${ONAIR_TIMEOUT}


Step 1: Check Commissioning File Presence
    [Timeout]  15 min

    Log  Step 1: Check commissioning file presence  console=True
    ${file_status}  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    Run Keyword If  ${file_status}
    ...  Log  ${COMMISSIONING_PATH} is set  console=true
    ...  ELSE
    ...  _Set COMMISSIONING_PATH
    OperatingSystem.Copy File  ${COMMISSIONING_PATH}  ${TEST_FILES}/commissioning.scf
    Log  Commissioning file exists at ${COMMISSIONING_PATH}  console=True


Step 2: SBTS Commissioning
    Log  Step 2: SBTS commissioning  console=True
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}  ${SKIP_PARAM_RELATION_ERRORS}  ${COMMISSIONING_TIMEOUT}
    Log  Commissioning done. Check BTS states will be performed  console=True
    ${step3_timeout}  Evaluate  ${STARTUP_TIMEOUT}+5
    Set Test Variable  ${STEP3_TIMEOUT}  ${step3_timeout}


Step 3: Check SBTS State After Commissioning
    [Timeout]  ${STEP3_TIMEOUT} min

    Log  Step 3: Check SBTS state after commissioning  console=True
    ${ignored_alarms}  Run Keyword If  '${POST_ALARMS_IGNORED_PATTERN}' != '${EMPTY}'
    ...  Create Alarm Pattern  ${POST_ALARMS_IGNORED_PATTERN}
    ...  ELSE
    ...  Create List  @{EMPTY}
    Run Keyword If  '${ALT_SCF_PATH}'!='${EMPTY}'
    ...  Replace SCFC Parser  ${ALT_SCF_PATH}
    Run Keyword If  ${POST_CHECK_ONLY_ALARMS}
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  15 sec
    ...  Admin Check Active Alarms TAF  ignored_patterns=${ignored_alarms}
    ...  ELSE
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  15 sec
    ...  Admin Check SBTS Cells, Modules And Alarms TAF  ignored_patterns=${ignored_alarms}
    ${mplane_ip}  Admin Get MPLANE IP
    ${status}  Run Keyword And Return Status
    ...  Admin Check Mplane Connection  ${mplane_ip}
    Run Keyword If  ${status}
    ...  Log  Mplane connection is on air  console=true
    ...  ELSE
    ...  Set Test Restriction  Check mplane connection to admin failed!


Create Alarm Pattern
    [Documentation]
    ...  Create alarm pattern from comma separated string of alarm keywords (faultId=49, severity=Major). Alarm pattern
    ...  can be used inside Admin Check Active Alarms KW
    [Arguments]  ${pattern}

    ${pattern_parts}  Split String  ${pattern}  ,
    ${alarms_pattern_list}  Create List
    FOR  ${part}  IN  @{pattern_parts}
        ${splited_part}  Split String  ${part}  =
        ${temp_dict}  Create Dictionary  @{splited_part}
        Append To List  ${alarms_pattern_list}  ${temp_dict}
    END

    [Return]  ${alarms_pattern_list}


Replace SCFC Parser
    [Documentation]
    ...  Tear down the default instance of SCFC parser and create new one with different commissioning file.
    ...  Must be used when commissioning is done with SIR file
    [Arguments]  ${alt_scf_path}

    hran_file_operations.Teardown SCFC Parser
    ${scf_parser_started}  hran_file_operations.Setup SCFC Parser  ${alt_scf_path}  parser_technology=SBTS
    Set Test Variable  ${SCF_PARSER_STARTED}  ${scf_parser_started}


TC Setup
    Common Test Setup Without Initial SBTS Check


TC Teardown
    Common Test Teardown
