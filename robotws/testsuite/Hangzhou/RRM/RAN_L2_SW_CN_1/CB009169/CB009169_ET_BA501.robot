*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_rewu
#...               CN1_SG06    CB009169    SBTS00    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${SCF_FILE}                       CB009169_BA_501_701_804.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Ba1603.xml
#${LOCAL_WTS_DIR}                  ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_BA_501_701_804.cfg
#${1T_3F_DL_DATA}                  200
#${1T_3F_UL_DATA}                  80
#@{1T_3F_EXP_DL_TPUT_LIST}         3    0    0    0
#@{1T_3F_EXP_UL_TPUT_LIST}         2    2
#@{4CC_PCELL_ID_LIST}              52
#@{4CC_SCELL_PHYSICALID_1}         50    53    54
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID_1}
#@{4CC_UE_LIST_1}                  3
#@{4CC_UE_LIST}                    3
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               102
#@{SCELL_PHYSICALID_LIST}          50    53    54
#${NONCA_UE_ID}                    6
#${4CC_UE_LIST_NONCA}              3
#
#*** Test Cases ***
#CB009169_ET_BA501_T_T_100Mhz_80Mhz_Single_UE_MG_A2_A3_A5_Config_Inter_frequency_HO
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_1}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${1T_3F_DL_DATA}    ${1T_3F_UL_DATA}
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${4CC_UE_LIST_1}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[0:2]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[3:4]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Trigger A2 Event For Handover    ue_id=3
#    Display Multi UE Throughput    ${4CC_UE_LIST_1}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[0:2]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[3:4]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    SA Single UE Attach    ${NONCA_UE_ID}    ${NONCA_UE_ID}
#    Trigger A3 Event For Handover    ue_id=3    phycell_id=55    nbr_cell_id=6
#    Verify Non CA UE DL UL Tput With In Range    ${4CC_UE_LIST_NONCA}    200    38    0.05
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
