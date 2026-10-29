*** Settings ***
Documentation     [PURPOSE]

Library          ute_wtssim                                WITH NAME    wts
Library          OperatingSystem
Library          DateTime

Library          ../python/Dev_lib.py

Resource         common_Dss_Keywords.robot

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

Reset DL Reservation
    [Arguments]                 ${alias}=default
    [Documentation]    This keyword is used to reset DL reservation.
    Log To Console    ***Start set dl resource cell reservation... with alias=${alias}
    ${command}    Set Variable    enb_dss_cell_resource_reservation_dl enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid} reset
    Dated Log New Line       ${command}
    Call Method    ${wtsObj}   execute_egate_command    cmd=${command}        alias=${alias}

Reset UL Reservation
    [Arguments]                 ${alias}=default
    [Documentation]    This keyword is used to reset UL reservation.
    Log To Console    ***Start set ul resource cell reservation... with alias=${alias}
    ${command}    Set Variable    enb_dss_cell_resource_reservation_ul enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid} reset
    Dated Log New Line       ${command}
    Call Method    ${wtsObj}    execute_egate_command    cmd=${command}      alias=${alias}

Set DL RESOURCE Cell Reservation
    [Arguments]    ${min_dss_ratio}=30    ${max_dss_ratio}=70
    [Documentation]    This keyword is used to set DL resource cell reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_dss_ratio | Yes | The minimum value of DSS share ratio |
    ...    | max_dss_ratio | Yes | The maximum value of DSS share ratio |
    ...    Example:
    ...    | Set DL RESOURCE Cell Reservation | 15 | 70 |
    common_Dss_CellSetup.Reset DL Reservation
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.DL Resource cell Reservation    subframes=${FIX_SUBFRAMES}  min_dss_ratio=${min_dss_ratio}  max_dss_ratio=${max_dss_ratio}

Set UL Resource Cell Reservation
    [Arguments]    ${min_prb_ratio}=1    ${max_prb_ratio}=52
    [Documentation]    This keyword is for ul resource cell Reservation.
    ...    | Input Parameters | Man. | Description |
    ...    | min_prb_ratio | Yes | The minimum value of PRB share ratio |
    ...    | max_prb_ratio | Yes | The maximum value of PRB share ratio |
    ...    Example:
    ...    | enb_dss_ul_cell_resource_reservation    | 2 | 1 | 30 | 70 |
    ${cmd}=    Catenate       enb_dss_ul_cell_resource_reservation enb=${Param.Context.eNBId} cell=1
    ...                              minimum_prb_share=${min_prb_ratio} maximum_prb_share=${max_prb_ratio}
    ute_wtssim.Execute Egate Command     cmd=${cmd}      alias=${alias}
    ${pattern}   Set Variable   EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${command}   Set Variable   enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data     cmd=${command}    pass_regexp=${pattern}    timeout=3minutes   alias=${alias}
    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1        alias=${alias}

DSS DL Cell Resource Allocation Phase3
    [Arguments]     ${dl_allocated_normal_subframes}=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    ...             ${dl_prb_area_allocation_list}=${empty}
    ...             ${allocation_type}=max_share
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3
    sleep   5
    # ${pattern}     Set Variable        Received DSS DL Resource Area Allocation Response
    ${pattern}     Set Variable        ${Param.Context.WtsWaitingPattern}
    ${msg}    Catenate    DSS DL Cell Resource Allocation Phase3 with allocation_start_time=immediate and
    ...                    allocation_type=${allocation_type} and
    ...                    dl_allocated_normal_subframes=${dl_allocated_normal_subframes} with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmdStr}    Catenate      enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                        tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=DL
    ...                        allocation_start_time=immediate dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                        allocation_type=${allocation_type}
    ...                        dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ${l_pattern}=   Set variable     Received DSS DL Resource Area Allocation Failure
    ${cmdStr1}=   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.Context.WtsWaitingPattern}'=='${l_pattern}'
    ...                Catenate      ${cmdStr} prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...                Catenate      ${cmdStr} prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                Catenate      ${cmdStr} prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_C_sib1br=${Param.seq.CatMinfo.prb_area_C_sib1br}
    ...                                        prb_area_D_sib1br=${Param.seq.CatMinfo.prb_area_D_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE    Set variable    ${cmdStr}
    # wts.execute egate command    cmd=${cmdStr1}     alias=${alias}
    ${output}    Call Method    ${wtsObj}  execute_egate_command_and_wait_for_data    cmd=${cmdStr1}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    log to console  \n***DSS DL Cell Resource Area Allocation completed***

DSS DL Cell Resource Allocation Phase3 failure case
    [Arguments]     ${dl_allocated_normal_subframes}=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    ...             ${dl_prb_area_allocation_list}=${empty}
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3
    sleep   5
    ${pattern}     Set Variable        DSS DL Resource Area Allocation Failure
    ${msg}    Catenate    DSS DL Cell Resource Allocation Phase3 with allocation_start_time=immediate and
    ...                    dl_allocated_normal_subframes=${dl_allocated_normal_subframes} with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmdStr}    Catenate      enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                        allocation_start_time=immediate dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                        dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ${cmdStr1}=   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                Catenate      ${cmdStr} prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE    Set variable    ${cmdStr}
    # ${cmd}    Catenate      enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    # ...                        allocation_start_time=immediate dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    # ...                        dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    # wts.execute egate command    cmd=${cmd}     alias=${alias}
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmdStr1}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    log to console  \n***DSS DL Cell Resource Area Allocation failure completed***

# enb_crm_periodic_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL periodicity=10 loopback=on
DSS DL Cell Periodic Resource Allocation Phase3
    [Arguments]     ${periodicity}=10
    ...             ${loopback}=on
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 Fast Allocation - feature 7738
    sleep   5
    ${pattern}     Set Variable        Received DSS DL Resource Area Allocation Response
    ${msg}    Catenate    DSS DL Cell Periodic Resource Allocation Phase3 with periodicity=${periodicity} and
    ...                    loopback=${loopback} and periodicity_and_load_indication=on and
    ...                    periodicity_messages_logged=500 with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_resource_allocation enb=${Param.Context.eNBId} cell=1
    ...                        tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                        periodicity=${periodicity}
    ...                        loopback=${loopback}
    ...                        periodicity_and_load_indication=on
    ...                        periodicity_messages_logged=500
    # wts.execute egate command    cmd=${cmd}     alias=${alias}
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    log to console  \n***DSS DL Cell Periodic Resource Area Allocation completed***

DSS UL Cell Periodic Resource Allocation Phase3
    [Arguments]     ${periodicity}=30
    ...             ${loopback}=on
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 Fast Allocation - feature 7738 for UL
    sleep   5
    #${pattern}      Set Variable        Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber
    #blufant en tronquant le patern ca passe !!
    ${pattern}=      Set Variable        Response SequenceNumber\=
    ${msg}    Catenate    DSS UL Cell Periodic Resource Allocation Phase3 UL with periodicity=${periodicity} and
    ...                    loopback=${loopback} and periodicity_and_load_indication=on and
    ...                    periodicity_messages_logged=500 with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_resource_allocation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                        tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=UL
    ...                        periodicity=${periodicity}
    ...                        loopback=${loopback}
    ...                        periodicity_and_load_indication=on
    ...                        periodicity_messages_logged=500
    # wts.execute egate command    cmd=${cmd}     alias=${alias}
    # ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    # ...    pass_regexp=${pattern}    timeout=16     alias=${alias}
    # ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True

    ${output}      wts.execute egate command          cmd=${cmd}    alias=${alias}
    #2 following lines are not working explaining usage of Run Keyword And Continue On Failure KW
    # timer set to 500s to let time to see somme result as logs are all 500ms
    # ${output}      wtsemu.read_wtsemu_output_until_re    ${pattern}    500      # Dated Log New Line      ${output}        #Debug aeffacer

#FTS ${output}      Run Keyword And Continue On Failure       wtsemu.read_wtsemu_output_until_re    ${pattern}    500
#FTS preconfiguration not needed the Get Lines Matching Regexp issue is on parttern size
#FTS wtsemu.Configure    file=${tl.core.dir_path}/${tl.core.cfg_filename}
    ${output}      wtsemu.read_wtsemu_output_until_re    ${pattern}    500
    ${output}      String.Get Lines Matching Regexp          ${output}    ${pattern}   partial_match=${TRUE}
    Dated Log New Line      ${output}        #Debug aeffacer
    Should Not Be Empty     ${output}

    Log To Console    \n${output}
    log to console  \n***DSS UL Cell Periodic Resource Area Allocation completed***

DSS UL Cell Resource Allocation Phase3
    # [Arguments]                 ${ULNbrOfPrb}=0x00000023     ${msg1FrequencyStart}=4    ${allocation_start_time}=immediate   ${alias}=default
    [Arguments]                 ${prb_area_list}=4,35       ${allocation_start_time}=immediate    ${allocation_type}=max_share    ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3
    sleep   5
    # ${ULNbrOfPrb_decimal}              toDecimalStr     ${ULNbrOfPrb}
    # ${msg1FrequencyStart_decimal}       toDecimalStr     ${msg1FrequencyStart}
    ${pattern}     Set Variable        Received EN DSS UL Subcarrier Resource Allocation Response
    ${msg}    Catenate     DSS UL Cell Resource Allocation with ul_allocated_prb_list=${prb_area_list}
    Dated Log New Line     ${msg}
    ${cmd}    Catenate    enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                     tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=UL
    ...                     allocation_start_time=${allocation_start_time} ul_allocated_prb_list=${prb_area_list}
    ...                     allocation_type=${allocation_type}
    # wts.execute egate command    cmd=${cmd}   alias=${alias}
    ${output}    Call Method    ${wtsObj}  execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    log to console  \n***DSS UL Cell Resource Allocation completed***

Set enb dss cell param for CatM
   [Arguments]              ${testParam}=Param     ${alias}=default
   [Documentation]    This keyword is used for DSS Phase3 in case of CatM
    BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid} dl_crm_sf_capabilities=lte_catm
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2

Set enb dss dl resource cell reservation for CatM
   [Arguments]              ${testParam}=Param     ${alias}=default
   [Documentation]    This keyword is used for DSS Phase3 in case of CatM
   BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
   ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=${Param.Context.eNBId_cellid} enb=${Param.Context.eNBId}
    ...                           repeated_mpbch=${Param.seq.CatMinfo.repeated_mpbch}
    ...                           start_symbol=${Param.seq.CatMinfo.start_symbol}
    ...                           catm_dl_data_index=${Param.seq.CatMinfo.catm_dl_data_index}
    ...                           paging_starting_index=${Param.seq.CatMinfo.paging_starting_index}
    ...                           num_of_catm_paging_records=${Param.seq.CatMinfo.num_of_catm_paging_records}
    ...                           sib1br_starting_index=${Param.seq.CatMinfo.sib1br_starting_index}
    ...                           num_of_catm_sib1br_records=${Param.seq.CatMinfo.num_of_catm_sib1br_records}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}
    Sleep   2

Set enb dss cell param for superfast_reduction_excess_msg
   [Arguments]              ${testParam}=Param     ${alias}=default    ${wtsObj}=wts
   [Documentation]    This keyword is used for DSS Phase3 in case of superfast_reduction_excess_msg
    BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
    ${cmd}    Catenate      enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                        dl_crm_sf_capabilities=superfast_reduction_excess_msg+gbr_support
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2

Set enb dss cell param for gbr_support
   [Arguments]              ${testParam}=Param     ${alias}=default    ${wtsObj}=wts
   [Documentation]    This keyword is used for DSS Phase3 in case of gbr_support
    BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                            dl_crm_sf_capabilities=gbr_support
    Dated Log New Line       ${cmd}
    # wts.execute egate command    cmd=${cmd}    alias=${alias}
    Call Method    ${wtsObj}   execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2

Set enb dss cell param for actLteNrDssFastAlloc
   [Arguments]              ${testParam}=Param     ${alias}=default    ${wtsObj}=wts
   [Documentation]    This keyword is used for DSS Phase3 in case of actLteNrDssFastAlloc
    BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
    ${cmd}    Catenate      enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                        ul_superfast_load_meas_timer=10 dl_superfast_load_meas_timer=10
    Dated Log New Line       ${cmd}
    # wts.execute egate command    cmd=${cmd}    alias=${alias}
    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}    alias=${alias}
    Sleep   2

# cmd used for DSS Phase3
#
# sim_trace enb=2 protocol=xp,xpu on
# enb_x2_link_up enb=2 target=1
# enb_xp_param id=2 ignore_xp=off xp_listening_socket=on
# enb_xp_param id=2 xp_peers=1
# enb_xp_link_up enb=2 target=1
# enb_dss_param id=2 feature_flag=on message_sets=DMS3
# enb_cell_param enb=2 id=1 lte_nr_dss_mode=DSS_PHASE_3  antenna_ports_num=2
# enb_cell_dss_feature enb=2 id=1 nr_dl_peak_rate_increase=on
# enb_dss_configure_partnership enb=2 cell=1 dss_peer=1:1
# enb_dss_establish_partnership enb=2 cell=1 tgt_enb=1 tgt_cell=1

# enb_dss_dl_cell_resource_reservation cell=1 enb=2 reset
# enb_dss_ul_cell_resource_reservation cell=1 enb=2 reset

# enb_dss_dl_resource_cell_reservation cell=1 enb=2 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none

# enb_dss_dl_resource_cell_reservation cell=1 enb=2
#               reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
# enb_dss_dl_resource_cell_reservation cell=1 enb=2 min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
# enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL
# enb_dss_ul_cell_resource_reservation enb=2 cell=1 minimum_prb_share=30 maximum_prb_share=70
# enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL
# enb_crm_status enb=2 cell=1

# DL allocation
# enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL allocation_start_time=immediate
#                dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
#                dl_prb_area_allocation_list=0:0,28+1:0,0+2:0,52+3:0,52+4:0,52+5:0,28+6:0,52+7:0,52+8:0,52+9:0,52+10:0,28+11:0,52+12:0,52+13:0,
#      52+14:0,52+15:0,28+16:0,52+17:0,52+18:0,52+19:0,52+20:0,28+21:0,0+22:0,52+23:0,52+24:0,52+25:0,28+26:0,52+27:0,52+28:0,52+29:0,52+30:0,
#      28+31:0,52+32:0,52+33:0,52+34:0,52+35:0,28+36:0,52+37:0,52+38:0,52+39:0,52+40:0,28+41:0,0+42:0,52+43:0,52+44:0,52+45:0,28+46:0,52+47:0,
#      52+48:0,52+49:0,52+50:0,28+51:0,52+52:0,52+53:0,52+54:0,52+55:0,28+56:0,52+57:0,52+58:0,52+59:0,52+60:0,28+61:0,0+62:0,52+63:0,52+64:0,
#      52+65:0,28+66:0,52+67:0,52+68:0,52+69:0,52+70:0,28+71:0,52+72:0,52+73:0,52+74:0,52+75:0,28+76:0,52+77:0,52+78:0,52+79:0,52

# UL Allocation
# enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL allocation_start_time=immediate ul_allocated_prb_list=1,35


DSS_CRM_Cell_Setup_Phase3
#     [Arguments]                 ${testParam}=Param    ${alias}=default
     [Arguments]                 ${alias}=default    ${wtsObj}=wts

    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Param}
    return from keyword If     '${status}'=='FAIL'     ${message}

    ${msg}=    Catenate     ***DSS ${Param.Context.DSS_Phase} ${consTraceColorBgYellow}${consTraceColorBlack}CRM CellSetup
    ...                       gNB ${defColor}${consTraceColorBgBlue}CellId=${Param.Context.gNBId_cellid}${defColor}
    ...                       BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console  \n${msg}

    Call Method    ${wtsObj}    execute_egate_command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3
    ...                                                  alias=${alias}
    Sleep   2
    ${antenna_ports_num}   run Keyword if   '${Param.Context.nrCellType}'=='4DL4UL'
    ...                       set variable    4
    ...           ELSE        set variable    2
    ${cmd}    Catenate    enb_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                  lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=${antenna_ports_num}
    Call Method    ${wtsObj}    execute_egate_command     cmd=${cmd}    alias=${alias}
    Dated Log New Line       ${cmd}
    Sleep   2
    Call Method    ${wtsObj}    execute_egate_command
    ...                         cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid} nr_dl_peak_rate_increase=on
    ...                                                  alias=${alias}
    Sleep   2
    ${superfast_allocation}   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    set variable    on
    ...           ELSE        set variable    off
    ${cmd}=  Catenate  enb_cell_dss_feature enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid} superfast_allocation=${superfast_allocation}
    Call Method    ${wtsObj}    execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}     Catenate     enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                        dl_resource_sharing_algo=${dl_resource_sharing_algo}
    Call Method    ${wtsObj}    execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2
    # for CatM
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'    Set enb dss cell param for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for CatM

    # for superfast_reduction_excess_msg
    run Keyword if   '${Param.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}'=='exc_msg_reduction_static'
    ...                                                                       Set enb dss cell param for superfast_reduction_excess_msg
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    ...                                                                                      wtsObj=${wtsObj}
    # end for superfast_reduction_excess_msg

    # for superfast_allocation
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    Set enb dss cell param for actLteNrDssFastAlloc
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    ...                                                                                      wtsObj=${wtsObj}
    # end for superfast_allocation

    ${cmd}     Catenate    enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                  dss_peer=${Param.Context.gNBId}:${Param.Context.gNBId_cellid}
    Call Method    ${wtsObj}    execute_egate_command   cmd=${cmd}    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...         tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr}
    ...         assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70
    ...         assigned_ul_minimum_share_to_nr=${Param.seq.assigned_ul_minimum_share_to_nr}
    ...         assigned_ul_maximum_share_to_nr=${Param.seq.assigned_ul_maximum_share_to_nr}

    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}      alias=${alias}

    Call Method    ${wtsObj}    execute_egate_command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    sleep    30
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ${output}    Call Method    ${wtsObj}    execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${prb_area_list}=  run Keyword if  '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...   ELSE     run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...                                     ${Param.seq.CatMinfo.prb_area_reservation_list_2}
    ...   ELSE    Set variable        0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${prb_area_reservation_list}=        run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                             set variable      ${prb_area_list}
    ...            ELSE             set variable      0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=${prb_area_reservation_list}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    # CatM case
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'   Set enb dss dl resource cell reservation for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end CatM case

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=${Param.Context.eNBId_cellid}
    ...                                                        enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId}
    ...                                                      tgt_cell=${Param.Context.gNBId_cellid} dir=DL
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=${Param.Context.eNBId_cellid} enb=${Param.Context.eNBId}
    ...                                                        minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=UL
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1
    ...                                                                                  alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    # CASE WO PRB BLANKING
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    # ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    # ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    # ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    # ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    # ...    ,52

    # CSAMSON : TO IMPROVE LATER ..... START PRB = 4 IN CASE OF PRB BLE = 3prb
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:4,52+1:4,0+2:4,52+3:4,52+4:4,52+5:4,52+6:4,52+7:4,52+8:4,52+9:4,52+10:4,52+11:4,52+12:4,52+13:4,52+14:4,52+15:4,52+16:4,52+17:4,52+
    # ...    18:4,52+19:4,52+20:4,52+21:4,0+22:4,52+23:4,52+24:4,52+25:4,52+26:4,52+27:4,52+52:4,52+29:4,52+30:4,52+31:4,52+32:4,52+33:4,52+34:4,52+
    # ...    35:4,52+36:4,52+37:4,52+38:4,52+39:4,52+40:4,52+41:4,0+42:4,52+43:4,52+44:4,52+45:4,52+46:4,52+47:4,52+48:4,52+49:4,52+50:4,52+51:4,52+
    # ...    52:4,52+53:4,52+54:4,52+55:4,52+56:4,52+57:4,52+58:4,52+59:4,52+60:4,52+61:4,0+62:4,52+63:4,52+64:4,52+65:4,52+66:4,52+67:4,52+68:4,52+
    # ...    69:4,52+70:4,52+71:4,52+72:4,52+73:4,52+74:4,52+75:4,52+76:4,52+77:4,52+78:4,52+79:4,52

    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:3,48+1:3,0+2:3,48+3:3,48+4:3,48+5:3,48+6:3,48+7:3,48+8:3,48+9:3,48+10:3,48+11:3,48+12:3,48+13:3,48+14:3,48+15:3,48+16:3,48+17:3,48+
    # ...    18:3,48+19:3,48+20:3,48+21:3,0+22:3,48+23:3,48+24:3,48+25:3,48+26:3,48+27:3,48+52:3,48+29:3,48+30:3,48+31:3,48+32:3,48+33:3,48+34:3,48+
    # ...    35:3,48+36:3,48+37:3,48+38:3,48+39:3,48+40:3,48+41:3,0+42:3,48+43:3,48+44:3,48+45:3,48+46:3,48+47:3,48+48:3,48+49:3,48+50:3,48+51:3,48+
    # ...    52:3,48+53:3,48+54:3,48+55:3,48+56:3,48+57:3,48+58:3,48+59:3,48+60:3,48+61:3,0+62:3,48+63:3,48+64:3,48+65:3,48+66:3,48+67:3,48+68:3,48+
    # ...    69:3,48+70:3,48+71:3,48+72:3,48+73:3,48+74:3,48+75:3,48+76:3,48+77:3,48+78:3,48+79:3,48

    # 3 PRB blanked Low Edge
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,49+1:0,0+2:0,49+3:0,49+4:0,49+5:0,49+6:0,49+7:0,49+8:0,49+9:0,49+10:0,49+11:0,
    # ...    52+12:0,49+13:0,49+14:0,49+15:0,49+16:0,49+17:0,49+18:0,49+19:0,49+20:0,49+21:0,0+22:0,49+23:0,49+24:0,49+25:0,49+26:0,49+27:0,49+52:0,
    # ...    52+29:0,49+30:0,49+31:0,49+32:0,49+33:0,49+34:0,49+35:0,49+36:0,49+37:0,49+38:0,49+39:0,49+40:0,49+41:0,0+42:0,49+43:0,49+44:0,49+45:0,
    # ...    52+46:0,49+47:0,49+48:0,49+49:0,49+50:0,49+51:0,49+52:0,49+53:0,49+54:0,49+55:0,49+56:0,49+57:0,49+58:0,49+59:0,49+60:0,49+61:0,0+62:0,
    # ...    52+63:0,49+64:0,49+65:0,49+66:0,49+67:0,49+68:0,49+69:0,49+70:0,49+71:0,49+72:0,49+73:0,49+74:0,49+75:0,49+76:0,49+77:0,49+
    # ...    78:0,49+79:0,52

    # CASE 10MHz/15MHz/20MHz w/o PRB BLANKING
    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...    ELSE    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    ...    10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # to manage DL PRB BLANKING case
    ${nbrOfBlankedPRBsHighEdgeDL}   set variable   ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL}   set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    ${max_prb}      run Keyword if     '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'      set variable    52
    ...    ELSE IF                     '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'      set variable    79
    ...    ELSE                                                                          set variable    106
    ${dl_prb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${max_prb}-${nbrOfBlankedPRBsHighEdgeDL}-${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    ${max_prb}
    ${msg}=   Catenate    max_dl_prb=${dl_prb} for dl_prb_area_allocation_list with
    ...                   actPRBBlanking=${Param.scfFile.nrcell.actPRBBlanking}
    ...                   nbrOfBlankedPRBsHighEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ...                   nbrOfBlankedPRBsLowEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    dated Log     ----------> ${msg}
    ${DL_StartPrb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    0
    ${dl_prb_area_allocation_list}=
    ...   Catenate    SEPARATOR=   0:${DL_StartPrb},${dl_prb}+1:${DL_StartPrb},${dl_prb}+2:${DL_StartPrb},${dl_prb}+3:${DL_StartPrb},${dl_prb}+
    ...     4:${DL_StartPrb},${dl_prb}+5:${DL_StartPrb},${dl_prb}+6:${DL_StartPrb},${dl_prb}+7:${DL_StartPrb},${dl_prb}+
    ...     8:${DL_StartPrb},${dl_prb}+9:${DL_StartPrb},${dl_prb}+10:${DL_StartPrb},${dl_prb}+11:${DL_StartPrb},${dl_prb}+
    ...     12:${DL_StartPrb},${dl_prb}+13:${DL_StartPrb},${dl_prb}+14:${DL_StartPrb},${dl_prb}+15:${DL_StartPrb},${dl_prb}+
    ...     16:${DL_StartPrb},${dl_prb}+17:${DL_StartPrb},${dl_prb}+18:${DL_StartPrb},${dl_prb}+19:${DL_StartPrb},${dl_prb}+
    ...     20:${DL_StartPrb},${dl_prb}+21:${DL_StartPrb},${dl_prb}+22:${DL_StartPrb},${dl_prb}+23:${DL_StartPrb},${dl_prb}+
    ...     24:${DL_StartPrb},${dl_prb}+25:${DL_StartPrb},${dl_prb}+26:${DL_StartPrb},${dl_prb}+27:${DL_StartPrb},${dl_prb}+
    ...     28:${DL_StartPrb},${dl_prb}+29:${DL_StartPrb},${dl_prb}+30:${DL_StartPrb},${dl_prb}+31:${DL_StartPrb},${dl_prb}+
    ...     32:${DL_StartPrb},${dl_prb}+33:${DL_StartPrb},${dl_prb}+34:${DL_StartPrb},${dl_prb}+35:${DL_StartPrb},${dl_prb}+
    ...     36:${DL_StartPrb},${dl_prb}+37:${DL_StartPrb},${dl_prb}+38:${DL_StartPrb},${dl_prb}+39:${DL_StartPrb},${dl_prb}+
    ...     40:${DL_StartPrb},${dl_prb}+41:${DL_StartPrb},${dl_prb}+42:${DL_StartPrb},${dl_prb}+43:${DL_StartPrb},${dl_prb}+
    ...     44:${DL_StartPrb},${dl_prb}+45:${DL_StartPrb},${dl_prb}+46:${DL_StartPrb},${dl_prb}+47:${DL_StartPrb},${dl_prb}+
    ...     48:${DL_StartPrb},${dl_prb}+49:${DL_StartPrb},${dl_prb}+50:${DL_StartPrb},${dl_prb}+51:${DL_StartPrb},${dl_prb}+
    ...     52:${DL_StartPrb},${dl_prb}+53:${DL_StartPrb},${dl_prb}+54:${DL_StartPrb},${dl_prb}+55:${DL_StartPrb},${dl_prb}+
    ...     56:${DL_StartPrb},${dl_prb}+57:${DL_StartPrb},${dl_prb}+58:${DL_StartPrb},${dl_prb}+59:${DL_StartPrb},${dl_prb}+
    ...     60:${DL_StartPrb},${dl_prb}+61:${DL_StartPrb},${dl_prb}+62:${DL_StartPrb},${dl_prb}+63:${DL_StartPrb},${dl_prb}+
    ...     64:${DL_StartPrb},${dl_prb}+65:${DL_StartPrb},${dl_prb}+66:${DL_StartPrb},${dl_prb}+67:${DL_StartPrb},${dl_prb}+
    ...     68:${DL_StartPrb},${dl_prb}+69:${DL_StartPrb},${dl_prb}+70:${DL_StartPrb},${dl_prb}+71:${DL_StartPrb},${dl_prb}+
    ...     72:${DL_StartPrb},${dl_prb}+73:${DL_StartPrb},${dl_prb}+74:${DL_StartPrb},${dl_prb}+75:${DL_StartPrb},${dl_prb}+
    ...     76:${DL_StartPrb},${dl_prb}+77:${DL_StartPrb},${dl_prb}+78:${DL_StartPrb},${dl_prb}+79:${DL_StartPrb},${dl_prb}

    dated Log     ----------> dl_prb_area_allocation_list = ${dl_prb_area_allocation_list}

    # 20MHz case
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    # ...    10:0,106+11:0,52+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    # ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    # ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    # ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    # ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    # ${dl_pattern}=      Catenate         0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    # ${dl_pattern}=      Catenate         0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         allocation_type=${Param.seq.ul_allocation_type}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${nbrOfBlankedPRBsLowEdgeUL}=     set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}
    ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    # IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0}
    #      ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    # ELSE
    #      ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    #      ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    # END
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
        ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,4|${prb_nr_pusch_area}|47,4
        ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,4|${prb_nr_pusch_area}|74,4
        ...  ELSE                                                                           set variable   0,4|${prb_nr_pusch_area}|101,4
    ELSE
        ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
        ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
        ...                                                                          106
        ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${5}
        ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
        ${prb_area_list}=    set variable   ${prb_nr_pucch_low_area_start},4|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},4
    END
    ${allocation_type}=    set variable     ${Param.seq.ul_allocation_type}
    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3         prb_area_list=${prb_area_list}
    ...                                                                 allocation_type=${allocation_type}
    ...                                                                 alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed***

    ${cmd}    Catenate     enb_crm_status enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}
    ...                                                                                  alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

DSS_CRM_Cell_Setup_Phase3_complete
#     [Arguments]                 ${testParam}=Param    ${alias}=default
     [Arguments]                 ${alias}=default    ${wtsObj}=wts

    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Param}
    return from keyword If     '${status}'=='FAIL'     ${message}

    ${msg}=    Catenate     ***DSS ${Param.Context.DSS_Phase} ${consTraceColorBgYellow}${consTraceColorBlack}CRM CellSetup
    ...                       gNB ${defColor}${consTraceColorBgBlue}CellId=${Param.Context.gNBId_cellid}${defColor}
    ...                       BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console  \n${msg}

    ${cmd}     Catenate    enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                  dss_peer=${Param.Context.gNBId}:${Param.Context.gNBId_cellid}
    Call Method    ${wtsObj}    execute_egate_command   cmd=${cmd}    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...         tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr} assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}      alias=${alias}

    Call Method    ${wtsObj}    execute_egate_command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    sleep    30
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ${output}    Call Method    ${wtsObj}    execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    # CASE WO PRB BLANKING
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    # ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    # ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    # ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    # ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    # ...    ,52

    # CSAMSON : TO IMPROVE LATER ..... START PRB = 4 IN CASE OF PRB BLE = 3prb
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:4,52+1:4,0+2:4,52+3:4,52+4:4,52+5:4,52+6:4,52+7:4,52+8:4,52+9:4,52+10:4,52+11:4,52+12:4,52+13:4,52+14:4,52+15:4,52+16:4,52+17:4,52+
    # ...    18:4,52+19:4,52+20:4,52+21:4,0+22:4,52+23:4,52+24:4,52+25:4,52+26:4,52+27:4,52+52:4,52+29:4,52+30:4,52+31:4,52+32:4,52+33:4,52+34:4,52+
    # ...    35:4,52+36:4,52+37:4,52+38:4,52+39:4,52+40:4,52+41:4,0+42:4,52+43:4,52+44:4,52+45:4,52+46:4,52+47:4,52+48:4,52+49:4,52+50:4,52+51:4,52+
    # ...    52:4,52+53:4,52+54:4,52+55:4,52+56:4,52+57:4,52+58:4,52+59:4,52+60:4,52+61:4,0+62:4,52+63:4,52+64:4,52+65:4,52+66:4,52+67:4,52+68:4,52+
    # ...    69:4,52+70:4,52+71:4,52+72:4,52+73:4,52+74:4,52+75:4,52+76:4,52+77:4,52+78:4,52+79:4,52

    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:3,48+1:3,0+2:3,48+3:3,48+4:3,48+5:3,48+6:3,48+7:3,48+8:3,48+9:3,48+10:3,48+11:3,48+12:3,48+13:3,48+14:3,48+15:3,48+16:3,48+17:3,48+
    # ...    18:3,48+19:3,48+20:3,48+21:3,0+22:3,48+23:3,48+24:3,48+25:3,48+26:3,48+27:3,48+52:3,48+29:3,48+30:3,48+31:3,48+32:3,48+33:3,48+34:3,48+
    # ...    35:3,48+36:3,48+37:3,48+38:3,48+39:3,48+40:3,48+41:3,0+42:3,48+43:3,48+44:3,48+45:3,48+46:3,48+47:3,48+48:3,48+49:3,48+50:3,48+51:3,48+
    # ...    52:3,48+53:3,48+54:3,48+55:3,48+56:3,48+57:3,48+58:3,48+59:3,48+60:3,48+61:3,0+62:3,48+63:3,48+64:3,48+65:3,48+66:3,48+67:3,48+68:3,48+
    # ...    69:3,48+70:3,48+71:3,48+72:3,48+73:3,48+74:3,48+75:3,48+76:3,48+77:3,48+78:3,48+79:3,48

    # 3 PRB blanked Low Edge
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,49+1:0,0+2:0,49+3:0,49+4:0,49+5:0,49+6:0,49+7:0,49+8:0,49+9:0,49+10:0,49+11:0,
    # ...    52+12:0,49+13:0,49+14:0,49+15:0,49+16:0,49+17:0,49+18:0,49+19:0,49+20:0,49+21:0,0+22:0,49+23:0,49+24:0,49+25:0,49+26:0,49+27:0,49+52:0,
    # ...    52+29:0,49+30:0,49+31:0,49+32:0,49+33:0,49+34:0,49+35:0,49+36:0,49+37:0,49+38:0,49+39:0,49+40:0,49+41:0,0+42:0,49+43:0,49+44:0,49+45:0,
    # ...    52+46:0,49+47:0,49+48:0,49+49:0,49+50:0,49+51:0,49+52:0,49+53:0,49+54:0,49+55:0,49+56:0,49+57:0,49+58:0,49+59:0,49+60:0,49+61:0,0+62:0,
    # ...    52+63:0,49+64:0,49+65:0,49+66:0,49+67:0,49+68:0,49+69:0,49+70:0,49+71:0,49+72:0,49+73:0,49+74:0,49+75:0,49+76:0,49+77:0,49+
    # ...    78:0,49+79:0,52

    # CASE 10MHz/15MHz/20MHz w/o PRB BLANKING
    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...    ELSE    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    ...    10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # to manage DL PRB BLANKING case
    ${nbrOfBlankedPRBsHighEdgeDL}   set variable   ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL}   set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    ${max_prb}      run Keyword if     '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'      set variable    52
    ...    ELSE IF                     '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'      set variable    79
    ...    ELSE                                                                          set variable    106
    ${dl_prb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${max_prb}-${nbrOfBlankedPRBsHighEdgeDL}-${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    ${max_prb}
    ${msg}=   Catenate    max_dl_prb=${dl_prb} for dl_prb_area_allocation_list with
    ...                   actPRBBlanking=${Param.scfFile.nrcell.actPRBBlanking}
    ...                   nbrOfBlankedPRBsHighEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ...                   nbrOfBlankedPRBsLowEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    dated Log     ----------> ${msg}
    ${DL_StartPrb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    0
    ${dl_prb_area_allocation_list}=
    ...   Catenate    SEPARATOR=   0:${DL_StartPrb},${dl_prb}+1:${DL_StartPrb},${dl_prb}+2:${DL_StartPrb},${dl_prb}+3:${DL_StartPrb},${dl_prb}+
    ...     4:${DL_StartPrb},${dl_prb}+5:${DL_StartPrb},${dl_prb}+6:${DL_StartPrb},${dl_prb}+7:${DL_StartPrb},${dl_prb}+
    ...     8:${DL_StartPrb},${dl_prb}+9:${DL_StartPrb},${dl_prb}+10:${DL_StartPrb},${dl_prb}+11:${DL_StartPrb},${dl_prb}+
    ...     12:${DL_StartPrb},${dl_prb}+13:${DL_StartPrb},${dl_prb}+14:${DL_StartPrb},${dl_prb}+15:${DL_StartPrb},${dl_prb}+
    ...     16:${DL_StartPrb},${dl_prb}+17:${DL_StartPrb},${dl_prb}+18:${DL_StartPrb},${dl_prb}+19:${DL_StartPrb},${dl_prb}+
    ...     20:${DL_StartPrb},${dl_prb}+21:${DL_StartPrb},${dl_prb}+22:${DL_StartPrb},${dl_prb}+23:${DL_StartPrb},${dl_prb}+
    ...     24:${DL_StartPrb},${dl_prb}+25:${DL_StartPrb},${dl_prb}+26:${DL_StartPrb},${dl_prb}+27:${DL_StartPrb},${dl_prb}+
    ...     28:${DL_StartPrb},${dl_prb}+29:${DL_StartPrb},${dl_prb}+30:${DL_StartPrb},${dl_prb}+31:${DL_StartPrb},${dl_prb}+
    ...     32:${DL_StartPrb},${dl_prb}+33:${DL_StartPrb},${dl_prb}+34:${DL_StartPrb},${dl_prb}+35:${DL_StartPrb},${dl_prb}+
    ...     36:${DL_StartPrb},${dl_prb}+37:${DL_StartPrb},${dl_prb}+38:${DL_StartPrb},${dl_prb}+39:${DL_StartPrb},${dl_prb}+
    ...     40:${DL_StartPrb},${dl_prb}+41:${DL_StartPrb},${dl_prb}+42:${DL_StartPrb},${dl_prb}+43:${DL_StartPrb},${dl_prb}+
    ...     44:${DL_StartPrb},${dl_prb}+45:${DL_StartPrb},${dl_prb}+46:${DL_StartPrb},${dl_prb}+47:${DL_StartPrb},${dl_prb}+
    ...     48:${DL_StartPrb},${dl_prb}+49:${DL_StartPrb},${dl_prb}+50:${DL_StartPrb},${dl_prb}+51:${DL_StartPrb},${dl_prb}+
    ...     52:${DL_StartPrb},${dl_prb}+53:${DL_StartPrb},${dl_prb}+54:${DL_StartPrb},${dl_prb}+55:${DL_StartPrb},${dl_prb}+
    ...     56:${DL_StartPrb},${dl_prb}+57:${DL_StartPrb},${dl_prb}+58:${DL_StartPrb},${dl_prb}+59:${DL_StartPrb},${dl_prb}+
    ...     60:${DL_StartPrb},${dl_prb}+61:${DL_StartPrb},${dl_prb}+62:${DL_StartPrb},${dl_prb}+63:${DL_StartPrb},${dl_prb}+
    ...     64:${DL_StartPrb},${dl_prb}+65:${DL_StartPrb},${dl_prb}+66:${DL_StartPrb},${dl_prb}+67:${DL_StartPrb},${dl_prb}+
    ...     68:${DL_StartPrb},${dl_prb}+69:${DL_StartPrb},${dl_prb}+70:${DL_StartPrb},${dl_prb}+71:${DL_StartPrb},${dl_prb}+
    ...     72:${DL_StartPrb},${dl_prb}+73:${DL_StartPrb},${dl_prb}+74:${DL_StartPrb},${dl_prb}+75:${DL_StartPrb},${dl_prb}+
    ...     76:${DL_StartPrb},${dl_prb}+77:${DL_StartPrb},${dl_prb}+78:${DL_StartPrb},${dl_prb}+79:${DL_StartPrb},${dl_prb}

    dated Log     ----------> dl_prb_area_allocation_list = ${dl_prb_area_allocation_list}

    # 20MHz case
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    # ...    10:0,106+11:0,52+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    # ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    # ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    # ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    # ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    # ${dl_pattern}=      Catenate         0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    # ${dl_pattern}=      Catenate         0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${nbrOfBlankedPRBsLowEdgeUL}=     set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}
    ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    # IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0}
    #      ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    # ELSE
    #      ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    #      ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    # END
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
        ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,5|${prb_nr_pusch_area}|47,5
        ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,5|${prb_nr_pusch_area}|74,5
        ...  ELSE                                                                           set variable   0,5|${prb_nr_pusch_area}|101,5
    ELSE
        ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
        ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
        ...                                                                          106
        ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${5}
        ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
        ${prb_area_list}=    set variable   ${prb_nr_pucch_low_area_start},5|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},5
    END

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3         prb_area_list=${prb_area_list}
    ...                                                                 alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed***


DSS CRM enb dss configure partnership
     [Arguments]                 ${alias}=default    ${wtsObj}=wts

    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Param}
    return from keyword If     '${status}'=='FAIL'     ${message}

    ${msg}=    Catenate     ***DSS ${Param.Context.DSS_Phase} ${consTraceColorBgYellow}${consTraceColorBlack}CRM enb dss configure partnership
    ...                     gNB ${defColor}${consTraceColorBgBlue}CellId=${Param.Context.gNBId_cellid}${defColor}
    ...                     BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${msg}

    Call Method    ${wtsObj}    execute_egate_command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3
    ...                                                  alias=${alias}
    Sleep   2
    ${antenna_ports_num}   run Keyword if   '${Param.Context.nrCellType}'=='4DL4UL'
    ...                       set variable    4
    ...           ELSE        set variable    2
    ${cmd}    Catenate    enb_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                  lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=${antenna_ports_num}
    Call Method    ${wtsObj}    execute_egate_command     cmd=${cmd}    alias=${alias}
    Dated Log New Line       ${cmd}
    Sleep   2
    Call Method    ${wtsObj}    execute_egate_command
    ...                         cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid} nr_dl_peak_rate_increase=on
    ...                                                  alias=${alias}
    Sleep   2
    ${superfast_allocation}   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    set variable    on
    ...           ELSE        set variable    off
    ${cmd}=  Catenate  enb_cell_dss_feature enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid} superfast_allocation=${superfast_allocation}
    Call Method    ${wtsObj}    execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}     Catenate     enb_dss_cell_param enb=${Param.Context.eNBId} id=${Param.Context.eNBId_cellid}
    ...                                        dl_resource_sharing_algo=${dl_resource_sharing_algo}
    Call Method    ${wtsObj}    execute_egate_command    cmd=${cmd}    alias=${alias}
    Sleep   2
    # for CatM
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'    Set enb dss cell param for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for CatM

    # for superfast_reduction_excess_msg
    run Keyword if   '${Param.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}'=='exc_msg_reduction_static'
    ...                                                                       Set enb dss cell param for superfast_reduction_excess_msg
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_reduction_excess_msg

    # for superfast_allocation
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    Set enb dss cell param for actLteNrDssFastAlloc
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_allocation

    ${cmd}     Catenate    enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                  dss_peer=${Param.Context.gNBId}:${Param.Context.gNBId_cellid}
    Call Method    ${wtsObj}    execute_egate_command   cmd=${cmd}    alias=${alias}
    sleep   2

DSS_CRM_Cell_Setup_Phase3_completation
     [Arguments]                 ${alias}=default    ${wtsObj}=wts

    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Param}
    return from keyword If     '${status}'=='FAIL'     ${message}

    ${msg}=    Catenate     ***DSS ${Param.Context.DSS_Phase} ${consTraceColorBgYellow}${consTraceColorBlack}CRM CellSetup
    ...                       gNB ${defColor}${consTraceColorBgBlue}CellId=${Param.Context.gNBId_cellid}${defColor}
    ...                       BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console  \n${msg}

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...         tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr} assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}    execute_egate_command      cmd=${cmd}      alias=${alias}

    Call Method    ${wtsObj}    execute_egate_command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    sleep    30
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid}
    ${output}    Call Method    ${wtsObj}    execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${prb_area_list}=  run Keyword if  '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...   ELSE     run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...                                     ${Param.seq.CatMinfo.prb_area_reservation_list_2}
    ...   ELSE    Set variable        0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${prb_area_reservation_list}=        run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                             set variable      ${prb_area_list}
    ...            ELSE             set variable      0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=${prb_area_reservation_list}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    # CatM case
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'   Set enb dss dl resource cell reservation for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end CatM case

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=${Param.Context.eNBId_cellid}
    ...                                                        enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId}
    ...                                                      tgt_cell=${Param.Context.gNBId_cellid} dir=DL
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=${Param.Context.eNBId_cellid} enb=${Param.Context.eNBId}
    ...                                                        minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                                                      tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=UL
    Dated Log New Line       ${cmd}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1
    ...                                                                                  alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    # CASE WO PRB BLANKING
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    # ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    # ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    # ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    # ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    # ...    ,52

    # CSAMSON : TO IMPROVE LATER ..... START PRB = 4 IN CASE OF PRB BLE = 3prb
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:4,52+1:4,0+2:4,52+3:4,52+4:4,52+5:4,52+6:4,52+7:4,52+8:4,52+9:4,52+10:4,52+11:4,52+12:4,52+13:4,52+14:4,52+15:4,52+16:4,52+17:4,52+
    # ...    18:4,52+19:4,52+20:4,52+21:4,0+22:4,52+23:4,52+24:4,52+25:4,52+26:4,52+27:4,52+52:4,52+29:4,52+30:4,52+31:4,52+32:4,52+33:4,52+34:4,52+
    # ...    35:4,52+36:4,52+37:4,52+38:4,52+39:4,52+40:4,52+41:4,0+42:4,52+43:4,52+44:4,52+45:4,52+46:4,52+47:4,52+48:4,52+49:4,52+50:4,52+51:4,52+
    # ...    52:4,52+53:4,52+54:4,52+55:4,52+56:4,52+57:4,52+58:4,52+59:4,52+60:4,52+61:4,0+62:4,52+63:4,52+64:4,52+65:4,52+66:4,52+67:4,52+68:4,52+
    # ...    69:4,52+70:4,52+71:4,52+72:4,52+73:4,52+74:4,52+75:4,52+76:4,52+77:4,52+78:4,52+79:4,52

    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:3,48+1:3,0+2:3,48+3:3,48+4:3,48+5:3,48+6:3,48+7:3,48+8:3,48+9:3,48+10:3,48+11:3,48+12:3,48+13:3,48+14:3,48+15:3,48+16:3,48+17:3,48+
    # ...    18:3,48+19:3,48+20:3,48+21:3,0+22:3,48+23:3,48+24:3,48+25:3,48+26:3,48+27:3,48+52:3,48+29:3,48+30:3,48+31:3,48+32:3,48+33:3,48+34:3,48+
    # ...    35:3,48+36:3,48+37:3,48+38:3,48+39:3,48+40:3,48+41:3,0+42:3,48+43:3,48+44:3,48+45:3,48+46:3,48+47:3,48+48:3,48+49:3,48+50:3,48+51:3,48+
    # ...    52:3,48+53:3,48+54:3,48+55:3,48+56:3,48+57:3,48+58:3,48+59:3,48+60:3,48+61:3,0+62:3,48+63:3,48+64:3,48+65:3,48+66:3,48+67:3,48+68:3,48+
    # ...    69:3,48+70:3,48+71:3,48+72:3,48+73:3,48+74:3,48+75:3,48+76:3,48+77:3,48+78:3,48+79:3,48

    # 3 PRB blanked Low Edge
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,49+1:0,0+2:0,49+3:0,49+4:0,49+5:0,49+6:0,49+7:0,49+8:0,49+9:0,49+10:0,49+11:0,
    # ...    52+12:0,49+13:0,49+14:0,49+15:0,49+16:0,49+17:0,49+18:0,49+19:0,49+20:0,49+21:0,0+22:0,49+23:0,49+24:0,49+25:0,49+26:0,49+27:0,49+52:0,
    # ...    52+29:0,49+30:0,49+31:0,49+32:0,49+33:0,49+34:0,49+35:0,49+36:0,49+37:0,49+38:0,49+39:0,49+40:0,49+41:0,0+42:0,49+43:0,49+44:0,49+45:0,
    # ...    52+46:0,49+47:0,49+48:0,49+49:0,49+50:0,49+51:0,49+52:0,49+53:0,49+54:0,49+55:0,49+56:0,49+57:0,49+58:0,49+59:0,49+60:0,49+61:0,0+62:0,
    # ...    52+63:0,49+64:0,49+65:0,49+66:0,49+67:0,49+68:0,49+69:0,49+70:0,49+71:0,49+72:0,49+73:0,49+74:0,49+75:0,49+76:0,49+77:0,49+
    # ...    78:0,49+79:0,52

    # CASE 10MHz/15MHz/20MHz w/o PRB BLANKING
    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...    ELSE    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    ...    10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # to manage DL PRB BLANKING case
    ${nbrOfBlankedPRBsHighEdgeDL}   set variable   ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL}   set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    ${max_prb}      run Keyword if     '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'      set variable    52
    ...    ELSE IF                     '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'      set variable    79
    ...    ELSE                                                                          set variable    106
    ${dl_prb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${max_prb}-${nbrOfBlankedPRBsHighEdgeDL}-${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    ${max_prb}
    ${msg}=   Catenate    max_dl_prb=${dl_prb} for dl_prb_area_allocation_list with
    ...                   actPRBBlanking=${Param.scfFile.nrcell.actPRBBlanking}
    ...                   nbrOfBlankedPRBsHighEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ...                   nbrOfBlankedPRBsLowEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    dated Log     ----------> ${msg}
    ${DL_StartPrb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    0
    ${dl_prb_area_allocation_list}=
    ...   Catenate    SEPARATOR=   0:${DL_StartPrb},${dl_prb}+1:${DL_StartPrb},${dl_prb}+2:${DL_StartPrb},${dl_prb}+3:${DL_StartPrb},${dl_prb}+
    ...     4:${DL_StartPrb},${dl_prb}+5:${DL_StartPrb},${dl_prb}+6:${DL_StartPrb},${dl_prb}+7:${DL_StartPrb},${dl_prb}+
    ...     8:${DL_StartPrb},${dl_prb}+9:${DL_StartPrb},${dl_prb}+10:${DL_StartPrb},${dl_prb}+11:${DL_StartPrb},${dl_prb}+
    ...     12:${DL_StartPrb},${dl_prb}+13:${DL_StartPrb},${dl_prb}+14:${DL_StartPrb},${dl_prb}+15:${DL_StartPrb},${dl_prb}+
    ...     16:${DL_StartPrb},${dl_prb}+17:${DL_StartPrb},${dl_prb}+18:${DL_StartPrb},${dl_prb}+19:${DL_StartPrb},${dl_prb}+
    ...     20:${DL_StartPrb},${dl_prb}+21:${DL_StartPrb},${dl_prb}+22:${DL_StartPrb},${dl_prb}+23:${DL_StartPrb},${dl_prb}+
    ...     24:${DL_StartPrb},${dl_prb}+25:${DL_StartPrb},${dl_prb}+26:${DL_StartPrb},${dl_prb}+27:${DL_StartPrb},${dl_prb}+
    ...     28:${DL_StartPrb},${dl_prb}+29:${DL_StartPrb},${dl_prb}+30:${DL_StartPrb},${dl_prb}+31:${DL_StartPrb},${dl_prb}+
    ...     32:${DL_StartPrb},${dl_prb}+33:${DL_StartPrb},${dl_prb}+34:${DL_StartPrb},${dl_prb}+35:${DL_StartPrb},${dl_prb}+
    ...     36:${DL_StartPrb},${dl_prb}+37:${DL_StartPrb},${dl_prb}+38:${DL_StartPrb},${dl_prb}+39:${DL_StartPrb},${dl_prb}+
    ...     40:${DL_StartPrb},${dl_prb}+41:${DL_StartPrb},${dl_prb}+42:${DL_StartPrb},${dl_prb}+43:${DL_StartPrb},${dl_prb}+
    ...     44:${DL_StartPrb},${dl_prb}+45:${DL_StartPrb},${dl_prb}+46:${DL_StartPrb},${dl_prb}+47:${DL_StartPrb},${dl_prb}+
    ...     48:${DL_StartPrb},${dl_prb}+49:${DL_StartPrb},${dl_prb}+50:${DL_StartPrb},${dl_prb}+51:${DL_StartPrb},${dl_prb}+
    ...     52:${DL_StartPrb},${dl_prb}+53:${DL_StartPrb},${dl_prb}+54:${DL_StartPrb},${dl_prb}+55:${DL_StartPrb},${dl_prb}+
    ...     56:${DL_StartPrb},${dl_prb}+57:${DL_StartPrb},${dl_prb}+58:${DL_StartPrb},${dl_prb}+59:${DL_StartPrb},${dl_prb}+
    ...     60:${DL_StartPrb},${dl_prb}+61:${DL_StartPrb},${dl_prb}+62:${DL_StartPrb},${dl_prb}+63:${DL_StartPrb},${dl_prb}+
    ...     64:${DL_StartPrb},${dl_prb}+65:${DL_StartPrb},${dl_prb}+66:${DL_StartPrb},${dl_prb}+67:${DL_StartPrb},${dl_prb}+
    ...     68:${DL_StartPrb},${dl_prb}+69:${DL_StartPrb},${dl_prb}+70:${DL_StartPrb},${dl_prb}+71:${DL_StartPrb},${dl_prb}+
    ...     72:${DL_StartPrb},${dl_prb}+73:${DL_StartPrb},${dl_prb}+74:${DL_StartPrb},${dl_prb}+75:${DL_StartPrb},${dl_prb}+
    ...     76:${DL_StartPrb},${dl_prb}+77:${DL_StartPrb},${dl_prb}+78:${DL_StartPrb},${dl_prb}+79:${DL_StartPrb},${dl_prb}

    dated Log     ----------> dl_prb_area_allocation_list = ${dl_prb_area_allocation_list}

    # 20MHz case
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    # ...    10:0,106+11:0,52+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    # ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    # ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    # ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    # ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    # ${dl_pattern}=      Catenate         0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    # ${dl_pattern}=      Catenate         0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${nbrOfBlankedPRBsLowEdgeUL}=     set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0}
        ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ELSE
        ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
        ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    END
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
        ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,5|${prb_nr_pusch_area}|47,5
        ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,5|${prb_nr_pusch_area}|74,5
        ...  ELSE                                                                           set variable   0,5|${prb_nr_pusch_area}|101,5
    ELSE
        ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
        ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
        ...                                                                          106
        ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${5}
        ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
        ${prb_area_list}=    set variable   ${prb_nr_pucch_low_area_start},5|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},5
    END

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3         prb_area_list=${prb_area_list}
    ...                                                                 alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed***

    ${cmd}    Catenate     enb_crm_status enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}
    ...                                                                                  alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

DSS_CRM_Cell_Setup_Phase3_2Cells
    [Arguments]                 ${alias}=default    ${wtsObj}=wts

    DSS CRM enb dss configure partnership    alias=${alias}    wtsObj=${wtsObj}



DSS_CRM_Cell_Setup_Phase3_TC21
#     [Arguments]                 ${testParam}=Param    ${alias}=default
     [Arguments]                 ${alias}=default

    Log to console   \n${blue}***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}*** ${normal}

    ${antenna_ports_num}   run Keyword if   '${Param.Context.nrCellType}'=='4DL4UL'
    ...                       set variable    4
    ...           ELSE        set variable    2
    wts.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3    alias=${alias}
    Sleep   2
    wts.execute egate command   cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=${antenna_ports_num}
    ...                                                   alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 nr_dl_peak_rate_increase=on    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=15 assigned_dl_maximum_share_to_nr=70 assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    wts.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    sleep    30
    # wts.execute egate command   cmd=enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    # ...                                         alias=${alias}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=70
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} dl_qos_load_meas_timer=1000
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***Dss Dl CellResource Area Coordination Update Indication BW=${Param.seq.bandwidth} triggered*** ${normal}


DSS_CRM_Cell_Setup_Phase3_Failure_case
#     [Arguments]                 ${testParam}=Param    ${alias}=default
    [Arguments]                 ${alias}=default
    [Documentation]     CellSetup Ph3 Failure case (used when actLteNrDssLteCatM activated) , DL Coord Update Ind without CatMInfo provided
    ...                 to CRMSim to trig the failure
    Log to console   \n${blue}***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}*** ${normal}

    wts.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 nr_dl_peak_rate_increase=on    alias=${alias}
    Sleep   2
    ${superfast_allocation}   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    set variable    on
    ...           ELSE        set variable    off
    ${cmd}=    Catenate   enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 superfast_allocation=${superfast_allocation}
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=1 dl_resource_sharing_algo=${dl_resource_sharing_algo}
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr} assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    wts.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    wts.execute egate command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    sleep    30
    # wts.execute egate command   cmd=enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    # ...                                         alias=${alias}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${prb_area_reservation_list}=        run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                             set variable      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...            ELSE             set variable      0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=${prb_area_reservation_list}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3 Failure case   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     prb_area_list=${prb_area_list}   alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}


DSS_CRM_Cell_Setup_Phase3_DL_Coordination_Failure_case
#     [Arguments]                 ${testParam}=Param    ${alias}=default
    [Arguments]                 ${alias}=default
    [Documentation]     CellSetup Ph3 Failure case (used when actLteNrDssLteCatM desactivated on gNB et activated on CRM/ENB side ) ,
    ...                  DL Coord Failure case with DSS configuartion error sent by CRM

    Log to console   \n${blue}***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}*** ${normal}

    wts.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 nr_dl_peak_rate_increase=on    alias=${alias}
    Sleep   2
    ${superfast_allocation}   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    set variable    on
    ...           ELSE        set variable    off
    ${cmd}=    Catenate   enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 superfast_allocation=${superfast_allocation}
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=1 dl_resource_sharing_algo=${dl_resource_sharing_algo}
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    # for CatM
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'    Set enb dss cell param for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for CatM

    # for superfast_allocation
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    Set enb dss cell param for actLteNrDssFastAlloc
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_allocation

    # for superfast_reduction_excess_msg
    run Keyword if   '${Param.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}'=='exec_msg_reduction_static'
    ...                                                                       Set enb dss cell param for superfast_reduction_excess_msg
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_reduction_excess_msg

    wts.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr} assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    wts.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    ...                                      cell_resource_coordination_failure_ttw=1
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    wts.execute egate command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    ${pattern}    Set Variable     EN DSS DL Cell Resource Area Coordination Failure
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep    5


DSS enb crm periodic allocation pattern UL
    [Arguments]     ${ul_allocated_prb_list}=1,35    ${allocation_type}=max_share
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 UL Fast Allocation
    sleep   1

     ${delay_if_auto}      set Variable        10
    ${msg}    Catenate    DSS enb_crm_periodic_allocation_pattern with allocation_start_time=auto and
    ...                    delay_if_auto=${delay_if_auto} and allocation_type=${allocation_type} and
    ...                    ul_allocated_prb_list=${ul_allocated_prb_list} with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_allocation_pattern enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    ...                      allocation_start_time=auto delay_if_auto=${delay_if_auto} ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                      allocation_type=${allocation_type}
    wts.execute egate command    cmd=${cmd}     alias=${alias}

    log to console  \n***DSS enb_crm_periodic_allocation_pattern  UL completed***

# DSS DL Cell Resource Allocation Phase3
DSS enb crm periodic allocation pattern
    [Arguments]     ${dl_allocated_normal_subframes}=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    ...             ${dl_prb_area_allocation_list}=${empty}
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 DL Fast Allocation
    sleep   1

    ${delay_if_auto}      set Variable        20
    # ${pattern}     Set Variable        Received DSS DL Resource Area Allocation Response
    ${msg}    Catenate    DSS enb_crm_periodic_allocation_pattern with allocation_start_time=auto and
    ...                    delay_if_auto=${delay_if_auto} and
    ...                    dl_allocated_normal_subframes=${dl_allocated_normal_subframes} with alias=${alias}
    Dated Log New Line      ${msg}

    ${cmd}    Catenate      enb_crm_periodic_allocation_pattern enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                   allocation_start_time=auto delay_if_auto=${delay_if_auto} dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                        dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ${l_pattern}=   Set variable     Received DSS DL Resource Area Allocation Failure
    ${cmdStr1}=   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.Context.WtsWaitingPattern}'=='${l_pattern}'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_C_sib1br=${Param.seq.CatMinfo.prb_area_C_sib1br}
    ...                                        prb_area_D_sib1br=${Param.seq.CatMinfo.prb_area_D_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE    Set variable    ${cmd}
    wts.execute egate command    cmd=${cmdStr1}     alias=${alias}
    # ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    # ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    # ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    # Log To Console    \n${output}
    log to console  \n***DSS enb_crm_periodic_allocation_pattern completed***

# enb_crm_periodic_allocation_pattern enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL allocation_start_time=auto
#      dl_allocated_normal_subframes=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
#     dl_prb_area_allocation_list=0:0,0+1:0,0+2:0,52+3:0,52+4:0,52+5:0,0+6:0,52+7:0,52+8:0,52+9:0,0+10:0,0+11:0,52+12:0,52+13:0,
#      52+14:0,52+15:0,0+16:0,52+17:0,52+18:0,52+19:0,0+20:0,0+21:0,0+22:0,52+23:0,52+24:0,52+25:0,0+26:0,52+27:0,52+28:0,52+29:0,
#      0+30:0,0+31:0,52+32:0,52+33:0,52+34:0,52+35:0,0+36:0,52+37:0,52+38:0,52+39:0,0+40:0,0+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
#      0+46:0,52+47:0,52+48:0,52+49:0,0+50:0,0+51:0,52+52:0,52+53:0,52+54:0,52+55:0,0+56:0,52+57:0,52+58:0,52+59:0,0+60:0,0+61:0,
#      0+62:0,52+63:0,52+64:0,52+65:0,0+66:0,52+67:0,52+68:0,52+69:0,0+70:0,0+71:0,52+72:0,52+73:0,52+74:0,52+75:0,0+76:0,52+77:0,52+78:0,52+79:0,0
# enb_crm_periodic_allocation_pattern enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL allocation_start_time=auto
#      dl_allocated_normal_subframes=1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110
#     dl_prb_area_allocation_list=0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,36+6:0,52+7:0,52+8:0,52+9:0,0+10:0,52+11:0,52+12:0,52+13:0,
#        52+14:0,52+15:0,36+16:0,52+17:0,52+18:0,52+19:0,0+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,36+26:0,52+27:0,52+28:0,52+29:0,
#        0+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,36+36:0,52+37:0,52+38:0,52+39:0,0+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
#        36+46:0,52+47:0,52+48:0,52+49:0,0+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,36+56:0,52+57:0,52+58:0,52+59:0,0+60:0,52+61:0,
#        0+62:0,52+63:0,52+64:0,52+65:0,36+66:0,52+67:0,52+68:0,52+69:0,0+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,36+76:0,52+77:0,
#        52+78:0,52+79:0,0
# enb_crm_periodic_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL periodicity=10 loopback=on
# enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL allocation_start_time=auto ul_allocated_prb_list=1,35
# enb_crm_status enb=2 cell=1

Periodic DL Fast Allocation
    [Arguments]                 ${alias}=default

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # for SSB POS1 test
    ${dl_allocated_normal_subframes}=  Catenate   0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    # ${dl_allocated_normal_subframes}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,0+1:0,0+2:0,52+3:0,52+4:0,52+5:0,0+6:0,52+7:0,52+8:0,52+9:0,0+10:0,0+11:0,52+12:0,
    ...    52+13:0,52+14:0,52+15:0,0+16:0,52+17:0,52+18:0,52+19:0,0+20:0,0+21:0,0+22:0,52+23:0,52+24:0,52+25:0,0+26:0,52+27:0,52+28:0,52+29:0,0+30:0,
    ...    0+31:0,52+32:0,52+33:0,52+34:0,52+35:0,0+36:0,52+37:0,52+38:0,52+39:0,0+40:0,0+41:0,0+42:0,52+43:0,52+44:0,52+45:0,0+46:0,52+47:0,52+48:0,
    ...    52+49:0,0+50:0,0+51:0,52+52:0,52+53:0,52+54:0,52+55:0,0+56:0,52+57:0,52+58:0,52+59:0,0+60:0,0+61:0,0+62:0,52+63:0,52+64:0,52+65:0,0+66:0,
    ...    52+67:0,52+68:0,52+69:0,0+70:0,0+71:0,52+72:0,52+73:0,52+74:0,52+75:0,0+76:0,52+77:0,52+78:0,52+79:0,0
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,0+1:0,0+2:0,79+3:0,79+4:0,79+5:0,0+6:0,79+7:0,79+8:0,79+9:0,0+10:0,0+11:0,79+12:0,
    ...    79+13:0,79+14:0,79+15:0,0+16:0,79+17:0,79+18:0,79+19:0,0+20:0,0+21:0,0+22:0,79+23:0,79+24:0,79+25:0,0+26:0,79+27:0,79+28:0,79+29:0,0+30:0,
    ...    0+31:0,79+32:0,79+33:0,79+34:0,79+35:0,0+36:0,79+37:0,79+38:0,79+39:0,0+40:0,0+41:0,0+42:0,79+43:0,79+44:0,79+45:0,0+46:0,79+47:0,79+48:0,
    ...    79+49:0,0+50:0,0+51:0,79+52:0,79+53:0,79+54:0,79+55:0,0+56:0,79+57:0,79+58:0,79+59:0,0+60:0,0+61:0,0+62:0,79+63:0,79+64:0,79+65:0,0+66:0,
    ...    79+67:0,79+68:0,79+69:0,0+70:0,0+71:0,79+72:0,79+73:0,79+74:0,79+75:0,0+76:0,79+77:0,79+78:0,79+79:0,0
    ...    ELSE    Catenate    SEPARATOR=   0:0,0+1:0,0+2:0,106+3:0,106+4:0,106+5:0,0+6:0,106+7:0,106+8:0,106+9:0,0+10:0,0+11:0,106+12:0,
    ...    106+13:0,106+14:0,106+15:0,0+16:0,106+17:0,106+18:0,106+19:0,0+20:0,0+21:0,0+22:0,106+23:0,106+24:0,106+25:0,0+26:0,106+27:0,106+28:0,
    ...    106+29:0,0+30:0,0+31:0,106+32:0,106+33:0,106+34:0,106+35:0,0+36:0,106+37:0,106+38:0,106+39:0,0+40:0,0+41:0,0+42:0,106+43:0,106+44:0,
    ...    106+45:0,0+46:0,106+47:0,106+48:0,106+49:0,0+50:0,0+51:0,106+52:0,106+53:0,106+54:0,106+55:0,0+56:0,106+57:0,106+58:0,106+59:0,0+60:0,
    ...    0+61:0,0+62:0,106+63:0,106+64:0,106+65:0,0+66:0,106+67:0,106+68:0,106+69:0,0+70:0,0+71:0,106+72:0,106+73:0,106+74:0,106+75:0,0+76:0,
    ...    106+77:0,106+78:0,106+79:0,0

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    # for SSB POS1 test
    ${dl_allocated_normal_subframes}=  Catenate   1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,36+6:0,52+7:0,52+8:0,52+9:0,0+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,36+16:0,52+17:0,52+18:0,52+19:0,0+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,36+26:0,52+27:0,52+28:0,
    ...     52+29:0,0+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,36+36:0,52+37:0,52+38:0,52+39:0,0+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...     36+46:0,52+47:0,52+48:0,52+49:0,0+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,36+56:0,52+57:0,52+58:0,52+59:0,0+60:0,52+61:0,0+62:0,
    ...     52+63:0,52+64:0,52+65:0,36+66:0,52+67:0,52+68:0,52+69:0,0+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,36+76:0,52+77:0,52+78:0,52+79:0,0
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,0+2:0,79+3:0,79+4:0,79+5:0,36+6:0,79+7:0,79+8:0,79+9:0,0+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,36+16:0,79+17:0,79+18:0,79+19:0,0+20:0,79+21:0,0+22:0,79+23:0,79+24:0,79+25:0,36+26:0,79+27:0,79+28:0,
    ...     79+29:0,0+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,36+36:0,79+37:0,79+38:0,79+39:0,0+40:0,79+41:0,0+42:0,79+43:0,79+44:0,79+45:0,
    ...     36+46:0,79+47:0,79+48:0,79+49:0,0+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,36+56:0,79+57:0,79+58:0,79+59:0,0+60:0,79+61:0,0+62:0,
    ...     79+63:0,79+64:0,79+65:0,36+66:0,79+67:0,79+68:0,79+69:0,0+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,36+76:0,79+77:0,79+78:0,79+79:0,0
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,36+6:0,106+7:0,106+8:0,106+9:0,0+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,36+16:0,106+17:0,106+18:0,106+19:0,0+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+25:0,36+26:0,
    ...     106+27:0,106+28:0,106+29:0,0+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,36+36:0,106+37:0,106+38:0,106+39:0,0+40:0,106+41:0,
    ...     0+42:0,106+43:0,106+44:0,106+45:0,36+46:0,106+47:0,106+48:0,106+49:0,0+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,36+56:0,
    ...     106+57:0,106+58:0,106+59:0,0+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,36+66:0,106+67:0,106+68:0,106+69:0,0+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,36+76:0,106+77:0,106+78:0,106+79:0,0

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    common_Dss_CellSetup.DSS DL Cell Periodic Resource Allocation Phase3     alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1
    # ...                                                           allocation_start_time=auto   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     prb_area_list=${prb_area_list}
    ...                                                             allocation_start_time=auto   alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Periodic DL Fast Allocation SSBSlot6
    [Arguments]                 ${alias}=default

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # for SSB POS6 test
    ${dl_allocated_normal_subframes}=  Catenate   0111100110-0111101110-0111100110-0111101110-0111100110-0111101110-0111100110-0111101110
    # ${dl_allocated_normal_subframes}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,0+1:0,0+2:0,52+3:0,52+4:0,52+5:0,0+6:0,52+7:0,52+8:0,52+9:0,0+10:0,0+11:0,52+12:0,
    ...    52+13:0,52+14:0,52+15:0,0+16:0,52+17:0,52+18:0,52+19:0,0+20:0,0+21:0,0+22:0,52+23:0,52+24:0,52+25:0,0+26:0,52+27:0,52+28:0,52+29:0,0+30:0,
    ...    0+31:0,52+32:0,52+33:0,52+34:0,52+35:0,0+36:0,52+37:0,52+38:0,52+39:0,0+40:0,0+41:0,0+42:0,52+43:0,52+44:0,52+45:0,0+46:0,52+47:0,52+48:0,
    ...    52+49:0,0+50:0,0+51:0,52+52:0,52+53:0,52+54:0,52+55:0,0+56:0,52+57:0,52+58:0,52+59:0,0+60:0,0+61:0,0+62:0,52+63:0,52+64:0,52+65:0,0+66:0,
    ...    52+67:0,52+68:0,52+69:0,0+70:0,0+71:0,52+72:0,52+73:0,52+74:0,52+75:0,0+76:0,52+77:0,52+78:0,52+79:0,0
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,0+1:0,0+2:0,79+3:0,79+4:0,79+5:0,0+6:0,79+7:0,79+8:0,79+9:0,0+10:0,0+11:0,79+12:0,
    ...    79+13:0,79+14:0,79+15:0,0+16:0,79+17:0,79+18:0,79+19:0,0+20:0,0+21:0,0+22:0,79+23:0,79+24:0,79+25:0,0+26:0,79+27:0,79+28:0,79+29:0,0+30:0,
    ...    0+31:0,79+32:0,79+33:0,79+34:0,79+35:0,0+36:0,79+37:0,79+38:0,79+39:0,0+40:0,0+41:0,0+42:0,79+43:0,79+44:0,79+45:0,0+46:0,79+47:0,79+48:0,
    ...    79+49:0,0+50:0,0+51:0,79+52:0,79+53:0,79+54:0,79+55:0,0+56:0,79+57:0,79+58:0,79+59:0,0+60:0,0+61:0,0+62:0,79+63:0,79+64:0,79+65:0,0+66:0,
    ...    79+67:0,79+68:0,79+69:0,0+70:0,0+71:0,79+72:0,79+73:0,79+74:0,79+75:0,0+76:0,79+77:0,79+78:0,79+79:0,0
    ...    ELSE    Catenate    SEPARATOR=   0:0,0+1:0,0+2:0,106+3:0,106+4:0,106+5:0,0+6:0,106+7:0,106+8:0,106+9:0,0+10:0,0+11:0,106+12:0,
    ...    106+13:0,106+14:0,106+15:0,0+16:0,106+17:0,106+18:0,106+19:0,0+20:0,0+21:0,0+22:0,106+23:0,106+24:0,106+25:0,0+26:0,106+27:0,106+28:0,
    ...    106+29:0,0+30:0,0+31:0,106+32:0,106+33:0,106+34:0,106+35:0,0+36:0,106+37:0,106+38:0,106+39:0,0+40:0,0+41:0,0+42:0,106+43:0,106+44:0,
    ...    106+45:0,0+46:0,106+47:0,106+48:0,106+49:0,0+50:0,0+51:0,106+52:0,106+53:0,106+54:0,106+55:0,0+56:0,106+57:0,106+58:0,106+59:0,0+60:0,
    ...    0+61:0,0+62:0,106+63:0,106+64:0,106+65:0,0+66:0,106+67:0,106+68:0,106+69:0,0+70:0,0+71:0,106+72:0,106+73:0,106+74:0,106+75:0,0+76:0,
    ...    106+77:0,106+78:0,106+79:0,0

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    # for SSB POS6 test
    ${dl_allocated_normal_subframes}=  Catenate   1111110110-1111111110-1111110110-1111111110-1111110110-1111111110-1111110110-1111111110

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,36+6:0,52+7:0,52+8:0,52+9:0,0+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,36+16:0,52+17:0,52+18:0,52+19:0,0+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,36+26:0,52+27:0,52+28:0,
    ...     52+29:0,0+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,36+36:0,52+37:0,52+38:0,52+39:0,0+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...     36+46:0,52+47:0,52+48:0,52+49:0,0+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,36+56:0,52+57:0,52+58:0,52+59:0,0+60:0,52+61:0,0+62:0,
    ...     52+63:0,52+64:0,52+65:0,36+66:0,52+67:0,52+68:0,52+69:0,0+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,36+76:0,52+77:0,52+78:0,52+79:0,0
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,0+2:0,79+3:0,79+4:0,79+5:0,36+6:0,79+7:0,79+8:0,79+9:0,0+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,36+16:0,79+17:0,79+18:0,79+19:0,0+20:0,79+21:0,0+22:0,79+23:0,79+24:0,79+25:0,36+26:0,79+27:0,79+28:0,
    ...     79+29:0,0+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,36+36:0,79+37:0,79+38:0,79+39:0,0+40:0,79+41:0,0+42:0,79+43:0,79+44:0,79+45:0,
    ...     36+46:0,79+47:0,79+48:0,79+49:0,0+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,36+56:0,79+57:0,79+58:0,79+59:0,0+60:0,79+61:0,0+62:0,
    ...     79+63:0,79+64:0,79+65:0,36+66:0,79+67:0,79+68:0,79+69:0,0+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,36+76:0,79+77:0,79+78:0,79+79:0,0
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,36+6:0,106+7:0,106+8:0,106+9:0,0+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,36+16:0,106+17:0,106+18:0,106+19:0,0+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+25:0,36+26:0,
    ...     106+27:0,106+28:0,106+29:0,0+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,36+36:0,106+37:0,106+38:0,106+39:0,0+40:0,106+41:0,
    ...     0+42:0,106+43:0,106+44:0,106+45:0,36+46:0,106+47:0,106+48:0,106+49:0,0+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,36+56:0,
    ...     106+57:0,106+58:0,106+59:0,0+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,36+66:0,106+67:0,106+68:0,106+69:0,0+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,36+76:0,106+77:0,106+78:0,106+79:0,0

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    common_Dss_CellSetup.DSS DL Cell Periodic Resource Allocation Phase3     alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1
    # ...                                                           allocation_start_time=auto   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     prb_area_list=${prb_area_list}
    ...                                                             allocation_start_time=auto   alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Periodic DL Fast Allocation With Same Pattern
    [Arguments]                 ${alias}=default
    [Documentation]       Procedure used by 2574 ; 2 same 100% DL pattern used with dl_prb_area_allocation_list for 10/15/20MHz wo prbBlanking

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # ${dl_allocated_normal_subframes}=  Catenate   1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110
    ${dl_allocated_normal_subframes}=  Catenate   1001110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,
    ...     52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,
    ...     52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,
    ...     52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,
    ...     52+79:0,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,79+2:0,79+3:0,79+4:0,79+5:0,79+6:0,79+7:0,79+8:0,79+9:0,79+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,79+16:0,79+17:0,79+18:0,79+19:0,79+20:0,79+21:0,79+22:0,79+23:0,79+24:0,79+25:0,79+26:0,79+27:0,79+28:0,
    ...     79+29:0,79+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,79+36:0,79+37:0,79+38:0,79+39:0,79+40:0,79+41:0,79+42:0,79+43:0,79+44:0,79+45:0,
    ...     79+46:0,79+47:0,79+48:0,79+49:0,79+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,79+56:0,79+57:0,79+58:0,79+59:0,79+60:0,79+61:0,79+62:0,
    ...     79+63:0,79+64:0,79+65:0,79+66:0,79+67:0,79+68:0,79+69:0,79+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,79+76:0,79+77:0,79+78:0,
    ...     79+79:0,79
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
    ...     106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
    ...     106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
    ...     106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    # ${dl_allocated_normal_subframes}=  Catenate   1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110
    ${dl_allocated_normal_subframes}=  Catenate   1001110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,
    ...     52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,
    ...     52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,
    ...     52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,
    ...     52+79:0,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,79+2:0,79+3:0,79+4:0,79+5:0,79+6:0,79+7:0,79+8:0,79+9:0,79+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,79+16:0,79+17:0,79+18:0,79+19:0,79+20:0,79+21:0,79+22:0,79+23:0,79+24:0,79+25:0,79+26:0,79+27:0,79+28:0,
    ...     79+29:0,79+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,79+36:0,79+37:0,79+38:0,79+39:0,79+40:0,79+41:0,79+42:0,79+43:0,79+44:0,79+45:0,
    ...     79+46:0,79+47:0,79+48:0,79+49:0,79+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,79+56:0,79+57:0,79+58:0,79+59:0,79+60:0,79+61:0,79+62:0,
    ...     79+63:0,79+64:0,79+65:0,79+66:0,79+67:0,79+68:0,79+69:0,79+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,79+76:0,79+77:0,79+78:0,
    ...     79+79:0,79
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
    ...     106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
    ...     106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
    ...     106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    common_Dss_CellSetup.DSS DL Cell Periodic Resource Allocation Phase3     alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     prb_area_list=${prb_area_list}
    ...                                                             allocation_start_time=auto   alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Periodic UL Fast Allocation
    [Arguments]                 ${alias}=default

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # ${ul_allocated_prb_list }=  Catenate   1,35

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3


    common_Dss_CellSetup.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                                             allocation_type=${Param.seq.ul_allocation_type}
    ...                                                             alias=${alias}

    # ${ul_allocated_prb_list }=  Catenate   1,20

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},20}
    ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                                             allocation_type=${Param.seq.ul_allocation_type}
    ...                                                             alias=${alias}

    common_Dss_CellSetup.DSS UL Cell Periodic Resource Allocation Phase3     alias=${alias}

    # Param variable is visible under the test suite

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Check DSS CellSetup Phase3
    [Documentation]      KW used to check DSS  CellSetup inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup inside PDML file    ${pdmlFile}

    Dated log                   ---Checking enDssSetupReq

# XpDssMessage.XpDssMessage-Discriminator value = 02000000 means enDssSetupReq
# check enDssSetupReq
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    # ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    ...                             kind="value"
    ...                             value=02000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssSetupResp

# XpDssMessage.XpDssMessage-Discriminator value = 03000000 means enDssSetupResp
# check enDssSetupRsp
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    # ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    ...                             kind="value"
    ...                             value=03000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

#    analyzer.check_list             pdmlFile=${pdmlFile}
#    ...                             packetName=xp_dss_XpDssMessage
#    ...                             path=xp_dss_xpdssmessage$
#    ...                             kind="showname"
#    ...                             value=enDssDlCellSubframeResourceCoordinationReq (Structure)
#    ...                             startPacket=${1}
#    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssDlCellResourceAreaCoordinationResp

# check enDssDlCellSubframeResourceCoordinationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.enDssDlQoSLoadMeasurementTimer.enDssDlQoSLoadMeasurementTimer_item_0$
    # ...                             path=.xp_dss_EnDssDlCrmSfInfo.enDssDlQoSLoadMeasurementTimer_item$
    ...                             kind="value"
    ...                             value=c800
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssUlCellSubframeResourceCoordinationResp

# check enDssUlCellSubframeResourceCoordinationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.enDssUlQoSLoadMeasurementTimer.enDssUlQoSLoadMeasurementTimer_item_0$
    # ...                             path=.xp_dss_EnDssUlCrmScInfo.enDssUlQoSLoadMeasurementTimer_item$
    ...                             kind="value"
    ...                             value=c800
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssDlCellResourceAreaAllocationResp

# check enDssDlCellResourceAreaAllocationResp
    # analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.enDssDlCellResourceAreaAllocationResp.dlAllocationSequenceNumber$
    ...                             kind="value"
    ...                             value=${dlAllocationSequenceNumber}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssUlSubcarrierResourceAllocationResp

# check enDssUlSubcarrierResourceAllocationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.enDssUlSubcarrierResourceAllocationResp.ulAllocationSequenceNumber$
    ...                             kind="value"
    ...                             value=${ulAllocationSequenceNumber}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   End checking DSS CellSetup inside PDML file

Check DSS CellSetup Phase3 Using MCShark
    [Documentation]      KW used to check DSS  CellSetup inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup inside PDML file    ${pdmlFile}

    Dated log                   ---Checking enDssSetupReq

# XpDssMessage.XpDssMessage-Discriminator value = 02000000 means enDssSetupReq
# check enDssSetupReq
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    # ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    ...                             kind="value"
    ...                             value=02000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssSetupResp

# XpDssMessage.XpDssMessage-Discriminator value = 03000000 means enDssSetupResp
# check enDssSetupRsp
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    # ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    ...                             kind="value"
    ...                             value=03000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

#    analyzer.check_list             pdmlFile=${pdmlFile}
#    ...                             packetName=xp_dss_XpDssMessage
#    ...                             path=xp_dss_xpdssmessage$
#    ...                             kind="showname"
#    ...                             value=enDssDlCellSubframeResourceCoordinationReq (Structure)
#    ...                             startPacket=${1}
#    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssDlCellResourceAreaCoordinationResp

# check enDssDlCellSubframeResourceCoordinationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_EnDssDlCrmSfInfo.enDssDlQoSLoadMeasurementTimer_item$
    # ...                             path=.xp_dss_EnDssDlCrmSfInfo.enDssDlQoSLoadMeasurementTimer_item$
    ...                             kind="value"
    ...                             value=c800
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssUlCellSubframeResourceCoordinationResp

# check enDssUlCellSubframeResourceCoordinationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_EnDssUlCrmScInfo.enDssUlQoSLoadMeasurementTimer_item$
    # ...                             path=.xp_dss_EnDssUlCrmScInfo.enDssUlQoSLoadMeasurementTimer_item$
    ...                             kind="value"
    ...                             value=c800
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssDlCellResourceAreaAllocationResp

# check enDssDlCellResourceAreaAllocationResp
    # analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_messages_EnDssDlCellResourceAreaAllocationResp_t.dlAllocationSequenceNumber$
    ...                             kind="value"
    ...                             value=${dlAllocationSequenceNumber}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking enDssUlSubcarrierResourceAllocationResp

# check enDssUlSubcarrierResourceAllocationResp
#    analyzer.check_list             pdmlFile=${pdmlFile}
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_messages_EnDssUlSubcarrierResourceAllocationResp_t.ulAllocationSequenceNumber$
    ...                             kind="value"
    ...                             value=${ulAllocationSequenceNumber}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   End checking DSS CellSetup inside PDML file

Check enDssDlCellResourceAreaCoordinationUpdateInd
    [Documentation]      KW used to check enDssDlCellResourceAreaCoordinationUpdateIndCellSetup inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DL CELL RESOURCE AREA COORDINATION Update procedure inside PDML file    ${pdmlFile}
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}
# XpDssMessage.XpDssMessage-Discriminator value = 00000029 means enDssDlCellResourceAreaCoordinationUpdateInd
# check enDssDlCellResourceAreaCoordinationUpdateInd
    Dated log                   ---Checking enDssDlCellResourceAreaCoordinationUpdateInd
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    ...                             kind="value"
    ...                             value=29000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   End checking DL CELL RESOURCE AREA COORDINATION Update procedure inside PDML file

Check enDssDlCellResourceAreaCoordinationUpdateInd Using MCShark
    [Documentation]      KW used to check enDssDlCellResourceAreaCoordinationUpdateIndCellSetup inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DL CELL RESOURCE AREA COORDINATION Update procedure inside PDML file    ${pdmlFile}
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

# XpDssMessage.XpDssMessage-Discriminator value = 00000029 means enDssDlCellResourceAreaCoordinationUpdateInd
# check enDssDlCellResourceAreaCoordinationUpdateInd
    Dated log                   ---Checking enDssDlCellResourceAreaCoordinationUpdateInd
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_messages_XpDssMessage_t.discriminator$
    ...                             kind="value"
    ...                             value=29000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   End checking DL CELL RESOURCE AREA COORDINATION Update procedure inside PDML file

7738_DSS_CRM_Cell_Setup_Phase3
    [Arguments]                 ${alias}=default
    ...                         ${max_lte_nr_dss_ratio}=70
    ...                         ${testmode_decode_PDSCH}=false

    Log to console   \n${blue}***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}*** ${normal}

    wts.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=V1,DMS3    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 nr_dl_peak_rate_increase=on    alias=${alias}
    Sleep   2
    wts.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 superfast_allocation=on    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=1 dl_resource_sharing_algo=${dl_resource_sharing_algo}
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2

    Run Keyword If    '${testmode_decode_PDSCH}'=='true'      WTS_CMD_DSS TestMode Decode PDSCH     alias=${alias}

    wts.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=15 assigned_dl_maximum_share_to_nr=70 assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    wts.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    sleep    30
    # wts.execute egate command   cmd=enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    # ...                                         alias=${alias}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate
    ...   enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=${max_lte_nr_dss_ratio}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,28+1:0,0+2:0,52+3:0,52+4:0,52+5:0,28+6:0,52+7:0,52+8:0,52+9:0,52+10:0,28+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,28+16:0,52+17:0,52+18:0,52+19:0,52+20:0,28+21:0,0+22:0,52+23:0,52+24:0,52+25:0,28+26:0,52+27:0,52+28:0,
    ...    52+29:0,52+30:0,28+31:0,52+32:0,52+33:0,52+34:0,52+35:0,28+36:0,52+37:0,52+38:0,52+39:0,52+40:0,28+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    28+46:0,52+47:0,52+48:0,52+49:0,52+50:0,28+51:0,52+52:0,52+53:0,52+54:0,52+55:0,28+56:0,52+57:0,52+58:0,52+59:0,52+60:0,28+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,28+66:0,52+67:0,52+68:0,52+69:0,52+70:0,28+71:0,52+72:0,52+73:0,52+74:0,52+75:0,28+76:0,52+77:0,52+78:0,52+79:0,52

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     prb_area_list=${prb_area_list}
    ...                                                             allocation_start_time=immediate    alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Verify AP Classical Cell Setup
    Dev_lib.start_to_capture_infomodel_log
    common_Dss_Keywords.Cells 1 Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log


Verify AP Classical Cell Setup version1
	${output}           SSH Wait For Connect and Cmd
	...                 command=grep complete /tmp/startup_l3.log
	...                 host=${AP_DU.sys[0].M}
    should contain	    ${output}	                Cell Setup completed
	Dated log           Cell Setup AP OK on L3 logs


Check DSS CellSetup CatM Capabilities
    [Documentation]      KW used to check DSS  CellSetup CatM Capabilities inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup CatM Capabilities inside PDML file    ${pdmlFile}

    Dated log                   ---Checking CatM capabilities_item in enDssDlCellResourceAreaCoordinationReq
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

# XpDssMessage.XpDssMessage-Discriminator value = 27000000 means enDssDlCellResourceAreaCoordinationReq
# check enDssSetupReq
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    ...                             kind="value"
    ...                             value=27000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking CatM capabilities_item in enDssUlCellSubcarrierResourceCoordinationUpdateInd

# XpDssMessage.XpDssMessage-Discriminator value = 29000000 means enDssUlCellSubcarrierResourceCoordinationUpdateInd
# check enDssSetupRsp
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    ...                             kind="value"
    ...                             value=29000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    ${capabilities_CatM_count}       Run      cat ${pdmlFile} | grep -E 'capabilities_item_0_byte_0: 0x20' -c
    Should Be Equal As Integers    ${capabilities_CatM_count}    ${2}    CatM Capabilities not present in DL Coordination Req/Update Ind as expected

    Dated log                   End checking DSS CatM Capabilities CellSetup Info inside PDML file

Check DSS CellSetup CatM Capabilities Using MCShark
    [Documentation]      KW used to check DSS  CellSetup CatM Capabilities inside PDML file
    [Arguments]                     ${pcapFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup CatM Capabilities inside PCAP file    ${pcapFile}

    Dated log                   ---Checking CatM capabilities_item in enDssDlCellResourceAreaCoordinationReq
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

# XpDssMessage.XpDssMessage-Discriminator value = 27000000 means enDssDlCellResourceAreaCoordinationReq
# check enDssDlCellResourceAreaCoordinationReq
    ${output}=    nps_2574_tools.check_exists_once    pcapFile=${pcapFile}
    ...                                               packetName=xp_dss_xpdssmessage
    ...                                               packetType=enDssDlCellResourceAreaCoordinationReq
    should contain     ${output.lower()}    passed

    Dated log                   ---Checking CatM capabilities_item in enDssUlCellSubcarrierResourceCoordinationUpdateInd

# XpDssMessage.XpDssMessage-Discriminator value = 29000000 means enDssUlCellSubcarrierResourceCoordinationUpdateInd
# check enDssDlCellResourceAreaCoordinationUpdateInd
    ${output}=    nps_2574_tools.check_exists_once    pcapFile=${pcapFile}
    ...                                               packetName=xp_dss_xpdssmessage
    ...                                               packetType=enDssDlCellResourceAreaCoordinationUpdateInd
    should contain     ${output.lower()}    passed

    ${output}=    nps_2574_tools.check_CatM_Capabilities    pcapFile=${pcapFile}
    ...                                                     packetName=xp_dss_xpdssmessage
    ...                                                     packetType=enDssDlCellResourceAreaCoordinationReq
    should contain     ${output.lower()}    passed   CatM Capabilities not present in DL Coordination Req/Update Ind as expected

    ${output}=    nps_2574_tools.check_CatM_Capabilities    pcapFile=${pcapFile}
    ...                                                     packetName=xp_dss_xpdssmessage
    ...                                                     packetType=enDssDlCellResourceAreaCoordinationUpdateInd
    should contain     ${output.lower()}    passed   CatM Capabilities not present in DL Coordination Req/Update Ind as expected

    Dated log                   End checking DSS CatM Capabilities CellSetup Info inside PCAP file

Check DSS CellSetup CatM Capabilities for Failure test case
    [Documentation]      KW used to check DSS  CellSetup CatM Capabilities inside PDML file
    [Arguments]                     ${pdmlFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup CatM Capabilities inside PDML file    ${pdmlFile}

    Dated log                   ---Checking CatM capabilities_item in enDssDlCellResourceAreaCoordinationReq
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

# XpDssMessage.XpDssMessage-Discriminator value = 27000000 means enDssDlCellResourceAreaCoordinationReq
# check enDssDlCellResourceAreaCoordinationReq
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    ...                             kind="value"
    ...                             value=27000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   ---Checking CatM capabilities_item in enDssDlCellResourceAreaCoordinationFailInfo

# XpDssMessage.XpDssMessage-Discriminator value = 2b000000 means enDssDlCellResourceAreaCoordinationFailInfo
# check enDssDlCellResourceAreaCoordinationFailInfo
    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.XpDssMessage.XpDssMessage-Discriminator$
    ...                             kind="value"
    ...                             value=2b000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    ${capabilities_CatM_count}       Run      cat ${pdmlFile} | grep -E 'capabilities_item_0_byte_0: 0x20' -c
    Should Be Equal As Integers    ${capabilities_CatM_count}    ${2}    CatM Capabilities not present in DL Coordination Req/Update Ind as expected

    ${cmd}=     Catenate     cat ${pdmlFile} | grep -E 'xp_dss_XpDssMessage.enDssDlCellResourceAreaCoordinationFailInfo.enDssFailureCause'
    ...                                      | grep -E 'xp_dss_EnDssFailureCause.DssConfigurationError' -c
    ${DssConfigurationError_count}       Run      ${cmd}
    ${msg}=   Catenate    xp_dss_EnDssFailureCause.DssConfigurationError not present in enDssDlCellResourceAreaCoordinationFailInfo as expected
    Should Be Equal As Integers    ${DssConfigurationError_count}    ${1}    ${msg}

    Dated log                   End checking DSS CatM Capabilities CellSetup Info inside PDML file

Check DSS CellSetup CatMInfo
    [Documentation]      KW used to check DSS  CellSetup CatMInfo inside PCAP file
    [Arguments]                     ${pcapFile}
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000
    ...                             ${lua_script}=/opt/luashark/generated_luashark/xpshark.lua

    Dated log                   Checking DSS CellSetup CatMInfo inside PCAP file    ${pcapFile}

    Dated log                   ---Checking CatMInfo in enDssDlCellSubcarrierResourceCoordinationUpdateInd
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

    set test variable    ${pcapprocessed_CatMInfo}    pcapprocessed_CatMInfo.txt
    set test variable    ${pcapprocessed_CatMInfo_path}    ${LOG_PATH}/${pcapprocessed_CatMInfo}
    ${cmd}=   set variable if    '${lua_script}'=='None'   tshark
    ...                                                    tshark -X lua_script:${lua_script}
    ${cmd}    catenate      ${cmd} -r
    ...        ${pcapFile} -T fields -Y "xp_dss_xpdssmessage || xp_xpmessage" -e _ws.col.Info
    ...           -e xp_dss_XpDssMessage.XpDssMessage.XpDssMessage-Discriminator -e xp_dss_XpDssMessage.catmInfo.repeatedMpbch
    ...           -e xp_dss_XpDssMessage.catmInfo.startSymbol -e xp_dss_XpDssMessage.catmInfo.catmDlDataIndex
    ...           -e xp_dss_XpDssMessage.catmInfo.pagingStartingIndex -e xp_dss_XpDssMessage.catmInfo.numberOfCatmPagingRecords
    ...           -e xp_dss_XpDssMessage.catmInfo.sib1BrStartingIndex -E header=y -E separator=';' > ${pcapprocessed_CatMInfo_path}
    Run       ${cmd}

    Dated log                   End checking DSS CatMInfo CellSetup inside PDML file

Check DSS CellSetup CatMInfo using MCShark
    [Documentation]      KW used to check DSS  CellSetup CatMInfo inside PCAP file
    [Arguments]                     ${pcapFile}
    ...                             ${lua_script}=/opt/luashark/generated_luashark/xpshark.lua
    ...                             ${dlAllocationSequenceNumber}=00000000
    ...                             ${ulAllocationSequenceNumber}=00000000

    Dated log                   Checking DSS CellSetup CatMInfo inside PCAP file    ${pcapFile}

    Dated log                   ---Checking CatMInfo in enDssDlCellSubcarrierResourceCoordinationUpdateInd
    BuiltIn.log                 dlAllocationSequenceNumber is ${dlAllocationSequenceNumber}
    BuiltIn.log                 ulAllocationSequenceNumber is ${ulAllocationSequenceNumber}

    set test variable    ${pcapprocessed_CatMInfo}    pcapprocessed_CatMInfo.txt
    set test variable    ${pcapprocessed_CatMInfo_path}    ${LOG_PATH}/${pcapprocessed_CatMInfo}
    ${cmd}=   set variable if    '${lua_script}'=='None'   tshark
    ...                                                    tshark -X lua_script:${lua_script}
    ${cmd}    catenate      ${cmd} -r
    ...        ${pcapFile} -T fields -Y "xp_dss_xpdssmessage || xp_xpmessage" -e _ws.col.Info
    ...           -e xp_dss_messages_XpDssMessage_t.discriminator -e xp_dss_CatmInfo.repeatedMpbch
    ...           -e xp_dss_CatmInfo.startSymbol  -e xp_dss_CatmInfo.catmDlDataIndex
    ...           -e xp_dss_CatmInfo.pagingStartingIndex -e xp_dss_CatmInfo.numberOfCatmPagingRecords
    ...           -e xp_dss_CatmInfo.sib1BrStartingIndex -E header=y -E separator=';' > ${pcapprocessed_CatMInfo_path}
    Run       ${cmd}

    Dated log                   End checking DSS CatMInfo CellSetup inside PDML file


WTS_CMD_DSS TestMode Decode PDSCH
    [Arguments]    ${alias}=default
    ${cmd}    Catenate          ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH
    wts.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2

# WA for cqi TM
# enb_endc_param id=1 serving_cell_index_range_scg=5:31
Add Scell Range To NSA
    [Arguments]        ${gNBId}=1            ${alias}=default
    Log To Console    add scell range to NSA...
    wts.Execute Egate Command
    ...    cmd=enb_endc_param id=${gNBId} serving_cell_index_range_scg=5:31     alias=${alias}

# ex
# Override CSI profile
# csi_override_testmode_nr profile_id=1 cqi=15 cqi_mode=fixed ri=1 ri_mode=fixed
# csi_override_testmode_nr profile_id=1' | pass_regexp='csi_override_testmode_nr Parameters
# and activate CSI profile  ( id = UeId)
# ue_testmode_set_nr id=11 scell=5 testmode=csi_override profile_id=1 action=activate

Associate UEs to testmode
    [Documentation]    :
    ...
    ...    :param id:          specified UE ID
    ...    :param scell:       carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.
    ...                        Secondary is for scell indexes 1-7.
    ...    :param testmode:    testmode to be used
    ...    :param profile_id:  test profile id
    ...    :param action:      triggers the activation or the deactivation of the test mode (activate or deactivate)
    ...
    [Arguments]    ${id}    ${testmode}    ${profile_id}    ${action}    ${scell}=0       ${alias}=default
    ${command}=    Set variable    ue_testmode_set_nr id=${id} scell=${scell} testmode=${testmode} profile_id=${profile_id} action=${action}
    wts.Execute Egate Command      cmd=${command}      alias=${alias}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    ${action} testmode ${testmode} for UE=${id} scell=${scell} and profile_id ${profile_id}    console=True

Override and Activate UE CSI profile
    [Arguments]        ${profile_id}= 1   ${UeId}=1   ${nr_cqi}=15    ${nr_cqi_mode}=fixed  ${cqi_min}=1     ${cqi_max}=15
    ...                      ${nr_ri}=1    ${nr_ri_mode}=fixed    ${alias}=default
    Log To Console    Override and Activate UE CSI profile...
    ${cmd_egate}=    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${nr_cqi} cqi_mode=${nr_cqi_mode} cqi_min=${cqi_min}
    ...                                                                            cqi_max=${cqi_max} ri=${nr_ri} ri_mode=${nr_ri_mode}
    wts.Execute Egate Command    cmd=${cmd_egate}       alias=${alias}
    ${cmd}=   Catenate   csi_override_testmode_nr profile_id=${profile_id}
    ${pattern}     Set Variable        csi_override_testmode_nr Parameters
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Dated log        ${cmd}
    Log To Console    \n${output}
    BuiltIn.Log     Channel State Information for UE${UeId} is updated with cqi=${nr_cqi} cqi_mode=${nr_cqi_mode} ri=${nr_ri} ri_mode=${nr_ri_mode}
    Log To Console   Channel State Information for UE${UeId} is updated with cqi=${nr_cqi} cqi_mode=${nr_cqi_mode} ri=${nr_ri} ri_mode=${nr_ri_mode}
    Log To Console   Associate UE to testmode...
    Associate UEs to testmode    id=${ue_id}    testmode=csi_override    profile_id=${profile_id}    action=activate    scell=5      alias=${alias}
    Log To Console    set_UE_CQI_Testmode_is_ok

Configure and Activate Bler Test Mode profile
    [Arguments]        ${profile_id}=1   ${UeId}=1   ${dl_bler}=500,500,500,500,500,500,500,500      ${alias}=default
    Log To Console    Configure and Activate Bler Test Mode profile...
    wts.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler}
    ...    alias=${alias}
    ${cmd}=   Catenate   bler_testmode_nr profile_id=${profile_id}
    # ${pattern}     Set Variable        Parameters of ProfileId
    ${pattern}     Set Variable        dl_bler
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Dated log        ${cmd}
    Log To Console    \n${output}
    BuiltIn.Log     Dl Bler TestMode for UE${UeId} is updated with dl_bler=${dl_bler}
    Log To Console    Dl Bler TestMode for UE${UeId} is updated with dl_bler=${dl_bler}
    Log To Console    Associate UE to testmode...
    Associate UEs to testmode    id=${ue_id}    testmode=bler    profile_id=${profile_id}    action=activate    scell=5    alias=${alias}
    Log To Console    set_bler_nr_Testmode_is_ok

Verify cell setup with COAM
    [Documentation]     : [PRIVATE]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     cell_id:   Id of cell,
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]     ${oam_alias}    ${cell_id}=0   ${timeout}=30
    ${cells_status}=   coam.get_cells_info    cell_type=nr     timeout=${timeout}    connection=${oam_alias}
    ${bts_status}=     coam.get_bts_statuses    timeout=${timeout}    connection=${oam_alias}
    ${P_internal_cell_dist_id}=  Set Variable   ${cells_status[${cell_id}]['id']['internal']}
    ${cell_status_}=    Set variable  ${cells_status[${cell_id}]['status']}
    ${msg}=   Catenate    Cell ${cell_id} [${P_internal_cell_dist_id}]
    Dated log    ${msg}
    ${msg}=   Catenate    operationalState=${cell_status_['operationalState']},
    ...                   proceduralStatus=${cell_status_['proceduralStatus']},
    ...                   administrativeState=${cell_status_['administrativeState']},
    Dated log    ${msg}
    ${msg}=   Catenate    blockingState=${cell_status_['blockingState']}
    Dated log    ${msg}
    Dated log    BTS procedural state is now: ${bts_status['proceduralState']}
    Dated log    BTS operational state is now: ${bts_status['operationalState']}
    Dated log    BTS blockingState is now: ${bts_status['blockingState']}
    Should be equal    ${cell_status_['operationalState']}         Enabled         ignore_case=true
    Should be equal    ${cell_status_['proceduralStatus']}         configured      ignore_case=true
    Should be equal    ${cell_status_['blockingState']}            Unblocked       ignore_case=true
    # 06-14-2022 : usageState is not present anymore on cell_status !!!
    # Should Contain Any    ${cell_status['usageState']}            Active          ignore_case=true
    Should be equal    ${cell_status_['administrativeState']}      Unlocked        ignore_case=true
    # Should be equal    ${bts_status['operationalState']}          Enabled        ignore_case=true
    should Contain Any   ${bts_status['operationalState']}          Enabled   Disabled      ignore_case=true
    # Should be equal    ${bts_status['proceduralState']}           OnAir
    # ...                                                           msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    # ...                                                           ignore_case=true
    should Contain Any   ${bts_status['proceduralState']}           OnAir    Configured   IntegratedToRan
    ...                                                                     msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    ...                                                                     ignore_case=true
    Should be equal    ${bts_status['blockingState']}             Unblocked       ignore_case=true

    [Return]  ${P_internal_cell_dist_id}

Verify cellId setup with COAM
    [Documentation]     : [PRIVATE]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     cell_status:   cell status reported bu cOAM, using get_cells_info
    ...     cell_id:   Id of cell,
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]    ${oam_alias}    ${cell_status}=None    ${cell_id}=1   ${timeout}=30
    ${bts_status}=     coam.get_bts_statuses    timeout=${timeout}    connection=${oam_alias}
    ${P_internal_cell_dist_id}=  Set Variable   ${cell_status['id']['internal']}
    ${cell_status_res}=    Set variable  ${cell_status['status']}
    ${msg}=   Catenate    Cell ${cell_id} [${P_internal_cell_dist_id}]
    Dated log    ${msg}
    ${msg}=   Catenate    operationalState=${cell_status_res['operationalState']},
    ...                   proceduralStatus=${cell_status_res['proceduralStatus']},
    ...                   administrativeState=${cell_status_res['administrativeState']},
    Dated log    ${msg}
    ${msg}=   Catenate    blockingState=${cell_status_res['blockingState']}
    Dated log    ${msg}
    Dated log    BTS procedural state is now: ${bts_status['proceduralState']}
    Dated log    BTS operational state is now: ${bts_status['operationalState']}
    Dated log    BTS blockingState is now: ${bts_status['blockingState']}
    Should be equal    ${cell_status_res['operationalState']}         Enabled         ignore_case=true
    Should be equal    ${cell_status_res['proceduralStatus']}         configured      ignore_case=true
    Should be equal    ${cell_status_res['blockingState']}            Unblocked       ignore_case=true
    # 06-14-2022 : usageState is not present anymore on cell_status !!!
    # Should Contain Any    ${cell_status_res['usageState']}            Active          ignore_case=true
    Should be equal    ${cell_status_res['administrativeState']}      Unlocked        ignore_case=true
    # Should be equal    ${bts_status['operationalState']}          Enabled        ignore_case=true
    should Contain Any    ${bts_status['operationalState']}          Enabled   Disabled      ignore_case=true
    # Should be equal    ${bts_status['proceduralState']}           OnAir
    # ...                                                           msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    # ...                                                           ignore_case=true
    should Contain Any   ${bts_status['proceduralState']}           OnAir    Configured   IntegratedToRan
    ...                                                             msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    ...                                                             ignore_case=true
    Should be equal    ${bts_status['blockingState']}             Unblocked       ignore_case=true

    [Return]  ${P_internal_cell_dist_id}

Verify that cellId are onair with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}   ${globalCellId}=1
    ${output}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    FOR    ${cell}    IN    @{output}
        continue for loop if   '${cell['globalCellId']}' != '${globalCellId}'
        ${_internal_cell_dist_id}=  Verify cellId setup with COAM   oam_alias=${oam_alias}  cell_status=${cell}  cell_id=${globalCellId}
    END

Verify that cells are onair with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}   ${num_of_cells}=1
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${_internal_cell_dist_id}=  Verify cell setup with COAM   oam_alias=${oam_alias}   cell_id=${cell_id}
    END

Wait gNB cells 5g On air
    [Documentation]        [PRIVATE]  Wait gNB cells 5g On air
    [Arguments]     ${num_of_cells}=1
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    wait until keyword succeeds    5min    20s      Verify that cells are onair with COAM   oam_alias=${GNB_DU.oam.httpAlias}
    ...                                                                                     num_of_cells=${num_of_cells}
    [Teardown]         OAM Disconnect                  ${GNB_DU.oam}

Wait gNB cell 5g On air
    [Documentation]        [PRIVATE]  Wait gNB cell 5g On air
    [Arguments]     ${globalCellId}=1
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    wait until keyword succeeds    1min    20s      Verify that cellId are onair with COAM   oam_alias=${GNB_DU.oam.httpAlias}
    ...                                                                                      globalCellId=${globalCellId}
    [Teardown]         OAM Disconnect                  ${GNB_DU.oam}

logout OAM
    [Arguments]    ${alias}=${GNB_DU.oam}
    ${status}   ${message}           run keyword and ignore error       OAM Disconnect        ${alias}
    run Keyword if      '${status}' == 'FAIL'   Log to console    Keyword logout OAM ${alias} failed

Get VDU Cell Number
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    # NRCELL_DN_LIST_DU is a global variable provided by AF
    BuiltIn.log    vdu_index=${vdu_index} and gnb_index=${gnb_index}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist       ${NRCELL_DN_LIST_DU}
    @{defaultList}=   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    Run Keyword If   "${status}"=="FAIL"     Set Global Variable     ${NRCELL_DN_LIST_DU}   ${defaultList}
    ${cell_number}    Set Variable    ${NRCELL_DN_LIST_DU.__len__()}
    [Return]   ${cell_number}

vDU Check All Cells Status Should Be Onair
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    BuiltIn.log    vdu_index=${vdu_index} and gnb_index=${gnb_index}
    ${cell_number}    Get VDU Cell Number    gnb_index=${gnb_index}
    ${aliasGNB}                     OAM Connect                          ${GNB_DU.oam}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${aliasGNB}
    Dated log    vdu_cells_summary=${vdu_cells_summary}
    ${msg}=   set variable   Check All Cells Status Should Be Onair Failed
    ${msg_err}=   Catenate    ${msg} => vDU_disabled_cell_amount=${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0    msg=${msg_err}  values=False
    ${msg_err}=   Catenate   ${msg} => vDU_locked_cell_amount=${vdu_cells_summary['basic_cells_summary']['operational_state']['locked']}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0   msg=${msg_err}   values=False
    ${msg_err}=   Catenate  ${msg} => vDU_shutting_down_cell_amount=${vdu_cells_summary['basic_cells_summary']['operational_state']['shutting_down']}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0  msg=${msg_err}  values=False
    ${msg_err}=   Catenate    ${msg} => vDU_on_line_cell_amount=${vdu_cells_summary['availability_status']['on_line']}
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    should be true    ${on_line}==${cell_number}   ${msg_err}
    [Teardown]  logout OAM   alias=${GNB_DU.oam}

get CRM and ENB Status
     [Arguments]          ${testParam}=Param    ${resultFileCRM}=resultFileCRM.log     ${alias}=default

    ${output}    wts.execute egate command and wait for data
    ...                  cmd=enb_crm_status enb=${testParam.Context.eNBId} cell=${testParam.Context.eNBId_cellid}     alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_crm_status enb=${testParam.Context.eNBId} cell=${testParam.Context.eNBId_cellid}
    Append To File   ${resultFileCRM}      \n${output}

    ${output}    wts.execute egate command and wait for data
    ...           cmd=enb_cell_dss_feature enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ...           alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_dss_feature enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    Append To File   ${resultFileCRM}      \n${output}

    ${output}    wts.execute egate command and wait for data
    ...                   cmd=enb_cell_dss_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ...                   alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_dss_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    Append To File   ${resultFileCRM}      \n${output}

    ${output}    wts.execute egate command and wait for data
    ...                                    cmd=enb_cell_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ...                                    alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    Append To File   ${resultFileCRM}      \n${output}

get CRM and ENB Status to File
     [Arguments]          ${testParam}=Param    ${resultFileCRM}=resultFileCRM.log     ${alias}=default
     ...                  ${wtsObj}=wts

    ${cmd}=     catenate    enb_crm_status enb=${testParam.Context.eNBId} cell=${testParam.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}    alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_crm_status enb=${testParam.Context.eNBId} cell=${testParam.Context.eNBId_cellid}
    ${reformatted_text}=    Replace String    ${output}    \r\n\r\n    \n
    Append To File   ${resultFileCRM}      \n${reformatted_text}

    ${cmd}=     catenate    enb_cell_dss_feature enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}         alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_dss_feature enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${reformatted_text}=    Replace String    ${output}    \r\n\r\n    \n
    Append To File   ${resultFileCRM}      \n${reformatted_text}

    ${cmd}=     catenate    enb_cell_dss_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}    alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_dss_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${reformatted_text}=    Replace String    ${output}    \r\n\r\n    \n
    Append To File   ${resultFileCRM}      \n${reformatted_text}

    ${cmd}=     catenate    enb_cell_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}    alias=${alias}
    Append To File   ${resultFileCRM}      \n*** enb_cell_param enb=${testParam.Context.eNBId} id=${testParam.Context.eNBId_cellid}
    ${reformatted_text}=    Replace String    ${output}    \r\n\r\n    \n
    Append To File   ${resultFileCRM}      \n${reformatted_text}

get and display ue_summary
    [Arguments]          ${testParam}=Param    ${alias}=default
    ...                  ${wtsObj}=wts
    ${cmd}=     catenate    ue_summary
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}    alias=${alias}
    Log to console    ue_summary=${output}
