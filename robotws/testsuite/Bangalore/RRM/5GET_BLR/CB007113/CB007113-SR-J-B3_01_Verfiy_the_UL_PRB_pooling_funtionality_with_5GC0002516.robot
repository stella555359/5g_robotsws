*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Prasun
...              :contact: prasun.chakravorty@nokia.com
...     1.	user creates the configuration plan (Refer US CB007113-C#1) and activate all cells.
...     2.	Add UEs with UL full buffer in cell 1 and make sure full bandwidth are consumed, and for other cells, add UEs with small traffic.
...     UEs are in good RF conditions and highest MCS is expected
...     3.Set MRBTS/NRBTS/NRCELL/actInfTddFrameMuting = true, and Fill the MRBTS/NRBTS/NRCELL/infTddFrameStructure fields according to ......
...     interfering frame structure, and set MRBTS/NRBTS/NRCELL/infTddFrameStructure/infTddFrameMutingBiAgreement to false.
...     Since the new parameters require object locking, cell is deleted and re-added in gNB-DU and normal Startup / Cell Setup proceeds,
...     step 2 is also needed to repeat here. see US 5GC002516-A#B1 For interfering system,
...     4.activate the interfering cell
...     5.add UEs with full buffer of DL and UL

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource	     ../resources/robot/common_log_collection.robot
Resource         resources/load_based_validation_keywords.resource
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../CB009215/resources/CB009215_keyword.robot

Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/avg_dl_data.py
Resource         resources/load_based_validation_keywords.resource
Library          resources/check_cell_expected_prballocation.py

Suite Teardown    Run Keyword and ignore error    Get Sos Report

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
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
@{PCI_list3}  50    51    52    53
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
${gw_ID1}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID1}    1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${TRF_ID1}    1
${Q_O_ADD}    1
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${r&d_parameter}     0x420068=7;0x58069C=1;0x580612=1;0x580686=0xa;0x58057c = 0x2800;0x58057a = 0x4
@{rnti}
@{PCI_CELL1}  50    51     52      53
${wts_cfg_file1}     ${CURDIR}/configs/basic_setup_ASOE_4cell_gscn_ue1-4.cfg
${Low_data_counter_value_cell1}
${Low_data_counter_value_cell4}
${High_data_counter_value_cell1}
${High_data_counter_value_cell4}
@{PhysCellID}      50    51    52    53
${start_ue_id}        5
${end_ue_id}        9
${start_ue_id_1}        22
${end_ue_id_1}        26

*** Test Cases ***
[1][1.0] CB007113-SR-J-B3_01 Verfiy the UL PRB pooling funtionality with 5GC0002516
    [Setup]    Run keywords   Set Suite Variable   ${SCFC}   ${CURDIR}/config/SCF/working7113_J_Configuration_scf.xml
    ...   AND   Set Suite Variable    ${AP_XML}     ${CURDIR}/config/ASOE_7113_J_B3_iphy.xml
    ...                 AND    Prepare TL with all config files
    ...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND    Configure UTE ETH3 IPs
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
    [Tags]    QC_256475      QCD_MN_RAN     QCP_RAN_ET   TC01
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set test variable      ${LOG_PATH}
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt      btslog
    Register UE and establish NonGBR Call   1    4    21
    sleep      20s
    ${TPut1}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID1}
    set suite variable   ${TPUT1}
    ${TPut2}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID2}
    set suite variable   ${TPUT2}
    sleep     10s
    ${TPut3}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID3}
    set suite variable   ${TPUT3}
    Get The Counter1
    Collect TTI and Sherpa Logs   Test_Step=Step1_cell1   Duration=500ms
    Decode and Valiadate Prb Allocation from TTI Logs Only UL  Test_Step=Step1_cell1
    ...   CellId=@{PCI_CELL1}    UL_Threshold1=100    UL_Threshold2=273
    Deregister UEs    1    4     21
    Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS-1_7_15_UTE5GTL313_20240606-1113.json
    Sleep   300s   reason=waiting to come on air
    Register UE and establish NonGBR Call    1    4    21
    ${TPut1_2}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID1}
    set suite variable   ${TPUT1_2}
    ${TPut2_2}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID2}
    set suite variable   ${TPUT2_2}
    ${TPut3_2}   load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE_ID3}
    set suite variable   ${TPUT3_2}
    Get The Counter2
    Througput check
    MultiUE Register should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Register should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Deregister should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Deregister should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Register should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Register should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Deregister should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Deregister should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Register should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Register should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Deregister should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Deregister should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Register should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Register should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Deregister should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Deregister should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Register should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Register should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
	MultiUE Deregister should be Successful    ${start_ue_id}    ${end_ue_id}
	MultiUE Deregister should be Successful    ${start_ue_id_1}    ${end_ue_id_1}
	sleep    5
    Collect TTI and Sherpa Logs   Test_Step=Step2_cell1   Duration=500ms

    Decode and Valiadate Prb Allocation from TTI Logs Only UL  Test_Step=Step1_cell1
    ...   CellId=@{PCI_CELL1}    UL_Threshold1=100    UL_Threshold2=273
    Deregister UEs   1    4    21
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...     AND   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf
    Check resource hanging

[1]CB007113_J1_2_Verify_IWK_CB006878_with_mutipleBWP_LongPUCCH_configured_FR1_TDD
    [Documentation]   verifies the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL
     ...    traffic rate and switch to large BWP on UL traffic increase in 4 cells.
    [Tags]     TC02
    [Setup]   Run Keywords   Set Suite Variable   ${SCFC}     ${CURDIR}/config/ASOE_SCF.xml
    ...   AND   Set Suite Variable    ${AP_XML}     ${CURDIR}/config/ASOE_IPHY.xml
    ...   AND    Run Keyword and Ignore Error    Suite setup from scratch
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    ...                 AND     Prepare TL with all config files
    ...                 AND    Start WTS Using WTS_Runner           ${wts_cfg_file1}
    ...                 AND     Check gNB Bulid
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Log     btslog
    ${crnti_list}=      MultiUE Register should be Successful    1  4
    Set test variable     ${crnti_list}     ${crnti_list}
    Stop Log    btslog          test_scenario=ueattach_TC2
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=mbps     ul_rate=145          trf_id=${TRF_ID}
    Start low UL data in all cells
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for low data
    Wait Until Keyword Succeeds    60s    5sec    Collect 6878 counter for low data and verify
    Start high UL data in all cells
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for high data
    Collect 6878 counter for high data and verify
    Wait Until Keyword Succeeds    12 min    3 min     PRB Validation
    Stop MultiUE Data Traffic for SA     1  4
    MultiUE Deregister should be Successful   1  4
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...   AND   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and establish NonGBR Call
    [Arguments]    ${start_ue}   ${end_ue}    ${2ndcell_ue}
    FOR  ${UE}  IN RANGE    ${start_ue}     ${end_ue}
        log to console   UE attach triggering now...${UE}
        UE Register should be Successful     ${UE}
        Sleep    5s
        Trigger UL Data Traffic for SA     ue_id=${UE}     Traffic_rate=mbps    ul_rate=175      pdu_id=1    trf_id=1
#        Trigger UL Data Traffic for SA     ue_id=${UE}     Traffic_rate=mbps    ul_rate=50       pdu_id=1    trf_id=2
        sleep   40s
        Run Keyword And Ignore Error    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=5      qfi_id=1
    END
    UE Register should be Successful    ${2ndcell_ue}
	Trigger UL Non Bursty Data Traffic for SA   ue_id=${2ndcell_ue}   Traffic_rate=mbps     ul_rate=175
    ...    trf_id=${TRF_ID1}      qfi_id=${QFI_ID1}
    sleep    40s
    Run Keyword And Ignore Error    Validate UL Traffic For SA   ue_id=${2ndcell_ue}     ul_rate=50      qfi_id=1



Deregister UEs
    [Arguments]    ${start_ue}   ${end_ue}    ${2ndcell_ue}
    FOR   ${UE}  IN RANGE    ${start_ue}       ${end_ue}
        Run Keyword and Ignore error    Stop Data Traffic for SA    ${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END
    Run Keyword and Ignore error    Stop Data Traffic for SA    ${2ndcell_ue}
    UE Deregister should be Successful   ${2ndcell_ue}

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}

Get The Counter1
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C10006_1}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C10006
    Set Suite Variable    ${M55308C10006_1}

Get The Counter2
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C10006_2}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C10006
    Set Suite Variable    ${M55308C10006_2}
    ${comp}   evaluate   ${M55308C10006_2} / ${M55308C10006_1}
    Should be True   ${comp} >= 0.5

Througput check
    Should be True      ${TPut1} >= ${TPut1_2}
    Should be True      ${TPut2} >= ${TPut2_2}
    Should be True      ${TPut3} >= ${TPut3_2}

Collect TTI and Sherpa Logs
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Sleep   5s

Decode and Valiadate Prb Allocation from TTI Logs Only UL
    [Arguments]    ${Test_Step}   ${CellId}       ${UL_Threshold1}    ${UL_Threshold2}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    Decode TTI Trace UL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell Only UL    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...       ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell Only UL
    [Arguments]   ${csv_file_path}  ${CellId}     ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${UL_Check}   Verify cell ulprballocation multicell_G      ${csv_file_path}/output_ul_formated.csv      ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Decode TTI Trace UL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Start low UL data in all cells
    Start Log       btslog
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    sleep   10s    reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_lowdata_TC2


Capture TTI traces and validate BWPID for low data
    ${bwpid}    Create List     2     2    2    2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start high UL data in all cells
	Start Log        btslog
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=mbps     ul_rate=145          trf_id=${TRF_ID}
    Run Keyword And Continue On Failure    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_highdata_TC2

Capture TTI traces and validate BWPID for high data
    ${bwpid}    Create List     1     1    1    1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Collect 6878 counter for low data and verify
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Low_data_counter_value_cell1}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-1
    ${Low_data_counter_value_cell4}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-4
    Should be true      ${Low_data_counter_value_cell1} > ${Low_data_counter_value_cell4}

Collect 6878 counter for high data and verify
    Wait until the next Measurement Period starts
    ${PM_dir2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${High_data_counter_value_cell1}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-1
    ${High_data_counter_value_cell4}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-4
    Should be true      ${High_data_counter_value_cell1} > ${High_data_counter_value_cell4}


Collect TTI Traces
    [Arguments]    ${dir_name}     ${sleep_time}
    Start Log      ttitrace
	Sleep    ${sleep_time}s
    ${tti_log_path}    Stop Log      ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}
    log to console   ${tti_log_path}
	Decode TTI Trace    ${dir_name}
	[Return]    ${tti_log_path}

Verify expected PRB allocation
    FOR     ${cellid}    IN    @{PhysCellID}
        ${UL_Check}    Verify Expected PRB Allocation in UL    ${TTI_log_dir}[ttitrace]      ${cellid}    46    273    204
        ${DL_Check}    Verify Expected PRB Allocation in DL    ${TTI_log_dir}[ttitrace]      ${cellid}    48    273    273
    END

Verify Expected PRB Allocation in UL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in ul...
    ${Result}   check_cell_expected_prballocation.check_ulexpectedprb      ${csv_file_path}/output_ul_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Verify Expected PRB Allocation in DL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in dl...
    ${Result}   check_cell_expected_prballocation.check_dlexpectedprb      ${csv_file_path}/output_dl_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}
Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
PRB Validation
    ${TTI_log_dir}     Collect TTI Traces      dir_name=cell_idle     sleep_time=2
    set test variable    ${TTI_log_dir}
    Verify expected PRB allocation
Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Verify cell ulprballocation multicell_G
    [Arguments]   ${csv_file_path}      ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_prb_multicell.check_ulallocatedprb      ${csv_file_path}    ${cellId}      ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}