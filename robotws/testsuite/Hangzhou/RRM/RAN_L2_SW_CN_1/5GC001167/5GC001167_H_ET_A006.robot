*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD        FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD    SBTS22R3
#Resource          ./5GC001167_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${SCF_FILE}         6cell_scfc.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/ta_6cell_iphy_ute.xml
#${DELTA_FILE}       Delta_conf_bufferbased.json
#${RECOV_FILE}       Delta_recov_bufferbased.json
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          1167_full_config.cfg
#${WTS_AP_XML}       case10AirPhoneConfig_l1by_fdd_sa_cmw_3CC_8366.xml
#${SCF_PATH}         ./Resource/Config
#${UE_ID}            4
#
#*** Test Cases ***
#5GC001167_ET_A006_Activation_Validation_SCellActivationMethod_BufferBased
#    SA UE Register    ${ue_id}
#    FOR    ${idx}    IN RANGE    1    3
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
#    Sleep    60s    reason=Wait For Stopping Data Transmission
#    END
#    Check 2CC Scell On EGate Console Log    ${egate_path}
