*** Settings ***
Documentation     author: LiuNing
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ning.4.liu@nokia-sbell.com

Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${web_ui}    https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${Max_loop}    10
${Checked_file_name}    snapshot_file_list
${Collect_Snapshot_failed}    Collect Snapshot Failed
*** Keywords ***
Get version based on stream version
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    #${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${sw_version}

Login CU WEBUI
	${version}    Get version based on stream version
    coam_cu.enable_virtual_display
    sleep    5s
    coam_cu.login    url=${web_ui}
    ...    username=Nemuadmin    password=nemuuser      browser=firefox    timeout=60    version=${version}


Commission_Case_teardown
    log to console    restore test line
    Run Keyword And Ignore Error    coam_cu.Choose Plan    plan_name=${Plan_Name}
    sleep    5s
    Run Keyword And Ignore Error    coam_cu.delete_plan
    coam_cu.logout
    coam_cu.disable_virtual_display
    CI_interface.Common Case Teardown

Case_teardown
    coam_cu.logout
    coam_cu.disable_virtual_display
    CI_interface.Common Case Teardown

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=COAM
    CI_interface.Common Case Teardown

Snapshot_Case_teardown
    Run Keyword And Ignore Error    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    run keyword and ignore error    AdminCli disconnection and Test teardown

Check snapshot file list
	[Arguments]    ${local_file_path}    ${snapshot_extract}
	${unzip_result}=    csn.execute    command=unzip -o ${local_file_path} -d ${snapshot_extract}    connection=ute
	${unzip_result}    split string    ${unzip_result}    \r\n
    ${unzip_result}    convert to string    ${unzip_result}
	${checked_snapshot}    Run Keyword And Continue On Failure
    ...    Should Match Regexp    ${unzip_result}    snapshot_file_list.*?
	should not be empty    ${checked_snapshot}
	[return]    ${checked_snapshot}

unzip snapshot and check files
    [Arguments]    ${local_file_path}    ${coverage}
    @{filename_list}   Create List
    @{filename_list_all}=    Create List    E040_runtime    E040_startup    E040_ntp   E040_lom_fm   E040_fault_log
    ...    E040_trace_controller_master_nr    E040_fm_fault    E040_sdl_namespace    E040_pm9
    ...    E040_OAM_CM    E040_tas    E040_snapshot    E040_LogCollectionSummary
    ...    E050_startup   E050_runtime    E050_lom_fm    E050_fault    E050_ntp
    ...    E051_startup   E051_runtime    E051_lom_fm    E051_fault    E051_ntp
    ...    E05F_startup   E05F_runtime    E05F_lom_fm    E05F_fault    E05F_ntp
    ...    E060_startup   E060_runtime    E060_lom_fm    E060_fault    E060_ntp
    ...    E070_startup   E070_runtime    E070_lom_fm    E070_fault    E070_ntp
    ...    E100_runtime   E100_LINUX    E100_lom_fm   E100_fault    E100_L2TraceHi    E100_EmTrace
    ...    E100_memdump

    @{filename_list_most}=    Create List     E040_runtime    E040_startup    E040_OAM_CM    E040_tas   E040_LogCollectionSummary
    ...    E040_snapshot    E050_startup   E050_runtime    E051_startup   E051_runtime
    ...    E05F_startup   E05F_runtime    E060_startup   E060_runtime    E070_startup   E070_runtime
    ...    E100_memdump

    @{RCP_filename_list}=    Create List     cpcl-000/acl_info/acl_info    cpif-000/acl_info/acl_info    cpnb-000/acl_info/acl_info
    ...    cpnrt-000/acl_info/acl_info    cpue-000/acl_info/acl_info    db-000/acl_info/acl_info    oam-000/acl_info/acl_info
    ...    upue-000/acl_info/acl_info    cpcl-000/actiontrigger_info/actiontrigger_info    cpif-000/actiontrigger_info/actiontrigger_info
    ...    cpnb-000/actiontrigger_info/actiontrigger_info    cpnrt-000/actiontrigger_info/actiontrigger_info
    ...     cpue-000/actiontrigger_info/actiontrigger_info    oam-000/actiontrigger_info/actiontrigger_info
    ...    db-000/actiontrigger_info/actiontrigger_info    upue-000/actiontrigger_info/actiontrigger_info
    ...    oam-000/alarms_info/alarms_info    cpcl-000/arp_info/arp_info    cpif-000/arp_info/arp_info    cpnb-000/arp_info/arp_info
    ...    cpnrt-000/arp_info/arp_info    cpue-000/arp_info/arp_info    oam-000/arp_info/arp_info    db-000/arp_info/arp_info
    ...    upue-000/arp_info/arp_inf    cpcl-000/bfd_info/var/run/Bfd    cpcl-000/bfd_info/bfd_info    cpif-000/bfd_info/var/run/Bfd
    ...    cpif-000/bfd_info/bfd_info    cpnrt-000/bfd_info/var/run/Bfd    cpnrt-000/bfd_info/bfd_info   cpnb-000/bfd_info/var/run/Bfd
    ...    cpnb-000/bfd_info/bfd_info    cpue-000/bfd_info/var/run/Bfd    cpue-000/bfd_info/bfd_info    db-000/bfd_info/var/run/Bfd
    ...    db-000/bfd_info/bfd_info    oam-000/bfd_info/var/run/Bfd    oam-000/bfd_info/bfd_info    upue-000/bfd_info/var/run/Bfd
    ...    upue-000/bfd_info/bfd_info    oam-000/blackbox_info/blackbox_inf    cpcl-000/dns_info/dns_info    cpif-000/dns_info/dns_info
    ...    cpnb-000/dns_info/dns_info    cpnrt-000/dns_info/dns_info    cpue-000/dns_info/dns_info    db-000/dns_info/dns_info
    ...    oam-000/dns_info/dns_info     cpnrt-000/ip_info/ip_info    cpif-000/lrip_info/lrip_info
    ...    upue-000/dns_info/dns_info    cpcl-000/ip_info/ip_info    cpif-000/ip_info/ip_info    cpnb-000/ip_info/ip_info
    ...    cpue-000/ip_info/ip_info     db-000/ip_info/ip_info    oam-000/ip_info/ip_info    upue-000/ip_info/ip_info
    ...    cpcl-000/lrip_info/lrip_info    cpnrt-000/lrip_info/lrip_info    cpnb-000/lrip_info/lrip_info    cpue-000/lrip_info/lrip_info
    ...    db-000/lrip_info/lrip_info    oam-000/lrip_info/lrip_info    upue-000/lrip_info/lrip_info    cpcl-000/ntp_info/ntp_info
    ...    cpif-000/ntp_info/ntp_info    cpnb-000/ntp_info/ntp_info     cpnrt-000/ntp_info/ntp_info    cpue-000/ntp_info/ntp_info
    ...    db-000/ntp_info/ntp_info    oam-000/ntp_info/ntp_info    upue-000/ntp_info/ntp_info    cpcl-000/os_info/os_info
    ...    cpif-000/os_info/os_info    cpnb-000/os_info/os_info     cpnrt-000/os_info/os_info     cpue-000/os_info/os_info
    ...    db-000/os_info/os_info     oam-000/os_info/os_info    upue-000/os_info/os_info    cpcl-000/routing_info/routing_info
    ...    cpif-000/routing_info/routing_info    cpnb-000/routing_info/routing_info    cpnrt-000/routing_info/routing_info
    ...    cpue-000/routing_info/routing_info    db-000/routing_info/routing_info    upue-000/routing_info/routing_info
    ...    oam-000/routing_info/routing_info    cpcl-000/sctp_info/sctp_info    cpif-000/sctp_info/sctp_info   cpnb-000/sctp_info/sctp_info
    ...    cpnrt-000/sctp_info/sctp_info    cpue-000/sctp_info/sctp_info    db-000/sctp_info/sctp_info    oam-000/sctp_info/sctp_info
    ...    cpcl-000/sctprdmgr_info/sctprdmgr_info    upue-000/sctp_info/sctp_info    cpnb-000/sctprdmgr_info/sctprdmgr_info
    ...    cpif-000/sctprdmgr_info/sctprdmgr_info    cpnrt-000/sctprdmgr_info/sctprdmgr_info    cpue-000/sctprdmgr_info/sctprdmgr_info
    ...    oam-000/sctprdmgr_info/sctprdmgr_info    db-000/sctprdmgr_info/sctprdmgr_info    upue-000/sctprdmgr_info/sctprdmgr_info
    ...    oam-000/syslog_info/var/log/master/syslog    cpcl-000/transport_info/transport_info    cpif-000/transport_info/transport_info
    ...    cpif-000/transport_info/rcp_dpdk    cpnb-000/transport_info/transport_info    cpnb-000/transport_info/rcp_dpdk
    ...    cpnb-000/transport_info/transport_info    cpnrt-000/transport_info/rcp_dpdk    cpue-000/transport_info/transport_info
    ...    cpue-000/transport_info/rcp_dpdk    oam-000/transport_info/transport_info    oam-000/transport_info/rcp_dpdk
    ...    db-000/transport_info/transport_info    db-000/transport_info/rcp_dpdk    upue-000/transport_info/transport_info
    ...    upue-000/transport_info/statscollect    upue-000/transport_info/rcp_dpdk    symptomreport/execution



    ${filename_list}    Run Keyword If  '${coverage}'=='All logs'    Copy List    ${filename_list_all}
    ...    ELSE IF   '${coverage}'=='Most important logs'    Copy List    ${filename_list_most}

    ${len}=    Get Length    ${filename_list}
    ${len1}=    Get Length    ${RCP_filename_list}
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
    csn.SendCommand    command=mkdir /home/ute/snapshot    connection=ute
    ${snapshot_extract}    Set Variable    /home/ute/snapshot
    #FOR    ${index}    IN RANGE    ${Max_loop}
    #    ${unzip_result}=    csn.execute    command=unzip -o ${local_file_path} -d ${snapshot_extract}    connection=ute
    #    ${unzip_result}    split string    ${unzip_result}    \r\n
    #    ${unzip_result}    convert to string    ${unzip_result}
    #    ${checked_snapshot}    Run Keyword And Continue On Failure
    #    ...    Should Match Regexp    ${unzip_result}    snapshot_file_list.*?
	#    Exit For Loop If    '${checked_snapshot}'!='None'
	#END
    
	${checked_snapshot}    wait until keyword succeeds    5min    30s    Check snapshot file list    
	...    local_file_path=${local_file_path}    snapshot_extract=${snapshot_extract}
	
	sleep     5s
    csn.SendCommand    command=cat /home/ute/snapshot/snapshot_file_list.txt    connection=ute
    ${hwfile}    csn.read output    connection=ute
    FOR    ${index}    IN RANGE    ${len}
        ${matched_content}    Should Match Regexp      ${hwfile}    ${mrbts_id}_${filename_list[${index}]}.*?
        Run Keyword And Continue On Failure     should not be empty    ${matched_content}
    END

    sleep     5s

    FOR    ${index}    IN RANGE    ${len1}
        ${matched_content}    Should Match Regexp      ${hwfile}    .${RCP_filename_list[${index}]}.*?
        Run Keyword And Continue On Failure     should not be empty    ${matched_content}
    END
    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    #csn.Disconnect    connection=ute
