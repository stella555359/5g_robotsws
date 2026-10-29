*** Settings ***
Documentation
    ...  SBTS delta recommissioning procedure without expected reset. Few important remarks:
    ...
    ...  * Only parameter update scenario is supported. Object create/update and parameter create/delete is pending,
    ...
    ...  * Parameter in delta file shouldn't be a list type. It is not supported yet,
    ...
    ...  As the delta commissioning functionality is not delivered to ADMIN WebGUI yet, you need to prepare delta file
    ...  manualy. To create proper delta JSON file please follow instructions under the link
    ...  https://sharenet-ims.int.net.nokia.com/Overview/D557430363.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${DELTA_JSON_FILE_PATH}  /home/ute/Downloads/time_zone_delta.json  # Absolute path to delta commissioning JSON file
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should relation errors be skipped (True, False)
${RECOMMISSIONING_TIMEOUT}  600  # Timeout for recommissioning procedure
${STARTUP_TIMEOUT}  15  # Timeout for BTS to startup after reset, default value 15 min


*** Keywords ***
TC__CM__Recommissioning_delta_commissioning_with_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7150
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7150 - Test creation
    ...  - 01.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9055 - Add test variable STARTUP_TIMEOUT
    ...  - 26.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9490 - Remove timeout tag from commissioning step
    ...  - 30.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9980 - Move KW for reset check and BTS check to resources
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7150_01.png#

    Set Tags  CA-CM  OWNER-michal.adamus@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001238  CABLING-SBTS_03_UEManager

    Step 1: Check Delta File Presence
    Step 2: Save BTS SCF Before Delta Recommissioning
    Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
    Step 4: SBTS Delta Recommissioning Via ADMIN API
    Step 5: Check If BTS Reset Was Triggered
    Step 6: Save BTS SCF After Delta Recommissioning
    Step 7: Validate If Delta Is Included Into SCF After Delta Recommissioning
    Step 8: Check SBTS State After Delta Recommissioning


Step 1: Check Delta File Presence
    [Timeout]  15 min

    Log  Step 1: Check delta file presence  console=True
    OperatingSystem.File Should Exist  ${DELTA_JSON_FILE_PATH}
    Log  Delta commissioning file exists at ${DELTA_JSON_FILE_PATH}  console=True
    ${json}  OperatingSystem.Get File  ${DELTA_JSON_FILE_PATH}
    ${json}  Evaluate  json.loads('''${json}''')  json
    Set Test Variable  ${DELTA_JSON}  ${json}


Step ${index}: Save BTS SCF ${when} Delta Recommissioning
    [Timeout]  15 min

    Log  Step ${index}: Save BTS SCF ${when} delta recommissioning  console=True
    Collect SCF  ${TEST_FILES}/SCF_${when}_recommissioning.xml
    Log  SCF has been saved under ${TEST_FILES}/SCF_${when}_recommissioning.xml  console=True
    ${scf_xml}  Parse Xml  ${TEST_FILES}/SCF_${when}_recommissioning.xml
    Set Test Variable  ${SCF_XML}  ${scf_xml}


Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
    [Timeout]  15 min

    Log  Step 3: Validate if delta is not included into SCF before delta recommissioning  console=True
    FOR  ${scf_object}  IN  @{DELTA_JSON}
        Log  Checking delta object with distName ${scf_object['distName']}  console=True
        Run Keyword And Expect Error  Value inside SCF is not equal value from delta JSON
        ...  Verify Parameters Values In SCF Object  ${SCF_XML}  ${scf_object['distName']}  ${scf_object['parameters']}
    END
    Log  All parameters in delta JSON have different values than parameters in SCF  console=True


Step 4: SBTS Delta Recommissioning Via ADMIN API
    Log  Step 4: SBTS delta recommissioning via ADMIN API  console=True
    Perform Delta Recommissioning  ${DELTA_JSON_FILE_PATH}  ${SKIP_PARAM_RELATION_ERRORS}  timeout=${RECOMMISSIONING_TIMEOUT}
    Log  Delta recommissioning done. Reset occurence will be checked.  console=True


Step 5: Check If BTS Reset Was Triggered
    [Timeout]  15 min

    Log  Step 5: Check if BTS reset was triggered  console=True
    ${was_triggered}  Infomodel Check IM Log If BTS Reset Was Triggered  ${BTS_FILES}/IM/InfoModel_log_for_reset_check.ims2
    Should Be True  ${was_triggered}  Reset event wasn't found inside IM log!
    Log  BTS reset occurence has been found inside InfoModel  console=True


Step 7: Validate If Delta Is Included Into SCF After Delta Recommissioning
    [Timeout]  15 min

    Log  Step 7: Validate if delta is included into SCF after delta recommissioning  console=True
    FOR  ${scf_object}  IN  @{DELTA_JSON}
        Log  Checking delta object with distName ${scf_object['distName']}  console=True
        Verify Parameters Values In SCF Object  ${SCF_XML}  ${scf_object['distName']}  ${scf_object['parameters']}
    END
    Log  All parameters in delta JSON have the same values that parameters in SCF  console=True


Step 8: Check SBTS State After Delta Recommissioning
    Log  Step 8: Check SBTS state after delta recommissioning  console=True
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  15 sec
    ...  Admin Check SBTS Cells, Modules And Alarms TAF


TC Setup
    Common Test Setup  tc_name=CM__Recommissioning_delta_commissioning_with_reset


TC Teardown
    Common Test Teardown
