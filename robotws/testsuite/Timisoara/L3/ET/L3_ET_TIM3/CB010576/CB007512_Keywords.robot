*** Settings ***
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/scripts/libraries_instances.robot
Resource     ../resources/admin.robot

Library      ta5g_throughput
Library      ta5g_bearers

*** Variables ***
${X2AP_SN_STATUS_TRANSFER}=    x2ap.SNStatusTransfer_element
${X2AP_SGNB_MODIFICATION_REQUEST_REJECT}=    x2ap.SgNBModificationRequestReject_element
${X2AP_SGNB_MODIFICATION_REQUEST}=    x2ap.SgNBModificationRequest_element
${WTS_DIR}               /opt/iphy/latest
${VM_ETH_IFACES}=    sudo ip addr add 10.0.1.131/24 dev eth3;
...  sudo ip addr add 10.0.1.132/24 dev eth3;
...  sudo ip addr add 10.0.1.133/24 dev eth3;
...  sudo ip addr add 10.0.1.134/24 dev eth3;
...  sudo ip addr add 10.0.1.135/24 dev eth3;
...  sudo ip addr add 10.0.1.136/24 dev eth3;
...  sudo ip addr add 10.0.1.137/24 dev eth3;
...  sudo ip addr add 10.0.1.121/24 dev eth3;
...  sudo ip addr add 10.0.1.3/24 dev eth3;
...  sudo ip addr add 10.0.1.4/24 dev eth3

*** Keywords ***

Reach Onair NSA
    [Arguments]    ${cfg_file}
    Start UTE WTS
    Run    ${VM_ETH_IFACES}
    Load Cfg File   ${cfg_file}
    Establish x2 link
    Wait for all cells to be enabled    timeout=600
    Check if BTS is On Air

Establish x2 link

    Execute egate command
    ...    cmd=enb_x2_link_up enb=1 target=2
    ...    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up

Load Cfg File
    [Arguments]    ${cfg_file}
    Log To Console    ${cfg_file}
    Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=CHANGE STATE: CONFIGURED    timeout=120
    sleep    30

Start UTE WTS
    [Documentation]    This keyword is to start edaemon, egate and clean log files.
    Log To Console    Starting WTS...
    Setup Edaemon    edaemon_port=10000    tool_dir=${WTS_DIR}    alias=edaemon
    Start Edaemon Process    alias=edaemon
    Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*

Activate CB007512 feature
     [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_enb_endc_param id=${ue_id} direct_bearer_sn_modification=on

Trigger SgNB Addition
    Start Gnb Addition Procedure    ue=11    target_cells=1    target_gnb=2    bearer=1,4    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA

Add Two Bearers
    Add Bearers To Ue    ue_id=11    bearers_params=id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Add Bearer    ue_id=11     pass_regexp=PGW-initiated Bearer Creation. Bearer-4 \\(EBI=6, QCI=6\\) created
    ...                        bearer_id=4    filter=1    precedence=1    by=pgw
    Trigger SgNB Addition
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}

Check if BTS is On Air
    ${bts_status}    Get current BTS state
    Should Be Equal     ${bts_status}    OnAir    ignore_case=True
