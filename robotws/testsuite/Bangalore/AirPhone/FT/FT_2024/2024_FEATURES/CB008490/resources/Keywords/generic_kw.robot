*** Settings ***
Documentation   This file contains keywords which are generic functions common to all features.

Library    ute_wtssim
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
#Library    taf.sw.scout    WITH NAME     scout
Resource    configuration_id.robot
Variables      ../PythonLib/UTILS.py


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
    Run    sudo ip addr add 10.0.1.8/24 dev eth3
    Run    sudo ip addr add 10.0.1.9/24 dev eth3
    Run    sudo ip addr add 10.0.1.10/24 dev eth3

Delete Basic Interface on UTE
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
    Run    sudo ip addr del 10.0.1.8/24 dev eth3
    Run    sudo ip addr del 10.0.1.9/24 dev eth3
    Run    sudo ip addr del 10.0.1.10/24 dev eth3


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
    Run           chmod 777 ${WTS_WORKING_DIR}/sosReport_ASIL/sosReport_ASIL.sh
    Run           ${WTS_WORKING_DIR}/sosReport_ASIL/sosReport_ASIL.sh -nr -c -s
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
