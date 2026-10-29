*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Get And Update BSR File    ${BSR_FILE_NAME}
#...               AND    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SG6    CB009169    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}            ${CURDIR}/Config
#${SCF_FILE}            Configuration_CB009169_BC_3F_1T_1002_scf.xml
#${IPHY_FILE}           ${CURDIR}/Resources/wts/iphy_CB009169_BC_3F_1T_1002.xml
#${LOCAL_WTS_DIR}       ${CURDIR}/Resources/wts
#${WTS_CFG}             CB009169_BC_1002.cfg
#${SCELL_PHYSICALID}    52
#${DL_CC_NUM}           2
#${PDU_ID}              1
#@{UE_LIST}             1    2    3    4    #T+F(DL2CC+UL2CC)
#@{UL_TPUT_LIST}        25    7
#@{DL_TPUT_LIST}        100    19
#${BSR_FILE_NAME}       BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
#${PROFILE1}            ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
#${PROFILE2}            ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
#${PROFILE3}            ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=3 trigger_puxch_update\=0
#${PROFILE4}            ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=4 trigger_puxch_update\=0
#${SET_PROFILE1}        ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#${SET_PROFILE2}        ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#${SET_PROFILE3}        ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#${SET_PROFILE4}        ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#
#*** Test Cases ***
#CB009169_ET_BC1002_1TDD_1FDD_UL2CC_Blind_ScellAdd_BufferBaseScellAct_IWK8360_4UEs_PairedInOneSubcell
#    Attach 4UE AND Check Scell
#    Set Ue Position
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST}    175    50
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${UE_LIST}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${UE_LIST}    ${UL_TPUT_LIST}    ${DL_TPUT_LIST}    ${DL_CC_NUM}
#    CUDU L2 Capture And Decode TTitrace    1    3
#    A2A Check CSV Table    ${CURDIR}/A2A/CB009169_BC/CB009169_BC1002_ulmumimo.ini    output_ul.csv    ${test_log_directory}/ttitrace/1/
#    SA Multi UE Detach    ${UE_LIST}
#
#*** Keywords ***
#Set Ue Position
#    FOR    ${id}    IN RANGE    1    5
#    \    ute_wtssim.Execute Egate Command    cmd=${PROFILE${id}}
#    \    ute_wtssim.Execute Egate Command    cmd=${SET_PROFILE${id}}
#    \    Sleep    2s    #wait for stable
#
#Attach 4UE AND Check Scell
#    FOR    ${ue_id}    IN    @{UE_LIST}
#    \    SA 5G CA Attach    ${ue_id}
#    \    Check SA Scell PhysicalID With UE ID    ${ue_id}    ${SCELL_PHYSICALID}    scell_index=1
