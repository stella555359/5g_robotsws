*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...	    [Procedure]	"The test case is planned to validate Sync"


variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** KeyWords ***

Load SCF
    [Arguments]     ${base_scf}
    Setup Oamops    dut=vdu_7576    alias=conn22
    Perform Commissioning    dut=vdu_7576    scf_file=${base_scf}    timeout=300    alias=conn22
    Sleep   300
    Teardown Oamops     dut=vdu_7576     alias=conn22

Reboot Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=sshiphy     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=reboot     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Enabling Rannic ssh
    Setup Oamops    dut=vdu_7576    alias=conn24   timeout=300
     Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}       new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=conn24

#    Change the service account password     serviceuser     Nokia@123   Nokia@123
    Enable or Disable ssh access from rannic    enable
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=conn24

Capture DHCP packets in case of direct connection
    Setup Oamops    dut=vdu_7576    alias=conn24   timeout=300
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${Login_to_Rannic}     exit_prompt=serviceuser@10.58.66.8's password:    alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
#    Execute Interactive Remote Command     command=${Login_to_Root}     exit_prompt=Password:   alias=default
#    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Capture_tcpdump}     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Change_mod_777}    exit_prompt=#    alias=default
    Execute Interactive Remote Command     command=${Exit}     exit_prompt=$   alias=default
#    Execute Interactive Remote Command     command=${Exit}     alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm}    exit_prompt=${prompt}   alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Teardown Remote Access      alias=default
#    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=conn24

Capture DHCP packets to verify PCP bit
    [Arguments]     ${interface}
    Setup Oamops    dut=vdu_7576    alias=conn24
    Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}       new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_7576       alias=conn24
    Run Keyword and Ignore Error    Enable or Disable ssh access from rannic    disable
    Run Keyword and Ignore Error    Enable or Disable ssh access from rannic    enable
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${Login_to_Rannic}     exit_prompt=serviceuser@10.58.66.8's password:   alias=default
    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
#    Execute Interactive Remote Command     command=${Login_to_Root}     exit_prompt=Password:   alias=default
#    Execute Interactive Remote Command     command=${Password}     exit_prompt=#   alias=default
#    Sleep   200
    Run Keyword If  '${interface}' == 'rfoe4'   Execute Interactive Remote Command     command=${Capture_tcpdump_Interface}
    ...     exit_prompt=#   alias=default
    Run Keyword If  '${interface}' == 'rfoe5'   Execute Interactive Remote Command     command=${Capture_tcpdump_Interface_1}
    ...     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=chmod 777 /tmp/rfoe*     exit_prompt=#   alias=default
    Execute Interactive Remote Command     command=${Exit}     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=conn24

Copy pcap to VM
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm_pcpru1}    exit_prompt=${prompt}   alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Execute Interactive Remote Command     command=${copy_from_rannic_to_vm_pcpru2}    exit_prompt=${prompt}   alias=default
    Execute Interactive Remote Command     command=${Password}    exit_prompt=$       alias=default
    Teardown Remote Access      alias=default

Change the service account password
   [Documentation]        This test case keyword is to change service account password
   [Arguments]          ${USERNAME}     ${PASSWORD}         ${NEW_PASSWORD}
   Update Service Account Password      username=${USERNAME}       password=${PASSWORD}       new_password=${NEW_PASSWORD}
   ...         dut=vdu_7576       alias=vdu
   ${PASSWORD}    Set Variable    ${NEW_PASSWORD}
   Set Suite Variable      ${PASSWORD}


Enable or Disable ssh access from rannic
    [Arguments]     ${operation}
    [Documentation]        This test case keyword is to activate the ssh tunnel
    Run Keyword If  '${operation}'=='enable'    Config Ssh Tunnel      dist_name=MRBTS-1/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=enable
    ...     timeout=500    dut=vdu_7576    alias=conn24
    Sleep     30
    Run Keyword If  '${operation}'=='disable'     Config Ssh Tunnel      dist_name=MRBTS-1/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=disable
    ...     timeout=100    dut=vdu_7576    alias=conn24
    Sleep     30
#   Config Ssh Tunnel      dist_name=MRBTS-5568/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=enable     timeout=500    dut=vdu_7576    alias=vdu
    Sleep     30
#    Config Ssh Tunnel      dist_name=MRBTS-1/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=disable     timeout=100    dut=cbts    alias=vdu
#    Sleep     30


Verify DHCP packets
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_discover    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_offer       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_request     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_ack         filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_discover_RU2    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_offer_RU2       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_request_RU2     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_ack_RU2         filter_file_name=${traffic_filter_file_name}

Verify DHCP packets with pcp rfoe4
##Check for pcp in dhcp packets
    Analyse Pcap        pcap_filename=${filename_B}        analysis=verify_dhcp_offer_pcp       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_B}        analysis=verify_dhcp_ack_pcp       filter_file_name=${traffic_filter_file_name}
##Check for pcp in ping packets
Verify DHCP packets with pcp rfoe5
    Analyse Pcap        pcap_filename=${filename_C}        analysis=verify_dhcp_offer_pcp2       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_C}        analysis=verify_dhcp_ack_pcp2     filter_file_name=${traffic_filter_file_name}


###Use this once delta KW support is provided########
Delta commissioning to change pcp and dscp value
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Recommissioning     dut=vdu_7576    type=delta      delta_file=${delta_to_change_pcp}
    ...   skip_parameter_relation_errors=${True}  force_reset=${True}     auto_lock_cells=${True}
    Sleep   120
    Teardown Oamops     dut=vdu_7576     alias=default
#
#
Delta commissioning to check for 61672 fronthaul mismatch alarm
    Setup Oamops    dut=vdu_7576    alias=con22
    Perform Recommissioning     dut=vdu_7576     type=delta      delta_file=${delta_to_change_vlan_in_fhmplanenw_moc}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Sleep   300
    Verify Alarm    faultid=61672   severity=critical   should_exist=${True}  occurrences=1   dut=vdu_7576    alias=con22
    Teardown Oamops     dut=vdu_7576     alias=con22

Delta commissioning to clear for 61672 fronthaul mismatch alarm
    Setup Oamops    dut=vdu_7576    alias=con22
    Perform Recommissioning     dut=vdu     type=delta      delta_file=${delta_to_correct_fhmplane_vlan}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Sleep   300
    Verify Alarm    faultid=61672   severity=critical   should_exist=${False}  occurrences=1   dut=vdu_7576    alias=con22
    Teardown Oamops     dut=vdu_7576     alias=con22


Check pcp
    [Arguments]     ${interface}
#    Load SCF    ${PCP_scf}
    Setup Oamops    dut=vdu_7576    alias=con22
    Perform Recommissioning     dut=vdu_7576     type=delta      delta_file=${delta_to_change_pcp}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=con22
    Reboot Airphone
    Sleep   60
    Capture DHCP packets to verify PCP bit  ${interface}