*** Settings ***
Documentation     author: jackie.ji; Jeffrey Shi
...               Group: HGZ_SG5
...               contact: jackie.ji@nokia-sbell.com; jeffrey.shi@nokia-sbell.com

#Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Library           Collections
Library           String
Library           ../../../../OAM/RAN_PZ_HAZ_34/libraries/snapshot_structure.py
Library           ../../../../OAM/RAN_PZ_HAZ_34/libraries/verify_snapshot.py
Library           verify_snapshot.VerifySnapshot    WITH NAME    snapshot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.analyzer.pcap

*** Variables ***
${mrbts_id}              ${tl.gnbs[0].instance_id}
${nrbts_id}              ${tl.gnbs[0].global_bts_id}
${ipv4_link_down_cmd}    iptables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
${ipv6_link_down_cmd}    ip6tables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
${ipv4_link_up_cmd}      iptables -t filter -D OUTPUT -p sctp --dport 38412 -j DROP
${ipv6_link_up_cmd}      ip6tables -t filter -D OUTPUT -p sctp --dport 38412 -j DROP
${zip_log_2nd}           runtime_cp_cl.log.xz
${zip_log_3rd}           runtime_cp_cl.log
${cell_barred_pcap}      cellbarred.pcap

*** Keywords ***
# Keyword usage: 'one NG-C link' means main link(just AMF1), 'another NG-C link' means not main link(just AMF2)

"${Step}" Login WebEM and check gNB is onair
    log to console    \n"${Step}": Login WebEM and check gNB is onair
    Selenium Login And Disable Screen Lock
    ${status}=     Run Keyword And Return Status     variable should exist    ${Active_SW_version}
    @{split_version}=    Run Keyword If   ${status}    string.split string    ${Active_SW_version}    separator=_
    ${version}=    Set Variable If    ${status}    ${split_version}[0]    ${version}
    ${NG_counter_name}=      set variable if
    ...    '${version}' > 'SBTS24R3'    MRBTS-${mrbts_id}    BTS
    Set suite variable    ${NG_counter_name}
    #Check gNB is onair
    #check cp_runtime_ini exist

"${Step}" Login WebEM and check NG-C links
    log to console    \n"${Step}": Login WebEM and check NG-C links
    Selenium Login And Disable Screen Lock
    ${status}=     Run Keyword And Return Status     variable should exist    ${Active_SW_version}
    @{split_version}=    Run Keyword If   ${status}    string.split string    ${Active_SW_version}    separator=_
    ${version}=    Set Variable If    ${status}    ${split_version}[0]    ${version}
    ${NG_counter_name}=      set variable if
    ...    '${version}' > 'SBTS24R3'    MRBTS-${mrbts_id}    BTS
    Set suite variable    ${NG_counter_name}
    Check two NG-C links status are active

"${Step}" Just lock one NG-C link via WebUI
    log to console    \n"${Step}": Just lock one NG-C link via WebUI
    Lock one NG-C link via WebUI

"${Step}" Unlock one NG-C link via WebUI
    log to console    \n"${Step}": Unlock one NG-C link via WebUI
    Unlock one NG-C link via WebUI

"${Step}" Check one NG-C link inactive and another active
    log to console    \n"${Step}": Check one NG-C link inactive and another active
    wait until keyword succeeds    10min    10s    Check one NG-C link status is inactive
    sleep    5s
    wait until keyword succeeds    10min    10s    Check another NG-C link status is active

"${Step}" Check main NG-C link active and another inactive
    log to console    \n"${Step}": Check main NG-C link active and another inactive
    wait until keyword succeeds    5min    1min    Check one NG-C link status is active
    sleep    5s
    wait until keyword succeeds    5min    1min    Check another NG-C link status is inactive

"${Step}" Check one locked counter via WebUI
    log to console    \n"${Step}": Check one locked counter via WebUI
    wait until keyword succeeds    10min    2min    Check one locked counters

"${Step}" Check gNB still onair and cell not barred
    log to console    \n"${Step}": Check gNB still onair and cell not barred
    Connect to gnb coam via ssl
    Check all cells info should be onair
    #${Cell_barred}    get cell barred or unbarred status
    #should contain    ${Cell_barred}    CellBarred: not barred
    [teardown]    COAM Teardown gnb connections

"${Step}" Lock all NG-C links via WebUI
    log to console    \n"${Step}": Lock all NG-C links via WebUI
    Lock two NG-C links via WebUI

"${Step}" unLock all NG-C links via WebUI
    log to console    \n"${Step}": unLock all NG-C links via WebUI
    unLock two NG-C links via WebUI

"${Step}" Check all NG-C links inactive
    log to console    \n"${Step}": Check all NG-C links inactive
    wait until keyword succeeds    5min    1min    Check two NG-C links status are inactive

"${Step}" Check all NG-C links active
    log to console    \n"${Step}": Check all NG-C links active
    wait until keyword succeeds    5min    1min    Check two NG-C links status are active

"${Step}" Check all locked counters via WebUI
    log to console    \n"${Step}": Check all locked counters via WebUI
    #wait until keyword succeeds    15min    30s    Check two locked counters
    Run Keyword And Ignore Error     selenium_coam.logout
    Run Keyword And Ignore Error     Selenium Login And Disable Screen Lock
    ${bts_name}    Get BTS Name
    set suite variable    ${bts_name}
    wait until keyword succeeds    30min    30s    Check two locked counters

"${Step}" Check gNB still onair and cell barred
    log to console    \n"${Step}": Check gNB still onair and cell barred
    Connect to gnb coam via ssl
    Check all cells info should be onair
    #Check cell barred from Wireshark logs     ${SAVE LOG DIRECTORY}/${cell_barred_pcap}
    [teardown]    COAM Teardown gnb connections

"${Step}" Check gNB still onair and cell not barred for one lock
    log to console    \n"${Step}": Check gNB still onair and cell not barred for one lock
    #Wait Until Keyword Succeeds    2min    10s     WEBUI Login
    Check gNB is onair
    #${Cell_barred}    get cell barred or unbarred status
    #should not contain    ${Cell_barred}    CellBarred: barred

"${Step}" Make all NG-C links down via SSH
    log to console    \n"${Step}": Make all NG-C links down via SSH
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result4}     convert to string    ${result}[-5]
    set suite variable    ${result4}
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     WEBUI Logout
    csn.Connect To    hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...   username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...   password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...   alias=ASIK Master
    ${hw_type}     connection_alias_store.Get hardware type    alias=ASIK Master
    set suite variable     ${hw_type}
    csn.disconnect    connection=ASIK Master
    Run Keyword If    "${hw_type}"!="ASIK"
    ...   Make all NG-C links down via SSH ASIK    ipv4_cmd=${ipv4_link_down_cmd}   ipv6_cmd=${ipv6_link_down_cmd}
    ...   ELSE    Make all NG-C links down via SSH ASIK salve      ipv4_cmd=${ipv4_link_down_cmd}   ipv6_cmd=${ipv6_link_down_cmd}

Make all NG-C links down via SSH ASIK salve
    [Arguments]  ${ipv4_cmd}    ${ipv6_cmd}
    #csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    Connect to Common Unit Master
    #Connect to Common Unit Slave
    csn.connect to     hostname=fctlb   username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}   proxy=ASIK Master     alias=ASIK Slave
    csn.execute    command=${ipv4_cmd}    connection=ASIK Slave
    sleep    5s
    csn.execute    command=${ipv6_cmd}    connection=ASIK Slave
    sleep    5s
    csn.disconnect    connection=ASIK Slave
    csn.disconnect    connection=ASIK Master
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    wait until keyword succeeds    10min    1min    Check two NG-C links status are inactive

Make all NG-C links down via SSH ASIK
    [Arguments]  ${ipv4_cmd}    ${ipv6_cmd}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.execute    command=${ipv4_cmd}    connection=gNB
    sleep    5s
    csn.execute    command=${ipv6_cmd}    connection=gNB
    sleep    5s
    csn.disconnect    connection=gNB
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    wait until keyword succeeds    10min    1min    Check two NG-C links status are inactive

"${Step}" Make all NG-C links up via SSH
    log to console    \n"${Step}": Make all NG-C links up via SSH
    #csn.Connect To    hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...   username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    #...   password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    #...   alias=ASIK Master
    #${hw_type}     connection_alias_store.Get hardware type    alias=ASIK Master
    #csn.disconnect    connection=ASIK Master
    Run Keyword If   "${hw_type}"!="ASIK"
    ...   Make all NG-C links up via SSH    ipv4_cmd=${ipv4_link_up_cmd}   ipv6_cmd=${ipv6_link_up_cmd}
    ...   ELSE     Make all NG-C links up via SSH ASIK salve     ipv4_cmd=${ipv4_link_up_cmd}   ipv6_cmd=${ipv6_link_up_cmd}

Make all NG-C links up via SSH ASIK salve
    [Arguments]  ${ipv4_cmd}    ${ipv6_cmd}
    #csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    Connect to Common Unit Master
    Connect to Common Unit Slave
    ${connection}    set variable if    "${hw_type}"=="ASIK"    ASIK Slave    ASIK Master
    csn.execute    command=${ipv4_cmd}    connection=${connection}
    sleep    5s
    csn.execute    command=${ipv6_cmd}    connection=${connection}
    sleep    5s
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    wait until keyword succeeds    6min    1min    Check two NG-C links status are active

Make all NG-C links up via SSH
    [Arguments]  ${ipv4_cmd}    ${ipv6_cmd}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.execute    command=${ipv4_cmd}    connection=gNB
    sleep    5s
    csn.execute    command=${ipv6_cmd}    connection=gNB
    sleep    5s
    csn.disconnect    connection=gNB
    #Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    wait until keyword succeeds    6min    1min    Check two NG-C links status are active

"${Step}" Check NG-C setup request and response counters for one unlock
    log to console    \n"${Step}": Check NG-C setup request and response counters for one unlock
    wait until keyword succeeds    10min    2min    Check NG-C setup request and response counters for one unlock

"${Step}" Check NG-C setup request and response counters for two unlock
    log to console    \n"${Step}": Check NG-C setup request and response counters for two unlock
    wait until keyword succeeds    10min    2min    Check NG-C setup request and response counters for two unlock

"${Step}" Modify actNgcFlexSaMode value to false
    log to console    \n"${Step}": Modify actNgcFlexSaMode value to false
    wait until keyword succeeds    20min    1min    Set actNgcFlexSaMode to false

"${Step}" Add trackingarea object via WebUI
    log to console    \n"${Step}": Add trackingarea object via WebUI
    Add trackingarea object via WebUI

"${Step}" Check trackingarea add success
    log to console    \n"${Step}": Check trackingarea add success
    wait until keyword succeeds    2min    30s    Check trackingarea add success

"${Step}" Check HW status via WebUI
    log to console           \n"${Step}": Check HW status via WebUI
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    #Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
#    Wait Until Keyword Succeeds    2min    30s    check RU STATUS

Set actNgcFlexSaMode to false
    log to console    Set actNgcFlexSaMode to false
    Change Parameter via webUI    expected_val=false
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                           filter_param=Activate NG-C flex SA mode
    ...                           p_name=actNgcFlexSaMode
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}

Set actNgcFlexSaMode to true
    log to console    Set actNgcFlexSaMode to true
    Change Parameter via webUI    expected_val=true
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                           filter_param=Activate NG-C flex SA mode
    ...                           p_name=actNgcFlexSaMode
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}

#Make all NG-C links up via SSH
#    log to console    Make all NG-C links up via SSH
#    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
#    csn.execute    command=${ipv4_link_up_cmd}    connection=gNB
#    sleep    5s
#    csn.execute    command=${ipv6_link_up_cmd}    connection=gNB
#    sleep    5s
#    csn.disconnect    connection=gNB

Recover setting and check another link active
    log to console    Recover setting and check another link active
    Wait Until Keyword Succeeds    30min    10s    reSet actNgcFlexSaMode to true
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist[1]}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    10s    Check another NG-C link status is active

reSet actNgcFlexSaMode to true
    #WEBUI Login
    Set actNgcFlexSaMode to true

Recover one NG-C link to unlocked
    log to console    Recover one NG-C link to unlocked
    #Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    run keyword and ignore error    Unlock one NG-C link via WebUI
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist[1]}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    1min    Check one NG-C link status is active

Recover all NG-C links to unlocked
    log to console    Recover all NG-C linka to unlocked
    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    30min    10s    Unlock two NG-C links via WebUI
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist[1]}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    1min    Check two NG-C links status are active

Recover all links up via WebUI and SSH
    log to console    Recover all links up via WebUI and SSH
    #csn.Connect To    hostname=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...   username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    #...   password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    #...   alias=ASIK Master
    #${hw_type}     connection_alias_store.Get hardware type    alias=ASIK Master
    #csn.disconnect    connection=ASIK Master
    Run Keyword If    "${hw_type}"=="ASOE"
    ...   Make all NG-C links up via SSH    ipv4_cmd=${ipv4_link_up_cmd}   ipv6_cmd=${ipv6_link_up_cmd}
    ...   ELSE     Make all NG-C links up via SSH ASIK salve   ipv4_cmd=${ipv4_link_up_cmd}   ipv6_cmd=${ipv6_link_up_cmd}
    Wait Until Keyword Succeeds    30min    10s    Unlock two NG-C links via WebUI
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist[1]}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    1min    Check two NG-C links status are active

Lock one NG-C link via WebUI
    Change Parameter via webUI    expected_val=Locked
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                           filter_param=Administrative State
    ...                           p_name=administrativeState
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}

Lock two NG-C links via WebUI
    Change Parameter via webUI    expected_val=Locked
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                           filter_param=Administrative State
    ...                           p_name=administrativeState
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}
    sleep    10s
    Change Parameter via webUI    expected_val=Locked
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                           filter_param=Administrative State
    ...                           p_name=administrativeState
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}

Unlock one NG-C link via WebUI
    Change Parameter via webUI    expected_val=Unlocked
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                           filter_param=Administrative State
    ...                           p_name=administrativeState
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}

Unlock two NG-C links via WebUI
    Change Parameter via webUI    expected_val=Unlocked
    ...                           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                           filter_param=Administrative State
    ...                           p_name=administrativeState
    ...                           is_need_to_check_validation_errors=${False}
    ...                           need_active=${True}
    sleep    10s
    Change Parameter via webUI    expected_val=Unlocked
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                          filter_param=Administrative State
    ...                          p_name=administrativeState
    ...                          is_need_to_check_validation_errors=${False}
    ...                          need_active=${True}

Check one NG-C link status is inactive
    Check Parameter via webUI    expected_val=Inactive
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check another NG-C link status is inactive
    Check Parameter via webUI    expected_val=Inactive
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check two NG-C links status are inactive
    Check Parameter via webUI    expected_val=Inactive
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus
    sleep    10s
    Check Parameter via webUI    expected_val=Inactive
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check one NG-C link status is active
    Check Parameter via webUI    expected_val=Active
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check another NG-C link status is active
    Check Parameter via webUI    expected_val=Active
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check two NG-C links status are active
    Check Parameter via webUI    expected_val=Active
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus
    sleep    10s
    Check Parameter via webUI    expected_val=Active
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                          filter_param=NG Link Status
    ...                          p_name=ngLinkStatus

Check gNB is onair
    wait until keyword succeeds    15min    30s    check gNB Staus onAir
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    search_text=Operational state

Get BTS Name
    [Arguments]    ${dist_name}=MRBTS-${mrbts_id}    ${filter_param}=BTS name    ${p_name}=btsName
    ${bts_name}    Run Keyword And Continue On Failure       selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    [Return]    ${bts_name}

Check one locked counters
    ${bts_name}    Get BTS Name
    set test variable    ${bts_name}
    ${locked_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00501
    ...                                                full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_SHUTDOWN_LOCKED
    ...                                                timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${locked_dict}[${target_value}]
    should be equal    ${int_counter}    ${1}

Check two locked counters
    ${locked_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00501
    ...                                            full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_SHUTDOWN_LOCKED
    ...                                            timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${locked_dict}[${target_value}]
    ${counter_time}    robot.libraries.DateTime.Add Time To Date    ${target_value}    300
    ${counter_time}    String.Remove String    ${counter_time}    .000
    ${result}    ${int_counter1}    run keyword and ignore error    convert to integer    ${locked_dict}[${counter_time}]
    Run Keyword If   "${int_counter}"=="${0}"     should be equal    ${int_counter1}    ${2}
    ...    ELSE      should be equal    ${int_counter}    ${2}

Check NG-C setup request and response counters for one unlock
    ${bts_name}    Get BTS Name
    set test variable    ${bts_name}
    ${request_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00001
    ...                                             full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_CU_SETUP_REQUEST_SENT
    ...                                             timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${request_dict}[${target_value}]
    should be equal    ${int_counter}    ${1}

    ${response_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00002
    ...                                             full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_CU_SETUP_RESPONSE_RCV
    ...                                             timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${response_dict}[${target_value}]
    should be equal    ${int_counter}    ${1}

Check NG-C setup request and response counters for two unlock
    ${bts_name}    Get BTS Name
    set test variable    ${bts_name}
    ${request_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00001
    ...                                             full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_CU_SETUP_REQUEST_SENT
    ...                                             timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${request_dict}[${target_value}]
    should be equal    ${int_counter}    ${2}

    ${response_dict}    Fetch NGAP Setup procedure counters    counter_id=M55119C00002
    ...                                             full_path=[${bts_name}] ${NG_counter_name}/NRBTS-${nrbts_id}/NNGCB/NG_CU_SETUP_RESPONSE_RCV
    ...                                             timeout_for_loading_available_counters=${20}
    ${int_counter}    convert to integer    ${response_dict}[${target_value}]
    should be equal    ${int_counter}    ${2}


"${Step}" Lock one NG-C link by judging ways via WebUI
    log to console    \n"${Step}": Lock one NG-C link by judging ways via WebUI
    ${target_value}    Judge execute counter operation ways    operation_type=Locked    lock_numbers=${1}
    set test variable    ${target_value}

"${Step}" Lock all NG-C links by judging ways via WebUI
    log to console    \n"${Step}": Lock all NG-C links by judging ways via WebUI
    ${target_value}    Judge execute counter operation ways    operation_type=Locked    lock_numbers=${2}
    set test variable    ${target_value}

"${Step}" Unlock one NG-C link by judging ways via WebUI
    log to console    \n"${Step}": Unlock one NG-C link by judging ways via WebUI
    ${target_value}    Judge execute counter operation ways    operation_type=Unlocked    lock_numbers=${1}
    set test variable    ${target_value}

"${Step}" Unlock all NG-C links by judging ways via WebUI
    log to console    \n"${Step}": Unlock all NG-C links by judging ways via WebUI
    ${target_value}    Judge execute counter operation ways    operation_type=Unlocked    lock_numbers=${2}
    set test variable    ${target_value}

Fetch NGAP Setup procedure counters
    [Arguments]    ${counter_id}    ${full_path}    ${timeout_for_loading_available_counters}
    run keyword and ignore error      selenium_coam.logout
    run keyword and ignore error      Selenium Login And Disable Screen Lock
    run keyword and ignore error      selenium_coam.disable_message_box
    run keyword and ignore error      selenium_coam.disable_screen_lock
    sleep    10s
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${if_bts_counters_get}=    Run Keyword And Ignore Error    selenium_coam.get_bts_counters_info
    ...                                counter_id=${counter_id}
    ...                                full_path=${full_path}
    ...                                timeout_for_loading_available_counters=${timeout_for_loading_available_counters}
    ${ngap_counters}=    Run Keyword If    '${if_bts_counters_get[0]}'=='PASS'    set variable    ${if_bts_counters_get[1]}
    ...    ELSE    selenium_coam.get_bts_counters_info
    ...                                counter_id=${counter_id}
    ...                                full_path=${full_path}
    ...                                timeout_for_loading_available_counters=${timeout_for_loading_available_counters}
    run keyword and ignore error      selenium_coam.logout
    [Return]    ${ngap_counters}

Lock one new NG-C link on WebUI
    Change new parameter on webUI    expected_val=Locked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}

Lock two new NG-C links on WebUI
    Change new parameter on webUI    expected_val=Locked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}
    sleep    3s
    Change new parameter on webUI    expected_val=Locked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}

Unlock one new NG-C link on WebUI
    Change new parameter on webUI    expected_val=Unlocked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}

Unlock two new NG-C links on WebUI
    Change new parameter on webUI    expected_val=Unlocked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-1
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}
    sleep    3s
    Change new parameter on webUI    expected_val=Unlocked
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/SERVEDAMF-2
    ...                              filter_param=Administrative State
    ...                              p_name=administrativeState
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}


Execute counter generation operation
    [Arguments]    ${operation_type}=Locked    ${lock_numbers}=${1}
    run keyword if    "${operation_type}" == "Locked" and ${lock_numbers} == ${1}    Lock one new NG-C link on WebUI
    ...    ELSE IF    "${operation_type}" == "Locked" and ${lock_numbers} == ${2}    Lock two new NG-C links on WebUI
    ...    ELSE IF    "${operation_type}" != "Locked" and ${lock_numbers} == ${1}    Unlock one new NG-C link on WebUI
    ...    ELSE IF    "${operation_type}" != "Locked" and ${lock_numbers} == ${2}    Unlock two new NG-C links on WebUI


Fetch datetime format string like dict
    ${cur_datetime}    get time
    @{split_datetime}    Split String From Right    ${cur_datetime}    :    2
    ${date_hour}    set variable    ${split_datetime}[0]
    ${date_hour_m_s}    join path    ${date_hour}    :00    :00
    ${start_date_h_m_s}    Remove String    ${date_hour_m_s}    /
    [Return]    ${cur_datetime}    ${start_date_h_m_s}

Judge execute counter operation ways
    [Arguments]    ${gap_time}=${200}    ${period_time}=${300}    ${zero}=${0}
    ...            ${operation_type}=Locked    ${lock_numbers}=${1}

    ${cur_datetime}    ${start_date_h_m_s}    Fetch datetime format string like dict
    ${new_list}    create list
    FOR    ${index}    IN RANGE    0    12    1
        ${start_date_h_m_s}    robot.libraries.DateTime.Add Time To Date    ${start_date_h_m_s}    ${period_time}
        append to list    ${new_list}    ${start_date_h_m_s}
    END

    FOR    ${value}    IN    @{new_list}
        ${delta}    robot.libraries.DateTime.Subtract Date From Date    ${value}    ${cur_datetime}
        ${delta_seconds}    convert to integer    ${delta}
        ${checked_value}    run keyword if    ${gap_time} <= ${delta_seconds} <= ${period_time}
        ...                  robot.libraries.DateTime.Subtract Time From Date    ${value}    ${period_time}
        run keyword if    ${gap_time} <= ${delta_seconds} <= ${period_time}
        ...    Execute counter generation operation    operation_type=${operation_type}    lock_numbers=${lock_numbers}
        run keyword if    ${gap_time} <= ${delta_seconds} <= ${period_time}
        ...                               exit for loop
        ${checked_value}    run keyword if    ${zero} < ${delta_seconds} < ${gap_time}
        ...                  robot.libraries.DateTime.Subtract Time From Date    ${value}    ${zero}
        run keyword if    ${zero} < ${delta_seconds} < ${gap_time}
        ...                               sleep    ${delta_seconds}s
        run keyword if    ${zero} < ${delta_seconds} < ${gap_time}
        ...    Execute counter generation operation    operation_type=${operation_type}    lock_numbers=${lock_numbers}
        run keyword if    ${zero} < ${delta_seconds} < ${gap_time}
        ...                               exit for loop

        run keyword if    ${delta_seconds} <= ${zero} or ${delta_seconds} > ${period_time}
        ...                               continue for loop
    END

    log to console    ${checked_value}
    ${target_value}    Remove String    ${checked_value}    .000
    [Return]    ${target_value}


save snapshot
    log to console    save snapshot log
    [Arguments]    ${coverage}    ${save_location}
    selenium_coam.snapshot_collection_settings    coverage=${coverage}    save_location=${save_location}
    ${snapshot_log}   selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    set suite variable    ${snapshot_log}
    ${snapshot_tmp_path}    ${snapshot_name}    Split Path   ${snapshot_log}
    set suite variable    ${snapshot_name}
    set suite variable    ${snapshot_tmp_path}

check snapshot collected in local driver and copy it
    log to console     check snapshot collect complete
    OperatingSystem.File Should Exist     ${snapshot_log}
    wait until keyword succeeds      20min    1min    check snapshot collected
    OperatingSystem.Copy File     ${snapshot_log}     ${SAVE LOG DIRECTORY}

check snapshot collected
    ${rc}    ${output}    Run And Return Rc And Output    ls -l ${snapshot_tmp_path}
    should not contain    ${output}     ${snapshot_name}.part

unzip snapshot file
    log to console     unzip snapshot
    snapshot.un_zip   path_name=${SAVE LOG DIRECTORY}    file_name=${snapshot_name}
    ${p1}    ${e1}    OperatingSystem.Split Extension    ${SAVE LOG DIRECTORY}/${snapshot_name}
    [Return]      ${p1}

remove the unzip directory
    log to console     clean snapshot logs
    #run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    OperatingSystem.Remove Directory    path=${unzip_file_path}    recursive=${True}

get cell barred or unbarred status
    log to console    get cell barred or unbarred status
    #wait until keyword succeeds      3min    10s     WEBUI Login
    save snapshot    coverage=All log files    save_location=Local
    check snapshot collected in local driver and copy it
    snapshot.un_zip    path_name=${SAVE LOG DIRECTORY}    file_name=${snapshot_name}
    ${CPCL_xz_log_path}    Get CPCLlog from snapshot
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.execute     command=xz -dvf ${CPCL_xz_log_path}    connection=VM
    csn.send_command     command=find ${SAVE LOG DIRECTORY} -name ${zip_log_3rd}    connection=VM
    ${runtime_cp_cl_log_tmp}    csn.read output    connection=VM
    ${runtime_cp_cl_log}    strip string    ${runtime_cp_cl_log_tmp}
    csn.send_command     command=cat ${runtime_cp_cl_log} | grep -i CellBarred    connection=VM
    sleep    5s
    ${cell_barred_status}    csn.read output    connection=VM
    csn.disconnect    connection=VM
    remove the unzip directory
    [Return]    ${cell_barred_status}

Get CPCLlog from snapshot
    log to console     get CPCLlog from snapshot
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.send_command     command=find ${SAVE LOG DIRECTORY} -name ${zip_log_2nd}    connection=VM
    sleep    5s
    ${runtime_cp_cl_log_xz_all}    csn.read output    connection=VM
    ${runtime_cp_cl_log_xz_full}    ${runtime_cp_cl_log_xz}      should Match Regexp
    ...    ${runtime_cp_cl_log_xz_all}    .*\n*(/home/.*/BTS\\d{2,4}\_\\d{4}\_runtime/runtime_cp_cl.log.xz)\n*.*
    csn.disconnect    connection=VM
    [Return]    ${runtime_cp_cl_log_xz}

Add trackingarea object via WebUI
    [Arguments]    ${id_value}=${201}
    selenium_coam.add_object    object_name=NRBTS-${nrbts_id}    object_class_name=TRACKINGAREA
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/TRACKINGAREA-200
    ...    id_value=${id_value}    is_load_default_values=${False}
    sleep    5s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    5s

Get fiveGsTac value for Trackingarea-200
    ${tac0_value}    Get Parameter via webUI    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/TRACKINGAREA-200
    ...    filter_param=5G extended tracking area code    p_name=fiveGsTac
    ${tac0_value_int}    convert to integer    ${tac0_value}
    [Return]    ${tac0_value_int}

Get fiveGsTac value for additional Trackingarea-201
    ${tac1_value}    Get Parameter via webUI    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/TRACKINGAREA-201
    ...    filter_param=5G extended tracking area code    p_name=fiveGsTac
    ${tac1_value_int}    convert to integer    ${tac1_value}
    [Return]    ${tac1_value_int}

Check trackingarea add success
    ${tac_value0}    Get fiveGsTac value for Trackingarea-200
    sleep    5s
    ${tac_value1}    Get fiveGsTac value for additional Trackingarea-201
    sleep    5s
    should be equal    ${tac_value0}    ${tac_value1}

Delete trackingarea object to recovery
    log to console    Delete trackingarea object to recovery
    selenium_coam.remove_object    object_name=TRACKINGAREA-201
    sleep    5s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    5s

Change new parameter on webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    run keyword if  not '${current_val}'=='${expected_val}'
    ...                  Set new parameter value on webUI    expected_val=${expected_val}
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      p_name=${p_name}
    ...                                                      is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                      need_active=${need_active}
    [Return]    ${current_val}

Set new parameter value on webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                              filter_param=${filter_param}
    ...                              new_value=${expected_val}
    ...                              abbr=${p_name}
    ...                              timeout=${120}
    selenium_coam.validate_plan
    ${errors}    selenium_coam.get_relation_errors
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

check cp_runtime_ini exist
    log to console     check cp_runtime_ini exist
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.send_command    command=ls -al /ffs/run/     connection=gNB
    sleep    5s
    ${file_list}    csn.read output    connection=gNB
    csn.disconnect    connection=gNB
    ${cp_runtime_init_status}    ${cp_runtime_init_value}    run keyword and ignore error    should contain    ${file_list}    cp_runtime.ini
    sleep    5s
    run keyword if     '${cp_runtime_init_status}'=='FAIL'    Generate cp_runtime_ini file
    ...    ELSE IF     '${cp_runtime_init_status}'=='PASS'    log to console     file "cp_runtime.ini" exist

Generate cp_runtime_ini file
    log to console    Generate cp_runtime_ini file
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.execute    command=echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini     connection=gNB
    sleep    3s
    ${grep_file}    csn.execute    command=ls /ffs/run/ | grep "cp_runtime.ini"    connection=gNB
    sleep    3s
    csn.disconnect    connection=gNB
    should contain    ${grep_file}    cp_runtime.ini
    log to console    cp_runtime.ini file generate success
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    selenium_coam.reset_site
    sleep    2min
    Wait Until Keyword Succeeds    10min    1min    WEBUI Login

#copy_cp_runtime_ini
#    log to console    copy cp_runtime.init to gNB
#    [Arguments]    ${file_path}=${EXECDIR}/TestData/cp_runtime.ini
#    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
#    run keyword and ignore error    run process
#    ...    sshpass -p ${asik_password} scp ${file_path} ${asik_username}@${asik_addr}:/ffs/run/    shell=yes
#    sleep    5s
#    csn.disconnect    connection=VM
#    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
#    selenium_coam.reset_site
#    sleep    2min
#    Wait Until Keyword Succeeds    10min    1min    WEBUI Login

Check actNgcFlexSaMode change success
    [Arguments]    ${actNgcFlexSaMode}
     ${actNgcFlexSaMode_value}    Get Parameter via webUI    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    filter_param=Activate NG-C flex SA mode    p_name=actNgcFlexSaMode
    ${actNgcFlexSaMode_value_convert}=    convert to boolean    ${actNgcFlexSaMode_value}
    should be equal    ${actNgcFlexSaMode_value_convert}    ${actNgcFlexSaMode}

Resume actNgcFlexSaMode back to true
    #Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    wait until keyword succeeds    5min    1min    Set actNgcFlexSaMode to true
    Check actNgcFlexSaMode change success    actNgcFlexSaMode=${true}

"${Step}" Check actNgcFlexSaMode modified success
    log to console    \n"${Step}": Check actNgcFlexSaMode change to false
    Check actNgcFlexSaMode change success     actNgcFlexSaMode=${false}

"${Step}" check NGC_link Main-AMF maintained and non-main-AMF released
    log to console    \n"${Step}": check NGC_link Main-AMF maintained and non-main-AMF released
    Wait Until Keyword Succeeds    3min    10s    Check one NG-C link status is active
    Wait Until Keyword Succeeds    3min    10s    Check another NG-C link status is inactive

Start To Capture Wireshark Logs
    log to console    start to capture Wireshark Logs
    [Arguments]    ${filename}
    #Run Keyword If   "${result4}"=="5G21A"
    #...   Start To Capture Wireshark Logs var ASIK Salve    file=${filename}
    #...   ELSE    Start To Capture Wireshark Logs var ASIK Master    file=${filename}
    Start To Capture Wireshark Logs var ASIK Master    file=${filename}

Start To Capture Wireshark Logs var ASIK Master
    [Arguments]    ${file}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB_wireshark
    csn.send command    command=tcpdump -i fp0 -w /tmp/${file}   connection=gNB_wireshark
    #csn.disconnect    connection=gNB_wireshark

Stop and download Wireshark Logs
    log to console    Stop and download Wireshark Logs
    [Arguments]    ${filename}
    Stop and download Wireshark Logs var ASIK Master    file=${filename}

Stop and download Wireshark Logs var ASIK Master
    [Arguments]    ${file}
    csn.send command    command=killall tcpdump     connection=gNB_wireshark
    sleep    5s
    csn.download_file   remote_path=/tmp/${file}   local_path=${SAVE LOG DIRECTORY}/${file}   connection=gNB_wireshark
    sleep    5s
    csn.disconnect    connection=gNB_wireshark
    #csn.disconnect    connection=ASIK Slave
    #csn.disconnect    connection=ASIK Master

#####2118_common_kw
Check Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Get Parameter via webUI     dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           p_name=${p_name}
    should be equal    ${current_val}    ${expected_val}

Get Parameter via webUI
    [Arguments]    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ...                                                      timeout=${120}
    [Return]    ${current_val}

Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...                     Set Parameter value via webUI     expected_val=${expected_val}
    ...                                                       dist_name=${dist_name}
    ...                                                       filter_param=${filter_param}
    ...                                                       p_name=${p_name}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                       need_active=${need_active}
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${current_val}    ${errors}

Set Parameter value via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                              filter_param=${filter_param}
    ...                              new_value=${expected_val}
    ...                              abbr=${p_name}
    ...                              timeout=${120}
    selenium_coam.validate_plan
    ${errors}    selenium_coam.get_relation_errors
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${errors}
