*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1
#...               Owner_haifewan    CN1_SQ    SBTS00    RAN_5G    RAN_5G_FDD
#Resource          ./CB008366_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${SCF_FILE}         basic_2T4F_SCFC.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/iphy_2T4F.xml
#${DELTA_FILE}       Delta_conf.json
#${RECOV_FILE}       Delta_recov.json
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          basic_2T4F.cfg
#${WTS_AP_XML}       basic_2T4F.xml
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${UE_ID}            4
#
#*** Test Cases ***
#CB008366_ET_A001_activation_validation_with_sCellAdditionMethod_Blind_and_sCellActivationMethod_Blind_on_ABIO
#    SA UE Register    ${ue_id}
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
#    Check 2CC Scell On EGate Console Log    ${egate_path}
