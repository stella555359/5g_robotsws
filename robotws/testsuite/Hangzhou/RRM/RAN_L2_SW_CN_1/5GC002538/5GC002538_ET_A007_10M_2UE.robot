*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    FR1    CRT    RAN_5G_FDD    Owner_fanjin
#...               SBTS00    SBTS23R1    SBTS22R4    RAN_5G
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./5GC002538_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/resources/config
#${DELTA_FILE}       ${CURDIR}/resources/config/Delta_Conf_5GC002538_A007_10M.json
#@{UE_ID}            151    152
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          3
#${BEARER_ID}        2
#${DL_TRAFFIC}       75
#@{LOG_NAME_LIST}    btslog    snapshot
#
#*** Test Cases ***
#5GC002538_ET_A007_PDSCH_In_SSB_And_TRS_Slot_DL_Mimo_2x2_2UE_10M_NSA
#    NSA UE Attach Do DL Traffic
#    Start Gnb BIP Log
#    Sleep    3s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${output_dir}
#    Covert BIP To Csv
#    Verify Multi UE PDSCH Schedule In SSB Slot
#    Verify Multi UE PDSCH Schedule In TRS Slot
#    Verify DL Not ACK Rate Less Than Target    ${output_dir}    0.01
#
#*** Keywords ***
#NSA UE Attach Do DL Traffic
#    : FOR    ${index}    IN    @{UE_ID}
#    \    Log To Console    ===============UE${index} Attach:==============
#    \    NSA LTE Attach    ${index}    ${PROFILE_ID}
#    \    NSA 5G Attach    ${index}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
##    \    NSA Verify If Attach Passed
#    \    Set PDSCH Test Mode
#    \    NSA Start DL Traffic    ${index}    ${BEARER_ID}    ${DL_TRAFFIC}
#    \    Sleep    1s    reason=Wait For Transmission Stable
#
