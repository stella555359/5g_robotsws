*** Keywords ***
SA 5G CA Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is to 5G UE attach for SA CA.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | YES | id of ue |
    ...    | pdu_id | No | id of pdu ，the default value is 1 |
    ...    This keyword return the output of the egate command to use for other checking.
    ...
    ...    | Examples: |
    ...    | ${output} | SA CA 5G Attach | 1 | 1 |
    ...
    Log To Console    UE${ue_id} Start Attach...
    Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
    [Return]    ${output}

Set UEC Reordering Timer
    [Arguments]    ${uec_id}=1
    [Documentation]    This keyword is to set reordering timer which will impact the throughput before UE attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | uec_id | No | id of UEC, the default value is 1 |
    ...
    ...    Examples:
    ...    | Set Reordering Timer | 1 |  |
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=${uec_id}
    ...    reordering_window_size\=${REORDERING_WINDOW_SIZE} reordering_timer\=${REORDERING_TIMER}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}

Check DRX On
    [Arguments]    ${attach_output}
    [Documentation]    This keyword is to check DRX enable in egate output of UE attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${attach_output} | Yes | output from keyword 'SA CA 5G Attach' |
    ...
    ...    Examples:
    ...    | ${attach_output} | SA CA 5G Attach | ue_id=1 |
    ...    | Check DRX On | ${attach_output} |
    ...
    ${output}    String.Get Lines Matching Regexp    ${attach_output}    drx-Config setup    partial_match=${true}
    Log To Console    ${output}

Get And Check Scell Infos
    [Arguments]    ${scells_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to get and check Scell Info from egate Log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scells_info} | Yes |expected scell info with the format ('sCellIndex', 'physCellId', 'frequencyBandList') |
    ...    | ${egate_file | No | the egate Log path|
    ...    The keyword return a tuple list, then check whether it include above expected infos defined in ${scells_info}
    ...    Examples:
    ...    | Get And Check Scell Infos | ('1', '51', '2'), ('2', '52', '66')|
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\s+{\\s+(?P<frequencyBandList>\\d+)\\s+},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    ${ret_str}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
    Log    ${ret}
    Should Contain    ${ret}    ${scells_info}

Verify Scells Are Activation
    [Arguments]    ${cell_nums}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to check whether scell actived from egate Log.
    Log To Console    verify Scell Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    # ${check_rst}    Run    cat ${egate_file}|grep -i "${scell_activation}"|wc -l
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    Should Be True    ${check_rst}>=1
    END

_Get Measurement Id From Egate Log
    [Arguments]    ${event_tag}    ${ue_id}=1
    Sleep    2s
    ute_wtssim.Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}
    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d+)[\\s\\S]{1,150}eventId event${event_tag}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[-1]
    ${measidregex}=    Set Variable    measId (?P<measId>\\d+)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
    [Return]    @{measid_list}[-1]

Trigger A1 Scell Addition
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Trigger A1 Scell Addition | 1 | 70 | 50 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${ret}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id}
    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete
    [Return]    ${ret}

Send A1 report
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Send A1 report | 1 | 70 | 50 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${ret}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id}
    ...    pass_regexp=EGATE    timeout=1min
    [Return]    ${ret}

Trigger A6 Scell Swape
    [Arguments]    ${ue_id}=3    ${meas_id}=2    ${scell_id}=3    ${phycell_id}=56
    [Documentation]    This keyword is to trigger A6 scell swape
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | yes | the id of ue |
    ...    | meas_id | yes | the id of meas |
    ...    | scell_id | yes | the id of scell |
    ...    | phycell_id | yes | phycell id for scell |
    ...
    ...    Examples:
    ...    | Trigger A6 Scell Swape | 3 | 2 | 3 | 56 |
    ...
    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A6 srsrp_nr=11 srsrq_nr=11
    ...    scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete
    [Return]    ${ret1}
    
Trigger A2 Scell Release
    [Arguments]    ${ue_id}    ${scell_id}=1    ${scell_rsrp}=36    ${phycell_id}=51    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A2 scell release
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | yes | the id of ue |
    ...    | scell_id | yes | the id of scell |
    ...    | scell_rsrp | yes | the value of scell_rsrp |
    ...    | phycell_id | yes | phycell id for scell |
    ...
    ...    Examples:
    ...    | Trigger A2 Scell Release | 1 | 1 | 1 | 51 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A2    ${ue_id}
    ${measida2}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${measida2} event=A2
    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} phycell_id=${phycell_id}
    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete
    [Return]    ${ret1}

Trigger A2 Event For Handover
    [Arguments]    ${ue_id}    ${srsrp_nr}=11    ${srsrq_nr}=11    ${meas_id}=${EMPTY}
    Log To Console    Trigger A2 Event For Inter Freq Handover
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A2    ${ue_id}
    ${measida2}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${pattern}    Set Variable    rrcReconfigurationComplete
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida2} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
    Should Match Regexp    ${output}    measGapConfig[\\s\\S]+gapUE setup
    Sleep    20s    reason=wait for traffic stable

Trigger A3 Event For Handover
    [Arguments]    ${ue_id}    ${phycell_id}    ${nbr_cell_id}    ${srsr_nr}=11    ${nrsr_nr}=80    ${meas_id}=${EMPTY}
    Log To Console    Trigger A3 Event For Inter Freq Handover
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A3    ${ue_id}
    ${measida3}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.* to EXT_ENB-2.${nbr_cell_id} performed
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida3} event=A3 srsrp_nr=${srsr_nr} srsrq_nr=${srsr_nr}
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsr_nr} nrsrq_nr=${nrsr_nr}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
    Sleep    20s    reason=wait for traffic stable

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Check CA UE Pcell Scell Cell TPut On Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} ${cell_type}${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb

Get ULCA SCell L1 Average Throughput
    [Arguments]    ${ue_id}    ${dl_cc_num}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dl_cc_num} | Yes | 2/3/4...|
    ...
    ...    | Examples: |
    ...    | ${ul_scell_tput} | Get ULCA SCell L1 Average Throughput | 1 | 4 |
    ...
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pusch scell\=1-${dl_cc_num}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Check ULCA Scell L1 Cell Tput On Target
    [Arguments]    ${ue_id}    ${dl_cc_num}    ${target_tp}
    ${tput}    Get ULCA SCell L1 Average Throughput    ${ue_id}    ${dl_cc_num}
    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} UL scell tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} UL scell tput ${tput} is on target: ${target_tp}Mb

Get PhysCellId From Egate Log
    [Arguments]    ${scellindex}    ${egate_Log}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Get physCellId from Egate Log | 1 | ${egate_Log} |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Set Variable    sCellIndex\\s${scellindex}\[\\s\\S\]*?physCellId\\s*(?P<physCellId>\\d*)
    ${physcellid_list}    String.Get Regexp Matches    ${content}    ${patt}    physCellId
    [Return]    ${physcellid_list}

Get PhysCellId With UE Id From Egate Log
    [Arguments]    ${ue_id}    ${scellindex}    ${egate_Log}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id, such as 1,2,3... |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Get physCellId with UE Id From Egate Log | 88 | 1 | ${egate_Log} |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Catenate    SEPARATOR=    UE${ue_id}\\[NR-RRC\\]: <- (DL-DCCH-NR)?[\\s\\S]*?
    ...    sCellIndex\\s${scellindex}\[\\s\\S\]*?physCellId\\s+(?P<physCellId>\\d+)[\\s\\S]*?
    ${physcellid}    String.Get Regexp Matches    ${content}    ${patt}    physCellId
    Log To Console    Get PhysCellId is ${physcellid[-1]} for UE${ue_id}
    [Return]    ${physcellid[-1]}

Get nrCellIdentity From SCF
    [Arguments]    ${scf_file}    ${cell_id}
    ${nrCellIdentity}=    Get Single Value From Scf File    ${scf_file}
    ...    ${NRBTS_DISTNAME}/NRCELL-${cell_id}    nrCellIdentity
    [Return]    ${nrCellIdentity}

Get Scell DL Latest Tput From Syslog
    [Arguments]    ${syslog}    ${nrCellIdentity}
    [Documentation]    This keyword is to calculate scell tput from syslog,
    ...    the return value is * Mbps
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${syslog} | YES | the syslog path |
    ...    | ${nrCellIdentity} | YES | the nrCellIdentity  |
    ...
    ...    Examples:
    ...    | ${scf_file} | Get Current Full SCF From Admin |
    ...    | ${nrCellIdentity} | Get nrCellIdentity From SCF | scf_file=${scf_file} | cell_id=1 |
    ...    | Get Scell DL Latest Tput From Syslog | ${CURDIR}/SYSLOG_12.LOG | ${nrCellIdentity} |
    ...
    ${content}    OperatingSystem.Get File    path=${syslog}    encoding_errors=ignore
    ${match_reg}    Catenate    SEPARATOR=    SentDataMeasurementCounting[.\\w\\/:\\d\\s]*
    ...    nrCellId\\s${nrCellIdentity}\\s\\[TBS\\|MacCe\\|StatusPdu\\|DataPdu:\\s(?P<TBS>\\d+)
    ${tput_list}    String.Get Regexp Matches    ${content}    ${match_reg}    TBS
    ${tput_num}    Get Length    ${tput_list}
    ${tput_list_int}    Evaluate    sum(list(map(int,${tput_list})))
    ${tput_all}    Evaluate    round(float(${tput_list_int})/${tput_num}*8/1024/1024,3)
    ${tput_20}    Run Keyword If    ${tput_num}>=20    Evaluate    round(float(sum(list(map(int,${tput_list[-20:]}))))/20*8/1024/1024,3)
    ${tput}     Set Variable If    ${tput_num}>=20    ${tput_20}    ${tput_all}
    [Return]    ${tput}

Get Scell UL Latest Tput From Syslog
    [Arguments]    ${syslog}    ${nrCellIdentity}
    [Documentation]    This keyword is to calculate scell tput from syslog
    ...    the return value is * Mbps
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${syslog} | YES | the syslog path |
    ...    | ${nrCellIdentity} | YES | the nrCellIdentity  |
    ...
    ...    Examples:
    ...    | ${scf_file} | Get Current Full SCF From Admin |
    ...    | ${nrCellIdentity} | Get nrCellIdentity From SCF | scf_file=${scf_file} | cell_id=1 |
    ...    | Get Scell UL Latest Tput From Syslog | ${CURDIR}/SYSLOG_12.LOG | ${nrCellIdentity} |
    ...
    ${content}    OperatingSystem.Get File    path=${syslog}    encoding_errors=ignore
    ${match_reg}    Catenate    SEPARATOR=    \\/L2Lo,\\sUlCounterUpdate\\.cpp:\\d+\\/UL:\\s(?P<bytes>\\d+)\\sBytes\\sreceived
    ...    [\\(\\w\\s,\\).]*?nrCellIdentity\\s${nrCellIdentity}
    ${tput_list}    String.Get Regexp Matches    ${content}    ${match_reg}    bytes
    ${tput_num}    Get Length    ${tput_list}
    ${tput_list_int}    Evaluate    sum(list(map(int,${tput_list})))
    ${tput_all}    Evaluate    round(float(${tput_list_int})/${tput_num}*8/1024/1024,3)
    ${tput_20}    Run Keyword If    ${tput_num}>=20    Evaluate    round(float(sum(list(map(int,${tput_list[-20:]}))))/20*8/1024/1024,3)
    ${tput}     Set Variable If    ${tput_num}>=20    ${tput_20}    ${tput_all}
    [Return]    ${tput}

Get Scell Index of ULCA UE From Tput
    [Arguments]    ${ue_id}
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pusch scell\=1-31
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-(?P<cell_index>\\d{1,2})\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ${match_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    cell_index
    [Return]    ${match_list[0]}

Check sCellIndex of ULCA UE From Tput
    [Arguments]    ${ue_id}    ${exp_scell_index}
    ${scell_index}    Get Scell Index of ULCA UE From Tput    ${ue_id}
    Should be True    '${scell_index}'=='${exp_scell_index}'

Check CA Cell Sum Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${target_sum_tp}    ${dl_cc_num}
    [Documentation]    This keyword is to check Pcell Scell sum TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${target_sum_tp} | yes | the expected sum tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc for dl |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | ${target_sum_tp} |  | 200  |
    ...    | Check CA Cell Sum Average Throughput | ${ue_id} | dl | ${target_sum_tp} | 3 |
    ${sum_tput}     Set Variable     0
    FOR    ${id}    IN RANGE    ${dl_cc_num}
        ${tput}    Run Keyword If    ${id}==${0}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    pcell    0
        ...    ELSE    Get CA Cell Average Throughput    ${ueId}    ${dir}    scell    ${id}
        ${sum_tput}    Evaluate    ${sum_tput}+${tput}
    END
    Log To Console    ${dir} Troughput is ${sum_tput}    console=True
    Should Be True    ${sum_tput}>=${target_sum_tp}

Add Bler To Scell ULDL Channel
    [Arguments]    ${ue_id}    ${scell_id}    ${dl_bler}    ${ul_bler}
    ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=1 dl_bler=${dl_bler} ul_bler=${ul_bler}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=bler action=activate profile_id=1 scell=${scell_id}

Trigger 5QI Setup For Multi UE
    [Arguments]    ${ue_5qi_info_list}
    [Documentation]    This keyword is to trigger 5QI Setup For Multi UE
    ...
    ...    Examples:
    ...    | *** Variables *** |  |  |
    ...    | &{ue1_5qi_info} | ue_id=1 | qfi=2 | qosflows_id_5qi=5 |
    ...    | &{ue2_5qi_info} | ue_id=1 | qfi=3 | qosflows_id_5qi=1 |
    ...    | &{ue3_5qi_info} | ue_id=2 | qfi=4 | qosflows_id_5qi=2 |
    ...    | @{ue_5qi_info_list} | ${ue1_5qi_info} | ${ue2_5qi_info} | ${ue3_5qi_info} |
    ...    | *** Test Cases *** |
    ...    | Trigger 5QI Setup For Multi UE | ${ue_5qi_info_list} |
    ...
    FOR    ${ue_5qi_info}    IN    @{ue_5qi_info_list}
        ${pass}    Run Keyword And Return Status    Dictionary Should Contain Key    ${ue_5qi_info}    pdu_id
        ${pdu_id}    Set Variable If    ${pass}    ${ue_5qi_info.pdu_id}    1
        Log Many    ${ue_5qi_info.ue_id}    ${ue_5qi_info.qfi}    ${ue_5qi_info.qosflows_id_5qi}
        Trigger 5QI Setup    ${ue_5qi_info.ue_id}    ${ue_5qi_info.qfi}    ${ue_5qi_info.qosflows_id_5qi}    ${pdu_id}
    END

Trigger 5QI Setup
    [Arguments]    ${ue_id}    ${qfi}    ${qosflows_id_5qi}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | qfi | Yes | qfi |
    ...    | qosflows_id_5qi | Yes | qosflows_id_5qi |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 | 1 | 2 |
    Log To Console    start 5QI-${qosflows_id_5qi} Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qfi} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:${qfi} 5QI:${qosflows_id_5qi}    partial_match=${true}
    Log To Console    ${output}

Verfiy Scells Are All Deactivation
    [Arguments]    ${scell_list}=${dlonly_scell_index}
    Log To Console    \nverify Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN    @{scell_list}
    ${scell_deactivation}    Set Variable    SCellIndex ${id} deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}==1
    END

Check Scell ActiveDeactivate Times
    [Arguments]    ${scell_index_start}=1    ${scell_index_end}=5    ${scell_active_status}=activated    ${times}=1
    Log To Console    \nverify Scell Activation Info...
    Sleep    2s    reason=Wait for active status stable
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${scell_index_end}
    ${scell_activation}    Set Variable    SCellIndex ${id} ${scell_active_status} successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=${times}
    END
