*** Settings ***

Library    ute_wtssim
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
Library    taf.sw.scout    WITH NAME     scout
Variables      ../PythonLib/UTILS.py

Documentation   :copyright: Nokia
...             generic keywords

*** Variables ***
${WTS_WORKING_DIR}             /opt/iphy/latest
${LOG_DIR}      /home/ute/logs
${GNB_IP}       192.168.255.1
${GNB_USERNAME}     toor4nsn
${GNB_PASSWORD}     oZPS0POrRieRtu

*** Keywords ***
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Perform Reset with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning And Wait For Reset   scfc_filename=${delta_commissioning_file_json}

Perform gNB Delta Commissioning
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Create Basic Interface on UTE
    Run    sudo ip addr add 10.0.1.1/24 dev eth3
    Run    sudo ip addr add 10.0.1.200/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.112/24 dev eth3
    Run    sudo ip addr add 10.0.1.113/24 dev eth3
	Run    sudo ip addr add 10.0.1.3/24 dev eth3
	Run    sudo ip addr add 10.0.1.4/24 dev eth3

Delete Basic Interface on UTE
    Run    sudo ip addr del 10.0.1.1/24 dev eth3
    Run    sudo ip addr del 10.0.1.200/24 dev eth3
    Run    sudo ip addr del 10.0.1.131/24 dev eth3
    Run    sudo ip addr del 10.0.1.132/24 dev eth3
    Run    sudo ip addr del 10.0.1.133/24 dev eth3
    Run    sudo ip addr del 10.0.1.134/24 dev eth3
    Run    sudo ip addr del 10.0.1.135/24 dev eth3
    Run    sudo ip addr del 10.0.1.136/24 dev eth3
    Run    sudo ip addr del 10.0.1.137/24 dev eth3
    Run    sudo ip addr del 10.0.1.138/24 dev eth3
    Run    sudo ip addr del 10.0.1.112/24 dev eth3
    Run    sudo ip addr del 10.0.1.113/24 dev eth3
    Run    sudo ip addr del 10.0.1.3/24 dev eth3
    Run    sudo ip addr del 10.0.1.4/24 dev eth3

GNB Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the gNB
    ssh.Connect to      ${GNB_IP}   ${GNB_USERNAME}     ${GNB_PASSWORD}     alias=gnb_coam
    ssh.execute     command=reboot      connection=gnb_coam
    [Teardown]      ssh.disconnect      connection=gnb_coam

Enable Internal TG
    [Arguments]     ${UE_ID}    ${Pdu_session_ID}
    wtsrunner.set_pdu_param     ue=${UE_ID}     pdu=${Pdu_session_ID}      trf_type=internal

Update UE capability Online
    [Arguments]    ${ueid}=1
    wtsrunner.ue_param      id=${UE_ID}      ue_nr_capabilities=${ue_cap}

Stop Log Collection
    Collect Logs For Run

Start PCAP on WTS
    [Documentation]     This KW shall help start pcap capture on WTS. Argument passed will be the name of the pcap file.
    [Arguments]     ${test_case_name}
    Run             sudo tcpdump -i any -w ${test_case_name}.pcap > /dev/null 2>&1 &
    ${get_Pid}      Run    sudo pgrep tcpdump
    ${close_session}    Run     disown --help
    [Return]        ${get_Pid}

Stop PCAP on WTS
    [Documentation]    This KW shall help stop pcap on WTS
    [Arguments]        ${get_Pid}
    Run                sudo kill -9 ${get_Pid}

Collect Logs For The Test
    [Arguments]     ${Log_Path}
    Run           /${WTS_WORKING_DIR}/sosReport.sh -nr -c -s
    Run           cp Sos*.tgz ${Log_Path}
    Run           ls ${Log_Path}/SosReport*.tgz

Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${Log_Path}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    set test variable       ${Log_Path}
    [Return]    ${Log_Path}

Updated Suite Setup
    RAT Block Unblock
    Common Optimized Suite Setup
    Create Basic Interface on UTE

RAT Block Unblock
    admin.Setup admin
    admin.block_rat     NR
    admin.unblock_rat   NR
    admin.Teardown admin

Get Eth0 IP Address
    [Documentation]     This KW will help to derive the VM ip from eth0 i/f
    ${ip_output}=    Run    sudo ip addr show eth0
    ${ip}=    Get IP Address From Output    ${ip_output}
    [Return]    ${ip}

Get IP Address From Output
    [Documentation]     Called by Eth0 KW to derive the ip
    [Arguments]    ${output}
    ${ip}=    Set Variable    ${EMPTY}
    :FOR    ${line}    IN    @{output.splitlines()}
    \    ${ip_match}=    Get Regexp Matches    ${line}    \\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b
    \    Exit For Loop If    ${ip_match}
    [Return]    ${ip_match}[0]

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]      ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}
