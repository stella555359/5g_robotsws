*** Settings ***
Documentation
...    Golden case keywords

*** Keywords ***
Check Test Cell Status
    [Arguments]  ${unimpact_cell_list}  ${bts_mode}  ${expected_cell_status}
    [Documentation]    Hanyuan Cui: Check Test Cell Status
    ...    This keyword can check the SBTS cell status based on the cell_list and bts_mode,
    ...    and the bts_mode can be 'LTE', '5GSA' and '5GNSA'.
    FOR  ${cell_id}  IN   @{unimpact_cell_list}
        ${cell_id_tmp}    Split String    ${cell_id}    .
        ${bts_id}    Set Variable    ${cell_id_tmp}[0]
        ${cell_list}    Set Variable    ${cell_id_tmp}[1]
        ${oam_ip}  RUN KEYWORD IF  '${bts_mode}' == 'LTE'  Set Variable  ${tl.enbs[0].oam_ip.v4}
        ...  ELSE IF  '${bts_mode}' == '5GSA'
        ...  Set Variable  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
        ...  ELSE IF  '${bts_mode}' == '5GNSA' and '${bts_id}' == '${tl.gnbs[0].global_bts_id}'
        ...  Set Variable  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
        ...  ELSE IF  '${bts_mode}' == '5GNSA' and '${bts_id}' == '${tl.enbs[0].global_bts_id}'
        ...  Set Variable  ${tl.enbs[0].oam_ip.v4}
        Check SBTS Cell Status    cell_list=${cell_list}
        ...  expected_status_dict=${expected_cell_status}  oam_ip=${oam_ip}
    END

Get Unimpact Cell List
    [Arguments]  ${scffile}  ${asir_cell_id_list}
    [Documentation]    Hanyuan Cui: Get Unimpact Cell List
    ...    Step 1: use keyword to get all_cell_list based on the ASIR commission file
    ...    Step 2: remove impact cell list (asir_cell_id_list) from all_cell_list to get unimpact cell list
    ${ant_cell_list}  Kw Get Asir Celllist Xmod Mapping  ${scffile}  ANTMOD  map_reverse=false
    ${antmod_idlist}   Get Dictionary Keys  ${ant_cell_list}
    FOR  ${ANTMOD_R}  IN  @{antmod_idlist}
        @{cell_list_tmp}  Get From Dictionary  ${ant_cell_list}[${ANTMOD_R}]    asir_cell_id_list
        ${all_cell_list}=    Combine Lists    ${all_cell_list}    ${cell_list_tmp}
    END
    Remove Duplicates    ${all_cell_list}
    ${unimpact_cell_list}    Copy List    ${all_cell_list}
    Remove Values From List  ${unimpact_cell_list}  @{asir_cell_id_list}
    [Return]   ${unimpact_cell_list}

Get Port Impact Cell List
    [Documentation]    Liang Hongsong:  Get Port Impact Cell List
	...    Get macro port related cell list on ASIRMOD
    [Arguments]    ${arg_asirmod}=ASIRMOD-1    ${arg_port_id}=5
    ${all_cell_list}    Get Macro Celllist From Xmod  mo_class=CABLINK_R  xmod_type=runtime
    ${cablinkrid}    Get Cablinkrid    ${arg_asirmod}    ${arg_port_id}
    ${port_impact_cell_list}    RUN KEYWORD IF    '${cablinkrid}' == 'none'    sleep     1s
    ...    ELSE    Set Variable     ${all_cell_list}[${cablinkrid}]
    [Return]   ${port_impact_cell_list}

Get Asirmod Impact Cell List
    [Documentation]    Liang Hongsong:  Get Port Impact Cell List
	...    Get macro ASIRMOD related cell list
    [Arguments]    ${arg_impact_asirmod}=ASIRMOD-1    ${arg_oam_ip}=${gnb_oam_ip}
    ${all_cell_list}    Get Macro Celllist From Xmod  mo_class=ASIRMOD_R    oam_ip=${arg_oam_ip}
    ${asirmod_impact_cell_list}    Set Variable    ${all_cell_list}[${arg_impact_asirmod}]
    [Return]   ${asirmod_impact_cell_list}

Get Macro unImpact Cell List
    [Documentation]    Liang Hongsong: Get Macro unImpact Cell List
	...    Calculate unimpact cell list after comparing impact cell list with all cell list
    [Arguments]    ${arg_impact_cell_list}    ${arg_oam_ip}=192.168.255.129
    ${all_asirmod_cell}    Get Macro Celllist From Xmod  mo_class=ASIRMOD_R    oam_ip=${arg_oam_ip}
    ${asirmod_mapping_dict}    Get Macro Xmod R Xmod Mapping  mo_class=ASIRMOD_R
    ${asirmod_id_list}    Get Dictionary Values   ${asirmod_mapping_dict}
    FOR  ${asirmod_id}  IN  @{asirmod_id_list}
        ${all_cell_list_tmp}    Set Variable    ${all_asirmod_cell}[${asirmod_id}]
        ${all_cell_list}    Combine Lists    ${all_cell_list}    ${all_cell_list_tmp}
        ${allcelllistcp}    Set Variable    ${all_cell_list}
    END

    ${arg_impact_cell_list}  Convert To List  ${arg_impact_cell_list}

    FOR  ${impact_cell_id}  IN  @{arg_impact_cell_list}
        RUN KEYWORD IF  ${arg_impact_cell_list} != 'none'  Remove Values From List  ${allcelllistcp}  ${impact_cell_id}
    END

    ${all_cell_list}    RUN KEYWORD IF    ${arg_impact_cell_list} == 'none'    Set Variable    ${all_cell_list}
    ...    ELSE    Set Variable    ${allcelllistcp}

    [Return]   ${all_cell_list}

Get Cablinkrid
    [Documentation]    Liang Hongsong: Get Cablinkrid
	...    Get cablinkr ID according to the port number on ASIRMOD
    [Arguments]    ${arg_ASIRMOD_id}=ASIRMOD-1
    ...            ${arg_port_id}=1
    ${arg_port_id}    Convert To Integer    	${arg_port_id}

    ${all_cablinkrs_info_dict}    Get Asirmod Cablinkr Mapping Info

    ${ANTMOD_cablinkrs_info_list}    Set Variable    ${all_cablinkrs_info_dict}[${arg_ASIRMOD_id}]

    ${ANTMOD_cablinkrs_num}    Get Length    ${ANTMOD_cablinkrs_info_list}

    FOR  ${index}  IN RANGE  ${ANTMOD_cablinkrs_num}
        Log To Console    \n calinkr_index=${index}
        ${cablinkr_info_dict}    Set Variable    @{ANTMOD_cablinkrs_info_list}[${index}]
        ${cablinkr_value_list}    Get Dictionary Values    ${cablinkr_info_dict}
        ${cablinkr_value}    Set Variable    @{cablinkr_value_list}[0]
        ${port_id}      Set Variable    ${cablinkr_value}[secondEndpointPortId]
        ${cablinkrs_id_list}    Get Dictionary Keys    ${cablinkr_info_dict}
        ${port_id}	   Convert To Integer    	${port_id}
        RUN KEYWORD IF    ${port_id} == ${arg_port_id}    Exit for loop
    END

    ${cablinkr_id_list}    RUN KEYWORD IF    ${port_id} == ${arg_port_id}    Set Variable    ${cablinkrs_id_list}[0]
    ...    ELSE    Set Variable    none

    Log To Console    \n matched_cablinkrs_id=${cablinkr_id_list}
    [Return]   ${cablinkr_id_list}

Get Asirmod Id Index
    [Documentation]    Liang Hongsong: Get Asirmod Id Index
	...    Get ASIRMOD ID index of ASIRMOD, for example 1,2,3...
    [Arguments]    ${arg_asirmod_id}=ASIRMOD-1
    ${asirmod_idindex}  Run  echo '${arg_asirmod_id}' | awk -F 'ASIRMOD-' '{print $2}'
    [Return]   ${asirmod_idindex}

Get Port Status
    [Documentation]    Liang Hongsong: Get Port Status
	...    Get ASIRMOD port status like
    ...    class,distName,version,operation,cablinkType,configDN,
    ...    firstEndpointDN,firstEndpointLabel,firstEndpointPortId,
    ...    iqCompression,linkMaxPhysicalCapacity,linkModeConfiguration,
    ...    linkModeDC,linkModeData,linkModeSynchronization,linkSpeed,
    ...    operationalState,secondEndpointDN,secondEndpointLabel,secondEndpointPortId
    ...    according the port number(1-6) on one ASIRMOD.
    [Arguments]    ${arg_ASIRMOD_id}=ASIRMOD-1
    ...            ${arg_port_id}=1
    ...            ${arg_port_item}=linkModeConfiguration
    ...            ${arg_all_cablinkrs_info_dict}=''
    ${arg_port_id}    Convert To Integer    	${arg_port_id}

    ${ANTMOD_cablinkrs_info_list}    Set Variable    ${arg_all_cablinkrs_info_dict}[${arg_ASIRMOD_id}]

    ${ANTMOD_cablinkrs_num}    Get Length    ${ANTMOD_cablinkrs_info_list}

    FOR  ${index}  IN RANGE  ${ANTMOD_cablinkrs_num}
        Log To Console    \n calinkr_index=${index}
        ${cablinkr_info_dict}    Set Variable    @{ANTMOD_cablinkrs_info_list}[${index}]
        ${cablinkr_value_list}    Get Dictionary Values    ${cablinkr_info_dict}
        ${cablinkr_value}    Set Variable    @{cablinkr_value_list}[0]
        ${port_id}      Set Variable    ${cablinkr_value}[secondEndpointPortId]
        ${port_value}      Set Variable    ${cablinkr_value}[${arg_port_item}]
        ${port_id}    Convert To Integer    	${port_id}
        RUN KEYWORD IF    ${port_id} == ${arg_port_id}    Exit for loop
    END

    ${port_value}    RUN KEYWORD IF    ${port_id} == ${arg_port_id}    Set Variable    ${port_value}
    ...    ELSE    Set Variable    none

    Log To Console    \n matched_port_value=${port_value}

    [Return]   ${port_value}

Get All Port Basic Status
    [Documentation]    Liang Hongsong: Get All Port Basic Status
	...    Get ASIRMOD port1-6 basic status like
    ...    operationalState, linkModeConfiguration, linkModeSynchronization
    ...    and return a list based port number
    ...    port1: [{'operationalState': 'disabled', 'linkModeConfiguration': None, 'linkModeSynchronization': None},
    ...    port2: {'operationalState': 'disabled', 'linkModeConfiguration': None, 'linkModeSynchronization': None},
    ...    portx: ...
    ...    port6: {'operationalState': 'enable', 'linkModeConfiguration': None, 'linkModeSynchronization': None}]
    ...
    ...    Each element of the list is a dictionary contain the value of operationalState, linkModeConfiguration,
    ...    linkModeSynchronization
    [Arguments]    ${arg_ASIRMOD_id}=ASIRMOD-1
    ${all_cablinkrs_info_dict}    Get Asirmod Cablinkr Mapping Info
    @{ports_basic_list_status}    Create List

    FOR    ${port_num}    IN RANGE    1    7
        ${port_oper_status}    Get Port Status
    ...    ${arg_ASIRMOD_id}    ${port_num}    operationalState    ${all_cablinkrs_info_dict}
        ${port_cm_status}    Get Port Status
    ...    ${arg_ASIRMOD_id}     ${port_num}    linkModeConfiguration    ${all_cablinkrs_info_dict}
        ${port_sync_status}    Get Port Status
    ...    ${arg_ASIRMOD_id}    ${port_num}    linkModeSynchronization    ${all_cablinkrs_info_dict}

        ${port_basic_dict_status}    Create Dictionary
    ...    operationalState=${port_oper_status}
    ...    linkModeConfiguration=${port_cm_status}
    ...    linkModeSynchronization=${port_sync_status}
        Append To List    ${ports_basic_list_status}    ${port_basic_dict_status}
    [Return]   ${ports_basic_list_status}
    END
