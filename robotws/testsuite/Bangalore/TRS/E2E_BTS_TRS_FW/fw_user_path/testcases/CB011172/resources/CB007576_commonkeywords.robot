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
Load Base SCF
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Commissioning    dut=vdu_7576    scf_file=${base_SW_scf}    timeout=300    alias=default
    Teardown Oamops     dut=vdu_7576     alias=default

Check actLbmOnFronthaul flag
    [Documentation]    Check if LBM flag is set to ENABLED
    Setup Oamops    dut=vdu_7576    alias=default
    ${flag}=    Get Parameter    param_path=${FLAG_PATH}    dut=vdu_7576    alias=default    timeout=60
    Should Be Equal    ${flag}    ${EXPECTED_FLAG_VALUE}
    Teardown Oamops     dut=vdu_7576     alias=default

Reboot RF
    Setup Oamops    dut=vdu_7576        timeout=100      alias=default
    ${rmods}=    Create List    1
    Reset    operation=reset_rmods    rmods_list=${rmods}    reset_reason=user    dut=vdu_7576    reset_type=Hard    timeout=300    alias=default
    Teardown Oamops     dut=vdu_7576     alias=default

Reboot Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=sshiphy     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=reboot     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Capture DHCP packets in case of direct connection
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
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_discover_RU2
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_offer_RU2
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_request_RU2
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_dhcp_ack_RU2
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
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_dhcp_discover_swn
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_dhcp_offer_swn
    ...     filter_file_name=${traffic_filter_file_name}
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
    Perform Recommissioning    dut=vdu_7576    type=delta    delta_file=${delta_fhm_swn_conf}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=conn22
    Teardown Oamops     dut=vdu_7576     alias=conn22

Capture DHCP packets
    Setup Oamops    dut=vdu_7576    alias=con23
    Setup Remote Access    remote_device=vdu_7576.ocp     alias=conn26
    Execute Interactive Remote Command     command=${oamfh_pod_name}     alias=conn26
    Execute Interactive Remote Command     command=${collect_pcap_dhcp}      alias=conn26
    Execute Interactive Remote Command     command=exit     alias=conn26
    Teardown Remote Access      alias=conn26
    Copy From Cluster To VM
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_7576     alias=con23

Copy From Cluster To VM
    Setup Remote Access    remote_device=vdu_7576.ocp     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_dhcp}      alias=conn28
    Execute Interactive Remote Command     command=${VM_pswd}          alias=conn28
    Teardown Remote Access      alias=conn28

Delta commissioning to change pcp and dscp value
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Recommissioning    dut=vdu_7576    type=delta    delta_file=${change_pcp_dscp}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=default
    Teardown Oamops     dut=vdu_7576     alias=default

Delta commissioning to check 61672 fronthaul mismatch alarm
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Recommissioning    dut=vdu_7576    type=delta    delta_file=${change_vlan_dscp}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=default
    Sleep   180
    Verify Alarm    alias=default    faultid=61672    severity=critical    should_exist=${True}    occurrences=1    dut=vdu_7576
    Teardown Oamops     dut=vdu_7576     alias=default

Delta commissioning to clear 61672 fronthaul mismatch alarm
    Setup Oamops    dut=vdu_7576    alias=default
    Perform Recommissioning    dut=vdu_7576    type=delta    delta_file=${correct_vlan_dscp}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=default
    Sleep   180
    Verify Alarm    faultid=61672    severity=critical    should_exist=${False}    occurrences=1    dut=vdu_7576    alias=default
    Teardown Oamops     dut=vdu_7576     alias=default
