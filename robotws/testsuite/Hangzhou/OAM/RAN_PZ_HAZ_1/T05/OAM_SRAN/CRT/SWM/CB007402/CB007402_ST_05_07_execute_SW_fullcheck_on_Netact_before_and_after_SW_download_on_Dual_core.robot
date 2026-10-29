*** Settings ***
Documentation     [PURPOSE]
Library    taf.nms.netact
Library    ute_tshark
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/OperateLog.py
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot


*** Keywords ***
TC_CB007402_ST_05_07_execute_SW_fullcheck_on_Netact_before_and_after_SW_download_on_Dual_core
    [Documentation]    Short description.
    Pre-condition_delete_ReportFilePrecheck
    ${sw_release}=    Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${SW_build}  Run keyword if   '9999' in '${sw_release}'    Get Updated SW From NetAct server_Trunk
    ...    ELSE    Get Updated SW From NetAct server_Branch
    #${SW_build}  Get Updated SW From NetAct server
    Set Test Variable    ${SW_build}
    Start to capture wireshark log    CB007402_05_07_01.pcap
    Wait Until Keyword Succeeds    1 min    30    Perfrom SW Upload
    Perform SW Precheck
    Stop to capture wireshark log 1    CB007402_05_07_01.pcap
    Check SW Precheck result for 2315
    Check active alarms
    Start to capture wireshark log    CB007402_05_07_01.pcap
    NMS software download
    Perform SW Precheck
    Stop to capture wireshark log 2    CB007402_05_07_01.pcap
    Check SW Precheck result for 7402
#    Check if all cells onAir
    Check active alarms
    SSHLibrary.Close All Connections

NE3S Feedback Verificaiton in Wireshark Log CB007402
    [Documentation]    Short description.
    ...    Args:
    ...        ${log_file}: <description>
    ...        ${expected_msg}: <description>
    [Arguments]    ${log_file}    ${expected_msg}
    ${output}=    Run    tshark -r "${log_file}" -Y 'xml.attribute == "name=\\"textualResponse\\""' -T pdml
    Log    ${output}
    Should Contain    ${output}    ${expected_msg}

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

Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}=  Get current date
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir
    Set test variable  ${all_cells_onair}
    #Log table  ${cell_state_table}
    ${MPLANE_IP}=  Admin Get MPLANE IP
    ${status}=  Run keyword and return status  Admin Check mplane connection  ${MPLANE_IP}
    Run keyword if    not ${status}  Set Test Restriction  Check mplane connection to admin failed!

Check active alarms
    [Documentation]    Short description.
    Log Step Header  Check active alarms
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail                  Major/Critical alarm found.
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

Get Updated SW From NetAct server_Trunk
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${sw_update_build}: <description>
    PRECONDITION NETACT WITH TAF
    ${SWlistfromNetact}    taf.nms.netact.get_list_of_imported_builds
    ${SWlist_noFSM3}  create list    None
    FOR  ${swpackage_noFSM3}  IN  @{SWlistfromNetact}
        run keyword if  'FSM3' not in '${swpackage_noFSM3}'  append to list  ${SWlist_noFSM3}  ${swpackage_noFSM3}
    END
    Log  ${SWlist_noFSM3}
    ${trunkbuildlist}  create list    None
    FOR  ${swpackage}  IN  @{SWlist_noFSM3}
        run keyword if  '9999' in '${swpackage}'  append to list  ${trunkbuildlist}  ${swpackage}
    END
    #${need_import_package}  run keyword if  '${trunkbuildlist}'=='None'  set variable  True  False
    #Log  need to import new package is
    Log  ${trunkbuildlist}
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive_Version}=    Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    ${sw_update_build}    Run Keyword If    '${trunkbuildlist[-1]}'!='${Passive_Version}' and '${trunkbuildlist[-1]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-1]}
    ...    ELSE IF    '${trunkbuildlist[-2]}'!='${Passive_Version}' and '${trunkbuildlist[-2]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-2]}
    ...    ELSE    Set Variable    ${trunkbuildlist[-3]}
    Postcondition Netact with TAF
    [Return]    ${sw_update_build}

 Get Updated SW From NetAct server_Branch
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${sw_update_build}: <description>
    PRECONDITION NETACT WITH TAF
    ${SWlistfromNetact}    taf.nms.netact.get_list_of_imported_builds
    ${sw_release}=    Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${release_Num}    Fetch from left    ${sw_release}    _
    ${SWlist_noFSM3}  create list    None
    FOR  ${swpackage_noFSM3}  IN  @{SWlistfromNetact}
        run keyword if  'FSM3' not in '${swpackage_noFSM3}'  append to list  ${SWlist_noFSM3}  ${swpackage_noFSM3}
    END
    Log  ${SWlist_noFSM3}
    ${Branchbuildlist}  create list    None
    FOR  ${swpackage}  IN  @{SWlist_noFSM3}
        run keyword if  '${release_Num}' in '${swpackage}'  append to list  ${Branchbuildlist}  ${swpackage}
    END
    #${need_import_package}  run keyword if  '${trunkbuildlist}'=='None'  set variable  True  False
    #Log  need to import new package is
    Log  ${Branchbuildlist}
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive_Version}=    Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    ${sw_update_build}    Run Keyword If
    ...    '${Branchbuildlist[-1]}'!='${Passive_Version}' and '${Branchbuildlist[-1]}'!='${Active_Version}'
    ...    Set Variable    ${Branchbuildlist[-1]}
    ...    ELSE IF    '${Branchbuildlist[-2]}'!='${Passive_Version}' and '${Branchbuildlist[-2]}'!='${Active_Version}'
    ...    Set Variable    ${Branchbuildlist[-2]}
    ...    ELSE    Set Variable    ${Branchbuildlist[-3]}
    Postcondition Netact with TAF
    [Return]    ${sw_update_build}

Check SW Precheck result for 2315
    [Documentation]    Short description.
#    OperateLog.file_should_contain   ${BTSFiles}${/}tshark.txt
    ...    All recent software management operations have been successful; All connected HW has correct active sw version
    NE3S Feedback Verificaiton in Wireshark Log CB007402    ${BTSFiles}${/}${logname}    Rollback will n
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    t be reject
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    Enough disk space to perform Full BTS SW upgrade
    NE3S Feedback Verificaiton in Wireshark Log CB007402    ${BTSFiles}${/}${logname}    RAM usage OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402    ${BTSFiles}${/}${logname}    CPU usage OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402    ${BTSFiles}${/}${logname}    RATs state OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402    ${BTSFiles}${/}${logname}    No critical alarms
#    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A OR Healthy
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    SW Precheck completed on network element
    ${healthycheck1}    run keyword and return status    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    N/A
    ${healthycheck2}    run keyword and return status    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    Disks healthy
    run keyword if    '${healthycheck1}'=='False' and '${healthycheck2}'=='False'    Fail  Disks healthy check failed
    Run keyword and ignore error    Check_ReportFilePrecheck_file_in_BTS

Check SW Precheck result for 7402
    [Documentation]    Short description.
#    OperateLog.file_should_contain   ${BTSFiles}${/}tshark.txt
    ...    All recent software management operations have been successful; All connected HW has correct active sw version
#    OperateLog.file_Should Contain    ${BTSFiles}${/}tshark.txt    Rollback will n
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   Rollback will not be rejected
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   Enough disk space to perform Full BTS SW upgrade
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   RAM usage OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   CPU usage OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   RATs state OK
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   No critical alarms
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   Migration output precheck is OK, has no error/warning
    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}   SW Precheck completed on network element
    ${healthycheck1}    run keyword and return status    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    N/A
    ${healthycheck2}    run keyword and return status    NE3S Feedback Verificaiton in Wireshark Log CB007402
        ...    ${BTSFiles}${/}${logname}    Disks healthy

#    OperateLog.file_should_contain   ${BTSFiles}${/}tshark.txt    Enough disk space to perform Full BTS SW upgrade
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    RAM usage OK
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    CPU usage OK
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    RATs state OK
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    No critical alarms
#    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A OR Healthy
#    OperateLog.file Should Contain    ${BTSFiles}${/}tshark.txt    Migration output precheck is OK, has no error/warning
#    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    SW Precheck completed on network element
#    ${healthycheck1}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A
#    ${healthycheck2}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    Disks healthy
    run keyword if    '${healthycheck1}'=='False' and '${healthycheck2}'=='False'    Fail  Disks healthy check failed
#    Run keyword and ignore error    Check_ReportFilePrecheck_file_in_BTS

Perfrom SW Upload
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect Web Url
    taf.nms.netact.Add Web Url    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}
    Should Contain    ${log}    SUCCESS
    taf.nms.netact.Delete Node    cmwas
    taf.nms.netact.Clean All

Perform SW Precheck
    [Documentation]    Short description.
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    SSHLibrary.Write
    ...    swmCLI.sh -op start --type precheck --software ${SW_build} -dn PLMN-PLMN/${BTS_INFO.MRBTS} --custom-attributes "precheckType=fullCheck"
#    or instead of  (--custom-attributes "precheckType=upgradeCfgDataValidCheck")
    ${Operation_Id}    SSHLibrary.Read Until    $
    log    ${Operation_Id}
    ${cmd2}    Set Variable    swmCLI.sh -op operation-status -id ${Operation_Id}
    Set Test Variable    ${cmd2}
    Wait Until Keyword Succeeds    5min    10s    Check SW Precheck status
    Fetch start and end time
    set test variable    ${Operation_precheck_expected_time}    60
    set test variable    ${sw_NA_precheck_start}    ${sw_NA_start}
    set test variable    ${sw_NA_precheck_end}    ${sw_NA_end}
    Operation_KPI_Check    ${sw_NA_precheck_end}    ${sw_NA_precheck_start}    ${Operation_precheck_expected_time}    SW_PRECHECK_Operaiton_KPI

Perfrom SW Activation
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    ${NETACT_SERVER_INFO.URL}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    Swm Activate    ${BTS_INFO.MRBTS}    ${download_SW_build}    alias=ta_netact
    Should Contain    ${log}    SUCCESS
    Teardown Ta Netact Swm Operations

Fetch start and end time
    [Documentation]    Short description.
    Evaluate    type($Operation_Status)
    ${deal_result}    Split String    ${Operation_Status}    ,
    log    start_date: ${deal_result[-2]}
    log    end_date: ${deal_result[-1]}
    ${deal_result[-1]}    strip string    ${deal_result[-1]}
    ${deal_result[-1]}   Fetch from left    ${deal_result[-1]}    \r
    ${deal_result[-2]}    strip string    ${deal_result[-2]}
    ${sw_NA_start}    convert date    ${deal_result[-2]}    date_format=%d.%m.%Y %H:%M:%S
    ${sw_NA_end}    convert date    ${deal_result[-1]}    date_format=%d.%m.%Y %H:%M:%S
    set test variable    ${sw_NA_start}
    set test variable    ${sw_NA_end}

Check SW Precheck status
    [Documentation]    Short description.
    SSHLibrary.Write    ${cmd2}
    ${Operation_Status}    SSHLibrary.Read Until    $
    log    ${Operation_Status}
    Should Contain    ${Operation_Status}    SUCCESS
    set test variable    ${Operation_Status}

Pre-condition_delete_ReportFilePrecheck
    [Documentation]    Short description.
    ${BTS_Connection}    Open Connection    192.168.255.1
    Login    toor4nsn    oZPS0POrRieRtu
#    login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    set test variable    ${BTS_Connection}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    rm -rf /ffs/run/config/ReportFilePrecheck.xml
    ${output}=  Read  delay=30s

Start to capture wireshark log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    ${listen port}    Set Variable    ${BTS_INFO.IP}
    ${cmd}    Set Variable    tcpdump -i any -s 0 -n -nn ip host ${listen port} -w /tmp/${logname}
    SSHLibrary.Write    ${cmd}
    sleep    4s

Stop to capture wireshark log 1
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    Set Global Variable    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    pkill -f \ tcpdump
    sleep    4s
    SSHLibrary.Write    du -h *CB007402_05_07*
    sleep    4s
    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
#    Common Transform Wireshark to Txt    ${BTSFiles}${/}${logname}    tcp    tshark.txt

Stop to capture wireshark log 2
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    Set Global Variable    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    pkill -f \ tcpdump
    sleep    4s
    SSHLibrary.Write    du -h *CB007402_05_07*
    sleep    4s
    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
#    Common Transform Wireshark to Txt    ${BTSFiles}${/}${logname}    tcp    tshark.txt

Check_ReportFilePrecheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=   Read   delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml

NMS software download
    [Documentation]    Short description.
    Precondition Netact with TAF
    ${operation_id}=    taf.nms.netact.Start SWM Operation    operation_type=download    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}
    ...                                        package=${SW_build}
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_id}
    Log    \nProgress: ${progress}    console=${TRUE}
    taf.nms.netact.Wait For SWM Operation    ${operation_id}    timeout=1800
    taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}
    ${status}=    taf.nms.netact.Get Mo Status    PLMN-PLMN/${BTS_INFO.MRBTS}
    set test variable  ${status}
    Log    Status: ${status}    console=${TRUE}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF

Check_ReportFilePostcheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=  Read  delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml    ReportFilePostcheck.xml
