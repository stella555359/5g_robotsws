*** Settings ***
Documentation    This Contains the Basic generic Keywords used for all the Features.

Library        taf.sbts.oam.coam.admin      WITH NAME    admin
Resource       configuration_id.robot
Variables      ${CURDIR}/../PythonLib/UTILS.py


*** Variables ***
${WTS_WORKING_DIR}             /opt/iphy/latest
${LOG_DIR}      /home/ute/logs
${GNB_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USERNAME}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASSWORD}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}


*** Keywords ***
Perform SCF Delta Commissioning With Delta File
    [Documentation]    Perform SCF Delta Commissioning With delta_commissioning_file_json
    [Arguments]     ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Perform Reset With Delta File
    [Documentation]    Perform Reset With Delta File
    [Arguments]     ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning And Wait For Reset   scfc_filename=${delta_commissioning_file_json}

Perform GNB Delta Commissioning
    [Documentation]    Perform GNB Delta Commissioning
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup Admin
    admin.Perform Delta Recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}       timeout=${timeout}
    [Teardown]    admin.Teardown Admin

Create Basic Interface On UTE
    [Documentation]    Create Basic Interface On UTE
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
    Run    sudo ip addr add 10.0.1.101/24 dev eth3
    Run    sudo ip addr add 10.0.1.102/24 dev eth3
    Run    sudo ip addr add 10.0.1.160/24 dev eth3
    Run    sudo ip addr add 10.0.1.161/24 dev eth3

Delete Basic Interface On UTE
    [Documentation]    Delete Basic Interface On UTE
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

GNB Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the gNB
    ssh.Connect To      ${GNB_IP}   ${GNB_USERNAME}     ${GNB_PASSWORD}     alias=gnb_coam
    ssh.Execute     command=reboot      connection=gnb_coam
    [Teardown]      ssh.Disconnect      connection=gnb_coam

Enable Internal TG
    [Documentation]    Enable Internal TG
    [Arguments]     ${UE_ID}    ${Pdu_session_ID}
    wtsrunner.Set Pdu Param     ue=${UE_ID}     pdu=${Pdu_session_ID}      trf_type=internal

Update UE Capability Online
    [Documentation]    Update UE capability Online
    [Arguments]    ${ueid}=1
    wtsrunner.UE Param      id=${ueid}      ue_nr_capabilities=${ue_cap}

Stop Log Collection
    [Documentation]    Stop Log Collection
    Collect Logs For Run

Start PCAP On WTS
    [Documentation]     This KW shall help start pcap capture on WTS. Argument passed will be the name of the pcap file.
    [Arguments]     ${test_case_name}
    Run             sudo tcpdump -i any -w ${test_case_name}.pcap > /dev/null 2>&1 &
    ${get_Pid}      Run    sudo pgrep tcpdump
    ${close_session}    Run     disown --help
    [Return]        ${get_Pid}

Stop PCAP On WTS
    [Documentation]    This KW shall help stop pcap on WTS
    [Arguments]        ${get_Pid}
    Run                sudo kill -9 ${get_Pid}

Collect Logs For The Test
    [Documentation]    Collect Logs For The Test
    [Arguments]     ${Log_Path}
    Run           /${WTS_WORKING_DIR}/sosReport.sh -nr -c -s
    Run           cp Sos*.tgz ${Log_Path}
    Run           ls ${Log_Path}/SosReport*.tgz

Create Log Directory
    [Documentation]    Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${LOG_PATH}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    Set Test Variable       ${LOG_PATH}
    [Return]    ${LOG_PATH}

Updated Suite Setup
    [Documentation]    Updated Suite Setup
    RAT Block Unblock
    Common Optimized Suite Setup
    Create Basic Interface On UTE

RAT Block Unblock
    [Documentation]    RAT Block Unblock
    admin.Setup Admin
    admin.Block Rat     NR
    admin.Unblock Rat   NR
    admin.Teardown Admin

Snapshot Collection
    [Documentation]     This keyword is used to collect Snapshot
    [Arguments]     ${logDir}     ${file}=Snapshot.zip
    admin.Setup Admin
    admin.Collect Snapshot      ${logDir}/${file}
    [Teardown]      admin.Teardown Admin
