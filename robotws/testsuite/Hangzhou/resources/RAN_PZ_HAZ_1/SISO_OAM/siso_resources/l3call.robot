*** Settings ***
Documentation
...    Author:        qiang.1.zhou@nokia.com
...    Maintainer:    qiang.1.zhou@nokia.com

Library    ./SISO_CPE.py
Library    Collections
Resource   ./basic_call_for_5G.robot
Resource   ./tools/attenuator_interface.robot
Resource   ./ue.robot
Resource   ./tput_config.robot
Resource   ./CPE.robot
Resource   ./SISO_UE.robot



*** Keywords ***
Get Matched Ue Info
    [Arguments]    ${band}    ${network_type}    ${pa_ids}    ${technology}=${EMPTY}
    ${ue_list}    Set Variable      ${tl_config.UE_INFO}
    ${matched_ue_info}    Get Matched Ue     ${band}    ${ue_list}    ${network_type}   ${technology}    ${pa_ids}
    Set Test Variable     ${matched_ue_info}
    ${MATCHED_UE_INFO}    Set Variable   ${matched_ue_info}
    Set Test Variable    ${MATCHED_UE_INFO}
    [Return]    ${matched_ue_info}

Get Related Cell Info With PCI
    [Arguments]    ${cell_list}   ${cell_info}
    ${RF_list}    Create List
    ${not_has_key}   Run Keyword And Return Status   Dictionary Should Not Contain Key    ${cell_info}    related_cell
    Return From Keyword If    ${not_has_key}    ${RF_list}
    FOR    ${pci}   IN    @{cell_info["related_cell"]}
        ${related_cell_info}   Get Cell Info With PCI   ${cell_list}    ${pci}
        ${RF_list}    Combine Lists    ${RF_list}    ${related_cell_info["RF"]}
    END
    [Return]   ${RF_list}

Get Runtime arfcnSsbPbch
    [Arguments]    ${cell_info}
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${nr_cell_id}    Set Variable    ${cell_info["nrCellId"]}
    ${nrcell_r_list}    coam.get managed objects    class_name=NRCELL_R    connection=${CASE_NAME}_${bts_id}
    FOR    ${nrcell_r}    IN    @{nrcell_r_list}
        Return From Keyword If    "${nrcell_r["parameters"]["nrCellIdentity"]}"=="${nr_cell_id}"
        ...    ${nrcell_r["parameters"]["arfcnSsbPbch"]}
    END

Get EARFCN
    [Arguments]   ${cell_info}
    ${network_type}   Set Variable   ${cell_info["NetworkType"]}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${arfcnSsbPbch}    Run Keyword If    '${network_type}'=='SA' or '${network_type}'=='NSA'
    ...    Get Runtime arfcnSsbPbch    ${cell_info}

    ${earfcn}   Set Variable if   '${network_type}'=='4G' and '${tech}'=='TDD'    ${cell_info["earfcn"]}
    ...    '${network_type}'=='4G' and '${tech}'=='FDD'    ${cell_info["earfcnDl"]}
    #...    'NSA'=='${network_type}' or 'SA'=='${network_type}'    ${cell_info["nrarfcn"]}
    ...    'NSA'=='${network_type}' or 'SA'=='${network_type}'    ${arfcnSsbPbch}
    ...    ${EMPTY}
    [Return]  ${earfcn}

Get eutra Cel Id
    [Arguments]    ${cell_info}
    ${network_type}   Set Variable   ${cell_info["NetworkType"]}
    #${tech}   Set Variable    ${cell_info["cellTechnology"]}

    ${eutra_cel_id}   Set Variable if   '${network_type}'=='4G'    ${cell_info["eutraCelId"]}
    ...    'NSA'=='${network_type}' or 'SA'=='${network_type}'    ${cell_info["nrCellId"]}
    ...    ${EMPTY}
    [Return]  ${eutra_cel_id}

#Get Cell Info With PCI
#    [Arguments]    ${cell_list}   ${pci}
#    For   ${cell_info}   In    ${cell_list}
#        ${is_matched}    list_should_contain_value   ${cell_info["phyCellId"]}   ${pci}
#        Return From Keyword If      ${is_matched}     ${cell_info}
#    END


Make L3call For One Super Cell
    [Arguments]    ${cell_info}    ${cell_info_list}=${ALL_CELL_LIST}    ${ping}=${False}
    ...    ${extra_peak_rate_config}=${Empty}
    Log    ${cell_info_list}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${out_tp_list}    Get LcrId Max TP   ${cell_info}    ${extra_peak_rate_config}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${earfcn}   Get EARFCN   ${cell_info}
    ${eutra_cel_id}    Get eutra Cel Id   ${cell_info}
    ${ue_info0}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${EMPTY}
    Run Keyword If
    ...    "${ue_info0["TYPE"]}"=="UE" or "${ue_info0["TYPE"]}"=="Dingli" or "${ue_info0["TYPE"]}"=="SISO_UE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    FOR    ${RF}    IN    @{cell_info["subCell"]}
        ${RF_list}   Create List
        ${RF_list}    Combine Lists    ${RF_list}    ${RF}
        ${pa_ids}    Get Related PA List   ${RF_list}
        ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
        ...    technology=${tech}   pa_ids=${pa_ids}
        Set PA Values   ${RF_list}
        Run Keyword If    "${ue_info["TYPE"]}"=="Dingli"
        ...    basic_call_for_5G.Dingli L3call    ue_index=${ue_info["UE_ID"]}
        ...    cell_info=${cell_info}
        ...    ELSE IF    "${ue_info["TYPE"]}"=="SISO_UE"
        ...    SISO_UE.SISO UE L3call    ue_index=${ue_info["UE_ID"]}
        ...    bts_id=${bts_id}    require_attach_cell_id=${pci}    eutra_cel_id=${eutra_cel_id}
        ...    network_type=${network_type}    tech=${tech}    band=${band}    earfcn=${earfcn}
        ...    ELSE IF    "NSA"=="${network_type}" or "SA"=="${network_type}"
        ...    basic_call_for_5G.Make L3 Call And Run Throughput    ue_index=${ue_info["UE_ID"]}
        ...    cell_index=${cell_info['cellId']}     gnb_ssl_connection=${CASE_NAME}_${bts_id}
        ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}       try_count=${cell_info["carries"]}
        ...    band=${cell_info['band']}
        ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and not ${ping}
        ...    Basic Call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
        ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and ${ping}
        ...    L3call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
        ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="UE"
        ...    Run Keywords    Reserve Real_UE for tests TDD Config    AND
        ...    Attach Real_UE To Cell TDD Config    bts_id=${bts_id}    eutra_id=${cell_info["eutraCelId"]}
        Set PA Values   ${RF_list}    disable
    END
    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...     Run Keyword If
    ...    "${ue_info0["TYPE"]}"=="UE" or "${ue_info0["TYPE"]}"=="Dingli" or "${ue_info0["TYPE"]}"=="SISO_UE"
    ...     Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Make L3call For One Subcell
    [Arguments]    ${cell_info}    ${RF_info}    ${ping}=${False}        ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    Disable All Ports   ${ALL_CELL_LIST}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${out_tp_list}    Get LcrId Max TP   ${cell_info}    ${extra_peak_rate_config}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${earfcn}   Get EARFCN   ${cell_info}
    ${eutra_cel_id}    Get eutra Cel Id   ${cell_info}
    ${RF_list}   Create List
    ${RF_list}    Combine Lists    ${RF_list}    ${RF_info}
    ${pa_ids}    Get Related PA List   ${RF_list}
    ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${pa_ids}
    Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    Set PA Values   ${RF_list}
    Run Keyword If    "${ue_info["TYPE"]}"=="Dingli"
    ...    basic_call_for_5G.Dingli L3call    ue_index=${ue_info["UE_ID"]}
    ...    cell_info=${cell_info}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="SISO_UE"
    ...    SISO_UE.SISO UE L3call    ue_index=${ue_info["UE_ID"]}
    ...    bts_id=${bts_id}    require_attach_cell_id=${pci}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}    band=${band}    earfcn=${earfcn}
    ...    ELSE IF    "NSA"=="${network_type}" or "SA"=="${network_type}"
    ...    basic_call_for_5G.Make L3 Call And Run Throughput    ue_index=${ue_info["UE_ID"]}
    ...    cell_index=${cell_info['cellId']}     gnb_ssl_connection=${CASE_NAME}_${bts_id}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}       try_count=${cell_info["carries"]}
    ...    band=${cell_info['band']}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and not ${ping}
    ...    Basic Call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and ${ping}
    ...    L3call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="UE"
    ...    Run Keywords    Reserve Real_UE for tests TDD Config    AND
    ...    Attach Real_UE To Cell TDD Config    bts_id=${bts_id}    eutra_id=${cell_info["eutraCelId"]}
    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...     Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE"
    ...     Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Make L3call For One Cell
    [Arguments]   ${cell_info_list}    ${cell_info}    ${ping}=${False}    ${extra_peak_rate_config}=${Empty}
    ${RF_list}   Create List
    ${RF_list}    Combine Lists    ${RF_list}    ${cell_info["RF"]}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    Run Keyword If    "NSA"=="${network_type}"    Check And Set Anchor Cell For NR Cell
    ...   cell_list=${cell_info_list}      5g_pci=${pci}
    ${related_RF_List}    Get Related Cell Info With PCI    ${cell_info_list}    ${cell_info}
    ${RF_list}    Combine Lists    ${RF_list}   ${related_RF_List}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${earfcn}   Get EARFCN   ${cell_info}
    ${eutra_cel_id}    Get eutra Cel Id   ${cell_info}
    ${pa_ids}    Get Related PA List   ${RF_list}
    ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${pa_ids}

    ${out_tp_list}    Get LcrId Max TP   ${cell_info}    ${extra_peak_rate_config}
    Set PA Values   ${RF_list}
    Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE" or "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    Run Keyword If   "${ue_info["TYPE"]}"=="Dingli"
    ...    basic_call_for_5G.Dingli L3call    ue_index=${ue_info["UE_ID"]}
    ...    cell_info=${cell_info}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="SISO_UE"
    ...    SISO_UE.SISO UE L3call    ue_index=${ue_info["UE_ID"]}
    ...    bts_id=${bts_id}    require_attach_cell_id=${pci}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}    band=${band}    earfcn=${earfcn}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...    Basic Call With Nokia CPE    bts_id=${bts_id}    cell_ids=${pci}   band=${band}    earfcn=${earfcn}
    ...    network_type=${network_type}
    ...    ELSE IF     "NSA"=="${network_type}" or "SA"=="${network_type}"
    ...    basic_call_for_5G.Make L3 Call And Run Throughput    ue_index=${ue_info["UE_ID"]}
    ...    cell_index=${cell_info['cellId']}     gnb_ssl_connection=${CASE_NAME}_${bts_id}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}       try_count=${cell_info["carries"]}
    ...    band=${cell_info['band']}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and "${ping}"=="False"
    ...    Basic Call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE" and ${ping}
    ...    L3call With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="UE"
    ...    Run Keywords    Reserve Real_UE for tests TDD Config    AND
    ...    Attach Real_UE To Cell TDD Config    bts_id=${bts_id}    eutra_id=${cell_info["eutraCelId"]}


    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...     Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE" or "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...     Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Make Tput For One Super Cell
    [Arguments]        ${cell_info}    ${cell_info_list}=${ALL_CELL_LIST}    ${ping}=${False}
    ...    ${extra_peak_rate_config}=${Empty}
    Log    ${cell_info_list}
    Log    ${ping}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${earfcn}   Get EARFCN   ${cell_info}
    ${eutra_cel_id}    Get eutra Cel Id   ${cell_info}
    ${out_tp_list}    Get LcrId Max TP   ${cell_info}   ${extra_peak_rate_config}
    ${ue_info0}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${EMPTY}
    Run Keyword If
    ...    "${ue_info0["TYPE"]}"=="UE" or "${ue_info0["TYPE"]}"=="Dingli" or "${ue_info0["TYPE"]}"=="SISO_UE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    FOR    ${RF}    IN    @{cell_info["subCell"]}
        ${RF_list}   Create List
        ${RF_list}    Combine Lists    ${RF_list}    ${RF}
        ${pa_ids}    Get Related PA List   ${RF_list}
        ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
        ...    technology=${tech}   pa_ids=${pa_ids}
        Set PA Values   ${RF_list}
        Run Keyword If    "${ue_info["TYPE"]}"=="Dingli"
        ...    basic_call_for_5G.Dingli Tput    ue_index=${ue_info["UE_ID"]}
        ...    cell_info=${cell_info}
        ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}
        ...    ELSE IF    "${ue_info["TYPE"]}"=="SISO_UE"
        ...    SISO_UE.SISO UE Tput    ue_index=${ue_info["UE_ID"]}
        ...    bts_id=${bts_id}    require_attach_cell_id=${pci}    eutra_cel_id=${eutra_cel_id}
        ...    network_type=${network_type}    tech=${tech}    band=${band}    earfcn=${earfcn}
        ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}
        ...    ELSE IF    "NSA"=="${network_type}" or "SA"=="${network_type}"
        ...    basic_call_for_5G.Make L3 Call And Run Throughput    ue_index=${ue_info["UE_ID"]}
        ...    cell_index=${cell_info['cellId']}     gnb_ssl_connection=${CASE_NAME}_${bts_id}
        ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}   try_count=${cell_info["carries"]}
        ...    band=${cell_info['band']}
        ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE"
        ...    Test Tput With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
        ...    ul=${out_tp_list[1]}    dl=${out_tp_list[0]}
#       ...    ELSE IF    "4G"=="${network_type}" And "${ue_info["TYPE"]}"=="UE"
#       ...    Run Keywords
#       ...    Reserve Real_UE for tests TDD Config    AND
#       ...    Automated Basic Call Real_UE Config    bts_id=${bts_id}    eutra_id=${cell_info["eutraCelId"]}
#       ...    out_exp_dict_ul=${out_tp_list[1]}     out_exp_dict_dl=${out_tp_list[0]}
        Set PA Values   ${RF_list}    disable
    END
    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...     Run Keyword If
    ...     "${ue_info0["TYPE"]}"=="UE" or "${ue_info0["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE"
    ...     Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Make Tput For One Cell
    [Arguments]   ${cell_info_list}    ${cell_info}    ${ping}=${False}    ${extra_peak_rate_config}=${Empty}
    Log    ${ping}
    ${RF_list}   Create List
    ${RF_list}    Combine Lists    ${RF_list}    ${cell_info["RF"]}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${tech}   Set Variable    ${cell_info["cellTechnology"]}
    ${earfcn}   Get EARFCN   ${cell_info}
    ${eutra_cel_id}    Get eutra Cel Id   ${cell_info}
    ${out_tp_list}    Get LcrId Max TP   ${cell_info}   ${extra_peak_rate_config}
    Run Keyword If    "NSA"=="${network_type}"    Check And Set Anchor Cell For NR Cell
    ...   cell_list=${cell_info_list}      5g_pci=${pci}
    ${related_RF_List}    Get Related Cell Info With PCI    ${cell_info_list}    ${cell_info}
    ${RF_list}    Combine Lists    ${RF_list}   ${related_RF_List}
#    FOR    ${pci}   IN    @{cell_info["related_cell"]}
#        ${related_cell_info}   Get Cell Info With PCI   ${cell_info_list}    ${pci}
#        ${RF_list}    Combine Lists    ${RF_list}    ${related_cell_info["RF"]}
#    END
    ${pa_ids}    Get Related PA List   ${RF_list}
    ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${pa_ids}
    ${out_tp_list}    Get LcrId Max TP   ${cell_info}    ${extra_peak_rate_config}

    Set PA Values   ${RF_list}
    Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE" or "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred

    Run Keyword If    "${ue_info["TYPE"]}"=="Dingli"
    ...    basic_call_for_5G.Dingli Tput    ue_index=${ue_info["UE_ID"]}
    ...    cell_info=${cell_info}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="SISO_UE"
    ...    SISO_UE.SISO UE Tput    ue_index=${ue_info["UE_ID"]}
    ...    bts_id=${bts_id}    require_attach_cell_id=${pci}    eutra_cel_id=${eutra_cel_id}
    ...    network_type=${network_type}    tech=${tech}    band=${band}    earfcn=${earfcn}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...    Test Tput With Nokia CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${earfcn}    band=${band}
    ...    network_type=${network_type}    ul=${out_tp_list[1]}    dl=${out_tp_list[0]}
    ...    ELSE IF    "NSA"=="${network_type}" or "SA"=="${network_type}"
    ...    basic_call_for_5G.Make L3 Call And Run Throughput    ue_index=${ue_info["UE_ID"]}
    ...    cell_index=${cell_info['cellId']}     gnb_ssl_connection=${CASE_NAME}_${bts_id}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}      try_count=${cell_info["carries"]}
    ...    band=${cell_info['band']}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="CPE"
    ...    Test Tput With CPE    bts_id=${bts_id}    cell_ids=${pci}   earfcn=${cell_info["earfcn"]}
    ...    ul=${out_tp_list[1]}    dl=${out_tp_list[0]}
    ...    ELSE IF    "4G"=="${network_type}" and "${ue_info["TYPE"]}"=="UE"
    ...    Run Keywords    Reserve Real_UE for tests TDD Config    AND
    ...    Automated Basic Call Real_UE Config    bts_id=${bts_id}    eutra_id=${cell_info["eutraCelId"]}
    ...    out_exp_dict_ul=${out_tp_list[1]}     out_exp_dict_dl=${out_tp_list[0]}
    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...    Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="SISO_UE" or "${ue_info["TYPE"]}"=="Nokia_CPE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Make Tput For CA Pair Cell
    [Arguments]   ${cell_info_list}    ${cell_info}    ${pair_cell_list}   ${extra_peak_rate_config}
    ${RF_list}   Create List
    ${RF_list}    Combine Lists    ${RF_list}    ${cell_info["RF"]}
    ${network_type}   Set Variable    ${cell_info["NetworkType"]}
    ${bts_id}   Set Variable    ${cell_info["btsId"]}
    ${band}    Set Variable    ${cell_info["band"]}
    ${pci}    Set Variable     ${cell_info["phyCellId"]}
    ${cell_info}   ${all_cell_list}     update_related_cells    ${cell_info}    ${pair_cell_list}
    Run Keyword If    "NSA"=="${network_type}"    Check And Set Anchor Cell For NR Cell
    ...   cell_list=${cell_info_list}      5g_pci=${pci}
    ${related_RF_List}    Get Related Cell Info With PCI    ${cell_info_list}    ${cell_info}
    ${RF_list}    Combine Lists    ${RF_list}   ${related_RF_List}

    ${pa_ids}    Get Related PA List   ${RF_list}
    ${ue_info}    Get Matched Ue Info    band=${band}    network_type=${network_type}
    ...    technology=${tech}   pa_ids=${pa_ids}

    ${out_tp_list}    Get LcrId Max TP   ${cell_info}    ${extra_peak_rate_config}
    Set PA Values   ${RF_list}
    Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="AndroidUE"
    ...    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    Run Keyword If   "${ue_info["TYPE"]}"=="Dingli"
    ...    basic_call_for_5G.Dingli L3call    ue_index=${ue_info["UE_ID"]}
    ...    cell_info=${cell_info}
    ...    ELSE IF    "${ue_info["TYPE"]}"=="AndroidUE"
    ...    basic_call_for_5G.Taf Android CA Tput    ue_index=${ue_info["UE_ID"]}
    ...    require_attach_cell_ids=${all_cell_list}
    ...    dl_exp=${out_tp_list[0]}    ul_exp=${out_tp_list[1]}

    [Return]      ${all_cell_list}
    [Teardown]   Run Keywords   Set PA Values   ${RF_list}    disable   AND
    ...     Run Keyword If
    ...    "${ue_info["TYPE"]}"=="UE" or "${ue_info["TYPE"]}"=="Dingli" or "${ue_info["TYPE"]}"=="AndroidUE"
    ...     Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=notBarred

Get Rquired Cells
    [Arguments]    ${cell_list}    ${required_cells}   ${tech}=${EMPTY}
    ${cells_need_make_call}   Create List
    ${required_cell_ids}   Split String    ${required_cells}    :
    FOR   ${cell_id}   IN    @{required_cell_ids}
       ${cell_info}    Get Cell Info With PCI    ${cell_list}    ${cell_id}    ${tech}
       Append To List     ${cells_need_make_call}    ${cell_info}
    END
    [Return]    ${cells_need_make_call}

Choose Cells
    [Arguments]    ${cell_list}    ${tech}=${EMPTY}
    Return From Keyword If    '${tech}'=='${EMPTY}'    ${cell_list}
    ${cells_need_make_call}   Create List
    FOR   ${cell_info}   IN    @{cell_list}
       Continue For Loop If   '${cell_info["cellTechnology"]}'!='${tech}'
       Append To List     ${cells_need_make_call}    ${cell_info}
    END
    #Log Many     ${cell_list}
    [Return]    ${cells_need_make_call}

Reselect Cells According To SISO Strategy
    [Arguments]    ${cell_list}
    ${if_define_strategy}    Run Keyword And Return Status     Variable Should Exist     ${CALL_STRATEGY}
    ${stragety}    Set Variable If     ${if_define_strategy}      ${CALL_STRATEGY}     regression
    ${cell_count}    Get Length    ${cell_list}

    Return From Keyword If      '${cell_count}'=='0'     ${cell_list}
    ${random} =	Evaluate	random.randint(0, ${cell_count}-1)    modules=random

    ${new_cell_list}      Run Keyword If
    ...      '${stragety}'=='regression'      Create List
    ...       ELSE      Set Variable    ${cell_list}
    Run Keyword If      '${stragety}'=='regression'   Append To List    ${new_cell_list}          ${cell_list[${random}]}

    [Return]    ${new_cell_list}

Make L3Call
    [Arguments]   ${cell_list}=${ALL_CELL_LIST}    ${ping}=${False}    ${required_cells}=${Empty}
    ...      ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${tech}=${Empty}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    ${cells_need_make_call}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${cell_list}    ${required_cells}   ${tech}
    ...    ELSE    Choose Cells    ${cell_list}    ${tech}

    ${cells_need_make_call}     Reselect Cells According To SISO Strategy     ${cells_need_make_call}

    Disable All Ports   ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{cells_need_make_call}
        ${is_need_to_operate}   Check Is Supported Call Cell    ${cell_info}
        Continue For Loop If    '${is_need_to_operate}'=='False'
        ${func_type}    Set Variable If    "${cell_info['cellType']}"=="Supercell"    Make L3call For One Super Cell
        ...    Make L3call For One Cell
        Run Keyword    ${func_type}    cell_info_list=${cell_list}    cell_info=${cell_info}
        ...    ping=${ping}    extra_peak_rate_config=${extra_peak_rate_config}
    END

Make L3Call All
    [Arguments]   ${cell_list}=${ALL_CELL_LIST}    ${ping}=${False}    ${required_cells}=${Empty}
    ...      ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${tech}=${Empty}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    ${cells_need_make_call}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${cell_list}    ${required_cells}   ${tech}
    ...    ELSE    Choose Cells    ${cell_list}    ${tech}

    ${cells_need_make_call}     Reselect Cells According To SISO Strategy     ${cells_need_make_call}

    Disable All Ports   ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{cells_need_make_call}
        ${is_need_to_operate}   Check Is Supported Call Cell    ${cell_info}
        Continue For Loop If    '${is_need_to_operate}'=='False'
        Run Keyword If    "${cell_info['cellType']}"=="Supercell"
        ...    Make L3call For One Super Cell     cell_info=${cell_info}    cell_info_list=${cell_list}
        ...    extra_peak_rate_config=${extra_peak_rate_config}
        ...    ELSE
        ...    Make L3call For One Cell   cell_info_list=${cell_list}    cell_info=${cell_info}
        ...    ping=${ping}    extra_peak_rate_config=${extra_peak_rate_config}
    END

Make Tput
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}    ${required_cells}=${Empty}
    ...            ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${tech}=${Empty}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    ${cells_need_make_call}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${cell_list}    ${required_cells}   ${tech}
    ...    ELSE    Choose Cells    ${cell_list}    ${tech}
    ${cells_need_make_call}     Reselect Cells According To SISO Strategy     ${cells_need_make_call}

    Disable All Ports   ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{cells_need_make_call}
       ${is_need_to_operate}   Check Is Supported Call Cell    ${cell_info}
       Continue For Loop If    '${is_need_to_operate}'=='False'
       ${func_type}    Set Variable If    "${cell_info['cellType']}"=="Supercell"    Make Tput For One Super Cell
        ...    Make Tput For One Cell
        Run Keyword    ${func_type}    cell_info_list=${cell_list}    cell_info=${cell_info}
        ...    extra_peak_rate_config=${extra_peak_rate_config}

    END

Make Tput All
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}    ${required_cells}=${Empty}
    ...            ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${tech}=${Empty}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    ${cells_need_make_call}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${cell_list}    ${required_cells}   ${tech}
    ...    ELSE    Choose Cells    ${cell_list}    ${tech}

    ${cells_need_make_call}     Reselect Cells According To SISO Strategy     ${cells_need_make_call}
    Disable All Ports   ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{cells_need_make_call}
       ${is_need_to_operate}   Check Is Supported Call Cell    ${cell_info}
       Continue For Loop If    '${is_need_to_operate}'=='False'
       Run Keyword If    "${cell_info['cellType']}"=="Supercell"
       ...    Make Tput For One Super Cell     cell_info_list=${cell_list}    cell_info=${cell_info}
       ...    extra_peak_rate_config=${extra_peak_rate_config}
       ...    ELSE
       ...    Make Tput For One Cell   cell_info_list=${cell_list}    cell_info=${cell_info}
       ...    extra_peak_rate_config=${extra_peak_rate_config}
    END


Make CA Tput For One Cell
     [Arguments]   ${cell_list_for_call_done}     ${cell_info}     ${extra_peak_rate_config}
     ${status}    Run Keyword And Return Status     Dictionary Should Contain Key    ${cell_info}    CA_MAP
     Return From Keyword If      not ${status}


     FOR    ${cell_map_info}    IN    @{cell_info["CA_MAP"]}
         ${already_done}      check_if_in_list     ${cell_list_for_call_done}    ${cell_info["phyCellId"]}      ${cell_map_info}
         Continue For Loop If    ${already_done}
         ${cell_list}     Make Tput For CA Pair Cell     cell_info_list=${ALL_CELL_LIST}
         ...    cell_info=${cell_info}     pair_cell_list=${cell_map_info}
         ...    extra_peak_rate_config=${extra_peak_rate_config}
         Append To List      ${cell_list_for_call_done}      ${cell_list}
     END

Make CA Tput
    [Arguments]   ${cell_list}=${ALL_CELL_LIST}    ${ping}=${False}    ${required_cells}=${Empty}
    ...      ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}   ${tech}=${Empty}
    Log    ${ping}
    Return From Keyword If    not ${IS_SUPPORTED_CALL}
    ${cells_need_make_call}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${cell_list}    ${required_cells}   ${tech}
    ...    ELSE    Choose Cells    ${cell_list}    ${tech}
    ${cell_list_for_call_done}     Create List
    #Set Test Variable     ${cell_list_for_call_done}

    Disable All Ports   ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{cells_need_make_call}
        ${is_need_to_operate}   Check Is Supported Call Cell    ${cell_info}
        Continue For Loop If    '${is_need_to_operate}'=='False'
        ${func_type}    Set Variable      Make CA Tput For One Cell
        Run Keyword    ${func_type}    ${cell_list_for_call_done}    cell_info=${cell_info}
        ...    extra_peak_rate_config=${extra_peak_rate_config}
    END

