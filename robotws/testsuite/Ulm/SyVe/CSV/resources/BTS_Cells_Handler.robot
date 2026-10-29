*** Settings ***
Documentation
...    | Author:       | Michele                                                             |
...    | Team:         | CSV Ulm                                                             |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                            |
...    | Description:  | Common Keywords used in CSV testcases                               |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    ../../resources/syve_testline.robot

Library    testsuite/Ulm/resources/Common/python/CustomizeCollections.py   WITH NAME   data_ops_py


*** Keywords ***
Set Active NRRU As Variable Based On Technology In Use
    [Documentation]    # ToDo: Select it automatically! Used in E2E_5G_SA_Data_Transfer...
    ...  |  Set First NR RU (New Radio Radio Unit) As Variable Based On Technology In Use for all Data Transfer Testing TCs...  |
    [Arguments]    ${technology_in_use}=FDD
    ${bts_distNames}=    gnb.Get DistNames From gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      ${\n}TL is ${bts_distName}
    IF  "${technology_in_use}" == "TDD"
        ${NRRU}=      Set Variable If
        ...    '${bts_distName}' == 'MRBTS-452851'    3
        ...    '${bts_distName}' == 'MRBTS-2861'    6    # TL286: use TDD cells from RMOD AEQQ#04 (RMOD-19)
        ...    '${bts_distName}' == 'MRBTS-9011'    2
        ...    '${bts_distName}' == 'MRBTS-409021'     2    # To be deleted! MRBTS-9021 already Present.
        ...    '${bts_distName}' == 'MRBTS-9021'    2
        #...    '${bts_distName}' == 'MRBTS-402321'     3   # TL232 has no TDD RMODs connected
        #...    '${bts_distName}' == 'MRBTS-402831'     3   # TL283 has no TDD RMODs connected
        ...    '${bts_distName}' == 'MRBTS-2841'    2    # index Start form 0.
        ...    '${bts_distName}' == 'MRBTS-1181'    0
        ...    '${bts_distName}' == 'MRBTS-452111'     3    # To be deleted! MRBTS-2111 already Present.
        ...    '${bts_distName}' == 'MRBTS-2111'    3
        ...    '${bts_distName}' == 'MRBTS-2121'    4    # index Start form 0.
        ...    '${bts_distName}' == 'MRBTS-452121'    4    # index Start form 0.
    ELSE    # RMOD to use in the FDD call...
        ${NRRU}=      Set Variable If
        ...    '${bts_distName}' == 'MRBTS-452851'    0
        ...    '${bts_distName}' == 'MRBTS-2861'    0
        ...    '${bts_distName}' == 'MRBTS-9011'    0
        ...    '${bts_distName}' == 'MRBTS-409021'     0    # To be deleted! MRBTS-9021 already Present.
        ...    '${bts_distName}' == 'MRBTS-9021'    0
        ...    '${bts_distName}' == 'MRBTS-402321'     0    # TL232: use cells from RMOD: AHPMDG#36 (RMOD-1000)
        ...    '${bts_distName}' == 'MRBTS-2831'    0    # TL283: use cells from RMOD: AHPMDG#18 (RMOD-1000)
        # ...    '${bts_distName}' == 'MRBTS-2831'    1    # TL283: use cells from RMOD: OFEGSA#09 (RMOD-1400)
        # ...    '${bts_distName}' == 'MRBTS-2831'    2    # TL283: use cells from RMOD: AHPMDG#19 (RMOD-2000)
        ...    '${bts_distName}' == 'MRBTS-2841'    0    # TL283: use cells from RMOD: AHPMDK#04 (RMOD-1000)
        # ToDo: OFEGSA#16 (RMOD-1400) have different cells frequency connected to different Attenuators ports. One Cell to one Att. Port.!!!
        # ...    '${bts_distName}' == 'MRBTS-2841'  1  # TL283: use cells from RMOD: OFEGSA#16 (RMOD-1400)
        # ...    '${bts_distName}' == 'MRBTS-2841'  4  # TL283: use cells from RMOD: OFEGSA#13 (RMOD-2400)
        ...    '${bts_distName}' == 'MRBTS-1181'    0
        ...    '${bts_distName}' == 'MRBTS-452111'     0    # To be deleted! MRBTS-2111 already Present.
        ...    '${bts_distName}' == 'MRBTS-2111'     0
        ...    '${bts_distName}' == 'MRBTS-2121'    2
        ...    '${bts_distName}' == 'MRBTS-452121'    2
    END
    Should Not Be Equal    ${NRRU}    ${None}    No mapping for NRRU found! Please, also check if the TL have TDD module installed...
    # ToDo: Select it automatically! Used in E2E_5G_SA_Data_Transfer...
    Log To Console      ${\n}The Radio Unit to use is: ${NRRU}
    RETURN    ${NRRU}


Guarded Block Cells
    [Documentation]
    ...  Check The Cell Status Before To Block it.
    ...  Guard clause: In programming, this refers to a check at the beginning of a function or
    ...  block of code that exits early if a condition is not met, preventing further execution.
    ...  | Arguments:  |
    ...  | ${RAT_to_Block}    | nr | lte | gsm  |
    ...  | ${node_type} Used to determinate the WebEM connection. | enb | gnb  |

    [Arguments]    ${cells_to_block}=${None}    ${node_type}=gnb    ${RAT_to_Block}=gsm

    IF   "${RAT_to_Block}"=="nr"
            ${node_type}    Set Variable    gnb
    ELSE IF   "${RAT_to_Block}"=="lte"
            ${node_type}    Set Variable    enb
    ELSE IF   "${RAT_to_Block}"=="gsm"
            ${node_type}    Set Variable    gnb
    ELSE
            Fail    Wrong RAT_in_use '${RAT_in_use}'! allowed: nr|lte|gsm
    END

    ${oam_alias}=    connect.Setup OAM HTTP Session    node_type=${node_type}    node_id=${0}
    FOR  ${cell_to_block}  IN  @{cells_to_block}
        ${cells_info}   admin.Get Cells Info  connection=${oam_alias}    cell_type=${RAT_to_Block}
        ${cells_state}  gnb.Generate Cells Status Dictionary  data_structure=${cells_info}  id_type=configuration
        Log To Console    ${\n}Cell Blocking State:${\n}${cell_to_block}${\n}${cells_state['${cell_to_block}']['status']['blockingState']}
        IF    "${cells_state['${cell_to_block}']['status']['blockingState']}" == "Unblocked"
            admin.Block Cell    dist_name=${cell_to_block}    connection=${oam_alias}    timeout=120
            Sleep  3s
        END
    END


Get Cells Within RMOD Based On RAT
    [Documentation]    # ToDo: Select it automatically! NRRU is now a fix Value! Use the as KEY the RMOD from the Cell under test.
    ...  Set the corresponding (Same Attenuator Same RM) Cells to be locked based on RAT.
    ...  | Arguments:  |
    ...  | ${RAT_to_Block}    | nr | lte | gsm  |
    ...  | ${NRRU} Used to determinate the RMOD connection. | 0 | 1 | n  |
    ...  | RETURN  |   The sorted cells to block.  |

    [Arguments]    ${NRRU}=${0}    ${RAT_to_Block}=gsm

    IF   "${RAT_to_Block}"=="nr"
            ${class}    Set Variable    NRCEL
    ELSE IF   "${RAT_to_Block}"=="lte"
            ${class}    Set Variable    LNCEL
    ELSE IF   "${RAT_to_Block}"=="gsm"
            ${class}    Set Variable    GNCEL
    ELSE
            Fail    Wrong RAT_in_use '${RAT_in_use}'! allowed: nr|lte|gsm
    END

    &{rmod_cell_to_block_mapping}    gnb.Get Radio Module Cell Mapping    class=${class}
    ${sorted_dict}    data_ops_py.Sort Collection Naturally    ${rmod_cell_to_block_mapping}
    ${all_keys}=    Get Dictionary Keys    ${sorted_dict}    sort_keys=False
    ${key_to_use}=    Get From List    ${all_keys}    ${NRRU}
    ${cell_to_block}=     Get From Dictionary    ${sorted_dict}    ${key_to_use}
    ${sorted_cell_to_block}=    data_ops_py.Sort Collection Naturally    ${cell_to_block}

    RETURN    ${sorted_cell_to_block}


Set Cell Accessibility
    [Documentation]
    ...  Barring the NR Cell the UE will perform NSA...
    ...  cellBarred: This is a flag or parameter broadcast by a cell (e.g., in system information blocks) that informs user equipment (UE)
    ...  whether they are permitted to camp on or access that particular cell.
    ...  It's a mechanism used by the network to control cell selection and reselection.
    ...  cellBarred is a parameter that indicates whether a cell is accessible
    ...  | Arguments:  |
    ...  | ${RAT_to_Block}    | nr | lte | gsm  |
    ...  | ${NRRU} Used to determinate the RMOD connection. | 0 | 1 | n  |
    ...  | ${states}  | barred | notBarred  |

    [Arguments]    ${NRRU}=${0}    ${RAT_to_Block}=nr    ${node_type}=gnb    ${states}=notBarred

    ${cells_to_barr}    Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=${RAT_to_Block}
    Log To Console    ${\n}The Cells to Barr List: ${cells_to_barr}

    ${oam_alias}=    connect.Setup OAM HTTP Session    node_type=${node_type}    node_id=${0}
    FOR  ${cell_to_barr}  IN  @{cells_to_barr}
        ${list_of_parameter}    Create List    cellBarred
        Log To Console    ${\n}Get Cell accessibility for:${\n} ${cell_to_barr} ${\n}with: ${list_of_parameter}
        ${parameter_status_list}    admin.Get Parameter By Distname
        ...    dist_name=${cell_to_barr}
        ...    connection=${oam_alias}
        ...    parameter_list=${list_of_parameter}
        ...    timeout=120
        Log To Console    ${\n}The Status is:${\n} ${parameter_status_list}
    END
    FOR  ${cell_to_barr}  IN  @{cells_to_barr}
        Log To Console    ${\n}Set Cell accessibility for:${\n} ${cell_to_barr} ${\n}to:${\n} ${states}
        admin.Perform Parameter Recommissioning
        ...    dist_name=${cell_to_barr}
        ...    connection=${oam_alias}
        ...    parameter=cellBarred
        ...    value=${states}
        ...    operation=update
        ...    skip_parameter_relation_errors=True
        ...    timeout=120
     END


Get Under Test Cell ID Path
    [Documentation]    # ToDo: Order in numeric ... # ToDo: Generally rework the complete KW...doing to match...
    ...  |  return the Cell ID under Test Based from the RMOD order [0 to n].  (still using the ${NRRU}) |
    [Arguments]    ${NRRU}=${0}    ${RAT_in_use}=nr    ${node_type}=gnb

    ${node_type}    string.Convert To Lowercase     ${node_type}

    IF   "${RAT_in_use}"=="nr"
            ${class}    Set Variable    NRCEL
    ELSE IF   "${RAT_in_use}"=="lte"
            ${class}    Set Variable    LNCEL
    ELSE IF   "${RAT_in_use}"=="gsm"
            ${class}    Set Variable    GNCEL
    ELSE
            Fail    Wrong RAT_in_use '${RAT_in_use}'! allowed: nr|lte|gsm
    END

    ${rmod_under_test_cell_mapping}    gnb.Get Radio Module Cell Mapping    class=${class}
    ${values}=    Get Dictionary Values    ${rmod_under_test_cell_mapping}    sort_keys=True
    ${under_test_cell_id}    Get From List    ${values}    ${NRRU}
    ${long_str_cell_id_path}    Convert To String    ${under_test_cell_id}
    ${str_cell_id_path}=    Evaluate    "${long_str_cell_id_path}"[2:-2]
    Log To Console    ${\n}The gNB Cell ID under Test is: ${str_cell_id_path}

    # 1. Get all keys from the dictionary (RF 5.0)
    @{all_keys}=    Get Dictionary Keys    ${rmod_under_test_cell_mapping}
    Log To Console    All Keys: ${all_keys}
    # 2. Sort the keys alphabetically (RF 5.0)
    Sort List    ${all_keys}
    Log To Console    ${\n}Sorted Keys (alphabetically!): ${all_keys}

    @{rmod_numbers}=    Create List
    FOR    ${key}    IN    @{all_keys}
        ${rmod_number}=    String.Fetch From Right    ${key}    -
        Log To Console    Extracted RMOD number: ${rmod_number}
        Append To List    ${rmod_numbers}    ${rmod_number}
    END
    Log To Console    All RMOD numbers: ${rmod_numbers}

    # Convert string numbers to actual integers
    @{converted_numbers}=    Create List
    FOR    ${item}    IN    @{rmod_numbers}
        ${num}=    Convert To Integer    ${item}
        Append To List    ${converted_numbers}    ${num}
    END
    Log To Console    Converted Numbers List: ${converted_numbers}

    # Now sort the list of actual numbers
    Sort List    ${converted_numbers}
    Log To Console    Numerically Sorted List: ${converted_numbers}

    ${rmod_under_test}=    Get From List    ${converted_numbers}    ${NRRU}
    ${rmod_under_test}=    Set Variable    RMOD-${rmod_under_test}
    Log To Console    ${\n}RMOD under test: ${rmod_under_test}

    ${cell_id_under_test_path}=    Set Variable    ${NONE} # Initialize with None

    FOR  ${key}  IN  @{rmod_under_test_cell_mapping.keys()}
        IF    '${rmod_under_test}' in '''${key}'''
            ${cell_id_under_test_path}=    Get From Dictionary    ${rmod_under_test_cell_mapping}    ${key}
            ${cell_id_under_test_path}=    Convert To String    ${cell_id_under_test_path}
            ${cell_id_under_test_path}=    Evaluate    "${cell_id_under_test_path}"[2:-2]
            Log To Console    Found value for key containing '${rmod_under_test}': ${cell_id_under_test_path}
            # Exit loop once found if you expect only one match
            BREAK
        END
    END

    FOR    ${key}    IN    @{rmod_under_test_cell_mapping.keys()}
        # Split the key string by '/' to get its components
        ${key_parts}=    Split String    ${key}    /
        # Get the last component of the key (e.g., 'RMOD-100' from the list)
        ${last_part_of_key}=    Get From List    ${key_parts}    -1

        Log To Console    Checking key: ${key}, last component: ${last_part_of_key}

        # Compare the last component for an exact match
        IF  '${last_part_of_key}' == '${rmod_under_test}'
            ${cell_id_under_test_path}=    Get From Dictionary    ${rmod_under_test_cell_mapping}    ${key}
            ${cell_id_under_test_path}=    Convert To String    ${cell_id_under_test_path}
            ${cell_id_under_test_path}=    Evaluate    "${cell_id_under_test_path}"[2:-2]
            Log To Console    Found exact match for "${rmod_under_test}": ${cell_id_under_test_path}
            BREAK  # Exit loop once the exact match is found
        END
    END

    RETURN    ${cell_id_under_test_path}


Get Specific Cell Info
    [Documentation]
    ...  Display the "under Test Cell Info.  (still using the ${NRRU})
    ...  Information like downlinkChannelBandwidth could be use in future to determinate the cell TPut.
    ...  | Arguments:  |
    ...  | ${RAT_in_use}    | nr | lte | gsm  |
    ...  | ${technology_in_use} | TDD | FDD  |
    ...  | ${deployment} deployment architectures  | SA | NSA  |
    ...  | ${cell_index} e.g. to attach under the Second cell.  | 0  |
    [Arguments]    ${NRRU}=${0}    ${technology_in_use}=TDD    ${RAT_in_use}=nr    ${cell_index}=${0}
    ${cell_id_under_test_path}    BTS_Cells_Handler.Get Under Test Cell ID Path  NRRU=${NRRU}  node_type=${node_type}  RAT_in_use=${RAT_in_use}

    IF   "${RAT_in_use}"=="nr"
            ${node_type}    Set Variable    gnb
    ELSE IF   "${RAT_in_use}"=="lte"
            ${node_type}    Set Variable    enb
    ELSE IF   "${RAT_in_use}"=="gsm"
            ${node_type}    Set Variable    gnb  # ToDo: add GSM in case in future we need also a GSM call.
    ELSE
            Fail    Wrong RAT_in_use '${RAT_in_use}'! allowed: nr|lte|gsm
    END

    @{cell_id_under_test_path_list}=      Split String    ${cell_id_under_test_path}    ', '
    ${cell_id_under_test_path_list}       data_ops_py.Sort Collection Naturally    ${cell_id_under_test_path_list}
    ${oam_alias}=    connect.Setup OAM http session    node_type=${node_type}    node_id=${0}
    ${specific_cell_info}    admin.Get Cell Specific Info
    ...    cell_id=${cell_id_under_test_path_list}[${cell_index}]
    ...    connection=${oam_alias}
    ...    detailed_output=False

    ${specific_cell_info_dict} =    Create Dictionary
    IF  "${node_type}"=="gnb"
        Set To Dictionary    ${specific_cell_info_dict}
        ...    cellDepType    ${specific_cell_info['cellDepType']}
        ...    nrCellType            ${specific_cell_info['nrCellType']}
        IF  "${technology_in_use}"=="FDD"
            Set To Dictionary    ${specific_cell_info_dict}
            ...    chBwDl    ${specific_cell_info['chBwDl']}
            ...    chBwUl    ${specific_cell_info['chBwUl']}
        ELSE    #5G TDD Case:
            Set To Dictionary    ${specific_cell_info_dict}
            ...    chBw    ${specific_cell_info['chBw']}
        END
    ELSE    # LTE Case:
        Set To Dictionary    ${specific_cell_info_dict}
        ...    cellType    ${specific_cell_info['cellType']}
        ...    bandNumber    ${specific_cell_info['bandNumber']}
        ...    downlinkChannelBandwidth    ${specific_cell_info['downlinkChannelBandwidth']}
        ...    uplinkChannelBandwidth    ${specific_cell_info['uplinkChannelBandwidth']}
    END
    Set To Dictionary    ${specific_cell_info_dict}
    ...    downlinkMimoMode      ${specific_cell_info['downlinkMimoMode']}
    ...    energySavingState     ${specific_cell_info['energySavingState']}
    ...    maximumOutputPower    ${specific_cell_info['maximumOutputPower']}
    ...    physicalCellId        ${specific_cell_info['physicalCellId']}
    ...    technology            ${specific_cell_info['technology']}
    Log To Console    ${\n}Cell Under Test Info:${\n}${specific_cell_info_dict}


Get RMOD Cell Mapping for all RAT
    ${rmod_GSM_cell_mapping}    gnb.Get Radio Module Cell Mapping    class=GNCEL
    Log To Console    ${\n}The GSM Cells RMOD mapping: ${rmod_GSM_cell_mapping}

    ${rmod_LTE_cell_mapping}    gnb.Get Radio Module Cell Mapping    class=LNCEL
    Log To Console    ${\n}The LTE Cells RMOD mapping: ${rmod_LTE_cell_mapping}

    ${rmod_NR_cell_mapping}    gnb.Get Radio Module Cell Mapping    class=NRCEL
    Log To Console    ${\n}The NR Cells RMOD mapping: ${rmod_NR_cell_mapping}


Get RMOD and Physical Cell ID
     [Arguments]    ${RAT_in_use}=nr    ${node_type}=gnb

    ${node_type}    string.Convert To Lowercase     ${node_type}

    IF   "${RAT_in_use}"=="nr"
            ${class}    Set Variable    NRCEL
    ELSE IF   "${RAT_in_use}"=="lte"
            ${class}    Set Variable    LNCEL
    ELSE IF   "${RAT_in_use}"=="gsm"
            ${class}    Set Variable    GNCEL
    ELSE
            Fail    Wrong RAT_in_use '${RAT_in_use}'! allowed: nr|lte|gsm
    END

    ${rmod_under_test_cell_mapping}    gnb.Get Radio Module Cell Mapping    class=${class}
    ${values}=    Get Dictionary Values    ${rmod_under_test_cell_mapping}    sort_keys=False
    ${under_test_cell_id}    Get From List    ${values}    ${NRRU}
    ${long_str_cell_id_path}    Convert To String    ${under_test_cell_id}
    ${str_cell_id_path}=    Evaluate    "${long_str_cell_id_path}"[2:-2]
    Log To Console    ${\n}The gNB Cell ID under Test is: ${str_cell_id_path}

    ${extracted_Cell_ID_digits}=    String.Fetch From Right    ${str_cell_id_path}    -
    Log To Console    ${\n}Extracted Cell ID Digits: ${extracted_Cell_ID_digits}

    syve_testline.Correlate Cell ID To Radio Module ID    node_type=${node_type}    Cell_ID=${extracted_Cell_ID_digits}
    IF  "${RAT_in_use}"=="nr"
        syve_testline.Correlate Cell ID To Physical Cell ID    node_type=${node_type}    Cell_ID=${extracted_Cell_ID_digits}
    ELSE
        Log To Console    ${\n}Wrong RAT_in_use '${RAT_in_use}'! Correlate Cell ID To Physical Cell ID work only for gNB.
    END
