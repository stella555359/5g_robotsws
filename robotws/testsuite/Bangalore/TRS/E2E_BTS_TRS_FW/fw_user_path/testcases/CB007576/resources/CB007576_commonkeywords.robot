*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check Multiple RUs Mplane FH Configuration discovery in direct connectivity mode"
...     [Date]      "20-02-24"
...     [Author]        "Indraja"
...     [QC_Path]   "Root\Test_Sets\Trunk\New_Features\BB_TRS_VRF_ET"
...     [QC_ID]     "341852"
...     [Funtion_Hash_Tags] "SWN CLOUD"
...     [Feature_ID]            "CB007576"
...     [Validated_TestLine]    "trs-cran8"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** KeyWords ***

Load SCF
    [Arguments]     ${comm_file}
    Setup Oamops    dut=vdu_7576    alias=conn22
    Perform Commissioning    dut=vdu_7576    scf_file=${comm_file}    timeout=300    alias=conn22
    Teardown Oamops     dut=vdu_7576     alias=conn22

Reboot Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=sshiphy     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=reboot     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Capture DHCP packets in case of direct connection
     Run Keyword And Ignore Error   Setup Oamops    dut=vdu_7576    alias=vdu
     Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}
    ...     new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=vdu
    Enable or Disable ssh access from rannic    enable
    Setup Remote Access    remote_device=remote_device_1     alias=default

    Execute Interactive Remote Command     command=${Login_to_Rannic}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Login_to_Root}     exit_prompt=Password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Capture_tcpdump}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Change_mod_777}   exit_prompt=#    alias=default
    Execute Interactive Remote Command     command=${Exit}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Exit}     alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm}    exit_prompt=${prompt}   alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Teardown Remote Access      alias=default
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=vdu

Capture DHCP packets to verify PCP bit
    [Arguments]     ${interface}
    Setup Oamops    dut=vdu_7576    alias=vdu
     Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}
    ...     new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=vdu
    Enable or Disable ssh access from rannic    enable

    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${Login_to_Rannic}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Login_to_Root}     exit_prompt=Password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
    Sleep   200
    Execute Interactive Remote Command     command=${interface}   exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Exit}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Exit}     alias=default
    Teardown Remote Access      alias=default
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=vdu

Copy pcap to VM
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm_pcpru1}    exit_prompt=${prompt}
    ...     alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm_pcpru2}    exit_prompt=${prompt}
    ...     alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Teardown Remote Access      alias=default

Change the service account password
   [Documentation]        This test case keyword is to change service account password
   [Arguments]          ${USERNAME}     ${PASSWORD}         ${NEW_PASSWORD}
   Update Service Account Password      username=${USERNAME}       password=${PASSWORD}
   ...      new_password=${NEW_PASSWORD}    dut=vdu_7576       alias=vdu
   ${PASSWORD}    Set Variable    ${NEW_PASSWORD}
   Set Suite Variable      ${PASSWORD}

Enable or Disable ssh access from rannic
    [Arguments]     ${operation}
    [Documentation]        This test case keyword is to activate the ssh tunnel
    Run Keyword If  '${operation}'=='enable'    Config Ssh Tunnel
    ...     dist_name=MRBTS-5568/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=enable     timeout=500    dut=vdu_7576
    ...     alias=vdu
    Sleep     30
    Run Keyword If  '${operation}'=='disable'     Config Ssh Tunnel
    ...     dist_name=MRBTS-1/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=disable     timeout=100    dut=cbts
    ...     alias=vdu
    Sleep     30

Verify DHCP packets
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_discover
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_offer
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_request
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_ack
    ...     filter_file_name=${traffic_filter_file_name}

Verify DHCP packets with pcp
##Check for pcp in dhcp packets
    Analyse Pcap        pcap_filename=${filename_B}        analysis=verify_dhcp_offer_pcp
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_B}        analysis=verify_dhcp_ack_pcp
    ...      filter_file_name=${traffic_filter_file_name}
##Check for pcp in ping packets
    Analyse Pcap        pcap_filename=${filename_C}        analysis=verify_icmp_RU2_pcp
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_C}        analysis=verify_icmp_RU2_dscp
    ...     filter_file_name=${traffic_filter_file_name}

Check pcp
    [Arguments]     ${interface}
    Load SCF    ${PCP_scf}
    Reboot Airphone
    Sleep   60
    Capture DHCP packets to verify PCP bit    ${interface}
Capture DHCP packets in case of Switched Connection
    Setup Oamops    dut=vdu_7576    alias=vdu
     Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}
    ...    new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=default
    Enable or Disable ssh access from rannic    enable
    Setup Remote Access    remote_device=remote_device_1     alias=default

    Execute Interactive Remote Command     command=${Login_to_Rannic}     exit_prompt=password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Login_to_Root}     exit_prompt=Password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Capture_tcpdump}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Change_mod_777}   exit_prompt=#    alias=default
    Execute Interactive Remote Command     command=${Exit}     exit_prompt=$   alias=default
    Execute Interactive Remote Command     command=${Exit}     alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm}    exit_prompt=${prompt}   alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Teardown Remote Access      alias=default
    Teardown Oamops     dut=vdu_7576     alias=vdu

Verify DHCP packets in swn
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_dhcp_request_swn
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_dhcp_ack_swn
    ...     filter_file_name=${traffic_filter_file_name}

Verify DHCP packets with pcp in swn
##Check for pcp in dhcp packets
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_changed_dhcp_offer_pcp
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_changed_dhcp_ack_pcp
    ...     filter_file_name=${traffic_filter_file_name}

Delta Commissioning with 7576 changes
    Setup Oamops    dut=vdu_7576    alias=conn22
    Perform Recommissioning     dut=vdu_7576    type=delta      delta_file=${delta_fhm_swn_conf}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=conn22
    Teardown Oamops     dut=vdu_7576     alias=conn22

Capture DHCP packets
    Run Keyword And Ignore Error    Setup Oamops    dut=vdu_7576    alias=con23
    Setup Remote Access    remote_device=vdu_7576_swn.ocp     alias=conn26
    Execute Interactive Remote Command     command=${oamfh_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap_dhcp}      alias=conn26
    Execute Interactive Remote Command     command=exit     exit_prompt=$     alias=conn26
    Teardown Remote Access      alias=conn26
    Copy From Cluster To VM     ${dhcp_pcap_path}
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=con23

Copy From Cluster To VM
    [Arguments]     ${path_in_cluster}
    Setup Remote Access    remote_device=vdu_7576_swn.ocp     alias=conn28
    Execute Interactive Remote Command     command=${path_in_cluster}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_dhcp}    exit_prompt=ute@10.58.66.234's password:   alias=conn28
    Execute Interactive Remote Command     command=UTE.debian12  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28

Perform SA call
    Setup Oamops    dut=vdu_7576      alias=conn100
    Traffic Capture Start   capture_device=vm_eth7_interface    alias=conn100
	Call Setup  nr=5g_basic_setup_cfg:data  parallel=${False}   verify_attach=${False}    attach=${False}     timeout=300   alias=conn100
    Check BTS status
    Sleep   60
    Check NGLINK Status
	Sleep	5
	Configure Ue    nr=5g_basic_setup_cfg:data    command=ue_register    id=1   alias=conn100
	Sleep   5
	Configure Ue    nr=5g_basic_setup_cfg:data    command=set_pdu_param    ue=1    pdu=1    trf_type=internal
    Sleep   2
	Configure Ue    nr=5g_basic_setup_cfg:data    command=ue_pdu_session_setup    pdu=1    gw=1      ue=1
	Sleep   2
	Configure Ue    nr=5g_basic_setup_cfg:data    command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    mbps=10
	Sleep   2
    Configure Ue    nr=5g_basic_setup_cfg:data    command=trf_data_start    ue=1    pdu=1    qfi=1    dir=ul    mbps=10
	Sleep   2
	${filename}=    Traffic Capture Stop   capture_device=vm_eth7_interface      timeout=180  alias=conn100
	Sleep   30
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_gtp
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ngap
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_ue_attach
    ...     filter_file_name=${traffic_filter_file_name}
    Teardown Oamops     dut=vcu_user     alias=conn100

Check BTS status
    Setup Oamops    dut=vdu_7576    alias=default
    @{config_variable}=     Create List     BTS_STATUS
    ${BTS_STATUS}=      Get Config Variable     ${config_variable}
    ${status}=      Get Parameter   param_path=${BTS_STATUS}     dut=vdu_7576   timeout=120     alias=default
    Should Be Equal     ${status}   ${bts_status_1}
    Teardown Oamops     dut=vdu_7576     alias=default

Check NGLINK status
    Setup Oamops    dut=vcu_user    alias=default
    @{config_variable}=     Create List     NGLINK
    ${BTS_STATUS}=      Get Config Variable     ${config_variable}
    ${status}=      Get Parameter   param_path=${BTS_STATUS}     dut=vcu_user   timeout=120     alias=default
    Should Be Equal     ${status}   ${nglink_status}
    Teardown Oamops     dut=vcu_user     alias=default