*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_log_capture.robot
#Resource    ./Resources/CB008236_resource.robot
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    CN1_SG09_SM2    RAN_5G    CRT
#
#*** Variables ***
#${LOCAL_WTS_DIR}     ${CURDIR}/Config
#${SCF_PATH}          ${CURDIR}/Config
#${SCF_8311_IWK101_1}    ${SCF_PATH}/SCF_B511_1.xml
#${SCF_8311_IWK101_2}    ${SCF_PATH}/SCF_B511_2.xml
#${IPHY_2CELL}        ${CURDIR}/Config/iphy_B511.xml
#${WTS_CFG_1}           basic_setup_B511.cfg
#${WTS_CFG_OH}           wts_oh.cfg
#@{LOG_NAME_LIST}     btslog    egatelog
#${force_reboot}      ${True}
#${rd_flag}           0x58057a = 4;0x58057d = 2151677952
#${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
#*** Test Cases ***
#
#CB008236-B-ET-B511_VoNR_UE_has_inter-gNB_CA_with_active_SCells_moves_to_cell_edge_or_RF_degrades
#    [Documentation]
#    ...    CB8311 para:
#    ...                 scellActivationMethod = bufferBased
#    ...                 scellAdditionMethod = blind
#    ...                 actSCellReleaseForInactiveSCell = timer_based_Fr1
#    ...                 scellInactivityReleaseTimer = 10 seconds
#    ...                 scellDeactivationTimerGNB = ms1280
#    ...                 actBufferBasedSCellAddition = oneShot_Dl_Fr1
#    ...   Test Steps:
#    ...                 Step1: UE moves to cell edge or its RF degrades (UL SINR)
#    ...                 Step2: UE moves to cell center or its RF condition improves
#    ...                 Step3: The data volume is reduced such that the gNB deactivates the SCells
#    ...                 Step4: Upon sCellInactivityReleaseTimer expiry, the gNB releases each SCell
#    ...                 Step5: Counter SCELL_DEACT_SAG updated
#    [Tags]    case101    TA_Mayue    Mannual_Mayue
#    Import Testline Variables For 2 GNBs
#    Create Suite Directory
#    Backup And Update Iphy Swconfig File    ${IPHY_2CELL}    ${RD}
#    log to console    Send scf to gnb2...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_2}    1    10.0.1.3
#    log to console    Send scf to gnb1...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_8311_IWK101_1}    1    10.0.1.2
#    Reboot TL And Check Configured For 2 GNBs
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_1}
#    Create Test Directory
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
#    Sleep    60s    Wait for interGNB communication interface established stable
#    Attach UE And Start Traffic For B511    1
#    #Step5
#    wait until keyword succeeds    20min    5min    Check PM Counter For SCELL_DEACT_SAG  1
#    #[Teardown]    Common Test Teardown 2
#
#*** Keywords ***
#Check PM Counter For SCELL_DEACT_SAG
#    [Arguments]    ${deactivate_times}=1
#    ${min}=  evaluate    ${deactivate_times}-1
#    ${max}=  evaluate    ${deactivate_times}+1
#    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55316C09005    CELLS/NRCELL-2/NCADU    ${min}    ${max}    2
#    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55316C09005    CELLS/NRCELL-3/NCADU    ${min}    ${max}    2
#
#Get PM Counter Latest Value From Admin
#    [Arguments]    ${counter_id}    ${counter_path}    ${bts_id}=1
#    [Documentation]    This keyword is to get counter value with counter id and counter path from admin
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${counter_id} | YES | such as M55118C01000 |
#    ...    | ${counter_path} | YES | such as CELLS/NRCELL-1/NCAC, can get from admin without the counter name |
#    ...
#    ...    Examples:
#    ...    | ${value} | Get Latest PM Counter Value With Counter Path From Admin | M55118C01000 | CELLS/NRCELL-1/NCAC |
#    ...
#    @{path_list}    Split String    ${counter_path}    /
#    Append To List    ${path_list}    ${counter_id}
#    ${path_format}    Evaluate    ''.join(["['"+x+"']" for x in ${path_list}])
#    ${status_cell}    ${value}    Run Keyword And Ignore Error    Should Contain    ${path_format}    NRCELL
#    ${path_format_2}    Remove String    ${path_format}    ['CELLS']
#    COAM.Setup Admin    bts_host=10.0.1.3
#    ${counter_dict}    COAM.Get Pm Counters    ${counter_id}
#    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}[BTS]${path_format}
#    ${counter_value_dict}    Run Keyword If    '${status_cell}'=='PASS' and '${status}'=='PASS'
#    ...    Evaluate    &{counter_dict}[BTS]${path_format}
#    ...    ELSE IF    '${status_cell}'=='PASS' and '${status}'=='FAIL'
#    ...    Evaluate    &{counter_dict}[BTS]['MRBTS-1']['NRBTS-${bts_id}']${path_format_2}
#    ...    ELSE IF    '${status_cell}'=='FAIL'    Evaluate    &{counter_dict}${path_format}
#    ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#    [Return]    ${counter_value_list[-1]}
#
#Check PM Counter Latest Value From Admin
#    [Arguments]    ${counter_id}    ${counter_path}    ${min_value}=${empty}    ${max_value}=${empty}    ${bts_id}=1
#    [Documentation]    This keyword is to check single pm counters with counter path from admin
#    ...     "${time}= ta_kiss_gnb.Get Counter File Remaining Time, counter_refresh_period=${counter_refresh_period}"
#    ...     before this keyword is recomment. then, sleep     ${time}
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${counter_id} | Yes | counter id which want to get the value |
#    ...    | ${counter_path} | Yes | counter path which display in admin but not includ counter name |
#    ...    | ${min_value} | No | the expected min value, the default value is ${empty}, if not empty, counter value should bigger than this value |
#    ...    | ${max_value} | No | the expected max value, the default value is ${empty}, if not empty, counter value should smaller than this value |
#    ...
#    ...    Examples:
#    ...    | Check PM Counter Latest Value From Admin | M55118C01000 | CELLS/NRCELL-1/NCAC | max_value=350 |
#    ...    | Check PM Counter Latest Value From Admin | M55800C00501 | BTS/MRBTS-1/CLOCK-1/GNSSE-1/NGNS | min_value=-1 |
#    ...    | Check PM Counter Latest Value From Admin | M55602C00010 | SMOD/SFP-21/CABINET-1/BBMOD-1/SFPBM | min_value=20 | max_value=1000 |
#    ${counter_value}    Get PM Counter Latest Value From Admin    ${counter_id}    ${counter_path}    ${bts_id}
#    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'!='${empty}'    Should be True    ${min_value}<${counter_value}<${max_value}
#    Run Keyword If    '${min_value}'=='${empty}' and '${max_value}'!='${empty}'    Should be True    ${counter_value}<${max_value}
#    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'=='${empty}'    Should be True    ${min_value}<${counter_value}
#    ute_reporting_portal.Report Pm Counter         ${counter_id}    ${counter_value}    Passed
#
#Attach UE
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Send Measurement Report To Trigger Scell Active
#    [Arguments]    ${UE_ID}
#    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=95    sleep_time=2
#    #Sleep    2s
#
#Send Measurement Report To Trigger Scell Deacitve
#    [Arguments]    ${UE_ID}
#    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=75
#    Sleep    2s
#
#Decrease DL Traffic To Deactivate Scell
#    [Arguments]    ${UE_ID}    ${deactivate_times}    ${trf_id_num}
#    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl trf_id\=${index}
#    END
#    Sleep   5s    reason=Wait scell deactivate successfully ...
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${deactivate_times}
#
#Check egate_console log Message
#    [Arguments]    ${A2A_ini}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    A2A_Check_RRC_Log    ${CURDIR}/A2A/rrcReconfiguration/${A2A_ini}    ${TEST_LOG_DIRECTORY}/egate_console.log    log_path=${TEST_LOG_DIRECTORY}
#
#Attach UE And Start Traffic For B511
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Modify PDU Session with VONR    1
#    Run Keyword And Continue On Failure    SA Start VONR Traffic
#    Run Keyword And Continue On Failure    Start DL Traffic    1    3
#    Run Keyword And Continue On Failure    Start UL Traffic    1    1
#    Wait Untill Scell Activated    2    1
#    #step1
#    Adjust Sinr Target Pathloss
#    Sleep    20s    wait Scell deactived...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
#    Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    1
#    Check DRX Profile    ms40    ms6    ms40
#    #step2
#    Deactive Pathloss
#    Sleep    10s    wait UL grant recovered...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    Check DRX Profile    ms6    ms6    ms40
#    #step3
#    Stop DL Traffic    1    4
#    Stop UL Traffic    1    1
#    Sleep    20s    wait traffic stop..
#    Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    1
#    #step4
#    Wait Untill Scell Released    ${UE_ID}
#
#Check Rel16 TDRA Table From Output
#    [Arguments]    ${output}    ${pusch_type}=typeB    ${rrc_times}=1
#    Should Contain    ${output}=    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
#    Should Contain    ${output}=    k2-r16
#    Should Contain    ${output}=    puschAllocationList-r16
#    Should Contain    ${output}=    mappingType-r16 ${pusch_type}
#    Should Contain    ${output}=    startSymbolAndLength-r16
#    Should Contain    ${output}=    numberOfRepetitions-r16
#    ${times}    evaluate    ${rrc_times}*17
#    Should Contain X Times    ${output}    puschAllocationList-r16    ${times}
#
#Start DL Traffic To Activate Scell
#    [Arguments]    ${UE_ID}    ${activate_times}    ${trf_id_num}    ${Scell_num}
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
#    Sleep   5s    reason=Wait scell activate successfully ...
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 2 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 3 activated successfully at airphone    ${activate_times}
#
#Check Traffic On Pcell
#    [Arguments]    ${UE_ID}    ${Scell_num}    ${dl_tp_threshold}=10
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    :FOR    ${index}    IN RANGE    1    ${Scell_num}+1
#    \    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=1
#    \    Run Keyword And Continue On Failure    Should Be True    "${scell_dl_tp}"=="0"
#
#Check UE Move to NR_RRC_INACTIVE state
#    Sleep    60s    reason=Wait for srbInactivityTimerSA expiry
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${ret1}=    OperatingSystem.Run    grep -A 10 "UE1: Is INACTIVE" /opt/iphy/latest/egate_console.log|tail -11
#    Should Contain    ${ret1}=    UE1: Is INACTIVE
#
#Check UE Not In Sag Mode by TTI
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace
#
#Attach UE And Start VONR Traffic
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Modify PDU Session with VONR    1
#    Run Keyword And Continue On Failure    SA Start VONR Traffic
#
#Check GBR Traffic On Pcell and Scell
#    [Arguments]    ${UE_ID}=1    ${Scell_num}=2    ${dl_tp_threshold}=10
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    :FOR    ${index}    IN RANGE    1    ${Scell_num}+1
#    \    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
#    \    Run Keyword And Continue On Failure    Should Be True    ${scell_dl_tp}>${dl_tp_threshold}
#
#Check GBR Traffic only On Pcell
#    [Arguments]    ${UE_ID}=1    ${Scell_num}=2    ${dl_tp_threshold}=10
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    :FOR    ${index}    IN RANGE    1    ${Scell_num}+1
#    \    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
#    \    Run Keyword And Continue On Failure    Should Be True    "${scell_dl_tp}"=="0"
#
#Check Rel15 TDRA Table for Target Cell
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-Rel15_TDRA.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-Rel15_TDRA.log
#    Check Egate Log With Message     ${egate_console_file}    pusch-TimeDomainAllocationListDCI-0-1-r16 release : NULL     1
#    Check Egate Log With Message     ${egate_console_file}    pusch-TimeDomainAllocationList setup :        3
#
#Stop DL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl trf_id\=${index}
#    END
#
#Stop UL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=ul trf_id\=${index}
#    END
#
#Start DL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
#    Sleep   5s    reason=Wait scell activate successfully ...
#
#Start UL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=50 dir=ul
#    Sleep   5s    reason=Start UL traffic ...
#
#Wait Untill Scell Activated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Wait Until Keyword Succeeds    60s    5s    Check Scell Activated    ${Scell_num}    ${activate_times}
#
#Wait Untill Scell Deactivated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Wait Until Keyword Succeeds    60s    5s    Check Scell Deactivated    ${Scell_num}    ${activate_times}
#
#Wait Untill Scell Released
#    [Arguments]    ${UE_ID}
#    Wait Until Keyword Succeeds    60s    5s    Check Whether UE In CA Mode    ${UE_ID}    1
#
#Check Scell Activated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 2 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 3 activated successfully at airphone    ${activate_times}
#
#Check Scell Deactivated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 2 deactivated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 3 deactivated successfully at airphone    ${activate_times}
#
#Check Whether UE In CA Mode
#    [Arguments]    ${UE_ID}=1    ${ca_num}=1
#    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
#    Log    ${output}
#    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
#
#Checkpoints For SAGON Set1
#    [Arguments]    ${id}
#    Check UE TP state   enabled
#    Check MCSPRB combination From Syslog    ${id}    repetition_num=2    mcs=3    prb=6
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_maxHarqTxNum_10.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_TypeB.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#
#Checkpoints For SAGON Set2
#    [Arguments]    ${id}
#    Check UE TP state   enabled
#    Check MCSPRB combination From Syslog    ${id}    repetition_num=2    mcs=4    prb=6
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_maxHarqTxNum_8.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_TypeB.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#
#Checkpoints For SAGOFF Set
#    [Arguments]    ${id}
#    Check UE TP state   disabled
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGOFF_${id}
