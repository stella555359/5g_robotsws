*** Settings ***
Documentation     This contains common keywords which are needed to run P0 L3 Calls.

Resource    common_keywords.robot

*** Variables ***
${PARALLEL_TRF}    False     #Variable to run parallel traffic SA+NSA+DL+UL+FDD+TDD all Parallel: Default is False
${SEQ_TRAFFIC}    True       #Variable to Run UL and DL Sequentially : Default is True
${SA_TRAFFIC}    True        #Variable to Run SA Traffic , Pass NSA Traffic as False to trigger only SA Traffic : Default is True
${NSA_TRAFFIC}    True       #Variable to Run NSA Traffic , Pass SA Traffic as False to trigger only NSA Traffic : Default is True
${FR1_TDD}    True           #Variable to Run Only TDD in FR1 , Pass FR1_FDD as False to trigger only TDD : Default is True
${FR1_FDD}    True           #Variable to Run Only FDD in FR1 , Pass FR1_TDD as False to trigger only FDD : Default is True
${Traffic_BIP}    True       #Variable to cllect Traffic BIP log : Default is True
#${TRF_DL}    True           #variable to disable DL data traffic
#${TRF_UL}    True           #variable to disable UL data traffic

*** Keywords ***
Traffic Execution Success
    Run Keyword If    '${PARALLEL_TRF}' == 'True'    Parallel Traffic should be Successful
    ...    ELSE    Run Keywords    SA Traffic should be Successful    AND    NSA Traffic should be Successful

SA Traffic should be Successful
    Return From Keyword If    '${SA_TRAFFIC}' == 'False'
    Run Keyword If    '${SEQ_TRAFFIC}' == 'True'    Traffic should be Successful for SA DL UL sequential    ELSE
    ...       Traffic should be Successful for SA Parallelly

NSA Traffic should be Successful
    Return From Keyword If    '${NSA_TRAFFIC}' == 'False'
    Run Keyword If    '${SEQ_TRAFFIC}' == 'True'    Traffic should be Successful for NSA DL UL sequential    ELSE
    ...       Traffic should be Successful for NSA Parallelly

Traffic should be Successful for SA DL UL sequential
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 17-Feb-2026
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to None
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate SA Traffic for Seq Flow

Traffic should be Successful for NSA DL UL sequential
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 21-Jun-2022
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to None
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate NSA Traffic for Seq Flow

Generate NSA Traffic for Seq Flow
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate Traffic for NSA TDD FDD Sequential
    ...    ELSE    Generate NSA Traffic SEQ

Generate Traffic for NSA TDD FDD Sequential
    Datarates for NSA TDD_FDD
    Run Keyword If    '${TRF_UL}' == 'True'    Traffic Generation for NSA TDD FDD Direction    ul
    Run Keyword If    '${TRF_DL}' == 'True'    Traffic Generation for NSA TDD FDD Direction    dl

Datarates for NSA TDD_FDD
    Datarates for NSA TDD
    Datarates for NSA FDD

Generate NSA Traffic SEQ
    Highthroughput datarates for NSA QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate Traffic for NSA Direction    ul    ${traffic_ul_rate}
    ...    Verify UE_stats Throughput Average Datarate for NSA_UL
    Run Keyword If    '${TRF_DL}' == 'True'    Generate Traffic for NSA Direction    dl    ${traffic_dl_rate}
    ...    Verify UE_stats Throughput Average Datarate for NSA_DL

Generate Traffic for NSA Direction
    [Arguments]    ${dir}    ${rate}    ${verify_keyword}
    Start NSA Traffic	  ${UE_ID_SANSA}    ${rate}    ${dir}
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s    ${verify_keyword}
    Stop Traffic NSA
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword And Continue On Failure    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Start NSA Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate Traffic Id Numbers    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate NSA Traffic for Maximum Datarate    ${ue_id}
    ...    ${trf_id}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate Traffic for Last Datarate NSA    ${ue_id}    ${trf_id}
    ...    ${dir}    ${last_trf_rate}
    END

Verify UE_stats Throughput Average Datarate for NSA_UL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for NSA_TDD_FDD_UL
    ...    ELSE    Verify UE_stats Average Datarate for NSA_UL    ${UE_ID_SANSA}    ${traffic_ul_rate}

Verify UE_stats Average Datarate for NSA_TDD_FDD_UL
    Run Keyword If    '${FR1_TDD}' == 'True'    Verify UE_stats Average Datarate for NSA_UL    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_ul_rate}
    Run Keyword If    '${FR1_FDD}' == 'True'    Verify UE_stats Average Datarate for NSA_UL    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_ul_rate}

Verify UE_stats Throughput Average Datarate for NSA_DL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for NSA_TDD_FDD_DL
    ...    ELSE    Verify UE_stats Average Datarate for NSA_DL    ${UE_ID_SANSA}    ${traffic_dl_rate}

Verify UE_stats Average Datarate for NSA_TDD_FDD_DL
    Run Keyword If    '${FR1_TDD}' == 'True'    Verify UE_stats Average Datarate for NSA_DL    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}
    Run Keyword If    '${FR1_FDD}' == 'True'    Verify UE_stats Average Datarate for NSA_DL    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}

Verify UE_stats Average Datarate for NSA Direction
    [Arguments]    ${ueid}    ${rate}    ${dir}
    IF    '${CARR_AGGR}' == 'True'
        IF    '${dir}' == 'ul'
            ${data_rate}=    Get UE stats for UL Carrier aggregation    ue=${ueid}
        ELSE
            ${data_rate}=    Get UE stats for DL Carrier aggregation    ue=${ueid}
        END
    ELSE
        IF    '${dir}' == 'ul'
            ${data_rate}=    Get Average data rate for UE via Egate UL    ue=${ueid}    scell=primary,secondary    type=pusch
        ELSE
            ${data_rate}=    Get Average data rate for UE via Egate DL    ue=${ueid}    scell=primary,secondary    type=pdsch
        END
    END
    ${avg_traffic1}=    Evaluate    (${rate}*0.9)*1000000
    ${avg_traffic2}=    Evaluate    (${rate}*1.2)*1000000
    ${dir_upper}=    Evaluate    '${dir}'.upper()
    Should Be True    ${data_rate} >= ${avg_traffic1}    msg=${dir_upper} avg Traffic Failed! for Cell
    ${status}=    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${avg_traffic2}
    ...    msg=${dir_upper} avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    ${dir_upper} avg Traffic is more than actual

Verify UE_stats Average Datarate for NSA_UL
    [Arguments]    ${ueid}    ${UL_RATE}
    Verify UE_stats Average Datarate for NSA Direction    ${ueid}    ${UL_RATE}    ul

Verify UE_stats Average Datarate for NSA_DL
    [Arguments]    ${ueid}    ${DL_RATE}
    Verify UE_stats Average Datarate for NSA Direction    ${ueid}    ${DL_RATE}    dl

Verify UE_stats Average Datarate for NSA_TDD_FDD
    Verify UE_stats Average Datarate for NSA    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}    ${traffic_nsa_tdd_ul_rate}
    Verify UE_stats Average Datarate for NSA    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}    ${traffic_nsa_fdd_ul_rate}

Traffic Generation for NSA TDD FDD Direction
    [Arguments]    ${dir}
    Log Traffic Bearer stats without verification NSA    ${dir}
    ${tdd_rate}=    Set Variable If    '${dir}' == 'ul'    ${traffic_nsa_tdd_ul_rate}    ${traffic_nsa_tdd_dl_rate}
    ${fdd_rate}=    Set Variable If    '${dir}' == 'ul'    ${traffic_nsa_fdd_ul_rate}    ${traffic_nsa_fdd_dl_rate}
    Run Keyword If    '${FR1_TDD}' == 'True'    Generate Single Duplex NSA Traffic    ${nsa_ueid_tdd_HTpQT}    ${tdd_rate}    ${dir}
    Run Keyword If    '${FR1_FDD}' == 'True'    Generate Single Duplex NSA Traffic    ${nsa_ueid_fdd_HTpQT}    ${fdd_rate}    ${dir}
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${verify_kw}=    Set Variable If    '${dir}' == 'ul'    Verify UE_stats Throughput Average Datarate for NSA_UL
    ...    Verify UE_stats Throughput Average Datarate for NSA_DL
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s    ${verify_kw}
    Log Traffic Bearer stats without verification NSA    ${dir}
    Stop Traffic NSA
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword And Continue On Failure    Run Keyword If    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Generate Single Duplex NSA Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate Traffic Id Numbers    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate NSA Traffic for Maximum Datarate    ${ue_id}
    ...    ${trf_id}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate Traffic for Last Datarate NSA    ${ue_id}    ${trf_id}
    ...    ${dir}    ${last_trf_rate}
    END

Generate NSA Traffic for Maximum Datarate
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${max_data_rate}  dir=${dir}  size=${burst_size}

Stop Traffic NSA
    Traffic Stop For NSA    ${nsa_ueid_tdd_HTpQT}
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Traffic Stop For NSA    ${nsa_ueid_fdd_HTpQT}

Traffic Stop For NSA
    [Arguments]    ${UE_ID_NSA}    ${bearer_id}=${BEARER_ID}
    Log to Console    Stopping DL + UL NSA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_NSA}    id=${bearer_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Get UE stats for Carrier aggregation
    [Arguments]    ${ue}    ${dir}
    set suite variable    ${ca_ag}    True
    ${data_rate}=    Run Keyword If    '${dir}' == 'ul'    Display UE traffic stats UL    ue=${ue}    scell=primary,secondary    type=pusch
    ...    ELSE    Display UE traffic stats DL    ue=${ue}    scell=primary,secondary    type=pdsch
    [Return]    ${data_rate}

Get UE stats for UL Carrier aggregation
    [Arguments]    ${ue}
    ${data_rate}=    Get UE stats for Carrier aggregation    ue=${ue}    dir=ul
    [Return]    ${data_rate}

Log Traffic Bearer stats without verification NSA
    [Arguments]    ${dir}
	FOR    ${ue}    IN    @{UE_IDs_NSA}
        wtsrunner.bearer_stats    ue=${ue}    id=2    dir=${dir}
        ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
	END

Log Traffic Bearer stats without verification SA Sequential
    [Arguments]    ${UE_ID}=${UE_ID}    ${qfi}=1
	FOR    ${UE_ID}    IN    @{UE_IDs_SA}
        wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
        ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
    END

Log Traffic Bearer stats without verification NSA Sequential
    Log Traffic Bearer stats without verification NSA    dl
    Log Traffic Bearer stats without verification NSA    ul

Datarates for NSA TDD
    [Documentation]    This keyword will set Highthroughput values for QT NSA TDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_tdd_dl_rate}
    ...    ${MTp_FR1_TDD_NSA_dl}
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_tdd_ul_rate}
    ...    ${MTp_FR1_TDD_NSA_ul}

Datarates for NSA FDD
    [Documentation]    This keyword will set Highthroughput values for QT NSA FDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_fdd_dl_rate}
    ...    ${MTp_FR1_FDD_NSA_dl}
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_fdd_ul_rate}
    ...    ${MTp_FR1_FDD_NSA_ul}

Traffic should be Successful for SA Parallelly
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 04-Jul-2022
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate Traffic for SA
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Traffic Bearer stats without verification SA Sequential
    ...              ELSE    Log Traffic Bearer stats without verification
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Datarate for SA
    Stop Traffic SA
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword And Continue On Failure    Run Keyword If    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Generate Traffic for SA
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate Traffic SA TDD FDD
    ...    ELSE    Generate Single Duplex SA Traffic

Generate Traffic SA TDD FDD
    Datarates for SA TDD_FDD
    Run Keyword If    '${FR1_TDD}' == 'True' and '${TRF_UL}' == 'True'    Start SA Traffic    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_ul_rate}    ul
    Run Keyword If    '${FR1_TDD}' == 'True' and '${TRF_DL}' == 'True'    Start SA Traffic    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}    dl
    Run Keyword If    '${FR1_FDD}' == 'True' and '${TRF_UL}' == 'True'    Start SA Traffic    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_ul_rate}    ul
    Run Keyword If    '${FR1_FDD}' == 'True' and '${TRF_DL}' == 'True'    Start SA Traffic    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}    dl

Generate Single Duplex SA Traffic
    Highthroughput datarates for SA QT
    Run Keyword If    '${TRF_DL}' == 'True'    Start SA Traffic    ${ueid}    ${traffic_dl_rate}    dl
    Run Keyword If    '${TRF_UL}' == 'True'    Start SA Traffic    ${ueid}    ${traffic_ul_rate}    ul

Datarates for SA TDD_FDD
    Throughput for SA TDD
    Throughput for SA FDD

Throughput for SA TDD
    [Documentation]    This keyword will set Highthroughput values for QT SA TDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_tdd_dl_rate}
    ...    ${MTp_FR1_TDD_SA_dl}
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_tdd_ul_rate}
    ...    ${MTp_FR1_TDD_SA_ul}

Throughput for SA FDD
    [Documentation]    This keyword will set Highthroughput values for QT SA FDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_fdd_dl_rate}
    ...    ${MTp_FR1_FDD_SA_dl}
    Run Keyword If    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_fdd_ul_rate}
    ...    ${MTp_FR1_FDD_SA_ul}

Generate SA Traffic for Seq Flow
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate SA TDD FDD Traffic Sequentially
    ...    ELSE    Generate SA Traffic Sequentially

Generate SA TDD FDD Traffic Sequentially
    Datarates for SA TDD_FDD
    Run Keyword If    '${TRF_UL}' == 'True'    Generate Traffic for SA TDD FDD Direction    ul
    Run Keyword If    '${TRF_DL}' == 'True'    Generate Traffic for SA TDD FDD Direction    dl

Generate SA Traffic Sequentially
    Highthroughput datarates for SA QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate Traffic for SA Direction    ul    ${traffic_ul_rate}
    ...    Verify UE_stats Throughput Average Datarate for SA_UL
    Run Keyword If    '${TRF_DL}' == 'True'    Generate Traffic for SA Direction    dl    ${traffic_dl_rate}
    ...    Verify UE_stats Throughput Average Datarate for SA_DL

Generate Traffic for SA Direction
    [Arguments]    ${dir}    ${rate}    ${verify_keyword}
    Start SA Traffic    ${ueid}    ${rate}    ${dir}
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Traffic Bearer stats without verification
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s    ${verify_keyword}
    Run Keyword If    '${status}' == 'False' and '${dir}' == 'ul'    Collection of em traces and em Perf
    Stop Traffic SA
    Run Keyword And Continue On Failure    Run Keyword If    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Generate Traffic for SA TDD FDD Direction
    [Arguments]    ${dir}
    Log Traffic Bearer stats without verification SA Sequential
    ${tdd_rate}=    Set Variable If    '${dir}' == 'ul'    ${traffic_sa_tdd_ul_rate}    ${traffic_sa_tdd_dl_rate}
    ${fdd_rate}=    Set Variable If    '${dir}' == 'ul'    ${traffic_sa_fdd_ul_rate}    ${traffic_sa_fdd_dl_rate}
    Run Keyword If    '${FR1_TDD}' == 'True'    Start SA Traffic    ${sa_ueid_tdd_HTpQT}    ${tdd_rate}    ${dir}
    Run Keyword If    '${FR1_FDD}' == 'True'    Start SA Traffic    ${sa_ueid_fdd_HTpQT}    ${fdd_rate}    ${dir}
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Traffic Bearer stats without verification SA Sequential
    ${verify_kw}=    Set Variable If    '${dir}' == 'ul'    Verify UE_stats Throughput Average Datarate for SA_UL
    ...    Verify UE_stats Throughput Average Datarate for SA_DL
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s    ${verify_kw}
    Stop Traffic SA
    Run Keyword And Continue On Failure    Run Keyword If    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Stop Traffic SA
    Traffic Stop SA    ${sa_ueid_tdd_HTpQT}
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Traffic Stop SA    ${sa_ueid_fdd_HTpQT}

Traffic Stop SA
    [Arguments]    ${UE_ID_SA}    ${qfi}=1
    Log to Console    Stopping DL + UL SA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_SA}   pdu=1   qfi=${qfi}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Start SA Traffic
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate Traffic Id Numbers    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate SA Traffic for Maximum Datarate    ${ue_id}
    ...    ${trf_id}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate Traffic for Last Datarate SA    ${ue_id}    ${trf_id}
    ...    ${dir}    ${last_trf_rate}
    END

Calculate Traffic Id Numbers
    [Arguments]    ${rate}
    ${num_trf_final}    ${last_trf_rate_final}=    Calculate Number Of Traffic Ids    ${rate}
    [Return]    ${num_trf_final}    ${last_trf_rate_final}

Generate SA Traffic for Maximum Datarate
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${max_data_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_1}  size=${burst_size}

Generate Traffic for Last Datarate SA
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${last_trf_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_1}  size=${burst_size}

Verify UE_stats Throughput Average Datarate for SA
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for SA_TDD_FDD
    ...    ELSE    Verify UE_stats Average Datarate for SA    ${UE_ID}    ${traffic_dl_rate}    ${traffic_ul_rate}

Verify UE_stats Average Datarate for SA_TDD_FDD
    Run Keyword If    '${FR1_TDD}' == 'True'    Verify UE_stats Average Datarate for SA
    ...    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}    ${traffic_sa_tdd_ul_rate}
    Run Keyword If    '${FR1_FDD}' == 'True'    Verify UE_stats Average Datarate for SA
    ...    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}    ${traffic_sa_fdd_ul_rate}

Verify UE_stats Average Datarate for SA
    [Arguments]    ${ueid}    ${DL_RATE}    ${UL_RATE}
    IF    '${TRF_DL}' == 'True'
        ${data_rate}=     Get Average data rate for UE via Egate DL    ue=${ueid}    scell=primary,secondary    type=pdsch
        ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
        ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
        Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
        ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
        Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual
    END
    IF    '${TRF_UL}' == 'True'
        ${data_rate}=     Get Average data rate for UE via Egate UL    ue=${ueid}    scell=primary,secondary    type=pusch
        ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
        ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
        Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
        ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic more than actual
        Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual
    END

Verify UE_stats Throughput Average Datarate for SA_UL
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for SA_TDD_FDD_UL
    ...    ELSE    Verify UE_stats Average Datarate for SA_UL    ${UE_ID}    ${traffic_ul_rate}

Verify UE_stats Average Datarate for SA_TDD_FDD_UL
    Run Keyword If    '${FR1_TDD}' == 'True'    Verify UE_stats Average Datarate for SA_UL    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_ul_rate}
    Run Keyword If    '${FR1_FDD}' == 'True'    Verify UE_stats Average Datarate for SA_UL    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_ul_rate}

Verify UE_stats Average Datarate for SA Direction
    [Arguments]    ${ueid}    ${rate}    ${dir}
    ${data_rate}=    Run Keyword If    '${dir}' == 'ul'    Get Average data rate for UE via Egate UL    ue=${ueid}    scell=primary,secondary
    ...    type=pusch    ELSE    Get Average data rate for UE via Egate DL    ue=${ueid}    scell=primary,secondary    type=pdsch
    ${avg_traffic1}=    Evaluate    (${rate}*0.9)*1000000
    ${avg_traffic2}=    Evaluate    (${rate}*1.2)*1000000
    ${dir_upper}=    Evaluate    '${dir}'.upper()
    Should Be True    ${data_rate} >= ${avg_traffic1}    msg=${dir_upper} avg Traffic Failed! for Cell
    ${status}=    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${avg_traffic2}
    ...    msg=${dir_upper} avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    ${dir_upper} avg Traffic is more than actual

Verify UE_stats Average Datarate for SA_UL
    [Arguments]    ${ueid}    ${UL_RATE}
    Verify UE_stats Average Datarate for SA Direction    ${ueid}    ${UL_RATE}    ul

Verify UE_stats Throughput Average Datarate for SA_DL
    Run Keyword If    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for SA_TDD_FDD_DL
    ...    ELSE    Verify UE_stats Average Datarate for SA_DL    ${UE_ID}    ${traffic_dl_rate}

Get UE stats for DL Carrier aggregation
    [Arguments]    ${ue}
    ${data_rate}=    Get UE stats for Carrier aggregation    ue=${ue}    dir=dl
    [Return]    ${data_rate}

Get Average data rate for UE via Egate UL
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=UL
    Log    !!!${dl_ul}!!!
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${data_rate}=    Display UE traffic stats UL    ue=${ue}    scell=${scell}    type=${type}
    [Return]    ${data_rate}

Display UE traffic stats
    [Arguments]    ${ue}    ${scell}    ${type}    ${dir}=UL
    ${dl_ul}=    Evaluate    '${dir}'.upper()
    ${channel}=    Set Variable If    '${dl_ul}' == 'UL'    PUSCH    PDSCH
    wtsrunner.ue_stats_nr  id=${ue}  type=${type} scell=${scell}
    Sleep    2s    reason=wait command to be executed
    ${output}      wtsrunner.read_wtsemu_output_until    expected=UE-${ue}: NR ${channel}
    ...     timeout=30
    ${data_rate}=    Get Average data rate from Egate output for SANSA UE    ${output}    ${ue}    ${dl_ul}
    ${data_rate}=    Convert to Number    ${data_rate}
    [Return]    ${data_rate}

Display UE traffic stats UL
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=UL
    ${data_rate}=    Display UE traffic stats    ue=${ue}    scell=${scell}    type=${type}    dir=${dl_ul}
    [Return]    ${data_rate}

Get Average data rate from Egate output for SANSA UE
    [Arguments]    ${output}    ${ue}    ${dl_ul}
    ${output}=    Get Average data rate from Egate Console log File    ue=${ue}    dl_ul=${dl_ul}
    ${output_1}=    Get Regexp Matches    ${output}    ${SPACE}*(\\d+\.\\d+)${SPACE}*Mbps${SPACE}*    1
    ${output_1}    Evaluate    ${output_1}[-1]
    Append To File    ${OUTPUT_DIR}/l3call_tp.txt    \nUE${ue}:${dl_ul} Average data rate: ${output_1} Mbit/s
    ${data_rate}=     Evaluate    ${output_1} * 1000000
    [Return]    ${data_rate}

Get Average data rate from Egate Console log File
    [Arguments]    ${ue}    ${dl_ul}
    ${output}=    Run Keyword If    '${ca_ag}' == 'False'    Derive Average data from Egate console log file    ue=${ue}    dl_ul=${dl_ul}
    ...    mode=NON_CA    ELSE    Derive Average data from Egate console log file    ue=${ue}    dl_ul=${dl_ul}    mode=CA
    Return From Keyword    ${output}

Derive Average data from Egate console log file
    [Arguments]    ${ue}    ${dl_ul}    ${mode}=NON_CA    ${file}=${run_script_log_set}
    Log to console    Fetching ue_nr_stats from egate_console file!!!
    wtsrunner.ue_disp   id=${ue}
    sleep    5s
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    sleep    5s
    ${output}=    Run Keyword If    '${dl_ul}' == 'UL'
    ...    find_tput_stats_from_egate_console_file    UE-${ue}: NR PUSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=${mode}
    ...    ELSE    find_tput_stats_from_egate_console_file    UE-${ue}: NR PDSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=${mode}
    Return From Keyword    ${output}

Verify UE_stats Average Datarate for SA_TDD_FDD_DL
    Run Keyword If    '${FR1_TDD}' == 'True'    Verify UE_stats Average Datarate for SA_DL    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}
    Run Keyword If    '${FR1_FDD}' == 'True'    Verify UE_stats Average Datarate for SA_DL    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}

Verify UE_stats Average Datarate for SA_DL
    [Arguments]    ${ueid}    ${DL_RATE}
    Verify UE_stats Average Datarate for SA Direction    ${ueid}    ${DL_RATE}    dl

Get Average data rate for UE via Egate DL
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=DL
    Log    !!!${dl_ul}!!!
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${data_rate}=    Display UE traffic stats DL    ue=${ue}    scell=${scell}    type=${type}
    [Return]    ${data_rate}

Display UE traffic stats DL
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=DL
    ${data_rate}=    Display UE traffic stats    ue=${ue}    scell=${scell}    type=${type}    dir=${dl_ul}
    [Return]    ${data_rate}

Traffic should be Successful for NSA Parallelly
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 21-Jun-2022
    ...                Last Modified by: sravani.k@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Traffic Bearer stats without verification NSA Sequential
    Generate Traffic for NSA
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Traffic Bearer stats without verification NSA Sequential
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Datarate for NSA
    Stop Traffic NSA
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword And Continue On Failure    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Generate Traffic for NSA
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate Traffic NSA TDD FDD
    ...    ELSE    Generate Duplex NSA Traffic

Generate Duplex NSA Traffic
    Highthroughput datarates for NSA QT
    Run Keyword If    '${TRF_DL}' == 'True'    Start NSA Traffic    ${UE_ID_SANSA}    ${traffic_dl_rate}    dl
    Run Keyword If    '${TRF_UL}' == 'True'    Start NSA Traffic	${UE_ID_SANSA}    ${traffic_ul_rate}    ul

Generate Traffic NSA TDD FDD
    Highthroughput datarates for NSA TDD_FDD QT
    Run Keyword If    '${FR1_TDD}' == 'True' and '${TRF_UL}' == 'True'    Start NSA Traffic
    ...    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_ul_rate}    ul
    Run Keyword If    '${FR1_TDD}' == 'True' and '${TRF_DL}' == 'True'    Start NSA Traffic
    ...    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}    dl
    Run Keyword If    '${FR1_FDD}' == 'True' and '${TRF_UL}' == 'True'    Start NSA Traffic
    ...    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_ul_rate}    ul
    Run Keyword If    '${FR1_FDD}' == 'True' and '${TRF_DL}' == 'True'    Start NSA Traffic
    ...    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}    dl

Generate Traffic for Last Datarate NSA
    [Arguments]    ${ue_id}    ${trf_id}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${last_trf_rate}  dir=${dir}  size=${burst_size}

Log Traffic Bearer stats without verification
    [Arguments]    ${UE_ID}=${UE_ID}    ${qfi}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval    timeout=30
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval    timeout=30

Verify UE_stats Throughput Average Datarate for NSA
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Datarate for NSA_TDD_FDD
    ...    ELSE    Verify UE_stats Average Datarate for NSA    ${UE_ID_SANSA}    ${traffic_dl_rate}    ${traffic_ul_rate}

Verify UE_stats Average Datarate for NSA
    [Arguments]    ${ueid}    ${DL_RATE}    ${UL_RATE}
    IF    '${TRF_DL}' == 'True'
        ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for DL Carrier aggregation    ${ueid}    ELSE
        ...    Get Average data rate for UE via Egate DL    ${ueid}    primary,secondary    pdsch
        ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
        ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
        Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
        ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
        Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual
    END
    IF    '${TRF_UL}' == 'True'
        ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for UL Carrier aggregation    ${ueid}    ELSE
        ...    Get Average data rate for UE via Egate UL    ${ueid}    primary,secondary    pusch
        ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
        ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
        Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
        ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic more than actual
        Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual
    END

Test Setup for Traffic
    [Arguments]    ${prefix}=SA_NSA_TRF
    [Documentation]    This keyword is used to start the TCPDUMP for SA Traffic
    ...                Modified Date: 26-june-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword If    '${IQ_ENABLE_FLAG}' == 'True'    Run Keyword and Ignore Error    Stopping IQ capture
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${Traffic_BIP}' == 'True'    Start sosReport Tcpdump    ${prefix}
    Run Keyword If    '${TTI_TRACE}' == 'True'    Start TTI Traces    SA__NSA_TRF
    Run Keyword If    '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Start L2PS TTI Traces
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Start WTS tcpdump for Traffic    UDP_SA_NSA_TRF

Test Teardown for Traffic
    [Arguments]    ${prefix}=SA_NSA_TRF
    [Documentation]    This keyword is used to stop the TCPDUMP for SA Traffic
    ...                Modified Date: 26-june-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Stop WTS tcpdump for Traffic    UDP_SA_TRF    ${exclude_pcap}
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${Traffic_BIP}' == 'True'    Stop Attach and Data Traffic TCPDUMP   ${prefix}
    Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Collect L2PS TTI Traces    TTI_SA_NSA_TRF
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot
    Run Keyword If    '${TTI_TRACE}' == 'True'    Stop and Copy TTI Traces    SA_TRF    ${exclude_pcap}

Parallel Traffic should be Successful
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Run Keyword If    '${SA_TRAFFIC}' == 'True'    Generate Traffic for SA
    Run Keyword If    '${NSA_TRAFFIC}' == 'True'    Generate Traffic for NSA
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Traffic Bearer stats without verification SA Sequential
    ...    ELSE    Log Traffic Bearer stats without verification
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Traffic Bearer stats without verification NSA Sequential
    ${status_SA}=    Run Keyword If    '${SA_TRAFFIC}' == 'True'    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1min    12s    Verify UE_stats Throughput Average Datarate for SA
    Run Keyword If    '${SA_TRAFFIC}' == 'True'    Run Keywords    Stop Traffic SA    AND
    ...    Run Keyword And Continue On Failure    Run Keyword If    '${status_SA}' == 'False'    Fail    msg=SA Traffic Failed
    ${status_NSA}=    Run Keyword If    '${NSA_TRAFFIC}' == 'True'    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1min    12s    Verify UE_stats Throughput Average Datarate for NSA
    Run Keyword If    '${NSA_TRAFFIC}' == 'True'     Run Keywords    Stop Traffic NSA    AND
    ...    Run Keyword And Continue On Failure    Run Keyword If    '${status_NSA}' == 'False'    Fail    msg=NSA Traffic Failed