*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Ganesha
...              :contact: ganesha.u@nokia.com

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

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner   ${wts_cfg_file}

#Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report


*** Variables ***
${wts_cfg_file}     ${CURDIR}/configs/basic_setup_CB007113_IWK_9189.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
${nwslice_ID}   1
${gw_ID}     1
${gw_ID1}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID}        1
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID}    1
${QFI_ID1}    1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${TRF_ID}    1
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD}    1
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4

@{rnti}
${epc_log_path}    /tmp/
*** Test Cases ***
[1]CB007113_J3_6_Verify_IWK_CB009189_DRB_addition_is_successful_in_UL_PRB_pooling_functionality
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt      btslog
    Register UE and establish VoNR GBR Call   1   3
    Register UE and establish VoNR GBR Call   21   23
    Register UE and establish VoNR GBR Call   41   43
    Stop Log      cprt      btslog       test_scenario=Scenario_1
	Run Keyword and Continue on Failure   Register UE and establish nGBR Call4   61
	Run Keyword and Continue on Failure   Verify The Counter
    Start Log      ttitrace
    Sleep   10s
    ${TTI_trace}   Stop Log   ttitrace
    Decode TTI Trace
    Run Keyword and Continue on Failure  Validate MaxHarqTxNum     ${TTI_trace}[ttitrace]    cell_id=${53}    Maxharqnum=${4}
    Run Keyword and Continue on Failure   Validate Payload Size    ${TTI_trace}[ttitrace]     ${rnti}     cell_id=${53}
    Run Keyword And Continue On Failure     Validate TTITraces For Loadbase Alogorithm    ${TTI_trace}[ttitrace]/tcpdump_ttitrace.pcap    816
	Deregister All UEs

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and establish VoNR GBR Call
    [Arguments]   ${Start_UE}   ${END_UE}
    log to console   ${UE_ID1} attach trigerring now...
	FOR  ${UE}   IN RANGE   ${Start_UE}   ${END_UE}+1
         UE Register should be Successful     ${UE}
    END
	Trigger UL Non Bursty Data Traffic for SA   ue_id=${Start_UE}    Traffic_rate=mbps     ul_rate=140       trf_id=${TRF_ID1}      qfi_id=${QFI_ID1}
	${TPut}   Get AVG UL DATA TRAFFIC For Given CC   ue_id=${Start_UE}
	Run Keyword and Ignore error   Should be True     ${TPut}>${130}
    FOR  ${UE}   IN RANGE   ${Start_UE}+1   ${END_UE}+1
        UE PDU Modfication should be Successful	  ${UE}   ${Pdu_session_ID1}   ${Q_O_ADD2}
        Sleep   3s
        UE PDU Modfication should be Successful	  ${UE}   ${Pdu_session_ID1}   ${Q_O_ADD3}
        Sleep   3s
        UE PDU Modfication should be Successful	  ${UE}   ${Pdu_session_ID1}   ${Q_O_ADD4}
        Sleep   3s
		Trigger UL Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=10       trf_id=${TRF_ID1}      qfi_id=${QFI_ID4}
	    Sleep  3s
        Validate UL Traffic For SA   ue_id=${UE}     ul_rate=10      qfi_id=${QFI_ID4}
    END


Register UE and establish nGBR Call4
    [Arguments]   ${UE}
	log to console   ${UE} attach trigerring now..
    Start Log      cprt      btslog
    ${rnti_ue}    UE Register should be Successful And Fetch RNTI     ${UE}
    Append To List    ${rnti}    ${rnti_ue}
	Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE}   Traffic_rate=mbps     ul_rate=100       trf_id=${TRF_ID1}      qfi_id=${QFI_ID1}
	#Validate UL Traffic For SA   ue_id=${Start_UE}     ul_rate=100     qfi_id=${QFI_ID1}
	Validate UL Traffic For UE   1   3
	Validate UL Traffic For UE   21   23
	Validate UL Traffic For UE   41   43
    wtsrunner.bler_testmode_nr   profile_id=30   ul_bler=200,200,200,200,200,200,200,200
    wtsrunner.ue_testmode_set_nr  id=61  testmode=bler  action=activate   profile_id=30
    Sleep       20s
	UE PDU Modfication should be Successful	  ${UE}   ${Pdu_session_ID1}   ${Q_O_ADD2}
	Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=10       trf_id=${TRF_ID1}      qfi_id=${QFI_ID2}
    Stop Log     cprt      btslog       test_scenario=Scenario_2

Validate UL Traffic For UE
    [Arguments]   ${Start_UE}   ${END_UE}
    ${PUSCH_tput}   Get AVG UL DATA TRAFFIC For Given CC     ${Start_UE}
    Should Be True    ${PUSCH_tput} > ${80}
    log to console   ${PUSCH_tput}
#	Validate UL Traffic For SA   ue_id=${Start_UE}     ul_rate=100     qfi_id=${QFI_ID1}
    FOR  ${UE}   IN RANGE   ${Start_UE}+1   ${END_UE}+1
         Validate UL Traffic For SA   ue_id=${UE}     ul_rate=10     qfi_id=${QFI_ID4}
    END

Deregister All UEs
    Deregister UEs    1    3
    Deregister UEs    21    23
    Deregister UEs    41    43
    Stop Data Traffic for SA     ue_id=61
    UE Deregister should be Successful   ue_id=61

Deregister UEs
    [Arguments]    ${Start_UE}   ${END_UE}
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${END_UE}+1
        Stop Data Traffic for SA     ue_id=${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END

Validate PM Counters bigger
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-4
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-4
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}
    log to console   ${moc}

Verify The Counter
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger    PM_dir=${PM_dir1}    PM_counter=M55302C00028    expected_value=0
    ${M55302C00028}    Check PM counter value   ${PM_dir1}    PM_counter=M55302C00028
    ${M55302C15002}    Check PM counter value   ${PM_dir1}    PM_counter=M55302C15002
    Should be True      ${M55302C00028} < ${M55302C15002}
    ${M55302C15001}    Check PM counter value   ${PM_dir1}    PM_counter=M55302C15001
    ${M55302C03028}    Check PM counter value   ${PM_dir1}    PM_counter=M55302C03028
    Should be True      ${M55302C15001} > ${M55302C03028}
    Should be True      ${M55302C15001} <= ${M55302C15002}
    ${M55302C15004}    Check PM counter value  ${PM_dir1}    PM_counter=M55302C15004
    ${Value} 	Evaluate   ${M55302C15002} - ${M55302C15001}
    Run Keyword and continue on failure   Should be True    ${M55302C15004} <= ${Value}
    ${M55302C15003}    Check PM counter value  ${PM_dir1}    PM_counter=M55302C15003
    ${Value1} 	Evaluate   3 * ${M55302C15001}
    Should be True   ${M55302C15003} >= ${Value1}
