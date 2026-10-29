*** Settings ***
Documentation     [PURPOSE]
#Library     taf.sbts.oam.coam.admin	WITH NAME	admin
Resource    ../CB007500/CB007500.robot
Resource    ../../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot

*** Keywords ***
CB010738 setup
    [Documentation]    Short description.
    Set Library Search Order    CB007500
    TC Setup
    SW update to Target Build
    Get MRBTS ID
    Feature is enabled
    DHCP IP in use
    Open Connection To DHCP Server

Get MRBTS ID
    [Documentation]    Short description.
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    Set Test Variable    ${mrbts_id}    ${bts_info}[mrbtsID]

Fake Setup
    [Documentation]    Short description.
    Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN37528
    Set Test Variable   ${release}    SBTS25R2
    Set Test Variable   ${newBTSID}    37528
#    taf.sbts.oam.coam.admin.connect to	bts_host=192.168.255.129
#    Get MRBTS ID
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
        ...     /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T05/OAM_SRAN/Variables/${TESTLINE_NAME}.py
#    Open Connection To DHCP Server
    Overwrite Netact Server Info
    Fake Keyword

Full commissioning with SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_file}: <description>
    [Arguments]    ${scf_file}
    ${result}=  taf.sbts.oam.coam.admin.perform_commissioning   scf_file=${scf_file}
    Log    ${result}

CB010738 teardown
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Feature is enabled
    DHCP IP in use
    Close Connection To DHCP Server
    CB007500 TC teardown

CB010738 PnP with DHCP and Followed by DHCP Renewal Failure
    [Documentation]    Short description.
    Step0.1: Update IPv4 Host Configuration in DHCP Server
    Step1: CB010738 prepare package on NMS
    Step2: prepare plan with SITEID on NMS For CB010738
    Step3.1: Allow booting of IPv4 Host In DHCP Server
    Step3: Configuration reset
    Step4: Start Autoconection with DHCP
    Step5: Check PnP Reslut
    Step5.1 Manual Commission To IPv4 If Autoconfiguratin Failed
    Step5.2 NTP and DNS Verification In SCF
    Step6: DHCP IP Address Failure IPv4

CB010738 PnP with DHCP and Followed by DHCP IP Change
    [Documentation]    Short description.
    Step0.1: Update IPv6 Host Configuration in DHCP Server
    Step1: CB010738 prepare package on NMS
    Step2: prepare plan with SITEID on NMS For CB010738
    Step3.1: Deny Booting of IPv4 Host In DHCP Server
    Step3: Configuration reset
    Step4: Start Autoconection with DHCP
    Step5: Check PnP Reslut
    Step5.1 Manual Commission To IPv6 If Autoconfiguratin Failed
    Step5.2 NTP and DNS Verification In SCF
    Step6: BTS IPv6 Address Change In DHCP Server
    Step7: New IPv6 Address Take Into Use
    Step8: BTS IPv6 Address Revert In DHCP Server
	Step7: New IPv6 Address Take Into Use

CB010738 With All planes
    [Documentation]    Short description.
    Step0.1: Update IPv6 Host Configuration in DHCP Server
    Step1: CB010738 prepare package on NMS
    Step2: prepare plan with SITEID on NMS For CB010738
    Step3.1: Deny Booting of IPv4 Host In DHCP Server
    Step3.2: Update Lease Time
    Step3: Configuration reset
    Step4: Start Autoconection with DHCP
    Step5: Check PnP Reslut
    Step5.1 Manual Commission To IPv6 If Autoconfiguratin Failed
    Step5.2 NTP and DNS Verification In SCF
    Step6: Update Link Outage Guard time
    Step7: Block Traffic From NMS IPv6
    Step8: Verify Force Renewal

Step2: prepare plan with SITEID on NMS For CB010738
    [Documentation]    Short description.
    Log Step Header    Step2: prepare plan with SITEID on NMS
    register MRBTS to NetAct
    Creation of Site configuration plan with SiteID    ${newBTSID}
    Remove DHCP IP And Default Route In SCF
    Remove LNRELG and LNRELW Objects In SCF
    run keyword and ignore error    DeIntegrate Mrbts from Netact TAF    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    CB007500.PnP_COAM_Site_Preparation_By_WFE    ${PnPPlanfile}
    ${SCF_NR}    Check if NR exist    ${TEMP_LOGS_DIR}${/}SCF.xml

CB010738 IP Address lease renewal
    [Documentation]    Short description.
    Log  Nothing
    ${info}=    Get Last Lease File Info
    taf.sbts.oam.coam.admin.reset_site
    Wait Until Keyword Succeeds  5 min  2 sec
    ...    taf.sbts.oam.coam.admin.start_ip_capture_file    measurement_point=NE_Terminated    uplane_capturing=${TRUE}
    Wait Until Keyword Succeeds  30min    3min    Lease File Updated IPv6    ${info}
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    ${Test Results Dir}${/}IP_Traffic_MRBTS-${mrbts_id}_${timestamp}.pcap.gz
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${target_file_name}
    Check DHCPv6 Renewal In IP Traffic File    ${target_file_name}

Step3: Configuration Reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${user}: <description>
    ...        ${pass}: <description>
    Log Step Header    Step3: Configuration Reset
    [Arguments]    ${user}=Nemuadmin    ${pass}=nemuuser
    Start Admin    username=${user}    password=${pass}    alias=hfv
#    ${ConfigResetStartTime}=    Get Current Date
    Run keyword and ignore error    Stop Watching Alarms
    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration    remove_operator_certificates=False
    ...    remove_user_account_credentials=False    alias=hfv    timeout=800
    ...    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    Wait Until Keyword Succeeds  15 min  15 sec    BTS is Down
    Wait Until Keyword Succeeds  15 min  15 sec    BTS is Up
    Sleep    5min
    Wait Until Keyword Succeeds  15 min  5 sec    Connected to RC
    ${ac_paras}=    taf.fdsw.rc.get_autoconnection_parameters
    Log    ${ac_paras}
#    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
#    ${ConfigResetEndTime}=    Get Current Date
#    ${ConfigReset_KPI_check}=  Operation_KPI_Check  ${ConfigResetEndTime}  ${ConfigResetStartTime}
#    ...    ${ConfigReset_expect_time}
#    ...    ConfigReset_BTS_KPI
#    set suite variable    ${ConfigReset_KPI_check}
#    set suite variable    ${ConfigResetStartTime}
#    set suite variable    ${ConfigResetEndTime}

Connected to RC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${fdsw_version}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...      ${fdsw_version}=fdsw21c    ${auto_discover}=True    ${secure}=True    ${name}=default
    ${result}=    Run Keyword and return status    taf.fdsw.rc.connect to
    ...    ip_address=${ip_address}    port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Run Keyword If    ${result}==${FALSE}    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Should Be True    ${result}==${TRUE}
    Log To Console    FDSW RC Connected successfully with IP ${ip_address}
    CB007500_enable_SSH_Access_On_RC
    ${ver}=    taf.fdsw.rc.get_running_sw_version_name

Step3.1: Allow booting of IPv4 Host In DHCP Server
    [Documentation]    Short description.
    Allow IPv4 Host In DHCP Server With MAC

Step4: Start Autoconection with DHCP
    [Documentation]    Short description.
    Log Step Header    Step4: Start Autoconection and Autoconfiguration for SiteID
    Start AutoConnection with DHCP with RC
    Autoconnection with DHCP Is Started
    Wait Until Keyword Succeeds    5min    2s    Update Site Identification
    ${AutoConnStartTime}=    Get Current Date
    set suite variable    ${AutoConnStartTime}

Autoconnection with DHCP Is Started
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    5min    2s    Autoconfiguratin Scenario In RC Update to DHCP

Autoconfiguratin Scenario In RC Update to DHCP
    [Documentation]    Short description.
    ${ac_paras}=    taf.fdsw.rc.get_autoconnection_parameters
    Should Be True    '${ac_paras}[scenario]'=='private network with DHCP'
    ${site_iden_info}=    taf.fdsw.rc.get_site_identification_info
    Should Be True    '${site_iden_info}[site_id]'=='None'
    Sleep    30s

BTS is Up
    [Documentation]    Short description.
    ${output}    Run    ping 192.168.255.129 -c 1
    Should Contain    ${output}    1 received
    Log To Console    BTS is Up

BTS is Down
    [Documentation]    Short description.
    ${output}    Run    ping 192.168.255.129 -c 1
    Should Not Contain    ${output}    1 received
    Log To Console    BTS is Down

Start AutoConnection with DHCP with RC
    [Documentation]    Short description.
    Log to console    start to config the AutoConnection by DHCP on RC
    ${IdserverIP}    Get IdserverIP
#    Wait Until Keyword Succeeds    15min    30s    Connected to D&RSW BTS by RC
    taf.fdsw.rc.set_autoconnection_parameters_to_default
#    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Log to console    finish to config the AutoConnection by DHCP on RC

Update Site Identification
    [Documentation]    Short description.
    ${site_iden}=    Set Variable    Site${newBTSID}
    taf.fdsw.rc.set_site_identification    ${site_iden}    timeout=${10}
    ${site_iden_info}=    taf.fdsw.rc.get_site_identification_info
	${site_iden_rc}=    Set Variable    ${site_iden_info}[site_id]
    Should Be True    '${site_iden}'=='${site_iden_rc}'
    Log to console    Site Identification set to ${site_iden}

Step1: CB010738 prepare package on NMS
    [Documentation]    Short description.
    Log Step Header    Step1: prepare package on NMS
    set test variable    ${newBTSID}    ${BTS_INFO.ID}
    set test variable    ${NetAct_CM_ExportFileName}     ${BTS_INFO.ID}_explort_SCF.xml
    Precondition Netact with TAF
    Prepare BTS ENV and Netact package

Step7: New IPv6 Address Take Into Use
    [Documentation]    Short description.
    Log Step Header    Step7: New IPv6 Address Take Into Use
    Wait Until Keyword Succeeds  30min    3min    New IPv6 Address In Configuration
#    Wait Until Keyword Succeeds  10min    3min    Not All rat onair
    sleep    5min
    Wait Until Keyword Succeeds  15min    3min    All rat onair

New IPv6 Address In Configuration
    [Documentation]    Short description.
    ${dhcp_in_use_v6}   ${dhcp_ip_v6}=  DHCP with IPv6 in Use
    Should Be True    '${dhcp_ip_v6}'=='${dhcp_ip_v6_new}'

Step6: Update Link Outage Guard time
    [Documentation]    Short description.
    Log Step Header    Step6: Update Link Outage Guard time
    Log     Update linkOutageGuardTime to 1 min
    Wait Until Keyword Succeeds  15min    3min    All rat onair
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     MPLANENW_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/MNLENT_A-(\\d+)/MPLANENW_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   linkOutageGuardTime   update  1

Step7: Block Traffic From NMS IPv6
    [documentation]    Generate ip6tables command to block traffic from NMS
    Log Step Header    Step7: Block Traffic From NMS IPv6
    ${manager_ip_list}=    Get NMS Manager IPs
    ${cmd}=    Set Variable    ip6tables -L
    FOR    ${ip}    IN    @{manager_ip_list}
        ${subnet}=    Replace String Using Regexp    ${ip}    :[0-9a-f]+$    :0/112
        ${not_same_subnet}=    Run Keyword And Return Status    Should Not Contain    ${cmd}    ${subnet}
        ${cmd}=    Set Variable If   ${not_same_subnet}   ip6tables -A INPUT -s ${subnet} -j DROP;${cmd}    ${cmd}
    END
    ${output}=    Execute Command On BTS via SSH    ${cmd}

Execute Command On BTS via SSH
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cmd}: <description>
    ...
    ...    Returns:
    ...        ${output}: <description>
    [arguments]    ${cmd}
    SSHLibrary.Open Connection              192.168.255.129             alias=bts_lmp
    ${output}=	SSHLibrary.Login            toor4nsn    oZPS0POrRieRtu  alias=bts_lmp
    ${output}=	SSHLibrary.Execute Command  ${cmd}   alias=bts_lmp
    Log         ${output}
    SSHLibrary.Close Connection
    [return]   ${output}

Get NMS Manager IPs
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${manager_ip_list}: <description>
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NE3S_SESSION
    Log    ${objs}
    ${manager_ip_list}=    Create List
    ${manager_info}=    Set Variable    ${objs}[0][parameters][managerInfo]
    FOR     ${manager}    IN    @{manager_info}
        Append To List    ${manager_ip_list}    ${manager}[managerIpAddress]
    END
    [return]    ${manager_ip_list}

Step8: Verify Force Renewal
    [Documentation]    Short description.
    Log Step Header    Step8: Verify Force Renewal
    Wait Until Keyword Succeeds  20min    1min    NMS Link Is Disconnected
    taf.sbts.oam.coam.admin.start_ip_capture_file    measurement_point=NE_Terminated
    ...     uplane_capturing=${FALSE}    password=${EMPTY}
    ${info}=    Get Last Lease File Info
    Wait Until Keyword Succeeds  30min    3min    Lease File Updated IPv6    ${info}
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    ${Test Results Dir}${/}IP_Traffic_MRBTS-${mrbts_id}_${timestamp}.pcap.gz
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${target_file_name}
    Check DHCPv6 Renewal In IP Traffic File    ${target_file_name}
    [teardown]    Unblock Traffic

Check DHCPv6 Renewal In IP Traffic File
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${zip_file}: <description>
    [arguments]    ${zip_file}
    ${output}=    Run    gunzip -d ${zip_file}
    ${pcap_file}=    Replace String     ${zip_file}    .gz    ${EMPTY}
    OperatingSystem.File Should Exist    ${pcap_file}
    ${output}=    Run    tshark -r ${pcap_file} -Y "dhcpv6" -T pdml
    Log    ${output}
    #Should Contain    ${output}    Message type: Confirm
    Should Contain    ${output}    Message type: Reply

Unblock Traffic
    [Documentation]    Short description.
    ${output}=    Execute Command On BTS via SSH    ip6tables -F
    Log    ${output}

Lease File Updated IPv6
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${info}: <description>
    [arguments]    ${info}
    ${new_info}=    Get Last Lease File Info
    Should Not Be Equal     ${info}    ${new_info}

Get Last Lease File Info
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${output}: <description>
#    ${output}=    Execute Command On BTS via SSH    cat /rom/trs_data/active/dhclient6.leases | grep starts | tail -1
#    Should Contain    ${output}    starts
#    ${ts}=    Get Regexp Matches    ${output}    \\d+
    ${output}=    Execute Command On BTS via SSH    ls -l /rom/trs_data/active/dhclient6.leases
    [return]    ${output}

NMS Link Is Disconnected
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NE3SADAPT
    Should Be True    '${objs}[0][parameters][nmsStateInfo][downlinkState]'=='Disconnected'
    Should Be True    '${objs}[0][parameters][nmsStateInfo][uplinkState]'=='Disconnected'

Step3.1: Deny Booting of IPv4 Host In DHCP Server
    [Documentation]    Short description.
    Log Step Header        Step3.1: Deny Booting of IPv4 Host In DHCP Server
    ${mac}=    Get MAC address of BTS
    Deny IPv4 Host In DHCP Server With MAC    ${mac}

Step3.2: Update Lease Time
    [Documentation]    Short description.
    Log Step Header    Step3.2: Update Lease Time
    ${SN}=      Get Serial Number of Primary Core
    ${duid}=    Generate BTS DUID with SN   ${SN}
    ${configuration}=       Get Host Configuration with DUID In DHCP Server     ${duid}
    ${configuration_tmp}=    Remove String Using Regexp    ${configuration}    default-lease-time[^;]+;
    Log    ${configuration_tmp}
    ${configuration_tmp}=    Remove String Using Regexp    ${configuration_tmp}    preferred-lifetime[^;]+;
    Log    ${configuration_tmp}
    ${configuration_tmp}=    Remove String Using Regexp    ${configuration_tmp}    option dhcp-renewal-time[^;]+;
    Log    ${configuration_tmp}
    ${config_wo_lease}=    Remove String Using Regexp    ${configuration_tmp}    option dhcp-rebinding-time[^;]+;
    Log    ${config_wo_lease}
    ${long_lease_config}=    Catenate    default-lease-time 14400; preferred-lifetime 12000;
    ...    option dhcp-renewal-time 7200; option dhcp-rebinding-time 10800;
    ${new_config}=    Set Variable    ${configuration} ${long_lease_config}
    Log    ${new_config}
    ${cmd}=     Set Variable    sudo sed -i "s/${configuration}/${new_config}/g" /etc/dhcp/dhcpd6.conf
    Execute Command On DHCP Server     ${cmd}
    Log    ${cmd}
    ${config_1}=       Get Host Configuration with DUID In DHCP Server     ${duid}
    Restart DHCP Server
    ${cmd}=     Set Variable    sudo sed -i "s/${new_config}/${config_wo_lease}/g" /etc/dhcp/dhcpd6.conf
    Execute Command On DHCP Server     ${cmd}
    ${config_2}=       Get Host Configuration with DUID In DHCP Server     ${duid}

#    ${config}=    Get Lease Configuration
#    ${line_count}=  Get Line Count    ${config}
#    Should Be True    '${line_count}'=='1'
#    ${cmd}=     Set Variable    sudo sed -i "s/default-lease-time 900/#default-lease-time 900/g" /etc/dhcp/dhcpd6.conf
#    Execute Command On DHCP Server     ${cmd}
#    ${cmd}=     Set Variable
#    ...    sudo sed -i "s/#default-lease-time 14400/default-lease-time 14400/g" /etc/dhcp/dhcpd6.conf
#    Execute Command On DHCP Server     ${cmd}
#    Restart DHCP Server
#    ${cmd}=     Set Variable
#    ...    sudo sed -i "s/default-lease-time 14400/#default-lease-time 14400/g" /etc/dhcp/dhcpd6.conf
#    Execute Command On DHCP Server     ${cmd}
#    ${cmd}=     Set Variable    sudo sed -i "s/#default-lease-time 900/default-lease-time 900/g" /etc/dhcp/dhcpd6.conf
#    Execute Command On DHCP Server     ${cmd}

Step0.1: Update IPv6 Host Configuration in DHCP Server
    [Documentation]    Short description.
    Log Step Header        Step0.1: Update IPv6 Host Configuration in DHCP Server
    Update IPv6 VEO On DHCP Server Based On SN

Step0.1: Update IPv4 Host Configuration in DHCP Server
    [Documentation]    Short description.
    Log Step Header        Step0.1: Update IPv4 Host Configuration in DHCP Server
    Update IPv4 VEO On DHCP Server Based On MAC

Get Lease Configuration
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${config}: <description>
    ${cmd}=    Set Variable    sudo cat /etc/dhcp/dhcpd6.conf|grep default-lease-time |grep -v "#"
    ${config}=    Execute Command On DHCP Server     ${cmd}
    [return]    ${config}

Step5: Check PnP Reslut
    [Documentation]    Short description.
    Log Step Header    Step5: Check PnP Reslut
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    run keyword and ignore error    Start Capture tcpdump from FDSW    7500_1
    set test variable    ${OnAirstatus}    ${FALSE}
    Wait Until Keyword Succeeds  15 min  10 sec    AutoConnection Is Successful
    Wait Until Keyword Succeeds  10 min  1 sec    SW Download Is Ongoing
    Wait Until Keyword Succeeds  60 min  5 sec    SW Download Is Successful
#   Wait Until Keyword Succeeds  60 min  5 sec    RC is Not Accessible
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Wait Until Keyword Succeeds  15 min  15 sec    BTS is Down
    Wait Until Keyword Succeeds  10 min  15 sec    BTS is Up
    ${PNPstatus}    run keyword and return status    Wait Until Keyword Succeeds
    ...    15min    10s    Start Admin_MRAT    alias=default
    Run keyword and ignore error    Setup Test Line Watchdog
    set test variable    ${PNPstatus}
    run keyword if    '${PNPstatus}'=='False'
    ...    run keywords
        ...    Save Tcpdump File For PnP
        ...    AND    Wait Until Keyword Succeeds  15 min  5 sec    Connected to RC
        ...    AND    fdsw.download_technical_logs    ${TEMP_LOGS_DIR}
        ...    AND    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
        ...    AND    set test variable    ${OnAirstatus}    ${FALSE}
        ...    AND    Should Be True    ${PNPstatus}==${TRUE}
    ${autoconfig_result}=    Get Autoconfiguratin Result
    set test variable    ${autoconfig_result}
    Return From Keyword If    ${autoconfig_result}==${FALSE}
    ${OnAirstatus}    run keyword and return status    Wait Until Keyword Succeeds  15 min    10 sec
    ...    Admin Check BTS Procedural and Blocking states  OnAir
    set test variable    ${OnAirstatus}

RC is Not Accessible
    [Documentation]    Short description.
    ${res}=    Run Keyword And Return Status    Wait Until Keyword Succeeds  1 min  10 sec
    ...    Connected to D&RSW BTS by RC
    Run Keyword And Ignore Error    taf.fdsw.rc.teardown
    Should Be True    ${res}==${FALSE}

AutoConnection Is Successful
    [Documentation]    Short description.
    ${ac_paras}=    taf.fdsw.rc.get_autoconnection_parameters
    Log    ${ac_paras}
    Should Be True    '${ac_paras}[pnp_status][autoconnection][status]'=='ok'
    Log To Console    Autoconnection is successful

SW Download Is Ongoing
    [Documentation]    Short description.
    ${ac_paras}=    taf.fdsw.rc.get_autoconnection_parameters
    Log    ${ac_paras}
    Should Be True    '${ac_paras}[pnp_status][autoconfiguration][sw_download]'=='ongoing'

SW Download Is Successful
    [Documentation]    Short description.
    ${ac_paras}=    taf.fdsw.rc.get_autoconnection_parameters
    Log    ${ac_paras}
    Should Be True    '${ac_paras}[pnp_status][autoconfiguration][sw_download]'=='succeeded'

Step5.1 Manual Commission To IPv6 If Autoconfiguratin Failed
    Log Step Header    Step5.1 Manual Commission To IPv6 If Autoconfiguratin Failed
    [documentation]    Autoconfiguration will be failed if original DHCP IP is IPv4.
    ...    Mnaual commission the BTS is needed.
    Run Keyword If    ${autoconfig_result}==${FALSE} and ${dhcp_in_use_v4}==${TRUE}
    ...    Commission BTS with IPv6 SCF via WebEM
    ...    ELSE
    ...    Should Be True    ${OnAirstatus}==${TRUE}
    Set Test Variable    ${OnAirstatus}    ${TRUE}
    DHCP IP in use

Step5.1 Manual Commission To IPv4 If Autoconfiguratin Failed
    Log Step Header    Step5.1 Manual Commission To IPv4 If Autoconfiguratin Failed
    [documentation]    Autoconfiguration will be failed if original DHCP IP is IPv6.
    ...    Mnaual commission the BTS is needed.
    Run Keyword If    ${autoconfig_result}==${FALSE} and ${dhcp_in_use_v6}==${TRUE}
    ...    Commission BTS with IPv4 SCF via WebEM
    ...    ELSE
    ...    Should Be True    ${OnAirstatus}==${TRUE}
    DHCP IP in use
    set test variable    ${OnAirstatus}    ${TRUE}

Read PnP report from Web
    [Documentation]    Short description.
    Log to console    Read PnP report from Web
    ${Report}    taf.sbts.oam.coam.admin.Get Pnp Report
    ...    ${TEMP_LOGS_DIR}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt    alias=hfv
    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    ${IdserverIP}    Get IdserverIP
    ${Report}    OperatingSystem.Get File    ${TEMP_LOGS_DIR}${/}MRBTS_${BTS_INFO.ID}PnPReport.txt

Get Autoconfiguratin Result
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${result}: <description>
    ${autoconfig_state}=    Wait Until Keyword Succeeds    20min    1min    Get Autoconfiguratin State From IM
    Should Be True    '${autoconfig_state}'=='Succeeded' or '${autoconfig_state}'=='Failed'
    ${result}=    Set Variable If    '${autoconfig_state}'=='Succeeded'    ${TRUE}    ${FALSE}
    [return]    ${result}

Get Autoconfiguratin State From IM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${autoconfig_state}: <description>
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects    PNP_PROCEDURE_R
    Should Not Be Empty    ${objs}
    ${autoconfig_state}=    Set Variable    ${objs}[0][parameters][autoconfigurationState]
    Should Be True    '${autoconfig_state}'=='Succeeded' or '${autoconfig_state}'=='Failed'
    [return]    ${autoconfig_state}

Step5.2 NTP and DNS Verification In SCF
    [documentation]    NTP/DNS server list shall be merged to SCF if it's not definied in SCF
    ${ntp_list}    ${dns_list}=    Read NTP and DNS Server List From Lease File
    NTP Mergered In SCF    ${ntp_list}
    DNS Mergered In SCF    ${dns_list}

NTP Mergered In SCF
    [documentation]    Count of DNS/NTP server list may greater than merged to SCF
    ...    Max number of NTP servers in SCF in 4
    [arguments]    ${ntp_list}
    ${ntp_list_len}=    Get Length    ${ntp_list}
    Return From Keyword If   '${ntp_list_len}'=='0'
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects    NTP_A
    Return From Keyword If    '${objs}[0][parameters][ntpServerConfigSource]'!='DHCP'
    ${count}=    Set Variable    0
    FOR    ${ntp}    IN    @{ntp_list}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count}>4
        Should Contain    ${objs}[0][parameters][ntpServerIpAddrOrFqdnList]    ${ntp}
    END

DNS Mergered In SCF
    [documentation]    Count of DNS/NTP server list may greater than merged to SCF
    ...    Max number of DNS servers in SCF in 2
    [arguments]    ${dns_list}
    ${dns_list_len}=    Get Length    ${dns_list}
    Return From Keyword If   '${dns_list_len}'=='0'
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects    DNS_A
    Return From Keyword If    '${objs}[0][parameters][dnsServerConfigSource]'!='DHCP'
    ${dns_pri}=    set variable    ${objs}[0][parameters][serverIpAddressPrimary]
    ${dns_sec}=    set variable    ${objs}[0][parameters][serverIpAddressSecondary]
    ${count}=    Set Variable    0
    FOR    ${ntp}    IN    @{dns_list}
        ${count}=    Evaluate    ${count}+1
        Exit For Loop If    ${count}>2
        Should Be True    '${dns_pri}'=='${ntp}' or '${dns_sec}'=='${ntp}'
    END

Read NTP and DNS Server List From Lease File
    [documentation]    Count of DNS/NTP server list may greater than merged to SCF
    ${output}=  execute command on bts via ssh    cat /rom/trs_data/active/dhclient*.leases
    ${matches_ntp}=    Get Regexp Matches    ${output}    ntp-servers ([0-9a-f:,.]+);    1
    ${ntp_list}=    Split String    ${matches_ntp}[0]    ,
    ${matches_dns}=    Get Regexp Matches    ${output}    name-servers ([0-9a-f:,.]+);    1
    ${dns_list}=    Split String    ${matches_dns}[0]    ,
    [return]    ${ntp_list}    ${dns_list}

Autoconfiguratin is Successful
    [Documentation]    Short description.
    All RAT onair

Commission BTS with IPv6 SCF via WebEM
    [Documentation]    Short description.
    Log to Console    Manual commission to ipv6
    Precondition For Manual Commission IPv6
    ${scf_file}=    Get IPv6 SCF File
    Wait Until Keyword Succeeds    10min    2min    Full commissioning with SCF    ${scf_file}
    Post Check

Commission BTS with IPv4 SCF via WebEM
    [Documentation]    Short description.
    Log to Console    Manual commission to ipv4
    Precondition For Manual Commission IPv4
    ${scf_file}=    Get IPv4 SCF File
    Wait Until Keyword Succeeds    20min    2min    Full commissioning with SCF    ${scf_file}
    Post Check

Post Check
    [Documentation]    Short description.
    Wait Until Keyword Succeeds  20min  2min  All RAT onair

All RAT onair
    [Documentation]    Short description.
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    Should Be True    '${bts_info}[status][proceduralState]'=='OnAir'
    ${keys}=    Get Dictionary Keys    ${bts_info}[ratState]
    ${is_no_cells}=    Set Variable    ${TRUE}
    FOR    ${rat}    IN    @{keys}
        ${rat_state}=    Set Variable    ${bts_info}[ratState][${rat}]
        Should Be True    '${rat_state}'=='NO_CELLS' or '${rat_state}'=='ALL_ENABLED'
        ${is_no_cells}=    Set Variable If    '${rat_state}'!='NO_CELLS'    ${FALSE}   ${is_no_cells}
    END
    Should Not Be True    ${is_no_cells}

Not All RAT onair
    [Documentation]    Short description.
    ${state}=    Run keyword and return status    All RAT onair
    Should Not Be True    ${state}

Precondition For Manual Commission IPv6
    [Documentation]    Short description.
    Lease File and NCF Check IPv6

Precondition For Manual Commission IPv4
    [Documentation]    Short description.
    Lease File and NCF Check IPv4

Lease File and NCF Check IPv4
    [Documentation]    Get Lease file
    ${dhcp_ip}=    Get DHCP IP From Lease File
    ${mplane_address}=    Get mplane IP From NCF
    Validate IPv4 Address    ${mplane_address}

Lease File and NCF Check IPv6
    [Documentation]    Get Lease file
    ${dhcp_ip}=    Get DHCP IP From Lease File
    ${mplane_address}=    Get mplane IP From NCF
    Validate IPv6 Address    ${mplane_address}

Get mplane IP From NCF
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${address}: <description>
    ${output}=    execute command on bts via ssh    cat /rom/config/NCF.xml
    Log         ${output}
    ${output}=    execute command on bts via ssh    cat /rom/config/NCF.xml|grep -i localIpAddress
    Log         ${output}
    ${matchs}=    Get Regexp Matches    ${output}    >([0-9a-f:.]+)<    1
    ${address}=    Set Variable    ${matchs}[0]
    ${result}=  Evaluate    ipaddress.ip_address("${address}").version     ipaddress
    Should Be True    '${result}'=='4' or '${result}'=='6'
    [return]    ${address}

Get DHCP IP From Lease File
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${address}: <description>
    ${output}=    execute command on bts via ssh    cat /rom/trs_data/active/dhclient*.leases
    Log         ${output}
    ${output}=    execute command on bts via ssh
    ...    cat /rom/trs_data/active/dhclient*.leases|grep -iE "fixed-address|iaaddr"|tail -1
    Log         ${output}
    ${output_1}=    Replace String    ${output}    iaaddr    ${EMPTY}
    ${output_2}=    Replace String    ${output1}    fixed-address    ${EMPTY}
    ${matchs}=    Get Regexp Matches    ${output_2}    ([0-9a-f:.]+)    1
    ${address}=    Set Variable    ${matchs}[0]
    ${result}=  Evaluate    ipaddress.ip_address("${address}").version     ipaddress
    Should Be True    '${result}'=='4' or '${result}'=='6'
    [return]    ${address}

Get IPv6 SCF File
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${scf_file}: <description>
    ${scf_file}=    Get SCF File    6
    [return]    ${scf_file}

Get IPv4 SCF File
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${scf_file}: <description>
    ${scf_file}=    Get SCF File    4
    [return]    ${scf_file}

Get SCF File
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_version}: <description>
    ...
    ...    Returns:
    ...        ${scf_file}: <description>
    [arguments]    ${ip_version}
    Should Be True    '${ip_version}'=='4' or '${ip_version}'=='6'
    ${scf_file}=    Set Variable    ${EMPTY}
    ${scf_dir}=    Set Variable   /home/ute/testline_configuration/${TESTLINE_NAME}/node1/
    ${scf_list}=    OperatingSystem.List Files In Directory    ${scf_dir}
    FOR    ${scf}  IN  @{scf_list}
        ${res}=    Run keyword and return status    Should contain    ${scf}
        ...    ${release}_IPv${ip_version}    ignore_case=${TRUE}
        ${scf_file}    Set Variable If    ${res}==${TRUE}    ${scf_dir}${scf}
        Exit For Loop If    ${res}
    END
    Should Not Be Empty    ${scf_file}
    [return]    ${scf_file}

Step6: DHCP IP Address Failure IPv4
    [Documentation]    Short description.
    Log Step Header    Step6: DHCP IP Address Failure IPv4
    Trigger Renewal Failure Of IPv4 Host    ${dhcp_ip_v4}
    Verify Mplane Connection                ${dhcp_ip_v4}
    Recover Renewal Of IPv4 Host            ${dhcp_ip_v4}

Verify Mplane Connection
    [Documentation]    Verify Mplane connectivity by check admin connection
    [Arguments]    ${mplane_ip}
    taf.sbts.oam.coam.admin.connect to	bts_host=${mplane_ip}   name=mplane_connectivity_check
    taf.sbts.oam.coam.admin.get_bts_info    connection=mplane_connectivity_check
    taf.sbts.oam.coam.admin.teardown    connection=mplane_connectivity_check

Step6: BTS IPv6 Address Change In DHCP Server
    [Documentation]    DHCP IP Change for IPv6
    ${dhcp_in_use_v6}   ${dhcp_ip_v6}=  DHCP with IPv6 in Use
    ${matches}=    Get Regexp Matches    ${dhcp_ip_v6}    :([0-9a-f]+)$    1
    ${last_segment_new}=    Evaluate    (${matches}[0]+10)%50
    ${dhcp_ip_v6_new}=    Replace String Using Regexp    ${dhcp_ip_v6}    :([0-9a-f]+)$    :${last_segment_new}
    Validate IPv6 Address    ${dhcp_ip_v6_new}
    Set Test Variable    ${dhcp_ip_v6_new}
    DHCP IP Change From DHCP Server IPv6    ${dhcp_ip_v6}    ${dhcp_ip_v6_new}

Step8: BTS IPv6 Address Revert In DHCP Server
    [Documentation]    Short description.
    DHCP IP Change From DHCP Server IPv6     ${dhcp_ip_v6_new}   ${dhcp_ip_v6}
    Set Test Variable    ${dhcp_ip_v6_new}    ${dhcp_ip_v6}

Feature is enabled
    [Documentation]    actDhcpIpContinuation is other than Deactivated
    ${objs}=    taf.sbts.oam.coam.admin.Get Managed Objects     FEATCADM_A
    ${actDhcpIpContinuation}=   Set Variable    ${objs}[0][parameters][actDhcpIpContinuation]
    Should Not Be True      '${actDhcpIpContinuation}' == 'Deactivated'

DHCP IP in Use
    [Documentation]    Verify if there are IPv4 or IPv6 address set ipAddressAllocationMethod as DHCP
    ${dhcp_in_use_v4}   ${dhcp_ip_v4}=  DHCP with IPv4 in Use
    ${dhcp_in_use_v6}   ${dhcp_ip_v6}=  DHCP with IPv6 in Use
    Should Be True      ${dhcp_in_use_v4} or ${dhcp_in_use_v6}
    Set Test Variable   ${dhcp_in_use_v4}
    Set Test Variable   ${dhcp_in_use_v6}
    Set Test Variable   ${dhcp_ip_v4}
    Set Test Variable   ${dhcp_ip_v6}

DHCP with IPv4 in Use
    [Documentation]    Verify if there are IPADDRESSV4_A set ipAddressAllocationMethod as DHCP
    ${dhcp_in_use_v4}=  Set Variable     ${FALSE}
    ${dhcp_ip_v4}=         Set Variable     ""
    ${objs}=    taf.sbts.oam.coam.admin.Get Managed Objects     IPADDRESSV4_A
    FOR     ${obj}  IN    @{objs}
        ${dhcp_in_use_v4}=  Set Variable If     '${obj}[parameters][ipAddressAllocationMethod]' == 'DHCP'
        ...     ${TRUE}     ${FALSE}
        ${dhcp_ip_v4}=      Set Variable If     ${dhcp_in_use_v4}==${TRUE}
        ...     ${obj}[parameters][localIpAddr]     ""
        Run Keyword If     ${dhcp_in_use_v4}==${TRUE}    Set To Dictionary    ${BTS_INFO}    IP=${dhcp_ip_v4}
        Exit For Loop If    ${dhcp_in_use_v4}==${TRUE}
    END
    [RETURN]    ${dhcp_in_use_v4}    ${dhcp_ip_v4}

DHCP with IPv6 in Use
    [Documentation]    Verify if there are IPADDRESSV6_A set ipAddressAllocationMethod as DHCP
    ${dhcp_in_use_v6}=  Set Variable     ${FALSE}
    ${dhcp_ip_v6}=      Set Variable     ""
    ${objs}=    taf.sbts.oam.coam.admin.Get Managed Objects     IPADDRESSV6_A
    FOR     ${obj}  IN    @{objs}
        ${dhcp_in_use_v6}=  Set Variable If     '${obj}[parameters][ipAddressAllocationMethod]' == 'DHCP'
        ...     ${TRUE}     ${FALSE}
        ${dhcp_ip_v6}=  Set Variable If     '${obj}[parameters][ipAddressAllocationMethod]' == 'DHCP'
        ...     ${obj}[parameters][localIpAddr]     ""
        Run Keyword If     ${dhcp_in_use_v6}==${TRUE}    Set To Dictionary    ${BTS_INFO}    IP=${dhcp_ip_v6}
        Exit For Loop If    ${dhcp_in_use_v6}==${TRUE}
    END
    [RETURN]    ${dhcp_in_use_v6}   ${dhcp_ip_v6}

Get Mplane IP
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.Get Managed Objects     IPADDRESSV6_A

DHCP Server Verificaiton
    [Documentation]    Short description.
    Log     Check if server is valid

Get DHCP Server IP From BTS
    [Documentation]    Short description.
    Log     Check DHCP server IP from BTS

Recover Renewal Of IPv4 Host
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dhcp_ip}: <description>
    [Arguments]    ${dhcp_ip}
    Allow IPv4 Host In DHCP Server    ${dhcp_ip}
    Fault 61678 Is Cleared

Trigger Renewal Failure Of IPv4 Host
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dhcp_ip}: <description>
    [Arguments]    ${dhcp_ip}
    Deny IPv4 Host In DHCP Server    ${dhcp_ip}
    Fault 61678 Is Raised

Fault 61678 Is Raised
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    10min    1min    Fault 61678 Is Active

Fault 61678 Is Cleared
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    10min    1min    Fault 61678 Is Not Active

Fault 61678 Is Active
    [Documentation]    Verify fault 61678
    ...     1. fault id = 61678
    ...     2. Servity = Major
    ...     2. supplementary alarm info = DHCP Renewal Failure
    ${fault_acitve}=        Set Variable    ${FALSE}
    ${suppl_alarm_info}=    Set Variable    ${EMPTY}
    ${fault_severity}=      Set Variable    ${EMPTY}
    ${alarms}=  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR     ${alarm}    IN  @{alarms}
        ${fault_severity}=  Set Variable    ${alarm}[faultSeverity]
        ${fault_acitve}=    Set Variable If     '${alarm}[faultId]'=='61678'    ${TRUE}     ${FALSE}
        ${suppl_alarm_info}=    Set Variable If    '${alarm}[faultId]'=='61678'
        ...     ${alarm}[supplAlarmInfo]    ${suppl_alarm_info}
        Exit For Loop If    ${fault_acitve}==${TRUE}
    END
    Should Be True  ${fault_acitve}
    Should Be True  '${suppl_alarm_info}'=='DHCP Renewal Failure'
    Should Be True  '${fault_severity}'=='Major'

Fault 61678 Is Not Active
    [Documentation]    Short description.
    ${fault_acitve}=    Set Variable    ${FALSE}
    ${alarms}=  taf.sbts.oam.coam.admin.Get Active Alarms
    ${alarms}=  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR     ${alarm}    IN  @{alarms}
        ${fault_acitve}=    Set Variable If     '${alarm}[faultId]'=='61678'    ${TRUE}     ${FALSE}
        Exit For Loop If    ${fault_acitve}==${TRUE}
    END
    Should Not Be True  ${fault_acitve}

Deny IPv4 Host In DHCP Server
    [Documentation]    The kw aims to deny a host to trigger renewal timeout.
    ...     Command used is based on Debian/isc-dhcp-server, it's not valid to
    ...     other dhcp server
    [Arguments]    ${dhcp_ip}
    Should Not Be True  '${dhcp_ip}'==''
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${dhcp_ip}
    ${is_host_denied}=    Run Keyword And Return Status    Should Contain    ${configuration}    deny booting
    Return From Keyword If    ${is_host_denied}==${TRUE}
    ${cmd}=     Set Variable    sudo sed -i "s/${dhcp_ip};/${dhcp_ip};deny booting;/g" /etc/dhcp/dhcpd.conf
    Log    ${cmd}
    Execute Command On DHCP Server     ${cmd}
    Restart DHCP Server

Allow IPv4 Host In DHCP Server
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dhcp_ip}: <description>
    [Arguments]    ${dhcp_ip}
    Should Not Be True  '${dhcp_ip}'==''
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${dhcp_ip}
    ${new_config}=    Remove String    ${configuration}    deny booting;
    ${cmd}=     Set Variable    sudo sed -i "s/${configuration}/${new_config}/g" /etc/dhcp/dhcpd.conf
    Log     ${cmd}
    Execute Command On DHCP Server     ${cmd}
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${dhcp_ip}
    Should Not Contain    ${configuration}    deny booting
    Restart DHCP Server

Allow IPv4 Host In DHCP Server With MAC
    [documentation]    Deny booting of IPv4 host to trigger renewal timeout
    ...    Or force the BTS to start PnP with DHCPv6
    ${mac}=    get mac address of bts
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${mac}
    ${new_config}=    Remove String    ${configuration}    deny booting;
    ${cmd}=     Set Variable    sudo sed -i "s/${configuration}/${new_config}/g" /etc/dhcp/dhcpd.conf
    Log     ${cmd}
    Execute Command On DHCP Server     ${cmd}
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${mac}
    Should Not Contain    ${configuration}    deny booting
    Restart DHCP Server

Deny IPv4 Host In DHCP Server With MAC
    [Documentation]    The kw aims to deny a host to trigger renewal timeout.
    ...     Command used is based on Debian/isc-dhcp-server, it's not valid to
    ...     other dhcp server
    [Arguments]    ${mac}
    Should Not Be True  '${mac}'==''
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${mac}
    ${is_host_denied}=    Run Keyword And Return Status    Should Contain    ${configuration}    deny booting
    Return From Keyword If    ${is_host_denied}==${TRUE}
    ${cmd}=     Set Variable    sudo sed -i "s/${mac};/${mac};deny booting;/g" /etc/dhcp/dhcpd.conf
    Log    ${cmd}
    Execute Command On DHCP Server     ${cmd}
    Restart DHCP Server

DHCP IP Change From DHCP Server IPv4
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${old_ip}: <description>
    ...        ${new_ip}: <description>
    [Arguments]    ${old_ip}    ${new_ip}
    ${cmd}=     Set Variable    sudo sed -i "s/${old_ip};/${new_ip};/g" /etc/dhcp/dhcpd.conf
    Log     ${cmd}
    ${output}=	Execute Command On DHCP Server     ${cmd}
    Restart DHCP Server

DHCP IP Change From DHCP Server IPv6
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${old_ip}: <description>
    ...        ${new_ip}: <description>
    [Arguments]    ${old_ip}    ${new_ip}
    ${cmd}=     Set Variable    sudo sed -i "s/${old_ip};/${new_ip};/g" /etc/dhcp/dhcpd6.conf
    Log     ${cmd}
    ${output}=	Execute Command On DHCP Server     ${cmd}
    ${cmd}=    Catenate    sudo service isc-dhcp-server stop;
    ...    sudo rm /var/lib/dhcp/dhcpd6.leases*;
    ...    sudo service isc-dhcp-server start;
    ...    sudo service isc-dhcp-server status
    ${output}=	Execute Command On DHCP Server     ${cmd}

Get Last IPv6 Address From Lease File
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${matchs}[0]: <description>
    ${cmd}=    cat /var/lib/dhcp/dhcpd6.leases | grep iaaddr | tail -1
    ${output}=	Execute Command On DHCP Server     ${cmd}
    ${matchs}=    Get Regexp Matches    ${output}    [0-9a-f:]+
    Should Not Be Empty    ${matchs}
    Log    ${matchs}
    [return]    ${matchs}[0]

Replace IPv6 address in Lease File
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${old_ip}: <description>
    ...        ${new_ip}: <description>
    [arguments]    ${old_ip}    ${new_ip}
    ${cmd}=    sudo sed -i "s/${old_ip}/${new_ip}/g" /var/lib/dhcp/dhcpd6.leases
    ${output}=	Execute Command On DHCP Server     ${cmd}

Stop DHCP Server
    [Documentation]    Short description.
    Execute Command On DHCP Server     sudo service isc-dhcp-server stop
    ${output}=	Execute Command On DHCP Server     sudo service isc-dhcp-server status
    Log    ${output}

Restart DHCP Server
    [Documentation]    Short description.
    Execute Command On DHCP Server     sudo service isc-dhcp-server restart
    ${output}=	Execute Command On DHCP Server     sudo service isc-dhcp-server status
    Log    ${output}
    Should Contain    ${output}  active (running)

Update IPv4 VEO On DHCP Server Based On MAC
    [Documentation]    Update Vendor Encapsulated Options for a specific host based on MAC address
    ${mac}=     Get MAC address of BTS
    ${lbwas_ip}=    Get lbwas IP From Url IPv4
    ${veo}=     Generate Vendor Encapsulated Options IPv4    ${lbwas_ip}
    ${configuration}=       Get Host Configuration with string In DHCP Server  ${mac}
    ${new_configuration}=   Replace String Using Regexp     ${configuration}
    ...     vendor-encapsulated-options\\s+[\\w:]+;     vendor-encapsulated-options ${veo};
    Update DHCP Configuration File IPv4     ${configuration}    ${new_configuration}

Update IPv6 VEO On DHCP Server Based On SN
    [Documentation]    Update Vendor Encapsulated Options for a specific host based on serial number
    ${SN}=      Get Serial Number of Primary Core
    ${duid}=    Generate BTS DUID with SN   ${SN}
    ${lbwas_address_ipv6}=    Get lbwas IP From Url IPv6
    ${veo}=     Generate Vendor Encapsulated Options IPv6    ${lbwas_address_ipv6}
    ${configuration}=       Get Host Configuration with DUID In DHCP Server     ${duid}
    ${new_configuration}=   Replace String Using Regexp     ${configuration}
    ...     dhcp6.vendor-opts\\s+[\\w:]+;     dhcp6.vendor-opts ${veo};
    Log     ${new_configuration}
    Update DHCP Configuration File IPv6     ${configuration}    ${new_configuration}

Get Host Configuration with DUID In DHCP Server
    [Documentation]    For IPv6 host
    [Arguments]    ${duid}
    ${output}=  Execute Command On DHCP Server     sudo cat /etc/dhcp/dhcpd6.conf|grep -i ${duid}
    ${count}=   Get Line Count  ${output}
    Should Be True      '${count}'=='1'
    ${configuration}=   Strip String    ${output}
    [RETURN]    ${configuration}

Generate BTS DUID with SN
    [Documentation]    DUID defination for NOKIA BTS: OM_GEN_SFS_RNWINT.5393
    ...    The Client identifier option code 1
    ...    Client Identifier option contains the DUID (DHCP Unique Identifier) and is used in DHCPv6 SOLICIT while
    ...    Auto connection. DUID type 2 shall be applied by Nokia NE (Vendor-assigned unique ID based on Enterprise
    ...    Number (DUID-EN)).
    ...    'Enterprise-number' shall be assigned value 28458
    ...    'Identifier' shall be assigned the HW serial number as printed on the outside of the BTS system module
    [Arguments]    ${SN}
    ${duid}=    Set Variable    00:02:00:00:6f:2a
    ${ch_list}=     Split String To Characters      ${SN}
    FOR     ${ch}   IN  @{ch_list}
        ${result}=  Evaluate    "${ch}".encode("utf-8").hex()
        ${duid}=    Set Variable    ${duid}:${result}
    END
    [RETURN]    ${duid}

Get Serial Number of Primary Core
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${sn}: <description>
    ${admin_is_working}=    Run keyword And Return Status    taf.sbts.oam.coam.admin.Get Bts Info
    ${sn}=    Run Keyword If    ${admin_is_working}==${TRUE}
    ...    Get Serial Number of Primary Core From Admin
    ...    ELSE
    ...    Get Serial Number of SMOD From SSH session
    [return]    ${sn}

Get Serial Number of Primary Core From Admin
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${SN}: <description>
    ${bts_info}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${smods}=   Set Variable  ${bts_info}[systemModules]
    Log     ${smods}
    ${SN}=  Set Variable    ""
    FOR     ${smod}     IN  @{smods}
        ${SN}=  Set Variable    ${smod}[serialNumber]
        ${key_exist}=    Run Keyword And Return Status   Dictionary Should Contain Key   ${smod}    activeRole
        Run Keyword If      ${key_exist}==${TRUE}   Exit For Loop If     '${smod}[activeRole]'=='Primary'
    END
    [RETURN]    ${SN}

Get Serial Number of SMOD From SSH session
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${matchs}[0]: <description>
    ${output}=      execute command on bts via ssh    sysinfo | grep -50|grep ID_00_MODULE_SN_
    ${matchs}=  Get Regexp Matches    ${output}    '(\\w)'
    Should Not Be Empty    ${matchs}
    [return]    ${matchs}[0]

Update DHCP Configuration File IPv4
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${old_config}: <description>
    ...        ${new_config}: <description>
    [Arguments]    ${old_config}    ${new_config}
    ${cmd}=     Set Variable    sudo sed -i "s/${old_config}/${new_config}/g" /etc/dhcp/dhcpd.conf
    Log     ${cmd}
    Execute Command On DHCP Server     ${cmd}
    ${output}=  Read DHCP Configuration File IPv4
    Should Contain  ${output}   ${new_config}
    Restart DHCP Server

Update DHCP Configuration File IPv6
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${old_config}: <description>
    ...        ${new_config}: <description>
    [Arguments]    ${old_config}    ${new_config}
    ${cmd}=     Set Variable    sudo sed -i "s/${old_config}/${new_config}/g" /etc/dhcp/dhcpd6.conf
    Log     ${cmd}
    Execute Command On DHCP Server     ${cmd}
    ${output}=  Read DHCP Configuration File IPv6
    Should Contain  ${output}   ${new_config}
    Restart DHCP Server

Execute Command On DHCP Server
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cmd}: <description>
    ...
    ...    Returns:
    ...        ${output}: <description>
    [Arguments]    ${cmd}
    SSHLibrary.Switch Connection    dhcp_server
    ${output}=	SSHLibrary.Execute Command     ${cmd}   dhcp_server
    Log     ${output}
    [RETURN]    ${output}

Read DHCP Configuration File IPv4
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${output}: <description>
    ${output}=	Execute Command On DHCP Server     sudo cat /etc/dhcp/dhcpd.conf
    Log         ${output}
    [RETURN]    ${output}

Read DHCP Configuration File IPv6
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${output}: <description>
    ${output}=	Execute Command On DHCP Server     sudo cat /etc/dhcp/dhcpd6.conf
    Log         ${output}
    [RETURN]    ${output}

Get Host Configuration with string In DHCP Server
    [Documentation]    For IPv4 host
    [Arguments]    ${str}
    ${output}=  Execute Command On DHCP Server     sudo cat /etc/dhcp/dhcpd.conf|grep -i ${str}
    ${count}=   Get Line Count  ${output}
    Should Be True      '${count}'=='1'
    ${configuration}=   Strip String    ${output}
    [RETURN]    ${configuration}

Get MAC address of BTS
    [Documentation]    Get MAC address of br0 or br1
    SSHLibrary.Open Connection              192.168.255.129             alias=bts_lmp
    ${output}=	SSHLibrary.Login            toor4nsn    oZPS0POrRieRtu  alias=bts_lmp
    ${output}=	SSHLibrary.Execute Command  ifconfig br0;ifconfig br1   alias=bts_lmp
    Log         ${output}
    ${matchs}=  Get Regexp Matches             ${output}   ether ([\\w+:]+)    1
    Should Not Be Empty     ${matchs}
    SSHLibrary.Close Connection
    [RETURN]    ${matchs}[0]

Generate Vendor Encapsulated Options IPv4
    [Documentation]    The keyword aims to generate "Vendor Encapsulated Options" based on provided lbwas IPv4 address
    ...    1. "Vendor Encapsulated Options" is defined as a text string or a colon-separated list of hexadecimal values
    ...       which is
    ...    2. Redundant PnP Service IP (fake) will be generated to verify if BTS can pick correct one for PnP.
    ...    3. See below link for defination of Vendor Encapsulated Options.
    ...       https://nokia.sharepoint.com/:x:/r/sites/ArchitectureandSpecification/_layouts/15/Doc.aspx?
    ...       sourcedoc=%7B46ECDC4B-CF35-4434-BCD2-5EABC65ECFA2%7D&file=DHCPv4_v6%20PnP%20vendor%20parameters.
    ...       xlsx&action=default&mobileredirect=true
    [Arguments]    ${lbwas_ip}
    ${lbwas_ip_hex}=    Convert IPv4 Address to colon-separated List of Hexadecimal Values    ${lbwas_ip}
    ${veo}=     Add Redundant Fake PnP Service IP To Veo For IPv4     ${lbwas_ip_hex}
    [RETURN]    ${veo}

Convert IPv4 Address to colon-separated List of Hexadecimal Values
    [Documentation]    Convert IPv4 address to colon-separated List of Hexadecimal Values
    ...    eg. 10.97.92.78 => 0a:61:5c:4e
    [Arguments]    ${lbwas_ip}
    Validate IPv4 Address     ${lbwas_ip}
    ${lbwas_ip_hex}=     Set Variable    ${EMPTY}
    ${ip_split}=    Split String        ${lbwas_ip}     .
    FOR    ${number}    IN    @{ip_split}
        ${result}=  Convert To Hex  ${number}   length=2    lowercase=${TRUE}
        ${lbwas_ip_hex}=     Set Variable    ${lbwas_ip_hex}:${result}
    END
    ${lbwas_ip_hex}=    Strip String    ${lbwas_ip_hex}    both    :
    Log    ${lbwas_ip_hex}
    [RETURN]    ${lbwas_ip_hex}

Add Redundant Fake PnP Service IP To Veo For IPv4
    [Documentation]    Add Redundant PnP Service IPs (fake) to "Vendor Encapsulated Options"
    ...    Amount (>1) of Redundant PnP Service IPs is random generated
    ...    Tag (one of 1, 20-26) for valid PnP Service IP is random set
    [Arguments]    ${lbwas_ip_hex}
    ${pnp_service_ip_count}=    Evaluate    random.randint(2,8)    random
    ${veo}=     Set Variable    ${EMPTY}
    ${fake_veo_prefix}=    Set Variable    0a:29:92
    ${tag_list}=    Evaluate    random.sample(range(20,27),${pnp_service_ip_count}-1)       random
    Append to List  ${tag_list}     ${1}
    Log     ${tag_list}
    ${tag_list_len}=    Get Length      ${tag_list}
    ${vaild_veo_tag_index}=     Evaluate    random.randint(0,${tag_list_len}-1)    random
    ${vaild_veo_tag}=   Set Variable    ${tag_list}[${vaild_veo_tag_index}]
    FOR     ${tag}  IN    @{tag_list}
        ${veo_suffix}=  Generate Random String  2   123456789
        ${tag_hex}=    Convert To Hex  ${tag}   length=2    lowercase=${TRUE}
        ${veo}=    Set Variable If    ${vaild_veo_tag}==${tag}
        ...     ${veo}:${tag_hex}:04:${lbwas_ip_hex}    ${veo}:${tag_hex}:04:${fake_veo_prefix}:${veo_suffix}
    END
    ${veo}=     Strip String    ${veo}    both    :
    [RETURN]    ${veo}

Add Redundant Fake PnP Service IP To Veo For IPv6
    [Documentation]    Add Redundant PnP Service IPs (fake) to "Vendor Encapsulated Options"
    ...    Amount (>1) of Redundant PnP Service IPs is random generated
    ...    Tag (one of 1, 20-26) for valid PnP Service IP is random set
    ...    ${ipv6_no_colon}: ipv6 address without colon. eg. 2a00:3456:...:1234 as 2a003456:...1234
    ...    ${lbwas_ipv6_cs}: colon-seperated ipv6 address. 2a00:3456:...:1234 as 2a:00:34:56:...:12:34
    [Arguments]    ${lbwas_ipv6_address}
    ${ipv6_no_colon}=    Replace String     ${lbwas_ipv6_address}    :   ${EMPTY}
    ${lbwas_ipv6_cs}=  Evaluate    ":".join("${ipv6_no_colon}"[i:i+2] for i in range(0, len("${ipv6_no_colon}"), 2))
    ${pnp_service_ip_count}=    Evaluate    random.randint(2,8)    random
    ${veo}=     Set Variable    ${EMPTY}
    ${fake_veo_prefix}=    Replace String Using Regexp    ${lbwas_ipv6_cs}    :[0-9a-f]+$    ${EMPTY}
    ${tag_list}=    Evaluate    random.sample(range(20,27),${pnp_service_ip_count}-1)       random
    Append to List  ${tag_list}     ${1}
    Log     ${tag_list}
    ${tag_list_len}=    Get Length      ${tag_list}
    ${vaild_veo_tag_index}=     Evaluate    random.randint(0,${tag_list_len}-1)    random
    ${vaild_veo_tag}=   Set Variable    ${tag_list}[${vaild_veo_tag_index}]
    FOR     ${tag}  IN    @{tag_list}
        ${veo_suffix}=  Generate Random String  2   123456789
        ${tag_hex}=    Convert To Hex  ${tag}   length=2    lowercase=${TRUE}
        ${veo}=    Set Variable If    ${vaild_veo_tag}==${tag}    ${veo}:00:${tag_hex}:00:10:${lbwas_ipv6_cs}
        ...    ${veo}:00:${tag_hex}:00:10:${fake_veo_prefix}:${veo_suffix}
    END
    ${veo}=     Strip String    ${veo}    both    :
    [RETURN]    ${veo}

Get lbwas IP From Url IPv4
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${lbwas_ip}: <description>
    ${dn}=  Get DN From Url     ${NETACT_SERVER_INFO}[URL]
    ${output}=  Run     host ${dn} |grep -iv ipv6
    ${lbwas_ip}=    Fetch From Right     ${output}     ${SPACE}
    Validate IPv4 Address     ${lbwas_ip}
    [RETURN]    ${lbwas_ip}

Generate Vendor Encapsulated Options IPv6
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lbwas_ipv6_address}: <description>
    ...
    ...    Returns:
    ...        ${veo}: <description>
    [Arguments]    ${lbwas_ipv6_address}
    Validate IPv6 Address     ${lbwas_ipv6_address}
    ${veo_without_en}=    Add Redundant Fake PnP Service IP To Veo For IPv6    ${lbwas_ipv6_address}
    ${veo}=    Set Variable    00:00:6f:2a:${veo_without_en}
    Log    ${veo}
    [RETURN]    ${veo}

Get lbwas IP From Url IPv6
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${lbwas_ipv6_address}: <description>
    ${dn}=  Get DN From Url     ${NETACT_SERVER_INFO}[URL]
    ${lbwas_ipv6_address}=    Get IPv6 Address With DN From NMS     ${dn}
    [RETURN]    ${lbwas_ipv6_address}

Get IPv6 Address With DN From NMS
    [Documentation]    Get IPv6 Address With DN From NMS
    ...    eg. srnclab1015lbwas.srnblr.nsn-rdnet.net => 2a00:8a00:a000:115c::a29:9293
    [Arguments]    ${dn}
    SSHLibrary.Open Connection      ${NETACT_SERVER_INFO}[IP]      alias=NMS
    ${output}=	SSHLibrary.Login
    ...     ${NETACT_SERVER_INFO}[USERNAME]    ${NETACT_SERVER_INFO}[PASSWORD]  alias=NMS
    SSHLibrary.Switch Connection    NMS
    ${output}=	SSHLibrary.Execute Command     host ${dn}|grep -i ipv6   alias=NMS
    SSHLibrary.Close Connection
    ${ipv6_address}=    Fetch From Right     ${output}     ${SPACE}
    Validate IPv6 Address   ${ipv6_address}
    ${ipv6_address_full}=   Get Full IPv6 Address   ${ipv6_address}
    Validate IPv6 Address    ${ipv6_address_full}
    [RETURN]    ${ipv6_address_full}

Validate IPv4 Address
    [Documentation]    ipv4 address validation
    [Arguments]    ${ipv4_address}
    ${result}=  Evaluate    ipaddress.ip_address("${ipv4_address}").version     ipaddress
    Should Be True  '${result}'=='4'

Validate IPv6 Address
    [Documentation]    ipv6 address validation
    [Arguments]    ${ipv6_address}
    ${result}=  Evaluate    ipaddress.ip_address("${ipv6_address}").version     ipaddress
    Should Be True  '${result}'=='6'

Get Full IPv6 Address
    [Documentation]    Get full ipv6 address in case of copressed address
    ...    eg. 2a00:8a00:a000:115c::a29:941c => 2a00:8a00:a000:115c:0000:0000:0a29:941c
    [Arguments]    ${ipv6_address}
    ${full_ip}=    Evaluate    ipaddress.ip_address("${ipv6_address}").exploded     ipaddress
    [RETURN]    ${full_ip}

Get Compressed IPv6 Address
    [Documentation]    Get compressed ipv6 address in case of copressed address
    ...    eg. 0::0 => ::
    [Arguments]    ${ipv6_address}
    ${compressed_ip}=    Evaluate    ipaddress.ip_address("${ipv6_address}").compressed     ipaddress
    [RETURN]    ${compressed_ip}

Get DN From Url
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${url}: <description>
    ...
    ...    Returns:
    ...        ${dn}: <description>
    [Arguments]    ${url}
    Log    ${url}
    ${str1}=    Remove String      ${url}       https://
    ${dn}=      Fetch From Left    ${str1}      /
    [RETURN]    ${dn}

Open Connection To DHCP Server
    [Documentation]    Short description.
    SSHLibrary.Open Connection      ${dhcp_server}[ip]      alias=dhcp_server
    ${output}=	SSHLibrary.Login       ${dhcp_server}[user]    ${dhcp_server}[password]     alias=dhcp_server
    ${output}=	SSHLibrary.Execute Command     sudo service isc-dhcp-server status   alias=dhcp_server
    Log     ${output}

Close Connection To DHCP Server
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    dhcp_server
    SSHLibrary.Close Connection

Remove LNRELG and LNRELW Objects In SCF
    [Documentation]    Remove LNRELG and LNRELW Objects which will lead import failed
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    ${xpath}    set variable    //*[@class='LNRELG']
    ${newxml}=    ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}
    ${xpath}    set variable    //*[@class='LNRELW']
    ${newxml}=    ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}

Remove DHCP IP And Default Route In SCF
    [documentation]    localIpAddr ,localIpPrefixLength and default route should be removed when
    ...    ipAddressAllocationMethod is DHCP, otherwise the plan activation maybe reject
#    ${PnPPlanfile}=    Set Variable    /home/ute/newMRBTSplan.xml
#    ${dhcp_in_use_v4}=    Set Variable    ${TRUE}
#    ${dhcp_in_use_v6}=    Set Variable    ${FALSE}
    Remove DHCP IP In SCF    ${PnPPlanfile}
    Run Keyword If    ${dhcp_in_use_v4}    Remove Default IPv4 Route In SCF    ${PnPPlanfile}
    Run Keyword If    ${dhcp_in_use_v6}    Remove Default IPv6 Route In SCF    ${PnPPlanfile}

Remove DHCP IP In SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [arguments]    ${PnPPlanfile}
    ${xpath}    set variable    //*[@name='ipAddressAllocationMethod' and text()='2']/..//*[@name='localIpAddr']
    ${newxml}=    ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}
    ${xpath}    set variable    //*[@name='ipAddressAllocationMethod' and text()='2']/..//*[@name='localIpPrefixLength']
    ${newxml}=    ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}

Remove Default IPv4 Route In SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [arguments]    ${PnPPlanfile}
    ${xpath}    set variable    //*[@name='destIpAddr' and text()='0.0.0.0']/..
    ${newxml}=    ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}

Remove Default IPv6 Route In SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PnPPlanfile}: <description>
    [arguments]    ${PnPPlanfile}
    ${output}=    Run    cat ${PnPPlanfile} |grep destIpv6Addr
    ${matchs}=    Get Regexp Matches  ${output}   >([0-9A-Fa-f:]+)<    1
    FOR    ${dst}    IN    @{matchs}
        ${dst_compressed}=    Get Compressed IPv6 Address    ${dst}
        Continue For Loop If    '${dst_compressed}'!='::'
        ${xpath}    set variable    //*[@name='destIpv6Addr' and text()='${dst}']/..
        ta_xml_interface.remove_xml_element  ${PnPPlanfile}  ${PnPPlanfile}    ${xpath}
    END
