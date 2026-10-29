*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    computation
#Suite Setup       Run Keywords    Set Library Search Order    CORE
#
#...               AND    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown Peak
#Test Setup        Common Test Setup For This Case
#Test Teardown     Common Test Teardown For This Case
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
#...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB012149_Ac202_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_AA.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB012149_Ac202.cfg
#${1T_3F_DL_DATA}                  1225
#${1T_3F_UL_DATA}                  175
#@{1T_3F_EXP_DL_TPUT_LIST}         425    90    190    432
#@{1T_3F_EXP_UL_TPUT_LIST}         90    28
#@{4CC_PCELL_ID_LIST}              52
#@{4CC_SCELL_PHYSICALID}           50    54    55
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID}
#@{4CC_UE_LIST}                    3
#@{GBR_UE_LIST}                    3
#@{QFI_ID_LIST}                    3    2    3
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#&{UE3_5QI_INFO_1}                 ue_id=3    qfi=2    qosflows_id_5qi=5
#&{UE3_5QI_INFO_2}                 ue_id=3    qfi=3    qosflows_id_5qi=1
#@{UE_5QI_INFO_LIST}               ${UE3_5QI_INFO_1}    ${UE3_5QI_INFO_2}
#@{list_of_cell_ids_3}             16387
#@{list_of_cell_ids_1}             16385
#@{list_of_cell_ids_5}             16389
#@{list_of_cell_ids_6}             16390
#
#*** Test Cases ***
#CB012149_ET_AC202_UL_Tx_Switching_With_VONR_Call_And_Non_GBR_And_UE_Support_Lch_ToSCellRestriction
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${HIGH_A1THRESHOLD}    4
#    #Trigger 5QI Setup For Multi UE    ${UE_5QI_INFO_LIST}
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${1T_3F_DL_DATA}    ${1T_3F_UL_DATA}
#    #Start Multi UE SA VONR GBR DL And UL Traffic    ${GBR_UE_LIST}    ${QFI_ID_LIST}    3    3
#    Sleep    15s    reason=wair for data is stable
#    #SA Check UE Cell TPut On Target    3    1    dl    1    3
#    ${cell_1_theoretical_dl}    ${cell_1_theoretical_ul}    Get Theoretical Throughput Per Cell FDD1    1    2    1
#    ${cell_3_theoretical_dl}    ${cell_3_theoretical_ul}    Get Theoretical Throughput Per Cell TDD3    3    2    2
#    ${cell_5_theoretical_dl}    ${cell_5_theoretical_ul}    Get Theoretical Throughput Per Cell FDD2    5    2    1
#    ${cell_6_theoretical_dl}    ${cell_6_theoretical_ul}    Get Theoretical Throughput Per Cell TDD6    6    2    2
#    power_ue.Collect Tput    ue_type=airphone    duration=300    filter=L2Lo    check_source=aasyslog
#    Log to Console  \n Start to collect Tput
#    Check DL Throughput with Theoretical per Cell    ${list_of_cell_ids_3}    ${cell_3_theoretical_dl}
#    Check UL Throughput with Theoretical per Cell    ${list_of_cell_ids_3}    ${cell_3_theoretical_ul}
#    Check DL Throughput with Theoretical per Cell    ${list_of_cell_ids_1}    ${cell_1_theoretical_dl}
#    Check UL Throughput with Theoretical per Cell    ${list_of_cell_ids_1}    ${cell_1_theoretical_ul}
#    Check DL Throughput with Theoretical per Cell    ${list_of_cell_ids_5}    ${cell_5_theoretical_dl}
#    Check DL Throughput with Theoretical per Cell    ${list_of_cell_ids_6}    ${cell_6_theoretical_dl}
#
#
#*** Keywords ***
#Start Multi UE SA VONR GBR DL And UL Traffic
#    [Arguments]    ${ue_id_list}    ${qfi_id_list}    ${dl_trf}    ${ul_trf}    ${pdu_id}=1
#    FOR    ${ue_id}    ${qfi_id}    IN ZIP    ${ue_id_list}    ${qfi_id_list}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu=${pdu_id} qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu=${pdu_id} qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
#    END
#    Sleep    5s    reason=wait DL/UL traffic is stable
#
#
#Get Theoretical Throughput Per Cell TDD3
#    [Arguments]     ${cellid}=1  ${ue_dl_layer}=2   ${ue_ul_layer}=1    &{modified_parameters}
#    ${ue_dl_layer}   Convert To Integer    ${ue_dl_layer}
#    ${ue_ul_layer}   Convert To Integer    ${ue_ul_layer}
#    ${theoretical_dl}    ${theoretical_ul}     computation.Get Theoretical Throughput    scf_path=${SCF_PATH}/CB012149_Ac202_scfc.xml
#    ...    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}    pucchprb=${32}
#    Log To Console    \n Theoretical DL TP is ${theoretical_dl} for ${cellid}
#    Log To Console    \n Theoretical UL TP is ${theoretical_ul} for ${cellid}
#    [Return]  ${theoretical_dl}    ${theoretical_ul}
#
#Get Theoretical Throughput Per Cell TDD6
#    [Arguments]     ${cellid}=1  ${ue_dl_layer}=2   ${ue_ul_layer}=1    &{modified_parameters}
#    ${ue_dl_layer}   Convert To Integer    ${ue_dl_layer}
#    ${ue_ul_layer}   Convert To Integer    ${ue_ul_layer}
#    ${theoretical_dl}    ${theoretical_ul}     computation.Get Theoretical Throughput    scf_path=${SCF_PATH}/CB012149_Ac202_scfc.xml
#    ...    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}    pucchprb=${30}
#    Log To Console    \n Theoretical DL TP is ${theoretical_dl} for ${cellid}
#    Log To Console    \n Theoretical UL TP is ${theoretical_ul} for ${cellid}
#    [Return]  ${theoretical_dl}    ${theoretical_ul}
#
#Get Theoretical Throughput Per Cell FDD1
#    [Arguments]     ${cellid}=1  ${ue_dl_layer}=2   ${ue_ul_layer}=1    &{modified_parameters}
#    ${ue_dl_layer}   Convert To Integer    ${ue_dl_layer}
#    ${ue_ul_layer}   Convert To Integer    ${ue_ul_layer}
#    ${theoretical_dl}    ${theoretical_ul}     computation.Get Theoretical Throughput    scf_path=${SCF_PATH}/CB012149_Ac202_scfc.xml
#    ...    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}    pucchprb=${20}
#    Log To Console    \n Theoretical DL TP is ${theoretical_dl} for ${cellid}
#    Log To Console    \n Theoretical UL TP is ${theoretical_ul} for ${cellid}
#    [Return]  ${theoretical_dl}    ${theoretical_ul}
#
#Get Theoretical Throughput Per Cell FDD2
#    [Arguments]     ${cellid}=1  ${ue_dl_layer}=2   ${ue_ul_layer}=1    &{modified_parameters}
#    ${ue_dl_layer}   Convert To Integer    ${ue_dl_layer}
#    ${ue_ul_layer}   Convert To Integer    ${ue_ul_layer}
#    ${theoretical_dl}    ${theoretical_ul}     computation.Get Theoretical Throughput    scf_path=${SCF_PATH}/CB012149_Ac202_scfc.xml
#    ...    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}
#    Log To Console    \n Theoretical DL TP is ${theoretical_dl} for ${cellid}
#    Log To Console    \n Theoretical UL TP is ${theoretical_ul} for ${cellid}
#    [Return]  ${theoretical_dl}    ${theoretical_ul}
#
#
#Get Total Theoretical Tput
#    [Arguments]    ${ue_dl_layer}=4    ${ue_ul_layer}=2
#    Log to Console    \n Start to calculate Theoritical TPUT
#    Connect to gnb coam via ssl
#    ${list_of_cell_ids}    Get List of NR Cell ID
#    &{cell_0_modified_parameters}    Create Dictionary    DLnumberOfLayersForSSB=${1}    dlLayers=${1}    ulLayers=${0}
#    ...    DLnumberOfLayersForTRS=${0}    actSlowPrbPooling=${1}    maxCsiRsPoolingGrp=${1}
#    ${cell_0_theoretical_dl}    ${cell_0_theoretical_ul}    Get Theoretical Throughput per Cell    1    ${ue_dl_layer}    ${ue_ul_layer}
#    ...    &{cell_0_modified_parameters}
#    &{cell_1_modified_parameters}    Create Dictionary    DLnumberOfLayersForSSB=${1}    dlLayers=${1}    ulLayers=${0}
#    ...    DLnumberOfLayersForTRS=${0}    actSlowPrbPooling=${1}    maxCsiRsPoolingGrp=${0}
#    ${cell_1_theoretical_dl}    ${cell_1_theoretical_ul}    Get Theoretical Throughput per Cell    6    ${ue_dl_layer}    ${ue_ul_layer}
#    ...    &{cell_1_modified_parameters}
#    ${total_theoretical_dl}   Evaluate    ${cell_0_theoretical_dl}+${cell_1_theoretical_dl}
#    ${total_theoretical_ul}   Evaluate    ${cell_0_theoretical_ul}+${cell_1_theoretical_ul}
#
#    Log To Console    \n Total Theoretical DL TP is ${total_theoretical_dl}
#    Log To Console    \n Total Theoretical UL TP is ${total_theoretical_ul}
#    Set Suite Variable    ${list_of_cell_ids}
#    Set Suite Variable    ${cell_0_theoretical_dl}
#    Set Suite Variable    ${cell_0_theoretical_ul}
#    Set Suite Variable    ${cell_1_theoretical_dl}
#    Set Suite Variable    ${cell_1_theoretical_ul}
#    Set Suite variable    ${total_theoretical_dl}
#    Set Suite Variable    ${total_theoretical_ul}
#
#Check DL Throughput with Theoretical per Cell
#    [Arguments]    ${cell_id}    ${theoretical_dl}    ${target_avg_percent}=0.98    ${ue_index}=${0}
#    # *** Get Cell List ***
#    run keyword and continue on failure    power_ue.Check Tput    ue_type=airphone    direction=dl    target_throughput=${theoretical_dl}
#    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog    cells=${cell_id}
#
#Check UL Throughput with Theoretical per Cell
#    [Arguments]    ${cell_id}    ${theoretical_ul}    ${target_avg_percent}=0.98    ${ue_index}=${0}
#    # *** Get Cell List ***
#    run keyword and continue on failure    power_ue.Check Tput    ue_type=airphone    direction=ul    target_throughput=${theoretical_ul}
#    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog    cells=${cell_id}
#
#
#Common Suite Teardown Peak
#    [Arguments]    ${mode}=${EMPTY}    ${collect_config_file}=${FALSE}
#    [Documentation]    This keyword is to collect the logs.
#    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
#    Run Keyword And Ignore Error    Get Alarms
#    Run keyword If    '${FLAG_CATCH_SUITE_LOG}'=='${True}'    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Show Relation Errors If Exist
#    Run Keyword If    '${collect_config_file}'=='${TRUE}' and '${SUITE STATUS}'=='PASS'
#    ...    Get Config Files And Put To Local Log Server
#    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
#    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed
#    ...    Collect UTE SosReport    ${SUITE_LOG_DIRECTORY}
#    #common_log_capture.Teardown All Connections
#    ute_wtssim.Teardown All Aliases For Wts
#    Run Keyword And Ignore Error    Stop Edaemon Egate
#    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${SUITE_LOG_DIRECTORY}
#    ...    ${CURDIR}/filter_msg.txt    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt
#    Auto_Analyze_Error    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt
#
#Common Test Setup For This Case
#    [Arguments]    ${delta_jason}=${none}    ${log}=${True}
#    [Documentation]    This keyword is to update parameters for this case.
#    ...
#    ...          1. Create test directory to store the logs for case
#    ...
#    ...          2. backup scf before update and after update parameters with jason file
#    ...
#    ...          3. start logs
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${delta_jason} | No | jason file,It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
#    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
#    ...
#    ...    | *** Variables *** |
#    ...    | ${SCF_PATH} | ${CURDIR}/config |
#    ...
#    ...    Examples1: no parameter need to update
#    ...    | Common Test Setup |
#    ...
#    ...    Examples2: update parameter with jason file
#    ...    | Common Test Setup | Delta_Conf_5GC002504_ET_01.json |
#    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
#    Run Keyword If    "${TEST_LOG_DIRECTORY}"==""    Create Test Directory
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
#    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
#    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
#    Run Keyword If    "${log}"=="${True}"    common_log_capture.Start Logs    ${LOG_NAME_LIST}
#
#Common Test Teardown For This Case
#    [Arguments]    ${mode}=${EMPTY}    ${log}=${True}    ${detach_ue_id}=${EMPTY}
#    FOR    ${index}    IN RANGE    1    4
#        Log To Console    ===============Excute 'Ask scout to analyze scf' Time: ${index}==============
#        ${ret}    Run Keyword And Ignore Error    Ask scout to analyze scf    remove_postfix=${False}
#        Run Keyword Unless    '${ret[0]}'=='PASS'    Run Keyword And Ignore Error    Ask scout to analyze scf    remove_postfix=${True}
#        Exit For Loop If    '${ret[0]}'=='PASS'
#        Sleep    10s     #avoid "admin_cli_status is not running!"
#    END
