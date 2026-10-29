*** Settings ***
Documentation     This contains common keywords for 4G5G combo Multi UE L3 Calls.
...               :author AP UTE team

Library    BuiltIn
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.pdu           WITH NAME    pdu
Library    taf.config.scf   WITH NAME  scf
Library    taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library    taf.analyzer.pmcounter    WITH NAME    pm_analyser
Library      taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library      taf.analyzer.pdml    WITH NAME    pdml_ana
Resource    common_keywords.robot
Resource    ../../resources/ute/sosReport.robot
Resource    ../Variables/mue_variables.robot


*** Keywords ***
LTE attach for CUS MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}    ${multi_ue_six_operator_value}=${lte_multi_ue_cus_six_operator_value}
    ...    ${ueids}=${lte_ueids}    ${lua_method}=MultiUeScript.lte_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator
    [Documentation]    This keyword is used at create the LTE Attach for MultiUE and checks the completion message in output file.
    ...                Modified Date: 29-Mar-2023
    ...                Last Modified by: kokila.b@nokia.com
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${multi_ue_six_operator_value})
    Sleep    2s
    FOR   ${ueid}   IN   @{ueids}
        ${validation_string}=    Catenate    UE${ueid}: ===     ${LTE_attach_pattern}
        ${status}    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
        Run Keyword If    '${status[0]}' == 'FAIL'    Check Pattern in Egate Console Log    ${validation_string}
    END
    Log    lte_attach_is_ok
    sleep    5s

Start LTE Traffic For CUS MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}    ${ul_traffic_range}=${lte_ul_traffic_range}
    ...    ${lua_method}=MultiUeScript.start_traffic_kbps_with_range    ${dl_traffic_range}=${lte_dl_traffic_range}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    ...                Modified Date: 29-Mar-2023
    ...                Last Modified by: kokila.b@nokia.com
    Log to console    "...Starting LTE Traffic..."
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${ul_traffic_range})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${dl_traffic_range})
    sleep    2s

NSA Attach for CUS MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}    ${multi_ue_six_operator_value}=${nsa_multi_ue_cus_six_operator_value}
    ...    ${ueids}=${nsa_ueids}    ${lua_method}=MultiUeScript.nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator
    [Documentation]    This keyword is used at create the UE Attach for NSA MultiUE and checks the completion message in output file.
    ...                Modified Date: 29-Mar-2023
    ...                Last Modified by: kokila.b@nokia.com
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${multi_ue_six_operator_value})
    Sleep    2s
    FOR   ${ueid}   IN   @{ueids}
        ${validation_string}=    Catenate    UE${ueid}: ===     ${LTE_attach_pattern}
        ${status}    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
        Run Keyword If    '${status[0]}' == 'FAIL'    Check Pattern in Egate Console Log    ${validation_string}
        Check Pattern in Egate Console Log     UE${ueid}: ${Bearer_CUS}
        ${validation_string}=    Catenate    UE${ueid}: Proxy.*    ${UE_attach_pattern}
        ${status}    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
        Run Keyword If    '${status[0]}' == 'FAIL'    Check Pattern in Egate Log    ${validation_string}    ${UE_attach_pattern}
    END
    Log    lte_attach_is_ok
    sleep    5s

Start NSA Traffic for CUS MultiUE
    [Documentation]    This Keyword starts NSA MUE traffic before HO
    Start NSA MultiUE Traffic for CUS
    Sleep    ${Duration_before_HO}

Start NSA MultiUE Traffic for CUS
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}    ${ul_traffic_range}=${nsa_ul_traffic_range}
    ...    ${lua_method}=MultiUeScript.start_traffic_kbps_with_range    ${dl_traffic_range}=${nsa_dl_traffic_range}
    [Documentation]    This Keyword starts NSA MUE traffic
    Log to console    "...Starting NSA Traffic..."
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${ul_traffic_range})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${dl_traffic_range})

Validate SA LTE and NSA Data rates Before HO For CUS
    Log to console    Checking Data rates for all UEs before HO...
    Run Keyword And Ignore Error    Validate SA NSA and LTE Throughput For CUS
    Reset UL and DL Data Rates

Validate SA NSA and LTE Throughput For CUS
    [Documentation]    This Keyword is used to validate throughput after handover
    Log to console    Collect data rates for all UEs and validate cumulative tput...
    Run Keyword And Ignore Error    Validate SA Traffic For MultiUE
    Run Keyword And Ignore Error    Validate LTE Traffic for MultiUE CUS
    Run Keyword And Ignore Error    Validate NSA Traffic for MultiUE CUS
    Validate DL and UL Cumulative Data Rates for MultiUE

Validate LTE Traffic for MultiUE CUS
    [Arguments]    ${traffic_range}=${lte_traffic_range}    ${duration}=10min
    ...   ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueids}=${lte_ueids}
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Validate LTE Or NSA Traffic CUS   traffic_range=${traffic_range}
    ...   dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${ueids}

Validate NSA Traffic for MultiUE CUS
    [Arguments]    ${traffic_range}=${nsa_traffic_range}    ${duration}=10min
    ...   ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueids}=${nsa_ueids}
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Validate LTE Or NSA Traffic CUS    traffic_range=${nsa_traffic_range}
    ...   dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${nsa_ueids}

Validate LTE Or NSA Traffic CUS
    [Arguments]    ${lua_file}=${multi_ue_script_NSA}    ${traffic_range}=${lte_traffic_range}
    ...    ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueids}=${lte_ueids}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    ${data_loss_ue_list}=    Create List
	FOR   ${ueid}   IN   @{ueids}
	    ${trf_throughput_status}     Run Keyword And Ignore Error
        ...    Validate LTE Traffic Throughput Average Rate For CUS    ${dl_rate}    ${ul_rate}   ${ueid}    ${BEARER_ID_CUS}
		Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
		${trf_dataloss_status}     Run Keyword And Ignore Error    Validate LTE Traffic Data Loss For CUS
        ...    ${dl_rate}    ${ul_rate}   ${ueid}    ${BEARER_ID_CUS}
		Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
	END
	List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL    msg=Traffic failed in Traffic Data Loss

Validate LTE Traffic Throughput Average Rate For CUS
    [Arguments]    ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueid}=${UE_ID}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
    Check Average Rate and Calculate LTE_NSA Throughput For CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl    mbps=${dl_rate}
    ...    BEARER_ID_CUS=${BEARER_ID_CUS}
    Check Average Rate and Calculate LTE_NSA Throughput For CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul    mbps=${ul_rate}
    ...    BEARER_ID_CUS=${BEARER_ID_CUS}

Check Average Rate and Calculate LTE_NSA Throughput For CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${TRF_ID}=${TRF_ID}    ${Dir}=${Dir}    ${mbps}=${mbps}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
    ${trf_stats}=     Run UEx command     get_trf_data_stats     ue=${UE_ID}   bearer=${BEARER_ID_CUS}    unit=Mbps    trf_id=${TRF_ID}
    ${tputs}=     Get From Dictionary     ${trf_stats}     ${Dir}
    ${tputs_avg}=    Get From Dictionary     ${tputs}     avg
    ${result}         Evaluate    (${mbps} * 1.1) > (${tputs_avg}) > (${mbps} * 0.9)
	${tputs_cur}=    Get From Dictionary     ${tputs}     cur
    Run Keyword If    '${Dir}'=='dl'    Append To List    ${dl_data_rates}    ${tputs_cur}
    ...    ELSE     Append To List    ${ul_data_rates}    ${tputs_cur}
    Run Keyword if    ${result}    Log to Console    UE${UE_ID}:${Dir} Average data rate: ${tputs_avg}
    ...               ELSE    Log    UE${UE_ID}:${Dir} Average data rate: ${tputs_avg}     level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${UE_ID}:${Dir} Average data rate failed!

Validate LTE Traffic Data Loss For CUS
    [Arguments]    ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${UE_ID}=${UE_ID}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
    Check Data Loss for LTE_NSA MultiUE For CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl    BEARER_ID_CUS=${BEARER_ID_CUS}
    Check Data Loss for LTE_NSA MultiUE For CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul    BEARER_ID_CUS=${BEARER_ID_CUS}

Check Data Loss for LTE_NSA MultiUE For CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${TRF_ID}=${TRF_ID}    ${Dir}=${Dir}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
    ${trf_stats}=     Run UEx command     get_trf_data_stats     ue=${UE_ID}   bearer=${BEARER_ID_CUS}    unit=Mbps    trf_id=${TRF_ID}
    ...    succ_rate=on
    ${tputs}=     Get From Dictionary     ${trf_stats}    ${Dir}
    ${tputs_pass}=    Get From Dictionary     ${tputs}     pass
    ${result}         Evaluate    ${tputs_pass} >= 99
    Run Keyword if    ${result}    Log to Console    UE${UE_ID}:${Dir} Data Received: ${tputs_pass}
    ...               ELSE    Log    UE${UE_ID}:${Dir} Data Loss!: ${tputs_pass}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${UE_ID}:${Dir} Data Loss! not matching given threshold!

Stop Traffic for SA NSA LTE and Validate Throughput for CUS
    [Documentation]    This Keyword is used to stop traffic and validate
    Log to console    Verify cumulative tput for all 60 UEs...
    Run Keyword And Ignore Error    Stop And Validate SA Traffic For MultiUE
    Run Keyword And Ignore Error    LTE Traffic should be Successful for MultiUE for CUS
    Run Keyword And Ignore Error    Traffic for NSA should be Successful for MultiUE for CUS
    Validate DL and UL Cumulative Data Rates for MultiUE
    Reset UL and DL Data Rates

LTE Traffic should be Successful for MultiUE for CUS
    [Arguments]    ${traffic_range}=${lte_traffic_range}    ${duration}=10min
    ...   ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueids}=${lte_ueids}
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Run Keyword And Ignore Error    Validate LTE Or NSA Traffic CUS   traffic_range=${traffic_range}
    ...   dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${ueids}
    Stop Traffic For LTE MultiUE For CUS    ${ueids}    ${BEARER_ID_CUS}

Traffic for NSA should be Successful for MultiUE for CUS
    [Arguments]    ${traffic_range}=${nsa_traffic_range}    ${duration}=10min
    ...   ${dl_rate}=${dl_rate_multiue}    ${ul_rate}=${ul_rate_multiue}    ${ueids}=${nsa_ueids}
    [Documentation]    This keyword Validates the Traffic for the NSA FDD/TDD variants for MultiUE
    Run Keyword And Ignore Error    Validate LTE Or NSA Traffic CUS    traffic_range=${nsa_traffic_range}
    ...   dl_rate=${dl_rate}    ul_rate=${ul_rate}    ueids=${nsa_ueids}
    Stop Traffic For LTE MultiUE For CUS    ${ueids}    ${BEARER_ID_CUS}

Stop Traffic For LTE MultiUE For CUS
    [Arguments]    ${ueids}    ${BEARER_ID_CUS}=${BEARER_ID_CUS}
	FOR   ${ueid}   IN   @{ueids}
	    Log to Console    Stopping DL + UL Traffic for UE:${UE_ID}
        Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=${BEARER_ID_CUS}    trf_id=1
        Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=${BEARER_ID_CUS}    trf_id=2
    END

Start SA NSA Forward HO for CUS and Validate
    [Documentation]    This Keyword is used for SA and NSA Forward HO and Validate
    Start SA HO for Combo And Validate
    Start NSA HO for CUS And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}
    Run Keyword And Ignore Error    Validate SA NSA and LTE Throughput For CUS
    Reset UL and DL Data Rates

Start NSA HO for CUS And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}
    ...    ${lua_method}=MultiUeScript.mue_nsa_handover
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_1})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_2})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_3})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_4})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_5})
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_6})
    FOR    ${ueid}    IN    @{nsa_ueids}
        Validation of CUS HO scenario    ${ueid}    ${NSA_HO_pattern}
    END

Validation of CUS HO scenario
    [Arguments]    ${ueid}    ${validation_string}
    ${updated_validation_string}=    Set Variable    UE${ueid}:.*${validation_string}
    ${result}   ${value}=    Run Keyword And Ignore Error
    ...    Check Pattern in Egate Log    ${updated_validation_string}    ${validation_string}
    Run Keyword If    '${result}' == 'FAIL'    wtsrunner.read_wtsemu_output_until_re    expected=${updated_validation_string}     timeout=120

Start SA NSA Reverse HO for CUS and Validate
    [Documentation]    This Keyword is used for SA and NSA Reverse HO and Validate
    Start Reverse SA HO for Combo And Validate
    Start Reverse NSA HO for CUS And Validate
    Sleep    5s
    Clear Bearer Stats
    Sleep    ${Duration_after_reverse_HO}

Start Reverse NSA HO for CUS And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}
    ...    ${lua_method}=MultiUeScript.mue_nsa_handover
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_RO_param})
    FOR    ${ueid}    IN    @{nsa_ueids}
        Validation of Combo HO scenario    ${ueid}    ${Reverse_NSA_HO_Success}    Reverse_NSA_HO
    END

Check Pattern in Egate Log
    [Arguments]    ${pattern}    ${search_pattern}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 04-April-2023
    ...                Last Modified by: kokila.b@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exist
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}    ${search_pattern}

Search pattern should Exist
    [Arguments]    ${file}    ${pattern}    ${search_pattern}    ${grepArgs}=grep -i    ${script_file}=${run_script_log_set}
    wtsrunner.script    file=${script_file}    entry=sim_log_set_flush()
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${search_pattern}    ignore_case=${TRUE}

Attach and Start NSA UL Traffic for CUS
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}    ${nsa_ueids}=${nsa_ueids}    ${lte_ueids}=${lte_ueids}
    ...    ${nsa_ue}=${nsa_ue}    ${lte_ue}=${lte_ue}   
    log to console    Deregister SA UEs...
    wtsrunner.script_stop
    Run Keyword And Ignore Error    wtsrunner.script    file=${multi_ue_script_SA}
    ...    entry=stop_multiue_call(${sa_ue_range})
    Run Keyword And Ignore Error    Check Pattern in Egate Console Log    ${sa_deregister_string}
    sleep    5s
    log to console    Detach LTE and NSA UEs if already attached...
    Run Keyword And Ignore Error    Detach LTE and NSA UE for CUS    ${nsa_ue}    ${lua_file}    ${nsa_ueids}
    Run Keyword And Ignore Error    Detach LTE and NSA UE for CUS    ${lte_ue}    ${lua_file}    ${lte_ueids}
    sleep    5s
    log to console    Attach NSA UEs...
    NSA Attach for CUS MultiUE    ${multi_ue_script_LTE_NSA}    ${nsa_multi_ue_split_traffic_cus}    ${nsa_ueids}
    Start NSA MultiUE Traffic for CUS

Detach LTE and NSA UE for CUS
    [Arguments]    ${ueid_range}    ${lua_file}    ${ueids}
    ...    ${lua_method}=MultiUeScript.ue_dettach_with_profile
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${ueid_range})
    FOR   ${ueid}   IN   @{ueids}
        ${validation_string}=    Catenate    UE${ueid}: ========================     ${UE_Detach}
        ${status}    Run Keyword And Ignore Error    Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_NSA}
        Run Keyword If    '${status[0]}' == 'FAIL'    Check Pattern in Egate Console Log    ${validation_string}
    END

Start L3 Call and HO For CUS DS Operator and Validate
    [Documentation]    This keyword test UE attach SA and NSA HO cases and validate traffic with DS operator
    Log    "Disable AMF-1 to avoid SA HO issues"
    wtsrunner.amf_config_update    id=1     relative_capacity=0
    SA Register for MultiUE    lua_method=start_multiue_call_with_networkslice
    ...    ue_register_mue_value=${ue_register_mue_sa_value}
    ...    lua_method_stop_string=${ue_register_string}
    Start SA Traffic for Combo MultiUE
    LTE attach for CUS MultiUE    multi_ue_six_operator_value=${lte_multi_ue_cus_operator_value}
    ...    lua_method=MultiUeScript.lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    Start LTE Traffic For CUS MultiUE
    NSA Attach for CUS MultiUE    multi_ue_six_operator_value=${nsa_multi_ue_cus_operator_value}
    ...    lua_method=MultiUeScript.nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy
    sleep    5s
    Start NSA Traffic for CUS MultiUE
    Validate SA LTE and NSA Data rates Before HO For CUS
    Start Forward HO for CUS and Validate 
    Start Reverse HO for CUS and Validate
    Stop Traffic for SA NSA LTE and Validate Throughput for CUS

Start L3 Call and HO For CUS IPV4 Operator and Validate
    [Documentation]    This keyword test UE attach SA and NSA HO cases and validate traffic with IPv4 operator
    SA Register for MultiUE    lua_method=start_multiue_call_with_networkslice
    ...    ue_register_mue_value=${ue_register_mue_sa_value}
    ...    lua_method_stop_string=${ue_register_string}
    Start SA Traffic for Combo MultiUE
    LTE attach for CUS MultiUE    multi_ue_six_operator_value=${lte_multi_ue_cus_operator_value}
    ...    lua_method=MultiUeScript.lte_attach_with_profile_multi_ue_with_range_for_AP_iphy
    Start LTE Traffic For CUS MultiUE
    NSA Attach for CUS MultiUE    multi_ue_six_operator_value=${nsa_multi_ue_cus_operator_value}
    ...    lua_method=MultiUeScript.nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy
    sleep    5s
    Start NSA Traffic for CUS MultiUE
    Validate SA LTE and NSA Data rates Before HO For CUS
    Start Forward HO for CUS and Validate 
    Start Reverse HO for CUS and Validate
    Stop Traffic for SA NSA LTE and Validate Throughput for CUS

Start Forward HO for CUS and Validate
    Log to console    Start Forward HO for SA and NSA UEs...
    Forward SA HO for Combo And Validate
    Forward NSA HO for CUS And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}
    Validate SA NSA and LTE Throughput For CUS
    Reset UL and DL Data Rates

Forward NSA HO for CUS And Validate
    [Arguments]    ${lua_file}=${multi_ue_script_LTE_NSA}
    ...    ${lua_method}=MultiUeScript.mue_nsa_handover
    Log to console    Start forward HO for NSA UEs...
    Run UEx command    script    file=${lua_file}    entry=${lua_method}(${NSA_HO_params_DS})
    FOR    ${ueid}    IN    @{nsa_ueids}
        Validation of CUS HO scenario    ${ueid}    ${NSA_HO_pattern}
    END

Start Reverse HO for CUS and Validate
    Log to console    Start Reverse HO for SA and NSA UEs...
    Reverse SA HO for Combo And Validate
    Start Reverse NSA HO for CUS And Validate
    Clear Bearer Stats
    Sleep    ${Duration_post_HO}

CUS and Egate Sync for DS and IPV4
    Configure CUS Executor should be Successful
    AP Cell Setup should be Successful

Attach NSA Split Traffic for CUS
    [Arguments]    ${Counter_List_cus}=${Counter_List_cus}
    Attach and Start NSA UL Traffic for CUS
    sleep    900s
    Log To Console    Validating via PM counters
    Wait Until Keyword Succeeds    15 min    1 min    Collect PM Counters and validate
