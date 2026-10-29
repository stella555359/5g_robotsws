*** Settings ***
Documentation  Applications running with root privileges-hardening improvement
...            author: Krzysztof Kordecki

Library        ../../../common_resources/applications_running_with_root/common_functions.py
Resource       ../../../common_resources/applications_running_with_root/common_keywords.robot
Resource       ../Resources/6048_Keywords.robot

*** Keywords ***
CB006048_Classical
    [Arguments]    ${plane_classical}
    add_heading_to_file  ${plane_classical}
    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv4  TCP  100
    get_root_opened_processes_on_ports  ${ports}  TCP

    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv4  UDP  100
    get_root_opened_processes_on_ports  ${ports}  UDP

    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv4  SCTP  100
    get_root_opened_processes_on_ports  ${ports}  SCTP

    add_heading_to_file  ${plane_classical}
    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv6  TCP  100
    get_root_opened_processes_on_ports  ${ports}  TCP

    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv6  UDP  100
    get_root_opened_processes_on_ports  ${ports}  UDP

    ${ports}=  Execute Nmap And Divide  ${plane_classical}  IPv6  SCTP  100
    get_root_opened_processes_on_ports  ${ports}  SCTP

CB006048_Cloud
    [Arguments]    ${plane_cloud}  ${version_IP}
    add_heading_to_file  ${plane_cloud}_${version_ip}
    ${ports}=  Execute Nmap And Divide On Cloud  ${plane_cloud}  ${version_IP}  TCP  100
    Sleep  120s
    get_root_opened_processes_on_ports  ${ports}  TCP

    ${ports}=  Execute Nmap And Divide On Cloud  ${plane_cloud}  ${version_IP}  UDP  100
    Sleep  120s
    get_root_opened_processes_on_ports  ${ports}  UDP

    ${ports}=  Execute Nmap And Divide On Cloud  ${plane_cloud}  ${version_IP}  SCTP  100
    Sleep  120s
    get_root_opened_processes_on_ports  ${ports}  SCTP

CB006048_All_Interfaces_TCP
    Compare Root And Btssw Processes List
#    compare_root_and_btssw_processes_list

CB006048_All_Interfaces_UDP_SCTP
    Compare Root And Btssw Processes List
#    compare_root_and_btssw_processes_list
