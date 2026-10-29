*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Perform warm reset from WebEM
    Setup Oamops    dut=vdu_1    alias=default
    Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}
    ...     verify_bts=${False}
    Teardown Oamops     dut=vdu_1     alias=default

Load base scf
    Setup Oamops    dut=vdu_1    alias=default
    Perform Commissioning    dut=vdu_1    scf_file=${DC_scf}    timeout=300    alias=default
    Sleep   300
    Teardown Oamops     dut=vdu_1     alias=default

Load LBM configurations
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${LBM_configs}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_1     alias=default

Change the service account password
    Setup Oamops    dut=vdu_1    alias=default
    [Documentation]        This test case keyword is to change service account password
    Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}
    ...     new_password=${RANNIC_NEW_PASSWORD}       dut=vdu_1       alias=default
    ${RANNIC_PASSWORD}    Set Variable    ${RANNIC_NEW_PASSWORD}
    Set Suite Variable      ${RANNIC_PASSWORD}
    Sleep     100
    Teardown Oamops     dut=vdu_1     alias=default

Enable ssh access from rannic
    Setup Oamops    dut=vdu_1    alias=default
    [Documentation]        This test case keyword is to activate the ssh tunnel
    @{config_variable}=   Create List     RANNIC_MOC
    ${RANNIC_MOC}=     Get Config Variable     ${config_variable}
    Config Ssh Tunnel      dist_name=${RANNIC_MOC}     operation=enable     timeout=500
    ...     dut=vdu_1    alias=default
    Sleep     30
    Teardown Oamops     dut=vdu_1     alias=default


Check BTS status
    Setup Oamops    dut=vdu_1    alias=default
    @{config_variable}=     Create List     BTS_STATUS
    ${BTS_STATUS}=      Get Config Variable     ${config_variable}
    ${status}=      Get Parameter   param_path=${BTS_STATUS}     dut=vdu_1   timeout=120     alias=default
    Should Be Equal     ${status}   ${bts_status_1}
    Teardown Oamops     dut=vdu_1     alias=default

Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Setup Remote Access     remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command      command=${login_to_rannic_via_ssh}      alias=default
    Sleep   10
    Execute Interactive Remote Command      command=${RANNIC_PASSWORD}      alias=default
    Execute Interactive Remote Command      command=${capture_lbm_traffic}      alias=default
    Execute Interactive Remote Command      command=${Change_mod_777}     alias=default
    Execute Interactive Remote Command      command=${Exit}     alias=default
    Execute Interactive Remote Command      command=${Exit}     alias=default
    Execute Interactive Remote Command      command=${copy_from_rannic_to_vm}    alias=default
    Teardown Remote Access      alias=default

Verify LBM traffic in the pcap file
    Analyse Pcap     pcap_filename=${LBM_packets}     analysis=verify_loopback_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap     pcap_filename=${LBM_packets}     analysis=verify_loopback_reply
    ...     filter_file_name=${traffic_filter_file_name}

Change the pcp value and verify same in pcap
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${DC_delta_pcp}
    ...     skip_parameter_relation_errors=${True}     timeout=300     alias=default
    Sleep   10
    @{config_variable}=     Create List     pcp_value
    ${pcp_value}=      Get Config Variable     ${config_variable}
    ${pcp}=    Get Parameter    dut=vdu_1   param_path=${pcp_value}     alias=default
    Set Suite Variable  ${pcp}  ${pcp}
    Login to RANNIC and capture the LBM traffic at rfoe4 interface and copy
    Analyse Pcap    pcap_filename=${LBM_packets}        analysis=verify_pcp_value
    ...     filter_file_name=${traffic_filter_file_name}
    Teardown Oamops     dut=vdu_1     alias=default

Reset RANNIC
    Setup Oamops    dut=vdu_1    alias=default
    @{config_variable}=   Create List     RANNIC_MOC
    ${RANNIC_MOC}=     Get Config Variable     ${config_variable}
    Reset Rannic    rannic_r_dn=${RANNIC_MOC}    dut=vdu_1  timeout=100     alias=default
    Teardown Oamops     dut=vdu_1     alias=default

Enable actLbmOnFronthaul flag
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${delta_enable_lbm_flag}
    ...     skip_parameter_relation_errors=${True}    timeout=300    force_reset=${True}    auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_1     alias=default

Disable actLbmOnFronthaul flag
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${delta_disable_lbm}
    ...     skip_parameter_relation_errors=${True}    timeout=300    force_reset=${True}    auto_lock_cells=${True}
    ...     alias=default
    Sleep   10
    Teardown Oamops     dut=vdu_1     alias=default

Verify CFM traffic in the pcap file
    Analyse Pcap     pcap_filename=${LBM_packets}       analysis=verify_CFM_traffic
    ...     filter_file_name=${traffic_filter_file_name}
    Log     Success

Compare vlanID for LCELNR
    Setup Oamops    dut=vdu_1    alias=default
    ${vlanID_1}=    Get Parameter    dut=vdu_1   param_path=${LCELNR1_vlan_path}     alias=default
    ${vlanID_2}=    Get Parameter    dut=vdu_1   param_path=${LCELNR2_vlan_path}     alias=default
    Set Suite Variable      ${vlanID_1} ${vlanID_1}
    Set Suite Variable      ${vlanID_2} ${vlanID_2}
    Should Not Be Equal     ${vlanID_1}     ${vlanID_2}

Verify LBM traffic for both vlans
    Analyse Pcap    pcap_filename=${LBM_packets}     analysis=verify_LBM_traffic_for_2804_vlan
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap    pcap_filename=${LBM_packets}     analysis=verify_LBM_traffic_for_444_vlan
    ...     filter_file_name=${traffic_filter_file_name}

Verify Alarms DC
    Setup Oamops    dut=vdu_1    alias=default
    Verify Alarm    faultid=61009    should_exist=${False}    dut=vdu_1    alias=default
    Teardown Oamops     dut=vdu_1     alias=default
