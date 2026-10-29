*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_rewu
#...               SBTS00     SBTS23R2    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB009169_Aa302_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB009169_Aa302.cfg
#${DL_DATA}                      500
#${NONCA_DL_DATA}                100
#${UL_DATA}                      100
#@{3CC_UE_LIST}                  1
#${CA_UE_ID}                     1
#${NONCA_UE_ID}                  2
#${CA_PDU_ID}                    1
#${PDU_ID}                       2
#@{3CC_SCELL_PHYSICALID_1}       50    51
#@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}
#@{3CC_EXP_DL_TPUT_LIST}         3    3    3
#@{2CC_EXP_UL_TPUT_LIST}         3    3
#${NONCA_DL_TPUT}                10
#${NONCA_UL_TPUT}                10
#
#*** Test Cases ***
#CB009169_ET_AA302_T_F_SingleUE_With_2DRB_Addition_Blind_NonBF
#    SA Multi UE Attach With Scell Blind Addition    ${3CC_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${DL_DATA}    ${UL_DATA}
#    Display Multi UE Throughput    ${3CC_UE_LIST}
#    Sleep    30s
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[0]}    2
#    SA 5G PDU Session Setup For NewDRB    ${CA_UE_ID}
#    Check Throughput For CaseAA302 With NewDRB    ${CA_UE_ID}
#    SA Single UE Attach    ${NONCA_UE_ID}    ${NONCA_UE_ID}
#    SA Start DL Traffic Internal    ${NONCA_UE_ID}    ${NONCA_UE_ID}    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    ${NONCA_UE_ID}    ${NONCA_UE_ID}    ${UL_DATA}
#    Sleep    60s
#    ${NONCA_DL_TPUT}    Get CA Cell Average Throughput    ${NONCA_UE_ID}    dl    pcell    0
#    ${NONCA_UL_TPUT}    Get CA Cell Average Throughput    ${NONCA_UE_ID}    ul    pcell    0
#    Should Be True    ${NONCA_DL_TPUT}>=5    Throughtput is in the accetable range
#    Should Be True    ${NONCA_UL_TPUT}>=5    Throughtput is in the accetable range
#    Check Throughput For CaseAA302 With NewDRB    ${CA_UE_ID}
#    SA 5G PDU Session Release For NewDRB    ${CA_UE_ID}
#
#*** Keywords ***
#Check Throughput For CaseAA302 With NewDRB
#    [Arguments]    ${ue_id}
#    SA Start DL Traffic Internal    ue_id=${ue_id}    pdu_id=1    mbps=175    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${ue_id}    pdu_id=1    mbps=175    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${ue_id}    pdu_id=15    mbps=175    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${ue_id}    pdu_id=15    mbps=175    trf_id=4
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=1    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=1    dir=ul
#    Log    PDU1 DL Troughput is ${dl_tp}    console=True
#    Log    PDU1 UL Troughput is ${ul_tp}    console=True
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=15    dir=dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=15    dir=ul
#    Log    PDU2 DL Troughput is ${dl_tp}    console=True
#    Log    PDU2 UL Troughput is ${ul_tp}    console=True
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=scell    scell_index=2
#
