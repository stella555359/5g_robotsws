*** Settings ***
Documentation
    ...  This TC was made to perform runtime cell addition.
    ...  Cell described by CELL_ID variable is added based on DeltaAddition.json.
    ...  Json file name may be any, but it must be correctly provided under DELTA_PATH variable.
    ...  Test is only executable on LWG cofiguration
    ...  ------------
    ...  IMPORTANT!!!
    ...  ------------
    ...  Delta .json file  must be prepared manually and put in "DELTA_PATH" location. To create it log in to Admin on developer
    ...  account, perform cell addition manually in parameter editor, validate plan and click Save BTS configuration -> Save Delta as Json.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TIMEOUT}  360  # Timeout
${CELL_ID}  ${EMPTY}  # To-be-added Cell ID e.g. 22874, must be consistent with created Delta file
${DELTA_PATH}  ${EMPTY}  # User-defined absolute and direct path to cell addition delta recommissioning file
${FTP_LABEL}  FTP_SERVER  # ftp name from env_config_1.yaml
${OLD_CELL_UE_SERIAL}  8f544f9b  # Serial number of UE attached to present LTE cell
${NEW_CELL_UE_SERIAL}  ca67e07a  # Serial number of UE attached to added LTE cell
${BANDWIDTH}  150M  # max bandwidth for UDP in bits
${OLD_DL_MAX}  105000000  # max average tput for old cell downlink in bits/sec
${OLD_DL_MIN}  80000000  # min average tput for old cell downlink in bits/sec ideal value for MIMO 20MHz LTE cells 100000000 bits/sec
# for non MIMO 20MHz LTE cells 73000000
${OLD_UL_MAX}  53000000  # max average tput for old cell uplink in bits/sec
${OLD_UL_MIN}  40000000  # min average tput for old uplink in bits/sec ideal value for MIMO 20MHz LTE cells 50000000 bits/sec
# for non MIMO 20MHz LTE cells 40000000
${NEW_DL_MAX}  150000000  # max average tput for added cell downlink in bits/sec
${NEW_DL_MIN}  80000000  # min average tput for added cell downlink in bits/sec ideal value for MIMO 20MHz LTE cells 100000000 bits/sec
# for non MIMO 20MHz LTE cells 73000000
${NEW_UL_MAX}  53000000  # max average tput for added cell uplink in bits/sec
${NEW_UL_MIN}  40000000  # min average tput for added cell uplink in bits/sec ideal value for MIMO 20MHz LTE cells 50000000 bits/sec
# for non MIMO 20MHz LTE cells 40000000


*** Keywords ***
TC__CM_Cell_Addition_LTE
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13945
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.06.2019 - initial creation
    ...  - 02.07.2019 - ready for delivery
    ...  - 20.11.2019 - enhancement recovery is added after test and cell remove before addition https://jira3.int.net.nokia.com/browse/TAT-18263
    ...  - 26.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18412 - Necessary modifications for CIT
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/blob/master/CM_Cell_Addition_Flowchart_TAT-13945.jpg

    Set Tags  CA-CM  OWNER-tomasz.1.krajewski@nokia.com  MAINTAINER-vlad.slivilescu1.krajewski@nokia.com  AUTHOR-tomasz.1.krajewski@nokia.com
    ...  PHASE-CRT  SW-SBTS19  FEATURE-LTE2060  GROUP_IN_CHARGE-TIM_2_Vrf

    Step 0: Preconditions
    Step 1: Cell Addition
    Step 2: Check If Addition Successful
    Step 3: Check If Cell Addition Had Impact To Other Cells


Step 0: Preconditions
    Log Step Header  Step 0: Check preconditions
    Collect Scf  ${TEST_FILES}/SCF_01_recommissioning.xml
    ${delta_present}  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${DELTA_PATH}
    Run Keyword If  ${delta_present}==${FALSE}
    ...  Run Keywords
    ...  Log  Error! No delta file found under provided delta path: ${DELTA_PATH}${\n}Test Case FAILED${\n}  console=True
    ...  AND
    ...  Fail
    Log  Delta file ${DELTA_PATH} found, procceeding...${\n}  console=True
    ${mrbts}  Admin Get BTS Id
    Set Test Variable  ${MRBTS}
    ${cell_list_lte}  Get Cell List  100
    Log  LTE cells list:  console=True
    FOR  ${lte_cell}  IN  @{cell_list_lte['cells']['lte']}
        Log  ${lte_cell['globalCellId']}  console=True
    END
    ${lcr_id}  Infomodel Get Objects Parameter  //MRBTS_A-${MRBTS}/LNBTS_A-${MRBTS}/LNCEL_A-${CELL_ID}  lcrId  allow_negative_result=${True}
    Set Test Variable  ${LCR_ID}
    ${delta_id_1}  Set Variable  2
    Create Delta  ${delta_id_1}
    Log  Set Delta  console=True
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${MRBTS}/LNCEL-${CELL_ID}  delete  ${delta_id_1}
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${LCR_ID[0]}  delete  ${delta_id_1}
    Get Delta  ${delta_id_1}
    Save Delta  ${BTS_FILES}/delta.json  ${delta_id_1}
    Log  Deleting cell procces has started..  console=True
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    ${ftp}  Get Variable Value  &{${FTP_LABEL}}


Step 1: Cell Addition
    Log Step Header  Step 1: Add cell ${CELL_ID}
    Log  Cell addition process started...  console=True
    Perform Delta Recommissioning  ${DELTA_PATH}
    Log  Done  console=True


Step 2: Check If Addition Successful
    Log Step Header  Step 2: Check if cell ${CELL_ID} was successfully added
    ${after_cell_list_lte}  Get Cell List  100
    Log  LTE cells list:  console=True
    FOR  ${lte_cell}  IN  @{after_cell_list_lte['cells']['lte']}
        Log  ${lte_cell['globalCellId']}  console=True
    END
    ${cells_string}  Convert To String  ${after_cell_list_lte}
    ${cell_present}  Run Keyword And Return Status
    ...  Should Contain  ${cells_string}  LNCEL_R-${CELL_ID}
    Run Keyword If  ${cell_present}
    ...  Log  ${\n}Cell ${CELL_ID} successfully added  console=True
    ...  ELSE
    ...  Fail  ${\n}Cell ${CELL_ID} is not present in cell list, addition FAILED
    Wait Until Keyword Succeeds  5m  15s
    ...  Assert All Cells Are In Expected State


Step 3: Check If Cell Addition Had Impact To Other Cells
    Log Step Header  Step 3: Check if cell addition had impact to other cells
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_Cell_addition.ims2
    ${im_log_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_after_Cell_addition.ims2
    Log  Infomodel log saved under ${im_log_path}  console=True
    Log  Checking if other cells were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${im_log_path}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${im_log_path}
    Infomodel Check If Other Than Added LTE Cells Were Operational According To IM Log  ${im_log_path}
    ${reset_value}  Infomodel Check IM Log If BTS Reset Was Triggered  ${im_log_path}
    Run Keyword If  ${reset_value}
    ...  Fail  BTS was restarted during cell addition process
    Admin Check Active Alarms TAF


Infomodel Check If Other Than Added LTE Cells Were Operational According To IM Log
    [Arguments]  ${im_log_path}

    ${cells_objects}  Query Infomodel  get list ${DIST_LTE_CELL}  allow_negative_result=True
    ${lcr_id}  Infomodel Get Objects Parameter  //MRBTS_A-${MRBTS}/LNBTS_A-${MRBTS}/LNCEL_A-${CELL_ID}  lcrId
    Log  Check LTE cells (Added LNCEL-${CELL_ID} will be skipped)  console=True
    FOR  ${cell_object}  IN  @{cells_objects}
        Run Keyword If  '${cell_object.dist_name}' != '/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-${lcr_id[0]}'
        ...  Run Keywords
        ...  Initialize Ims2 Validator  ${im_log_path}
        ...  AND
        ...  Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]
        ...  AND
        ...  Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState]
        ...  AND
        ...  Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        ...  AND
        ...  Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=True
    END
    Log  All LTE cells existing before addition remained operational during addition proccess.  console=True


Custom Test Teardown
    Admin Get Bts_id And Perform Commissioning  ${TEST_FILES}/SCF_01_recommissioning.xml  True  ${TIMEOUT}
    Wait Until Keyword Succeeds  15m  30s
    ...  Assert All Cells Are In Expected State
    Common Test Teardown


TC Setup
    Common Test Setup


TC Teardown
    Custom Test Teardown
