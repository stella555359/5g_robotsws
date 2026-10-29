*** Settings ***
Documentation     CB0013709 case
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_13709_C_B1_CASE03.xml
${AIRPHONE_NAME}      IPHY_13709_C_B1_CASE03.xml
${WTS_NAME}           WTS_6CC_C_B1_003.lua


${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               20
${UE_NUM_SA_BEARER}         3
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${UE_FDD_ID}          201
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
CB013709_C_B1_case003_Interworking_with_DL FDD_TDD_CA_with_multiple_CCs_during_high_load
   Step1:Commission configuration for onair
   Step2:Trigger everity metrics for high load and check counter
   Step3:Trigger FDD cell everity metrics for high load and check counter
   Step4:Trigger FDD scell deactivates for high load and check counter

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add Common RD parameter
    Add 13079_A RD parameter
    Add 13079_C_B1 RD parameter
    Prepare gnb onair    multi_cells=True

Step2:Trigger everity metrics for high load and check counter
    Log To Console   \n----------Step2:Trigger everity metrics for high load and check counter-------
    Start capture gnb and ap syslog in 'step2_highload' file
    Attach '${UE_NUM_SA}' SA UE'${UE_ID}'
    Send data to SA UE
    Trigger TDD A1 Scell Addition For CA UE
    Wait '60s' for stabible
    Check 13079_C TDD cell PM counters    cell_grp_id=6
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    [Teardown]  Stop capture gnb and ap syslog in 'step2_highload' file

Step3:Trigger FDD cell everity metrics for high load and check counter
    Log To Console   \n----------Step3:Trigger FDD cell everity metrics for high load and check counter-------
    Start capture gnb and ap syslog in 'step3_highload' file
    #Run Keyword And Ignore Error   Airphone Detach'${UE_FDD_ID}'SA UE'${UE_NUM_SA_BEARER}'
    Attach '${UE_NUM_SA}' SA UE'${UE_FDD_ID}'
    Send data to SA UE    low_ue_id=${UE_FDD_ID}
    Trigger FDD A1 Scell Addition For CA UE
    Wait '60s' for stabible
    Check 13079_C FDD cell PM counters    cell_grp_id=1
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_fdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step3_highload' file

Step4:Trigger FDD scell deactivates for high load and check counter
    Log To Console   \n----------Step4:Trigger FDD scell deactivates for high load and check counter-------
    Start capture gnb and ap syslog in 'step4_highload' file
    Run Keyword And Ignore Error   Airphone stop enough UE traffic
    Wait '90s' for stabible
    Trigger 2UE TDD A1 Scell Addition For CA UE
    Send data to CA SA UE
    Wait '300s' for stabible
    Send data to SA UE    low_ue_id=${UE_FDD_ID}
    Check 13079_C TDD cell PM counters update    cell_grp_id=6
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    [Teardown]  Stop capture gnb and ap syslog in 'step4_highload' file

Trigger 2UE TDD A1 Scell Addition For CA UE
    Send A1 report    1   120    56    1
    Send A1 report    2   120    56    1

Trigger TDD A1 Scell Addition For CA UE
    FOR    ${ue_id}    IN RANGE    1    ${UE_NUM_SA}+1
        Send A1 report    ${ue_id}   120    56    1
        sleep    2s
    END

Trigger FDD A1 Scell Addition For CA UE
    FOR    ${ue_id}    IN RANGE    ${UE_FDD_ID}    ${UE_FDD_ID}+${UE_NUM_SA}
        Send A1 report    ${ue_id}   120    51    1
        sleep    2s
    END

Send A1 report
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycel_id}=50    ${meas_id}=1
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} phycell_id\=${phycel_id}

#Add 13079_C_B1 RD parameter
#    Add GNB swconfig    0x5808E4:1          #rdExtendedOlcReleaseFlagForCa
#    Add GNB swconfig    0x5808ed:12011      #rdCaSuspendRelFddPerCent
#    Add GNB swconfig    0x5808ee:12011      #rdCaSuspendRelTddPerCent
#    Add GNB swconfig    0x5808ef:10009          #rdCaForbidScellActOlcFddDlPerCent
#    Add GNB swconfig    0x5808f0:10009      #rdCaForbidScellActOlcTddDlPerCent
##    Add GNB swconfig    0x5808f1:10009      #rdCaForbidScellActOlcFddUlPerCent
##    Add GNB swconfig    0x5808f2:10009      #rdCaForbidScellActOlcTddUlPerCent
#    Add GNB swconfig    0x5808f3:10009          #rdCaScellStopDataOlcFddDlPerCent
#    Add GNB swconfig    0x5808f4:10009          #rdCaScellStopDataOlcTddDlPerCent
#    Add GNB swconfig    0x5808FD:10010       #rdCoreSoftRtNrtStopScellActOlcPerCent
##    Add GNB swconfig    0x5808f5:3003       #rdCaScellStopDataOlcFddUlPerCent
##    Add GNB swconfig    0x5808f6:3003       #rdCaScellStopDataOlcTddUlPerCent
##    Add GNB swconfig    0x5808f7:3003       #rdCaPcellStopDataOlcFddUlPerCent
##    Add GNB swconfig    0x5808f8:3003       #rdCaPcellStopDataOlcTddUlPerCent
#    Add GNB swconfig    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent
#    Add GNB swconfig    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
#    Add GNB swconfig    0x5808fc:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent
#    Add GNB swconfig    0x5901cf:4096 #rdStateHistoryBufferRuntimeSize


Add 13079_C_B1 RD parameter
    Add GNB swconfig    0x5808E4:1    0x5808ed:12011    0x5808ee:12011    0x5808ef:10009    0x5808f0:10009      #rdCaForbidScellActOlcTddDlPerCent
    Add GNB swconfig    0x5808f1:100090x    5808f2:10009    0x5808f3:10009    0x5808f4:10009    0x5808FD:10010
    Add GNB swconfig    0x5808f5:3003    0x5808f6:3003    0x5808f7:3003    0x5808f8:3003       #rdCaPcellStopDataOlcTddUlPerCent
    Add GNB swconfig    0x5808F9:9005    0x5808FA:9005    0x5808fc:9005    0x5901cf:4096 #rdStateHistoryBufferRuntimeSize

#Add 13079_A RD parameter
#    #13709 overload control
#    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
#    #13709-rt
#    Add GNB swconfig    0x5800CA:4004004 #rdMaxNumUeTdDl
#    Add GNB swconfig    0x5800CB:4004004 #rdMaxNumUeTdUl
#    #13709-nrt
#    Add GNB swconfig    0x580932:60 #rdNbProcedureContextsMaxLimit
#    Add GNB swconfig    0x580933:0 #rdNbProcedureContextsLow
#    Add GNB swconfig    0x580821:90090090   #rdMaxAdaptiveSlotProcessingRatio_perCent
#    Add GNB swconfig    0x580822:65065065   #rdMinAdaptiveSlotProcessingRatio_perCent

Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1    0x5800CA:4004004    0x5800CB:4004004    0x580932:60    0x580933:0    0x580821:90090090    0x580822:65065065

#Add Common RD parameter
#     Add GNB swconfig    0x9D0000:15
#     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
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

Add Common RD parameter
     Add GNB swconfig    0x9D0000:15    0x590072:1    0x41001b:1    0x590072:1    0x66001b:1    0x890001:1    0x890002:1
     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890003:1    0x890004:1    0x890005:1    0x890006:1

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

Airphone stop enough UE traffic
    FOR    ${num}    IN RANGE    1    20+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        airphone_sa_stop_data_traffic    ue_id=${num}    pdu_id= ${gw_pdu_r}    direction=dl
        airphone_sa_stop_data_traffic    ue_id=${num}    pdu_id= ${gw_pdu_r}    direction=ul
    END
    FOR    ${num}    IN RANGE    202    220+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        airphone_sa_stop_data_traffic    ue_id=${num}    pdu_id= ${gw_pdu_r}    direction=dl
        airphone_sa_stop_data_traffic    ue_id=${num}    pdu_id= ${gw_pdu_r}    direction=ul
    END

Send data to CA SA UE
     FOR    ${num}    IN RANGE    1    2+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    6   175M    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   175M   ${gw_pdu_r}
     END

Attach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
     FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}
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
     FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    1   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END

Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection

Release VONR
    [Arguments]    ${UE_ID}
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
	Wait '5s' for stabible

check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    Log To Console   ini_file=${ini_file}
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END

Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case08.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Check 13079_C TDD cell PM counters
    [Arguments]    ${cell_grp_id}=6
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        Log To Console    check counter times:${num}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        Wait Until Keyword Succeeds    10min    1min    Check 13709_C cell DL_CA    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Wait '60s' for stabible
    END

Check 13079_C TDD cell PM counters update
    [Arguments]    ${cell_grp_id}=6
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    Wait Until Keyword Succeeds    10min    1min    Check 13709_C deactivates_SCell    ${PM_counter_file}    cell_grp_id=${cell_grp_id}


Check 13709_C deactivates_SCell
     [Arguments]    ${counter_file}    ${cell_grp_id}=0
     ${M55208C00024_deactivates_SCell}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00024    cell_grp_id=${cell_grp_id}
    Should Be True    ${M55208C00024_deactivates_SCell}==2

Check 13079_C FDD cell PM counters
    [Arguments]    ${cell_grp_id}=1
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        Log To Console    check counter times:${num}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        Wait Until Keyword Succeeds    10min    1min    Check 13709_C cell DL_CA    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Wait '60s' for stabible
    END

Check 13709_C cell DL_CA
     [Arguments]    ${counter_file}    ${cell_grp_id}=0
     ${M55208C00021_suspension_REL}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00021    cell_grp_id=${cell_grp_id}
     ${M55208C00022_activation_checks_scell_olc}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00022    cell_grp_id=${cell_grp_id}
     ${M55208C00023_excludes_SCell_activation}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00023    cell_grp_id=${cell_grp_id}
     ${M55208C00024_deactivates_SCell}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00024    cell_grp_id=${cell_grp_id}
     ${M55208C00025_stop_scell_flow}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00025    cell_grp_id=${cell_grp_id}
    Should Be True    ${M55208C00021_suspension_REL}==375
    Should Be True    ${M55208C00022_activation_checks_scell_olc}==375
    Should Be True    ${M55208C00023_excludes_SCell_activation}==0
    Should Be True    ${M55208C00024_deactivates_SCell}==0
    Should Be True    ${M55208C00025_stop_scell_flow}==375

Check two times results
     [Arguments]    ${pre_count_value}    ${counter_id}    ${counter_file}    ${cell_grp_id}=0
        ${counter_value_cur}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
        ...    counter_id=${counter_id}    cell_grp_id=${cell_grp_id}
        Log To Console    counter:${counter_id}=${counter_value_cur}
        ${delta_count}=     Evaluate    abs(${counter_value_cur}-${pre_count_value}) if ${pre_count_value} != 0 else 0
        should be true    ${delta_count}<2
        [return]    ${counter_value_cur}

Check overflow config in bip
    [Arguments]    ${log_dir}
    Convert BIP To CSV    ${log_dir}/cellSetup0.pcap    ${log_dir}/ovf_configreq.csv    ${FILTER1}    ${title_ovf}
    run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/bip_ovf_config.ini     log_need_to_check=i
    ...    save_log_directory=${log_dir}

Check congestion config in bip
    [Arguments]    ${log_dir}
    Convert BIP To CSV    ${log_dir}/All/cellSetup1.pcap    ${log_dir}/cong_configreq.csv    ${FILTER1}    ${title1}
    run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/bip_cong_config.ini     log_need_to_check=i
    ...    save_log_directory=${log_dir}


Online change actPdcpRlcBufCongOvlMech
    [Arguments]    ${act_cong_ovl_value}=19
    Start collect 'cellSetup1' tcpdump
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    actPdcpRlcBufCongOvlMech    ${act_cong_ovl_value}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online
    Stop collect 'cellSetup1' tcpdump
