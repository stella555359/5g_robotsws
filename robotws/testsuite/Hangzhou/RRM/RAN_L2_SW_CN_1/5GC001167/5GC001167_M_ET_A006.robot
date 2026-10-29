*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD        FR1    Owner_K3CHEN    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD    SBTS22R3
#Resource          ./5GC001167_Resource.robot
#
#*** Variables ***
#${WTS_CFG}     basic_l1bp_sa_call_fdd_cmwv_3CC_pcell_2scell_DSS.cfg
#${SCF_FILE}    6cell_scfc_3cell_dss_bufferbased.xml
#${UE_ID}       1
#
#*** Test Cases ***
#5GC001167_M_ET_A006_3CC_sCellActivationMethod_Buffer_based_PCELL_and_two_SCELL_DSS_enabled
#    Configure 3CELL DSS    ${PRB_LIST_10M_WITHOUT_BLANKING}    30    70    30    70
#    SA UE Register    ${ue_id}
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
#    Check Scell On EGate Console Log    ${egate_path}
