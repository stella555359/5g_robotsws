*** Settings ***
Documentation    ...

*** Keywords ***
Modify Wts Cfg File Content
    [Arguments]    ${cfg_file_path}    ${old_patterns_list}    ${new_patterns_list}
    [Documentation]    This keyword is to modify wts cfg file content according old and new parameres
    ...    offered by case owner
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file_path} | Yes | cfg file located |
    ...    | ${old_patterns_list} | Yes | a list contains paras patterns needed modify |
    ...    | ${new_patterns_list} | Yes | a list contains new paras after modified |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${CFG_FILE} | basic_fullstack_nsa_call_tdd_cmwv.cfg |
    ...    | @{CFG_OLD_PATTERNS} | plmn=[0-9]+:[0-9]+ | nr_arfcn=[0-9]+:[0-9]+ |
    ...    | @{CFG_NEW_PATTERNS} | plmn=302:610 | nr_arfcn=628333:628333 |
    ...
    ...    | Modify Wts Cfg File Content | ${CFG_FILE} | ${CFG_OLD_PATTERNS} | ${CFG_NEW_PATTERNS} |
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_file_path}
    FOR    ${old_val}    ${new_val}    IN ZIP    ${old_patterns_list}    ${new_patterns_list}
         ${content}    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${old_val}
    ...    replace_with=${new_val}
    END
    OperatingSystem.Create File    path=${cfg_file_path}    content=${content}

Get gNbCuType From SCFC
    [Arguments]    ${scfc_path}
    [Documentation]    This keyword is to the value of GNB type from current SCF
    ...
    ...    | gNbCuType | NSA/SA/both |
    ...    | cellTechnology | TDD/FDD |
    ...    | freqBandIndicatorNR | mmwv/cmwv | freqBandIndicatorNR>=127 == FR2==mmmv |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scfc_path | Yes | SCF file path. the default value is ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml |
    ...
    ...    Examples:
    ...    | Get GNB Type From SCFC |  |  |
    ${content}    OperatingSystem.Get File    path=${scfc_path}
    ${regexp}    Set Variable    gNbCuType">(?P<gNbCuType>[A-Za-z+]*)<
    ${match_list}     Get Regexp Matches    ${content}    ${regexp}    gNbCuType
    Set Suite Variable    ${GNBCUTYPE}    ${match_list[0]}
    [Return]    ${GNBCUTYPE}

Get Cell Number From Cfg
    [Arguments]    ${cfg_path}=${WTS_DIR}/${WTS_CFG}
    [Documentation]    This keyword is to get cell num from cfg file with count the number of 'set_cell id='
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_path}
    ${regexp}    Set Variable    ^set_cell id=.*?gnb=
    ${match_list}     Get Lines Matching Regexp    ${content}    ${regexp}    partial_match=true
    Log    ${match_list}
    ${cell_num}    Get Count    ${match_list}    set_cell id=
    [Return]    ${cell_num}

Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | actDddsReduction | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${suite_log_directory}/SCF_before_suite.xml |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | vlanId | 1901 |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | actDddsReduction | false | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Remove Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to delete single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | Remove Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ...    | Remove Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | actDddsReduction | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Remove Element    source=${root}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Remove Element    source=${root}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Get Radio Protocol Type From Scf File
    [Arguments]    ${scfc_file}
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get Radio Protocol Type| /tmp/SCF.xml |
    ${root}=    XML.Parse XML    ${scfc_file}
    Should Be Equal    ${root.tag}    raml
    ${radio_protocol}=    XML.Get Elements Texts    ${root}    xpath=.//p[@name="radioProtocolType"]
    ${ret}=    Run Keyword And Return Status    Should Contain    ${radio_protocol}[0]    eCPRI
    ${rf}=    Set Variable If    '${ret}'=='${True}'    eCPRI    CPRI
    Set Suite Variable    ${RF_TYPE}    ${rf}
    [Return]    ${rf}

Modify GSCN For Iphy XML
    [Arguments]    ${iphy_path}    ${gscn_new_value}
    ${iphy_xml}    XML.Parse XML    ${iphy_path}
    ${gscn_num}    Get Element Count    source=${iphy_xml}    xpath=//RE/descendant::GSCN
    F0R    ${index}    IN RANGE    1    ${gscn_num}+1
        ${xpath}    Set Variable    //RE[${index}]/descendant::GSCN
        XML.Set Element Text    source=${iphy_xml}    text=${gscn_new_value}    xpath=${xpath}
    END
    XML.Save Xml    ${iphy_xml}    ${iphy_path}

Modify vDU VlanId In SCF File
    [Arguments]    ${scf_path}
    [Documentation]    This keyword is to make sure VlanId in SCF file as the same as the testline.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |${scf_path} | Yes | the path for scf file, the modified file path is same as the origin one. |
    ...
    ...    Examples:
    ...    | Modify VlanId In SCF File | ${CURDIR}/SCF_after_suite.xml |
    # ${MRBTS_DISTNAME}    Set Variable If    '${MRBTS_DISTNAME}'==''    MRBTS-1    ${MRBTS_DISTNAME}
    FOR    ${index}    ${VLAN_ID}    IN ENUMERATE    @{VLAN_ID_LIST}
        ${cell_id}     Evaluate    int(${index})+1
        ${vlanif_distname}    Set Variable    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ${vlan_id_ori}    Convert To String    ${VLAN_ID}
        ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
        Log To Console    VlanId in Testline: ${vlan_id_ori}
        Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
        Set Single Value From Scf File    file_path=${scf_path}
        ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id_ori}
    END