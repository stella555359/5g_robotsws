*** Settings ***
Documentation
...  ASOG TEMP and ONAP feature

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB STATE_COMMISSIONED
Library           XML  use_lxml=True


Resource    ../../PM/test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot
Resource    ../../PM/test_resources/PM__NE3S_Interface_Setup_In_Startup.robot



Suite Setup   Run keywords   Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1746
${SKIP_RU_POWER_CHECK}    ${TRUE}
${VM_WITH_PANO_IP}       10.5.47.47
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   UTE.debian12
${VES_PORT}              30510
${ADDITIONAL_IGNORED_ALARMS}  [['faultId', '4639', ' alarmId ', '7115']]
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1676/commissioning


${LTE_MEASUREMENT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/SBTS19A__LTE_Counters_2019-07-01.csv

${LTE_ABBREVIATION_DICT_PATH}=  SEPARATOR=
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PM/counters/LTE_Abbreviations.csv



*** Test Cases ***

[1]PM__NE3S_Interface_Setup_In_Startup
    [Tags]     QC_300308
    [Setup]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Setup
    ...    AND    Modify Resource Search Order    PM__NE3S_Interface_Setup_In_Startup
    ...    AND    Set Library Search Order    PM__NE3S_Interface_Setup_In_Startup
    TC__PM__NE3S_Interface_Setup_In_Startup
    [Teardown]    Run Keywords    PM__NE3S_Interface_Setup_In_Startup.TC Teardown
    ...    AND    Restore Resource Search Order


PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Tags]     QC_300309
    [Setup]    Run Keywords
    ...    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Setup
    ...    AND    Modify Resource Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    ...    AND    Set Library Search Order    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Timeout]    21600
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]    Run Keywords    PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
