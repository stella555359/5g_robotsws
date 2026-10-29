*** Settings ***
Documentation   The purpose of this test case is to verify configuration and activation of UL CoMP feature, based on delta file.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     XML    use_lxml=${TRUE}
#Library     ../../hran_ta/resources/ims2_parser.py
#Resource    ../../testcase_setup_and_teardown.robot

#Resource    ../../SiSo_L3_Call.robot
Resource    ./Ul_Comp_common.robot
*** Variables ***

@{UL_COMP_LIST}            # eutranCellId of cells which are going to be included in ulComp set,
                                 # example:  386314  386317
${CELLS_YAML_PATH}               # path to reference yaml file with cells parameters
${CALL_IN_UL_COMP}  ${True}
${SINGLE_NODE}    ${False}    #set in robot suite to TRUE in order to test only 1 node on testline. Need to add additional
# variable  eg.  ${SINGLE_NODE_NUMBER}    1404
*** Keywords ***


Configuring UL CoMP
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check if configuration of Basic/Fixed/Flexible UL CoMP feature on SBTS and
    ...  making a call works as expected.
    ...  Delta File for each Ul CoMP (Basic/Fixed/Flexible) needs to be prepared by user using Web Element Manager
    ...  and stored in same folder as TS.
    ...  Following changes have to be done in configuration to properly configure Ul CoMP delta file
    ...  ==============FOR BASIC ULCOMP==============
    ...  Create Object: MRBTS-x/LNBTS-x/ULCOMPBASICCONF and configure all mandatory parameters
    ...  Configure two, or three Uplink CoMP Basic Cell List (cellList) parameter structures
    ...  Fill Uplink CoMP Cell (lnCelId) parameter with corresponding LTE cell configuration identifier (lnCelId)
    ...  Make sure that the Uplink combination mode (ulCombinationMode) parameter value, under the LNCEL_FDD/ LNCEL_TDD object,
    ...  is set to IRC for each eNB cell that is included in UL CoMP set.
    ...  Set the Activate CoMP (actCoMp) parameter to fixedULCoMp or measBasedCoMp
    ...  ==============FOR FIXED UL COMP=============
    ...  Create Object: MRBTS-x/LNBTS-x/ULCOMP and configure all mandatory parameters
    ...  Configure Uplink CoMP Cell List (ulCoMpCellList) parameter structures
    ...  Fill Uplink CoMP Cell (lnCelId) parameter with corresponding LTE cell configuration identifier (lnCelId)
    ...  Set Uplink CoMP SINR Thresholdparameter (ulCoMpSinrThreshold)
    ...  Uplink combination mode (ulCombinationMode) parameter value is set to IRC for each eNB cell that is included in UL CoMP set.
    ...  Set the Activate CoMP (actCoMp) parameter to fixedULCoMp
    ...  ==============FOR FLEXIBLE UL COMP==========
    ...  Create Object: MRBTS-x/LNBTS-x/A2PR and configure all mandatory parameters.
    ...  Create Object: MRBTS-x/LNBTS-x/A2DPR and configure all mandatory parameters.
    ...  Create Object: MRBTS-x/LNBTS-x/A3PR and configure all mandatory parameters.
    ...  Create Object: MRBTS-x/LNBTS-x/A3DPR and configure all mandatory parameters.
    ...  Create Object: MRBTS-x/LNBTS-x/COMPCONF and configure all mandatory parameters.
    ...  Add measBasedCellConf structures for each neighbour cell.
    ...  Make sure that the Uplink combination mode (ulCombinationMode) parameter value, under the LNCEL_FDD/ LNCEL_TDD object,
    ...  is set to IRC for each eNB cell that is included in UL CoMP set.
    ...  Set the Activate CoMP (actCoMp) parameter to measBasedCoMp
    ...  JSON file naming convention: delta_<bts_id>_<custom_name>.jsonl
    ...  *****************
    ...  History of change
    ...  *****************
    ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Configuring UL CoMP
  ...  style=ONGOING
    Set Tags	CA-CM  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 2  PHASE-CRT
    Configuring Basic Fixed Ul Comp All Steps
    [Teardown]  Run Keywords
    ...  Force Recommissioning With Current Branch On Every Node
    ...  AND    Common Test Teardown


Configuring Basic Fixed Ul Comp All Steps
    Set Test Variable    ${IS_ULCOMP_ACTIVE}    ${False}
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Precondition UlComp  ${node}
    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Run Keyword  Set Test Variable  ${BTS_ID}  ${node}
        Step 1: Check And Prepare Delta File Presence
        Step 2: Save BTS SCF Before Delta Recommissioning
        Step 3: Validate If Delta Is Not Included Into SCF Before Delta Recommissioning
        Step 4: SBTS Delta Recommissioning Via ADMIN API
        Step 5: Save BTS SCF After Delta Recommissioning
        Step 6: Validate If Delta Is Included Into SCF After Delta Recommissioning
        Step 7: Check SBTS State After Delta Recommissioning
        Step 8: Call to cell in UlComp
        Verify Unexpected And Historical Alarms  alias=${BTS_ID}
    END

Step 1: Check And Prepare Delta File Presence
    Log  === Step 1: Check And Prepare Delta File Presence ===  console=${TRUE}
    ${DELTA_JSON_FILE_PATH}=  Delta Commissioning Define JSON Path  ${DELTA}
    ${json}=  OperatingSystem.Get File  ${DELTA_JSON_FILE_PATH}
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
    Perform Delta Commissioning

Step 6: Validate If Delta Is Included Into SCF After Delta Recommissioning
    Log  === Step 6: Validate If Delta Is Included Into SCF After Delta Recommissioning ===  console=${TRUE}
    Get Current SCF File  ${cfg.test_logs_path}  SCF_FOR_CHECK_IF_BASIC.xml  connection=${BTS_ID}
    ${If_Basic_XML}=  Parse xml  ${cfg.test_logs_path}/SCF_FOR_CHECK_IF_BASIC.xml
    Load Scf  file_path=${cfg.test_logs_path}/SCF_FOR_CHECK_IF_BASIC.xml
    ${is_basic}=  Is Object In Scf  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/ULCOMPBASICCONF-0
    Validate Delta Against SCF  included  ${is_basic}

Step 7: Check SBTS State After Delta Recommissioning
    Log  === Step 7: Check SBTS State After Delta Recommissioning ===  console=${TRUE}
    Verify BTS State  ${BTS_ID}  600
    Verify Alarms  alias=${BTS_ID}

Step 8: Call to cell in UlComp
    Log  === Step 8: Perform call    console=${TRUE}
    Set Test Variable  ${SELECTED_CELLS}  ${UL_COMP_LIST}
    Log  ${SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call  cells_input=${SELECTED_CELLS}
    ...  ELSE    Log To Console    Call skipped    console=True
