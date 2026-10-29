*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot
Library           ute_reporting_portal

*** Keywords ***
Multi SA UE Attach
    [Arguments]    ${start_ue_num}    ${end_ue_num}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    SA UE Attach    sa_ue_id=${UE_ID}
    END

SA UE Attach
    [Arguments]    ${sa_ue_id}
    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
    ...    ue_register
    ...    set_pdu_param
    ...    ue_pdu_session_setup
    SA 5G Attach    ue_id=${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${sa_ue_id}

Multi PDUs Establishment
    [Arguments]    ${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=2
    SA 5G Attach    ue_id=${sa_ue_id}
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=${sa_ue_id} nwslice=1 gw=1
    Wait AP Command Executed
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=${sa_ue_id} nwslice=1 gw=1
    Wait AP Command Executed
    Start SA UE Internal Trf DLUL    ${sa_ue_id}    ${DL_PEAK}    ${UL_PEAK}    pdu_id=2

Start SA UE Internal Trf DLUL
    [Arguments]    ${ue_id}    ${mbps_dl}    ${mbps_ul}    ${pdu_id}=1
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps_dl}    trf_id=1
    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps_ul}    trf_id=1



Multi UE Attach And Do UL DL Traffic
    [Arguments]    ${start_ue_num}    ${end_ue_num}    ${ul_mbps}=10    ${dl_mbps}=10
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    SA UE Attach    sa_ue_id=${UE_ID}
    Sleep    3s    Reason=wait for PDU session completed
    END
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    SA Start UL Traffic Internal    ${UE_ID}    pdu_id=1    mbps=${ul_mbps}
    SA Start DL Traffic Internal    ${UE_ID}    pdu_id=1    mbps=${dl_mbps}
    Sleep    3s    Reason=wait for traffic send out
    END

Start ULDL Small Traffic And Check The Tput
    [Arguments]    ${ue}    ${dl_tp_set}    ${ul_tp_set}    ${dl_aver_tput}    ${ul_aver_tput}
    SA Start UL Traffic Internal    ue_id=${ue}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${ue}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    Sleep    5s    reason=wait ULDL traffic is stable
    Check UE Tput With Bearer    ${ue}      ul    ${ul_aver_tput}
    Check UE Tput With Bearer    ${ue}      dl    ${dl_aver_tput}

Check UE Tput With Bearer
    [Arguments]     ${UE_ID}    ${traffic_type}    ${target_tp}
    ${aver_tp}    SA Get UE Average Traffic Internal    ${UE_ID}    1    ${traffic_type}
    ${gap_tp}    evaluate    float(${aver_tp})-float(${target_tp})
    Should Be True    float(${gap_tp})>0

Trigger Scell Addition With CoverbaseA1 Rsrp Rsrq
    [Arguments]    ${ue_id}    ${mea_id}=1    ${rsrp}=105    ${rsrq}=105    ${pcell_id}=50
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=A1 srsrp_nr\=${rsrp} srsrq_nr\=${rsrq} phycell_id\=${pcell_id}
    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes

Check Scell Addition Successful
    [Arguments]    ${ueId}    ${scell_physicalid}
    Check SA Scell PhysicalID With UE ID    ${ueId}    ${scell_physicalid}    1

Check Scell Addition UL And DL
    [Arguments]    ${ueId}    ${scell_physicalid}
    Check SA Scell PhysicalID With UE ID    ${ueId}    ${scell_physicalid}    1

Trigger Scell Addition With CoverbaseA1 But Failed
    [Arguments]    ${ue_id}    ${mea_id}=1    ${rsrp}=105    ${rsrq}=105    ${pcell_id}=50
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=A1 srsrp_nr\=${rsrp} srsrq_nr\=${rsrq} phycell_id\=${pcell_id}
    ${output}    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
    ...    pass_regexp=rrcReconfigurationComplete    timeout=20s
    Should Contain    ${output}    FAIL
    Save Egate Log

Online Change Para And Check SBTS Status
    [Arguments]    ${SCF_JSON}
    Delta Commission With SCF File     ${SCF_JSON}
    Reboot TL And Check Configured
    Verify Coam Site Is Ready
    Verify All Cells Are OnAir

Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value
    [Arguments]    ${ue_id}    ${rsrq}    ${rsrp}    ${scell}   ${mea_id}=1
    ${cmd_rsrp}    Set Variable
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${mea_id} event\=A1 srsrp_nr\=${rsrp} srsrq_nr\=${rsrq}
    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd_rsrp}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes
    Check Scell Addition UL And DL    ${ue_id}    ${scell}

Capture And Covert BIP To Csv
    [Arguments]    ${FILTER}    ${COLUMN_NAME}
    Sleep    1s    reason=Wait For Transmission Stable
    Start Gnb BIP Log
    Sleep    3s    reason=Capture BIP log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.csv    filter=${FILTER}
    ...        csv_title_list=${COLUMN_NAME}

Set Config Path
    Log To Console    ${SW_BRANCH}
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/config/${SW_BRANCH}
    Log To Console    ${JSON_PATH}

Start SA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${dl_times+1}

Check UL Tput On Target Pcell Plus Scell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    UL Troughput is ${sum_tp}    console=True
    Should Be True    ${sum_tp}>=${target_sum_tp}

Check DL Tput On Target Pcell Plus Scell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    UL Troughput is ${sum_tp}    console=True
    Should Be True    ${sum_tp}>=${target_sum_tp}

Start ULDL Traffic And Check The Tput
    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}    ${dl_peak_tput}    ${ul_peak_tput}
    Start SA DL Big Traffic Internal    ${ue}    ${dl_trf}
    Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
    Sleep    5s    reason=wait UL traffic is stable
    Check DL Tput On Target Pcell Plus Scell    ${ue}    0    1    ${dl_peak_tput}
    Sleep    5s    reason=wait UL traffic is stable
    Check UL Tput On Target Pcell Plus Scell    ${ue}    0    1    ${ul_peak_tput}

Check PCell And SCell DLUL Tput
    [Arguments]    ${ue}    ${dl_peak_tput}    ${ul_peak_tput}
    Sleep    5s    reason=wait UL traffic is stable
    Check DL Tput On Target Pcell Plus Scell    ${ue}    0    1    ${dl_peak_tput}
    Sleep    5s    reason=wait UL traffic is stable
    Check UL Tput On Target Pcell Plus Scell    ${ue}    0    1    ${ul_peak_tput}

Start SA UL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big ul udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${ul_times+1}

Check Tput On Target Scell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_scell_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    UL Troughput is ${sum_tp}    console=True
    Should Be True    ${scell_TP}>=${target_scell_tp}

Check Ul Tput On Target Pcell
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_pcell_tp}
    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
    Log To Console    UL Troughput is ${sum_tp}    console=True
    Should Be True    ${pcell_TP}>=${target_pcell_tp}
    Should Be True    ${scell_TP}>=0

Check Multiple NonCA UEs Throughput
    [Arguments]    ${start_ue_num}    ${end_ue_num}     ${traffic_type}     ${target_tp}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Check UE Tput With Bearer    ${UE_ID}     ${traffic_type}     ${target_tp}
    END

Check Multiple CA UEs UL Throughput
    [Arguments]    ${start_ue_num}    ${end_ue_num}     ${pcell_index}    ${scell_index}    ${target_sum_tp}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Check UL Tput On Target Pcell Plus Scell    ${UE_ID}     ${pcell_index}    ${scell_index}    ${target_sum_tp}
    END

Check Multiple CA UEs Scell Throughput
    [Arguments]    ${start_ue_num}    ${end_ue_num}     ${pcell_index}    ${scell_index}    ${target_scell_tp}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Check Tput On Target Scell    ${UE_ID}     ${pcell_index}    ${scell_index}    ${target_scell_tp}
    END

Check Multiple CA UEs Ul Pcell Throughput
    [Arguments]    ${start_ue_num}    ${end_ue_num}     ${pcell_index}    ${scell_index}    ${target_pcell_tp}
    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
    Check Ul Tput On Target Pcell    ${UE_ID}     ${pcell_index}    ${scell_index}    ${target_pcell_tp}
    END

Set Reordering Timer
    [Arguments]    ${reordering_window_size}    ${reordering_timer}
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=1
    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}

Verify Ue Detached
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_path}
    Should Contain    ${content}    Received NG Reset from GNB-2

Check Report PM Counter
    [Arguments]    ${reordering_window_size}
    Wait Until Keyword Succeeds    20min    1min    Verify CB006137 SchedUE PM Counters
    ute_reporting_portal.Report Pm Counter    M55308C18002    1    Passed

Get And Verify PM Counters
    [Documentation]    This keyword is used to check if PM counter
    ...            Counter_Path_Name   show
    ...            [51001-01] CELLS/NRCELL-1/RACCU/SUM_SA_UE_FULL_PWR_FR1 or
    ...            [51001-01] CELLS/NRCELL-1/NCELA/ACC_SCHED_UE_PUSCH
    [Arguments]     ${COUNTERCellID}    ${COUNTER_PATH_NAME}    ${PM_COUNTERS_AND_EXPEC_VALUES}
    ${PM_Counter_Value_list}    Create List
    FOR    ${CouterName}    ${CounterValue_Expec}    IN    @{PM_COUNTERS_AND_EXPEC_VALUES}
        ${PM_Counter_Value}    Get Latest PM Counter Value With Admin For Cell       ${COUNTERCellID}    ${COUNTER_PATH_NAME}    ${CouterName}
        Should Be True    ${PM_Counter_Value} > ${CounterValue_Expec}
    Log Many       ${CouterName}    ${PM_Counter_Value}
        ute_reporting_portal.Report Pm Counter         ${CouterName}    ${PM_Counter_Value}    Passed
    END

Get Latest PM Counter Value With Admin For Cell
    [Arguments]    ${COUNTERCellID}    ${COUNTER_PATH_NAME}        ${PMCouterName}
    Run Keyword And Ignore Error    COAM.Teardown
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${counter}=     COAM.Get Pm Counters     ${PMCouterName}
    ${counter_str}=     BuiltIn.Convert To String      ${counter}
    ${cell_counter_list}=     String.Get Regexp Matches     ${counter_str}
    ...        (?<=NRCELL-${COUNTERCellID}':\\s{'${COUNTER_PATH_NAME}':\\s{)[\\w:,\\s'{]+}
    ${cell_counter_list}=     String.Get Regexp Matches     ${cell_counter_list}[0]
    ...   (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}=     BuiltIn.Evaluate    max(${cell_counter_list})
    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Modify Vendor File And Do Full Commission Workaround
    [Arguments]    ${vendor_file}    ${scf_file}=${EMPTY}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | No | SCF file name.It usual exist in ${scf_path}/${sw_branch}/SCF/${scf_file}. |
    ...    |    |    | ${sw_branch} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...    | ${vendor_file} | Yes | vendor file provided |
    Log To Console    Perform full commissioning please use the scf with full configuration saved.
    ${bts_id}    Get BTS Id
    COAM.Setup Admin
   ${new_scf_path}    Run Keyword If    '${scf_file}'!='${EMPTY}'
    ...    _Set SCF Full File and Migration    ${scf_file}
    ${full_scf_file}    Set Variable If    '${scf_file}'=='${EMPTY}'    ${output_dir}/full_SCF.xml    ${new_scf_path}
    Run Keyword If    '${full_scf_file}'=='${output_dir}/full_SCF.xml'    COAM.get_current_scf_file
    ...    local_dir_path=${OUTPUT_DIR}    file_name=full_SCF.xml
    ...    export_type=configurationAndRuntimeObjects    timeout=120s
    COAM.Set Vendor File    ${vendor_file}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${full_scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    # Run Keyword And Ignore Error    Verify Coam Site Is Ready
    Sleep    300s
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown



