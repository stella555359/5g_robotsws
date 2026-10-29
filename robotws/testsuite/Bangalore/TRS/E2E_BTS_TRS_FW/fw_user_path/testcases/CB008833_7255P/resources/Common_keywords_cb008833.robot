*** Settings ***
Documentation
...            [Author]         "Santhosh K G"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***

#       Fetch SOAP/RP1 RF IP
Get AWHQN IP
    Setup Remote Access     remote_device=chained_bts     alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${lxc_enb2}     alias=secondary
    ${soaprp}=     Execute Interactive Remote Command      command=${getrfip_awhqn}     alias=secondary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Execute Interactive Remote Command      command=${exit}     alias=secondary


Get AWHQN ORAN IP
    Setup Remote Access     remote_device=bts     alias=primary
    Execute Interactive Remote Command      command=${ssh_enb}     alias=primary
    Execute Interactive Remote Command      command=${lxc_enb}     alias=primary
    ${soaprp}=     Execute Interactive Remote Command      command=${getrfip_awhqn}     alias=primary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Execute Interactive Remote Command      command=${exit}     alias=primary

Get AEQY IP
    Setup Remote Access     remote_device=chained_bts     alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${lxc_enb2}     alias=secondary
    ${soaprp}=     Execute Interactive Remote Command      command=${getrfip_aeqy}     alias=secondary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Execute Interactive Remote Command      command=${exit}     alias=secondary

Get AWEUC IP
    Setup Remote Access     remote_device=chained_bts     alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${lxc_enb2}     alias=secondary
    ${soaprp}=     Execute Interactive Remote Command      command=${getrfip_rmod2}     alias=secondary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Execute Interactive Remote Command      command=${exit}     alias=secondary


Get AZQG IP
    Setup Remote Access     remote_device=chained_bts     alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${lxc_enb2}     alias=secondary
    ${soaprp}=     Execute Interactive Remote Command      command=${getrfip_azqg}     alias=secondary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Execute Interactive Remote Command      command=${exit}     alias=secondary


Reload BTS
    Perform Recommissioning    type=delta    delta_file=${8833_config_delete}        timeout=300
    Perform Recommissioning     type=param      param_path=${LCELNR1}     operation=delete     value=   timeout=300
    Perform Recommissioning     type=param      param_path=${LCELNR2}     operation=delete     value=   timeout=300
    Perform Recommissioning     type=param      param_path=${LCELNR184}     operation=delete     value=   timeout=300
    Perform Recommissioning     type=param      param_path=${LCELNR18}     operation=delete     value=   timeout=300

    Sleep   300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active



Check Ping
    ${ping_rf}=      Execute Interactive Remote Command      command=ping -c 10 ${soaprp1}     alias=conn2
    Sleep    10
    Should Contain    ${ping_rf}    ${packet_loss}

DSCP PCP Verification AWHQNORAN
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_LF_as_src}      ${verify_mplanedscppcp_rmod_NKoran_src}
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodLF}    alias=primary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=primary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=primary

    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodLF}    alias=primary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=primary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=primary
    Execute Interactive Remote Command      command=${copy_bbmodLF_to_board}    alias=primary
    Execute Interactive Remote Command      command=${pwd}    alias=primary
    Log     below commented lines for the dual core cases
#    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=primary
#    Execute Interactive Remote Command      command=${vm_password}    alias=primary
#    Execute Interactive Remote Command      command=${exit}    alias=primary
#    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=primary
    Get File From Remote Host    source=${src}      destination=${dest}    alias=primary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_LF_as_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplanedscppcp_rmod_NKoran_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Execute Interactive Remote Command      command=${remove_pcap}      alias=primary

    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login}    alias=primary
    Execute Interactive Remote Command      command=ssh serviceuser@${soaprp1}   alias=primary
    Execute Interactive Remote Command      command=${Radio1_password_awhqn}    alias=primary
    Execute Interactive Remote Command      command=${root_login}    alias=primary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=primary
    ${cupcp_value}=     Get Line    ${cupcp}   -6
    Should Match    ${cupcp_pcp}   ${cupcp_value}

    Execute Interactive Remote Command      command=${exit}    alias=primary
    Execute Interactive Remote Command      command=${exit}    alias=primary
    Execute Interactive Remote Command      command=${exit}    alias=primary

DSCP PCP Verification AWHQNORAN Modification
    [Arguments]        ${verify_mplane_dscp_pcp_bbmodLF_as_src_mod}       ${verify_mplanedscppcp_NKoran_mod}
    Setup Ems  config_device=netact   alias=lab1042
    Cm Upload   config_device=netact   alias=lab1042
    Configuration Manage    config_device=netact   config=mplane_pcpdscp.json    plan_name=dscp_pcp_update
    ... delete_plan="True"  alias=lab1042
    Log     DSCP PCP Modification succesful via netact
    Teardown Ems    config_device=netact    alias=lab1042
    Perform Recommissioning     type=delta      delta_file=${Mplane_pcp_dscp_mod}       timeout=300
    Sleep   20
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log   Baseband verification


    Execute Interactive Remote Command      command=${bbmodLF}    alias=primary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=primary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=primary


    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodLF}    alias=primary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=primary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=primary
    Execute Interactive Remote Command      command=${copy_bbmodLF_to_board}    alias=primary
    Execute Interactive Remote Command      command=${pwd}    alias=primary

    Get File From Remote Host    source=${src}      destination=${dest}    alias=primary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmodLF_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=primary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplanedscppcp_NKoran_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=primary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=primary

    Log     CU PCP modification with BTS reset
    Perform Recommissioning    type=delta    delta_file=${cupcp_mod}        timeout=300
    Sleep  300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log     RF module verification
    Execute Interactive Remote Command      command=${ssh_enb}     alias=primary
    Execute Interactive Remote Command      command=${fronthaul_login}    alias=primary
    Execute Interactive Remote Command      command=ssh rfsw@${soaprp1}    alias=primary
    Execute Interactive Remote Command      command=${Radio1_password_awhqn}    alias=primary
    Execute Interactive Remote Command      command=${root_login}    alias=primary


    Execute Interactive Remote Command      command=${exit}    alias=primary
    Execute Interactive Remote Command      command=${exit}    alias=primary
    Execute Interactive Remote Command      command=${exit}    alias=primary




DSCP PCP Verification AEQY
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RM_as_src}      ${verify_mplanedscppcp_rmod_AEQY_src}
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRM}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary

    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodLF}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRM_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RM_as_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplanedscppcp_rmod_AEQY_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no serviceuser@${soaprp1}   alias=secondary
    Execute Interactive Remote Command      command=${Radio_password_aeqy}    alias=secondary
    Execute Interactive Remote Command      command=${root_login}    alias=secondary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   -6
    Should Match    ${cupcp_pcp}   ${cupcp_value}

    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary

DSCP PCP Verification AEQY Modification
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RM_as_src_mod}       ${verify_mplane_dscp_pcp_AEQY_as_src_mod}
    Perform Recommissioning     type=delta      delta_file=${Mplane_pcp_dscp_mod}       timeout=300
    Sleep   20
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRM}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary


    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodLF}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRM_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary

    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RM_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_AEQY_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     CU PCP modification with BTS reset
    Perform Recommissioning    type=delta    delta_file=${cupcp_mod}        timeout=300
    Sleep  300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no serviceuser@${soaprp1}    alias=secondary
    Execute Interactive Remote Command      command=${Radio_password_aeqy}    alias=secondary
    Execute Interactive Remote Command      command=${root_login}    alias=secondary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   -6
    Should Match    ${cupcp_pcp_mod}    ${cupcp_value}
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary

DSCP PCP Verification AZQG
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RL_as_src}      ${verify_mplanedscppcp_rmod_AZQG_src}
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRL}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary

    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodRL}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRL_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RL_as_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplanedscppcp_rmod_AZQG_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     RF module verification

    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no root@${soaprp1}   alias=secondary
    Execute Interactive Remote Command      command=${Radio_password_azqg}    alias=secondary


    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   3
    Should Match    ${cupcp_pcp}   ${cupcp_value}

    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary

DSCP PCP Verification AZQG Modification
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RL_as_src_mod}       ${verify_mplane_dscp_pcp_AZQG_as_src_mod}
    Perform Recommissioning     type=delta      delta_file=${Mplane_pcp_dscp_mod}       timeout=300
    Sleep   20
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRL}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary


    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodRL}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRL_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary

    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RL_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_AZQG_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     CU PCP modification with BTS reset
    Perform Recommissioning    type=delta    delta_file=${cupcp_mod}        timeout=300
    Sleep  300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no root@${soaprp1}    alias=secondary
    Execute Interactive Remote Command      command=${Radio_password_azqg}    alias=secondary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   3
    Should Match    ${cupcp_pcp_mod}    ${cupcp_value}
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary


DSCP PCP Verification AWHQN
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RL5b_as_src}      ${verify_mplanedscppcp_rmod_AWHQN_src}
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRL5b}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary

    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodRL}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRL5b_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RL5b_as_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplanedscppcp_rmod_AWHQN_src}
    ...       filter_file_name=${traffic_filter_file_name}
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no serviceuser@${soaprp1}   alias=secondary
    Execute Interactive Remote Command      command=${Radio1_password_awhqn}    alias=secondary
    Execute Interactive Remote Command      command=${root_login}    alias=secondary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   3
    Should Match    ${cupcp_pcp}   ${cupcp_value}

    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary

DSCP PCP Verification AWHQN Modification
    [Arguments]        ${verify_mplane_dscp_pcp_bbmod_RL5b_as_src_mod}       ${verify_mplane_dscp_pcp_AWHQN_as_src_mod}
    Perform Recommissioning     type=delta      delta_file=${Mplane_pcp_dscp_mod}       timeout=300
    Sleep   20
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log   Baseband verification

    Execute Interactive Remote Command      command=${bbmodRL5b}    alias=secondary
    Execute Interactive Remote Command      command=${bbmodpasswd}    alias=secondary
    Execute Interactive Remote Command      command=${bbmod_netns}       alias=secondary


    Log    Packet Analysis of Mplane PCP-DSCP at Baseband
    Execute Interactive Remote Command      command=${start_capture_bbmod_bbmodRL}    alias=secondary
    sleep   70
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    sleep   10
    Execute Interactive Remote Command      command=${exit}     alias=secondary
    Execute Interactive Remote Command      command=${copy_bbmodRL5b_to_board}    alias=secondary
    Execute Interactive Remote Command      command=${pwd}    alias=secondary
    Execute Interactive Remote Command      command=${copy_board_to_vm}    alias=secondary
    Execute Interactive Remote Command      command=${vm_password}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${copy_sec_to_pri_vm}    alias=secondary


    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_bbmod_RL5b_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Analyse Pcap        pcap_filename=${pcap_file_location2}        analysis=${verify_mplane_dscp_pcp_AWHQN_as_src_mod}
    ...       filter_file_name=${traffic_filter_file_name}      alias=secondary
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${remove_pcap}      alias=secondary

    Log     CU PCP modification with BTS reset
    Perform Recommissioning    type=delta    delta_file=${cupcp_mod}        timeout=300
    Sleep  300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log     RF module verification
    Execute Interactive Remote Command      command=${fronthaul_login_sec}    alias=secondary
    Execute Interactive Remote Command      command=ssh -o StrictHostKeyChecking=no serviceuser@${soaprp1}    alias=secondary
    Execute Interactive Remote Command      command=${Radio1_password_awhqn}    alias=secondary
    Execute Interactive Remote Command      command=${root_login}    alias=secondary

    Log    Default C/U plane PCP value verification on Radio module
    ${cupcp}=     Execute Interactive Remote Command      command=${cupcp_rmod}    alias=secondary
    ${cupcp_value}=     Get Line    ${cupcp}   3
    Should Match    ${cupcp_pcp_mod}    ${cupcp_value}
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondary
    Execute Interactive Remote Command      command=${exit}    alias=secondarym
