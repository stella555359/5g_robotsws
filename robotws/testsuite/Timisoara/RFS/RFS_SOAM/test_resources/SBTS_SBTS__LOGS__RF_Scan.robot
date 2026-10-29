*** Settings ***
Documentation    TC__SBTS_SBTS__LOGS__RF_Scan
Variables    tc_variables/sbts_sbts__logs__rf_scan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}         3    # Number of RF Scan operations, default value 3
${RM_SERIAL_NUMBER_LIST}  ALL  # RM serial number list on which RF Scan operation will be performed. Possible values (by default ALL):
                               # - ALL (operation will be performed on all shared and dedicated RMs)
                               # - list of selected shared and/or dedicated RM serial number separated by comma.
${CAPTURE_TYPE_LIST}      ALL  # Capture type list values on which RF Scan operation will be performed. Possible values (by default ALL):
                               # - ALL: operation will be performed on all values (TX_FEEDBACK, RX_COMBINED, RX_COMBINED_RAW, RX_CARRIER); if a
                               # value is not compatible with RF, RF Scan operation will fail with specific error
                               # - list of selected values from available list separated by comma: TX_FEEDBACK, RX_COMBINED, RX_COMBINED_RAW,
                               # RX_CARRIER.

*** Keywords ***
TC__SBTS_SBTS__LOGS__RF_Scan
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26915
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for RF Scan operatiom, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - check RF Scan feature settings
    ...  - get all BTS info for RF Scan operation
    ...  - perform RF Scan operation on each RM from RM list checking generated archive info as described below:
    ...    - shared RM: from both BTS primary and secondary controller
    ...    - dedicated RM: only from BTS primary controller
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: RF Scan operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26915 - [5G][CB009074] New TC for RF Scan scenario test

    Set Tags    CA-LOGS    OWNER-dorin.caluser@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check RF Scan feature settings
    Step 4: Get all BTS info for RF Scan operation
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform RF Scan operation for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_alias_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    Run Keyword If  '${RM_SERIAL_NUMBER_LIST}' != 'ALL'  Check RM serial number list

    ${RF_Scan_capture_type_list}=  Create List  TX_FEEDBACK  RX_COMBINED  RX_COMBINED_RAW  RX_CARRIER
    Set Test Variable  ${RF_Scan_capture_type_list}

    Run Keyword If  '${CAPTURE_TYPE_LIST}' != 'ALL'  Check Capture Type list

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
        Get and Check ALD state info  alias=${alias}
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

Step ${index}: Check RF Scan feature settings
    [Documentation]
    ...  Helper Keyword used to check classical BTS RF Scan feature settings and set them accordingly if needed

    Log  Step ${index}: Check RF Scan feature settings  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Log  Enable R&D mode for Admin session on ${alias} BTS  console=True
        coam.Change Bts Rad Parameters  component=69  params=39:1  connection=${alias}
        Log  R&D mode enabled successfully  console=True

        Log  Check RF Scan feature settings on ${alias} BTS and set them accordingly if needed  console=True

        ${BTS_RF_Scan_feature_dict}=  Get BTS RF Scan feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_RF_Scan_feature_dict_initial}  ${BTS_RF_Scan_feature_dict}

        Set classical BTS RF Scan feature parameter  actRfiTesting  true  ${alias}

    END

Step ${index}: Get all BTS info for RF Scan operation
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of RAT cells configured (per BTS alias)
    ...  - RF Scan technology for all RMs (per BTS alias)
    ...  - Cell mapping info for all RMs (per BTS alias)
    ...  - Antenna mapping info for all RMs (per BTS alias)

    Log  Step ${index}: Get all BTS info for RF Scan operation  console=True

    ${RM_sn_BTS_alias_RF_Scan_technology_dict}=  Get RF Scan Technology Info For All RMs
    Set Test Variable  ${RM_sn_BTS_alias_RF_Scan_technology_dict}

    ${RM_sn_BTS_alias_ANT_info_dict}=  Get Antenna Mapping Info For All RMs
    Set Test Variable  ${RM_sn_BTS_alias_ANT_info_dict}

    ${BTS_alias_ANT_id_CELL_id_dict}=  Get Cell Mapping Info For All Antennas
    Set Test Variable  ${BTS_alias_ANT_id_CELL_id_dict}

    ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}=  Get RF Scan Antenna Panel Info For All RMs
    Set Test Variable  ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}

    ${RF_Scan_folder}=  Set Variable  ${Test Results Dir}/RF_Scan
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RF_Scan_folder}
    Set Test Variable  ${RF_Scan_folder}

    ${RF_Scan_file_name}=  Set Variable  ${RF_Scan_folder}/RF_Scan_info.txt
    Create File  ${RF_Scan_file_name}
    Set Test Variable  ${RF_Scan_file_name}
    Append To File  ${RF_Scan_file_name}  \n ***** Test RF Scan feature ***** \n

    Set Test Variable  ${RF_Scan_operation_failed_count}  0

Step ${index}: Perform RF Scan operation for iteration ${INDEX}
    [Documentation]
    ...  Perform RF Scan operation on selected RMs based on following info: technology, capture type, antenna, antenna panel, local cell

    Log  Step ${index}: Perform RF Scan operation for iteration ${INDEX}  console=True

    Append To File  ${RF_Scan_file_name}  \n ***** RF Scan operation info for iteration ${INDEX} ***** \n

    FOR  ${RM_sn}  IN  @{RMOD_all_sn_list}

        Perform RF Scan operation on RM  ${RM_sn}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM serial number list

    ${RM_sn_check}=  Set Variable  True
    ${RM_sn_invalid_list}=  Create List
    ${BTS_operation_list}=  Create List

    ${RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RM_SERIAL_NUMBER_LIST_custom}=  Split String  ${RM_SERIAL_NUMBER_LIST_strip}  ,

    FOR  ${RM_sn}  IN  @{RM_SERIAL_NUMBER_LIST_custom}

        ${RM_sn_check}=  Set Variable If  '${RM_sn}' not in ${RMOD_all_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${RM_sn}' not in ${RMOD_all_sn_list}  Append To List  ${RM_sn_invalid_list}  ${RM_sn}

    END

    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RM serial number values are not valid: ${RM_sn_invalid_list}. Log  Please select values for test
    ...  argument \${RM_SERIAL_NUMBER_LIST} from configured RM: ${RMOD_all_sn_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RMOD_all_sn_list}  ${RM_SERIAL_NUMBER_LIST_custom}

    FOR  ${RM_sn}  IN  @{RMOD_all_sn_list}

        ${RM_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RM_sn}
        Append To List  ${BTS_operation_list}  @{RM_BTS_alias_list}

    END

    ${BTS_operation_list}=  Remove Duplicates  ${BTS_operation_list}

    Set Test Variable  ${BTS_alias_list}  ${BTS_operation_list}

Check Capture Type list

    ${Capture_type_check}=  Set Variable  True
    ${Capture_type_invalid_list}=  Create List

    ${CAPTURE_TYPE_LIST_strip}=  Replace String  ${CAPTURE_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${CAPTURE_TYPE_LIST_custom}=  Split String  ${CAPTURE_TYPE_LIST_strip}  ,

    FOR  ${item}  IN  @{CAPTURE_TYPE_LIST_custom}

        ${Capture_type_check}=  Set Variable If  '${item}' not in ${RF_Scan_capture_type_list}  False  ${Capture_type_check}
        Run Keyword If  '${item}' not in ${RF_Scan_capture_type_list}  Append To List  ${Capture_type_invalid_list}  ${item}

    END

    Run Keyword If  '${Capture_type_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected Capture type values are not valid: ${Capture_type_invalid_list}. Log  Please select values for test
    ...  argument \${CAPTURE_TYPE_LIST} from available list: ${RF_Scan_capture_type_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RF_Scan_capture_type_list}  ${CAPTURE_TYPE_LIST_custom}

Check Antenna Panel list

    ${Antenna_panel_check}=  Set Variable  True
    ${Antenna_panel_invalid_list}=  Create List

    ${ANTENNA_PANEL_LIST_strip}=  Replace String  ${ANTENNA_PANEL_LIST}  ${SPACE}  ${EMPTY}
    ${ANTENNA_PANEL_LIST_custom}=  Split String  ${ANTENNA_PANEL_LIST_strip}  ,

    FOR  ${item}  IN  @{ANTENNA_PANEL_LIST_custom}

        ${Antenna_panel_check}=  Set Variable If  '${item}' not in ${RF_Scan_antenna_panel_list}  False  ${Antenna_panel_check}
        Run Keyword If  '${item}' not in ${RF_Scan_antenna_panel_list}  Append To List  ${Antenna_panel_invalid_list}  ${item}

    END

    Run Keyword If  '${Antenna_panel_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected Capture type values are not valid: ${Antenna_panel_invalid_list}. Log  Please select values for test
    ...  argument \${ANTENNA_PANEL_LIST} from available list: ${RF_Scan_antenna_panel_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RF_Scan_antenna_panel_list}  ${ANTENNA_PANEL_LIST_custom}

Get RF Scan Technology Info For All RMs

    ${RM_sn_BTS_alias_RF_Scan_technology_dict}=  Create Dictionary

    Get Cell List By RAT For All BTS

    FOR  ${RM_sn}  IN  @{RMOD_all_sn_list}

        ${RM_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RM_sn}

        ${BTS_alias_RF_Scan_technology_dict}=  Get RF Scan feature info for RM  ${RM_sn}  ${RM_BTS_alias_list}

        Set To Dictionary  ${RM_sn_BTS_alias_RF_Scan_technology_dict}  ${RM_sn}  ${BTS_alias_RF_Scan_technology_dict}

    END

    [Return]  ${RM_sn_BTS_alias_RF_Scan_technology_dict}

Get Cell List By RAT For All BTS

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
        ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
        ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}

        Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}
        Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
        Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}
        Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}

    END

Get RF Scan feature info for RM
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}

    ${BTS_alias_RF_Scan_technology_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RM_sn}

        ${RM_mapped_CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}

        ${RF_Scan_technology_list}=  Get RF Scan Technology Info For RM  ${RM_mapped_CELL_id_list}  ${alias}

        Set To Dictionary  ${BTS_alias_RF_Scan_technology_dict}  ${alias}  ${RF_Scan_technology_list}

    END

    [Return]  ${BTS_alias_RF_Scan_technology_dict}

Get RF Scan Technology Info For RM
    [Arguments]  ${CELL_id_list}  ${alias}

    ${RF_Scan_technology_list}=  Create List

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        ${CELL_class_name}=  Set Variable If
        ...  '${CELL_id}' in ${${alias}_NR_CELL_id_list}  NRCEL
        ...  '${CELL_id}' in ${${alias}_LTE_CELL_id_list}  LNCEL
        ...  '${CELL_id}' in ${${alias}_WCDMA_CELL_id_list}  WNCEL
        ...  '${CELL_id}' in ${${alias}_GSM_CELL_id_list}  GNCEL

        ${CELL_param}=  Get Parameters For  class_name=${CELL_class_name}  id_num=${CELL_id}  connection=${alias}
        ${CELL_technology}=  Run Keyword If  '${CELL_class_name}' in ['NRCEL', 'LNCEL']
        ...  Get From Dictionary  ${CELL_param}  technology

        Run Keyword If  '${CELL_class_name}' == 'NRCEL' and '${CELL_technology}' == 'FDD'
        ...  Append To List  ${RF_Scan_technology_list}  NR_FDD
        ...  ELSE IF  '${CELL_class_name}' == 'NRCEL' and '${CELL_technology}' == 'TDD'
        ...  Append To List  ${RF_Scan_technology_list}  NR_TDD
        ...  ELSE IF  '${CELL_class_name}' == 'LNCEL' and '${CELL_technology}' == 'FDD'
        ...  Append To List  ${RF_Scan_technology_list}  LTE_FDD
        ...  ELSE IF  '${CELL_class_name}' == 'LNCEL' and '${CELL_technology}' == 'TDD'
        ...  Append To List  ${RF_Scan_technology_list}  LTE_TDD
        ...  ELSE IF  '${CELL_class_name}' == 'WNCEL'
        ...  Append To List  ${RF_Scan_technology_list}  WCDMA

    END

    ${RF_Scan_technology_list}=  Remove Duplicates  ${RF_Scan_technology_list}

    [Return]  ${RF_Scan_technology_list}

Get Antenna Mapping Info For All RMs

    ${RM_sn_BTS_alias_ANT_info_dict}=  Create Dictionary

    FOR  ${RM_sn}  IN  @{RMOD_all_sn_list}

        ${RM_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RM_sn}

        ${BTS_alias_ANT_info_dict}=  Get Antenna Mapping Info For RM  ${RM_sn}  ${RM_BTS_alias_list}

        Set To Dictionary  ${RM_sn_BTS_alias_ANT_info_dict}  ${RM_sn}  ${BTS_alias_ANT_info_dict}

    END

    [Return]  ${RM_sn_BTS_alias_ANT_info_dict}

Get Antenna Mapping Info For RM
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}

    ${BTS_alias_ANT_info_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${BTS_info}=  Get Bts Info  connection=${alias}

        ${RM_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RM_sn}

        ${ANT_info_dict}=  Get BTS Antenna Mapping Info For RM  ${RM_id}  ${BTS_info}

        Set To Dictionary  ${BTS_alias_ANT_info_dict}  ${alias}  ${ANT_info_dict}

    END

    [Return]  ${BTS_alias_ANT_info_dict}

Get BTS Antenna Mapping Info For RM
    [Arguments]  ${RM_id}  ${BTS_info}

    ${ANT_info_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}

        Continue For Loop If  '${item['id']['internal']}' != '${RM_id}'

        ${RM_ANTL_TX_list}  ${RM_ANTL_RX_list}  ${RM_PHYANT_list}=  Get RM Antenna info list  ${item['antenaUsageInfo']}  ${item['ports']}

        Set To Dictionary  ${ANT_info_dict}  ANTL_TX=${RM_ANTL_TX_list}  ANTL_RX=${RM_ANTL_RX_list}  PHYANT=${RM_PHYANT_list}

    END

    [Return]  ${ANT_info_dict}

Get RM Antenna info list
    [Arguments]  ${antenaUsageInfo}  ${ports}

    ${RM_ANTL_TX_list}=  Create List
    ${RM_ANTL_RX_list}=  Create List
    ${RM_PHYANT_list}=  Create List

    FOR  ${item}  IN  @{antenaUsageInfo}

        Run Keyword If  ('TX' or 'TX/RX') in '${item['direction']}'
        ...  Append To List  ${RM_ANTL_TX_list}  ${item['id']['internal']}
        Run Keyword If  ('RX' or 'TX/RX') in '${item['direction']}'
        ...  Append To List  ${RM_ANTL_RX_list}  ${item['id']['internal']}

    END

    FOR  ${item}  IN  @{ports}

        Run Keyword If  'PHYANT' in '${item['label']}'
        ...  Append To List  ${RM_PHYANT_list}  ${item['id']['internal']}

    END

    ${RM_ANTL_TX_list}=  Remove Duplicates  ${RM_ANTL_TX_list}
    ${RM_ANTL_RX_list}=  Remove Duplicates  ${RM_ANTL_RX_list}
    ${RM_PHYANT_list}=  Remove Duplicates  ${RM_PHYANT_list}
    Sort List  ${RM_ANTL_TX_list}
    Sort List  ${RM_ANTL_RX_list}
    Sort List  ${RM_PHYANT_list}

    [Return]  ${RM_ANTL_TX_list}  ${RM_ANTL_RX_list}  ${RM_PHYANT_list}

Get Cell Mapping Info For All Antennas

    ${BTS_alias_ANT_id_CELL_id_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${ANTL_R_info}=  Get Managed Objects  class_name=ANTL_R  connection=${alias}
        ${BTS_ANTL_id_list}=  Get BTS Antennas list  ${ANTL_R_info}

        ${PHYANT_R_info}=  Get Managed Objects  class_name=PHYANT_R  connection=${alias}
        ${BTS_PHYANT_id_list}=  Get BTS Antennas list  ${PHYANT_R_info}

        ${BTS_ANT_id_list}=  Combine Lists  ${BTS_ANTL_id_list}  ${BTS_PHYANT_id_list}

        ${ANT_id_CELL_id_dict}=  Get Cell Mapping Info For BTS Antennas  ${BTS_ANT_id_list}  ${alias}

        Set To Dictionary  ${BTS_alias_ANT_id_CELL_id_dict}  ${alias}  ${ANT_id_CELL_id_dict}

    END

    [Return]  ${BTS_alias_ANT_id_CELL_id_dict}

Get BTS Antennas list
    [Arguments]  ${ANT_info}

    ${BTS_ANT_id_list}=  Create List

    FOR  ${item}  IN  @{ANT_info}

        ${ANT_id}=  Get From Dictionary  ${item}  distName

        Append To List  ${BTS_ANT_id_list}  ${ANT_id}

    END

    Sort List  ${BTS_ANT_id_list}

    [Return]  ${BTS_ANT_id_list}

Get Cell Mapping Info For BTS Antennas
    [Arguments]  ${BTS_ANT_id_list}  ${alias}

    ${ANT_id_CELL_id_dict}=  Create Dictionary

    FOR  ${ANT_id}  IN  @{BTS_ANT_id_list}

        ${ANT_mapped_CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${ANT_id}  connection=${alias}

        Set To Dictionary  ${ANT_id_CELL_id_dict}  ${ANT_id}  ${ANT_mapped_CELL_id_list}

    END

    [Return]  ${ANT_id_CELL_id_dict}

Get RF Scan Antenna Panel Info For All RMs

    ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}=  Create Dictionary

    FOR  ${RM_sn}  IN  @{RMOD_all_sn_list}

        ${RM_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RM_sn}

        ${BTS_alias_RF_Scan_antenna_panel_dict}=  Get RF Scan Antenna Panel Info For RM  ${RM_sn}  ${RM_BTS_alias_list}

        Set To Dictionary  ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}  ${RM_sn}  ${BTS_alias_RF_Scan_antenna_panel_dict}

    END

    [Return]  ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}

Get RF Scan Antenna Panel Info For RM
    [Arguments]  ${RM_sn}  ${RM_BTS_alias_list}

    ${BTS_alias_RF_Scan_antenna_panel_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RM_sn}

        ${RM_mapped_CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}

        ${Antenna_panel_list}=  Get Cell Antenna Panel Info For BTS  ${RM_mapped_CELL_id_list}  ${alias}

        Set To Dictionary  ${BTS_alias_RF_Scan_antenna_panel_dict}  ${alias}  ${Antenna_panel_list}

    END

    [Return]  ${BTS_alias_RF_Scan_antenna_panel_dict}

Get Cell Antenna Panel Info For BTS
    [Arguments]  ${RM_mapped_CELL_id_list}  ${alias}

    ${Antenna_panel_list}=  Create List

    ${BTS_CELL_tech_runtime_scf_dict}  ${BTS_CELL_tech_scf_runtime_dict}=  Get BTS CELL runtime and scf info dict  ${alias}
    ${BTS_NRCELL_scf_runtime_dict}=  Get From Dictionary  ${BTS_CELL_tech_scf_runtime_dict}  nr
    ${BTS_LNCEL_scf_runtime_dict}=  Get From Dictionary  ${BTS_CELL_tech_scf_runtime_dict}  lte

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp
    ${BTS_SCF_NRCELL_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRCELL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}

    FOR  ${item}  IN  @{BTS_SCF_NRCELL_list}

        ${CELL_id}=  Get From Dictionary  ${BTS_NRCELL_scf_runtime_dict}  ${item}

        Continue For Loop If  '${CELL_id}' not in ${RM_mapped_CELL_id_list}

        ${mMimoAntArrayMode_status}=  Check If Parameter Exists From SCF  item_dist_name=${item}  parameter_to_check=mMimoAntArrayMode
        ...  scf_path=${BTS_scf}  alias=${alias}

        ${CELL_mMimoAntArrayMode}=  Run Keyword If  ${mMimoAntArrayMode_status}
        ...  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=mMimoAntArrayMode  scf_path=${BTS_scf}
        ...  ELSE
        ...  Set Variable  None

        ${cond1}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Full 64TRX Array (4x8x2)', 'Full 32TRX Array (2x8x2)', 'None']
        ${cond2}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Top 32TRX Array (2x8x2)', 'Top 16TRX Array (1x8x2)']
        ${cond3}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Bottom 32TRX Array (2x8x2)', 'Bottom 16TRX Array (1x8x2)']
        ${cond4}=  Set Variable  '${CELL_mMimoAntArrayMode}' == 'Left 32TRX Array (4x4x2)'
        ${cond5}=  Set Variable  '${CELL_mMimoAntArrayMode}' == 'Right 32TRX Array (4x4x2)'

        Run Keyword If  ${cond1}  Append To List  ${Antenna_panel_list}  PHYANT_1_Full_Array
        Run Keyword If  ${cond2}  Append To List  ${Antenna_panel_list}  PHYANT_1_Top_Array
        Run Keyword If  ${cond3}  Append To List  ${Antenna_panel_list}  PHYANT_1_Bottom_Array
        Run Keyword If  ${cond4}  Append To List  ${Antenna_panel_list}  PHYANT_1_Left_Array
        Run Keyword If  ${cond5}  Append To List  ${Antenna_panel_list}  PHYANT_1_Right_Array

    END

    ${BTS_SCF_LNCEL_TDD_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL_TDD-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}

    FOR  ${item}  IN  @{BTS_SCF_LNCEL_TDD_list}

        ${CELL_dn}=  Fetch From Left  ${item}  /LNCEL_TDD-

        ${CELL_id}=  Get From Dictionary  ${BTS_LNCEL_scf_runtime_dict}  ${CELL_dn}

        Continue For Loop If  '${CELL_id}' not in ${RM_mapped_CELL_id_list}

        ${mMimoAntArrayMode_status}=  Check If Parameter Exists From SCF  item_dist_name=${item}  parameter_to_check=mMimoAntArrayMode
        ...  scf_path=${BTS_scf}  alias=${alias}

        ${CELL_mMimoAntArrayMode}=  Run Keyword If  ${mMimoAntArrayMode_status}
        ...  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=mMimoAntArrayMode  scf_path=${BTS_scf}
        ...  ELSE
        ...  Set Variable  None

        ${cond1}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Full 64TRX Array (4x8x2)', 'Full 32TRX Array (2x8x2)', 'None']
        ${cond2}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Top 32TRX Array (2x8x2)', 'Top 16TRX Array (1x8x2)']
        ${cond3}=  Set Variable  '${CELL_mMimoAntArrayMode}' in ['Bottom 32TRX Array (2x8x2)', 'Bottom 16TRX Array (1x8x2)']
        ${cond4}=  Set Variable  '${CELL_mMimoAntArrayMode}' == 'Left 32TRX Array (4x4x2)'
        ${cond5}=  Set Variable  '${CELL_mMimoAntArrayMode}' == 'Right 32TRX Array (4x4x2)'

        Run Keyword If  ${cond1}  Append To List  ${Antenna_panel_list}  PHYANT_1_Full_Array
        Run Keyword If  ${cond2}  Append To List  ${Antenna_panel_list}  PHYANT_1_Top_Array
        Run Keyword If  ${cond3}  Append To List  ${Antenna_panel_list}  PHYANT_1_Bottom_Array
        Run Keyword If  ${cond4}  Append To List  ${Antenna_panel_list}  PHYANT_1_Left_Array
        Run Keyword If  ${cond5}  Append To List  ${Antenna_panel_list}  PHYANT_1_Right_Array

    END

    ${Antenna_panel_list}=  Remove Duplicates  ${Antenna_panel_list}

    [Return]  ${Antenna_panel_list}

Perform RF Scan operation on RM
    [Arguments]  ${RM_sn}

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
        ...  ${alias}
        ${RM_id}=  Get From Dictionary  ${BTS_RMOD_sn_id_dict}  ${RM_sn}
        ${RM_pn}=  Get From Dictionary  ${BTS_RMOD_sn_pn_dict}  ${RM_sn}
        Set Test Variable  ${RM_id}
        Set Test Variable  ${RM_pn}

        ${BTS_alias_RF_Scan_technology_dict}=  Get From Dictionary  ${RM_sn_BTS_alias_RF_Scan_technology_dict}  ${RM_sn}
        ${RF_Scan_technology_list}=  Get From Dictionary  ${BTS_alias_RF_Scan_technology_dict}  ${alias}
        Set Test Variable  ${RM_RF_Scan_technology_list}  ${RF_Scan_technology_list}

        ${BTS_alias_ANT_info_dict}=  Get From Dictionary  ${RM_sn_BTS_alias_ANT_info_dict}  ${RM_sn}
        ${ANT_info_dict}=  Get From Dictionary  ${BTS_alias_ANT_info_dict}  ${alias}
        ${ANTL_TX_id_list}=  Get From Dictionary  ${ANT_info_dict}  ANTL_TX
        ${ANTL_RX_id_list}=  Get From Dictionary  ${ANT_info_dict}  ANTL_RX
        ${PHYANT_id_list}=  Get From Dictionary  ${ANT_info_dict}  PHYANT
        ${RM_RF_Scan_ANT_id_list}=  Combine Lists  ${ANTL_TX_id_list}  ${ANTL_RX_id_list}  ${PHYANT_id_list}
        ${RM_RF_Scan_ANT_id_list}=  Remove Duplicates  ${RM_RF_Scan_ANT_id_list}
        Set Test Variable  ${RM_RF_Scan_ANTL_TX_id_list}  ${ANTL_TX_id_list}
        Set Test Variable  ${RM_RF_Scan_ANTL_RX_id_list}  ${ANTL_RX_id_list}
        Set Test Variable  ${RM_RF_Scan_PHYANT_id_list}  ${PHYANT_id_list}
        Set Test Variable  ${RM_RF_Scan_ANT_id_list}

        Perform RF Scan operation on RM with specific Technology parameter  ${RM_sn}  ${alias}

    END

Perform RF Scan operation on RM with specific Technology parameter
    [Arguments]  ${RM_sn}  ${alias}

    FOR  ${RF_Scan_technology}  IN  @{RM_RF_Scan_technology_list}

        Perform RF Scan operation on RM with specific Capture type parameter  ${RM_sn}  ${RF_Scan_technology}  ${alias}

    END

Perform RF Scan operation on RM with specific Capture type parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${alias}

    FOR  ${RF_Scan_capture_type}  IN  @{RF_Scan_capture_type_list}

        Perform RF Scan operation on RM with Antenna parameters  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${alias}

        Run Keyword If  '${RF_Scan_technology}' not in ['NR_TDD', 'LTE_TDD'] and '${RF_Scan_capture_type}' != 'RX_CARRIER'
        ...  Perform RF Scan operation on RM with All Antennas parameter  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${alias}

    END

Perform RF Scan operation on RM with Antenna parameters
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${alias}

    FOR  ${ANT_id}  IN  @{RM_RF_Scan_ANT_id_list}

        ${TX_status}=  Set Variable If  '${ANT_id}' in ${RM_RF_Scan_ANTL_TX_id_list}  ${TRUE}  ${FALSE}
        ${RX_status}=  Set Variable If  '${ANT_id}' in ${RM_RF_Scan_ANTL_RX_id_list}  ${TRUE}  ${FALSE}

        ${cond1}=  Set Variable  '${RF_Scan_capture_type}' == 'TX_FEEDBACK' and ${TX_status}
        ${cond2}=  Set Variable  '${RF_Scan_capture_type}' == 'RX_COMBINED' and ${RX_status}
        ${cond3}=  Set Variable  '${RF_Scan_capture_type}' == 'RX_COMBINED_RAW' and ${RX_status}
        ${cond4}=  Set Variable  '${RF_Scan_capture_type}' == 'RX_CARRIER' and ${RX_status}
        ${cond5}=  Set Variable  '${RF_Scan_technology}' in ['NR_TDD', 'LTE_TDD'] and '${RF_Scan_capture_type}' != 'RX_CARRIER'
        ${cond6}=  Set Variable  '${RF_Scan_technology}' in ['NR_TDD', 'LTE_TDD'] and '${RF_Scan_capture_type}' == 'RX_CARRIER'

        Run Keyword If  ${cond1} or ${cond2} or ${cond3}
        ...  Perform RF Scan operation on RM with specific Antenna parameter  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}
        ...  ${alias}

        Run Keyword If  ${cond4}
        ...  Perform RF Scan operation on RM with specific Antenna and Cell parameter  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}
        ...  ${ANT_id}  ${alias}

        Run Keyword If  ${cond5}
        ...  Perform RF Scan operation on mMIMO TDD RM with specific Antenna and Antenna panel parameter  ${RM_sn}  ${RF_Scan_technology}
        ...  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

        Run Keyword If  ${cond6}
        ...  Perform RF Scan operation on mMIMO TDD RM with specific Antenna and Antenna panel and Cell parameter  ${RM_sn}  ${RF_Scan_technology}
        ...  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

    END

Perform RF Scan operation on RM with All Antennas parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${alias}

    ${RM_RF_Scan_folder}=  Set Variable  ${RF_Scan_folder}/RMOD_${RM_sn}/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RM_RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RM_RF_Scan_folder}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RF_Scan_file}=  Set Variable  RF_Scan__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    ${RF_Scan_output_file_name}=  Set Variable   ${RM_RF_Scan_folder}/${RF_Scan_file}

    Append To File  ${RF_Scan_file_name}  \n Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters: \n
    Append To File  ${RF_Scan_file_name}  - Technology: ${RF_Scan_technology} \n
    Append To File  ${RF_Scan_file_name}  - Radio: ${RM_id} (${RM_pn}) \n
    Append To File  ${RF_Scan_file_name}  - Capture type: ${RF_Scan_capture_type} \n
    Append To File  ${RF_Scan_file_name}  - Antenna: All Antennas \n

    Log  Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters:  console=True
    Log  - Technology: ${RF_Scan_technology}  console=True
    Log  - Radio: ${RM_id} (${RM_pn})  console=True
    Log  - Capture type: ${RF_Scan_capture_type}  console=True
    Log  - Antenna: All Antennas  console=True

    ${RF_Scan_status}  ${RF_Scan_info}=  Run Keyword And Ignore Error  coam.Start Rf Scanning Test  technology=${RF_Scan_technology}
    ...  radio_dn=${RM_id}  capture_type=${RF_Scan_capture_type}  output_file_name=${RF_Scan_output_file_name}  timeout=60  connection=${alias}

    Run Keyword If  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation successfully finished: \n
        ...  AND  Log  RF Scan operation successfully finished: console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'FAIL'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation failed! \n
        ...  AND  Set RF Scan operation failed count
        ...  AND  Log  RF Scan operation failed!  level=ERROR

        ${RF_Scan_file_size}=  OperatingSystem.Get File Size  ${RF_Scan_output_file_name}
        Run Keyword If  '${RF_Scan_status}' == 'PASS' and ${RF_Scan_file_size} != 0  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file available at ${RF_Scan_output_file_name} \n
        ...  AND  Log  - RF Scan file available at ${RF_Scan_output_file_name}  console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file couldn't be saved or file is empty! \n
        ...  AND  Log  - RF Scan file couldn't be saved or file is empty!  level=ERROR
        ...  AND  Fail  RF Scan file couldn't be saved or file is empty!

Perform RF Scan operation on RM with specific Antenna parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

    ${RM_RF_Scan_folder}=  Set Variable  ${RF_Scan_folder}/RMOD_${RM_sn}/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RM_RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RM_RF_Scan_folder}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RF_Scan_file}=  Set Variable  RF_Scan__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    ${RF_Scan_output_file_name}=  Set Variable   ${RM_RF_Scan_folder}/${RF_Scan_file}

    Append To File  ${RF_Scan_file_name}  \n Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters: \n
    Append To File  ${RF_Scan_file_name}  - Technology: ${RF_Scan_technology} \n
    Append To File  ${RF_Scan_file_name}  - Radio: ${RM_id} (${RM_pn}) \n
    Append To File  ${RF_Scan_file_name}  - Capture type: ${RF_Scan_capture_type} \n
    Append To File  ${RF_Scan_file_name}  - Antenna: ${ANT_id} \n

    Log  Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters:  console=True
    Log  - Technology: ${RF_Scan_technology}  console=True
    Log  - Radio: ${RM_id} (${RM_pn})  console=True
    Log  - Capture type: ${RF_Scan_capture_type}  console=True
    Log  - Antenna: ${ANT_id}  console=True

    ${RF_Scan_status}  ${RF_Scan_info}=  Run Keyword And Ignore Error  coam.Start Rf Scanning Test  technology=${RF_Scan_technology}
    ...  radio_dn=${RM_id}  capture_type=${RF_Scan_capture_type}  antenna_dn=${ANT_id}  output_file_name=${RF_Scan_output_file_name}  timeout=60
    ...  connection=${alias}

    Run Keyword If  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation successfully finished: \n
        ...  AND  Log  RF Scan operation successfully finished: console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'FAIL'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation failed! \n
        ...  AND  Set RF Scan operation failed count
        ...  AND  Log  RF Scan operation failed!  level=ERROR

        ${RF_Scan_file_size}=  OperatingSystem.Get File Size  ${RF_Scan_output_file_name}
        Run Keyword If  '${RF_Scan_status}' == 'PASS' and ${RF_Scan_file_size} != 0  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file available at ${RF_Scan_output_file_name} \n
        ...  AND  Log  - RF Scan file available at ${RF_Scan_output_file_name}  console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file couldn't be saved or file is empty! \n
        ...  AND  Log  - RF Scan file couldn't be saved or file is empty!  level=ERROR
        ...  AND  Fail  RF Scan file couldn't be saved or file is empty!

Perform RF Scan operation on RM with specific Antenna and Cell parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

    ${ANT_id_CELL_id_dict}=  Get From Dictionary  ${BTS_alias_ANT_id_CELL_id_dict}  ${alias}
    ${CELL_id_list}=  Get From Dictionary  ${ANT_id_CELL_id_dict}  ${ANT_id}

    ${RM_RF_Scan_folder}=  Set Variable  ${RF_Scan_folder}/RMOD_${RM_sn}/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RM_RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RM_RF_Scan_folder}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RF_Scan_file}=  Set Variable  RF_Scan__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    ${RF_Scan_output_file_name}=  Set Variable   ${RM_RF_Scan_folder}/${RF_Scan_file}

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        ${cond1}=  Set Variable  '${RF_Scan_technology}' == 'NR_FDD' and '${CELL_id}' not in ${${alias}_NR_CELL_id_list}
        ${cond2}=  Set Variable  '${RF_Scan_technology}' == 'LTE_FDD' and '${CELL_id}' not in ${${alias}_LTE_CELL_id_list}
        ${cond3}=  Set Variable  '${RF_Scan_technology}' == 'WCDMA' and '${CELL_id}' not in ${${alias}_WCDMA_CELL_id_list}

        Continue For Loop If  ${cond1} or ${cond2} or ${cond3}

        Append To File  ${RF_Scan_file_name}  \n Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters: \n
        Append To File  ${RF_Scan_file_name}  - Technology: ${RF_Scan_technology} \n
        Append To File  ${RF_Scan_file_name}  - Radio: ${RM_id} (${RM_pn}) \n
        Append To File  ${RF_Scan_file_name}  - Capture type: ${RF_Scan_capture_type} \n
        Append To File  ${RF_Scan_file_name}  - Antenna: ${ANT_id} \n
        Append To File  ${RF_Scan_file_name}  - Local cell: ${CELL_id} \n

        Log  Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters:  console=True
        Log  - Technology: ${RF_Scan_technology}  console=True
        Log  - Radio: ${RM_id} (${RM_pn})  console=True
        Log  - Capture type: ${RF_Scan_capture_type}  console=True
        Log  - Antenna: ${ANT_id}  console=True
        Log  - Local cell: ${CELL_id}  console=True

        ${RF_Scan_status}  ${RF_Scan_info}=  Run Keyword And Ignore Error  coam.Start Rf Scanning Test  technology=${RF_Scan_technology}
        ...  radio_dn=${RM_id}  capture_type=${RF_Scan_capture_type}  antenna_dn=${ANT_id}  cell_dn=${CELL_id}
        ...  output_file_name=${RF_Scan_output_file_name}  timeout=60  connection=${alias}

        Run Keyword If  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation successfully finished: \n
        ...  AND  Log  RF Scan operation successfully finished: console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'FAIL'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation failed! \n
        ...  AND  Log  RF Scan operation failed!  level=ERROR

        ${RF_Scan_file_size}=  OperatingSystem.Get File Size  ${RF_Scan_output_file_name}
        Run Keyword If  '${RF_Scan_status}' == 'PASS' and ${RF_Scan_file_size} != 0  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file available at ${RF_Scan_output_file_name} \n
        ...  AND  Log  - RF Scan file available at ${RF_Scan_output_file_name}  console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file couldn't be saved or file is empty! \n
        ...  AND  Log  - RF Scan file couldn't be saved or file is empty!  level=ERROR
        ...  AND  Fail  RF Scan file couldn't be saved or file is empty!

    END

Perform RF Scan operation on mMIMO TDD RM with specific Antenna and Antenna panel parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

    ${RM_RF_Scan_folder}=  Set Variable  ${RF_Scan_folder}/RMOD_${RM_sn}/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RM_RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RM_RF_Scan_folder}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RF_Scan_file}=  Set Variable  RF_Scan__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    ${RF_Scan_output_file_name}=  Set Variable   ${RM_RF_Scan_folder}/${RF_Scan_file}

    ${BTS_alias_RF_Scan_antenna_panel_dict}=  Get From Dictionary  ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}  ${RM_sn}
    ${RF_Scan_antenna_panel_list}=  Get From Dictionary  ${BTS_alias_RF_Scan_antenna_panel_dict}  ${alias}

    FOR  ${RF_Scan_antenna_panel}  IN  @{RF_Scan_antenna_panel_list}

        Append To File  ${RF_Scan_file_name}  \n Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters: \n
        Append To File  ${RF_Scan_file_name}  - Technology: ${RF_Scan_technology} \n
        Append To File  ${RF_Scan_file_name}  - Radio: ${RM_id} (${RM_pn}) \n
        Append To File  ${RF_Scan_file_name}  - Capture type: ${RF_Scan_capture_type} \n
        Append To File  ${RF_Scan_file_name}  - Antenna: ${ANT_id} \n
        Append To File  ${RF_Scan_file_name}  - Antenna panel: ${RF_Scan_antenna_panel} \n

        Log  Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters:  console=True
        Log  - Technology: ${RF_Scan_technology}  console=True
        Log  - Radio: ${RM_id} (${RM_pn})  console=True
        Log  - Capture type: ${RF_Scan_capture_type}  console=True
        Log  - Antenna: ${ANT_id}  console=True
        Log  - Antenna panel: ${RF_Scan_antenna_panel}  console=True

        ${RF_Scan_status}  ${RF_Scan_info}=  Run Keyword And Ignore Error  coam.Start Rf Scanning Test  technology=${RF_Scan_technology}
        ...  radio_dn=${RM_id}  capture_type=${RF_Scan_capture_type}  antenna_panel=${RF_Scan_antenna_panel}
        ...  output_file_name=${RF_Scan_output_file_name}  timeout=60  connection=${alias}

        Run Keyword If  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation successfully finished: \n
        ...  AND  Log  RF Scan operation successfully finished: console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'FAIL'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation failed! \n
        ...  AND  Log  RF Scan operation failed!  level=ERROR

        ${RF_Scan_file_size}=  OperatingSystem.Get File Size  ${RF_Scan_output_file_name}
        Run Keyword If  '${RF_Scan_status}' == 'PASS' and ${RF_Scan_file_size} != 0  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file available at ${RF_Scan_output_file_name} \n
        ...  AND  Log  - RF Scan file available at ${RF_Scan_output_file_name}  console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file couldn't be saved or file is empty! \n
        ...  AND  Log  - RF Scan file couldn't be saved or file is empty!  level=ERROR
        ...  AND  Fail  RF Scan file couldn't be saved or file is empty!

    END

Perform RF Scan operation on mMIMO TDD RM with specific Antenna and Antenna panel and Cell parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}  ${alias}

    ${BTS_alias_RF_Scan_antenna_panel_dict}=  Get From Dictionary  ${RM_sn_BTS_alias_RF_Scan_antenna_panel_dict}  ${RM_sn}
    ${RF_Scan_antenna_panel_list}=  Get From Dictionary  ${BTS_alias_RF_Scan_antenna_panel_dict}  ${alias}

    FOR  ${RF_Scan_antenna_panel}  IN  @{RF_Scan_antenna_panel_list}

        Perform RF Scan operation on mMIMO TDD RM with specific Cell parameter  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}
        ...  ${ANT_id}  ${RF_Scan_antenna_panel}  ${alias}

    END

Perform RF Scan operation on mMIMO TDD RM with specific Cell parameter
    [Arguments]  ${RM_sn}  ${RF_Scan_technology}  ${RF_Scan_capture_type}  ${ANT_id}  ${RF_Scan_antenna_panel}  ${alias}

    ${ANT_id_CELL_id_dict}=  Get From Dictionary  ${BTS_alias_ANT_id_CELL_id_dict}  ${alias}
    ${CELL_id_list}=  Get From Dictionary  ${ANT_id_CELL_id_dict}  ${ANT_id}

    ${RM_RF_Scan_folder}=  Set Variable  ${RF_Scan_folder}/RMOD_${RM_sn}/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${RM_RF_Scan_folder}
    Run Keyword If  not ${status}  Create Directory  ${RM_RF_Scan_folder}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RF_Scan_file}=  Set Variable  RF_Scan__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    ${RF_Scan_output_file_name}=  Set Variable   ${RM_RF_Scan_folder}/${RF_Scan_file}

    FOR  ${CELL_id}  IN  @{CELL_id_list}

        ${cond1}=  Set Variable  '${RF_Scan_technology}' == 'NR_TDD' and '${CELL_id}' not in ${${alias}_NR_CELL_id_list}
        ${cond2}=  Set Variable  '${RF_Scan_technology}' == 'LTE_TDD' and '${CELL_id}' not in ${${alias}_LTE_CELL_id_list}

        Continue For Loop If  ${cond1} or ${cond2}

        Append To File  ${RF_Scan_file_name}  \n Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters: \n
        Append To File  ${RF_Scan_file_name}  - Technology: ${RF_Scan_technology} \n
        Append To File  ${RF_Scan_file_name}  - Radio: ${RM_id} (${RM_pn}) \n
        Append To File  ${RF_Scan_file_name}  - Capture type: ${RF_Scan_capture_type} \n
        Append To File  ${RF_Scan_file_name}  - Antenna: ${ANT_id} \n
        Append To File  ${RF_Scan_file_name}  - Antenna panel: ${RF_Scan_antenna_panel} \n
        Append To File  ${RF_Scan_file_name}  - Local cell: ${CELL_id} \n

        Log  Start RF Scan operation on ${alias} BTS for RM with SN ${RM_sn} with following parameters:  console=True
        Log  - Technology: ${RF_Scan_technology}  console=True
        Log  - Radio: ${RM_id} (${RM_pn})  console=True
        Log  - Capture type: ${RF_Scan_capture_type}  console=True
        Log  - Antenna: ${ANT_id}  console=True
        Log  - Antenna panel: ${RF_Scan_antenna_panel}  console=True
        Log  - Local cell: ${CELL_id}  console=True

        ${RF_Scan_status}  ${RF_Scan_info}=  Run Keyword And Ignore Error  coam.Start Rf Scanning Test  technology=${RF_Scan_technology}
        ...  radio_dn=${RM_id}  capture_type=${RF_Scan_capture_type}  antenna_panel=${RF_Scan_antenna_panel}  cell_dn=${CELL_id}
        ...  output_file_name=${RF_Scan_output_file_name}  timeout=60  connection=${alias}

        Run Keyword If  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation successfully finished: \n
        ...  AND  Log  RF Scan operation successfully finished: console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'FAIL'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  RF Scan operation failed! \n
        ...  AND  Log  RF Scan operation failed!  level=ERROR

        ${RF_Scan_file_size}=  OperatingSystem.Get File Size  ${RF_Scan_output_file_name}
        Run Keyword If  '${RF_Scan_status}' == 'PASS' and ${RF_Scan_file_size} != 0  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file available at ${RF_Scan_output_file_name} \n
        ...  AND  Log  - RF Scan file available at ${RF_Scan_output_file_name}  console=True
        ...  ELSE IF  '${RF_Scan_status}' == 'PASS'  Run Keywords
        ...  Append To File  ${RF_Scan_file_name}  - RF Scan file couldn't be saved or file is empty! \n
        ...  AND  Log  - RF Scan file couldn't be saved or file is empty!  level=ERROR
        ...  AND  Fail  RF Scan file couldn't be saved or file is empty!

    END

Set RF Scan operation failed count
    ${RF_Scan_operation_failed_count}=  Evaluate  ${RF_Scan_operation_failed_count} + 1
    Set Test Variable  ${RF_Scan_operation_failed_count}

Recover initial settings for RF Scan feature on classical BTS
    [Documentation]
    ...  Keyword used to recover initial settings for RF Scan feature on classical BTS

    [Arguments]  ${alias}
    Log  Recover initial settings for RF Scan feature on ${alias} BTS  console=True
    ${actRfiTesting_initial}=  Get From Dictionary  ${${alias}_RF_Scan_feature_dict_initial}  actRfiTesting
    Set classical BTS RF Scan feature parameter  actRfiTesting  ${actRfiTesting_initial}  ${alias}

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}

        Recover initial settings for RF Scan feature on classical BTS  ${alias}

    END

    ${RF_Scan_operation_failed_info}=  Create Long String  Some RF Scan operations might be failed due to input parameters incompatibility! For
    ...  detailed info, please consult specific RF Scan log file: ${RF_Scan_file_name}

    Run Keyword If  ${RF_Scan_operation_failed_count} > 0  Run Keywords
    ...  Log  ${RF_Scan_operation_failed_info}  console=True
    ...  AND  Fail  ${RF_Scan_operation_failed_info}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown