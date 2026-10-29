*** Settings ***
Documentation  This suite contains PM test cases.

Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LW_1FSMF_1FBBC_1FSMF_2FBBC_2FRGX_2FXJB_1AHDB
Library           XML  use_lxml=True

Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot



Suite Setup   Run keywords   Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


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


PM__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Tags]     QC_162177
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
