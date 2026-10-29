*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Aditya M"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "Configuration of 100G Fat pipe with FHGW or switch Network"
...     [Date]      "08-03-2024"
...     [QC_Path]   "Root\Test_Sets\Trunk\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...     [QC_ID]     "353201"
...     [Funtion_Hash_Tags] "100G fat pipe"
...     [Feature_ID]            "CB010919-A"
...     [Requirement ID]    "TT_GEN_COMMON_USCR_742"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "trs-cran6_vDU"
...     [Config]    "This testcase requires basic configuration with RANNIC TNL"
...     [scf_file]  "CB010919_basic_scf.xml"

Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***
Load the basic scf
     Login_vDU
     Perform Commissioning    dut=vdu_10919    scf_file=${basic_scf}     skip_parameter_relation_errors=${True}    timeout=300     alias=default
     Sleep   100
     Logout vDU


Verify 100G fat pipe is Enabled
    Verify in FHGW

Verify in FHGW
    Setup Remote Access    remote_device=10919_FHGW     alias=default
    Execute Interactive Remote Command     command=${login_to_FHGW}     exit_prompt=#     alias=default
    ${port_status}=    Execute Interactive Remote Command     command=${get_port_status}     exit_prompt=#    alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$    alias=default
    Teardown Remote Access      alias=default
    Should Contain    ${port_status}    up
    Should Contain    ${port_status}    100G
    Should not Contain    ${port_status}    down
    Should not Contain    ${port_status}    25G

Get RANNIC TNL number from the webem
    FOR   ${num}    IN RANGE   7   13
        Set Suite Variable    ${num}
        Run Keyword And Ignore Error    Get TNL
    END

Get TNL
    Set Suite Variable    ${num}
    ${vlanIfName}=    Get Parameter    dut=vdu_10919   param_path=${fhuc_TNL_path}${num}${rannic_vlan_path}     alias=default
    ${TNL}   Set Variable If    '${vlanIfName}' == 'fhucplane01'   ${num}
    Run Keyword If    '${vlanIfName}' == 'fhucplane01'   Set Suite Variable    ${TNL}   ${num}


Change the service account password
    Login_vDU
    [Documentation]        This test case keyword is to change service account password
    Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}       new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_10919       alias=default
    ${RANNIC_PASSWORD}    Set Variable    ${RANNIC_NEW_PASSWORD}
    Set Suite Variable      ${RANNIC_PASSWORD}
    Sleep     100
    Logout vDU

Enable ssh access from rannic
    Login_vDU
    [Documentation]        This test case keyword is to activate the ssh tunnel
    Config Ssh Tunnel      dist_name=${rannic_runtime_path}     operation=enable     timeout=500    dut=vdu_10919    alias=default
    Sleep     30
    Logout vDU

Login to RANNIC and enable the R&D flag for 100G fat pipe support
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${login_to_rannic_via_ssh}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${RANNIC_PASSWORD}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${root_login}     exit_prompt=Password:   alias=default
    Execute Interactive Remote Command     command=${RANNIC_PASSWORD}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${enable_100G_R&D_flag}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Enable 100G fat pipe in webEM
    Login_vDU
    Run Keyword And Expect Error    *   Perform Recommissioning    dut=vdu_10919    type=delta    delta_file=${enable_fat_pipe_flag}
    ...      skip_parameter_relation_errors=${True}    timeout=300   force_reset=${True}   auto_lock_cells=${True}     alias=default
    Sleep    300
    Logout vDU

Verify RANNIC sync status is Locked
    Login_vDU
    ${RANNIC_sync_status}=    Get Parameter    dut=vdu_10919    param_path=${rannic_sync_status_path}    alias=default
    Should be equal     ${RANNIC_sync_status}      Locked
    Logout vDU
    Sleep   10

Run Airphone commands for on-Air
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=cd /opt/iphy/latest     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=sudo killall edaemon egate     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=sudo killall edaemon egate     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=sudo killall edaemon egate     exit_prompt=$   alias=default
    Call Setup    dut=vdu_10919     5g=device1:data      parallel=${False}    attach=${False}     verify_attach=${False}    ipv4_or_6=ipv4
    Sleep   50
    Configure Ue    5g=device1:data    command=enb_x2_link_up   enb=1   target=2
    Sleep   10

Verify F1c link is UP
    Login_vDU
    ${f1c_link_status}=    Get Parameter    dut=vdu_10919     param_path=${f1c_link_status_path}     alias=default
    Should be equal     ${f1c_link_status}     available
    Logout vDU

Verify BTS is on-Air
    Login_vDU
    Verify Bts Status     dut=vdu_10919     should_be_onair=${True}     wait_for=60     timeout=60     alias=default
    Logout vDU

Login_vDU
    Setup Oamops    dut=vdu_10919        timeout=100      alias=default

Logout vDU
    Teardown Oamops    dut=vdu_10919      timeout=100      alias=default

Change RANNIC sync source to GNSS via delta plan
     Login_vDU
#     Perform Recommissioning    dut=vdu_10919    type=delta    delta_file=${change_sync_source_GNSS}    skip_parameter_relation_errors=${True}
#     ...    timeout=300   force_reset=${True}   auto_lock_cells=${True}     alias=default
     Perform Commissioning    dut=vdu_10919    scf_file=${GNSS_added_scf}     skip_parameter_relation_errors=${True}    timeout=300     alias=default
     Sleep   100
     Logout vDU

Add RANNIC ethlk DN in ptpmaster moc
     Login_vDU
     Perform Recommissioning    dut=vdu_10919    type=delta    delta_file=${add_ethlk_DN}    skip_parameter_relation_errors=${True}
     ...    timeout=300   force_reset=${True}   auto_lock_cells=${True}     alias=default
     Sleep   100
     Logout vDU


Reset the vDU to apply the sync changes
    Login_vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_10919    alias=default    should_be_onair=${False}     verify_bts=${False}
    Sleep   100
    Logout vDU

Change the sync input in FHGW as TOPP
    Setup Remote Access    remote_device=10919_FHGW     alias=default
    Execute Interactive Remote Command     command=${login_to_FHGW}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${set_sync_input_type}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${set_sync_input_port}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${set_sync_input_port_DN}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${set_ecpri_port_confLIST}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${enable_port_27_as_admin}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${restart_switch_manager}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=${restart_sync_app}     exit_prompt=#     alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$    alias=default
    Teardown Remote Access      alias=default


Verify ocp sync status is Locked
    Login_vDU
    ${ocp_sync_status}=    Get Parameter    dut=vdu_10919    param_path=${ocp_sync_status_path}     alias=default
    Should be equal     ${ocp_sync_status}      Locked
    Logout vDU

Reset vDU 5 times and verify F1c link is UP
    FOR   ${num}    IN RANGE   5
       Perform vDU reset
       Sleep   200
       Verify F1c link is UP
    END

Perform vDU reset
    Login_vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_10919    alias=default    should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vDU


Verify LBM traffic in the pcap file
    Analyse Pcap        pcap_filename=${LBM_packets}        analysis=verify_loopback_message       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${LBM_packets}        analysis=verify_loopback_reply       filter_file_name=${traffic_filter_file_name}


Login to RANNIC and capture the LBM traffic at rfoe4 interface
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${login_to_rannic_via_ssh}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${RANNIC_PASSWORD}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${root_login}     exit_prompt=Password:   alias=default
    Execute Interactive Remote Command     command=${RANNIC_PASSWORD}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${capture_lbm_traffic}      exit_prompt=#   alias=default
    Copy pcap from RANNIC to cluster

Copy pcap from RANNIC to cluster
    Setup Remote Access    remote_device=vdu_10919.ocp     alias=conn23
    Execute Interactive Remote Command     command=sudo ifconfig ens35f0 192.168.254.16/24     exit_prompt=$   alias=conn23
    Execute Interactive Remote Command     command=${copy_pcap_rannic_to_cluster}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${cluster_password}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=exit     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default
    Copy pcap from cluster to VM

Copy pcap from cluster to VM
    Execute Interactive Remote Command     command=${copy_pcap_cluster_to_VM}     exit_prompt=password:   alias=conn23
    Execute Interactive Remote Command     command=${VM_password}     exit_prompt=$   alias=conn23
    Teardown Remote Access      alias=conn23

Reset vDU in WebEM and Capture DHCP packets in OAMFH pod
    Run Keywords In Parallel    Run keyword    Perform vDU reset    AND   Run Keyword    Capture DHCP packets in OAMFH pod


Capture DHCP packets in OAMFH pod
    Sleep   150
    Setup Remote Access    remote_device=vdu_10919.ocp     alias=default
    Execute Interactive Remote Command     command=${login_to_oamfh_pod}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${start_tcpdump}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${exit_from_pod}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${copy_pcap_from_pod_to_cluster}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${copy_pcap_from_cluster_to_VM}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${VM_password}     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default


Verify DHCP packets between RU and OAMFH
    Analyse Pcap        pcap_filename=${dhcp_packets}        analysis=verify_dhcp_discover       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${dhcp_packets}        analysis=verify_dhcp_offer       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${dhcp_packets}        analysis=verify_dhcp_request       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${dhcp_packets}        analysis=verify_dhcp_ack       filter_file_name=${traffic_filter_file_name}


Reset Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${ssh_login_to_Airphone}     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=${reboot_Airphone}     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default
