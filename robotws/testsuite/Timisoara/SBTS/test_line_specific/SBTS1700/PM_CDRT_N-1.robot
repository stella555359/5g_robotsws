*** Settings ***
Documentation  This suite contains PM test cases.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NLWG_10700_1ASIB_1ABIO_1ABIN_1FSMF_2FBBC_3AHFIB_1ABIA_3AHLOA  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.robot
Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot



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


[1]Automated__PM_check_counters_after_delete_block_lock_LTE_cell
    [Tags]     QC_255754
    [Setup]    Run Keywords    Set Test Variable    ${CELL_OPERATIONS}    delete, block, lock
    ...    AND    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Setup
    ...    AND    Modify Resource Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    ...    AND    Set Library Search Order    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Timeout]    14400
    TC__PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Teardown]    Run Keywords    PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


PM__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Tags]     QC_255753
    [Setup]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Setup
    ...    AND    Modify Resource Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    ...    AND    Set Library Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    TC__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Teardown]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
