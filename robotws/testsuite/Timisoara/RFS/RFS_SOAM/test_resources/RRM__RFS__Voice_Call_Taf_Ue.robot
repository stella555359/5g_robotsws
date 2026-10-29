*** Settings ***
Documentation    TC__RRM__RFS__Voice_Call_Taf_Ue
Variables    tc_variables/RRM__RFS__Voice_Call_Taf_Ue.py
Library    String
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${TECHNO}    WCDMA                 # Specified standalone technology on which call will be peformed;
                                   # Possible values: "WCDMA", "GSM"
${BTS_CALL}    BTS1                 # Specified BTS on which call will be peformed; Default value: BTS1 (Master)
${USE_ATTENUATOR}    NO            # Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
${CELLS_LIST}    DEFAULT           # Specify the cells list on which UE will be chekced; Possible values: "DEFAULT" - means that UE is checked if it
                                   # is camped on a cell belonging to BTS; "30295 30294 30293"-User provides cells list with space between Cells Id.
                                   # For WCDMA - Global Cell Id is used, for GSM - Cell CI is used.
${CALL_DURATION}    15             # Duration of call in seconds. In case CALL_DURATION < 1.5*RSSI_MEASUREMENT_PERIOD, CALL_DURATION wii be set to
                                   # 1.5*RSSI_MEASUREMENT_PERIOD; Make sure to provide a value greater than 10
${NUMBER_TO_CALL}    00104         # Number to which voice call will be performed
${RSSI_MEASUREMENT_PERIOD}    10m  # Minimum call duration needed to compute a new set of RSSI raw measurements (GSM call only). Can be given in
                                   # s or m. If there's no indication of unit, seconds will be assumed.
${UE_CAPABILITIES}    None          # Label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${DETACH_UE}    False              # Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False

*** Keywords ***
TC__RRM__RFS__Voice_Call_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-20023
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing voice call over WCDMA and GSM techno using taf.ue solution.
    ...
    ...
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - TECHNO          ----  Specified standalone technology on which call will be peformed;
    ...                          Possible values: "WCDMA", "GSM"
    ...
    ...  - BTS_CALL        ----  Specified BTS on which call will be peformed; Default value: BTS1 (Master)
    ...
    ...  - USE_ATTENUATOR  ----  Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
    ...
    ...  - CELLS_LIST      ----  Possible values: "DEFAULT" - Test Case will Fail if UE is not be camped on one of the BTS/ENB Cells; User provides
    ...  cells list in format "30295 30294 30293" (space between Cells Id). For WCDMA Global Cell Id is used, for GSM Cell CI is used
    ...
    ...  - CALL_DURATION   ----  Duration of call in seconds. In case CALL_DURATION < 1.5*RSSI_MEASUREMENT_PERIOD, CALL_DURATION wii be set to
    ...  1.5*RSSI_MEASUREMENT_PERIOD
    ...
    ...  - NUMBER_TO_CALL  ----  Number to which voice call will be performed
    ...
    ...  - RSSI_MEASUREMENT_PERIOD  ----  Minimum call duration needed by BTS to compute a new set of RSSI raw measurements (RSSI measurement is done
    ...  only for GSM voice call).Can be given in s or m. If there's no indication of unit, seconds will be assumed
    ...
    ...  - UE_CAPABILITIES ----  Label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False
    ...
    ...  ******************
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 23.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25049 - [RFS calls] RRM__RFS__Voice_call_taf_ue - test delivery
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27373 - Refactor RRM TCs after drop of legacy WCDMA and GSM - Argument Part
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases -
    ...   NRL, NR_NR, NR_SBTS, RRM, PM, LOGS
    ...  - 12.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28856 - Use only Common TC Setup and TC Teardown in RRM TCs
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/TAT-25049_RRM__RFS__Voice_Call_Taf_Ue.png


    Set Tags    CA-RRM    OWNER-oana.bonchis@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-CR1    SW-SBTS23R3
    ...    CABLING-RFS_01_UE

    Step 1: TC Parameter Check
    Step 2: Get Cells List of ${TECHNO}
    Step 3: Start voice call based on selected TECHNO ${TECHNO}
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: TC Parameter Check
    Log  Step ${index}: TC Parameter Check  console=True
    ${rssi measurement period number}=  Convert time  ${RSSI_MEASUREMENT_PERIOD}
    ${call duration number}=  Convert time  ${CALL_DURATION}
    ${call duration to rssi}=  Evaluate  ${call duration number}/${rssi measurement period number}
    ${new gsm call duration}=  Evaluate  "%d" % (1.5 * ${rssi measurement period number})
    Run Keyword If  '${TECHNO}' == 'GSM' and ${call duration to rssi} < ${1.5}  Run Keywords  Set Test Variable  ${CALL_DURATION}
    ...  ${new gsm call duration}
    ...  AND  Log  RSSI Measurement period > CALL DURATION and techno=GSM. New CALL DURATION will be ${CALL DURATION}s  console=True
    Run Keyword If  '${TECHNO}' in ['NR', 'LTE']   Run Keywords
    ...  Log  Parameter TECHNO error ${TECHNO} not supported in Voice Call scenarios!  level=ERROR
    ...  AND  Fail  Parameter TECHNO error ${TECHNO} not supported in Voice Call scenarios!

    ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
    ${BTS_count}=  Set Variable  0
    ${admin_alias}=  Set Variable  None
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_count}=  Evaluate  ${BTS_count}+1
        Run Keyword If  "${BTS_number}" == "${BTS_count}"  Run Keywords
        ...  Set Test Variable  ${admin_alias}  ${alias}
        ...  AND  Exit For Loop
    END
    Run Keyword If  "${admin_alias}"=="None"  Fail  Admin alias for ${BTS_CALL} not found!

    ${admin_alias_TECH}=  Get From Dictionary  ${${admin_alias.upper()}}   ${admin_alias.upper()}_TECH

    FOR  ${this_tech}  IN  WCDMA GSM
        Run Keyword If
        ...  ('${TECHNO.upper()}' == '${this_tech}' and '${admin_alias_TECH}' not in ['${this_tech}', 'SBTS'])
        ...  Fail  Parameter TECHNO set as ${TECHNO} but ${BTS_CALL} does not have ${TECHNO} configured!
    END

    Log  TC parameters check verification ended successfully  console=True

Step ${index}: Get Cells List of ${TECHNO}
    Log  Step ${index}: Get Cells List of selected techno: ${TECHNO}  console=True
    ${cells_list}=  Get cells list for call  ${TECHNO}  ${CELLS_LIST}  ${admin_alias}
    Set Test Variable  ${cells_list}
    Log  ${TECHNO} cells list: ${cells_list}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${TECHNO.lower()}_ues}  ${ue_list}
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Log  Attenuator currently not implemented  console=True
    ${timeout}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=voice  call_direction=NA
    ...  cells_list=${cells_list}  techno=${TECHNO}  attenuator=${USE_ATTENUATOR}
    Set Test Variable  ${timeout}

Step ${index}: Start voice call based on selected TECHNO ${TECHNO}
    [Timeout]   ${timeout}
    Log  Step ${index}: Start voice call based on selected techno: ${TECHNO}  console=True
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  SCF backup  TECHNO=${TECHNO}  OAM_architecture=SOAM
    ${techno_lower}=  Convert to Lowercase  ${TECHNO}
    ${ue_index}=  Set Variable  1
    ${common_args_dict}=  Create Dictionary
    ...  TECHNO=${TECHNO}
    ...  USE_ATTENUATOR=${USE_ATTENUATOR}
    ...  cells_list=${cells_list}
    ...  CALL_DURATION=${CALL_DURATION}
    ...  call_type=voice
    ...  call_direction=NA
    ...  NUMBER_TO_CALL=${NUMBER_TO_CALL}
    ...  RSSI_MEASUREMENT_PERIOD=${RSSI_MEASUREMENT_PERIOD}
    ...  capabilities=${UE_CAPABILITIES}
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Set To Dictionary  ${common_args_dict}  BACKUP_SCF_PATH=${BACKUP_SCF_PATH}

    Log  Start voice call for selected techno: ${TECHNO}  console=True
    ${wcdma_cell_id}=  Set Variable If  '${TECHNO.lower()}'=='wcdma'  True  False
    Taf Ue Perform taf ue voice call with one UE on cell list  common_args_dict=${common_args_dict}  ue_index=${ue_index}
    ...  detach_ue=${DETACH_UE}  wcdma_cell_id=${wcdma_cell_id}
    Log  End call for selected techno: ${TECHNO}  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get cells list for call
    [Arguments]  ${TECHNO}  ${CELLS_LIST_param}  ${admin_alias}
    ${get_full_techno_cells_list}=  Set Variable If  '${CELLS_LIST_param}' == 'DEFAULT'  ${True}  ${False}
    ${full_techno_cells_list}=  Run Keyword If  '${CELLS_LIST_param}' != 'DEFAULT'  Split String  ${CELLS_LIST_param}
    Run Keyword If  not ${get_full_techno_cells_list}  Return From Keyword  ${full_techno_cells_list}
    ${BCF_ID}=  Run Keyword If  '${TECHNO.upper()}' == 'GSM'  Get From Dictionary  ${${admin_alias.upper()}}  BCF_ID
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO.upper()}' == 'GSM'
    ...  Get GSM cell IDs from BSC and admin  ${admin_alias}  ${BCF_ID}
    Run Keyword If  '${TECHNO.upper()}' == 'GSM'  Return From Keyword  ${cells_list}
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=
    ...  Run Keyword If  '${TECHNO.upper()}' == 'WCDMA' and '${${admin_alias.upper()}}[${admin_alias.upper()}_TECH]'=='SBTS'
    ...  Get SBTS Cell Ids from admin  ${admin_alias}  ${TECHNO.upper()}
    ...  ELSE IF  '${TECHNO.upper()}' == 'LTE'  Get SBTS Cell Ids from admin  ${admin_alias}  ${TECHNO.upper()}
    ...  ELSE IF  '${TECHNO.upper()}' == 'NR'  Get NR Cell Ids from admin  ${admin_alias}
    ${cell_count}=  Get Length  ${cells_list}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No ${TECHNO} cells are found on BTS!  level=ERROR
    ...  AND  Fail  No ${TECHNO} cells are found on ${BTS_CALL}!
    Sort list  ${cells_list}
    [Return]  ${cells_list}

Particular teardown
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Run Keyword And Continue On Failure  Log  Attenuator currently not implemented  console=True
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs  timeout=300

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Run Keyword And Continue On Failure  Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}
    ...  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
