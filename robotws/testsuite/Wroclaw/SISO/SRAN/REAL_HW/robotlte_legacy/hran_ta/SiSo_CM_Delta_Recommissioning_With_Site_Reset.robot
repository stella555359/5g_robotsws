*** Settings ***
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library     XML    use_lxml=${TRUE}
Resource    resources/ca_delta_resource.robot

*** Variables ***
${IGNORE_ERRORS}               ${FALSE}
${RECOMMISSIONING_TIMEOUT}     600
${STARTUP_TIMEOUT}             ${EMPTY}
${DELTA_CUSTOM_NAME}           ${EMPTY}
${DELTA_JSON_PATH}             ${EMPTY}
${BTS_ID}                      ${EMPTY}


*** Keywords ***
TC__Siso_CM_Delta_Recommissioning_With_Site_Reset
  [Documentation]
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-9295
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  SBTS delta recommissioning procedure with expected Site Reset.
  ...  Delta File need to be prepared by user using Web Element Manager
  ...  and stored in same folder as TS.
  ...  ${STARTUP_TIMEOUT} if not set, default value used 600s for Site Reset
  ...  ${DELTA_JSON_PATH} should be chosen as path to <custom_name>.json
  ...  ${BTS_ID} is set to select on which BTS test is going to be performed
  ...  ${RECOMMISSIONING_TIMEOUT}  timeout fo delta recommissioning
  ...  ${IGNORE_ERRORS} can be set to avoid relation errors during delta loading on BTS
  ...  *****************
  ...  History of change
  ...  *****************
  ...  23.11.2023 - Adding possibility to verify parameter as list of values and recources creation

  Set Tags	CA-CM  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
  ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8  PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__Siso_CM_Delta_Recommissioning_With_Site_Reset will be executed
  ...  style=ONGOING
  Precondition
  Step 1: Check And Prepare Delta File Presence
  Step 2: Save BTS SCF Before Delta Recommissioning
  Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
  Step 4: SBTS Delta Recommissioning Via ADMIN API
  Step 5: Check If BTS Reset Was Triggered
  Step 6: Save BTS SCF After Delta Recommissioning
  Step 7: Validate If Delta Is Included Into SCF After Delta Recommissioning
  Step 8: Check SBTS State After Delta Recommissioning
  Postcondition
  [Teardown]    Common Test Teardown

Precondition
    Log  === Precondition ===  console=${TRUE}
    OperatingSystem.File Should Exist  ${DELTA_JSON_PATH}    Delta file not exist. Set correct path to delta.


Step 1: Check And Prepare Delta File Presence
    Log  === Step 1: Check And Prepare Delta File Presence ===  console=${TRUE}
    ${json}=  OperatingSystem.Get File  ${DELTA_JSON_PATH}
    Set Test Variable  ${DELTA_FOR_RECOMM}  ${json}
    ${json}=  Evaluate  json.loads('''${json}''')  json
    Set Test Variable  ${DELTA_JSON_FILE}  ${json}

Step ${index}: Save BTS SCF ${when} Delta Recommissioning
    Log  === Step ${index}: Save BTS SCF ${when} Delta Recommissioning ===  console=${TRUE}
    Get Current SCF File  ${cfg.test_logs_path}  SCF_${when}_recommissioning.xml  connection=${BTS_ID}
    ${SCF_XML}=  Parse xml  ${cfg.test_logs_path}/SCF_${when}_recommissioning.xml
    Set Test Variable  ${SCF_XML}

Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
    Log  === Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning ===  console=${TRUE}
    Validate Delta Against SCF  excluded

Step 4: SBTS Delta Recommissioning Via ADMIN API
    Log  === Step 4: SBTS Delta Recommissioning Via ADMIN API ===  console=${TRUE}
    ca_delta_resource.Perform Delta File Commissioning

Step 5: Check If BTS Reset Was Triggered
    Log  === Step 5: Check If BTS Reset Was Triggered ===  console=${TRUE}
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_log_for_reset_check.ims2  connection=${BTS_ID}
    ${num}=  Find Reset  ${cfg.test_logs_path}/InfoModel_log_for_reset_check.ims2
    Run Keyword If  '${num}'=='0'  Fail  Reset event wasn't found inside IM log!

Step 7: Validate If Delta Is Included Into SCF After Delta Recommissioning
    Log  === Step 7: Validate If Delta Is Included Into SCF After Delta Recommissioning ===  console=${TRUE}
    Validate Delta Against SCF  included

Step 8: Check SBTS State After Delta Recommissioning
    Log  === Step 8: Check SBTS State After Delta Recommissioning ===  console=${TRUE}
    Verify BTS State    ${BTS_ID}    600
    Verify Alarms    alias=${BTS_ID}

Postcondition
    Log  === Postcondition ===  console=${TRUE}
    Force Recommissioning With Current Branch On Every Node

