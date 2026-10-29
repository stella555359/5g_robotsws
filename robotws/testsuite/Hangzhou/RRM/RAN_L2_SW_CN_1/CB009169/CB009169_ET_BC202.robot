*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    swconfig_param=${SWCONF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Test Teardown Recover Env
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SG6    CB009169    SBTS00    AP_REG
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SWCONF}                   0x580497=1
#${SCF_PATH}                 ${CURDIR}/Config
#${SCF_FILE}                 Configuration_CB009169_BC_4F_2T_202_scf.xml
#${IPHY_FILE}                ${CURDIR}/Resources/wts/iphy_CB009169_BC_4F_2T_202.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Resources/wts
#${WTS_CFG}                  CB009169_BC_202.cfg
#${PCELL_ID}                 52
#${UE_ID}                    1    #1T+3F (DL4CC, UL2CC)
#@{SCELL_PHYSICALID_LIST}    50    51    54
#${DL_CC_NUM}                4
#${PDU_ID}                   1
#@{SCELL_INDEX_LIST1}        0    1    2    3
#@{CELL_TPUT_LIST1}          434    82    82    82
#
#*** Test Cases ***
#CB009169_ET_BC202_FR1_TDD_FDD_4CC_DL_2CC_UL_Blind_ScellAdd_BufferBaseScellActivation_IWK7737
#    SA Single UE Attach    ${UE_ID}
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_PHYSICALID_LIST}    ${DL_CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    700
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    100
#    Sleep    20s    #wait for traffic stable
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id\=${UE_ID} type\=pusch,pdsch scell\=0-5
#    wait_until_keyword_succeeds    30s    5s    Verify DL4CC Tput Within Range    ${UE_ID}    ${SCELL_INDEX_LIST1}    ${CELL_TPUT_LIST1}
#    wait_until_keyword_succeeds    30s    5s    Verify UL2CC Tput Within Range    ${UE_ID}    51    30    ${DL_CC_NUM}
#
#*** Keywords ***
#Verify DL4CC Tput Within Range
#    [Arguments]    ${UE_ID}    ${scell_index_list}    ${cell_tput_list}
#    FOR    ${id}    ${cell_tput}    IN ZIP    ${scell_index_list}    ${cell_tput_list}
#    \    ${cell_type}    Set Variable If    '${id}'=='0'    pcell    scell
#    \    ${scell_dl_tput}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=${cell_type}    scell_index=${id}
#    \    ${dl_scell_threshhold}    Evaluate    abs(${scell_dl_tput}-${cell_tput})/${cell_tput}
#    \    Should Be True    ${dl_scell_threshhold}<0.05
#    \    Log To Console    ${cell_type} ${id} TPUT ${scell_dl_tput} Is Within Range
#
#Verify UL2CC Tput Within Range
#    [Arguments]    ${UE_ID}    ${ul_pcell_tput}    ${ul_scell_tput}    ${DL_CC_NUM}
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1-${DL_CC_NUM}
#    ${ul_p_threshhold}    Evaluate    abs(${pcell_ul_tp}-${ul_pcell_tput})/${ul_pcell_tput}
#    Should Be True    ${ul_p_threshhold}<0.05
#    Log To Console    UL Pcell TPUT ${pcell_ul_tp} Is Within Range
#    ${ul_s_threshhold}    Evaluate    abs(${scell_ul_tp}-${ul_scell_tput})/${ul_scell_tput}
#    Should Be True    ${ul_s_threshhold}<0.05
#    Log To Console    UL Scell TPUT ${scell_ul_tp} Is Within Range
