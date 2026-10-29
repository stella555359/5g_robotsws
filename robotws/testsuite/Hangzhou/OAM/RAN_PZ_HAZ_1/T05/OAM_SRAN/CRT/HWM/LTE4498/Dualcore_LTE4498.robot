*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/CmOperationsExtend.py


*** Keywords ***
LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Documentation]    Short description.
    Teardown Infomodel
    ${Rid}    _Get Runtime ID By Infomodel
    Set Test Variable    ${Rid}
    ${GNSS_INVUNIT}    ${BB_INVUNIT}    _check cm status
    _reset hw and check state from admin    ${GNSS_INVUNIT}    ${BB_INVUNIT}
    _wait until working from admin
    Verify BTS states

_check cm status
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${GNNS_DN_value}: <description>
    ...        ${BR_DN_value}: <description>
    ${bb_not_reset}    Get unsupport reset bbmod
    set test variable    ${bb_not_reset}
    #taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    FOR    ${Item}    IN RANGE    1    20
        ${exist}    Run keyword and return status    Get Parameter Value By Admin
        ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Exit for loop if    not ${exist}
        ${GNNS_DN_value}    Get Parameter Value By Admin
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}    configDN
        ${GNS_State1}    Run Keyword And Return Status    Should Contain    ${GNNS_DN_value}    GNSSE_A-1
        ${GNS_State2}    Run Keyword And Return Status    Should Contain    ${GNNS_DN_value}    GNSSI_A-1
        ${Correct_GNSS_INVUNIT}=    Set Variable
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Set Test Variable    ${Correct_GNSS_INVUNIT}
        ${NetAct_GNSSEvalue}    Set Variable    PLMN-PLMN/${BTS_INFO.MRBTS}/HW-1/INVUNIT-${Item}
        Set Test Variable    ${NetAct_GNSSEvalue}
        Exit For Loop If    ${GNS_State1} or ${GNS_State2}
    END
    ${serialNumber}    Get Parameter Value By Admin    ${Correct_GNSS_INVUNIT}    serialNumber
    Run keyword if    '${serialNumber}' != ''    Check GPS before reset    ${Correct_GNSS_INVUNIT}
    ${GNNS_DN_value}    set variable if    '${serialNumber}' == ''    None
    ${Correct_GNSS_INVUNIT}    set variable if    '${serialNumber}' == ''    None
    ${NetAct_GNSSEvalue}    set variable if    '${serialNumber}' == ''    None
    set test variable    ${NetAct_GNSSEvalue}
    FOR    ${Item}    IN RANGE    1    20
        ${exist}    Run keyword and return status    Get Parameter Value By Admin
        ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Exit for loop if    not ${exist}
        ${BR_DN_value}    Get Parameter Value By Admin
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}    configDN

        ${BB_exist}    Run Keyword And Return Status    Should Contain    ${BR_DN_value}    BBMOD_A
        ${BR_run_value}    Run keyword if    ${BB_exist}
        ...  Get Parameter Value By Admin
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}    runtimeDN
        Run keyword if    ${BB_exist}
        ...    Continue For Loop If     '${BR_run_value}' in ${bb_not_reset}
        ${Rmod_exist}    Run Keyword And Return Status    Should Contain    ${BR_DN_value}    RMOD_A
        ${Correct_INVUNIT}=    Set Variable
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Set Test Variable    ${Correct_INVUNIT}
        ${NetAct_value}    Set Variable    PLMN-PLMN/${BTS_INFO.MRBTS}/HW-1/INVUNIT-${Item}
        Set Test Variable    ${NetAct_value}
        Exit For Loop If    ${BB_exist} or ${Rmod_exist}
    END
    ${status}    Run keyword if    ${BB_exist} or ${Rmod_exist}    Get Parameter Value By Admin
    ...    ${Correct_INVUNIT}    state
    Run keyword if    ${BB_exist} or ${Rmod_exist}    Should Be Equal    ${status}    working
    [Return]    ${GNNS_DN_value}    ${BR_DN_value}

Check GPS before reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Correct_GNSSE_INVUNIT}: <description>
    [Arguments]    ${Correct_GNSSE_INVUNIT}
    ${configDN_GNSSE}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    configDN
    Should Not Be empty    ${configDN_GNSSE}
    ${inventoryUnitType}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    inventoryUnitType
    Should Not Be empty    ${inventoryUnitType}
    ${parentDN}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    parentDN
    Should Not Be empty    ${parentDN}
    ${runtimeDN}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    runtimeDN
    Should Not Be empty    ${runtimeDN}
    ${state}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    state
    Should Contain Any    ${state}    working    degraded
    ${vendorName}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    vendorName
    Should Not Be empty    ${vendorName}
    ${vendorName}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    vendorName
    Should Not Be empty    ${vendorName}
    ${vendorUnitFamilyType}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    vendorUnitFamilyType
    Should Not Be empty    ${vendorUnitFamilyType}
    ${vendorUnitTypeNumber}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    vendorUnitTypeNumber
    Should Not Be empty    ${vendorUnitTypeNumber}
    ${versionNumber}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    versionNumber
    Should Not Be empty    ${versionNumber}

Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Documentation]    Short description.
    Perfrom CM Upload
    Teardown Infomodel
    ${Rid}    _Get Runtime ID By Infomodel
    Set Test Variable    ${Rid}
    ${GNSS_DN_value}    ${BR_DN_value}    _check cm status
    sleep    20s
    _reset hw and check state from netact    4998_01_01.pcap    4498_02.pcap    ${GNSS_DN_value}    ${BR_DN_value}
    _wait unitl working from netact

Perfrom CM Upload
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect Web Url
    taf.nms.netact.Add Web Url    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    &{dict}=     Create Dictionary    '-sranBtsHwContentInUse'=${True}
#    '-lteHwContentInUse'=${True}
    ${log}    taf.nms.netact.Upload Configuration    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}   parameters=${dict}
    Should Contain    ${log}    SUCCESS
    taf.nms.netact.Delete Node    cmwas
    taf.nms.netact.Clean All

_reset hw and check state from admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${GNSS_DN_value}: <description>
    ...        ${BR_DN_value}: <description>
    [Arguments]    ${GNSS_DN_value}    ${BR_DN_value}
    #Start Admin
    Start Infomodel
    Run keyword if    'GNSS' in '${GNSS_DN_value}'    Run keywords
    ...    taf.sbts.oam.coam.admin.reset_unit
    ...    ${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1    Warm    alias=default
    ...    AND   ute_admin_infomodel.Query Infomodel    ${Correct_GNSSE_INVUNIT} is [state=faulty]    alias=default    timeout=300
    sleep    30s
    ${num}    Get HW Num    ${BR_DN_value}
    set test variable    ${num}
    Run keyword if    'BBMOD' in '${BR_DN_value}'    Run keywords
    ...    taf.sbts.oam.coam.admin.Run keyword in background      reset_unit
    ...    ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/BBMOD-${num}    Warm    timeout=300    alias=default
    ...    AND    Wait Until Keyword Succeeds    5min     10s
    ...    ute_admin_infomodel.Query Infomodel    ${Correct_INVUNIT} is [state=faulty]    alias=default    timeout=300
    ...    ELSE    Run keywords    taf.sbts.oam.coam.admin.Run keyword in background
    ...     reset_unit    ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/RMOD-${num}
    ...    Warm    timeout=300    alias=default
    ...    AND    Wait Until Keyword Succeeds    5min     10s
    ...    ute_admin_infomodel.Query Infomodel    ${Correct_INVUNIT} is [state=faulty]    alias=default    timeout=300
    #taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    Teardown Infomodel
    sleep    90s

Get HW Num
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${DN}: <description>
    ...
    ...    Returns:
    ...        ${num}: <description>
    [Arguments]    ${DN}
    ${num}    Fetch from right    ${DN}    -
    [return]    ${num}

_reset hw and check state from netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname_1}: <description>
    ...        ${logname_2}: <description>
    ...        ${GNSS_DN_value}: <description>
    ...        ${BR_DN_value}: <description>
    [Arguments]    ${logname_1}    ${logname_2}    ${GNSS_DN_value}    ${BR_DN_value}
    ${rid}    _Get Runtime ID By Infomodel
    #Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.Teardown Admin
    #taf.sbts.oam.coam.admin.Setup Admin
    Run keyword if    'GNSS' in '${GNSS_DN_value}'    Run keywords
    ...    Start tcpdump     ${logname_1}
    ...    AND    taf.sbts.oam.coam.admin.reset_unit
    ...    ${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1    Warm    alias=default    timeout=300
    ...    AND    Stop and Check tcpdump     ${logname_1}    tshark_01.txt
    ${num}    Get HW Num    ${BR_DN_value}
    set test variable    ${num}
    Start tcpdump    ${logname_2}
    Run keyword if    'BBMOD' in '${BR_DN_value}'
    ...    taf.sbts.oam.coam.admin.reset_unit
    ...    ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/BBMOD-${num}    Warm    timeout=300    alias=default
    ...    ELSE    taf.sbts.oam.coam.admin.reset_unit    ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/RMOD-${num}
    ...    Warm    timeout=300    alias=default
	sleep    5min
	Stop and Check tcpdump    ${logname_2}    tshark_02.txt
    #[Teardown]    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.Teardown Admin

Start tcpdump
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    ${listen port}    Set Variable    ${BTS_INFO.IP}
    ${cmd}    Set Variable    tcpdump -i any -s 0 -n -nn ip host ${listen port} -w /tmp/${logname}
    set client configuration    prompt=tcpdump: listening on any
    Write    ${cmd}
    ${output}   Read until prompt
    Log  ${output}
    sleep    10s

Stop and Check tcpdump
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    ...        ${tshark_txt}: <description>
    [Arguments]    ${logname}    ${tshark_txt}
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Execute Command  pkill -f \tcpdump
    Sftp Download    192.168.255.1   toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
    Common Transform Wireshark to Txt     ${BTSFiles}${/}${logname}    tcp    ${tshark_txt}
    ${result}=     SSHLibrary.execute command    cat ${BTSFiles}${/}${tshark_txt} |grep faulty
    Should Contain    ${result}    faulty
    sleep    10s

Get TestData From XML
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${testdata}: <description>
    ${plan_xml}    XML.Parse Xml    ${plan_path}
    ${objects}    XML.Get Elements    ${plan_xml}    .//managedObject
    ${testdata}    Create Dictionary
    FOR    ${obj}    IN    @{objects}
    ${dn}    XML.Get Element Attribute    ${obj}    distName
    ${p_objs}    XML.Get Elements    ${plan_xml}    .//managedObject[@distName="${dn}"]/p
    ${param_value_dict}    Generate Parameter Value Dic    ${p_objs}
    Set To Dictionary    ${testdata}    ${dn}=${param_value_dict}
    END
    [Return]    ${testdata}

Common Transform Wireshark to Txt
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${wiresharkcaplogpath}: <description>
    ...        ${filterconditions}: <description>
    ...        ${txtname}: <description>
    ...
    ...    Returns:
    ...        ${retFilePath}: <description>
    [Arguments]    ${wiresharkcaplogpath}    ${filterconditions}    ${txtname}=tshark.txt
    ${retFilePath}    Set Variable    ${BTSFiles}${/}${txtname}
    ${PC_connection}    open connection    ${BTS_PC_INFO.IP}
    login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    SSHLibrary.Switch Connection    ${PC_connection}
    SSHLibrary.Write    cd /home/ute/
    sleep    4s
    SSHLibrary.Write    tshark -r "${wiresharkcaplogpath}" -Y "${filterconditions}" -x -V> "${retFilePath}"
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${retFilePath}
    Comment    Append To File    ${retFilePath}    Frame 99999: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    [Return]    ${retFilePath}

_wait unitl working from netact
    [Documentation]    Short description.
    Wait Until Keyword Succeeds  600  5  Check Actual Configuration Parameters  ${NetAct_value}
                                                                           ...  ${NETACT_SERVER_INFO.IP}
                                                                           ...  ${NETACT_SERVER_INFO.USERNAME}
                                                                           ...  ${NETACT_SERVER_INFO.PASSWORD}
                                                                           ...  state=working
    ${status}    Run Keyword And Return Status    Run keyword if    ${NetAct_GNSSEvalue}
    ...  Wait Until Keyword Succeeds  60  5  Check Actual Configuration Parameters  ${NetAct_GNSSEvalue}
                                                                               ...  ${NETACT_SERVER_INFO.IP}
                                                                               ...  ${NETACT_SERVER_INFO.USERNAME}
                                                                               ...  ${NETACT_SERVER_INFO.PASSWORD}
                                                                               ...  state=working
    Run Keyword If    ${status}==False and ${NetAct_GNSSEvalue}
    ...  Wait Until Keyword Succeeds  60  5  Check Actual Configuration Parameters  ${NetAct_GNSSEvalue}
                                                                               ...  ${NETACT_SERVER_INFO.IP}
                                                                               ...  ${NETACT_SERVER_INFO.USERNAME}
                                                                               ...  ${NETACT_SERVER_INFO.PASSWORD}
                                                                               ...  state=degraded

_wait until working from admin
    [Documentation]    Short description.
#    Start Admin
    Start Infomodel
    ute_admin_infomodel.Query Infomodel    ${Correct_INVUNIT} is [state=working]    alias=default    timeout=300

    ${status}    Run Keyword And Return Status    Run keyword if    'GNSS' in '${Correct_GNSS_INVUNIT}'   ute_admin_infomodel.Query Infomodel
    ...  ${Correct_GNSS_INVUNIT} is [state=working]    alias=default    timeout=300
    Run Keyword If    ${status}==False and 'GNSS' in '${Correct_GNSS_INVUNIT}'    ute_admin_infomodel.Query Infomodel
    ...  ${Correct_GNSS_INVUNIT} is [state=degraded]    alias=default    timeout=300
    Teardown Infomodel

Get unsupport reset bbmod
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${bb_not_reset}: <description>
    Start infomodel
    @{bb_not_reset}    create list
    ${r1}   set variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/BBADM_R-1/BBPOOL_R-*
    ${bbpool_list}     ute_admin_infomodel.Query Infomodel
    ...  query=get list ${r1}   alias=default    timeout=300
    FOR    ${bb_item}    IN   @{bbpool_list}
        ${bbmod_dn}    Run keyword if    'GSM' in '${bb_item}[bbPoolTech]' or 'WCDMA' in '${bb_item}[bbPoolTech]'
        ...    Fetch from left    ${bb_item}[bbPwrGroupDNList][0]   /POWERGROUP_R
        Run keyword if    'GSM' in '${bb_item}[bbPoolTech]' or 'WCDMA' in '${bb_item}[bbPoolTech]'
        ...    Append to list    ${bb_not_reset}    ${bbmod_dn}
    END
    Teardown Infomodel
    [Return]    ${bb_not_reset}
