*** Settings ***
Suite Setup       5822 SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Test Setup        CB005822 Case Setup
Test Teardown     CB005822 Case Teardown
Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT_UTE
...    PY39
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_Common_Keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${MAX_LOOP}        20

${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1400M
${UL_EXPECT}    50
${DL_EXPECT}    340

${UL_THROUGHPUT_peak}    210M
${DL_THROUGHPUT_peak}    1500M

${UL_THROUGHPUT_60M}    60M
${DL_THROUGHPUT_60M}    860M
${UL_EXPECT_60M}    9
${DL_EXPECT_60M}    200

${UL_THROUGHPUT_80M}    80M
${DL_THROUGHPUT_80M}    1100M
${UL_EXPECT_80M}    40
${DL_EXPECT_80M}    250

${UL_THROUGHPUT_50M}    50M
${DL_THROUGHPUT_50M}    700M
${UL_EXPECT_50M}    25
${DL_EXPECT_50M}    46

*** Test Cases ***
[1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    Connect to all rus with allocated IP
    Lock all RUs    ru_index_list=${ru_index_list}
    Unock all RUs    ru_index_list=${ru_index_list}
    ${DL_EXPECT_peak}    ${UL_EXPECT_peak}    get_theoretical_throughput
    ...     scf_path=${backup_scf_file}
    ...     cell_id=1
    ...     pucchprb = ${38}
    ${UL_EXPECT_peak}=    Evaluate    ${UL_EXPECT_peak}*0.5
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    UE Attach and Start Traffic for peak   throughput_ul=${UL_THROUGHPUT_peak}
    ...                           throughput_dl=${DL_THROUGHPUT_peak}
    ...                           target_throughput_ul=${UL_EXPECT_peak}
    ...                           target_throughput_dl=${DL_EXPECT_peak}

[1][1.0] General_SiSo_throughput_curve_execution
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and Start Traffic   throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}

[1][1.0] General_SiSo_Auto_RF_module_power_reset
    General_SiSo_RF_module_power_reset

[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset

[1][1.0] General_SiSo_90percent_of_DL_absolute_maximum_Tput
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and Check 90percent of DL absolute maximum Tput

[1][1.0] General_SiSo_KPI_Cell_lock_unlock_success_rate
    General_SiSo_KPI_Cell_lock_unlock_success_rate

[1]General_SiSo_Beamforming_Calibration_Activation
    General_SiSo_Beamforming_calibration for 5822

[1]CB005822_B_02_AQHA_L3call_with_dual_carrier_60M+100M_SA
    ${version}     get software version for 5822
    Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_60M_100M_SA.xml
    Sleep   3min
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and Start Traffic for Other   throughput_ul=${UL_THROUGHPUT_60M}
    ...                           throughput_dl=${DL_THROUGHPUT_60M}
    ...                           target_throughput_ul=${UL_EXPECT_60M}
    ...                           target_throughput_dl=${DL_EXPECT_60M}

[1]CB005822_B_03_AQHA_L3call_with_dual_carrier_80M+80M_NSA
    ${version}     get software version for 5822
    Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_80M_80M_NSA.xml
    Sleep   3min
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and Start Traffic for Other   throughput_ul=${UL_THROUGHPUT_80M}
    ...                           throughput_dl=${DL_THROUGHPUT_80M}
    ...                           target_throughput_ul=${UL_EXPECT_80M}
    ...                           target_throughput_dl=${DL_EXPECT_80M}

[1]CB005822_B_06_AQHA_L3call_with_dual_carrier_40M+50M_SA
    ${version}     get software version for 5822
    Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_40M_50M_SA.xml
    Sleep    3min
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and Start Traffic for Other   throughput_ul=${UL_THROUGHPUT_50M}
    ...                           throughput_dl=${DL_THROUGHPUT_50M}
    ...                           target_throughput_ul=${UL_EXPECT_50M}
    ...                           target_throughput_dl=${DL_EXPECT_50M}
