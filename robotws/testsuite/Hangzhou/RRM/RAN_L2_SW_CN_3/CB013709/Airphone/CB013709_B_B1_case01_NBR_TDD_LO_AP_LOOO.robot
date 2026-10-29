*** Settings ***
Documentation     CB0013709 case
...
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_13709_LO_AP_LOOO_B_B1_NBR.xml
${AIRPHONE_NAME}      IPHY_13709_LO_AP_LOOO.xml
${WTS_NAME}           WTS_3CC_3TDD_16D.lua


${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               20
${UE_NUM_SA_BEARER}         5
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${UE_FDD_ID}          400
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
CB013709_D_b1_case01_Verfication_actPdcpRlcBufCongOvlMech_GBROnly_PDCP_RLC_buffer_congestion_Counter
   Step1:Commission configuration for onair
   Step2:Trigger PDCP congestion and check counter
#   Step3:Trigger everity metrics for high load and check counter
#   Step4:Trigger FDD cell PDCP congestion and check counter
#   Step5:Trigger FDD cell everity metrics for high load and check counter

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add Common RD parameter
    Add 13079_A RD parameter
    Add 13079_D RD parameter
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    Prepare gnb onair    multi_cells=True

Step2:Trigger PDCP congestion and check counter
    Log To Console   \n----------Step2:Trigger PDCP overflow and check counter-------
    Start capture gnb and ap syslog in 'step2_overflow' file
    Attach '${UE_NUM_SA_BEARER}' SA UE'${UE_ID}'
    Send data to SA UE    ue_num=${UE_NUM_SA_BEARER}    dl_tput=50M   ul_tput=1M
    Add GBR Bearer and Send Data
    Add nonGBR Bearer and Send Data
    Wait '60s' for stabible
    Check 13079_D congestion PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step2_overflow' file

Step3:Trigger everity metrics for high load and check counter
    Log To Console   \n----------Step3:Trigger everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step3_highload' file
    Run Keyword And Ignore Error    Airphone Detach'${UE_ID}'SA UE'${UE_NUM_SA_BEARER}'
    Attach '${UE_NUM_SA}' SA UE'${UE_ID}'
    Send data to SA UE
    Wait '60s' for stabible
    Check 13079_A TDD cell PM counters    cell_grp_id=0
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    [Teardown]  Stop capture gnb and ap syslog in 'step3_highload' file

Step4:Trigger FDD cell PDCP congestion and check counter
    Log To Console   \n----------Step4:Trigger FDD cell PDCP overflow and check counter-------
    Start capture gnb and ap syslog in 'step4_congestion' file
    Run Keyword And Ignore Error   Airphone Detach'${UE_ID}'SA UE'${UE_NUM_SA}'
    Attach '${UE_NUM_SA_BEARER}' SA UE'${UE_FDD_ID}'
    Send data to SA UE    ue_num=${UE_NUM_SA_BEARER}    dl_tput=150M   ul_tput=1M    low_ue_id=${UE_FDD_ID}
    Add GBR Bearer and Send Data    low_ue_id=${UE_FDD_ID}
    Add nonGBR Bearer and Send Data     low_ue_id=${UE_FDD_ID}
    Wait '60s' for stabible
    Check 13079_D congestion PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step4_congestion' file

Step5:Trigger FDD cell everity metrics for high load and check counter
    Log To Console   \n----------Step5:Trigger FDD  cell everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step5_highload' file
    Run Keyword And Ignore Error   Airphone Detach'${UE_FDD_ID}'SA UE'${UE_NUM_SA_BEARER}'
    Attach '${UE_NUM_SA}' SA UE'${UE_FDD_ID}'
    Send data to SA UE    low_ue_id=${UE_FDD_ID}
    Wait '60s' for stabible
    Check 13079_A FDD cell PM counters    cell_grp_id=2
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_fdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step5_highload' file


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


Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:3003003 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:3003003 #rdMaxNumUeTdUl
    #13709-nrt
    Add GNB swconfig    0x580932:5 #rdNbProcedureContextsMaxLimit
    Add GNB swconfig    0x580933:1 #rdNbProcedureContextsLow
    #0x580934 = 2 #rdNbProcedureContextsHigh
    #13709-core
    #0x580821 = 30030030 #rdMaxAdaptiveSlotProcessingRatio_perCent
    Add GNB swconfig    0x580822:65065065 #rdMinAdaptiveSlotProcessingRatio_perCent


Add Common RD parameter
     Add GNB swconfig    0x9D0000:15
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (avaiable after 19B, default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x41001b:1
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x66001b:1
     #CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890001:1
     #CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890002:1
     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890003:1
     #CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890004:1
     #CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890005:1
     #CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890006:1

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

Add GBR Bearer and Send Data
     [Arguments]  ${ue_num}=1   ${send_data}=150    ${low_ue_id}=${UE_ID}
       FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}+1
            ${gw_pdu_r}    evaluate    ${num}%10+1
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=3
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=2 trf_id\=5 mbps\=${send_data} dir\=dl
            Wait '1s' for stabible
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=4
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=3 trf_id\=5 mbps\=${send_data} dir\=dl
            Wait '1s' for stabible
       END

Add nonGBR Bearer and Send Data
     [Arguments]  ${ue_num}=1   ${send_data}=150    ${low_ue_id}=${UE_ID}
        FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}+1
            ${gw_pdu_r}    evaluate    ${num}%10+1
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=8
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=4 trf_id\=5 mbps\=${send_data} dir\=dl
            Wait '1s' for stabible
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=9
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=5 trf_id\=5 mbps\=${send_data} dir\=dl
            Wait '1s' for stabible
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=10
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=6 trf_id\=5 mbps\=${send_data} dir\=dl
            Wait '1s' for stabible
        END


Send GBR data to SA UE
    [Arguments]  ${ue_id}=1  ${pdu}=1    ${qfi}=2
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=50 dir\=dl
#    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=ul
    Wait '1s' for stabible

Add bearer for all UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Add GBR bearer    ue_id=${num}    set_qfi_low=3    set_qfi_high=4    qfi_start=2
        Add nonGBR bearer    ue_id=${num}    set_qfi_low=8    set_qfi_high=10    qfi_start=4
    END

Add GBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=1    ${set_qfi_high}=1    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}+1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Wait '1s' for stabible
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
    END

Add nonGBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=8    ${set_qfi_high}=11    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}-1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
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


Check 13079_D overflow PM counters
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55350C00036_DL_SDU_DISC_BOP_CU}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55350C00036    cell_id=1
    ${M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05003
    ${M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05004

    ${M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C06003
    ${M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C06004

    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C04003
    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C04004

    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C03003
    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C03004

    log to console     M55350C00036_DL_SDU_DISC_BOP_CU=${M55350C00036_DL_SDU_DISC_BOP_CU}
    log to console     M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03=${M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03}
    log to console     M5530C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04=${M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04}

    log to console     M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03=${M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03}
    log to console     M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04=${M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04}

    log to console     M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03=${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04=${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}

    log to console     M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03=${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04=${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}

    Should Be True    ${M55350C00036_DL_SDU_DISC_BOP_CU}>0
    Should Be True    ${M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03}==0
    Should Be True    ${M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04}==0
    Should Be True    ${M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03}==0
    Should Be True    ${M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04}==0
    Should Be True    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}==0
    Should Be True    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}==0

Check 13079_D congestion PM counters
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05006
     ${M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05007
    ${M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05008
    ${M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C05009

    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C04003
    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C04004

    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C03003
    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55320C03004

    log to console     M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06=${M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06}
    log to console     M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07=${M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07}
    log to console     M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08=${M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08}
    log to console     M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09=${M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09}

    log to console     M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03=${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04=${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}

    log to console     M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03=${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04=${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}

    Should Be True    ${M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06}>=0
    Should Be True    ${M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07}>=0
    Should Be True    ${M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08}>=0
    Should Be True    ${M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09}>=0
    Should Be True    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}==0
    Should Be True    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}==0

Check 13079_A TDD cell PM counters
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55206C00001_PRE}    0
    Set Test Variable    ${M55206C00002_PRE}    0
    Set Test Variable    ${M55206C00003_PRE}    0
    Set Test Variable    ${M55206C00004_PRE}    0
    Set Test Variable    ${M55206C00005_PRE}    0
    Set Test Variable    ${M55206C00006_PRE}    0

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC    ${PM_counter_file}
        ${M55206C00001_PRE}   Check two times results    ${M55206C00001_PRE}    M55206C00001    ${PM_counter_file}
        ${M55206C00002_PRE}   Check two times results    ${M55206C00002_PRE}    M55206C00002    ${PM_counter_file}
        ${M55206C00003_PRE}   Check two times results    ${M55206C00003_PRE}    M55206C00003    ${PM_counter_file}
        ${M55206C00004_PRE}   Check two times results    ${M55206C00004_PRE}    M55206C00004    ${PM_counter_file}
        ${M55206C00005_PRE}   Check two times results    ${M55206C00005_PRE}    M55206C00005    ${PM_counter_file}
        ${M55206C00006_PRE}   Check two times results    ${M55206C00006_PRE}    M55206C00006    ${PM_counter_file}
        ${M55206C00008_MAX_NRT_L2POOL_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
        ...    counter_id=M55206C00008    cell_grp_id=${cell_grp_id}
        Log To Console    M55206C00008_MAX_NRT_L2POOL_SVT_METRIC=${M55206C00008_MAX_NRT_L2POOL_SVT_METRIC}
        Wait '60s' for stabible
    END

Check 13079_A FDD cell PM counters
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55206C00001_PRE}    0
    Set Test Variable    ${M55206C00002_PRE}    0
    Set Test Variable    ${M55206C00003_PRE}    0
    Set Test Variable    ${M55206C00004_PRE}    0
    Set Test Variable    ${M55206C00005_PRE}    0
    Set Test Variable    ${M55206C00006_PRE}    0
    Set Test Variable    ${M55206C00010_PRE}    0
    Set Test Variable    ${M55206C00011_PRE}    0
    Set Test Variable    ${M55206C00012_PRE}    0
    Set Test Variable    ${M55206C00013_PRE}    0
    Set Test Variable    ${M55206C00014_PRE}    0
    Set Test Variable    ${M55206C00015_PRE}    0

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55206C00001_PRE}   Check two times results    ${M55206C00001_PRE}    M55206C00001    ${PM_counter_file}
        ${M55206C00002_PRE}   Check two times results    ${M55206C00002_PRE}    M55206C00002    ${PM_counter_file}
        ${M55206C00003_PRE}   Check two times results    ${M55206C00003_PRE}    M55206C00003    ${PM_counter_file}
        ${M55206C00004_PRE}   Check two times results    ${M55206C00004_PRE}    M55206C00004    ${PM_counter_file}
        ${M55206C00005_PRE}   Check two times results    ${M55206C00005_PRE}    M55206C00005    ${PM_counter_file}
        ${M55206C00006_PRE}   Check two times results    ${M55206C00006_PRE}    M55206C00006    ${PM_counter_file}
        ${M55206C00010_PRE}   Check two times results    ${M55206C00010_PRE}    M55206C00010    ${PM_counter_file}
        ${M55206C00011_PRE}   Check two times results    ${M55206C00011_PRE}    M55206C00011    ${PM_counter_file}
        ${M55206C00012_PRE}   Check two times results    ${M55206C00012_PRE}    M55206C00012    ${PM_counter_file}
        ${M55206C00013_PRE}   Check two times results    ${M55206C00013_PRE}    M55206C00013    ${PM_counter_file}
        ${M55206C00014_PRE}   Check two times results    ${M55206C00014_PRE}    M55206C00014    ${PM_counter_file}
        ${M55206C00015_PRE}   Check two times results    ${M55206C00015_PRE}    M55206C00015    ${PM_counter_file}
        ${M55206C00008_MAX_NRT_L2POOL_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
        ...    counter_id=M55206C00008    cell_grp_id=${cell_grp_id}
        Log To Console    M55206C00008_MAX_NRT_L2POOL_SVT_METRIC=${M55206C00008_MAX_NRT_L2POOL_SVT_METRIC}
        Wait '60s' for stabible
    END

Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC
     [Arguments]    ${counter_file}    ${cell_grp_id}=0
     ${M55206C00010_MIN_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00010    cell_grp_id=0
     ${M55206C00011_MAX_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00011    cell_grp_id=0
     ${M55206C00012_AVGE_DL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00012    cell_grp_id=0
     ${M55206C00013_MIN_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00013    cell_grp_id=0
     ${M55206C00014_MAX_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00014    cell_grp_id=0
     ${M55206C00015_AVGE_UL_NRT_CORE_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55206C00015    cell_grp_id=${cell_grp_id}

    Should Be True    ${M55206C00010_MIN_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55206C00011_MAX_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55206C00012_AVGE_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55206C00013_MIN_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55206C00014_MAX_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55206C00015_AVGE_UL_NRT_CORE_SVT_METRIC}==0


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
