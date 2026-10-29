*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      CB007227_Keywords.py
Library      ta5g_pm_counters
Library      ta5g_throughput
Library      ta_messaging
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb
Library      ta_pcmd

*** Variables ***
${PM_MOID_NRCELL-1}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${PM_MOID_NRCELL-2}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2

${upload_time_report_field}      timeOfUeDataBurstRx
${upload_rlc_report_field}       sumOfRlcSduRxDataBurstBytes

${download_time_report_field}    timeOfUeDataBurstTx
${download_pdcp_report_field}    sumOfPdcpSduTxDataBurstBytes

${upload_rlc_pmcounter}          M55349C03001
${upload_time_pmcounter}         M55349C04001

${download_pdpc_pmcounter}       M55350C07001
${download_time_pmcounter}       M55350C08001

${first_ran_ue_id}               00:00:00:00:00:00:00:00
${second_ran_ue_id}              00:00:00:00:00:02:00:00

*** Keywords ***
Register And Start Traffic And Save Alias For UE
    [Arguments]    ${the_ue_id}    ${ue_alias}
    Register and Start Traffic for UE    the_ue_id=${the_ue_id}
    Save C-RNTI Of Active ${ue_alias}

Stop Internal SA Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id}

Perform PCMD Record Verification
    [Documentation]    Gathers PCMD reports for both Upload and Download
    ...                Throughput and compares the values with correlating
    ...                margins and PM counters.
    [Arguments]    ${ue_alias}    ${PM_counters}    ${ran_ue_id}
    Perform PCMD Record Verification For Upload
    ...    burst_field=${upload_rlc_report_field}
    ...    time_field=${upload_time_report_field}
    ...    ue_alias=${ue_alias}
    ...    PM_counters=${PM_counters}
    ...    burst_pmcounter=${upload_rlc_pmcounter}
    ...    time_pmcounter=${upload_time_pmcounter}

    Perform PCMD Record Verification For Download
    ...    burst_field=${download_pdcp_report_field}
    ...    time_field=${download_time_report_field}
    ...    ue_alias=${ue_alias}
    ...    PM_counters=${PM_counters}
    ...    burst_pmcounter=${download_pdpc_pmcounter}
    ...    time_pmcounter=${download_time_pmcounter}
    ...    ran_ue_id=${ran_ue_id}


Perform PCMD Record Verification For Upload
    [Documentation]    This keyword takes burst_field and time_field
    ...                PCMD reports field for Upload or Download,
    ...                gathers appropriate PCMD reports for provided UE via
    ...                the UE alias, and compares collected values with
    ...                appropriate PM counters.
    [Arguments]
    ...    ${burst_field}
    ...    ${time_field}
    ...    ${ue_alias}
    ...    ${PM_counters}
    ...    ${burst_pmcounter}
    ...    ${time_pmcounter}

    ${sum_time_data_burst}     Get Sum Of '${time_field}' Field Values From All PCMD Reports For ${ue_alias}
    ${sum_burst_bytes}         Get Sum Of '${burst_field}' Field Values From All PCMD Reports For ${ue_alias}
    ${time_data_list}          Get All '${time_field}' Field Values From All PCMD Reports For ${ue_alias}
    ${burst_bytes_list}        Get All '${burst_field}' Field Values From All PCMD Reports For ${ue_alias}
    Verify PM Counters And PCMD Data In PCMD Records
    ...    ue_id=${ue_alias}
    ...    PM_counters=${PM_counters}
    ...    data_burst=${sum_time_data_burst}
    ...    burst_bytes=${sum_burst_bytes}
    ...    data_list=${time_data_list}
    ...    burst_list=${burst_bytes_list}
    ...    burst_pmcounter=${burst_pmcounter}
    ...    time_pmcounter=${time_pmcounter}

Perform PCMD Record Verification For Download
    [Documentation]    This keyword takes burst_field and time_field
    ...                PCMD reports field for Upload or Download,
    ...                gathers appropriate PCMD reports for provided UE via
    ...                the UE alias, and compares collected values with
    ...                appropriate PM counters.
    [Arguments]
    ...    ${burst_field}
    ...    ${time_field}
    ...    ${ue_alias}
    ...    ${PM_counters}
    ...    ${burst_pmcounter}
    ...    ${time_pmcounter}
    ...    ${ran_ue_id}

    ${pcmd_reports}            Get All PCMD Reports
    ${sum_time_data_burst}     Get Sum Of Field Values From All PCMD Reports For UE Download
    ...    report_field_name=${time_field}
    ...    pcmd_reports=${pcmd_reports}
    ...    ran_ue_id=${ran_ue_id}
    ${sum_burst_bytes}         Get Sum Of Field Values From All PCMD Reports For UE Download
    ...    report_field_name=${burst_field}
    ...    pcmd_reports=${pcmd_reports}
    ...    ran_ue_id=${ran_ue_id}
    ${time_data_list}          Get All Field Values From All PCMD Reports For UE Download
    ...    report_field_name=${time_field}
    ...    pcmd_reports=${pcmd_reports}
    ...    ran_ue_id=${ran_ue_id}
    ${burst_bytes_list}        Get All Field Values From All PCMD Reports For UE Download
    ...    report_field_name=${burst_field}
    ...    pcmd_reports=${pcmd_reports}
    ...    ran_ue_id=${ran_ue_id}
    Verify PM Counters And PCMD Data In PCMD Records
    ...    ue_id=${ue_alias}
    ...    PM_counters=${PM_counters}
    ...    data_burst=${sum_time_data_burst}
    ...    burst_bytes=${sum_burst_bytes}
    ...    data_list=${time_data_list}
    ...    burst_list=${burst_bytes_list}
    ...    burst_pmcounter=${burst_pmcounter}
    ...    time_pmcounter=${time_pmcounter}


Verify PM Counters And PCMD Data In PCMD Records
    [Documentation]    Keyword gathers values from specified PM Counters
    ...                and compares them with values from PCMD reports.
    [Arguments]
    ...    ${ue_id}
    ...    ${PM_counters}
    ...    ${data_burst}
    ...    ${burst_bytes}
    ...    ${data_list}
    ...    ${burst_list}
    ...    ${burst_pmcounter}
    ...    ${time_pmcounter}

    ${VOL_UE_TPUT_TOT}    Get PM Counter Value    ${burst_pmcounter}    ${PM_MOID_NRCELL-${ue_id}}    ${PM_counters}
    ${VOL_UE_TPUT_TOT}    Calculate Counter For Expected Value    ${VOL_UE_TPUT_TOT}    value=1000
    ${TIME_UE_TPUT}       Get PM Counter Value    ${time_pmcounter}    ${PM_MOID_NRCELL-${ue_id}}    ${PM_counters}
    ${burst_bytes}    Calculate Counter For Expected Value    ${burst_bytes}    value=8
    Time Of Data Burst Should Be Equal To Counter Value    ${data_burst}    ${TIME_UE_TPUT}[0]
    Compare Values With Margin    value=${burst_bytes}    expected_value=${VOL_UE_TPUT_TOT}    margin=1
    Verify Throughput From Records    ${burst_list}    ${data_list}    margin=10



Verify Both Traffic For UE
    [Arguments]    ${the_ue_id}
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=${the_ue_id}    throughput=10
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=${the_ue_id}    throughput=10
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15

Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Register and Start Traffic for UE
    [Arguments]    ${the_ue_id}
    Attach UE    ue_id=${the_ue_id}
    Establish Pdu Session With Traffic    ue_id=${the_ue_id}    pdu_id=${the_ue_id}    nwslice=1    gw_id=1    direction=both    throughput=10mbps

Wait For Throughput
    Sleep    5s

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${False}
    Start Collecting PCMD Reports

Teardown PCMD
    Stop Collecting PCMD Reports
    Deconfigure PCMD
