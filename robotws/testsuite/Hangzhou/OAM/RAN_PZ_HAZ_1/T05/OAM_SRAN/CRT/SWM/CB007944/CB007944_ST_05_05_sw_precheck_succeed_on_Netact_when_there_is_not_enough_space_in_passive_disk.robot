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
TC_CB007944_ST_05_05_sw_precheck_succeed_on_Netact_when_there_is_not_enough_space_in_passive_disk
    [Documentation]    Short description.
    Pre-condition_delete_ReportFilePrecheck
    ${sw_release}=    Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${SW_build}  Run keyword if   '9999' in '${sw_release}'    Get Updated SW From NetAct server_Trunk
    ...    ELSE    Get Updated SW From NetAct server_Branch
    Set Test Variable    ${SW_build}
    Make disc full enough in stb logs
    Start to capture wireshark log    RP002315_05_01.pcap
    Wait Until Keyword Succeeds    1 min    30    Perfrom SW Upload
    Perform SW Precheck
    Check if all cells onAir
    Check active alarms
    Stop to capture wireshark log    RP002315_05_01.pcap
    Check SW Precheck result
    SSHLibrary.Close All Connections

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
    ${PC_connection}    SSHLibrary.open connection    ${BTS_PC_INFO.IP}
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
    Verify BTS states

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
    ${sw_update_build}    Run Keyword If    '${trunkbuildlist[-1]}'!='${Passive_Version}' and '${trunkbuildlist[-1]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-1]}
    ...    ELSE IF    '${trunkbuildlist[-2]}'!='${Passive_Version}' and '${trunkbuildlist[-2]}'!='${Active_Version}'
    ...    Set Variable    ${trunkbuildlist[-2]}
    ...    ELSE    Set Variable    ${trunkbuildlist[-3]}
    Postcondition Netact with TAF
    [Return]    ${sw_update_build}

Check SW Precheck result
    [Documentation]    Short description.
    OperateLog.File Should Contain   ${BTSFiles}${/}tshark.txt
    ...    All recent software management operations have been successful; All connected HW has correct active sw version
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    Rollback w
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    t be reject
    OperateLog.File Should Contain   ${BTSFiles}${/}tshark.txt    Enough disk space to perform SW upgrade
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    RAM usage OK
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    CPU usage OK
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    RATs state OK
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    No critical alarms
#    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A OR Healthy
    OperateLog.File Should Contain    ${BTSFiles}${/}tshark.txt    SW Precheck completed on network element
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
    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
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
    Operation_KPI_Check    ${sw_NA_precheck_end}    ${sw_NA_precheck_start}    ${Operation_precheck_expected_time}    SW_PRECHECK_Operaiton_KPI

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
    ${BTS_Connection}    SSHLibrary.Open Connection    192.168.255.1
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
#    login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    set test variable    ${BTS_Connection}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    rm -rf /ffs/run/config/ReportFilePrecheck.xml
    ${output}=  SSHLibrary.Read  delay=30s

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

Stop to capture wireshark log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    pkill -f \ tcpdump
    sleep    4s
    SSHLibrary.Write    du -h *RP002315_05_01*
    sleep    4s
    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
    Common Transform Wireshark to Txt    ${BTSFiles}${/}${logname}    tcp    tshark.txt

Check_ReportFilePrecheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=   SSHLibrary.Read   delay=30s
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
    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
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
    Operation_KPI_Check    ${sw_NA_postcheck_end}    ${sw_NA_postcheck_start}    ${Operation_postcheck_expected_time}    SW_POSTCHECK_Operaiton_KPI

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
    ${log_file}=  SSHLibrary.Read  delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml    ReportFilePostcheck.xml

Make disc full enough in stb logs
    [Documentation]    Short description.
    Log Step Header  Make disc full enough in stb logs
	${TARGET_SW_DIR}    Set Variable    /home/ute/btsauto/Big_file
    ${status}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${TARGET_SW_DIR}
    Run Keyword If    '${status[0]}'=='FAIL'    Create Directory    ${TARGET_SW_DIR}
    OperatingSystem.Directory Should Exist    ${TARGET_SW_DIR}
    OperatingSystem.Empty Directory    ${TARGET_SW_DIR}
    Set test Variable    ${TARGET_SW_DIR}
    sftp_download    ${down_server}    ute    ute@dmin5    /home/ute/HZOAM/01_BTS_SW/BigFile/BigFile.zip    ${TARGET_SW_DIR}/BigFile.zip
    ${Package_size}    Get File Size    ${TARGET_SW_DIR}/BigFile.zip
    Should Be True    ${Package_size} > 1000000
#    connect to host    host=192.168.255.129    port=22    username=toor4nsn    password=oZPS0POrRieRtu    conn_type=SSH
#    ${result}    ta_ssh_telnet.Execute Shell Command   uboot_env get | grep active_partition
#    ${passivepartition}  run keyword if  '${result[-1]}'=='1'  set variable  2  ELSE  set variable  1
#    connect to host    host=192.168.255.129    port=22    username=toor4nsn    password=oZPS0POrRieRtu    conn_type=SSH
    Login_with_multiway    ${SMOD1['TRS_IP']}    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
#    ta_ssh_telnet.Execute Shell Command   mount -o rw,remount /ffs/stb
#    ta_ssh_telnet.Execute Shell Command   mkdir /ffs/stb/logs/
    SSHLibrary.Execute Command   mount -o rw,remount /ffs/stb
    SSHLibrary.Execute Command   mkdir /ffs/stb/logs/
    sftp_upload    192.168.255.129    toor4nsn    oZPS0POrRieRtu    ${TARGET_SW_DIR}/BigFile.zip    /ffs/stb/logs/BigFile.zip

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
#    ${need_import_package}  run keyword if  '${trunkbuildlist}'=='None'  set variable  True  False
#    Log  need to import new package is
    Log  ${trunkbuildlist}
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive_Version}=    Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    ${sw_update_build}    Run Keyword If
    ...    '${trunkbuildlist[-1]}'!='${Passive_Version}' and '${trunkbuildlist[-1]}'!='${Active_Version}'    Set Variable    ${trunkbuildlist[-1]}
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
#    ${need_import_package}  run keyword if  '${trunkbuildlist}'=='None'  set variable  True  False
#    Log  need to import new package is
    Log  ${Branchbuildlist}
    ${Active_Version}=     Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${Passive_Version}=    Infomodel Get Passive SW Version  im_param=passiveBuildDescriptorId
    ${sw_update_build}    Run Keyword If    '${Branchbuildlist[-1]}'!='${Passive_Version}' and '${Branchbuildlist[-1]}'!='${Active_Version}'
    ...    Set Variable    ${Branchbuildlist[-1]}
    ...    ELSE IF    '${Branchbuildlist[-2]}'!='${Passive_Version}' and '${Branchbuildlist[-2]}'!='${Active_Version}'
    ...    Set Variable    ${Branchbuildlist[-2]}
    ...    ELSE    Set Variable    ${Branchbuildlist[-3]}
    Postcondition Netact with TAF
    [Return]    ${sw_update_build}
