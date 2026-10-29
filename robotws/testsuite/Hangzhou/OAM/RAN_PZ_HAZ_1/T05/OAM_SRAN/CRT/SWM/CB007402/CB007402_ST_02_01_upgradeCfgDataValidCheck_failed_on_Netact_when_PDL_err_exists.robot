*** Settings ***
Documentation     [PURPOSE]
Library    taf.nms.netact
Library    ute_tshark
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/OperateLog.py
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot


*** Keywords ***
TC_CB007402_ST_02_01_upgradeCfgDataValidCheck_failed_on_Netact_when_PDL_err_exists
    [Documentation]    Short description.
    Pre-condition_delete_ReportFilePrecheck
    ${sw_release}=    Infomodel Get Active SW Version  im_param=activeBuildDescriptorId
    ${SW_build}  Run keyword if   '9999' in '${sw_release}'    Get Updated SW From NetAct server_Trunk
    ...    ELSE    Get Updated SW From NetAct server_Branch
    #${SW_build}  Get Updated SW From NetAct server
    Set Test Variable    ${SW_build}
    Start to capture wireshark log    CB007402_02_01.pcap
    Wait Until Keyword Succeeds    1 min    30    Perfrom SW Upload
    Step 1: Prepare PDL err on BTS
    step 2: NMS software download
    step 3: Perform SW Precheck for 7402
    Stop to capture wireshark log    CB007402_02_01.pcap
    step 4: Check SW Precheck result for 7402
    Step 5: Check if fault30 present after valid err
    Step 6: ParaModifyCorrect and upgradeCfgDataValidCheck
    Step 7: Check if fault30 cleared after valid ok
#    Check if all cells onAir
    Check active alarms
    SSHLibrary.Close All Connections

Step 1: Prepare PDL err on BTS
    [Documentation]    Short description.
    Log Step Header  Step 1: Prepare PDL err on BTS
    _Get Scf By Admin  ${BTSFiles}/BACK_UP.xml
    ModifyParaOnSBTS  true
    _Get Scf By Admin  /home/ute/wait_validate_NOK_scf.xml
    ${validate_res}  Run keyword
    ...  taf.sbts.oam.coam.admin.validate_scf_online
    ...    /home/ute/wait_validate_NOK_scf.xml  skip_parameter_relation_errors=True
    Run keyword if  '${validate_res['requestMessage']['pdlValidationResult']['status']}'=='FAIL'
    ...  log to console   Validation err on BTS as expected.
    ...  ELSE   FAIL   Validation err not occured on BTS.

step 2: NMS software download
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

step 3: Perform SW Precheck for 7402
    [Documentation]    Short description.
    Open Connection    ${NETACT_SERVER_INFO.IP}
    Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Client Configuration    timeout=15min
    SSHLibrary.Write
    ...  swmCLI.sh -op start --type precheck --software ${SW_build} -dn PLMN-PLMN/${BTS_INFO.MRBTS} --custom-attributes "precheckType=fullCheck"
#    or instead of  (--custom-attributes "precheckType=upgradeCfgDataValidCheck")
    ${Operation_Id}    SSHLibrary.Read Until    $
    log    ${Operation_Id}
    ${cmd2}    Set Variable    swmCLI.sh -op operation-status -id ${Operation_Id}
    Set Test Variable    ${cmd2}
    Wait Until Keyword Succeeds    5min    10s    Check SW Precheck status
    Fetch start and end time
    set test variable    ${Operation_precheck_expected_time}    180
    set test variable    ${sw_NA_precheck_start}    ${sw_NA_start}
    set test variable    ${sw_NA_precheck_end}    ${sw_NA_end}
    Operation_KPI_Check    ${sw_NA_precheck_end}    ${sw_NA_precheck_start}    ${Operation_precheck_expected_time}    SW_PRECHECK_Operaiton_KPI

step 4: Check SW Precheck result for 7402
    [Documentation]    Short description.
#    ...  All recent software management operations have been successful; All connected HW has correct active sw version
#    Should Contain    ${BTSFiles}${/}tshark.txt
#    File Should Contain    ${BTSFiles}${/}tshark.txt    Rollback will n
#    File Should Contain    ${BTSFiles}${/}tshark.txt    Enough disk space to perform SW upgrade
#    File Should Contain    ${BTSFiles}${/}tshark.txt    RAM usage OK
#    File Should Contain    ${BTSFiles}${/}tshark.txt    CPU usage OK
#    File Should Contain    ${BTSFiles}${/}tshark.txt    RATs state OK
#    File Should Contain    ${BTSFiles}${/}tshark.txt    No critical alarms
#    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A OR Healthy
    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    Migration output precheck has PDL validation error
    OperateLog.file_should_contain    ${BTSFiles}${/}tshark.txt    SW Precheck completed on network element
#    ${healthycheck1}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    N/A
#    ${healthycheck2}    run keyword and return status    File Should Contain    ${BTSFiles}${/}tshark.txt    Disks healthy
#    run keyword if    '${healthycheck1}'=='False' and '${healthycheck2}'=='False'    Fail  Disks healthy check failed
#    Run keyword and ignore error    Check_ReportFilePrecheck_file_in_BTS

Step 5: Check if fault30 present after valid err
    [Documentation]    Short description.
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=30
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ${alarms_status}    ${alarms_msg}=
    ...  Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${EXPECTED}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...  Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}

Step 6: ParaModifyCorrect and upgradeCfgDataValidCheck
    [Documentation]    Short description.
    ModifyParaOnSBTS  false
    ${upgrade_validate_res}
    ...   Run keyword and return status
    ...   taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=120  detailed_output=True
    Run keyword if  '${upgrade_validate_res}'=='True'
    ...  log  upgradeCfgDataValidCheck success as expected  console=${TRUE}

Step 7: Check if fault30 cleared after valid ok
    [Documentation]    Short description.
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    Log  ${\n}Active alarms on SBTS:  console=${TRUE}
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=yes
#        ${suplement_info}  run keyword and return status  should contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='30'
#         and ${notifier_is_smod}
        ...  Fail  Alarm with fault 30 on SBTS active
    END
    Log  ${\n}Fault30 cleared  console=yes

ModifyParaOnSBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Paravalue}: <description>
    [Arguments]  ${Paravalue}=false
    create file    ${BTSFiles}/modify_${Paravalue}.json
    file_operation.Update Json File  target_json_file=${BTSFiles}/modify_${Paravalue}.json
    ...  dist_operation=update    dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter_operation=update       rfSharingEnabled=${Paravalue}
    _Perform Delta Commission By Admin    ${BTSFiles}/modify_${Paravalue}.json

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
    sleep    300s
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

Perfrom SW Upload
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect Web Url
    taf.nms.netact.Add Web Url    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}
    Should Contain    ${log}    SUCCESS
    taf.nms.netact.Delete Node    cmwas
    taf.nms.netact.Clean All

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
    Should Contain    ${Operation_Status}    FAILED
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
    ${log_file}=   Read   delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml

Check_ReportFilePostcheck_file_in_BTS
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    ls /ffs/run/config
    ${log_file}=  Read  delay=30s
    Should Contain    ${log_file}    ReportFilePrecheck.xml    ReportFilePostcheck.xml
