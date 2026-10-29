*** Settings ***

Documentation   Common_CA keywords


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

Trigger A1 Scell Addition
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50
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
    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measidregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
    ${measida1}=    Set Variable    @{measid_list}[0]
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id}
    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete

Trigger A2 Scell Release
    [Arguments]    ${ue_id}    ${scell_id}=1    ${scell_rsrp}=36    ${phycell_id}=51
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
    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[-1]
    ${measidregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
    ${measida2}=    Set Variable    @{measid_list}[-1]
    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${measida2} event=A2
    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} phycell_id=${phycell_id}
    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete

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
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} The tput is on target: ${target_tp}Mb

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
    Log To Console    \nUE${ue_id} UL scell tput is on target: ${target_tp}Mb



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
    ${tput}    Evaluate    round(float(${tput_list_int})/${tput_num}*8/1024/1024,3)
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
    ${tput}    Evaluate    round(float(${tput_list_int})/${tput_num}*8/1024/1024,3)
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
