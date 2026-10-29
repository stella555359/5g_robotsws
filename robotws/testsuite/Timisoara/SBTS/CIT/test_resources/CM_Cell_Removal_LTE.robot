*** Settings ***
Documentation
    ...  This TC was made to perform runtime cell addition.
    ...  Cell described by CELL_ID variable is added based on DeltaAddition.json.
    ...  Test is only executable on LWG cofiguration
    ...  ------------
    ...  IMPORTANT!!!
    ...  ------------
    ...  Delta .json file  must be prepared manually and put in "DELTA_PATH" location. To create it log in to Admin on developer
    ...  account, perform cell addition manually in parameter editor, validate plan and click Save BTS configuration -> Save Delta as Json.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TIMEOUT}  360  # Timeout
${CELL_ID}  ${EMPTY}  # Cell ID e.g.  15594


*** Keywords ***
TC__CM_Cell_Removal_LTE
    [Documentation]
    ...  [CASE LINK]:
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19651 - changind disct key name
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24108 - Get LNBTS id
    ...  - 25.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25749 - Checking cell fix
    ...  - 04.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29032 - Add BTS reset wait after teardown recommissioning
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...

    Set Tags  CA-CM  OWNER-lukasz.rudzinski@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  AUTHOR-lukasz.rudzinski@nokia.com  PHASE-CIT  SW-SBTS19
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  FEATURE-LTE2060

    Preconditions
    Step 1: Cell Removal
    Step 2: Checking Whether Current Cell Was Deleted
    Step 3 : Checking Whether Cell Removal Had Impact To Other Cells


Get Random Cell ID
    ${cell_ids}  Admin Get IDs For All LTE Cells
    ${number_of_lte_cells}  Get Length  ${cell_ids}
    ${cell_index}  Evaluate  random.randint(0, ${number_of_lte_cells}-1)  modules=random
    ${cell}  Get From List  ${cell_ids}  ${cell_index}
    ${cell}  Fetch From Right  ${cell}  -
    Set Test Variable  ${CELL_ID}  ${cell}


Preconditions
    Collect Scf  ${TEST_FILES}/SCF_01_recommissioning.xml
    ${mrbts}  Admin Get BTS Id
    Set Test Variable  ${MRBTS}
    ${lnbts}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS}
    Log  Preconditions  console=True
    IF  '${CELL_ID}'=='${EMPTY}'  Get Random Cell ID
    ${actual_parameter}  Infomodel Get Objects Parameter  //MRBTS_A-${MRBTS}/LNBTS_A-${LNBTS}  planFileActivationMode  allow_negative_result=${True}
    ${lcr_id}  Infomodel Get Objects Parameter  //MRBTS_A-${MRBTS}/LNBTS_A-${LNBTS}/LNCEL_A-${CELL_ID}  lcrId  allow_negative_result=${True}
    Set Test Variable  ${LCR_ID}
    IF  '${actual_parameter[0]}'=='totalServiceLossAllowed'
      Log  Parameter actual is totalServiceLossAllowed, Cell removal will be proceed  console=True
    ELSE
      Log  Perform recommissioning parameter to value totalServiceLossAllowed  console=True
      Perform Parameter Recommissioning  dist_name=MRBTS-${MRBTS}/LNBTS-${LNBTS}
      ...  parameter=planFileActivationMode
      ...  operation=update
      ...  value=totalServiceLossAllowed
      ...  skip_parameter_relation_errors=True
      ...  timeout=360
    END


Checking Cells Are OnAir
    Assert All Cells Are In Expected State


Step 1: Cell Removal
    Log  Step 1: Cell removal  console=True
    ${cell_list_lte}  Get Cell List  100
    FOR  ${lte_cell}  IN  @{cell_list_lte['cells']['lte']}
        Log  lte_cell:${lte_cell['globalCellId']}  console=True
    END
    ${delta_id_1}  Set Variable  1
    Create Delta  ${delta_id_1}
    Log  Set Delta  console=True
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNCEL-${CELL_ID}  delete  ${delta_id_1}
    Append Managed Object To Delta  MRBTS-${MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${LCR_ID[0]}  delete  ${delta_id_1}
    Get Delta  ${delta_id_1}
    Save Delta  ${BTS_FILES}/delta.json  ${delta_id_1}
    Log  Deleting cell procces has started..  console=True
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=Truas


Step 2: Checking Whether Current Cell Was Deleted
    Log  Step 2: Checking whether current cell was deleted  console=True
    ${after_cell_list_lte}  Get Cell List  100
    FOR  ${lte_cell}  IN  @{after_cell_list_lte['cells']['lte']}
        Log  lte_cell:${lte_cell['globalCellId']}  console=True
        IF  '${CELL_ID}'=='${lte_cell['globalCellId']}'  Fail  Cell Still Exists, Removal FAILED
    END
    Log  Cell was deleted ID:${CELL_ID}  console=True


Step 3 : Checking Whether Cell Removal Had Impact To Other Cells
    Log  Step 3 : Checking whether cell removal had impact to other cells  console=True
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_Cell_removal.ims2
    ${im_log_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_after_Cell_removal.ims2
    Log  Infomodel log saved under ${im_log_path}  console=True
    Log  Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${im_log_path}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${im_log_path}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${im_log_path}
    ${reset_value}  Infomodel Check IM Log If BTS Reset Was Triggered  ${im_log_path}
    IF  '${reset_value}'!='False'  Fail  BTS was restarted during cell removal process
    Admin Check Active Alarms TAF


Custom Test Teardown
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}  True  ${TIMEOUT}
    Run Keyword And Ignore Error  Wait For No Ping  ${OAM_BTS_IP}  timeout=300s
    Wait Until Keyword Succeeds  15m  30s
    ...  Checking Cells Are OnAir
    Common Test Teardown


TC Setup
    Common Test Setup  tc_name=CM_Cell_Removal_LTE


TC Teardown
    Custom Test Teardown
