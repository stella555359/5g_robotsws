*** Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


Force Tags       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS21A]     4G_FDD              CRT

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot



Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown


*** Test Cases ***
[1][1.0] CB006886_994C_Delta Verfication of Maximum TWAMP and UDPecho session

    Pre-condition
    Sleep    60s
    Copy File     ${delta_dir}/${twamp_100sessions}    ${delta_dir}/${twamp_100sessions_backup}
	Perform Recommissioning		type=delta		delta_file=${twamp_100sessions}		timeout=300
    Run         sudo python ${twampy.py} responder --load_json ${sample.json} --section 1 2 3 4 --padding 100 -d >twamp.txt & echo $! > pid.txt
	Sleep  60s
	Start the twamp sender sessions and verify wireshark
	Lock the twamp sessions and verify
    unlock the twamp sessions and verify wireshark
	50sessions locked and changing the dscp vlaue for another 50
	verfying boundary conditions
    verifying all changes in one delta
    [Teardown]          Keywords to run at end

*** Keywords ***
Pre-condition
     ${interface_adddress_last_octet}=        Set Variable        209
     ${interface_adddress_last_octet_IPv6}=      Set Variable        0X06
     ${sim_ip}=            Set Variable     20

    Copy File     ${delta_dir}/${delta_4_vlan}    ${delta_dir}/${delta_4_vlan_copy}
    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
    FOR        ${i}        IN RANGE    0       5
           ${nw_ipv4}=         Evaluate            ${interface_adddress_last_octet}-1
           ${nw_ipv6}=         Evaluate            hex(${interface_adddress_last_octet_IPv6}-2)
           ${nw_ipv6}=         Evaluate            hex(${nw_ipv6}).lstrip("0x")
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           Bring IPv4 VLAN VM Interfaces    ${vlan_id}   10.0.3.${interface_adddress_last_octet}    10.0.3.${broadcast_adddress_last_octet}    30
           Run         sudo ifconfig eth3.${vlan_id} inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           ${ENB_interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
            Run     sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${delta_4_vlan}
            ${vlan_id}=      Evaluate      ${vlan_id}+1
    END

    Perform commissioning       scf_file=${twamp_base_scf}   verify_bts_status=False     timeout=400     alias=default
    Sleep   100
    Perform Recommissioning     type=delta      delta_file=${delta_4_vlan}     timeout=300
    Sleep     60

    [Teardown]           Copy File     ${delta_dir}/${delta_4_vlan_copy}    ${delta_dir}/${delta_4_vlan}


Bring IPv4 VLAN VM Interfaces
    [Arguments]             ${Vlan_ID}          ${interface_address}        ${broadcast_ip_address}         ${sunbet_mask}
    Run     sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     sudo ip link set dev eth3.${Vlan_ID} up



Start the twamp sender sessions and verify wireshark

	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_1
    Sleep	100s
	${pcap_capture_1}=       Traffic Capture Stop        alias=eth3_pcap_1
	FOR    ${i}        IN RANGE    1   11
           ${srcport}=         Evaluate     5000+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=twamp_port_sender    filter_file_name=${twamp_wireshark_filter}
	END
    FOR    ${i}        IN RANGE     11   101
           ${srcport}=         Evaluate     5010+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=twamp_port_sender    filter_file_name=${twamp_wireshark_filter}
    END
    FOR    ${i}        IN RANGE    1   11
           ${dstport}=         Evaluate     5000+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=twamp_port_ref    filter_file_name=${twamp_wireshark_filter}
    END
    FOR    ${i}        IN RANGE     11   101
           ${dstport}=         Evaluate     5010+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_1}        analysis=twamp_port_ref    filter_file_name=${twamp_wireshark_filter}
    END

Lock the twamp sessions and verify
    Run     sudo sed -i "s/unlocked/locked/g" ${delta_dir}/${twamp_100sessions}
    Run     sudo sed -i "s/create/update/g" ${delta_dir}/${twamp_100sessions}
    Perform Recommissioning     type=delta      delta_file=${twamp_100sessions}     timeout=300
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_3
    Sleep	100s
	${pcap_capture_3}=       Traffic Capture Stop        alias=eth3_pcap_3
	FOR    ${i}        IN RANGE    1   11
           ${srcport}=         Evaluate     5000+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_lock_sender    filter_file_name=${twamp_wireshark_filter}
	END
    FOR    ${i}        IN RANGE     11   101
           ${srcport}=         Evaluate     5010+${i}
	       Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_lock_sender    filter_file_name=${twamp_wireshark_filter}
    END

unlock the twamp sessions and verify wireshark
    Run     sudo sed -i "s/locked/unlocked/g" ${delta_dir}/${twamp_100sessions}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_2
	Perform Recommissioning		type=delta		delta_file=${twamp_100sessions}		timeout=300
    Sleep    100s
    ${pcap_capture_2}=       Traffic Capture Stop        alias=eth3_pcap_2
    FOR    ${i}        IN RANGE    1   11
           ${srcport}=         Evaluate     5000+${i}
           Analyse pcap            pcap_filename=${pcap_capture_2}        analysis=twamp_unlock    filter_file_name=${twamp_wireshark_filter}
    END
    FOR    ${i}        IN RANGE     11   101
           ${srcport}=         Evaluate     5010+${i}
           Analyse pcap            pcap_filename=${pcap_capture_2}        analysis=twamp_unlock   filter_file_name=${twamp_wireshark_filter}
    END

50sessions locked and changing the dscp vlaue for another 50
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_3
    Sleep   60s
    ${pcap_capture_3}=       Traffic Capture Stop        alias=eth3_pcap_3
    FOR    ${i}        IN RANGE    1   11
           ${srcport}=         Evaluate     5000+${i}
           Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_lock_sender    filter_file_name=${twamp_wireshark_filter}
    END
    FOR    ${i}        IN RANGE     11   50
           ${srcport}=         Evaluate     5010+${i}
           Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_lock_sender   filter_file_name=${twamp_wireshark_filter}
    END
    FOR    ${i}        IN RANGE     51   100
           ${srcport}=         Evaluate     5010+${i}
           Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_unlock_sessions   filter_file_name=${twamp_wireshark_filter}
    END
    FOR       ${i}      IN RANGE       1     50
          ${dscp_change}=     Evaluate     0+${i}
          Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_dscp_unlock   filter_file_name=${twamp_wireshark_filter}
    END

verfying boundary conditions
      Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=TWAMP-11:destPort    operation=update    value=65536     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=TWAMP-12:messageSize    operation=update    value=1401     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=TWAMP-12:twampDscp    operation=update    value=64     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=TWAMP-13:plrAlarmThreshold    operation=update    value=10001     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=TWAMP-14:rttAlarmThreshold    operation=update    value=1000001     timeout=300
	Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning
    ...     type=param  param_path=MRBTS-1/TNLSVC-1/TNL-1/PMTNL-1:twampStatisticsInterval
    ...     skip_parameter_relation_errors=${False}  operation=update    value=5min     timeout=300

verifying all changes in one delta
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_4
    Sleep    60s
    Perform Recommissioning        type=delta      delta_file=${twamp_delta}       timeout=300
    Sleep  100s
   ${pcap_capture_4}=       Traffic Capture Stop        alias=eth3_pcap_4
   Analyse pcap            pcap_filename=${pcap_capture_4}        analysis=twamp_delta_srcport    filter_file_name=${twamp_wireshark_filter}
    Analyse pcap            pcap_filename=${pcap_capture_4}        analysis=twamp_delta_dscp    filter_file_name=${twamp_wireshark_filter}
    ${enhanced_metric}=      Get Parameter   param_path=${enhanced_metric}
    Should be True     '${enhanced_metric}'=='False'


Keywords to run at end
    Copy File     ${delta_dir}/${twamp_100sessions_backup}    ${delta_dir}/${twamp_100sessions}
