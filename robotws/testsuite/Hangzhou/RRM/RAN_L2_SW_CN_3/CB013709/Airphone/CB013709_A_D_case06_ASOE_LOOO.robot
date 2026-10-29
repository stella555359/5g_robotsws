*** Settings ***
Documentation     CB0013709 case
...
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_O_E_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Resource    ./Resource/13709_keyword.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_ASOE_LOOO.xml
${AIRPHONE_NAME}      IPHY_ASOE_LOOO.xml
${WTS_NAME}           WTS_ASOE_LOOO.lua

${UE_ID1}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               20
${UE_NUM_SA_BEARER}         5
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${CHECK_COUNTER_NUM}        6
${CHECK_COUNTER_TIMES}      4
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
@{LOG_NAME_LIST}    gnb_snapshot    egatelog
@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
@{Common_Rdparameter}    0x9D0000:15

@{13709_A_Rdparameter}    0x5808A6:1 #rdEnableOverloadErrMsg    0x5800CA:6006006 #rdMaxNumUeTdDl    0x5800CB:6006006 #rdMaxNumUeTdUl
...    0x580822:65065065 #rdMinAdaptiveSlotProcessingRatio_perCent
...    0x580932:5 #rdNbProcedureContextsMaxLimit    0x580933:1 #rdNbProcedureContextsLow

@{13709_D_Rdparameter}    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT    0x5902BA:1 #rdEnableCB013709#CPRT
...    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT    0x6601EF:1 #rdEnableCB013709#CPNRT


*** Test Cases ***
CB013709_D_b2_case06_TDD_Verfication_actPdcpRlcBufCongOvlMech_GbrOnly_nonGbr_rrcInactive_Priority_PDCP_RLC_buffer_congestion_Counter
   Step1:Commission configuration for onair
   Step'${2}':Trigger PDCP congestion and check counter
   Step3:Online change actPdcpRlcBufCongOvlMech and check log
   Step'${4}':Trigger everity metrics for high load and check counter
   Step5:Reset cell and check counter
   Step6:Block unblock cell and check counter

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add GNB swconfig    @{Common_Rdparameter}
    Add GNB swconfig    @{13709_A_Rdparameter}
    Add GNB swconfig    @{13709_D_Rdparameter}
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H3H3_ALN60_ARP60_P00_COVERAGE_00444_00002
    Prepare gnb onair    multi_cells=True

Step'${step}':Trigger PDCP congestion and check counter
    Log To Console   \n----------Step${step}:Trigger PDCP congestion and check counter-------
    Start capture gnb and ap syslog in 'step${step}_congestion' file
    Attach '${UE_NUM_SA_BEARER}' SA UE
    Send data to SA UE    ue_num=${UE_NUM_SA_BEARER}    dl_tput=175M   ul_tput=50M
    Add GBR Bearer and Send Data
    Add nonGBR Bearer and Send Data
    Wait '120s' for stabible
    Check 13079_D congestion PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step${step}_congestion' file

Step'${step}':Trigger everity metrics for high load and check counter
    Log To Console   \n----------Step${step}:Trigger everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step${step}_highload' file
    Run Keyword And Ignore Error    Airphone Detach SA UE'${UE_NUM_SA_BEARER}'
#    Attach '${UE_NUM_SA}' SA UE
#    Send data to SA UE
    Attach SA UE and Send Data    ue_num=${UE_NUM_SA}    dl_tput=50M    ul_tput=10M
    Wait '120s' for stabible
    Check 13079_A PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step${step}_highload' file

Step3:Online change actPdcpRlcBufCongOvlMech and check log
    Log To Console   \n----------Step3:Online change actPdcpRlcBufCongOvlMech-------
    Start capture gnb and ap syslog in 'step3_onlinechange' file
    Online change actPdcpRlcBufCongOvlMech
    Wait '60s' for stabible
    Check 13079_D overflow PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step3_onlinechange' file

Step5:Reset cell and check counter
    Log To Console   \n----------Step4:Reset cell and check counter-------
    Run Keyword And Ignore Error   Airphone Detach SA UE'${UE_NUM_SA}'
    Reset cell    phy_cell_id=50
    Wait '30s' for stabible
    Step'${5_1}':Trigger PDCP congestion and check counter
    Step'${5_2}':Trigger everity metrics for high load and check counter

Step6:Block unblock cell and check counter
    Log To Console   \n----------Step6:Block unblock cell and check counter-------
    Run Keyword And Ignore Error   Airphone Detach SA UE'${UE_NUM_SA}'
    BlockingState block cell   phy_cell_id=50    alias=block_cell
    BlockingState unblock cell  phy_cell_id=50    alias=unblock_cell
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '30s' for stabible
    Step'${6_1}':Trigger PDCP congestion and check counter
    Step'${6_2}':Trigger everity metrics for high load and check counter

Add 13079_D RD parameter
	Add GNB swconfig    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x5902BA:1 #rdEnableCB013709#CPRT
    Add GNB swconfig    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT
    Add GNB swconfig    0x6601EF:1 #rdEnableCB013709#CPNRT
#    Add GNB swconfig    0x5A0614:1 #rdDebugBearerManagement#L2HICU
 #   Add GNB swconfig    0x5A0605:1 #rdDebugBufferConsumption #L2HIDU
#    Add GNB swconfig    0x5A0616:1  #rdDebugPacketRetention#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugDlDataLimiter#L2HICU
#    Add GNB swconfig    0x5a008f:1 #rdBufferCongestionTracingEnabled#L2HICU
#    Add GNB swconfig    0x5B0615:1  #rdDebugPacketRetention#L2HIDU


Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:6006006 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:6006006 #rdMaxNumUeTdUl
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

Airphone Detach SA UE'${UE_NUM_SA}'
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Airphone SA Detach    ue_id=${num}
     END

Attach '${UE_NUM_SA}' SA UE
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '2s' for stabible
     END

Attach SA UE and Send Data
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=175M   ${ul_tput}=150M
     FOR    ${num}    IN RANGE    1    ${ue_num}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '2s' for stabible
       SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
       SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
       Wait '2s' for stabible
     END

Attach multiple SA UEs and send data
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=175M   ${ul_tput}=50M
     FOR    ${num}    IN RANGE    1    ${ue_num}+1
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= 1    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=1   nwslice_id=1
       Wait '2s' for stabible
       SA send mutiple trf dl data    ${num}    1   ${dl_tput}
       SA send mutiple trf ul data    ${num}    1   ${ul_tput}
     END

Send data to SA UE
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=175M   ${ul_tput}=150M
     FOR    ${num}    IN RANGE    1    ${ue_num}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END

Add GBR Bearer and Send Data
     [Arguments]  ${ue_num}=1   ${send_data}=150
       FOR    ${num}    IN RANGE    1    ${ue_num}+1
            ${gw_pdu_r}    evaluate    ${num}%10+1
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=3
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=2 trf_id\=5 mbps\=${send_data}dir\=dl
            Wait '1s' for stabible
            Airphone Pdu Session Modify    ue_id=${num}   pdu_id=${gw_pdu_r}   qosflows_to_add=4
            Wait '1s' for stabible
            airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} qfi\=3 trf_id\=5 mbps\=${send_data}dir\=dl
            Wait '1s' for stabible
       END

Add nonGBR Bearer and Send Data
     [Arguments]  ${ue_num}=1   ${send_data}=150
        FOR    ${num}    IN RANGE    1    ${ue_num}+1
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

Reset cell
    [Arguments]    ${phy_cell_id}    ${alias}=reset_cell
    Log To Console    Reset cell phy_cell_id=${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${onair_pre}=    TAF_ADMIN.Get Bts Statuses    timeout=30    connection=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    Log To Console    nrcel_list=${nrcel_list}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.reset_cell    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    20
    END
    FOR    ${i}    IN RANGE    1    20
        ${onair_cur}=    TAF_ADMIN.Get Bts Statuses    timeout=30    connection=${alias}
        Log To Console    onair_cur=${onair_cur}
        Run Keyword If    '${onair_pre}[proceduralState]' == '${onair_cur}[proceduralState]'    Exit For Loop
        Sleep    5
    END
    [Teardown]  TAF_ADMIN.teardown    connection=${alias}

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
    ...    counter_id=M55320C05006
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
    log to console     M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_03=${M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03}
    log to console     M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04=${M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04}

    log to console     M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03=${M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03}
    log to console     M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04=${M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04}

    log to console     M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03=${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04=${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}

    log to console     M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03=${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}
    log to console     M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04=${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}

    Should Be True    ${M55350C00036_DL_SDU_DISC_BOP_CU}>=0
    Should Be True    ${M55320C05003_DL_VOL_DISC_BUFTH_QOS_GRP_03}>=0
    #Should Be True    ${M55320C05004_DL_VOL_DISC_BUFTH_QOS_GRP_04}==0
    #Should Be True    ${M55320C06003_DL_SDU_DISC_BUFTH_QOS_GRP_03}==0
    #Should Be True    ${M55320C06004_DL_SDU_DISC_BUFTH_QOS_GRP_04}==0
    #Should Be True    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}==0
    #Should Be True    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}==0
    #Should Be True    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}==0
    #Should Be True    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}==0

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

#    Should Be True    ${M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06}>0
#    Should Be True    ${M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07}>=0
#    Should Be True    ${M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08}>=0
#    Should Be True    ${M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09}>=0
    Should Be True    ${M55320C04003_DL_SDU_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C04004_DL_SDU_DISC_OTHER_QOS_GRP_04}==0
    Should Be True    ${M55320C03003_DL_VOL_DISC_OTHER_QOS_GRP_03}==0
    Should Be True    ${M55320C03004_DL_VOL_DISC_OTHER_QOS_GRP_04}==0
    At Least One Greater Than Zero    ${M55320C05006_DL_VOL_DISC_BUFTH_QOS_GRP_06}    ${M55320C05007_DL_VOL_DISC_BUFTH_QOS_GRP_07}
    ...    ${M55320C05008_DL_VOL_DISC_BUFTH_QOS_GRP_08}    ${M55320C05009_DL_VOL_DISC_BUFTH_QOS_GRP_09}

Check 13079_A PM counters
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0
    Set Test Variable    ${M55208C00004_PRE}    0
    Set Test Variable    ${M55208C00005_PRE}    0
    Set Test Variable    ${M55208C00006_PRE}    0
    ${cell_grp_list}    Get all cell group id list
    Log To Console    ${cell_grp_list}
    Set Test Variable    ${cell_grp_list}

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        Log To Console    check counter times:${num}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        #Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC    ${PM_counter_file}
        FOR    ${cellgrp}    IN    @{cell_grp_list}
            Run Keyword If    '${cellgrp}' != '${cell_grp_id}'    Check 13709_A other cell SVRT_METRIC equal 0
            ...    counter_file=${PM_counter_file}    cell_grp_id=${cellgrp}
        END
#       ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}
#       ${M55208C00004_PRE}   Check two times results    ${M55208C00004_PRE}    M55208C00004    ${PM_counter_file}
        ${M55208C00005_PRE}   Check two times results    ${M55208C00005_PRE}    M55208C00005    ${PM_counter_file}
        ${M55208C00006_PRE}   Check two times results    ${M55208C00006_PRE}    M55208C00006    ${PM_counter_file}
        ${M55208C00008_MAX_NRT_L2POOL_SVT_METRIC}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
        ...    counter_id=M55208C00008    cell_grp_id=0
        Log To Console    M55208C00008_MAX_NRT_L2POOL_SVT_METRIC=${M55208C00008_MAX_NRT_L2POOL_SVT_METRIC}
    END

Check 13709_A TDD cell DL_NRT_CORE_SVT_METRIC
     [Arguments]    ${counter_file}
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
     ...    counter_id=M55208C00015    cell_grp_id=0
     ${M55208C00033_SAMPL_INT_CNT_MEAS_DL_UL_TYPES}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00033    cell_grp_id=0
     ${M55208C00034_SAMPL_INT_CNT_MEAS_POOL_TYPES}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
     ...    counter_id=M55208C00034    cell_grp_id=0

    Should Be True    ${M55208C00010_MIN_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00011_MAX_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00012_AVGE_DL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00013_MIN_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00014_MAX_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00015_AVGE_UL_NRT_CORE_SVT_METRIC}==0
    Should Be True    ${M55208C00033_SAMPL_INT_CNT_MEAS_DL_UL_TYPES}>300 and ${M55208C00033_SAMPL_INT_CNT_MEAS_DL_UL_TYPES}<=375
    Should Be True    ${M55208C00034_SAMPL_INT_CNT_MEAS_POOL_TYPES}==6000

Check two times results
     [Arguments]    ${pre_count_value}    ${counter_id}    ${counter_file}
        ${counter_value_cur}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
        ...    counter_id=${counter_id}    cell_grp_id=0
        Log To Console    counter_value_cur counter:${counter_id}=${counter_value_cur}
        Should Be True    ${counter_value_cur} >= 0 and ${counter_value_cur} <= 100
        ${delta_count}=     Evaluate    abs(${counter_value_cur}-${pre_count_value}) if ${pre_count_value} != 0 else 0
        should be true    ${delta_count}<=2
#        should be true    ${counter_value_cur}>0
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
    [Arguments]    ${act_cong_ovl_value}=24
    Start collect 'cellSetup1' tcpdump
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    actPdcpRlcBufCongOvlMech    ${act_cong_ovl_value}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online
    Stop collect 'cellSetup1' tcpdump
