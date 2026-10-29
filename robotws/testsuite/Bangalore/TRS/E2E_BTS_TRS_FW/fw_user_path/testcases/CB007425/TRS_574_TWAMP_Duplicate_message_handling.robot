***Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


variables      ta_e2e_bts_trs_fw
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource      ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Setup Oamops
Suite Teardown     Teardown Oamops

***Variable****
${sbh_filter_file}				   SBH_traffic_filter.json
${sbh_lock_filter_file}			   SBH_TWAMP_lock_traffic_filter.json
${counter_analysis_file_name}      SBH_counter_analysis.json
${pcap_dir}                        ${EXECDIR}
${mplane_ipv4}                     10.0.1.2

*** Test Cases ***
[1][1.0] 1.0 TRS_574_TWAMP Duplicate message handling
    Generate Scf	target_file=${target_file}
    Copy File    ${target_file}    ${backup_file}
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet add 10.0.3.209
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::1/126
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::3:6/126
    Run     sudo cp ${CURDIR}/resources/ipsec.conf /etc/ipsec.conf


    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT}        skip_parameter_relation_errors=${True}      timeout=300
    Perform Recommissioning     type=delta       delta_file=${Ipsec_file}        skip_parameter_relation_errors=${True}      timeout=300
    Perform Recommissioning     type=delta       delta_file=${TWAMP_Reflector}        skip_parameter_relation_errors=${True}      timeout=300
    Analyse pcap    pcap_filename=${pcap_file}      analysis=twamp_reflector_IPv4_1st      filter_file_name=${TWAMP_Reflector_Filter}
    [Teardown]    Keywords to run at end

***Keywords****


Initial configuration of SBH and TWAMP
		Perform Commissioning       scf_file=${SBH_TWAMP_Commissioning}       verify_bts_status=False

Read TWAMP Session IP
        ${sender_ip} =      Get Parameter           param_path=TWAMP-1:sourceIpAddressDN:localIpAddr
        ${reflector_ip} =     Get Parameter           param_path=TWAMP-1:destIpAddress
		Set Suite Variable      ${sender_ip}    ${sender_ip}
        Set Suite Variable      ${reflector_ip}        ${reflector_ip}

Keywords to run at end
        Perform Commissioning       scf_file=${CURDIR}/resources/Backup_Commissioning.xml       verify_bts_status=False
        Run     sudo killall edaemon egate
        Run     sudo ipsec stop