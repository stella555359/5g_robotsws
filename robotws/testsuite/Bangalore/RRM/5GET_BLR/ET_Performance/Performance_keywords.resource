*** Settings ***
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot


*** Variables ***
${SA_DL_CELL_RLC_COUNTER}    M55310C01006
${SA_UL_CELL_RLC_COUNTER}    M55310C03006


*** Keywords ***
Register Multiple UE and Send the Data
    [Arguments]   ${Start_UE}    ${MAX_UE}   ${DL_Rate}   ${UL_Rate}    ${Syslog_name}   ${Traffic_rate}=mbps
    [Documentation]   Use This keyword to Register multiple UE.. Pass the Arguments StartUE, EndUE, DLRate, ULRate and Traffic_rate
    ...    Example   Register Multiple UE and Send the Data   1    10    Traffic_rate=kbps   DL_Rate=1000   UL_Rate=125  Syslog_name=cell1syslog
    ...    Example   Register Multiple UE and Send the Data   1    10    Traffic_rate=mbps   DL_Rate=10   UL_Rate=1   Syslog_name=cell1syslog
    [Teardown]      Run Keywords   Stop Collecting Syslog       NAME=${Syslog_name}
    ...    AND      Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    ...    AND      Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/${Syslog_name}_cprt.pcap
    Start Collecting Syslog     NAME=${Syslog_name}
    Start CPRT Trace Capturing
    ${DL_Val}   ${UL_Val}   Set DL UL Validation Variables   ${DL_Rate}   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
         log to console   UE attach triggering now...${UE}
         UE Register should be Successful     ${UE}
         Sleep    5s
         Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}      pdu_id=${Pdu_session_ID}     trf_id=${TRF_ID}
         sleep   5s
         Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}    ul_rate=${UL_Rate}      pdu_id=${Pdu_session_ID}    trf_id=${TRF_ID2}
         sleep   5s
         Validate DL Traffic For SA   ue_id=${UE}     dl_rate=${DL_Val}      qfi_id=${QFI_ID}
         Validate UL Traffic For SA   ue_id=${UE}     ul_rate=${UL_Val}      qfi_id=${QFI_ID}
         BuiltIn.Log    UE Registration Done...${UE}    WARN
    END
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
         Validate DL Traffic For SA   ue_id=${UE}     dl_rate=${DL_Val}      qfi_id=${QFI_ID}
         Validate UL Traffic For SA   ue_id=${UE}     ul_rate=${UL_Val}      qfi_id=${QFI_ID}
    END


Stop Traffic and Dettach Multiple UE
    [Arguments]    ${Start_UE}    ${MAX_UE}
    [Documentation]   Use This keyword to Stop Traffic and Detach multiple UE.. Pass the Arguments StartUE and EndUE.
    ...    Example   Stop Traffic and Dettach Multiple UE    1    10
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1
        Stop Data Traffic for SA     ue_id=${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END

Stop Traffic and Dettach Single UE
    [Arguments]    ${UE}
    Stop Data Traffic for SA     ue_id=${UE}
    UE Deregister should be Successful   ue_id=${UE}

Register Single UE and Send High Data
    [Documentation]   Use This keyword to Register Single UE.. Pass the Arguments UE, DLRatePerTraffic, ULRatePerTraffic, DL_Maximum_Traffic_id, UL_Maximum_Traffic_id,
    ...   Maximum_DL_TRP and Maximum_UL_TRP
    ...    Example       Register Single UE and Send High Data   1   175   100   9    2   1550   200
    [Arguments]   ${UE}   ${DL_Rate}   ${UL_Rate}    ${DL_Max_TRFID}    ${UL_Max_TRFID}   ${DL_MAX}    ${UL_MAX}
    Start Collecting Syslog     NAME=syslog_ue_attach
    log to console   UE attach trigerring now...
    UE Register should be Successful     ${UE}
    Sleep    5s
    FOR  ${TRFID}  IN RANGE   1   ${DL_Max_TRFID}+1
        Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     dl_rate=${DL_Rate}     pdu_id=${Pdu_session_ID}     trf_id=${TRFID}
        sleep   5s
    END
    FOR  ${TRFID}  IN RANGE   1   ${UL_Max_TRFID}+1
        Trigger UL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=${UL_Rate}      pdu_id=${Pdu_session_ID}     trf_id=${TRFID}
        sleep   5s
    END
    Validate DL Traffic For SA   ue_id=${UE}     dl_rate=${DL_MAX}     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=${UL_MAX}     qfi_id=${QFI_ID}
    Stop Collecting Syslog       NAME=syslog_ue_attach

Set DL UL Validation Variables
    [Arguments]    ${DL_Rate}   ${UL_Rate}    ${Traffic_rate}=mbps
    ${DL}   Evaluate    ${DL_Rate} / 1000
    ${UL}   Evaluate    ${UL_Rate} / 1000
    ${DL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${DL}
    ...     "${Traffic_rate}"=="mbps"     ${DL_Rate}
    ${UL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${UL}
    ...     "${Traffic_rate}"=="mbps"     ${UL_Rate}
    [Return]   ${DL_Rate}    ${UL_Rate}

Validate PM Counters equal or bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${pi_value}=   Evaluate    ${pi_value}*8/300000000
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} >= ${expected_value}     PM Counter ${PM_counter} expected to be >= ${expected_value} but is ${pi_value}

Validate RLC PM Counter
    [Arguments]    ${DL_MAX}   ${UL_MAX}   ${Traffic_rate}=mbps    ${moc}=NRCELL-1
    [Documentation]    use this keyword to validate Tput RLC Counter
    ...   Example   Validate RLC PM Counter    1550   200   Traffic_rate=mbps    moc=NRCELL-2
    ${DL_TRP}   ${UL_TRP}    Set DL UL Validation Variables    ${DL_MAX}   ${UL_MAX}   ${Traffic_rate}
    ${DL_TRP}    Evaluate   ${DL_TRP}*0.875
    ${UL_TRP}    Evaluate   ${UL_TRP}*0.875
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Performance_keywords.Validate PM Counters equal or bigger than    PM_dir=${PM_dir1}    PM_counter=${SA_DL_CELL_RLC_COUNTER}    expected_value=${DL_TRP}   moc=${moc}
    Performance_keywords.Validate PM Counters equal or bigger than    PM_dir=${PM_dir1}    PM_counter=${SA_UL_CELL_RLC_COUNTER}    expected_value=${UL_TRP}   moc=${moc}
