*** Settings ***
Documentation     CB0013709 case
...
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_13709_B2_MP_AP_LOOO_2.xml
${AIRPHONE_NAME}      IPHY_13709_BB2_MP_AP_LOOO.xml
${WTS_NAME}           WTS_BB2_6CC_2TDD4FDD.lua


${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               26
${UE_NUM_SA_BEARER}         6
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${UE_TDD_ID}          1
${UE_FDD_ID}          401
${UE_NUM_FDD_BEARER}         5
${UE_NUM_FDD}                20
${CHECK_COUNTER_NUM}        6
${CHECK_COUNTER_TIMES}      4
${LOW_UE_ID}                1
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60



*** Test Cases ***
CB013709_B_B2_case004_Interworking_with_DL_Interference_Avoidance_RBG_randomization_handling_during_high_load_TDD
    Step1:Commission configuration for onair
    Step2:Trigger TDD cell everity metrics for high load and check counter and check counter
    Step3:onLine change actDlRbgRandomization disabled
    Step4:onLine change actDlRbgRandomization to enhanced
    step5:detach some UEs
    step6:enable actDlInterferenceAvoidance

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add Common RD parameter
    Add 13079_A RD parameter
    Add 13079_B RD parameter
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H3H3_ALN60_ARP60_P00_COVERAGE_00444_00002
    Prepare gnb onair    multi_cells=True


Step2:Trigger TDD cell everity metrics for high load and check counter and check counter
    Log To Console   \n----------Step2:Trigger TDD cell everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step2_highload' file
    Attach '${UE_NUM_SA_BEARER}' SA UE'${UE_ID}'
    Send data to SA UE    ue_num=${UE_NUM_SA_BEARER}    dl_tput=175M   ul_tput=50M
    Wait '60s' for stabible
    Check 13079_B TDD cell PM counters    cell_grp_id=0    PM_dir=step2
    Start collect ttitrace
    Wait for '0.5s' to stop ttitrace with name'step2_tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step2_highload' file

Online change actDlRbgRandomization to '${flag}'
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    actDlRbgRandomization    ${flag}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online

Step3:onLine change actDlRbgRandomization disabled
    Log To Console   \n----------Step3:change actDlRbgRandomization and actDlInterferenceAvoidance to disabled -------
	Start capture gnb and ap syslog in 'step3' file
    Online change actDlRbgRandomization to 'disabled'
	check 13709_B disabled logs    PM_dir=step3
	Start collect ttitrace
    Wait for '0.5s' to stop ttitrace with name'step3_tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step3' file

Step4:onLine change actDlRbgRandomization to enhanced
    Log To Console   \n----------Step4:change actDlRbgRandomization to enhanced -------
	Start capture gnb and ap syslog in 'step4' file
    Online change actDlRbgRandomization to 'enhanced'
	Check 13079_B TDD cell PM counters    PM_dir=step4
	Start collect ttitrace
    Wait for '0.5s' to stop ttitrace with name'step4_tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step4' file

step5:detach some UEs
    Log To Console   \n----------Step5:detach some UEs -------
	Start capture gnb and ap syslog in 'step5_detach_some_UES' file
    detach some '${UE_NUM_SA_BEARER}' SA UE'${UE_ID}'
    Wait '60s' for stabible
    check 13709_B low load after detach UE    cell_grp_id=0    PM_dir=step5
    Start collect ttitrace
    Wait for '0.5s' to stop ttitrace with name'step5_tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step5_detach_some_UES' file

step6:enable actDlInterferenceAvoidance
    Log To Console   \n----------Step6:enable actDlInterferenceAvoidance -------
	Start capture gnb and ap syslog in 'step6_enable_actDlInterferenceAvoidance' file
    Online recommissioning with delta json file    ${CURDIR}/ini/CB013709_actDlInterferenceAvoidance.json
    #attach 1UE, not trigger high load
    Wait '180s' for stabible
    FOR    ${i}    IN RANGE    1    2
        Run Keyword And Ignore Error    Attach UE to cell    ${i}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    30M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    150M    2
    END
    Wait '300s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${cell1_BB2}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}    counter_id=M55208C00019
    ...    cell_grp_id=0
    ${cell1_19}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00019
    ...    cell_id=1
    ${cell1_08}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10008
    ...    cell_id=1
    run keyword and continue on failure    should be true    ${cell1_BB2}==0
    run keyword and continue on failure    should be true    ${cell1_19}>0
    run keyword and continue on failure    should be true    ${cell1_08}>0
    #attach 7UE, trigger high load
    FOR    ${i}    IN RANGE    2    8
        Run Keyword And Ignore Error    Attach UE to cell    ${i}
        Run Keyword And Ignore Error    Send trf for UE    ${i}    UL    30M    1
        Run Keyword And Ignore Error    Send trf for UE    ${i}    DL    150M    2
    END
    Wait '300s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${cell1_BB2}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}    counter_id=M55208C00019
    ...    cell_grp_id=0
    ${cell1_19}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00019
    ...    cell_id=1
    ${cell1_08}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10008
    ...    cell_id=1
    run keyword and continue on failure    should be true    ${cell1_BB2}>350 and ${cell1_BB2}<400
    run keyword and continue on failure    should be true    ${cell1_19}==0
    run keyword and continue on failure    should be true    ${cell1_08}==0
    #deattach UEs, back to low load
    FOR    ${i}    IN RANGE    2    8
	    airphone_sa_detach    ue_id=${i}    timeout=30
    END
    Wait '300s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${cell1_BB2}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}    counter_id=M55208C00019
    ...    cell_grp_id=0
    ${cell1_19}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00019
    ...    cell_id=1
    ${cell1_08}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10008
    ...    cell_id=1
    run keyword and continue on failure    should be true    ${cell1_BB2}==0
    run keyword and continue on failure    should be true    ${cell1_19}>0
    run keyword and continue on failure    should be true    ${cell1_08}>0
    #Start collect ttitrace
    #Wait for '0.5s' to stop ttitrace with name'step6_tti_tdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step6_enable_actDlInterferenceAvoidance' file


detach some '${LOW_UE_ID}' SA UE'${UE_NUM_SA}'
    FOR    ${num}    IN RANGE    ${UE_NUM_SA}    ${LOW_UE_ID}+${UE_NUM_SA}+1
        Airphone SA Detach    ue_id=${num}
    END

Add 13079_B RD parameter
    Add GNB swconfig    0x5808EC:9009 #rdIntfAvdRbgRandOlcDlPerCent

Add 13079_C RD parameter
    Add GNB swconfig    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent
    Add GNB swconfig    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
    Add GNB swconfig    0x5808fc:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent
    Add GNB swconfig    0x5901cf:4096 #rdStateHistoryBufferRuntimeSize

Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:4004004 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:4004004 #rdMaxNumUeTdUl
    #13709-nrt
    Add GNB swconfig    0x580932:5 #rdNbProcedureContextsMaxLimit
    Add GNB swconfig    0x580933:1 #rdNbProcedureContextsLow
    #0x580934 = 2 #rdNbProcedureContextsHigh
    #13709-core
    #0x580821 = 30030030 #rdMaxAdaptiveSlotProcessingRatio_perCent
    Add GNB swconfig    0x580822:65065065 #rdMinAdaptiveSlotProcessingRatio_perCent

Add 13079_D RD parameter
	Add GNB swconfig    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x5902BA:1 #rdEnableCB013709#CPRT
    Add GNB swconfig    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x6601EF:1 #rdEnableCB013709#CPNRT
#    Add GNB swconfig    0x5A0614:1 #rdDebugBearerManagement#L2HICU
#    Add GNB swconfig    0x5A0605:1 #rdDebugBufferConsumption #L2HIDU
#    Add GNB swconfig    0x5A0616:1  #rdDebugPacketRetention#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugDlDataLimiter#L2HICU
#    Add GNB swconfig    0x5a008f:1 #rdBufferCongestionTracingEnabled#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugPacketRetention#L2HIDU

Add Common RD parameter
    Add GNB swconfig    0x9D0000:15
    #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x590072:1
#     #CP-NRT log level (avaiable after 19B, default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x41001b:1
#     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x590072:1
#     #CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x66001b:1
#     #CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890001:1
#     #CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890002:1
#     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890003:1
#     #CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890004:1
#     #CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890005:1
#     #CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     Add GNB swconfig    0x890006:1

check 13709_B low load after detach UE
    [Arguments]    ${cell_grp_id}=0     ${PM_dir}=step
    Wait '120s' for stabible
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}${PM_dir}${/}
	Check 13709_B low load counters    ${PM_counter_file}    cell_grp_id=${cell_grp_id}

Check 13709_B low load counters
    [Arguments]    ${counter_file}    ${cell_grp_id}=0
    ${M55208C00001_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00001    cell_grp_id=0
    ${M55208C00002_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00002    cell_grp_id=0
    ${M55208C00003_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00003    cell_grp_id=0
	${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00019    cell_grp_id=${cell_grp_id}
    should be true    ${M55208C00001_value}==0
    should be true    ${M55208C00002_value}==0
    should be true    ${M55208C00003_value}==0
	Should Be True    ${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}==0

check 13709_B disabled logs
    [Arguments]    ${cell_grp_id}=0     ${PM_dir}=step
    Wait '120s' for stabible
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}${PM_dir}${/}
	Check 13709_B disable counters    ${PM_counter_file}    cell_grp_id=${cell_grp_id}

Check 13709_B disable counters
    [Arguments]    ${counter_file}    ${cell_grp_id}=0
    ${M55208C00001_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00001    cell_grp_id=0
    ${M55208C00002_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00002    cell_grp_id=0
    ${M55208C00003_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00003    cell_grp_id=0
	${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00019    cell_grp_id=${cell_grp_id}
    should be true    ${M55208C00001_value}>9 and ${M55208C00001_value}<100
    should be true    ${M55208C00002_value}>9 and ${M55208C00002_value}<100
    should be true    ${M55208C00003_value}>9 and ${M55208C00003_value}<100
	Should Be True    ${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}==0

Check 13079_B TDD cell PM counters
    [Arguments]    ${cell_grp_id}=0    ${PM_dir}=step
    Wait '120s' for stabible
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}${PM_dir}${/}
    Check 13709_B TDD cell DL_NRT_CORE_SVT_METRIC    ${PM_counter_file}    cell_grp_id=${cell_grp_id}

Check 13709_B TDD cell DL_NRT_CORE_SVT_METRIC
    [Arguments]    ${counter_file}    ${cell_grp_id}=0
    ${M55208C00001_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00001    cell_grp_id=0
    ${M55208C00002_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00002    cell_grp_id=0
    ${M55208C00003_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00003    cell_grp_id=0
    ${M55208C00004_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00004    cell_grp_id=0
    ${M55208C00005_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00005    cell_grp_id=0
    ${M55208C00006_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00006    cell_grp_id=0
    ${M55208C00007_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00007    cell_grp_id=0
    ${M55208C00008_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00008    cell_grp_id=0
    ${M55208C00009_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00009    cell_grp_id=0
    ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00010    cell_grp_id=0
    ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00011    cell_grp_id=0
    ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00012    cell_grp_id=0
    ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00013    cell_grp_id=0
    ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00014    cell_grp_id=0
    ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00015    cell_grp_id=${cell_grp_id}
	${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
    ...    counter_id=M55208C00019    cell_grp_id=${cell_grp_id}
    should be true    ${M55208C00001_value}>9 and ${M55208C00001_value}<100
    should be true    ${M55208C00002_value}>9 and ${M55208C00002_value}<100
    should be true    ${M55208C00003_value}>9 and ${M55208C00003_value}<100
    should be true    ${M55208C00004_value}>9 and ${M55208C00004_value}<100
    should be true    ${M55208C00005_value}>9 and ${M55208C00005_value}<100
    should be true    ${M55208C00006_value}>9 and ${M55208C00006_value}<100
    should be true    ${M55208C00007_value}==0 and ${M55208C00007_value}<100
    should be true    ${M55208C00008_value}==0 and ${M55208C00008_value}<100
    should be true    ${M55208C00009_value}==0 and ${M55208C00009_value}<100
    Should Be True    ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}<100
    Should Be True    ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}==0 and ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}<100
	Should Be True    ${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}>350 and ${M55208C00019_TOT_CNT_MEAS_DL_TYPE4}<400

Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    8+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        Run Keyword If    ${num}!=${7} and ${num}!=${8}    should_be_true    ${dl_throughput_pcell}>200000
    END

Airphone Detach'${LOW_UE_ID}'SA UE'${UE_NUM_SA}'
    FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}+1
       Airphone SA Detach    ue_id=${num}
    END

Attach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
    FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
        Wait '2s' for stabible
    END

Send data to SA UE
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=150M   ${ul_tput}=150M    ${low_ue_id}=${UE_ID}
    FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
    END

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END

Attach UE to cell
    [Arguments]    ${ue_id}
#    ${pattern}
#    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10
#    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10
#    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    airphone_execute_egate_command    ue_pdu_session_setup ue\=${ue_id} pdu\=1 nwslice\=1
    #${pdu_id}    evaluate    ${ue_id}%10+1
    #${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ue_id=${ue_id}    pdu_id=1     nwslice_id=1
    #${newNum}=    evaluate    ${ue_id}+8
    #Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
    Wait '1s' for stabible