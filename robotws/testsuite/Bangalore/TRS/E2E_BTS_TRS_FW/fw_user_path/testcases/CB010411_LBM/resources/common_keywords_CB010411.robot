*** Settings ***
Documentation	[Author]        "Shivani Patil"
...     	[Maintenance]   "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Perform warm reset from WebEM
    Setup Oamops    dut=vdu_10411    alias=default
    Reset    operation=reset_bts    rat=5g    dut=vdu_10411    alias=default    should_be_onair=${False}
    ...     verify_bts=${True}
    Teardown Oamops     dut=vdu_10411     alias=default

Load base scf
    Setup Oamops    dut=vdu_10411    alias=con22
    Perform Commissioning    dut=vdu_10411    scf_file=${comm_file_base}    timeout=300    alias=con22
    Run Keyword And Ignore Error   Teardown Oamops     dut=vdu_10411     alias=con22

Reboot Airphone
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command     command=sshiphy     exit_prompt=>   alias=default
    Execute Interactive Remote Command     command=reboot     exit_prompt=$   alias=default
    Teardown Remote Access      alias=default

Perform delta comissioning for RANNIC
    Setup Oamops    dut=vdu_10411    alias=default
    Perform Recommissioning    dut=vdu_10411    type=delta    delta_file=create_RANNIC_template.xml
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_10411     alias=default

Change the service account password
    Setup Oamops    dut=vdu_10411    alias=default
    [Documentation]        This test case keyword is to change service account password
    Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}
    ...     new_password=${RANNIC_NEW_PASSWORD}       dut=vdu_10411       alias=default
    ${RANNIC_PASSWORD}    Set Variable    ${RANNIC_NEW_PASSWORD}
    Set Suite Variable      ${RANNIC_PASSWORD}
    Sleep     100
    Teardown Oamops     dut=vdu_10411     alias=default

Enable ssh access from rannic
    Setup Oamops    dut=vdu_10411    alias=default
    [Documentation]        This test case keyword is to activate the ssh tunnel
    Config Ssh Tunnel      dist_name=MRBTS-1/EQM_R-1/APEQM_R-1/RNICMOD_R-1     operation=enable     timeout=500
    ...     dut=vdu_10411    alias=default
    Sleep     30
    Teardown Oamops     dut=vdu_10411     alias=default

Check if vDU is onAir
    Setup Oamops    dut=vdu_10411    alias=default
    Verify Bts Status     dut=vdu_10411     should_be_onair=${True}     wait_for=60     timeout=60     alias=default
    Teardown Oamops     dut=vdu_10411     alias=default

Login to RANNIC and capture the LBM traffic at rfoe4 interface
    Setup Remote Access     remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command      command=${login_to_rannic_via_ssh}    exit_prompt=serviceuser@10.58.66.2's password:    alias=default
    Execute Interactive Remote Command      command=${RANNIC_PASSWORD}    exit_prompt=#     alias=default
    Execute Interactive Remote Command      command=${capture_lbm_traffic}      exit_prompt=#       alias=default
    Execute Interactive Remote Command      command=${Change_mod_777}      exit_prompt=#       alias=default
    Execute Interactive Remote Command      command=${Exit}      exit_prompt=$       alias=default
    Execute Interactive Remote Command      command=${copy_from_rannic_to_VM}      exit_prompt=password:    alias=default
    Execute Interactive Remote Command      command=${VM_password}        exit_prompt=$     alias=default
    Teardown Remote Access  alias=default

Copy pcap from RANNIC to cluster
    Setup Remote Access     remote_device=vdu_10411.ocp      alias=conn25
    Execute Interactive Remote Command      command=sudo ifconfig ens35f0 192.168.254.16/24       exit_prompt=$
    ...     alias=conn25
    Execute Interactive Remote Command      command=${copy_pcap_rannic_to_cluster}        exit_prompt=password:
    ...     alias=default
    Execute Interactive Remote Command      command=${cluster_password}      exit_prompt=#       alias=default
    Execute Interactive Remote Command      command=exit     exit_prompt=$      alias=default
    Teardown Remote Access       alias=default
    Copy pcap from cluster to VM

Verify LBM traffic in the pcap file
    Analyse Pcap     pcap_filename=${LBM_packets}     analysis=verify_loopback_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap     pcap_filename=${LBM_packets}     analysis=verify_loopback_reply
    ...     filter_file_name=${traffic_filter_file_name}

Copy pcap from cluster to VM
    Setup Remote Access     remote_device=remote_device_1     alias=conn25
    Execute Interactive Remote Command      command=${copy_from_rannic_to_VM}      exit_prompt=password:
    ...     alias=conn25
    Execute Interactive Remote Command      command=${VM_password}        exit_prompt=$     alias=conn25
    Teardown Remote Access      alias=conn25

Change the pcp value and verify same in pcap
    Setup Oamops    dut=vdu_10411    alias=default
    Perform Recommissioning    dut=vdu_10411    type=delta    delta_file=${change_pcp_in_delta}
    ...     skip_parameter_relation_errors=${True}     timeout=300    force_reset=${True}    auto_lock_cells=${True}
    ...     alias=default
    Sleep   100
    Change the service account password
    Enable ssh access from rannic
    Login to RANNIC and capture the LBM traffic at rfoe4 interface
    Analyse Pcap    pcap_filename=${LBM_packets}        analysis=verify_pcp_value
    ...     filter_file_name=${traffic_filter_file_name}
    Run Keyword And Ignore Error   Teardown Oamops     dut=vdu_10411     alias=default

Verify Alarms
    Setup Remote Access     remote_device=remote_device_1     alias=conn27
    Execute Interactive Remote Command      command=${SSH_Airphone}        exit_prompt=>     alias=conn27
    Execute Interactive Remote Command      command=${bsh1}        exit_prompt=#     alias=conn27
    Execute Interactive Remote Command      command=${rfoe0_Down}        exit_prompt=#     alias=conn27
    Sleep    40
    Setup Oamops    dut=vdu_10411    alias=default
    Verify Alarm    faultid=61009    should_exist=${True}    dut=vdu_10411    alias=default
    Execute Interactive Remote Command      command=${rfoe0_Up}        exit_prompt=#     alias=conn27
    Sleep    50
    Verify Alarm    faultid=61009    should_exist=${False}    dut=vdu_10411    alias=default
    Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_10411     alias=default

Reset RANNIC
    Setup Oamops    dut=vdu_10411    alias=default
    Reset    dist_name=${resetRANNIC}    reset_type=reset_unit    dut=vdu_10411    alias=default
    ...     should_be_onair=${False}     verify_bts=${True}
    Teardown Oamops     dut=vdu_10411     alias=default

Enable actLbmOnFronthaul flag
    Setup Oamops    dut=vdu_10411    alias=default
    Perform Recommissioning    dut=vdu_10411    type=delta    delta_file=enable_actLbm_flagl.xml
    ...     skip_parameter_relation_errors=${True}    timeout=300    force_reset=${True}    auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_10411     alias=default

Disable actLbmOnFronthaul flag
    Setup Oamops    dut=vdu_10411    alias=default
    Perform Recommissioning    dut=vdu_10411    type=delta    delta_file=disable_actLbm_flagl.xml
    ...     skip_parameter_relation_errors=${True}    timeout=300    force_reset=${True}    auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_10411     alias=default

Verify CFM traffic in the pcap file
    Analyse Pcap     pcap_filename=${LBM_packets}       analysis=verify_CFM_traffic
    ...     filter_file_name=${traffic_filter_file_name}

Compare vlanID for LCELNR
    Setup Oamops    dut=vdu_10411    alias=default
    ${vlanID_1}=    Get Parameter    dut=vdu_10411   param_path=${LCELNR1_vlan_path}     alias=default
    ${vlanID_2}=    Get Parameter    dut=vdu_10411   param_path=${LCELNR2_vlan_path}     alias=default
    Should Not Be Equal     ${vlanID_1}     ${vlanID_2}

Verify LBM traffic for both vlans
    Analyse Pcap    pcap_filename=${LBM_packets}     analysis=verify_LBM_traffic_for_415_vlan
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap    pcap_filename=${LBM_packets}     analysis=verify_LBM_traffic_for_500_vlan
    ...     filter_file_name=${traffic_filter_file_name}
