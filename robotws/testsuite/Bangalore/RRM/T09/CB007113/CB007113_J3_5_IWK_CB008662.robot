*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB007113_J/Configuration_scf_MRBTS-1_7_15_UTE5GTL313_20221130-1246_TC5_7113.xml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Sujay
...              :contact: sujay.kumar_mj@nokia.com
...              This scenario verifies when adaptive retransmission is enabled, the number of prb's requested is less than
...              the initial number of prbs for the reserved mcs values
Library          Collections
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/Common_Keywords.robot
Resource	     ../../../resources/robot/common_log_collection.robot
Resource         resources/load_based_validation_keywords.resource
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Library          ../../../resources/python/avg_dl_data.py
Library          resources/CB008662_CheckTTITraceDL.py

Suite Setup         Run keywords    Run Keyword and Ignore Error  Suite setup from scratch
#...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_8662_TC5.json
...                 AND      Start WTS Using WTS_Runner      ${wts_cfg_file}
Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Test Setup       Start_capture_testcase_default_logging
Test Teardown     Run keyword and ignore error       	Deregister UEs   1    13
*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_ASOE_4cell_Full.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        5
${UE_ID3}        9
${UE_ID4}        13
${nwslice_ID}   1
${gw_ID1}     1
${Pdu_session_ID1}       1
${pdu_id}    1
${QFI_ID1}    1
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD1}    1
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CNI85011-5G_B2_3_Verify_UL_PRB_pooling_with_adaptive_re-transmission_enabled_with_Multiple_UEs_in_TDD_cells
    Start Log    cprt    btslog
    Register UE and establish nGBR Call  ${UE_ID1}     ul_data_sent=140     ul_data_received=123     expected_data=${100}
    Register UE and establish nGBR Call  ${UE_ID2}     ul_data_sent=50      ul_data_received=50     expected_data=${45}
    Register UE and establish nGBR Call  ${UE_ID3}     ul_data_sent=50      ul_data_received=50     expected_data=${45}
	Register UE and establish nGBR Call  ${UE_ID4}     ul_data_sent=50      ul_data_received=50     expected_data=${45}
    Check tput in all the cells    1      13
	Trigger retransmission on UE1    ${UE_ID1}
	Stop Log    cprt    btslog
	Collect TTI trace and validate retransmission
    ${checksResults}=     run keyword and ignore error    CB008662_CheckTTITraceDL.Check Adaptive TDDUL     jsonPathName=${TTIjson}
    ...    rdAdaptiveReTxNackCount=2
    run keyword and continue on failure     Verify PM Counter for using MCS 31

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and establish nGBR Call
    [Arguments]   ${UE}       ${ul_data_sent}      ${ul_data_received}    ${expected_data}
	log to console   ${UE} attach trigerring now...
    UE Register should be Successful  ue_id=${UE}  pdu_id=${Pdu_session_ID1}    nw_id=${nwslice_ID}      gw_id=${gw_ID1}
	Trigger UL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps    ul_rate=${ul_data_sent}    pdu_id=${Pdu_session_ID1}    trf_id=${TRF_ID1}
	Sleep    10s
	Run Keyword and Continue on Failure      Validate UL Traffic For SA   ue_id=${UE}     pdu_id=${pdu_id}    ul_rate=${ul_data_received}
    ...    qfi_id=${QFI_ID1}
	Run Keyword and Continue on Failure      Verify Non GBR PUSCH Tput at APL1 per cell    ${UE}    ${expected_data}

Check tput in all the cells
    [Arguments]    ${start_ue_id}	  ${end_ue_id}
   	Sleep    10s
   	log to console     checking all cells tput
    log to console    ${start_ue_id}     ${end_ue_id}
#    FOR   ${UE}  IN RANGE    ${start_ue_id}	  ${end_ue_id}+1     4
	Run keyword and continue on failure     Verify Non GBR PUSCH Tput at APL1 per cell   ${UE_ID1}    expected_data=${100}
	Run keyword and continue on failure     Verify Non GBR PUSCH Tput at APL1 per cell   ${UE_ID2}    expected_data=${45}
	Run keyword and continue on failure     Verify Non GBR PUSCH Tput at APL1 per cell   ${UE_ID3}    expected_data=${45}
	Run keyword and continue on failure     Verify Non GBR PUSCH Tput at APL1 per cell   ${UE_ID4}    expected_data=${45}
#	END

Deregister UEs
    [Arguments]    ${start_ue_id}	  ${end_ue_id}
	 FOR   ${UE}  IN RANGE    ${start_ue_id}	  ${end_ue_id}+1     4
	        UE Deregister should be Successful   ${UE}
	 END

Trigger retransmission on UE1
    [Arguments]   ${UE}
    log to console      Trigeer retransmission
    wtsrunner.bler_testmode_nr   profile_id=30   ul_bler=100,200,300,400,100,300,400,500
    wtsrunner.ue_testmode_set_nr  id=${UE}  testmode=bler  action=activate   profile_id=30

Collect TTI trace and validate retransmission
    log to console     collect TTI trace and convert to json
    Start Log     ttitrace
    sleep    10s
    Stop Log      ttitrace
#    ${TTIjson}     Convert TTI trace from pcap to others     ${log_dir_gnb}/tcpdump_ttitrace.pcap
#    Set test variable     ${TTIjson}     ${TTIjson}

Get AVG UL DATA TRAFFIC For Given Cell
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pusch_ue_stats}    Get PUSCH UE Stats for Given Cell    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pusch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get PUSCH UE Stats for Given Cell
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PUSCH UE stats for given Cell
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET PUSCH UE Stats    expected=Average
    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}
Verify Non GBR PUSCH Tput at APL1 per cell
    [Arguments]   ${UE}    ${expected_data}
    ${PUSCH_tput}=    Get AVG UL DATA TRAFFIC For Given Cell    ue_id=${UE}    scell_idx=0    unit=Mbps
    Should Be True    ${PUSCH_tput} > ${expected_data}
    BuiltIn.log   ${pcell_tput}
    log to console   ${pcell_tput}
GET PUSCH UE Stats
    [Arguments]     ${expected}=NR PUSCH Throughput
    ${output}    wtsrunner.Read Wtsemu Output Until Prompt    timeout=10
    # Try2 : ${output}    wtsemu.read_wtsemu_output_until_re    expected=${expected}   timeout=10
    # Try3 : ${output}    wtsemu.read_wtsemu_output_until    expected=${expected}   timeout=10
    ${result}    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    Log to Console    ${output}
    log to console  ${expected}
    should contain    ${output}    Average
    [Return]      ${output}
Verify PM Counter for using MCS 31
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_D2_6}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
	PM_Counters.Check PM counter value bigger than   expected_value=1   pm_files_location=${PM_dir_D2_6}
    ...  pi_id=M55302C03031    moc=NRCELL-1
