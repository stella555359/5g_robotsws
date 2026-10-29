*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown    debug
#...              AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD
#Resource          ./5GC001167_Resource.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${SCF_FILE}          6cell_scfc_loo.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/ta_6cell_iphy_ute_loo.xml
#${DELTA_FILE}            Delta_NRREL_Lcrid5.json
#${RECOV_FILE}            Delta_NRREL_Lcrid5.json
#${LOCAL_WTS_DIR}         ${CURDIR}/Resource/wts
#${WTS_CFG}               1167_full_config_loo.cfg
#${UE_ID}                 4
#${SCF_FILE_CHANGESCF}    Delta_NRREL_Lcrid2.json
#${SCELLINDEX}            1
#
#*** Test Cases ***
#5GC001167_ET_A010_Pass_Scenario_For_Changing_Scell_From_Cell5_To_Cell2
#    CA UE Noramlly Attach And Data Transmit
#    Check 2CC Scell On EGate Console Log    ${egate_path}
#    Delta Commission With SCF File    ${SCF_FILE_CHANGESCF}
#    Sleep    120s    reason=wait online changed succssfully
#    CA UE Noramlly Attach And Data Transmit
#    ${physCellId_list}    Get PhysCellId From Egate Log    ${SCELLINDEX}    ${egate_path}
#    Should Not Be Equal    ${physCellId_list[0]}    ${physCellId_list[1]}
#
#*** Keywords ***
#CA UE Noramlly Attach And Data Transmit
#    SA UE Register    ${UE_ID}
#    SA Start DL Traffic EGate    ${UE_ID}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${UE_ID}    ${pdu_id}    10
#    Sleep    30s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${UE_ID}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${UE_ID}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${UE_ID}    ${pdu_id}
#    Run Keyword And Ignore Error    SA 5G Detach    ${UE_ID}
