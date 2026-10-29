*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot

*** Keywords ***
WEBUI Remove Element For bwpDN
    [Arguments]    ${deleted_params}
    ${paramdel_len}    get length    ${deleted_params}
    FOR  ${i}  IN RANGE  ${paramdel_len}
        ${new_value}    Set Variable    ${deleted_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${deleted_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${deleted_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable    ${deleted_params[${i}]['dist_name']}
        log to console    “try ${i}, delete ${abbr} for ${deleted_params[${i}]['dist_name']}”
        WEBUI Remove Element
        ...   dist_name=${dist_name}
        ...   filter_param=${deleted_params[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

WEBUI Update Param For bwpDN
    [Arguments]    ${updated_params}
    ${paramlist_len}    get length   ${updated_params}
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${new_value}    Set Variable    ${updated_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${updated_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${updated_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable If    'NRCELL' in '${updated_params[${i}]['dist_name']}'
        ...    ${updated_params[${i}]['dist_name'].split('/')[-1]}    ${updated_params[${i}]['dist_name']}
        ${dist_name_for_globalF0ForRs}    Set Variable    ${updated_params[${i}]['dist_name']}
        ${dist_name}    Set Variable If    '${abbr}'=='globalF0ForRs'    ${dist_name_for_globalF0ForRs}    ${dist_name}
        log to console    “try ${i}, modify ${abbr} to ${new_value} for ${updated_params[${i}]['dist_name']}”
        WEBUI Set Param Value
        ...   dist_name=${dist_name}
        ...   filter_param=${updated_params[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

WEBUI Remove Element
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'=='${None}'    selenium_coam.remove_element
     ...   dist_name=${dist_name}
     ...   filter_param=${filter_param}
     ...   abbr=${abbr}
     ...   node_index=${node_index}


WEBUI Set Param Value
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'!='${None}'     selenium_coam.set_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   timeout=${600}

WEBUI Add Element For bwpDN
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_params}
    ${paramadd_len}    get length    ${added_params}
    FOR  ${index}  IN RANGE  ${paramadd_len}
        ${added_param_cell}    Set Variable    ${added_params[${index}]}
        WEBUI Add BwpDN For each cell    added_param_cell=${added_param_cell}
    END

WEBUI Add BwpDN For each cell
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_param_cell}
    ${cell_len}    get length    ${added_param_cell}
    FOR  ${i}  IN RANGE  ${cell_len}
        WEBUI Add BwpDN Operation    added_param_cell_per_bwpdn=${added_param_cell[${i}]}
    END

WEBUI Add BwpDN Operation
    [Documentation]   only for adding bwpDN and set parameter value
    [Arguments]   ${added_param_cell_per_bwpdn}
    ${paramadd_len}    get length    ${added_param_cell_per_bwpdn}
    selenium_coam.add_element
    ...    dist_name=${added_param_cell_per_bwpdn[${0}]['dist_name']}    filter_param=Cell bandwidth part list
    FOR  ${i}  IN RANGE  ${paramadd_len}
        ${new_value}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('node_index', ${0})}
        ${abbr}    Set Variable    ${added_param_cell_per_bwpdn[${i}].get('abbr', ${None})}
        ${dist_name}     Set Variable    ${added_param_cell_per_bwpdn[${i}]['dist_name']}
        log to console    “try ${i}, add ${abbr} to ${new_value} for ${added_param_cell_per_bwpdn[${i}]['dist_name']}”
        Run Keyword If    '${dist_name}'=='${added_param_cell_per_bwpdn[${0}]['dist_name']}'    WEBUI Set Param Value
        ...   dist_name=${dist_name}
        ...   filter_param=${added_param_cell_per_bwpdn[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END

Generate remove element for bwpDN
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     remove element in WebUI: bwpDN
    [Arguments]    ${cell_id}    ${delete_param_list}
    ${cellBwpList_length}    Get CellBwpList Length From SCF    cell_id=${cell_id}
    FOR    ${bwpdn_id}    IN RANGE    ${cellBwpList_length}
        ${bwpdn_param_delete}    Create Dictionary     dist_name=NRCELL-${cell_id}
        ...   filter_param=Bandwidth Part Profile distinguished name
        ...   abbr=bwpDN
        ...   node_index=${bwpdn_id}
        Append To List    ${delete_param_list}     ${bwpdn_param_delete}
    END


Generate add element for bwpDN
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     add element in WebUI: bwpDN
    [Arguments]    ${cell}    ${add_param_list}    ${cellBwpList_added}
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    @{add_bwpdn_per_cell}    create list
    ${cellBwpList_length}    Get CellBwpList Length From SCF    cell_id=${cell}
    FOR    ${node_index}    IN   @{cellBwpList_added}
        @{cellBwpList}    create list
        ${node_index0}    Evaluate    ${cellBwpList_length}+${node_index}
        ${node_index1}    Evaluate    ${cellBwpList_length}+${1}
        ${node_index2}    Evaluate    ${cellBwpList_length}+${2}
        ${node_index3}    Evaluate    ${cellBwpList_length}+${3}
        ${bwpDN_0}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn0_profile}
        ...                                  node_index=${cellBwpList_length}
        ${bwpDN_1}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn1_profile}
        ...                                  node_index=${node_index1}
        ${bwpDN_2}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn2_profile}
        ...                                  node_index=${node_index2}
        ${bwpDN_3}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=bwpDN
        ...                                  filter_param=Bandwidth Part Profile distinguished name
        ...                                  new_value=BWP_PROFILE-${bwpdn3_profile}
        ...                                  node_index=${node_index3}
        ${cellBwpId}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=cellBwpId
        ...                                  filter_param=Cell bandwidth part Identifier
        ...                                  new_value=str(${node_index})
        ...                                  node_index=${node_index0}
        ${pdcchResourcePreference}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=pdcchResourcePreference
        ...                                  filter_param=PDCCH resource preference mode
        ...                                  new_value=peakRate
        ...                                  node_index=${node_index0}
        ${actPdcchCceFragmentControl}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actPdcchCceFragmentControl
        ...                                  filter_param=Activate PDCCH CCE fragment control
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        ${actUpperThrAckNackFiltering}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actUpperThrAckNackFiltering
        ...                                  filter_param=Activate upper ACK/NACK filtering threshold
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        ${actUpperThrAckNackHrFiltering}     Create Dictionary     dist_name=NRCELL-${cell}
        ...                                  abbr=actUpperThrAckNackHrFiltering
        ...                                  filter_param=Activate upper ACK/NACK filtering threshold for high reliability DRB
        ...                                  new_value=false
        ...                                  node_index=${node_index0}
        Append To List    ${cellBwpList}     ${cellBwpId}    ${bwpDN_${node_index}}
        Append To List    ${add_bwpdn_per_cell}     ${cellBwpList}
    END
    Append To List    ${add_param_list}     ${add_bwpdn_per_cell}


Modify chBW And Related Parameters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...     for case:5603105, all default values are used for 80MHz configuration
    [Arguments]     ${cell_list}
    ...             ${configuration_type}=80MHz
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...             ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...             ${cellchBW_value}=80MHz
    ...             ${nrarfcn_value}=510024
    ...             ${csirsPower_value}=17
    ...             ${maxCsirsNumber_value}=1
    ...             ${actMultipleDedicatedBWPs_value}=true
    ...             ${actEnhMultipleDedicatedBWPs_value}=true
    ...             ${actPowerSavingBWP_value}=true
    ...             ${actDynPdcchTd_value}=false
    ...             ${gscnOrSsPbchArfcn_value}=6303
    ...             ${msg1FrequencyStart_value}=28
    ...             ${reqMinNumPuschPrb_value}=189
    ...             ${ssPbchBlockPower_value}=14
    ...             ${pMax_value}=327
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${timeout}=300
    ...             ${actDynPdcchTdMode}=disabled
    @{param_list}    Create List
    @{value_list}    Create List
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    ${bwpDN_0}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ${bwpDN_0_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_0_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn0_profile}
    ...                                 cellBwpId=0
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_1}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ${bwpDN_1_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_1_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn1_profile}
    ...                                 cellBwpId=1
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_2}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ${bwpDN_2_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_2_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn2_profile}
    ...                                 cellBwpId=2
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_3}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ${bwpDN_3_23R4}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ${bwpDN_3_master}     Create Dictionary    bwpDN=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/BWP_PROFILE-${bwpdn3_profile}
    ...                                 cellBwpId=3
    ...                                 actPdcchCceFragmentControl=false
    ...                                 pdcchResourcePreference=peakRate
    ...                                 actUpperThrAckNackFiltering=false
    ...                                 actUpperThrAckNackHrFiltering=false
    ${bwpDN_0} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1'    ${bwpDN_0_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_0_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_0}
    ${bwpDN_1} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_1_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_1_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_1}
    ${bwpDN_2} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_2_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_2_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_2}
    ${bwpDN_3} = 	Set Variable If
    ... 	       '${stream_version}'=='master' or '${stream_version}'=='24R1' 	${bwpDN_3_master}
    ... 	       '${stream_version}'=='23R4' 	    ${bwpDN_3_23R4}
    ... 	       '${stream_version}'=='23R3'      ${bwpDN_3}
    Run Keyword If    '${configuration_type}'=='80MHz'       Append To List    ${value_list}
    ...             ${bwpDN_0}    ${bwpDN_1}    ${bwpDN_2}    ${bwpDN_3}
    ...      ELSE      Append To List    ${value_list}      ${bwpDN_0}     ${bwpDN_1}
    &{periodicCsiAcquisition_param}    Create Dictionary     csirsPower=${csirsPower_value}
    ...                                                      maxCsirsNumber=${maxCsirsNumber_value}
    &{dynPdcchTdMgt_param}    Create Dictionary     actDynPdcchTd=${actDynPdcchTd_value}
    ${actMultipleDedicatedBWPs}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    ...                                   parameter=actMultipleDedicatedBWPs
    ...                                   value=${actMultipleDedicatedBWPs_value}
    Append To List    ${param_list}    ${actMultipleDedicatedBWPs}
    FOR    ${cell}   IN    @{cell_list}
        ${cellchBW}     Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=chBw
        ...                                   value=${cellchBW_value}
        ${nrarfcn}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=nrarfcn
        ...                                   value=${nrarfcn_value}
        ${actEnhMultipleDedicatedBWPs}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actEnhMultipleDedicatedBWPs
        ...                                   value=${actEnhMultipleDedicatedBWPs_value}
        ${actPowerSavingBWP}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actPowerSavingBWP
        ...                                   value=${actPowerSavingBWP_value}
        ${gscnOrSsPbchArfcn}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=gscnOrSsPbchArfcn
        ...                                   value=${gscnOrSsPbchArfcn_value}
        ${msg1FrequencyStart}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=msg1FrequencyStart
        ...                                   value=${msg1FrequencyStart_value}
        ${pMax}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=pMax
        ...                                   value=${pMax_value}
        ${reqMinNumPuschPrb}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=reqMinNumPuschPrb
        ...                                   value=${reqMinNumPuschPrb_value}
        ${ssPbchBlockPower}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=ssPbchBlockPower
        ...                                   value=${ssPbchBlockPower_value}
        ${cellBwpList}     Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=cellBwpList
        ...                                   value=${value_list}
        ${cellBwpList_delete}    Create Dictionary     dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=cellBwpList
        Append To List    ${delete_param_list}     ${cellBwpList_delete}
        ${dist_name}    Set Variable    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ${periodicCsiAcquisition}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'periodicCsiAcquisition','value':[&{periodicCsiAcquisition_param}]}
        ${dynPdcchTdMgt_23R3}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'dynPdcchTdMgt','value':[&{dynPdcchTdMgt_param}]}
        ${dynPdcchTdMgt_trunk}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                   parameter=actDynPdcchTdMode
        ...                                   value=${actDynPdcchTdMode}
        ${dynPdcchTdMgt}    Set Variable If      '${stream_version}'=='23R3'     ${dynPdcchTdMgt_23R3}    ${dynPdcchTdMgt_trunk}
        Append To List    ${param_list}    ${cellchBW}     ${nrarfcn}     ${actEnhMultipleDedicatedBWPs}
        ...               ${actPowerSavingBWP}    ${gscnOrSsPbchArfcn}    ${msg1FrequencyStart}    ${pMax}
        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}
        ...               ${periodicCsiAcquisition}   ${dynPdcchTdMgt}
        Append To List    ${add_param_list}     ${cellBwpList}
    END
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM delete parameters via rest api        parameters_to_delete_via_api=${delete_param_list}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}
    sleep    60s
    COAM add several parameters via rest api     parameters_to_add_via_api=${add_param_list}
    ...                                          timeout=${timeout}
    ...                                          connection=${connection}
    sleep    60s
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}   timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}



Get TDD large chbw cells
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     get 100M AEHC cells
    [Arguments]    ${aehc_nr_cell_list}
    ${large_chbw_nrcells_list}     Create List
    FOR    ${cell_index}    IN    @{aehc_nr_cell_list}
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        ${chbw}    coam_parameter.get_single_value_from_scf_file    parameter=chBw
        ...                                                         dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
        ...                                                         connection=GNB_OAM
        ...                                                         timeout=300
        Run Keyword if    "${chbw}"=="100MHz"    Append to list    ${large_chbw_nrcells_list}    ${cell_index}
    END
    [Return]    ${large_chbw_nrcells_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Start L3 call and Record tput with aasyslog
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     start sa l3 call and record tput with aasyslog, wo checking tput
    [Arguments]    ${cell_list}    ${ue_index}=${0}   ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${cell_type}=nr    ${ul_throughput}=220M    ${dl_throughput}=3000MKbits/sec
    ...            ${whether_do_ue_prepare}=${False}    ${whether_need_ue_log}=${False}
    ...            ${get_spark_license}=${true}
    log    ${cell_type}
    &{tput_file_for_upgrade}     Create Dictionary
    FOR    ${cell_index}    IN    @{cell_list}
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
        Trun Off All PA Ports
        Set PA value based on pcell index    pcell_index=${cell_index}    ue_index=${ue_index}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call
        ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
        ...    whether_check_tupt=${False}
        ...    notbarred_cell_index=${cell_index}
        ...    b1_select_cell_index=${cell_index}
        ...    expect_addition_scell_indexs=${None}
        ...    pcell_mapping=${None}
        ...    scell_mapping=${None}
        ...    list_cell_ids=all
        ...    enb_index=${fdd_enb_index}
        ...    whether_do_ue_prepare=${whether_do_ue_prepare}
        ...    whether_need_ue_log=${whether_need_ue_log}
        ...    ue_index=${ue_index}
        ...    get_spark_license=${get_spark_license}
        sleep    30sec
        ${host}   Start To Capture Aasyslog    gnb_index=${gnb_index}    du_index=${du_index}
        Sleep    180sec
        ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
        Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
        Set To Dictionary    ${tput_file_for_upgrade}    ${cell_index}=${tupt_file_path}
    END
    [Return]    ${tput_file_for_upgrade}

Check Tput from aasyslog file
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Descrition: Verify throughput from aasyslog file
    [Arguments]    ${tput_log}
    ...            ${expect_tput}=0
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${target_avg_percent}=0.8
    ...            ${min_percent}=0
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${direction}=UL
    ${ue_type}    Set Variable If   'spark' in '${ue_type}'    qct_dx50    ${ue_type}
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ${list_nrcell_ids}    check_android_ue_l3_call_process.Get NRCELLID based on CELLID
    ...    cellid=${cellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    ${aasyslog_TPUT}    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
    ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
    ...                                                           target_throughput=${expect_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    ${tput_result}    Evaluate    int(${aasyslog_TPUT[0]['average']})
    [Return]    ${tput_result}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections


Verify Test In Loop
    [Documentation]
    ...   Perform test verification in loop:
    ...   - check bts proper state before test,
    ...   - provide syslog collection,
    ...   - run test, then check for crashes in syslog and get test result,
    ...   - uuf_rfrl_common_keywords.Gather Snapshot if iteration failed,
    ...   - recover hardware if needed,
    ...   - provide report to Reporting portal,
    ...   - get PASS to FAIL ratio.
    [Arguments]    ${iteration_number}  ${should_be_reported}  ${test_keyword}
    csn.reset_cache
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    @{loop_results}=    Create List
    Set Test Variable  ${LOOP_RESULTS}
    @{fails_after_test}=    Create List
    &{kpis}=    Create Dictionary
    Set Test Variable  ${KPIS}  ${kpis}
    Set Test Variable  ${PASS_ITERATION}  ${0}
    FOR    ${i}    IN RANGE    1    ${iteration_number}+1
        Set Test Variable  ${i}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        Log    ${\n}Iteration_${i} of ${test_keyword} started : ${START_TIME}    console=yes
        ${iteration_result}    ${error}=    Run Keyword And Ignore Error    ${test_keyword}  i=${i}
        Run Keyword If  "${iteration_result}"=="FAIL"  Log  Loop_${i} Failed due to Error:${\n}${error}  ERROR  console=yes
        ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${iteration_result}
        Append To List    ${loop_results}    ${test_run_status}
        uuf_rfrl_common_keywords.Get Iteration End Time
        Run Keyword If  "${should_be_reported}" == "True"  uuf_rfrl_common_keywords.Report To Reporting Portal  ${test_run_status}
        Exit For Loop If    "${iteration_result}" == "FAIL"
    END
    uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
    List Should Not Contain Value    ${loop_results}    failed
    [Teardown]    Run Keywords
    ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
    ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
    ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
    ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports


Perform Lock Or Unlock Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    log    ${enb_connection}
    ${ru_type}    Set Variable If    '${tl_prefix}'=='T819'    AWHHJ    ${ru_type}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} Lock
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${gnb_state}    ${gnb_error_log}=     Run Keyword And Ignore Error
        ...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} Unlock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unlock cell Failed - ${test_unlock_phase}
    END

Perform BBMOD From All RU Reset with OAM KPI
    [Documentation]    xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${bbmod_distname_list}    Get BBMOD List For All RU
    ${loop_num}     Set Variable     1
    FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
		${test_phase}     Set Variable      Loop_${i}_${loop_num}
		uuf_rfrl_common_keywords.Get Iteration Start Time
		uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
		Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
		...                                                                              gnb_index=${0}
		Run Keyword And Ignore Error     coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
		 ...                timeout=${600}    connection=GNB_OAM
		Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
		${gnb_state}    ${gnb_error_log}=   Run Keyword And Ignore Error
		...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${enb_state}    ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
		...                                  Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}   ${gnb_state}
        ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
		${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    BBMOD RESET Failed - ${test_phase}
    END
    [Teardown]   Teardown GNB and ENB Connections

Get BBMOD List For All RU
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_productName}   Set Variable   ${bbmod_info['productName']}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
        Run Keyword If  '${bbmod_productName}'=='ABIA AirScale Capacity'
        ...             Remove From List   ${bbmod_distname_list}    -1
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Perform Special RU Reset with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=all    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['internal']}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only}==${False} and '${ru_type}'=='all'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
    END
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    ${loop_num}     Set Variable     1
    FOR    ${ru_index}    IN    @{aehc_ru_list}
        ${test_phase}     Set Variable      Loop_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
        Run Keyword And Ignore Error    coam.reset_unit    dist_name=${ru_index}     reset_type=Warm
        ...         force_radio_reset=${True}   connection=${connection}   timeout=${timeout}
        Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
		${gnb_state}    ${gnb_error_log}=    Run Keyword And Ignore Error
		...             Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
		...                                   Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
        ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
		${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    RU RESET Failed - ${test_phase}
		Exit For Loop If    "${test_result}" == "FAIL"
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Perform Block Or Unblock Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type_tmo}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    log    ${enb_connection}
    ${ru_type_tmo}    Set Variable If    '${tl_prefix}'=='T819'    AWHHJ    ${ru_type_tmo}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type_tmo}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${gnb_state}    ${gnb_error_log}=   Run Keyword And Ignore Error     Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}   ${gnb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Perform Reset with HWF deletion
    [Documentation]    author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}    Set Variable    loop_${i}
#    COAM Create log directory
    Common_setup_and_teardown.Create Case Log Path
#    ${swconfig_list}=   Create List    0x4F0214=0
#    Modify Swconfig File   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM    timeout=600
    sleep   2min
    ${gnb_status_status}   ${gnb_error_log}=    Run Keyword And Ignore Error    Check TMO Gnb Ready And All Cell On Air
    Check Gnb Startup Log
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_status_status}   ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}    ${gnb_status_status}   ${gnb_state}
    uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
	Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
#	FOR    ${enb_id}    IN RANGE    ${enb_length}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        coam.reset_site    connection=enblte_${enb_id}
#        sleep   5min
#        Wait until keyword succeeds    5 min    20 sec   Verify Enb All Cell On Air    enb_index=${enb_id}
#        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...   Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}  connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...  Unexpect History Alarm Should Not Exist  allowed_faults=@{ALLOWED_HISTORY_FAULT}   connection=enblte_${enb_id}
#    END
    Run Keyword If   '${test_result}'=='False'   Fail    Site Reset Failed - ${test_phase}
    [Teardown]      Run Keyword And Ignore Error    COAM Teardown gnb connections

Perform Lock Or Unlock LTE Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    log    ${enb_connection}
    ${ru_type1}      Set Variable If    '${tl_prefix}'=='T819'    AWMFIA
    ...                                 '${tl_prefix}'=='T080'    AHLOB    ${ru_type}
    ${ru_type2}      Set Variable If    '${tl_prefix}'=='T080'    AHFII    ${None}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type1}
    ...    ru_index=${ru_index}
    ${cell_list2}    Run Keyword If    '${ru_type2}'!='${None}'    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type2}
    ...    ru_index=${ru_index}
    ${cell_list}    Run Keyword If    '${ru_type2}'!='${None}'    Combine Lists    ${cell_list}    ${cell_list2}
    ...    ELSE    Set Variable    ${cell_list}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} Lock
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
		${test_result}    uuf_rfrl_common.Verify Iteration   ${test_unlock_phase}    ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} Unlock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unlock Cell Failed - ${test_unlock_phase}
    END

Perform Block Or Unblock LTE Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    log    ${enb_connection}
    ${ru_type1}      Set Variable If    '${tl_prefix}'=='T819'    AWMFIA
    ...                                 '${tl_prefix}'=='T080'    AHLOB    ${ru_type}
    ${ru_type2}      Set Variable If    '${tl_prefix}'=='T080'    AHFII    ${None}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type1}
    ...    ru_index=${ru_index}
    ${cell_list2}    Run Keyword If    '${ru_type2}'!='${None}'    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type2}
    ...    ru_index=${ru_index}
    ${cell_list}    Run Keyword If    '${ru_type2}'!='${None}'    Combine Lists    ${cell_list}    ${cell_list2}
    ...    ELSE    Set Variable    ${cell_list}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}   uuf_rfrl_common.Verify Iteration     ${test_unlock_phase}   ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Unexpect Alarm and History Alarm Should Not Exist
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${is_history_alarm_check}=${True}    ${allowed_history_faults}=${ALLOWED_HISTORY_FAULT}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...       connection=${connection}
    Run Keyword If    ${is_history_alarm_check}    Run Keyword And Continue On Failure
    ...    Unexpect History Alarm Should Not Exist   allowed_faults=${allowed_history_faults}
    ...       connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    Run Keyword And Continue On Failure        Check TMO Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...       connection=${connection}
#    Run Keyword And Continue On Failure     Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ...       connection=${connection}
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword And Continue On Failure     Wait Until Keyword Succeeds    5 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
        Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        Run Keyword And Continue On Failure
        ...   Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}  connection=enblte_${enb_id}
#        Run Keyword And Continue On Failure
#        ...  Unexpect History Alarm Should Not Exist  allowed_faults=@{ALLOWED_HISTORY_FAULT}   connection=enblte_${enb_id}
        Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_id}
    END
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Delta Commissioning With NR Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
     [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_actBeamControlImprovement1}    Get actBeamControlImprovement1 parameters in Gnb
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Update actBeamControlImprovement1 parameters with different value in Gnb   cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
	${gnb_state_diff}  ${gnb_error_log1}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_diff}  ${enb_error_log1}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update actBeamControlImprovement1 parameters with origin value in Gnb    cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
	${gnb_state_ori}  ${gnb_error_log2}=  Run Keyword And Ignore Error
	...               Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_ori}  ${enb_error_log2}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...       uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state_diff}    ${gnb_state_diff}    ${gnb_state_ori}    ${enb_state_ori}
    ...       ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}     ${gnb_state_ori}
	uuf_rfrl_common_keywords.Get Iteration End Time
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get actBeamControlImprovement1 parameters in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM    ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${timeout}=120
    log    ${connection}
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_actBeamControlImprovement1_value}    coam_parameter.get_single_value_from_scf_file    parameter=actBeamControlImprovement1
    ...                                 dist_name=${gnb_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_actBeamControlImprovement1_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actBeamControlImprovement1 parameters with origin value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actBeamControlImprovement1}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=actBeamControlImprovement1   value=${cur_actBeamControlImprovement1}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actBeamControlImprovement1 parameters with different value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actBeamControlImprovement1}    ${actBeamControlImprovement1}=false    ${connection}=GNB_OAM     ${timeout}=600
    ${modify_actBeamControlImprovement1}     set variable if   '${cur_actBeamControlImprovement1}'=='${actBeamControlImprovement1}'
    ...                              true    ${actBeamControlImprovement1}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=actBeamControlImprovement1    value=${modify_actBeamControlImprovement1}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections


Delta Commissioning With Online Parameter Modification with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
     [Arguments]    ${i}    ${cell_idx}=${PCELL_INDEX}    ${exp_status}=notBarred    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${600}
    ${test_phase}     Set Variable      Loop_${i}
    ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_idx}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_status}    coam_parameter.get_single_value_from_scf_file    parameter=cellBarred    dist_name=${dist_name}
    ...                                                               connection=${connection}      timeout=${timeout}
    ${exp_status}    Set Variable If    '${cell_status}'=='barred'    notBarred     barred
    ${params}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
    @{params_for_update}    create list
    Append to list      ${params_for_update}     ${params}
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    ${gnb_state}  ${gnb_error_log}=   Run Keyword And Ignore Error     Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    uuf_rfrl_common.Verify Iteration   ${test_phase}    ${gnb_state}
    Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Snapshot Log    timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With online Failed - ${test_phase}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Delta Commissioning With GSM Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_perTrxPower_value}    Get perTrxPower parameters in GSM cell
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update perTrxPower parameters with different value     cur_perTrxPower=${cur_perTrxPower_value}
	${gnb_state_diff}  ${gnb_log_diff}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_diff}  ${enb_log_diff}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update perTrxPower parameters with origin value    cur_perTrxPower=${cur_perTrxPower_value}
    ${gnb_state_origin}  ${gnb_error_origin}=  Run Keyword And Ignore Error
    ...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state_origin}  ${enb_error_origin}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...     uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}    ${gnb_state_origin}    ${enb_state_diff}   ${enb_state_origin}
    ...     ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state_diff}     ${gnb_state_origin}
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With GSM Reset Failed - ${test_phase}

Get perTrxPower parameters in GSM cell
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}     ${timeout}=120
    log    ${connection}
    ${gsm_case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${GSM_cell_INDEX}    ${gsm_case_params.get('gsm_cell_idx')}
    Set Test Variable    ${GSM_bts_INDEX}    ${gsm_case_params.get('gsm_bts_id')}
    Set Test Variable    ${GSM_bcf_INDEX}    ${gsm_case_params.get('gsm_bcf_id')}
    Set Test Variable    ${gsm_dist_name}    MRBTS-${MRBTS_id}/GNBTS-${GSM_bts_INDEX}/GNBCF-${GSM_bcf_INDEX}/GNCEL-${GSM_cell_INDEX}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_perTrxPower_value}    coam_parameter.get_single_value_from_scf_file    parameter=perTrxPower
    ...                                 dist_name=${gsm_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_perTrxPower_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update perTrxPower parameters with origin value
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_perTrxPower}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gsm_dist_name}    parameter=perTrxPower    value=${cur_perTrxPower}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update perTrxPower parameters with different value
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_perTrxPower}    ${perTrxPower}=393     ${connection}=GNB_OAM     ${timeout}=600
    ${modify_perTrxPower}     set variable if   '${cur_perTrxPower}'=='${perTrxPower}'      391      ${perTrxPower}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gsm_dist_name}    parameter=perTrxPower    value=${modify_perTrxPower}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Delta Commissioning With LTE Rat Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
    ${cur_actTransportSeparationLte_value}    Get actTransportSeparationLte parameters in LTE
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update actTransportSeparationLte parameters with different value in LTE    cur_actTransportSeparationLte=${cur_actTransportSeparationLte_value}
	${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
	Update actTransportSeparationLte parameters with origin value in LTE  cur_actTransportSeparationLte=${cur_actTransportSeparationLte_value}
    ${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
    ...           Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}

    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get actTransportSeparationLte parameters in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${timeout}=120
    log    ${connection}
    ${LTE_case_params}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']}
    Set Test Variable    ${LTE_bts_INDEX}    ${LTE_case_params.get('LTE_bts_id')}
    Set Test Variable    ${LTE_dist_name}    MRBTS-${MRBTS_id}/LNBTS-${LTE_bts_INDEX}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_actTransportSeparationLte_value}    coam_parameter.get_single_value_from_scf_file    parameter=actTransportSeparationLte
    ...                                     dist_name=${LTE_dist_name}    connection=GNB_OAM    timeout=${timeout}
    [Return]    ${cur_actTransportSeparationLte_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actTransportSeparationLte parameters with origin value in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actTransportSeparationLte}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${LTE_dist_name}    parameter=actTransportSeparationLte    value=${cur_actTransportSeparationLte}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update actTransportSeparationLte parameters with different value in LTE
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_actTransportSeparationLte}    ${actTransportSeparationLte}=true     ${connection}=GNB_OAM     ${timeout}=600
    ${modify_actTransportSeparationLte}     set variable if   '${cur_actTransportSeparationLte}'=='${actTransportSeparationLte}'    fasle    true
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${LTE_dist_name}    parameter=actTransportSeparationLte    value=${modify_actTransportSeparationLte}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Delta Commissioning With Site Reset Required with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}     Set Variable      Loop_${i}
#    ${cur_tuningProfile_value}    Get tuningProfile parameters in Gnb
    ${cur_totalDelayFromSHM_value}    Get totalDelayFromSHM parameter in Gnb
    uuf_rfrl_common_keywords.Get Iteration Start Time
    Update totalDelayFromSHM parameter with different value in Gnb    cur_totalDelayFromSHM_value=${cur_totalDelayFromSHM_value}
#    Update tuningProfile parameters with different value in Gnb     cur_tuningProfile=${cur_tuningProfile_value}
	${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
	...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_common_keywords.Get Iteration Start Time
#	Update tuningProfile parameters with origin value in Gnb     cur_tuningProfile=${cur_tuningProfile_value}
	Update totalDelayFromSHM parameter with origin value in Gnb    cur_totalDelayFromSHM_value=${cur_totalDelayFromSHM_value}
    ${gnb_state}  ${gnb_error_log}=  Run Keyword And Ignore Error
    ...                Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
	${enb_state}  ${enb_error_log}=  Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
	...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
	uuf_rfrl_common_keywords.Get Iteration End Time
	${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}   ${gnb_state}
    Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb   timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Commissioning With Site Reset Failed - ${test_phase}

Get tuningProfile parameters in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM      ${MRBTS_id}=${tl.gnbs[0].instance_id}   ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${timeout}=120
    log many    ${connection}    ${nr_bts_id}
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_tuningProfile_value}    coam_parameter.get_single_value_from_scf_file    parameter=tuningProfile
    ...                                dist_name=${gnb_dist_name}    connection=GNB_OAM     timeout=${timeout}
    [Return]    ${cur_tuningProfile_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update tuningProfile parameters with origin value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_tuningProfile}        ${connection}=GNB_OAM     ${timeout}=600
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=tuningProfile    value=${cur_tuningProfile}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update tuningProfile parameters with different value in Gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${cur_tuningProfile}    ${tuningProfile}=Normal    ${connection}=GNB_OAM     ${timeout}=600
    ${modify_tuningProfile}     set variable if   '${cur_tuningProfile}'=='${tuningProfile}'   Custom    ${tuningProfile}
    @{params_for_update}   create list
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=tuningProfile    value=${modify_tuningProfile}
    Append To List    ${params_for_update}    ${param}
    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get totalDelayFromSHM parameter in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]        ${connection}=GNB_OAM    ${MRBTS_id}=${tl.gnbs[0].instance_id}    ${timeout}=120
    log    ${connection}
    Set Test Variable    ${gnb_dist_name}    MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cur_totalDelayFromSHM_value}    coam_parameter.get_single_value_from_scf_file    parameter=totalDelayFromSHM
    ...                                                                                dist_name=${gnb_dist_name}
    ...                                                                                connection=GNB_OAM
    ...                                                                                timeout=${timeout}
    [Return]    ${cur_totalDelayFromSHM_value}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update totalDelayFromSHM parameter with different value in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]       ${cur_totalDelayFromSHM_value}    ${totalDelayFromSHM_value}=200    ${connection}=GNB_OAM    ${timeout}=600
    ${cur_totalDelayFromSHM_value_type}    Evaluate    type(${cur_totalDelayFromSHM_value}).__name__
    ${convert_cur_totalDelayFromSHM_value}    Create List    ${cur_totalDelayFromSHM_value}
    ${cur_totalDelayFromSHM_value_list}    Set Variable If    'list' in '${cur_totalDelayFromSHM_value_type}'
    ...    ${cur_totalDelayFromSHM_value}    ${convert_cur_totalDelayFromSHM_value}
    ${value_length}    Get Length    ${cur_totalDelayFromSHM_value}
    ${modify_totalDelayFromSHM}    Set Variable If
    ...    ${value_length}==${0}    ${totalDelayFromSHM_value}
    ...    ${value_length}!=${0} and '${cur_totalDelayFromSHM_value[0]}'=='${totalDelayFromSHM_value}'    210
    ...    ${totalDelayFromSHM_value}
    ${param}    Create Dictionary    dist_name=${gnb_dist_name}    parameter=totalDelayFromSHM    value=${modify_totalDelayFromSHM}
    ${params_for_update}    Evaluate    [${param}]
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Update totalDelayFromSHM parameter with origin value in Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]       ${cur_totalDelayFromSHM_value}    ${connection}=GNB_OAM    ${timeout}=600
    ${cur_totalDelayFromSHM_value_type}    Evaluate    type(${cur_totalDelayFromSHM_value}).__name__
    ${convert_cur_totalDelayFromSHM_value}    Create List    ${cur_totalDelayFromSHM_value}
    ${cur_totalDelayFromSHM_value_list}    Set Variable If    'list' in '${cur_totalDelayFromSHM_value_type}'
    ...    ${cur_totalDelayFromSHM_value}    ${convert_cur_totalDelayFromSHM_value}
    ${value_length}    Get Length    ${cur_totalDelayFromSHM_value}
    ${param}    Run Keyword If    ${value_length}==${0}    Create Dictionary    dist_name=${gnb_dist_name}
    ...                                                                         parameter=totalDelayFromSHM
    ...    ELSE IF    ${value_length}!=${0}    Create Dictionary    dist_name=${gnb_dist_name}
    ...    parameter=totalDelayFromSHM    value=${cur_totalDelayFromSHM_value[0]}
    ${params_for_update}    Evaluate    [${param}]
    Wait until keyword succeeds    2min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM
    Run Keyword If    ${value_length}!=${0}    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                                                                       timeout=${timeout}
    ...                                                                                       connection=${connection}
    ...    ELSE    COAM delete parameters via rest api    parameters_to_delete_via_api=${params_for_update}
    ...                                                   timeout=${timeout}
    ...                                                   connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Collect Snapshot Log in gnb and enb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${log_path}=${TS_CASE_LOG_PATH}     ${timeout}=${1200}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_index}
    ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}
    ...                                                         log_path=${log_path}
    ...                                                         timeout=${timeout}
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec   Connect to eNB via ssl   enb_index=${enb_id}    connection=enblte_${enb_id}
        ${snapshot_file_path}    COAM Save snapshot via rest api    connection=enblte_${enb_id}
        ...                                                         log_path=${log_path}
        ...                                                         timeout=${timeout}
        Run Keyword And Ignore Error    Enblte close down    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

SW_Upgrade_Rollback_with_OAM_KPI
    [Documentation]    Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ...          ${gnb_index}=0
    ...          ${test_iteration}=2
#    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported_input}=${True}
    ...          ${report_sw}=${None}
    ...          ${customers_list_input}=${customers}
#    ...          ${5g_source_sw}=${None}
#    ...          ${5g_target_sw}=${None}
#    ...          ${5g_target_sw_path}=${None}
    ...          ${4g_source_sw}=${None}
    ...          ${4g_target_sw}=${None}
    ...          ${4g_target_sw_path}=${None}
    ...          ${use_test_packages}=${False}
    ...          ${use_builds_storage}=${False}
    ...          ${restore_to_target_sw}=${False}
    ...          ${remote_node_update}=${False}
    ...          ${use_remote_node}=${True}
    ...          ${download_path}=${None}
    ...          ${local_node_attach_test_keyword}=${None}
    ...          ${remote_node_attach_test_keyword}=${None}
    ...          ${perform_uboot_downgrade}=${False}
    ...          ${disable_syslog_check}=${False}
    ...          ${user_suspicious_prints}=@{EMPTY}
    ...          ${report_comment}=${None}
    ...          ${qc_domain_input}=MN_RAN
    ...          ${qc_project_input}=RAN_VRF
    ...          ${qc_id_input}=664023
    ...          ${comment_input}=${None}
    ...          ${whether_during_energy_save_mode}=${False}
    ${custom_alarms}      Create List     ${4203}   ${4459}    ${8000}    ${1932}   ${1933}    ${1934}    ${61631}   ${4293}   ${4297}
    ...                                   ${4589}   ${7307}    ${4741}    ${1815}    ${6261}    ${7535}    ${7525}
    Set Test Variable       ${custom_alarms}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${gnb_current_version}    coam.get_sw_version    timeout=60    connection=${connection}
    ${new_sw_version}   Evaluate    "_".join(["SBTS00", "${gnb_current_version.split("_", 1)[1]}"])
    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${gnb_current_version}    9999    9990
    ${gnb_current_version}    Set Variable If    ${is_trunk}    ${new_sw_version}    ${gnb_current_version}
	Set Test Variable    ${5g_source_sw}        ${gnb_current_version}
    Set Test Variable    ${5g_target_sw_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${5g_target_sw}        ${package_version_1525-CA}
    Download SW Build from artifactory
    Run keyword and ignore error    COAM Teardown gnb connections
    Set Test Variable    ${should_be_reported}    ${should_be_reported_input}
    Set Test Variable    ${customers_list}    ${customers_list_input}
    Set Test Variable    ${qc_domain}    ${qc_domain_input}
    Set Test Variable    ${qc_project}    ${qc_project_input}
    Set Test Variable    ${qc_id}    ${qc_id_input}
    Set Test Variable    ${comment}    ${comment_input}
    uuf_rfrl_common_keywords.Common Test Setup   ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    ...  ${disable_syslog_check}  ${user_suspicious_prints}  ${report_comment}  ${qc_domain}  ${qc_project}  ${qc_id}
    uuf_rfrl_common_keywords.Update Rollback Test Setup  ${5g_source_sw}  ${5g_target_sw}  ${5g_target_sw_path}
    ...  ${4g_source_sw}  ${4g_target_sw}  ${4g_target_sw_path}  ${use_builds_storage}  ${remote_node_update}
    ...  ${download_path}  ${use_test_packages}  ${perform_uboot_downgrade}  ${report_sw}
    Attach Test Setup   ${local_node_attach_test_keyword}  ${remote_node_attach_test_keyword}
    IF    ${whether_during_energy_save_mode}
        uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  ${should_be_reported}  Upgrade Test With Enengy Save Mode
    ELSE
        uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  ${should_be_reported}  uuf_rfrl_common_keywords.Upgrade Test
    END
    [Teardown]  Run Keywords  Run Keyword If  ${restore_to_target_sw}  uuf_rfrl_common_keywords.Restore To Target SW
    ...  AND  Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...  Run Keyword If  ${MUMIN}  uuf_rfrl_common.Mumin Teardown  AND
    ...  uuf_rfrl_common.Log Update Results

Upgrade Test With Enengy Save Mode
    [Arguments]  ${test_phase}=${EMPTY}
    Set Test Variable  ${CELL_DOWNTIME}  ${None}
    Log  ${UPDATE_TEST_VARIABLES}
    admin.Teardown All Aliases For Admin
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    ...                                                 reportAmountCA_value=r2
    ...                                                 qRxLevMin_value=-60
    ...                                                 actBadUplinkRadioRedirect_vlaue=highUlBlerBased
    ...                                                 ulBlerThresholdRedirectData=40
    ...                                                 ulBlerThresholdRedirectVoNR=20
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=360
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Set Test Variable    ${recover_hour}    ${hour}
    Set Test Variable    ${recover_minute}    ${minute}
    Set Test Variable    ${recover_lbpsCellList_num}    ${lbpsCellList_length}
    Set Test Variable    ${recover_lbpsCellPeriodList_num}    ${lbpsCellPeriodList_length}
    uuf_rfrl_common_keywords.Software Update  ${UPDATE_TEST_VARIABLES["1st_bts"]["target_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["target_sw_path"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  uuf_rfrl_common_keywords.Software Update  ${UPDATE_TEST_VARIABLES["2nd_bts"]["target_sw"]}
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["target_sw_path"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=80
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Sleep  30sec
    Update Related Parameters For Exit Energy Saving    cell_list=${cell_list}
    Wait Until Keyword Succeeds    55 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                                whether_check_energy_saving=${False}
    uuf_rfrl_common_keywords.Software Rollback  ${UPDATE_TEST_VARIABLES["1st_bts"]["source_sw"]}  ${test_phase}
    ...  ${UPDATE_TEST_VARIABLES["1st_bts"]["remote_node"]}
    Run Keyword If  "${REMOTE_VM_IP}" != "None" and "${REMOTE_NODE_UPDATE}" == "True"
    ...  uuf_rfrl_common_keywords.Software Rollback  ${UPDATE_TEST_VARIABLES["2nd_bts"]["source_sw"]}
    ...  ${test_phase}  ${UPDATE_TEST_VARIABLES["2nd_bts"]["remote_node"]}
    Update Related Parameters For Energy Saving    Duration=10
    ...                                            Hour=${recover_hour}
    ...                                            Minute=${recover_minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Check TMO Gnb Ready And All Cell On Air
    [Teardown]   Run Keyword If  ${USE_TEST_PACKAGES}  uuf_rfrl_common.Update Target SW Variable

Local_node_attach_test_keyword
    [Documentation]    Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${cell_used_in_test}=${False}   ${remote}=${False}
#    COAM Create log directory
    log    ${cell_used_in_test}
    log    ${remote}
    Common_setup_and_teardown.Create Case Log Path
    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr   whether_get_first_ru_only=True
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${ue_index}    Set Variable If    '${tl_prefix}'=='T080'    ${15}    ${0}
    Set Test Variable    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Multi-UE_Case_Setup    ue_index=${ue_index}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Procedures.Verify CA Basic L3 Call    ue_index=${ue_index}
    ...                                   ue_type=${ue_type1}
    ...                                   ul_throughput=250M
    ...                                   dl_throughput=2000MKbits/sec
    ...                                   whether_need_ue_log=${False}
    ...                                   notbarred_cell_index=${PCELL_INDEX_${ue_index}}
    ...                                   b1_select_cell_index=${PCELL_INDEX_${ue_index}}
    ...                                   expect_addition_scell_indexs=${SCELL_INDEX_LIST_${ue_index}}
    ...                                   start_keep_on_duration=1200
    ...                                   whether_do_ue_prepare=${False}
    ...                                   ignore_time=1min
    ...                                   tput_collect_duration=120
    ...                                   pcell_mapping=${PCELL_MAPPING_${ue_index}}
    ...                                   scell_mapping=${SCELL_MAPPING_${ue_index}}
    ...                                   target_DL_avg_percent=0.1
    ...                                   target_UL_avg_percent=0.1
    ...                                   min_DL_percent=0.1
    ...                                   min_UL_percent=0.1
    ...                                   list_cell_ids=${None}
    ...                                   check_scell_tput=${False}
    ...                                   enb_index=${fdd_enb_index}
    [Teardown]   Run Keywords
    ...    run keyword and ignore error    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}    AND
    ...    Teardown GNB and ENB Connections

Perform Block Or Unblock GSM Single Cell On Special RU with OAM KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${i}   ${ru_type}=AHFII   ${cell_type}=gsm    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    log    ${enb_connection}
    ${ru_type}      Set Variable If    '${tl_prefix}'=='T816'        AHFIG
    ...                                '${tl_prefix}'=='T073'       AHFIB     ${ru_type}
    ${cell_list}    Get GSM Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${loop_num}     Set Variable     1
    FOR    ${cell_index}    IN    @{cell_list}
        ${test_lock_phase}     Set Variable      Loop_lock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_lock_phase} block
        sleep   10s
        ${test_unlock_phase}     Set Variable      Loop_unlock_${i}_${loop_num}
        uuf_rfrl_common_keywords.Get Iteration Start Time
        uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        ${enb_state}    ${enb_error_log}=    Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
        ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
        ${test_result}   uuf_rfrl_common.Verify Iteration     ${test_unlock_phase}   ${enb_state}
		uuf_rfrl_common_keywords.Get Iteration End Time
		uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_unlock_phase} unblock
        ${loop_num}   Convert To Integer     ${loop_num}
		${loop_num}    Evaluate     ${loop_num}+1
		Run Keyword If   '${test_result}'=='False'   Common_keywords.Collect Enb Snapshot Log    timeout=${2400}
		Run Keyword If   '${test_result}'=='False'   Fail    unblock Cell Failed - ${test_unlock_phase}
    END

Get GSM Cell List For Special RU
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Log to console    ${\n}----Get all ${cell_type} cells For Special RU ${ru_type}----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${aehc_ru_list_new}    Remove Duplicates    ${aehc_ru_list}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{aehc_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        Append To List     ${aehc_ru_list_new}    ${cell_id}
    END
    [Return]     ${aehc_ru_list_new}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get mutiple nonGBR PDU IP Address From Wireshark
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    [Arguments]    ${cpif_log_path}    ${is_multi_pdu}=${False}    ${alias}=parser    ${mode}=SA
    log    ${is_multi_pdu}
    ${pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 29 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...                                                                       s1ap.procedureCode == 19 && nas_eps.esm.pdn_ipv4
    ${pdu_ip_xpath}    Set Variable If     '${mode}'=='SA'    .//_[4]/nas_5gs.sm.pdu_addr_inf_ipv4   .//nas_eps.esm.pdn_ipv4
    ${dnn_xpath}    Set Variable If     '${mode}'=='SA'    .//nas_5gs.cmn.dnn    .//nas_eps.esm.qci
    ${pdu_ip_dnn_dict}    Create Dictionary
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd}    alias=${alias}
    ${pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${pdu_ip_dnn_pair}    Evaluate    list(zip(${pdu_ip},${dnn_value}))
    FOR  ${item}  IN  @{pdu_ip_dnn_pair}
      ${ip_type}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_type}    ${item[0]}
    END
    Log to console    All pdu ip address are : ${pdu_ip_dnn_dict}
    run keyword if  not ${pdu_ip_dnn_dict}    Fail    msg=fail to get ue ip from wireshark。
    [Return]    ${pdu_ip_dnn_dict}

Get KPI Report with difference RSRP in 15min
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${spark_ue_logpath}    ${folder_index}=1   ${start_L3_call}=True    ${good}=good    ${mid}=mid    ${bad}=bad
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
	${start_L3_call}    Get time to start L3 call
	${call_start_fisrt}     ${call_end_fisrt}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...                  logname=run_${folder_index}_1
	...                  enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}    whether_do_ue_prepare=True
    ${start_L3_call}    Get time to start L3 call
	${call_start_second}     ${call_end_second}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...    logname=run_${folder_index}_2
	...    enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}
	${start_L3_call}    Get time to start L3 call
	${call_start_third}     ${call_end_third}    Run Keyword If    ${start_L3_call}
	...                  Get KPI Report with difference RSRP and TP in 15min    logpath=${spark_ue_logpath}
	...    logname=run_${folder_index}_3
	...    enb_index=${fdd_enb_index}    good=${good}    mid=${mid}    bad=${bad}
    Get time to start L3 call
    sleep   361s
    Run Keyword And Continue On Failure    Get KPI Report from gnb and enb    folder_index=${folder_index}
    Get start time and end time with call in 15min    call_start_fisrt=${call_start_fisrt}
    ...                             call_end_fisrt=${call_end_fisrt}
    ...                             call_start_second=${call_start_second}
    ...                             call_end_second=${call_end_second}
    ...                             call_start_third=${call_start_third}
    ...                             call_end_third=${call_end_third}
    Common_keywords.Collect Snapshot Log    log_path=${remote_log_path}


Get KPI Report with difference RSRP and TP in 15min
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${logpath}=${None}       ${logname}=${None}    ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...            ${ue_type}=${ue_type}    ${ue_mode}=SA
    ...            ${du_index}=0	 ${hwcheck_index}=${1} 	${power_reset}=False	${5Gstatus}=PASS     ${scell_addition_method}=A1
    ...            ${protocol}=udp    ${start_keep_on_duration}=640     ${whether_check_scell_addition}=${False}
    ...            ${whether_do_ue_prepare}=${True}
    ...            ${expect_addition_scell_indexs}=${SCELL_INDEX_LIST}   ${pcell_mapping}=${PCELL_MAPPING}
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${apn_address}=${tl.core.pdns[0].apn}    ${whether_need_ue_log}=${True}     ${whether_do_lte_barred_action}=${False}
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log     ${enb_index}=${1}    ${common_unit_index}=${0}
    ...            ${sleep_interval}=5 sec      ${check_pcell_tput}=${True}    ${check_scell_tput}=${True}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf    ${dl_process_num}=${2}
    ...            ${list_cell_ids}=${LTE_CELL_INDEX}      ${whether_do_lte_cell_locked}=${False}   ${min_scell_percent}=0.05
    ...            ${whether_change_fren}=${True}          ${gnb_index}=${0}
    ...            ${DL_Peak_TP}=DL_Peak_TP      ${UL_Peak_TP}=UL_Peak_TP    ${DL_mid_TP}=DL_mid_TP        ${UL_mid_TP}=UL_mid_TP
    ...            ${DL_bad_TP}=DL_bad_TP        ${UL_bad_TP}=UL_bad_TP
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${wireshark_log_prefix}=cpif_attach
    ...            ${coam_connection}=GNB_OAM
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${common_unit_index}=${0}
    ...            ${hwcheck_index}=${1}
    ...            ${detach_request}=${true}
    ...            ${power_reset}=False
    ...            ${4G_check}=True      ${get_spark_license}=${false}
    ...            ${buffer_size}=1400B    ${appserver}=APPserver        ${buffer_size_ul}=2048
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}
    ...            ${good}=good    ${mid}=mid    ${bad}=bad      ${UTC_timezone}=${False}
    log many    ${5Gstatus}    ${scell_addition_method}    ${whether_check_scell_addition}
    ...    ${expect_addition_scell_indexs}    ${pcell_mapping}    ${scell_mapping}    ${whether_do_lte_barred_action}
    ...    ${check_pcell_tput}    ${check_scell_tput}    ${dl_process_num}    ${list_cell_ids}
    ...    ${whether_do_lte_cell_locked}    ${min_scell_percent}    ${whether_change_fren}
    ...    ${DL_mid_TP}    ${UL_mid_TP}    ${DL_bad_TP}    ${UL_bad_TP}    ${buffer_size}
    ...    ${appserver}    ${buffer_size_ul}    ${seg_size}    ${window}    ${ul_process_num}
#    ${whether_do_ue_prepare}     Set Variable If   '${tl_prefix}'=='T284'    True     False
    ${get_spark_license}     Set Variable If   '${tl_prefix}'!='T284'    True     False
    # prepare ue
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    ${whether_do_ue_prepare}    Run Keyword And Continue On Failure    Procedures.Start UE Prepare
    ...    ue_index=${ue_index}    ue_type=${ue_type}      get_spark_license=${get_spark_license}
    ...   detach_request=${detach_request}      power_reset=${power_reset}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start special UE Log    ue_index=${ue_index}    logpath=${logpath}    logname=${logname}
#    Run Keyword If    '${tl_prefix}'=='T080' and ${whether_do_ue_prepare}    Lock UE band n41 in X75
#    ...                ue_index=${ue_index}
    ${4G_check}    Set Variable If    '${ue_mode}'=='NSA'    True    False
    ${call_start_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    kill DL iperf port     dl_port=${tl.ues[${ue_index}].iperf_details.port}
#    Close the iperf in UE      ue_index=${ue_index}     ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${good}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${curr_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${timeToSleep}    Caculate timeToSleep Before Next Counters Period
    sleep     ${timeToSleep}
    ${call_attach_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_attach_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${5Grach_ed}    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    Sleep    30sec
    Run Keyword If     '${ue_type}'=='huawei_sigspark'
    ...                Spark_common_keywords.Start UE Attach in X65 multi UE x65   ue_index=${ue_index}
    Sleep    30sec
    ${DL_max_TP}    Set Variable    ${KPI_PA['${tl_prefix}']['${DL_Peak_TP}']}
    ${UL_max_TP}    Set Variable    ${KPI_PA['${tl_prefix}']['${UL_Peak_TP}']}
    Run Keyword If   '${tl_prefix}'=='T080'     sleep    2s
    Run Keyword If   '${tl_prefix}'=='T080'     Set test Variable    ${ue_ip_address}    172.250.164.56
    Run Keyword If   '${tl_prefix}'=='T284'     Set test Variable    ${ue_ip_address}    172.250.164.52
    Run Keyword If   '${tl_prefix}'=='T283'     Set test Variable    ${ue_ip_address}    172.250.164.26
    Run Keyword If   '${tl_prefix}'=='T813'     Set test Variable    ${ue_ip_address}    172.250.164.37
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${DL_max_TP}
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${ue_iperf_path}    iperf
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    Procedures.Start TMO L3 Call    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             protocol=${protocol}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ul_throughput=${UL_max_TP}
    ...                             dl_throughput=${DL_max_TP}
    ...                             apn_address=${apn_address}
    ...                             iperf_path=${iperf_path}
    ...                             dl_process_num=${process_num}
    ...                             ue_type=${ue_type}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${mid}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${bad}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${mid}
    sleep     120s
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${ue_index}    RSPR_PA=${good}
    sleep     120s
    Run Keyword And Continue On Failure    Procedures.Stop TMO L3 Call And Detach
    ...    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    ${call_end_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${timeToSleep}    Caculate timeToSleep Before Next Counters Period
    Run Keyword If    ${UTC_timezone}    sleep     ${timeToSleep}
    ${call_end_time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_UTC}=    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index_first}    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index_first}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index_first}
    ${attach_cell_index}    Set Variable If    '${ue_mode}'=='NSA'    ${b1_select_cell_index}    ${notbarred_cell_index}
    ${Pcell_attach}    run keyword and return status    Should Be Equal As Integers    ${attach_info['attach_cell_index']}
    ...   ${attach_cell_index}
    ${L3_call_succesful}    Set Variable If   '${Pcell_attach}'=='True'    True    False
    ${call_attach_time}      Set Variable If   ${UTC_timezone}    ${call_attach_time_UTC}     ${call_attach_time}
    ${call_end_time}      Set Variable If   ${UTC_timezone}    ${call_end_time_UTC}     ${call_end_time}
    [Return]    ${L3_call_succesful}    ${call_attach_time}     ${call_end_time}
    [Teardown]    Run Keywords    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'
    ...    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop special UE Log    ue_index=${ue_index}   AND
    ...    Run Keyword And Ignore Error     Recover Collect Syslog On GNB


Modify Attenuation Vaule For KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${attenuator_list}    ${ue_index}=${0}  ${RSPR_PA}=${good}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Attenuation Vaule For KPI    ue_index=${ue_index}    RSPR_PA=${RSPR_PA}
        ...    ELSE IF    '${attenuator}'=='mcs'    Modify MCS Attenuation Vaule For KPI    ue_index=${ue_index}   RSPR_PA=${RSPR_PA}
        ...    ELSE IF    '${attenuator}'=='radiorack'    Modify Radiorack Attenuation Vaule For KPI
        ...    ue_index=${ue_index}   RSPR_PA=${RSPR_PA}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

Modify PA Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}   ${RSPR_PA}=${good}
    log many    ${modify_ru_id}     ${pa_off_value}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${attenuator_KPI}    Set Variable    ${KPI_PA['${tl_prefix}']}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${pcell_ru_index}']}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_id[0]}]}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels_num}
        ${PA_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel}']}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${PA_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}


Modify Radiorack Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}   ${RSPR_PA}=${good}
    log many    ${modify_ru_id}    ${pa_off_value}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${attenuator_KPI}    Set Variable    ${KPI_PA['${tl_prefix}']}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${pcell_ru_index}']}
    ${ip_addr}    set variable     ${tl.attenuator[${attenuator_id[0]}].ip_addr}
    ${port}    set variable     ${tl.attenuator[${attenuator_id[0]}].port}
    ${vendor}    set variable    ${tl.attenuator[${attenuator_id[0]}].vendor}
    ${model}    set variable     ${tl.attenuator[${attenuator_id[0]}].model}
    @{channels}    Set Variable    ${tl.attenuator[${attenuator_id[0]}].attenuator_ports}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels_num}
        ${PA_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel}']}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${PA_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${port}    IN    @{ports}
        ${port}    Convert To Integer    ${port}
        ${value}    Evaluate    float(${value})
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${port}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
    END
    FOR    ${port}    IN    @{ports}
        ${new_value}    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.read_attenuation
        ...    port=${port}   attenuator_device=${configured_attenuator}
        Lists Should Be Equal    ${new_value}    ${value}    msg=Attenuation set failed
    END

Modify MCS Attenuation Vaule For KPI
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}    ${RSPR_PA}=${good}
    log   ${ue_index}
    ${channels_num}     Get Dictionary Keys    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']}
    ${channel_0}    Set Variable    ${channels_num[0]}
    ${att_value}    Set Variable    ${KPI_PA['${tl_prefix}']['${RSPR_PA}']['${channel_0}']}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...                                                begin_output_port=${1}    end_output_port=${4}
    ...                                                begin_input_port=${1}    end_input_port=${64}

TMO_Common_Suite_Setup_KPI
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${whether_do_prepare_ue}=${True}
    ...            ${ue_index}=${0}    ${ute_space}=20    ${prefer_5g_nr_mode}=SA
    log many    ${whether_do_prepare_ue}    ${prefer_5g_nr_mode}
#    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    ${stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Set Suite Variable    ${stream_version}
    # get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
#    ${SCOUT_TL_NAME}=  Set Variable If    '${tl_prefix}'=='T813' or '${tl_prefix}'=='T284'    ${testline_name}_5G    ${testline_name}
#    Set Suite Variable    ${SCOUT_TL_NAME}
    ${ue_index}    Set Variable     ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    # get how many UEs
    ${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}
    # get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    ${dict_enb_Technology_index}    Get LTE Technology Value
    Set Suite Variable    ${DICT_ENB_TECHNOLOGY_INDEX}    ${dict_enb_Technology_index}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Check And Clear TestPC Space    ute_space=${ute_space}
    Kill Adb App    ue_index=${ue_index}
    &{fault_4203}     Create Dictionary     faultId=${4203}
    &{fault_4459}     Create Dictionary     faultId=${4459}
    &{fault_8000}     Create Dictionary     faultId=${8000}
    &{fault_1932}     Create Dictionary     faultId=${1932}
    &{fault_1933}     Create Dictionary     faultId=${1933}
    &{fault_1934}     Create Dictionary     faultId=${1934}
    &{fault_61631}     Create Dictionary     faultId=${61631}
    &{fault_1838}     Create Dictionary     faultId=${1838}
    &{fault_4741}     Create Dictionary     faultId=${4741}
    &{fault_4681}     Create Dictionary     faultId=${4681}
    &{fault_4334}     Create Dictionary     faultId=${4334}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    &{fault_4298}     Create Dictionary     faultId=${4298}
    &{fault_4293}     Create Dictionary     faultId=${4293}
    &{fault_1898}     Create Dictionary     faultId=${1898}
    &{fault_251}     Create Dictionary     faultId=${251}
    &{fault_4475}     Create Dictionary     faultId=${4475}
    &{fault_4476}     Create Dictionary     faultId=${4476}
    &{fault_4476}     Create Dictionary     faultId=${4476}
    &{fault_4297}     Create Dictionary     faultId=${4297}
    ${GNB_ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_4203}    ${fault_4459}   ${fault_1932}
    ...    ${fault_1934}    ${fault_4298}
    ...    ${fault_1838}     ${fault_4741}    ${fault_1933}    ${fault_4681}    ${fault_4334}    ${fault_7311}
    ...    ${fault_4293}   ${fault_1898}   ${fault_251}   ${fault_4475}   ${fault_4476}   ${fault_4297}
    Set Suite Variable    ${GNB_ALLOWED_FAULT}
    robot_common_operations.Common Suite Setup
    Suite Log Path Create
    Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}
    Perform gNB Reset site and Wait Onair

Commission SCF with gnb version
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ${scf_stream_version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=/home/ute/SCF/${tl_prefix}_gNB_${scf_stream_version}.xml
    ...                                     connection=GNB_OAM
    ...                                     timeout=900
    ...                                     is_pdl_checking_needed=${True}
#    Run Keyword If    '${tl_prefix}'=='T284'     Connect to eNB via ssl    enb_index=0   connection=enblte_0
#    ${enb_SW_Info}=   Run Keyword If    '${tl_prefix}'=='T284'    coam.get_software_info    timeout=300    connection=enblte_0
#    ${enb_scf_version_tmp}=     Run Keyword If    '${tl_prefix}'=='T284'    Get from dictionary    ${enb_SW_Info}    Active SW version
#    ${enb_scf_version_tmp}    Split String    ${enb_scf_version_tmp}    _
#    ${enb_scf_version}    Replace String Using Regexp    string=${enb_scf_version_tmp[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    Run Keyword If    '${tl_prefix}'=='T284'     COAM Commission with scf file
#    ...                                     scf_file_path=/home/ute/SCF/${tl_prefix}_FDDeNB_${enb_scf_version}.xml
#    ...                                     connection=enblte_0
#    ...                                     timeout=900
#    ...                                     is_pdl_checking_needed=${True}
#    Run Keyword And Ignore Error    Enblte close down    connection=enblte_0
    Sleep    10min
    Check TMO Gnb Ready And All Cell On Air
    Run Keyword And Continue On Failure    Verify All Enbs Cell On Air

