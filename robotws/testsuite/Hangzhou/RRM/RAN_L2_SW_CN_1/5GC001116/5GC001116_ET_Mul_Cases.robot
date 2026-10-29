*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Log To Console    1116_cases_start
#...               AND    Run Keyword and ignore error    Delta Commission With SCF File    ${CHANNEL_5_6_JASON}
#...               AND    Suite Setup Update GNB    swconfig_param=0x58012d=2
#...               AND    Suite Setup Copy WTS Config Files From QT
##...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Force Tags        CRT    RAN_5G_TDD    RAN_5G    FR1    Owner_LiLiang    PRI-High    SBTS00    SBTS23R1
#...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          5GC001116_common_keywords.robot
#
#*** Variables ***
#${SCF_PATH}             ${CURDIR}/config
#${DELTA_FILE_4005}      Delta_Conf_5GC001116_C_4005.json
#${DELTA_FILE_4010}      Delta_Conf_5GC001116_C_4010.json
#${DELTA_FILE_4013}      Delta_Conf_5GC001116_C_4013.json
#${DELTA_FILE_4015}      Delta_Conf_5GC001116_C_4015.json
#${DELTA_FILE_4016}      Delta_Conf_5GC001116_C_4016.json
#${DELTA_FILE_4017}      Delta_Conf_5GC001116_C_4017.json
#${DELTA_FILE_D_4003}    Delta_Conf_5GC001116_D_4003.json
#${DELTA_FILE_D_4005}    Delta_Conf_5GC001116_D_4005.json
#${UE_ID}                11
#${PROFILE_ID}           1
#${GNB_ID}               2
#${CELL_ID}              1
#${BEARER_ID}            2
#
#*** Test Cases ***
#5GC001116_C_4005_Single_UE_Scheduling_In_Without_Digital_BF_And_Carrier_Aggregation_With_Prach_A2_And_Mcs10
#    [Setup]  Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4005}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    Start Gnb BIP Log
#    Sleep    2s    reason=Capture BIP log
#    Run Keyword and ignore error    Stop Gnb BIP Log    ${test_log_directory}
#    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Log    DL Troughput is ${dl_tp}    console=True
#    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Log    UL Troughput is ${ul_tp}    console=True
#    NSA LTE Detach    ${UE_ID}
#    [Teardown]    Common Test Teardown
#
#5GC001116_C_4010_SSPBCH_Transmission_Initial_Access_In_Without_Digital_BF_TDLTE_Cfg26_Starting_From_Subframe_3_In_SFN_0_For_Prach_B4
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4010}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Log    DL Troughput is ${dl_tp}    console=True
#    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Log    UL Troughput is ${ul_tp}    console=True
#    NSA LTE Detach    ${UE_ID}
#    [Teardown]    Common Test Teardown
#
#5GC001116_C_4013_SSPBCH_Transmission_Initial_Access_In_Digital_BF_With_BeamSet_4_Aligned_With_TDLTE_Cfg26_Subframe_3_In_SFN_0_For_Prach_B4
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4013}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    [Teardown]    Common Test Teardown
#
#5GC001116_C_4015_SSPBCH_Transmission_Initial_Access_In_Digital_BF_With_BeamSet_8_Aligned_With_TDLTE_Cfg26_Subframe_3_In_SFN_0_For_Prach_B4
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4015}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    [Teardown]    Common Test Teardown
#
#5GC001116_C_4017_Single_UE_Scheduling_In_Digital_BF_System_With_BeamSet_8_Without_Carrier_Aggregation_With_Prach_B4_And_Mcs0
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4017}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    [Teardown]    Common Test Teardown
#
#5GC001116_D_4003_SSPBCH_Transmission_And_Initial_Access_In_Digital_BF_BeamSet_2_Between_3GHz_And_6GHz_Aligned_With_TD_LTE_Cfg27_Starting_From_SFN_0
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_D_4003}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Log    DL Troughput is ${dl_tp}    console=True
#    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Log    UL Troughput is ${ul_tp}    console=True
#    NSA LTE Detach    ${UE_ID}
#    [Teardown]    Common Test Teardown
#
#5GC001116_D_4005_SSPBCH_Transmission_And_Initial_Access_In_Digital_BF_BeamSet_6_Below_3GHz_Aligned_With_TD_LTE_Cfg27_Starting_From_SFN_0
#    [Tags]    case_d_4005
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_D_4005}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    [Teardown]    Common Test Teardown
#
#5GC001116_C_4016_Single_UE_Scheduling_In_Digital_BF_System_With_BeamSet_1_Without_Carrier_Aggregation_With_Prach_B4_And_Mcs0
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_4016}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
