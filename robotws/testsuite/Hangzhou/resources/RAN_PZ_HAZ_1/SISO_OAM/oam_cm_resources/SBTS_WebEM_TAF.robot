*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to UI operation for SBTS cases by taf library.
...    ******************
...    History of changes
...    ******************
...    - 21.09.2024 - Xu Yuyan new resource

Library     taf.selenium.sbts    WITH NAME    selenium_sbts

*** Variables ***
${IS_VIRTAUL_DISPLAYED}    ${True}

*** Keywords ***
Selenium Login
    [Arguments]    ${url}=https://192.168.255.129
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    ...            ${download_dir}=${Test Results Dir}
    ...            ${timeout}=${60}
    #...            ${index}=${0}
    ...            ${version}=SBTS26R3
    ...            ${browser}=Firefox
    ...            ${alias}=default
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=${url}
    ...    username=${username}
    ...    password=${password}
    ...    download_dir=${download_dir}
    ...    timeout=${timeout}
    ...    version=${version}
    ...    browser=${browser}
    ...    alias=${alias}
    selenium_sbts.disable_message_box    sbts=${alias}
    selenium_sbts.disable_screen_lock    sbts=${alias}

Selenium Logout
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    selenium_sbts.logout    sbts=${alias}
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser    sbts=${alias}

LTE Cell Deletion Via Selenium
    [Arguments]    ${LTE_cell_DN}    ${alias}=default
    [Documentation]    This keyword is used to delete LTE cell.
    ...    | Parameter | Mandatory | Description |
    ...    | LTE_cell_DN | Yes | e.g. MRBTS-37376/LNBTS-37376/LNCEL-1 |
    ...    | alias | No |  |
    ...    | Return |
    ...    | lcrId | No | parameter Local cell resource ID value e.g. 1 |
    Log To Console    LTE Cell Deletion Via Selenium
    ${lcrId}    selenium_sbts.Get Parameter Value    dist_name=${LTE_cell_DN}
        ...    abbr=lcrId    filter_param=Local cell resource ID    sbts=${alias}    timeout=600
    ${lncel_id}    Set Variable    ${LTE_cell_DN.split("/")[-1].split("-")[-1]}
    selenium_sbts.remove_object    object_name=LNCEL-${lncel_id}    timeout=60    sbts=${alias}
    selenium_sbts.remove_object    object_name=LCELL-${lcrId}    timeout=60    sbts=${alias}
    ${cell_deletion_plan}    save_bts_configuration
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True
    [Return]    ${lcrId}

LTE Cell Addition Via Selenium
    [Arguments]    ${LTE_cell_DN}    ${lcrid}    ${initial_scf}    ${plan_to_copy_from}=CONF-1    ${alias}=default
    [Documentation]    This keyword is used to add LTE cell.
    ...    | Parameter | Mandatory | Description |
    ...    | LTE_cell_DN | Yes | e.g. MRBTS-37376/LNBTS-37376/LNCEL-1 |
    ...    | lcrId | Yes | parameter:Local cell resource ID value. e.g. 1 |
    ...    | initial_scf | Yes | scf file, for copy from |
    ...    | plan_to_copy_from | No | plan name. Default is CONF-1 |
    ...    | alias | No |  |
    Log To Console    LTE Cell Addition Via Selenium
    ${mrbts_dn}    Set Variable    ${LTE_cell_DN.split("/")[0]}
    ${lte_dn}    Set Variable    ${LTE_cell_DN.split("/")[1]}
    ${lncel_id}    Set Variable    ${LTE_cell_DN.split("/")[-1].split("-")[-1]}
    selenium_sbts.Load Commissioning File And Check Load Status    file_path=${initial_scf}    sbts=${alias}
    Sleep    30s
    ${scf_name}    Should Match Regexp    ${initial_scf}    ([^/]+?)\\.\\w+$
    selenium_sbts.add_object    object_name=${mrbts_dn}/${lte_dn}    object_class_name=LNCEL
    ...    plan_to_copy_from=${plan_to_copy_from}_${scf_name[1]}    copy_from=${LTE_cell_DN}
    ...    include_subobject=${True}    id_value=${lncel_id}    sbts=${alias}
    sleep    2s
    selenium_sbts.add_object    object_name=${mrbts_dn}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELL
    ...    plan_to_copy_from=${plan_to_copy_from}_${scf_name[1]}    copy_from=${mrbts_dn}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${lcrid}
    ...    include_subobject=${True}    id_value=${lcrid}    sbts=${alias}
    sleep    2s
    selenium_sbts.set_parameter_value    dist_name=${LTE_cell_DN}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}    sbts=${alias}    timeout=600
    ${cell_addition_plan}    save_bts_configuration
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True

NR Cell Deletion Via Selenium
    [Arguments]    ${NR_cell_DN}    ${cellGroup_id}=${None}    ${alias}=default
    [Documentation]    This keyword is used to delete NR cell. Only support one cell group mapping to one nrcell
    ...    | Parameter | Mandatory | Description |
    ...    | NR_cell_DN | Yes | e.g. MRBTS-37376/NRBTS-37376/NRCELL-0 |
    ...    | cellGroup_id | No | e.g. NRCELLGRP-1. Default is None, nrcellgroup id is same with NRCeLL id |
    ...    | alias | No |  |
    ...    | Return |
    ...    | lcrId | No | parameter Local cell resource ID value e.g. 1 |
    ...    | cellGrp_id | No | e.g. NRCELLGRP-1 |
    Log To Console    NR Cell Deletion Via Selenium
    ${mrbts_dn}    Set Variable    ${NR_cell_DN.split("/")[0]}
    ${nrbts_dn}    Set Variable    ${NR_cell_DN.split("/")[1]}
    ${lcrId}    selenium_sbts.Get Parameter Value    dist_name=${NR_cell_DN}
        ...    abbr=lcrId    filter_param=Local cell resource ID    sbts=${alias}    timeout=600
    ${nrcell_id}    Set Variable    ${NR_cell_DN.split("/")[-1].split("-")[-1]}
    selenium_sbts.remove_object    object_name=NRCELL-${nrcell_id}    timeout=60    sbts=${alias}
    selenium_sbts.remove_object    object_name=LCELNR-${lcrId}    timeout=60    sbts=${alias}
    ${cellGrp_id}    Set Variable If    ${cellGroup_id} is None    NRCELLGRP-${lcrId}    ${cellGroup_id}
    ${cell_group_list}    selenium_sbts.get_object_name_list    object_name=NRCELLGRP     timeout=60    sbts=${alias}
    ${cell_group_num}    Get Length    ${cell_group_list}
    selenium_sbts.remove_object    object_name=${cellGrp_id}    timeout=60    sbts=${alias}
    #NRDU
    FOR    ${index}    IN RANGE    ${cell_group_num}
        ${value}    selenium_sbts.Get Parameter Value    dist_name=${mrbts_dn}/${nrbts_dn}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group    node_index=${index}     sbts=${alias}
        Run Keyword If    "${cellGrp_id.split("-")[-1]}"=="${value}"    Run Keywords    selenium_sbts.remove_element
        ...    dist_name=${mrbts_dn}/${nrbts_dn}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group    node_index=${index}     sbts=${alias}
        ...    AND    Exit For Loop
    END
    ${cell_deletion_plan}    save_bts_configuration
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True
    [Return]    ${lcrId}    ${cellGrp_id}

NR Cell Addition Via Selenium
    [Arguments]    ${NR_cell_DN}    ${lcrId}    ${initial_scf}    ${cellGroup_id}=${None}    ${plan_to_copy_from}=CONF-1    ${alias}=default
    [Documentation]    This keyword is used to add NR cell. Only support one cell group mapping to one nrcell
    ...    | Parameter | Mandatory | Description |
    ...    | NR_cell_DN | Yes | e.g. MRBTS-37376/NRBTS-37376/NRCELL-0 |
    ...    | lcrId | Yes | parameter:Local cell resource ID value. e.g. 1 |
    ...    | initial_scf | Yes | scf file, for copy from |
    ...    | cellGroup_id | No | e.g. NRCELLGRP-1. Default is None, nrcellgroup id is same with NRCeLL id |
    ...    | plan_to_copy_from | No | plan name. Default is CONF-1 |
    ...    | alias | No |  |
    Log To Console    NR Cell Addition Via Selenium
    ${mrbts_dn}    Set Variable    ${NR_cell_DN.split("/")[0]}
    ${nrbts_dn}    Set Variable    ${NR_cell_DN.split("/")[1]}
    ${nrcell_id}    Set Variable    ${NR_cell_DN.split("/")[-1].split("-")[-1]}
    selenium_sbts.Load Commissioning File And Check Load Status    file_path=${initial_scf}    sbts=${alias}
    Sleep    30s
    ${scf_name}    Should Match Regexp    ${initial_scf}    ([^/]+?)\\.\\w+$
    selenium_sbts.add_object    object_name=${mrbts_dn}/${nrbts_dn}    object_class_name=NRCELL
    ...    plan_to_copy_from=${plan_to_copy_from}_${scf_name[1]}    copy_from=${NR_cell_DN}
    ...    include_subobject=${True}    id_value=${nrcell_id}    sbts=${alias}
    sleep    2s
    selenium_sbts.add_object    object_name=${mrbts_dn}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=${plan_to_copy_from}_${scf_name[1]}    copy_from=${mrbts_dn}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrid}
    ...    include_subobject=${True}    id_value=${lcrid}    sbts=${alias}
    sleep    2s
    selenium_sbts.set_parameter_value    dist_name=${NR_cell_DN}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}    sbts=${alias}    timeout=600
    ${cellGrp_id}    Set Variable If    ${cellGroup_id} is None    NRCELLGRP-${lcrId}    ${cellGroup_id}
    ${cell_group_list}    selenium_sbts.get_object_name_list    object_name=NRCELLGRP     timeout=60    sbts=${alias}
    ${cell_group_num}    Get Length    ${cell_group_list}
    selenium_sbts.add_object    object_name=${mrbts_dn}/${nrbts_dn}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=${plan_to_copy_from}_${scf_name[1]}    copy_from=${mrbts_dn}/${nrbts_dn}/${cellGrp_id}
    ...    include_subobject=${True}    id_value=${cellGrp_id.split("-")[-1]}    sbts=${alias}
    selenium_sbts.Add Element    dist_name=${mrbts_dn}/${nrbts_dn}/NRDU-1     abbr=refNrCellGroup
    ...    filter_param=Reference to cell group    sbts=${alias}
    selenium_sbts.Set Parameter Value    dist_name=${mrbts_dn}/${nrbts_dn}/NRDU-1    filter_param=Reference to cell group
    ...    new_value=${cellGrp_id.split("-")[-1]}    node_index=${cell_group_num}    sbts=${alias}
    ${cell_addition_plan}    save_bts_configuration
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True


Get MAA Cell TRX Num From Detailed Site View Via Selenium
     [Arguments]    ${nrcell_name}    ${channelgroup_name}=CHANNELGROUP-1
     ${channel_info}    selenium_sbts.get_site_cell_channel_info    ${nrcell_name}
     ${channelgroup_count}    Get Length    ${channel_info}
     Should Be Equal As Integers    ${channelgroup_count}    ${1}
     ${keys}    Get Dictionary Keys    ${channel_info[0]}
     Should Be Equal As Strings    ${keys[0]}    ${channelgroup_name}
     ${channelinfo_list}    Get From Dictionary    ${channel_info[0]}    ${channelgroup_name}
     ${final_TX_num}    Set Variable    0
     ${final_RX_num}    Set Variable    0
     FOR    ${group}    IN    @{channelinfo_list}
         ${TX_num}    ${RX_num}    _Get MAA Cell TRX Num From Detail Info    ${group}
         ${final_TX_num}    Evaluate    ${final_TX_num}+${TX_num}
         ${final_RX_num}    Evaluate    ${final_RX_num}+${RX_num}
     END
     [Return]     ${final_TX_num}    ${final_RX_num}

_Get MAA Cell TRX Num From Detail Info
    [Arguments]      ${channalgrouplist}
    [Documentation]    This keyword is called by keyword "Get MAA Cell TRX Num From Detailed Site View Via Selenium"
    ${TX_num}   Set Variable    0
    ${RX_num}   Set Variable    0
    FOR    ${item}   IN    @{channalgrouplist}
        ${TX_num}    Set Variable If    '${item['Direction']}'=='TX'    ${${TX_num}+1}    ${TX_num}
        ${RX_num}    Set Variable If    '${item['Direction']}'=='RX'    ${${RX_num}+1}    ${RX_num}
    END
    [Return]     ${TX_num}    ${RX_num}