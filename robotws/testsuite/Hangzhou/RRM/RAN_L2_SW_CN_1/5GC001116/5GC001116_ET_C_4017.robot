*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Delta Commission With SCF File    ${CHANNEL_5_6_JASON}
#...               AND    Suite Setup Update GNB    scf_file=${DELTA_FILE}    swconfig_param=0x58012d=2
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        RAN_5G_TDD    RAN_5G    FR1    Owner_LiLiang    PRI-High    SBTS00    SBTS23R1    SBTS22R4
#...               CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          5GC001116_common_keywords.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/config
#${DELTA_FILE}       Delta_Conf_5GC001116_C_4017.json
#${UE_ID}            11
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          1
#${BEARER_ID}        2
#
#*** Test Cases ***
#5GC001116_C_4017_Single_UE_Scheduling_In_Digital_BF_System_With_BeamSet_8_Without_Carrier_Aggregation_With_Prach_B4_And_Mcs0
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    Check Slottype For 1116    B4_C4017
#
