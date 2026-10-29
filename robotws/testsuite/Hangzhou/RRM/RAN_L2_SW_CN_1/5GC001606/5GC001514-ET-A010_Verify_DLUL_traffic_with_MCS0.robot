*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    RAN_5G_TDD    FR1
#...               RAN_5G    SBTS00    Owner_fanjin
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_ID}            101
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          1
#${BEARER_ID}        2
#
#*** Test Cases ***
#5GC001514-ET-A010 Verify_DLUL_traffic_with_MCS0
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
##    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
#    Sleep    5s    reason=Keep the traffic stable
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    dl    5
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    ul    5