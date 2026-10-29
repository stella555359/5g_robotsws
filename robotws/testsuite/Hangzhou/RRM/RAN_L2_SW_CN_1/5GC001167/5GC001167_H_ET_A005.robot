*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CIT    FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD    CDRT    SBTS22R3
#Resource          ./5GC001167_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${SCF_FILE}         6cell_scfc_loo.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/ta_6cell_iphy_ute_loo.xml
#${DELTA_FILE}       Delta_conf_bufferAndRLQualityBased.json
#${RECOV_FILE}       Delta_recov.json
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          1167_full_config_loo.cfg
#${SCF_PATH}         ./Resource/Config
#${PRO_ID}           1
#${UE_ID}            2
#
#*** Test Cases ***
#5GC001167_ET_A005_Activation_Scell_With_BufferAndRLQualityBased_Method
#    SA UE Register    ${ue_id}
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    170
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    10s    reason=Wait For Data Transmission
#    ${bler_lst}    Create List    0    100    200    0
#    FOR    ${bler_num}    IN    @{bler_lst}
#    Set Bler To UE    ${ue_id}    ${PRO_ID}    ${bler_num}
#    Sleep    5s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    END
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
