*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library        taf.selenium.sbts        WITH NAME        selenium_coam
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
#bts id
${MRBTS_ID}           ${tl.enbs[0].instance_id}
${NRBTS_ID}           ${tl.enbs[0].global_bts_id}

*** Keywords ***
Modify Mimo Mode to TM3 via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${lncel_id}=1
    log to console    \nModify Mimo Mode to TM3 with cell ${lncel_id}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}/MPUCCH_TDD-0
    ...    filter_param=Rank indication reporting enable
    ...    abbr=riEnable
    ...    new_value=true
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Downlink MIMO mode
    ...    abbr=dlMimoMode
    ...    new_value=Dynamic Open Loop MIMO
    Modify SRS Configuration    remove_or_add_srs_configuration=remove    lncel_id=${lncel_id}

Modify Mimo Mode to TM7 via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${lncel_id}=1
    log to console    \nModify Mimo Mode to TM7 with cell ${lncel_id}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}/MPUCCH_TDD-0
    ...    filter_param=Rank indication reporting enable
    ...    abbr=riEnable
    ...    new_value=false
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Downlink MIMO mode
    ...    abbr=dlMimoMode
    ...    new_value=Single Stream Beamforming
    Modify SRS Configuration    remove_or_add_srs_configuration=add    lncel_id=${lncel_id}

Modify Mimo Mode to TM8 via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${lncel_id}=1
    log to console    \nModify Mimo Mode to TM8 with cell ${lncel_id}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}/MPUCCH_TDD-0
    ...    filter_param=Rank indication reporting enable
    ...    abbr=riEnable
    ...    new_value=true
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Downlink MIMO mode
    ...    abbr=dlMimoMode
    ...    new_value=Dual Stream Beamforming
    Modify SRS Configuration    remove_or_add_srs_configuration=add    lncel_id=${lncel_id}

Modify SRS Configuration
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${remove_or_add_srs_configuration}=remove    ${lncel_id}=1
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    ${status}    ${beamforming_type}    run keyword and ignore error    selenium_coam.get_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=SRS beamforming type
    ...    abbr=beamformingType
    ...    node_index=1
    ${filter_param}    set variable    SRS downlink MIMO mode dependent configuration
    run keyword if    '${status}'=='PASS' and '${remove_or_add_srs_configuration}'=='remove'
    ...    selenium_coam.remove_element    dist_name=${cell_dist_name}
    ...    filter_param=${filter_param}
    ...    node_index=1
    return from keyword if    '${remove_or_add_srs_configuration}'=='remove'
    run keyword if    '${status}'=='FAIL'    run keywords    selenium_coam.add_element     dist_name=${cell_dist_name}
    ...    filter_param=${filter_param}    AND
    ...    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=SRS beamforming type
    ...    node_index=1
    ...    abbr=beamformingType
    ...    new_value=beamforming    AND
    ...    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=SRS bandwidth
    ...    node_index=1
    ...    abbr=srsBandwidth
    ...    new_value=2hbw    AND
    ...    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=SRS periodicity of UE transmission
    ...    node_index=1
    ...    abbr=srsUePeriodicity
    ...    new_value=20ms

Modify Mimo Mode via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${mimo_mode}=TM3    ${lncel_id}=1
    run keyword if    '${mimo_mode}'=='TM3'    Modify Mimo Mode to TM3 via Webem    lncel_id=${lncel_id}
    ...    ELSE IF    '${mimo_mode}'=='TM7'    Modify Mimo Mode to TM7 via Webem    lncel_id=${lncel_id}
    ...    ELSE    Modify Mimo Mode to TM8 via Webem    lncel_id=${lncel_id}

Modify Frame Structure via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${frame_structure}=2/7    ${lncel_id}=1
    log to console    \nModify Frame Structure to ${frame_structure} with cell ${lncel_id}
    @{split_list}    string.split string    ${frame_structure}    separator=/
    ${tdd_frame_conf}    set variable    ${split_list[0]}
    ${tdd_spec_subf_conf}    set variable    ${split_list[1]}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=TDD subframe configuration
    ...    abbr=tddFrameConf
    ...    new_value=${tdd_frame_conf}
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=TDD special subframe configuration
    ...    abbr=tddSpecSubfConf
    ...    new_value=${tdd_spec_subf_conf}
    ${maxNumUeDlDwPTS}    set variable if    '${tdd_spec_subf_conf}'=='5'    0    8
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=Maximum amount of users per TTI in DL DwPTS
    ...    abbr=maxNumUeDlDwPTS
    ...    new_value=${maxNumUeDlDwPTS}

Modify Prach via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${prach_index}=4    ${lncel_id}=1
    log to console    \nModify Prach to ${prach_index} with cell ${lncel_id}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}/LNCEL_TDD-0
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=PRACH configuration index
    ...    abbr=prachConfIndex
    ...    new_value=${prach_index}

Modify Timing Shifter OFF via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    log to console    \nModify Timing Shifter Off
    ${stream}    get stream from version  version=${Active_SW_version}
    ${filter_param}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Activate cell timing offset
    ...    Activate eCPRI cell timing offset
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=0
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=${filter_param}
    ...    abbr=actCellTimingOffset
    ...    new_value=false

Modify Timing Shifter ON via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${lncel_id}=1    ${frameStartOffset}=3000    ${sfnOffset}=0
    log to console    \nModify Timing Shifter On with frameStartOffset ${frameStartOffset} sfnOffset ${sfnOffset}
    ${stream}    get stream from version  version=${Active_SW_version}
    ${filter_param}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Activate cell timing offset
    ...    Activate eCPRI cell timing offset
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=0
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=${filter_param}
    ...    abbr=actCellTimingOffset
    ...    new_value=true
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=Frame start offset
    ...    abbr=frameStartOffset
    ...    new_value=${frameStartOffset}
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=SFN offset
    ...    abbr=sfnOffset
    ...    new_value=${sfnOffset}

Modify Timing Shifter via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${timing_shifter}=ON    ${lncel_id}=1    ${frameStartOffset}=3000    ${sfnOffset}=0
    run keyword if    '${timing_shifter}'=='ON'    Modify Timing Shifter ON via Webem    lncel_id=${lncel_id}
    ...    frameStartOffset=${frameStartOffset}    sfnOffset=${sfnOffset}
    ...    ELSE IF    '${timing_shifter}'=='OFF'    Modify Timing Shifter OFF via Webem

Modify Activate modulation scheme DL via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${scheme_dl}=256QAM    ${lncel_id}=1
    log to console    \nModify actModulationSchemeDl to ${scheme_dl} with cell ${lncel_id}
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${lncel_id}
    ...    filter_param=Activate modulation scheme DL
    ...    abbr=actModulationSchemeDl
    ...    new_value=${scheme_dl}

Site General Modify via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${ru_index}=${None}    ${mimo_mode}=${None}    ${frame_structure}=${None}    ${prach_index}=${None}
    ...    ${timing_shifter}=${None}    ${scheme_dl}=${None}    ${frameStartOffset}=3000    ${sfnOffset}=0
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    FOR    ${cell_id}    IN    @{cell_id_list}
        run keyword if    '${mimo_mode}'!='${None}'
        ...    Modify Mimo Mode via Webem    mimo_mode=${mimo_mode}    lncel_id=${cell_id}
        run keyword if    '${frame_structure}'!='${None}'
        ...    Modify Frame Structure via Webem    frame_structure=${frame_structure}    lncel_id=${cell_id}
        run keyword if    '${prach_index}'!='${None}'
        ...    Modify Prach via Webem    prach_index=${prach_index}    lncel_id=${cell_id}
        run keyword if    '${timing_shifter}'!='${None}'
        ...    Modify Timing Shifter via Webem    timing_shifter=${timing_shifter}    lncel_id=${cell_id}
        ...    frameStartOffset=${frameStartOffset}    sfnOffset=${sfnOffset}
        run keyword if    '${scheme_dl}'!='${None}'
        ...    Modify Activate modulation scheme DL via Webem    scheme_dl=${scheme_dl}    lncel_id=${cell_id}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}

Active CRGPR via Webem
    [Arguments]  ${cell_id_list}    ${modify_crgpr}    ${add_crgpr_id}=${1}    ${cellResource}=${1}
    log to console  add CRGPR-${add_crgpr_id}
    ${crgpr_object_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ${crgpr_dist_name}    set variable    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/CRGPR-${add_crgpr_id}
    selenium_coam.set_parameter_value    dist_name=${crgpr_object_name}
    ...    filter_param=Cell resource sharing type    abbr=cellResourceSharingType    new_value=plmnBased
    FOR  ${cell_id}  IN  @{cell_id_list}
        selenium_coam.set_parameter_value    dist_name=${crgpr_object_name}/LNCEL-${cell_id}
        ...    filter_param=Assigned cell resource group profile    abbr=cellResourceGroupPrId    new_value=${cellResource}
    END
    selenium_coam.add_object    object_name=${crgpr_object_name}
    ...    object_class_name=CRGPR    is_load_default_values=${True}    id_value=${add_crgpr_id}    timeout=15
    selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
    ...    filter_param=Cell resource group subframe skipping threshold    abbr=crgSkipThreshold    new_value=${0}
    selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
    ...    filter_param=Default group    abbr=defaultGroupId    new_value=${1}
    selenium_coam.remove_element    dist_name=${crgpr_dist_name}
    ...    filter_param=Group Share List for Selective TTI Donation    abbr=groupShareListSelTtiDon
    FOR    ${index}    IN RANGE    0    2
        ${plmn_node_index}    set variable if    '${index}'=='0'    ${1}    ${3}
        selenium_coam.add_element    dist_name=${crgpr_dist_name}
        ...    filter_param=Group share list    abbr=groupShareList    timeout=15
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Group identifier    abbr=groupId
        ...    new_value=${modify_crgpr}[${index}][groupId]    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Cell resource group share    abbr=groupShare
        ...    new_value=${modify_crgpr}[${index}][groupShare]    node_index=${index}
        selenium_coam.add_element    dist_name=${crgpr_dist_name}
        ...    filter_param=PLMN group list    abbr=plmnGroupList    timeout=15
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Group identifier    abbr=groupId
        ...    new_value=${modify_crgpr}[${index}][groupId]    node_index=${plmn_node_index}
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Mobile country code    abbr=mcc
        ...    new_value=${modify_crgpr}[${index}][mcc]    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Mobile network code    abbr=mnc
        ...    new_value=${modify_crgpr}[${index}][mnc]    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=${crgpr_dist_name}
        ...    filter_param=Mobile network code length    abbr=mncLength
        ...    new_value=${modify_crgpr}[${index}][mncLength]    node_index=${index}
    END
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan
    sleep    60

Deactive CRGPR via Webem
    [Arguments]  ${cell_id_list}    ${add_crgpr_id}=${1}
    log to console  delete CRGPR-${add_crgpr_id}
    ${object_list}    selenium_coam.get_object_name_list    object_name=CRGPR-${add_crgpr_id}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object
    ...    object_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/CRGPR-${add_crgpr_id}    timeout=15
    ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ...    filter_param=Cell resource sharing type    abbr=cellResourceSharingType
    run keyword if    '${value}'!=''    selenium_coam.delete_parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ...    filter_param=Cell resource sharing type    abbr=cellResourceSharingType
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Assigned cell resource group profile    abbr=cellResourceGroupPrId
        run keyword if    '${value}'!=''    selenium_coam.delete_parameter
        ...    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Assigned cell resource group profile    abbr=cellResourceGroupPrId
    END
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60
