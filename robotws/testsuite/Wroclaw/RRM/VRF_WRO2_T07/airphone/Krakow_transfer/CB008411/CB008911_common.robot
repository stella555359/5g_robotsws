*** Settings ***
Documentation
...            author:     Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...                        Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                        Bartosz Szlezak, bartosz.szlezak@nokia.com
...                        Kamil Deregowki, kamil.deregowski@nokia.com
...                        Wojciech Gicala, wojciech.gicala@nokia.com
...                        Michal Sagan, michal.sagan@nokia.com
...
...            maintainer:     Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                            Bartosz Szlezak, bartosz.szlezak@nokia.com
...                            Kamil Deregowki, kamil.deregowski@nokia.com
...                            Wojciech Gicala, wojciech.gicala@nokia.com
...                            Michal Sagan, michal.sagan@nokia.com

Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot

*** Keywords ***
Verify Traffic On All SCells
    [Arguments]    ${ue_id}
    ${ret}  Execute Egate Command Ext    cmd=ue_stats_nr    id=${ue_id}    scell=0-6    type=pdsch
    Log    ${ret}

Start ${n_trf} Traffic Streams for UE-${ue_id} during ${traffic_time} Seconds
    FOR   ${trf_id}      IN RANGE    1    ${n_trf}+1
          Start Internal NSA Downlink Traffic    ue_id=${ue_id}    tput=25mbps    trf_id=${trf_id}
    END
    Start Internal NSA Uplink Traffic    ue_id=${ue_id}    tput=30mbps
    Sleep     ${traffic_time}s

Trigger SgNB Modification by Performing Intra-eNB Inter-cell HO
    [Arguments]      ${ue_id}      ${t_enb_cell}
    Execute Egate Command Ext   cmd=ue_ho id=${ue_id} enb=1 cell=${t_enb_cell} ho_mode=INTRA_LTE
    ...      pass_regexp=Intra-eNB handover from ENB.* to ENB.* performed    timeout=30s
    Sleep    5s     reason=Wait for reestablishment to be fully completed

Enable EN_DC on eNB-1 Cell-2
    Execute Egate Command Ext     cmd=enb_cell_param enb=1 id=2 allow_endc=on
    Sleep    5s      reason=Wait for reestablishment to be fully completed

Perform A1-Based Scell Addition
    [Arguments]    ${ue_id}    ${should_contain}=@{Empty}
    ...    ${pass_regexp}=rrcReconfigurationComplete    &{params}
    ${meas_id}    Get Next Meas ID From Egate    ue_id=${ue_id}    event=A1
    ${log_msg}    Set Variable    Performing A1-Based scell addition with UE-${ue_id}
    Execute Egate Command Ext    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}
    ...    srsrp_nr=100    event=A1    pass_regexp=${pass_regexp}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}

Activate TA Test Mode for UE
    [Arguments]     ${ue_id}     ${scell_idx}=secondary
    ${cmd}      Set Variable
    ...    ue_ta_nr profile_id=1 nb_reps_ta_sim=100 ue_speed=4 ue_p_delay_max=500 ue_p_delay_min=100 ue_p_delay_initial=350
    ${cmd_tm}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=${scell_idx} testmode=ta profile_id=1 action=activate
    Execute Egate Command Ext     cmd=${cmd}
    Execute Egate Command Ext     cmd=${cmd_tm}

Perform A2-Based Scell Release
    [Arguments]    ${ue_id}    ${scell_id}    ${target_ssb}=${Empty}    ${should_contain}=@{Empty}
    ...    ${pass_regexp}=${Empty}
    ${meas_id}    Get Next Meas ID From Egate    ue_id=${ue_id}    event=A2    target_ssb=${target_ssb}
    ${log_msg}    Set Variable    Performing A2-Based scell release with UE-${ue_id}
    Execute Egate Command Ext    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}
    ...    srsrp_nr=100    event=A2    scell=${scell_id}    scell_rsrp=0
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain}    log_msg=${log_msg}

Get all periodicTa Value from GNB Syslog and convert to Ts Units
    [Arguments]    ${syslog}
    ${periodicTa}        Create List
    FOR    ${syslog_in_path}    IN    @{syslog}
        ${rc}    ${output}    Run And Return Rc And Output
        ...   grep -o 'convertedPeriodicTaValue: [0-9]*' '${syslog_in_path}' | cut -b 27-32
        Append To List     ${periodicTa}     ${output}
    END
    ${s}     Catenate    SEPARATOR=    @{periodicTa}
    @{periodic_values}    Split String     ${s}    \n
    [Return]    @{periodic_values}

Perform Periodic Timing Advance Record verification
    [Arguments]        ${record_collection}     ${syslog}
    @{periodic_ta_values}      Get all periodicTa Value from GNB Syslog and convert to Ts Units
    ...           syslog=${syslog}
    ${periodic_timing_advance_record}      Create Dictionary
    ...    record_name=timingAdvanceRecord
    ...    taData=2
    ...    periodic=${empty}
    ...    tagId=0
    ${periodic_list}    Create List
    FOR    ${periodic_value}    IN    @{periodic_ta_values}
        ${temp_dict}=    Copy Dictionary    ${periodic_timing_advance_record}
        Set to dictionary    ${temp_dict}     periodic     ${periodic_value}
        Append To List       ${periodic_list}    ${temp_dict}
    END
    Verify PCMD Records Sequence in Collection    ${record_collection}    ${periodic_list}    strict_fields_check=yes

Send UE Assistance Information
    [Documentation]    Sends UE Assistance Information to GNB via ``ue_assistance_send_nr``.
    [Arguments]    ${ue_id}    ${pass_regexp}    ${fail_regexp}=${None}    ${timeout}=30s
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_assistance_send_nr ue_id=${ue_id}
    ${log_msg}    Set Variable    Sending Assistance Information from UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Set and Attach Beamcontrol Test Mode
    [Arguments]       ${ue_id}
    Log to Console    Setting Beamcontrol Test Mode
    ${beam_control_prf_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${beam_control_prf_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${test_mode_attach}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute Egate Command Ext    cmd=${beam_control_prf_1}
    Execute Egate Command Ext    cmd=${beam_control_prf_2}
    Execute Egate Command Ext    cmd=${test_mode_attach}
    Sleep      5s    Wait for command to execute

Trigger Beam Change On The TDD FR1 SCells Based On SSB Beam Measurements Received From UE For NR-UE${UE_ID}
    Execute Egate Command Ext
    ...  cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-140
    Execute Egate Command Ext
    ...   cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=2
    Execute Egate Command Ext
    ...   cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=0
    Execute Egate Command Ext
    ...   cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=3

Verify Nsetapx Message Count in PCAP
    [Arguments]    ${pcap_filepath}    ${filter}    ${count}
    ${options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148    -J    nsetapx
    ${msg_count}    Verify Message Count in PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    filter=${filter}
    ...    count=${count}
    ...    options=${options}
    [Return]    ${msg_count}

Get Frame Number of Beam Change Record
    [Arguments]    ${pcap_filepath}    ${nrci}
    ${options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148    -J    nsetapx
    ${seq_num}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    field_name=frame.number
    ...    filter=nsetapx.caSCellBeamUsageRecord && nsetapx.nrci == ${nrci} && nsetapx.numOfTotalBeamChanges == 1
    ...    options=${options}
    [Return]    ${seq_num}[0]

Create PCMD Record Sequence for DL and UL CA SCELL Scheduling Records
    [Arguments]    ${nrci}    ${count_dl}     ${count_ul}
    ${dlCaSCellSchedulingRecord}    Create Dictionary
    ...    record_name=dlCaSCellSchedulingRecord
    ...    endMarker=0
    ...    cellId=0
    ...    cellId.*nrci=${nrci}
    ...    recordCollectionDuration=\\d+
    ...    timeOfUeSched=\\d+
    ...    numOf1stMacPduTx=\\d+
    ...    numOfBad1stMacPduTx=\\d+
    ...    numOfBadLastMacPduTx=\\d+
    ...    numOfPdschTxWithRank1=\\d+
    ...    numOfPdschTxWithRank2=\\d+
    ...    numOfPdschTxWithRank3=\\d+
    ...    numOfPdschTxWithRank4=\\d+
    ...    avgTb0WbCqi.*sumOfWbCqi=\\d+
    ...    avgTb0WbCqi.*numOfWbCqiSamples=\\d+
    ${ulCaSCellSchedulingRecord}    Create Dictionary
    ...    record_name=ulCaSCellSchedulingRecord
    ...    endMarker=0
    ...    cellId=0
    ...    cellId.*nrci=${nrci}
    ...    recordCollectionDuration=\\d+
    ...    timeOfUeSched=\\d+
    ...    numOf1stMacPduTx=\\d+
    ...    numOfBad1stMacPduTx=\\d+
    ...    numOfBadLastMacPduTx=\\d+
    ...    numOfPuschTxWithRank1=\\d+
    ...    numOfPuschTxWithRank2=\\d+
    ${dlCaSCellSchedulingRecord_end}    Create Dictionary    &{dlCaSCellSchedulingRecord}    endMarker=1
    ${ulCaSCellSchedulingRecord_end}    Create Dictionary    &{ulCaSCellSchedulingRecord}    endMarker=1
    ${PCMD_Seq_dl}    Evaluate    [${dlCaSCellSchedulingRecord}] * (${count_dl} - 1) + [${dlCaSCellSchedulingRecord_end}]
    ${PCMD_Seq_ul}    Evaluate    [${ulCaSCellSchedulingRecord}] * (${count_ul} - 1) + [${ulCaSCellSchedulingRecord_end}]
    [Return]    ${PCMD_Seq_dl}     ${PCMD_Seq_ul}

Get sum of rlc bytes from PCAP
    [Documentation]    Get sum of specific field presented within PCMD records
    [Arguments]    ${field_name}    ${record_name}    ${dcap_file_path}    ${nrci}=None    ${is_pcell}=no
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    nsetapx.TraceMessage    -E    separator\=';'
    ${filter}    Run Keyword If    '${nrci}' != 'None'
    ...    Set Variable    nsetapx.${record_name} && nsetapx.nrci == ${nrci}
    ...    ELSE    Set Variable    nsetapx.${record_name}
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${dcap_file_path}    options=${options}
    ...    field_name=${field_name}    filter=${filter}
    ${sum_of_rlc_bytes}    Set Variable    0
    FOR    ${string}    IN    @{fields}
          ${msg_type}    ${values}    Split String    ${string}    ;
          ${val_list}    Split String    ${values}    ,
          ${val_list}    Remove Duplicates	   ${val_list}
          ${length}    Get Length    ${val_list}
          ${value}    Run Keyword If    ${length}==2 and '${is_pcell}'=='yes'
          ...    Set Variable    ${val_list}[1]
          ...    ELSE    Set Variable    ${val_list}[0]
          ${sum_of_rlc_bytes}    Evaluate    ${sum_of_rlc_bytes} + ${value}
    END
    [Return]    ${sum_of_rlc_bytes}

Compare PM counter and record values
    [Arguments]    ${counter_value}    ${record_value}    ${max_difference}=1
    ${difference}    Run Keyword If    ${counter_value} == 0 and ${record_value} == 0
    ...    Set Variable    0
    ...    ELSE    Evaluate    abs((1 - (${counter_value}/${record_value}))*100.0)
    ${msg}    Evaluate    "Difference between PM counter and value from records: %.2f" % ${difference} + "%"
    ${msg_fail}    Set Variable    Verification condition is not meet - values differ
    Log to console    ${msg}
    Should Be True    ${difference} <= ${max_difference}    msg=${msg_fail}
