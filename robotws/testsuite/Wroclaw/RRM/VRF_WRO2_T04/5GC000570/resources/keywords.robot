*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library         ./specific_keywords_570.py
Library         taf.sw.reporting_portal
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py   WITH NAME   wro4_pm
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000570/resources/kpi_pm_counters.py


*** Variables ***
${reportingIntervalPm}              300                 # time in sec
${DL_VOLUME_F1}                     M55323C0100         # counter id prefix; postfix (QoS) is added during test
${DL_VOLUME_X2}                     M55313C0800
${MAX_DL_TPUT_F1}                   M55323C0700
${MAX_DL_TPUT_X2}                   M55313C1700
${UL_VOLUME_F1}                     M55323C0300
${UL_VOLUME_X2}                     M55313C1100
${MAX_UL_TPUT_F1}                   M55323C0900
${MAX_UL_TPUT_X2}                   M55313C1900
${avg_tput_deviation}               25                  # in percentage
@{ues}                              SAMSUNG_1  SAMSUNG_2  SAMSUNG_3  SAMSUNG_4


*** Keywords ***
Attach UEs To NR Cell n71
    Show Text on Console   [Attach UEs]
    FOR   ${ue}   IN   @{ues}
        Require Ue     ${ue}  capabilities=${ue}
        enable_band_config   ${ue}   NSA_b2_n71
        Start Tracing On SMOD   filename=attach_${ue}  smod slave=False
        Attach Ue   ${ue}
        ${log_path}   Stop Tracing And Download Logs From SMOD   filename=attach_${ue}   offset=5s
        ${check_qos}   Check QoS Group   ${log_path}
        Should Be Equal   ${check_qos}   ${ue_config}[${ue}][QCI]
        Verify 5G NSA Attach   ue_alias=${ue}  pcap_file=${log_path}
        Log To Console   ${SPACE} QCI: ${check_qos}
    END


Verify Average Tput in Whole Time Period
    Show Text on Console   [Verify average tput from NAA with tput calculated from counters per given QCI]
    FOR   ${ue}   IN   @{ues}
        Get Average Tput   direction=DL   ue=${ue}
        Get Average Tput   direction=UL   ue=${ue}
    END

    wro4_pm.sync_to_next_reporting_interval
    ${counter_ids}   prepare_counters_list
    ${counter_values}   wro4_pm.get_sum_of_n_last_pm_counters_values   ${counter_ids}

    validate_counters_for_no_tput_qci   ${counter_values}
    FOR   ${ue}   IN   @{ues}
        Verify Tput from Counters   direction=DL   ue=${ue}   counter_values=${counter_values}
        Verify Tput from Counters   direction=UL   ue=${ue}   counter_values=${counter_values}
    END


Get Average Tput
    [Arguments]     ${direction}  ${ue}
    ${avg_tput_test}   Get Average Throughput   dt_name=DT_${direction}_${ue}  from_last=${300}   tput_collection_src=control_app
    ${avg_tput}   Get Average Throughput   dt_name=DT_${direction}_${ue}  from_last=${300}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Set Test Variable   ${${ue}_${direction}_naa_avg_tput}   ${avg_tput}


Verify Tput from Counters
    [Arguments]     ${direction}  ${ue}  ${counter_values}
    ${f1_counters}  ${x2_counters}   Prepare counters to check   direction=${direction}   qci=${ue_config}[${ue}][QCI]
    ${avg_pm_tput}  ${max_pm_tput}   calculate_tput_from_counters
    ...     pm_values=${counter_values}
    ...     ues_no=${ue_config}[${ue}][ues_no]
    ...     split_mode=${ue_config}[${ue}][split_mode_${direction.lower()}]
    ...     f1_counters=${f1_counters}
    ...     x2_counters=${x2_counters}

    ${avg_tput_diff}   Evaluate   abs((${avg_pm_tput} - ${${ue}_${direction}_naa_avg_tput}) / ${avg_pm_tput} * 100)
    ${avg_tput_diff}   Evaluate   "%.2f" % ${avg_tput_diff}
    Run Keyword And Continue On Failure    Should Be True   ${avg_tput_diff} < ${avg_tput_deviation}

    Run Keyword And Continue On Failure    Should Be True   ${max_pm_tput} >= ${avg_pm_tput}

    Log To Console   ${ue} ${direction} TPUT measurements: \n${SPACE} PM_MAX_TPUT: ${max_pm_tput} Mbits/sec,
    Log To Console   ${SPACE} PM_AVG_TPUT: ${avg_pm_tput} Mbits/sec,
    Log To Console   ${SPACE} NAA_AVG_TPUT: ${${ue}_${direction}_naa_avg_tput} Mbits/sec,
    Log To Console   ${SPACE*7} AVG TPUT Difference: ${avg_tput_diff}% \n


Prepare counters to check
    [Arguments]  ${direction}   ${qci}
    ${volume_f1}    Set Variable If  '${direction}' == 'DL'  ${DL_VOLUME_F1}${qci}  ${UL_VOLUME_F1}${qci}
    ${volume_x2}    Set Variable If  '${direction}' == 'DL'  ${DL_VOLUME_X2}${qci}  ${UL_VOLUME_X2}${qci}
    ${max_tput_f1}  Set Variable If  '${direction}' == 'DL'  ${MAX_DL_TPUT_F1}${qci}  ${MAX_UL_TPUT_F1}${qci}
    ${max_tput_x2}  Set Variable If  '${direction}' == 'DL'  ${MAX_DL_TPUT_X2}${qci}  ${MAX_UL_TPUT_X2}${qci}

    @{f1_counters}   Create List   ${volume_f1}  ${max_tput_f1}
    @{x2_counters}   Create List   ${volume_x2}  ${max_tput_x2}

    [Return]   ${f1_counters}  ${x2_counters}


Calculate KPIs and send report to REP
    ${NR_59b}  ${NR_973a}   calculate_latency_kpis
    ${kpi_list}   Get Dictionary Keys   ${KPIs}
    FOR   ${kpi}   IN   @{kpi_list}
        ${value_to_report}   Convert To String   ${${KPIs}[${kpi}][kpi_id]}

        Run Keyword And Continue On Failure    Validate KPI   ${kpi}  ${value_to_report}

        taf.sw.reporting_portal.Report KPI Results
        ...   name=${KPIs}[${kpi}][kpi_id]
        ...   target=${KPIs}[${kpi}][target]
        ...   value=${value_to_report}
        ...   visible_to_db=True
        ...   kpi_type=${KPIs}[${kpi}][type]
        ...   description=${KPIs}[${kpi}][description]
        ...   category=Performance
        ...   unit=${KPIs}[${kpi}][unit]
    END


Validate KPI
    [Arguments]   ${kpi}  ${value_to_report}
    Should Be True   ${value_to_report} <= ${KPIs}[${kpi}][target]
    Log To Console
    ...   \n${kpi} measurements:\n MAX ACCEPTED: ${KPIs}[${kpi}][target] ${KPIs}[${kpi}][unit],\n MEASURED: ${value_to_report} ${KPIs}[${kpi}][unit]


Detach UEs
    FOR  ${ue}  IN  @{ues}
        enable_band_config   ${ue}   NR_ONLY
        Detach Ue    ue_alias=${ue}
        Clear NAA Storage   ${ue}
    END
