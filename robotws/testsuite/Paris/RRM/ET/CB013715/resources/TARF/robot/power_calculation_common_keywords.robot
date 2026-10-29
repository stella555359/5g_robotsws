*** Settings ***
Library      OperatingSystem
Library      Collections
Library      BuiltIn
Library      String

Library      ./../python/tools.py                          WITH NAME    nps_trf_tools
Library      ./../python/coam_parameter.py                 WITH NAME    coam_parameters
Library      ./../lib_py/powercalcu_python_lib.py          WITH NAME    powercalcu_python_lib

Resource     ./coam_nps.robot

Documentation
...   This Keyword is used to check 5G Power calculation:
...   SSB power calculation, DL Power in Bip and Power setting to UE
...   please use this keyword in this way:
...       Get SSB Power Parameters Via Coam Admin   #Input Parameters
...       Check SSB Power Calculation Parameters    # SSB power calculation output
...       Analyze DL Power In BIP                   # SSB power calculation output

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

Get SSB Power Parameters Via Coam Admin
    [Documentation]    Description: Get input values via COAM Admin.
    ...                input values:
    ...                            pmax, ssPbchBlockPower(dBm/RE), Channel bandwidth with PRB, rbAllocation,
    ...                           actDl256Qam,  dlQam256PowerBackoff, dlMimoMode, numberOfTransmittedSsBlocks
    [Arguments]    ${cell_id}=1    ${cell_group_index}=${0}    ${beamforming_type}=DBF
    ...    ${mr_bts_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${alias}=coam_gnb
    ${modified_paras}    create list    actDl256Qam    chBw    dlMimoMode    dlQam256PowerBackoffSub6
    ...    numberOfTransmittedSsBlocks    pMax    rbAllocation    ssPbchBlockPower
    @{para_value_list}    create list
    FOR  ${parameter}  IN  @{modified_paras}
      ${dist_name}    set variable if    '${parameter}'=='numberOfTransmittedSsBlocks'
        ...    MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELLGRP-${cell_group_index}
        ...    MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}
      ${actual_para_value}    coam_parameters.get_single_value_from_scf_file_coam
      ...    dist_name=${dist_name}
      ...    parameter=${parameter}
      ...    connection=${alias}
      ${param_values}=    coam_nps.Get SCF single Value from current xml file     parameter=${parameter}
      ...                                                                         dist_name=${dist_name}
      ...                                                                         alias=${alias}
      nps_trf_tools.log_to_console_with_time_prefix   From NIDD for Cell=${cell_id} ${parameter}=${param_values}   level=INFO
      append to list    ${para_value_list}    ${actual_para_value}
    END
    power_calculation_common_keywords.Get SSB Power NIDD Parameter Values    para_value_list=${para_value_list}
    set test variable    ${beamforming_type}

Check SSB Power Calculation Parameters
    [Documentation]    Description: This keyword is used to compare SSB power caculation parameters with expected ones.
    ...                SSB power caculation parameters: maxSsBlockPower(dB), powerBudgetPerBeam(dB), ssBlockPowerFromNidd(dB)
    ...                Parameter values are got from SSB logs.
    ...                Expected values are caculated:
    ...                        maxSsBlockPower(dB) = Floor(-10*LOG10(maxRE))
    ...                        powerBudgetPerBeam = floor(pmax+10*log10(#TRX))+ MU-MIMO offset
    ...                        ssBlockPowerFromNidd=ssPbchBlockPower-powerBudgetPerBeam
    ...                        ssBlockPower(0.1dB) = MIN(maxSsBlockPower,ssBlockPowerFromNidd)*10
    [Arguments]    ${numOfTRX}    ${MU_MIMO_offset}=${0}     ${cell_id}=1    ${cell_group_index}=${0}
    ${maxRe} =    powercalcu_python_lib.get_maxRe    chbw=${chbw_prb}    rballocation=${rbAllocation_value}
    set test variable    ${maxRe}
    nps_trf_tools.log_to_console_with_time_prefix   for Cell=${cell_id} maxRe=${maxRe}   level=INFO
    &{ssb_power_calculation} =    create dictionary    sspbchBlcokPower=${sspbch_blcok_power}
    ...    maxRe=${maxRe}    numofTRX=${numOfTRX}    pmax=${pmax}
    ...    ruBeamformingType=${beamforming_type}    mumimoOffset=${MU_MIMO_offset}
    @{expected_ssb_power_paras} =    powercalcu_python_lib.get_ssb_power_calculation    &{ssb_power_calculation}
    set test variable    ${expected_powerBudgetPerBeam}    ${expected_ssb_power_paras}[1]
    set test variable    ${expected_ssBlockPower}    ${expected_ssb_power_paras}[3]
    set test variable    ${max_ssPbchBlockPower}    ${expected_ssb_power_paras}[4]
    nps_trf_tools.log_to_console_with_time_prefix   for Cell=${cell_id} numOfTRX=${numOfTRX}   level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   for Cell=${cell_id} expected_powerBudgetPerBeam=${expected_powerBudgetPerBeam}   level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   for Cell=${cell_id} expected_ssBlockPower=${expected_ssBlockPower}   level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   for Cell=${cell_id} max_ssPbchBlockPower=${max_ssPbchBlockPower}   level=INFO

#------------------------------- Analyze DL Power In BIP  ---------------------------------------------#
Analyze DL Power In BIP
    [Documentation]    Description: This keyword is used to verify dl power transmit power in BIP Log.
    ...                update check bip file with taf.ul.parser.pcap lib.
    ...                DL Transmit Power Parameters:
    ...                      ssBlockPower(0.1dB) in DlCell_SetupReq
    ...                      csiTransmitPower(0.1dB) CSI-RS measurement
    ...                      csiTransmitPower(0.1dB) CSI-RS tracking
    ...                      pdschTbTransmitPower(0.1dB)
    ...                      pdcchDciTransmitPower(0.1dB)
    [Arguments]    ${bip_log_file}    ${csi_item_value}=19
    ...    ${rdPdcchPrecodingOption4X4}=${2}    ${rdPdschPrecodingOption4X4}=${2}
    ...    ${pdcch_item_value}=7
    ...    ${luashark_path}=/home/ute/luashark_script/generated_luashark/luashark.lua
    ...    ${TSHARK_PATH}=/usr/bin/tshark
    ...    ${FILTER}=dldata_pdschsendreq||dldata_pdcchsendreq||dldata_csirssendreq
    ...    ${command_template}={tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y "${FILTER}" -T pdml > {output_file}
    Get Expected CSIPowerOffset
    ${pdml_packets}=    Convert Pcap to pdml format    file_path=${bip_log_file}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    Verify CSI-RS Values In BIP    bip_log_file=${bip_log_file}    item_value=${csi_item_value}
    ...    luashark_path=${luashark_path}
    ...    pdml_packets=${pdml_packets}
    Verify PDSCH TB Power Values In BIP
    ...    bip_log_file=${bip_log_file}
    ...    rdPdcchPrecodingOption4X4=${rdPdcchPrecodingOption4X4}
    ...    rdPdschPrecodingOption4X4=${rdPdschPrecodingOption4X4}
    ...    item_value=${pdcch_item_value}
    ...    luashark_path=${luashark_path}
    ...    pdml_packets=${pdml_packets}
    [Teardown]    pcap.teardown

Verify CSI-RS Values In BIP
    [Documentation]  Description: verify csiTransmitPower(0.1dB) CSI-RS measurement and CSI-RS tracking in CSI-RS BIP
    ...              Expected values are caculated:
    ...                        csiTransmitPower(0.1dB) CSI-RS measurement = ssBlockPower+csiPowerOffset
    ...                        csiTransmitPower(0.1dB) CSI-RS tracking = ssBlockPower+csirsTrackingPowerControlOffsetSS
    [Arguments]    ${bip_log_file}    ${pdml_packets}
    ...    ${item_value}=11    ${luashark_path}=/home/ute/luashark_script/generated_luashark/luashark.lua
    ${tracking} =    set variable    DlData_CsiRsSendReq.csiRsResources_item_${item_value}.trsInfo == 0x01
    ${no_tracking} =    set variable    DlData_CsiRsSendReq.csiRsResources_item_${item_value}.trsInfo == 0x00
    ${csi_element_name} =    set variable    .//DlData_CsiRsSendReq.csiRsResources_item_${item_value}.csiTransmitPower
    ${no_tracking_element} =    set variable    .//DlData_CsiRsSendReq.csiRsResources_item_${item_value}.csiTransmitPower
    ${csiTransmitPower_meas}    ${csirs_meas_length} =   Get IE Length and Value Of BIP
    ...    filter_expression=${no_tracking}
    ...    xpath=${csi_element_name}
    ...    pdml_list=${pdml_packets}
    ${csiTransmitPower_tracking}    ${csirs_tracking_length} =   Get IE Length and Value Of BIP
    ...    filter_expression=${tracking}
    ...    xpath=${csi_element_name}
    ...    pdml_list=${pdml_packets}
    ${expected_csitramsmit_meas} =    evaluate    ${expected_ssBlockPower} + ${csiPowerOffset}
    ${expected_csitramsmit_tracking} =   evaluate    ${expected_ssBlockPower} + ${csirsTrackingPowerControlOffsetSS}
    run keyword and continue on failure    should be equal as integers
    ...    @{csiTransmitPower_meas}[0]    ${expected_csitramsmit_meas}
    run keyword and continue on failure    should be equal as integers
    ...    @{csiTransmitPower_tracking}[0]    ${expected_csitramsmit_tracking}

Verify PDSCH TB Power Values In BIP
    [Documentation]  Description: verify pdschTbTransmitPower(0.1dB) and pdcchDciTransmitPower(0.1dB) in BIP log
    ...              updated 2020-12-18: after feature 522 Dynamic 256qam backoff introduced, pdschTbTransmitPower value changes dynamically.
    [Arguments]    ${bip_log_file}    ${pdml_packets}
    ...    ${rdPdcchPrecodingOption4X4}=${2}    ${rdPdschPrecodingOption4X4}=${2}
    ...    ${item_value}=7
    ...    ${luashark_path}=/home/ute/luashark_script/generated_luashark/luashark.lua
    ...    ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${gnb_sw_version}    coam.get_sw_version    connection=${connection}
    run keyword and ignore error    COAM Teardown gnb connections
    ${pdschtb} =    set variable    dldata_pdschsendreq
    ${pdcchdci} =    set variable    dldata_pdcchsendreq
    ${pdsch_element} =    set variable if    '5G20A' in '${gnb_sw_version}'
    ...    .//DlData_PdschSendReq.PdschSendReq.pdschTbTransmitPower
    ...    .//DlData_PdschSendReq.grants_item_15.pdschTbTransmitPower
    ${pdcch_element} =    set variable if    '5G20A' in '${gnb_sw_version}'
    ...    .//DlData_PdcchSendReq.dciInfo_item_${item_value}.pdcchDciTransmitPower
    ...    .//DlData_PdcchSendReq.dciInfo_item_15.pdcchDciTransmitPower
    ${filter_rank} =    set variable if    '5G20A' in '${gnb_sw_version}'
    ...    .//DlData_PdschSendReq.PdschSendReq.numOfLayers
    ...    .//DlData_PdschSendReq.grants_item_15.numOfLayers
    ${pdschtbPower}    ${pdsch_length} =   Get IE Length and Value Of BIP
    ...    filter_expression=${pdschtb}
    ...    xpath=${pdsch_element}
    ...    pdml_list=${pdml_packets}
    ${pdcchdciPower}    ${pdcch_length} =   Get IE Length and Value Of BIP
    ...    filter_expression=${pdcchdci}
    ...    xpath=${pdcch_element}
    ...    pdml_list=${pdml_packets}
    ${DL_Scheduled_Rank}    ${rank_length} =   Get IE Length and Value Of BIP
    ...    filter_expression=${pdschtb}
    ...    xpath=${filter_rank}
    ...    pdml_list=${pdml_packets}
    sort list    ${DL_Scheduled_Rank}
    Reverse List 	${DL_Scheduled_Rank}
    &{pdschPowerOffset_paras}    create dictionary    ruBeamformingType=${beamforming_type}
    ...    MIMO4X4Enabled=${4x4_mimo_enabled}    rdPdschPrecodingOption4X4=${rdPdschPrecodingOption4X4}
    ...    dlScheduledRank=@{DL_Scheduled_Rank}[0]
    ${pdschPowerOffset}    get_pdschPowerOffset    &{pdschPowerOffset_paras}
    &{pdcchPowerOffset_paras}    create dictionary    ruBeamformingType=${beamforming_type}
    ...    MIMO4X4Enabled=${4x4_mimo_enabled}    rdPdcchPrecodingOption4X4=${rdPdcchPrecodingOption4X4}
    ${pdcchPowerOffset}    get_pdcchPowerOffset    &{pdcchPowerOffset_paras}
    ${expected_pdcchdci_power} =    get_dl_trans_power    para1=${chbw_prb}    para2=${0}
    ${expected_pdschtb_power} =    get_dl_trans_power    para1=${chbw_prb}    para2=${dl256qam_power_backoff}
    ${expected_pdschTbTransmitPower}    evaluate    ${expected_pdschtb_power} + ${pdschPowerOffset}
    ${expected_pdschTbTransmitPower}    convert to integer    ${expected_pdschTbTransmitPower}
    ${expected_pdcchDciTransmitPower}    evaluate    ${expected_pdcchdci_power} + ${pdcchPowerOffset}
    run keyword and continue on failure    list should contain value
    ...    ${pdschtbPower}    ${expected_pdschTbTransmitPower}
    run keyword and continue on failure    should be equal as integers
    ...    @{pdcchdciPower}[0]    ${expected_pdcchDciTransmitPower}

Get Expected CSIPowerOffset
    [Documentation]  Description: this keyword is used to get expected poweroffset values.
    ...              csiPowerOffset, csirsTrackingPowerControlOffsetSS
    &{csiPowerOffset_input_para}    create dictionary    ruBeamformingType=${beamforming_type}
    ...    MIMO4X4Enabled=${4x4_mimo_enabled}
    ${csiPowerOffset}    get_csiPowerOffset    &{csiPowerOffset_input_para}
    set test variable    ${csiPowerOffset}
    &{csirsTrackingPowerControlOffsetSS_paras}    create dictionary    numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}
    ...    ruBeamformingType=${beamforming_type}    rballocation=${rbAllocation_value}
    ...    maxRe=${maxRe}    sspbchBlcokPower=${sspbch_blcok_power}    maxssPbchBlockPower=${max_ssPbchBlockPower}
    ${csirsTrackingPowerControlOffsetSS}    get_csirsTrackingPowerControlOffsetSS    &{csirsTrackingPowerControlOffsetSS_paras}
    set test variable    ${csirsTrackingPowerControlOffsetSS}

#------------------------------- Verify Power Setting To UE In X2 Log  ---------------------------------------------#
Verify Power Setting To UE In X2 Log
    [Documentation]    Description: This keyword is used to verify power setting to ue.
    ...                in RRC Message: ss-PBCH-BlockPower, powerControlOffset, powerControlOffsetSS(dB)
    ...                Arguments: rdSyncSignalsTxMode(default is 2)
    ...                            powerControlOffsetSS = db0    # Fixed value db0 used for all CSI-RS
    [Arguments]    ${x2_log_file}
    ...    ${rdSyncSignalsTxMode}=${2}
    ...    ${expected_powerControlOffsetSS}=1
    ${expected_sspbch_blcok_power_rrc} =    Get Expected Sspbch Block Power    rdSyncSignalsTxMode=${rdSyncSignalsTxMode}
#    ${expected_power_control_offset} =    Get Expected Power Control Offset
    @{power_control_offset_paras} =  create list    ${actDl256Qam}    ${dl256qam_power_backoff}    ${expected_powerBudgetPerBeam}
    ...    ${chbw_prb}    ${sspbch_blcok_power}
    ${expected_power_control_offset} =    get_power_control_offset    @{power_control_offset_paras}
    ${expected_power_control_offset} =    convert to string    ${expected_power_control_offset}
    ${ss_PBCH_BlockPower_list} =    create list    .//nr-rrc.ss_PBCH_BlockPower    ${expected_sspbch_blcok_power_rrc}    ${0}
    ${powerControlOffset_list} =    create list    .//nr-rrc.powerControlOffset    ${expected_power_control_offset}    ${0}
    ${powerControlOffsetSS_list} =    create list    .//nr-rrc.powerControlOffsetSS    ${expected_powerControlOffsetSS}    ${0}
    ${power_setting_to_ue} =    create list    ${ss_PBCH_BlockPower_list}    ${powerControlOffset_list}    ${powerControlOffsetSS_list}
    Check X2 PCAP      IE_values=${power_setting_to_ue}       x2_pcap=${x2_log_file}

#--------------------------------Get Input Parameters--------------------------------------------#
Get SSB Power NIDD Parameter Values
    [Documentation]  Description: Get Parameter values via Megazone Client
    [Arguments]    ${para_value_list}
    ${pmax_status}    run keyword and return status    Should Contain    ${para_value_list}[5]    dB
    ${pmax} =    fetch from left    ${para_value_list}[5]    dB
    ${pmax} =     convert to integer    ${pmax}
    ${pmax}    set variable if    '${pmax_status}'=='true'    ${pmax}    ${pmax / 10}
    ${sspbch_blcok_power}    fetch from left    ${para_value_list}[7]    dB
    ${sspbch_blcok_power} =     convert to integer    ${sspbch_blcok_power}
    ${chbw_prb} =    Get Channel Bandwidth With PRB    chbw=${para_value_list}[1]
    set test variable    ${pmax}
    set test variable    ${sspbch_blcok_power}
    set test variable    ${chbw_prb}
    ${rbAllocation_value}    set variable if    '${para_value_list}[6]'=='BWP'    ${chbw_prb}    ${52}
    set test variable    ${rbAllocation_value}
    set test variable    ${actDl256Qam}    ${para_value_list}[0]
    ${dl256qam_power_backoff} =    Get DL 256QAM Power Backoff Value    dl256qam_power_backoff=${para_value_list}[3]
    set test variable    ${dl256qam_power_backoff}
    power_calculation_common_keywords.Check 4X4 MIMO enabled    dlMimoMode=${para_value_list}[2]
    ${numberOfTransmittedSsBlocks}    fetch from left    ${para_value_list}[4]    beam
    ${numberOfTransmittedSsBlocks}    convert to integer    ${numberOfTransmittedSsBlocks}
    set test variable    ${numberOfTransmittedSsBlocks}
    nps_trf_tools.log_to_console_with_time_prefix    actDl256Qam: ${actDl256Qam}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    chbw_prb: ${chbw_prb}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    ssPbchBlockPower: ${sspbch_blcok_power}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    rbAllocation: ${rbAllocation_value}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    pmax: ${pmax}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    dl256qam_power_backoff: ${dl256qam_power_backoff}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    Check 4X4 MIMO enabled: ${4x4_mimo_enabled}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    numberOfTransmittedSsBlocks: ${numberOfTransmittedSsBlocks}    level=INFO

Get Channel Bandwidth With PRB
    [Documentation]   Description: caculate PRBs from channal bandwidth
    ...               for example: for 40M, it is 106PRB
    [Arguments]    ${chbw}
    ${chbw_prb} =    run keyword if    '${chbw}' == '40MHz'    set variable    ${106}
    ...    ELSE IF    '${chbw}' == '60MHz'    set variable    ${162}
    ...    ELSE IF    '${chbw}' == '80MHz'    set variable    ${217}
    ...    ELSE IF    '${chbw}' == '100MHz'    set variable    ${273}
    ...    ELSE IF    '${chbw}' == '20MHz'    set variable    ${51}
    ...    ELSE IF    '${chbw}' == '10MHz'    set variable    ${24}
    ...    ELSE       BuiltIn.Log    Error: channel bandwidth is larger than 100M, please confirm form RRC message/SIB1    level=ERROR
    nps_trf_tools.log_to_console_with_time_prefix    Get Channel Bandwidth with PRB: ${chbw_prb}    level=INFO
    [Return]    ${chbw_prb}

Check 4X4 MIMO enabled
    [Documentation]  Description: check whether 4*4 mimo enabled
    [Arguments]    ${dlMimoMode}
    @{mimo_mode_list}    create list    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ${status}    run keyword and return status    list should contain value    ${mimo_mode_list}    ${dlMimoMode}
    ${4x4_mimo_enabled} =    set variable if    '${status}' == '${True}'    ${True}    ${False}
    set test variable    ${4x4_mimo_enabled}

Get DL 256QAM Power Backoff Value
    [Documentation]  Description: caculate intermediate value dlQam256PowerBackoff_result
    [Arguments]    ${dl256qam_power_backoff}
    ${dl256qam_power_backoff_status}    run keyword and return status    Should Contain    ${dl256qam_power_backoff}    dB
    ${dl256qam_power_backoff}    fetch from left    ${dl256qam_power_backoff}    dB
    ${dl256qam_power_backoff}    evaluate    float(${dl256qam_power_backoff})
    ${dl256qam_power_backoff}    set variable if    '${dl256qam_power_backoff_status}'=='true'
    ...    ${dl256qam_power_backoff}    ${dl256qam_power_backoff / 10}
    ${dl256qam_power_backoff} =    run keyword if    '${actDl256Qam}' == 'true'    set variable    ${dl256qam_power_backoff}
    ...    ELSE    set variable    ${0}
    [Return]    ${dl256qam_power_backoff}

#------------------------------- Analyze BIP Log ---------------------------------------------#
Remove Duplicates And Get IE Length
    [Documentation]  Description: remove duplicates in bip log
    [Arguments]   ${list}
    ${new_list}      remove duplicates      ${list}
    ${list_num}=      get length     ${new_list}
    @{new_integer_list}    create list
    FOR    ${item}    IN     @{new_list}
        ${integer_item}    convert to integer    ${item}
        append to list    ${new_integer_list}    ${integer_item}
    END
    [Return]    ${new_integer_list}   ${list_num}

Get IE Length and Value Of BIP
    [Documentation]  Description: get element value and remove duplicates in bip log with taf.ul.parser.pcap lib.
    ...                  this keyword is used to get_field_value_by_xpath, please use keyword "load_pcap_file" first.
    ...                  for more than one fields with the same name in a packet, please select get_field_value_by_xpath.
    ...                  for ${attribute_name}, "value" is hex data for "show". "show" is the origin value, for example 0x00000008.
    [Arguments]    ${pdml_list}
    ...    ${xpath}
    ...    ${filter_expression}=dldata_csirssendreq||dldata_pdcchsendreq||dldata_pdschsendreq
    ...    ${attribute_name}=show
    ${element_value}     Get Field Value By Xpath From Pdml
    ...    pdml_list=${pdml_list}    xpath=${xpath}    attribute_name=${attribute_name}    filter_expression=${filter_expression}
    ${element_value}    ${count_of_element} =    Remove Duplicates And Get IE Length
    ...    list=${element_value}
    [Return]    ${element_value}   ${count_of_element}

Get Field Value By Xpath From Pdml
    [Documentation]    Description: this keyword is used to get_field_value_by_xpath, please use keyword "load_pcap_file" first.
    ...                 for ${attribute_name}, "value" is hex data for "show". "show" is the origin value, for example 0x00000008.
    [Arguments]    ${pdml_list}    ${filter_expression}    ${xpath}    ${attribute_name}=show
    ${filtered_packets}=    pcap.filter_packets_by_expression    pdml_list=${pdml_list}    filter_expression=${filter_expression}
    ${field_value}=     pcap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=${xpath}    attribute_name=${attribute_name}
    [Return]    ${field_value}

#------------------------------- Check X2 Log ---------------------------------------------#
Check X2 PCAP
    [Documentation]  Description: check whether lots of element values are expected in x2 wireshark
    [Arguments]     ${IE_values}      ${x2_pcap}
    ...    ${luashark_path}=/home/ute/luashark_script/generated_luashark/luashark.lua
    ...    ${TSHARK_PATH}=/usr/bin/tshark
    ...    ${command_template}={tshark_path} -Y "x2ap" -r {input_file} -X lua_script:{luashark_path} -T pdml > {output_file}
    ...    ${attribute_name}=show
    ${pdml_packets}=    Convert Pcap to pdml format    file_path=${x2_pcap}
    ...    luashark_path=${luashark_path}
    ...    command_template=${command_template}
    FOR    ${item}    IN     @{IE_values}
        ${res}=    pcap.get_field_value_by_xpath    pdml_list=${pdml_packets}    xpath=@{item}[0]    attribute_name=${attribute_name}
        run keyword and continue on failure     should be equal     @{item}[1]      @{res}[0]
    END
    [Teardown]    pcap.teardown

#------------------------------- Get Expected Power  ---------------------------------------------#
Get Expected Sspbch Block Power
    [Documentation]  Description: caculate ss-PBCH-BlockPower
    ...              ss-PBCH-BlockPower = ssPbchBlockPower(dBm/RE) + ControlChannelsOffset
    [Arguments]    ${rdSyncSignalsTxMode}
    ${control_channel_offset} =    run keyword if    ${rdSyncSignalsTxMode} == ${2}    set variable    ${3}
    ...    ELSE    set variable    ${0}
    ${sspbch_blcok_power_rrc} =     evaluate    ${sspbch_blcok_power} + ${control_channel_offset}
    ${sspbch_blcok_power_rrc} =    convert to string      ${sspbch_blcok_power_rrc}
    [Return]    ${sspbch_blcok_power_rrc}
