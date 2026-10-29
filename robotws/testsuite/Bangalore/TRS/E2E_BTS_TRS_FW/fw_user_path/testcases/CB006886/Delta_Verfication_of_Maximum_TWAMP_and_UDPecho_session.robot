*** Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


#Force Tags       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS21A]     4G_FDD              CRT
#Force Tags      CLOUD_R4P_IPSEC    CA_E2ET_BTSTRSPZ        SBTS00        SBTS21A     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

#Variables               ta_e2e_bts_trs_fw
Library					ute_fsmaccess
#esource                taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource       	 ${CURDIR}/../resources/common_keywords.robot
#Resource         	 ${CURDIR}/../resources/Common_IPSEC_Operations.robot
#Resource        	 ${CURDIR}/../resources/Admin_Common_Library.robot
Resource                           ${CURDIR}/../resources/Common_Twamp.robot
#Variables		config
#Resource            setup/framework.robot

Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown


*** Variables ***
@{vlan_ids}                                                  311         312         313         314
@{Interface_ip}                                             10.0.3.209      10.0.3.213          10.0.3.217          10.0.3.221
@{Broadcast_ip}                                             10.0.3.211      10.0.3.215          10.0.3.219          10.0.3.223

*** Test Cases ***
[1]CB006886_994C_Delta Verfication of Maximum TWAMP and UDPecho session_Copy_1

#   Pre-condition
#a    Perform Commissioning       scf_file=${scf_commissioning}   verify_bts_status=False     timeout=400     alias=default
	Perform Recommissioning		type=delta		delta_file=${4_IP_Config}		timeout=300
    Sleep    60
    Bring 4 VLAN interface on VM
    Sleep    60

#TestCase
	Perform Recommissioning		type=delta		delta_file=${twamp_100sessions}		timeout=300
    ${twampy_command}=    Set Variable    python /home/ute/Downloads/Tool/twampy.py responder --load_json /home/ute/Downloads/Tool/sample.json
    ...     --section 1 --padding 100 -d >twamp.txt & echo $! > pid.txt
	Run     ${twampy_command}
    Sleep  60s
	Pm Counters Start     analysis=twamp_counter_unlock    counter_analysis_file=${twamp_counter_unlock}
	Start the twamp sender sessions and verify wireshark
	Verify Pm Counters     analysis=twamp_counter_unlock     counter_analysis_file=${twamp_counter_unlock}
	Lock the twamp sessions and verify
    unlock the twamp sessions and verify wireshark
	50sessions locked and changing the dscp vlaue for another 50
	verfying boundary conditions
#    verifying all changes in one delta
    [Teardown]  Keywords to run at end


*** Keywords ***
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
    Perform Recommissioning		type=delta		delta_file=${twamp_100sessions_lock}		timeout=300
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
#    Run         python /home/ute/Tool/twampy.py responder --load_json /home/ute/Tool/sample.json --section s1 -d >twamp.txt & echo $! > pid.txt
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_2
    ${twampy_command2}=    Set Variable    python /home/ute/Downloads/Tool/twampy.py responder --load_json /home/ute/Downloads/Tool/sample.json
    ...     --section s1 -d >twamp.txt & echo $! > pid.txt
	Run     ${twampy_command2}
    Perform Recommissioning		type=delta		delta_file=${twamp_100sessions_unlock}		timeout=300
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
#    Run         python /home/ute/Tool/twampy.py responder --load_json /home/ute/Tool/sample.json --section s1 -d >twamp.txt & echo $! > pid.txt
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap_3
    ${twampy_command3}=    Set Variable    python /home/ute/Downloads/Tool/twampy.py responder --load_json /home/ute/Downloads/Tool/sample.json
    ...     --section s1 -d >twamp.txt & echo $! > pid.txt
    Run         ${twampy_command3}
#   Perform Recommissioning     type=delta      delta_file=${delta_dscp_msg_lock}      timeout=300
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
#     :For    ${i}        IN RANGE     41   100
#    \       ${srcport}=         Evaluate     5010+${i}
#    \       Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_dscp_unlock   filter_file_name=${twamp_wireshark_filter}
#    \       ${srcport}=         Evaluate     5010+${i}
    FOR    ${i}        IN RANGE     51   100
           ${srcport}=         Evaluate     5010+${i}
           Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_unlock_sessions   filter_file_name=${twamp_wireshark_filter}
    END
    FOR       ${i}      IN RANGE       1     50
           ${dscp_change}=     Evaluate     0+${i}
           Analyse pcap            pcap_filename=${pcap_capture_3}        analysis=twamp_dscp_unlock   filter_file_name=${twamp_wireshark_filter}
    END

verfying boundary conditions
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param  param_path=TWAMP-11:destPort
    ...     operation=update    value=65536     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param
    ...     param_path=TWAMP-12:messageSize     operation=update    value=1401     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param  param_path=TWAMP-12:twampDscp
    ...     operation=update    value=64     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param
    ...     param_path=TWAMP-13:plrAlarmThreshold       operation=update    value=10001     timeout=300
    Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param
    ...     param_path=TWAMP-14:rttAlarmThreshold    operation=update    value=1000001     timeout=300
	Run Keyword And Expect Error        *AdminApiProcedureFailureException*     Perform Recommissioning     type=param
    ...     param_path=MRBTS-3806/TNLSVC-1/TNL-1/PMTNL-1:twampStatisticsInterval   skip_parameter_relation_errors=${False}
    ...     operation=update    value=5min     timeout=300

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

Bring 4 VLAN interface on VM
	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[1] type vlan id ${vlan_ids}[1]
	Run		sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.${vlan_ids}[1]
	Run		sudo ip link set dev eth3.${vlan_ids}[1] up

	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[2] type vlan id ${vlan_ids}[2]
	Run		sudo ip addr add 10.0.3.213/30 brd 10.0.3.215 dev eth3.${vlan_ids}[2]
	Run		sudo ip link set dev eth3.${vlan_ids}[2] up

	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[3] type vlan id ${vlan_ids}[3]
	Run		sudo ip addr add 10.0.3.217/30 brd 10.0.3.219 dev eth3.${vlan_ids}[3]
	Run		sudo ip link set dev eth3.${vlan_ids}[3] up

#	Run		sudo ip link add link eth3 name eth3.${vlan_ids}[4] type vlan id ${vlan_ids}[4]
#	Run		sudo ip addr add 10.0.3.221/30 brd 10.0.3.223 dev eth3.${vlan_ids}[4]
#	Run		sudo ip link set dev eth3.${vlan_ids}[4] up


Keywords to run at end
#        Run     sudo killall edaemon egate
#        Run     sudo ipsec stop
#        Run     sudo ip a d 10.0.3.209/30 dev eth3.${vlan_ids}[0]
#        Run     sudo ip a d fc00::3:6/126 dev eth3.${vlan_ids}[0]
        Run     for pid in $(ps -ef | grep twamp | awk '{print $2}'); do kill -9 $pid; done
#        Run     rm -rf ${CURDIR}/execution_logs/*_A54.zip

