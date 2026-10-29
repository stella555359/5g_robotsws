*** Settings ***
Documentation
...   author: mengli yang
...   contact: mengli.yang@nokia-sbell.com
...   this is a robot case about CB005882.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Force Tags    CRT             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

*** Variables ***
${NRCELL_1}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${NRCELL_2}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
${5GC000900_Fault_ID}      49
${testline_type}    CLOUD_5G_CLASSICAL_2xMIFI_ASIBR_ABIAB1_ABILB2_AHPMDA_AHEGB

*** Test Cases ***
5GC000474_LTEENB object locked incoming X2 reset and related counter verification
    [Tags]    CRT
    Precondition counter
	Start tcpdump by command
	Lock LTE object
	Stop tcpdump by command
	Check counter for 5GC000474_TC01
	Check tcpdump log for 5GC000474_TC01
	Unlock LTE object
	[Teardown]    Run keywords    5GC000474_TC01 Teardown    AND    Common Test Teardown For RRM

5GC000900_Successful_SA_calls_setup_when_gNB_is_operating_in_mixed_mode
    [Tags]    CRT
    LOCK cell for ENB
	Precondition counter
	Start tcpdump by command
    Attach UE0 And Start DL TPUT
	Stop tcpdump by command
	Check counter for SA
	[Teardown]    Run keywords    5GC000900_TC01 Teardown    AND    Common Test Teardown For RRM

*** Keywords ***
Prepare for FDD SA 64QAM 15M 1UE UL T-put testing
	${dict1}=    create dictionary    parameterName=chBwDl
    ...                               operation=update
    ...                               value=15MHz
	${dict2}=    create dictionary    parameterName=chBwUl
    ...                               operation=update
    ...                               value=15MHz
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRCELL_FDD-1
	...                                          parameter_delta_list=${parameter_delta_list}
	Sleep    800s
	COAM_Admin.Login
	${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
	Run Keyword If    ${cell_status}==${False}  reset site and wait cell onair

Tput UL Teardown
	Run Keyword And Ignore Error    Init Attenuation
	Run Keyword And Ignore Error    Stop UL THPUT And Detach UE0

Check TPUT for UL
    Check throughput     direction=ul    dl_expect=50    cellid=720897

Start BIP trace
    log to console    start bip log
    ${connection_ASIB}    Start Bip Capture with gnbMirroring scripts and MCShark    file_size_mbytes=200
    ...                                                                  number_of_files=1
    ...                                                                  mirror_abil_1=false
    ...                                                                  mirror_abil_6=true
	set test variable    ${connection_ASIB}
	sleep    4

Stop BIP trace for rank1
    ${list_log_path_local}    Stop BIP trace    local_log_name=Rank1.pcap
	...                                         connection_ASIB=${connection_ASIB}
    Set test variable    ${list_log_path_local}

Check BIP log for Rank1RMI0_backup
    ${UlData_PuschReceiveRespPs_filter}=    Set Variable
	...                                     UlData_PuschReceiveReq.grants_item_15.numOfLayers == 0x01
    ${xpath} =    Set Variable    .//UlData_PuschReceiveReq.grants_item_15.numOfLayers
	${values}    Parse Pcap by name with luashark      input_file=${list_log_path_local[0]}
	...                       expected_value=1
    ...                       filter_expression=UlData_PuschReceiveReq.grants_item_15.numOfLayers
    ...                       field_name=UlData_PuschReceiveReq.grants_item_15.numOfLayers

Check BIP log for Rank1RMI0
    [Arguments]    ${name}=Rank1
    ${filter}=    Set Variable
    ...    UlData_puschReceiveReqGrant_t.numOfLayers == 1
    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfLayers
    Convert BIP To CSV By MCShark    ${name}.pcap    ${TEST_LOG_DIRECTORY}/csv_${name}.csv    ${filter}    ${csv_title_list}
    ${filename} =    Set Variable    ${TEST_LOG_DIRECTORY}/csv_${name}.csv
    ${matrix}=    tti_analysis.read_csv_file_into_matrix    file_path=${filename}
    ${column_list}=    tti_analysis.get_column_from_matrix    matrix=${matrix}
    ...                                          column_nubmer=${3}
    should contain    ${column_list}    1

Check counter for 5GC000532_Support_of_Rank1_and_PMI_0_conducted_below6Ghz
    Log to console    check counter
	Sleep    300
	${pi_list}=  Create List    M55303C00000
    ${expect_value}    Set Variable    0
	${counter_id_value_list}    Check counter value    counter_ID=${pi_list[0]}    expect_value=${expect_value}
	${pi_list1}=  Create List    M55303C00028    M55303C01000
	...                         M55303C01028    M55303C02000    M55303C02004
	...                         M55303C03000    M55303C03002    M55303C04001
	...                         M55303C04002

5GC000532 Teardown
	Run Keyword And Ignore Error    Stop BIP trace witout collect
	Run Keyword And Ignore Error    Stop UL THPUT And Detach UE0
	Run Keyword And Ignore Error    Reboot VM

prepare testline setup
    Log to console    prepare testline setup
#######    5GC002060_StaticCall_DrxLongCycle_Counters_HighUL&DLTraffic    #######
Make Call with LowDL and Verify ping
	${pingres}=            Ping package with DL      ${ue0_type}    numberofping=120    intervalofpings=1
	Set Suite Variable    ${pingres}
	Sleep    20s

Make Call with LowDL
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=1M    duration=120

Check counter for 5GC002060_StaticCall_DrxLongCycle_LowBurstyUL&DLTraffic
	Sleep    400
	${pi_list}=  Create List    M55308C11001    M55308C11002
    ${expect_value}    Set Variable    0
	${counter_values_list_M55308C11001}    Check counter value    counter_ID=${pi_list[0]}
	...                                                           expect_value=${expect_value}
	${counter_values_list_M55308C11002}    Check counter value    counter_ID=${pi_list[1]}
	...                                                           expect_value=${expect_value}
	${counter_values}    Evaluate    ${counter_values_list_M55308C11001[-1]}/${counter_values_list_M55308C11002[-1]}
	should be true    ${counter_values} > 0.125

Start call with DL with TPUT
	Start DL TPUT for UE0
    sleep    25
    ${dl_status}  ${output}  run keyword and ignore error    Check throughput    direction=dl
    ...                                                                          dl_expect=50
    run keyword if  '${dl_status}'=='FAIL'  FAIL  throughput are less than expect
    Stop DL THPUT for UE0

Start call with UL with TPUT
    Start UL TPUT for UE0
    sleep    25
    ${dl_status}  ${output}  run keyword and ignore error    Check throughput    direction=ul
    ...                                                                          ul_expect=10
    run keyword if  '${dl_status}'=='FAIL'  FAIL  throughput are less than expect
    Stop UL THPUT for UE0

Check tcpdump log for 5GC002060_StaticCall_DrxLongCycle_Counters_HighUL&DLTraffic
    ${filter} =    Set Variable    f1ap
    ${filter_expression} =    Set Variable    nr-rrc.drx_Config == 1
    ${xpath} =    Set Variable    .//nr-rrc.drx_Config
	${value_list} =    Parse Pcap by xpath    input_file=${SUITE_LOG_PATH}/${tcpdump_log_name}
	...   filter=${filter}    filter_expression=${filter_expression}    xpath=${xpath}
	Should Be True    ${value_list[0]} == 1

Precondition Parameter for 5GC002060
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                               parameter=actCDrx    new_value=true
    @{value_list}    create list
	${value}=    create dictionary     drxLongCycle=320ms
	...                               drxOnDurationTimer=80ms
	...                               drxInactivityTimer=40ms
	...                               drxRetransTimerDl=16slot
	...                               drxRetransTimerUl=16slot
    append to list    ${value_list}    ${value}
	@{value1_list}    create list
	${value1}=    create dictionary    csiReportPeriodicity=slots320
    append to list    ${value1_list}    ${value1}
	${dict1}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{value_list}
	${dict2}=    create dictionary    parameterName=periodicCsiAcquisition
    ...                               operation=update
    ...                               value=${value1_list}
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                                          parameter_delta_list=${parameter_delta_list}


#######    5GC001983_Verify the UL SU-MIMO when codebookSubset is noncoherent    #######
Check tcpdump log for 5GC001983_Verify the UL SU-MIMO when codebookSubset is noncoherent
    ${filter_expression} =    Set Variable    nr-rrc.bandNR && nr-rrc.pusch_TransCoherence == 0
	Parse Pcap by expression    input_file=${capture_file_path}
    ...                         filter_expression=${filter_expression}

#######    5GC000474_Successful X2 act SCTP shutdown due to no traffic and related counters verification    #######
5GC000474_TC02 Teardown
    Init Attenuation
    Recover shutdownNoX2TrafficTmr
    Run Keyword And Ignore Error    Stop Tcpdump without collect

UE0 attach and detach
    Prepare UE0
    Attach UE0
    Detach UE0
Set shutdownNoX2TrafficTmr
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...                               parameter=shutdownNoX2TrafficTmr    new_value=1
Recover shutdownNoX2TrafficTmr
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...                               parameter=shutdownNoX2TrafficTmr    new_value=24
Check counter for sctp shutdown
	${pi_list}=  Create List    M55110C00001    M55110C00003
    ${expect_value}    Set Variable    0
	${counter_values_list_M55110C00001}    Check counter value    counter_ID=${pi_list[0]}
	...                                                           expect_value=${expect_value}
	${counter_values_list_M55110C00003}    Check counter value    counter_ID=${pi_list[1]}
	...                                                           expect_value=${expect_value}
Check tcpdump log with X2 SCTP shutdown
    ${filter} =    Set Variable    f1ap
    ${filter_expression_active} =    catenate    sctp.chunk_type == 8
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_expression_active}

##########    5GC001877_5GC000772_C_Online Change of setting of DRX profile in NSA mode    ##########
Check Aasyslog_newParameters
	${btslog_prints}=    Create list
	...    drx-onDurationTimerLen=20
	...    drx-longCycle=80
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name1}
    ...             filter=drx

Modify DRX Profile for GNB
    @{value_list}    create list
	${value}=    create dictionary    drxLongCycle=80ms
	...                               drxOnDurationTimer=40ms
	...                               drxInactivityTimer=30ms
	...                               drxRetransTimerDl=24slot
	...                               drxRetransTimerUl=24slot
    append to list    ${value_list}    ${value}
	${dict1}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{value_list}
    @{parameter_delta_list}=    create list    ${dict1}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                                          parameter_delta_list=${parameter_delta_list}
##########    5GC001877_5GC000772_C_Online Change of setting of actCDrx in NSA mode    ##########
Check Aasyslog_actCDrx_false
    Log    Checking BTS Syslog to confirm parameter change.    console=True
	${btslog_prints}=    Create list
	...    drx-onDurationTimerLen=20
	...    drx-longCycle=80
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name1}
    ...             filter=drx

Check Btslog with old value
    Log    Checking BTS Syslog to confirm parameter change.    console=True
	${btslog_prints}=    Create list
	...    drx-onDurationTimerLen=20
	...    drx-longCycle=80
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name1}
    ...             filter=drx

Set actCDrx to false
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                               parameter=actCDrx    new_value=false

Check Aasyslog for 5GC001877
	${btslog_prints}=    Create list
	...    drx-onDurationTimerLen=20
	...    drx-longCycle=80
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name1}
    ...             filter=drx

Check Btslog For 5GC001877
    Log    Checking BTS Syslog to confirm parameter change.    console=True
	${btslog_prints}=    Create list
	...    drx-onDurationTimerLen=20
	...    drx-longCycle=80
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name1}
    ...             filter=drx

Precondition Parameter for 5GC001877
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                               parameter=actCDrx    new_value=true
    @{value_list}    create list
	${value}=    create dictionary     drxLongCycle=80ms
	...                               drxOnDurationTimer=20ms
	...                               drxInactivityTimer=40ms
	...                               drxRetransTimerDl=16slot
	...                               drxRetransTimerUl=16slot
    append to list    ${value_list}    ${value}
	@{value1_list}    create list
	${value1}=    create dictionary    csiReportPeriodicity=slots320
    append to list    ${value1_list}    ${value1}
	${dict1}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{value_list}
	${dict2}=    create dictionary    parameterName=periodicCsiAcquisition
    ...                               operation=update
    ...                               value=${value1_list}
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                                          parameter_delta_list=${parameter_delta_list}

LOCK cell for ENB
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
	...    parameter=administrativeState     new_value=locked

UnlOCK cell for ENB
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
	...    parameter=administrativeState     new_value=unlocked

Tput DL Teardown
    Run Keyword And Ignore Error    Set ALL AMF To Unlocked
	Run Keyword And Ignore Error    Init Attenuation
	Run Keyword And Ignore Error    Stop DL THPUT And Detach UE0
	Run Keyword And Ignore Error    Stop DL THPUT And Detach UE1

Check tcpdump log for FDD NSA 256QAM 20M 2UE Mobility DL T-Put testing
    ${measurementReport_filter} =    catenate    nr-rrc.measResultServingCell_element && nr-rrc.physCellId
    ...    && nr-rrc.MeasResultNR_element && nr-rrc.physCellId
    ${measurementReport} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${measurementReport_filter}
	should contain    ${measurementReport}    Measurement Report

    ${handover_filter} =    catenate    x2ap.radioNetwork == 0
    ${handover} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${handover_filter}
    should contain    ${handover}    RRC Reconfiguration

Check tcpdump log for FDD NSA 256QAM 20M 2UE Mobility UL T-Put testing
    ${measurementReport_filter} =    catenate    nr-rrc.measResultServingCell_element && nr-rrc.physCellId
    ...    && nr-rrc.MeasResultNR_element && nr-rrc.physCellId
    ${measurementReport} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${measurementReport_filter}
	should contain    ${measurementReport}    Measurement Report

    ${handover_filter} =    catenate    x2ap.radioNetwork == 0
    ${handover} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${handover_filter}
    should contain    ${handover}    RRC Reconfiguration

Check throughput for FDD NSA 256QAM 20M 2UE Mobility DL T-Put testing for cell1
    Check throughput     direction=dl    dl_expect=120    cellid=720897

Check throughput for FDD NSA 256QAM 20M 2UE Mobility DL T-Put testing for cell2
    Check throughput     direction=dl    dl_expect=120    cellid=720898

Check throughput for FDD NSA 256QAM 20M 2UE Mobility UL T-Put testing for cell1
    Check throughput     direction=ul    dl_expect=120    cellid=720897

Check throughput for FDD NSA 256QAM 20M 2UE Mobility UL T-Put testing for cell2
    Check throughput     direction=ul    dl_expect=120    cellid=720898

CB005892_B_UL Teardown
    Run Keyword And Ignore Error    Stop TTI log
	Run Keyword And Ignore Error    Stop UL THPUT And Detach UE0
	Run Keyword And Ignore Error    Stop UL THPUT And Detach UE1

Check tti log for CB005892_B_UL scheduling of up to 2 UEs in a single slot in FDD (SA)
    Log to console    analysis tti
    ${local_csv_file_path}    Convert TTI trace to CVS and download csv logs to test pc
    ...    connection_ABIL=${connection_ABIL}
	set test variable    ${local_csv_file_path}
	${list_index_ul}    Get index of parameters for ul
	set test variable    ${list_index_ul}
	${rnti}    Get rnti    local_csv_file_path=${local_csv_file_path['UL']}
	${sfn_list_ue1}    Get sfn    local_csv_file_path=${local_csv_file_path['UL']}
    ...                       list_index=${list_index_ul}
    ...                       rnti=${rnti[0]}
    ...                       event_name=ulFdSchedData
    set test variable    ${sfn_list_ue1}
    ${sfn_list_ue2}    Get sfn    local_csv_file_path=${local_csv_file_path['UL']}
    ...                       list_index=${list_index_ul}
    ...                       rnti=${rnti[1]}
    ...                       event_name=ulFdSchedData
    set test variable    ${sfn_list_ue2}
    ${slot_list_ue1}    Get slot    local_csv_file_path=${local_csv_file_path['UL']}
    ...                       list_index=${list_index_ul}
    ...                       rnti=${rnti[0]}
    ...                       event_name=ulFdSchedData
    set test variable    ${slot_list_ue1}
    ${slot_list_ue2}    Get slot    local_csv_file_path=${local_csv_file_path['UL']}
    ...                       list_index=${list_index_ul}
    ...                       rnti=${rnti[1]}
    ...                       event_name=ulFdSchedData
    set test variable    ${slot_list_ue2}
    ${same_value_list}    Get same value for two list    list1=${sfn_list_ue1}    list2=${sfn_list_ue2}
    Should Not Be Empty    ${same_value_list}
    ${same_value_list}    Get same value for two list    list1=${slot_list_ue1}    list2=${slot_list_ue2}
    Should Not Be Empty    ${same_value_list}

Check counter for CB005892_B_UL scheduling of up to 2 UEs in a single slot in FDD (SA)
    Log to console    check counter
	Sleep    300
	${pi_list}=  Create List        M55308C18002
    ${expect_value}    Set Variable    0
	FOR  ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value    counter_ID=${counter_ID}    expect_value=${expect_value}
	END

Start TTI log
    Log to console    start tti for GNB
	${connection_ABIL}    Start TTI trace log capturing
	set test variable    ${connection_ABIL}
	Sleep    10s

Stop TTI log
    Log to console    stop tti for GNB
    Stop TTI trace log capturing    connection_ABIL=${connection_ABIL}

Precondition counter and start call
	Wait For New Measurement Period
	Attach UE0 And Start UL TPUT
	Attach UE1 And Start UL TPUT
	Delete before PM counter file

5GC000900_TC01 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Stop Tcpdump without collect
	Run Keyword And Ignore Error    Stop DL THPUT And Detach UE0
	Get SCF Internal Id By Scout    no_ute=False

Check counter for SA
	sleep    300
	${pi_list}=  Create List    M55145C00501
    ${expect_value}    Set Variable    0
	${counter_id_value_list}    Check counter value    counter_ID=${pi_list[0]}
	...                                                expect_value=${expect_value}
5GC000746_TC01 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Stop DL THPUT And Detach UE0
	Run Keyword And Ignore Error    Stop Tcpdump without collect
Check counter with WRITE-REPLACE WARNING REQUEST
    Log to console    check counter
	sleep    300s
	${pi_list}=  Create List   M55119C02001    M55119C02002
    ${expect_value}    Set Variable    1
	FOR  ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value equal expect value    counter_ID=${counter_ID}
	    ...                                                                   expect_value=${expect_value}
	END
Precondition Parameter for 5GC000746_A_026
	${dict1}=    create dictionary    parameterName=siWindowLength
    ...                               operation=update
    ...                               value=s10
	@{parameter_delta_list}=    create list    ${dict1}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE-1
	...                                          parameter_delta_list=${parameter_delta_list}
	${dict3}=    create dictionary    parameterName=actTimeAlignExtension
    ...                               operation=update
    ...                               value=false
	${dict4}=    create dictionary    parameterName=actCMAS
    ...                               operation=update
    ...                               value=true
	@{parameter_delta_list1}=    create list    ${dict3}    ${dict4}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...                                          parameter_delta_list=${parameter_delta_list1}
Check tcpdump log with SIB8
    ${filter} =    Set Variable    f1ap
    ${filter_expression}=    catenate    f1ap.sIBtype == 8 and
	...                                  nr-rrc.warningMessageSegment.nb_pages == 4
	Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_expression}

5GC000746_TC03 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Stop Tcpdump without collect

Check counter with PWSCancel
    Log to console    check counter
	sleep    300s
	${pi_list}=  Create List    M55119C02004    M55119C02005
    ${expect_value}    Set Variable    1
	FOR  ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value equal expect value    counter_ID=${counter_ID}
	    ...                                                                   expect_value=${expect_value}
	END

Check tcpdump log with PWSCancel
    ${filter} =    Set Variable    ngap
	${filter_PWSCancelRequest} =    Catenate    ngap.PWSCancelRequest_element and
	...                                   ngap.procedureCode == 32
    ${filter_PWSCancelResponse} =    Catenate    ngap.PWSCancelResponse_element and
	...                                   ngap.procedureCode == 32
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_PWSCancelRequest}
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_PWSCancelResponse}
Trigger PWS Cancel
    CMAS PWS Cancel        amf=&{AMF6_Han}
    ...                    nr_of_bits_g_node_b_id=32
    ...                    cell_id=1
    ...                    connection=${cbctest_alias}

5GC000746_TC02 Teardown
    UnlOCK cell for ENB
    Unlock NRCELL1
	Run Keyword And Ignore Error    Stop Tcpdump without collect

Check counter with PWS Failure Indication
    [Timeout]  11 min
    Log to console    check counter
	sleep    300s
	${pi_list}=  Create List   M55119C02003
    ${expect_value}    Set Variable    1
	${counter_id_value_list}    Check counter value equal expect value    counter_ID=${pi_list[0]}
	...                                                                   expect_value=${expect_value}
Check tcpdump log with PWS Failure Indication
    ${filter_expression} =    Set Variable     ip.dst == 10.107.180.5 && ngap.PWSFailedCellIDLis
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_expression}
	Parse Pcap by xpath with confirm    expected_value=23
	...                                 input_file=${capture_file_path}
	...                                 filter=f1ap
    ...                                 xpath=.//f1ap.initiatingMessage_element/f1ap.procedureCode
Trigger CMAS Notification
    Log to console    trigger cmas
    CMAS Notification    amf=${AMF6_Han}
    ...                          message_identifier=4372    serial_number=51
    ...                          repetition_period=5
    ...                          number_of_broadcasts_requested=${10}
    ...                          connection=${cbctest_alias}
	...                          nr_of_bits_g_node_b_id=22
    ...                          cell_id=1
Set actCMAS To true
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...    parameter=actCMAS     new_value=true

5GC000740_TC03 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Unlock NRCELL1
	Run Keyword And Ignore Error    Stop Tcpdump without collect

Check tcpdump with RAN config update
    ${filter} =    Set Variable    NGAP
    ${filter_expression_AMF1} =    catenate    ip.dst == 10.107.180.5 && ngap.tAC == 210
    ${RANConfigurationUpdate_AMF1}    Parse Pcap by expression    input_file=${capture_file_path}
	...                                                     filter_expression=${filter_expression_AMF1}
    ${filter_expression_AMF2} =    catenate    ip.dst == 10.110.66.198 && ngap.tAC == 210
    ${RANConfigurationUpdate_AMF2}    Parse Pcap by expression    input_file=${capture_file_path}
	...                                                     filter_expression=${filter_expression_AMF2}
    ${filter_expression_AMF3} =    catenate    ip.dst == 10.108.221.70 && ngap.tAC == 210
    ${RANConfigurationUpdate_AMF3}    Parse Pcap by expression    input_file=${capture_file_path}
	...                                                     filter_expression=${filter_expression_AMF3}
5GC000740_TC02 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Set actNgcFlexSaMode To true
	Run Keyword And Ignore Error    Stop Tcpdump without collect
Check tcpdump with 3AMF
    ${filter} =    Set Variable    NGAP
    ${AMF1_filter_expression} =    Set Variable    ngap.AMFName == "amf-amfhan2"
	${AMF2_filter_expression} =    Set Variable    ngap.AMFName == "amf2-amfsui1"
	${AMF3_filter_expression} =    Set Variable    ngap.AMFName == "amf4-amf4"
	${AMF1_filtered_packets} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${AMF1_filter_expression}
	${AMF2_filtered_packets} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${AMF2_filter_expression}
	${AMF3_filtered_packets} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${AMF3_filter_expression}
Set ALL AMF To Unlocked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
	...    parameter=administrativeState    new_value=Unlocked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-2
	...    parameter=administrativeState    new_value=Unlocked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-3
	...    parameter=administrativeState    new_value=Unlocked
Set ALL AMF To Locked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
	...    parameter=administrativeState    new_value=Locked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-2
	...    parameter=administrativeState    new_value=Locked
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-3
	...    parameter=administrativeState    new_value=Locked
Set actNgcFlexSaMode To false
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...    parameter=actNgcFlexSaMode     new_value=false
Set actNgcFlexSaMode To true
	COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	...    parameter=actNgcFlexSaMode     new_value=true
Check SCTP_association_establishment with main AMF

   COAM_Admin.get parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-${NRBTS_ID}/SERVEDAMF_R-1
   ...                          pattern=ngLinkStatus
   ...                          value=Active
   COAM_Admin.get parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-${NRBTS_ID}/SERVEDAMF_R-2
   ...                          pattern=ngLinkStatus
   ...                          value=Inactive
   COAM_Admin.get parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-${NRBTS_ID}/SERVEDAMF_R-3
   ...                          pattern=ngLinkStatus
   ...                          value=Inactive
5GC000740_TC01 Teardown
    UnlOCK cell for ENB
	Run Keyword And Ignore Error    Set actNgcFlexSaMode To true

5GC000630 Teardown
    Run Keyword And Ignore Error    Stop UL THPUT And Detach UE0

5GC000630_2 Teardown
    Run Keyword And Ignore Error    Stop DL THPUT And Detach UE0

5GC001876 Teardown
    Run Keyword And Ignore Error    Stop Tcpdump without collect
    Stop DL THPUT And Detach UE0
    Recover Parameter for 5GC001876_classical_cmw_NSA_counter_is_update_in_DRXactive

Check tcpdump log for 5GC001876_classical_cmw_NSA_counter_is_update_in_DRXactive
	${filter_expression} =    catenate    nr-rrc.drx_Config == 1
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                         filter_expression=${filter_expression}

Check counter for 5GC001876_classical_cmw_NSA_counter_is_update_in_DRXactive
    Log to console    check counter
    Sleep    300s
	${pi_list}=  Create List    M55308C11001    M55308C11002
    ${expect_value}    Set Variable    0
	${counter_values_list_M55308C11001}    Check counter value    counter_ID=${pi_list[0]}
	...                                                           expect_value=${expect_value}
	${counter_values_list_M55308C11002}    Check counter value    counter_ID=${pi_list[1]}
	...                                                           expect_value=${expect_value}
	${counter_value}    Evaluate    ${counter_values_list_M55308C11001[-1]}/${counter_values_list_M55308C11002[-1]}
	Should Be True    ${counter_value} > 0.1
Precondition Parameter for 5GC001876_classical_cmw_NSA_counter_is_update_in_DRXactive
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                               parameter=actCDrx    new_value=true
    @{value_list}    create list
	${value}=    create dictionary     drxLongCycle=80ms
	...                               drxOnDurationTimer=20ms
	...                               drxInactivityTimer=40ms
	...                               drxRetransTimerDl=16slot
	...                               drxRetransTimerUl=16slot
    append to list    ${value_list}    ${value}
	@{value1_list}    create list
	${value1}=    create dictionary    csiReportPeriodicity=slots320
    append to list    ${value1_list}    ${value1}
	${dict1}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{value_list}
	${dict2}=    create dictionary    parameterName=periodicCsiAcquisition
    ...                               operation=update
    ...                               value=${value1_list}
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}
	COAM_Admin.perform_object_recommissioning    dist_name=${NRCELL_1}
	...                                          parameter_delta_list=${parameter_delta_list}
Recover Parameter for 5GC001876_classical_cmw_NSA_counter_is_update_in_DRXactive
	COAM_Admin.set parameter value    dist_name=${NRCELL_1}
	...                               parameter=actCDrx    new_value=false
5GC000900_TC02 Teardown
	Run Keyword And Ignore Error    Unlock NRCELL1
	Run Keyword And Ignore Error    Stop Tcpdump without collect
	Run Keyword And Ignore Error    Stop DL THPUT And Detach UE0
	Run Keyword And Ignore Error    Set ALL AMF To Unlocked

Check counter for 5GC000900_Successful_NSA_calls_setup_when_gNB_is_operating_in_mixed_mode
	sleep    300
	${pi_list}=  Create List    M55145C00005
    ${expect_value}    Set Variable    0
	${counter_id_value_list}    Check counter value    counter_ID=${pi_list[0]}
	...                                                expect_value=${expect_value}
Lock NRCELL1
	COAM_Admin.lockcell    ${NRCELL_1}
	sleep    20s
Unlock NRCELL1
	COAM_Admin.unlock_cell    ${NRCELL_1}
	sleep    60s
Check counter for 5GC000718_the_new_DU_counters_update_verification
#    Log to console    check counter
	${pi_list}=  Create List    M55117C00528    M55117C00532    M55117C00533
    ${expect_value}    Set Variable    0
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
	${counter_id_value_list}    Check counter value    counter_ID=${pi_list[0]}
	...                                                expect_value=${expect_value}
	${pi_list1}=  Create List    M55117C00534    M55117C00536    M55117C00538    M55117C00542
	...                         M55117C00543    M55117C00544    M55117C00545    M55117C00546
	...                         M55117C00547    M55117C00548    M55117C00549    M55117C00551
	...                         M55117C00552    M55117C00553    M55117C00554
    FOR  ${counter_ID}  IN  @{pi_list1}
        Check counter value include zero   counter_ID=${counter_ID}
	END

Check counter for 5GC000718_the_new_CU_counters_update_verification
#    Log to console    check counter
	${pi_list}=  Create List    M55150C00023    M55150C00024    M55150C00026    M55150C00027
    ${expect_value}    Set Variable    0
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
	FOR  ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value    counter_ID=${counter_ID}
	...                                                     expect_value=${expect_value}
	END
	${pi_list1}=  Create List    M55150C00025    M55150C00028    M55150C00029    M55150C00031
	...                         M55150C00035    M55150C00036    M55150C00037    M55150C00038
	...                         M55150C00039    M55150C00040    M55150C00041    M55150C00042
	...                         M55150C00043    M55150C00044    M55150C00045    M55150C00046
	...                         M55150C00051    M55150C00052    M55150C00053
	FOR  ${counter_ID}  IN  @{pi_list1}
        ${counter_id_value_list}    Check counter value include zero   counter_ID=${counter_ID}
	END

Reset Site
	COAM_Admin.ResetSite
	Sleep    600s

Precondition counter
	Wait For New Measurement Period
	Delete before PM counter file

Change Attenuation to trigger handover
    Log to console    change attenuation, trigger handover
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[2]}=0   ${attenuation_channels[3]}=0
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep   5s
	&{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=20   ${attenuation_channels[1]}=20
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep   20s
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=63   ${attenuation_channels[1]}=63
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    Log to console    \nattenuation change complete

handover case Init Attenuation
    Log to console    change attenuation
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0
    ...                                          ${attenuation_channels[2]}=63   ${attenuation_channels[3]}=63
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete

Init Attenuation
    Log to console    change attenuation
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0
    ...                                          ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
    ...                                          ${attenuation_channels[4]}=0    ${attenuation_channels[5]}=0
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete

Adapt Attenuation close signale
    Log to console    change attenuation
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[4]}=63    ${attenuation_channels[5]}=63
#    ...                                          ${attenuation_channels[2]}=0   ${attenuation_channels[3]}=0
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete

Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}

Stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}

Lock LTE object
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNADJGNB-1
	...                               parameter=administrativeState    new_value=locked
	...                               connection=COAM
	Sleep    500

Unlock LTE object
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNADJGNB-1
	...                               parameter=administrativeState    new_value=unlocked
Check counter for 5GC000474_TC01
	${pi_list}=  Create List    M55110C00009
    ${expect_value}    Set Variable    0
	${counter_values_list_M55110C00009}    Check counter value   counter_ID=${pi_list[0]}
	...                                                          expect_value=${expect_value}

Check tcpdump log for 5GC000474_TC01
    ${ResetRequest_element} =    catenate    x2ap.ResetRequest_element
    ${ResetResponse_element} =    catenate    x2ap.ResetResponse_element
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${ResetRequest_element}
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${ResetResponse_element}

5GC000474_TC01 Teardown
    Unlock LTE object
    Run Keyword And Ignore Error    Stop Tcpdump without collect
    Get SCF Internal Id By Scout    no_ute=False

Check counter for 5GC000630_Number_of_downlink_PDCP_PDU_sent_over_F1-U
    Log to console    check counter
	${pi_list}=  Create List    M55314C02007    M55314C03007    M55314C14007    M55314C21001
	...                         M55323C00007    M55323C01007    M55323C07007
    ${expect_value}    Set Variable    0
    sleep    300s
	FOR    ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value    counter_ID=${counter_ID}
	    ...                                                expect_value=${expect_value}
	END

Check counter for 5GC000630_Number_of_uplink_PDCP_PDU_sent_over_F1-U
    Log to console    check counter
	${pi_list}=  Create List    M55314C04007    M55314C05007    M55314C06007
	...                         M55323C02007    M55323C03007
    ${expect_value}    Set Variable    0
    sleep    300s
	FOR  ${counter_ID}  IN  @{pi_list}
	    ${counter_id_value_list}    Check counter value    counter_ID=${counter_ID}
	    ...                                                expect_value=${expect_value}
	END
##########    UE related    ##########
Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}
Prepare UE1
    ${ue1_type}    translate_power_ue_type_from_testline    ue_index=${1}
	set test variable    ${ue1_type}
    Prepare UE    ${ue1_type}    ue_index=${1}
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
#	Sleep    60s
Attach UE1
    UE Attach    ${ue1_type}    ue_index=${1}
#	Sleep    60s
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=600
Start UL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=100M    duration=300
Start DL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=dl    dt_index=${1}
	...              throughput=110M    duration=600
Start UL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=ul    dt_index=${1}
	...              throughput=100M    duration=300
Stop DL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Detach UE0
Stop Both DL AND UL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop DL THPUT And Detach UE1
    Stop DL THPUT for UE1
    Detach UE1
Stop UL THPUT And Detach UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop UL THPUT And Detach UE1
    Stop UL THPUT for UE1
    Detach UE1

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}
Detach UE1
    UE Detach    ${ue1_type}    ue_index=${1}

Stop DL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=dl
Stop UL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul
Stop DL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=dl
Stop UL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=ul

Attach UE0 And Start Both DL And UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    Start UL TPUT for UE0
    sleep    10s

Attach UE0 And Start DL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    sleep    10s

Attach UE0 And Start UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start UL TPUT for UE0
    sleep    10s

Attach UE1 And Start DL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start DL TPUT for UE1
    sleep    10s

Attach UE1 And Start UL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start UL TPUT for UE1
    sleep    10s


Modify Parameter To True For CNI-60777
	${dict1}=    create dictionary    parameterName=actFlexCaMgmt
    ...                               operation=update
    ...                               value=true
	${dict2}=    create dictionary    parameterName=actDLCAggr
    ...                               operation=update
    ...                               value=true
    ${dict3}=    create dictionary    parameterName=actAmbrModCaTrigger
    ...                               operation=update
    ...                               value=true
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}    ${dict3}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
	...                                          parameter_delta_list=${parameter_delta_list}
	Sleep    800s
	COAM_Admin.Login
	Wait Until Keyword Succeeds    3 min    10 sec     Verify bts and all cell status should be onair

Modify Parameter To False For CNI-60777
	${dict1}=    create dictionary    parameterName=actFlexCaMgmt
    ...                               operation=update
    ...                               value=false
	${dict2}=    create dictionary    parameterName=actDLCAggr
    ...                               operation=update
    ...                               value=false
    ${dict3}=    create dictionary    parameterName=actAmbrModCaTrigger
    ...                               operation=update
    ...                               value=false
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}    ${dict3}
	COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
	...                                          parameter_delta_list=${parameter_delta_list}
	Sleep    800s
	COAM_Admin.Login
	Wait Until Keyword Succeeds    3 min    10 sec     Verify bts and all cell status should be onair