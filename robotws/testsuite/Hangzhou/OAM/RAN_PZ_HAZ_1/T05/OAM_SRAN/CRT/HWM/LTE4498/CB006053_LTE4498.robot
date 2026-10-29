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
    _check cm status
    _reset hw and check state from admin
    _wait until working from admin
    Verify BTS states

_check cm status
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    FOR    ${Item}    IN RANGE    1    10
        ${DN_value}    Get Parameter Value By Admin
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}    configDN
        ${Return_State}    Run Keyword And Return Status    Should Contain    ${DN_value}    GNSSE_A-1
        ${Correct_GNSSE_INVUNIT}=    Set Variable
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Set Test Variable    ${Correct_GNSSE_INVUNIT}
        ${NetAct_GNSSEvalue}    Set Variable    PLMN-PLMN/${BTS_INFO.MRBTS}/HW-1/INVUNIT-${Item}
        Set Test Variable    ${NetAct_GNSSEvalue}
        Exit For Loop If    ${Return_State}
    END
    ${configDN_GNSSE}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    configDN
    Should Not Be empty    ${configDN_GNSSE}
    ${inventoryUnitType}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    inventoryUnitType
    Should Not Be empty    ${inventoryUnitType}
    ${parentDN}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    parentDN
    Should Not Be empty    ${parentDN}
    ${runtimeDN}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    runtimeDN
    Should Not Be empty    ${runtimeDN}
    Set Test Variable      ${runtimeDN}
    ${serialNumber}    Get Parameter Value By Admin    ${Correct_GNSSE_INVUNIT}    serialNumber
    Should Not Be empty    ${serialNumber}
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
    FOR    ${Item}    IN RANGE    1    10
        ${DN_value}    Get Parameter Value By Admin
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}    configDN
        ${Return_State}    Run Keyword And Return Status    Should Contain    ${DN_value}    BBMOD_A-2
        ${Correct_INVUNIT}=    Set Variable
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-${Rid}/MRBTS_R-${Rid}/HW_R-1/INVUNIT_R-${Item}
        Set Test Variable    ${Correct_INVUNIT}
        ${NetAct_value}    Set Variable    PLMN-PLMN/${BTS_INFO.MRBTS}/HW-1/INVUNIT-${Item}
        Set Test Variable    ${NetAct_value}
        Exit For Loop If    ${Return_State}
    END
    ${state5}    Get Parameter Value By Admin    ${Correct_INVUNIT}    state
    Should Be Equal    ${state5}    working

ASMI_LTE4498_ST_04_Do HW inverntory upload from Netact independently form CM
    [Documentation]    Short description.
    Run keyword and ignore error    taf.nms.netact.Delete Node    cmwas
    Perfrom CM Upload
    Teardown Infomodel
    ${Rid}    _Get Runtime ID By Infomodel
    Set Test Variable    ${Rid}
    _check cm status
    sleep    20s
    _reset hw and check state from netact    4998_01_01.pcap    4498_02.pcap
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
    Start Admin
    Start Infomodel
    taf.sbts.oam.coam.admin.reset_unit
    ...  ${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1    Warm    alias=default
    ute_admin_infomodel.Query Infomodel    ${Correct_GNSSE_INVUNIT} is [state=faulty]    alias=default    timeout=20
    sleep    30s
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.reset_unit
    ...  ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    Warm    timeout=5    alias=default
    ute_admin_infomodel.Query Infomodel    ${Correct_INVUNIT} is [state=faulty]    alias=default    timeout=60
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    Teardown Infomodel
    sleep    90s

_reset hw and check state from netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    ...        ${logname_2}: <description>
    [Arguments]    ${logname}    ${logname_2}
    ${rid}    _Get Runtime ID By Infomodel
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.Teardown Admin
    taf.sbts.oam.coam.admin.Setup Admin
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    ${listen port}    Set Variable    ${BTS_INFO.IP}
    ${cmd}    Set Variable    tcpdump -i any -s 0 -n -nn ip host ${listen port} -w /tmp/${logname}
    set client configuration    prompt=tcpdump: listening on any
    Write    ${cmd}
    ${output}   Read until prompt
    Log  ${output}
    sleep  10s
	FOR    ${Item}    IN RANGE    1    5
        taf.sbts.oam.coam.admin.reset_unit
    ...  ${runtimeDN}
    ...  Hard    timeout=60    alias=default
        sleep    60s
    END
    Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Execute Command  pkill -f \tcpdump
    Sftp Download    192.168.255.1   toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
    Common Transform Wireshark to Txt     ${BTSFiles}${/}${logname}    tcp    tshark.txt
    ${result}=     SSHLibrary.execute command    cat ${BTSFiles}${/}tshark.txt |grep faulty
    Should Contain    ${result}    faulty
    Comment    Wait Until Keyword Succeeds    60    1    Check Actual Configuration Parameters
    ...  PLMN-PLMN/${BTS_INFO.MRBTS}/HW-1/INVUNIT-4    state=faulty
    ...    alias=ta_netact
    sleep    10s
	Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    ${listen port}    Set Variable    ${BTS_INFO.IP}
	${cmd_1}    Set Variable    tcpdump -i any -s 0 -n -nn ip host ${listen port} -w /tmp/${logname_2}
    set client configuration    prompt=tcpdump: listening on any
    Write    ${cmd_1}
    ${output_2}   Read until prompt
    Log  ${output_2}
    sleep  10s
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.reset_unit
    ...  ${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    Warm    timeout=5    alias=default
	sleep    5min
	Login_with_multiway   192.168.255.129    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Execute Command  pkill -f \tcpdump
    Sftp Download    192.168.255.129    toor4nsn    oZPS0POrRieRtu
    ...  /tmp/${logname_2}    ${BTSFiles}${/}${logname_2}
    Common Transform Wireshark to Txt    ${BTSFiles}${/}${logname_2}    tcp    tshark_02.txt
    ${result_2}=     SSHLibrary.execute command    cat ${BTSFiles}${/}tshark_02.txt |grep faulty
    Should Contain    ${result_2}    faulty

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
    ${status}    Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  60  5  Check Actual Configuration Parameters  ${NetAct_GNSSEvalue}
                                                                               ...  ${NETACT_SERVER_INFO.IP}
                                                                               ...  ${NETACT_SERVER_INFO.USERNAME}
                                                                               ...  ${NETACT_SERVER_INFO.PASSWORD}
                                                                               ...  state=working
    Run Keyword If    ${status}==False
    ...  Wait Until Keyword Succeeds  60  5  Check Actual Configuration Parameters  ${NetAct_GNSSEvalue}
                                                                               ...  ${NETACT_SERVER_INFO.IP}
                                                                               ...  ${NETACT_SERVER_INFO.USERNAME}
                                                                               ...  ${NETACT_SERVER_INFO.PASSWORD}
                                                                               ...  state=degraded

_wait until working from admin
    [Documentation]    Short description.
    Start Admin
    Start Infomodel
    ute_admin_infomodel.Query Infomodel    ${Correct_INVUNIT} is [state=working]    alias=default    timeout=120
    ${status}    Run Keyword And Return Status    ute_admin_infomodel.Query Infomodel
    ...  ${Correct_GNSSE_INVUNIT} is [state=working]    alias=default    timeout=60
    Run Keyword If    ${status}==False    ute_admin_infomodel.Query Infomodel
    ...  ${Correct_GNSSE_INVUNIT} is [state=degraded]    alias=default    timeout=60
    Teardown Infomodel
