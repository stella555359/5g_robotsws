*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
#...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${SCF_FILE}                       CB012149_Ac401_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_AA.xml
#${LOCAL_WTS_DIR}                  ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB012149_AA301.cfg
#${1T_3F_DL_DATA}                  875
#${1T_3F_UL_DATA}                  175
#@{1T_3F_EXP_DL_TPUT_LIST}         490    100    100    100
#@{1T_3F_EXP_UL_TPUT_LIST}         120    25
#@{1T_1F_EXP_DL_TPUT_LIST}         100    490
#@{1T_1F_EXP_UL_TPUT_LIST}         25    50
#@{4CC_PCELL_ID_LIST}              55
#@{4CC_SCELL_PHYSICALID_1}         50    51    53
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID_1}
#@{4CC_UE_LIST_1}                  6
#@{4CC_UE_LIST}                    6
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#@{SCELL_PHYSICALID_LIST}          50    51    53
#
#*** Test Cases ***
#CB012149_ET_AC401_UL_Tx_Switching_Single_UE_MG_A2_A3_A5_Config_Inter_Frequency_HO
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_1}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${1T_3F_DL_DATA}    ${1T_3F_UL_DATA}
#    Sleep    20s    #wait for traffic stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Trigger A2 Event For Handover    ue_id=6    srsrp_nr=11    srsrq_nr=11    meas_id=1
#    Trigger A3 Event For Handover    ue_id=6    phycell_id=50    nbr_cell_id=1    srsr_nr=11    nrsr_nr=110    meas_id=7
#    Send A1 report    ue_id=6    srsrp_nr=110    phycell_id=50    meas_id=12
#	Sleep    10s    #wait for traffic stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${1T_1F_EXP_UL_TPUT_LIST}    ${1T_1F_EXP_DL_TPUT_LIST}    2
#
#*** Keywords ***
#Verify Non CA UE DL UL Tput With In Range
#    [Arguments]    ${ue_id}    ${dl_tput}    ${ul_tput}    ${threshold}
#    ${dl_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
#    ${ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0
#    Log To Console    DL Troughput is ${dl_tp}
#    Log To Console    UL Troughput is ${ul_tp}
#    ${dl_thres}    Evaluate    abs(${dl_tp}-${dl_tput})/${dl_tput}
#    Should Be True    ${dl_thres}<${threshold}
#    ${ul_thres}    Evaluate    abs(${ul_tp}-${ul_tput})/${ul_tput}
#    Should Be True    ${ul_thres}<${threshold}
