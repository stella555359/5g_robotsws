*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Sunil
...              :contact: sunil.t_kurian@nokia.com
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource	     ../../../../resources/robot/common_log_collection.robot
Library          ../../../../resources/python/BIP_Capture.py
Library          ../../../../resources/python/CPRT_Capture.py
Library          ../../../../resources/python/avg_dl_data.py
Library          check_dl_ul_prballocation.py

*** Keywords ***
Validate CellSetup_SysLog for bbpooling
    [Arguments]    ${syslog}
    ${status1} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "numMinPrbAllocUlTdd:54"
    Builtin.Log   ${status1}
    Should Not Be Empty    ${status1}
    ${status2} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "poolMaxNumStreamPrb 3276"
    Builtin.Log   ${status2}
    Should Not Be Empty    ${status2}
    ${status3} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "l1SubPoolId"
    Builtin.Log   ${status3}
    Should Not Be Empty    ${status3}
Register 4Non GBR UEs High Traffic in each Cell and Traffic Check
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps   ${step}=${jump}
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    Run Keyword And Ignore Error   Start Log   btslog
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   ${step}
         log to console   ${UE} NonGBR UE attach triggering now
         UE Register should be Successful     ${UE}   gw_id=${UE}
         sleep   2s
         Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}   Traffic_rate=${Traffic_rate}   ul_rate=80
    END
    Run Keyword And Ignore Error   Stop Log   btslog    test_scenario=4_high_NoNGBR_Ues_each_cell
    Sleep   7s
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   20
         Get PUSCH UE Stats NR   ${UE}
         Run Keyword And Ignore Error  Validate UL GBR Traffic For SA   1   ${UL_Val}
    END
Register Multiple UEs and ViNR Traffic
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th GBR UE reg triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=10   qfi_id=4
        sleep   5s
        Run Keyword And Ignore Error   Validate UL GBR Traffic For SA   ue_id=${UE}   ul_rate=${UL_Val}   qfi_id=4
     log to console  /n Ue${UE} ViNR call Successful
   END
Set UL Validation Variables
    [Arguments]    ${UL_Rate}    ${Traffic_rate}=mbps
    ${UL}   Evaluate    ${UL_Rate} / 1000
    ${UL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${UL}
    ...     "${Traffic_rate}"=="mbps"     ${UL_Rate}
    [Return]    ${UL_Rate}
Validate UL GBR Traffic For SA
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
MultiUE Get AVG UL DATA TRAFFIC NonGBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword and Ignore Error  Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END
    log to console  ${scell_idx}

MultiUE Get AVG UL DATA TRAFFIC GBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    ${count}=   set test variable   ${0}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Continue On Failure   Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END
    log to console  ${scell_idx}

Get PUSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}
