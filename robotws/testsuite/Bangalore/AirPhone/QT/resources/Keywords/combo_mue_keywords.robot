*** Settings ***
Documentation     This contains common keywords for 4G5G combo Multi UE L3 Calls.
...               :author AP UTE team

Library    BuiltIn
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.hw.pdu    WITH NAME   pdu
Library    taf.config.scf   WITH NAME  scf
Library    taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library    taf.analyzer.pmcounter    WITH NAME    pm_analyser
Library      taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library      taf.analyzer.pdml    WITH NAME    pdml_ana
Resource    common_keywords.robot
Resource    ../../resources/ute/sosReport.robot
Resource    ../Variables/mue_variables.robot


*** Keywords ***
SA Register for MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_SA}     ${lua_method}=start_multiue_call_with_networkslice_sixoperator
    ...    ${ue_register_mue_value}=${ue_register_mue_value}    ${lua_method_stop_string}=${ue_register_stop_string}
    [Documentation]    This keyword is used at UE Register for MultiUE and checks the completion message in output file.
    ...                Modified Date: 27-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Log To Console    Starting SA UEs Registare...
    wtsrunner.script    file=${lua_file}    entry=${lua_method}(${ue_register_mue_value})
    Check Pattern in Egate Console Log    ${lua_method_stop_string}
    FOR   ${ueid}   IN   @{sa_ueids}
       ${validation_string}=    Catenate    UE${ueid}:     ${ue_registeration_completion}
       ${output}    Read WTS Output Until Pattern Matches    ${validation_string}    ${Timeout_SA}
       Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
       ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
       Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    END
    sleep    5s

LTE attach for MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}    ${multi_ue_six_operator_value}=${lte_multi_ue_six_operator_value}
    ...    ${ueids}=${lte_ueids}    ${lua_method}=lte_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator
    ...    ${lua_method_stop_string}=${lte_attach_stop_string}
    [Documentation]    This keyword is used at create the LTE Attach for MultiUE and checks the completion message in output file.
    ...                Modified Date: 27-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.script    file=${lua_file}
    ...   entry=${lua_method}(${multi_ue_six_operator_value})
    Check Pattern in Egate Console Log    ${lua_method_stop_string}
    Sleep    2s
    FOR   ${ueid}   IN   @{ueids}
        ${validation_string}=    Catenate    UE${ueid}: ===     ${LTE_attach_pattern}
        ${status}    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
        Run Keyword If    '${status[0]}' == 'FAIL'    Check Pattern in Egate Console Log    ${validation_string}
    END
    Log    lte_attach_is_ok
    sleep    5s

NSA Attach for MultiUE
    [Arguments]    ${nsa_multi_ue_six_operator_value}=${nsa_multi_ue_six_operator_value}
    LTE attach for MultiUE    multi_ue_six_operator_value=${nsa_multi_ue_six_operator_value}
    ...    ueids=${nsa_ueids}    lua_method_stop_string=${nsa_attach_stop_string}
    sleep    5s
    UE Attach should be Successful for NSA MultiUE
    sleep    5s

UE Attach should be Successful for NSA MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}    ${ue_range}=${nsa_ue_step_value}
    ...    ${lua_method}=fiveG_attach_multi_ue_with_range_for_AP_iphy    ${lua_method_stop_string}=${ue_attach_stop_string}
    [Documentation]    This keyword is used do UE Attach for MultiUE and checks the completion message in output file.
    ...                Modified Date: 27-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.script    file=${lua_file}    entry=${lua_method}(${ue_range})
    Check Pattern in Egate Console Log     ${lua_method_stop_string}
    FOR   ${ueid}   IN   @{nsa_ueids}
        ${validation_string}=    Catenate    UE${ueid}: Proxy.*    ${UE_attach_pattern}
        Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    END

Start SA NSA Forward HO for Combo and Validate
    [Documentation]    This Keyword is used for SA and NSA Forward HO and Validate
    Start SA HO for Combo And Validate
    Start NSA HO for Combo And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}
    Validate SA NSA and LTE Throughput
    Reset UL and DL Data Rates

Start SA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_SA}
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_1},forward1)
    Check Pattern in Egate Console Log    forward1 SA HO completed
    Sleep    2s
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_2},forward2)
    Check Pattern in Egate Console Log    forward2 SA HO completed
    Sleep    2s
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_3},forward3)
    Check Pattern in Egate Console Log    forward3 SA HO completed
    Sleep    2s
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_4},forward4)
    Check Pattern in Egate Console Log    forward4 SA HO completed
    Sleep    2s
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_5},forward5)
    Check Pattern in Egate Console Log    forward5 SA HO completed
    Sleep    2s
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params_6},forward6)
    Check Pattern in Egate Console Log    forward6 SA HO completed
    Sleep    2s
    FOR    ${ueid}    IN    @{sa_ueids}
        Validation of Combo HO scenario    ${ueid}   ${SA_HO_Message}    SA_HO
    END

Start NSA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_1},forward1)
    Check Pattern in Egate Console Log    forward1 NSA HO completed
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_2},forward2)
    Check Pattern in Egate Console Log    forward2 NSA HO completed
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_3},forward3)
    Check Pattern in Egate Console Log    forward3 NSA HO completed
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_4},forward4)
    Check Pattern in Egate Console Log    forward4 NSA HO completed
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_5},forward5)
    Check Pattern in Egate Console Log    forward5 NSA HO completed
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params_6},forward6)
    Check Pattern in Egate Console Log    forward6 NSA HO completed
    FOR    ${ueid}    IN    @{nsa_ueids}
        Validation of Combo HO scenario    ${ueid}    ${NSA_HO_Success}    NSA_HO
    END

Start SA NSA Reverse HO for Combo and Validate
    [Documentation]    This Keyword is used for SA and NSA Reverse HO and Validate
    Start Reverse SA HO for Combo And Validate
    Start Reverse NSA HO for Combo And Validate
    Sleep    5s
    Clear Bearer Stats
    Sleep    ${Duration_after_reverse_HO}

Start Reverse SA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_SA}
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_1},1)
    Check Pattern in Egate Console Log    UE History1 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_1},reverse1)
    Check Pattern in Egate Console Log    reverse1 SA HO completed
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_2},2)
    Check Pattern in Egate Console Log    UE History2 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_2},reverse2)
    Check Pattern in Egate Console Log    reverse2 SA HO completed
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_3},3)
    Check Pattern in Egate Console Log    UE History3 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_3},reverse3)
    Check Pattern in Egate Console Log    reverse3 SA HO completed
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_4},4)
    Check Pattern in Egate Console Log    UE History4 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_4},reverse4)
    Check Pattern in Egate Console Log    reverse4 SA HO completed
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_5},5)
    Check Pattern in Egate Console Log    UE History5 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_5},reverse5)
    Check Pattern in Egate Console Log    reverse5 SA HO completed
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history_6},6)
    Check Pattern in Egate Console Log    UE History6 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params_6},reverse6)
    Check Pattern in Egate Console Log    reverse6 SA HO completed
    ${validate_list}=    Create List
    FOR    ${ueid}    IN    @{sa_ueids}
        ${status}    Run Keyword And Ignore Error    Validation of Combo HO scenario    ${ueid}   ${SA_HO_Message}   Reverse_HO
        Append To List    ${validate_list}    ${status[0]}
    END
    List Should Not Contain Value    ${validate_list}    FAIL    msg=Reverse HO failed, see error above!

Start Reverse NSA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}
    Log to console    Start Reverse NSA HO...
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${reverse_nsa_handover_params},reverse)
    Check Pattern in Egate Console Log    reverse NSA HO completed
    ${validate_list}=    Create List
    FOR    ${ueid}    IN    @{nsa_ueids}
        ${status}    Run Keyword And Ignore Error    Validation of Combo HO scenario    ${ueid}   ${Reverse_NSA_HO_Success}    Reverse_NSA_HO
        Append To List    ${validate_list}    ${status[0]}
    END
    List Should Not Contain Value    ${validate_list}    FAIL    msg=Reverse HO failed, see error above!

Validation of Combo HO scenario
    [Arguments]    ${ueid}    ${validation_string}    ${HO_TYPE}=SA_HO
    ${updated_validation_string}=    Catenate    UE${ueid}:      ${validation_string}
    ${status}    Run Keyword And Ignore Error
    ...   wtsrunner.read_wtsemu_output_until_re    expected=${updated_validation_string}     timeout=120
    Run Keyword If    '${HO_TYPE}' == 'SA_HO'   Validate Egate Console Log forward    ${egate_file}
    ...   ${updated_validation_string}
    ...   ELSE IF    '${HO_TYPE}' == 'Reverse_HO'    Validate Egate Console Log reverse    ${egate_file}
    ...   ${updated_validation_string}
    ...   ELSE   Check Pattern in Egate Console Log    ${updated_validation_string}

Validate Egate Console Log forward
    [Arguments]    ${file}     ${pattern}     ${grepArgs}=grep -i -c
    ${command}     Catenate     ${grepArgs}     '${pattern}'     ${file}
    ${result}     Run    ${command}
    Log    ${result}
    ${num_of_HO}    Set Variable    1
    Should Be Equal    ${result}     ${num_of_HO}

Validate Egate Console Log reverse
    [Arguments]    ${file}     ${pattern}     ${grepArgs}=grep -i -c
    ${command}     Catenate     ${grepArgs}     '${pattern}'     ${file}
    ${result}     Run    ${command}
    Log    ${result}
    ${num_of_RHO}    Set Variable    2
    Should Be Equal    ${result}     ${num_of_RHO}

Start SA Traffic for Combo MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_SA}    ${lua_method}=start_traffic_internal_multiue
    ...    ${ul_traffic_range}=${sa_ul_traffic_range}     ${dl_traffic_range}=${sa_dl_traffic_range}
    Log to console    "...Starting SA Traffic..."
    Run     sudo sysctl -w net.core.wmem_max=20971520
    Run     sysctl -w net.core.rmem_max=20971520
    wtsrunner.script    file=${lua_file}   entry=${lua_method}(${dl_traffic_range})
    ${validation_string}=    Catenate    dl    ${sa_traffic_start_string}
    Check Pattern in Egate Console Log    ${validation_string}
    Sleep    2s
    wtsrunner.script    file=${lua_file}   entry=${lua_method}(${ul_traffic_range})
    ${validation_string}=    Catenate    ul    ${sa_traffic_start_string}
    Check Pattern in Egate Console Log    ${validation_string}
    Sleep    4s

Start LTE Traffic For Combo MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}    ${ul_traffic_range}=${lte_traffic_range}
    ...    ${dl_traffic_range}=${lte_traffic_range}    ${ul_data_rate}=2000    ${split_traffic}=False
    ...    ${split_traffic_range}=${ap_iphy_range_value}    ${dl_data_rate}=2000   ${traffic_type}=LTE
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    ...                Modified Date: 29-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Log to console    "...Starting Traffic..."
    Run Keyword If    '${traffic_type}' == 'NSA'    wtsrunner.script    file=${lua_file}
    ...   entry=setting_percentage_in_ap_iphy(${split_traffic_range})
    Run Keyword If    '${traffic_type}' == 'NSA'    Check Pattern in Egate Console Log    Traffic distribution is set...
    Run Keyword If    '${traffic_type}' == 'NSA' and '${split_traffic}' == 'True'
    ...    Wait Until Keyword Succeeds    5 min    30 sec
    ...    Validate Egate Console Log reverse    ${egate_file}    Traffic distribution is set...
    wtsrunner.script    file=${lua_file}    entry=start_traffic_kbps_with_range(${traffic_type},${ul_traffic_range},ul,3,${ul_data_rate})
    ${validation_string}=    Catenate    ${traffic_type} ul ${traffic_start_string}
    Check Pattern in Egate Console Log    ${validation_string}

    wtsrunner.script    file=${lua_file}    entry=start_traffic_kbps_with_range(${traffic_type},${dl_traffic_range},dl,3,${dl_data_rate})
    ${validation_string}=    Catenate    ${traffic_type} dl ${traffic_start_string}
    Check Pattern in Egate Console Log    ${validation_string}
    sleep    2s

Start NSA Traffic for Combo MultiUE
    [Documentation]    This Keyword starts NSA MUE traffic
    Log to console    "...Starting NSA Traffic..."
    Start NSA Traffic for MultiUE
    Sleep    ${Duration_before_HO}

Start NSA Traffic for MultiUE
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    ...                Modified Date: 29-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Start LTE Traffic For Combo MultiUE    ul_traffic_range=${nsa_traffic_range}     dl_traffic_range=${nsa_traffic_range}     traffic_type=NSA

Stop Traffic for SA NSA LTE and Validate Throughput
    [Documentation]    This Keyword is used to stop traffic and validate
    Log to console    Verify cumulative tput for all 60 UEs...
    Run Keyword And Ignore Error    Stop And Validate SA Traffic For MultiUE
    Run Keyword And Ignore Error    LTE Traffic should be Successful for MultiUE
    Run Keyword And Ignore Error    Traffic for NSA should be Successful for MultiUE
    Validate DL and UL Cumulative Data Rates for MultiUE
    Reset UL and DL Data Rates

Stop And Validate SA Traffic For MultiUE
    [Arguments]    ${dl_rate}=2    ${ul_rate}=2
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    FOR   ${sa_ueid}   IN   @{sa_ueids}
        Run Keyword And Ignore Error    Calculate SA Throughput for MultiUE    ${sa_ueid}
        ${trf_throughput_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA    ${dl_rate}
        ...   ${ul_rate}   ${sa_ueid}
        Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
        Stop Traffic For SA MultiUE    ${sa_ueid}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${dl_rate}    ${ul_rate}   ${sa_ueid}
        Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
    END
    List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL    msg=Traffic failed in Traffic Data Loss

LTE Traffic should be Successful for MultiUE
    [Arguments]    ${ueids}=${lte_ueids}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    ...                Modified Date: 29-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Stop And Validate LTE Traffic For MultiUE    ueids=${ueids}

Calculate SA Throughput for MultiUE
    [Arguments]    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_dl}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_dl}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${dl_data_rates}    ${ue_data_rate}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_ul}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_ul}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${ul_data_rates}    ${ue_data_rate}

Stop Traffic For SA MultiUE
    [Arguments]    ${UE_ID_SA}
    Log to Console    Stopping DL + UL SA Traffic for UE:${UE_ID_SA}
    wtsrunner.trf_data_stop     ue=${UE_ID_SA}

Stop And Validate LTE Traffic For MultiUE
    [Arguments]    ${ueids}=${lte_ueids}
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    FOR   ${ueid}   IN   @{ueids}
        Run Keyword And Ignore Error    Calculate LTE_NSA Throughput for MultiUE    ${ueid}    BEARER_ID=3
        ${trf_throughput_status}     Run Keyword And Ignore Error
        ...    Validate LTE Traffic Throughput Average Rate   ${dl_rate}    ${ul_rate}   ${ueid}    BEARER_ID=3
        Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
        Stop Traffic For LTE MultiUE    ${ueid}    BEARER_ID=3
        ${trf_dataloss_status}     Run Keyword And Ignore Error    Validate LTE Traffic Data Loss   ${ueid}    BEARER_ID=3
        Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
    END
    List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL    msg=Traffic failed in Traffic Data Loss

Calculate LTE_NSA Throughput for MultiUE
    [Arguments]    ${UE_ID}=1    ${BEARER_ID}=${BEARER_ID}
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_dl}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_dl}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${dl_data_rates}    ${ue_data_rate}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_ul}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_ul}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${ul_data_rates}    ${ue_data_rate}

Validate LTE Traffic Throughput Average Rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${BEARER_ID}=${BEARER_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}    ${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}    ${UE_ID}

Validate LTE Traffic Data Loss
    [Arguments]    ${UE_ID}=1    ${BEARER_ID}=${BEARER_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

Stop Traffic For LTE MultiUE
    [Arguments]    ${UE_ID}    ${BEARER_ID}=${BEARER_ID}
    Log to Console    Stopping DL + UL Traffic for UE:${UE_ID}
    wtsrunner.trf_data_stop     ue=${UE_ID}    id=${BEARER_ID}

Traffic for NSA should be Successful for MultiUE
    [Documentation]    This keyword starts and Validates the Traffic for the LTE, SA and NSA FDD/TDD variants for MultiUE
    ...                Modified Date: 29-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Stop And Validate LTE Traffic For MultiUE    ueids=${nsa_ueids}

Validate DL and UL Cumulative Data Rates for MultiUE
    ${dl_data_rate}    Set Variable    0
    ${ul_data_rate}    Set Variable    0
    FOR   ${dl_val}    ${ul_val}   IN ZIP   ${dl_data_rates}    ${ul_data_rates}
            ${dl_data_rate}    Evaluate    float(${dl_data_rate}+${dl_val})
            ${ul_data_rate}    Evaluate    float(${ul_data_rate}+${ul_val})
    END
    ${num_of_dl_ues}=    Evaluate    len(${dl_data_rates})
    ${num_of_ul_ues}=    Evaluate    len(${ul_data_rates})
    Log    "DL rates: ${dl_data_rates}..and UL rates: ${ul_data_rates}..and DL and UL UEs:${num_of_dl_ues} and ${num_of_ul_ues}"
    Should Be True    ${dl_data_rate}>=90 and ${ul_data_rate}>=60
    ...    msg=Traffic failed due to less throughput
    List Should Not Contain Value    ${dl_data_rates}    0.0    msg='DL rate is 0 for one or more UEs.'
    List Should Not Contain Value    ${ul_data_rates}    0.0    msg='UL rate is 0 for one or more UEs.'

Validate SA LTE and NSA Data rates Before HO
    Log to console    Checking Data rates for all UEs before HO...
    Validate SA NSA and LTE Throughput
    Reset UL and DL Data Rates

Reset UL and DL Data Rates
    @{dl_data_rates}=    Create List
    @{ul_data_rates}=    Create List
    Set Suite Variable    @{dl_data_rates}
    Set Suite Variable    @{ul_data_rates}

Calculate SA Traffic Data rate
    FOR   ${ueid}   IN   @{sa_ueids}
        Run Keyword And Ignore Error    Calculate SA Throughput for MultiUE    ${ueid}
    END

Calculate NSA and LTE Traffic Data rates
    FOR   ${lte_ueid}    ${nsa_ueid}   IN ZIP   ${lte_ueids}    ${nsa_ueids}
        Run Keyword And Ignore Error    Calculate LTE_NSA Throughput for MultiUE    ${lte_ueid}    BEARER_ID=3
        Run Keyword And Ignore Error    Calculate LTE_NSA Throughput for MultiUE    ${nsa_ueid}    BEARER_ID=3
    END

Clear SA Bearer Stats
    FOR   ${sa_ueid}    IN    ${sa_ueids}
        wtsrunner.bearer_stats_clear    ue=${sa_ueid}    pdu=1
    END

Clear NSA and LTE Bearer Stats
    FOR   ${lte_ueid}    ${nsa_ueid}    IN ZIP    ${lte_ueids}    ${nsa_ueids}
        wtsrunner.bearer_stats_clear    ue=${lte_ueid}    id=3
        wtsrunner.bearer_stats_clear    ue=${nsa_ueid}    id=3
    END

Clear Bearer Stats
    Clear SA Bearer Stats
    Clear NSA and LTE Bearer Stats

Validate SA NSA and LTE Throughput
    [Documentation]    This Keyword is used to validate throughput after handover
    Log to console    Collect data rates for all UEs and validate cumulative tput...
    Run Keyword And Ignore Error    Validate SA Traffic For MultiUE
    Run Keyword And Ignore Error    Validate LTE Traffic for MultiUE
    Run Keyword And Ignore Error    Validate NSA Traffic for MultiUE
    Validate DL and UL Cumulative Data Rates for MultiUE

Validate SA Traffic For MultiUE
    [Arguments]    ${dl_rate}=2    ${ul_rate}=2
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    ${data_loss_ue_list}=    Create List
    FOR   ${sa_ueid}   IN   @{sa_ueids}
        Run Keyword And Ignore Error    Calculate SA Throughput for MultiUE    ${sa_ueid}
        ${trf_throughput_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA    ${dl_rate}
        ...   ${ul_rate}   ${sa_ueid}
        Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${dl_rate}    ${ul_rate}   ${sa_ueid}
        Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        Run Keyword If    '${trf_dataloss_status[0]}' == 'FAIL'
        ...    Append To List    ${data_loss_ue_list}    ${sa_ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
    END
    List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL
    ...    msg=Traffic failed in Traffic Data Loss for UEs ${data_loss_ue_list}...

Validate LTE Or NSA Traffic
    [Arguments]    ${dl_rate}=2    ${ul_rate}=2    ${ueids}=${lte_ueids}
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    ${data_loss_ue_list}=    Create List
    FOR   ${ueid}   IN   @{ueids}
        Run Keyword And Ignore Error    Calculate LTE_NSA Throughput for MultiUE    ${ueid}    BEARER_ID=3
        ${trf_throughput_status}     Run Keyword And Ignore Error
        ...    Validate LTE Traffic Throughput Average Rate   ${dl_rate}    ${ul_rate}   ${ueid}    BEARER_ID=3
        Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
        ${trf_dataloss_status}     Run Keyword And Ignore Error    Validate LTE Traffic Data Loss    ${ueid}    BEARER_ID=3
        Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        Run Keyword If    '${trf_dataloss_status[0]}' == 'FAIL'
        ...    Append To List    ${data_loss_ue_list}    ${ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
    END
    List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL
    ...    msg=Traffic failed in Traffic Data Loss for UEs ${data_loss_ue_list}...

Validate LTE Traffic for MultiUE
    [Arguments]    ${dl_rate}=2    ${ul_rate}=2    ${ueids}=${lte_ueids}
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Validate LTE Or NSA Traffic    dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${ueids}

Validate NSA Traffic for MultiUE
    [Arguments]    ${dl_rate}=2    ${ul_rate}=2
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Validate LTE Or NSA Traffic    dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${nsa_ueids}

Bringup Setup After Commissioning
    [Arguments]    ${proto}
    Perform SCF Commissioning    proto=${proto}
    Modify UTE SCTP Timeout
    Run Keyword If    '${proto}'!= 'GTPU'    Start WTS For Combo    proto=${proto}

Perform SCF Commissioning
    [Arguments]    ${proto}=${proto}
    Stop Edaemon Egate
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    SSH.Execute    mkdir -p ${cus_script_path}    VM2
    ${command}    Catenate    mkdir    -p ${cus_script_path}
    Run    ${command}
    Run    cp ${custom-path}/${ute_ca_variant}/scfc_multiue.xml ${cus_script_path}/scfc.xml
    ${command}=    Catenate     python3 ${scf_file_path} ${cus_script_path}/scfc.xml ${proto}
    Run    ${command}
    ${input_scf}=   Catenate   ${cus_script_path}/scfc.xml
    ${output_scf}=    Catenate    ${cus_script_path}/scf_${proto}.xml
    Modify Vlan    input_scf=${input_scf}    output_scf=${output_scf}
    ${command}=    Catenate    scp ${cus_script_path}/scf_${proto}.xml
    ...            ${test_pc2}[username]@${test_pc2}[addr]:${cus_script_path}
    Run            ${command}
    ${command}=    Catenate    scp ${CURDIR}/../scripts/scf_comm_script.py
    ...            ${test_pc2}[username]@${test_pc2}[addr]:${cus_script_path}
    Run            ${command}
    ${command}=    Catenate    source /home/ute/test_repo/bin/activate &&
    ...            cd ${cus_script_path} &&
    ...            python -c
    ...            "import scf_comm_script;scf_comm_script.scf_comm('${ENB_BTS.Ip}', 'scf_${proto}.xml')"
    log to console    ${command}
    ${result}=    SSH.Execute    ${command}    VM2
    log to console    Commissioning is done successfully.
    SSH.Disconnect    VM2
    Power Reset From PDU
    Wait Until Keyword Succeeds    15min    30sec    Coam Site Should be Ready

Coam Site Should be Ready
    [Documentation]     This keyword checks whether TL is in Configured state and BTS sw is populated.
    Wait Coam Site to be Ready
    Should Contain    ${stream_nr}    SBTS

Power Reset From PDU
    ${rc}       ${output}=          Run and Return RC and Output     grep pdu_ports ${init_file}
    @{lines}=    Split String  ${output}    \n
    Length Should Be    ${lines}   4   Not able to find PDU ports from '${init_file}'

    ${rc}   ${output}=      Run and Return RC and Output     grep port_numbers ${init_file}
    ${matched_value}=    Get Regexp Matches    ${output}    \\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}
    Set Suite Variable    ${pdu_ip}    ${matched_value}
    FOR    ${line}    IN    @{lines}
        ${pdu_port}=    Get Substring   ${line}    -3   -2
        Reset port on PDU    ${pdu_ip}[0]    ${pdu_port}
    END

Reset port on PDU
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

Start WTS For Combo
    [Arguments]    ${proto}=${proto}
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Log to Console                 Starting WTS...
    Connect To WTS VM
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
    Copy Lua File to WTS_DIR    ${proto}
    ${command}    Catenate    hostname -I | awk '{print $1}'
    ${test_pc1}=    Run    ${command}
    ${command_mue}    Catenate
    ...    sed -i "s/\\(set_cnode ip=\\)[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+/\\1${test_pc1}/" ${WTS_DIR}/basic.lua
    Run Keyword If    '${4G5G_CUS}' == '1'    Run    ${command_mue}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    Check Simmode Status
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active

Copy Lua File to WTS_DIR
    [Arguments]    ${proto}
    ${cmd}=    Catenate    cp ${config-path}/basic_${proto}.lua
    ...    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run    ${cmd}
    Set Suite Variable    ${SUITE_WTS_CFG}

Check Simmode Status
    [Documentation]    This keyword checks if SimMode is ready in egate_console.log file
    ...                Modified Date: 15-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    ${validation_string}=    Set Variable    SimMode is ready now
    ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
    ...          expected=${validation_string}     timeout=240
    Run Keyword If    '${status}' == 'False'
    ...    Verify Pattern in Egate Console Log    ${validation_string}

Verify Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 15-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Start Forward HO for Combo and Validate
    Log to console    Start Forward HO for SA and NSA UEs...
    Forward SA HO for Combo And Validate
    Forward NSA HO for Combo And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}
    Validate SA NSA and LTE Throughput
    Reset UL and DL Data Rates

Forward SA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_SA}
    Log to console    Start forward HO for SA UEs...
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${sa_handover_params},forward)
    Check Pattern in Egate Console Log    forward SA HO completed
    Sleep    2s
    FOR    ${ueid}    IN    @{sa_ueids}
        Validation of Combo HO scenario    ${ueid}   ${SA_HO_Message}    SA_HO
    END

Forward NSA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}
    Log to console    Start forward HO for NSA UEs...
    wtsrunner.script    file=${lua_file}    entry=handover_mue(${nsa_handover_params},forward)
    Check Pattern in Egate Console Log    forward NSA HO completed
    FOR    ${ueid}    IN    @{nsa_ueids}
        Validation of Combo HO scenario    ${ueid}    ${NSA_HO_Success}    NSA_HO
    END

Start Reverse HO for Combo and Validate
    Log to console    Start Reverse HO for SA and NSA UEs...
    Reverse SA HO for Combo And Validate
    Start Reverse NSA HO for Combo And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}

Reverse SA HO for Combo And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_SA}
    Log to console    Start Reverse HO for SA UEs...
    wtsrunner.script    file=${lua_file}    entry=addition_of_uehistory_info_sa_handover(${ue_history},1)
    Check Pattern in Egate Console Log    UE History1 Info added
    wtsrunner.script    file=${lua_file}    entry=start_multiue_sa_handover(${reverse_sa_handover_params},reverse)
    Check Pattern in Egate Console Log    reverse SA HO completed
    Sleep    2s
    FOR    ${ueid}    IN    @{sa_ueids}
        Validation of Combo HO scenario    ${ueid}   ${SA_HO_Message}    Reverse_HO
    END

Start L3 Call and HO For IPv4 Operator and Validate
    [Documentation]    This keyword test UE attach SA and NSA HO cases and validate traffic with IPv4 operator
    SA Register for MultiUE    lua_method=start_multiue_call_with_networkslice
    ...    ue_register_mue_value=${ue_register_mue_sa_value}
    ...    lua_method_stop_string=${ue_register_string}
    Start SA Traffic for Combo MultiUE
    LTE attach for MultiUE    multi_ue_six_operator_value=${lte_multi_ue_operator_value}
    ...    lua_method=lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    ...    lua_method_stop_string=${attach_stop_string}
    Start LTE Traffic For Combo MultiUE
    LTE attach for MultiUE    multi_ue_six_operator_value=${nsa_multi_ue_operator_value}
    ...    ueids=${nsa_ueids}    lua_method_stop_string=${attach_stop_string}
    ...    lua_method=lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    sleep    5s
    UE Attach should be Successful for NSA MultiUE
    sleep    5s
    Start NSA Traffic for Combo MultiUE
    Validate SA LTE and NSA Data rates Before HO
    Start Forward HO for Combo and Validate
    Start Reverse HO for Combo and Validate
    Stop Traffic for SA NSA LTE and Validate Throughput

Start L3 Call and HO For DS Operator and Validate
    [Documentation]    This keyword test UE attach SA and NSA HO cases and validate traffic with DS operator
    Log    "Disable AMF-1 to avoid SA HO issues"
    wtsrunner.amf_config_update    id=1     relative_capacity=0
    SA Register for MultiUE    lua_method=start_multiue_call_with_networkslice
    ...    ue_register_mue_value=${ue_register_mue_sa_value}
    ...    lua_method_stop_string=${ue_register_string}
    Start SA Traffic for Combo MultiUE
    LTE attach for MultiUE    multi_ue_six_operator_value=${lte_multi_ue_operator_value}
    ...    lua_method=lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    ...    lua_method_stop_string=${attach_stop_string}
    Start LTE Traffic For Combo MultiUE
    LTE attach for MultiUE    multi_ue_six_operator_value=${nsa_multi_ue_operator_value}
    ...    ueids=${nsa_ueids}    lua_method_stop_string=${attach_stop_string}
    ...    lua_method=lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    sleep    5s
    UE Attach should be Successful for NSA MultiUE
    sleep    5s
    Start NSA Traffic for Combo MultiUE
    Validate SA LTE and NSA Data rates Before HO
    Start Forward HO for Combo and Validate
    Start Reverse HO for Combo and Validate
    Stop Traffic for SA NSA LTE and Validate Throughput

Modify Vlan
    [Arguments]    ${input_scf}=${input_scf}    ${output_scf}=${output_scf}    ${ID}=${ID}
    ${vlan_id}=    Get init file path
    scf.load_scf    ${input_scf}
    Run Keyword If    '${variant_name}' == '4G5G_COMBO_MultiUE'    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist}    p_name=${ID}
    Run Keyword If    '${variant_name}' == '4G5G_CUS_MultiUE'    Load SCF for CUS    ${vlan_id}
    scf.save_scf    ${output_scf}

Load SCF for CUS
    [Arguments]    ${vlan_id}=${vlan_id}    ${ID}=${ID}
    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist_VLANIF-3}    p_name=${ID}
    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist_VLANIF-1}    p_name=${ID}

Get init file path
    [Arguments]    ${testline_resuls_path}=${testline_resuls_path}
    ${hostname}=    Get Hostname Details
    ${init_file}=    Catenate    ${testline_resuls_path}/${hostname}/__init__.py
    ${cloned_init_file}=    Catenate    ${EXECDIR}/testline_configuration/${hostname}/__init__.py
    ${file_list} =    Create List    ${init_file}    ${testline_file}    ${cloned_init_file}
    FOR    ${file}    IN    @{file_list}
        ${result}   ${value} =   Run Keyword And Ignore Error    File Should Exist    ${file}
        ${pattern}=    Run Keyword If    '${result}' == 'PASS'    Get Vlan ID    ${file}
        Continue For Loop If    '${pattern}' == 'None'
        Return From Keyword If    '${pattern}' != 'None'    ${pattern}
    END

Get Vlan ID
    [Arguments]    ${init_file}=${file}
    ${command}    Catenate    sed -nr 's/^.*vlan_id=//p' ${init_file} | cut -d')' -f1 | head -n 1
    ${vlan_id}    Run    ${command}
    [Return]    ${vlan_id}

Copy Egate Console Log File
    [Arguments]    ${proto}=${proto}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    Run Keyword And Ignore Error    Copy File    ${WTS_DIR}/egate_console.log
    ...    ${EXECDIR}/logs/egate_console_${proto}.log

Attach NSA Split Traffic
    Attach and Start NSA UL Traffic
    sleep    900s
    Wait Until Keyword Succeeds    15 min    1 min    Collect PM Counters and validate

Attach and Start NSA UL Traffic
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}
    log to console    Deregister SA UEs...
    wtsrunner.script_stop
    Run Keyword And Ignore Error    wtsrunner.script    file=${multi_ue_script_SA}
    ...    entry=stop_multiue_call(${sa_ue_range})
    Run Keyword And Ignore Error    Check Pattern in Egate Console Log    ${sa_deregister_string}
    sleep    5s
    log to console    Detach LTE and NSA UEs if already attached...
    wtsrunner.script_stop
    Run Keyword And Ignore Error    wtsrunner.script    file=${lua_file}
    ...    entry=lte_detach_multi_ue_with_range_without_timer(${lte_nsa_ue_range})
    Run Keyword And Ignore Error    Check Pattern in Egate Console Log    ${lte_detach_string}
    sleep    5s
    log to console    Attach NSA UEs...
    NSA Attach for MultiUE    nsa_multi_ue_six_operator_value=${nsa_multi_ue_split_traffic}
    Start LTE Traffic For Combo MultiUE    split_traffic_range=${ap_iphy_split_range}
    ...    ul_traffic_range=${nsa_traffic_split_range}     dl_traffic_range=${nsa_traffic_split_range}
    ...    traffic_type=NSA    split_traffic=True

Collect PM Counters and validate
    [Arguments]    ${Counter_List_cus}=${Counter_List_cus}    ${Counter_List_combo}=${Counter_List_combo}
    Collect Gnb PM Counters    ${EXECDIR}/logs/
    ${counter_output}=    Run Keyword If    '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    pm_analyser.get_pi_value    pi_list=${Counter_List_combo}
    ...    pi_dir=${EXECDIR}/logs/gnb_pm_counters/    pi_file_pattern=PM*
    ...    ELSE    pm_analyser.get_pi_value    pi_list=${Counter_List_cus}
    ...    pi_dir=${EXECDIR}/logs/gnb_pm_counters/    pi_file_pattern=PM*
    log to console    ${counter_output}
    ${non_empty_list}    Create List
    Set Test Variable    ${non_empty_list}
    Common Counter Interator    ${counter_output}    Get PM Counters
    Run Keyword If    '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    Common Counter Interator    ${Counter_List_combo}    Verify PM counters
    ...    ELSE    Common Counter Interator    ${Counter_List_cus}    Verify PM counters for CUS
    log to console    PM Counter Validation is finished...

Collect Gnb PM Counters
    [Arguments]    ${target_dir}    ${name}=gnb_pm_counters    ${duration}=15 minutes
    Log To Console    Download gNB PM Counters...
    ${webservice}=    Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    gnb_pmcounters.create PM collector   name=${name}    webservice=${webservice}    for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Common Counter Interator
    [Arguments]    ${list_name}    ${Keyword_name}
    FOR    ${item}    IN    @{list_name}
        Run Keyword    ${Keyword_name}    ${item}
    END

Verify PM counters
    [Arguments]    ${counter}
    ${pm_status_list}    Create List
    FOR    ${element}    IN    @{non_empty_list}
        ${status}    Run Keyword and Return Status    Dictionary Should Contain Key    ${element}    ${counter}
        ${incr_values}    Run Keyword If    '${status}' == 'True'    Evaluate    ${element}.values()[0].values()
        ...    ELSE    Set Variable    Dictionary: ${element} doesnot have ${counter} counter key.
        ${pm_status}    Run Keyword If    '${status}' == 'True'    Run Keyword And Ignore Error
        ...    Should be true    ${incr_values}[0] > 710000
        Run Keyword If    '${status}' == 'True'    Append To List    ${pm_status_list}    ${pm_status[0]}
    END
    List Should Contain Value   ${pm_status_list}    PASS    msg=PM counter:${counter} is not updated as expected

Verify PM counters for CUS
    [Arguments]    ${counter}
    [Documentation]    This keyword is used to Verify the PM counters where sum of each value is multiplied
    ...                by 8 to convert from bytes to bits. And to convert from kbps to mbps is divided by 300000
    ...                The obtained value should be atleast 50% is the pass criteria,
    ...                total 40mbps is pumped hence result should be greater than 20mpbs.
    ...                Modified Date: 24-Apr-2023
    ...                Last Modified by: kokila.b@nokia.com
    ${pm_status_list}    Create List
    FOR    ${element}    IN    @{non_empty_list}
        ${status}    Run Keyword and Return Status    Dictionary Should Contain Key    ${element}    ${counter}
        ${pm_status}    Run Keyword If    '${status}' == 'True'    Evaluate PM counters for CUS    ${element}
        ...    ELSE    Set Variable    Dictionary: ${element} doesnot have ${counter} counter key.
        Run Keyword If    '${status}' == 'True'    Append To List    ${pm_status_list}    ${pm_status[0]}
    END
    List Should Contain Value   ${pm_status_list}    PASS    msg=PM counter:${counter} is not updated as expected

Evaluate PM counters for CUS
    [Arguments]    ${element}
    FOR    ${element_path}    IN    @{element.keys()}
        ${value}=    Get From Dictionary    ${element}    ${element_path}
    END
    ${incr_values}    Get Dictionary Values    ${value}
    ${sum}=    Evaluate    sum([int(x) for x in ${incr_values}])
    ${result}=    Evaluate    (${sum} * 8) / 300000
    ${pm_status}    Run Keyword And Ignore Error    Should be true    ${result} > 20
    [Return]    ${pm_status}

Get PM Counters
    [Arguments]    ${pm_dict_out}
    ${pm_ouput_list}    Get Dictionary Items    ${pm_dict_out}
    FOR    ${key}    ${value}    IN    @{pm_ouput_list}
        ${dict_values}    Get Dictionary Values    ${value}
        ${len}    Get length    ${dict_values}[0]
        ${status}    Run Keyword and Return status    Should Be Equal As Integers    ${len}    0
        Continue For Loop If    ${status}
        Append To List    ${non_empty_list}    ${value}
    END

Verify GTPU Alarm And ECHO Messages
   Verify GTPU Alarm Detection
   Start WTS Tcpdump    /tmp/GTPU.pcap
   Start WTS For Combo    proto=GTPU
   NG Link Should be UP
   Address Distribution should be Successful
   UE SIB Decoding should be Successful
   AP Cell Setup should be Successful
   Alarm Should Not Be Active in BTS    ${fault_id}    ${alias}
   Validate ECHO messages

Copy GTPU Path Text File to eNB
    Log To Console    Copy GTPU_config file to eNB...
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    ${command}=    Catenate    scp ${config-path}/SupervisedGtpuPath.txt
    ...            ${test_pc2}[username]@${test_pc2}[addr]:${cus_script_path}
    Run            ${command}
    ${command}=    Catenate    scp ${cus_script_path}/SupervisedGtpuPath.txt
    ...    ${GNB_ASIK.Username}@${ENB_BTS.Ip}:/ffs/run/config
    ${result}=    SSH.Execute    ${command}    VM2
    SSH.Disconnect    VM2

Verify GTPU Alarm Detection
    log to console    Check GTPU Alarm is raised...
    CoamAdmin.connect_to    bts_host=${GNB_BTS.Ip}     bts_port=${GNB_BTS.Port}   username=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}   name=default
    Set Suite Variable    ${fault_id}    6150
    Set Suite Variable    ${alias}    default
    Alarm Should be Active In BTS   ${fault_id}    ${alias}

Is Alarm Active in Admin
    [Arguments]    ${alias}=${alias}
    ${active_alarms}=    CoamAdmin.get_active_alarms    connection=${alias}
    Log To Console    ${active_alarms}
    CoamAdmin.teardown    connection=${alias}
    [Return]   ${active_alarms}

Alarm Should be Active In BTS
    [Arguments]    ${fault_id}=${fault_id}    ${alias}=${alias}
    ${is_alarm_present}=    Is Alarm Active In Admin    ${alias}
    should contain    '@{is_alarm_present}'    'faultId': ${FAULT_ID}

Alarm Should Not Be Active in BTS
    [Arguments]    ${fault_id}=${fault_id}    ${alias}=${alias}
    log to console    Check GTPU Alarm is cleared...
    CoamAdmin.connect_to    bts_host=${GNB_BTS.Ip}     bts_port=${GNB_BTS.Port}   username=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}   name=default
    ${is_alarm_present}=    Is Alarm Active In Admin    ${alias}
    should not contain    '@{is_alarm_present}'    'faultId': ${FAULT_ID}

Validate ECHO messages
    log to console    Check exchanged six ECHO Request and six Response msgs...
    FOR    ${index}    IN RANGE    1    13
        Run Keyword if    ${index} < 7   Convert PCAP And Verify ECHO Message    ${ECHO_Req${index}}    1
        ...    ELSE    Convert PCAP And Verify ECHO Message    ${ECHO_Resp${index}}    2
    END

Convert PCAP And Verify ECHO Message
    [Arguments]    ${ECHO_Msg}    ${Msg_Id}
    log to console    Convert PCAP file to PDML format...
    ${command}=    Catenate    tshark -Y
    ...    "${ECHO_Msg}"
    ...    -r /tmp/GTPU.pcap -T pdml > /tmp/GTPU.pdml
    pcaptopdml.create_pcap_to_pdml_converter
    ...    name=converter
    ...    file_path_pattern=/tmp/GTPU.pcap
    ...    command_template=${command}
    Run Keyword And Ignore Error    pcaptopdml.convert    converter
    log to console    Verify if ECHO msg is present...
    Run keyword if    ${Msg_Id} == 1    Search pattern should Exists In EGATE
    ...    /tmp/GTPU.pdml    Echo request
    ...    ELSE    Search pattern should Exists In EGATE
    ...    /tmp/GTPU.pdml    Echo response

Stop GTPU Tcpdump
    [Arguments]    ${fileName}=${EMPTY}
    [Documentation]    Stops tcpdump and compress pcap when given a filename.
    Run                   sudo pkill tcpdump
    Run Keyword if    "${fileName}" != "${EMPTY}"
    ...                   Compress Tcpdump file    ${fileName}
    Run                   sudo rm -rf /tmp/GTPU.pcap
    Run Keyword And Ignore Error    Create directory    ${EXECDIR}/logs/GTPUpcap
    Run    sudo mv /tmp/GTPU.pcap.tgz ${EXECDIR}/logs/GTPUpcap/
    Run    ls -lrt ${EXECDIR}/logs/GTPUpcap/

GTPU Teardown
    Stop GTPU Tcpdump    fileName=/tmp/GTPU.pcap
    Copy Egate Console Log File    GTPU

MUEs Test Failure Teardown
    [Arguments]    ${proto}
    Copy Egate Console Log File    ${proto}
    Run Keyword If
    ...    ('${CONDITIONAL_LOGGING}' == 'False' and '${TEST STATUS}' == 'FAIL') or '${TRS_COMBO_LOGS}' == 'True'
    ...    Collect UTE SosReport
