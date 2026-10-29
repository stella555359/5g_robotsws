*** Settings ***
Documentation    author: Deng xueqin
...              Group: HGZ_SG7
...              contact: xueqin.deng@nokia-sbell.com
...              Description

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../common/robot/ecpri_transport_common_keyword.robot

*** Variables ***
${du_ip}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${du_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${du_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${remote_log_path}    /ffs/run/logs/fhnet.pcap
${local_log_path}    ${output_dir}/fhnet.pcap


*** Keywords ***
Get actEcpriRuMPlaneSecurity value
    [Documentation]  Author: Deng xueqin
    ...              Description: get actEcpriRuMPlaneSecurity parameter value
    ${actEcpriRuMPlaneSecurity}    selenium_coam.get_parameter_value
    ...    dist_name=FEATCADM-1
    ...    abbr=actEcpriRuMPlaneSecurity
    ...    filter_param=Activate eCPRI RU M-Plane security
    [Return]    ${actEcpriRuMPlaneSecurity}

Set actEcpriRuMPlaneSecurity value
    [Documentation]  Author: Deng xueqin
    ...              Description: set actEcpriRuMPlaneSecurity parameter value
    [Arguments]    ${act_ipsec_value}
    selenium_coam.set_parameter_value
    ...    dist_name=FEATCADM-1
    ...    abbr=actEcpriRuMPlaneSecurity
    ...    new_value=${act_ipsec_value}
    ...    filter_param=Activate eCPRI RU M-Plane security
    sleep    1s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Set IPSec Optional
    [Arguments]    ${plain_allowed_value}    ${MRBTS-ID}
    selenium_coam.set_parameter_value
    ...    dist_name=FEATCADM-1
    ...    abbr=actEcpriRuMPlaneSecurity
    ...    new_value=RuProtectOptional
    ...    filter_param=Activate eCPRI RU M-Plane security
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS-ID}/EQM-1/APEQM-1/RMOD-1
    ...    abbr=plainTextConnectionAllowed
    ...    new_value=${plain_allowed_value}
    ...    filter_param=Plain text connection allowed
    sleep    1s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=30

Check RU resetted
    Connect to gnb coam via ssl
    RU Should Be Offline
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Capture log on fhnet
    ssh.Connect to     hostname=${du_ip}    username=${du_username}    password=${du_password}    alias=DU
    ssh.send_command    command=lxc-attach -n 0x1018 -- tcpdump -i any -w ${remote_log_path} &    connection=DU

Stop capture log and download
    ssh.send_command    command=lxc-attach -n 0x1018 -- killall -2 tcpdump     connection=DU
    ssh.download_file   remote_path=${remote_log_path}   local_path=${local_log_path}    connection=DU
    ssh.send_command    command=lxc-attach -n 0x1018 -- rm ${remote_log_path}   connection=DU
    [Teardown]    ssh.disconnect    connection=DU

Check disable IPSec from WebEM
    Set actEcpriRuMPlaneSecurity value    act_ipsec_value=RuProtectDisabled
    Wait until keyword succeeds    5 min    10 sec
    ...    Check RU resetted
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Check IPSec not established
    
Check enable IPSec from WebEM
    Set actEcpriRuMPlaneSecurity value    act_ipsec_value=RuProtectEnabled
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login

Get IPSec status
    [Arguments]    ${connection}=DU
    ssh.send_command    command=lxc-attach -n 0x1018 -- ipsec statusall     connection=${connection}
    sleep    3s
    ${ipsec_status}    ssh.read output    connection=${connection}
    [Return]    ${ipsec_status}

Get rlan0 ecpri ip
    [Arguments]    ${connection}=DU
    ssh.send_command
    ...    command=lxc-attach -n 0x1018 -- ip a |grep rlan0.ecpri | awk -F "[ /]+" 'NR==2{print $3}'
    ...    connection=${connection}
    sleep    3s
    ${rlan0_ecpri_ip_tmp}    ssh.read output    connection=${connection}
    ${rlan0_ecpri_ip}    Replace String    ${rlan0_ecpri_ip_tmp}   \n   ${EMPTY}
    [Return]    ${rlan0_ecpri_ip}

Check IPSec established
    ssh.Connect to     hostname=${du_ip}    username=${du_username}    password=${du_password}    alias=DU
    ${ipsec_status}    Get IPSec status
    should match regexp    ${ipsec_status}    conn[0-99999]*\[[0-99999]*\]: ESTABLISHED
    should match regexp    ${ipsec_status}    conn[0-99999]*\{[0-99999]*\}:    ${rlan0_ecpri_ip}/32[udp] === ${ru_ip_addr}/32[udp]
    should match regexp    ${ipsec_status}    conn[0-99999]*\{[0-99999]*\}:    ${rlan0_ecpri_ip}/32[tcp] === ${ru_ip_addr}/32[tcp]
    [Teardown]    ssh.disconnect    connection=DU

Check IPSec not established
    ssh.Connect to     hostname=${du_ip}    username=${du_username}    password=${du_password}    alias=DU
    ${ipsec_status}    Get IPSec status
    should be empty    ${ipsec_status}
    [Teardown]    ssh.disconnect    connection=DU

Check IKE process from RU to DU 
    [Arguments]    ${pcap_file}    ${exchangetype}
    ${SA_2du_filter}    Catenate
    ...    ip.src==${ru_ip_addr} and ip.dst==${rlan0_ecpri_ip} and isakmp.exchangetype==${exchangetype}
    ${SA_2du_filtered}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${SA_2du_filter}
    ${SA_2du_flags}=    Get field value    packets=${SA_2du_filtered}    field_name=isakmp.flags
    should contain    ${SA_2du_flags}    0x08

Check IKE process from DU to RU
    [Arguments]    ${pcap_file}    ${exchangetype}
    ${SA_2ru_filter}    Catenate
    ...    ip.src==${rlan0_ecpri_ip} and ip.dst==${ru_ip_addr} and isakmp.exchangetype==${exchangetype}
    ${SA_2ru_filtered}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${SA_2ru_filter}
    ${SA_2ru_flags}=    Get field value    packets=${SA_2ru_filtered}    field_name=isakmp.flags
    should contain    ${SA_2ru_flags}    0x20

Check IKE process
    [Arguments]    ${pcap_file}
    Check IKE process from RU to DU    pcap_file=${pcap_file}    exchangetype=34
    Check IKE process from RU to DU    pcap_file=${pcap_file}    exchangetype=35
    Check IKE process from DU to RU    pcap_file=${pcap_file}    exchangetype=34
    Check IKE process from DU to RU    pcap_file=${pcap_file}    exchangetype=35
