*** Settings ***
Resource   Common.robot


*** Variables ***


*** Keywords ***
CB010820 L3 Call Common Keyword
    [Arguments]   ${cell_id_list}=${L3CALL_CELL_LIST}
    Log To Console   CB010820 L3 Call Common Keyword
    FOR   ${cell_id}   IN   @{cell_id_list}
        CB010820 L3 Call Single Cell   cell_id=${cell_id}
    END


CB010820 L3 Call Single Cell
    [Arguments]   ${cell_id}
    Log To Console   CB010820 L3 Call Single Cell: ${cell_id}

    COAM Update qRxLevMin   cell_id=${cell_id}

    ${random_port}   Evaluate   random.randint(57000, 57999)   random
    ${iperf_port}   Get Variable Value   ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}   ${random_port}


    ${ue_index}   Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["ue_index"]}   ${L3_CALL_PARAMETER_DEFAULT["ue_index"]}

    ${tput_send_dl}         Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_send_dl"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_send_dl"]}
    ${tput_expect_dl}       Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_expect_dl"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_expect_dl"]}
    ${tput_deviation_dl}    Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_deviation_dl"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_deviation_dl"]}

    ${method}               Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["method"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["method"]}
    ${tput_send_ul}         Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_send_ul"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_send_ul"]}
    ${tput_expect_ul}       Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_expect_ul"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_expect_ul"]}
    ${tput_deviation_ul}    Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["tput_deviation_ul"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["tput_deviation_ul"]}


    ${min_percent}          Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["min_percent"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["min_percent"]}
    ${duration}             Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["duration"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["duration"]}
    ${bip_request}          Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["bip_request"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["bip_request"]}
    ${traffic_stop}         Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["traffic_stop"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["traffic_stop"]}


    ${ue_lock}              Get Variable Value   ${L3_CALL_PARAMETER["${cell_id}"]["ue_lock"]}
    ...   ${L3_CALL_PARAMETER_DEFAULT["ue_lock"]}
    ${band}                 Get Variable Value   ${CELLID_CELLINFO_MAPPING["${cell_id}"]["band"]}
    ${arfcnSsbPbch}              Get Variable Value   ${CELLID_CELLINFO_MAPPING["${cell_id}"]["arfcnSsbPbch"]}
    ${physicalCellId}       Get Variable Value   ${CELLID_CELLINFO_MAPPING["${cell_id}"]["physicalCellId"]}


    Wait Until Keyword Succeeds   3x   2m   Call Setup and check tput
    ...   ue_index=${ue_index}   port=${iperf_port}   duration=${duration}
    ...   tput=${tput_send_dl}   tput_expect=${tput_expect_dl}   dl_deviation=${tput_deviation_dl}
    ...   method=${method}   peak_ul=${tput_send_ul}   ul_expect=${tput_expect_ul}   ul_deviation=${tput_deviation_ul}
    ...   min_percent=${min_percent}
    ...   bip_request=${bip_request}   traffic_stop=${traffic_stop}
    ...   ue_lock=${ue_lock}   band=${band}   arfcn=${arfcnSsbPbch}   pci=${physicalCellId}



COAM Update qRxLevMin
    [Arguments]   ${cell_id}   ${connection}=MultiCC_L3Call   ${delta_id}=MultiCC_L3Call
    COAM Login   alias=${connection}

    coam.create_delta   delta_id=${delta_id}


    ${cellid_celldn_mapping}   ${cellid_cellinfo_mapping}   COAM Get All Cell Id   connection=${connection}
    Log To Console   ${cellid_celldn_mapping}
    Log To Console   ${cellid_cellinfo_mapping}
    Set Test Variable   ${CELLID_CELLINFO_MAPPING}

    ${not_l3call_cell_id_list}   Evaluate   list($cellid_celldn_mapping.keys())
    Sort List   ${not_l3call_cell_id_list}
    Remove Values From List   ${not_l3call_cell_id_list}   ${cell_id}
    Log To Console   ${not_l3call_cell_id_list}


    ${cell_dn}   Set Variable   ${cellid_celldn_mapping["${cell_id}"]}
    coam.append_parameter_update_to_delta
    ...   dist_name=${cell_dn}
    ...   parameter=qRxLevMin
    ...   value=-45
    ...   delta_id=${delta_id}

    FOR   ${cell_id}   IN   @{not_l3call_cell_id_list}
        ${cell_dn}   Set Variable   ${cellid_celldn_mapping["${cell_id}"]}
        coam.append_parameter_update_to_delta
        ...   dist_name=${cell_dn}
        ...   parameter=qRxLevMin
        ...   value=-22
        ...   delta_id=${delta_id}
    END

    ${delta_file}   coam.get_delta   delta_id=${delta_id}
    Log To Console   ${delta_file}


    Log To Console   COAM Perform Delta Recommissioning...
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=${connection}
    Log To Console   COAM Perform Delta Recommissioning Finished!
    Log To Console   Wait For Cell Onair...
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair   connection=${connection}
    Log To Console   Wait For Cell Onair Finished!


    [Teardown]   COAM Logout   connection=${connection}


COAM Get All Cell Id
    [Documentation]  ru_index=None: get all gnb cells, ru_index=ru_index: get all cells under RU
    [Arguments]   ${connection}=MultiCC_L3Call
    ${cell_info_list}   coam.get_cells_info    cell_type=nr    connection=${connection}
    ${scf_xml}   coam.get_scf      export_type=configurationAndRuntimeObjects   connection=${connection}   timeout=${600}
    &{cellid_celldn_mapping}   Create Dictionary
    &{cellid_cellinfo_mapping}   Create Dictionary
    FOR  ${cell}  IN  @{cell_info_list}
        ${cell_id}   Set Variable   ${cell['globalCellId']}
        ${cell_id}   Convert To String   ${cell_id}
        ${cell_dn}   Set Variable   ${cell["id"]["configuration"]}
        Set To Dictionary   ${cellid_celldn_mapping}   ${cell_id}=${cell_dn}

        ${arfcnSsbPbch}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@distName="${cell_dn}"]/p[@name="arfcnSsbPbch"]
        &{cell_info}   Create Dictionary   band=${cell["band"]}   arfcnSsbPbch=${arfcnSsbPbch}   physicalCellId=${cell["physicalCellId"]}
        Set To Dictionary   ${cellid_cellinfo_mapping}   ${cell_id}=${cell_info}

    END

    [Return]  ${cellid_celldn_mapping}   ${cellid_cellinfo_mapping}
