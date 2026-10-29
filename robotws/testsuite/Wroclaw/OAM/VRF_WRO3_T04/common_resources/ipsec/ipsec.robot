*** Settings ***
Documentation
...  IPSEC documentation

Resource    ../admin/admin.robot
Resource    ../ip_traffic/ip_traffic.robot
Resource    ../ssh/ssh_operations.robot
Resource    ../commissioning/commissioning.robot
Resource    ../commissioning/parameters.robot
Resource    ../mantaray/mantaray.robot
Resource    ../certificates/certificates.robot

Library     taf.transport.ssh        WITH NAME    ssh
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library     taf.nms.netact    WITH NAME    netact
Library     OperatingSystem    WITH NAME    operating_system

*** Variables ***
${templete_name}    IPSEC-create.xml
${plan_name}        MRBTS-${BTS_ID}_IPSECC_create

*** Keywords ***
Firewall_actMplaneFronthaulFirewall_true
    [Arguments]    ${bts_host}=192.168.255.129
    ${ipsec_admin_connection}=  Connect To ADMIN    ip_address=${bts_host}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actMplaneFronthaulFirewall
    ...                        param_value=true
    ...                        connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    Wait Until Keyword Succeeds    12x    2min      Check if BTS in given state
    ...                                             state=OnAir
    ...                                             connection=${ipsec_admin_connection}
    Get nft List Ruleset Output To File And Download It  bts_host=${bts_host}
    [Teardown]    Run Keywords  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                         param_name=actMplaneFronthaulFirewall
    ...                         param_value=false
    ...                         skip_parameter_relation_errors=${TRUE}
    ...                         connection=${ipsec_admin_connection}  AND
    ...                         Wait Until Keyword Succeeds    12x    2min      Check if BTS in given state
    ...                         state=OnAir
    ...                         connection=${ipsec_admin_connection}  AND
    ...                         Disconnect From ADMIN    connection=${ipsec_admin_connection}

IPSEC_actEcpriRuMPlaneSecurity_RuProtectEnabled
    [Arguments]    ${bts_host}=192.168.255.129
    ${ipsec_admin_connection}=  Connect To ADMIN    ip_address=${bts_host}
    Start Tcpdump On FHNET via SSH    bts_host=${bts_host}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actEcpriRuMPlaneSecurity
    ...                        param_value=RuProtectEnabled
    ...                        connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    Wait Until RU Will Automatically Reboot    connection=${ipsec_admin_connection}    bts_host=${bts_host}
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH    bts_host=${bts_host}
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}    bts_host=${bts_host}
    ${node}=    Get NodeId For Your Airscale    ${bts_host}
    Wait Until Keyword Succeeds    10x    1min    Check IPSec Tunnels    ${node}    ip=${bts_host}
    Wait Until Keyword Succeeds    12x    2min    Check if BTS in given state    state=OnAir    connection=${ipsec_admin_connection}
    ESP Packets Should Be Present On BTS    ${node}    bts_host=${bts_host}
    [Teardown]    Run Keywords    Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actEcpriRuMPlaneSecurity
    ...                           param_value=RuProtectDisabled
    ...                           skip_parameter_relation_errors=${TRUE}
    ...                           connection=${ipsec_admin_connection}    AND
    ...                           Disconnect From ADMIN    connection=${ipsec_admin_connection}

IPSEC_actEcpriRuMPlaneSecurity_RuProtectOptional_plainTextConnectionAllowed_true
    [Arguments]    ${bts_host}=192.168.255.129
    ${ipsec_admin_connection}=  Connect To ADMIN    ip_address=${bts_host}
    Start Tcpdump On FHNET via SSH    bts_host=${bts_host}
    ${delta}=    Prepare Delta With Plain Text    ${BTS_ID}   true    ${bts_host}
    Recommission Parameters By Delta    delta=${delta}    connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    Wait Until RU Will Automatically Reboot    connection=${ipsec_admin_connection}    bts_host=${bts_host}
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH    bts_host=${bts_host}
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}    bts_host=${bts_host}
    ${node}=    Get NodeId For Your Airscale    ${bts_host}
    Wait Until Keyword Succeeds    10x    1min    Check IPSec Tunnels    ${node}    ip=${bts_host}
    Wait Until Keyword Succeeds    12x    2min    Check if BTS in given state    state=OnAir    connection=${ipsec_admin_connection}
    ESP Packets Should Be Present On BTS    ${node}    bts_host=${bts_host}
    [Teardown]    Run Keywords    Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actEcpriRuMPlaneSecurity
    ...                           param_value=RuProtectDisabled
    ...                           skip_parameter_relation_errors=${TRUE}
    ...                           connection=${ipsec_admin_connection}   AND
    ...                           Disconnect From ADMIN    connection=${ipsec_admin_connection}

IPSEC_actEcpriRuMPlaneSecurity_RuProtectOptional_plainTextConnectionAllowed_false
    [Arguments]    ${bts_host}=192.168.255.129
    ${ipsec_admin_connection}=  Connect To ADMIN    ip_address=${bts_host}
    Start Tcpdump On FHNET via SSH    bts_host=${bts_host}
    ${delta}=    Prepare Delta With Plain Text    ${BTS_ID}     false    ${bts_host}
    Recommission Parameters By Delta    delta=${delta}    connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    Wait Until RU Will Automatically Reboot    connection=${ipsec_admin_connection}    bts_host=${bts_host}
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH    bts_host=${bts_host}
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}    bts_host=${bts_host}
    ${node}=    Get NodeId For Your Airscale    ${bts_host}
    Wait Until Keyword Succeeds    10x    1min    Check IPSec Tunnels    ${node}    ip=${bts_host}
    Wait Until Keyword Succeeds    12x    2min    Check if BTS in given state    state=OnAir    connection=${ipsec_admin_connection}
    ESP Packets Should Be Present On BTS    ${node}    bts_host=${bts_host}
    [Teardown]    Run Keywords    Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actEcpriRuMPlaneSecurity
    ...                           param_value=RuProtectDisabled
    ...                           skip_parameter_relation_errors=${TRUE}
    ...                           connection=${ipsec_admin_connection}   AND
    ...                           Disconnect From ADMIN    connection=${ipsec_admin_connection}

IPSEC_toggle_Enabled_to_RuProtectOptional_plainTextConnectionAllowed_true
    [Arguments]    ${bts_host}=192.168.255.129
    ${ipsec_admin_connection}=  Connect To ADMIN    ip_address=${bts_host}
    Start Tcpdump On FHNET via SSH    bts_host=${bts_host}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actEcpriRuMPlaneSecurity
    ...                        param_value=RuProtectEnabled
    ...                        connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    ${delta}=    Prepare Delta With Plain Text    ${BTS_ID}     false    ${bts_host}
    Recommission Parameters By Delta    delta=${delta}    connection=${ipsec_admin_connection}
    ...                        skip_parameter_relation_errors=${TRUE}
    Wait Until RU Will Automatically Reboot    connection=${ipsec_admin_connection}    bts_host=${bts_host}
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH    bts_host=${bts_host}
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}    bts_host=${bts_host}
    ${node}=    Get NodeId For Your Airscale    ${bts_host}
    Wait Until Keyword Succeeds    10x    1min    Check IPSec Tunnels    ${node}    ip=${bts_host}
    Wait Until Keyword Succeeds    12x    2min    Check if BTS in given state    state=OnAir    connection=${ipsec_admin_connection}
    ESP Packets Should Be Present On BTS    ${node}    bts_host=${bts_host}
    [Teardown]    Run Keywords    Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actEcpriRuMPlaneSecurity
    ...                           param_value=RuProtectDisabled
    ...                           skip_parameter_relation_errors=${TRUE}
    ...                           connection=${ipsec_admin_connection}   AND
    ...                           Disconnect From ADMIN    connection=${ipsec_admin_connection}

ISAKMP Packets Should Be Present On BTS
    [Arguments]    ${pcap_file}    ${bts_host}=${LMP_IP}
    ssh.Connect to    hostname=${bts_host}
    ...               username=${ROOT_USERNAME}
    ...               password=${ROOT_PASSWORD}
    ...               alias=bts_connection
    ${radio_ips}=      Get IP Address For All RUs    bts_host=${bts_host}
    FOR   ${radio_ip}    IN    @{radio_ips}
        ${output}=    Run  tshark -r ${pcap_file} -Y 'ip.src==${radio_ip} && isakmp.exchangetype == 34'
        Should Contain    ${output}    IKE_SA_INIT
    END
    [Teardown]    ssh.Disconnect    connection=bts_connection

ESP Packets Should Be Present On BTS
    [Arguments]    ${node}    ${bts_host}=${LMP_IP}
    ssh.Connect to    hostname=${bts_host}
    ...               username=${ROOT_USERNAME}
    ...               password=${ROOT_PASSWORD}
    ...               alias=bts_connection
    ${response}=      ssh.Execute    command=lxc-attach -n ${node} -- timeout -s 9 90s tcpdump -i rlan0
    ...                              connection=bts_connection
    Should Contain    ${response}    ESP
    [Teardown]    ssh.Disconnect     connection=bts_connection

Get nft List Ruleset Output To File And Download It
    [Arguments]    ${bts_host}=${LMP_IP}
    Get nft List Ruleset Output To File  bts_host=${bts_host}
    Download nft List Ruleset Output File  bts_host=${bts_host}

Get nft List Ruleset Output To File
    [Arguments]    ${bts_host}=${LMP_IP}
    ${ssh_connection}=    Connect to BTS  ip_address=${bts_host}
    SSH.Execute     command=nft list ruleset > /user/toor4nsn/nft_list_ruleset.txt    connection=${ssh_connection}
    [Teardown]    Disconnect from BTS  connection=${ssh_connection}

Download nft List Ruleset Output File
    [Documentation]    The file is downloaded from SMOD to VM so that it can be placed in the log folder.
    ...                This file can be useful in troubleshooting while maintenance the test in regression.
    [Arguments]    ${bts_host}=${LMP_IP}
    Run    sshpass -p "oZPS0POrRieRtu" scp toor4nsn@${bts_host}:/user/toor4nsn/nft_list_ruleset.txt ${EXECDIR}/nft_list_ruleset.txt

_Provision Full IPSEC Object
    [Documentation]    Provision full IPSEC object
    [Arguments]    ${lab_ip}    ${lab_username}=omc    ${lab_password}=Medsql!_1893
    _Prepare Plan For Provisioning
    netact.Add Node    service_name=cmwas    hostname=${lab_ip}   username=${lab_username}   password=${lab_password}
    netact.Import Configuration    local_dir=${TEST_OUTPUT_DIR}/Plans/    file_name=${templete_name}    plan_name=${plan_name}
    netact.Provision Plan     plan_name=${plan_name}
    [Teardown]
    netact.Delete Plan    plan_name=${plan_name}
    netact.Delete Node    cmwas

_IPSEC Infomodel Getter
    [Documentation]    Get needed information for IPSEC from infomodel and init file
    [Arguments]    ${APP_IP}=10.44.47.30    ${IPSEC_GW}=10.42.131.99
    ${trsnw_dictionary}=    Run Keyword With ADMIN Connection    coam_admin.Get Parameter By Class    TRSNW
    ${trsnw_string}=    Convert To String    ${trsnw_dictionary}
    ${trsnw_regex}=    Set Variable    (uPlane).*(ipV4AddressDN1).*(MRBTS-\\d*\/TNLSVC-\\d*\/TNL-\\d*\/IPNO-\\d*\/IPIF-\\d*\/IPADDRESSV4-\\d*)
    ${ipaddressv4_path}=    Evaluate    re.search(r'${trsnw_regex}', str(${trsnw_string})).group(3)
    ${ipaddressv4_dictionary}=    Run Keyword With ADMIN Connection    coam_admin.Get Parameter By Distname   ${ipaddressv4_path}
    ${ipaddressv4_string}=    Convert To String    ${ipaddressv4_dictionary}
    ${ipaddressv4_regex}=    Set Variable    (localIpAddr)\\W*(\\d*.\\d*.\\d*.\\d*)
    ${LTE_IP}=    Evaluate    re.search(r'${ipaddressv4_regex}', str(${ipaddressv4_string})).group(2)
    ${ip_dict}=    Run Keyword With ADMIN Connection    coam_admin.Get Parameter By Class    IPADDRESSV4
    ${IPADDRESS_PATH}=    Evaluate    [entry['distName'] for entry in ${ip_dict} if entry['parameters']['localIpAddr'] == '${MPLANE_IPV4}']
    &{IPSEC_parameters}=   Create Dictionary
    ...    {MRBTS-ID}=${BTS_ID}
    ...    {OAM-IP}=${MPLANE_IPV4}
    ...    {LTE-IP}=${LTE_IP}
    ...    {NGU-IP}=${NGU}
    ...    {NGC-IP}=${NGC}
    ...    {X2U-IP}=${X2U}
    ...    {X2C-IP}=${X2C}
    ...    {APP-IP}=${APP_IP}
    ...    {IPSEC-GW}=${IPSEC_GW}
    ...    {IPADDR-PATH}=${IPADDRESS_PATH}[0]
    [Return]    &{IPSEC_parameters}

_Prepare Plan For Provisioning
    [Documentation]    Prepare plan for IPSEC provisioning via MantaRay
    Copy File    ${CURDIR}/${templete_name}    ${TEST_OUTPUT_DIR}/Plans/${templete_name}
    &{IPSEC_parameters}=    _IPSEC Infomodel Getter
    ${file_content}=      operating_system.Get File  ${TEST_OUTPUT_DIR}/Plans/${templete_name}
    FOR    ${key}    ${value}    IN    &{IPSEC_parameters}
        ${value}=    Convert To String    ${value}
        ${file_content}=    Replace String     ${file_content}    ${key}    ${value}
    END
    Create File  ${TEST_OUTPUT_DIR}/Plans/${templete_name}  ${file_content}

Create IPSEC with MantaRay
    [Documentation]    Upload IPSEC with required MO using MantaRay
    [Arguments]    ${lab_ip}   ${lab_name}
    Turn Off TLS
    Integrate BTS to MantaRay without TLS    ${lab_ip}    ${lab_name}
    _Provision Full IPSEC Object    ${lab_ip}
    Deintegrate BTS from MantaRay    ${lab_name}
    Turn On TLS
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    mPlaneIpv4AddressDN
    ...    MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-99/IPADDRESSV4-1
    Change Parameter on BTS    MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1    ipSecEnabled    true
