***Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Force Tags       CA_E2ET_BTSTRSPZ        SBTS00     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot
Resource       ${CURDIR}/../resources/Common_Traffic_Mirroring.robot

Suite Setup        Run Keywords    	Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

***Variable****
${sbh_filter_file}				   SBH_traffic_filter.json
${sbh_lock_filter_file}			   SBH_TWAMP_lock_traffic_filter.json
${counter_analysis_file_name}      SBH_counter_analysis.json
${pcap_dir}                        ${EXECDIR}
${mplane_ipv4}                     10.0.1.2

*** Test Cases ***
[1][1.0] 1.0 TRS_574_TWAMP Commissioning TWAMP reflector

    Generate Scf	target_file=${target_file}
    Copy File    ${target_file}    ${backup_file}
    Execute command     sudo ifconfig eth3.${vlan_ids}[0] inet add 10.0.3.209
    Execute command     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::1/126
    Execute command     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::3:6/126
    Execute command     sudo cp ${CURDIR}/resources/ipsec.conf /etc/ipsec.conf


    Perform Recommissioning    type=delta    delta_file=CMP_RSA.xml    timeout=100
    Sleep   60
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
    Sleep   30
    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT}        skip_parameter_relation_errors=${True}      timeout=300
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   60
    Perform Recommissioning     type=delta       delta_file=${Ipsec_file}        skip_parameter_relation_errors=${True}      timeout=300
    Call Setup  lte=Plain_config_CUS:data   parallel=${False}   verify_attach=      attach=${False}
    Perform Recommissioning     type=delta       delta_file=${TWAMP_Reflector}        skip_parameter_relation_errors=${True}      timeout=300

    @{Sender_IPs}=            Create List
    FOR     ${i}    IN RANGE    4       0       -1
            ${Send_IP}=    Execute command     sudo ip a s eth3.${vlan_ids}[0] |grep inet |awk -F ' ' '{print $2}'|sed -n 1,4p|cut -d/ -f1
            ...         | head ${${i} - 5} | tail -1
            Append To List      ${Sender_IPs}         ${Send_IP}
    END
    log     ${Sender_IPs}
    ${Permission}=      Set Variable    sudo chmod 777 /home/ute/fw_user_path/testcases/resources/twamp_reflector/*
    Run         ${Permission}
    Start Ip traffic capture point A file mode  oam_device
    ${TWAMP_Reflector_1}=      Set Variable    python /home/ute/fw_user_path/testcases/resources/twamp_reflector/twampy.py sender 10.0.1.2:5018
    ...         ${Sender_IPs}[0]:5001 --padding 100 -i 100 -c 100000 -d > 1st_twamp_Sender.txt & echo $! > pid.txt
    Run         ${TWAMP_Reflector_1}
    ${TWAMP_Reflector_2}=      Set Variable    python /home/ute/fw_user_path/testcases/resources/twamp_reflector/twampy.py sender 10.0.3.210:5018
    ...          ${Sender_IPs}[1]:5001 --padding 100 -i 100 -c 100000 -d > 2nd_twamp_Sender.txt & echo $! >> pid.txt
    Run         ${TWAMP_Reflector_2}
    ${TWAMP_Reflector_3}=      Set Variable    /home/ute/fw_user_path/testcases/resources/twamp_reflector/twampSenderIPV6 ${Sender_IPs}[3]
    ...          fc00::2 5018 > 3rd_twamp_Sender.txt & echo $! >> pid.txt
    Run         ${TWAMP_Reflector_3}
    ${TWAMP_Reflector_4}=      Set Variable    /home/ute/fw_user_path/testcases/resources/twamp_reflector/twampSenderIPV6 ${Sender_IPs}[2]
    ...          fc00::3:7 5018 > 4th_twamp_Sender.txt & echo $! >> pid.txt
    Run         ${TWAMP_Reflector_4}
    Sleep   60
    Stop Ip traffic capture in file mode
    Analyse pcap    pcap_filename=${pcap_file}      analysis=twamp_reflector_IPv4_1st      filter_file_name=${TWAMP_Reflector_Filter}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=twamp_reflector_IPv4_2nd      filter_file_name=${TWAMP_Reflector_Filter}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=twamp_reflector_IPv6_1st      filter_file_name=${TWAMP_Reflector_Filter}
    Analyse pcap    pcap_filename=${pcap_file}      analysis=twamp_reflector_IPv6_2nd      filter_file_name=${TWAMP_Reflector_Filter}
    [Teardown]    Keywords to run at end

***Keywords***
Initial configuration of SBH and TWAMP
		Perform Commissioning       scf_file=${SBH_TWAMP_Commissioning}       verify_bts_status=False

Read TWAMP Session IP
        ${sender_ip} =      Get Parameter           param_path=TWAMP-1:sourceIpAddressDN:localIpAddr
        ${reflector_ip} =     Get Parameter           param_path=TWAMP-1:destIpAddress
	Set Suite Variable      ${sender_ip}    ${sender_ip}
        Set Suite Variable      ${reflector_ip}        ${reflector_ip}

Keywords to run at end
        Perform Commissioning       scf_file=${CURDIR}/resources/Backup_Commissioning.xml       verify_bts_status=False
        ${killall}=     Set Variable    sudo killall edaemon egate
        Run     ${killall}
        ${ipsec_stop}=     Set Variable    sudo ipsec stop
        Run     ${ipsec_stop}
        ${stop_twampy}=     Set Variable    for pid in $(ps -ef | grep twamp | awk '{print $2}'); do kill -9 $pid; done
        Run     ${stop_twampy}