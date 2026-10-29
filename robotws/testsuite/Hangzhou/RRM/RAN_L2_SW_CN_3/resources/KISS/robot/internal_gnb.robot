*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     BuiltIn
Library     String
Library     Collections
Library     OperatingSystem
Library     XML    use_lxml=True
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
Library    taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    VDU
Library    taf.gnb.oam.coam.cu.interface.cu    WITH NAME    CU
Library     taf.transport.ssh    WITH NAME    SSH
Resource    base.robot

*** Variables ***
${SOFTWARE_INFO}    ${EMPTY}


*** Keywords ***
_Get Software Info
    [Documentation]   Get GNB Software Info
    COAM.setup admin    bts_host=${GNB_ASIK.ip}    alias=coam_sw
    ${sw_info}=    COAM.Get Sw Version    connection=coam_sw
    Set Global Variable    ${SOFTWARE_INFO}    ${sw_info}
    Set Suite Metadata    Software Version    ${SOFTWARE_INFO}
    [Teardown]    COAM.Teardown    coam_sw
    [Return]    ${sw_info}

_Get Software Version On Common Package
    [Arguments]    ${software_info}
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    | Global variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    Log    Software Version: ${software_info}
    @{sw_list}    String.Split String    ${software_info}    _
    #${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${status}    Set Variable If    '${sw_list[2]}'=='9999'    True    '${sw_list[2]}'=='9990'    True     '${sw_list[2]}'=='0000'    False
    Run Keyword If    '${status}'=='True'    Set Global Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Global Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Global Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Global Variable   ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Global Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}

_Get Software Version On 5G Pacakge
    [Arguments]    ${software_info}
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    | Global variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    Log    Software Version: ${software_info}
    @{sw_list}    String.Split String    ${software_info}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==0000
    ${version_0}    String.Get Regexp Matches    ${sw_list[2]}    [1-9]+[0-9]*
    ${version_1}    String.Get Regexp Matches    ${sw_list[3]}    [1-9]+[0-9]*
    ${version_2}    String.Get Regexp Matches    ${sw_list[4]}    [1-9]+[0-9]*
    Run Keyword If    '${status}'=='True'    Set Global Variable    ${SW_VERSION}    0.${version_1[0]}
    ...    ELSE    Set Global Variable    ${SW_VERSION}    ${version_0[0]}.${version_1[0]}
    Run Keyword If    '${status}'=='True'    Set Global Variable    ${SW_VERSION_TOTAL}    0.${version_1[0]}.${version_2[0]}
    ...    ELSE    Set Global Variable    ${SW_VERSION_TOTAL}    ${version_0[0]}.${version_1[0]}.${version_2[0]}
    Set Global Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}

_Verify Process Is Running On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${process}    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} 'ps aux | grep ${part_proc_msg}'
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${True}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

_Verify Process Is Not Running On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${process}    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} 'ps aux | grep ${part_proc_msg}'
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${True}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}

_Kill Process On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${pids}    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} ps aux|grep ${part_proc_msg}|awk '{print $2}'
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} kill -2 ${pids}
    _Verify Process Is Not Running On Gnb    ${part_proc_msg}    ${process_msg}

_Get PhysCellId In GNB By LcrdId
    [Arguments]    ${scfc}    ${lcr_ids}
    @{lcr_id_list}    Split String    ${lcr_ids}    ,
	${xml}=    XML.Parse Xml    ${scfc}
    @{phycellids}=    Create List
    FOR    ${lcr_id}    IN    @{lcr_id_list}
        ${phycellid}=   XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL') and (contains(@distName, "NRCELL-${lcr_id}"))]/p[@name="physCellId"])
        Append To List     ${phycellids}     ${phycellid}
    END
    Log    all phycellid:@{phycellids}
    [Return]    @{phycellids}

_Get All PhysCellId In GNB
    [Arguments]    ${scfc}
    [Documentation]    This keyword to get all physcellid in gnb.
    ...    Examples:
    ...    | ${RF_TYPE}= | Get PhysCellId Of GNB |   |
    ${xml}=    XML.Parse Xml    ${scfc}
    ${phycellids}=   XML.Get Elements Texts    ${xml}    .//managedObject[@class\="com.nokia.srbts.nrbts:NRCELL"]/p[@name\="physCellId"]
    Log    all phycellid:${phycellids}
    [Return]    ${phycellids}

_Get localIpAddr Of GNB
    [Arguments]    ${scfc}
    ${str}=    OperatingSystem.Get File    ${scfc}
    ${localIpAddr}=    String.Get Regexp Matches    ${str}    <p name=\"localIpAddr\">(?P<localIpAddr>.*?)</p>    localIpAddr
    Log     localIpAddr=${localIpAddr}
    [Return]    ${localIpAddr}[0]

_Verify RRU Is Configured
    [Arguments]    ${rru_id}    ${ailas}
    ${bts_hw_info}    COAM.Get Bts Info    connection=${ailas}
    Should Be Equal    ${bts_hw_info['radioModules']['rmod'][${rru_id}]['status']['proceduralStatus']}    configured

_Onling Get NRBTS DistName
    [Documentation]    This keyword is to online get the NRBTS distname for current gNB. e.g.MRBTS-1/NRBTS-1
    ...    Examples:
    ...    | ${nrbts_distname}= | _Onling Get NRBTS DistName |
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=cOAM_nrbts
    ${cells_info}=    COAM.Get Cell List    connection=cOAM_nrbts
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    ${nrbts_distname}=    Set Variable    ${mrbts}/${nrbts}
    Log To Console    nrbts_distname: ${nrbts_distname}
    [Return]    ${nrbts_distname}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown    connection=cOAM_nrbts

_Get NRBTS DistName Via SCF
    [Arguments]    ${scfc}
    [Documentation]    This keyword to get NRBTS DistName.
    ...    Examples:
    ...    | ${RF_TYPE}= | _Get NRBTS DistName Via SCF | scfc.xml |
    ${xml}=    XML.Parse Xml    ${scfc}
    ${distName}=    get_element_attribute    ${xml}    distName    .//managedObject[@class\="com.nokia.srbts.nrbts:NRBTS"]
    [Return]    ${distName}

_Upload CU Plan
    [Arguments]    ${scf_file}
    CU OAM Login    CU
    ${upload_state}=    CU.Upload Plan File    ${scf_file}    connection=cu_admin
    CU OAM Logout    CU
    ${operation_state}=    Wait Until Keyword Succeeds    1m    5s    _Upload CU plan should be successful    ${upload_state}
    Log To Console    ${\n}CU: uploaded plan
    [Return]    ${operation_state}[plan_id]

_Upload CU plan should be successful
    [Arguments]    ${upload_state}
    CU OAM Login    CU
    ${operation_state}=    CU.Get Operation State Of Uploading Plan    ${upload_state}[action_id]    connection=cu_admin
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    [Return]    ${operation_state}
    [Teardown]    CU OAM Logout    CU

_Validate CU plan
    [Arguments]    ${plan_id}
    CU OAM Login    CU
    ${validation_state}=    CU.Plan validation    ${plan_id}    connection=cu_admin
    CU OAM Logout    CU
    ${operation_state}=    Wait Until Keyword Succeeds    1m    5s
    ...  _Validate CU Plan Should Be Successful    ${plan_id}    ${validation_state}[action_id]
    Log To Console    CU: validated plan
    [Return]    ${operation_state}

_Validate CU Plan Should Be Successful
    [Arguments]    ${plan_id}    ${operation_id}
    CU OAM Login    CU
    ${operation_state}=    CU.Get Operation State Of Validating Plan    {plan_id}    ${operation_id}    connection=cu_admin
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    Log To Console    plan_id=${plan_id}
    [Return]    ${operation_state}
    [Teardown]    CU OAM Logout    CU

_Activate CU Plan
    [Arguments]    ${plan_id}
    CU OAM Login    CU
    ${activation_state}=    CU.Plan Activation    ${plan_id}    connection=cu_admin
    Wait Until Keyword Succeeds    10m    20s    _Activate CU Plan Should Be Successful    ${OAM_CU}[alias]    ${plan_id}    ${activation_state}[id]
    [Return]    ${activation_state}
    [Teardown]    CU OAM Logout    CU

_Activate CU Plan Should Be Successful
    [Arguments]    ${connection}    ${plan_id}    ${operation_id}
    ${operation_state}=    CU.Get Operation State Of Activating Plan    ${plan_id}    ${operation_id}    connection=${connection}
    Run Keyword If    "${operation_state}[status]" == "failure"    Fail    Activating CU Plan has failed.${\n}${operation_state}
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    Log To Console  CU: plan activated successfully
    [Return]    ${operation_state}

_Upload VDU Plan
    [Arguments]    ${scf_file}
    VDU OAM Login    VDU
    ${upload_state}=     VDU.Upload Plan    ${scf_file}    vdu_connection=vdu_admin
    VDU OAM Logout    VDU
    ${operation_state}=    Wait until keyword succeeds    1m    5s    _Upload VDU Plan Should Be Successful    ${upload_state}
    Log To Console    ${\n}DU: uploaded plan
    [Return]    ${operation_state}[plan_id]

_Upload VDU Plan Should Be Successful
    [Arguments]    ${upload_state}
    VDU OAM Login    VDU
    ${operation_state}=    VDU.Get Upload Plan Operation Status    ${upload_state}[action_id]    vdu_connection=vdu_admin
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    [Return]    ${operation_state}
    [Teardown]    VDU OAM Logout    VDU

_Validate VDU plan
    [Arguments]    ${plan_id}
    VDU OAM Login    VDU
    ${validation_state}=    VDU.Validate plan     ${plan_id}    vdu_connection=vdu_admin
    VDU OAM Logout    VDU
    ${operation_state}=    Wait Until Keyword Succeeds    1m    5s    _Validate VDU Plan Should Be Successful    ${plan_id}
    ...                    ${validation_state}[action_id]
    Log To Console  DU: validated plan
    [Return]  ${operation_state}

_Validate VDU Plan Should Be Successful
    [Arguments]    ${plan_id}    ${operation_id}
    VDU OAM Login    VDU
    ${operation_state}=    VDU.Get Validate Plan Operation Status    ${plan_id}    ${operation_id}    vdu_connection=vdu_admin
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    [Return]    ${operation_state}
    [Teardown]    VDU OAM Logout    VDU

_Activate VDU Plan
    [Arguments]    ${plan_id}
    VDU OAM Login    VDU
    ${activation_state}=    VDU.Activate Plan    ${plan_id}    vdu_connection=vdu_admin
    Wait Until Keyword Succeeds    10m    20s    _Activate VDU Plan Should Be Successful    vdu_admin
    ...                                          ${plan_id}    ${activation_state}[id]
    [Return]    ${activation_state}
    [Teardown]    VDU OAM Logout    VDU

_Activate VDU Plan Should Be Successful
    [Arguments]    ${connection}    ${plan_id}    ${operation_id}
    ${operation_state}=    VDU.Get Activate Plan Operation Status    ${plan_id}    ${operation_id}    vdu_connection=${connection}
    Run Keyword If    "${operation_state}[status]" == "failure"    Fail    Activating VDU Plan has failed.${\n}${operation_state}
    Should Be Equal    ${operation_state}[status]    success    ignore_case=True
    Log To Console  DU: plan activated successfully
    [Return]    ${operation_state}

_Get TL Config From File
    [Arguments]    ${filename}=${None}
    Run Keyword And Return If    ${filename} != ${None}    Import Variables    ${filename}
    ${hostname}=     Run   hostname | tr \"-\" \"_\"
    ${tl_config}=    Set variable    /home/ute/testline_configuration/${hostname}
    Import Variables    ${tl_config}

_Add Route For VDU Capture Ttitrace
    [Arguments]    ${ip}=10.0.12.1
    VDU Get Pods
    ${common_cmd}=    Set Variable    kubectl exec -it ${VDU_PODS} -c ctr-${NAMESPACE_VDU}-l2hi -n ${NAMESPACE_VDU}
    ${F1u_ip}=    VDU Get F1uplane IP
    ${cmd} =          Set Variable    ${common_cmd} -- ip route add ${ip}/32 dev f1uplane via ${F1u_ip}
    VDU Master Login
    SSH.Execute    ${cmd}    connection=${MASTER_VDU}[alias]
    ${ret} =       SSH.Execute     ${common_cmd} -- route | grep ${ip}     connection=vdu_master
    VDU Master Logout
    Should Contain    ${ret}    ${ip}

_VDU Update Uplane Configuration
    [Arguments]    ${ip}=10.0.12.1    ${port}=55900    ${dscp}=0
    ${port_1}    Convert To Integer    ${port}
    ${dscp_1}    Convert To Integer    ${dscp}
    VDU OAM Login    VDU
    ${ret1}=     VDU.Update Uplane Configuration    ${ip}    ${port_1}    ${dscp_1}    vdu_connection=vdu_admin
    Sleep    10s
    ${ret2}=     VDU.Get Trs Api Operation Status    operation_id=${ret1}    vdu_connection=vdu_admin
    Should Contain    ${ret2['status']}    Successful
    [Teardown]    VDU OAM Logout    VDU

_VDU Get Cell Dist Name
    [Arguments]    ${cell_id_list}=All
    VDU OAM Login    VDU
    ${cell_status}=     VDU.Get VDU Cells Status    vdu_connection=vdu_admin
    VDU OAM Logout    VDU
    ${all_cell_ids}=    Run Keyword If    '${cell_id_list}'=='All'    _VDU Get All Cell Ids    ${cell_status}
    ...      ELSE IF    '${cell_id_list}'!='All' and (',' not in '${cell_id_list}')     create list    ${cell_id_list}
    ...      ELSE IF    '${cell_id_list}'!='All' and (',' in '${cell_id_list}')      split string   ${cell_id_list}       ,
    ...      ELSE       fail       Please check the argument should be ALL/1/1,2,3
    ${dist_name_list}=    Create List
    FOR    ${cell_id}    IN    @{all_cell_ids}
        ${dist_name}    _VDU Get Single Cell Dist Name    ${cell_id}    ${cell_status}
        Append To List    ${dist_name_list}    ${dist_name}
    END
    [Return]    ${dist_name_list}

_VDU Get All Cell Ids
    [Arguments]    ${cell_status}
    ${all_cell_ids}=    Create List
    FOR    ${status}    IN    @{cell_status}
        ${cell_id}=    Get From Dictionary    ${status}    id
        Append To List    ${all_cell_ids}    ${cell_id}
    END
    [Return]    ${all_cell_ids}

_VDU Get Single Cell Dist Name
    [Arguments]    ${cell_id}    ${cell_status}
    FOR    ${status}    IN    @{cell_status}
        ${dist_names}    Run Keyword If    '${status['id']}'=='${cell_id}'    _VDU Get Dist Name    ${cell_id}    ${status}
        Exit For Loop If    '${status['id']}'=='${cell_id}'
    END
    [Return]    ${dist_names}

_VDU Get Dist Name
    [Arguments]    ${cell_id}    ${status}
    ${value}=    Get From Dictionary    ${status}     dist_names
    ${dist_names}    Get From Dictionary    ${value}     config
    Log To Console    cell_id=${cell_id}
    [Return]    ${dist_names}

get BSR file name
    [Arguments]       ${part_of_file_name}
     ${files}     List Files In Directory      ${PRIVATE_LOCAL_PATH}/BSR_FILE
     FOR     ${f}    IN    @{files}
         Return From Keyword if     '${part_of_file_name}' in '${f}'         ${PRIVATE_LOCAL_PATH}/BSR_FILE/${f}
     END




