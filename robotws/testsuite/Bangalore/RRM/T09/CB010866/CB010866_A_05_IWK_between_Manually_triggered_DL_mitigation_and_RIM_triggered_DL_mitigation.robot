*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB010866 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB010866_A_05_IWK_between_Manually_triggered_DL_mitigation_and_RIM_triggered_DL_mitigation
...  TESTING SPLIT   :   Split-A
...  CONTACTS        :   Ganesha.u@nokia.com
...  REFERENCES      :   CB010866-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25026


Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         CB010866_resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          taf.sw.scout    WITH NAME     scout
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          ../../../resources/python/avg_dl_data.py
Library          ./python/manual_mitigation_enable.py
Library          ./python/manel_mitigation_disable.py
Library          taf.transport.ssh  WITH NAME  ssh
Library          taf.sbts.oam.coam.admin


Suite Setup         Run keywords    Suite setup from scratch
...                 AND          Run keywords     Update bsr package
...                 AND    Perform SCF Delta Commissioning with Enable_RIMRS.json
...                 AND    Update GNB R&D Parameters    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    6
...                 AND    Check gNB Bulid

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262219
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${Pdu_session_ID}       1
${nwslice_ID}   1
${gw_ID}     1
${QFI_ID1}     1

${START_UE}   1
${END_UE}     9
${DL_RATE}     50
${UL_RATE}    1
${PDU_ID}     1
${qfi_id}     1
${UL_RATE_after_RI}    1
@{pysical_cell_ids1}    50
${START_UE1}    1
${END_UE1}      3
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True



*** Test Cases ***
[1]CB010866_A_05_IWK_between_Manually_triggered_DL_mitigation_and_RIM_triggered_DL_mitigation
    [Tags]    TC01
    Set test variable      ${LOG_PATH}
    Register SA call and send data     1     10
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Log to Console    Manual Mitigation Trigger is Enabling
    Perform SCF Delta Commissioning with Enable_manualtrigger.json
    Wait For Fault To Be Down     fault_id=7535   timeout=100
    Log to console    Counter Validation
    Verify The Counter
    Log to Console    Manual Mitigation Trigger is disabling
    Perform SCF Delta Commissioning with Disable_manualtrigger.json
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down.
    Wait For Fault To Be down     fault_id=7525   timeout=500
    Log to console    alarm 7535 will go down after 10 min of RI disappear.
    Wait For Fault To Be down     fault_id=7535   timeout=650
    sleep  10s  reason=stable data
    MultiUE Deregister should be Successful    1    10
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog1
    Stop log    snapshot  test_scenario=snap
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
#    ...   AND    Run Keyword If Test Failed   Run Keyword and ignore error  wts_sim_keywords.UE Deregister should be Successful   ue_id=1
    ...   AND      Check resource hanging


[1]CB010866_B_01_Robustness_PDCCH_and_PDSCH_muting_on_special_slot_during_RIM_DL_mitigation
    [Tags]    QC_363194      QCD_MN_RAN    QCP_RAN_ET   TC02
    Set test variable      ${LOG_PATH}
    Register SA call and send data     1     10
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=1000
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Log to console    Counter Validation
    Verify The Counter
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Sleep    10s
    Deactivate RI
    Wait For Fault To Be down     fault_id=7525   timeout=800
    MultiUE Deregister should be Successful    1    10
    Stop log    snapshot  test_scenario=snap1
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...   AND      Check resource hanging

[1]CB010866_C#_01_Verify_Legacy_FW1_Default_LeapSecond_leap_seconds_auto_on_StandAlone_Mode_RIM_RS1_detection_at_gNB
    [Tags]    QC_363194      QCD_MN_RAN    QCP_RAN_ET   TC03
    Set test variable      ${LOG_PATH}
    Register SA call and send data     1     3
#    Register SA call and send data     ${START_UE}    ${END_UE}
    Activate RI
    Log to console    RI Triggered
	sleep  60s
    Run Keyword and ignore error    Validate DL Traffic For MultiUE SA     ${START_UE1}    ${END_UE1}     ${dl_rate}
    ...     ${pdu_id}     ${qfi_id}
    Run Keyword and ignore error    Validate UL Traffic For MultiUE SA   ${START_UE1}    ${END_UE1}    ${UL_RATE_after_RI}
    ...     ${pdu_id}     ${qfi_id}
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH special slot plus the preceding slot
    Log to console    RS Triggered
    Activate LeapRIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=600
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected, detected RIM RS1 setIDs list is 44444
    Sleep    10s
    Deactivate RI
	Sleep    10s
	Validate DL Traffic For MultiUE SA     ${START_UE1}    ${END_UE1}     ${dl_rate}
    ...     ${pdu_id}     ${qfi_id}
    Validate UL Traffic For MultiUE SA   ${START_UE1}    ${END_UE1}   ${UL_RATE}
    ...     ${pdu_id}     ${qfi_id}
    Wait For Fault To Be down     fault_id=7525   timeout=800
    Wait For Fault To Be down     fault_id=7535   timeout=1000
    Wait For Fault To Be down     fault_id=7527   timeout=100
    #*
    Log to Console    Manual Mitigation Trigger is Enabling
    Perform SCF Delta Commissioning with Enable_manualtrigger.json
    Sleep    10s
    Capture TTI Traces Per Cell    ${LOG_PATH}   Test_Step   @{pysical_cell_ids1}    duration=1s
    Sleep    10s
    Log to Console    Decoding
    Decode and Verify Manual mitigation enable    Test_Step
    Sleep    10s
    Log to Console    Manual Mitigation Trigger is disabling
    Perform SCF Delta Commissioning with Disable_manualtrigger.json
    Sleep    10s
    Capture TTI Traces Per Cell for disable    ${LOG_PATH}   Test_Step1   @{pysical_cell_ids1}   duration=1s
    Sleep    10s
    Decode and Verify Manual mitigation disable     Test_Step1


    MultiUE Deregister should be Successful    1    3
    Stop log    snapshot    test_scenario=snap2
    [Teardown]    Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...    AND    Run Keyword If Test Failed    Run Keyword and ignore error    wts_sim_keywords.UE Deregister should be Successful    ue_id=1
    ...    AND    Check resource hanging


*** Keywords ***
Update GNB R&D Parameters
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   admin.Setup admin    bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   use_ssl=${USE_SSL}  name=swc
   admin.download_software_config    ${LOG_PATH}/swconfig_gnb.txt   connection=swc
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=OAM-conn
   ssh.upload_file    local_path=${LOG_PATH}/swconfig_gnb.txt     remote_path=/ffs/run/swconfig.txt    connection=OAM-conn
   ssh.send_command     command=crasign /ffs/run/swconfig.txt   connection=OAM-conn
   ssh.send_command     command=craverify /ffs/run/swconfig.txt*    connection=OAM-conn
   ssh.disconnect   connection=OAM-conn

Capture TTI Traces and Validate mitigation slot Per Cell
     ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
     ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
     set test variable      ${LOG_PATH}
     [Arguments]   ${LOG_PATH}   ${filename}    ${pysical_cell_ids}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=1s
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}


Capture TTI Traces Per Cell
     [Arguments]   ${LOG_PATH}   ${filename}   ${pysical_cell_ids}   ${duration}=1s
     ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
     ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
     set test variable      ${LOG_PATH}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=${duration}
     ${pcap_file}=    Set Variable           ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
     OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}

Capture TTI Traces Per Cell for disable
     [Arguments]   ${LOG_PATH}   ${filename}   ${pysical_cell_ids}   ${duration}=1s
     ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
     ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
     set test variable      ${LOG_PATH}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming1/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=${duration}
     ${pcap_file}=    Set Variable           ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
     OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming1/${filename}

Decode and Verify Manual mitigation enable
    [Arguments]    ${Test_Step}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${pcap_file}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}
#    Common TTI PCAP to CSV Converter   ${Test_Step}
#    Common TTI PCAP to CSV Converter   ${LOG_PATH}/ttitrace_streaming/${filename}
    Verify Manual mitigation enable    ${LOG_PATH}/ttitrace_streaming/${Test_Step}/output_ul_formated.csv
    Sleep    40s

Decode and Verify Manual mitigation disable
    [Arguments]    ${Test_Step1}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${pcap_file}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}
#    Common TTI PCAP to CSV Converter   ${Test_Step1}
#    Verify Manual mitigation disable    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step1}/dlFdSchedData.csv
     Verify Manual mitigation disable    ${LOG_PATH}/ttitrace_streaming1/${Test_Step1}/output_ul_formated.csv
    Sleep    40s

#Update GNB R&D Parameters
#   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
#   admin.Setup admin    bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   use_ssl=${USE_SSL}  name=swc
#   admin.download_software_config    ${LOG_PATH}/swconfig_gnb.txt   connection=swc
#   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
#   ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=OAM-conn
#   ssh.upload_file    local_path=${LOG_PATH}/swconfig_gnb.txt     remote_path=/ffs/run/swconfig.txt    connection=OAM-conn
#   ssh.send_command     command=crasign /ffs/run/swconfig.txt   connection=OAM-conn
#   ssh.send_command     command=craverify /ffs/run/swconfig.txt*    connection=OAM-conn
#   ssh.disconnect   connection=OAM-conn

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/ttitrace_streaming/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Run Keyword And Ignore Error    Dated Log              converting large ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Run Keyword And Ignore Error    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/dlFdSchedData.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/dlFdSchedData.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Common Convert Tti To Csv Mode
    [Arguments]         ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv


Verify Manual mitigation enable
    [Arguments]     ${file_path}
    manual_mitigation_enable.check_manual_mitigation_slots     ${file_path}

Verify Manual mitigation disable
    [Arguments]     ${file_path}
    manel_mitigation_disable.check_manual_mitigation_slots     ${file_path}


wts_sim_keywords.Validate UL Traffic For MultiUE for SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Validate DL Traffic For MultiUE SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}    ${end_ue_id}  ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
	END

Validate UL Traffic For MultiUE SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]   ${start_ue_id}    ${end_ue_id}    ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=ul
    ${bearer_stat_ul}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
	END

Activate LeapRIMRS
	${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=44444
    ...     \ numRsSetId=1 rimRsType=rsType1 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8
    ...     \ rsPattern1Period=50 rsPattern2Period=25 factorRsSequenceRS2=1 offsetRsSequence=1 factorRsSequence=1 offsetRsSequenceRS2=1
	...     \ repetitionRsType2=4 rim_framework=framework_1 numRsType2SetId=65536 numRsType1SetId=65536 repetitionRsType1=4
	...     \ startFreqOffsetForRs=1 globalF0ForRs=636672 leap_seconds_manual=27 leap_seconds_auto=on

    ute_wtssim.Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate


Register SA call and send data
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          Trigger DL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   dl_rate=50   pdu_id=1   trf_id=1   qfi_id=${QFI_ID1}
          Trigger UL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   ul_rate=1   pdu_id=1   trf_id=1   qfi_id=${QFI_ID1}
          sleep  5s   reason=data stable
          Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=${UE}     dl_rate=50
          ...   pdu_id=${Pdu_session_ID}    qfi_id=1
          Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=1
          ...   pdu_id=${Pdu_session_ID}    qfi_id=1
    END

Verify The Counter
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slots}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slots} == 300.0

Register NSA UE and Send High Data
    wts_sim_keywords.NSA Multi UE Attach should be Successful    Start_NSA_UE=21    END_NSA_UE=30     Target_Cells=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for NSA      start_ue_id=21     end_ue_id=30     Traffic_rate=mbps
    ...     dl_rate=70      id=2   trf_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for NSA      start_ue_id=21     end_ue_id=30     Traffic_rate=mbps
    ...     ul_rate=30      id=2   trf_id=1

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=Meghs --password=Meghuacchu@123 -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

MultiUE Deregister should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_idx} ue_deregister_type=switch_off by=ue
	ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=${UE_deregister_pattern}
    ... 	timeout=${EGATE_COMMAND_TIMEOUT}
    END
    BuiltIn.Log                multi_ue_deregister_is_ok
