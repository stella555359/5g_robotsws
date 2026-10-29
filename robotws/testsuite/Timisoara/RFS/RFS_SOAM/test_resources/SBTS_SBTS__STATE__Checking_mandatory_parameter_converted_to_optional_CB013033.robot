*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
Variables    tc_variables/sbts_sbts__state__checking_mandatory_parameter_converted_to_optional_CB013033.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Library  json

*** Variables ***
${REPEAT_COUNTER}    3    # Number of mandatory parameter converted to optional check, default value 3
${BTS_LIST}          ALL  # Specify on which BTS, mandatory parameter converted to optional check will be performed. Possible values (by default ALL):
                          # - ALL: action will be performed on all BTS
                          # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py; ex. BTS1, BTS2)
${RAT_LIST}          ALL  # RAT list on mandatory parameter converted to optional check will be performed.
                          # Possible values (by default ALL):
                          # - ALL: action will be performed on all onfigured NR and LTE RAT cells on BTS
                          # - list of selected RAT separated by comma, possible values: NR, LTE (ex. NR)

*** Keywords ***
TC__SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29524
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for Checking mandatory parameter converted to optional CB013033 - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for all BTS
    ...  - admin check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check (creation priority value: 1)
    ...  - WebEm UI check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check (creation priotiry value: optional)
    ...  - check final state and alarms for all BTS
    ...  - Check final number and state of Cells and RMs
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29524 - [CB013033] Web EM check improvements for
    ...    BTS Mandatory Parameters
    ...  - 18.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29796 - Xpath expressions must be modified as on some VMs the menu items
    ...  can't be found

    Set Tags    CA-STATE    OWNER-florina.stefan@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Set Test Variable  ${CYCLE}  ${INDEX}
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Admin check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check
        Step 4: WebEm UI check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

TC Preconditions

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  ============================================================================  console=True
    Log  BTS label list selected for mandatory parameter converted to optional check: ${BTS_label_list}  console=True
    Log  BTS alias list selected for mandatory parameter converted to optional check: ${BTS_alias_list}  console=True
    Log  ============================================================================  console=True

    FOR  ${alias}  IN  @{alias_list}

        Check BTS RAT list  ${alias}

    END

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Admin check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check

    Log  Step ${index}: Admin check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${json_file_path}=  Set Variable  ${BTS Files}/${alias}/export_nidd_run_${CYCLE}.json
        ${result}=  Export NIDD  json_file=${json_file_path}  connection=${alias}
        ${file_content}=  OperatingSystem.Get file  ${json_file_path}
        ${dict_result}=  json.loads  ${file_content}
        Set Test Variable  ${${alias}_dict_result}  ${dict_result}

        Check NIDD parameters  ${alias}

    END

Step ${index}: WebEM UI check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check

    Log  Step ${index}: WebEm UI check NIDD definition of parameters on all BTS, based on avaiable RATs and parameters to check  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        WebEM UI check NIDD parameters  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}

        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}

        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}

    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}

        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}

    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check BTS RAT list
    [Arguments]  ${alias}
    ${BTS_RAT_configured_list}=  Get BTS RAT info  ${alias}
    Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_configured_list}
    Return From Keyword If  '${RAT_LIST}' == 'ALL'

    ${BTS_RAT_LIST_strip}=  Replace String  ${RAT_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_RAT_LIST}=  Split String  ${BTS_RAT_LIST_strip}  ,
    ${BTS_RAT_check}=  Set Variable  True
    ${BTS_RAT_invalid_list}=  Create List
    ${BTS_RAT_request_list}=  Create List

    FOR  ${item}  IN  @{BTS_RAT_LIST}

        ${BTS_RAT_check}=  Set Variable If  '${item}' not in ${BTS_RAT_configured_list}  False  ${BTS_RAT_check}

        Run Keyword If  '${item}' not in ${BTS_RAT_configured_list}
        ...  Append To List  ${BTS_RAT_invalid_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_RAT_request_list}  ${item}

    END

    Run Keyword If  '${BTS_RAT_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RATs for ${alias} BTS are not valid: ${BTS_RAT_invalid_list}. Please select values for test argument
    ...  \${RAT_LIST} from configured RATs: ${BTS_RAT_configured_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${${alias}_BTS_RAT_list}  ${BTS_RAT_request_list}

Get BTS RAT info
    [Arguments]  ${alias}
    ${RAT_configured_list}=  Create List
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${NR_CELL_list}  Append To List  ${RAT_configured_list}  NR
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${LTE_CELL_list}  Append To List  ${RAT_configured_list}  LTE
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${WCDMA_CELL_list}  Append To List  ${RAT_configured_list}  WCDMA
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${GSM_CELL_list}  Append To List  ${RAT_configured_list}  GSM

    [Return]  ${RAT_configured_list}

Check NIDD parameters
    [Arguments]  ${alias}

    FOR  ${RAT}  IN  @{${alias}_BTS_RAT_list}

        Continue For Loop If  '${RAT}' not in ['NR', 'LTE']

        Run Keyword If  '${RAT}' == 'NR'
        ...  Check NR RAT parameters  ${alias}
        ...  ELSE IF  '${RAT}' == 'LTE'
        ...  Check LTE RAT parameters  ${alias}

    END

    Check common BTS parameters  ${alias}

Check NR RAT parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} NR RAT NIDD parameters ***  console=True

    ${nidd_params}=  Create List  cPlaneDscp  bwpType  actPowerSavingBWP  administrativeState  cellBarred  gscnOrSsPbchArfcn  msg1FrequencyStart
    ${creation_priority_1}=  Create List
    ${creation_priority_0}=  Create List

    ${cPlaneDscp_value}=  Set Variable  ${${alias}_dict_result}[NRBTS][params][cPlaneDscp][creationPriority]
    ${bwpType_value}=  Set Variable  ${${alias}_dict_result}[BWP_PROFILE][params][bwpType][creationPriority]
    ${actPowerSavingBWP_value}=  Set Variable  ${${alias}_dict_result}[NRCELL][params][actPowerSavingBWP][creationPriority]
    ${administrativeState_value}=  Set Variable  ${${alias}_dict_result}[NRCELL][params][administrativeState][creationPriority]
    ${cellBarred_value}=  Set Variable  ${${alias}_dict_result}[NRCELL][params][cellBarred][creationPriority]
    ${gscnOrSsPbchArfcn_value}=  Set Variable  ${${alias}_dict_result}[NRCELL][params][gscnOrSsPbchArfcn][creationPriority]
    ${msg1FrequencyStart_value}=  Set Variable  ${${alias}_dict_result}[NRCELL][params][msg1FrequencyStart][creationPriority]

    FOR  ${param}  IN  @{nidd_params}

        Run Keyword If  ${${param}_value} == 1
        ...  Append To List  ${creation_priority_1}  ${param}
        ...  ELSE  Append To List  ${creation_priority_0}  ${param}

    END

    Run Keyword If  ${creation_priority_1}
    ...  Log  The following BTS ${alias} NR RAT NIDD parameters have creationPriority:1, as expected! -> ${creation_priority_1}  console=True

    Run Keyword If  ${creation_priority_0}  Run Keywords
    ...  Log  The following BTS ${alias} NR RAT NIDD parameters have creationPriority:0, not as expected! -> ${creation_priority_0}  level=ERROR
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  The following BTS ${alias} NR RAT NIDD parameters have creationPriority:0 -> ${creation_priority_0}

Check LTE RAT parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} LTE RAT NIDD parameters ***  console=True

    ${nidd_params}=  Create List  actBbPooling  actUeCapEndcHo  tLteNrDualConnectPrep  maxNumOfLnadjLimit  actDownSampling
    ${creation_priority_1}=  Create List
    ${creation_priority_0}=  Create List

    ${actBbPooling_value}=  Set Variable  ${${alias}_dict_result}[LNBTS][params][actBbPooling][creationPriority]
    ${actUeCapEndcHo_value}=  Set Variable  ${${alias}_dict_result}[LNBTS][params][actUeCapEndcHo][creationPriority]
    ${tLteNrDualConnectPrep_value}=  Set Variable  ${${alias}_dict_result}[LNBTS][params][tLteNrDualConnectPrep][creationPriority]
    ${maxNumOfLnadjLimit_value}=  Set Variable  ${${alias}_dict_result}[LNBTS][params][maxNumOfLnadjLimit][creationPriority]
    ${actDownSampling_value}=  Set Variable  ${${alias}_dict_result}[LNCEL][params][actDownSampling][creationPriority]

    FOR  ${param}  IN  @{nidd_params}

        Run Keyword If  ${${param}_value} == 1
        ...  Append To List  ${creation_priority_1}  ${param}
        ...  ELSE  Append To List  ${creation_priority_0}  ${param}

    END

    Run Keyword If  ${creation_priority_1}
    ...  Log  The following BTS ${alias} LTE RAT NIDD parameters have creationPriority:1, as expected! -> ${creation_priority_1}  console=True

    Run Keyword If  ${creation_priority_0}  Run Keywords
    ...  Log  The following BTS ${alias} LTE RAT NIDD parameters have creationPriority:0, not as expected! -> ${creation_priority_0}  level=ERROR
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  The following BTS ${alias} LTE RAT NIDD parameters have creationPriority:0 -> ${creation_priority_0}

Check common BTS parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} common NIDD parameters ***  console=True

    ${nidd_params}=  Create List  useFullCapacity  linkSpeed  actSharedRUIndControl  energySavingMode  actSnapshotCollection
    ${creation_priority_1}=  Create List
    ${creation_priority_0}=  Create List

    ${useFullCapacity_value}=  Set Variable  ${${alias}_dict_result}[BBMOD][params][useFullCapacity][creationPriority]
    ${linkSpeed_value}=  Set Variable  ${${alias}_dict_result}[CABLINK][params][linkSpeed][creationPriority]
    ${actSharedRUIndControl_value}=  Set Variable  ${${alias}_dict_result}[RMOD][params][actSharedRUIndControl][creationPriority]
    ${energySavingMode_value}=  Set Variable  ${${alias}_dict_result}[RMOD][params][energySavingMode][creationPriority]
    ${actSnapshotCollection_value}=  Set Variable  ${${alias}_dict_result}[RMOD][params][actSnapshotCollection][creationPriority]

    FOR  ${param}  IN  @{nidd_params}

        Run Keyword If  ${${param}_value} == 1
        ...  Append To List  ${creation_priority_1}  ${param}
        ...  ELSE  Append To List  ${creation_priority_0}  ${param}

    END

    Run Keyword If  ${creation_priority_1}
    ...  Log  The following BTS ${alias} common NIDD parameters have creationPriority:1, as expected! -> ${creation_priority_1}  console=True

    Run Keyword If  ${creation_priority_0}  Run Keywords
    ...  Log  The following BTS ${alias} common NIDD parameters have creationPriority:0, not as expected! -> ${creation_priority_0}  level=ERROR
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  The following BTS ${alias} common NIDD parameters have creationPriority:0 -> ${creation_priority_0}

WebEM UI check NIDD parameters
    [Arguments]  ${alias}

    SBTS WebEM Setup  alias=${alias}
    SBTS WebEM Open Parameter Editor Menu  alias=${alias}
    Wait Until Keyword Succeeds  30  3
    ...  Click Element  xpath=//button[@class='btn btn-small compact-button']

    FOR  ${RAT}  IN  @{${alias}_BTS_RAT_list}

        Continue For Loop If  '${RAT}' not in ['NR', 'LTE']

        Run Keyword If  '${RAT}' == 'NR'
        ...  WebEM UI Check NR RAT parameters  ${alias}
        ...  ELSE IF  '${RAT}' == 'LTE'
        ...  WebEM UI Check LTE RAT parameters  ${alias}

    END

    WebEM UI Check common BTS parameters  ${alias}

    [Teardown]  SBTS WebEM Teardown  alias=${alias}

WebEM UI Check NR RAT parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} NR RAT NIDD parameters from WebEM UI ***  console=True

    Check WebEM UI parameter  alias=${alias}  parameter_name=cPlaneDscp  parameter_object=NRBTS-
    Check WebEM UI parameter  alias=${alias}  parameter_name=bwpType  parameter_object=BWP_PROFILE-
    Check WebEM UI parameter  alias=${alias}  parameter_name=actPowerSavingBWP  parameter_object=NRCELL-
    Check WebEM UI parameter  alias=${alias}  parameter_name=administrativeState  parameter_object=NRCELL-
    Check WebEM UI parameter  alias=${alias}  parameter_name=cellBarred  parameter_object=NRCELL-
    Check WebEM UI parameter  alias=${alias}  parameter_name=gscnOrSsPbchArfcn  parameter_object=NRCELL-
    Check WebEM UI parameter  alias=${alias}  parameter_name=msg1FrequencyStart  parameter_object=NRCELL-

WebEM UI Check LTE RAT parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} LTE RAT NIDD parameters from WebEM UI ***  console=True

    Check WebEM UI parameter  alias=${alias}  parameter_name=actBbPooling  parameter_object=LNBTS-
    Check WebEM UI parameter  alias=${alias}  parameter_name=actUeCapEndcHo  parameter_object=LNBTS-
    Check WebEM UI parameter  alias=${alias}  parameter_name=tLteNrDualConnectPrep  parameter_object=LNBTS-
    Check WebEM UI parameter  alias=${alias}  parameter_name=maxNumOfLnadjLimit  parameter_object=LNBTS-
    Check WebEM UI parameter  alias=${alias}  parameter_name=actDownSampling  parameter_object=LNCEL-

WebEM UI Check common BTS parameters
    [Arguments]  ${alias}

    Log  *** Check BTS ${alias} common NIDD parameters from WebEM UI ***  console=True

    Check WebEM UI parameter  alias=${alias}  parameter_name=useFullCapacity  parameter_object=BBMOD-
    Check WebEM UI parameter  alias=${alias}  parameter_name=linkSpeed  parameter_object=CABLINK-
    Check WebEM UI parameter  alias=${alias}  parameter_name=actSharedRUIndControl  parameter_object=RMOD-
    Check WebEM UI parameter  alias=${alias}  parameter_name=energySavingMode  parameter_object=RMOD-
    Check WebEM UI parameter  alias=${alias}  parameter_name=actSnapshotCollection  parameter_object=RMOD-

Check WebEM UI parameter
    [Arguments]  ${alias}  ${parameter_name}  ${parameter_object}

    Log  Check BTS ${alias} creation priority value for ${parameter_name} parameter  console=True

    Wait Until Keyword Succeeds  30  3
    ...  Click Element  xpath=//input[@placeholder='Search with enter']
    Input Text  xpath=//input[@placeholder='Search with enter']  ${parameter_name}
    Press Keys  xpath=//input[@placeholder='Search with enter']  RETURN

    ${table_columns}=  SeleniumLibrary.Get Element Count  //thead[@class='p-treetable-thead']//tr[1]/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //thead[@class='p-treetable-thead']//tr[1]/th[${column}]

        Run Keyword If  '${column_value}' == 'Parameter name'  Run Keywords
        ...  Get parameter creation priority value  alias=${alias}  parameter_column=${column}  parameter_name=${parameter_name}
        ...  parameter_object=${parameter_object}
        ...  AND  Exit For Loop

    END

Get parameter creation priority value
    [Arguments]  ${alias}  ${parameter_column}  ${parameter_name}  ${parameter_object}

    ${abbreviation_column}=  Evaluate  ${parameter_column} + 1
    Set Test Variable  ${object_found}  False

    Zoom Out Page  zoom_level=10  # used when running without headless option
    ${table_rows}=  SeleniumLibrary.Get Element Count  //tbody[@class='p-element p-treetable-tbody']/tr
    Zoom Out Page  zoom_level=100  # used when running without headless option

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        Scroll Element Into View  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${parameter_column}]
        Wait Until Element Is Visible  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${parameter_column}]  timeout=5s
        Sleep  0.2s  reason=Waiting time to control execution speed

        Wait Until Keyword Succeeds  30  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${parameter_column}]
        ${parameter_object_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${parameter_column}]
        ${parameter_abbreviation_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${abbreviation_column}]
        ${parameter_object_label}=  Fetch From Right  ${parameter_object_value}  \n

        ${object_status}=  Run Keyword And Return Status  Should Contain  ${parameter_object_value}  ${parameter_object}
        ${abbreviation_status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${parameter_abbreviation_value}  ${parameter_name}

        Run Keyword If  ${object_status} and ${abbreviation_status}
        ...    Set Test Variable  ${object_found}  True

        Run Keyword If  ${object_status} and ${abbreviation_status}  Run Keywords
        ...  Element Should Be Visible  //div[label[normalize-space()='Creation priority:'] and span[normalize-space()='optional']]
        ...  AND  Log Long String  BTS ${alias} creation priority value for ${parameter_name} parameter under ${parameter_object_label} object:
        ...  optional, as expected!  console=True

        Run Keyword If  '${object_found}' == 'False' and ${table_row} == ${table_rows}  Run Keywords
        ...  Capture BTS Page Screenshot  screenshot_name=run_${CYCLE}_BTS_${alias}_${parameter_name}_creation_priority_value
        ...  AND  Log  No BTS ${alias} ${parameter_name} parameter under .../${parameter_object} object found!  level=ERROR
        ...  AND  Fail  No BTS ${alias} ${parameter_name} parameter under .../${parameter_object} object found!
        ...  ELSE  Continue For Loop

    END


Zoom Out Page
    [Documentation]  Zoom out the page to see the entire content. Used when running without headless option.
    [Arguments]  ${zoom_level}

    Execute JavaScript  document.body.style.zoom = '${zoom_level}%'
    Sleep  1s

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
