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
#${WTS_CFG}          10UE_1167_loo.cfg
#${SCF_PATH}         ./Resource/Config
#
#*** Test Cases ***
#5GC001167_ET_L001_five_2CC_UE_and_five_3CC_UE_successful_SCell_addition_with_DL_UL_tput
#    Multi UE Register    1    10
#    FOR    ${ue_id}    IN RANGE    1    11
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    15
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    5s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    Run Keyword If    ${ue_id}<6    SA Check 2CC Traffic Bigger Than Target EGate    ${ue_id}    dl    0
#    Run Keyword If    ${ue_id}>5    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    0
#    END
#    Check All UE Scell On EGate Console Log    ${egate_path}
#    Get And Check PM Counter
#
#*** Keywords ***
#Multi UE Register
#    [Arguments]    ${start_ue_num}    ${stop_ue_num}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
#    Log To Console    ===============UE${ue_id} Register:==============
#    SA UE Register    ${ue_id}
#    END
#
#Check All UE Scell On EGate Console Log
#    [Arguments]    ${egate_path}
#    ${content}    OperatingSystem.Get File    ${egate_path}
#    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
#    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
#    ${index}    Create List    sCellIndex 1,    sCellIndex 1,    sCellIndex 1,    sCellIndex 1,    sCellIndex 1,
#    ...    sCellIndex 1,    sCellIndex 2,    sCellIndex 1,    sCellIndex 2,    sCellIndex 1,    sCellIndex 2,
#    ...    sCellIndex 1,    sCellIndex 2,    sCellIndex 1,    sCellIndex 2,
#    Collections.Lists Should Be Equal    ${matches}    ${index}
#
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
#    Should Be True    "${available_secondary_cells}">"0"
#    ${used_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00002
#    Should Be True    "${used_secondary_cells}">"0"
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    ${available_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00001
#    Should Be True    "${available_secondary_cells}">"0"
#    ${used_secondary_cells}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55348C00002
#    Should Be True    "${used_secondary_cells}">"0"
