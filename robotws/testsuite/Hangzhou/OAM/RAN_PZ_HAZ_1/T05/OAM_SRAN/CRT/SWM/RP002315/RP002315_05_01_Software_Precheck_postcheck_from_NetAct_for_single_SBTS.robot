*** Settings ***
Documentation     [PURPOSE]
Library            taf.nms.netact
Library           ute_tshark
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/OperateLog.py
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../CB002956/RP002956_ST_SWM_duration_of_SW_Download_Activation_KPI.robot


*** Keywords ***
RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Documentation]    Short description.
    Pre-condition_delete_ReportFilePrecheck
    ${sw_release}=    Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${SW_build}  Run keyword if   '9999' in '${sw_release}'    Get Updated SW From NetAct server_Trunk
    ...    ELSE    Get Updated SW From NetAct server_Branch
    #${SW_build}  Get Updated SW From NetAct server
    Set Test Variable    ${SW_build}
    Start to capture wireshark log    RP002315_05_01.pcap
    Wait Until Keyword Succeeds    1 min    30    Perfrom SW Upload
    Perform SW Precheck
    Check if all cells onAir
    Check active alarms
    Stop to capture wireshark log    RP002315_05_01.pcap
    Check SW Precheck result
    SSHLibrary.Close All Connections
    [teardown]    Run keyword and ignore error       taf.sbts.oam.coam.admin.Stop IP Capture File

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
#    ${PC_connection}    open connection    ${BTS_PC_INFO.IP}
#    login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
#    SSHLibrary.Switch Connection    ${PC_connection}
#    SSHLibrary.Write    cd /home/ute/
    sleep    5s
#    SSHLibrary.Write    tshark -r "${wiresharkcaplogpath}" -Y "${filterconditions}" -x -V> "${retFilePath}"
    OperatingSystem.Run    tshark -r "${wiresharkcaplogpath}" -Y "${filterconditions}" -x -V> "${retFilePath}"
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${retFilePath}
    Comment    Append To File  ${retFilePath}    Frame 99999: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
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
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir for 2315
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

Get Updated SW From NetAct server
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${sw_update_build}: <description>
    PRECONDITION NETACT WITH TAF
    ${SWlistfromNetact}    taf.nms.netact.get_list_of_imported_builds
    ${trunkbuildlist}  create list    None
    FOR  ${swpackage}  IN  @{SWlistfromNetact}
        run keyword if  '9999' in '${swpackage}'  append to list  ${trunkbuildlist}  ${swpackage}
    END
    Log  ${trunkbuildlist}
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive_Version}=    Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    ${sw_update_build}    Run Keyword If
    ...    '${trunkbuildlist[-1]}'!='${Passive_Version}' and '${trunkbuildlist[-1]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-1]}
    ...    ELSE IF    '${trunkbuildlist[-2]}'!='${Passive_Version}' and '${trunkbuildlist[-2]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-2]}
    ...    ELSE    Set Variable    ${trunkbuildlist[-3]}
    Postcondition Netact with TAF
    [Return]    ${sw_update_build}

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

Check SW Precheck result
    [Documentation]    Short description.
    File Should Contain    ${BTSFiles}${/}tshark.txt
    ...    All recent software management operations have been successful; All connected HW has correct active sw version
    File Should Contain    ${BTSFiles}${/}tshark.txt    Rollback w
    File Should Contain    ${BTSFiles}${/}tshark.txt    ot be rejec
    File Should Contain    ${BTSFiles}${/}tshark.txt    Enough disk space to perform Full BTS SW upgrade
    File Should Contain    ${BTSFiles}${/}tshark.txt    RAM usage OK
    File Should Contain    ${BTSFiles}${/}tshark.txt    CPU usage OK
    File Should Contain    ${BTSFiles}${/}tshark.txt    RATs state OK
    File Should Contain    ${BTSFiles}${/}tshark.txt    No critical alarms
    #File Should Contain    ${BTSFiles}${/}tshark.txt    N/A OR Healthy
    File Should Contain    ${BTSFiles}${/}tshark.txt    SW Precheck completed on network element
    ${healthycheck1}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A
    ${healthycheck2}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    Disks healthy
    run keyword if    '${healthycheck1}'=='False' and '${healthycheck2}'=='False'    Fail  Disks healthy check failed
    Run keyword and ignore error    Check_ReportFilePrecheck_file_in_BTS

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
    ${Operation_Id}    SSHLibrary.Read Until    $
    log    ${Operation_Id}
    ${cmd2}    Set Variable    swmCLI.sh -op operation-status -id ${Operation_Id}
    Set Test Variable    ${cmd2}
    Wait Until Keyword Succeeds    5min    10s    Check SW Precheck status
    Fetch start and end time
    set test variable    ${Operation_precheck_expected_time}    60
    set test variable    ${sw_NA_precheck_start}    ${sw_NA_start}
    set test variable    ${sw_NA_precheck_end}    ${sw_NA_end}
    Operation_KPI_Check    ${sw_NA_precheck_end}    ${sw_NA_precheck_start}
    ...    ${Operation_precheck_expected_time}    SW_PRECHECK_Operaiton_KPI

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
#    SSHLibrary.Switch Connection    ${BTS_Connection}
#    ${listen port}    Set Variable    ${BTS_INFO.IP}
#    ${cmd}    Set Variable    tcpdump -i any not host 192.168.255.129 -s 0 -w /tmp/${logname}
#    SSHLibrary.Write    ${cmd}
#    sleep    4s
    taf.sbts.oam.coam.admin.start_ip_capture_file    measurement_point=NE_Terminated
    ...     uplane_capturing=${FALSE}    password=${EMPTY}

Stop to capture wireshark log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
#    SSHLibrary.Switch Connection    ${BTS_Connection}
#    SSHLibrary.Write    pkill -f \ tcpdump
#    sleep    4s
#    SSHLibrary.Write    du -h *RP002315_05_01*
#    sleep    4s
#    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    ${BTSFiles}${/}IP_Traffic_${BTS_INFO.MRBTS}_${timestamp}.pcap.gz
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${target_file_name}
    Common Transform Wireshark to Txt    ${target_file_name}    http    tshark.txt


Check_ReportFilePrecheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=   Read   delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml

RP002315_05_02_Software Postcheck from NetAct for single SBTS
    [Documentation]    Short description.
    Pre-condition_delete_ReportFilePrecheck
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${SW_build}    Set Variable    ${Active_Version}
    Set Test Variable    ${SW_build}
    Start to capture wireshark log    RP002315_05_02.pcap
    Perform SW Postcheck
    Stop to capture wireshark log    RP002315_05_02.pcap
    Check SW Postcheck result

Perform SW Download
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    web_url=${NETACT_SERVER_INFO.URL}    web_user=${NETACT_SERVER_INFO.USERNAME}
    ...    web_pass=${NETACT_SERVER_INFO.PASSWORD}
    ${log}    swm download    ${BTS_INFO.MRBTS}    ${sw_release}    alias=ta_netact
    Should Contain    ${log}    SUCCESS

Perfrom SW Activation
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    ${NETACT_SERVER_INFO.URL}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    Swm Activate    ${BTS_INFO.MRBTS}    ${download_SW_build}    alias=ta_netact
    Should Contain    ${log}    SUCCESS
    Teardown Ta Netact Swm Operations

Perform SW Postcheck
    [Documentation]    Short description.
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
#    ${sw_NA_postcheck_start}=  Get current date
    SSHLibrary.Write    swmCLI.sh -op start --type postcheck --software ${SW_build} -dn PLMN-PLMN/${BTS_INFO.MRBTS}
    ${Operation_Id}    SSHLibrary.Read Until    $
    log    ${Operation_Id}
    ${cmd2}    Set Variable    swmCLI.sh -op operation-status -id ${Operation_Id}
    Set Test Variable    ${cmd2}
    Wait Until Keyword Succeeds    3min    10s    Check SW Postcheck status
#    ${sw_NA_postcheck_end}=  Get current date
    Fetch start and end time
    set test variable    ${Operation_postcheck_expected_time}    45
    set test variable    ${sw_NA_postcheck_start}    ${sw_NA_start}
    set test variable    ${sw_NA_postcheck_end}    ${sw_NA_end}
    Operation_KPI_Check    ${sw_NA_postcheck_end}    ${sw_NA_postcheck_start}
    ...    ${Operation_postcheck_expected_time}    SW_POSTCHECK_Operaiton_KPI

Check SW Postcheck status
    [Documentation]    Short description.
    SSHLibrary.Write    ${cmd2}
    ${Operation_Status}    SSHLibrary.Read Until    $
    log    ${Operation_Status}
    Should Contain    ${Operation_Status}    SUCCESS
    set test variable    ${Operation_Status}

Check SW Postcheck result
    [Documentation]    Short description.
    File Should Contain    ${BTSFiles}${/}tshark.txt    CPU usage OK
    File Should Contain    ${BTSFiles}${/}tshark.txt    RAM usage OK
    Run keyword and ignore error    File Should Contain    ${BTSFiles}${/}tshark.txt    RATs status OK
    File Should Contain    ${BTSFiles}${/}tshark.txt    SW Postcheck completed on network element
    Run keyword and ignore error    Check_ReportFilePostcheck_file_in_BTS

Check_ReportFilePostcheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=  Read  delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml    ReportFilePostcheck.xml

Ensure that BTS remains OnAir for 2315
    [Documentation]    Short description.
    Log   BTS will be checked ${Additional Checks Number} times with interval ${Sleep interval} if it remains onAir
    ...   console=${TRUE}
    FOR  ${i}  IN RANGE  ${Additional Checks Number}
        ${is_onAir}=    Verify states for 2315
        Log    BTS is onAir    console=${TRUE}
        Sleep   ${Sleep interval}
    END

Verify states for 2315
    [Documentation]    Short description.
    ${status}  ${system_modules_working}=   Run Keyword And Ignore Error    Verify system modules states
    ${status}  ${radio_modules_working}=    Run Keyword And Ignore Error    Verify radio modules states
    Run keyword if   not(${system_modules_working} and ${radio_modules_working})    Fail
    ...    msg=At least one module has state other than expected

    ${status}  ${cells_GSM_onair}=          Run Keyword And Ignore Error    Verify GSM cells states
    ${status}  ${cells_WCDMA_onair}=        Run Keyword And Ignore Error    Verify WCDMA cells states
    ${status}  ${cells_LTE_onair}=          Run Keyword And Ignore Error    Verify LTE cells states
    Run keyword if   not(${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair})    Fail
    ...    msg=At least one cell has state other than expected

    ${IGNORED_ALARMS}=      Create Dictionary  severity=Minor
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${IGNORED_PATTERNS}=    Create List  ${IGNORED_ALARMS}
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  ignored_patterns=${IGNORED_PATTERNS}  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    not('${alarms_status}'=='PASS')    Fail    msg=Major alarm found.
