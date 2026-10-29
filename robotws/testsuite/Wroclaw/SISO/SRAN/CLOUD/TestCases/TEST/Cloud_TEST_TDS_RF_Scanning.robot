*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{VCU_TDS_RF_SCAN_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_TEST_TDS_RF_Scanning
    [Arguments]  ${scfc_file_path}  ${rmod_sn}  ${capture_types}=@{EMPTY}  ${antenna_panel}=${None}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46698
    ...  Feature: CB010474 - RF scan support for Cloud BTS.
    ...
    ...  Test case starts/cancels RF scan test operation and checks downloaded files.
    ...  The purpose of this case is to verify the RF Scan feature works properly for BTS in TDS state.
    ...  RF Scan test is also known as RF Sniffing test or RFI (Radio Frequency Scanning) test.
    ...  TC supports RF-Scanning measurements for Radio Frequency Interference (RFI) with the following inputs:
    ...  - Antenna ID: indicates physical antenna for testing
    ...    This is the Rx Antenna Line used by the cell under test.
    ...    For mMIMO radios, it refers to the part of antenna panel that cells are deployed on the radios.
    ...  - Radio ID: indicates physical radio for testing
    ...    When provided, data from all RX Antenna Lines present on the radio shall be collected.
    ...  - Cell ID: indicates the specific cell's Rx RF data to be captured
    ...  TC enables feature activation flag - actRfiTesting.
    ...  TC starts/cancels RF scan test with given capture type in TDS mode.
    ...  TC runs given capture type (RX_COMBINED(HBF0), RX_COMBINED_RAW(RxADC) and RX_CARRIER(FIR9))
    ...  on input radio module serial number and collect RF scan data.
    ...  TC capture types:
    ...  - Raw Composite Rx (RxADC) required inputs: Radio ID + Antenna ID.
    ...  - Composite Rx (HBF0) required inputs: Radio ID + Antenna ID.
    ...  - Carrier Rx (FIR9) required inputs: Radio ID+Antenna ID+Cell ID.
    ...  The supported test options could be different for each radio variant, it is defined in radio's BPF file.
    ...  TC checks the number of downloaded RF scan files.
    ...
    ...  Step 1: Initial check
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Check if radio module serial number is in configuration
    ...  Step 2: Activate RF scan
    ...  a) Set parameter "actRfiTesting" to "true".
    ...  Step 3: Enter into Test Dedicated State mode
    ...  a) vDU operation state is in test mode (operational_state=test)
    ...  Step 4: RF Scanning for Carrier RX (FIR9) - Each Antenna
    ...  a) Start RF scan
    ...  b) Check start RF scan test operation status
    ...  c) Check the number of .rfcap and .xml files
    ...  Step 5:  RF Scanning for Composite RX (HBFO) - All Antennas
    ...  a) Start RF scan
    ...  b) Check start RF scan test operation status
    ...  c) Check the number of .rfcap and .xml files
    ...  Step 6: RF Scanning for Composite RX (HBFO) - Each Antenna
    ...  a) Start RF scan
    ...  b) Check start RF scan test operation status
    ...  c) Check the number of .rfcap and .xml files
    ...  Step 7:  RF Scanning for Raw Composite RX (RxADC) - All Antennas
    ...  a) Start RF scan
    ...  b) Check start RF scan test operation status
    ...  c) Check the number of .rfcap and .xml files
    ...  Step 8: RF Scanning for Raw Composite RX (RxADC) - Each Antenna
    ...  a) Start RF scan
    ...  b) Check start RF scan test operation status
    ...  c) Check the number of .rfcap and .xml files
    ...  Step 9: Check Cancel Requests for Composite Rx (HBF0) - All Antennas
    ...  a) Start and cancel RF scan
    ...  b) Check cancel RF scan test operation status
    ...  Step 10: Exit from into Test Dedicated State mode
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  Step 11: Postconditions
    ...  a) Set parameter "actRfiTesting" to "false".
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn                | Yes  | Serial number of the tested radio module.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | capture_types          | Yes  | List of capture types.                                                     |
    ...  |                        |      | Supported types: RX_COMBINED(HBF0), RX_COMBINED_RAW(RxADC),                |
    ...  |                        |      | RX_CARRIER(FIR9).                                                          |
    ...  |                        |      | The supported capture type could be different for each radio variant.      |
    ...  |                        |      | It is defined in radio's BPF file.                                         |
    ...  |                        |      | Default values: [RX_CARRIER, RX_COMBINED].                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_panel          |  No  | Will be received only when the requested radio is an mMiMO                 |
    ...  |                        |      | one it's meaningful.                                                       |
    ...  |                        |      | One of [Full_Array, Top_Array, Bottom_Array, Left_Array, Right_Array,      |
    ...  |                        |      | All_Arrays ]                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

#step1: Initial check
    Log  ${start_prefix_green}Test Case: TDS RF Scanning  console=${log_to_console}
    Log  ${dots_prefix_green}Step 1: Initial setup  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_TDS_RF_SCAN_ALLOWED_HIST_ALARMS}
    ${capture_type_list}=  Run Keyword If  ${capture_types}==@{EMPTY}
    ...  Create List  RX_CARRIER  RX_COMBINED
    ...  ELSE
    ...  Set Variable  ${capture_types}
    ${teardown_updated_params_dict}=  Create Dictionary  actRfiTesting=false
    vDU Rest Login
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    ${current_vdu_state}=  Set Test Variable  ${current_vdu_state}
    Log  ${info_prefix}vDU operational state is OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Run Keyword If  '${rmod_sn_value}'!='${rmod_sn}'
    ...  Fail  Radio module serial number ${rmod_sn} not found in current configuration !
    Log  ${info_prefix}Tested radio module is present in current configuration  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Initial setup  console=${log_to_console}
#Step 2: Activate RF Scan
    Log  ${dots_prefix_green}Step 2: Activate RF Scan  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
#    Set Test Variable  ${mrbts_id}
    ${actrfitesting_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${actrfitesting_mo_dn}
    Log  ${info_prefix}RF Scan activation parameter (actRfiTesting) setting  console=${log_to_console}
    ${actrfitesting_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actrfitesting_mo_dn}  para_name=actRfiTesting
    ${updated_params_dict}=  Create Dictionary  actRfiTesting=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${actrfitesting_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${actrfitesting_value}'=='false'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to enable RF Interference testing function (actRfiTesting=true) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actrfitesting_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actrfitesting_mo_dn}  para_name=actRfiTesting
    Log  ${below_info_prefix}Parameter "actRfiTesting" is now set to "${actrfitesting_value}"  console=${log_to_console}
    ${rfscan_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/RFScan
    Create Directory  path=${rfscan_dir_path}
    ${rmod_dn}  ${rmod_runtime_dn}=  vDU RMOD Get Dist Names Based On Serial Number  rmod_sn=${rmod_sn}
    ${rmod_cell_list}=  RMOD Get Cell Id List  rmod_sn=${rmod_sn}
    Log  ${ok_prefix_green}Step 2: Activate RF Scan console=${log_to_console}
#step3: Enter To Test Dedicated State
    Log  ${dots_prefix_green}Step 3: Enter into Test Dedicated State mode  console=${log_to_console}
    Log  ${info_prefix}Waiting to enter into Test Dedicated State mode ...  console=${log_to_console}
    vDU Enter Into TDS Mode
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    ${current_vdu_state}=  Set Test Variable  ${current_vdu_state}
    Log  ${info_prefix}BTS is in Test Dedicated State mode (operational_state=${current_vdu_state})  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Enter into Test Dedicated State mode  console=${log_to_console}
#step4: RF Scanning for Carrier RX (FIR9) - Each Antenna
    Log  ${dots_prefix_green}Step 4: RF Scanning for Carrier RX (FIR9) - Each Antenna  console=${log_to_console}
    ${ant_port_direction}=  Create List  TXRX  RX
    ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
    FOR  ${rmod_cell_id}  IN  @{rmod_cell_list}
      ${antenna_carrier}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${rmod_cell_id}
      ${rfscan_filename}=  Set Variable  Carrier_RX_FIR9_${rmod_sn}_NRCELL_${rmod_cell_id}
      ${capture_type}=  Set Variable  RX_CARRIER
      ${log_info1}=  Set Variable  ${info_prefix}Capture type ${capture_type} has not been selected by the user
      ${log_info2}=  Set Variable  ${info_prefix}Probably capture type ${capture_type} is not supported by radio module ${rmod_sn}
      Run Keyword If  '${capture_type}' in ${capture_type_list}
      ...  Start RF Scan Test And Check File  rmod_dn=${rmod_runtime_dn}  capture_type=${capture_type}  all_antennas=False
      ...  ants_runtime_dns=${ants_runtime_dn_list}  antenna_carrier=${antenna_carrier}  antenna_panel=${antenna_panel}
      ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  log_prefix=${info_prefix}
      ...  ELSE  Run Keywords
      ...  Exit For Loop
      ...  AND
      ...  Log  ${log_info1}\n${log_info2}  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 4: RF Scanning for Carrier RX (FIR9) - Each Antenna  console=${log_to_console}
#step5: RF Scanning for Composite RX (HBFO) - All Antennas
    Log  ${dots_prefix_green}Step 5: RF Scanning for Composite RX (HBFO) - All Antennas  console=${log_to_console}
    ${ant_port_direction}=  Create List  TXRX  RX
    ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
    ${rfscan_filename}=  Set Variable  Composite_RX_HBF0_${rmod_sn}
    ${capture_type}=  Set Variable  RX_COMBINED
    ${log_info1}=  Set Variable  ${info_prefix}Capture type ${capture_type} has not been selected by the user
    ${log_info2}=  Set Variable  ${info_prefix}Probably capture type ${capture_type} is not supported by radio module ${rmod_sn}
    Run Keyword If  '${capture_type}' in ${capture_type_list}
    ...  Start RF Scan Test And Check File  rmod_dn=${rmod_runtime_dn}  capture_type=${capture_type}  all_antennas=True
    ...  ants_runtime_dns=${ants_runtime_dn_list}  antenna_panel=${antenna_panel}
    ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${log_info1}\n${log_info2}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: RF Scanning for Composite RX (HBFO) - All Antennas  console=${log_to_console}
#step6: RF Scanning for Composite RX (HBFO) - Each Antenna
    Log  ${dots_prefix_green}Step 6: RF Scanning for Composite RX (HBFO) - Each Antenna  console=${log_to_console}
    ${ant_port_direction}=  Create List  TXRX  RX
    ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
    ${rfscan_filename}=  Set Variable  Composite_RX_HBF0_${rmod_sn}
    ${capture_type}=  Set Variable  RX_COMBINED
    ${log_info1}=  Set Variable  ${info_prefix}Capture type ${capture_type} has not been selected by the user
    ${log_info2}=  Set Variable  ${info_prefix}Probably capture type ${capture_type} is not supported by radio module ${rmod_sn}
    Run Keyword If  '${capture_type}' in ${capture_type_list}
    ...  Start RF Scan Test And Check File  rmod_dn=${rmod_runtime_dn}  capture_type=${capture_type}  all_antennas=False
    ...  ants_runtime_dns=${ants_runtime_dn_list}  antenna_panel=${antenna_panel}
    ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${log_info1}\n${log_info2}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: RF Scanning for Composite RX (HBFO) - Each Antenna  console=${log_to_console}
#step7: RF Scanning for Raw Composite RX (RxADC) - All Antennas
    Log  ${dots_prefix_green}Step 7: RF Scanning for Raw Composite RX (RxADC) - All Antennas  console=${log_to_console}
    ${ant_port_direction}=  Create List  TXRX  RX
    ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
    ${rfscan_filename}=  Set Variable  Raw_Composite_RX_HBF0_${rmod_sn}
    ${capture_type}=  Set Variable  RX_COMBINED_RAW
    ${log_info1}=  Set Variable  ${info_prefix}Capture type ${capture_type} has not been selected by the user
    ${log_info2}=  Set Variable  ${info_prefix}Probably capture type ${capture_type} is not supported by radio module ${rmod_sn}
    Run Keyword If  '${capture_type}' in ${capture_type_list}
    ...  Start RF Scan Test And Check File  rmod_dn=${rmod_runtime_dn}  capture_type=${capture_type}  all_antennas=True
    ...  ants_runtime_dns=${ants_runtime_dn_list}  antenna_panel=${antenna_panel}
    ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${log_info1}\n${log_info2}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: RF Scanning for Raw Composite RX (RxADC) - All Antennas  console=${log_to_console}
#step8: RF Scanning for Raw Composite RX (RxADC) - Each Antenna
    Log  ${dots_prefix_green}Step 8: RF Scanning for Raw Composite RX (RxADC) - Each Antenna  console=${log_to_console}
    ${ant_port_direction}=  Create List  TXRX  RX
    ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
    ${rfscan_filename}=  Set Variable  Raw_Composite_RX_HBF0_${rmod_sn}
    ${capture_type}=  Set Variable  RX_COMBINED_RAW
    ${log_info1}=  Set Variable  ${info_prefix}Capture type ${capture_type} has not been selected by the user
    ${log_info2}=  Set Variable  ${info_prefix}Probably capture type ${capture_type} is not supported by radio module ${rmod_sn}
    Run Keyword If  '${capture_type}' in ${capture_type_list}
    ...  Start RF Scan Test And Check File  rmod_dn=${rmod_runtime_dn}  capture_type=${capture_type}  all_antennas=False
    ...  ants_runtime_dns=${ants_runtime_dn_list}  antenna_panel=${antenna_panel}
    ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=${rfscan_filename}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${log_info1}\n${log_info2}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: RF Scanning for Raw Composite RX (RxADC) - Each Antenna  console=${log_to_console}
#step9: Check Cancel Requests for Composite Rx (HBF0) - All Antennas
    Log  ${dots_prefix_green}Step 9: Check Cancel Requests for Composite Rx (HBF0)  console=${log_to_console}
    ${start_rf_scan_result}=  vdu.Start Rf Scan Test  ru_dn=${rmod_runtime_dn}  signal=RX_COMBINED  antenna_panel=${antenna_panel}
    Sleep  7s
    Log  ${info_prefix}Start RF scan test operation status ${start_rf_scan_result['status']}  console=${log_to_console}
    vDU Cancel RF Scan Test
    Log  ${info_prefix}Cancel RF scan test operation completed successfully  console=${log_to_console}
    ${rf_scan_test_result}=  vdu.Get Rf Scan Test Operation Status  operation_id=${start_rf_scan_result['operation_id']}
    Log  ${info_prefix}Start RF scan file collecting status: ${rf_scan_test_result['has_file']}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Check Cancel Requests for Composite Rx (HBF0)  console=${log_to_console}
#step10: Exit From Test Dedicated State
    Log  ${dots_prefix_green}Step 10: Exit from Test Dedicated State mode  console=${log_to_console}
    Log  ${info_prefix}Waiting to exit from Test Dedicated State mode ...  console=${log_to_console}
    vDU Exit From TDS Mode  log_prefix=${info_prefix}
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    ${current_vdu_state}=  Set Test Variable  ${current_vdu_state}
    Log  ${info_prefix}BTS is now onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 10: Exit from Test Dedicated State mode  console=${log_to_console}
#step11: Postconditions
    Log  ${dots_prefix_green}Step 11: Postconditions  console=${log_to_console}
    Log  ${info_prefix}Deactivating RF Interference testing function in a BTS  console=${log_to_console}
    ${actrfitesting_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actrfitesting_mo_dn}  para_name=actRfiTesting
    ${updated_params_dict}=  Create Dictionary  actRfiTesting=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${actrfitesting_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${actrfitesting_value}'=='true'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to disable RF Interference testing function (actRfiTesting=false) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actrfitesting_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actrfitesting_mo_dn}  para_name=actRfiTesting
    Log  ${below_info_prefix}Parameter "actRfiTesting" is now set to "${actrfitesting_value}"  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 11: Postconditions  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: RF_Scan  console=${log_to_console}
    [Teardown]  TDS RF Scanning Teardown  tc_status=${KEYWORD_STATUS}

#INTERNAL TEST CASE KEYWORDS
Check RF Scan Files
    [Arguments]  ${rfscan_dir_path}  ${files_count}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the number of RF scan files is correct.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rfscan_dir_path        | Yes  | Path to the directory where the RF scan unpacked scan files are saved.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | files_count            | Yes  | Expected number of RF scan files.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rfcap_files_count}=  Count Files In Directory  path=${rfscan_dir_path}  pattern=*.rfcap
    Should Be Equal As Integers  first=${rfcap_files_count}  second=${files_count}
    ...  msg=Number of .rfcap files doesn't meet conditions !!!
    ${xml_files_count}=  Count Files In Directory  path=${rfscan_dir_path}  pattern=*.xml
    Should Be Equal As Integers  first=${xml_files_count}  second=1
    ...  msg=Number of .xml files doesn't meet conditions !!!
    Log  ${log_prefix}Number of .rfcap and .xml files is correct  console=${log_to_console}

Unzip And Check RF Scan Files
    [Arguments]  ${rfscan_dir_path}  ${files_count}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword unpacks additional RF scan zip files and checks whether the number of RF scan files is correct
    ...  (in case of 'all antennas' option).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rfscan_dir_path        | Yes  | Path to the directory where the RF scan unpacked scan files are saved.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | files_count            | Yes  | Expected number of RF scan files.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    @{rfcap_files}=  List Files In Directory  path=${rfscan_dir_path}
    ${rfcap_files_count}=  Count Files In Directory  path=${rfscan_dir_path}  pattern=*.zip
    Should Be Equal As Integers  first=${rfcap_files_count}  second=${files_count}
    ...  msg=Number of .zip files doesn't meet conditions !!!
    FOR  ${rfcap_file}  IN  @{rfcap_files}
      ${rfcap_filename}=  Fetch From Left  string=${rfcap_file}  marker=.
      Unzip File  dir_path=${rfscan_dir_path}  filename=${rfcap_filename}
      Log  ${log_prefix}File ${rfcap_file} has been uncompressed successfully  console=${log_to_console}
      Check RF Scan Files  rfscan_dir_path=${rfscan_dir_path}/${rfcap_filename}
      ...  files_count=1  log_prefix=${log_prefix}
    END

Get And Check RF Scan File
    [Arguments]  ${ants_runtime_dn_list}  ${rfscan_dir_path}=${SUITE_LOGS_DIR_PATH}  ${rfscan_filename}=rfscan.zip
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword unpacks RF scan zip files, gets RF scan files and checks the number of files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ants_runtime_dns       |  No  | Antennas runtime managed object dist names.                                |
    ...  |                        |      | Will be received only if target radio is not an mMIMO and user doesn't     |
    ...  |                        |      | intend to perform test on "All ANTL".                                      |
    ...  |                        |      | Example: [MRBTS-11111/EQM_R-1/APEQM_R-1/RMOD_R-1/ANTL_R-1]                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rfscan_dir_path        | Yes  | Path to the directory where the RF scan file will be saved.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rfscan_filename        | Yes  | Name of RF scan file.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    vdu.Get Rf Scan Test File  local_path=${rfscan_dir_path}  local_file_name=${rfscan_filename}.zip
    Unzip File  dir_path=${rfscan_dir_path}  filename=${rfscan_filename}
    Log  ${log_prefix}File ${rfscan_filename}.zip has been uncompressed successfully  console=${log_to_console}
    ${antenna_count}=  Get Length  item=${ants_runtime_dn_list}
    Run Keyword If  ${antenna_count}>1
    ...  Unzip And Check RF Scan Files  rfscan_dir_path=${rfscan_dir_path}/${rfscan_filename}
    ...  files_count=${antenna_count}  log_prefix=${log_prefix}
    ...  ELSE
    ...  Check RF Scan Files  rfscan_dir_path=${rfscan_dir_path}/${rfscan_filename}
    ...  files_count=${antenna_count}  log_prefix=${log_prefix}
    Run  command=rm -fr ${rfscan_dir_path}/${rfscan_filename}

Start RF Scan Test And Check File
    [Arguments]  ${rmod_dn}  ${capture_type}  ${all_antennas}  ${ants_runtime_dns}=@{EMPTY}  ${antenna_carrier}=${None}
    ...  ${antenna_panel}=${None}  ${rfscan_dir_path}=${SUITE_LOGS_DIR_PATH}  ${rfscan_filename}=rfscan.zip
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword starts RF scan test.
    ...  Keyword gets RF scan files and checks the number of files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_dn                |  Yes | Radio module runtime managed object dist name.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | capture_type           |  Yes | Capture type.                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | all_antennas           |  Yes | Specifies whether one or all antennas are tested.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ants_runtime_dns       |  No  | Antennas runtime managed object dist names.                                |
    ...  |                        |      | Will be received only if target radio is not an mMIMO and user doesn't     |
    ...  |                        |      | intend to perform test on "All ANTL".                                      |
    ...  |                        |      | Example: [MRBTS-11111/EQM_R-1/APEQM_R-1/RMOD_R-1/ANTL_R-1]                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_carrier        |  No  | Managed object dist name of cell.                                          |
    ...  |                        |      | Example: MRBTS-11111/NRBTS-11077/NRCELL-1                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_panel          |  No  | Will be received only when the requested radio is an mMiMO                 |
    ...  |                        |      | one it's meaningful.                                                       |
    ...  |                        |      | One of [Full_Array, Top_Array, Bottom_Array, Left_Array, Right_Array,      |
    ...  |                        |      | All_Arrays ]                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rfscan_dir_path        | Yes  | Path to the directory where the RF scan file will be saved.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rfscan_filename        | Yes  | Name of RF scan file.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${ant_runtime_dn}  IN  @{ants_runtime_dns}
      ${antenna}=  Run Keyword If  '${all_antennas}'=='True'
      ...  Set Variable  ALL_ANTENNAS
      ...  ELSE
      ...  Fetch From Right  string=${ant_runtime_dn}  marker=/
      Run Keyword If  '${all_antennas}'=='True'
      ...  vDU Start RF Scan Test  rmod_dn=${rmod_dn}  capture_type=${capture_type}
      ...  antenna_panel=${antenna_panel}  timeout=150
      ...  ELSE
      ...  vDU Start RF Scan Test  rmod_dn=${rmod_dn}  capture_type=${capture_type}  antenna_dn=${ant_runtime_dn}
      ...  antenna_carrier=${antenna_carrier}  antenna_panel=${antenna_panel}  timeout=150
      Log  ${log_prefix}Start RF scan test operation for ${antenna} completed successfully  console=${log_to_console}
      ${rfscan_filename_local}=  Set Variable  ${rfscan_filename}_${antenna}
      ${one_ant_runtime_dn}=  Create List  ${ant_runtime_dn}
      Run Keyword If  '${all_antennas}'=='True'
      ...  Get And Check RF Scan File  ants_runtime_dn_list=${ants_runtime_dns}  rfscan_dir_path=${rfscan_dir_path}
      ...  rfscan_filename=${rfscan_filename_local}  log_prefix=${info_prefix}
      ...  ELSE
      ...  Get And Check RF Scan File  ants_runtime_dn_list=${one_ant_runtime_dn}  rfscan_dir_path=${rfscan_dir_path}
      ...  rfscan_filename=${rfscan_filename_local}  log_prefix=${info_prefix}
      Exit For Loop If  '${all_antennas}'=='True'
    END

TDS RF Scanning Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed (PASS or FAIL).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  '${tc_status}'=='PASS'
    ...  Run Keyword And Ignore Error  vDU Rest Logout
    Return From Keyword If  '${tc_status}'=='PASS'
    Run Keyword If  '${current_vdu_state}'=='test'
    ...  vDU Exit From TDS Mode  log_to_console=False
    ${updated_params_dict}=  Create Dictionary  actRfiTesting=false
    vDU Verify And Update Parameter Of Delta Plan
    ...  mo_dn=${actrfitesting_mo_dn}  updated_params_dict=${updated_params_dict}
    Run Keyword And Ignore Error  vDU Rest Logout
