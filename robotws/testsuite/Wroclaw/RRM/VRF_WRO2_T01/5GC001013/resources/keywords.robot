*** Settings ***
Documentation
...               Editor: Wiktor Jarosiński
...               Contact Person: Paweł Wiśniewski
...               Edit Reason: Robocop Clean
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library           testsuite.Wroclaw.RRM.resources.webui.WebuiInterface   WITH NAME   WebUI
Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Library           taf.transport.ssh       WITH NAME    ssh
Library           taf.config.scf          WITH NAME    scf
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_cplane.py
Library           pcap_cplane.pdml               WITH NAME    pdmlp
Library           taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library           taf.hw.rf_attenuator    WITH NAME    att
Library           taf.collectors.tcpdump    WITH NAME    tcpdump
Library           taf.collectors.core    WITH NAME    core
Library           taf.ue
Library           OperatingSystem
Library           Telnet
Library           String
Library           Collections
Resource          testsuite/Wroclaw/RRM/resources/connections.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/BBmod_cell_lock.robot
Variables         testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC001013/resources/PSCellChange_variables.py


*** Variables ***
@{MeasConfigMN_fields}     nr-rrc.measConfigMN_element    nr-rrc.setup_element    nr-rrc.gapOffset
...                        nr-rrc.mgl    nr-rrc.mgrp    nr-rrc.mgta    nr-rrc.gapPurpose
...                        nr-rrc.physCellId    nr-rrc.release_element


*** Keywords ***
Set cells for 1013
    Log to console       __Setting cells for 1013
    Block BBmod Cells      ABIO AirScale Capacity
    ${locked_cells}        Get cell ids         adminState=Locked
#    long pucch is now supported as well so shortPucch isn't required to be set
#    Set pucchModeSelect    ${unlocked_cells}    pucchModeSelect=shortPucch
    FOR    ${id}    IN    @{locked_cells}
        Set attenuation and check    lines=${lines_cell${id}_5G}    value=90
    END

Unlock all cells
    [Arguments]    ${alias}=coam
    ${locked_cells}     Get cell ids         adminState=Locked
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    Connect with runtime release  ${alias}
    FOR  ${cell_id}  IN  @{locked_cells}
      coam.Unlock  dist_name=${object_path}/NRCELL-${cell_id}  timeout=60  connection=${alias}
    END
    [Teardown]    coam.Teardown     connection=${alias}

Commissioning for X2
    Modify SCF file for X2    value=dlOverF1UX2U
    Perform commissioning with SCF file    scf_path=/tmp/scf_X2.xml

Modify SCF file for X2
    [Arguments]    ${value}=dlOverF1UX2U    ${target_scf_path}=/tmp/scf_X2.xml
    scf.Load Scf    file_path=${DEFAULT_SCF_PATH}/${DEFAULT_SCF_FILENAME}
    ${dlDataSplitMode}      scf.Get all values from scf    p_name=dlDataSplitMode
    ${no_modes}    Get length    ${dlDataSplitMode}
    FOR    ${id}    IN RANGE    1    ${no_modes}+1
        scf.modify_scf_element
        ...    value=${value}
        ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-${id}
        ...    p_name=dlDataSplitMode
        ...    list_name=nsaDrbParam
    END
    scf.Save scf    ${target_scf_path}

Perform commissioning with SCF file
    [Arguments]       ${scf_path}     ${alias}=cOAM
    Connect with runtime release  ${alias}
    coam.Perform commissioning    scf_file=${scf_path}
    ...                           skip_parameter_relation_errors=${TRUE}    connection=${alias}
    Verify if all cells are onair
    [Teardown]  coam.Teardown     connection=${alias}

Perform commissioning 1013
    [Arguments]         ${srb3SupportEnabled}=false
    ...                 ${a3MeasEnabled}=rsrp
    ...                 ${a5MeasEnabled}=rsrp
    ...                 ${actIntraFreqIntraGnbMobilityNSA}=true
    ...                 ${csiReportPeriodicity}=slots160
    ...                 ${lteToNrTimeOffset}=0
    ...                 ${enDcSyncStatus}=synchronous
    ...                 ${actCDrx}=false
    ...                 ${option}=none
    ...                 ${scramblingIdStep}=3
    ...                 ${actTcpBoostPug}=allUes

    Log to console      __Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    &{csiReportPeriodicity_dict}    Create dictionary    csiReportPeriodicity=${csiReportPeriodicity}
    ${is_higher}    check_release_is_higher_than    SBTS23R3
    run keyword if    ${is_higher} == ${True}    set to dictionary
    ...    ${csiReportPeriodicity_dict}    scramblingIdStep=${scramblingIdStep}
    Initialise delta store
    Add param to delta  ${object_path}      srb3SupportEnabled                value=${srb3SupportEnabled}

    Run keyword if    '${option}'=='B4'
    ...     Add param to delta  ${object_path}      actIntraFreqIntraGnbMobilityNSA   value=${actIntraFreqIntraGnbMobilityNSA}
    Run keyword if  '${actCDrx}' == 'false'
    ...     set test variable  ${actTcpBoostPug}  disabled

    FOR    ${cell_id}    IN     @{cell_ids}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    enDcSyncStatus      value=${enDcSyncStatus}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actCDrx             value=${actCDrx}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    lteToNrTimeOffset   value=${lteToNrTimeOffset}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actTcpBoostPug      value=${actTcpBoostPug}
        Add list parameters to delta  ${object_path}/NRCELL-${cell_id}
        ...    periodicCsiAcquisition     &{csiReportPeriodicity_dict}
        Run keyword if    '${option}'=='B4'    Run keywords
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a3MeasEnabled    value=${a3MeasEnabled}    AND
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a5MeasEnabled    value=${a5MeasEnabled}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair

Perform commissioning 1013 __23r3
    [Arguments]         ${srb3SupportEnabled}=false
    ...                 ${a3MeasEnabled}=rsrp
    ...                 ${a5MeasEnabled}=rsrp
    ...                 ${actIntraFreqIntraGnbMobilityNSA}=true
    ...                 ${csiReportPeriodicity}=slots160
    ...                 ${scramblingIdStep}=3
    ...                 ${lteToNrTimeOffset}=0
    ...                 ${enDcSyncStatus}=synchronous
    ...                 ${actCDrx}=false
    ...                 ${option}=none
    Log to console      __Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    &{csiReportPeriodicity_dict}    Create dictionary
    ...    csiReportPeriodicity=${csiReportPeriodicity}
    ...    scramblingIdStep=${scramblingIdStep}
    Initialise delta store
    Add param to delta  ${object_path}      srb3SupportEnabled                value=${srb3SupportEnabled}
    Run keyword if    '${option}'=='B4'
    ...     Add param to delta  ${object_path}      actIntraFreqIntraGnbMobilityNSA   value=${actIntraFreqIntraGnbMobilityNSA}
    FOR    ${cell_id}    IN     @{cell_ids}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    enDcSyncStatus      value=${enDcSyncStatus}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actCDrx             value=${actCDrx}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    lteToNrTimeOffset   value=${lteToNrTimeOffset}
        Add list parameters to delta  ${object_path}/NRCELL-${cell_id}
        ...    periodicCsiAcquisition     &{csiReportPeriodicity_dict}
        Run keyword if    '${option}'=='B4'    Run keywords
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a3MeasEnabled    value=${a3MeasEnabled}    AND
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a5MeasEnabled    value=${a5MeasEnabled}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair

Set pucchModeSelect
    [Arguments]         ${cell_ids}
    ...                 ${pucchModeSelect}=longPucch
    ...                 ${actAperCsi}=false
    ...                 ${actIncreasedFdmUsersPerSlot}=false
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    Initialise delta store
    FOR    ${cell_id}    IN     @{cell_ids}
      Add param to delta  ${object_path}/NRCELL-${cell_id}    pucchModeSelect              value=${pucchModeSelect}
      Add param to delta  ${object_path}/NRCELL-${cell_id}    actAperCsi                   value=${actAperCsi}
      Add param to delta  ${object_path}/NRCELL-${cell_id}    actIncreasedFdmUsersPerSlot  value=${actIncreasedFdmUsersPerSlot}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}

Gnb reset
    [Arguments]    ${alias}=cOAM
    Connect with runtime release  ${alias}
    ${cells_info}    coam.reset site    connection=${alias}
    Verify if all cells are onair
    Log to console                ${cells_info}
    [Teardown]  coam.Teardown     connection=${alias}

Attach and detach UE
    [Arguments]    ${ue_alias}=AT_BASED_UE_1
    taf.ue.Detach Ue   ${ue_alias}
    taf.ue.Attach Ue   ${ue_alias}
    Sleep    5s

Get sw
    Connect with runtime release     sw
    ${full_ver}         coam.Get sw version   connection=sw
    ${ver}              Fetch from left    ${full_ver}    _
    Set suite variable  ${ver}
    [Teardown]    coam.Teardown     connection=sw

Is abio
    [Arguments]    ${alias}=coam
    ${is_abio}    Set variable    ${FALSE}
    Connect with runtime release     ${alias}
    ${hw}         coam.Get detected hw info   connection=${alias}
    FOR    ${bmod}    IN    @{hw['basebandModules']}
        Run keyword if    '${bmod['productName'][:4]}'=='ABIO'
        ...    Set test variable    ${is_abio}    ${TRUE}
    END
    Set suite variable    ${is_abio}
    [Teardown]  coam.Teardown    connection=${alias}

Attenuate lte cell for SgNB Addition
    Is abio
    Run keyword if    ${is_abio}==${TRUE}
    ...                     Set attenuation and check    lines=${lines_cell1_LTE}    value=90
    ...         ELSE
    ...                     Set attenuation and check    lines=${lines_cell2_LTE}    value=90

Slow attenuation with checking
    [Arguments]      ${lines}    ${duration}=15    ${frequency}=6    ${attenuation}=strengthen    ${alias}=TopYoung
    ${attenuate_per_iter}     Evaluate    round(90/(${duration}*${frequency}),1)
    ${add_or_sub}    Set variable if    '${attenuation}'=='strengthen'    1    -1
    ${value}    att.Read attenuation    port=${${lines[0]}}
    FOR    ${iteration}    IN RANGE    1    ${duration}*${frequency}+1
        ${value}    Evaluate    ${value}+${add_or_sub}*${attenuate_per_iter}
        Set attenuation and check     lines=${lines}    value=${${value}}
        ${sleep}    Evaluate    1.0/${frequency}
        Sleep    ${sleep}
        Log to console      ${alias}
        Log to console      ${iteration}
    END

Slow attenuation
    [Arguments]      ${lines}    ${duration}=15    ${frequency}=6    ${attenuation}=strengthen    ${alias}=TopYoung
    ${attenuate_per_iter}     Evaluate    round(90/(${duration}*${frequency}),1)
    ${add_or_sub}    Set variable if    '${attenuation}'=='strengthen'    1    -1
    ${value}    Set variable if    '${attenuation}'=='strengthen'    0    ${max_attenuation_value}
    FOR    ${iteration}    IN RANGE    1    ${duration}*${frequency}+1
        ${value}    Evaluate    ${value}+${add_or_sub}*${attenuate_per_iter}
        Set attenuation     lines=${lines}    value=${${value}}
        ${sleep}    Evaluate    1.0/${frequency}
        Sleep    ${sleep}
        Log to console      ${iteration}
        Log to console      ${alias}
    END

PSCellChange attenuation setup
    ${len_5G2_values}    Get length    ${att_values['2_5G']}
    Run keyword if    ${att_values['1_LTE']}==90
    ...                 Set attenuation and check    lines=@{lines_cell1_LTE}    value=90
    ...               ELSE IF    ${att_values['2_LTE']}==90
    ...                 Set attenuation and check    lines=@{lines_cell2_LTE}    value=90
    ${unlocked_cells}      Get cell ids         adminState=Unlocked
    Set test variable      ${unlocked_cells}
    Set attenuation and check    lines=${lines_cell${unlocked_cells[0]}_5G}    value=${att_values['1_5G'][0]}
    Set attenuation and check    lines=${lines_cell${unlocked_cells[1]}_5G}    value=${att_values['2_5G'][0]}
    Log to console         ${len_5G2_values}

Attenuate lte cell for MeasGap
    [Arguments]    ${lines_cell1_LTE}    ${lines_cell2_LTE}
    Run keyword if    ${att_values['1_LTE']}!=90
    ...                 Set attenuation and check    lines=${lines_cell1_LTE}    value=${att_values['1_LTE']}
    ...               ELSE IF    ${att_values['2_LTE']}!=90
    ...                 Set attenuation and check    lines=${lines_cell2_LTE}    value=${att_values['2_LTE']}
    Log to console    Attenuate lte cell for MeasGap

Perform PSCellChange
    ${len1}    Get length    ${att_values['1_5G']}
    ${len2}    Get length    ${att_values['2_5G']}
    Run keyword if    ${len1}==2
    ...               Strengthen and weaken attenuation    cell_lines=${lines_cell${unlocked_cells[0]}_5G}
    ...                                  min=${att_values['1_5G'][0]}    max=${att_values['1_5G'][1]}
    Run keyword if    ${len2}==2
    ...               Strengthen and weaken attenuation    cell_lines=${lines_cell${unlocked_cells[1]}_5G}
    ...                                  min=${att_values['2_5G'][0]}    max=${att_values['2_5G'][1]}

Activate debug logs
    [Arguments]      ${command}= printf "[control]\n \nLoggingSeverity=debug" > /ffs/run/cp_runtime.ini
    Connect with runtime release     sw
    ${full_ver}         coam.Get sw version   connection=sw
    ${ver}              Fetch from left    ${full_ver}    _
    ${smod}         coam.Get fsm info        connection=sw
    ${smod name}    Get substring    ${smod[0]['productName']}    0    4
    Set suite variable   ${smod name}
    Run keyword if      '${ver}'=='5G20B'    Run keywords
    ...                 Connect to SMOD SLAVE    alias=asik_slave                 AND
    ...                 ssh.send_command   ${command}     connection=asik_slave   AND
    ...                 ssh.send_command   crasign /ffs/run/cp_runtime.ini    connection=asik_slave     AND
    ...                 ssh.Disconnect    connection=asik_slave
    Connect to ASIK    alias=asik
    ssh.send_command   ${command}     connection=asik
    ssh.send_command   crasign /ffs/run/cp_runtime.ini    connection=asik
    [Teardown]    Run keywords    ssh.Disconnect    connection=asik          AND
    ...                           coam.Teardown     connection=sw

Attach to lte cell
    [Arguments]     ${to_attenuate}=0    ${ue_alias}=AT_BASED_UE_1
    Run keyword if    ${to_attenuate}!=0
    ...               Set attenuation and check    lines=${to_attenuate}     value=90
    taf.ue.Detach Ue   ${ue_alias}
    taf.ue.Attach Ue   ${ue_alias}
    Run keyword if    ${to_attenuate}!=0
    ...               Set attenuation and check    lines=${to_attenuate}     value=0

Start throughput
    [Arguments]    ${throughput}=100Mbits/sec    ${deviation}=20%    ${ue_alias}=AT_BASED_UE_1
    ...            ${dt_alias}=DT_1    ${protocol}=udp    ${duration}=60s
    Log to console    Starting thruoughput, deviation: ${throughput} ${deviation}

    taf.ue.Start Data Transfer
    ...     dt_name=${dt_alias}
    ...     ue_alias=${ue_alias}
    ...     direction=dl
    ...     duration=${duration}
    ...     throughput=${throughput}
    ...     protocol=${protocol}
    ...     packet_size=1400
    Sleep  2s

Stop throughput
    [Arguments]    ${dt_alias}=DT_1
    Await Data Transfer Finish    ${dt_alias}
    Log to console      Stop throughput
Check and log MeasConfigMN
    [Arguments]    ${measgap_field}    ${attrib_name_list}
    ${attrib_name_list}    Check measgap setup and release    ${measgap_field}    ${attrib_name_list}
    Log MeasConfigMN    ${measgap_field}    ${attrib_name_list}

Check measgap setup and release
    [Arguments]    ${measgap_field}    ${attrib_name_list}
    ${type}    Fetch from right    ${TEST_NAME}    1013-
    Should contain    ${attrib_name_list}    setup    msg=There is no measGapConfig in ${measgap_field}
    Run keyword if    '${type[0]}'=='B'    Run keywords
    ...     Should contain    ${attrib_name_list}     release: NULL
    ...                                   msg=No measGapConfig release in ${measgap_field}    AND
    ...     Remove values from list    ${attrib_name_list}    release: NULL
    [Return]    ${attrib_name_list}

Log MeasConfigMN
    [Arguments]    ${measgap_field}    ${attrib_name_list}
    ${type}    Fetch from right    ${TEST_NAME}    1013-
    Log to console    \nmeasGapConfig in ${measgap_field}:
    FOR    ${index}    ${param}   IN ENUMERATE   @{attrib_name_list}
        Run keyword if    ${index}>=1     Log to console    \t   no_newline=${TRUE}
        Run keyword if    ${index}>=2 and ${index}<=5   Log to console    \t   no_newline=${TRUE}
        Log to console    ${param}
    END
    Run keyword if    '${type[0]}'=='B'
    ...               Log to console    measGapConfig release is present

Check SgNBRelease occurence
    [Arguments]    ${pdml_file}
    ${entry_add}           pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=x2ap.SgNBAdditionRequest_element
    ...                                             attrib_name=showname   attrib_value=SgNBAdditionRequest
    ${entry_rel}           pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=x2ap.SgNBReleaseRequired_element
    ...                                             attrib_name=showname   attrib_value=SgNBReleaseRequired
    ${addition_time}       pdmlp.Get entry time     ${entry_add[0]}
    ${release_time}        Run keyword if    ${entry_rel}    pdmlp.Get entry time    ${entry_rel[-1]}
    Run keyword if         ${entry_rel}
    ...                    Should be true    ${release_time} < ${addition_time}
    ...                                      msg=There is SgNBReleaseRequired in pcap

Check event
    [Arguments]    ${pdml_file}    ${field}    ${id}
    ${field}    Create list    ${field}
    ${mess}     pdmlp.Get msg    file_name=${pdml_file}  field_name_list=${field}
    ${number}    Evaluate    ${${id}}-1
    Should contain    ${mess}    eventId: eventA${id} (${number})

Change order of physcellids
    [Arguments]    ${attrib_list}
    ${phys_matches}    Get matches     ${attrib_list}    physCellId*
    Remove values from list    ${attrib_list}    @{phys_matches}
    ${attrib_list}    Combine lists    ${attrib_list}    ${phys_matches}
    [Return]    ${attrib_list}    ${phys_matches}

Check MeasConfigMN
    [Arguments]    ${pdml_file}    ${measgap_fields}    ${option}
    ...            ${measgap_attrib_vals}    ${measgap_number}=1
    ${no_fields}    Get length    ${measgap_fields}
    FOR    ${index}    IN RANGE   0    ${no_fields}
        ${entries}        pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=${measgap_fields[${index}]}
        ...    attrib_name=showname   attrib_value=${measgap_attrib_vals[${index}]}
        ${attrib_list}    pdmlp.Get attrib value from pdml entries    pdml_entries=${entries}
        ...    field_names=@{MeasConfigMN_fields}   attrib_name=showname
        ${attrib_list}    ${phys_matches}    Change order of physcellids    ${attrib_list}
        Run keyword if    '${option}'!='B1' or '${measgap_fields[${index}]}'=='f1ap.UEContextSetupRequest_element'
        ...                             Should not be empty    ${phys_matches}
        ...                                                    msg=There is no physCellId in ${measgap_fields[${index}]}
        Check and log MeasConfigMN    measgap_field=${measgap_fields[${index}]}    attrib_name_list=${attrib_list}
        Run keyword if    ${measgap_number}!=1    Check number of measgap       ${pdml_file}    ${measgap_number}
    END

Check number of measgap
    [Arguments]       ${pdml_file}    ${measgap_number}
    ${mess_fields}    Create list     nr-rrc.measGapConfig
    @{setup_mess}     pdmlp.Get msg   file_name=${pdml_file}  field_name_list=${mess_fields}
    ...                               use_set=${False}
    ${measgap_count}    Count Values In List    ${setup_mess}    measGapConfig: setup (1)
    Should be true      ${measgap_count}>=${measgap_number}      msg=Not enough MeasGapConfig messages

Check slots
    [Arguments]    ${nr_slots_not_expected}  ${path}=/tmp/master/master.pcap
    ${pdml_file}        Convert pcap to pdml  ${path}
    ${entries}          pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=nr-rrc.csi_MeasConfig
    ...                                         attrib_name=showname   attrib_value=csi-MeasConfig: setup (1)
    ${slot_parameter}   pdmlp.Get attrib value from pdml entries    pdml_entries=${entries}
    ...                                         field_names=nr-rrc.reportSlotConfig   attrib_name=showname
    ${slot_parameter}   Get regexp matches    ${slot_parameter[0]}    (slots[0-9]+)
    ${slots_not_expected}     Change slots to messages    ${nr_slots_not_expected}   ${slot_parameter[0]}
    ${slots_mess}       pdmlp.Get attrib value from pdml entries    pdml_entries=${entries}
    ...                                         field_names=nr-rrc.${slot_parameter[0]}   attrib_name=showname
    ${max_slot}         Get max slot from slot list    ${slots_mess}
    ${min_slot}         Get min slot from slot list    ${slots_mess}
    Should be true    ${min_slot}<=18    msg=Not enough slots in logs. Try to reset gnb.
    Should be true    ${max_slot}>=25    msg=Not enough slots in logs
    ${result}           Compare slots    ${slots_mess}    ${slots_not_expected}
    Should be true    ${result}    msg=Wrong slots! Current slots: ${slots_mess}, Not expected slots: ${slots_not_expected}

Check list with physcellId sequence
    [Arguments]     ${list}    ${step}
    ${length}       Get Length    ${list}
    ${counter}      Set variable    ${0}
    FOR     ${index}   IN RANGE    ${length}-${step}
        ${var1}    Convert to list   ${list[${index}]}
        ${var2}    Convert to list   ${list[${index}+${step}]}
        ${condition}      Evaluate    ${var1}!=${var2}
        ${counter}        Set variable if    ${condition}    ${${counter}+1}    ${counter}
    END
    ${sequence_ratio}    Evaluate    ${counter}.0/(${length}-${step})
    Should be true    ${sequence_ratio}>0.95   msg=PhysCellIds sequence is not correct

Check physcellId sequence
    [Arguments]    ${pdml_file}   ${fields}    ${option}
    ${physcell_list}    Create list
    FOR    ${field}    IN    @{fields}
        ${attrib_value}    Get regexp matches      ${field}    (?<=[.])(.*)(?=_)
        ${entry}           pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=${field}
        ...    attrib_name=showname   attrib_value=${attrib_value[0]}
        ${attrib_list}     pdmlp.Get separately attrib value from pdml entries    pdml_entries=${entry}
        ...    field_names=nr-rrc.physCellId   attrib_name=showname
        Should not be empty    ${attrib_list}    msg=There is no physCellId in ${field}
        Append to list    ${physcell_list}    ${attrib_list}
    END
    Check list with physcellId sequence    list=${physcell_list[0]}    step=1
    Run keyword if    '${option}'=='A'
    ...               Set list value    ${physcell_list}    1    ${physcell_list[1][:8]}
    Check list with physcellId sequence    list=${physcell_list[1]}    step=2

Check srb3 support
    [Arguments]    ${pdml_file}
    @{srb3_fields}           Create list    f1ap.UEContextModificationRequest_element
    ...                                     x2ap.SgNBAdditionRequestAcknowledge_element
    @{srb3_fields_vals}      Create list    UEContextModificationRequest
    ...                                     SgNBAdditionRequestAcknowledge
    @{srb3_param_fields}     Create list    nr-rrc.srb3            nr-rrc.srb_Identity
    @{srb3_param_expect}     Create list    srb3: supported (0)    srb-Identity: 3
    ${indexes}     Get length    ${srb3_fields}
    FOR    ${index}    IN RANGE    ${indexes}
        ${entries}           pdmlp.Get pdml entries   file_name=${pdml_file}  field_name=${srb3_fields[${index}]}
        ...    attrib_name=showname   attrib_value=${srb3_fields_vals[${index}]}
        ${attrib}      pdmlp.Get attrib value from pdml entries    pdml_entries=${entries}
        ...    field_names=${srb3_param_fields[${index}]}   attrib_name=showname
        Should not be empty           ${attrib}
        ...    msg=There is no ${srb3_param_expect[${index}]} in ${srb3_fields_vals[${index}]}
        Should be equal as strings    ${attrib[0]}    ${srb3_param_expect[${index}]}
        ...    msg=There is no ${srb3_param_expect[${index}]} in ${srb3_fields_vals[${index}]}
    END

Check pcap
    [Arguments]    ${option}=B1    ${DRX}=${FALSE}    ${event_id}=${EMPTY}
    ...            ${srb3}=${FALSE}  ${path}=/tmp/master/master.pcap
    ${pdml_file}        Convert pcap to pdml    path=${path}
    ${pdml_size}        Get file size    ${pdml_file}
    Should be true     ${pdml_size}>0      msg=Pdml file is empty. Check tshark
    Run keyword if    '${option}'=='B1'    Check pcap B1           pdml_file=${pdml_file}
    ...                                                            srb3=${srb3}    DRX=${DRX}
    ...    ELSE IF    '${option}'=='B4'    Check pcap B4           pdml_file=${pdml_file}
    ...                                                            srb3=${srb3}    event_id=${event_id}
    ...    ELSE                            Check pcap ${option}    pdml_file=${pdml_file}

Check pcap B1
    [Arguments]    ${pdml_file}    ${DRX}    ${srb3}
    @{measgap_fields}         Create list    f1ap.UEContextModificationRequest_element
    ...                                      x2ap.SgNBModificationRequest_element
    @{measgap_attrib_vals}    Create list    UEContextModificationRequest
    ...                                      SgNBModificationRequest
    @{mess_fields}            Create list    f1ap.UEContextModificationRequest_element
    ...                                      x2ap.SgNBModificationRequest_element
    ...                                      x2ap.SgNBModificationRequestAcknowledge_element
    ...                                      x2ap.SgNBReconfigurationComplete_element
    ...                                      f1ap.UEContextModificationResponse_element
    ...                                      nr-rrc.RRCReconfigurationComplete_element
    @{mess_expect}            Create list    UEContextModificationRequest    SgNBModificationRequest
    ...                                      SgNBModificationRequestAcknowledge    SgNBReconfigurationComplete
    ...                                      UEContextModificationResponse    RRCReconfigurationComplete
    Run keyword if    ${DRX}==${TRUE}    Run keywords
    ...                           Append to list    ${mess_fields}      nr-rrc.drx_Config         AND
    ...                           Append to list    ${mess_expect}      drx-Config: release (0)    drx-Config: setup (1)
    Run keyword if        ${srb3}
    ...                   Check srb3 support    ${pdml_file}
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=B1                 measgap_attrib_vals=${measgap_attrib_vals}
    @{mess}               pdmlp.Get msg    file_name=${pdml_file}  field_name_list=${mess_fields}
    Sort List          ${mess_expect}
    Should be equal    ${mess}    ${mess_expect}     msg=Wrong messages in pcap

Check pcap B2_A
    [Arguments]    ${pdml_file}
    @{measgap_fields}         Create list    x2ap.SgNBAdditionRequest_element
    ...                                      f1ap.UEContextSetupRequest_element
    @{measgap_attrib_vals}    Create list    SgNBAdditionRequest
    ...                                      UEContextSetupRequest
    @{mess_fields}            Create list    x2ap.SgNBAdditionRequest_element
    ...                                      f1ap.UEContextSetupRequest_element
    ...                                      x2ap.SNStatusTransfer_element
    ...                                      f1ap.UEContextSetupResponse_element
    ...                                      x2ap.SgNBAdditionRequestAcknowledge_element
    ...                                      x2ap.SgNBReconfigurationComplete_element
    @{mess_expect}            Create list    SgNBAdditionRequest    UEContextSetupRequest
    ...                                      SNStatusTransfer    UEContextSetupResponse
    ...                                      SgNBAdditionRequestAcknowledge    SgNBReconfigurationComplete
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=B2_A               measgap_attrib_vals=${measgap_attrib_vals}
    @{mess}               pdmlp.Get msg    file_name=${pdml_file}  field_name_list=${mess_fields}
    Sort List          ${mess_expect}
    Should be equal    ${mess}    ${mess_expect}     msg=Wrong messages in pcap

Check pcap B4
    [Arguments]    ${pdml_file}    ${event_id}    ${srb3}
    @{measgap_fields}         Create list    f1ap.UEContextModificationRequest_element
    @{measgap_attrib_vals}    Create list    UEContextModificationRequest
    @{mess_fields}            Create list    x2ap.SgNBAdditionRequest_element
    ...                                      x2ap.SgNBReconfigurationComplete_element
    ...                                      nr-rrc.RRCReconfigurationComplete_element
    ...                                      x2ap.SNStatusTransfer_element
    ...                                      f1ap.UEContextSetupResponse_element
    ...                                      f1ap.UEContextModificationResponse_element
    ...                                      f1ap.UEContextModificationRequest_element
    ...                                      x2ap.SgNBAdditionRequestAcknowledge_element
    @{mess_expect}            Create list    SgNBReconfigurationComplete    RRCReconfigurationComplete
    ...                                      SNStatusTransfer      UEContextSetupResponse
    ...                                      UEContextModificationResponse      UEContextModificationRequest
    ...                                      SgNBAdditionRequest    SgNBAdditionRequestAcknowledge
    @{physcellid_fields}      Create list    f1ap.UEContextModificationRequest_element
    ...                                      f1ap.UEContextModificationResponse_element
    Sort List             ${mess_expect}
    Check physcellId sequence     pdml_file=${pdml_file}
    ...                           fields=${physcellid_fields}
    ...                           option=A
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=B4                 measgap_attrib_vals=${measgap_attrib_vals}
    Run keyword if        ${srb3}
    ...                   Check srb3 support    ${pdml_file}
    Check event           pdml_file=${pdml_file}    field=nr-rrc.eventId    id=${event_id}
    @{mess}               pdmlp.Get msg    file_name=${pdml_file}  field_name_list=${mess_fields}
    Should be equal       ${mess}    ${mess_expect}     msg=Wrong messages in pcap

Check pcap D1
    [Arguments]    ${pdml_file}
    @{measgap_fields}         Create list    x2ap.SgNBModificationRequestAcknowledge_element
    ...                                      f1ap.UEContextSetupResponse_element
    @{measgap_attrib_vals}    Create list    SgNBModificationRequestAcknowledge
    ...                                      UEContextSetupResponse
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=D1                 measgap_attrib_vals=${measgap_attrib_vals}
    ...                   measgap_number=10

Check pcap D2
    [Arguments]    ${pdml_file}
    @{measgap_fields}         Create list    x2ap.SgNBAdditionRequest_element
    ...                                      f1ap.UEContextSetupResponse_element
    @{measgap_attrib_vals}    Create list    SgNBAdditionRequest
    ...                                      UEContextSetupResponse
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=D2                 measgap_attrib_vals=${measgap_attrib_vals}
    ...                   measgap_number=10

Check pcap D4
    [Arguments]    ${pdml_file}
    @{measgap_fields}         Create list    f1ap.UEContextModificationRequest_element
    @{measgap_attrib_vals}    Create list    UEContextModificationRequest
    @{physcellid_fields}      Create list    f1ap.UEContextModificationRequest_element
    ...                                      f1ap.UEContextModificationResponse_element
    Check physcellId sequence     pdml_file=${pdml_file}
    ...                           fields=${physcellid_fields}
    ...                           option=D
    Check MeasConfigMN    pdml_file=${pdml_file}    measgap_fields=${measgap_fields}
    ...                   option=D4                 measgap_attrib_vals=${measgap_attrib_vals}
    ...                   measgap_number=10

Get cells number
    [Arguments]    ${alias}=cOAM
    Connect with runtime release    ${alias}
    ${cells_info}    coam.Get cells info    connection=${alias}
    ${no_cells}      Get length    ${cells_info}
    [Teardown]  coam.Teardown     connection=${alias}
    [Return]    ${no_cells}

Move logs to test folder 1013
    ${dir}    Set variable    ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    operatingSystem.Create Directory    ${dir}/pcaps
    operatingSystem.Move files    /tmp/master/master.pcap    /tmp/master/master.pdml
    ...                           ${OUTPUT DIR}/tcpdump_L2L1*.pcap
    ...                           ${dir}/pcaps
