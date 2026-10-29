*** Settings ***
Documentation
...     [Author]        "Priyanka"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Suite Setup       Setup Oamops
Suite Teardown     Teardown Oamops

Library         OperatingSystem
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Common_LTE4623_Operations.robot
Resource        ${CURDIR}/../resources/Common_LTE4727_Operations.robot

***Variables***
${Delta_file}       /home/ute/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/config/1/delta_files/256_supervised_ipv4_sgw.xml

*** Test Cases ***
[1.0] TRS_SR002672_RP002096_Airscale_TRS_RP002096_Verification_of_Ingress_Rate_limiting_GTP_U
#    Perform dualstack Configuration        ${Perform_Vlan_configuration_dualstack}
    Sleep       120
	Run		sudo ifconfig eth3 inet6 add fc00::1
#    Perform Recommissioning     type=delta       delta_file=${Delta_file}        skip_parameter_relation_errors=${True}      timeout=300
#    Sleep   120
    Perform Parameter Commissioning      MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1:ipSecEnabled:update:false
    Perform Parameter Commissioning        MRBTS-1/LNBTS-1/LNMME-0:administrativeState:update:locked
    Create and Bring Logical Interfaces UP IPV6         ${Supervised_sgw_ipaddress_ipv6}     ${Supervised_sgw_interface_ipv6all}
    Create and Bring Logical Interfaces UP IPV4         ${Supervised_sgw_ipaddress_ipv4}     ${Supervised_sgw_interface_all}
    Traffic Capture Start   capture_device=vm_eth3_interface        alias=gtp
#    Call Setup  lte=128_dualstack_sgw_ue_simulator:data		selected_plmn=244:09	parallel=${False}  attach=${false}  verify_attach=${false}
    Sleep       30
    Perform Parameter Commissioning        MRBTS-1/LNBTS-1/LNMME-0:administrativeState:update:unlocked
    Sleep   300
    ${file}=        Traffic Capture Stop        alias=gtp
    Wireshark verification for IPV4     ${Supervised_sgw_ipaddress_ipv4}     ${Supervised_sgw_interface}     ${file}
	Install scapy
	Traffic Capture Start   capture_device=vm_eth3_interface        alias=gtp_unsupervised
    Send GTPU Echo Request     ${Unsupervised_sgw_ipaddress}/22    ${Enb1_Ip}    2152    2152    GTP    1   ${GTP_Expect_Script}
	${file2}=        Traffic Capture Stop        alias=gtp_unsupervised
    Verify Wireshark Messages of IPv4 Address       ${file2}        gtp       ${Unsupervised_sgw}      ${Enb1_Ip}      ${Unsupervised_sgw_ipaddress}

***Keywords***
Perform dualstack Configuration
    [Arguments]     ${Comm_file}
    Run     sudo sed -i "s/{{vlan_id_1}}/@{tl.vlan_ids}[0]/g" ${scf_dir}/${Comm_file}
    Run     sudo sed -i "s/{{vlan_id_2}}/@{tl.vlan_ids}[1]/g" ${scf_dir}/${Comm_file}
    Run     sudo sed -i "s/{{vlan_id_3}}/@{tl.vlan_ids}[2]/g" ${scf_dir}/${Comm_file}
    Run     sudo sed -i "s/{{vlan_id_4}}/@{tl.vlan_ids}[3]/g" ${scf_dir}/${Comm_file}
    Perform Commissioning       scf_file=${Comm_file}       verify_bts_status=False
    Sleep   180
    Configure Certificate in Admin      ${Ipsec_Cert_file}      BtsTrustChain       P12     ${Ipsec_Cert_password}
    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
    Run        sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.@{tl.vlan_ids}[0]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
    Run        sudo ip addr add 10.0.3.213/30 brd 10.0.3.215 dev eth3.@{tl.vlan_ids}[1]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
    Run        sudo ip addr add 10.0.3.217/30 brd 10.0.3.219 dev eth3.@{tl.vlan_ids}[2]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
    Run        sudo ip addr add 10.0.3.221/30 brd 10.0.3.223 dev eth3.@{tl.vlan_ids}[3]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up
    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[0] type vlan id @{tl.vlan_ids}[0]
    Run        sudo ip -6 addr add fc00::3:6/126 dev eth3.@{tl.vlan_ids}[0]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[0] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[1] type vlan id @{tl.vlan_ids}[1]
    Run        sudo ip -6 addr add fc00::3:a/126 dev eth3.@{tl.vlan_ids}[1]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[1] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[2] type vlan id @{tl.vlan_ids}[2]
    Run        sudo ip -6 addr add fc00::3:e/126 dev eth3.@{tl.vlan_ids}[2]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[2] up

    Run        sudo ip link add link eth3 name eth3.@{tl.vlan_ids}[3] type vlan id @{tl.vlan_ids}[3]
    Run        sudo ip -6 addr add fc00::3:19/126 dev eth3.@{tl.vlan_ids}[3]
    Run        sudo ip link set dev eth3.@{tl.vlan_ids}[3] up

Install scapy

    Run    pip install scapy

Send GTPU Echo Request
    [Arguments]     ${sgw_addr}    ${Destination_IP}       ${Source_port}      ${Destination_port}     ${protocol}     ${count}     ${expect_Script}
    Run             sudo expect ${expect_Script} ${sgw_addr} ${Destination_IP} ${Source_port} ${Destination_port} ${protocol} ${count}
Download Alarm File from eNB
#    Setup Admin     bts_host=192.168.255.129    bts_port=443    use_ssl=True
    ${alarms}=      Get Active Alarms
    Set Suite Variable      ${Active_alarms}        ${alarms}
    @{SEM_alarms}=      Create List
    ${Dict}=    Create Dictionary
    ${len}=     Get Length      ${alarms}
    FOR    ${i}    IN RANGE    0   ${len}
           Log Dictionary      @{alarms}[${i}]
           ${val}=     Get From Dictionary     @{alarms}[${i}]     faultName
           Append To List      ${SEM_alarms}       ${val}
           Set To Dictionary   ${Dict}     ${i}    ${val}
    END

    Set Suite Variable      ${SEM_alarms}       ${SEM_alarms}
    Set Suite Variable      ${Dict}     ${Dict}
#    [Teardown]     Teardown Admin

Delete Logical Interfaces
    Run     sudo ifconfig eth3 down
    Sleep      60

