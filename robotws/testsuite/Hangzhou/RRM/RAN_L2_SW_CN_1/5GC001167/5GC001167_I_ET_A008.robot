*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown    debug
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD
#Resource          ./5GC001167_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${SCF_FILE}         6cell_scfc_loo.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/ta_6cell_iphy_ute_loo.xml
#${DELTA_FILE}       Delta_conf_bufferbased.json
#${RECOV_FILE}       Delta_recov_bufferbased.json
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          1167_full_config_loo.cfg
#${SCF_PATH}         ./Resource/Config
#${PRO_ID}           5
#${UE_ID}            2
#
#*** Test Cases ***
#5GC001167_I_ET_A008_Overheating_Handling_interwork
#    SA UE Register    ${ue_id}
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    10s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    Set SCell1 Overheating And Check Tput
#    Set SCell1 And SCell2 Overheating And Check Tput
#    Recover SCell1 And SCell2 From Overheating And Check Tput
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
#    Check Scell On EGate Console Log    ${egate_path}
#
#*** Keywords ***
#Set SCell CQI And Check Tput
#    [Arguments]    ${ue_id}    ${PRO_ID}    ${cqi_num}    ${scell_lst}
#    FOR    ${scell_id}    IN    @{scell_lst}
#    Set CQI For Overheating    ${ue_id}    ${PRO_ID}    ${cqi_num}    ${scell_id}
#    END
#    Sleep    10s    reason=Wait For Data Transmission
#    ${pcell_tput}    Get CA Cell Average Throughput    ${ue_id}    dl    pcell    0
#    ${scell1_tput}    Get CA Cell Average Throughput    ${ue_id}    dl    scell    1
#    ${scell2_tput}    Get CA Cell Average Throughput    ${ue_id}    dl    scell    2
#    ${scelltput_lst}    Create List    ${pcell_tput}    ${scell1_tput}    ${scell2_tput}
#    [Return]    @{scelltput_lst}
#
#Set SCell1 Overheating And Check Tput
#    ${scell_lst}    Create List    1
#    @{scelltput_lst}    Set SCell CQI And Check Tput    ${ue_id}    ${PRO_ID}    0    ${scell_lst}
#    Should Be True    @{scelltput_lst}[0]>=${expected_tput_dl}
#    Should Not Be True    @{scelltput_lst}[1]>=${expected_tput_dl}
#    Should Be True    @{scelltput_lst}[2]>=${expected_tput_dl}
#
#Set SCell1 And SCell2 Overheating And Check Tput
#    ${scell_lst}    Create List    1    2
#    @{scelltput_lst}    Set SCell CQI And Check Tput    ${ue_id}    ${PRO_ID}    0    ${scell_lst}
#    Should Be True    @{scelltput_lst}[0]>=${expected_tput_dl}
#    Should Not Be True    @{scelltput_lst}[1]>=${expected_tput_dl}
#    Should Not Be True    @{scelltput_lst}[2]>=${expected_tput_dl}
#
#Recover SCell1 And SCell2 From Overheating And Check Tput
#    ${scell_lst}    Create List    1    2
#    @{scelltput_lst}    Set SCell CQI And Check Tput    ${ue_id}    ${PRO_ID}    15    ${scell_lst}
#    Should Be True    @{scelltput_lst}[0]>=${expected_tput_dl}
#    Should Be True    @{scelltput_lst}[1]>=${expected_tput_dl}
#    Should Be True    @{scelltput_lst}[2]>=${expected_tput_dl}
