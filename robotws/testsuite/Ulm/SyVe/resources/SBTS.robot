*** Settings ***
Documentation
...    | Author:        | Michele, Ulm SQD64                          |
...    | Contact:       | I_PZ_ULM_SQD_64@internal.nsn.com            |
...    | Description:   | Keywords for SRAN                       |
...    | AI Overview:   | In the context of telecommunications, |
...    |  | SRAN (Single Radio Access Network) and SBTS (Single Base Station Unit) are related but distinct concepts. |
...    |  | SRAN is a strategy that aims to simplify network architecture by using a single base station unit  |
...    |  | to support multiple radio access technologies, including LTE, HSPA, and GSM. |
...    |  | SBTS, on the other hand, refers to the specific technology or hardware that implements the Single RAN strategy.  |

Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    testsuite/Ulm/resources/Common/gnb.robot


# *** Variables ***


*** Keywords ***
Get HW Info
    [Arguments]    ${gnb_id}
    [Documentation]    Get HW info from gNB
    ${oam_alias}=    connect.Setup OAM HTTP Session    node_id=${gnb_id}
    ${hw_info}    admin.Get Detected HW Info    timeout=${30}    connection=${oam_alias}
    RETURN  ${hw_info}


Get SystemModules ProductName
    [Arguments]    ${gnb_id}=${0}
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb    node_id=${gnb_id}
    ${HW_info}=    admin.Get Detected HW Info    connection=${oam_alias}

    ${detected_smods}    Get Length    ${HW_info["systemModules"]}
    FOR    ${smod}    IN RANGE    ${detected_smods}
        Set Suite Variable    ${SMOD_PRODUCT_NAME_${gnb_id}_${smod}}    ${HW_info["systemModules"][${smod}]["productName"]}
        ${smod_id}    Evaluate    ${smod}+${1}
        Log To Console    ${\n}SMOD-${smod_id} Product Name of gNB ${gnb_id}: ${\n} \t ${SMOD_PRODUCT_NAME_${gnb_id}_${smod}}
        Log To Console    SMOD-${smod_id} Serial number: ${HW_info["systemModules"][${smod}]["serialNumber"]}
    END


Get BaseBandModules ProductName
    [Arguments]    ${gnb_id}=${0}
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb    node_id=${gnb_id}
    ${baseband_module_information}    admin.Get Fbb Info    connection=${oam_alias}
    ${number_of_BB_modules}    Get Length    ${baseband_module_information}

    FOR    ${BB_module_index}    IN RANGE    ${number_of_BB_modules}
        Set Suite Variable    ${BB_MODULE_NAME_${gnb_id}_${BB_module_index}}    ${baseband_module_information[${BB_module_index}]["productName"]}
        ${baseband_id}    Evaluate    ${BB_module_index}+1
        Log To Console  ${\n}BBMOD-${baseband_id} Product Name of gNB ${gnb_id}: ${\n} \t ${BB_MODULE_NAME_${gnb_id}_${BB_module_index}}
        Log To Console  BBMOD-${baseband_id} Serial number: ${baseband_module_information[${BB_module_index}]["serialNumber"]}
    END


Get Physical Cell ID
    [Documentation]
    ...    | The kw determines the Physical Cell ID |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    ...    | cell type: | NRCEL, LNCEL |
    ...    | RETURN:    | Physical Cell ID Dictionary. |
    ...    | Return: {'NRCELL-111': 120, |
    ...    | 'NRCELL-112': 121, |
    ...    | 'NRCELL-113': 122, |
    ...    | 'NRCELL-171': 123, |
    ...    | 'NRCELL-172': 124, |
    ...    | 'NRCELL-173': 125} |
    [Arguments]    ${node_type}=gnb
    ${node_type}    Convert To Lower Case    ${node_type}
    ${RAN_type}    Get RAN Type From Node    node_type=${node_type}

    IF  "${node_type}" == "gnb"
        ${physical_Cell_ID_dict}    gnb.Get GNB Physical Cell ID
    ELSE
        ${get_cell_dictionary}    Get Cell Dictionary
        ${physical_Cell_ID_dict} =    Create Dictionary
        FOR    ${cell_info}  IN    @{get_cell_dictionary["cells"]["${RAN_type}"]}
            Set To Dictionary    ${physical_Cell_ID_dict}    LNCEL-${cell_info['globalCellId']}    ${cell_info['physicalCellId']}
        END
    END

    RETURN    ${physical_Cell_ID_dict}


Get Cell Dictionary
    [Documentation]
    ...    | The kw determines the Cells List (all RAT with all parameters) |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    [Arguments]    ${node_id}=0    ${node_type}=gnb

    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=${node_type}    node_id=${node_id}
    ${get_cell_dictionary}    admin.Get Cell List    connection=${oam_alias}

    RETURN    ${get_cell_dictionary}


Log Cell RAN Types
    [Documentation]
    ...    | The kw determines the Cells Dictionary (all RAT with all parameters) |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    [Arguments]    ${node_id}=0    ${node_type}=gnb

    ${get_cell_dictionary}    Get Cell Dictionary    node_type=${node_type}    node_id=${node_id}
    ${RAN_type_name}    Get Dictionary Keys    ${get_cell_dictionary["cells"]}
    Log To Console  ${\n}RAN Names: ${RAN_type_name}


Get globalCellId For RAN Type
    [Documentation]
    ...    | The kw determines the available globalCellId and Sort a List of it depending of the RAN Type.  |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    ...    | RAN_type  | Node type; possible values: gsm or lte or nr or wcdma | see "Log Cell RAN Types" output. |
    ...    | ToDo | gsm and wcdma have different keys names... |
    [Arguments]    ${node_id}=0    ${node_type}=gnb    ${RAN_type}=nr

    ${get_cell_dictionary}    Get Cell Dictionary    node_type=${node_type}    node_id=${node_id}
    ${detected_cells}    Get Length    ${get_cell_dictionary["cells"]["${RAN_type}"]}

    @{globalCellId_list} =    Create List
    FOR    ${cell_tally}  IN RANGE    ${detected_cells}
        Append To List    ${globalCellId_list}    ${get_cell_dictionary["cells"]["${RAN_type}"][${cell_tally}]['globalCellId']}
    END
    Sort List    ${globalCellId_list}
    Log To Console  ${\n}Sorted Global CellId for ${RAN_type} RAN: ${globalCellId_list}

    RETURN    ${globalCellId_list}


Get Cells Parameters For RAN Type
    [Documentation]
    ...    | The kw determines Cells parameters depending of the RAN Type.  |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    ...    | node_type  | Node type; possible values: gNB or eNB |
    ...    | RAN_type  | Node type; possible values: gsm or lte or nr or wcdma | see "Log Cell RAN Types" output. |
    ...    | ToDo | gsm and wcdma have different keys names... |
    ...    | ToDo | {'NRCELL-111': {120, FDD} |
    ...    | | 'NRCELL-112': 121, FDD |
    ...    | | 'NRCELL-113': 122, FDD |
    ...    | | 'NRCELL-171': 123, TDD |
    ...    | | 'NRCELL-172': 124, TDD |
    ...    | | 'NRCELL-173': 125, TDD} |
    [Arguments]    ${node_id}=0    ${node_type}=gnb

    ${RAN_type}    Get RAN Type From Node    node_type=${node_type}

    ${get_cell_dictionary}    Get Cell Dictionary    node_type=${node_type}    node_id=${node_id}

    &{cells_parameters} =    Create Dictionary
    FOR    ${cell_info}    IN    @{get_cell_dictionary["cells"]["${RAN_type}"]}
        Set To Dictionary    ${cells_parameters}
        ...    ${RAN_type}_Cell_${cell_info["globalCellId"]}_technology       ${cell_info["technology"]}
        ...    ${RAN_type}_Cell_${cell_info["globalCellId"]}_physicalCellId   ${cell_info["physicalCellId"]}
    END


Get RAN Type From Node
    [Documentation]
    ...    | The kw determines the Physical Cell ID |
    ...    | node_id    | Id/Number of Node (eNB|gNB) |
    [Arguments]    ${node_type}=gnb
    ${node_type}    Convert to lower case    ${node_type}
    IF          "${node_type}"=="gnb"
        ${RAN_type}    Set Variable   nr
    ELSE IF     "${node_type}"=="enb"
        ${RAN_type}    Set Variable   lte
    ELSE
        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    RETURN    ${RAN_type}
