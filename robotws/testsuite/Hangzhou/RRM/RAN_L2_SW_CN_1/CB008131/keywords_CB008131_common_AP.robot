*** Settings ***

Library    OperatingSystem
Resource    ../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${NSA_DL}                           5
${NSA_UL}                           5
${GSCN_10M_CA002}                   1582
${GSCN_10M_C019}                    1582
${GSCN_10M}                         1589
${GSCN_20M}                         1
${UE_ID}                            1
${PDU_ID}                           1
${PROFILE_ID}                       1
${GNB_ID}                           2
${CELL_ID}                          1
${BEARER_ID}                        2
${TestLine_Type_NSA}                NSA
${TestLine_Type_SA}                 SA
${OPENLOOP_FLAG}                    OpenLoop
${CLOSELOOP_FLAG}                   CloseLoop
${NO_UL_ZEROPADDING}                False
${UL_ZEROPADDING}                   True
${UciOnly_False}                    0
${UciOnly_True}                     1
${Measurement_Gap_True}             1
${OpenLoop_WO_CsiPart2_True}        1
${OpenLoop_WO_CsiPart2_False}       0
${2CC}                              2
${3CC}                              3
${BLIND}                            0
${COVBASEDA1}                       1
${A2_REL_SCELL}                     1
${NO_A2_REL_SCELL}                  0
${2CC_INTRA_BAND_FF_SCELL}      ('1', '51', '66')
${2CC_INTER_BAND_FF_SCELL}      ('1', '51', '71')
${3CC_INTRA_BAND_FFF_SCELLS}    ('1', '51', '66'), ('2', '52', '71')
${3CC_INTER_BAND_FFF_SCELLS}    ('1', '51', '2'), ('2', '52', '66')
${FT_2CC_SCELL}                 ('9', '50', '41')
${FT_2CC_SCELL_B008}            ('6', '50', '41')
${FT_2CC_SCELL_10M}             ('1', '50', '41')

${NEW_WTS_DIR}                 /opt/iphy/latest
${IPHY_DIR}                    /ffs/run/simmode/
${LOCAL_WTS_DIR}               ${CURDIR}/Resource/WTS_CFG
${LOCAL_IPHY_DIR}              ${CURDIR}/Resource/IPHY
${LOCAL_CFG_DIR}               ${CURDIR}/Resource/
${RIGHT_GNB_SH}                ABIO_BIP_mirroring_2slot_right.sh
${gNB_swconfig}                gNB_swconfig.txt
${ap_swconfig}                 ap_swconfig.txt  
${L1BypassMap}                 ${empty}
*** Keywords ***
L1b To Fullstack Tag
    [Timeout]    1min
#    Check L1bypass Tag In GNB
#    ${L1BypassMap}    Get L1BypassMap From L1bypass GNB
#    Set Suite Variable    ${L1BypassMap}
    Delete L1bypass Tag From GNB
#    Check L1bypass Tag Not In GNB

Common Suite Setup
    Suite Setup Update GNB

Recover L1b Tag
    Add L1bypass Tag To GNB     ${L1BypassMap}
    Check L1bypass Tag In GNB

Release Scell And Capture BIP Log
    [Arguments]    ${tc_id}    ${cell_nums}    ${measurement_gap}=0
    Run Keyword If    '${cell_nums}'=='${3CC}' and '${measurement_gap}'=='0'   Run Keywords
    ...           Scell Released By A2 Event    1    3    2
    ...    AND    Sleep    10s    reason=For the log
    ...    AND    Start And Stop BIP LOG For Two ABIOs    10    ${tc_id}    2
    ...    AND    Scell Released By A2 Event    1    2    1
    ...    AND    Start And Stop BIP LOG For Two ABIOs    10    ${tc_id}    3
    Run Keyword If    '${cell_nums}'=='${3CC}' and '${measurement_gap}'=='1'    Run Keywords
    ...           Start BIP LOG For Two ABIOs    15    ${tc_id}    2
    ...    AND    Scell Released By A2 Event    1    4    2
    ...    AND    Sleep    5s    reason=For the log
    ...    AND    Stop BIP LOG For Two ABIOs    10    ${tc_id}    2
    ...    AND    Sleep    5s    reason=For the log
    ...    AND    Start BIP LOG For Two ABIOs    15    ${tc_id}    3
    ...    AND    Scell Released By A2 Event    1    3    1
    ...    AND    Sleep    5s    reason=For the log
    ...    AND    Stop BIP LOG For Two ABIOs    10    ${tc_id}    3
    Run Keyword If    '${cell_nums}'=='${2CC}'     Run Keywords
    ...           Scell Released By A2 Event    1    2    1
    ...    AND    Sleep    10s    reason=For the log
    ...    AND    Start And Stop BIP LOG For Two ABIOs    10    ${tc_id}    2
    Sleep    5s    reason=For the log

Get And Check Cells TP 
    [Arguments]    ${dir}    ${cell_nums}
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Log To Console    Pcell Throughtput of ${dir} is ${pcell_tput}
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell__tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Log To Console    Scell${id} Throughtput of {dir} is ${scell__tput}.
    END

Capture TTItrace And BIP Logs
    [Arguments]    ${interface}=L1-L2
    [Documentation]    L2Hi-L2Lo for L1y. L1-L2 fullstack.
    Log To Console     start ttitrace...
    Teardown All Connections
    Start Ttitrace With Streaming Mode
    Sleep    5s    reason=Wait for logs
    Stop Ttitrace    log_dir=${OUTPUT_DIR}
    Teardown All Connections
    Start GNB BIP By Admin Method    0    ${interface}    Local
    Sleep    10s    reason=Wait for logs
    Stop Gnb BIP By Admin Method   ${SUITE_LOG_DIRECTORY}    ${interface}    Local    0
    Collect GNB BIP By Admin Method8131    ${SUITE_LOG_DIRECTORY}

Collect GNB BIP By Admin Method8131
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring_*.pcap
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 capinfos -aeS /tmp/CCSPacketCapture/*.pcap
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls -al /tmp/CCSPacketCapture
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
    Sleep    5s    reason=Wait for scp logs
    #Run    ls -1 ${log_path}
    Run    mergecap -a -w ${log_path}/5GBipL2L1_filtering_off.pcap0 ${log_path}/mirroring_*.pcap
    ${bip_file}=    Set Variable    ${log_path}/5GBipL2L1_filtering_off.pcap0
    OperatingSystem.File Should Exist    ${bip_file}
    Run    capinfos -aeS ${log_path}/*.pcap
    Log To Console    bip log:${bip_file}
    [Return]    ${bip_file}

Get And Check Cells TP For UL
    ${pcell_tput}    Get CA Cell Average Throughput    1    ul    pcell    0
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of UL is abnormal.

Start And Stop BIP LOG For Two ABIOs
    [Arguments]    ${log_duration}    ${case_name}    ${id}    ${interface}=L1-L2
    Start GNB BIP By Admin Method    0    ${interface}    Local
    Sleep    ${log_duration}s    reason=Wait for logs
    Stop Gnb BIP By Admin Method   ${SUITE_LOG_DIRECTORY}/${case_name}/${id}    ${interface}    Local    0
    Collect GNB BIP By Admin Method8131    ${SUITE_LOG_DIRECTORY}/${case_name}/${id}

Start BIP LOG For Two ABIOs
    [Arguments]    ${log_duration}    ${case_name}    ${id}
    Start Gnb BIP Log For Two ABIOs    ${RIGHT_GNB_SH}
    Sleep    ${log_duration}s        reason=For the log

Stop BIP LOG For Two ABIOs
    [Arguments]    ${log_duration}    ${case_name}    ${id}
    Stop Gnb BIP Log For Two ABIOs   ${SUITE_LOG_DIRECTORY}/${case_name}/${id}

Convert BIP To CSV By MCShark For CRC And DTX
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    3gpp.subcellid
    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
    ...     ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}

Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
    [Arguments]    ${tc_id}
    Log To Console    Check A-CSI in PdcchSendReq.
    Convert BIP To CSV By MCShark For CRC And DTX    ${tc_id}
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.csv

Check PCSI Periodicity On Each Cell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${case_id}/ttitrace_1_pcsi.ini    ${csv_file_path}/output_ul.csv     

Check ACSI Periodicity On PCell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${case_id}/ttitrace_1_acsi.ini    ${csv_file_path}/output_ul.csv   

Convert BIP To CSV And Check Pcsi On Scell   
    [Arguments]    ${tcid}    ${cell_nums}    ${scell1_measid}=2    ${scell2_measid}=3
    ${filter}    catenate     nr-rrc.MeasId == ${scell1_measid}||nr-rrc.MeasId ==${scell2_measid}
    ...    ||UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 3
    @{csv_title_list}=    Create List    3gpp.subcellid    UlData_PucchReceiveRespPs_t.slotForProcessing
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${logid}    evaluate    ${id}+1
        Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/${tcid}/${logid}/5GBipL2L1_filtering_off.pcap0
        ...     ${OUTPUT_DIR}/csv_TC${tcid}_pcsi_report_${logid}.csv    ${filter}    ${csv_title_list}
        A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tcid}/ttitrace_pcsi_report_${logid}.ini    ${OUTPUT_DIR}/csv_TC${tcid}_pcsi_report_${logid}.csv
    END

Capture TTItrace
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    3s    reason=Wait for logs
    Stop Ttitrace    log_dir=${OUTPUT_DIR}

Capture BIP Log
    Start Gnb BIP Log For Two ABIOs    ${RIGHT_GNB_SH}
    Sleep    10s    reason=Wait for logs
    Stop Gnb BIP Log For Two ABIOs   ${SUITE_LOG_DIRECTORY}
    Sleep    30s    reason=Wait for the process handling.

Capture BIP LOG II
    [Arguments]    ${log_duration}    ${case_name}    ${id}
    Start Gnb BIP Log For Two ABIOs    ${RIGHT_GNB_SH}
    Sleep    ${log_duration}s        reason=For the log
    Stop Gnb BIP Log For Two ABIOs   ${SUITE_LOG_DIRECTORY}/${case_name}/${id}

Prepare Test TL
    [Documentation]    This keyword is to prepare the common configuration for TL.
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Set SCF Path
    Set Suite Variable    ${WTS_DIR}    ${NEW_WTS_DIR}
    #Deploy GNB BIP Script

Setup TL For Test Case
    [Arguments]    ${ru_nums}    ${scf_file}    ${iphy_name}    ${cfg_name}    ${EnableDynBetaOff}=2
    ...    ${EnableBetaOptimistic}=0    ${ACsiCheckDlLoad}=1
    ...    ${ucionly}=0    ${ModeratePayloadSizeThr}=0x2    ${CqiJitterTimer}=0x28    ${AcsiHighJitterTimer}=0x28
    ...    ${CqiDeltaThreshold}=0    ${gscn}=1    ${nsa_sa_flag}=NSA    ${OpenLoopwocsipart2}=2
    ...    ${rdACsiEligibilityAgeThreshold}=0x50
#    Backup Gnb Sw Configuration
#    Backup AP Config File
#    Configurate Airphone For CA    ${iphy_name}
    Log To Console     \nSend Swconfig for GNB....\n
    Send Swconfig for GNB    /home/ute/testline_init_results/configs/sm_swconfig.txt
	Log To Console     \nSend Swconfig for AP....\n
    Send Swconfig for AP     /home/ute/testline_init_results/configs/sim_swconfig.txt
	Log To Console     \nModify IPHY File And Send to Airphone....\n
    Modify IPHY File And Send to Airphone    ${CURDIR}/Resource/IPHY/${iphy_name}
	Log To Console     \nModify Gnb Sw Configuration For ACSI....\n
    Modify Gnb Sw Configuration For ACSI    ${EnableDynBetaOff}    ${EnableBetaOptimistic}    ${ACsiCheckDlLoad}    ${ucionly}
    ...    ${ModeratePayloadSizeThr}    ${CqiJitterTimer}    ${AcsiHighJitterTimer}    ${CqiDeltaThreshold} 
    ...    ${OpenLoopwocsipart2}    ${rdACsiEligibilityAgeThreshold}
    Run Keyword If    "${SW_VERSION}"==""    Get Software Version
    Run Keyword If    "${SW_VERSION}"=="SBTS00"    Add rdEnable6137Fr1CaDrxSolution
#    Configure Gnb With Full SCF For Local TL    ${scf_file}
    Log To Console     \nConfigure SCF,Reboot testline....\n
    Full Commission With SCF File    ${scf_file}
    Sleep     120s     \nFor Site reset
#    Check CA TL Is Ready    ${ru_nums}
    Verify Coam Site Is Ready With New Cfg
    Start UTE WTS And Check Cell Setup    ${cfg_name}    ${ru_nums}

Add rdEnable6137Fr1CaDrxSolution
     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x58062d=1">>/ffs/run/swconfig.txt'
     Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'crasign /ffs/run/swconfig.txt'

Verify Coam Site Is Ready With New Cfg
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured

Get Cfg Files And Recover TL For Each Case
    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
    Common Suite Teardown 2
    Recover Gnb Sw Configuration
    Recover AP Config File
    Recover Config
    Clean Edaemon And Egate

Get Cfg Files And Recover TL For Each Case3
    [Arguments]    ${destlog_path}=${OUTPUTDIR}/"${SUITE_NAME}"/${TEST_NAME}
    Save Egate Log    ${OUTPUT_DIR}/${TEST_NAME}
#    Note: Do not delete below 3 lines,it helps CRT.   
#    OperatingSystem.Run    mv ${OUTPUTDIR}/output_ul.csv ${destlog_path}/output_ul.csv
#    OperatingSystem.Run    mv ${OUTPUTDIR}/output_dl.csv ${destlog_path}/output_dl.csv
#    OperatingSystem.Run    mv ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0 ${destlog_path}/5GBipL2L1_filtering_off.pcap0
    Clean Edaemon And Egate

Start L3 Call And BIP Log
    [Arguments]    ${sa_flag}    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}
    ...    ${A2_flag}    ${cell_nums}    ${tc_id}    ${cell_id}    ${measurement_gap}=0    ${MBPS}=60
    Run Keyword If    '${sa_flag}'=='SA' and '${measurement_gap}'=='0'
    ...    L3 Call With SA    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}    ${A2_flag}    ${cell_nums}    ${tc_id}
    ...    ${measurement_gap}    ${MBPS}
    Run Keyword If    '${sa_flag}'=='SA' and '${measurement_gap}'=='1'
    ...    L3 Call With SA For MG    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}    ${A2_flag}    ${cell_nums}
    ...    ${tc_id}    ${measurement_gap}
    Run Keyword If    '${sa_flag}'=='NSA'
    ...    L3 Call With NSA    ${scell_add_method}    ${A2_Flag}    ${tc_id}    ${cell_id}    ${MBPS}
    Sleep    10s    reason=Keep for the log collection

L3 Call With NSA
    [Arguments]    ${scell_add_method}    ${A2_Flag}    ${tc_id}    ${cell_id}    ${MBPS}
    Set Suite Variable    ${UE_ID}    11
    Setup X2 Connection
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
    NSA Verify If Attach Passed
    #Start Gnb BIP Log
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${MBPS}    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
    Run Keyword If    '${scell_add_method}'=='1'
    ...     Scell Addition Triggered By A1 Event    ue_id=${UE_ID}
    Sleep    10s    reason=Keep the traffic stable
    Capture TTItrace And BIP Logs
    Get And Check Cells TP For NSA    ${UE_ID}    dl    8
    Run Keyword If    '${A2_Flag}'=='1' 
    ...    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}
    NSA Stop Traffic    11    2    dl
    NSA LTE Detach    ${UE_ID}

L3 Call With NSA FOR UCIOnly
    [Arguments]    ${scell_add_method}    ${A2_Flag}    ${tc_id}    ${cell_id}    ${MBPS}
    Set Suite Variable    ${UE_ID}    11
    Setup X2 Connection
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    ute_wtssim.Execute Egate Command    enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${MBPS}    1
    Run Keyword If    '${scell_add_method}'=='1'
    ...     Scell Addition Triggered By A1 Event    ue_id=${UE_ID}
    Sleep    10s    reason=Keep the traffic stable
    Trigger CQI Change And Capture Logs
    #Get And Check Cells TP For NSA    ${UE_ID}    dl    5
    Run Keyword If    '${A2_Flag}'=='1' 
    ...    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}
    NSA Stop Traffic    11    2    dl
    NSA LTE Detach    ${UE_ID}

L3 Call With SA
    [Arguments]    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}
    ...    ${A2_Flag}    ${cell_nums}    ${tc_id}    ${measurement_gap}=0    ${MBPS}=175
    Set Suite Variable    ${UE_ID}    1
    SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175
    Run Keyword If    '${ul_zeropadding}'=='False'
    #...    SA Start UL Traffic Egate Command    1    15
    ...    SA Start UL Traffic Internal    1    1    15
    Run Keyword If    '${scell_add_method}'=='1'
    ...     Scell Addition Triggered By A1 Event
    Run Keyword If    '${measurement_gap}'=='1'
    ...     Measurement Gap Triggered By A2 Event
    Run Keyword If    '${ucionly}'=='1'
    ...    ute_wtssim.Execute Egate Command
    ...    ue_cqi_param id\=1 on\=nr nr_cqi\=15 nr_cqi_mode\=oneway nr_cqi_min\=4 nr_cqi_max\=15 nr_cqi_step\=-1 nr_cqi_period\=32
    Capture TTItrace And BIP Logs
    Get And Check Cells TP    dl    ${cell_nums}
    Run Keyword If    '${ul_zeropadding}'=='False'
    ...    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
    Run Keyword If    '${A2_Flag}'=='1' 
    ...    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}
    SA Stop DL Traffic Egate Command    1
    Run Keyword If    '${ul_zeropadding}'=='False'
    ...    SA Stop UL Traffic Egate Command    1

L3 Call With SA With Iperf
    [Arguments]
    Set Suite Variable    ${UE_ID}    1
    Sleep    10s
    SA 5G Attach    ${UE_ID}
    # ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    #...    ue_register id\=1    pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    #${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DLUL TCP Traffic
    Capture TTItrace And BIP Logs


SA Start DLUL TCP Traffic
    [Arguments]    ${dlmbps}=100    ${ulmbps}=10    ${duration}=200
    [Documentation]    This keyword is to start DL and UL TCP traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 10s |
    ...    Example:
    ...    | SA Start DLUL TCP Traffic | 20 | 10 | 10 |
    Log To Console    ready to start DL and UL TCP traffic at the same time...
    Log To Console    start DL traffic...
    Execute Iperf In Linux    args=-s -p 7070 -i 1 -l 1400 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_dl.txt
    Execute Iperf In Linux    args=-c 1.2.4.2 -p 7070 -l 1400 -i 1 -t ${duration} -B 10.0.2.1
    Log To Console    Running DL Traffic ${dlmbps}M for ${duration}s
    Log To Console    start UL traffic...
    Execute Iperf In Linux    args=-s -p 7071 -i 1 -l 1400 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_ul.txt
    Execute Iperf In Linux    args=-c 72.23.0.1 -p 7071 -l 1400 -i 1 -t ${duration} -B 10.0.2.1
    Log To Console    Running UL Traffic ${ulmbps}M for ${duration}s
    #ute_wtssim.Execute Egate Command    sim_log_set flush
    #Sleep    ${duration}s


L3 Call With SA For MG
    [Arguments]    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}
    ...    ${A2_Flag}    ${cell_nums}    ${tc_id}    ${measurement_gap}=0    ${MBPS}=175
    Set Suite Variable    ${UE_ID}    1
    SA Set Traffic Type To Internal    ${UE_ID}     ${PDU_ID}
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    175
    Run Keyword If    '${ul_zeropadding}'=='False'
    ...    SA Start UL Traffic Egate Command    1    15
    Run Keyword If    '${scell_add_method}'=='1'
    ...     Scell Addition Triggered By A1 Event    1    2    100
    Capture TTItrace And BIP Logs
    Run Keyword If    '${measurement_gap}'=='1'
    ...     Measurement Gap Triggered By A2 Event
    Run Keyword If    '${ucionly}'=='1'
    ...    ute_wtssim.Execute Egate Command
    ...    ue_cqi_param id\=1 on\=nr nr_cqi\=15 nr_cqi_mode\=oneway nr_cqi_min\=4 nr_cqi_max\=15 nr_cqi_step\=-1 nr_cqi_period\=32
    Run Keyword If    '${ul_zeropadding}'=='False'
    ...    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
    Run Keyword If    '${A2_Flag}'=='1'
    ...    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}
    SA Stop DL Traffic Egate Command    1
    Run Keyword If    '${ul_zeropadding}'=='False'
    ...    SA Stop UL Traffic Egate Command    1

Get And Check Cells TP For NSA
    [Arguments]    ${ue_id}    ${dir}    ${scellindex}
    ${pcell_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    pcell    ${scellindex}
    Log To Console    Pcell Throughtput of ${dir} is ${pcell_tput}
    Should Be True    ${pcell_tput}>1    Pcell Throughtput of ${dir} is abnormal.
    ${scellindex}    Evaluate     int(${scellindex})+1
    ${scell_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    ${scellindex}
    Log To Console    Scell${scellindex} Throughtput of ${dir} is ${scell_tput}.

Deploy GNB BIP Script
    [Documentation]    This keyword is to deploy gnb bip script to gnb
    Log To Console    \nstart deploy gNB BIP script...\n
    OperatingSystem.Run And Return Rc And Output    scp ${LOCAL_CFG_DIR}/${RIGHT_GNB_SH} toor4nsn@192.168.255.1:/user/toor4nsn/

Set WTS Files Name For Each Cases
    [Arguments]    ${wts_cfg_name}    ${wts_xml_name}
#    Verify Coam Site Is Ready
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
    Log To Console    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}    ${wts_xml_name}
    Log To Console    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}

Set SCF Path
    [Documentation]    This keyword is to set the direcotry of scf.
    Log To Console    ${SW_VERSION}
    Set Suite Variable    ${SCF_DIR}    ${CURDIR}/config/${SW_VERSION}/SCF
    Log To Console    ${SCF_DIR}

Check CA TL Is Ready
    [Documentation]    This keyword is to check the state of gNB is configured and Two Radios are online.
    [Arguments]    ${ru_nums}    
    Log To Console    verify bts site is ready...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radios Are Online    ${ru_nums}

Verify Radios Are Online
    [Documentation]    This keyword is to check the state of Radios are online
    [Arguments]    ${ru_nums}    
    Log To Console    verify Radio is online...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_hw_info}    COAM.Get Bts Info
    FOR    ${id}    IN RANGE    0    ${ru_nums}
    ${radio_state}    Set Variable
    ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['status']['availabilityStatus']}
    ${ru_id}=    Evaluate    ${id}+1
    Log To Console    [INFO]    RADIO${ru_id}    STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    Online    ignore_case=True
    END
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown Admin

Scell Addition Triggered By A1 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=100
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    #...    pass_regexp=activated successfully    timeout=60
    Log To Console    \n${output}    

Measurement Gap Triggered By A2 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=20
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr}
    ...    pass_regexp=rrcReconfigurationComplete     timeout=60
    Log To Console    \n${output}

Scell Released By A2 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${scell_id}=1    ${scell_rsrp}=70
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=${scell_rsrp} 
    ...    pass_regexp=rrcReconfigurationComplete    timeout=30
    Log To Console    \n${output}

Configure Gnb With Full SCF For Local TL
    [Arguments]    ${scf_file}
    Log To Console    start gnb commission...
    ${bts_id}    Get BTS Id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${SCF_DIR}/${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300    
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Modify Gnb Sw Configuration For ACSI
    [Arguments]    ${EnableDynBetaOff}    ${EnableBetaOptimistic}    ${ACsiCheckDlLoad}    ${ucionly}
    ...    ${ModeratePayloadSizeThr}    ${CqiJitterTimer}    ${AcsiHighJitterTimer}    ${CqiDeltaThreshold}
    ...    ${OpenLoopwocsipart2}    ${rdACsiEligibilityAgeThreshold}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580431=${ucionly}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580384=${ModeratePayloadSizeThr}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x58045D=${CqiDeltaThreshold}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580458=${CqiDeltaThreshold}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x59006a=${OpenLoopwocsipart2}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x58041c=${rdACsiEligibilityAgeThreshold}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'crasign /ffs/run/swconfig.txt'

Configurate Airphone For CA
    [Arguments]    ${iphy_name}    
    Log To Console    start configure AP iphy.xml...
    OperatingSystem.Run And Return Rc And Output    scp ${LOCAL_IPHY_DIR}/${iphy_name} toor4nsn@192.168.200.1:${IPHY_DIR}
    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf iphy.xml;ln -fs ${iphy_name} iphy.xml
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'

Start UTE WTS And Check Cell Setup
    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
    [Arguments]    ${local_wts_cfg}    ${ru_nums} 
    Log To Console    \nStarting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
    ute_wtssim.Start Egate Process
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${local_wts_cfg}
    ...    pass_regexp=SystemInformationBlockType4-NR updated    timeout=5min
	Verify Cell Setup    ${ru_nums}
	Sleep    10s    wait for all cells' sib come up...\n

Start Gnb BIP Log For Two ABIOs
    [Documentation]    This keyword is to capture gnb L2L1 BIP for 2 ABIOs
    [Arguments]    ${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=GNB_BIP
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'rm -rf /tmp/*pcap*'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'sh /user/toor4nsn/${exec_script} 1>/dev/null 2>&1 &'
    Set Suite Variable    ${cmd}    tcpdump -vvv -i
    Wait Until Keyword Succeeds    2min    4s    Verify Process Start Success    5GBipL2L1_filtering_off    ${cmd}    GNB_BIP
    Log To Console   \nINFO:bip start success...

Stop Gnb BIP Log For Two ABIOs
    [Documentation]    This keyword is to stop gnb L2L1 BIP for 2 ABIOs 
    [Arguments]    ${log_dir}
    Log To Console    \nINFO:Stop GNB BIP log...
    ${cmd}    Set Variable    tcpdump -vvv -i
    Wait Until Keyword Succeeds    60s    4s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off    ${cmd}    GNB_BIP
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count For Two ABIOs	    ${log_dir}
    Log To Console   \nINFO:bip end success...
    [Return]    ${bip_counts}

Copy BIP Files And Return Count For Two ABIOs	
    [Arguments]    ${path}
    Log To Console    \ncopy bip files to ${path}...
    Wait Until Keyword Succeeds    60 s    4 s    Verify GNB Bip Log Exist
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${GNB_ASIK.ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=5GBipL2L1_filtering_off.pcap*
    Should Be True    ${count}!=0
    [Return]    ${count}

Verify GNB Bip Log Exist
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${GNB_ASIK.ip} ls -al /tmp/5GBipL2L1_filtering_off.pcap*
    Should Be True    "${rc}"=="0"	

Check_Betaoffset_MCShark_For_CA
    [Arguments]    ${tc_id}
    Log To Console    \ncheck BetaOffset...
    Convert BIP To CSV By MCShark For CA    ${tc_id}
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_c.ini    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_c.csv

Convert BIP To CSV By MCShark For CA
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
    @{csv_title_list}=    Create List    3gpp.sfn    dci.dci01.CSIrequest    3gpp.subcellid
    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_c.csv    ${filter}    ${csv_title_list}	

Check BetaOffsets From Local Egate Log
    [Arguments]    ${sa_flag}    ${log_path}=/opt/iphy/latest
    Log To Console    \nStart check betaOffset info from egate log.\n
    ${betaoffset}    Set Variable    betaOffset
    ${check_rst}    Run    cat ${log_path}/egate_console.log|grep "${betaoffset}"|wc -l
    Run Keyword If    '${sa_flag}'=='SA'
    ...    Should Be True    ${check_rst}>=37
    Run Keyword If    '${sa_flag}'=='NSA'
    ...    Should Be True    ${check_rst}==29

Change CQI For UCIonly SA
    Log To Console    \nChange CQI ...
    ${prepare_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32

    ${prepare_2}    Set Variable
    ...    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ute_wtssim.Execute Egate Command    ${prepare_2}

Check_Ucionly_MCShark_For_CA
    [Arguments]    ${tc_id}
    Log To Console    \nUcionly in MCShark...
    Convert BIP To CSV By MCShark For Ucionly    ${tc_id}
    CALC CSV UCIBITS AS CQI    ${OUTPUT_DIR}/csv_TC${tc_id}_cucionly.csv    ${OUTPUT_DIR}/csv_TC${tc_id}_c_new.csv
    ...    uci.pucch.ucibits    uciBits.qci
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_2.ini    ${CURDIR}/Resource/TC${tc_id}/ttitrace_2_ERR.csv

Convert BIP To CSV By MCShark For Ucionly
    [Arguments]    ${tc_id}
    ${filter}=    Catenate    dci.dci01.CSIrequest==1||UlData_UePuschReceiveRespPs_t.numOfUciCsiPart2Bits >0
    ...    ||(UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 3&&uldata_pucchreceiverespps)
    @{csv_title_list}=    Create List    3gpp.sfn    uci.cqi     dci.dci01.CSIrequest    uci.pucch.ucibits
    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_cucionly.csv    ${filter}    ${csv_title_list}

Verfiy Scells Are Activation
    [Arguments]    ${scell_nums}
    Log To Console    \nverify Scell Info...
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}==1
    END

Verfiy Scells Are Activation From BIP
    [Arguments]    ${tc_id}    ${scell_nums}
    Log To Console  verify Scell activation from bip...
    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
    Convert BIP to CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_scellactive.csv    ${filter}    ${csv_title_list}
    #Convert BIP to CSV By MCShark For Scell Activation And Deactivation    ${tc_id}
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${active_number}   Get Total Active Number   ${tc_id}    ${id}
    Should Be True    ${active_number}>=1
    END
    
Get Total Active Number
    [Arguments]    ${tc_id}    ${id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_scellactive.csv   mac-nr.control.scell-act-deact.cell${id}   ["1"]   include   no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Verfiy Scells Are Deactivation From BIP
    [Arguments]    ${tc_id}    ${scell_nums}
    Log To Console    verify Scells Deactivation from bip...
    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
    Convert BIP to CSV By MCShark    ${SUITE_LOG_DIRECTORY}/${tc_id}/2/5GBipL2L1_filtering_off.pcap0
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_scelldeactive.csv    ${filter}    ${csv_title_list}
    #Convert BIP to CSV By MCShark For Scell Activation And Deactivation    ${tc_id}
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${deactive_number}    Get Total DeActive Number    ${tc_id}    ${id}
    Should Be True    ${deactive_number}>=1
    END

Get Total DeActive Number
    [Arguments]    ${tc_id}    ${id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_scelldeactive.csv    mac-nr.control.scell-act-deact.cell${id}    ["0"]    include   no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Verify TDD Scell Is Activation
    [Arguments]    ${scell_index}
    [Documentation]    This keyword is to check whether TDD scell actived from egate log.
    Log To Console    verify TDD Scell Info...
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} activated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>0

Check ACSI Info From Egate Log For CA
    [Arguments]    ${open_loop_flag}     ${cell_nums}
    Log To Console    \nStart check A-CSI info from egate log.\n
    ${openloop_qua}    Set Variable    reportQuantity cri-RI-CQI
    ${closeloop_qua}    Set Variable    reportQuantity cri-RI-PMI-CQI
    ${config_id}    Set Variable    reportConfigId 1
	${trigger_size}    Set Variable    reportTriggerSize 1
    ${reportConfigId_13}    Set Variable    reportConfigId 13
    ${reportConfigId_14}    Set Variable    reportConfigId 14
    ${check_rst1}    Run Keyword If    '${open_loop_flag}'=='OpenLoop'
    ...    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${openloop_qua}"|wc -l
    ...    ELSE
    ...    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${closeloop_qua}"|wc -l
    ${check_rst2}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${config_id}"|wc -l
    ${check_rst3}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${trigger_size}"|wc -l
	${check_rst4}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${reportConfigId_13}"|wc -l
	${check_rst5}    Run Keyword If    '${cell_nums}'=='${3CC}'
    ...    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${reportConfigId_14}"|wc -l
	Run Keyword If    '${cell_nums}'=='${3CC}'
    ...    Should Be True    ${check_rst5}>=1
    Should Be True    ${check_rst1}>=2
    Should Be True    ${check_rst2}>=2
    Should Be True    ${check_rst3}>=1
	Should Be True    ${check_rst4}>=1
	
SA UE Attach And PDU Session Setup
    [Arguments]    ${id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | id | Yes | ue id and pdu session id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
	Log To Console    start UE${ue_id} attach...
	SA 5G Attach    ${id}
    Log To Console    start 5G PDU Session${id} Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${id} ue=${id} gw=${id} nwslice=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Change CQI For UCIonly NSA
    Log To Console    Change CQI ...
    ${prepare_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=3 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
    ${prepare_2}    Set Variable
    ...    ue_testmode_set_nr id=11 testmode=csi_override profile_id=3 action=activate scell=5
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ute_wtssim.Execute Egate Command    ${prepare_2}

Trigger CQI Change And Capture Logs
 	Log To Console     start bip... 
    Start Gnb BIP Log For Two ABIOs    ${RIGHT_GNB_SH}
    Sleep    10s    reason=Wait for start BIP script 
	Change CQI For UCIonly NSA
	Sleep    10s    reason=Wait for logs
    Stop Gnb BIP Log For Two ABIOs   ${SUITE_LOG_DIRECTORY}
    Sleep    30s    reason=Wait for the process handling.
	Log To Console     start ttitrace...
    Sleep    5s    reason=Scell Addition done
    Start Ttitrace With Streaming Mode
    Sleep    5s    reason=Wait for logs
    Stop Ttitrace    log_dir=${OUTPUT_DIR}

Save Egate Log8131
    [Arguments]    ${log_path}=${OUTPUT_DIR}/${TEST_NAME}
	[Documentation]    This keyword is to copy egate console log from opt/iphy/latest/egate_console.log to ${log_path}
    ...    after execute 'sim_log_set flush'
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy File    /opt/iphy/latest/egate_console.log    ${log_path}
	
Verify Scells Are Released
    [Arguments]    ${cell_nums}
    Log To Console    \nverify scell release Info...\n
    ${scell_release}    Set Variable    csi-ReportConfigToReleaseList
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep "${scell_release}"|wc -l
    ${scell_nums}=    Evaluate    int(${cell_nums})-1
    Should Be True    ${check_rst}==${scell_nums}

Get MeasID A1
    [Arguments]    ${ueid}
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
	${measorder}    Evaluate    int(${ueid})-1
    ${report_id}=    Set Variable    @{report_id_list}[${measorder}]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[${measorder}]
    [Return]    ${measIdA1}
	
Get MeasID A2 MG
    [Arguments]    ${ueid}
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
	${measorder}    Evaluate    int(${ueid})-1
    ${report_id}=    Set Variable    @{report_id_list}[${measorder}]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA2}=    Set Variable    @{measId_list}[${measorder}]
    [Return]    ${measIdA2}

Get MeasID A2 release
    [Arguments]    ${ueid}
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
	${reportorder}    Evaluate    int(${ueid})+1
    ${report_id}=    Set Variable    @{report_id_list}[${reportorder}]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
	${measorder}    Evaluate    int(${ueid})-1
    ${measIdA2}=    Set Variable    @{measId_list}[${measorder}]
    [Return]    ${measIdA2}
	
Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
    ...    UlData_UePuschReceiveRespHarqU_t.dtx
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
