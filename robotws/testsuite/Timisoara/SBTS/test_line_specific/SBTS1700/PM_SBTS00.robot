*** Settings ***
Documentation  This suite contains PM test cases.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_10700_1ASIB_1ABIO_1ABIN_1FSMF_2FBBC_3AHFIB_1ABIA_3AHLOA  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime.robot
Resource    ../../PM/test_resources/PM__Latest_measurement_files_history_available_on_flash.robot
Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.robot
Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot
Resource    ../../PM/test_resources/PM__Check_Counters_Number_On_NetAct_Reports.robot
Resource    ../../PM/test_resources/PM__PPM_File_Transfer_To_Mantaray.robot
Resource    taf/rfrl/scrambling_logs_collector/Keywords.robot




Suite Setup   Run keywords   Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1700
${SKIP_RU_POWER_CHECK}    ${TRUE}


${PM__WBTS_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  SBTS_WBTS19_selected_groups_0207.csv

${PM__WBTS_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  WCDMA_Abbreviations.csv

${PM__LTE_counter_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   SBTS19A__LTE_Counters_10700.csv

${PM__LTE_counter_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   LTE_Abbreviations.csv

${PM__TRS_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  TRS_NIDD_2019-03-28.csv

${PM__SBTS19A_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   SBTS19A_Counters_10700_limited.csv

${PM__LTE_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   LTE_Abbreviations.csv

${PM__TNL_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  TNL_NIDD_target_TRUNK.csv

${PM__WCDMA_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  WCDMA_FULL_NIDD_2019-03-12.csv


${PM__TNL_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  TNL_Abbreviations.csv

${PM__WBTS_M5015_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   WBTS_M5015_CountersWithoutMetaData_2020-08-07.csv

${PM__WCDMA_counters_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   WCDMA_Abbreviations.csv

${PM__WBTS19_counters_MEASUREMENT_PATH}=  SEPARATOR=
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...   SBTS_WBTS19_selected_groups_0207.csv

${LTE_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
    ...  SBTS19A__LTE_Counters_2019-07-01.csv

${LTE_M804x_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/M8046_M8047_M8048_2021-02-05.csv

${LTE_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/LTE_Abbreviations.csv




${PM__NR_MEASUREMENT_PATH}                   SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       SBTS24R3_NR_Counters_10700.csv


${PM__NR_counters_ABBREVIATION_DICT_PATH}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/
...                                                       NR_Abbreviations.csv


*** Test Cases ***
PM__Check_Counters_Number_On_NetAct_Reports
    [Tags]     QC_274889
    [Setup]    Run Keywords
    ...    Set Test Variable    ${WEB_URL}    srnclab5012lbwas.srnblr.nsn-rdnet.net
    ...    AND    Set Test Variable    ${CMWAS_SERVICE_IP}    10.8.103.185
    ...    AND    PM__Check_Counters_Number_On_NetAct_Reports.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    ...    AND    Set Library Search Order    PM__Check_Counters_Number_On_NetAct_Reports
    TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Teardown]    Run Keywords    PM__Check_Counters_Number_On_NetAct_Reports.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Tags]     QC_132958
    [Setup]    Run Keywords    Set Test Variable    ${skip_parameter_relation_errors}    True
    ...    AND    Set Test Variable    ${DISABLE_WATCHDOG}    ${TRUE}
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...           [['faultId', '6150', ' alarmId ', '7107'], ['faultId', '1898', 'alarmId', '7108']]
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime.TC Setup
    ...    AND    Modify Resource Search Order    PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    ...    AND    Set Library Search Order    PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Timeout]    14400
    TC__PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Teardown]    Run Keywords    PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime.TC Teardown
    ...    AND    Restore Resource Search Order


[1]PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_132960
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run Keyword And Ignore Error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR1
    ...    input_logs_dir=${NONE}


[1]Automated__PM_check_counters_after_delete_block_lock_LTE_cell
    [Tags]     QC_132957
    [Setup]    Run Keywords    Set Test Variable    ${CELL_OPERATIONS}    delete, block, lock
    ...    AND    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    ...    AND    Set Library Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Timeout]    14400
    TC__PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Teardown]    Run Keywords    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


PM__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Tags]     QC_177269
    [Setup]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Setup
    ...    AND    Modify Resource Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    ...    AND    Set Library Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    TC__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Teardown]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Teardown
    ...    AND    Restore Resource Search Order


PM__PPM_File_Transfer_To_Mantaray
    [Tags]     QC_240932
    [Setup]    Run Keywords
    ...    PM__PPM_File_Transfer_To_Mantaray.TC Setup
    ...    AND    Modify Resource Search Order    PM__PPM_File_Transfer_To_Mantaray
    ...    AND    Set Library Search Order    PM__PPM_File_Transfer_To_Mantaray
    TC__PM__PPM_File_Transfer_To_Mantaray
    [Teardown]    Run Keywords    PM__PPM_File_Transfer_To_Mantaray.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
