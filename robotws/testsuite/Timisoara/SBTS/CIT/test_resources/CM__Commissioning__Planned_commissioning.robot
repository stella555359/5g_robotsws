*** Settings ***
Documentation
    ...  TC for SBTS commissioning from given SCF file via ADMIN API. BTS should be in 'notCommissioned' state.
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
#${IPSEC_INSTALL}  ${FALSE}  # Is IPSec configuration enabled on BTS (True, False)
${POST_CHECK_ONLY_ALARMS}  ${FALSE}  # Should post verification verify only alarms (True, False)
${POST_ALARMS_IGNORED_PATTERN}  ${EMPTY}  # Comma separated alarm patterns which should be ignored.
# Keywords: - severity, faultId, faultName, notifier, number (i.e. faultId=49, severity=Major)
${ALT_SCF_PATH}  ${EMPTY}  # Alternative SCF file path for parser in case SIR file is used for commissioning
${EXPECTED_BTS_STATUS}  (?i)NotCommissioned  # Expected bts status variable
${REFERENCE_NUMBER}  ${EMPTY}  # Mandatory. Reference number for set certificate.
${PRESHARED_KEY}  ${EMPTY}  # Mandatory. Pre-shared key for set certificate.


*** Keywords ***
TC__CM__Commissioning__Planned_commissioning
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4859
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4859 - Test creation
    ...  - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5741 - Resolve minor bugs
    ...  - 07.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5744 - Add manual method for SCF loading
    ...  - 21.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-6040 - Minor modifications
    ...  - 03.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6846 - Bug for Xpath error. Corrections for new SOAMIF
    ...  - 12.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7116 - Add checking if BTS is in notCommisioned state according to InfoModel
    ...  - 14.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7017 - Remove waiting for reset event in IM as ADMIN KW cover the BTS reconnection
    ...  - 26.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7814 - Replace the postcondition check
    ...  - 02.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7902 - Correct not found KW bug
    ...  - 17.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8063 - Correct path for IM activeSWversion
    ...  - 02.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071 - add verify BTS procedState in Common Test Setup,delete Admin Check BTS state
    ...  - 02.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9055 - Add test variable STARTUP_TIMEOUT
    ...  - 26.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9490 - Remove timeout tag from commissioning step
    ...  - 06.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9671 - Remove step for SW version checking
    ...  - 30.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9980 - Move KW for reset check and BTS check to resources
    ...  - 03.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-10806 - Add IPSec certs installation after commissioning
    ...  - 17.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12540 - Add KW Admin Check mplane connection
    ...  - 07.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12753 - Symlink this TC to SBTS18/CI
    ...  - 15.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13008 - Adjust step 3 to let it check only alarms
    ...  - 20.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15377 - Correct bug connected to treating ignored alarms as critical
    ...  - 01.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15599 - Copy commissioning file to test logs
    ...  - 30.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-14451 - Added ALT_SCF_PATH argument
    ...  - 20.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25782 - Added EXPECTED_BTS_STATUS variable
    ...  - 03.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29377 - Update TC for IPSEC certificates
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4859_01.png#

    Set Tags  CA-CM  OWNER-tomasz.stasinski@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-COMPA  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-LTE_OPR_REQ_10863

    Step 1: Check Commissioning File Presence
    Step 2: SBTS Commissioning
    Step 2a: Perform IPSec Certificates Installation
    Step 3: Check SBTS State After Commissioning


Step 1: Check Commissioning File Presence
    [Timeout]  15 min

    Log  Step 1: Check commissioning file presence  console=true
    ${file_status}  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    IF  ${file_status}
        Log  File ${COMMISSIONING_PATH} exists!  console=true
    ELSE
        Fail  File ${COMMISSIONING_PATH} doesn't exist
    END
    OperatingSystem.Copy File  ${COMMISSIONING_PATH}  ${TEST_FILES}/commissioning.scf
    Log  Commissioning file exists at ${COMMISSIONING_PATH}  console=true


Step 2: SBTS Commissioning
    Log  Step 2: SBTS commissioning  console=true
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}  ${SKIP_PARAM_RELATION_ERRORS}  ${COMMISSIONING_TIMEOUT}
    Log  Commissioning done. Check BTS states will be performed  console=true
    ${step3_timeout}  Evaluate  ${STARTUP_TIMEOUT}+5
    Set Test Variable  ${STEP3_TIMEOUT}


Step 2a: Perform IPSec Certificates Installation
    Log  Step 2a: Perform IPSec certificates installation  console=true
    ${fault_status}  Run Keyword And Return Status  Assert Alarm Active  parameters=alarmId=7220, faultId=61510,
    ...  alarmName="BASE STATION SECURITY PROBLEM", faultName="Automatic BTS Operator Certificate retrieval unsuccessful"  timeout=300
    IF  ${fault_status}
        Log  Fault 61510 is active [OK]  console=true
    ELSE
        Log  Fault 61510 is not active.This step will be skipped!  console=true
        RETURN
    END
    Should Not Be Empty  ${REFERENCE_NUMBER}  Reference number must be specified, please provide it and retest.
    Should Not Be Empty  ${PRESHARED_KEY}  Pre-shared key must be specified, please provide it and retest.
    coam.Set Certificate Automatic Managment  reference_number=${REFERENCE_NUMBER}  preshared_key=${PRESHARED_KEY}  timeout=60
    Assert Alarm Inactive  parameters=alarmId=7220, faultId=61510, alarmName="BASE STATION SECURITY PROBLEM",
    ...  faultName="Automatic BTS Operator Certificate retrieval unsuccessful"  timeout=300


Step 3: Check SBTS State After Commissioning
    [Timeout]  ${STEP3_TIMEOUT} min

    Log  Step 3: Check SBTS state after commissioning  console=true
    IF  '${POST_ALARMS_IGNORED_PATTERN}' != '${EMPTY}'
        ${ignored_alarms}  Create Alarm Pattern  ${POST_ALARMS_IGNORED_PATTERN}
    ELSE
        ${ignored_alarms}  Create List  @{EMPTY}
    END
    IF  '${ALT_SCF_PATH}'!='${EMPTY}'  Replace SCFC Parser  ${ALT_SCF_PATH}
    IF  ${POST_CHECK_ONLY_ALARMS}
        Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  15 sec  Admin Check Active Alarms TAF  ignored_patterns=${ignored_alarms}
    ELSE
        Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  15 sec  Admin Check SBTS Cells, Modules And Alarms TAF  ignored_patterns=${ignored_alarms}
    END
    ${mplane_ip}  Admin Get MPLANE IP
    ${status}  Run Keyword And Return Status  Admin Check Mplane Connection  ${mplane_ip}
    IF  ${status}
        Log  Mplane connection to admin was performed successfully!  console=true
    ELSE
        Set Test Restriction  Check mplane connection to admin failed!
    END


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

    RETURN  ${alarms_pattern_list}


Replace SCFC Parser
    [Documentation]
    ...  Tear down the default instance of SCFC parser and create new one with different commissioning file.
    ...  Must be used when commissioning is done with SIR file
    [Arguments]  ${alt_scf_path}

    hran_file_operations.Teardown SCFC Parser
    ${scf_parser_started}  hran_file_operations.Setup SCFC Parser  ${alt_scf_path}  parser_technology=SBTS
    Set Test Variable  ${SCF_PARSER_STARTED}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  expected_bts_status=${EXPECTED_BTS_STATUS}
    ...  tc_name=CM__Commissioning__Planned_commissioning


TC Teardown
    Common Test Teardown
    Set Test Variable  ${DISABLE_WATCHDOG}  ${FALSE}
