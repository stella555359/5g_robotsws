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
${UE_NUM_SA}               40
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
CB013709_C_B2_case007_Interworking with_DL_and_UL_mixed_CA_with_multiple_CCs_during_high_load_PCell
   Step1:Commission configuration for onair
   Step2:Trigger everity metrics for high load and check counter
   Step3:Trigger FDD cell everity metrics for high load and check counter


*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add Common RD parameter
    Add 13079_A RD parameter
    Add 13079_C_B1 RD parameter
    Prepare gnb onair    multi_cells=True

Step2:Trigger everity metrics for high load and check counter
    Log To Console   \n----------Step2:Trigger everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step2_highload' file
    Attach '${UE_NUM_SA}' SA UE'${UE_ID}'
    Send data to SA UE
    Trigger TDD A1 Scell Addition For CA UE
    Wait '60s' for stabible
    Wait Until Keyword Succeeds    10m    1m    Check_13709_C_UL_CA_Counter    cell_grp_id=6
    Start collect ttitrace
    Wait for '0.1s' to stop ttitrace with name'tti'
    [Teardown]  Stop capture gnb and ap syslog in 'step2_highload' file

Step3:Trigger FDD cell everity metrics for high load and check counter
    Log To Console   \n----------Step3:Trigger FDD  cell everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step3_highload' file
    #Run Keyword And Ignore Error   Airphone Detach'${UE_FDD_ID}'SA UE'${UE_NUM_SA_BEARER}'
    Attach '${UE_NUM_SA}' SA UE'${UE_FDD_ID}'
    Send data to SA UE    low_ue_id=${UE_FDD_ID}
    Trigger FDD A1 Scell Addition For CA UE
    Wait '60s' for stabible
    Wait Until Keyword Succeeds    10m    1m    Check_13709_C_UL_CA_Counter    cell_grp_id=1
    Start collect ttitrace
    Wait for '0.1s' to stop ttitrace with name'tti_fdd'
    [Teardown]  Stop capture gnb and ap syslog in 'step3_highload' file

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
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=1
    airphone_execute_egate_command
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} phycell_id\=${phycell_id}

Add 13079_C_B1 RD parameter
    Add GNB swconfig    0x5808E4:1          #rdExtendedOlcReleaseFlagForCa
#    Add GNB swconfig    0x5808ed:12011      #rdCaSuspendRelFddPerCent
#    Add GNB swconfig    0x5808ee:12011      #rdCaSuspendRelTddPerCent
#    Add GNB swconfig    0x5808ef:10009          #rdCaForbidScellActOlcFddDlPerCent
#    Add GNB swconfig    0x5808f0:10009      #rdCaForbidScellActOlcTddDlPerCent
    Add GNB swconfig    0x5808f1:8007      #rdCaForbidScellActOlcFddUlPerCent
    Add GNB swconfig    0x5808f2:3003     #rdCaForbidScellActOlcTddUlPerCent
#    Add GNB swconfig    0x5808f3:10009          #rdCaScellStopDataOlcFddDlPerCent
#    Add GNB swconfig    0x5808f4:10009          #rdCaScellStopDataOlcTddDlPerCent
#    Add GNB swconfig    0x5808FD:10010       #rdCoreSoftRtNrtStopScellActOlcPerCent
    Add GNB swconfig    0x5808f5:6005       #rdCaScellStopDataOlcFddUlPerCent
    Add GNB swconfig    0x5808f6:3003       #rdCaScellStopDataOlcTddUlPerCent
    Add GNB swconfig    0x5808f7:7006       #rdCaPcellStopDataOlcFddUlPerCent
    Add GNB swconfig    0x5808f8:3003       #rdCaPcellStopDataOlcTddUlPerCent


Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:8008008 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:8008008 #rdMaxNumUeTdUl
    #13709-nrt
    Add GNB swconfig    0x580821:40040040   #rdMaxAdaptiveSlotProcessingRatio_perCent
    Add GNB swconfig    0x580822:30030030   #rdMinAdaptiveSlotProcessingRatio_perCent

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
        #SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        log to console    trigger ul traffic ${ul_tput},Ignore dl traffic ${dl_tput}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END

Add bearer for all UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Add GBR bearer    ue_id=${num}    set_qfi_low=3    set_qfi_high=4    qfi_start=2
        Add nonGBR bearer    ue_id=${num}    set_qfi_low=8    set_qfi_high=10    qfi_start=4
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


Check_13709_C_UL_CA_Counter
     [Arguments]    ${cell_grp_id}=0
     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
     ${M55208C00030_TOT_CNT_MEAS_UL_TYPE5}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
     ...    counter_id=M55208C00030    cell_grp_id=${cell_grp_id}
     ${M55208C00031_TOT_CNT_MEAS_UL_TYPE6}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
     ...    counter_id=M55208C00031    cell_grp_id=${cell_grp_id}
     ${M55208C00032_TOT_CNT_MEAS_UL_TYPE7}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
     ...    counter_id=M55208C00032    cell_grp_id=${cell_grp_id}

    Should Be True    ${M55208C00030_TOT_CNT_MEAS_UL_TYPE5}==375
    Should Be True    ${M55208C00031_TOT_CNT_MEAS_UL_TYPE6}>1000

