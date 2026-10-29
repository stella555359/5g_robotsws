*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB008541/CB008541_5G_B_B002_1_APoverABIO.yml
#...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Meghana
...              :contact: meghana.s@Nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         /resources/robot/common_log_collection.robot
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         resources/load_based_validation_keywords.resource
Resource         ../resources/robot/TTI_Traces.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/avg_dl_data.py
Resource         ../CB009215/resources/CB009215_keyword.robot
Library           ta5g_enb
Resource         ../resources/robot/wts_sim_keywords.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}

Test Teardown    Run Keywords    Get Sos Report
...              AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
${RI_LOW_POWER_VALUES}=     SEPARATOR=
...                         -140,-140,-139,-138,-137,-136,-135,-134,-133,-132,-131,-130,-128,-126,-124,-122,-120,
...                         -118,-120,-124,-126,-128,-130,-131,-132,-133,-134,-135,-136,-137,-138,-140
${RI_HIGH_POWER_VALUES}=    SEPARATOR=
...                         -100,-95,-90,-90,-90,-85,-85,-85,-80,-80,-75,-75,-70,-65,-65,-55,-55,-55,-65,-70,-75,-75,
...                         -80,-80,-85,-85,-85,-90,-90,-90,-95,-100
${RI_MONITORING_PERIOD}=    5m

${wts_cfg_file}     ${CURDIR}/config/basic_setup_ASOE_4Cell_80ue.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${SCFC}=   ${CURDIR}/config/SCF/working7113_G_Configuration_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy.xml

@{PCI_CELL1}  50
@{PCI_CELL2}  51
@{PCI_CELL3}  52
@{PCI_CELL4}  53

*** Test Cases ***
[1][1.0] CB007113-SR-G-B0_02 Verfiy the UL PRB pooling with CB008249 feature enabled in loaded cell condition
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with small BWP and
    [Tags]    QC_364458      QCD_MN_RAN     QCP_RAN_ET
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set test variable      ${LOG_PATH}
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    Start Log     cprt      btslog
    X2AP Link Should be UP
    Register UE And Send Data    1    61
    Generate Remote Interference    2    ${RI_LOW_POWER_VALUES}
    Sleep   600s
    Check If RI Alarm Is Not Present
    Deactivate Remote Interference Testmode    2
    Generate Remote Interference    3    ${RI_HIGH_POWER_VALUES}
    Start Log    ttitrace
    sleep  0.5s
    ${scen2}    Stop Log    ttitrace
    log to console    ${scen2}
    Sleep   580s
    Check If RI Alarm Is Present
    Stop Log      cprt      btslog       test_scenario=Scenario_1
    Sleep   10s
    Deactivate Remote Interference Testmode    3
    Sleep   600s
    Check If RI Alarm Is Not Present

    Collect TTI and Sherpa Logs   Test_Step=Step1_cell1   Duration=500ms
	Collect TTI and Sherpa Logs   Test_Step=Step2_cell2   Duration=500ms
	Collect TTI and Sherpa Logs   Test_Step=Step3_cell3   Duration=500ms
	Collect TTI and Sherpa Logs   Test_Step=Step4_cell4   Duration=500ms

    Decode and Valiadate Prb Allocation from TTI UL prb  Test_Step=Step1_cell1
    ...   CellId=@{PCI_CELL1}    UL_Threshold1=36    UL_Threshold2=273
    Decode and Valiadate Prb Allocation from TTI UL prb  Test_Step=Step2_cell2
    ...   CellId=@{PCI_CELL2}    UL_Threshold1=100    UL_Threshold2=273
    Decode and Valiadate Prb Allocation from TTI UL prb  Test_Step=Step3_cell3
    ...   CellId=@{PCI_CELL3}    UL_Threshold1=100    UL_Threshold2=273
    Decode and Valiadate Prb Allocation from TTI UL prb  Test_Step=Step4_cell4
    ...   CellId=@{PCI_CELL4}    UL_Threshold1=100    UL_Threshold2=273



*** Keywords ***

Collect TTI and Sherpa Logs
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Sleep   5s

Decode TTI Trace UL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=$F{LOG_PATH}/${TEST_NAME}

Validate CellSetup_SysLog for bbpooling
    [Arguments]    ${syslog}
    ${status1} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "numMinPrbAllocUlTdd:54"
    Builtin.Log   ${status1}
    Should Not Be Empty    ${status1}
    ${status2} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "poolMaxNumStreamPrb 3276"F
    Builtin.Log   ${status2}
    Should Not Be Empty    ${status2}
    ${status3} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "l1SubPoolId"
    Builtin.Log   ${status3}
    Should Not Be Empty    ${status3}

Register UE And Send Data
    [Arguments]   ${Start_UE}   ${MAX_UE}
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    20
        log to console   UE attach triggering now...${UE}F
        WTS_Runner_Keywords.UE Register should be Successful     ${UE}
        Sleep    5s
        WTS_Runner_Keywords.Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps   ul_rate=100      pdu_id=1    trf_id=1
        sleep   5s
        Run Keyword And Ignore Error    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=80      qfi_id=1
    END


Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr  profile_id=${ID}    start_symbol_position=0   num_of_symbols=32   noise_power_values=${RI_PWR}
    Sleep    2s
    wtsrunner.cell_testmode_set_nr    testmode=remote_interference     gnb=2     cell_id=1      profile_id=${ID}  action=activate
    Sleep    10s

Create RI Profiles
    [Arguments]    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr profile_id=${ID}   start_symbol_position=0   num_of_symbols=32   noise_power_values=${RI_PWR}

Deactivate Remote Interference Testmode
    [Arguments]    ${ID}
    wtsrunner.cell_testmode_set_nr     testmode=remote_interference     gnb=2     cell_id=1     profile_id=${ID}   action=deactivate
    Sleep    10s

Check If RI Alarm Is Not Present
     ta5g_enb.Verify If Admin Fault Is Down    fault_id=7525

Check If RI Alarm Is Present
     ta5g_enb.Verify If Admin Fault Is Up    fault_id=7525

Deregister All UE
    [Arguments]   ${Start_UE}   ${MAX_UE}
    #Start Collecting Syslog     NAME=syslog_ue_attach
    #Start CPRT Trace Capturing
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    20
        Stop Data Traffic for SA     ue_id=${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END
Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    ${scen2}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    Convert Ttitrace From Pcap To Excelcsv        ${scen2}
    Convert Tti To Csv Mode          ${scen2}
    [Return]        ${scen2}
Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv${scen2}

Convert Ttitrace From Pcap To Excelcsv
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}


Validate UL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate     ${bearer_stat_ul}    UL    ${ul_rate}

Decode and Valiadate Prb Allocation from TTI UL prb
    [Arguments]    ${Test_Step}   ${CellId}    ${UL_Threshold1}    ${UL_Threshold2}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    Decode TTI Trace UL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell UL prb    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...       ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell UL prb
    [Arguments]   ${csv_file_path}  ${CellId}    ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${UL_Check}   Verify cell ulprballocation multicell_G      ${csv_file_path}/output_ul_formated.csv      ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Common Convert Ttitrace From Pcap To Excelcsv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace    ${filename}=tcpdump_ttitrace.pcap
    ${file_path}=    Set Variable    ${log_path}/${filename}
    log to console  ${names}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}
