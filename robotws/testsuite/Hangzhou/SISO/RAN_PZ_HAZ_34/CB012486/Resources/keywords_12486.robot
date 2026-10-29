*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library  taf.selenium.sbts  WITH NAME  selenium_coam
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/case.robot
Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008680/keywords_8680.robot
Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009471_CB010582_Half_Rack/Resources/CB009471_keyword.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/nokia_fastmile.robot
Resource  ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_General_SiSo_vDU_Reset.robot
*** Variables ***
${PATH_Storage}    /home/ute/CB012486
${delta_1116_3ms_10_10_10}               ${CURDIR}/jsons/delta_1116_3ms_10_10_10.json
# ${delta_1116_3ms_100_50_50}               ${CURDIR}/jsons/delta_1116_3ms_100_50_50.json
# ${delta_1070_80_50_50}               ${CURDIR}/jsons/delta_1070_80_50_50.json
${delta_1070_90_50_50}               ${CURDIR}/jsons/delta_1070_90_50_50.json
${delta_1116_0ms_10_10}               ${CURDIR}/jsons/delta_1116_0ms_10_10.json
# ${delta_1116_0ms_40_50}               ${CURDIR}/jsons/delta_1116_0ms_40_50.json
${delta_1208_10_10_10}               ${CURDIR}/jsons/delta_1208_10_10_10.json
${delta_modify_to_8D}               ${CURDIR}/jsons/delta_modify_to_8D.json
${delta_modify_to_16D}               ${CURDIR}/jsons/delta_modify_to_16D.json
${delta_delete_cell_1}    ${CURDIR}/jsons/delta_delete_cell_1.json
@{common_id}  LCELNR-x  NRCELL-x  BBMOD-y
@{replace_cell_1}  LCELNR-1  NRCELL-1  BBMOD-1
@{replace_cell_2}  LCELNR-2  NRCELL-2  BBMOD-1
@{replace_cell_3}  LCELNR-3  NRCELL-3  BBMOD-2
${ue_index}  ${2}
${SAVE LOG DIRECTORY}    /home/ute/CB012486
${gNb_CuType}         SA
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${Log_directory}  ${CURDIR}/scf
${SCF_Filename}    1911_40_50_1116.xml
${SCF_Filename_3ms}    1911_100_50_50_1116.xml
${SCF_60_10_10_3ms}    1911_60_10_10_1116.xml
${SCF_60_20_3ms}    1911_60_20_1116.xml
${SCF_80_50_50_1070}    1911_80_50_50_1070.xml
${loop_times}  3
*** Keywords ***
12486_Manual_SiSo_SM_NR_RAT_reset
  Modify common json file and activate for different ENV  json_file=${delta_modify_to_16D}  old_string=${common_id}
  ...  new_string=${replace_cell_1}  diff_env=${False}
  Run Keyword If  ${release}  Add New Parameters to json  ${delta_1116_3ms_10_10_10}
  Activate or Deactivate feature  delta_file=${delta_1116_3ms_10_10_10}
  Connect to gnb coam via ssl
  9471_Manual_SiSo_SM_NR_RAT_reset  call_keyword=Receiver 5G19-A Attach and Start traffic
  [Teardown]  Run keyword And Ignore Error  Modify common json file and activate for different ENV  json_file=${delta_modify_to_8D}
  ...  old_string=${common_id}  new_string=${replace_cell_1}  diff_env=${False}

Receiver 5G19-A Attach and Start traffic
  ${cell_id_list}  Get All Cell Id
  ${cell_num}    get length  ${cell_id_list}
  Set Test Variable  ${cell_num}
  ${scf_file}  scf.Get real SCF From BTS
  Set Test Variable  ${scf_file}
    Set suite variable    ${NR_CELL_ID_MAPPING}  ${None}
  FOR  ${cell_id}  IN RANGE  ${cell_num}
    Connect to gnb coam via ssl
    5G Receiver Attach cell  cell_id=${cell_id}
  END

5G Receiver Attach cell
  [Arguments]  ${cell_id}=0
  ${id}  Run Keyword If  '${cell_num}'=='3'  Evaluate  ${cell_id}+1
  ...  ELSE  Evaluate  ${cell_id}+2
  ${pci}  Get Parameter Value from SCF  parameter=physCellId  dist_name=${GNB_PATH}/NRCELL-${id}  scf_file_path=${scf_file}
  ${arfcnSsbPbch}  Get Parameter Value from SCF  parameter=arfcnSsbPbch  dist_name=${GNB_PATH}/NRCELL-${id}  scf_file_path=${scf_file}
  nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${pci}    arfcn=${arfcnSsbPbch}
  Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${loop_times}x  30sec  Run keywords  Log to Console
  ...  ******Try to attach NRCELL-${id}******
  ...  AND  UE Attach and Start traffic
  ...  physCellId=${pci}  ue_index=${ue_index}    cell_id=${cell_id}  barred=${False}


Delete existent cell-1
  Connect to gnb coam via ssl
  ${scf_file}  scf.Get real SCF From BTS
    ${exist_cell1}  Run Keyword And Return Status  Get Parameter Value from SCF  parameter=physCellId  dist_name=${GNB_PATH}/NRCELL-1
    ...  scf_file_path=${scf_file}
    Run Keyword If  ${exist_cell1}  Run keywords  Modify json file and activate  json_file=${delta_delete_cell_1}
    ...  AND  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl

12486 Suite Setup
  robot_common_operations.Common Suite Setup
  keywords_8680.Suite Case Setup
  Generate suite log path

12486 case Teardown
  coam_gnb_classical.Connect to gnb coam via ssl
  AlarmWatchdog.add_allow_alarms    fault_id=4592
  Wait Until Keyword Succeeds  10min  20 sec  COAM Check X2 link status from GNB
  AlarmWatchdog.remove_allow_alarms    fault_id=4592
  case.Test Case Teardown
  CI interface.Common Case Teardown

12486_General_SiSo_Cell_block_and_unblock
  scf.scf uploading and commissioning  Log_directory=${Log_directory}  SCF_Filename=${SCF_Filename_3ms}
  Connect to gnb coam via ssl
  ${scf_file}  scf.Get real SCF From BTS
  Set Test Variable  ${scf_file}
  ${cell_id_list}  Get All Cell Id
  ${cell_num}    get length  ${cell_id_list}
  Set Test Variable  ${cell_num}
  AlarmWatchdog.add_allow_alarms    fault_id=49
  General_SiSo_Cell_block_and_unblock  call_keyword=5G Receiver Attach the target cell
  AlarmWatchdog.remove_allow_alarms    fault_id=49
  [Teardown]  CI_interface.Common Suite Setup

5G Receiver Attach the target cell
  [Arguments]  ${cell_list}  ${with_peak}=${False}
  ${id}  Evaluate  ${cell_list[0]}-1
  Log  with_peak=${with_peak}
  Connect to gnb coam via ssl
  5G Receiver Attach cell  cell_id=${id}

12486_Manual_SiSo_CM_Recommissioning
  Run Keyword If  ${release}  Add New Parameters to json  ${delta_1070_90_50_50}
  Activate or Deactivate feature  delta_file=${delta_1070_90_50_50}
  9471_Manual_SiSo_CM_Recommissioning
  Connect to gnb coam via ssl
  Receiver 5G19-A Attach and Start traffic

12486_Manual_SiSo_STARTUP_BTS_Power_Reset
  CI_interface.Common Suite Setup
  Connect to gnb coam via ssl
  AlarmWatchdog.add_allow_alarms    fault_id=4590
  9471_Manual_SiSo_STARTUP_BTS_Power_Reset  call_keyword=Receiver 5G19-A Attach and Start traffic
  AlarmWatchdog.remove_allow_alarms    fault_id=4590

12486_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
  Delete existent cell-1
  Run Keyword If  ${release}  Add New Parameters to json  ${delta_1116_0ms_10_10}
  Activate or Deactivate feature  delta_file=${delta_1116_0ms_10_10}
  Modify common json file and activate for different ENV  json_file=${delta_modify_to_16D}  old_string=${common_id}
  ...  new_string=${replace_cell_2}  diff_env=${False}
  Modify common json file and activate for different ENV  json_file=${delta_modify_to_16D}  old_string=${common_id}
  ...  new_string=${replace_cell_3}  diff_env=${False}
  # Set suite variable    ${NR_CELL_ID_MAPPING}  ${None}
  Connect to gnb coam via ssl
    8680_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
  Receiver 5G19-A Attach and Start traffic
    COAM Teardown gnb connections
    [Teardown]  CI_interface.Common Suite Setup

12486_General_SiSo_Online_Cell_Addition_Deletion
  Activate or Deactivate feature  delta_file=${delta_1208_10_10_10}
  Connect to gnb coam via ssl
  Online Cell addition deletion
  Receiver 5G19-A Attach and Start traffic

12486_Common_SiSo_Call_Multi UE throughput testing
  scf.Uploading and commissioning SCF    SCF_Filename=${SCF_80_50_50_1070}
  Connect to gnb coam via ssl
  Receiver 5G19-A Attach and Start traffic
  [Teardown]  scf.Uploading and commissioning SCF

12486_General_SiSo_custom_beam_set_realization_to_Gnb
  scf.Uploading and commissioning SCF    SCF_Filename=${SCF_Filename}
  # Set suite variable    ${NR_CELL_ID_MAPPING}  ${None}
  Connect to gnb coam via ssl
  8680_General_SiSo_custom_beam_set_realization_to_gNB  call_keyword=Receiver 5G19-A Attach and Start traffic
  [Teardown]  scf.Uploading and commissioning SCF

12486_Auto_RF_lock_unlock_with_L3call
  scf.Uploading and commissioning SCF    SCF_Filename=${SCF_60_10_10_3ms}
  Connect to gnb coam via ssl
  8680_Manual_SiSo_SM_RF_Module_lock_unlock  call_keyword=Receiver 5G19-A Attach and Start traffic
  [Teardown]  scf.Uploading and commissioning SCF

12486_RF_module_reset_from_GUI_with_L3call
  scf.Uploading and commissioning SCF  SCF_Filename=${SCF_60_20_3ms}
  # Set suite variable    ${NR_CELL_ID_MAPPING}  ${None}
  Connect to gnb coam via ssl
  8680_General_SiSo_RF_module_reset_from_GUI_with_L3call  call_keyword=Receiver 5G19-A Attach and Start traffic
  [Teardown]  scf.Uploading and commissioning SCF

Add New Parameters to json
    [Arguments]  ${file}=${delta_1116_3ms_10_10_10}
    OperatingSystem.Run    sed -i 's/"cSRS"/"srsDlBeamFallbackOption": "fallback once",\\\n\\t\\t\\t\\"cSRS"/' ${file}
    OperatingSystem.Run
    ...  sed -i 's/"bSRS"/"srsUlBeamFallbackOption": "fallback once",\\\n\\t\\t\\t\\"bSRS"/' ${file}




