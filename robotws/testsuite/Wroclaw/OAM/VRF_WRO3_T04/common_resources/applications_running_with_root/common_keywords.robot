*** Settings ***
Documentation    Port scanning testing

Library          Process
Library          OperatingSystem
Library          ./common_functions.py
Library          ./NmapOperations.py  WITH NAME  nmap
Resource         ../admin/admin.robot

*** Keywords ***
Execute Nmap And Divide
    [Arguments]    ${plane}  ${version_ip}  ${protocol}  ${divide}
    &{targets}=  CREATE DICTIONARY
    ...          LMPIPv4=${SSH_IP}
    ...          LMPIPv6=${SSH_IP}
    ...          Management planeIPv4=${MPLANE_IPV4}
    ...          Management planeIPv6=${MPLANE_IPV6}
    ...          Control planeIPv4=${X2C}
    ...          Control planeIPv6=${X2C_V6}
    ...          User planeIPv4=${X2U}
    ...          User planeS1IPv4=${S1U}
    ...          User planeIPv6=${X2U_V6}
    ...          User planeS1IPv6=${S1U_V6}
    ...          Synchronization planeIPv4=${XNU}
    ...          Synchronization planeIPv6=${XNU_V6}
    ...          Control SA planeIPv4=${XNC}
    ...          Control SA planeIPv6=${XNC_V6}
    ...          NG-UIPv4=${X2U}
    ...          NG-UIPv6=${X2U_V6}
    ...          NG-CIPv4=${X2C}
    ...          NG-CIPv6=${X2C_V6}

    Run Keyword If  "${protocol}" in ["SCTPcookie", "TCPmai"]
    ...   nmap.run_divided_nmap_scan_parallel  ${plane}${version_ip}${protocol}  ${targets["${plane}${version_ip}"]}
    ...   ${protocol}                          ${divide}                         ${OUTPUT DIR}
    Run Keyword If  "${protocol}" != "SCTPcookie" and "${protocol}" != "TCPmai"
    ...   nmap.run_divided_nmap_scan  ${plane}${version_ip}${protocol}  ${targets["${plane}${version_ip}"]}
    ...   ${protocol}                 ${divide}                         ${OUTPUT DIR}
    ${open_ports}=       nmap.get_open_ports_from_nmap_output
    ${network_element}=  Set Variable     classical
    ${network_element}=  Set Variable If  "DU" in "${plane}"  du  ${network_element}
    ${network_element}=  Set Variable If  "CU" in "${plane}"  cu  ${network_element}
    Log To Console       network_element=${network_element}
    ${wrong_ports}=      nmap.get ports with wrong behavior  open_ports=${open_ports}
    ...                                                      plane=${plane}
    ...                                                      protocol=${protocol}

    [Teardown]  nmap.teardown
    [Return]    @{open_ports}[${0}]

Execute Nmap And Divide On Cloud
    [Arguments]   ${plane}  ${version_ip}  ${protocol}  ${divide}
    ${splane_temporary}=  get_cloud_ip_splane
    &{targets}=  CREATE DICTIONARY
    ...          LMPDUIPv4=${LMPDUIPv4}
    ...          SplaneDUIPv4=${splane_temporary}
    ...          F1-CDUIPv4=${F1-CDUIPv4}
    ...          F1-MDUIPv4=${F1-MDUIPv4}
    ...          F1-UDUIPv4=${F1-UDUIPv4}

    Run Keyword If  "${protocol}" in ["SCTPcookie", "TCPmai"]
    ...   nmap.run_divided_nmap_scan_parallel  ${plane}${version_ip}${protocol}  ${targets["${plane}${version_ip}"]}
    ...   ${protocol}                          ${divide}                         ${OUTPUT DIR}
    Run Keyword If  "${protocol}" != "SCTPcookie" and "${protocol}" != "TCPmai"
    ...   nmap.run_divided_nmap_scan  ${plane}${version_ip}${protocol}  ${targets["${plane}${version_ip}"]}
    ...   ${protocol}                 ${divide}                         ${OUTPUT DIR}
    ${open_ports}=       nmap.get_open_ports_from_nmap_output
    ${network_element}=  Set Variable     classical
    ${network_element}=  Set Variable If  "DU" in "${plane}"  du  ${network_element}
    ${network_element}=  Set Variable If  "CU" in "${plane}"  cu  ${network_element}
    Log To Console   network_element=${network_element}
    ${wrong_ports}=  nmap.get ports with wrong behavior     open_ports=${open_ports}
    ...                                                     plane=${plane}
    ...                                                     protocol=${protocol}

    [Teardown]  nmap.teardown
    [Return]    ${open_ports}[${0}]

Change Ethernet Port Security Enabled To True CLASSICAL
    ${connection}=                      Connect to ADMIN  192.168.255.129
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                 param_name=ethernetPortSecurityEnabled
    ...                                 param_value=true
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Copy Report Txt File To Output Directory
    ${path_report_txt_file}=  get_path_to_report_file
    Operating System.Copy File  ${path_report_txt_file}  ${OUTPUT_DIR}
