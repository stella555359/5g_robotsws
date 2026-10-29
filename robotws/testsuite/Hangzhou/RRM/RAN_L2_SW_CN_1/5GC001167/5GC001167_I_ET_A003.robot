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
#${DELTA_FILE}       Delta_conf.json
#${RECOV_FILE}       Delta_recov.json
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          1167_full_config.cfg
#${WTS_AP_XML}       case10AirPhoneConfig_l1by_fdd_sa_cmw_3CC_8366.xml
#${SCF_PATH}         ./Resource/Config
#${UE_ID}            2
#
#*** Test Cases ***
#5GC001167_I_ET_A003_3CC_SCellActivationMethod_Blind
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
#    Get And Check PM Counter
#
#*** Keywords ***
#Get And Check PM Counter
#    [Documentation]    Average number of available Secondary cells per bearer during a sample period: M55348C00001
#    ...    Average number of used Secondary cells per bearer during a sample period (M55348C00002)
#    #<p name="reportingIntervalPm">5min</p>
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    320s    wait next pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${available_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00001
#    Should Be True    "${available_secondary_cells}"=="2"
#    ${used_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00002
#    Should Be True    "${used_secondary_cells}"=="0"
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${available_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00001
#    Should Be True    "${available_secondary_cells}"=="2"
#    ${used_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00002
#    Should Be True    "${used_secondary_cells}"=="0"
