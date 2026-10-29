*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Shekhar
...              :contact:
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource	     ../../resources/robot/common_log_collection.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py

*** Variables ***


${Bearer_ID}  2
*** Keywords ***
Check Parameter in syslog
    [Arguments]  @{parameter_name}
    log to console     \n Verifying Evos mapping
    FOR   ${item}   IN    @{parameter_name}
          Log to console  Attempting "${item}" to search
          sleep  2s
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          ${status1}   Should Contain    ${status}    ${item}
          log to console  ${item} successfully found in syslog ...${UE}
          sleep  2s

    END
Grep vDU FHUC vlanid from default path and Replace in vDU delta file
    [Arguments]    ${File_path}
    Log to console  Searching the vDU FHUC vlan from testline init result default path
    ${vlanid} =   run    command=grep -i "fhuc_vlans" ~/testline_init_results/execution/configs/testline_configuration/__init__.py -m 1
    BuiltIn.log     ${vlanid}
    Log to console    changing vlan value
    ${vlan}     Get Regexp Matches     ${vlanid}     \\d+
    ${cmd}    Set Variable    sed -i 's/228/${vlan}[0]/g' ${File_path}
    ${status}    run    command=${cmd}
    Builtin.log       changing vlan changed done with ${vlan}
    Log to console    changing vlan changed done with ${vlan}
Multiple UEs SA L3 should be successful
    [Arguments]  ${Start_UE}  ${MAX_UE}  ${DL_Rate}  ${UL_Rate}  ${start_trf_id}  ${end_trf_id}  ${pdu}=${Pdu_session_ID}
    ...   ${qfi}=${QFI_ID}  ${Traffic_rate_SA}=${Trf_rate_SA}  ${scell}=${scell_id}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th GBR UE reg triggering now...
        ${Status}   Run Keyword and Return status  UE Register should be Successful     ${UE}   gw_id=1
        Run keyword if   ${status}==${True}    BuiltIn.Log    UE Registration Done...${UE}    WARN
        Run keyword if   ${status}==${False}    Exit For Loop
        sleep   2s
        Run Keyword And Continue On Failure  Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}  pdu_id=${pdu}  qfi_id=${qfi_id}
        ...  Traffic_rate=${Traffic_rate_SA}  ul_rate=${UL_Rate}
        Run Keyword And Continue On Failure  Trigger DL Non Bursty Data Traffic for SA with multi trfids per ue  ${UE}  ${start_trf_id}
        ...  ${end_trf_id}   ${Traffic_rate_SA}  ${DL_Rate}  ${pdu}  ${qfi}
        sleep   2s
    END
    sleep  5s
    Run Keyword And Continue On Failure   MultiUE Get AVG DL UL SA DATA TRAFFIC UEs  ${Start_UE}  ${MAX_UE}+1  ${DL_Rate}  ${UL_Rate}  ${pdu}  ${qfi}
    ...  ${scell}  ${Traffic_rate_SA}
Multiple UEs NSA L3 should be successful
    [Arguments]   ${Start_UE_NSA}   ${MAX_UE_NSA}  ${Target_cell_NSA}  ${DL_RT_NSA}=${DL_RATE_NSA}  ${UL_RT_NSA}=${UL_RATE_NSA}
    ...  ${Trf_rate}=${Trf_rate_NSA}  ${dl_start_trf_id_NSA}=${NSA_start_DL_trfids}  ${dl_end_trf_id_NSA}=${NSA_end_DL_trfids}
     FOR  ${UE}   IN RANGE   ${Start_UE_NSA}   ${MAX_UE_NSA}+1
        LTE Attach should be Successful  ${UE}
        ${Status}   Run Keyword and Return status  UE Attach should be Successful  ${UE}  ${Target_cell_NSA}
        Run keyword if   ${status}==${True}    BuiltIn.Log    UE attach Done...${UE}    WARN
        Run keyword if   ${status}==${False}    Exit For Loop
        sleep  5s
        Trigger DL Traffic for NSA multi tfids per ue  ${UE}  ${dl_start_trf_id_NSA}  ${dl_end_trf_id_NSA}  ${Trf_rate}  ${DL_RT_NSA}
        Trigger UL Traffic for NSA   ${UE}  Traffic_rate=${Trf_rate}  ul_rate=${UL_RT_NSA}
     END
        Sleep   5s
        MultiUE Get AVG DL UL NSA DATA TRAFFIC UEs  ${Start_UE_NSA}  ${MAX_UE_NSA}+1  ${DL_RT_NSA}  ${UL_RT_NSA}  ${Trf_rate}
Trigger DL Non Bursty Data Traffic for SA with multi trfids per ue
    [Arguments]   ${ue_id}  ${start_trf_id}   ${end_trf_id}  ${Traffic_rate}  ${DL_Rate}  ${pdu_id}=${Pdu_session_ID}
    ...   ${qf_id}=${QFI_ID}
    FOR   ${trfid}  IN RANGE   ${start_trf_id}   ${end_trf_id}+1
        Trigger DL Non Bursty Data Traffic for SA   ue_id=${ue_id}  pdu_id=${pdu_id}  qfi_id=${qfi_id}
            ...   Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}   trf_id=${trfid}
        sleep   2s
    END
Set DL UL Validation Variables
    [Arguments]    ${DL_Rate}   ${UL_Rate}    ${Traffic_rate}=mbps
    ${DL}   Evaluate    ${DL_Rate} / 1000
    ${UL}   Evaluate    ${UL_Rate} / 1000
    ${UL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${UL}
    ...     "${Traffic_rate}"=="mbps"     ${UL_Rate}
    ${DL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${DL}
    ...     "${Traffic_rate}"=="mbps"     ${UL_Rate}
    [Return]    ${DL_Rate}   ${UL_Rate}
Trigger DL Traffic for NSA multi tfids per ue
    [Arguments]    ${ue_id}  ${dl_start_trf_id_NSA}  ${dl_end_trf_id_NSA}  ${Traffic_rate}  ${dl_rate}
    FOR   ${trfid}  IN RANGE   ${dl_start_trf_id_NSA}   ${dl_end_trf_id_NSA}+1
        Trigger DL Traffic for NSA  ue_id=${ue_id}  Traffic_rate=${Traffic_rate}  dl_rate=${dl_rate}  trf_id=${trfid}
    END
MultiUE Get AVG DL UL SA DATA TRAFFIC UEs
    [Arguments]  ${st_ue_id}  ${end_ue_id}  ${dl_rate}  ${ul_rate}   ${pdu_id}=${Pdu_session_ID}  ${qfi_id}=${QFI_ID}
    ...  ${scell_idx}=0  ${unit}=mbps
    ${DL_Val}   ${UL_Val}   Set DL UL Validation Variables   ${DL_Rate}   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}
         Get PUSCH UE Stats NR   ${UE}
         sleep  3s
         Get PDSCH UE Stats NR   ${UE}
         sleep  3s
         Validate DL UL Traffic For SA  ${UE}  ${DL_Val}  ${UL_Val}  ${pdu_id}   ${qfi_id}
    END
MultiUE Get AVG DL UL NSA DATA TRAFFIC UEs
    [Arguments]    ${Start_UE_NSA}   ${MAX_UE_NSA}  ${dl_rate}  ${ul_rate}  ${unit}=mbps
    ${DL_Val}   ${UL_Val}   Set DL UL Validation Variables   ${DL_Rate}   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${Start_UE_NSA}  ${MAX_UE_NSA}
        Validate DL UL Traffic For NSA  ${UE}  ${DL_Val}  ${UL_Val}
    END
Validate DL UL Traffic For NSA
    [Arguments]    ${ue_id}  ${dl_rate}  ${ul_rate}   ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${Bearer_ID}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Run keyword and Ignore Error  Check Average Rate_F    ${bearer_stat_dl}    DL    ${dl_rate}
    Sleep  5s
    wtsrunner.bearer_stats  ue=${ue_id}   id=${Bearer_ID}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Run keyword and Ignore Error  Check Average Rate_F      ${bearer_stat_ul}    UL    ${ul_rate}
Validate DL UL Traffic For SA
    [Arguments]    ${ue_id}  ${dl_rate}  ${ul_rate}  ${pdu_id}  ${qfi_id}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Run keyword and Ignore Error   Check Average Rate_F      ${bearer_stat_dl}    DL    ${dl_rate}
    sleep   5s
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}       wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Run keyword and Ignore Error   Check Average Rate_F      ${bearer_stat_ul}    UL    ${ul_rate}
    [Return]   ${bearer_stat_dl}    ${bearer_stat_ul}
Check Average Rate_F
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
    Run keyword and Ignore Error   log to console   ${output}
    [Return]  ${output}
Get PUSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}
Get PDSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1   ${scell_idx}=0
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pdsch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PDSCH Throughput   timeout=10
    [Return]      ${output}

