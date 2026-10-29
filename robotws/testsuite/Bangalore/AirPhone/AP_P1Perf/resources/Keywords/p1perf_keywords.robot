*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
Library    BuiltIn
Library    String
Library    OperatingSystem
Library    ute_wtssim
Library    Collections
Library    DateTime
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.config.scf	WITH NAME      scf
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library    taf.analyzer.pmcounter    WITH NAME    pm_analyser
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Resource    ../../../QT/resources/Keywords/common_keywords.robot
Resource    ../Variables/p1perf_variables.robot
Resource    ../../../QT/resources/Variables/mue_variables.robot

*** Keywords ***
Detach NSA MUE
    [Arguments]    ${nsa_ue_list}=${nsa_ueids_cell1}
    UE 5GDetach should be Successful for NSA MUE    ${nsa_ue_list}
    UE Detach should be Successful for NSA MUE   ${nsa_ue_list}

Register Single UE for Single Cell
    Register Single SA UE Start Traffic and Validate    ${sa_ueids_cell1[0]}

Register Multi UE for Multi Cell
    [Arguments]    ${ul_rate}=${perf_ul_rate}    ${dl_rate}=${perf_sa_sue_dl_rate}    ${sa_list}=${sa_ueids_multicell}
    ${sa_sue_dl_list}=    Create List
    ${sa_sue_ul_list}=    Create List
    Set Suite Variable    @{sa_sue_dl_list}
    Set Suite Variable    @{sa_sue_ul_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${Fdd_Perf}' != 'True'    Initial Setup for PET Test Cases    SA_MUE
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
	Create and Reset SA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    Run Keyword If    '${IWF_ENABLED}' != 'True' or '${Fdd_Perf}' == 'True'   Set Amf to register Single UE    ${mnc_mcc_plmn}
    FOR   ${ueid}    IN    @{sa_list}
        UE Register should be Successful for SA for MUE    ${ueid}
        Generate SA Traffic    ${ueid}    ${dl_rate}    dl
        Generate SA Traffic    ${ueid}    ${ul_rate}    ul
    END
    Check UE Activity for SA    ${sa_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        Check UE Activity for SA    ${sa_list}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats for SA MUE    ${sa_list}
        ...    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check UE Activity for SA    ${sa_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
	FOR    ${ueid}    IN    @{sa_list}
        Stop SA Traffic    ${ueid}
    END
    ${achieved_sa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${SA_UL_CELL_RLC_COUNTER}
    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}' != '1'    Validation of SA Traffic for FDD Perf    ${dl_rate}
    ...    ${ul_rate}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1'   Validation of SA Traffic for FDD IWF    ${dl_rate}
    ...    ${ul_rate}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    ...    ELSE    Validation of SA Traffic for fr1 Perf    ${dl_rate}    ${ul_rate}
    ...    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}

Validation of SA Traffic for fr1 Perf
    [Arguments]    ${dl_rate}    ${ul_rate}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    Run Keyword And Continue On Failure    Validate Perf SA SUE Traffic
    ...    ${dl_rate}    ${ul_rate}    1UE
    ...    ${achieved_sa_dl_tput[0]}    ${achieved_sa_ul_tput[0]}
	Run Keyword And Continue On Failure    Validate Perf SA SUE Traffic
    ...    ${dl_rate}    ${ul_rate}    101UE
    ...    ${achieved_sa_dl_tput[1]}    ${achieved_sa_ul_tput[1]}


Validation of SA Traffic for FDD Perf
    [Arguments]    ${dl_rate}    ${ul_rate}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    @{ues}    Create List    201UE    251UE    301UE    351UE
    ${sa_count}    Get Length    ${ues}
    FOR    ${cell}    IN RANGE    ${sa_count}
        ${dl_tput}    Set Variable    ${achieved_sa_dl_tput}[${cell}]
        ${ul_tput}    Set Variable    ${achieved_sa_ul_tput}[${cell}]
        Log To Console    Printing Cell ${cell+1} TPut
        Run Keyword And Continue On Failure    Validate Perf SA SUE Traffic
        ...    ${dl_rate}    ${ul_rate}    ${SA_CELL}${cell+1}
        ...    ${dl_tput}    ${ul_tput}
    END

Validation of SA Traffic for FDD IWF
    [Arguments]    ${dl_rate}    ${ul_rate}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    FOR    ${cell}    IN RANGE    ${NO_OF_CELLS_FDDIWF}
        ${dl_tput}    Set Variable    ${achieved_sa_dl_tput}[${cell}]
        ${ul_tput}    Set Variable    ${achieved_sa_ul_tput}[${cell}]
        Log To Console    Printing Cell ${cell+1} TPut
        Run Keyword And Continue On Failure    Validate Perf SA SUE Traffic
        ...    ${dl_rate}    ${ul_rate}    ${SA_CELL}${cell+1}
        ...    ${dl_tput}    ${ul_tput}
    END

UE Register should be Successful for SA for MUE
    [Arguments]    ${UE_ID}
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}
    ${validation_string}=    Set Variable     ${EMPTY}
    ${validation_string}=    Catenate    UE${ueid}:    ${pdu_session_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log                ue_register_is_ok

UE Deregister for SA MUE
    [Arguments]    ${sa_ue_list}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR   ${ueid}   IN   @{sa_ue_list}
        UE Deregister for Single SA UE    ${ueid}
    END
    Log    ue_deregister_is_ok

UE Detach should be Successful for NSA MUE
    [Arguments]    ${nsa_ue_list}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    FOR   ${ueid}   IN   @{nsa_ue_list}
        UE Detach should be Successful for NSA Single UE    ${ueid}
    END
    Log    detach_is_ok

UE 5GDetach should be Successful for NSA MUE
    [Arguments]    ${nsa_ue_list}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    FOR   ${ueid}   IN   @{nsa_ue_list}
        UE 5GDetach should be Successful for NSA Single UE    ${ueid}
    END
    Log          5gdetach_is_ok

UE Connectivity check
    [Arguments]    ${nsa_ue_id_list}
    [Timeout]    120
    ${ue_at_gnb}=    Create List
    ${type}=    Evaluate    type(${nsa_ue_id_list}).__name__
    @{final_list}=    Run Keyword If    '${type}' == 'list'    Copy List    ${nsa_ue_id_list}
    Run Keyword If    '${type}' == 'int'    Append To List    ${final_list}    ${nsa_ue_id_list}
    Set Suite Variable    @{ue_at_gnb}
    FOR    ${ueid}    IN    @{final_list}
        wtsrunner.bearer_disp    id=2     ue=${ueid}     at=enb
        ${output}    Run Keyword And Return Status    Read WTS Output Until Pattern Matches
        ...    ${gnb_pdcp}    60
		Append to List    ${ue_at_gnb}    ${output}
    END
	${num}=    Get length    ${ue_at_gnb}
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    Log To Console    [${hr}:${min}:${sec}]:Active No.of NSA UEs:${num}
	List Should Not Contain Value    ${ue_at_gnb}    FAIL    msg=NSA UE not in 5G

LTE Attach should be Successful for NSA MUE
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    wtsrunner.ue_attach    id=${UE_ID}
    ${validation_string}    Set Variable    ${EMPTY}
    ${validation_string}    Catenate    UE${ueid}: ===    ${LTE_attach_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
    Log    lte_attach_is_ok

UE Attach should be Successful for NSA MUE
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    Run Keyword If   '${IWF_ENABLED}' == 'True' and '${RU_TYPE}' == 'AEQE'
    ...    Update scell for NSA CA
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${validation_string}    Set Variable    ${EMPTY}
    ${validation_string}=    Catenate    UE${ueid}: Proxy.*    ${UE_attach_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
    Log    ue_attach_is_ok

Validate Traffic Throughput Average Rate for SA MUE
    [Documentation]    SA Traffic Throughput Criteria
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=5
    ${sa_dl_avg_data_rate}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
    Check Perf Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=5
    ${sa_ul_avg_data_rate}         Get Regexp Matches    ${bearer_stat_ul}    Average data rate +(\\d+)    1
    Check Perf Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}    ${UE_ID}
    [Return]    ${sa_dl_avg_data_rate}    ${sa_ul_avg_data_rate}

Check Perf Average Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${dl_rate}    ${ueid}
    Log To Console    Achieved DL Rate: ${dl_rate}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log
    ...    UE${ueid}:${dir} Average data rate: ${output[0]}
    ...               ELSE    Log    UE${ueid}:${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${ueid}:${dir} Average data rate failed!

Calculate Cumulative Average Data Rate
    [Documentation]    Calculates Cumulative Average Data Rate
    [Arguments]    ${dl_tput_list}    ${ul_tput_list}
    ${dl_avg_tput_rate}=    Set Variable    0
    ${ul_avg_tput_rate}=    Set Variable    0
    FOR    ${value}    IN    @{dl_tput_list}
        ${status}    ${avg_rate}    Run Keyword And Ignore Error    Convert To Integer    ${value}
        ${avg_rate}=    Set Variable If    '${status}' == 'FAIL'    0    ${avg_rate}
        ${dl_avg_tput_rate}=    Evaluate    ${dl_avg_tput_rate}+${avg_rate}
    END
    FOR    ${value}    IN    @{ul_tput_list}
        ${status}    ${avg_rate}    Run Keyword And Ignore Error    Convert To Integer    ${value}
        ${avg_rate}=    Set Variable If    '${status}' == 'FAIL'    0    ${avg_rate}
        ${ul_avg_tput_rate}=    Evaluate    ${ul_avg_tput_rate}+${avg_rate}
    END
    [Return]    ${dl_avg_tput_rate}    ${ul_avg_tput_rate}

Validate Traffic Throughput Average Rate for NSA MUE
    [Documentation]    NSA Traffic Throughput Criteria
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=5
    ${nsa_dl_avg_data_rate}         Get Regexp Matches    ${bearer_stat_scg}    Average data rate +(\\d+)    1
    Check Perf Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=5
    ${nsa_ul_avg_data_rate}         Get Regexp Matches    ${bearer_stat_all}    Average data rate +(\\d+)    1
    Check Perf Average Rate      ${bearer_stat_all}    UL    ${ul_rate}    ${UE_ID}
    [Return]    ${nsa_dl_avg_data_rate}    ${nsa_ul_avg_data_rate}

Get Avg Data Rate SA
    [Arguments]    ${ueid}
    wtsrunner.bearer_stats  ue=${ueid}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${sa_dl_avg_data_rate}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
    wtsrunner.bearer_stats  ue=${ueid}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${sa_ul_avg_data_rate}         Get Regexp Matches    ${bearer_stat_ul}    Average data rate +(\\d+)    1
    [Return]    ${sa_dl_avg_data_rate}    ${sa_ul_avg_data_rate}

Get Avg Data Rate NSA
    [Arguments]    ${ueid}
    wtsrunner.bearer_stats    ue=${ueid}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${nsa_dl_avg_data_rate}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
    wtsrunner.bearer_stats    ue=${ueid}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${nsa_ul_avg_data_rate}         Get Regexp Matches    ${bearer_stat_ul}    Average data rate +(\\d+)    1
    [Return]    ${nsa_dl_avg_data_rate}    ${nsa_ul_avg_data_rate}

Register Single SA UE Start Traffic and Validate
    [Arguments]    ${ueid}
    [Documentation]    This Keyword does UE register for Single SA UE and start traffic
    ${ul_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${SUE_UL_RATE}
    ...     ${abil_sue_ul_rate}
    ...    ELSE    Get Variable Value    ${SUE_UL_RATE}     ${perf_ul_rate}
    ${dl_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${NSA_SUE_DL_RATE}
    ...     ${abil_sue_dl_rate}
    ...    ELSE    Get Variable Value    ${SA_SUE_DL_RATE}     ${perf_sa_sue_dl_rate}
    Start SA Traffic for SUE scenario    ${dl_rate}    ${ul_rate}    ${ueid}    1SUE

Validate Perf SA Traffic
    [Arguments]    ${dl_rate}    ${ul_rate}    ${tc_name}    ${tput_sa_dl}    ${tput_sa_ul}
    ${updated_sa_dl}    ${updated_sa_ul}    Converting List of List To Single List    ${sa_dl_list}    ${sa_ul_list}
    ${sa_status}    ${sa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_sa_dl}    ${updated_sa_ul}
    Log To Console    SA Data Status: ${sa_status}
    Convert SA Data Rate and Update    ${sa_data_rate[0]}    ${sa_data_rate[1]}    ${tc_name}    ${dl_rate}    ${ul_rate}
    ...    ${tput_sa_dl}    ${tput_sa_ul}

Validate Perf SA SUE Traffic
    [Arguments]    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    ${updated_sa_dl}    ${updated_sa_ul}    Converting List of List To Single List
    ...    ${sa_sue_dl_list}    ${sa_sue_ul_list}
    ${sa_status}    ${sa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_sa_dl}    ${updated_sa_ul}
    Log To Console    SA Data Status: ${sa_status}
    Convert SA Data Rate and Update SingleUE MUE    ${sa_data_rate[0]}    ${sa_data_rate[1]}    ${tc_name}    ${dl_rate}
    ...    ${ul_rate}    ${achieved_dl}    ${achieved_ul}

Validate Perf MUE SA Traffic
    [Arguments]    ${ue_list}    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    FOR    ${ueid}    IN    ${ue_list}
        Validate Perf SA Traffic    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    END

Validate Perf NSA Traffic
    [Arguments]    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    ${updated_nsa_dl}    ${updated_nsa_ul}    Converting List of List To Single List
    ...    ${nsa_dl_list}    ${nsa_ul_list}
    ${nsa_status}    ${nsa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_nsa_dl}    ${updated_nsa_ul}
    Log To Console    NSA Data Status: ${nsa_status}
    Convert NSA Data Rate and Update    ${nsa_data_rate[0]}    ${nsa_data_rate[1]}
    ...    ${tc_name}    ${dl_rate}    ${ul_rate}    ${achieved_dl}    ${achieved_ul}

Validate Perf NSA MUE Traffic
    [Arguments]    ${ue_list}    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
	FOR    ${ueid}    IN    ${ue_list}
	    Validate Perf NSA Traffic    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    END

UE Deregister for Single SA UE
    [Arguments]    ${ueid}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    wtsrunner.ue_pdu_session_release    ue=${ueid}    pdu=${Pdu_session_ID}    by=ue
    ${validation_string}=    Set Variable     ${EMPTY}
    ${validation_string}=    Catenate    UE${ueid}:    ${pdu_session_release}    ID=${Pdu_session_ID}
    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    Log    pdu_session_release_is_ok
    wtsrunner.ue_deregister    id=${ueid}   ue_deregister_type=switch_off
    ${validation_string}=    Set Variable     ${EMPTY}
    ${validation_string}=    Catenate    UE${ueid}:    ${sa_nsa_detach_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    Log    ue_deregister_is_ok

Deregister for Multi UE for Multi Cell
    UE Deregister for Single SA UE    ${sa_ueids_cell1[0]}
    UE Deregister for Single SA UE    ${sa_ueids_cell2[0]}

Deregister Single UE Single Cell
    UE Deregister for Single SA UE    ${sa_ueids_cell1[0]}

Detach NSA Single UE
    [Arguments]    ${ueid}=${nsa_ueids_cell1[0]}
    UE 5GDetach should be Successful for NSA Single UE    ${ueid}
    UE Detach should be Successful for NSA Single UE    ${ueid}

NSA Attach for Single UE Single Cell
    Attach NSA Single UE Start Traffic and Validate    ${nsa_ueids_cell1[0]}    11SUE

Attach NSA Single UE Start Traffic and Validate
    [Arguments]    ${ueid}    ${tcname}
    [Documentation]    This Keyword does NSA UE attach for Single NSA UE and start traffic
    ${ul_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${SUE_UL_RATE}
    ...     ${abil_sue_ul_rate}    ELSE    Get Variable Value    ${SUE_UL_RATE}
    ...     ${perf_ul_rate}
    ${dl_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${NSA_SUE_DL_RATE}
    ...     ${abil_sue_dl_rate}    ELSE    Get Variable Value    ${NSA_SUE_DL_RATE}
    ...     ${perf_nsa_sue_dl_rate}
    Start NSA Traffic for SUE scenario    ${dl_rate}    ${ul_rate}    ${ueid}    ${tcname}

UE Detach should be Successful for NSA Single UE
    [Arguments]    ${ueid}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    wtsrunner.ue_detach    id=${ueid}
    ${validation_string}=    Catenate    UE${ueid}:    ${sa_nsa_detach_pattern}
    Read WTS Output Until Pattern Matches    ${validation_string}    ${Timeout_NSA}
    Log    detach_is_ok

UE 5GDetach should be Successful for NSA Single UE
    [Arguments]    ${ueid}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    wtsrunner.enb_ue_dc_release    ue=${ueid}    bearer=${Bearer_ID}    by=enb    cause=off
    Sleep    2s
    ${validation_string}=    Catenate    SEPARATOR=${SPACE}    UE${ueid}:    ${mue_detach_pattern}
    Should Contain    ${validation_string}    Bearer-type change from SCG-split to MCG    ignore_case=True
    Log          5gdetach_is_ok

Calculate number of Traffic Id
    [Arguments]    ${rate}
    ${num_trf_ids}=     Run Keyword If     ${rate}>160     Evaluate     ${rate}/160
    ...    ELSE     Set Variable    1
    ${last_trf_rate}=     Run Keyword If     ${rate}>160     Evaluate     ${rate}%160
    ...    ELSE     Set Variable     ${rate}
    ${num_trf}=    Run Keyword If    ${last_trf_rate}>0     Evaluate    ${num_trf_ids}+1
    ...    ELSE     Set Variable     ${num_trf_ids}
    ${num_trf_final}=     Run Keyword If     ${last_trf_rate}==${rate}     Set Variable    1
    ...    ELSE     Set Variable     int(${num_trf})
    ${last_trf_rate_final}=     Run Keyword If     ${last_trf_rate}==0     Set Variable     160
    ...     ELSE     Set Variable     ${last_trf_rate}
    [Return]     ${num_trf_final}     ${last_trf_rate_final}

Calculate number of Traffic Id for Kbps
    [Arguments]    ${rate}
    ${num_trf_ids}=     Run Keyword If    '${Fdd_Perf}' == 'True'    Evaluate    ${rate}/${trf_id_fddperf}
    ...    ELSE IF    ${rate}>${trf_id_fddperf}     Evaluate     ${rate}/${trf_id_fddperf}
    ...    ELSE     Set Variable    1
    ${last_trf_rate}=     Run Keyword If     ${rate}>${trf_id_fddperf}     Evaluate     ${rate}%${trf_id_fddperf}
    ...    ELSE     Set Variable     ${rate}
    ${num_trf}=    Run Keyword If    ${last_trf_rate}>0     Evaluate    ${num_trf_ids}+1
    ...    ELSE     Set Variable     ${num_trf_ids}
    ${num_trf_final}=     Run Keyword If     ${last_trf_rate}==${rate}     Set Variable    1
    ...    ELSE     Evaluate    int(${num_trf})
    ${last_trf_rate_final}=     Run Keyword If     ${last_trf_rate}==0     Set Variable     ${trf_id_fddperf}
    ...     ELSE     Set Variable     ${last_trf_rate}
    [Return]     ${num_trf_final}     ${last_trf_rate_final}

Generate SA Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}<${num_trf}    Start SA Perf Traffic one    ${ue_id}
        ...    ${trf_id}    ${dir}
        Run Keyword If    ${trf_id}==${num_trf}    Start SA Perf Traffic Two    ${ue_id}    ${trf_id}
        ...    ${dir}    ${last_trf_rate}
    END

Start SA Perf Traffic one
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}   pdu=${pdu}   qfi=${qfi}   trf_id=${trf_id}   mbps=160   dir=${dir}    size=${trf_id_perf}

Start SA Perf Traffic Two
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}   pdu=${pdu}   qfi=${qfi}   trf_id=${trf_id}   mbps=${last_trf_rate}   dir=${dir}    size=${trf_id_perf}

Generate NSA Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}<${num_trf}    Start NSA Perf Traffic one    ${ue_id}
        ...    ${trf_id}    ${dir}
        Run Keyword If    ${trf_id}==${num_trf}    Start NSA Perf Traffic Two    ${ue_id}    ${trf_id}
        ...    ${dir}    ${last_trf_rate}
    END

Start NSA Perf Traffic one
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}   trf_id=${trf_id}   id=${Bearer_ID}    mbps=160   dir=${dir}    size=${trf_id_perf}

Start NSA Perf Traffic Two
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}   trf_id=${trf_id}   id=${Bearer_ID}    mbps=${last_trf_rate}   dir=${dir}    size=${trf_id_perf}

Converting List of List To Single List
    [Arguments]    ${dl_list}    ${ul_list}
    ${updated_dl_list}    Evaluate    [item for sublist in $dl_list for item in (sublist if isinstance(sublist, list) else [sublist])]
    ${updated_ul_list}    Evaluate    [item for sublist in $ul_list for item in (sublist if isinstance(sublist, list) else [sublist])]
    [Return]    ${updated_dl_list}    ${updated_ul_list}

SA MUE Register Traffic and Validation
    [Arguments]    ${ue_list}    ${dl_rate}    ${ul_rate}
    Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    FOR    ${ueid}    IN    @{ue_list}
        UE Register should be Successful for SA for MUE    ${ueid}
        Run Keyword If    '${Fdd_Perf}' == 'True'    Generate SA Traffic for PerfFDD    ${ueid}    ${dl_rate}    dl
        ...    ELSE    Generate SA Traffic    ${ueid}    ${dl_rate}    dl
        Run Keyword If    '${Fdd_Perf}' == 'True'    Generate SA Traffic for PerfFDD    ${ueid}    ${ul_rate}    ul
		...    ELSE    Generate SA Traffic    ${ueid}    ${ul_rate}    ul
    END

NSA MUE Attach Traffic and Validation
    [Arguments]    ${nsa_ue_list}    ${target_cell}    ${dl_rate}    ${ul_rate}
    Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    FOR   ${ueid}    IN    @{nsa_ue_list}
        LTE Attach should be Successful for NSA MUE    ${ueid}
    END
    Sleep    2s
    FOR   ${ueid}    IN    @{nsa_ue_list}
        UE Attach should be Successful for NSA MUE    ${ueid}    ${target_cell}
        Sleep    2s
        Generate NSA Traffic    ${ueid}    ${dl_rate}    dl
        Generate NSA Traffic    ${ueid}    ${ul_rate}    ul
    END

Get UE IDS
    [Arguments]    ${ue_list}
    ${count}=    Set Variable    0
    ${updated_ue_list}=    Create List
    FOR    ${ueid}    IN    @{ue_list}
        Append To List    ${updated_ue_list}    ${ueid}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count} == 5
    END
    [Return]    ${updated_ue_list}

Get 10UE IDS
    [Arguments]    ${ue_list}
    ${count}=    Set Variable    0
    ${updated_ue_list}=    Create List
    FOR    ${ueid}    IN    @{ue_list}
        Append To List    ${updated_ue_list}    ${ueid}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count} == 10
    END
    [Return]    ${updated_ue_list}

SA Deregister MUE Multicell
    [Arguments]    ${sa_ue_list}
    ${count}=    Set Variable    0
    ${sa_list}=    Create List
    FOR    ${ueid}    IN    @{sa_ue_list}
        Append To List    ${sa_list}    ${ueid}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count} == 5
    END
    UE Deregister for SA MUE    ${sa_list}

NSA Detach MUE Multicell
    [Arguments]    ${nsa_ue_list}
    ${count}=    Set Variable    0
    ${nsa_list}=    Create List
    FOR    ${ueid}    IN    @{nsa_ue_list}
        Append To List    ${nsa_list}    ${ueid}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count} == 5
    END
    Detach NSA MUE    ${nsa_list}

Convert SA Data Rate and Update
    [Arguments]   ${dl_data_rate}    ${ul_data_rate}    ${tc_name}    ${overall_dl}
    ...    ${overall_ul}    ${dl_tput}    ${ul_tput}
    Log To Console    Achieved DL Tput: ${dl_data_rate}
    Log To Console    Achieved UL Tput: ${ul_data_rate}
    ${overall_dl}    Run Keyword If    '${tc_name}' == '10PARUE' or '${tc_name}' == '5PARUE'   Evaluate    ${overall_dl}*10
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' != '1'
    ...    Evaluate    (${overall_dl}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDPerf})
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' == '1'
    ...    Evaluate    (${overall_dl}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDIWF})
    ...    ELSE    Set Variable    ${overall_dl}
    ${overall_ul}    Run Keyword If    '${tc_name}' == '10PARUE' or '${tc_name}' == '5PARUE'    Evaluate    ${overall_ul}*10
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' != '1'
    ...    Evaluate    (${overall_ul}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDPerf})
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' == '1'
    ...    Evaluate    (${overall_ul}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDIWF})
    ...    ELSE    Set Variable    ${overall_ul}
    ${dl_limit}    Run Keyword If    '${tc_name}' == '1SUE'    Set Variable    0.875
    ...    ELSE    Run Keyword If    ('${tc_name}' in "@{mue_tcs}") and '${IWF_ENABLED}' == 'True'
    ...    Set Variable    0.90
    ...    ELSE    Set Variable    ${dl_limit}
    ${ul_limit}    Run Keyword If    ('${tc_name}' in "@{mue_tcs}") and '${IWF_ENABLED}' == 'True'
    ...    Set Variable    0.90
    ...    ELSE    Set Variable    ${ul_limit}
    ${dl_tput}=    Evaluate    int(${dl_tput})
    ${ul_tput}=    Evaluate    int(${ul_tput})
    ${sa_dl_tput_status}=    Evaluate    ${dl_tput} >= (${overall_dl}*${dl_limit})
    ${sa_ul_tput_status}=    Evaluate    ${ul_tput} >= (${overall_ul}*${ul_limit})

    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_UL=${ul_tput}${\n}

    Log To Console    AVG Data Rate SA DL ${dl_tput}
    Log To Console    AVG Data Rate SA UL ${ul_tput}

    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${sa_dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${sa_ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Convert NSA Data Rate and Update
    [Arguments]   ${dl_data_rate}    ${ul_data_rate}    ${tc_name}    ${overall_dl}    ${overall_ul}    ${dl_tput}    ${ul_tput}
    ${overall_dl}    Run Keyword If    '${tc_name}' == '10PARUE' or '${tc_name}' == '5PARUE'    Evaluate    ${overall_dl}*10
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' != '1'
    ...    Evaluate    (${overall_dl}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDPerf})
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' == '1'
    ...    Evaluate    (${overall_dl}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDIWF})
    ...    ELSE    Set Variable    ${overall_dl}
    ${overall_ul}    Run Keyword If    '${tc_name}' == '10PARUE' or '${tc_name}' == '5PARUE'    Evaluate    ${overall_ul}*10
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' != '1'
    ...    Evaluate    (${overall_ul}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDPerf})
    ...    ELSE IF    '${tc_name}' == 'SANSA_MUE_20' and '${FDD_IWF_multicell}' == '1'
    ...    Evaluate    (${overall_ul}/1000)*(${SANSA_MUE_20_CELLUE}*${NO_OF_CELLS_FDDIWF})
    ...    ELSE    Set Variable    ${overall_ul}
    ${overall_dl}    Run Keyword If    '${tc_name}' == '20MUE'    Evaluate    ${overall_dl}*20
    ...    ELSE    Set Variable    ${overall_dl}
    ${overall_ul}    Run Keyword If    '${tc_name}' == '20MUE'  Evaluate    ${overall_ul}*20
    ...    ELSE    Set Variable    ${overall_ul}
    ${dl_limit}    Run Keyword If    '${tc_name}' == '11SUE'    Set Variable    0.83
    ...    ELSE    Run Keyword If     '${tc_name}' in "@{mue_tcs}"    Set Variable    0.90
    ...    ELSE    Set Variable    ${dl_limit}
    ${ul_limit}    Run Keyword If    '${tc_name}' in "@{mue_tcs}"    Set Variable    0.90
    ...    ELSE    Set Variable    ${ul_limit}
	${dl_data_rate}=    Evaluate    int(${dl_data_rate}/11)
	${ul_data_rate}=    Evaluate    int(${ul_data_rate}/11)
    ${dl_data_rate}=    Evaluate    int(${dl_data_rate}/${evaluator})
    ${ul_data_rate}=    Evaluate    int(${ul_data_rate}/${evaluator})
    Append To File     ${test_property_file}    ${\n}NSA_stats_${tc_name}_DL=${dl_data_rate}${\n}
    Append To File     ${test_property_file}    ${\n}NSA_stats_${tc_name}_UL=${ul_data_rate}${\n}
    ${dl_tput}=    Evaluate    int(${dl_tput})
    ${ul_tput}=    Evaluate    int(${ul_tput})

    Append To File     ${test_property_file}    ${\n}NSA_${tc_name}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}NSA_${tc_name}_UL=${ul_tput}${\n}
    Log To Console    Validating via gNB PM counters AVG Data Rate NSA DL ${dl_tput}
    Log To Console    Validating via gNB PM counters AVG Data Rate NSA UL ${ul_tput}
    ${nsa_dl_tput_status}=    Evaluate    ${dl_tput} >= (${overall_dl}*${dl_limit})
    ${nsa_ul_tput_status}=    Run Keyword If    '${tcname}' == '11SUE' or '${IWF_ENABLED}' != 'True'
    ...    Evaluate    ${ul_tput} >= (${overall_ul}*${ul_limit})
    ...    ELSE    Set Variable    True
    ${status_dl_nsa}    Run Keyword And Ignore Error    Should Be True    '${nsa_dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status_nsa}    ${status_dl_nsa[0]}
    ${status_ul_nsa}    Run Keyword And Ignore Error   Should Be True    '${nsa_ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status_nsa}    ${status_ul_nsa[0]}
    List Should Not Contain Value    ${pm_counter_status_nsa}    FAIL    msg=Traffic failed in Throughput, see error above!

Collect Bearer Stats at Intervals
    [Arguments]    ${nsa_cell1_5ues}    ${nsa_cell2_5ues}   ${sa_cell1_5ues}
    ...    ${sa_cell2_5ues}    ${dl_rate}    ${ul_rate}
    Run Keyword And Continue On Failure    Collect Bearer Stats for NSA MUE    ${nsa_cell1_5ues}    ${dl_rate}    ${ul_rate}
    Run Keyword And Continue On Failure    Collect Bearer Stats for NSA MUE    ${nsa_cell2_5ues}    ${dl_rate}    ${ul_rate}
    Run Keyword And Continue On Failure    Collect Bearer Stats for SA MUE    ${sa_cell1_5ues}    ${dl_rate}    ${ul_rate}
    Run Keyword And Continue On Failure    Collect Bearer Stats for SA MUE   ${sa_cell2_5ues}    ${dl_rate}    ${ul_rate}

Collect Bearer Stats at Intervals for FDD
    [Arguments]    ${nsa_cell1_5ues}    ${nsa_cell2_5ues}    ${nsa_cell3_5ues}    ${nsa_cell4_5ues}    ${sa_cell1_5ues}
    ...    ${sa_cell2_5ues}    ${sa_cell3_5ues}    ${sa_cell4_5ues}    ${dl_rate}    ${ul_rate}
    @{nsa_cells}    Create List    ${nsa_cell1_5ues}    ${nsa_cell2_5ues}    ${nsa_cell3_5ues}    ${nsa_cell4_5ues}
    @{sa_cells}    Create List    ${sa_cell1_5ues}    ${sa_cell2_5ues}    ${sa_cell3_5ues}    ${sa_cell4_5ues}
    FOR    ${cell}    IN    @{nsa_cells}
      Run Keyword And Continue On Failure    Collect Bearer Stats for NSA MUE    ${cell}    ${dl_rate}    ${ul_rate}
    END

    FOR    ${cell}    IN    @{sa_cells}
      Run Keyword And Continue On Failure    Collect Bearer Stats for SA MUE    ${cell}    ${dl_rate}    ${ul_rate}
    END

Collect Bearer Stats at Intervals for Single Cell
    [Arguments]    ${nsa_ueids_cell1}    ${sa_ueids_cell1}    ${dl_rate}    ${ul_rate}
	Run Keyword And Continue On Failure    Collect Bearer Stats for NSA MUE    ${nsa_ueids_cell1}    ${dl_rate}    ${ul_rate}
	Run Keyword And Continue On Failure    Collect Bearer Stats for SA MUE    ${sa_ueids_cell1}    ${dl_rate}    ${ul_rate}

Collect Bearer Stats for NSA
    [Arguments]    ${ueid}    ${dl_rate}    ${ul_rate}
    ${trf_nsa_status}    ${avg_data_rate}    Run Keyword And Ignore Error
    ...    Validate Traffic Throughput Average Rate for NSA MUE
    ...    ${dl_rate}     ${ul_rate}    ${ueid}
    ${data_status}    ${data_rate}    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Run Keyword And Ignore Error    Get Avg Data Rate NSA    ${ueid}
    Log To Console    NSA Data Status: ${data_status}
    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Append to List    ${nsa_dl_list}    ${data_rate[0]}
    ...    ELSE    Append to List    ${nsa_dl_list}    ${avg_data_rate[0]}
    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Append to List    ${nsa_ul_list}    ${data_rate[1]}
    ...    ELSE    Append to List    ${nsa_ul_list}    ${avg_data_rate[1]}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_nsa_status}' == 'PASS'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_validate_list_nsa}    ${status[0]}
    ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For Perf NSA    ${ueid}
    ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
    ...    msg=Traffic failed in Data Loss, see error above!
    Append To List    ${dataloss_validate_list_nsa}    ${dataloss_status[0]}

Collect Bearer Stats for NSA MUE
    [Arguments]    ${ue_list}    ${dl_rate}    ${ul_rate}
    FOR   ${ueid}   IN   @{ue_list}
        Wait Until Keyword Succeeds    4s    2s    Collect Bearer Stats for NSA
        ...    ${ueid}    ${dl_rate}    ${ul_rate}
    END

Collect Bearer Stats for SA MUE
    [Arguments]    ${ue_list}    ${dl_rate}    ${ul_rate}
    FOR   ${ueid}   IN   @{ue_list}
        Wait Until Keyword Succeeds    4s    2s    Collect Bearer Stats for SA
        ...    ${ueid}    ${dl_rate}    ${ul_rate}
    END

Collect Bearer Stats for SA
    [Arguments]    ${ueid}    ${dl_rate}    ${ul_rate}
    ${trf_sa_status}    ${avg_data_rate}    Run Keyword And Ignore Error
    ...    Validate Traffic Throughput Average Rate for SA MUE    ${dl_rate}
    ...    ${ul_rate}    ${ueid}
    ${data_status}    ${data_rate}    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Run Keyword And Ignore Error    Get Avg Data Rate SA    ${ueid}
    Log To Console    SA Data Status: ${data_status}
    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Append to List    ${sa_dl_list}    ${data_rate[0]}
    ...    ELSE    Append to List    ${sa_dl_list}    ${avg_data_rate[0]}
    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Append to List    ${sa_ul_list}    ${data_rate[1]}
    ...    ELSE    Append to List    ${sa_ul_list}    ${avg_data_rate[1]}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_sa_status}' == 'PASS'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_validate_list_sa}    ${status[0]}
    ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For Perf SA    ${ueid}
    ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
    ...    msg=Traffic failed in Data Loss, see error above!
    Append To List    ${dataloss_validate_list_sa}    ${dataloss_status[0]}

Collect Bearer Stats for SA SUE
    [Arguments]    ${ueid}    ${dl_rate}    ${ul_rate}
    ${trf_sa_status}    ${avg_data_rate}    Run Keyword And Ignore Error
    ...    Validate Traffic Throughput Average Rate for SA MUE    ${dl_rate}
    ...    ${ul_rate}    ${ueid}
    ${data_status}    ${data_rate}    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Run Keyword And Ignore Error    Get Avg Data Rate SA    ${ueid}
    Log To Console    SA Data Status: ${data_status}
    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Append to List    ${sa_sue_dl_list}    ${data_rate[0]}
    ...    ELSE    Append to List    ${sa_sue_dl_list}    ${avg_data_rate[0]}
    Run Keyword If    '${trf_sa_status}' == 'FAIL'
    ...    Append to List    ${sa_sue_ul_list}    ${data_rate[1]}
    ...    ELSE    Append to List    ${sa_sue_ul_list}    ${avg_data_rate[1]}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_sa_status}' == 'PASS'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_validate_list_sa}    ${status[0]}
    ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For Perf SA    ${ueid}
    ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
    ...    msg=Traffic failed in Data Loss, see error above!
    Append To List    ${dataloss_validate_list_sa}    ${dataloss_status[0]}

Stop SA and NSA Traffic
    [Arguments]    ${sa_list}    ${nsa_list}
    Stop MUE SA Traffic    ${sa_list}
    Stop NSA MUE Traffic    ${nsa_list}

Stop SA Traffic
    [Arguments]    ${sa_ueid}
    wtsrunner.trf_data_stop     ue=${sa_ueid}    pdu=1    qfi=1

Stop MUE SA Traffic
    [Arguments]    ${sa_list}
    wtsrunner.trf_data_stop     ue=${sa_list[0]}-${sa_list[-1]}    pdu=1    qfi=1

Stop NSA MUE Traffic
    [Arguments]    ${nsa_list}
    wtsrunner.trf_data_stop     ue=${nsa_list[0]}-${nsa_list[-1]}    id=${BEARER_ID}

Stop NSA Traffic
    [Arguments]    ${nsa_ueid}
    wtsrunner.trf_data_stop     ue=${nsa_ueid}    id=${BEARER_ID}

Create and Reset SA List
    ${dataloss_validate_list_sa}=    Create List
    ${tput_validate_list_sa}=    Create List
    ${sa_dl_list}=    Create List
    ${sa_ul_list}=    Create List
    ${pm_counter_status}=    Create List
    ${sa_sue_dl_list}=    Create List
    ${sa_sue_ul_list}=    Create List
    Set Suite Variable    @{sa_sue_dl_list}
    Set Suite Variable    @{sa_sue_ul_list}
    Set Suite Variable    @{dataloss_validate_list_sa}
    Set Suite Variable    @{tput_validate_list_sa}
    Set Suite Variable    @{sa_dl_list}
    Set Suite Variable    @{sa_ul_list}
    Set Suite Variable    @{pm_counter_status}

Create and Reset NSA List
    ${dataloss_validate_list_nsa}=    Create List
    ${tput_validate_list_nsa}=    Create List
    ${nsa_dl_list}=    Create List
    ${nsa_ul_list}=    Create List
    ${ue_at_gnb}=    Create List
    ${pm_counter_status_nsa}=    Create List
    ${nsa_sue_dl_list}=    Create List
    ${nsa_sue_ul_list}=    Create List
    Set Suite Variable    @{nsa_sue_dl_list}
    Set Suite Variable    @{nsa_sue_ul_list}
    Set Suite Variable    @{dataloss_validate_list_nsa}
    Set Suite Variable    @{tput_validate_list_nsa}
    Set Suite Variable    @{nsa_dl_list}
    Set Suite Variable    @{nsa_ul_list}
    Set Suite Variable    @{ue_at_gnb}
    Set Suite Variable    @{pm_counter_status_nsa}

NSA Attach for Mmwv Single UE Single Cell
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    wtsrunner.enb_endc_param    id=${cell_index_id}    serving_cell_index_range_scg=${FR2_single_cell_index}
    Attach mmwv NSA Single UE Start Traffic and Validate    ${nsa_ueids[0]}    11SUE

Attach mmwv NSA Single UE Start Traffic and Validate
    [Arguments]    ${ueid}    ${tcname}
    [Documentation]    This Keyword does NSA UE attach for Single NSA UE and start traffic
    ${ul_rate}     Get Variable Value    ${TRF_UL_RATE_SUE}     ${ul_data_rate_mmwv}
    ${dl_rate}     Get Variable Value    ${TRF_DL_RATE_SUE}     ${dl_data_rate_mmwv}
    Start NSA Traffic for SUE scenario    ${dl_rate}    ${ul_rate}    ${ueid}    ${tcname}

Attach NSA mmwv Multi UEs Start Traffic and Validate
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ${ul_rate}     Get Variable Value    ${TRF_UL_RATE}     ${ul_datarate_mmwv_mue}
    ${dl_rate}     Get Variable Value    ${TRF_DL_RATE}     ${dl_datarate_mmwv_mue}
    Create and Reset NSA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    NSA mmwv MUE Attach    ${nsa_ueids_cell1}    ${dl_rate}    ${ul_rate}
    UE Connectivity check    ${nsa_ueids_cell1}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        UE Connectivity check    ${nsa_ueids_cell1}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Collect Bearer Stats for NSA MUE    ${nsa_ueids_cell1}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${nsa_ueids_cell1}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    Stop NSA MUE Traffic    ${nsa_ueids_cell1}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Validate Perf NSA MUE Traffic    ${nsa_ueids_cell1}    ${dl_rate}    ${ul_rate}    20MUE    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

NSA mmwv MUE Attach
    [Arguments]    ${nsa_ueids}    ${dl_rate}    ${ul_rate}
    Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    FOR   ${ueid}    IN    @{nsa_ueids}
        LTE Attach should be Successful for NSA MUE    ${ueid}
        UE Attach should be Successful for NSA MUE    ${ueid}    ${targetCellsIds[0]}
    END
    FOR   ${ueid}    IN    @{nsa_ueids}
        Generate NSA mmwv ul Traffic    ${ueid}    ${dl_rate}
        Generate NSA mmwv dl Traffic    ${ueid}    ${ul_rate}
    END

Generate NSA mmwv dl Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}==${num_trf}    Start mmwv NSA Perf dl Traffic    ${ue_id}    ${trf_id}
    END

Generate NSA mmwv ul Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    Log To Console    ${last_trf_rate}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}==${num_trf}    Start mmwv NSA Perf ul Traffic    ${ue_id}    ${trf_id}
    END

Generate NSA Traffic for PerfFDD
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id for Kbps    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}<${num_trf}    Start NSA Perf dl Traffic for PerfFDD    ${ue_id}    ${trf_id}
        ...    ${dir}
        Run Keyword If    ${trf_id}==${num_trf}    Start NSA Perf ul Traffic for PerfFDD    ${ue_id}    ${trf_id}
        ...    ${dir}    ${last_trf_rate}
    END

Start mmwv NSA Perf dl Traffic
    [Arguments]    ${ue_id}    ${trf_id}
    wtsrunner.trf_data_start  ue=${ueid}   trf_id=${trf_id}   id=${Bearer_ID}    kbps=${kbps_dl}   dir=dl    size=1350

Start NSA Perf Traffic for FDD for DL
    [Arguments]    ${ue_id}    ${dl_rate}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}   trf_id=1   id=${Bearer_ID}    kbps=${dl_rate}   dir=${dir}    size=1350

Start mmwv NSA Perf ul Traffic
    [Arguments]    ${ue_id}    ${trf_id}
    wtsrunner.trf_data_start  ue=${ueid}   trf_id=${trf_id}   id=${Bearer_ID}    kbps=${kbps_ul}   dir=ul    size=1350

Start NSA Perf dl Traffic for PerfFDD
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}    trf_id=${trf_id}    id=${Bearer_ID}    kbps=${trf_id_fddperf}   dir=${dir}    size=1350

Start NSA Perf ul Traffic for PerfFDD
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}    trf_id=${trf_id}    id=${Bearer_ID}    kbps=${last_trf_rate}   dir=${dir}    size=1350

Detach NSA MMWV Single UE
    UE 5GDetach should be Successful for NSA Single UE    ${nsa_ueids[0]}
    UE Detach should be Successful for NSA Single UE    ${nsa_ueids[0]}

Detach NSA MMWV MUE
    Detach NSA MUE    ${nsa_ueids}

Validate Perf Tput via gNB counter
    [Arguments]    ${dir}    ${gNB_counter}
    Log To Console    Traffic for: ${dir}
    ${counter}    Get PM Counter Value    ${gNB_counter}
    ${achieved_final_tput}    Run Keyword If    '${counter}' != '${EMPTY}'    Check PM Counter Values    ${counter}
    ...    ELSE    Log To Console    PM Counters are not updated
    [Return]    ${achieved_final_tput}

Check PM Counter Values
    [Arguments]    ${counter}
    ${achieved_tput}=    Evaluate    (${counter}[0]*8)/300000
    [Return]    ${achieved_tput}

Validate Perf Tput via gNB counter for PET
    [Arguments]    ${dir}    ${gNB_counter}
    Log To Console    Traffic for: ${dir}
    ${counter}    Get PM Counter Value    ${gNB_counter}
    ${achieved_final_tput}    Run Keyword If    '${counter}' != '${EMPTY}'    Check PET Counters    ${counter}
    ...    ELSE    Log To Console    PM Counters are not updated
    [Return]    ${achieved_final_tput}

Check PET Counters
    [Arguments]    ${counter}
    ${achieved_tput}=    Evaluate    (${counter}[0]*8)/float(300000)
    [Return]    ${achieved_tput}

Validate Perf Tput via RLC gNB counter
    [Arguments]    ${gNB_counter}
    ${counter}=    Create List
    ${counter}=    Get RLC PM Counter Value    ${gNB_counter}
    ${achieved_counters}    Run Keyword If    '${counter}' != '${EMPTY}'    Check Counter values    ${counter}
    ...    ELSE    Fail    msg=PM Counters are not updated
    [Return]    ${achieved_counters}

Check Counter values
    [Arguments]    ${counter}
    ${achieved_counters}=    Create List
    FOR    ${value}    IN    @{counter}
        ${achieved_tput}=   Evaluate    ${value}*8/300
        Append To List    ${achieved_counters}    ${achieved_tput}
    END
    Log    ${achieved_tput}
    [Return]    ${achieved_counters}

Get PM Counter Value
    [Arguments]    ${counter}
    ${single_counter}=    Create List
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
	${pm_file}=    SSH.Execute    ls -lrt /tmp/PM.*.ANY.xml.gz | tail -1 | awk '{print $9}'    ${GNB_ASIK.Connection}
	${cmd_output}=    Fetch from Left    ${pm_file}    \r
	${cmd_output}=    SSH.Execute	zcat ${cmd_output}	${GNB_ASIK.Connection}
	${counter_list}=    Get regexp matches    ${cmd_output}     \<${counter}\>([0-9]+)
    FOR    ${index}    IN    @{counter_list}
	    ${counter_string}=    Convert to String    ${index}
	    ${counter_string}=    Fetch From Right    ${counter_string}	>
	    ${counter_string}=    Fetch From Left    ${counter_string}	'
	    ${counter}=    Convert to Integer    ${counter_string}
        Run Keyword If    '${counter}' > '0'
        ...    Append To List    ${single_counter}    ${counter}
    END
	[Return]	${single_counter}

Convert SA Data Rate and Update SingleUE MUE
    [Arguments]   ${dl_data_rate}    ${ul_data_rate}    ${tc_name}    ${overall_dl}
    ...    ${overall_ul}    ${dl_tput}    ${ul_tput}
    Log To Console    DL Tput: ${dl_data_rate}
    Log To Console    UL Tput: ${ul_data_rate}
    ${dl_limit}=    Run Keyword If    '${tc_name}' == 'SUE_SA' or '${tc_name}' == '500_CELL2' or '${tc_name}' == '500_CELL1'
    ...    Set Variable    ${dl_limit}
    ...    ELSE IF    '${Fdd_Perf}' == 'True'    Set Variable    ${mue_dl_limit}
    ...    ELSE    Set Variable    ${sa_mue_dl_limit}
    ${ul_limit}=    Run Keyword If    '${Fdd_Perf}' == 'True'    Set Variable    ${mue_dl_limit}
    ...    ELSE    Set Variable    ${ul_limit}
    ${overall_dl}=    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}' != '1'
    ...    Set Variable    ${fdd_per_cell_dl}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' != 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_iwf_dl_dataRate}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' == 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_iwf_per_cell_dl}
    ...    ELSE    Set Variable    ${overall_dl}
    ${overall_ul}=    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}' != '1'
    ...    Set Variable    ${fdd_per_cell_ul}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' != 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_ul_dataRate}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' == 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_per_cell_ul}
    ...    ELSE    Set Variable    ${overall_ul}
    ${sa_dl_rate}=    Evaluate    ${dl_tput}/float(${evaluator})
    ${sa_ul_rate}=    Evaluate    ${ul_tput}/float(${evaluator})
    ${sa_dl_tput_status}=    Evaluate    ${sa_dl_rate} >= (${overall_dl}*${dl_limit})
    ${sa_ul_tput_status}=    Evaluate    ${sa_ul_rate} >= (${overall_ul}*${ul_limit})
    ${sa_dl_rate}=    Evaluate    int(${sa_dl_rate})
    ${sa_ul_rate}=    Evaluate    int(${sa_ul_rate})
    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_DL=${sa_dl_rate}${\n}
    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_UL=${sa_ul_rate}${\n}
    Log To Console    AVG Data Rate SA DL ${sa_dl_rate}
    Log To Console    AVG Data Rate SA UL ${sa_ul_rate}
    ${status_dl}    Run Keyword And Ignore Error    Should Be True    '${sa_dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${sa_ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Get RLC PM Counter Value
    [Arguments]    ${counter}
    ${counter_value}=    Create List
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    ${pm_file}=    SSH.Execute    ls -lrt /tmp/PM.*.ANY.xml.gz | tail -1 | awk '{print $9}'    ${GNB_ASIK.Connection}
    ${cmd_output}=    Fetch from Left    ${pm_file}    \r
    ${cmd_output}=    SSH.Execute   zcat ${cmd_output}  ${GNB_ASIK.Connection}
    ${counter_list}=    Get regexp matches    ${cmd_output}     \<${counter}\>([0-9]+)
    FOR    ${index}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${index}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter}=    Convert to Integer    ${counter_string}
        Run Keyword If    '${counter}' > '0'    Append To List    ${counter_value}    ${counter}
    END
    [Return]    ${counter_value}

Attach Multi UE for Multi Cell
    [Arguments]    ${ul_rate}=${perf_ul_rate}    ${dl_rate}=${perf_nsa_sue_dl_rate}    ${nsa_list}=${nsa_ueids_multicell}
    ...    ${targetIds}=${targetCellsIds}
    ${dl_rate}=    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${Fdd_Perf}' != 'True'    Set Variable    ${perf_sa_sue_dl_rate}
    ...    ELSE    Set Variable    ${dl_rate}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ${nsa_sue_dl_list}=    Create List
    ${nsa_sue_ul_list}=    Create List
    Set Suite Variable    @{nsa_sue_dl_list}
    Set Suite Variable    @{nsa_sue_ul_list}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset NSA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    FOR   ${ueid}    ${target_cell}    IN ZIP    ${nsa_list}    ${targetIds}
        LTE Attach should be Successful for NSA MUE    ${ueid}
        Sleep    2s
        UE Attach should be Successful for NSA MUE    ${ueid}    ${target_cell}
        Sleep    2s
        Generate NSA Traffic    ${ueid}    ${dl_rate}    dl
        Generate NSA Traffic    ${ueid}    ${ul_rate}    ul
    END
    UE Connectivity check    ${nsa_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        UE Connectivity check    ${nsa_list}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats for NSA
        ...    ${nsa_list[0]}    ${dl_rate}    ${ul_rate}
        Run Keyword and Continue On Failure    Collect Bearer Stats for NSA SUE
        ...    ${nsa_list[1]}    ${dl_rate}    ${ul_rate}
        Run Keyword If    '${IWF_ENABLED}' == 'True' and '${Fdd_Perf}' != 'True'    Display nr_stats for NSA UE list    ${nsa_list}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${nsa_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${ueid}    IN    @{nsa_list}
        Stop NSA Traffic    ${ueid}
    END
    ${achieved_nsa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_DL_CELL_RLC_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_UL_CELL_RLC_COUNTER}
    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}'!='1'    Validation of NSA Traffic for fdd Perf    ${dl_rate}
    ...    ${ul_rate}    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    ...    ELSE IF    '${FDD_IWF_multicell}'=='1'    Validation of NSA Traffic for fdd IWF    ${dl_rate}
    ...    ${ul_rate}    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    ...    ELSE    Validation of NSA Traffic for fr1 Perf    ${dl_rate}    ${ul_rate}
    ...    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}

Validation of NSA Traffic for fr1 Perf
    [Arguments]    ${dl_rate}    ${ul_rate}
    ...    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    Run Keyword and Continue On Failure    Validate Perf NSA SUE Traffic
    ...    ${dl_rate}    ${ul_rate}    11UE
    ...    ${achieved_nsa_dl_tput[0]}    ${achieved_nsa_ul_tput[0]}
    Run Keyword and Continue On Failure    Validate Perf NSA SUE Traffic
    ...    ${dl_rate}    ${ul_rate}    111UE
    ...    ${achieved_nsa_dl_tput[1]}    ${achieved_nsa_ul_tput[1]}

Validation of NSA Traffic for fdd Perf
    [Arguments]   ${dl_rate}
    ...    ${ul_rate}    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    @{nsa_ues_count}    Create List    1UE    51UE    101UE    151UE
    ${nsa_ue_list}=    Get Length    ${nsa_ues_count}
    FOR    ${cell}    IN RANGE    ${nsa_ue_list}
        ${dl_tput}    Set Variable    ${achieved_nsa_dl_tput}[${cell}]
        ${ul_tput}    Set Variable    ${achieved_nsa_ul_tput}[${cell}]
        Log To Console    Printing Cell ${cell+1} TPut
        Run Keyword And Continue On Failure    Validate Perf NSA SUE Traffic
        ...    ${dl_rate}    ${ul_rate}    ${NSA_CELL}${cell+1}
        ...    ${dl_tput}    ${ul_tput}
    END

Validation of NSA Traffic for fdd IWF
    [Arguments]    ${dl_rate}
    ...    ${ul_rate}    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    FOR    ${cell}    IN RANGE    ${NO_OF_CELLS_FDDIWF}
        ${dl_tput}    Set Variable    ${achieved_nsa_dl_tput}[${cell}]
        ${ul_tput}    Set Variable    ${achieved_nsa_ul_tput}[${cell}]
        Log To Console    Printing Cell ${cell+1} TPut
        Run Keyword And Continue On Failure    Validate Perf NSA SUE Traffic
        ...    ${dl_rate}    ${ul_rate}    ${NSA_CELL}${cell+1}
        ...    ${dl_tput}    ${ul_tput}
    END

Validate Perf NSA SUE Traffic
    [Arguments]    ${dl_rate}    ${ul_rate}    ${tc_name}    ${achieved_dl}    ${achieved_ul}
    ${updated_nsa_dl}    ${updated_nsa_ul}    Converting List of List To Single List
    ...    ${nsa_sue_dl_list}    ${nsa_sue_ul_list}
    ${nsa_status}    ${nsa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_nsa_dl}    ${updated_nsa_ul}
    Log To Console    NSA Data Status: ${nsa_status}
    Convert NSA Data Rate and Update SingleUE MUE    ${nsa_data_rate[0]}    ${nsa_data_rate[1]}    ${tc_name}    ${dl_rate}
    ...    ${ul_rate}    ${achieved_dl}    ${achieved_ul}

Convert NSA Data Rate and Update SingleUE MUE
    [Arguments]   ${dl_data_rate}    ${ul_data_rate}    ${tc_name}    ${dl}
    ...    ${ul}    ${dl_tput}    ${ul_tput}
    Log To Console    DL Tput: ${dl}
    Log To Console    UL Tput: ${ul}
    Log To Console    DL Rate: ${dl_data_rate}
    Log To Console    UL Rate: ${ul_data_rate}
    ${dl_limit}=    Run Keyword If    '${IWF_ENABLED}' == 'True'    Set Variable    ${dl_limit}
    ...    ELSE IF    '${IWF_ENABLED}' != 'True' and '${Fdd_Perf}' != 'True'    Set Variable    ${dl_mue_limit}
    ...    ELSE IF    '${Fdd_Perf}' == 'True'    Set Variable    ${mue_dl_limit}
    ${ul_limit}=    Run Keyword If    '${Fdd_Perf}' == 'True'    Set Variable    ${mue_dl_limit}
    ...    ELSE    Set Variable    ${ul_limit}
    ${dl}=    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}' != '1'
    ...    Set Variable    ${fdd_per_cell_dl}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' != 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_iwf_dl_dataRate}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' == 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_iwf_per_cell_dl}
    ...    ELSE    Set Variable    ${dl}
    ${ul}=    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}' != '1'
    ...    Set Variable    ${fdd_per_cell_ul}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' != 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_ul_dataRate}
    ...    ELSE IF    '${FDD_IWF_multicell}' == '1' and '${fdd_mue_tag}' == 'SANSA_MUE_20'
    ...    Set Variable    ${fdd_per_cell_ul}
    ...    ELSE    Set Variable    ${ul}
    ${nsa_dl_rate}=    Evaluate    int(${dl_tput}/${evaluator})
    ${nsa_ul_rate}=    Evaluate    int(${ul_tput}/${evaluator})
    Log To Console    AVG Data Rate NSA DL ${nsa_dl_rate}
    Log To Console    AVG Data Rate NSA UL ${nsa_ul_rate}
    ${sa_dl_tput_status}=    Evaluate    ${nsa_dl_rate} >= (${dl}*${dl_limit})
    ${sa_ul_tput_status}=    Evaluate    ${nsa_ul_rate} >= (${ul}*${ul_limit})
    Append To File     ${test_property_file}    ${\n}NSA_${tc_name}_DL=${nsa_dl_rate}${\n}
    Append To File     ${test_property_file}    ${\n}NSA_${tc_name}_UL=${nsa_ul_rate}${\n}

    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${sa_dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status_nsa}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error    Should Be True    '${sa_ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status_nsa}    ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status_nsa}    FAIL    msg=Traffic failed in Throughput, see error above!

Detach for Multi UE for Multi Cell
    [Arguments]    ${nsa_list}=${nsa_ueids_multicell}
    Detach NSA MUE    ${nsa_list}

Collect Bearer Stats for NSA SUE
    [Arguments]    ${ueid}    ${dl_rate}    ${ul_rate}
    ${trf_nsa_status}    ${avg_data_rate}    Run Keyword And Ignore Error
    ...    Validate Traffic Throughput Average Rate for NSA MUE
    ...    ${dl_rate}     ${ul_rate}    ${ueid}
    ${data_status}    ${data_rate}    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Run Keyword And Ignore Error    Get Avg Data Rate NSA    ${ueid}
    Log To Console    NSA data Status: ${data_status}
    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Append to List    ${nsa_sue_dl_list}    ${data_rate[0]}
    ...    ELSE    Append to List    ${nsa_sue_dl_list}    ${avg_data_rate[0]}
    Run Keyword If    '${trf_nsa_status}' == 'FAIL'
    ...    Append to List    ${nsa_sue_ul_list}    ${data_rate[1]}
    ...    ELSE    Append to List    ${nsa_sue_ul_list}    ${avg_data_rate[1]}
    ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_nsa_status}' == 'PASS'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_validate_list_nsa}    ${status[0]}
    ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For Perf NSA    ${ueid}
    ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
    ...    msg=Traffic failed in Data Loss, see error above!
    Append To List    ${dataloss_validate_list_nsa}    ${dataloss_status[0]}

Get L2RT container ID
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    ${L2RT_id}=    SSH.execute    command=ddal -s ddal_sysinfo_module_get_domain_id 0 | grep "^dmid=" | cut -d "=" -f 2
    ...    connection=${AP_ASIK.Connection}
    ${L2RT_id}=    Set Variable    ${L2RT_id.strip()}
    ${L2RT_container}=    Set Variable If    '${L2RT_id}' == '6'    ${L2RT_container.replace('5', '6')}    ${L2RT_container}
    ${L2RT_container_ID}=    Set Variable If    '${L2RT_id}' == '6'    ${L2RT_container_ID.replace('5', '6')}    ${L2RT_container_ID}
    ssh.Disconnect    ${AP_ASIK.Connection}
    Set Suite Variable    ${L2RT_container}
    Set Suite Variable    ${L2RT_container_ID}

Collection of em perf Stats
    [Arguments]    ${tcname}    ${L2RT_container}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    ${tcname}=    Replace String    ${tcname}    ${SPACE}    _
    Execute Send SSH commands    ${ap_base_ip}    1:0
    ...    lxc-attach --name ${L2RT_container} -- /opt/CCS_RT/em_perf_monitor -pq > /ffs/run/logs/stats.log
    ...    ${AP_ASIK.Connection}
    sleep    10s
    ssh.Disconnect    target
    ssh.Disconnect    ${AP_ASIK.Connection}
    Cleanup of em perf process    ${tcname}    ${L2RT_container}

Cleanup of em perf process
    [Arguments]    ${tcname}    ${L2RT_container_ID}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    Execute Send SSH commands    ${ap_base_ip}    1:0    lxc-attach --name ${L2RT_container_ID} -- pgrep perf
    ...    ${AP_ASIK.Connection}
    Execute Send SSH commands    ${ap_base_ip}    1:0    lxc-attach --name ${L2RT_container_ID} -- pkill -f perf
    ...    ${AP_ASIK.Connection}
    ssh.Disconnect    target
    ssh.Disconnect    ${AP_ASIK.Connection}
    Collect em_perf_Stats Logs    ${tcname}

Collect em_perf_Stats Logs
    [Arguments]    ${tcname}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    Download File    /ffs/run/logs/stats.log    ${EXECDIR}/logs/stats.log
    ...    ${AP_ASIK.Connection}
    SSH.Send Command    command=rm -rf /ffs/run/logs/stats.log
    ...               timeout=60    connection=${AP_ASIK.Connection}
    ssh.Disconnect    ${AP_ASIK.Connection}
    Run    mkdir ${EXECDIR}/em_perf_Stats
    Run    mv ${EXECDIR}/logs/stats.log ${EXECDIR}/em_perf_Stats
    Run    mv ${EXECDIR}/em_perf_Stats/stats.log ${EXECDIR}/em_perf_Stats/${tcname}.log

Collection of em traces
    [Arguments]    ${tcname}    ${L2RT_container_ID}
    ${tcname}=    Replace String    ${tcname}    ${SPACE}    _
    Run    chmod +x ${EXECDIR}/${em_trace_stream}
    ${cmd}    catenate    ${EXECDIR}/${em_trace_stream} - -p ${em_trace_stream_port}
    ...       -c ${L2RT_container_ID} -t ${em_trace_type}
    ...       -n ${AP_ASIK.Ip}
    Run Process    ${cmd}    shell=True   timeout=60s
    Collect em_traces Logs    ${tcname}    ${L2RT_container_ID}

Collect em_traces Logs
    [Arguments]    ${tcname}    ${L2RT_container_ID}
    ${tcname}=    Remove String    ${tcname}    &
    Run    killall EmTraceHistoryBufferStreamReceiver64
    Run    ls -lrt
    Run    mkdir -p ${EXECDIR}/logs/em_traces
    Run    mv ${EXECDIR}/${L2RT_container_ID}_* ${EXECDIR}/logs/em_traces
    Run    cd ${EXECDIR}/logs/em_traces && ls -lrt
    Run    tar -czvf ${EXECDIR}/logs/em_traces/${tcname}.tar.gz ${EXECDIR}/logs/em_traces/${L2RT_container_ID}_*
    Run    rm -rf ${EXECDIR}/logs/em_traces/${L2RT_container_ID}_*

Check UE Activity for SA
    [Arguments]    ${sa_ue_id_list}
    ${active_sa_ue}=    Create List
    ${ue_list_sa}=    Create List
    Set Suite Variable    @{active_sa_ue}
    Set Suite Variable    @{ue_list_sa}
    ${type_of}=    Evaluate    type(${sa_ue_id_list}).__name__
    ${num}=    Run Keyword If    '${type_of}' == 'int'    Set Variable    1
    ...    ELSE    Get Length    ${sa_ue_id_list}
    wtsrunner.ue_summary
    ${ue_summary}      wtsrunner.read_wtsemu_output_until    expected=Idle
    ...                     timeout=60
    ${active_ues}       Run Keyword If    '${perf_mue}' == 'True'    Get Regexp Matches
    ...    ${ue_summary}    Active +(\\d+)    1
    ...    ELSE    Get Regexp Matches    ${ue_summary}    ENB-2 +(\\d+)    1
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    Log To Console    [${hr}:${min}:${sec}]:Active No.of SA UEs:${active_ues[0]}
    Run Keyword If    '${TAG_NAME}' == '3000UEDLUL'    Check RRC Connected UES    ${active_ues[0]}    ${num}
    ...    ELSE IF    '${TAG_NAME}' != '3000UEDLUL'    Check Connected UES    ${active_ues[0]}
    ${active_ues_total}=    Run Keyword If    '${test_label}' == 'SA500UE' or '${tag_name}' == 'SA608UE'
    ...    Set Variable    ${active_ues[0]}
    Run Keyword If    '${test_label}' == 'SA500UE' or '${tag_name}' == 'SA608UE'    Set Suite Variable    ${active_ues_total}
    ${status}=    Run Keyword If    '${active_ues[0]}' == '0'    Set Variable    'FAIL'
    Append To List    ${ue_list_sa}    ${status}
    List Should Not Contain Value    ${ue_list_sa}    FAIL    msg=Active No Of UEs are zero

Check Active UEs
    [Arguments]    ${sa_ue_id_list}    ${nsa_ue_id_list}
    Check UE Activity for SA    ${sa_ue_id_list}
    UE Connectivity check    ${nsa_ue_id_list}

SA NSA Register Attach and Traffic Validation
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ${ul_rate}     Get Variable Value    ${MUE_UL_RATE}     ${perf_mue_ul_rate}
    ${dl_rate}     Get Variable Value    ${MUE_DL_RATE}     ${perf_mue_dl_rate}
	Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
	Create and Reset SA List
    Create and Reset NSA List
    NSA MUE Attach Traffic and Validation    ${nsa_ueids_cell1}    ${targetCellsIds[0]}    ${dl_rate}
    ...    ${ul_rate}
    ${sa_cell1_10ues}    Get 10UE IDS    ${sa_ueids_cell1}
    Set Suite Variable    ${sa_cell1_10ues}
    SA MUE Register Traffic and Validation    ${sa_cell1_10ues}    ${dl_rate}
    ...    ${ul_rate}
    Check Active UEs    ${sa_cell1_10ues}    ${nsa_ueids_cell1}
	FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Check Active UEs    ${sa_cell1_10ues}    ${nsa_ueids_cell1}
        Run Keyword and Continue On Failure    Collect Bearer Stats at Intervals for Single Cell
        ...    ${nsa_ueids_cell1}    ${sa_cell1_10ues}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
	END
    Check Active UEs    ${sa_cell1_10ues}    ${nsa_ueids_cell1}
    Stop SA and NSA Traffic    ${sa_cell1_10ues}    ${nsa_ueids_cell1}
    SA NSA Validation    10PARUE    ${dl_rate}    ${ul_rate}

SA Register and Traffic Validation
    [Arguments]    ${tc_name}    ${ue_list}    ${dl_rate}    ${ul_rate}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    Create and Reset SA List
    SA MUE Register Traffic and Validation    ${ue_list}    ${dl_rate}
    ...    ${ul_rate}
    Check UE Activity for SA    ${ue_list}
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Check UE Activity for SA    ${ue_list}
        Run Keyword and Continue On Failure    Collect Bearer Stats for SA MUE
        ...    ${ue_list}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check UE Activity for SA    ${ue_list}
    Stop MUE SA Traffic    ${ue_list}
    SA Validation    ${tc_name}    ${dl_rate}    ${ul_rate}

SA Deregister and NSA UE Detach
    [Arguments]    ${sa_list}=${sa_cell1_10ues}    ${nsa_list}=${nsa_ueids_cell1}
    UE Deregister for SA MUE    ${sa_list}
    Detach NSA MUE    ${nsa_list}

NSA Attach and Traffic Validation
    [Arguments]    ${nsa_ueids_cell1}=${nsa_ueids_cell1}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    ${ul_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${MUE_UL_RATE}
    ...    ${abil_mue_rate}
    ...    ELSE    Get Variable Value    ${MUE_UL_RATE}     ${perf_mue_ul_rate}
    ${dl_rate}     Run Keyword If    '${AP_P1Perf_ABIL}'=='True'    Get Variable Value    ${MUE_DL_RATE}
    ...    ${abil_mue_rate}
    ...    ELSE    Get Variable Value    ${MUE_DL_RATE}     ${perf_mue_dl_rate}
	Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    Create and Reset NSA List
    NSA MUE Attach Traffic and Validation    ${nsa_ueids_cell1}    ${targetCellsIds[0]}    ${dl_rate}
    ...    ${ul_rate}
    UE Connectivity check    ${nsa_ueids_cell1}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        UE Connectivity check    ${nsa_ueids_cell1}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats for NSA MUE
        ...    ${nsa_ueids_cell1}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${nsa_ueids_cell1}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    Stop NSA MUE Traffic    ${nsa_ueids_cell1}
    NSA Validation    10NSAUE    ${dl_rate}    ${ul_rate}

SA NSA MUE Register Attach and Traffic
    [Arguments]    ${dl_rate}=${perf_mue_dl_rate}    ${ul_rate}=${perf_mue_ul_rate}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Initial Setup for PET Test Cases    SA_NSA_PAR_TC2
    ${nsa_cell1_5ues}    Get UE IDS    ${nsa_ueids_cell1}
    ${nsa_cell2_5ues}    Get UE IDS    ${nsa_ueids_cell2}
    ${sa_cell1_5ues}    Get UE IDS    ${sa_ueids_cell1}
    ${sa_cell2_5ues}    Get UE IDS    ${sa_ueids_cell2}
    ${no_of_ues}=     Get Length    ${sa_cell1_5ues}
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Set Amf to register MUE With start UE    ${amf_list[0]}
    ...    ${amf_list[1]}    ${mnc_mcc_plmn}    ${no_of_ues}    ${sa_ueids_multicell[0]}
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Set Amf to register MUE With start UE    ${amf_list[0]}
    ...    ${amf_list[1]}    ${mnc_mcc_plmn}    ${no_of_ues}    ${sa_ueids_multicell[1]}
    NSA MUE Attach Traffic and Validation    ${nsa_cell1_5ues}    ${targetCellsIds[0]}    ${dl_rate}
    ...    ${ul_rate}
    NSA MUE Attach Traffic and Validation    ${nsa_cell2_5ues}    ${targetCellsIds[1]}    ${dl_rate}
    ...    ${ul_rate}
    SA MUE Register Traffic and Validation    ${sa_cell1_5ues}    ${dl_rate}
    ...    ${ul_rate}
    SA MUE Register Traffic and Validation    ${sa_cell2_5ues}    ${dl_rate}
    ...    ${ul_rate}
    Create and Reset SA List
    Create and Reset NSA List
    ${total_nsa_ues}=    Combine Lists    ${nsa_cell1_5ues}    ${nsa_cell2_5ues}
    ${total_sa_ues}=    Combine Lists    ${nsa_cell1_5ues}    ${nsa_cell2_5ues}
    Check Active UEs    ${total_sa_ues}    ${total_nsa_ues}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Check Active UEs    ${total_sa_ues}    ${total_nsa_ues}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats at Intervals    ${nsa_cell1_5ues}
        ...    ${nsa_cell2_5ues}    ${sa_cell1_5ues}    ${sa_cell2_5ues}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check Active UEs    ${total_sa_ues}    ${total_nsa_ues}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
	Stop SA and NSA Traffic    ${sa_cell1_5ues}    ${nsa_cell1_5ues}
    Stop SA and NSA Traffic    ${sa_cell2_5ues}    ${nsa_cell2_5ues}
    SA NSA Validation    5PARUE    ${dl_rate}    ${ul_rate}

SA Deregister and NSA MUE Detach MultiCell
    NSA Detach MUE Multicell    ${nsa_ueids_cell1}
    NSA Detach MUE Multicell    ${nsa_ueids_cell2}
    SA Deregister MUE Multicell    ${sa_ueids_cell1}
    SA Deregister MUE Multicell    ${sa_ueids_cell2}

Start SA Traffic for SUE scenario
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ueid}    ${tcname}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset SA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    UE Register should be Successful for SA for MUE    ${ueid}
    Generate SA Traffic    ${ueid}    ${dl_rate}    dl
    Run Keyword If    '${IWF_ENABLED}' != 'True'    Generate SA Traffic    ${ueid}    ${ul_rate}    ul
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    Check UE Activity for SA    ${ueid}
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        Check UE Activity for SA    ${ueid}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats for SA
        ...    ${ueid}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check UE Activity for SA    ${ueid}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    Stop SA Traffic    ${ueid}
    ${achieved_sa_dl_tput}    Run Keyword If    '${tcname}' != '1UEUL'
    ...    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Run Keyword If    '${tcname}' != 'SA_1_UE_2CC' or '${tcname}' != 'SA_1_UE_3CC'
    ...    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    Run Keyword If    '${tcname}' != '1UEUL'    Validate Perf SA Traffic
    ...    ${dl_rate}    ${ul_rate}    ${tcname}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    ...    ELSE    Run Keyword If    '${tcname}' == '1UEUL'    Validate Traffic    1UEUL
    ...    ${achieved_sa_ul_tput}    ul

NSA MUE Attach Traffic and Validation for PerfFDD
    [Arguments]    ${nsa_ue_list}    ${target_cell}    ${dl_rate}    ${ul_rate}
    Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    FOR   ${ueid}    IN    @{nsa_ue_list}
        LTE Attach should be Successful for NSA MUE    ${ueid}
    END
    Sleep    2s
    FOR   ${ueid}    IN    @{nsa_ue_list}
        UE Attach should be Successful for NSA MUE    ${ueid}    ${target_cell}
        Sleep    2s
        Start NSA Perf Traffic for FDD for DL    ${ueid}    ${dl_rate}    dl
        Generate NSA Traffic for PerfFDD    ${ueid}    ${ul_rate}    ul
    END

Generate SA Traffic for PerfFDD
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id for Kbps    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}<${num_trf}    Start SA Perf Traffic Kbps   ${ue_id}
        ...    ${trf_id}    ${dir}
        Run Keyword If    ${trf_id}==${num_trf}    Start SA Perf Traffic Kbps FDD    ${ue_id}    ${trf_id}
        ...    ${dir}    ${last_trf_rate}
    END

Start SA Perf Traffic Kbps
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}   pdu=${pdu}   qfi=${qfi}   trf_id=${trf_id}   kbps=${trf_id_fddperf}   dir=${dir}    size=${trf_id_perf}

Start SA Perf Traffic Kbps FDD
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}   pdu=${pdu}   qfi=${qfi}   trf_id=${trf_id}   kbps=${last_trf_rate}   dir=${dir}    size=${trf_id_perf}

Start SA Traffic for MUE scenario
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ueid_list}    ${tcname}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset SA List
    FOR   ${ueid}    IN    @{ueid_list}
        UE Register should be Successful for SA for MUE    ${ueid}
        Generate SA Traffic    ${ueid}    ${dl_rate}    dl
        Generate SA Traffic    ${ueid}    ${ul_rate}    ul
    END
    Check UE Activity for SA    ${ueid_list}
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        Check UE Activity for SA    ${ueid_list}
        Run Keyword and Continue On Failure    Collect Bearer Stats for SA MUE
        ...    ${ueid_list}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check UE Activity for SA    ${ueid_list}
    Stop MUE SA Traffic    ${ueid_list}
    ${achieved_sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    Validate Perf MUE SA Traffic    ${ueid_list}    ${dl_rate}    ${ul_rate}    ${tcname}    ${achieved_sa_dl_tput}
    ...    ${achieved_sa_ul_tput}

SA MUE Register for 304UEs
    ${TRF_DURATION}    Get Variable Value    ${PET_DURATION}    ${perf_trf_duration}
    Register and Traffic    ${SA_304UE_BOTH}
    ...    ${TRF_DURATION}    both    SA304UE
    ${achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    ul    ${SA_UL_TPUT_COUNTER}
	Validate Traffic DLUL    SA304UE    ${achieved_dl_tput}    ${achieved_ul_tput}

SA Deregister MUE 304UEs
    UE Deregister for SA MUE    ${sa_ue_id_list}

Start NSA Traffic for SUE scenario
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ueid}    ${tcname}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset NSA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    LTE Attach should be Successful for NSA MUE    ${ueid}
    Sleep    2s
    UE Attach should be Successful for NSA MUE    ${ueid}    ${targetcell_ids[0]}
    Generate NSA Traffic    ${ueid}    ${dl_rate}    dl
    Run Keyword If    '${tcname}' == '11SUE' or '${IWF_ENABLED}' != 'True'
    ...    Generate NSA Traffic    ${ueid}    ${ul_rate}    ul
    UE Connectivity check    ${ueid}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        UE Connectivity check    ${ueid}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Continue On Failure    Collect Bearer Stats for NSA
        ...    ${ueid}    ${dl_rate}    ${ul_rate}
        wtsrunner.ue_stats_nr    id=${stats_id}    type=${stats_type}    scell=${stats_scell}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${ueid}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    Stop NSA Traffic    ${ueid}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Run Keyword If    '${tcname}' == '11SUE' or '${IWF_ENABLED}' != 'True'
    ...    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    ...    ELSE    Set Variable    0
    Validate Perf NSA Traffic    ${dl_rate}    ${ul_rate}    ${tcname}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

Start NSA Traffic for MUE scenario
    [Arguments]    ${ueid_list}    ${dl_rate}    ${ul_rate}    ${tcname}    ${targetcells}=${targetCellsIds[0]}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset NSA List
    FOR   ${ueid}    IN    @{ueid_list}
        LTE Attach should be Successful for NSA MUE    ${ueid}
    END
    Sleep    2s
    FOR   ${ueid}    IN    @{ueid_list}
        UE Attach should be Successful for NSA MUE    ${ueid}    ${targetcells}
        Sleep    2s
        Generate NSA Traffic    ${ueid}    ${dl_rate}    dl
        Generate NSA Traffic    ${ueid}    ${ul_rate}    ul
    END
    UE Connectivity check    ${ueid_list}
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        UE Connectivity check    ${ueid_list}
        Run Keyword and Continue On Failure    Collect Bearer Stats for NSA MUE
        ...    ${ueid_list}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${ueid_list}
    Stop NSA MUE Traffic    ${ueid_list}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Validate Perf NSA MUE Traffic    ${ueid_list}    ${dl_rate}    ${ul_rate}    ${tcname}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

Validate Traffic Data Loss For Perf NSA
    [Documentation]    NSA Traffic Data Loss Criteria
    [Arguments]    ${UE_ID}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Perf Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=ul   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Perf Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

Validate Traffic Data Loss For Perf SA
    [Documentation]    SA Traffic Data Loss Criteria
    [Arguments]    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Perf Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Perf Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}    ${UE_ID}

Check DL Perf Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}    ${ueid}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log    UE${ueid}:DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               Log    UE${ueid}:DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Check UL Perf Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}    ${ueid}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_scg}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_all}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log    UE${ueid}:UL Bytes sent complete (${bytes_sent[0]})
    ...               ELSE
    ...               Log    UE${ueid}:UL Data Loss! Bytes Sent (${bytes_sent[0]}) not matching given threshold! Received (${bytes_rec[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

SA NSA Validation
    [Arguments]    ${tcname}    ${dl_rate}    ${ul_rate}
    ${updated_sa_dl}    ${updated_sa_ul}    Converting List of List To Single List    ${sa_dl_list}
    ...    ${sa_ul_list}
    ${updated_nsa_dl}    ${updated_nsa_ul}    Converting List of List To Single List    ${nsa_dl_list}
    ...    ${nsa_ul_list}
    ${sa_status}    ${sa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_sa_dl}    ${updated_sa_ul}
    Log To Console    SA data Status: ${sa_status}
    ${nsa_status}    ${nsa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_nsa_dl}    ${updated_nsa_ul}
    Log To Console    NSA data Status: ${nsa_status}
    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}
    ...    Run Keyword If    '${Fdd_Perf}' != 'True'    Counter gNB
    ...    ELSE    Counter RLC
    Run Keyword And Continue On Failure    Convert SA Data Rate and Update    ${sa_data_rate[0]}
    ...    ${sa_data_rate[1]}    ${tcname}    ${dl_rate}    ${ul_rate}    ${achieved_sa_dl_tput}
    ...    ${achieved_sa_ul_tput}
    Run Keyword And Continue On Failure    Convert NSA Data Rate and Update    ${nsa_data_rate[0]}
    ...    ${nsa_data_rate[1]}    ${tcname}    ${dl_rate}    ${ul_rate}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

Counter gNB
    ${achieved_sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    [Return]    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

Counter RLC
    ${achieved_sa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${SA_UL_TPUT_COUNTER}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_UL_TPUT_COUNTER}
    [Return]    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

SA Validation
    [Arguments]    ${tcname}    ${dl_rate}    ${ul_rate}
    ${updated_sa_dl}    ${updated_sa_ul}    Converting List of List To Single List    ${sa_dl_list}
    ...    ${sa_ul_list}
    ${sa_status}    ${sa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_sa_dl}    ${updated_sa_ul}
    Log To Console    SA Data Status: ${sa_status}
    ${achieved_sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    Run Keyword And Continue On Failure    Convert SA Data Rate and Update    ${sa_data_rate[0]}
    ...    ${sa_data_rate[1]}    ${tcname}    ${dl_rate}    ${ul_rate}    ${achieved_sa_dl_tput}
    ...    ${achieved_sa_ul_tput}

NSA Validation
    [Arguments]    ${tcname}    ${dl_rate}    ${ul_rate}
    ${updated_nsa_dl}    ${updated_nsa_ul}    Converting List of List To Single List    ${nsa_dl_list}
    ...    ${nsa_ul_list}
    ${nsa_status}    ${nsa_data_rate}    Run Keyword And Ignore Error
    ...    Calculate Cumulative Average Data Rate    ${updated_nsa_dl}    ${updated_nsa_ul}
    Log To Console    NSA Data Status: ${nsa_status}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Run Keyword And Continue On Failure    Convert NSA Data Rate and Update    ${nsa_data_rate[0]}
    ...    ${nsa_data_rate[1]}    ${tcname}    ${dl_rate}    ${ul_rate}    ${achieved_nsa_dl_tput}
    ...    ${achieved_nsa_ul_tput}

UE List creation
    [Arguments]    ${start_ue}    ${end_ue}
    ${uelist}=    Create List
    FOR    ${ueid}    IN RANGE    ${start_ue}    ${end_ue}+1    1
        Append To List    ${uelist}    ${ueid}
    END
    [Return]    ${uelist}

Stop Traffic for SA MultiUE Perf and Validate Throughput
    [Arguments]    ${uelist}
    Stop MUE SA Traffic    ${uelist}

Commission the scf
    [Arguments]    ${wft_label_fr1}
    ${pet_scf_file}=    Set Variable    ${EXECDIR}/topology-configs/${ute_ca_label}/SBTS00/${ute_ca_variant}/scfc.xml
    Run Keyword If    '${perf_mue}' == 'True'
    ...    Run    cp ${pet_scf_file} ${custom_perf_path}/${ute_ca_variant}/scfc.xml
    ${command}=    Catenate     python3 ${config_reader} ${custom_perf_path}/${ute_ca_variant}/scfc.xml ${wft_label_fr1}
    ${result}=    Run    ${command}
    Should Not Contain    ${result}    Traceback    msg=Yaml Update failure! Check taf.config.scf library

Bringup Perf Setup After Commissioning
    [Arguments]    ${test_tag}
    Removal of logs from e2e_tests path
    Removal of logs
    Remove tmp contents
    Run Keyword If    '${test_tag}' != 'SA500UE'    Perform Perf SCF Commissioning
    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True'    Apply ECPRI72E Vendor File
    Run Keyword If    '${test_label}' in "@{DSS_CA_TAGS}" or '${IWF_TDD_ECPRI72E}' == 'True'
    ...    Start UTE WTS Perf for WtsSim IWF
    ...    ELSE    Start UTE WTS Perf

Perform Perf SCF Commissioning
    ${command}    Catenate    mkdir    -p /home/ute/scripts
    Run    ${command}
    ${input_scf}=    Catenate    ${custom_perf_path}/${ute_ca_variant}/scfc.xml
    ${output_scf}=    Set Variable    ${input_scf}
    Modify Vlan for Perf    input_scf=${input_scf}    output_scf=${output_scf}
    ${command}=    Catenate    cd ${CURDIR}/../../../QT/resources/scripts/ &&
    ...            python -c
    ...            "import scf_comm_script;scf_comm_script.scf_comm('${GNB_ASIK.Ip}', '${output_scf}')"
    log to console    Commission: ${command}
    ${commission_result}=    Run    ${command}
    Log To Console    Commission Result: ${commission_result}
    Should Not Contain    ${commission_result}    Traceback    msg=Commission Failure! Terminating the execution
    ${status}    Run Keyword If    '${ute_ca_variant}' != 'PRIVATE_SANSA_ECPRI72E_CMWV_TDD_50MHz_AP_PERF'
    ...    Run Keyword And Return Status    Reset and Check Ready State
    Run Keyword If    '${status}' != '' and ${status} == False    Reset and Check Ready State

Reset and Check Ready State
    Reset Coam Site PET
    Wait Until Keyword Succeeds    20min    15sec    Coam Site Should be Ready for PET

Coam Site Should be Ready for PET
    [Documentation]     This keyword checks whether TL is in Configured state and BTS sw is populated.
    Wait Coam Site to be Ready
    Should Contain    ${stream_nr}    SBTS

Reset Coam Site PET
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Reset Site
    [Teardown]    CoamAdmin.Teardown

Power Reset From PDU for PET
    ${rc}       ${output}=          Run and Return RC and Output     grep pdu_ports ${init_file}
    @{lines}=    Split String  ${output}    \n
    Length Should Be    ${lines}   2   Not able to find PDU ports from '${init_file}'

    ${rc}   ${output}=      Run and Return RC and Output     grep port_numbers ${init_file}
    ${matched_value}=    Get Regexp Matches    ${output}    \\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}
    Set Suite Variable    ${pdu_ip}    ${matched_value}
    ${rc}       ${output}=    Run and Return RC and Output
    ...    grep -A 0 _pdu ${init_file}|cut -d'(' -f1 | head -n 1 | cut -d' ' -f3
    Set Suite Variable    ${model}    ${output}
    FOR    ${line}    IN    @{lines}
        ${pdu_port}=    Get Substring   ${line}    -3   -2
        Reset port on PDU for PET    ${pdu_ip}[0]    ${pdu_port}    model=${model}
    END

Reset port on PDU for PET
    [Arguments]         ${PDU_IP}    ${PDU_PORT}    ${alias}=atenpdu    ${model}=RRB
    Log To Console      \n Reset ongoing for PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu       host=${PDU_IP}
    ...                 model=${model}
    ...                 alias=${alias}
    pdu.power_off       port=${PDU_PORT}
    ...                 pdu_device=${alias}
    sleep               10s
    pdu.power_on        port=${PDU_PORT}
    ...                 pdu_device=${alias}
    Sleep               10s

Modify Vlan for Perf
    [Arguments]    ${input_scf}=${input_scf}    ${output_scf}=${output_scf}    ${dist}=${dist}    ${pname}=${vland_pname}
    ${init_file}=    Get init file for Perf
    Set Suite Variable    ${init_file}
    ${command}    Catenate    sed -nr 's/^.*vlan_id=//p' ${init_file} | cut -d')' -f1 | head -n 1
    ${vlan_id}    Run    ${command}
    scf.load_scf    ${input_scf}
    Run Keyword    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist}    p_name=${pname}
    scf.save_scf    ${output_scf}

Get Hostname Details for Perf
    ${result}   ${value}=     Run Keyword And Ignore Error    Get Param Value From File
    ...    ${testline_results_file}    HOSTNAME:\\s+(\\w+.*\\w+)
    ${value}=    Run Keyword If    '${result}' == 'FAIL'    Run Command Locally for Perf    hostname
    ...    ELSE    Set Variable    ${value}
    ${hostname}=    Replace String Using Regexp    ${value}    -    _
    [Return]    ${hostname}

Run Command Locally for Perf
    [Arguments]    ${command}
    ${rc}   ${output}=      Run and Return RC and Output     ${command}
    [Return]    ${output}

Check Status till Cell Setup
    [Arguments]    ${label}
    Run Keyword If    '${label}' == '40UEDL'
    ...    Set Suite Variable    ${component_carrier}    2
    Run Keyword If    '${label}' == '40UEDL3CC'
    ...    Set Suite Variable    ${component_carrier}    3
    Run Keyword If    '${label}' == 'FR2_4CC'
    ...    Set Suite Variable    ${component_carrier}    4
    Run Keyword If    '${label}' == 'FR2_8CC'
    ...    Set Suite Variable    ${component_carrier}    8
    Run Keyword If    '${label}' == 'FR2_NSA_MUE_2CELL'
    ...    Set Suite Variable    ${component_carrier}    2
    Run Keyword If    '${label}' == 'FR2_NSA_SUE'
    ...    Set Suite Variable    ${component_carrier}    2
    Run Keyword If    '${label}' == 'FR2_NSA_SUE'
    ...    Set Suite Variable    ${component_carrier}    2
    Run Keyword If    '${label}' == 'SA500UE'
    ...    Set Suite Variable    ${component_carrier}    2
    Run Keyword If    '${label}' == 'SA_CA_80UE'
    ...    Set Suite Variable    ${component_carrier}    4
    Run Keyword If    '${label}' in "@{NSA_TAGS}"    X2AP Link Should be UP
    Run Keyword If    '${label}' in "@{IWF_TAGS}" and '${label}' not in "@{FR1_2CC_TAGS}" and '${label}' not in "@{FR2_IWF_TAGS}"
    ...    AP Cell Setup should be Successful
    Run Keyword If    '${label}' in "@{FR2_IWF_TAGS}" and '${label}' not in "@{FR1_IWF_TAGS}"
    ...    Cell Setup Validation from egate Console
    Log To Console    Completed Cell status
    Run Keyword If    '${perf_mue}' == 'True'    Stop Tcpdump for PET

Stop Tcpdump for PET
    Run    sudo pkill tcpdump
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Execute    pkill tcpdump
    ...               timeout=60    connection=${AP_ASIK.Connection}
    ssh.Disconnect    ${AP_ASIK.Connection}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    SSH.Execute    pkill tcpdump
    ...               timeout=60    connection=${GNB_ASIK.Connection}
    ssh.Disconnect    ${GNB_ASIK.Connection}

Removal of logs from e2e_tests path
    Run    cd ${EXECDIR}/logs/
    Remove Directory    ${EXECDIR}/logs/udpsyslog/    recursive=True
    Remove Directory    ${sys_log_directory}    recursive=True

Removal of logs
    Run    cd ${WTS_DIR}
    Run    rm -rf ${WTS_DIR}/pgw* enb* uec* enb* stdout* upf* sgw* amf* mme*
    Run    rm -rf ${EXECDIR}/logs/SosReport*.tgz


Validate Traffic
    [Arguments]    ${tc_name}    ${tput}    ${dir}
    ${status}=    Create List
    ${pm_counter_status}=    Create List
    Set Suite Variable    @{pm_counter_status}
    ${overall_data_rate}=    Run Keyword If    '${dir}' == 'dl' and '${tc_name}' not in "@{DL_TAGS}"
    ...    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}
    ...    ELSE    Run Keyword If    '${dir}' == 'ul' and '${tc_name}' not in "@{UL_TAGS}"
    ...    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}
    ...    ELSE    Run Keyword If    '${tc_name}' == '1UEUL'    Set Variable    440
    ...    ELSE    Run Keyword If    '${tc_name}' == '72UEUL'
    ...    Evaluate    ${OVERALL_UL}*72/float(1000)
    ...    ELSE    Run Keyword If    '${tc_name}' == '40UEDL' or '${tc_name}' == '40UEDL3CC'
    ...    Evaluate    ${OVERALL_DL}*40
    ...    ELSE    Run Keyword If    '${tc_name}' == 'SA20'
    ...    Evaluate    ${OVERALL_DL}*20
    ...    ELSE    Run Keyword If    '${tc_name}' == 'FR2_2CC' or '${tc_name}' == 'FR2_8CC' or '${tc_name}' == 'SA_20_UE_2CC'
    ...    Evaluate    ${OVERALL_DL}
    ...    ELSE    Run Keyword If    '${tc_name}' == 'NSA_4_UE' or '${tc_name}' == 'SA_4_UE'
    ...    Evaluate    ${OVERALL_DL}*4
    ...    ELSE    Run Keyword If    '${tc_name}' == 'SA_1_UE_3CC'
    ...    Set Variable    ${OVERALL_DL}
    ...    ELSE    Run Keyword If    '${tc_name}' == '144UEDL'
    ...    Evaluate    ${OVERALL_DL}*2
    ...    ELSE    Run Keyword If    '${tc_name}' == '432UEDL_BF'
    ...    Evaluate    ${OVERALL_DL}
    ...    ELSE    Run Keyword If    '${tc_name}' == '${tc_name}' == 'CB008360_2UES'
    ...    Evaluate    ${OVERALL_UL}
    ...    ELSE    Run Keyword If    '${tc_name}' == '1208FF_GBR' or '${tc_name}' == 'FDD_432UE_DL' or '${tc_name}' == 'FDD_SA_72UE_DL'
    ...    Evaluate    ${OVERALL_DL}
    ...    ELSE    Run Keyword If    '${tc_name}' == '1070FF_GBR' or '${tc_name}' == 'FDD_432UE_UL' or '${tc_name}' == 'FDD_SA_30UE_UL'
    ...    Evaluate    ${OVERALL_UL}
    ...    ELSE    Run Keyword If    '${tc_name}' == 'CB008406FF_432UES'
    ...    Set Variable    ${OVERALL_UL_TPUT_${tc_name}}
    ...    ELSE    Run Keyword If    '${tc_name}' == 'CB008701_4UES' or '${tc_name}' == 'CB008701_72UES'
    ...    Set Variable    ${OVERALL_DL}
    ${tput}=    Convert To Number    ${tput}    2
    ${NonDSS_CA}=    Catenate    '${tc_name}' == 'SA_4_UE' or '${tc_name}' == 'NSA_4_UE' or
    ...    '${tc_name}' == 'FDD_SA_72UE_DL' or '${tc_name}' == '144UEDL' or '${perf_mue}' == 'True'
    ${dl_limit}=    Set Variable If    ${NonDSS_CA} or '${PET_FDD}' == 'True'
    ...    0.90    ${dl_limit}
    ${ul_limit}=    Set Variable If    ${NonDSS_CA} or '${PET_FDD}' == 'True'
    ...    0.90    ${ul_limit}
    ${tput_limit}=    Set Variable If    '${dir}' == 'ul'    ${ul_limit}    ${dl_limit}
    ${tput_status}=    Evaluate    ${tput} >= (${overall_data_rate}*${tput_limit})
    Run Keyword If    '${tc_name}' != 'SA20' and '${tc_name}' not in "@{IWF_TAGS}"
    ...    Write Test case Details in properties file    ${tc_name}
    ...    ${dir}    ${tput}    ${overall_data_rate}
    ...    ELSE    Run Keyword    Perf Properties File    ${tc_name}    ${tput}    0

    Log To Console    AVG Data Rate SA ${tput}

    ${status}    Run Keyword And Ignore Error   Should Be True    '${tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Log To Console    Traffic Status ${status[0]}
    Append To List    ${pm_counter_status}    ${status[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Intermediate Traffic Validation
    [Arguments]    ${tc_name}    ${tput}    ${dir}
    ${pm_counter_status}=    Create List
    Set Suite Variable    @{pm_counter_status}
    ${overall_data_rate}=    Run Keyword If    '${dir}' == 'dl' and '${tc_name}' != '40UEDL' and '${tc_name}' != '40UEDL3CC'
    ...    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}
    ...    ELSE    Run Keyword If    '${dir}' == 'ul' and '${tc_name}' not in "@{UL_TAGS}"
    ...    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}
    ...    ELSE    Run Keyword If    '${tc_name}' == '1UEUL'    Set Variable    440
    ...    ELSE    Run Keyword If    '${tc_name}' == '72UEUL'
    ...    Evaluate    ${OVERALL_UL}*72/float(1000)
    ...    ELSE    Run Keyword If    '${tc_name}' == '40UEDL'
    ...    Evaluate    ${OVERALL_DL}*40
    ...    ELSE    Run Keyword If    '${tc_name}' == '40UEDL3CC'
    ...    Evaluate    ${OVERALL_DL}*40
    ...    ELSE    Run Keyword If    '${tc_name}' == '144UEDL'
    ...    Evaluate    ${OVERALL_DL}*2
    ...    ELSE    Run Keyword If    '${tc_name}' == '432UEDL_BF'
    ...    Evaluate    ${OVERALL_DL}
    ${tput}=    Convert To Number    ${tput}    2
    ${dl_limit}=    Run Keyword If    '${tc_name}' == '144UEDL' or '${perf_mue}' == 'True'   Set Variable    0.90
    ...    ELSE    Set Variable    ${dl_limit}
    ${expected_data}=    Evaluate    (${overall_data_rate}*${dl_limit})
    ${tput_status}=    Evaluate    ${tput} >= (${expected_data})
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    Log To Console    [${hr}:${min}:${sec}]:Expected Data SA Rate ${expected_data}
    Log To Console    [${hr}:${min}:${sec}]:AVG Data Rate SA ${tput}
    Log To Console    [${hr}:${min}:${sec}]:Traffic Status ${tput_status}
    Append To List    ${pm_counter_status}    ${tput_status}
    ${fail_count}=    Get Match Count    ${pm_counter_status}    regexp=False.*
    ${traffic_status}    Run Keyword If    ${fail_count} > 3    Set Variable    False
    ...    ELSE    Set Variable    True
    Should Not Contain    ${traffic_status}    False    msg=Traffic failed in Throughput, see error above!

Validate Traffic DLUL
    [Arguments]    ${tc_name}    ${dl_tput}    ${ul_tput}
    ${pm_counter_status}=    Create List
    Set Suite Variable    @{pm_counter_status}
    ${overall_dl_data}=    Run Keyword If    '${tc_name}' == '3000UEDLUL'
    ...    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}/float(1000)
    ...    ELSE    Run Keyword If    '${tc_name}' == 'SA304UE' or '${tc_name}' == 'SA500UE'   Evaluate
    ...    (${OVERALL_DL}*${NO_OF_CELL_LO})
    ...    ELSE    Run Keyword If    '${tc_name}' == '1070FF_VoNR_CDRx_Disabled'
    ...    Set Variable    ${OVERALL_DL_TPUT_${tc_name}}
    ...    ELSE    Run Keyword If    '${IWF_ENABLED}' == 'True' or '${perf_mue}' == 'True' or '${PET_FDD}' == 'True'
    ...    Set Variable    ${OVERALL_DL}
    ...    ELSE    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}
    ${overall_ul_data}=    Run Keyword If    '${tc_name}' == '3000UEDLUL'
    ...    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}/float(1000)
    ...    ELSE    Run Keyword If    '${tc_name}' == 'SA304UE' or '${tc_name}' == 'SA500UE'    Evaluate
    ...    (${OVERALL_UL}*${NO_OF_CELL_LO})
    ...    ELSE    Run Keyword If    '${tc_name}' == '1070FF_VoNR_CDRx_Disabled'
    ...    Set Variable    ${OVERALL_UL_TPUT_${tc_name}}
    ...    ELSE    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${tc_name}' != 'SA500UE' or '${perf_mue}' == 'True' or '${PET_FDD}' == 'True'
    ...    Set Variable    ${OVERALL_UL}
    ...    ELSE    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}
    ${dl_tput}=    Convert To Number    ${dl_tput}    2
    ${ul_tput}=    Convert To Number    ${ul_tput}    2
    ${dl_limit}=    Run Keyword If    ('${IWF_ENABLED}' == 'True') or ('${perf_mue}' == 'True') or ('${PET_FDD}' == 'True')
    ...    Set Variable    0.90
    ...    ELSE    Set Variable    ${dl_limit}
    ${ul_limit}=    Run Keyword If    ('${IWF_ENABLED}' == 'True') or ('${perf_mue}' == 'True') or ('${PET_FDD}' == 'True')
    ...    Set Variable    0.90
    ...    ELSE    Set Variable    ${ul_limit}
    ${tput_dl_status}=    Evaluate    ${dl_tput} >= (${overall_dl_data}*${dl_limit})
    ${tput_ul_status}=    Evaluate    ${ul_tput} >= (${overall_ul_data}*${ul_limit})

    ${SKIP_Properties}=    Catenate     '${tc_name}' != 'SA304UE' and '${tc_name}' != 'SA608UE' and '${tc_name}' != 'SANSA_72_UE' and
    ...    '${tc_name}' != '1070FF_MIXEDGBR' and '${tc_name}' != '1070FF_VoNR_CDRx_Disabled'
    ${SKIP_Perf_Properties}=    Catenate    '${tc_name}' != 'SANSA_72_UE' and '${tc_name}' != '1070FF_MIXEDGBR' and
    ...    '${tc_name}' != '1070FF_VoNR_CDRx_Disabled' and '${tc_name}' != 'MUE_FullABIO' and
    ...    '${tc_name}' != '72UE2CELL'
    Run Keyword If    ${SKIP_Properties}
    ...    Write Test case Details in properties file DLUL
    ...    ${tc_name}    ${dl_tput}    ${ul_tput}    ${overall_dl_data}    ${overall_ul_data}
    ...    ELSE IF    ${SKIP_Perf_Properties}    Run Keyword
    ...    Perf Properties File    ${tc_name}    ${dl_tput}    ${ul_tput}
    ...    ELSE IF    '${tc_name}' == '1070FF_MIXEDGBR'    PET Test Properties    ${tc_name}    ${dl_tput}    ${ul_tput}

    Log To Console    AVG Data Rate SA DL ${dl_tput}
    Log To Console    AVG Data Rate SA UL ${ul_tput}

    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${tput_dl_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_dl[0]}
    Log To Console    DL Traffic Status ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${tput_ul_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_ul[0]}
    Log To Console    UL Traffic Status ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Perf Properties File
    [Arguments]    ${tc_name}    ${dl_tput}    ${ul_tput}
    Append To File     ${test_property_file}    ${\n}${tc_name}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}${tc_name}_UL=${ul_tput}${\n}

Intermediate Traffic Validation DLUL
    [Arguments]    ${tc_name}    ${dl_tput}    ${ul_tput}
    ${pm_counter_dl_status}=    Create List
    Set Suite Variable    @{pm_counter_dl_status}
    ${pm_counter_ul_status}=    Create List
    Set Suite Variable    @{pm_counter_ul_status}
    ${overall_dl_data}=    Run Keyword If    '${tc_name}' == '3000UEDLUL'
    ...    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}/float(1000)
    ...    ELSE    Evaluate    ${OVERALL_DL}*${NO_OF_CELL_LOOO}
    ${overall_ul_data}=    Run Keyword If    '${tc_name}' == '3000UEDLUL'
    ...    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}/float(1000)
    ...    ELSE    Evaluate    ${OVERALL_UL}*${NO_OF_CELL_LOOO}
    ${dl_tput}=    Convert To Number    ${dl_tput}    2
    ${ul_tput}=    Convert To Number    ${ul_tput}    2
    ${expected_dl}=    Evaluate    (${overall_dl_data}*${dl_limit})
    ${expected_ul}=    Evaluate    (${overall_ul_data}*${dl_limit})
    ${tput_dl_status}=    Evaluate    ${dl_tput} >= (${expected_dl})
    ${tput_ul_status}=    Evaluate    ${ul_tput} >= (${expected_ul})
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    Log To Console    [${hr}:${min}:${sec}]:Expected SA DL Rate ${expected_dl}
    Log To Console    [${hr}:${min}:${sec}]:AVG Data Rate SA DL ${dl_tput}
    Log To Console    [${hr}:${min}:${sec}]:DL Traffic Status ${tput_dl_status}
    Log To Console    [${hr}:${min}:${sec}]:Expected SA UL Rate ${expected_ul}
    Log To Console    [${hr}:${min}:${sec}]:AVG Data Rate SA UL ${ul_tput}
    Log To Console    [${hr}:${min}:${sec}]:UL Traffic Status ${tput_ul_status}
    Append To List    ${pm_counter_dl_status}    ${tput_dl_status}
    Append To List    ${pm_counter_ul_status}    ${tput_ul_status}
    ${fail_dl_count}=    Get Match Count    ${pm_counter_dl_status}    regexp=False.*
    ${traffic_dl_status}    Run Keyword If    ${fail_dl_count} > 3    Set Variable    False
    ...    ELSE    Set Variable    True
    Should Not Contain    ${traffic_dl_status}    False    msg=Traffic failed in Throughput, see error above!
    ${fail_ul_count}=    Get Match Count    ${pm_counter_ul_status}    regexp=False.*
    ${traffic_ul_status}    Run Keyword If    ${fail_ul_count} > 3    Set Variable    False
    ...    ELSE    Set Variable    True
    Should Not Contain    ${traffic_ul_status}    False    msg=Traffic failed in Throughput, see error above!

Register and Traffic
    [Arguments]    ${dictionary_name}    ${TRF_DURATION}    ${dir}    ${tag_name}
    Run Keyword And Ignore Error    Set WTS Default Log Level to VIP Level
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${tag_name}' == 'SA304UE'
    ...    Initial Setup for PET Test Cases    ${tag_name}
    Run Keyword If    '${tag_name}' != 'SA304UE' and '${tag_name}' != 'SA608UE' and '${tag_name}' != '3000UEDLUL'
    ...    Initial Setup for PET Test Cases    ${tag_name}
    Run Keyword If    '${tag_name}' == 'SA608UE'    Set Suite Variable    ${tag_name}
    Run Keyword If    '${tag_name}' == '144UEDL'    Set Beam info for MIMO
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    wtsrunner.sim_debug_log    gate=1    level=0
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    Run Keyword If    '${tag_name}' == '3000UEDLUL'    Set Amf to register MUE
    Run Keyword If    '${tag_name}' == 'SA304UE' and '${tag_name}' != 'SA608UE' and '${IWF_ENABLED}' != 'True'
    ...    Set Amf to register MUE With start UE    ${amf_list[0]}    ${amf_list[1]}    ${mnc_mcc_plmn}
    ...    ${END_UE}    ${FIRST_UE}
    Run Keyword If    '${tag_name}' == 'SA20'    Set Amf to register MUE    1    2    ${mnc_mcc_plmn}    ${END_UE}
    ...    ${FIRST_UE}
    ${parameters}=    Catenate    SEPARATOR=,    ${FIRST_UE}    ${END_UE}    ${PDU_ID}    ${QFI_ID}    ${TRF_ID}
    ...    ${UL_RATE}    ${DL_RATE}    ${TRF_DIR}    ${DELAY_BTW_PDU_TRAFFIC}
    ...    ${TRF_TYPE}    ${PACKET_SIZE}
    Run Keyword If    '${tag_name}' == '3000UEDLUL'    Parameters Update for MUE Parallel
    ...    ELSE IF    '${tag_name}' == '144UEDL'    Parameters Update for MUMIMO
    ...    ELSE    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=${LUA_METHOD}(${parameters})
    Run Keyword If    '${tag_name}' == '3000UEDLUL'    Validation of UE Register Parallel
    ...    ELSE IF    '${tag_name}' == '144UEDL'    Validation of UE Register Parallel
    ...    ELSE    Validation of UE Resgiter
    Run Keyword If    '${tag_name}' == '40UEDL'    Display stats    1
    Run Keyword If    '${tag_name}' == '40UEDL3CC'    Display stats    2
    Run Keyword If    '${tag_name}' == 'SA20'    Display stats    1
    ${sa_ue_id_list}=    Create List
    Set Suite Variable    @{sa_ue_id_list}
    ${sa_ue_id_list}=    Run Keyword    UE List creation    ${FIRST_UE}    ${END_UE}
    FOR    ${count}    IN RANGE    1    ${TRF_DURATION}+1    1
        Sleep    1m
        Check UE Activity for SA    ${sa_ue_id_list}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
        ${mod_value}    Check Modulo    ${count}
        Run Keyword If    '${mod_value}' == '0' and ('${tag_name}' != 'SA304UE' and '${Perf_Testsuite}' != 'True' and '${tag_name}' != 'SA_20_UE_2CC')
        ...    Check Tput    ${dir}    ${tag_name}
    END
    Check UE Activity for SA    ${sa_ue_id_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    wtsrunner.script_stop
    Stop Traffic for SA MultiUE Perf and Validate Throughput    ${sa_ue_id_list}

AP Cell Setup should be Successful for PET
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    cell ${cell_id + 1}: ${sib_decoding_pattern_pet}
        Check Pattern in Egate Console Log    ${validation_string}
    END
    sleep              5s
    Log                cell_setup_is_ok

Cell Setup Validation from egate Console
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep              100s
    wtsrunner.script_stop
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Catenate    cell ${cell_id + 1}: ${mib_pattern_iwf}
        Check Pattern in Egate Console Log    ${validation_string}
    END
    sleep              5s
    Log                cell_setup_is_ok

AP Cell Setup should be Successful for MIMO
    FOR   ${cell_id}   IN RANGE    1    4    1
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    cell ${cell_id}: ${sib_decoding_pattern_pet}
        Check Pattern in Egate Console Log    ${validation_string}
    END
    sleep              5s
    Log                cell_setup_is_ok

Display stats
    [Arguments]    ${end_cell}    ${file}=${run_script_log_set}
    Sleep    5s
    Check Pattern in Egate Console Log    ${traffic_validation}
    Sleep    5s
    wtsrunner.ue_stats_nr    id=${FIRST_UE}-${END_UE}    scell=0-${end_cell}
    ...    type=pdsch
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Sleep    5s

UE Deregister should be Successful for 1208FF NonBF 4x4 MIMO CA Intra Loki 40UEs
    UE Deregister for SA MUE    ${sa_ue_id_list}

Check Modulo
    [Arguments]    ${count}
    ${mod}=    Evaluate    (${count}%5)
    [Return]    ${mod}

Check Tput
    [Arguments]    ${traffic_dir}    ${test_tag}
    ${achieved_dl_tput}    Run Keyword If    '${traffic_dir}' == 'dl'
    ...    Validate Perf Tput via gNB counter for PET    ${traffic_dir}    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul_tput}    Run Keyword If    '${traffic_dir}' == 'ul'
    ...    Validate Perf Tput via gNB counter for PET    ${traffic_dir}    ${SA_UL_TPUT_COUNTER}
    ${achieved_tput_dl}    Run Keyword If    '${traffic_dir}' == 'both'
    ...    Validate Perf Tput via gNB counter for PET    ${traffic_dir}    ${SA_DL_TPUT_COUNTER}
    ${achieved_tput_ul}    Run Keyword If    '${traffic_dir}' == 'both'
    ...    Validate Perf Tput via gNB counter for PET    ${traffic_dir}    ${SA_UL_TPUT_COUNTER}
    Run Keyword If    '${traffic_dir}' == 'dl'
    ...    Intermediate Traffic Validation    ${test_tag}    ${achieved_dl_tput}    ${traffic_dir}
    Run Keyword If    '${traffic_dir}' == 'ul'
    ...    Intermediate Traffic Validation    ${test_tag}    ${achieved_ul_tput}    ${traffic_dir}
    Run Keyword If    '${traffic_dir}' == 'both'
    ...    Intermediate Traffic Validation DLUL    ${test_tag}
    ...    ${achieved_tput_dl}    ${achieved_tput_ul}

Initial Setup for PET Test Cases
    [Arguments]    ${tag_name}
    Kill Deleted Process
    Stop Edaemon Egate
    Commission the scf    ${tag_name}
    Set Suite Variable    ${test_label}    ${tag_name}
    ${TAG_CONDITION}=    Catenate    '${tag_name}' == '40UEDL3CC' or '${tag_name}' == 'SA20' or
    ...    '${perf_mue}' == 'True' or '${IWF_FDD_CA_DSS}' == 'True' or '${tag_name}' == 'NSA_10UEs'
    ...    or 'IWF_TDD_ECPRI72E' == 'True' or '${tag_name}' == 'SA_NSA_SUE_2CELL'
    Run Keyword If    ${TAG_CONDITION}    Update Iphy File    ${tag_name}
    Bringup Perf Setup After Commissioning    ${tag_name}
    Run Keyword If    '${IWF_FDD_CA_DSS}' == 'False'    Check Status till Cell Setup    ${tag_name}

Write Test case Details in properties file
    [Arguments]    ${tc_name}    ${dir}    ${tput}    ${t_tput}
    ${ue_data}=    Set Variable    ${active_ues_total}/${END_UE}
    Run Keyword If    '${dir}' == 'dl'
    ...    Append To File     ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${ue_data}", "DL_RATE":"${tput}Mbps/${t_tput}Mbps"}}${\n}
    Run Keyword If    '${dir}' == 'ul'
    ...    Append To File     ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${ue_data}", "UL_RATE":"${tput}Mbps/${t_tput}Mbps"}}${\n}

Write Test case Details in properties file DLUL
    [Arguments]    ${tc_name}    ${dl_rate}    ${ul_rate}    ${tdl_tput}    ${tul_tput}
    ${UE_DATA}=    Set Variable    "Active Number of UEs":"${active_ues_total}/${END_UE}"
    ${DL_DATA}=    Set Variable    ${dl_rate}Mbps/${tdl_tput}Mbps
    ${UL_DATA}=    Set Variable    ${ul_rate}Mbps/${tul_tput}Mbps
    ${DL}=    Set Variable    DL_RATE
    ${UL}=    Set Variable    UL_RATE
    Run    sed -i '$ a\\${tc_name}_TEST_RESULTS={"s1-t1":{${UE_DATA}, "${DL}":"${DL_DATA}", "${UL}":"${UL_DATA}" }}' ${test_property_file}

Check Proxy Strings
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    ${proxy_estblishment}    ${cell_id + 1}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
        Log To Console    Pattern Status: ${status}
    END

Check RRC Connected UES
    [Arguments]    ${ue_count}    ${num}
    ${ue_status}=    Evaluate    (${ue_count}) > (${num}*0.995)
    Should Be Equal    '${ue_status}'    'True'    msg=Active UEs are less than expected

Check Connected UES
    [Arguments]    ${ue_count}
    Run Keyword If    '${ue_count}' == '0'    Fail    msg=No of Active UEs are zero

Set Amf to register MUE
    [Arguments]    ${start_amf}=${start_amf}    ${end_amf}=${end_amf}    ${mnc_mcc}=${mnc_mcc}    ${max_ues}=${max_ues}
    ...    ${start_ue}=${FIRST_UE}
    ${parameters}=    Catenate    SEPARATOR=,    ${start_amf}    ${end_amf}    ${mnc_mcc}    ${max_ues}    ${start_ue}
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=set_amf_to_register_multiue(${parameters})
    Sleep    1m
    wtsrunner.script_stop
    Check Pattern in Egate Console Log    ${amf_register_mue}

Set Amf to register MUE With start UE
    [Arguments]    ${start_amf}    ${end_amf}    ${mnc_mcc}    ${max_ues}    ${start_ue}
    ${parameters}=    Catenate    SEPARATOR=,    ${start_amf}    ${end_amf}    ${mnc_mcc}    ${max_ues}    ${start_ue}
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=set_amf_to_register_multiue(${parameters})
    Sleep    5s
    wtsrunner.script_stop
    Sleep    5s
    Check Pattern in Egate Console Log    ${amf_register_mue}

Set Amf to register Single UE
    [Arguments]    ${mnc_mcc}
    FOR    ${amf_id}    ${ue_id}    IN ZIP    ${amf_list}    ${sa_ueids_multicell}
        ${parameters}=    Catenate    SEPARATOR=,    ${amf_id}    ${mnc_mcc}    ${ue_id}
        wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=set_amf_to_register_single_ue(${parameters})
        Sleep    5s
    END
    Check Pattern in Egate Console Log    ${amf_register_mue}

Parameters Update for MUE Parallel
    ${parameters}=    Catenate    SEPARATOR=,    ${FIRST_UE}    ${END_UE}    ${CELLS}    ${PDU_ID}    ${QFI_ID}
    ...    ${TRF_ID}
    ...    ${RATE}    ${UL_RATE}    ${DL_RATE}    ${TRF_DIR}    ${DELAY_BTW_PDU_TRAFFIC}
    ...    ${TRF_TYPE}    ${PACKET_SIZE}    ${RETRY}    ${SRB_INACTIVITY_TIMER}
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=${LUA_METHOD}(${parameters})

Parameters Update for MUMIMO
     ${parameters}=    Catenate    SEPARATOR=,    ${FIRST_UE}    ${END_UE}    ${PDU_ID}    ${QFI_ID}
    ...    ${TRF_ID}    ${RATE}
    ...    ${UL_RATE}    ${DL_RATE}    ${TRF_DIR}    ${DELAY_BTW_PDU_TRAFFIC}
    ...    ${TRF_TYPE}    ${PACKET_SIZE}    ${RETRY}    ${SRB_INACTIVITY_TIMER}
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=${LUA_METHOD}(${parameters})

Validation of UE Register Parallel
    FOR   ${ueid}   IN RANGE    ${FIRST_UE}    ${END_UE}+1    ${skip_ues}
        ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
        Log To Console    Validation String: ${validation_string}
        ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
        ...    expected=${validation_string}     timeout=5
        Log To Console    Pattern Status: ${status}
        Run Keyword and Ignore Error    Read WTS Output For Pattern And Print matching Lines
        ...    ${ue_register_complete}    5
    END

Script Stop and Check Pattern
    Sleep    480s
    wtsrunner.script_stop
    Check Pattern in Egate Console Log    ${ue_register_complete}

Validation of UE Resgiter
    Sleep    10s
    FOR   ${ueid}   IN RANGE    ${FIRST_UE}    ${END_UE}+1    1
        ${validation_string}=    Catenate    UE${ueid}:     ${ue_registeration_completion}
        ${output}    Read WTS Output Until Pattern Matches    ${validation_string}    ${Timeout_SA}
        Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
        ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
        Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    END

Lua deregister
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=multiue_retry_dereg(${FIRST_UE},${END_UE},0.1)
    Read WTS Output For Pattern And Print matching Lines    ${mue_deregister_complete}
    ...    ${Timeout_Fdd_Perf}

SA Register and Traffic for 1208FF Non BF 4x4 CA Intra Loki 20UEs
    ${TRF_DURATION}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    Register and Traffic
    ...    ${SA_20UE_DL}    ${TRF_DURATION}    dl    SA20
    ${achieved_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${SA_DL_TPUT_COUNTER}
    Log To Console    Achieved DL tput: ${achieved_tput}
    Run Keyword And Continue On Failure    Validate Traffic    SA20    ${achieved_tput}    dl

UE Deregister should be Successful for 1208FF NonBF 4x4 MIMO CA Intra Loki 20UEs
    UE Deregister for SA MUE    ${sa_ue_id_list}

Update Iphy File
    [Arguments]    ${wft_label_fr1}
    ${command}    Catenate    mkdir    -p ${local_path}
    Run    ${command}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Download File    ${remote_path}/iphy.xml    ${local_path}/iphy.xml    ${AP_ASIK.Connection}
    ${command}        Catenate     python3 ${config_reader} ${local_path}/iphy.xml
    ...    ${wft_label_fr1}
    Run    ${command}
    Sleep    2s
    SSH.Upload File    ${local_path}/iphy.xml    /user/toor4nsn/updated_iphy.xml    ${AP_ASIK.Connection}
    SSH.Send Command    scp /user/toor4nsn/updated_iphy.xml /ffs/run/simmode; ln -f -s /ffs/run/simmode/updated_iphy.xml /ffs/run/simmode/iphy.xml
    ...    timeout=60    connection=${AP_ASIK.Connection}

Update Wts File
    [Arguments]    ${wft_label_fr1}
    ${scf_file_path}=    Set Variable    ${EXECDIR}/robotws/testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/scf_param_update.py
    ${wts_file_path}=    Set Variable    ${EXECDIR}/custom_configs/wts/basic.cfg
    ${command}        Catenate     python3 ${scf_file_path} ${wts_file_path}
    ...    ${wft_label_fr1}
    Run    ${command}
    Sleep    2s

Test Case teardown
    Run Keyword And Ignore Error    Collect gnb PM Counter Logs
    Run Keyword And Ignore Error    Collect IWF fsyslog
    Run Keyword And Ignore Error    Collect UTE Perf Logs
    Run Keyword And Ignore Error    Store Logs

Store Logs
    Run    mkdir ${EXECDIR}/logs_and_config_files
    Run    cp ${WTS_DIR}/egate_console.log ${EXECDIR}/logs/
    Run    zip -r FR1_PERF.zip logs/
    Run    mv ${EXECDIR}/FR1_PERF.zip ${EXECDIR}/logs/FR1_PERF.zip

Copy CA Lua file
    [Arguments]    ${wts_cfg_file}
    ${file_path}   ${filenames}=    Split Path     ${wts_cfg_file}
    Log To Console    Filepath: ${file_path}
    ${file_name}   ${extention}=    Split Extension     ${filenames}
    Log To Console    File extension: ${extention}
    ${file}        Catenate     SEPARATOR=.   ${file_name}   lua
    ${wts_cfg_file}=    Run Keyword If    '${test_label}' == 'SA20'
    ...    Set Variable    ${20UEDL_lua}
    ...    ELSE IF    '${test_label}' == '144UEDL'
    ...    Set Variable    ${144UEDL_lua}
    ...    ELSE IF    '${Fdd_Perf}' == 'True' and '${test_label}' != 'SA608UE'
    ...    Set Variable    ${Fdd_Perf_Lua}
    Run    cp ${wts_cfg_file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    CFG file: ${SUITE_WTS_CFG}
    Run Keyword If    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}'!='1'    Update Fdd Perf UE ids list    ${FDD_UE_IDS}
    ...    ELSE IF    '${Fdd_Perf}' == 'True' and '${FDD_IWF_multicell}'=='1'    Update Fdd IWF UE ids list    ${FDD_IWF_UE_IDS}

Check Proxy Strings IWF
    FOR   ${cell_id}   IN RANGE   1    4    2
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    ${proxy_estblishment}    ${cell_id}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
    END

Generate perf lua file from basic cfg file
    [Arguments]    ${wts_cfg_file}    ${lua_generator}
    ${sa_first_cell1}    Get Variable Value    ${SA_CELL1_FIRST}    ${SA_CELL1_FIRST_DEFAULT}
    ${sa_end_cell1}    Get Variable Value   ${SA_CELL1_FIRST}    ${SA_CELL1_END_DEFAULT}
    ${nsa_first_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    ${NSA_CELL1_FIRST_DEFAULT}
    ${nsa_end_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    ${NSA_CELL1_END_DEFAULT}
    ${sa_first_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    ${SA_CELL2_FIRST_DEFAULT}
    ${sa_end_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    ${SA_CELL2_END_DEFAULT}
    ${nsa_first_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    ${NSA_CELL2_FIRST_DEFAULT}
    ${nsa_end_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    ${NSA_CELL2_END_DEFAULT}
    ${command}        Catenate     python ${lua_generator}
    ...    -cfg ${wts_cfg_file}    -first_sa_cell1 ${sa_first_cell1}    -end_sa_cell1 ${sa_end_cell1}
    ...    -first_nsa_cell1 ${nsa_first_cell1}    -end_nsa_cell1 ${nsa_end_cell1}
    ...    -first_sa_cell2 ${sa_first_cell2}    -end_sa_cell2 ${sa_end_cell2}
    ...    -first_nsa_cell2 ${nsa_first_cell2}    -end_nsa_cell2 ${nsa_end_cell2}
    Log    ${command}
    Run    ${command}
    ${file_path}   ${filenames}=    Split Path     ${wts_cfg_file}
    Log To Console    File path: ${file_path}
    ${file_name}   ${extention}=    Split Extension     ${filenames}
    Log To Console    File extension: ${extention}
    ${file}        Catenate     SEPARATOR=.   ${file_name}   lua
    File Should Exist    ${file}
    ...    msg='Ap P1Perf lua file doesn't exists at path ${file}
    Run    cp ${file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    CFG file: ${SUITE_WTS_CFG}
    Run Keyword    Update Perf UE ids list    ${sa_first_cell1}    ${sa_end_cell1}    ${nsa_first_cell1}
    ...    ${nsa_end_cell1}    ${sa_first_cell2}    ${sa_end_cell2}    ${nsa_first_cell2}    ${nsa_end_cell2}

Set UE ids for Perf
    ${sa_first_cell1}    Get Variable Value    ${SA_CELL1_FIRST}    ${SA_CELL1_FIRST_DEFAULT}
    ${sa_end_cell1}    Get Variable Value   ${SA_CELL1_FIRST}    ${SA_CELL1_END_DEFAULT}
    ${nsa_first_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    ${NSA_CELL1_FIRST_DEFAULT}
    ${nsa_end_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    ${NSA_CELL1_END_DEFAULT}
    ${sa_first_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    ${SA_CELL2_FIRST_DEFAULT}
    ${sa_end_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    ${SA_CELL2_END_DEFAULT}
    ${nsa_first_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    ${NSA_CELL2_FIRST_DEFAULT}
    ${nsa_end_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    ${NSA_CELL2_END_DEFAULT}
    Run Keyword    Update Perf UE ids list    ${sa_first_cell1}    ${sa_end_cell1}    ${nsa_first_cell1}
    ...    ${nsa_end_cell1}    ${sa_first_cell2}    ${sa_end_cell2}    ${nsa_first_cell2}    ${nsa_end_cell2}

Update Perf UE ids list
    [Arguments]    ${sa_first_cell1}    ${sa_end_cell1}    ${nsa_first_cell1}
    ...    ${nsa_end_cell1}    ${sa_first_cell2}    ${sa_end_cell2}    ${nsa_first_cell2}    ${nsa_end_cell2}
    @{sa_ueids_cell1}=    Create List
    @{nsa_ueids_cell1}=    Create List
    @{sa_ueids_cell2}=    Create List
    @{nsa_ueids_cell2}=    Create List
    @{targetCellsIds}=    Create List


    FOR    ${ueid}    IN RANGE      ${sa_first_cell1}    ${sa_end_cell1}+1    1
        Append To List    ${sa_ueids_cell1}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${sa_first_cell2}    ${sa_end_cell2}+1     1
        Append To List    ${sa_ueids_cell2}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${nsa_first_cell1}    ${nsa_end_cell1}+1    1
        Append To List    ${nsa_ueids_cell1}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${nsa_first_cell2}    ${nsa_end_cell2}+1    1
        Append To List    ${nsa_ueids_cell2}    ${ueid}
    END

    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetCellsIds}   ${value+1}
    END

    Set Suite Variable    @{sa_ueids_cell1}
    Set Suite Variable    @{nsa_ueids_cell1}
    Set Suite Variable    @{sa_ueids_cell2}
    Set Suite Variable    @{nsa_ueids_cell2}
    Set Suite Variable    @{targetCellsIds}

Generate mmwv perf lua file from basic cfg file
    [Arguments]    ${wts_cfg_file}
    ${command}        Catenate     python ${lua_generator_mmwv_script}
    ...    -cfg ${wts_cfg_file}
    Log    ${command}
    Run    ${command}
    ${file_path}   ${filename}=    Split Path     ${wts_cfg_file}
    Log To Console    File Path: ${file_path}
    ${name}   ${extention}=    Split Extension     ${filename}
    Log To Console    File extension:${extention}
    ${file}        Catenate     SEPARATOR=.   ${name}   lua
    File Should Exist    ${file}
    ...    msg='Ap P1Perf lua file doesn't exists at path ${file}
    Run    cp ${file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    CFg file: ${SUITE_WTS_CFG}
    Update FR2 UE ids list    ${nsa_fr2_first_cell1}    ${nsa_fr2_end_cell1}

Perf Lua file copy
    [Arguments]    ${wts_cfg_file}
    Run Keyword If    '${test_label}' == '144UEDL'
    ...    Copy CA Lua file    ${wts_cfg_file}
    ...    ELSE    Perf Lua file copy Extended    ${wts_cfg_file}

Perf Lua file copy Extended
    [Arguments]    ${wts_cfg_file}
    ${file_path}   ${filenames}=    Split Path     ${wts_cfg_file}
    Log To Console    ${file_path}
    ${file_name}   ${extension}=    Split Extension     ${filenames}
    Log To Console    ${extension}
    ${file}        Catenate     SEPARATOR=.   ${file_name}   lua
    Run    cp ${wts_cfg_file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    ${SUITE_WTS_CFG}

Replace Lua Files for Perf IWF
    [Arguments]    ${wts_cfg_file}
    ${file_path}   ${filenames}=    Split Path     ${wts_cfg_file}
    Log To Console    ${file_path}
    ${file_name}   ${extension}=    Split Extension     ${filenames}
    Log To Console    ${extension}
    ${file}        Catenate     SEPARATOR=.   ${file_name}   lua
    ${wts_cfg_file}=    Run Keyword If    '${test_label}' in "@{IWF_TAGS}"
    ...    Get Lua File    ${test_label}
    Run    cp ${wts_cfg_file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    ${SUITE_WTS_CFG}
    Run Keyword    Update Perf UE ids list    ${SA_CELL1_FIRST_DEFAULT}    ${SA_CELL1_END_DEFAULT}    ${NSA_CELL1_FIRST_DEFAULT}
    ...    ${NSA_CELL1_END_DEFAULT}    ${SA_CELL2_FIRST_DEFAULT}    ${SA_CELL2_END_DEFAULT}    ${NSA_CELL2_FIRST_DEFAULT}
    ...    ${NSA_CELL2_END_DEFAULT}

Get Lua File
    [Arguments]    ${test_label}
    ${lua_file}    Run Keyword If    '${test_label}' == 'NSA_4_MUE'
    ...    Set Variable    ${NSA_4_UE}
    ...    ELSE    Run Keyword If    '${test_label}' == 'SA_1_UE_2CC'
    ...    Set Variable    ${SA_1_UE_2CC}
    ...    ELSE    Run Keyword If    '${test_label}' == 'NSA_1_UE_2CC'
    ...    Set Variable    ${NSA_1_UE_2CC}
    ...    ELSE    Run Keyword If    '${test_label}' == 'SA_4_UE'
    ...    Set Variable    ${SA_4_UE}
    [Return]    ${lua_file}

IWF Test Case teardown
    [Arguments]    ${tc_name}
    Run Keyword And Ignore Error    Collect gnb PM Counter Logs
    Run Keyword And Ignore Error    Collect IWF fsyslog
    Run Keyword And Ignore Error    Collect UTE Perf Logs
    Run Keyword And Ignore Error    Collect UTE SosReport
    Run Keyword And Ignore Error    Store IWF Logs    ${tc_name}
    Run Keyword And Ignore Error    Kill Strace Process
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'
    ...    Stop sosReport Tcpdump    init    0

Store IWF Logs
    [Arguments]    ${tc_name}
    Run    mkdir ${EXECDIR}/logs_and_config_files
    Run    cp ${WTS_DIR}/egate_console.log ${EXECDIR}/logs/
    Run    mv /home/ute/udpsyslog.tar.gz ${EXECDIR}/logs/
    Run    tar -czvf ${EXECDIR}/logs_and_config_files/${tc_name}.tar.gz ${EXECDIR}/logs/*

Enable IWF Prechecks
    Log to console    Activating IWF MODe...
    Run    python3 ${IWF_CONFIG} -il True

Enable IWF After Egate Reset
    Run Keyword If    '${IWF_FDD_CA_DSS}' == 'True'
    ...    Run    python3 ${IWF_CONFIG} --enable_strace ${enable_strace} --enable_dss 'True'
    ...    ELSE
    ...    Run    python3 ${IWF_CONFIG} --enable_strace ${enable_strace}
    Check IWF Status

Validate IWF Mode
    Log to console    Checking If IWF Mode Enabled..
    Wait Until Keyword Succeeds    2.5 min    15 sec    Verify Core Entities With IWF

Verify Core Entities With IWF
    FOR    ${exp_string}    IN    @{IWF_Strings}
        wtsrunner.read_wtsemu_output_until_re    expected=${exp_string}    timeout=2
    END

Check IWF Status
    Run    ps -C iwf
    ${iwf_pid}=    Run    pidof iwf
    Log To Console    IWF Process id is ${iwf_pid}
    Run    sudo -i | cat /proc/meminfo | grep Huge
    Should Not Be Empty    ${iwf_pid}    msg=IWF process is not active

NSA SUE Attach and DL Traffic for 1127FF NonBF 4CC CA
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    wtsrunner.enb_endc_param    id=${cell_index_id}    serving_cell_index_range_scg=${FR2_4CC_cell_index}
    Start NSA Traffic for SUE scenario    ${FR2_4CCDl}    ${FR2_Ul}    ${FR2_UE}    FR2_4CC

NSA SUE Attach DL Traffic for 1127FF NonBF 8CC CA
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    wtsrunner.enb_endc_param    id=${cell_index_id}    serving_cell_index_range_scg=${FR2_8CC_cell_index}
    Start NSA Traffic for SUE scenario    ${FR2_8CCDl}    ${FR2_Ul}    ${FR2_UE}    FR2_8CC

Configure UTE ETH3 FOR FR1_PERF_IWF
    Run    sudo ip addr add 10.0.2.100/24 dev eth4
    Run    sudo ip addr add 10.0.2.101/24 dev eth4
    Run    sudo ip addr add 10.0.2.102/24 dev eth4
    Run    sudo ip addr add 10.0.2.103/24 dev eth4
    Run    sudo ip addr add 10.0.2.14/24 dev eth4

Update scell for NSA CA
    wtsrunner.enb_endc_param    id=1    serving_cell_index_range_scg=8:9

UE SIB Decoding should be Successful Perf
    FOR   ${cell_id}   IN RANGE   1    4    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    cell ${cell_id}:     ${UE_SIB_decoding_pattern}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
    END

Collect Cummulative Logs
    Run    mv ${EXECDIR}/logs_and_config_files ${EXECDIR}/logs/
    Run    mv ${EXECDIR}/em_traces ${EXECDIR}/logs/
    Run    mv ${EXECDIR}/em_perf_Stats ${EXECDIR}/logs/

Testmode enable
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true

Start fsyslog for IWF
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    ${dir_exist_status}=    Run Keyword And Return Status   Directory Should Exist    ${EXECDIR}/logs
    Run Keyword If    '${dir_exist_status}' == 'False'    Run Keywords
    ...    Remove File    ${EXECDIR}/logs    AND     Create Directory     ${EXECDIR}/logs
    Run    rm -rf ${sys_log_directory}
    Run    mkdir -p ${sys_log_directory}
    ${command}          Catenate    ${WTS_DIR}/fsyslog --log-dir=/home/ute/udpsyslog
    ...                 --log-file-name=udpsyslog.log
    Run                 ${command}

Syslog Collection for IWF
    Run Keyword    Collect IWF fsyslog

Collect IWF fsyslog
    Run                 killall fsyslog
    Run Keyword    Check IWF fsyslog
    Run                 tar -cvf /home/ute/udpsyslog.tar.gz /home/ute/udpsyslog/*.log.*
    Run                 mv /home/ute/udpsyslog.tar.gz ${EXECDIR}/logs
    Run Keyword And Ignore Error    Remove Files    /home/ute/udpsyslog/*
    Remove Directory    ${sys_log_directory}    recursive=True

Check IWF fsyslog
    [Arguments]    ${file}=udpsyslog.log.001    ${pattern}=192.168.200.1    ${grepArgs}=grep -i
    File Should Exist    /home/ute/udpsyslog/*.log.*
    ${command}        Catenate    ${grepArgs} '${pattern}' /home/ute/udpsyslog/${file}
    Run    ${command}

Collection of em perf stats and em traces
    [Arguments]    ${count}
    Run Keyword And Ignore Error    Get L2RT container ID
    Run Keyword If    '${count}' == '4' and '${EM_TRACES}' == 'True'   Run Keyword And Ignore Error    Collection of em traces
    ...    ${TEST_NAME}    ${L2RT_container_ID}
    Run Keyword If    '${count}' == '5' and '${EM_PERF_STATS}' == 'True'   Run Keyword And Ignore Error    Collection of em perf Stats
    ...    ${TEST_NAME}    ${L2RT_container}

Attach Multi UE for Multi Cell NSA
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    wtsrunner.enb_endc_param    id=${cell_index_id}    serving_cell_index_range_scg=${FR2_single_cell_index}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ${ul_rate}     Get Variable Value    ${TRF_UL_RATE}     ${ul_datarate_mmwv_mue}
    ${dl_rate}     Get Variable Value    ${TRF_DL_RATE}     ${dl_datarate_mmwv_mue}
    ${nsa_sue_dl_list}=    Create List
    ${nsa_sue_ul_list}=    Create List
    Set Suite Variable    @{nsa_sue_dl_list}
    Set Suite Variable    @{nsa_sue_ul_list}
    Create and Reset NSA List
    wtsrunner.uec_l2_testmode_params    fixed_csi_report=true
    NSA mmwv MUE Attach with lua functions   ${FR2_NSA_MUE_1CELL_ULDL}
    Sleep    100s
    wtsrunner.script_stop
    Check Pattern in Egate Console Log    ${Trf_validation_string}
    NSA mmwv MUE Attach with lua functions   ${FR2_NSA_MUE_2CELL_ULDL}
    ${nsa_mue_id_list}=    Create List
    Set Suite Variable    @{nsa_mue_id_list}
    ${nsa_mue_id_list}=    Run Keyword    UE List creation    ${FR2FirstUE}    ${FR2EndUE}
    UE Connectivity check    ${nsa_mue_id_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    FOR    ${count}    IN RANGE    ${duration}
         Sleep    1m
         UE Connectivity check    ${nsa_mue_id_list}
         Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
         Collect Bearer Stats for NSA MUE    ${nsa_mue_id_list}    ${dl_rate}    ${ul_rate}
         wtsrunner.ue_stats_nr    id=${stats_id_Cell1}    type=${stats_type}    scell=${stats_scell}
         wtsrunner.ue_stats_nr    id=${stats_id_Cell2}    type=${stats_type}    scell=${stats_scell}
         Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    UE Connectivity check    ${nsa_mue_id_list}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    wtsrunner.script_stop
    Stop NSA MUE Traffic    ${nsa_mue_id_list}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_DL_CELL_RLC_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_UL_CELL_RLC_COUNTER}
    Run Keyword and Continue On Failure    Validate Perf NSA SUE Traffic
    ...    ${OVERALL_DL}    ${OVERALL_UL}    1CELL_UE
    ...    ${achieved_nsa_dl_tput[0]}    ${achieved_nsa_ul_tput[0]}
    Run Keyword and Continue On Failure    Validate Perf NSA SUE Traffic
    ...    ${OVERALL_DL}    ${OVERALL_UL}    2CELL_UE
    ...    ${achieved_nsa_dl_tput[1]}    ${achieved_nsa_ul_tput[1]}

NSA mmwv MUE Attach with lua functions
    [Arguments]    ${dictionary_name}
	${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${parameters}=    Catenate    SEPARATOR=,    ${FIRST_UE}    ${END_UE}    ${BEARER_ID}
    ...    ${TARGET_GNB}    ${TARGET_GNB_CELL}     ${UL_RATE}    ${DL_RATE}
    ...    ${UL_PACKET_SIZE}    ${UL_PACKET_SIZE}
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=${LUA_METHOD}(${parameters})

Kill Strace Process
    ${strace_pid}=    Run    pidof strace
    Run    sudo kill ${strace_pid}

Kill IWF Process
    ${iwf_pid}=    Run    pidof iwf
    Run    sudo kill -15 ${iwf_pid}

SA register 2CC 20UE
    SA Register in PET SE Format    ${SA_20_UE_2CC}    SA_20_UE_2CC
    ${achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${SA_DL_TPUT_COUNTER}
	Validate Traffic    SA_20_UE_2CC    ${achieved_dl_tput}    dl

SA Deregister SA 20UE 2CC
    Lua deregister

Start UTE WTS Perf
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Configure UTE ETH3
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    Configure UTE ETH3 FOR FR1_PERF_IWF
    Run Keyword If    '${AP_P1Perf}' == 'True'
    ...    Configure UTE ETH3 FOR FR1_PERF
    Run Keyword If    '${perf_mue}' == 'True' or '${PET_FDD}' == 'True'
    ...    Configure UTE ETH3 FOR MUE PERF
    Run Keyword If    '${IWF_ENABLED}' == 'True'
    ...    Configure UTE ETH3 FOR FR1_PERF_IWF
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Start wts interface stats collection
    Run Keyword If    '${Fdd_Perf}' == 'True'
    ...    Configure UTE ETH3 FOR MUE PERF
    Run Keyword If    '${IWF_ENABLED}' == 'True' or '${perf_mue}' == 'True' or '${PET_FDD}' == 'True'
    ...    Copy Lua file
    Run Keyword If     '${BSR_TEST}' == '1' and '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LOOO_AEQE_1S_1CC_CB008701_4UE'
    ...    Validate Active BSR File    ${bsr_package_CB008701}    ${bsr_package_CB008701_path}
    ...    ELSE IF    '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LOOO_AEQE_1S_1CC_CB008360_2UE'
    ...    Validate Active BSR File    ${bsr_package_CB008360}    ${bsr_package_CB008360_path}
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True' and '${IWF_ENABLED}' == 'True'
    ...    Start sosReport Tcpdump    init
    Log to Console                 Starting WTS...
    Run Keyword If    "${SKIP_WTS_CONFIG_DOWNLOAD}" == "False"    Download of WTS config Files
    ...    ELSE    Copy CUS MultiUE lua file
    Run Keyword If    '${AP_P1Perf}' == 'True' and '${test_label}' == 'SA20' and "${SKIP_WTS_CONFIG_DOWNLOAD}" == "True"
    ...    Copy CA Lua file    ${WTS_DIR}/basic.lua
    Run Keyword If    '${AP_P1Perf_mmwv}' == 'True' and "${SKIP_WTS_CONFIG_DOWNLOAD}" == "True"
    ...    Update FR2 UE ids list    ${nsa_fr2_first_cell1}    ${nsa_fr2_end_cell1}
    Run Keyword If    '${AP_P1Perf}' == 'True' and "${SKIP_WTS_CONFIG_DOWNLOAD}" == "True"    Set UE ids for Perf
    Run Keyword If    '${Fdd_Perf}' == 'True' and "${SKIP_WTS_CONFIG_DOWNLOAD}" == "True" and '${FDD_IWF_multicell}'!='1'
    ...    Update Fdd Perf UE ids list    ${FDD_UE_IDS}
    ...    ELSE IF    '${FDD_IWF_multicell}'=='1'    Update Fdd IWF UE ids list    ${FDD_IWF_UE_IDS}
    Connect To WTS VM
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Enable IWF After Egate Reset
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    Run Keyword If   '${PET_TDD}' != 'True' and '${PET_FDD}' != 'True'
    ...    Start UTE WTS Perf Extended
    Run Keyword If    '${PET_TDD}' == 'True' or '${PET_FDD}' == 'True'    Cleanup Process and IP flush
    Run Keyword If    '${SYSLOG}' == 'True' or '${IWF_ENABLED}' == 'True'    Start fsyslog for IWF

Start UTE WTS Perf Extended
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${AP_P1Perf}' == 'True'
    ...    Execute Lua in PET SE format
    ...    ELSE IF    '${AP_P1Perf_mmwv}' == 'True' or '${Fdd_Perf}' == 'True'
    ...    Execute Lua
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=${simmode_timeout}
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active
    Run Keyword If    '${Fdd_Perf}' == 'True' or '${AP_P1Perf}' == 'True' or '${AP_P1Perf_mmwv}' == 'True'
    ...    Testmode enable

Copy Lua file
    ${cmd}=    Catenate    cp ${EXECDIR}/custom_configs/${ute_ca_variant}/basic.lua
    ...    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run    ${cmd}
    Set Suite Variable    ${SUITE_WTS_CFG}

SA NSA MUE Register Attach 72Ues
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    Create and Reset SA List
    Create and Reset NSA List
    Run Keyword And Continue on Failure    NSA mmwv MUE Attach with lua functions   ${NSA_72UE_CELL1}
    Run Keyword And Continue on Failure    Validation of UE Attach
    ${nsa_ue_id_list_cell1}=    Create List
    Set Suite Variable    @{nsa_ue_id_list_cell1}
    ${nsa_ue_id_list_cell1}=    Run Keyword    UE List creation    ${FIRST_UE}    ${END_UE}
    Run Keyword And Continue on Failure    NSA mmwv MUE Attach with lua functions   ${NSA_72UE_CELL2}
    Run Keyword And Continue on Failure    Validation of UE Attach
    ${nsa_ue_id_list_cell2}=    Create List
    Set Suite Variable    @{nsa_ue_id_list_cell2}
    ${nsa_ue_id_list_cell2}=    Run Keyword    UE List creation    ${FIRST_UE}    ${END_UE}
    ${total_nsa_ues}=    Combine Lists    ${nsa_ue_id_list_cell1}    ${nsa_ue_id_list_cell2}
    Set Suite Variable    ${total_nsa_ues}
    Get Dictionary Values and register    ${SA_72UE_CELL}    SANSA_72_UE
    Sleep    150s
    Check Active No Of SA UEs for PET SE    SANSA_72_UE
    UE Connectivity check    ${total_nsa_ues}
    FOR    ${count}    IN RANGE    1    ${duration}    1
        Sleep    1m
        Check Active No Of SA UEs for PET SE    SANSA_72_UE
        UE Connectivity check    ${total_nsa_ues}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
        Run Keyword and Ignore Error    Display nr_stats for NSA UE list    ${total_nsa_ues}
    END
    Check Active No Of SA UEs for PET SE    SANSA_72_UE
    UE Connectivity check    ${total_nsa_ues}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    wtsrunner.script_stop
    ${dl_rate}=    Set Variable    ${OVERALL_CELL_DL}
    ${ul_rate}=    Set Variable    ${OVERALL_CELL_UL}
    Stop NSA MUE Traffic    ${total_nsa_ues}
    ${achieved_sa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${SA_UL_CELL_RLC_COUNTER}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_DL_CELL_RLC_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_UL_CELL_RLC_COUNTER}
    FOR    ${i}    IN RANGE    ${target_cells_IWF_FR1}
        Run Keyword and Continue On Failure    Validate SA Traffic for PET_SE_IWF    SA_CELL${i+1}    ${dl_rate}
        ...    ${ul_rate}    ${achieved_sa_dl_tput[${i}]}    ${achieved_sa_ul_tput[${i}]}
        Run Keyword and Continue On Failure    Validate Perf NSA SUE Traffic
        ...    ${dl_rate}    ${ul_rate}    NSA_CELL${i+1}
        ...    ${achieved_nsa_dl_tput[${i}]}    ${achieved_nsa_ul_tput[${i}]}
    END
    ${sa_achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${SA_DL_TPUT_COUNTER}
    ${sa_achieved_ul_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    ul    ${SA_UL_TPUT_COUNTER}
    Run Keyword And Continue On Failure    Validate Traffic DLUL    SANSA_72_UE    ${sa_achieved_dl_tput}
    ...    ${sa_achieved_ul_tput}
    ${nsa_achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${NSA_DL_gNB_COUNTER}
    ${nsa_achieved_ul_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    ul    ${NSA_UL_gNB_COUNTER}
    Run Keyword And Continue On Failure    Validate Traffic DLUL    SANSA_72_UE    ${nsa_achieved_dl_tput}
    ...    ${nsa_achieved_ul_tput}

NSA MUE Deregister detach 72Ues
    Detach NSA MUE    ${total_nsa_ues}
    Deregister UEs

Validation of UE Attach
    FOR   ${ueid}   IN RANGE    ${FIRST_UE}    ${END_UE}+1    1
        ${validation_string}    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    UE${ueid}: Proxy.*    ${UE_attach_pattern}
        Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
    END
    Log    ue_attach_is_ok
    Sleep    2m
    wtsrunner.script_stop
    Check Pattern in Egate Console Log    ${traffic_validation}

Get Dictionary Values and register
    [Arguments]    ${dictionary_name}    ${tag_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    Run Keyword If    '${tag_name}' == 'SA_1_UE_3CC'    Enable BeamForming for IWF
    wtsrunner.seq_start    rate=1    id=${ID}    detailed_print=on    duration=${SE_duration}
    ...    max_active_ues=${CELL1_UES}
    Sleep    120s
    Run Keyword If    '${tag_name}' == 'SANSA_72_UE'
    ...    Validation of UE Register Parallel

SA MUE Register for 500UEs
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    Initial Setup for PET Test Cases with WtsSim    SA500UE
    Copy PET SE files
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items    ${SA_500_UE_2CELL}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${cfg_load_output}=    ute_wtssim.Execute Egate Command And Wait For Data    ${wts_cfg_load_command}
    ...    pass_regexp=Cell Setup completed    timeout=5minutes
    ${cfg_load_output}=    Get Lines Matching Regexp    ${cfg_load_output}    Airphone: Cell Setup completed
    ...    partial_match=${TRUE}
    Log    ${cfg_load_output}
    Sleep    60s
    Log To Console    Config file loaded successfully
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}
    ...    ${iwf_cells}
    Sleep    15s
    Check SIB Messages for All Cells    ${iwf_cells}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on
    ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/commands.lua entry\=TDD_FR1_SA_500UE_Register
    ...    pass_regexp=script completed    timeout=600
    FOR    ${count}    IN RANGE    1    ${duration}+1    1
        Sleep    1m
        Log To Console    Loop:${count}
        ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ue_disp state\=ACTIVE    timeout=10
        ${regex}=    Set Variable    ${SPACE}${SPACE}ACTIVE${SPACE}${SPACE}
        ${ue_count}=    Get Count    ${output}    ${regex}
        Log To Console    Number of ACTIVE SA UEs is ${ue_count}
        ${active_ues_total}=    Set Variable    ${ue_count}
        Run Keyword If    '${test_label}' == 'SA500UE'    Set Suite Variable    ${active_ues_total}
        Check IWF Status
    END
    Write Active No of UEs
    ${active_sa}=    Create List
    Set Suite Variable    @{active_sa}
    ${status}=    Run Keyword If    '${active_ues_total}' != '${END_UE}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected
    ute_wtssim.Execute Egate Command    seq_stop    rate=1    id=all
    IWF Test Case teardown    SA500UE

Write Active No of UEs
    Append To File     ${test_property_file}    ${\n}UEs=${active_ues_total}${\n}

SA MUE Register for 2 cell 2 UEs
    Create and Reset SA List
    SA Register in PET SE Format    ${SA_2cell_MUE}    SA_MUE
    ${achieved_sa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${SA_UL_CELL_RLC_COUNTER}
    Validate SA Traffic for PET_SE_IWF    1UE    ${OVERALL_DL}
    ...    ${OVERALL_UL}    ${achieved_sa_dl_tput[0]}    ${achieved_sa_ul_tput[0]}
    Validate SA Traffic for PET_SE_IWF    101UE    ${OVERALL_DL}
    ...    ${OVERALL_UL}    ${achieved_sa_dl_tput[1]}    ${achieved_sa_ul_tput[1]}

SA Register in PET SE Format
    [Arguments]    ${dictionary_name}    ${tag_name}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    Get Dictionary Values and register    ${dictionary_name}    ${tag_name}
    FOR    ${count}    IN RANGE    1    ${duration}    1
        Sleep    1m
        Check Active No Of SA UEs for PET SE    ${tag_name}
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check Active No Of SA UEs for PET SE    ${tag_name}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    wtsrunner.script_stop

Copy PET sequence files
	Run    cp ${MULTI_UE_SCRIPT_NEW} ${WTS_DIR}
	Run    cp ${CAP_CFG_500_FILE} ${WTS_DIR}

Copy capability cfg file
	${CAP_CFG_FILE}=    Catenate    ${CURDIR}${/}../scripts/${CAP_CFG_FILE}
	Run    cp ${CAP_CFG_FILE} ${WTS_DIR}

Execute Lua in PET format
    Copy PET sequence files
    ${cfg_filename}    Set variable    ${SA500UE}
    ${command}=    Catenate    ${cfg_filename}    entry=run_configuration()
    wtsrunner.configure    ${command}

Execute PET lua
    Copy capability cfg file
    ${cfg_filename}    Set variable    ${SA432UE}
    ${command}=    Catenate    ${cfg_filename}    entry=run_configuration()
    wtsrunner.configure    ${command}

Execute Lua
    ${cfg_filename}    Set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}

Set Beam info for MIMO
    wtsrunner.ul_sinr_testmode_nr    profile_id=${profile_id}    sinr_target_srs=${sinr_target_srs}
    ...    noise_srs=${noise_srs}
    wtsrunner.ue_testmode_set_nr    id=${mu_id1}    testmode=${testmode}     action=${action}
    ...    profile_id=${profile_id}
    wtsrunner.ue_testmode_set_nr    id=${mu_id2}    testmode=${testmode}    action=${action}
    ...    profile_id=${profile_id}
    FOR    ${Prof_id}    ${init_pos}    IN ZIP    ${Prof_id}    ${init_pos}
        wtsrunner.ue_srs_beam_pos_nr    profile_id=${Prof_id}    srsMode=fixed    init_pos=${init_pos}
    END
    FOR    ${i}    IN RANGE    1    5    1
        wtsrunner.ue_testmode_set_nr    id=${MIMO_id${i}}    testmode=ue_srs_beam_pos
        ...    action=activate    profile_id=${i}
    END
    FOR    ${i}    IN RANGE    1    5    1
        wtsrunner.ue_testmode_set_nr    id=${MUMIMO_id${i}}    testmode=ue_srs_beam_pos
        ...    action=activate    profile_id=${i}
    END

Write Active No of UEs To Test Proprties File
    Append To File     ${test_property_file}    ${\n}UEs=${active_ues_total}${\n}

Execute Lua in PET SE format
    Copy PET SE files
    ${cfg_filename}    Set variable    ${LUA_FILE}
    ${command}=    Catenate    ${cfg_filename}    entry=run_configuration()
    wtsrunner.configure    ${command}

Copy PET SE files
    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True' or '${IWF_TDD_FR1}' == 'True' or '${IWF_TDD_FR2}' == 'True' or '${IWF_FR1_LOO_LOOO}' == 'True'
    ...    Copy Lua file IWF

    ${CAP_CFG_FILE}=    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True'    Catenate    ${WTS_CAPS_CFG_FILE}
    ...    ELSE IF    '${IWF_ENABLED}' == 'True'    Catenate    ${FR1_CAPABILITIES_CFG_FILE}
    ...    ELSE    Catenate    ${CAPABILITIES_CFG_FILE}
    Set Suite Variable    ${CAP_CFG_FILE}
    Run    cp ${CAP_CFG_FILE} ${WTS_DIR}

    ${CMD_LUA}=    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True'    Catenate    ${WTS_COMMANDS_LUA}
    ...    ELSE IF    '${IWF_ENABLED}' == 'True'    Catenate    ${FR1_COMMANDS_LUA}
    ...    ELSE    Catenate    ${COMMANDS_LUA}
    Set Suite Variable    ${CMD_LUA}
    Run    cp ${CMD_LUA} ${WTS_DIR}

    ${MULTI_UE_SCRIPT_NEW}=    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True'    Catenate    ${WTS_TEST_SCRIPT}
    ...    ELSE IF    '${IWF_ENABLED}' == 'True'    Catenate    ${FR1_MULTI_UE_SCRIPT}
    ...    ELSE    Catenate    ${MULTI_UE_SCRIPT}
    Set Suite Variable    ${MULTI_UE_SCRIPT_NEW}
    Run    cp ${MULTI_UE_SCRIPT_NEW} ${WTS_DIR}
    Log To Console    Copied PET SE Files

Copy PET SE Lua
    [Arguments]    ${SE_SANSA_LUA}
    ${LUA_FILE}=    Catenate    ${SE_SANSA_LUA}
    Set Suite Variable    ${LUA_FILE}
    Run    cp ${LUA_FILE} ${WTS_DIR}

SIB Broadcast with PET SE
    [Documentation]    This keyword brooadcasts the SIB messages
    wtsrunner.script    file=multi_ue_sa_script_new.lua     entry=check_SIBs(${SE_sib})
    Sleep    60s

SIB Validation with PET SE
    [Documentation]    This keyword checks if the SIB messages are broadcasted in PET SE
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Catenate    cell ${cell_id + 1}: ${sib_pattern_pet_se}
        Check Pattern in Egate Console Log    ${validation_string}
    END
    sleep              5s
    Log                sib messages are validated

Start SA Traffic for SUE scenario PET SE
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ueid}    ${tcname}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    Create and Reset SA List
    Copy PET SE files
    SIB Broadcast with PET SE
    SIB Validation with PET SE
    Run Keyword If    '${tcname}' == '1UEUL'
    ...    wtsrunner.script    file=${COMMANDS_LUA}    entry=PET_8406FF_nonBF_1UE_UL
    Sleep    60s
    Check UE Activity for SA    ${ueid}
    FOR    ${count}    IN RANGE    ${perf_trf_duration}
        Sleep    1m
        Check UE Activity for SA    ${ueid}
        Run Keyword and Continue On Failure    Collect Bearer Stats for SA
        ...    ${ueid}    ${dl_rate}    ${ul_rate}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
    END
    Check UE Activity for SA    ${ueid}
    Stop SA Traffic    ${ueid}
    ${achieved_sa_dl_tput}    Run Keyword If    '${tcname}' != '1UEUL'
    ...    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${achieved_sa_ul_tput}    Run Keyword If    '${tcname}' != 'SA_1_UE_2CC' or '${tcname}' != 'SA_1_UE_3CC'
    ...    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    Run Keyword If    '${tcname}' != '1UEUL'    Validate Perf SA Traffic
    ...    ${dl_rate}    ${ul_rate}    ${tcname}    ${achieved_sa_dl_tput}    ${achieved_sa_ul_tput}
    ...    ELSE    Run Keyword If    '${tcname}' == '1UEUL'    Validate Traffic    1UEUL
    ...    ${achieved_sa_ul_tput}    ul

Validation of UE Register Parallel for PET SE
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    FOR   ${ueid}   IN RANGE    ${FIRST_UE}    ${END_UE}+1    100
        ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
        Log To Console    Context Pattern: ${validation_string}
        ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
        ...    expected=${validation_string}     timeout=10
        Log To Console   ${status}
        Run Keyword and Ignore Error    Read WTS Output For Pattern And Print matching Lines
        ...    ${ue_register_complete}    5
    END

Start Collecting Perf WTS VM Statistics
    Start WTS Top Output Capture for Perf Suite
    List All WTS Process    Before Start of Test Execution    ${wts_vm_process_suitesetup}

Start WTS Top Output Capture for Perf Suite
    Run    rm -f ${EXECDIR}/${wts_vm_top_results}
    Start Process    top -d 5 -b >> wts_vm_top_results.txt    shell=yes

Common Optimized Perf Suite Setup
    [Documentation]    This keyword is used load test suite varaibles dynamically based on TOPOLOGY value
    ...                This keyword need to be removed once individual test suite are removed in repo:
    ${TOP_INTERFACE_STATS}    Get Variable Value    ${Collect_WTS_Stats}    ${TOP_INTERFACE_STATS}
    Set Suite Variable    ${TOP_INTERFACE_STATS}
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Run Keyword and Ignore Error   Start Collecting Perf WTS VM Statistics
    Get AP Suite Configuration Variables
    Set Suite Variable    ${Perf_Testsuite}    True
    Common Perf Suite Setup

Common Perf Suite Setup
    [Documentation]    This keyword is used to start the UTE SCTP timeout and WTS related process at the start of suite
    ...                The sos report logs collection will be started
    ...                Modified Date: 21-Jun-2022
    ...                Last Modified by: sravani.k@nokia.com
    Get Component Carrier Variables
    Run Keyword and Ignore Error    Kill All Admin Cli Process Perf
    Run Keyword And Ignore Error    Install PyYaml and Taf config
    ${IWF_ENABLED}    Get Variable Value    ${IWF_ENABLE}    False
    Set Suite Variable    ${IWF_ENABLED}
    ${AP_TAG}    Get Environment Variable    LOAD_ID
    ${status}    ${TOPOLOGY_BRANCH_VALUE}     Run Keyword And Ignore Error   Get Environment Variable    TOPOLOGY_CONFIGS_BRANCH_NAME
    ${TOPOLOGY_BRANCH_VALUE}=    Set Variable If    '${status}' in ['FAIL','Fail']
    ...    ${AP_TAG}    ${TOPOLOGY_BRANCH_VALUE}
    Set Suite Variable    ${TOPOLOGY_BRANCH_VALUE}
    ${enable_strace}    Get Variable Value    ${STRACE_ENABLE}    False
    Set Suite Variable    ${enable_strace}
    ${EM_TRACES}    Get Variable Value    ${COLLECT_EM_TRACES}    ${EM_TRACES}
    Set Suite Variable    ${EM_TRACES}
    ${EM_PERF_STATS}    Get Variable Value    ${COLLECT_EM_PERF_STATS}    ${EM_PERF_STATS}
    Set Suite Variable    ${EM_PERF_STATS}
    ${SYSLOG}    Get Variable Value    ${COLLECT_SYSLOG}    ${SYSLOG}
    Set Suite Variable    ${SYSLOG}
    ${WTS_WIRESHARK}    Get Variable Value    ${WTS_PCAP_WIRESHARK}    ${WTS_PCAP}
    Set Suite Variable    ${WTS_WIRESHARK}
    ${AP_TOP_INTERFACE_STATS}    Get Variable Value    ${AP_TOP_STATS}    ${AP_TOP}
    Set Suite Variable    ${AP_TOP_INTERFACE_STATS}
    ${TTI_TRACES_GNB_WTS}    Get Variable Value    ${GNB_WTS_TTI_TRACES}    False
    Set Suite Variable    ${TTI_TRACES_GNB_WTS}
    Wait Coam Site to be Ready
    Remove old gNB and AP BIP Logs
    Run Keyword If    '${L2L3_BIPLOG}' == 'True' and '${IWF_ENABLED}' == 'True'
    ...    Run Keyword And Ignore Error    Enable L2L3 BIP Log
    ${condition}=    Catenate    '${IWF_TDD_FR2}' != 'True' and '${IWF_TDD_FR1}' != 'True' and
    ...    '${IWF_FR1_LOO_LOOO}' != 'True' and '${IWF_TDD_ECPRI72E}' != 'True'
    Run Keyword If    ${condition}
    ...    Start UTE WTS Perf
    ...    ELSE    Start UTE WTS Perf for WtsSim IWF
    Run Keyword And Ignore Error    Modify Sosreport script for Perf
    Run Keyword And Ignore Error    Disable gNB Ports And Update sosScripts
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}
    Run Keyword and Ignore Error    Kill All Admin Cli Process Perf
    Run Keyword and Ignore Error    Run    sudo umount /mnt/AP_QT_logs
    Run Keyword If    '${AP_TOP_INTERFACE_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Start AP Top output Collection IWF
    Run Keyword If    '${WTS_WIRESHARK}' == 'True'
    ...    Run Keyword And Ignore Error    Start WTS WireShark IWF

Common Perf Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    Collect Logs For Perf Run
    gNB Snapshot Collection via adminAPI
    Run Keyword If    '${PET_TDD}' == 'True' or '${PET_FDD}' == 'True'
    ...    Check Occurances in Egate Console    ${simmode_check}    1
    Run Keyword If    '${SYSLOG}' == 'True' or '${IWF_ENABLED}' == 'True'
    ...    Run Keyword and Ignore Error    Collect IWF fsyslog
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True' and ('${IWF_ENABLED}' == 'True' or '${SUITE STATUS}' == 'FAIL')
    ...    Stop sosReport Tcpdump    init    0
    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Run Keyword and Ignore Error    Stop and Collect WTS Interface Stats
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Run Keyword and Ignore Error    Stop Collecting WTS VM Statistics
    Run Keyword If    '${IWF_ENABLED}' == 'True' or '${Perf_Testsuite}' == 'True'    Collect Cummulative Logs
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Kill IWF Process
    Run Keyword and Ignore Error    Copy PET SE cfg and lua files to logs
    Run Keyword If    '${PET_TDD}' == 'True' or '${PET_FDD}' == 'True'    Copy Config Files to directory
    Run Keyword and Ignore Error    Kill All Admin Cli Process Perf
    Run Keyword and Ignore Error    Cleanup Counters Directory
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True' and '${IWF_ENABLED}' == 'True'
    ...    Move SosReport from IWF_Logs to Log
    Run Keyword If    '${AP_TOP_INTERFACE_STATS}' == 'True'
    ...    Run Keyword And Ignore Error    Collect and Download AP Top output IWF
    Run Keyword If    '${WTS_WIRESHARK}' == 'True'
    ...    Run Keyword And Ignore Error    Stop WTS WireShark IWF
    Run Keyword If    '${TTI_TRACES_GNB_WTS}' == 'True'
    ...    Run Keyword And Ignore Error    Collect TTI Traces

Collect Logs For Perf Run
   ${skip_logs}=   Check if Log needs to be Collected
   Run Keyword If   '${skip_logs}' == '1'   Delete UDP Syslog
   Collect UTE Perf Logs
   Run Keyword If   '${skip_logs}' == '0'   Collect gnb PM Counter Logs
   Run Keyword If   '${skip_logs}' == '0' and '${ap_sm_hardware}' == 'ASIL'
   ...   Run Keyword And Ignore Error    collect additional logs for LOKI

Start WTS WireShark IWF
    Run    chmod -R 777 /home/ute/logs/
    Start Process    sudo tcpdump -i any -p sctp -W 200 -C 200 -w /home/ute/logs/wts_wireshak.pcap    shell=yes

Stop WTS WireShark IWF
    Run    sudo pkill tcpdump
    Run    sudo tar -czvf /home/ute/logs/WTS.pcapng.tar /home/ute/logs/wts_wireshak.pcap*
    Run    mv /home/ute/logs/WTS.pcapng.tar ${EXECDIR}/logs/
    Run    rm -rf /home/ute/logs/wts_wireshak.pcap*

Start AP Top output Collection IWF
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Send Command    while [ 1 ]; do top -b |head -15 >>/user/toor4nsn/AP_top.txt; sleep 2; done &
    ...    connection=${AP_ASIK.Connection}
    ssh.Disconnect    ${AP_ASIK.Connection}

Collect and Download AP Top output IWF
    Run    mkdir -p /home/ute/AP_TOP_STATS
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.Send Command    pkill -f top
    ...    timeout=60    connection=${AP_ASIK.Connection}
    Download File    /user/toor4nsn/AP_top.txt    /home/ute/AP_TOP_STATS/AP_top.txt    ${AP_ASIK.Connection}
    Run    mv /home/ute/AP_TOP_STATS/AP_top.txt ${EXECDIR}/logs/AP_top.txt
    Run    gzip ${EXECDIR}/logs/AP_top.txt
    ssh.Disconnect    ${AP_ASIK.Connection}

Runner Log_Flush
    [Arguments]    ${file}
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    wtsrunner.script    file=${file}    entry=sim_log_re()

Wtssim Log_flush
    ute_wtssim.Execute Egate Command    sim_log_set flush

Collect UTE Perf Logs
    Log to Console            Collecting configs...
    Run Keyword If    'CLOUD_5GC_d' in '${TOPOLOGY}'    Collect CU Snapshot And SCF
    ...    ELSE    Run Keywords    Get Coam SCF For P1Perf    AND    Collect UTE Files
    Log to Console            Collecting all logs...
    Run Keyword If    '${CONDITIONAL_LOGGING}' == 'False' or '${SUITE STATUS}' == 'FAIL'    Collect UTE SosReport

Get Coam SCF For P1Perf
    Set Suite Variable    ${coamSCF}    ${EXECDIR}/logs/gnb_coam_scf.xml
    ${path}                           ${file}    Split Path    ${coamSCF}
    Wait Until Keyword Succeeds    5min    5sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ...    name='gNB_alias'
    Wait Until Keyword Succeeds    2min    1min    CoamAdmin.Get Current Scf File    ${path}    ${file}    timeout=60    connection='gNB_alias'
    File Should Exist                 ${coamSCF}
    [Teardown]    CoamAdmin.Teardown    connection='gNB_alias'

Check Active No Of SA UEs for PET SE
    [Arguments]    ${test_label}
    ${active_sa_ue}=    Create List
    ${ue_list_sa}=    Create List
    Set Suite Variable    @{active_sa_ue}
    Set Suite Variable    @{ue_list_sa}
    wtsrunner.ue_summary
    ${ue_summary}      wtsrunner.read_wtsemu_output_until    expected=Idle
    ...                     timeout=60
    ${active_ues}       Run Keyword If    '${perf_mue}' == 'True'    Get Regexp Matches
    ...    ${ue_summary}    Active +(\\d+)    1
    ...    ELSE    Get Regexp Matches    ${ue_summary}    ENB-2 +(\\d+)    1
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    ${ue_status}    Run Keyword and Return Status    Should Not Be Empty    ${active_ues[0]}
    Run Keyword If    '${ue_status}' == 'True'
    ...    Log To Console    [${hr}:${min}:${sec}]:Active No.of SA UEs:${active_ues[0]}
    ...    ELSE    Log To Console    Active Number Of UEs not present
    ${active_ues_total}=    Run Keyword If    '${test_label}' == 'SA500UE' and '${ue_status}' == 'True'
    ...    Set Variable    ${active_ues[0]}
    ...    ELSE    Set Variable    0
    Run Keyword If    '${test_label}' == 'SA500UE'    Set Suite Variable    ${active_ues_total}
    ${status}=    Run Keyword If    '${test_label}' != 'SA500UE' and '${active_ues[0]}' == '0'    Set Variable    'FAIL'
    Append To List    ${ue_list_sa}    ${status}
    List Should Not Contain Value    ${ue_list_sa}    FAIL    msg=Active No Of UEs are zero

Validation for PET SE UEs
    FOR   ${ueid}   IN    @{ue_id_list}
        ${validation_string}=    Catenate    UE${ueid}:     ${ue_registeration_completion}
        ${output}    Read WTS Output Until Pattern Matches    ${validation_string}    ${Timeout_SA}
        Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
        ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
        Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    END

Validate SA Traffic for PET_SE_IWF
    [Arguments]    ${tc_name}    ${overall_dl}
    ...    ${overall_ul}    ${dl_tput}    ${ul_tput}
    ${dl_limit}=    Set Variable    ${sa_mue_dl_limit}
    ${ul_limit}=    Set Variable    ${ul_limit}
    ${sa_dl_rate}=    Evaluate    ${dl_tput}/float(${evaluator})
    ${sa_ul_rate}=    Evaluate    ${ul_tput}/float(${evaluator})
    ${sa_dl_tput_status}=    Evaluate    ${sa_dl_rate} >= (${overall_dl}*${dl_limit})
    ${sa_ul_tput_status}=    Evaluate    ${sa_ul_rate} >= (${overall_ul}*${ul_limit})
    ${sa_dl_rate}=    Evaluate    int(${sa_dl_rate})
    ${sa_ul_rate}=    Evaluate    int(${sa_ul_rate})
    Log To Console    AVG Data Rate SA DL ${sa_dl_rate}
    Log To Console    AVG Data Rate SA UL ${sa_ul_rate}
    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_DL=${sa_dl_rate}${\n}
    Append To File     ${test_property_file}    ${\n}SA_${tc_name}_UL=${sa_ul_rate}${\n}
    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${sa_dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${sa_ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Attach 2 UE for 2 Cell
    Attach Multi UE for Multi Cell    ${perf_ul_rate}    ${perf_nsa_sue_dl_rate}    ${nsa_iwf_fr1_ueids}
    ...    ${target_ids_nsa}

Detach NSA MUE Multicell
    Detach for Multi UE for Multi Cell    ${nsa_iwf_fr1_ueids}

Display nr_stats for NSA UE list
    [Arguments]    ${nsa_list}
    FOR    ${index}    IN    @{nsa_list}
        Display nr_stats for NSA    ${index}
    END

Display nr_stats for NSA
    [Arguments]    ${ue_id}
    wtsrunner.ue_stats_nr    id=${ue_id}    type=pusch,pdsch    scell=8-15

IWF Status Check
    [Arguments]    ${tag_name}
    ${iwf_status}=    Run    ps -C iwf
    Log To Console    ${iwf_status}
    ${iwf_pid}=    Run    pidof iwf
    ${huge_page}=    Run    sudo -i | cat /proc/meminfo | grep Huge
    Log To Console    ${huge_page}
    Should Not Be Empty    ${iwf_pid}    msg=IWF process is not active
    ${iwf_status}    Run Keyword and Return Status    Should Not Be Empty    ${iwf_pid}
    Run Keyword If    '${iwf_status}' == 'False'
    ...    Append To File     ${test_property_file}    ${\n}${tag_name}_IWF_STATUS=${IWF_FAIL}${\n}

Update Fdd Perf UE ids list
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    @{sa_ueids_cell1}=    Create List
    @{nsa_ueids_cell1}=    Create List
    @{sa_ueids_cell2}=    Create List
    @{nsa_ueids_cell2}=    Create List
    @{sa_ueids_cell3}=    Create List
    @{nsa_ueids_cell3}=    Create List
    @{sa_ueids_cell4}=    Create List
    @{nsa_ueids_cell4}=    Create List
    @{targetCellsIds}=    Create List
    FOR    ${ueid}    IN RANGE      ${FIRST_SA_CELL1}    ${END_SA_CELL1}+1    1
        Append To List    ${sa_ueids_cell1}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_SA_CELL2}    ${END_SA_CELL2}+1     1
        Append To List    ${sa_ueids_cell2}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_NSA_CELL1}    ${END_NSA_CELL1}+1    1
        Append To List    ${nsa_ueids_cell1}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_NSA_CELL2}    ${END_NSA_CELL2}+1    1
        Append To List    ${nsa_ueids_cell2}    ${ueid}
    END
    FOR    ${ueid}    IN RANGE      ${FIRST_SA_CELL3}    ${END_SA_CELL3}+1    1
        Append To List    ${sa_ueids_cell3}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_SA_CELL4}    ${END_SA_CELL4}+1     1
        Append To List    ${sa_ueids_cell4}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_NSA_CELL3}    ${END_NSA_CELL3}+1    1
        Append To List    ${nsa_ueids_cell3}    ${ueid}
    END

    FOR    ${ueid}    IN RANGE      ${FIRST_NSA_CELL4}    ${END_NSA_CELL4}+1    1
        Append To List    ${nsa_ueids_cell4}    ${ueid}
    END

    FOR    ${value}    IN RANGE    4
        Append To List    ${targetCellsIds}   ${value+1}
    END

    Set Suite Variable    ${component_carrier}    4
    Set Suite Variable    @{sa_ueids_cell1}
    Set Suite Variable    @{nsa_ueids_cell1}
    Set Suite Variable    @{sa_ueids_cell2}
    Set Suite Variable    @{nsa_ueids_cell2}
    Set Suite Variable    @{sa_ueids_cell3}
    Set Suite Variable    @{nsa_ueids_cell3}
    Set Suite Variable    @{sa_ueids_cell4}
    Set Suite Variable    @{nsa_ueids_cell4}
    Set Suite Variable    @{targetCellsIds}

Update Fdd IWF UE ids list
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

    FOR    ${index}    IN RANGE    1    ${NO_OF_CELLS_FDDIWF}+1
        Set Suite Variable    @{sa_ueids_cell${index}}    @{EMPTY}
        Set Suite Variable    @{nsa_ueids_cell${index}}    @{EMPTY}
        Set Fdd IWF UEs    ${index}
    END
    @{targetCellsIds}=    Create List
    FOR    ${value}    IN RANGE    ${NO_OF_CELLS_FDDIWF}
        Append To List    ${targetCellsIds}   ${value+1}
    END
    Set Suite Variable    @{targetCellsIds}

Set Fdd IWF UEs
    [Arguments]    ${index}
    FOR    ${ueid}    IN RANGE      ${FIRST_SA_CELL${index}}    ${END_SA_CELL${index}}+1    1
        Append To List    ${sa_ueids_cell${index}}    ${ueid}
    END
    FOR    ${ueid}    IN RANGE      ${FIRST_NSA_CELL${index}}    ${END_NSA_CELL${index}}+1    1
        Append To List    ${nsa_ueids_cell${index}}    ${ueid}
    END
    Set Suite Variable    @{sa_ueids_cell${index}}
    Set Suite Variable    @{nsa_ueids_cell${index}}

Configure UTE ETH3 FOR MUE PERF
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3
    Run    sudo ip addr add 10.0.1.142/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.63/24 dev eth3
    Run    sudo ip addr add 10.0.1.64/24 dev eth3
    Run    sudo ip addr add 10.0.1.65/24 dev eth3
    Run    sudo ip addr add 10.0.2.3/24 dev eth4
    Run    sudo ip addr add 10.0.2.4/24 dev eth4
    Run    sudo ip addr add 10.0.2.5/24 dev eth4
    Run    sudo ip addr add 10.0.2.6/24 dev eth4
    Run    sudo ip addr add 10.0.2.7/24 dev eth4
    Run    sudo ip addr add 10.0.2.8/24 dev eth4
    Run    sudo ip addr add 10.0.2.9/24 dev eth4
    Run    sudo ip addr add 10.0.2.10/24 dev eth4
    Run    sudo ip addr add 10.0.2.11/24 dev eth4
    Run    sudo ip addr add 10.0.2.12/24 dev eth4
    Run    sudo ip addr add 10.0.2.13/24 dev eth4
    Run    sudo ip addr add 10.0.2.24/24 dev eth4
    Run    sudo ip addr add 10.0.2.22/24 dev eth4
    Run    sudo ip addr add 10.0.2.23/24 dev eth4
    Run    sudo ip addr add 10.0.2.25/24 dev eth4

Configure UTE ETH3 FOR FR1_PERF
    FOR    ${i}    IN RANGE    3    14    1
        Run    sudo ip addr add 10.0.2.${i}/24 dev eth4
    END
    FOR    ${i}    IN RANGE    61    64   1
        Run    sudo ip addr add 10.0.1.${i}/24 dev eth3
    END
    FOR    ${i}    IN RANGE    138    140    1
        Run    sudo ip addr add 10.0.1.${i}/24 dev eth3
    END
    FOR    ${i}    IN RANGE    6    8    1
        Run    sudo ip addr add 1.2.${i}.1/24 dev eth4
    END

Copy PET SE cfg and lua files to logs
    Run    cp ${WTS_DIR}/*.lua* ${EXECDIR}/logs/
    Run    cp ${WTS_DIR}/*.cfg* ${EXECDIR}/logs/
    Run    cp ${WTS_DIR}/WTS_Summary_*.csv* ${EXECDIR}/logs/

Copy Config Files to directory
    Run    rm -rf ${EXECDIR}/logs/config_files/
    Run    mkdir ${EXECDIR}/logs/config_files/
    Run    mv ${EXECDIR}/logs/*.lua* ${EXECDIR}/logs/config_files/
    Run    mv ${EXECDIR}/logs/*capability*.cfg* ${EXECDIR}/logs/config_files/
    Run    mv ${EXECDIR}/logs/*iphy*.xml* ${EXECDIR}/logs/config_files/
    Run    mv ${EXECDIR}/logs/*scf*.xml* ${EXECDIR}/logs/config_files/
    Run    mv ${EXECDIR}/logs/*swconfig*.txt* ${EXECDIR}/logs/config_files/
    Run    cp ${EXECDIR}/tools/BSR_Package/BSR* ${EXECDIR}/logs/config_files/

Get WTS Summary for PET SE
    [Documentation]    WTS summary script location :
    ...    testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/WTS_Summary
    ...    KW expects the following arguments -u TLTYPE, yes or no [yes for UTE and no for non-UTE]
    ...    -c CALLTYPE, calltype sa or nsa
    Run    cp ${WTS_Summary} ${WTS_DIR}
    Run    pip3 install tabulate
    ${output}    Run    python3 ${WTS_DIR}/WTS_Summary -u ${TLTYPE} -c ${CALLTYPE} -p ${WTS_DIR}/egate_console.log
    Log To Console    ${output}

Validate Peak counter for PET SE
    [Arguments]    ${COUNTER}
    ${counter_val}=    Get PM Counter Value    ${COUNTER}
    Log    ${counter_val}
    [Return]    ${counter_val}

Enable beamcontrol testmode nr profile
	wtsrunner.script    file=multi_ue_sa_script_new.lua    entry=create_beamcontrol_testmode_nr_profile(${testmode_nr_profile})
	sleep    60s
    FOR    ${i}    IN RANGE    1    5    1
        ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
        ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=(${testmode_profile${i}})
        ...    pass_regexp=UEs associated successfully    timeout=80
    END

Initial Setup for PET Test Cases with WtsSim
    [Arguments]    ${tag_name}
    Kill Deleted Process
    Stop Edaemon Egate
    Run Keyword If    '${tag_name}' != 'SA500UE'    Commission the scf    ${tag_name}
    Set Suite Variable    ${test_label}    ${tag_name}
    Run Keyword If    '${tag_name}' != 'SA500UE' or '${perf_Mue}' == 'True' or '${IWF_TDD_FR1}' == 'True'
    ...    Update Iphy File    ${tag_name}
    Bringup Perf Setup After Commissioning for WtsSim

Bringup Perf Setup After Commissioning for WtsSim
    Removal of logs from e2e_tests path
    Removal of logs
    Remove tmp contents
    Perform Perf SCF Commissioning
    Run Keyword If    '${IWF_TDD_FR1}' == 'True' or '${IWF_FR1_LOO_LOOO}' == 'True'    Start UTE WTS Perf for WtsSim IWF
    ...    ELSE    Start UTE WTS Perf for WtsSim

Start UTE WTS Perf for WtsSim
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS SIM
    Stop Edaemon Egate
    Configure UTE ETH3
    Configure UTE ETH3 FOR FR1_PERF
    Configure UTE ETH3 FOR MUE PERF
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Start wts interface stats collection
    Log to Console                 Starting WTS...
    Add ca_5gair User in ssh config
    Run Keyword If    "${SKIP_WTS_CONFIG_DOWNLOAD}" == "False"    Download of WTS config Files
    Update Bearer Configuration For TCP Traffic
    Connect To WTS VM
    ute_wtssim.Setup Edaemon    edaemon_port=${wts_sim_edaemon_port}    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${wts_sim_egate_port}    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    Run Keyword If    '${test_label}' not in "@{SKIP_LUA_UPDATE}" and '${PET_FDD}' != 'True'
    ...    Execute Lua in PET SE format
    Start fsyslog for IWF

SA Register and Scell addition
    ${TRF_DURATION}    Get Variable Value    ${PET_DURATION}    ${pet_trf_duration}
    Initial Setup for PET Test Cases with WtsSim    505Scell
    Copy PET SE files
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${505_Scell}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${ng_link_up_pattern}    ${PET_AMF}
    Log To Console    Config file loaded successfully
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${NO_OF_CELLS}
    Sleep    15s
    Check SIB Messages for All Cells With UEC    ${NO_OF_CELLS}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${entry}    timeout=300
    Wait Until Keyword Succeeds    35min    1min    Check Script Completion in Egate Console    ${SCRIPT_COMPLETE}
    log to console    Attach script is completed...
    Sleep    660s
    Validate Cumulative Count from gNB counter
    ${ue_status}=    Evaluate    (${Counter_value}) == (${EXPECTED_SCELL})
    Should Be Equal    '${ue_status}'    'True'    msg=Scell UEs are less than expected
    Get WTS Summary for PET SE
    FOR    ${count}    IN RANGE    1    ${TRF_DURATION}+1    1
        Sleep    1m
        Log To Console    Loop:${count}
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword If    '${active_ues_total}' == '0'    FAIL    msg=Active No Of UEs are zero
    END
    ${ue_status}=    Evaluate    (${active_ues_total}) == (${EXPECTED_SCELL})
    Append To File     ${test_property_file}
    ...    ${\n}505Scell_TEST_RESULTS={"s1-t1":{"Scell UEs" : "${active_ues_total}/${EXPECTED_SCELL}"}}${\n}
    Should Be Equal    '${ue_status}'    'True'    msg=Scell UEs are less than expected

Update FR2 UE ids list
    [Arguments]    ${nsa_fr2_first_cell1}    ${nsa_fr2_end_cell1}
    @{nsa_ueids_cell1}=    Create List
    @{targetCellsIds}=    Create List


    FOR    ${ueid}    IN RANGE      ${nsa_fr2_first_cell1}    ${nsa_fr2_end_cell1}+1    1
        Append To List    ${nsa_ueids_cell1}    ${ueid}
    END

    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetCellsIds}   ${value+1}
    END

    Set Suite Variable    @{nsa_ueids_cell1}
    Set Suite Variable    @{targetCellsIds}

Validate Cumulative Count from gNB counter
    ${Counter_value}=    Set Variable    0
    FOR    ${value}    IN RANGE    1    5    1
        ${value}    Get PM Counter Value from Multiple Cells    M55118C07003    ${value}
        ${value}    Get From List    ${value}    0
        ${Counter_value}=    Evaluate    (${value}+${Counter_value})
        Set Suite Variable    ${Counter_value}    ${Counter_value}
    END
    Log To Console    SCELL Addition Count from gNB counter : ${Counter_value}

Get PM Counter Value from Multiple Cells
    [Arguments]    ${counter}    ${pm_file_number}=1
    [Documentation]    pm_file_number: 1 means latest file, 2 is second latest and so on
    ${counter_value}=    Create List
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    ${pm_file}=	SSH.Execute	ls -lrt /tmp/PM.*.ANY.xml.gz | tail -${pm_file_number} | awk '{print $9}'    ${GNB_ASIK.Connection}
    ${cmd_output}=    Fetch from Left    ${pm_file}    \r
    ${cmd_output}=    SSH.Execute   zcat ${cmd_output}  ${GNB_ASIK.Connection}
    ${counter_list}=    Get regexp matches    ${cmd_output}     \<${counter}\>([0-9]+)
    FOR    ${index}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${index}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter}=    Convert to Integer    ${counter_string}
        Append To List    ${counter_value}    ${counter}
    END
    [Return]    ${counter_value}

Get init file for Perf
    ${hostname}=    Get Hostname Details for Perf
    ${testline_init}=    Catenate    ${testline_results_path_perf}/${hostname}/__init__.py
    ${cloned_init_file}=    Catenate    ${testline_config_perf_path}/${hostname}/__init__.py
    ${ute_ca_init_file}=    Catenate    ${ute_perf_ca_path}/__init__.py
    ${file_list} =    Create List    ${cloned_init_file}    ${testline_init}    ${ute_ca_init_file}
    FOR    ${file}    IN    @{file_list}
        ${result}   ${value} =   Run Keyword And Ignore Error    File Should Exist    ${file}
        Log To Console    File Exist: ${value}
        Continue For Loop If    '${result}' != 'PASS'
        Return From Keyword If   '${result}' == 'PASS'    ${file}
    END

Remove tmp contents
    Run    sudo rm -rf /tmp/tmp*

Deregister UEs
    Run Keyword If    '${IWF_ENABLED}' == 'True'    wtsrunner.seq_stop    rate=1    id=all
    ...    ELSE    Run Keyword If    '${test_label}' in "@{WTSSIM_TAGS}"    ute_wtssim.Execute Egate Command    seq_stop    rate=5    id=all
    ...    ELSE    wtsrunner.seq_stop    rate=5    id=all

Kill All Admin Cli Process Perf
    RUN    ps -ef | pgrep -f "Nemuadmin" | xargs sudo kill -9

Check Test Properties File
    ${test_file}=    Get File    ${EXECDIR}/test.properties
    ${string}=    Catenate   ${test_label}_TEST_RESULTS
    ${string}=    Encode String To Bytes    ${string}    UTF-8
    ${status}    Run Keyword And Ignore Error    Should Contain    ${test_file}    ${string}
    Log To Console    ${status[0]}
    ${resulted_ues}=    Get Variable Value    ${active_ues_total}
    ${expected_ues}=    Get Variable Value    ${END_UE}
    ${resulted_ues}=    Set Variable If    '${resulted_ues}' == 'None'    0    ${resulted_ues}
    ${expected_ues}=    Set Variable If    '${expected_ues}' == 'None'    0    ${expected_ues}
    Run Keyword If    '${status[0]}' == 'FAIL'
    ...    Append To File    ${test_property_file}
    ...    ${\n}${test_label}_TEST_RESULTS={"s1-t1":{"Active Number of UEs":"${resulted_ues}/${expected_ues}"}}${\n}
    ...    ELSE    Log To Console    Data present in file

Install PyYaml and Taf config
    Run    pip3 install pyYaml
    Run    pip3 install -i ${TAF_REPO} taf.config.scf

Counter Validation and write test properties
    [Arguments]    ${test_name}
    [Timeout]    10 minutes
    Fetch Counters and Validate    ${test_name}
    Write data to test file    ${test_name}

Check Peak Status
    ${peak_status}=    Evaluate    ${achieved_peak_counter} == ${${test_name}_peak}
    Log To Console    ${peak_status}

Write data to test file
    [Arguments]    ${test_name}
    ${test_file}=    Set Variable    ${test_property_file}
    ${cmd}=    Catenate    sed -i
    ...    '$ a\\${test_label}_TEST_RESULTS={"s1-t1":{"Active Number of UEs" : "${achieved_peak_counter}/${${test_name}_peak}" }}'
    ...    ${test_file}
    Run    ${cmd}
    Log To Console    test_properties file updated...
    Run Keyword If    '${test_name}' not in "@{RRC_TAGS}"    Validate Peak Counters    ${test_name}
    ...    ELSE    Validate RRC Counter Values    ${test_name}

Validate RRC Counter Values
    [Arguments]    ${test_name}
    ${peak}=    Evaluate    int((${${test_name}_peak})*${rrc_limit})
    ${active_sa}=    Create List
    Set Suite Variable    @{active_sa}
    ${status}=    Run Keyword If    '${achieved_peak_counter}' < '${peak}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected

Validate Peak Counters
    [Arguments]    ${test_name}
    Should Be Equal As Integers    ${achieved_peak_counter}    ${${test_name}_peak}

Counters and Traffic Validation
    [Arguments]    ${test_name}
    [Timeout]    10 minutes
    ${achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET FDD
    ...    dl    ${SA_DL_TPUT_COUNTER}
    Log To Console    ${achieved_dl_tput}
    ${achieved_ul_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET FDD
    ...    ul    ${SA_UL_TPUT_COUNTER}
    Log To Console    ${achieved_ul_tput}
    Run Keyword    Validate Traffic DLUL    ${test_name}    ${achieved_dl_tput}
    ...    ${achieved_ul_tput}

Counters and Traffic Validation for DL
    [Arguments]    ${test_name}
    [Timeout]    10 minutes
    ${achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET FDD
    ...    ${SA_DL_TPUT_COUNTER}
    Log To Console    Achieved Tput: ${achieved_dl_tput}
    Run Keyword    Validate Traffic    ${test_name}
    ...    ${achieved_dl_tput}    dl

Counters and Traffic Validation for UL
    [Arguments]    ${test_name}
    [Timeout]    10 minutes
    ${achieved_ul_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET FDD
    ...    ${SA_UL_TPUT_COUNTER}
    Log To Console    Achieved Tput: ${achieved_ul_tput}
    Run Keyword    Validate Traffic    ${test_name}
    ...    ${achieved_ul_tput}    ul

Validate Cumulative Req and Res Count from gNB counter
    [Arguments]    ${tag_name}
    Run Keyword If    '${tag_name}' == '9000_BF'
    ...    Set Suite Variable    ${UE_Count_threshold}    ${RRC_UE_Count_threshold}
    ...    ELSE    Set Suite Variable    ${UE_Count_threshold}    ${nonRRC_UE_Count_threshold}
    Validate Cumulative Count from gNB counter from multiple Cells   ${SGNB_ADMISSION_REQ_Counter}
    Validate Cumulative Count from gNB counter from multiple Cells   ${SGNB_ADMISSION_RES_Counter}
    ${failure_count}=     Evaluate    (${Req_counter}-${Res_counter})
    ${admissable_threshold}=    Evaluate    (${END_UE}*${UE_Count_threshold})
    ${counter_status}=     Evaluate    (${failure_count}<=${admissable_threshold})
    Set Suite Variable     ${SGNB_ADMISSION_REQ_RES_Status}    ${counter_status}

Validate Cumulative Count from gNB counter from multiple Cells
    [Arguments]    ${counter}
    ${value_list}=    Create List
    ${sum_list}=    Create List
    FOR    ${value}    IN RANGE    1    7    1
        ${value_list}    Get PM Counter Value from Multiple Cells    ${counter}    ${value}
        ${sum}    Evaluate    sum(map(int, ${value_list}))
        Append To List    ${sum_list}    ${sum}
    END
    ${sum}    Evaluate    sum(map(int, ${sum_list}))
    Run Keyword If   '${counter}' == '${SGNB_ADMISSION_REQ_Counter}'
    ...    Set Suite Variable    ${Req_counter}    ${sum}
    ...    ELSE    Set Suite Variable    ${Res_counter}    ${sum}

SIB Validation for WTSSIM
    [Arguments]    ${cells}    ${file}=/opt/wts/latest/egate_console.log     ${pattern}=SIB Found
    ...    ${grepArgs}=grep -i -c
    Wait Until Keyword Succeeds    2min    10s    Wtssim Log_flush
    ${command}     Catenate     ${grepArgs}     '${pattern}'     ${file}
    ${result}     Run    ${command}
    Log    ${result}
    Should Be Equal    ${result}     ${cells}    msg=SIB not received

Reading Dictionary Values
    [Arguments]    ${bf_dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${bf_dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

Enable BeamForming for IWF
    FOR    ${prof}    IN RANGE    1    7    1
        ${bf_dictionary_name}=    Set Variable    ${BF_ENABLE_PROFILE${prof}}
        Reading Dictionary Values    ${bf_dictionary_name}
        Sleep    2s
        wtsrunner.beam_control_testmode_nr    profile_id=${profile_id}    ueBeamIndexInitial=${ueBeamIndexInitial}
        ...    ssbeam_bestbeam=${ssbeam_bestbeam}    ssbeam_rsrp_best=${ssbeam_rsrp_best}    ssbeam_rsrp_avg=${ssbeam_rsrp_avg}
    END
    wtsrunner.script    file=${MULTI_UE_SCRIPT_NEW}    entry=${LUA_METHOD}(${parameters})

Modify Sosreport script for Perf
    Run    sed -i 's/chk lx/ls/g' /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh

Check ue_summary output
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ue_summary    timeout=10
    ${active_ues}=    Get Regexp Matches    ${output}    Active +(\\d+)    1
    Should Not Be Empty    ${active_ues}    msg=ue_summary has no result. Retry
    [Return]    ${active_ues}

Deregister PET
    [Timeout]    10 minutes
    ${sim_deregister}=    Catenate    '${test_label}' in "@{WTSSIM_TAGS}" or '${PET_FDD}' == 'True' or '${IWF_TDD_FR1}' == 'True'
    ...    or '${IWF_FDD_DSS}' == 'True' or '${IWF_FDD_NON_DSS}' == 'True'
    ...    or '${IWF_FDD_NON_DSS_CA}' == 'True' or '${IWF_FDD_CA_DSS}' == 'True' or '${IWF_FR1_LOO_LOOO}' == 'True'
    ...    or '${IWF_TDD_ECPRI72E}' == 'True'
    Run Keyword If    ${sim_deregister}
    ...    ute_wtssim.Execute Egate Command    seq_stop rate\=${DEREGISTER_RATE} id\=all
    ...    ELSE    wtsrunner.seq_stop    rate=5    id=all
    Run Keyword If    ${sim_deregister}
    ...    Wait Until Keyword Succeeds    5min    10s
    ...    Checking upto zero UEs
    ...    ELSE    Wait Until Keyword Succeeds    5min    10s    Checking upto zero UEs for runner

Checking upto zero UEs
    ${active_ues_summary}=    Run Keyword    Check ue_summary output
    ${zero_ue}=    Run Keyword If    '${active_ues_summary[0]}' == '0'    Set Variable    True
    Should Be True    ${zero_ue}    msg=Deregister in Progress

Checking upto zero UEs for runner
    wtsrunner.ue_summary
    ${ue_summary}      wtsrunner.read_wtsemu_output_until    expected=Idle
    ...                     timeout=60
    ${active_ues}       Run Keyword If    '${perf_mue}' == 'True'    Get Regexp Matches
    ...    ${ue_summary}    Active +(\\d+)    1
    ...    ELSE    Get Regexp Matches    ${ue_summary}    ENB-2 +(\\d+)    1
    ${hr}    ${min}    ${sec}=    Get Time    hour min sec
    Log To Console    [${hr}:${min}:${sec}]:Active No.of SA UEs:${active_ues[0]}
    ${zero_ue}=    Run Keyword If    '${active_ues[0]}' == '0'    Set Variable    True
    Should Be True    ${zero_ue}    msg=Deregister in Progress

Validate Perf Tput via gNB counter for PET FDD
    [Arguments]    ${gNB_counter}
    Get PM Counter Value FDD    ${gnb_pmcounter_dir}
    File Should Exist    /home/ute/fdd_pmcounters/gnb_pm_counters/PM.*.ANY.xml
    ${single_counter}    Get counter value from XML file    ${gNB_counter}
    ${achieved_final_tput}    Run Keyword If    '${single_counter}' != '${EMPTY}'    Check PET Counters FDD    ${single_counter}
    ...    ELSE    Log To Console    PM Counters are not updated
    Log To Console    ${achieved_final_tput}
    [Return]    ${achieved_final_tput}

Get PM Counter Value FDD
    [Arguments]    ${target_dir}    ${name}=gnb_pm_counters    ${duration}=5 minutes
    Log To Console    Download gNB PM Counters...
    ${webservice}=    Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    gnb_pmcounters.create PM collector    name=${name}    webservice=${webservice}    for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Check PET Counters FDD
    [Arguments]    ${counter}
    ${achieved_tput}=    Evaluate    (${counter}[0]*8)/float(300000)
    [Return]    ${achieved_tput}

Get counter value from XML file
    [Arguments]    ${COUNTER}
    ${single_counter}=    Create List
    ${pm_file}=    Set Variable    /home/ute/fdd_pmcounters/gnb_pm_counters/PM.*.ANY.xml
    ${cmd_output}=    Fetch from Left    ${pm_file}    \r
    ${cmd_output}=    Run    cat ${cmd_output}
    ${counter_list}=    Get Regexp Matches    ${cmd_output}     \<${COUNTER}\>([0-9]+)
    Log To Console    Counter List: ${counter_list}
    FOR    ${index}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${index}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter_val}=    Convert to Integer    ${counter_string}
        Log To Console    Counter Value: ${counter_val}
        Run Keyword If    '${counter_val}' > '0'
        ...    Append To List    ${single_counter}    ${counter_val}
    END
    [Return]    ${single_counter}

Cleanup Counters Directory
    Run    rm -rf /home/ute/fdd_pmcounters

Check SIB Messages for All Cells
    [Arguments]    ${cells}
    ${Cell_Count}=    Run Keyword If    '${IWF_TDD_FR1}' == 'True'    Set Variable    1,3
    ...    ELSE    Set Variable    ${Cell_Count}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs(${Cell_Count})
    ...    pass_regexp=SIB Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully
    SIB Validation for WTSSIM    ${cells}

Check SIB Messages for All Cells IWF
    [Arguments]    ${cells}    ${test_tag}
    ${Cell_Count}=    Run Keyword If    '${IWF_TDD_FR1}' == 'True'    Set Variable    1,3
    ...    ELSE IF   '${test_tag}' == 'SA_5CC_COMMON'
    ...    Set Variable    1,5
    ...    ELSE IF    '${test_tag}' == 'SA_SUE_6CC_IWF' or '${test_tag}' == 'SA_UE_6CC'
    ...    Set Variable    1,6
    ...    ELSE    Set Variable    ${Cell_Count}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs(${Cell_Count})
    ...    pass_regexp=SIB Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully
    SIB Validation for WTSSIM    ${cells}


Validate Counters for Bearers
    [Arguments]    ${gNB_counter}
    Get PM Counter Value FDD    ${gnb_pmcounter_dir}
    ${single_counter}    Get counter value from XML file    ${gNB_counter}
    [Return]    ${single_counter}

PET Test Properties
    [Arguments]    ${tc_name}    ${dl_tput}    ${ul_tput}
    ${DL_DATA}=    Set Variable    ${dl_tput}/${OVERALL_DL}Mbps
    ${UL_DATA}=    Set Variable    ${ul_tput}/${OVERALL_UL}Mbps
    ${GBR}=    Set Variable    ${achieved_GBR[0]}/${1070FF_MIXED_GBR}
    ${NON_GBR}=    Set Variable    ${achieved_nonGBR[0]}/${1070FF_MIXED_NON_GBR}
    Append To File    ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"DL_RATE":"${DL_DATA}", "UL_RATE":"${UL_DATA}", "GBR":"${GBR}", "NON GBR":"${NON_GBR}"}}${\n}

Cleanup Process and IP flush
    Run    sudo ifdown eth4
    Run    sudo ifup eth4
    Run    sudo ifdown eth3
    Run    sudo ifup eth3
    ${WTS_BUILD}    Run    ls -l /opt/wts/ | grep latest
    ${WTS_build_number}   Fetch From Right    ${WTS_BUILD}    /opt/wts/
    ${AP_build_number}    Run    ls /home/ute/.ute-ca/cache/airphone
    Run    rm -rf /opt/wts/*
    Run    cd /opt/wts; mkdir -p ${WTS_build_number}
    Run    tar -xvf /home/ute/.ute-ca/cache/airphone/${AP_build_number}/${WTS_build_number}.tar.bz2 -C /opt/wts/${WTS_build_number}
    Run    ln -f -s /opt/wts/${WTS_build_number} /opt/wts/latest

Check Occurances in Egate Console
    [Arguments]    ${pattern}    ${expected_occurances}    ${file}=/opt/wts/latest/egate_console.log
    ...    ${grepArgs}=grep -i -c
    Wait Until Keyword Succeeds    2min    10s    Wtssim Log_flush
    ${command}     Catenate     ${grepArgs}     '${pattern}'     ${file}
    ${result}     Run    ${command}
    Log    ${result}
    Should Be Equal    ${result}     ${expected_occurances}    msg=Error Found in Egate Logs: ${pattern} Not Found

Check Script Completion in Egate Console
    [Arguments]    ${pattern}    ${file}=/opt/wts/latest/egate_console.log
    ...    ${grepArgs}=grep -i -c
    Wait Until Keyword Succeeds    2min    10s    Wtssim Log_flush
    ${expected_occurances}=    Set Variable    1
    ${command}     Catenate     ${grepArgs}     '${pattern}'     ${file}
    ${result}     Run    ${command}
    Log    ${result}
    Should Be Equal    ${result}     ${expected_occurances}    msg=Script not Completed

Append to Test properties with GBR
    [Arguments]    ${tc_name}    ${dl_rate}    ${ul_rate}    ${tdl_tput}    ${tul_tput}    ${achieved_GBR}    ${GBR_value}
    ${DL_DATA}=    Set Variable    ${dl_rate}Mbps/${tdl_tput}Mbps
    ${UL_DATA}=    Set Variable    ${ul_rate}Mbps/${tul_tput}Mbps
    ${GBR_DATA}=    Set Variable    ${achieved_GBR}/${GBR_value}
    ${DL}=    Set Variable    DL_RATE
    ${UL}=    Set Variable    UL_RATE
    ${GBR}=    Set Variable    GBR_BEARERS
    Append To File     ${test_property_file}
    ...    ${\n}${tc_name}_TEST_RESULTS={"s1-t1":{"${DL}":"${DL_DATA}", "${UL}":"${UL_DATA}", "${GBR}":"${GBR_DATA}"}}${\n}

Get In Use BSR File
    Wait Until Keyword Succeeds    5min    10sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${bsr_files}    admin.Get Bsr Files
    ${bsr_in_use_count}=    Get Length    ${bsr_files['bsrFileInused']}
    Run Keyword If    ${bsr_in_use_count} > 0
    ...    Set Suite Variable    ${active_bsr}    ${bsr_files['bsrFileInused'][0]['filename']}
    ...    ELSE
    ...    Set Suite Variable    ${active_bsr}    ${EMPTY}
    [Return]    ${active_bsr}

Validate Active BSR File
    [Arguments]    ${bsr_package}    ${bsr_package_path}
    ${active_bsr}    Get In Use BSR File
    Return From Keyword If    '${active_bsr}' != '${EMPTY}' and '${active_bsr}' == '${bsr_package}'
    Clone Entitytest Repo    ${bsr_package_path}
    Log To Console    Uploading and Activating BSR Package
    Wait Until Keyword Succeeds    5min    5sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Wait Until Keyword Succeeds    2min    30sec    CoamAdmin.Update Software    ${bsr_package_path}
    Sleep    10s
    ${active_bsr}    Get In Use BSR File
    ${status}=    Run Keyword And Return Status    Should Be Equal    ${active_bsr}    ${bsr_package}
    Run Keyword If    '${status}'=='True'    Log To Console    BSR Package Matching
    ...    ELSE    Run Keywords    Log To Console    BSR Package Not Matching    AND    FAIL
    [Teardown]    CoamAdmin.Teardown

Clone Entitytest Repo
    [Arguments]    ${bsr_package_path}
    ${cmd}=    Catenate    git archive -o latest.zip
    ...     --remote=ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/5G/AIRPHONE/entitytests
    ...     master ${bsr_package_path}
    Run    ${cmd}
    Run    unzip latest.zip

Start UTE WTS Perf for WtsSim IWF
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS SIM
    Stop Edaemon Egate
    Run Keyword And Ignore Error    Kill Alias of WTSSIM egate and Edaemon
    Configure UTE ETH3
    Configure UTE ETH3 FOR FR1_PERF_IWF
    Run Keyword If     '${BSR_TEST}' == '1' and '${apConfiguration}' == 'fs_tdd_fdd_sansa_eCpri_cpri_cmwv_LOO_AP_LOOO_P1Perf_IWF'
    ...    Validate Active BSR File    ${BSR_PKG}    ${BSR_PKG_PATH}/${BSR_PKG}.zip
    Run Keyword If     '${BSR_TEST}' == '1' and '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LOO_P1Perf_IWF'
    ...    Validate Active BSR File    ${BSR_PKG}    ${BSR_PKG_PATH}/${BSR_PKG}.zip
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'
    ...    Start sosReport Tcpdump    init
    Run Keyword If    '${TOP_INTERFACE_STATS}' == 'True'    Start wts interface stats collection
    Log to Console                 Starting WTS...
    Add ca_5gair User in ssh config
    Run Keyword If    "${SKIP_WTS_CONFIG_DOWNLOAD}" == "False"    Download of WTS config Files
    Run Keyword If    '${Sim_Config_Format}' == 'True'    Copy PET SE Files Sim Config Format
    ...    ELSE    Copy PET SE files
    Connect To WTS VM
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Enable IWF After Egate Reset
    ...    ELSE    Kill IWF Process
    ute_wtssim.Setup Edaemon    edaemon_port=${wts_sim_edaemon_port}    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${wts_sim_egate_port}    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${IWF_Scenario}=    Catenate    '${IWF_TDD_FR2}' == 'True' and '${IWF_FDD_DSS}' == 'False' and
    ...    '${IWF_FDD_NON_DSS_CA}' == 'False' and '${IWF_FDD_NON_DSS}' == 'False' and
    ...    '${IWF_FDD_CA_DSS}' == 'False' and '${test_label}' != 'SA_CA_80UE'
    Run Keyword If    '${Sim_Config_Format}' == 'True'   Upload Lua File In Sim Config Format
    ...    ELSE IF    '${IWF_TDD_ECPRI72E}' == 'True'    Upload_Lua_File_For_ECPRI72E_IWF
    ...    ELSE IF    ${IWF_Scenario}    Upload Lua File for FR2
    ...    ELSE IF    '${IWF_TDD_FR1}' == 'True'    Upload Lua File
    ...    ELSE IF    '${IWF_FR1_LOO_LOOO}' == 'True' and '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_5CC_TDD_AP_PERF'
    ...    Upload Lua File IWF    SA_5CC_COMMON
    ...    ELSE IF    '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_6CC_TDD_AP_PERF' and '${test_label}' == 'SA_SUE_6CC_IWF'
    ...    Upload Lua File IWF    SA_SUE_6CC_IWF
    ...    ELSE IF    '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_6CC_TDD_AP_PERF' and '${test_label}' == 'SA_UE_6CC'
    ...    Upload Lua File IWF    SA_UE_6CC
    ...    ELSE IF    '${IWF_FDD_DSS}' == 'True' and '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_DSS_AP_PERF'
    ...    Upload Lua File for DSS IWF    ${DSS_FDD_40UE}
    ...    ELSE IF    '${test_label}' == 'SA_CA_80UE'    Upload Lua File for Non DSS IWF    ${SA_CA_80UE_NON_DSS}
    ...    ELSE IF    '${test_label}' == 'SA_CA_20UE'    Upload Lua File for Non DSS IWF    ${20UE_CA_SA}
    ...    ELSE IF    '${IWF_FDD_NON_DSS}' == 'True'    Upload Lua File for Non DSS IWF    ${SA_SUE_NON_DSS}
    ...    ELSE IF    '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_CA_DSS_AP_PERF'
    ...    Upload Lua File for DSS IWF    ${SA_2F_20UE}
    Start fsyslog for IWF
    Run Keyword If    '${TTI_TRACES_GNB_WTS}' == 'True'
    ...    Run Keyword And Ignore Error    Get L2stream logs using Sbts cOAM cli using nr_phy_cell_ids
    Run Keyword If    '${skip_l2testmode}' == 'False'    Enable L2 Testmode Params

Upload Lua File
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Run Keyword If    '${IWF_TDD_FR1}' == 'True'    Check Cell Setup    ${iwf_cells}

Check Cell Setup IWF
    [Arguments]    ${iwf_cells}    ${test_tag}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${iwf_cells}
    Check SIB Messages for All Cells IWF    ${iwf_cells}    ${test_tag}
    ute_wtssim.Execute Egate Command    sim_debug_log level\=3 app_type\=ueproxy
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Upload Lua File IWF
    [Arguments]    ${test_tag}
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Sleep    1m
    Wait Until Keyword Succeeds    2min    10s    Wtssim Log_flush
    Run Keyword If    '${test_tag}' == 'SA_5CC_COMMON'    Check Cell Setup IWF    ${loo_iwf_cells}    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'SA_SUE_6CC_IWF' or '${test_tag}' == 'SA_UE_6CC'    Check Cell Setup IWF    ${IWF_LOO_CELLS_6}    ${test_tag}

Check Cell Setup
    [Arguments]    ${iwf_cells}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${iwf_cells}
    ${status}=     Run Keyword And Return Status    Check SIB Messages for All Cells    ${iwf_cells}
    Run Keyword If    '${status}' == 'False'     Wait Until Keyword Succeeds    1min    10s
    ...    Check Occurances in Egate Console    ${sib_decoding_pattern_pet}    ${iwf_cells}
    ute_wtssim.Execute Egate Command    sim_debug_log level\=3 app_type\=ueproxy
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Upload Lua File for FR2
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Sleep    1m
    Wait Until Keyword Succeeds    2min    10s    Wtssim Log_flush
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${UE_SIB_decoding_pattern}    1
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${UE_SIB_decoding_pattern_eNB}    1
    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...    pass_regexp=eNB 2 cell 8: MasterInformationBlock-NR Updated    timeout=10minutes
    Wait Until Keyword Succeeds    5min    1min    Check Occurances in Egate Console    ${mib_pattern_iwf}    ${NO_OF_CELLS_IWF}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Attach Multi UE for Multi Cell NSA 106 UE
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${FR2_IWF_NSA_MUE_106UE_ULDL}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_single_cell_index}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    NSA mmwv MUE Attach with lua functions For IWF   ${FR2_IWF_NSA_MUE_106UE_ULDL}
    ${nsa_ue_id_list}=    Create List
    Set Suite Variable    @{nsa_ue_id_list}
    ${nsa_ue_id_list}=    Run Keyword    UE List creation    ${FIRST_UE}    ${END_UE}
    Sleep    100s
    FOR    ${count}    IN RANGE    ${duration}
         Sleep    1m
         Check IWF Status
         Validate NSA UE Connectivity at gNB     ${nsa_ue_id_list}
         Run Keyword and Ignore Error    Collection Of Em Perf Stats And Em Traces   ${count}
         Run Keyword If    '${AP_Snapshot}' == 'True'
         ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Validate NSA UE Connectivity at gNB     ${nsa_ue_id_list}
    Append To File    ${test_property_file}    ${\n}UEs=${active_ues_total}${\n}
    ${active_nsa}=    Create List
    Set Suite Variable    @{active_nsa}
    ${status}=    Run Keyword If    '${active_ues_total}' != '${END_UE}'    Set Variable    FAIL
    Append To List    ${active_nsa}    ${status}
    List Should Not Contain Value    ${active_nsa}    FAIL    msg=Active No Of UEs are Less than expected
    ute_wtssim.Execute Egate Command    script_stop

Deregister NSA MultiUE IWF
    [Arguments]    ${dictionary_name}
	${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ute_wtssim.Execute Egate Command    ue_detach id\=${FirstUE}-${ENDUE}
    Sleep    5s
    Run Keyword If    '${IWF_FDD_NON_DSS_CA}' != 'True' and '${IWF_FDD_NON_DSS}' != 'True'    Checking upto zero UEs

NSA mmwv MUE Attach with lua functions For IWF
    [Arguments]    ${dictionary_name}
	${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${parameters}=    Catenate    SEPARATOR=,    ${FIRST_UE}    ${END_UE}    ${BEARER_ID}
    ...    ${TARGET_GNB}    ${TARGET_GNB_CELL}     ${UL_RATE}    ${DL_RATE}
    ...    ${UL_PACKET_SIZE}    ${UL_PACKET_SIZE}    ${tag}
    ute_wtssim.Execute Egate Command    script file\=${MULTI_UE_SCRIPT_NEW} entry\=${LUA_METHOD}(${parameters})

Stop NSA MUE Traffic for IWF
    [Arguments]    ${nsa_list}
    ute_wtssim.Execute Egate Command    trf_data_stop ue\=${nsa_list[0]}-${nsa_list[-1]} id\=${BEARER_ID}

Thoughput Validation
    [Arguments]    ${test_tag}    ${sa_nsa}    ${dl_tput}=0
    ${tput_ue_status}=    Create List
    ${dl_tput_status}=    Evaluate    ${dl_tput} >= (${OVERALL_DL}*${mue_dl_limit})
    ${dl_tput}=    Evaluate    "%.2f" % ${dl_tput}
    Log To Console    Achieved ${sa_nsa} DL Tput ${dl_tput}
    Append To File     ${test_property_file}    ${\n}${test_tag}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}${test_tag}_UE=${active_ues_total}/${EXPECTED_UE_COUNT}${\n}
    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_ue_status}    ${status_dl[0]}
    ${ue_check}=    Evaluate    '${active_ues_total}' == '${EXPECTED_UE_COUNT}'
    Should Be Equal    '${ue_check}'    'True'    msg=Active UEs are less than expected
    ${ue_status}=    Run Keyword And Ignore Error   Should Be True    '${ue_check}' == 'True'
    ...    msg=failed in active UE check, see error above!
    Append To List    ${tput_ue_status}    ${ue_status[0]}
    List Should Not Contain Value    ${tput_ue_status}    FAIL    msg=Criteria Not Met

Attach Multi UE for Multi Cell NSA 10 UE 8CC 1277FF
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
	${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${FR2_IWF_NSA_MUE_10UE_ULDL}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_cell_index_8CC}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    NSA mmwv MUE Attach with lua functions For IWF   ${FR2_IWF_NSA_MUE_10UE_ULDL}
    ${Trf_validation_string}=    Set Variable    ${Trf_validation_string} for ${tag}
    Wait Until Keyword Succeeds    5min    1min    Check Occurances in Egate Console    ${Trf_validation_string}
    ...    1
    FOR    ${TRFID}    ${data_rate}    IN ZIP    ${TRFID}    ${data_rate}
        ute_wtssim.Execute Egate Command
        ...    trf_data_start ue\=${FIRST_UE}-${END_UE} id\=${BEARER_ID} dir\=dl trf_id\=${TRFID} mbps\=${data_rate} size\=1350
    END
    ute_wtssim.Execute Egate Command
    ...    trf_data_start ue\=${FIRST_UE}-${END_UE} id\=${BEARER_ID} dir\=ul trf_id\=${TRF_ID_UL} mbps\=${UL_DATA_RATE} size\=1350
    ${nsa_mue_id_list}=    Create List
    Set Suite Variable    @{nsa_mue_id_list}
    ${nsa_mue_id_list}=    Run Keyword    UE List creation    ${FIRST_UE}    ${END_UE}
    Check IWF Status
    Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
    FOR    ${count}    IN RANGE    ${duration}
         Sleep    1m
         Check IWF Status
         ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id_Cell_8CC} type\=${stats_type} scell\=${stats_scell}
         Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
         Run Keyword and Ignore Error    Collection Of Em Perf Stats And Em Traces   ${count}
         Run Keyword If    '${AP_Snapshot}' == 'True'
         ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Check IWF Status
    ute_wtssim.Execute Egate Command    script_stop
    Stop NSA MUE Traffic for IWF    ${nsa_mue_id_list}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Thoughput Validation    NSA_10    NSA    ${achieved_nsa_dl_tput}
    Thoughput Validation for UL and DL    NSA_10    NSA    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}

Attach NSA SUE Attach and Traffic 8CC CA DL 4300Mbps
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values    ${FR2_IWF_NSA_SUE_8CC}
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_cell_index}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Attach NSA SUE for IWF    ${FR2_UE}    ${targetcell_ids[0]}
    Check IWF Status
    Generate NSA Traffic for IWF    ${FR2_UE}    ${DL_data_rate}    dl
    Generate NSA Traffic for IWF    ${FR2_UE}    ${UL_data_rate}    ul
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id} type\=${stats_type} scell\=${stats_scell}
        Validate NSA UE Connectivity at gNB     ${FR2_UE}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Stop NSA SUE Traffic for IWF    ${FR2_UE}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Thoughput Validation for UL and DL    NSA_8CC_SUE    NSA    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}

Stop NSA SUE Traffic for IWF
    [Arguments]    ${nsa_ueid}
    ute_wtssim.Execute Egate Command    trf_data_stop ue\=${nsa_ueid} id\=${BEARER_ID}

Attach NSA SUE for IWF
    [Arguments]    ${ueid}    ${Target_Cells}
    ute_wtssim.Execute Egate Command    ue_attach id\=${ue_id}
    Sleep    2s
    ute_wtssim.Execute Egate Command
    ...    enb_ue_dc_start target_gnb\=${Target_gNB} target_cells\=${Target_Cells} ue\=${ueid} bearer\=${Bearer_ID} type\=split_scg

Generate NSA Traffic for IWF
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
        Run Keyword If    ${trf_id}<${num_trf}    Start NSA Perf Traffic one for IWF    ${ue_id}
        ...    ${trf_id}    ${dir}
        Run Keyword If    ${trf_id}==${num_trf}    Start NSA Perf Traffic Two for IWF    ${ue_id}    ${trf_id}
        ...    ${dir}    ${last_trf_rate}
    END

Start NSA Perf Traffic one for IWF
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    ute_wtssim.Execute Egate Command
    ...    trf_data_start ue\=${ueid} trf_id\=${trf_id} id\=${Bearer_ID} mbps\=160 dir\=${dir} size\=${trf_id_perf}

Start NSA Perf Traffic Two for IWF
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    ute_wtssim.Execute Egate Command
    ...    trf_data_start ue\=${ueid} trf_id\=${trf_id} id\=${Bearer_ID} mbps\=${last_trf_rate} dir\=${dir} size\=${trf_id_perf}

Attach NSA SUE Attach and Traffic 4CC CA DL 2200Mbps
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values    ${FR2_IWF_NSA_SUE_4CC}
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_cell_index}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Attach NSA SUE for IWF    ${FR2_UE}    ${targetcell_ids[0]}
    Check IWF Status
    Generate NSA Traffic for IWF    ${FR2_UE}    ${DL_data_rate}    dl
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id} type\=${stats_type} scell\=${stats_scell}
        Validate NSA UE Connectivity at gNB     ${FR2_UE}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Set Suite Variable    ${OVERALL_DL}    ${DL_data_rate}
    Stop NSA SUE Traffic for IWF    ${FR2_UE}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    Thoughput Validation    NSA_4CC_SUE    NSA    ${achieved_nsa_dl_tput}

Attach NSA SUE Attach and Traffic DL 550Mbps UL 110Mbps
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values    ${FR2_IWF_NSA_SUE}
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_cell_index}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Attach NSA SUE for IWF   ${FR2_UE}    ${targetcell_ids[0]}
    Check IWF Status
    Generate NSA Traffic for IWF    ${FR2_UE}    ${DL_data_rate}    dl
    Generate NSA Traffic for IWF    ${FR2_UE}    ${UL_data_rate}    ul
    FOR    ${count}    IN RANGE    ${duration}
        Sleep    1m
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id} type\=${stats_type} scell\=${stats_scell}
        Validate NSA UE Connectivity at gNB     ${FR2_UE}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${count}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Set Suite Variable    ${OVERALL_DL}    ${DL_data_rate}
    Set Suite Variable    ${OVERALL_UL}    ${UL_data_rate}
    Stop NSA SUE Traffic for IWF    ${FR2_UE}
    ${achieved_nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_TPUT_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_TPUT_COUNTER}
    Thoughput Validation for UL and DL    NSA_SUE    NSA    ${achieved_nsa_dl_tput}    ${achieved_nsa_ul_tput}

Thoughput Validation for UL and DL
    [Arguments]    ${test_tag}    ${sa_nsa}    ${dl_tput}=0    ${ul_tput}=0
    ${dl_tput_status}=    Evaluate    ${dl_tput} >= (${OVERALL_DL}*${mue_dl_limit})
    ${ul_tput_status}=    Evaluate    ${ul_tput} >= (${OVERALL_UL}*${mue_ul_limit})
    ${dl_tput}=    Evaluate    "%.2f" % ${dl_tput}
    ${ul_tput}=    Evaluate    "%.2f" % ${ul_tput}
    Log To Console    Achieved ${sa_nsa} DL Tput ${dl_tput}
    Log To Console    Achieved ${sa_nsa} UL Tput ${ul_tput}
    Validate Tput Active UE and Evaluate
    ...    ${test_tag}    ${dl_tput_status}    ${ul_tput_status}    ${dl_tput}    ${ul_tput}

Deregister FR2 NSA MultiCell
    ute_wtssim.Execute Egate Command    ue_detach id\=${FR2FirstUE}-${FR2EndUE}
    Sleep    5s
    Checking upto zero UEs

Attach NSA 10UEs Attach and Traffic DL 550Mbps UL 110Mbps
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values    ${FR2_IWF_NSA_80UES}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${perf_trf_duration}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${FR2_cell_index_1}
    ${Trf_validation_string}=    Set Variable    ${Trf_validation_string} for ${tag}
    FOR    ${index}    IN RANGE    1    ${iteration_num}
        ${cell_index}=    Get Variable Value    ${FR2_cell_index_${index}}
        ${mue_variable}=    Get Variable Value    ${FR2_NSA_MUE_${index}CELL_ULDL}

        ute_wtssim.Execute Egate Command    enb_endc_param id\=${cell_index_id} serving_cell_index_range_scg\=${cell_index}
        NSA mmwv MUE Attach with lua functions For IWF   ${mue_variable}
        ${index}    Convert To String    ${index}
        Wait Until Keyword Succeeds    5min    1min    Check Occurances in Egate Console    ${Trf_validation_string}
        ...    ${index}
        ${last_index}=    Evaluate    ${iteration_num} - 1
        Run Keyword If    ${index} != ${last_index}    ute_wtssim.Execute Egate Command    script_stop
    END
    ${nsa_mue_id_list}=    Create List
    Set Suite Variable    @{nsa_mue_id_list}
    ${nsa_mue_id_list}=    Run Keyword    UE List creation    ${FR2FirstUE}    ${FR2EndUE}
    Check IWF Status
    Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
    FOR    ${count}    IN RANGE    ${duration}
         Sleep    1m
         Check IWF Status
         FOR    ${index}    IN RANGE    1    ${iteration_num}
             ${stats_id}=    Get Variable Value    ${stats_id_Cell${index}}
			 ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id} type\=${stats_type} scell\=${stats_scell}
         END
         Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
         Run Keyword and Ignore Error    Collection Of Em Perf Stats And Em Traces   ${count}
         Run Keyword If    '${AP_Snapshot}' == 'True'
         ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${duration}   ${count}
    END
    Check IWF Status
    ute_wtssim.Execute Egate Command    script_stop
    Stop NSA MUE Traffic for IWF    ${nsa_mue_id_list}
    ${achieved_nsa_dl_tput}=    Create List
    ${achieved_nsa_ul_tput}=    Create List
    ${achieved_nsa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_DL_CELL_RLC_COUNTER}
    ${achieved_nsa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${NSA_UL_CELL_RLC_COUNTER}
    ${achieved_nsa_dl_tput}=    Convert the data    ${achieved_nsa_dl_tput}
    ${achieved_nsa_ul_tput}=    Convert the data    ${achieved_nsa_ul_tput}
    FOR    ${index}    IN RANGE    1    ${iteration_num}
        ${cell_name}=    Set Variable    NSA_20UE_${index}CELL
        ${dl_tput}=      Get From List    ${achieved_nsa_dl_tput}    ${index - 1}
        ${ul_tput}=      Get From List    ${achieved_nsa_ul_tput}    ${index - 1}
        Run Keyword And Continue On Failure    Thoughput Validation for UL and DL    ${cell_name}    NSA    ${dl_tput}    ${ul_tput}
    END

Convert the data
    [Arguments]    ${original_list}
    ${updated_list}=    Create List
    FOR    ${value}    IN    @{original_list}
        ${result}=    Evaluate    ${value}/${evaluator}
        Append To List    ${updated_list}    ${result}
    END
    [Return]    ${updated_list}

Deregister FR2 NSA SUE
    ute_wtssim.Execute Egate Command    ue_detach id\=${FR2_UE}
    Sleep    5s
    Checking upto zero UEs

Validating gNB PM Counter file
    Get PM Counter Value FDD    ${gnb_pmcounter_dir}
    File Should Exist    /home/ute/fdd_pmcounters/gnb_pm_counters/PM.*.ANY.xml

Fetch Counters and Validate
    [Arguments]    ${tag_name}
    Log To Console    Enter Fetch Counters and Validate
    ${achieved_peak}    Validate Counters    ${${tag_name}_counter}
    Set Suite Variable    ${achieved_peak_counter}    ${achieved_peak[0]}

Validate Counters
    [Arguments]    ${peak_COUNTER}
    ${achieved_peak}    Run Keyword    Validate Peak counter for PET SE FDD
    ...    ${peak_COUNTER}
    Log To Console    Achieved UE ${achieved_peak}
    [Return]    ${achieved_peak}

Validate Peak counter for PET SE FDD
    [Arguments]    ${COUNTER}
    Wait Until Keyword Succeeds    10min   1min    Validating gNB PM Counter file
    ${single_counter}    Get counter value from XML file    ${COUNTER}
    [Return]    ${single_counter}

SA 20 UE 3CC Register and Traffic DL 4800Mbps and UL 200Mbps1208FF 256QAM 8x4 BF 100Mhz
    Fetch Dictionary Values    ${SA_20_UE_3CC}
    Enable BeamForming IWF
    Sleep    5s
    FOR    ${prof_id}    IN RANGE    1    7    1
        ute_wtssim.Execute Egate Command    script file\=${MULTI_UE_SCRIPT_NEW} entry\=${LUA_METHOD}(${TEST_MODE_PARAMS_${prof_id}})
    END
    Sleep    5s
    Start Register and Traffic    SA_20    cell_stats_check=True    ue_stats_check=True
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul}    Fetch Counter Values IWF    ${SA_UL_TPUT_COUNTER}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_dl}    ${achieved_ul}
        Run Keyword If    '${tput_dl}' != '0' and '${tput_ul}' != '0'    Thoughput Validation For IWF    SA_20    SA
        ...    ${tput_dl}    ${tput_ul}
    END

SA SUE Register and Traffic DL 1600Mbps and UL 200Mbps 1208FF 256QAM 2CELL 4x4 nonBF 100Mhz
    Fetch Dictionary Values    ${SA_MUE_2CELL}
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'    IWF Test Case teardown    SA_SUE
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'    Copy logs to IWF Logs
    Initial Setup for PET Test Cases with WtsSim    SA_MUE
    ${OVERALL_DL}=    Evaluate    int(${OVERALL_DL})*2
    ${OVERALL_UL}=    Evaluate    int(${OVERALL_UL})*2
    Set Suite Variable    ${OVERALL_DL}    ${OVERALL_DL}
    Set Suite Variable    ${OVERALL_UL}    ${OVERALL_UL}
    Start Register and Traffic    SA_MUE    cell_stats_check=True    ue_stats_check=True
    ${OVERALL_DL}=    Evaluate    int(${OVERALL_DL})//2
    ${OVERALL_UL}=    Evaluate    int(${OVERALL_UL})//2
    Set Suite Variable    ${OVERALL_DL}    ${OVERALL_DL}
    Set Suite Variable    ${OVERALL_UL}    ${OVERALL_UL}
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_ul}    Fetch Counter Values IWF    ${SA_UL_CELL_RLC_COUNTER}
    ${cell}=    Set Variable    0
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_dl}    ${achieved_ul}
        ${cell}=    Evaluate    (${cell}+1)
        ${tput_dl}=    Evaluate    (${tput_dl}/1000)
        ${tput_ul}=    Evaluate    (${tput_ul}/1000)
        Run Keyword If    int(${tput_dl}) != 0 and int(${tput_ul}) != 0    Thoughput Validation For IWF    SA_MUE_${cell}    SA
        ...    ${tput_dl}    ${tput_ul}
    END

SA 2000UE Register DL 74bps and UL 74bps 1208FF 256QAM 3CELL 8x4 BF 100Mhz
    Fetch Dictionary Values    ${SA_2000_UE_3CELL}
    Attach MultiUE For Multiple sequence IWF
    ${active_sa}=    Create List
    Set Suite Variable    @{active_sa}
    ${status}=    Run Keyword If    '${active_ues_total}' != '${EXPECTED_UE_COUNT}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    Append To File     ${test_property_file}    ${\n}UEs=${active_ues_total}${\n}
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected

SA SUE 3CC Register and Traffic DL 4800Mbps 1208FF 256QAM 8x4 BF 100Mhz
    Fetch Dictionary Values    ${SA_3CC}
    Enable BeamForming IWF
    Enable Test Mode Profile
    Start Register and Traffic    SA_UE_3CC    cell_stats_check=True    ue_stats_check=True
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_TPUT_COUNTER}
    Thoughput Validation For IWF    SA_UE_3CC    SA    ${achieved_dl[0]}

Fetch Dictionary Values
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

Enable BeamForming IWF
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0,2,3,4,5 ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-120
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=3 ueBeamIndexInitial\=2,0,1,3,4,5 ssbeam_bestbeam\=2 ssbeam_rsrp_best\=-50 ssbeam_rsrp_avg\=-125
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=4 ueBeamIndexInitial\=3,0,1,2,4,5 ssbeam_bestbeam\=3 ssbeam_rsrp_best\=-55 ssbeam_rsrp_avg\=-120
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=5 ueBeamIndexInitial\=4,0,1,2,3,5 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-60 ssbeam_rsrp_avg\=-139
    ute_wtssim.Execute Egate Command
    ...    beam_control_testmode_nr profile_id\=6 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-65 ssbeam_rsrp_avg\=-70

Start Register and Traffic
    [Arguments]    ${test_tag}    ${cell_stats_check}=False    ${ue_stats_check}=False
    Log To Console    Executing ${test_tag} TC
    Set Test Variable    ${test_tag}    ${test_tag}
    ${ue_stats_check}=    Run Keyword If    '${ue_stats_check}' == 'True'
    ...    Enable UE NR Stats Check
    ...    ELSE
    ...    Set Variable    False
    ${stats_check}    Set Variable If    '${cell_stats_check}' == 'True' or '${ue_stats_check}' == 'True'    True    False
    Run Keyword If    '${stats_check}' == 'True'    Prevars_For_UE_Cell_Stats
    Run Keyword If    '${IWF_TDD_ECPRI72E}' == 'True'    ute_wtssim.Execute Egate Command    ${WTS_TC_CMD}
    ...    ELSE    ute_wtssim.Execute Egate Command
    ...    seq_start rate\=1 id\=${ID} detailed_print\=on duration\=${SE_DURATION} max_active_ues\=${MAX_ACTIVE_UES}
    ...    timeout=10s
    Sleep    ${SCRIPT_COMPLETE_TIME}
    Check IWF Status
    Run Keyword If    '${stats_check}' == 'True'    Calculate_UE_IDs_From_Egate_Logs
    FOR    ${trf_loop}    IN RANGE    1    ${perf_trf_duration}+1    1
        Sleep    1m
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword If    '${active_ues_total}' == '0'    FAIL    msg=Active No Of UEs are zero
        Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${trf_loop}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${perf_trf_duration}   ${trf_loop}
        Run Keyword If    (${trf_loop} == 5 or ${trf_loop} == 10) and '${cell_stats_check}' == 'True'
        ...    Display_Cell_Stats_Data_Rates
        Run Keyword If    (${trf_loop} == 5 or ${trf_loop} == 10) and '${ue_stats_check}' == 'True'
        ...    Display_UE_Stats_NR
    END
    ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
    Check IWF Status

Prevars_For_UE_Cell_Stats
    Set Test Variable    ${start_pattern}    ${test_tag}_script_started
    Set Test Variable    ${end_pattern}    ${test_tag}_script_completed
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    ute_wtssim.Execute Egate Command    echo ${test_tag}_script_started!!!

Calculate_UE_IDs_From_Egate_Logs
    ute_wtssim.Execute Egate Command    echo ${test_tag}_script_completed!!!
    ${sa_ue_ids}    extract_ue_ids_from_egate    file_path=${WTS_DIR}/egate_console.log    pattern=Established PDU session
    ...   start_line=${start_pattern}    end_line=${end_pattern}
    ${nsa_ue_ids}    extract_ue_ids_from_egate    file_path=${WTS_DIR}/egate_console.log    pattern=SgNB Modification is successful
    ...   start_line=${start_pattern}    end_line=${end_pattern}
    Set Suite Variable    ${sa_ue_ids}
    Set Suite Variable    ${nsa_ue_ids}

Validate_UE_And_Cell_Stats
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

Execute UE STATS NR
    ute_wtssim.Execute Egate Command    ue_stats_nr id\=${stats_id} scell\=${stats_scell} type\=${stats_type}

Attach MultiUE For Multiple sequence IWF
    ute_wtssim.Execute Egate Command    filter_sim_rfm disable\=all
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=CSI,ACR,OERR,IERR
    ute_wtssim.Execute Egate Command    seq_start rate\=2 id\=${ID} detailed_print\=on duration\=${SE_DURATION} max_active_ues\=${MAX_ACTIVE_UES}
    ...    timeout=10s
    Sleep    ${SCRIPT_COMPLETE_TIME}
    ute_wtssim.Execute Egate Command    seq_start rate\=2 id\=${ID1} detailed_print\=on duration\=${SE_DURATION1} max_active_ues\=${MAX_ACTIVE_UES1}
    ...    timeout=10s
    Sleep    ${SCRIPT_COMPLETE_TIME1}
    Check IWF Status
    FOR    ${trf_loop}    IN RANGE    1    ${perf_trf_duration}+1    1
        Sleep    1m
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword If    '${active_ues_total}' == '0'    FAIL    msg=Active No Of UEs are zero
        Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${trf_loop}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${perf_trf_duration}   ${trf_loop}
    END
    ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
    Check IWF Status
    ute_wtssim.Execute Egate Command    filter_sim_rfm enable\=all

Fetch Counter Values IWF
    [Arguments]    ${counter_name}
    ${counter_values}=    Get RLC PM Counter Values for IWF    ${counter_name}
    ${final_converted_values}=    Run Keyword    Convert Counter Values    ${counter_values}
    [Return]    ${final_converted_values}

Thoughput Validation For IWF
    [Arguments]    ${test_tag}    ${sa_nsa}    ${dl_tput}=0    ${ul_tput}=0
    ${dl_tput_status}=    Evaluate    ${dl_tput} >= (${OVERALL_DL}*${DL_LIMIT})
    ${ul_tput_status}=    Evaluate    ${ul_tput} >= (${OVERALL_UL}*${UL_LIMIT})
    ${dl_tput}=    Evaluate    "%.2f" % ${dl_tput}
    ${ul_tput}=    Evaluate    "%.2f" % ${ul_tput}
    Log To Console    Achieved ${sa_nsa} DL Tput ${dl_tput}
    Log To Console    Achieved ${sa_nsa} UL Tput ${ul_tput}
    Validate Tput Active UE and Evaluate
    ...    ${test_tag}    ${dl_tput_status}    ${ul_tput_status}    ${dl_tput}    ${ul_tput}

Set UL SINR Test Mode
    ute_wtssim.Execute Egate Command    ul_sinr_testmode_nr profile_id\=${PROFILE_ID} sinr_target_srs\=${TARGET_SRS} noise_srs\=${NOISE_SRS}

Enable Test Mode SINR
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=${TESTMODE_NR_ID} testmode\=${TESTMODE} action\=activate profile_id\=${PROFILE_ID}

Set UE Beam Position
    ute_wtssim.Execute Egate Command    ue_srs_beam_pos_nr profile_id\=1 srsMode\=fixed init_pos\=0
    ute_wtssim.Execute Egate Command    ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=1
    ute_wtssim.Execute Egate Command    ue_srs_beam_pos_nr profile_id\=3 srsMode\=fixed init_pos\=2
    ute_wtssim.Execute Egate Command    ue_srs_beam_pos_nr profile_id\=4 srsMode\=fixed init_pos\=3

Activate Test Mode Profile
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=526-535 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=536-545 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=546-555 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=556-565 testmode\=ue_srs_beam_pos action\=activate profile_id\=4

Enable Test Mode Profile
    ute_wtssim.Execute Egate Command
    ...    script file\=/${MULTI_UE_SCRIPT_NEW} entry\=/${LUA_METHOD}(${TEST_MODE_PARAMS})

Get TAF PM Counter Files
    [Arguments]    ${target_dir}    ${name}=gnb_pm_counters    ${duration}=5 minutes
    Log To Console    Download gNB PM Counters...
    ${webservice}=    Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    gnb_pmcounters.create PM collector    name=${name}    webservice=${webservice}    for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Get RLC PM Counter Values for IWF
    [Arguments]    ${counter}    # ex. "M55310C01006" or "M55310C01006,M55310C01007"
    ${counter_value}=    Create List
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ${pm_file}=       SSH.Execute    ls -lrt /tmp/PM.*.ANY.xml.gz | tail -1 | awk '{print $9}'    ${GNB_ASIK.Connection}
    ${pm_file}=       Fetch From Left    ${pm_file}    \r
    ${xml}=           SSH.Execute    zcat ${pm_file}    ${GNB_ASIK.Connection}
    @{counters}=          Split String    ${counter}    ,
    ${lists_vals}=         Create List
    FOR    ${counter}    IN    @{counters}
        ${counter}=       Strip String    ${counter}
        ${vals}=      Extract Single Counter Values From XML    ${xml}    ${counter}
        Append To List    ${lists_vals}    ${vals}
    END
    # If multiple counters, sum counter-wise per cell; else take the single counter
    ${num_lists}=     Get Length    ${lists_vals}
    ${final}=    Run Keyword If    ${num_lists} > 1
    ...    Sum Counters Per Cell    @{lists_vals}
    ...    ELSE
    ...    Set Variable    ${lists_vals[0]}
    [Return]    ${final}

Extract Single Counter Values From XML
    [Arguments]    ${xml}    ${tag}
    ${matches}=    Get Regexp Matches    ${xml}    \<${tag}\>([0-9]+)
    ${values}=     Create List
    FOR    ${match}    IN    @{matches}
        ${counter_string}=    Convert to String    ${match}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${val}=      Convert To Integer    ${counter_string}
        Append To List    ${values}    ${val}
    END
    [Return]    ${values}

Sum Counters Per Cell
    [Arguments]    @{lists}
    ${count}=     Get Length    ${lists[0]}
    FOR    ${seq}    IN    @{lists}
        ${len}=     Get Length    ${seq}
        Run Keyword If    ${len} != ${count}
        ...    Fail    RLC counter lists have mismatched lengths: expected ${count}, got ${len}
    END
    ${summed}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${cell_sum}=    Set Variable    0
        FOR    ${seq}    IN    @{lists}
            ${cell_sum}=  Evaluate    ${cell_sum} + ${seq[${i}]}
        END
        Append To List    ${summed}    ${cell_sum}
    END
    [Return]    ${summed}

Copy Lua file IWF
    ${cmd}=    Catenate    cp ${EXECDIR}/custom_configs/${ute_ca_variant}/basic.lua
    ...    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run    ${cmd}
    Run    mv ${WTS_DIR}/basic.lua ${WTS_DIR}/sansa.lua
    Set Suite Variable    ${SUITE_WTS_CFG}

Convert Counter Values
    [Arguments]    ${counter}
    ${achieved_counters}=    Create List
    FOR    ${value}    IN    @{counter}
        ${achieved_tput}=   Evaluate    (${value}*8/300000)
        Append To List    ${achieved_counters}    ${achieved_tput}
    END
    Log    ${achieved_tput}
    [Return]    ${achieved_counters}

SA MU-MIMO 40 UE Register and Traffic DL 3200Mbps and UL 200Mbps 1208FF 256QAM 8x4 BF 100Mhz
    Fetch Dictionary Values    ${SA_40_UE_MIMO}
    Set UL SINR Test Mode
    Sleep    5s
    Enable Test Mode SINR
    Sleep    5s
    Set UE Beam Position
    Sleep    5s
    Activate Test Mode Profile
    Sleep    5s
    Start Register and Traffic    SA_40    cell_stats_check=True    ue_stats_check=True
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul}    Fetch Counter Values IWF    ${SA_UL_TPUT_COUNTER}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_dl}    ${achieved_ul}
        Run Keyword If    '${tput_dl}' != '0' and '${tput_ul}' != '0'    Thoughput Validation For IWF    SA_40    SA
        ...    ${tput_dl}    ${tput_ul}
    END

SA Throughput Check for IWF
    [Arguments]    ${tag}
    ${cell}=    Set Variable    0
    ${achieved_sa_dl}    Fetch Counter Values IWF    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_sa_ul}    Fetch Counter Values IWF    ${SA_UL_CELL_RLC_COUNTER}
    Evaluate Total TPut    ${achieved_sa_dl}      ${achieved_sa_ul}    ${tag}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_sa_dl}    ${achieved_sa_ul}
        ${cell}=    Evaluate    (${cell}+1)
        ${tput_dl}=    Evaluate    (${tput_dl}/1000)
        ${tput_ul}=    Evaluate    (${tput_ul}/1000)
        Run Keyword And Continue On Failure    Thoughput Validation Intermediate   ${tag}_${cell}    SA
        ...    ${tput_dl}    ${tput_ul}
    END

NSA Throughput Check for IWF
    [Arguments]    ${tag}
    ${cell}=    Set Variable    0
    ${achieved_nsa_dl}    Fetch Counter Values IWF    ${NSA_DL_CELL_RLC_COUNTER}
    ${achieved_nsa_ul}    Fetch Counter Values IWF    ${NSA_UL_CELL_RLC_COUNTER}
    Evaluate Total TPut    ${achieved_nsa_dl}      ${achieved_nsa_ul}    ${tag}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_nsa_dl}    ${achieved_nsa_ul}
        ${cell}=    Evaluate    (${cell}+1)
        ${tput_dl}=    Evaluate    (${tput_dl}/1000)
        ${tput_ul}=    Evaluate    (${tput_ul}/1000)
        Run Keyword And Continue On Failure    Thoughput Validation Intermediate     ${tag}_${cell}    NSA
        ...    ${tput_dl}    ${tput_ul}
    END

Thoughput Validation Intermediate
    [Arguments]    ${tag_name}    ${sa_nsa}    ${tput_dl}    ${tput_ul}
    Run Keyword If    '${tput_dl}' != '0' and '${tput_ul}' != '0'    Thoughput Validation For IWF    ${tag_name}    ${sa_nsa}
    ...    ${tput_dl}    ${tput_ul}

NSA Detach
    ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${MULTI_UE_SCRIPT_NEW} entry\=sgnb_release_multi_ue_with_range(${NSA_CELL1_RANGE},2)
    ...    pass_regexp=SgNB Release is successful    timeout=200
    Sleep    20s
    ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${MULTI_UE_SCRIPT_NEW} entry\=sgnb_release_multi_ue_with_range(${NSA_CELL2_RANGE},2)
    ...    pass_regexp=SgNB Release is successful    timeout=200
    Sleep    20s
    ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${MULTI_UE_SCRIPT_NEW} entry\=lte_detach_multi_ue_with_range(${NSA_CELL1_RANGE})
    ...    pass_regexp=detached successfully    timeout=200
    Sleep    20s
    ${ouput}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${MULTI_UE_SCRIPT_NEW} entry\=lte_detach_multi_ue_with_range(${NSA_CELL2_RANGE})
    ...    pass_regexp=detached successfully    timeout=200
    Sleep    20s

Upload Lua File for DSS IWF
    [Arguments]    ${dictionary_name}
    Fetch Dictionary Values    ${dictionary_name}
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Sleep    1m
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${ng_link_up_pattern}    ${ng_link_count}
    Sleep    10s
    ute_wtssim.Execute Egate Command And Wait For Data    script file\=commands.lua entry\=DSS_xp_connections()
    ...    pass_regexp=XpAP Link with GNB-2.* is up    timeout=10minutes
    Sleep    20s
    ute_wtssim.Execute Egate Command    script file\=commands.lua entry\=DSS_cell_setup()
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}
    ...    ${iwf_cells}
    Sleep    20s
    Check SIB Messages for All Cells    ${NO_OF_CELLS}
    ute_wtssim.Execute Egate Command    sim_debug_log level\=3 app_type\=ueproxy
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Upload Lua File for Non DSS IWF
    [Arguments]    ${dictionary_name}
    Fetch Dictionary Values    ${dictionary_name}
    ute_wtssim.Execute Egate Command    ${wts_cfg_load_command}    timeout=10minutes
    Sleep    1m
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${ng_link_up_pattern}    ${ng_link_count}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${NO_OF_CELLS}
    Check SIB Messages for All Cells    ${NO_OF_CELLS}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Attach Multi UE for Multi Cell SA 40 UE
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values    ${DSS_FDD_40UE}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Start Register and Traffic    SANSA_40_UE
    ${active_ues_total}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Append To File     ${test_property_file}    ${\n}20_UEs=${active_ues_total[0]}${\n}
    ${achieved_sa_dl_tput}    Validate Perf Tput via RLC gNB counter    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_sa_ul_tput}    Validate Perf Tput via RLC gNB counter    ${SA_UL_CELL_RLC_COUNTER}
    ${achieved_sa_dl_tput}=    Convert the data    ${achieved_sa_dl_tput}
    ${achieved_sa_ul_tput}=    Convert the data    ${achieved_sa_ul_tput}
    ${achieved_dl_tput}=    Convert to Integers and Calculate Tput    ${achieved_sa_dl_tput}    DL    SA_40UE_4CELL
    ${achieved_ul_tput}=     Convert to Integers and Calculate Tput    ${achieved_sa_ul_tput}   UL    SA_40UE_4CELL
    Thoughput Validation for UL and DL    SA_40UE_4CELL    SA    ${achieved_dl_tput}    ${achieved_ul_tput}

Convert to Integers and Calculate Tput
    [Arguments]    ${my_list}    ${dir}    ${tag}
    FOR    ${cell}    IN RANGE    ${component_carrier}
        ${cell_tput}=    Evaluate    "%.2f" % ${my_list}[${cell}]
        Log To Console    Printing Cell ${cell+1} ${dir} TPut:${cell_tput}
        Append To File     ${test_property_file}    ${\n}${cell+1}_${dir}_${tag}=${cell_tput}${\n}
    END
    ${sum}=    Evaluate    sum([int(item) for item in @{my_list}])
    [Return]    ${sum}

Attach Multi UE for Multi Cell SA 152 UE
    [Documentation]    This Keyword does NSA UE attach for all NSA UEs and start traffic
    Fetch Dictionary Values   ${DSS_FDD_152}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Start Register and Traffic    SANSA_152_UE
    ${active_ues_total}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Log To Console    Number of ACTIVE SA UEs is ${active_ues_total[0]}
    Append To File     ${test_property_file}    ${\n}152_UEs=${active_ues_total[0]}${\n}
    ${active_sa}=    Create List
    Set Suite Variable    @{active_sa}
    ${status}=    Run Keyword If    '${active_ues_total[0]}' != '${END_UE}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected
    ute_wtssim.Execute Egate Command    script_stop

Kill Alias of WTSSIM egate and Edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown egate
    Run Keyword And Ignore Error    ute_wtssim.Teardown edaemon    alias=edaemon

gNB Snapshot Collection via adminAPI
    [Timeout]    25 minutes
    Log To Console    Collecting gNB Snapshot via admin API
    ${timestamp}                  Get Current Date    result_format=%d.%m_%H-%M
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.Get Snapshot    target_file_name=${EXECDIR}/logs/Snapshot_MRBTS-1_${timestamp}.zip
    ...                       timeout=20 mins
    File Should Exist         ${EXECDIR}/logs/Snapshot_MRBTS-1_${timestamp}.zip
    [Teardown]    CoamAdmin.Teardown

Attach Multi_UE for IWF DL
    [Arguments]    ${dictionary_name}    ${tag}
    Fetch Dictionary Values    ${dictionary_name}
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    Start Register and Traffic    ${tag}
    ${achieved_sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    Run Keyword If    '${achieved_sa_dl_tput}' != '0'    Thoughput Validation For IWF     ${tag}    SA
    ...    ${achieved_sa_dl_tput}    0

Clone and Configure topologyconfig repo IWF
    ${command}    Catenate    rm -rf ${AP_configs} &&
    ...    git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    ${rc_clone}    ${output_clone}    Run And Return Rc And Output    ${command}
    Should Be Equal As Integers    ${rc_clone}    0    msg=git clone command failed with error code ${rc_clone}
    ${command}    Catenate    cd ${AP_configs} && git checkout ${TOPOLOGY_BRANCH_VALUE} && git pull origin
    ...    && git config user.email I_MN_5G_AIRPHONE_CI@nokia.com && git config user.name ca_5gair
    Run And Return Rc And Output    ${command}

Attach SA UE
    [Arguments]    ${dictionary_name}    ${tag}
    Fetch Dictionary Values    ${dictionary_name}
    Register and Traffic for PET SE IWF
    ${achieved_sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    Run Keyword If    '${achieved_sa_dl_tput}' != '0'    Thoughput Validation For IWF     ${tag}    SA
    ...    ${achieved_sa_dl_tput}    0

Attach SA_SUE for 8CELL 1216UE
    Fetch Dictionary Values    ${SA_1216UE_NON_DSS}
    Register and Traffic for PET SE IWF
    ${active_sa}=    Create List
    ${status}=    Run Keyword If    '${active_ues_total}' != '${END_UE}'    Set Variable    FAIL
    Append To List    ${active_sa}    ${status}
    Write Active No of UEs To Test Proprties File
    List Should Not Contain Value    ${active_sa}    FAIL    msg=Active No Of UEs are Less than expected

Attach SA_UE for 8CELL
    [Arguments]    ${dictionary_name}    ${tag}
    Fetch Dictionary Values    ${dictionary_name}
    Register and Traffic for PET SE IWF
    Fetch and Validate RLC Counters
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul}    Fetch Counter Values IWF    ${SA_UL_TPUT_COUNTER}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_dl}    ${achieved_ul}
        Run Keyword If    '${tput_dl}' != '0' and '${tput_ul}' != '0'    Thoughput Validation For IWF    ${tag}    SA
        ...    ${tput_dl}    ${tput_ul}
    END

Attach SA_20UE for 8CELL
    Attach SA_UE for 8CELL    ${SA_20UE_NON_DSS}    SA_20UE

Attach SA_SUE for 8CELL
    Attach SA_UE for 8CELL    ${SA_SUE_NON_DSS}    SA_SUE

Attach SA_SUE for MULTI_CELL
    Attach SA_UE for 8CELL    ${SA_CA_80UE_NON_DSS}    SA_CA_80UE

Evaluate Total TPut
    [Arguments]     ${achieved_dl}      ${achieved_ul}    ${tag}
    ${achieved_dl_tput}=    Evaluate    ((sum([int(item) for item in @{achieved_dl}]))/1000)
    ${achieved_ul_tput}=    Evaluate    ((sum([int(item) for item in @{achieved_ul}]))/1000)
    ${achieved_dl_tput}=    Evaluate    "%.2f" % ${achieved_dl_tput}
    ${achieved_ul_tput}=    Evaluate    "%.2f" % ${achieved_ul_tput}
    Log To Console    Achieved Total Tput DL ${achieved_dl_tput}
    Log To Console    Achieved Total Tput UL ${achieved_ul_tput}
    Append To File     ${test_property_file}    ${\n}${tag}_DL_Tput=${achieved_dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}${tag}_UL_Tput=${achieved_ul_tput}${\n}

Register and Traffic for PET SE IWF
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${entry}    timeout=300
    Wait Until Keyword Succeeds    20min    1min    Check Script Completion in Egate Console    ${SCRIPT_COMPLETE}
    Check IWF Status
    FOR    ${trf_loop}    IN RANGE    1    ${perf_trf_duration}+1    1
        Sleep    1m
        Run Keyword If    '${IWF_FDD_CA_DSS}' == 'True'    Execute UE STATS NR
        Check IWF Status
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Log To Console    Number of ACTIVE SA UEs is ${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${trf_loop}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${perf_trf_duration}   ${trf_loop}
        Run Keyword If    '${active_ues[0]}' == '0'    FAIL    msg=Active No Of UEs are zero
    END

10 SA and 10 NSA Register Attach and Traffic DL 3248Mbps and UL 1680Mbps
    Fetch Dictionary Values    ${SANSA_10UE_NON_DSS}
    ute_wtssim.Execute Egate Command    enb_x2_link_up enb\=1 target\=2
    ute_wtssim.Execute Egate Command    uec_l2_testmode_params fixed_csi_report\=true
    ute_wtssim.Execute Egate Command    seq_start rate\=1 id\=${ID} detailed_print\=on duration\=${SE_DURATION} max_active_ues\=${MAX_ACTIVE_UES}
    ...    timeout=10s
    Sleep    30s
    Run    cp ${CURDIR}/../scripts/PET_SE_IWF/multi_ue_sa_script_new.lua /opt/wts/latest/multi_ue_sa_script_new.lua
    ${MULTI_UE_SCRIPT_WTS}    Set Variable    /opt/wts/latest/multi_ue_sa_script_new.lua
    ute_wtssim.Execute Egate Command    script file\=${MULTI_UE_SCRIPT_WTS} entry\=${LUA_METHOD}(${CELL2})
    Wait Until Keyword Succeeds    5min    1min    Check Occurances in Egate Console    ${Trf_validation_string}
    ...    1
    ute_wtssim.Execute Egate Command
    ...    seq_start rate\=1 id\=${ID_SA_NSA} detailed_print\=on duration\=${SE_DURATION_SA_NSA} max_active_ues\=${MAX_UES_SA_NSA}    timeout=10s
    Sleep    20s
    FOR    ${cell}    IN RANGE    3    ${NO_OF_CELLS}+1
        ute_wtssim.Execute Egate Command    script file\=${MULTI_UE_SCRIPT_WTS} entry\=${LUA_METHOD}(${SA_NSA_CELL${cell}})
        ${count}=    Evaluate    str(${cell}-1)
        ${count}    Convert To String    ${count}
        Wait Until Keyword Succeeds    5min    1min    Check Occurances in Egate Console    ${Trf_validation_string}
         ...    ${count}
    END
    Check IWF Status
    ${nsa_mue_id_list}=    Run Keyword    UE List creation    ${FirstUE}    ${ENDUE}
    FOR    ${trf_loop}    IN RANGE    1    ${perf_trf_duration}+1    1
        Sleep    1m
        Check IWF Status
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
        Check SA UE Count
        Log To Console    Number of ACTIVE UEs is ${active_ues[0]}
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${trf_loop}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${perf_trf_duration}   ${trf_loop}
        Run Keyword If    '${active_ues[0]}' == '0'    FAIL    msg=Active No Of UEs are zero
    END
    Validate NSA UE Connectivity at gNB     ${nsa_mue_id_list}
    Check SA UE Count
    Run Keyword And Continue On Failure    Validate Active UE for SANSA    NSA_80_UEs    SA_80_UEs
    ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Log To Console    Number of ACTIVE UEs is ${active_ues[0]}
    Check IWF Status
    ${nsa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${NSA_DL_gNB_COUNTER}
    ${nsa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${NSA_UL_gNB_COUNTER}
    Set Suite Variable    ${DL_LIMIT}    ${DL_LIMIT_SA}
    Set Suite Variable    ${OVERALL_DL}    ${OVERALL_DL_SA}
    ${sa_dl_tput}    Validate Perf Tput via gNB counter    dl    ${SA_DL_TPUT_COUNTER}
    ${sa_ul_tput}    Validate Perf Tput via gNB counter    ul    ${SA_UL_TPUT_COUNTER}
    Run Keyword And Continue On Failure    Thoughput Validation Intermediate   SA_80UE    SA
    ...    ${sa_dl_tput}    ${sa_ul_tput}
    Run Keyword And Continue On Failure    Thoughput Validation Intermediate   NSA_80UE    NSA
    ...    ${nsa_dl_tput}    ${nsa_ul_tput}

Deregister Non DSS
    Deregister NSA MultiUE IWF    ${SANSA_10UE_NON_DSS}
    Deregister PET

Get TargetBD File
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ${tgtb_file}=    SSH.Execute    ls -lrt /ffs/run/TargetBD_*.xml    ${GNB_ASIK.Connection}
    ${file_name}=    Fetch from Left    ${tgtb_file}    \r
    ${file_name_output}=    Fetch from Right    ${file_name}    /ffs/run/
    Download File    ${remote_paths}/${file_name_output}    ${targetbd_file}/${file_name_output}    ${GNB_ASIK.Connection}
    Update Iphy File Iwf    ${file_name_output}

Update Iphy File Iwf
    [Arguments]    ${file_name_output}
    ${script_file_path_py}=    Set Variable    ${EXECDIR}/robotws/testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/update_iphy_swversion.py
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    ${command}        Catenate     python3 ${script_file_path_py}   -i ${targetbd_file}/${ute_ca_variant}/iphy.xml
    ...    -t  ${targetbd_file}/${file_name_output}
    Run    ${command}
    Sleep    2s
    SSH.Upload File    ${targetbd_file}/${ute_ca_variant}/iphy.xml    /user/toor4nsn/updated_iphy.xml    ${AP_ASIK.Connection}
    SSH.Send Command    scp /user/toor4nsn/updated_iphy.xml /ffs/run/simmode; ln -f -s /ffs/run/simmode/updated_iphy.xml /ffs/run/simmode/iphy.xml
    ...    timeout=60    connection=${AP_ASIK.Connection}

Environment Setup for PET IWF
    [Arguments]    ${tc_name}    ${test_dict}=None
    ${is_dict}=    Evaluate    isinstance(${test_dict}, dict)
    Run Keyword If    ${is_dict}   Fetch Dictionary Values    ${test_dict}
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'    IWF Test Case teardown    ${tc_name}
    Run Keyword If    '${TRF_PERF_BIP_LOGS}' == 'True'    Copy logs to IWF Logs
    Run Keyword If    '${tc_name}' == 'SA_CA_80UE'
    ...    Set Suite Variable    ${ute_ca_variant}    ${ute_ca_variant_ca_dss}
    ...    ELSE IF    '${tc_name}' == 'SUE_PER_CELL_SANSA_ECPRI72E'
    ...    Set Suite Variable    ${ute_ca_variant}    ${ute_ca_variant_tc4}
    ...    ELSE
    ...    Set Suite Variable    ${ute_ca_variant}    ${ute_ca_variant_dss}
    Set Suite Variable    ${AP_configs}     ${EXECDIR}/topologyconfigs/
    Clone and Configure topologyconfig repo IWF
    Run    cp -r ${EXECDIR}/topologyconfigs/${ute_ca_label}/SBTS00/${ute_ca_variant} ${EXECDIR}/custom_configs/
    Run    cp -r ${EXECDIR}/topologyconfigs/${ute_ca_label}/SBTS00/${ute_ca_variant} ${EXECDIR}/logs/custom_configs/
    Get TargetBD File
    Run    rm -f ${targetbd_file}/TargetBD_*.xml
    Run Keyword If    '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_CA_DSS_AP_PERF'
    ...    Initial Setup for PET Test Cases    DSS_CA_IWF
    ...    ELSE IF   '${IWF_FR1_LOO_LOOO}' == 'True'     Initial Setup for PET Test Cases    SA_SUE_6CC_IWF
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CPRI_CMWV_1S_4CC_FDD_CA_AP_PERF'
    ...    Initial Setup for PET Test Cases    SA_CA_20UE
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_CPRI_CMWV_FDD_MIX_BAND_DL_UL_CA_AP_PERF'
    ...    Initial Setup for PET Test Cases    SA_CA_80UE
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_NSA_FS_ECPRI_MMWV_TDD_NONBF_AP_PERFORMANCE'
    ...    Initial Setup for PET Test Cases    NSA_10UEs
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_SANSA_ECPRI72E_CMWV_TDD_50MHz_AP_PERF'
    ...    Initial Setup for PET Test Cases    ${tc_name}
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_AP_PERFORMANCE'
    ...    Initial Setup for PET Test Cases    ${tc_name}
    ...    ELSE IF   '${ute_ca_variant}' == 'PRIVATE_SA_FS_ECPRI_MMWV_TDD_AP_PERF'
    ...    Initial Setup for PET Test Cases    ${tc_name}

SA SUE 5CC Register and Traffic DL 4500Mbps UL 250Mbps 1208FF
    Common Register Traffic and Validation    ${SA_SUE_5CC}    SA_SUE_5CC

Common Register Traffic and Validation
    [Arguments]    ${tc_dictionary}    ${test_tag}
    ${TRF_DURATION}    Get Variable Value    ${PET_DURATION}    ${perf_trf_duration}
    Set Suite Variable    ${perf_trf_duration}    ${TRF_DURATION}
    Fetch Dictionary Values    ${tc_dictionary}
    Start Register and Traffic    ${test_tag}
    ${achieved_dl}    Fetch Counter Values IWF    ${SA_DL_TPUT_COUNTER}
    ${achieved_ul}    Fetch Counter Values IWF    ${SA_UL_TPUT_COUNTER}
    FOR    ${tput_dl}    ${tput_ul}    IN ZIP    ${achieved_dl}    ${achieved_ul}
        Run Keyword If    '${tput_dl}' != '0' and '${tput_ul}' != '0'    Thoughput Validation For IWF    ${test_tag}    SA
        ...    ${tput_dl}    ${tput_ul}
    END

SA 40UE 5CC Register and Traffic DL 5000Mbps UL 248Mbps 1208FF
    Common Register Traffic and Validation    ${SA_40_5CC}    SA_40_UE_5CC

Validate Tput and evaluate
    [Arguments]    ${test_tag}    ${dl_tput_status}    ${ul_tput_status}    ${dl_tput}    ${ul_tput}
    ${pm_counter_status}=    Create List
    Append To File     ${test_property_file}    ${\n}${test_tag}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}${test_tag}_UL=${ul_tput}${\n}
    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${pm_counter_status}    ${status_ul[0]}
    List Should Not Contain Value    ${pm_counter_status}    FAIL    msg=Traffic failed in Throughput, see error above!

Validate Tput Active UE and Evaluate
    [Arguments]    ${test_tag}    ${dl_tput_status}    ${ul_tput_status}    ${dl_tput}    ${ul_tput}
    ${tput_ue_status}=    Create List
    Append To File     ${test_property_file}    ${\n}${test_tag}_UE=${active_ues_total}/${EXPECTED_UE_COUNT}${\n}
    Append To File     ${test_property_file}    ${\n}${test_tag}_DL=${dl_tput}${\n}
    Append To File     ${test_property_file}    ${\n}${test_tag}_UL=${ul_tput}${\n}
    ${status_dl}    Run Keyword And Ignore Error   Should Be True    '${dl_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_ue_status}    ${status_dl[0]}
    ${status_ul}    Run Keyword And Ignore Error   Should Be True    '${ul_tput_status}' == 'True'
    ...    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_ue_status}    ${status_ul[0]}
    ${ue_check}=    Evaluate    '${active_ues_total}' == '${EXPECTED_UE_COUNT}'
    Should Be Equal    '${ue_check}'    'True'    msg=Active UEs are less than expected
    ${ue_status}=    Run Keyword And Ignore Error   Should Be True    '${ue_check}' == 'True'
    ...    msg=failed in active UE check, see error above!
    Append To List    ${tput_ue_status}    ${ue_status[0]}
    List Should Not Contain Value    ${tput_ue_status}    FAIL    msg=Criteria Not Met

Enable L2 Testmode Params
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=l2_testmode_param    timeout=300

Check SIB Messages for All Cells With UEC
    [Arguments]    ${cells}
    ...    ${command}=grep "Number of Expected SIBs" /opt/wts/latest/egate_console.log | tr "|" "\n"
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs_withUECcount(1,${cells},${UEC_COUNT})
    ...    pass_regexp=Total SIBs received    timeout=${SIB_TIMEOUT}
    ${result}     Run    ${command}
    ${result_list}=    Create List    ${result.split("\n")}
    @{expected_SIB}=    Split String    ${result_list[0][2]}    :
    @{received_SIB}=    Split String    ${result_list[0][3]}    :
    Should Be Equal As Integers    ${expected_SIB[1]}    ${received_SIB[1]}    msg=SIB not received

Collect AP Snapshot During Test
    [Arguments]    ${duration}    ${count}
    ${result}=    Evaluate    int(${duration}/2)
    Run Keyword If    '${count}' == '${result}'    Run Keyword And Ignore Error    Collect and Download AP Snapshot    ${TEST_NAME}

Collect and Download AP Snapshot
    [Arguments]    ${tcname}
    ${tcname}=    Remove String    ${tcname}    &
    ${tcname}=    Replace String    ${tcname}    ${SPACE}    _
    Run    mkdir -p ${EXECDIR}/logs/AP_Snapshot
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...    alias=${AP_ASIK.Connection}
    SSH.execute    command=echo "log -a -z snapshot.zip" | nc 0 15007
    ...    connection=${AP_ASIK.Connection}
    Download File    /tmp/snapshot.zip    ${EXECDIR}/logs/AP_Snapshot/${tcname}.zip    ${AP_ASIK.Connection}
    Run    gzip ${EXECDIR}/logs/AP_Snapshot/${tcname}.zip
    ssh.Disconnect    ${AP_ASIK.Connection}

Reset AP gNB and Check Ready State
    ${status}    Run Keyword And Return Status    Reset and Check Ready State
    Run Keyword If    '${status}' == 'False'    Reset and Check Ready State

Enable L2L3 BIP Log
    Run    sed -i "s/SYSCOM_MIRRORING='false'/SYSCOM_MIRRORING='true'/" ${gNB_Mirroring_script}

Copy logs to IWF Logs
    Run    mkdir ${EXECDIR}/IWF_Logs/
    Run    cp ${EXECDIR}/logs/SosReport*.tgz ${EXECDIR}/IWF_Logs/

Move SosReport from IWF_Logs to Log
    Run    mv ${EXECDIR}/IWF_Logs/SosReport*.tgz ${EXECDIR}/logs/

SA Register 3CC SUE
    Initial Setup for PET Test Cases    SA_1_UE_3CC
    SA Register in PET SE Format    ${SA_1_UE_3CC}    SA_1_UE_3CC
    ${achieved_dl_tput}    Run Keyword    Validate Perf Tput via gNB counter for PET
    ...    dl    ${SA_DL_TPUT_COUNTER}
    Validate Traffic    SA_1_UE_3CC    ${achieved_dl_tput}    dl

Display Tput values
    [Arguments]    ${tput_list}    ${dir}
    ${updated_list}=    Create List
    FOR    ${value}    IN    @{tput_list}
        ${result}=    Evaluate    ${value}/1000
        Append To List    ${updated_list}    ${result}
    END
    FOR    ${cell}    IN RANGE    ${component_carrier}
        ${cell_tput}=    Evaluate    "%.2f" % ${updated_list}[${cell}]
        Log To Console    Cell ${cell+1} ${dir} TPut:${cell_tput}
    END

Fetch and Validate RLC Counters
    ${achieved_dl_rlc}    Fetch Counter Values IWF    ${SA_DL_CELL_RLC_COUNTER}
    ${achieved_ul_rlc}    Fetch Counter Values IWF    ${SA_UL_CELL_RLC_COUNTER}
    Display Tput values    ${achieved_dl_rlc}    DL
    Display Tput values    ${achieved_ul_rlc}    UL

Get L2stream logs using Sbts cOAM cli using nr_phy_cell_ids
    ${webservice}=    Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    ${l2_stream_config_2}=  Create Dictionary
    ...  nr_phy_cell_ids=50,51,52,53
    ...  up_sw=L2Lo
    ...  trace_type=Component
    ${l2_stream_config_3}=  Create Dictionary
    ...  nr_phy_cell_ids=50,51,52,53
    ...  up_sw=L2Ps
    ...  trace_type=Component
    ${l2_stream_config_4}=  Create Dictionary
    ...  up_sw=L2HiPdcp
    ...  trace_type=Component
    ${l2_stream_config_5}=  Create Dictionary
    ...  nr_phy_cell_ids=50,51,52,53
    ...  up_sw=L2HiRlc
    ...  trace_type=Component
    @{l2_stream_configuration}    Create List    ${l2_stream_config_2}    ${l2_stream_config_3}
    ...    ${l2_stream_config_4}    ${l2_stream_config_5}
    Log To Console    Startin TTI TCP Dump
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    Run Keyword And Ignore Error    l2stream3.set_global_alias    alias=l2stream3
    Run Keyword And Ignore Error    core.set_global_alias    alias=core
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3

Collect TTI Traces
    Log To Console    Collecting TTI on Big Disk
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3    target_dir=/home/ute/BIGdisk/
    Run Keyword And Ignore Error    Run    sudo mv /tmp/tcpdump* /home/ute/BIGdisk/

Validate NSA UE Connectivity at gNB
    [Arguments]    ${nsa_ue_id_list}
    ${ue_list_sa}=    Create List
    [Documentation]    This keyword is used to validate the connectivity of NSA UEs at the gNB.
    ${type}=    Evaluate    type(${nsa_ue_id_list}).__name__
    @{final_list}=    Run Keyword If    '${type}' == 'list'    Copy List    ${nsa_ue_id_list}
    Run Keyword If    '${type}' == 'int'    Append To List    ${final_list}    ${nsa_ue_id_list}
    ${start_ue}=    Get From List    ${final_list}    0
    ${end_index}=    Evaluate    len(${final_list})-1
    ${end_ue}=      Get From List    ${final_list}    ${end_index}
    ${range_string}=    Set Variable    ${start_ue}-${end_ue}

    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=off
    ute_wtssim.Execute Egate Command    set_log flush
    ${output}=    ute_wtssim.Execute Egate Command and Wait for Data    ue_disp id\=${range_string} at\=ue state\=ACTIVE type\=general_info
    ...    pass_regexp=${DC_ACTIVE_REGEXP}    timeout=10sec
    ute_wtssim.Execute Egate Command    set_log flush
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on
    ${output}      Get Lines Matching Regexp    ${output}    DC state\\s+active    partial_match=${TRUE}
    ${active_ues_total}    Get Line Count    ${output}
    Log To Console    Number of ACTIVE NSA UEs is ${active_ues_total}
    Set Suite Variable    ${active_ues_total}
    ${status}=    Run Keyword If    '${active_ues_total}' == '0'    Set Variable    FAIL
    ...    ELSE    Set Variable    PASS
    Append To List    ${ue_list_sa}    ${status}
    List Should Not Contain Value    ${ue_list_sa}    FAIL    msg=Active No Of UEs are zero

Check SA UE Count
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ue_summary    timeout=10
    ${SA_Active_UE}=    Get Regexp Matches    ${output}    ENB-2 +(\\d+)    1
    ${SA_Active_UEs}=    Set Variable    ${SA_Active_UE[0]}
    Log To Console    Active No.of SA UEs:${SA_Active_UEs}
    Run Keyword If    '${SA_Active_UEs}' == '0'    FAIL    msg=Active No Of UEs are zero
    Set Suite Variable    ${SA_Active_UEs}

Validate Active UE for SANSA
    [Arguments]    ${NSA_TAG}    ${SA_TAG}
    Append To File    ${test_property_file}    ${\n}${NSA_TAG}=${active_ues_total}${\n}
    Append To File    ${test_property_file}    ${\n}${SA_TAG}=${SA_Active_UEs}${\n}
    ${sansa_ue_status}=    Create List
    ${nsa_ue_check}=    Evaluate    '${active_ues_total}' == '${EXPECTED_UE_COUNT}'
    Should Be Equal    '${nsa_ue_check}'    'True'    msg=Active UEs are less than expected
    ${nsa_ue_status}=    Run Keyword And Ignore Error   Should Be True    '${nsa_ue_check}' == 'True'
    ...    msg=failed in active UE check, see error above!
    Append To List    ${sansa_ue_status}    ${nsa_ue_status[0]}
    ${sa_ue_check}=    Evaluate    '${SA_Active_UEs}' == '${EXPECTED_UE_COUNT}'
    Should Be Equal    '${sa_ue_check}'    'True'    msg=Active UEs are less than expected
    ${sa_ue_status}=    Run Keyword And Ignore Error   Should Be True    '${sa_ue_check}' == 'True'
    ...    msg=failed in active UE check, see error above!
    Append To List    ${sansa_ue_status}    ${sa_ue_status[0]}
    List Should Not Contain Value    ${sansa_ue_status}    FAIL    msg=Criteria Not Met

Perform Delta SCF Commissioning
    [Arguments]    ${tc_name}
    ${DELTA_CONFIG_FILE}=    Set Variable    ${CURDIR}/../scripts/delta_config.json
    ${CURRENT_CONFIG_FILE}=    Set Variable    ${CURDIR}/../scripts/current_${tc_name}.json
    ${extract_cmd}=    Catenate
    ...    python3 -c
    ...    "import json; d=json.load(open('${DELTA_CONFIG_FILE}')); json.dump(d['${tc_name}'], open('${CURRENT_CONFIG_FILE}', 'w'), indent=4)"
    ${extract_result}=    Run    ${extract_cmd}
    Should Not Contain    ${extract_result}    Traceback    msg=Failed to extract JSON config for tag: ${tc_name}
    ${commission_cmd}=    Catenate
    ...    cd ${CURDIR}/../../../QT/resources/scripts/ &&
    ...    python3 -c
    ...    "import scf_comm_script; scf_comm_script.delta_comm('${GNB_ASIK.Ip}', '${CURRENT_CONFIG_FILE}')"
    Log To Console    Commission: ${commission_cmd}
    ${commission_result}=    Run    ${commission_cmd}
    Log To Console    Delta Commission Result: ${commission_result}
    Should Not Contain    ${commission_result}    Traceback    msg=Delta Commission Failure! Terminating the execution
    Start UTE WTS Perf for WtsSim IWF
    Run Keyword If    '${IWF_FDD_CA_DSS}' == 'False'    Check Status till Cell Setup    ${tc_name}

Execute Send SSH commands
    [Arguments]    ${ip}    ${board_mapping}    ${command}    ${connection}
    ${parts}=    Split String    ${board_mapping}    :
    ${proxy_index}=    Set Variable    ${parts[0]}
    ${target_index}=   Set Variable    ${parts[1]}
    ${proxy_ip}=      Set Variable    ${ip}.${proxy_index}
    ${dict_name}=    Set Variable If    '${ip}' == '${ap_base_ip}'    AP    gNB
    ${dictionary_name}=    Set Variable    ${${dict_name}_bsh_ip}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${target_ip}=    Get From Dictionary    ${dictionary_name}    ${board_mapping}
    SSH.Connect To    ${target_ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=${connection}    alias=target
    SSH.Send Command    command=${command}    timeout=60    connection=target

Initialize_Test_Data_And_Execute
    [Arguments]    ${tc_dictionary}    ${test_tag}
    Fetch Dictionary Values    ${tc_dictionary}
    Run Keyword If
    ...    '${test_tag}' == 'SUE_SANSA_ECPRI72E'    SUE_PerCell_TDD_ECPRI72E_SA_NSA_DL1600_UL220   ${test_tag}
    ...    ELSE IF    '${test_tag}' == '40UE_SA_ECPRI72E'    40UE_SA_TPUT_DL3200_UL220_Single_Cell    ${test_tag}
    ...    ELSE IF    '${test_tag}' == '2000UE_SANSA_ECPRI72E'    2000UE_SANSA_2Cells    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'SUE_PER_CELL_SANSA_ECPRI72E'    SUE_PER_CELL_SA_NSA_TPUT_DL3200    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'SUE_SA_ECPRI72E_DL'    SUE_PER_CELL_SA_TPUT_DL6000    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'SUE_SA_ECPRI72E_UL'    SUE_PER_CELL_SA_TPUT_UL220    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'S2TC3_SA_MUE_UL_440Mbps'    MUE_PER_CELL_SA_TPUT_UL440    ${test_tag}
    ...    ELSE IF    '${test_tag}' == 'SA_2000UE'    Generic UEs Check Test Case Definition    ${test_tag}
    ...    ELSE IF    '${Sim_Config_Format}' == 'True'    Generic Throughput Test Case Definition    ${test_tag}

Generic Throughput Test Case Definition
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    ${COUNTER_CHECK}    ${DIR}
    Fetch_and_Display_RLC_Counters    ${COUNTER_CHECK}    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0
    ...    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

Generic UEs Check Test Case Definition
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=False
    Validate_UE_Summary_Output    ${test_tag}

SUE_PerCell_TDD_ECPRI72E_SA_NSA_DL1600_UL220
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    SANSA    ${DIR}
    Fetch_and_Display_RLC_Counters    SANSA    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

40UE_SA_TPUT_DL3200_UL220_Single_Cell
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Fetch_and_Display_RLC_Counters    SA    ${DIR}
    Validate_Traffic_Tput    ${test_tag}    SA    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

2000UE_SANSA_2Cells
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=False
    Validate_UE_Summary_Output    ${test_tag}

SUE_PER_CELL_SA_NSA_TPUT_DL3200
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    Environment Setup for PET IWF    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    SANSA    ${DIR}
    Fetch_and_Display_RLC_Counters    SANSA    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

SUE_PER_CELL_SA_TPUT_DL6000
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    ${COUNTER_CHECK}    ${DIR}
    Fetch_and_Display_RLC_Counters    ${COUNTER_CHECK}    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

SUE_PER_CELL_SA_TPUT_UL220
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    ${COUNTER_CHECK}    ${DIR}
    Fetch_and_Display_RLC_Counters    ${COUNTER_CHECK}    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

MUE_PER_CELL_SA_TPUT_UL440
    [Arguments]    ${test_tag}
    Set Test Variable    ${test_tag}    ${test_tag}
    @{ue_stats_res}=    Create List
    Set Suite Variable    ${ue_stats_res}
    Start_Test_Execution_Script    ${test_tag}
    Monitor_Active_UEs_Over_Test_Interval    stats_check=True
    Validate_UE_Summary_Output    ${test_tag}
    Validate_Traffic_Tput    ${test_tag}    ${COUNTER_CHECK}    ${DIR}
    Fetch_and_Display_RLC_Counters    ${COUNTER_CHECK}    ${DIR}
    ${fail_count}=    Get Count    ${ue_stats_res}    FAIL
    Run Keyword If    ${fail_count} > 0    Fail    One or more tput outputs are out of range. Check the logs: ${ue_stats_res}

Upload_Lua_File_For_ECPRI72E_IWF
    ute_wtssim.Execute Egate Command    ${WTS_CFG_LOAD_CMD}    timeout=10minutes
    sleep    30s
    Egate Console File Presence Check
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${ng_link_up_pattern}    ${ng_link_count}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${NO_OF_CELLS}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${sib_decoding_pattern_pet}    ${NO_OF_CELLS}
    ute_wtssim.Execute Egate Command    ${WTS_X2_LINK_CMD}    timeout=1minutes
    sleep    2s
    ute_wtssim.Execute Egate Command    ${UEPROXY_CMD}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Egate Console File Presence Check
    ${status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    2min    10sec     File Should Exist    ${WTS_DIR}/egate_console.log
    Run Keyword If    ${status}    log to console    egate_console file is found!!!
    ...    ELSE    Fail    msg=egate_console file is not found!!!

Start_Test_Execution_Script
    [Arguments]    ${test_tag}
    Log To Console    Executing ${test_tag} TC
    Set Test Variable    ${start_pattern}    ${test_tag}_script_started
    Set Test Variable    ${end_pattern}    ${test_tag}_script_completed
    ute_wtssim.Execute Egate Command    echo ${test_tag}_script_started!!!
    ute_wtssim.Execute Egate Command    ${WTS_TC_CMD}
    Sleep    30s
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_TIME}min    1min    Check Occurances in Egate Console   ${SCRIPT_COMPLETE}    1
    ute_wtssim.Execute Egate Command    echo ${test_tag}_script_completed!!!

    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
    ${sa_ue_ids}    extract_ue_ids_from_egate    file_path=${WTS_DIR}/egate_console.log    pattern=Established PDU session
    ...   start_line=${start_pattern}    end_line=${end_pattern}
    ${nsa_ue_ids}    extract_ue_ids_from_egate    file_path=${WTS_DIR}/egate_console.log    pattern=E-RAB modification completed for UE
    ...   start_line=${start_pattern}    end_line=${end_pattern}
    ${sa_ues}=    Get Length    ${sa_ue_ids}
    ${nsa_ues}=    Get Length    ${nsa_ue_ids}
    Append To File     ${test_property_file}    ${\n}SA_${test_tag}_UE=${sa_ues}${\n}
    Append To File     ${test_property_file}    ${\n}NSA_${test_tag}_UE=${nsa_ues}${\n}
    Set Suite Variable    ${sa_ue_ids}
    Set Suite Variable    ${nsa_ue_ids}

Monitor_Active_UEs_Over_Test_Interval
    [Arguments]    ${stats_check}=False
    [Documentation]    Monitors the number of active UEs over test interval.
    ${ue_stats_check}=    Set Variable    False
    ${ue_stats_check}=    Run Keyword If    '${stats_check}' == 'True'
    ...    Enable UE NR Stats Check
    ...    ELSE
    ...    Set Variable    False
    FOR    ${trf_loop}    IN RANGE    1    ${perf_trf_duration}+1    1
        Sleep    1m
        ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
        Log To Console    Number of ACTIVE UEs is ${active_ues[0]}
        Set Suite Variable    ${active_ues_total}    ${active_ues[0]}
        Run Keyword If    '${active_ues_total}' == '0'    FAIL    msg=Active No Of UEs are zero
        Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status
        Run Keyword and Ignore Error    Collection of em perf stats and em traces    ${trf_loop}
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${perf_trf_duration}   ${trf_loop}
        Run Keyword If    (${trf_loop} == 5 or ${trf_loop} == 10) and '${stats_check}' == 'True'
        ...    Display_Cell_Stats_Data_Rates
        Run Keyword If    (${trf_loop} == 5 or ${trf_loop} == 10) and '${ue_stats_check}' == 'True'
        ...    Display_UE_Stats_NR
    END
    ${active_ues}    Wait Until Keyword Succeeds    30s    2s    Check ue_summary output
    Log To Console    Number of ACTIVE UEs is ${active_ues[0]}
    Run Keyword If    '${IWF_ENABLED}' == 'True'    Check IWF Status

Deregister_Perf_IWF
    [Timeout]    10 minutes
    Run Keyword And Ignore Error    Detach_And_Deregister_UEs    ${sa_ue_ids}    ${nsa_ue_ids}
    Wait Until Keyword Succeeds    5min    10s    Checking upto zero UEs

Detach_And_Deregister_UEs
    [Arguments]    ${sa_ue_ids}    ${nsa_ue_ids}
    [Documentation]    Detaches and deregisters all SA and NSA UEs provided in the lists.
    ute_wtssim.Execute Egate Command    ue_deregister id\=${sa_ue_ids}[0]-${sa_ue_ids}[-1] ue_deregister_type\=switch_off
    ...    pass_regexp\=.*UE.*    timeout\=30
    sleep    5s
    ${detach_cmd}=    Set Variable    ue_detach id\=${nsa_ue_ids}[0]-${nsa_ue_ids}[-1]
    ute_wtssim.Execute Egate Command    ${detach_cmd}
    ...    pass_regexp\=.*UE.*    timeout\=30
    sleep    5s

Validate_Traffic_Tput
    [Arguments]    ${test_tag}    ${mode}    ${direction}=${DIR}
    [Documentation]    Validates throughput for NSA or SA based on direction: DL, UL, or BOTH
    Log To Console    Processing TPUT For ${mode} UEs!!!

    @{counter_list}=    Get_Counter_List_Based_On_Mode    ${COUNTER_CHECK}

    FOR    ${mode}    IN    @{counter_list}
        ${dl_counter}=    Set Variable If    '${mode}' == 'NSA'    ${NSA_DL_TPUT_COUNTER}    ${SA_DL_TPUT_COUNTER}
        ${ul_counter}=    Set Variable If    '${mode}' == 'NSA'    ${NSA_UL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}

        ${achieved_dl_tput}=    Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
        ...    Validate Perf Tput via gNB counter    dl    ${dl_counter}

        ${achieved_ul_tput}=    Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
        ...    Validate Perf Tput via gNB counter    ul    ${ul_counter}

        Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
        ...    Thoughput Validation Generic    ${test_tag}    ${mode}    DL    ${achieved_dl_tput}

        Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
        ...    Thoughput Validation Generic    ${test_tag}    ${mode}    UL    ${achieved_ul_tput}
    END
    Log To Console    Processed TPUT For ${mode} UEs!!!

Thoughput Validation Generic
    [Arguments]    ${test_tag}    ${mode}    ${direction}    ${tput}=0
    ${OVERALL_DL}=    Run Keyword If    '${mode}'=='SA'    Get Variable Value    ${OVERALL_DL_SA}    ${OVERALL_DL}
    ...    ELSE IF    '${mode}'=='NSA'    Get Variable Value    ${OVERALL_DL_NSA}    ${OVERALL_DL}
    ...    ELSE    Set Variable    ${OVERALL_DL}
    ${OVERALL_UL}=    Run Keyword If    '${mode}'=='SA'    Get Variable Value    ${OVERALL_UL_SA}    ${OVERALL_UL}
    ...    ELSE IF    '${mode}'=='NSA'    Get Variable Value    ${OVERALL_UL_NSA}    ${OVERALL_UL}
    ...    ELSE    Set Variable    ${OVERALL_UL}
    ${tput_ue_status}=    Create List
    ${threshold}=    Run Keyword If    '${direction}' == 'DL'    Evaluate    (${OVERALL_DL}*${DL_LIMIT})
    ...    ELSE    Evaluate    (${OVERALL_UL}*${UL_LIMIT})
    ${tput_status}=    Evaluate    ${tput} >= ${threshold}
    ${tput}=    Evaluate    "%.2f" % ${tput}
    Log To Console    Achieved ${mode} ${direction} Tput ${tput}
    Append To File    ${test_property_file}    ${\n}${test_tag}_${direction}=${tput}${\n}
    ${status}=    Run Keyword And Ignore Error    Should Be True    '${tput_status}' == 'True'    msg=Traffic failed in Throughput, see error above!
    Append To List    ${tput_ue_status}    ${status[0]}
    List Should Not Contain Value    ${tput_ue_status}    FAIL    msg=Criteria Not Met

Fetch And Display RLC Counters With Direction
    [Arguments]    ${counter}    ${dir}    ${mode}
    ${achieved_rlc}=    Fetch Counter Values IWF    ${counter}
    Display_RLC_Counters_Tput_Values    ${achieved_rlc}    ${dir}    ${mode}

Fetch_and_Display_RLC_Counters
    [Arguments]    ${COUNTER_CHECK}=SANSA    ${direction}=BOTH
    Log To Console    Processing TPUT Based on RLC Counters!!!
    @{counter_list}=    Get_Counter_List_Based_On_Mode    ${COUNTER_CHECK}

    FOR    ${mode}    IN    @{counter_list}
        ${dl_counter}=    Set Variable If    '${mode}' == 'SA'    ${SA_DL_CELL_RLC_COUNTER}    ${NSA_DL_CELL_RLC_COUNTER}
        ${ul_counter}=    Set Variable If    '${mode}' == 'SA'    ${SA_UL_CELL_RLC_COUNTER}    ${NSA_UL_CELL_RLC_COUNTER}

        Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
        ...    Fetch And Display RLC Counters With Direction    ${dl_counter}    DL    ${mode}

        Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
        ...    Fetch And Display RLC Counters With Direction    ${ul_counter}    UL    ${mode}
    END
    Log To Console    Processed TPUT Based on RLC Counters!!!

Get_Counter_List_Based_On_Mode
    [Arguments]    ${COUNTER_CHECK}
    Run Keyword If    '${COUNTER_CHECK}' == 'SANSA'    Set Test Variable    @{counter_list}    SA    NSA
    ...  ELSE IF    '${COUNTER_CHECK}' == 'SA'         Set Test Variable    @{counter_list}    SA
    ...  ELSE IF    '${COUNTER_CHECK}' == 'NSA'        Set Test Variable    @{counter_list}    NSA
    ...  ELSE                                          Fail    Invalid COUNTER_CHECK value: ${COUNTER_CHECK}
    [Return]    @{counter_list}

Display_RLC_Counters_Tput_Values
    [Arguments]    ${tput_list}    ${dir}    ${mode}
    Log To Console    RLC Counter for ${mode} ${dir}:

    ${updated_list}=    Create List
    FOR    ${value}    IN    @{tput_list}
        ${result}=    Evaluate    float(${value}) / 1000
        Append To List    ${updated_list}    ${result}
    END

    ${cell_ids_raw}=    Set Variable If    '${mode}' == 'SA'    ${Cell_IDs_SA}    ${Cell_IDs_NSA}
    @{cell_ids}=        Split String    ${cell_ids_raw}    ,

    FOR    ${cell_id}    IN    @{cell_ids}
        ${index}=        Evaluate    int(${cell_id}) - 1
        ${cell_tput}=    Evaluate    "%.2f" % ${updated_list[${index}]}
        Log To Console   Cell ${cell_id} ${mode} ${dir} TPut:${cell_tput}
        Append To File     ${test_property_file}    ${\n}${test_tag}_Cell_${cell_id}_${mode}_${dir}=${cell_tput}${\n}
    END

Derive_Average_Rate_From_Egate_Console_File
    [Arguments]    ${ue}    ${dl_ul}    ${CA_NCA_MODE}=${CA_NCA_MODE}
    ${output}=    Run Keyword if    '${dl_ul}' == 'UL'
    ...    find_tput_stats_from_egate_console_file    UE-${ue}: NR PUSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=${CA_NCA_MODE}
    ...    ELSE    find_tput_stats_from_egate_console_file    UE-${ue}: NR PDSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=${CA_NCA_MODE}
    Return From Keyword    ${output}

Display_UE_Stats_NR
    [Arguments]    ${direction}=${DIR}
    Log To Console    UE Stats NR Details Processing!!!
    Run Keyword If    ${sa_ue_ids}    Process UE NR Stats    SA    ${sa_ue_ids}    ${direction}
    Run Keyword If    ${nsa_ue_ids}    Process UE NR Stats    NSA    ${nsa_ue_ids}    ${direction}
    Log To Console    UE Stats NR Details Processing Done!!!

Process UE NR Stats
    [Arguments]    ${mode}    ${ue_ids}    ${direction}
    ${dl_sum}=    Set Variable    0.0
    ${ul_sum}=    Set Variable    0.0
    ${ue_count}=  Get Length    ${ue_ids}

    FOR    ${ue}    IN    @{ue_ids}
        Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
        ...    ute_wtssim.Execute Egate Command    ue_stats_nr id\=${ue} scell\=primary,secondary type\=pdsch
        ...    pass_regexp=Total    timeout=60
        Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
        ...    ute_wtssim.Execute Egate Command    ue_stats_nr id\=${ue} scell\=primary,secondary type\=pusch
        ...    pass_regexp=Total    timeout=60
        Sleep    1s
        ute_wtssim.Execute Egate Command    set_log flush

        ${dl_sum}=    Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
        ...     Process UE Stats    ${ue}    ${dl_sum}    ${ue_count}    DL    ${mode}
        ${ul_sum}=    Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
        ...     Process UE Stats    ${ue}    ${ul_sum}    ${ue_count}    UL    ${mode}
    END

    Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
    ...    Final UE NR Stats    ${mode}    ${dl_sum}    ${ue_count}    DL
    Run Keyword If    '${direction}' == 'DL' or '${direction}' == 'BOTH'
    ...    Append To File     ${test_property_file}    ${\n}${mode}_${test_tag}_DL=${dl_sum}${\n}
    Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
    ...    Final UE NR Stats    ${mode}    ${ul_sum}    ${ue_count}    UL
    Run Keyword If    '${direction}' == 'UL' or '${direction}' == 'BOTH'
    ...    Append To File     ${test_property_file}    ${\n}${mode}_${test_tag}_UL=${ul_sum}${\n}

Process UE Stats
    [Arguments]    ${ue}    ${sum}    ${ue_count}    ${direction}    ${mode}
    ${output}=       Derive_Average_Rate_From_Egate_Console_File    ${ue}    ${direction}
    ${rate}=         Get Regexp Matches    ${output}    ${SPACE}*(\\d+\\.\\d+)${SPACE}*Mbps${SPACE}*    1
    ${rate_val}=     Convert To Number    ${rate}[-1]
    ${sum}=          Evaluate    ${sum} + ${rate_val}
    ${sum}=          Evaluate    "%.2f" % ${sum}
    Run Keyword If   ${ue_count} == 1    Log To Console    ${mode} ${direction} Rate for UE ${ue}: ${sum} Mbps
    [Return]         ${sum}

Final UE NR Stats
    [Arguments]    ${mode}   ${sum}    ${ue_count}    ${direction}
    ${sum}=    Evaluate    "%.2f" % ${sum}
    Run Keyword If    ${ue_count} > 1    Log To Console    ${mode} UEs ${direction} Throughput: ${sum} Mbps
    ${OVERALL_DL}=    Run Keyword If    '${mode}'=='SA'    Get Variable Value    ${OVERALL_DL_SA}    ${OVERALL_DL}
    ...    ELSE IF    '${mode}'=='NSA'    Get Variable Value    ${OVERALL_DL_NSA}    ${OVERALL_DL}
    ...    ELSE    Set Variable    ${OVERALL_DL}
    ${OVERALL_UL}=    Run Keyword If    '${mode}'=='SA'    Get Variable Value    ${OVERALL_UL_SA}    ${OVERALL_UL}
    ...    ELSE IF    '${mode}'=='NSA'    Get Variable Value    ${OVERALL_UL_NSA}    ${OVERALL_UL}
    ...    ELSE    Set Variable    ${OVERALL_UL}
    ${threshold}=    Set Variable If    '${direction}' == 'DL'    ${OVERALL_DL}    ${OVERALL_UL}
    ${status}=    Validate_Output_Within_Range    ${sum}    ${threshold}
    Append To List    ${ue_stats_res}    ${status}

Validate_Output_Within_Range
    [Arguments]    ${tput}    ${expected_tput}
    ${tput}=    Convert To Number    ${tput}
    ${expected_tput}=    Convert To Number    ${expected_tput}
    ${lower_bound}=    Evaluate    ${expected_tput} * ${ue_nr_stats_lower_limit}
    ${upper_bound}=    Evaluate    ${expected_tput} * ${ue_nr_stats_upper_limit}
    ${status}=    Run Keyword If    ${tput} >= ${lower_bound} and ${tput} <= ${upper_bound}
    ...    Set Variable    PASS
    ...    ELSE    Set Variable    FAIL
    [Return]    ${status}

Display_Cell_Stats_Data_Rates
    [Arguments]    ${log_file_path}=${WTS_DIR}/egate_console.log    ${direction}=${DIR}
    ...            ${expected_dl}=None    ${expected_ul}=None
    Log to console    Cell Stats Data Rates Details!!!
    ute_wtssim.Execute Egate Command    cell_stats_nr id\=${Cell_IDs} enb\=2 type\=throughput
    ...    pass_regexp=DL Current Data Rate    timeout=10
    Sleep    5s
    ute_wtssim.Execute Egate Command    set_log flush
    ${cell_list}=    Split String    ${Cell_IDs}    ,
    FOR    ${cell}    IN    @{cell_list}
        ${cell}=    Convert To Integer    ${cell}
        Run Keyword If    '${direction}' in ['DL', 'BOTH']    Process Cell Data Rate    ${log_file_path}    ${cell}    DL    ${expected_dl}
        Run Keyword If    '${direction}' in ['UL', 'BOTH']    Process Cell Data Rate    ${log_file_path}    ${cell}    UL    ${expected_ul}
    END
    Log to console    Cell Stats Data Rates Processing Done!!!

Process Cell Data Rate
    [Arguments]    ${log_file_path}    ${cell}    ${dir}    ${expected_tput}=None
    ${tput_rate}=        Get Last Data Rate By Cell    ${log_file_path}    ${cell}    ${dir}
    ${tput_rate}=        Evaluate    round(${tput_rate} / 1000, 2)
    Log To Console  Cell ${cell} ${dir} Current Data Rate: ${tput_rate} mbps

    Run Keyword If    '${expected_tput}' != 'None'    Cell Data Rate Validation    ${tput_rate}    ${expected_tput}    ${cell}    ${dir}

Cell Data Rate Validation
    [Arguments]    ${tput_rate}    ${expected_tput}    ${cell}    ${dir}
    ${status}=     Validate_Output_Within_Range    ${tput_rate}    ${expected_tput}
    Log To Console    Cell ${cell} ${dir} Data Rate Validation: ${status}

Validate_UE_Summary_Output
    [Arguments]    ${test_tag}    ${Expected_UEs}=${EXPECTED_UE_COUNT}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    ue_summary    timeout=10
    ${active_ues}=    Get Regexp Matches    ${output}    Active +(\\d+)    1
    Should Not Be Empty    ${active_ues}    msg=ue_summary has no result. Retry

    ${active_count}=    Convert To Integer    ${active_ues}[0]
    ${threshold}=       Evaluate    int(${Expected_UEs} * ${UE_Count_Threshold})
    Append To File     ${test_property_file}    ${\n}${test_tag}_UE=${active_count}/${EXPECTED_UE_COUNT}${\n}
    Run Keyword If    ${active_count} != ${threshold}    Fail
    ...    Active UEs ${active_count} are less than expected ${Expected_UEs}!!!
    Log To Console    Active UEs ${active_count} meet the expected threshold ${threshold}
    [Return]    ${active_count}

Apply ECPRI72E Vendor File
    Log to console    Applying ECPRI72E Vendor File!!!
    ${vendor_script_path}=    Set Variable    ${EXECDIR}/tools/scripts/misc/install_integration/vendor_file_update.py
    Run    python3 ${vendor_script_path}
    Sleep    2s
    Log to console    Applied ECPRI72E Vendor File!!!

Copy PET SE Files Sim Config Format
    Log To Console    Copying Perf Config Files
    Copy Lua file IWF
    Run    cp ${WTS_CAPS_CFG_FILE} ${WTS_DIR}
    Run    cp ${WTS_COMMANDS_LUA} ${WTS_DIR}
    Run    cp ${WTS_TEST_SCRIPT} ${WTS_DIR}
    Run Keyword If    '${IWF_ENABLED}' == 'False'    Run    cp ${MULTI_LUA_SCRIPT} ${WTS_DIR}
    Log To Console    Copied Perf Config Files

Upload Lua File In Sim Config Format
    ute_wtssim.Execute Egate Command    ${WTS_CFG_LOAD_CMD}    timeout=10minutes
    sleep    30s
    Egate Console File Presence Check
    Run Keyword If    '${deployment}' == 'NSA'    Validate LTESIBs X2Link And NRCellSetup
    Run Keyword If    '${deployment}' != 'NSA'    Validate NGLink NRCellSetup And SIBMessages
    sleep    2s
    ute_wtssim.Execute Egate Command    ${UEPROXY_CMD}
    ute_wtssim.Execute Egate Command    sim_param_set disable_events_on_telnet_session\=on

Validate NGLink NRCellSetup And SIBMessages
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${ng_link_up_pattern}    ${ng_link_count}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${NO_OF_CELLS}
    ${no_of_sibs_value}=    Get Variable Value    ${NO_OF_SIBS}    ${EMPTY}
    ${NO_OF_CELLS}=    Set Variable If    '${no_of_sibs_value}' != '${EMPTY}'    ${no_of_sibs_value}    ${NO_OF_CELLS}
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${sib_decoding_pattern_pet}    ${NO_OF_CELLS}
    Run Keyword If    '${deployment}' != 'SA'    ute_wtssim.Execute Egate Command    ${WTS_X2_LINK_CMD}    timeout=1minutes

Validate LTESIBs X2Link And NRCellSetup
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${UE_SIB_decoding_pattern}    1
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${UE_SIB_decoding_pattern_eNB}    1
    ute_wtssim.Execute Egate Command    ${WTS_X2_LINK_CMD}    timeout=1minutes
    Wait Until Keyword Succeeds    10min    1min    Check Occurances in Egate Console    ${cell_setup_pattern}    ${NO_OF_CELLS}

Perf Test Teardown Common
    [Arguments]    ${test_tag}
    Run Keywords    Deregister_Perf_IWF    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    IWF Status Check    ${test_tag}    AND
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    gNB Snapshot Collection via adminAPI

Enable UE NR Stats Check
    [Documentation]    Enable UE NR stats only when expected UE count is less than or equal to cell count.
    ${expected_ues}=    Get Variable Value    ${EXPECTED_UE_COUNT}    0
    ${cell_ids}=    Get Variable Value    ${Cell_IDs}    ${EMPTY}
    ${cell_ids}=    Run Keyword If    '${cell_ids}' == '' and '${COUNTER_CHECK}' == 'SA'
    ...    Get Variable Value    ${Cell_IDs_SA}    ${EMPTY}
    ...    ELSE IF    '${cell_ids}' == '' and '${COUNTER_CHECK}' == 'NSA'
    ...    Get Variable Value    ${Cell_IDs_NSA}    ${EMPTY}
    ...    ELSE
    ...    Set Variable    ${cell_ids}
    ${expected_ues}=    Convert To Integer    ${expected_ues}
    @{cell_list}=    Run Keyword If    '${cell_ids}' != ''    Split String    ${cell_ids}    ,
    ...    ELSE    Create List
    ${cell_count}=    Get Length    ${cell_list}
    ${enable_ue_stats}=    Evaluate    ${expected_ues} > 0 and ${cell_count} > 0 and ${expected_ues} <= ${cell_count}
    Log To Console    UE NR stats validation check: expected_ues=${expected_ues}, cells=${cell_count}, enabled=${enable_ue_stats}
    [Return]    ${enable_ue_stats}
