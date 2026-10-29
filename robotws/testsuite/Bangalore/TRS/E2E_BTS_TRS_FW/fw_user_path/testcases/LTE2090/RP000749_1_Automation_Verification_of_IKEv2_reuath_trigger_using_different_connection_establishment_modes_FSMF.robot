*** Settings ***
Documentation
...		[Author]     	"Kamal"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"


Resource		${CURDIR}/../resources/Admin_Common_Library.robot
Resource		${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]RP000749_1_Automation_Verification of IKEv2 reuathentication trigger using different connection establishment modes
    Perform Commissioning       scf_file=${base_fsmf_scfc}       verify_bts_status=False       timeout=1200
    BuiltIn.Sleep    600
    Verify IPSEC Association
	Enable the reauth flag and timer as 300s
	Check the ipsec tunnels after reauth triggered from enb
	Disable ipsec on enb and sw
	Make BTS as responder
	Check the ipsec tunnels established after bts as responder

*** Keywords ***

Verify IPSEC Association
    [Arguments]      ${no_association}=${False}      ${Enb_IP}=192.168.255.129
            Execute command on ENodeB       ipsec status | grep conn1        ${Enb_IP}
            Run Keyword If      ${no_association}==${False}     Should Match Regexp     ${stdout}   .*ESTABLISHED.*
            Run Keyword If      ${no_association}==${False}     Should Match Regexp     ${stdout}   .*INSTALLED.*
            Run Keyword If      ${no_association}==${True}      Should Not Match Regexp     ${stdout}   .*ESTABLISHED.*
            Run Keyword If      ${no_association}==${True}      Should Not Match Regexp     ${stdout}   .*INSTALLED.*


Get Ipsec Tunnels Status
    [Documentation]     This test case keyword is to verify IPSec tunnels status for 6 operators x2c list
    @{parent_tunnel_moc_list} =      Get Parameter      param_path=${ike_sa_l_moc_path}
    FOR     ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}= Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
        ${parent_tunnel_proceduralState}=   Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'    timeout=800
    END

    @{child_tunnel_moc_list} =  Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}
    FOR     ${child_tunnel} IN  @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=  Get From Dictionary     dictionary=${child_tunnel}      key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'   timeout=800
    END



Enable the reauth flag and timer as 300s
	Perform Recommissioning     type=delta       delta_file=${Enable_Reauthentication_flag_v4_300_fsmf}
	...   skip_parameter_relation_errors=${True}      timeout=120

Enable ipsec on enb and sw
	Enable Ipsec on Admin

Check the ipsec tunnels after reauth triggered from sw
	Enable ipsec on enb and sw
    Verify IPSEC Association
	Traffic Capture Start   capture_device=bts     alias=ipsec_after_reauthenticationsw_pcap
    BuiltIn.Sleep    3800
    Enable Ipsec on Admin
	${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
	...    alias=ipsec_after_reauthenticationsw_pcap
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}
	...   analysis=ike_reauth_uplane_300      filter_file_name=${ipsec_reauthentication_filter_file}
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}
	...   analysis=ike_reauth_cplane_300      filter_file_name=${ipsec_reauthentication_filter_file}
    Verify IPSEC Association

Disable ipsec on enb and sw
	Disable Ipsec on Admin

Check the ipsec tunnels after reauth triggered from enb
	Disable ipsec on enb and sw
	Enable ipsec on enb and sw
	Traffic Capture Start   capture_device=bts     alias=ipsec_after_reauthenticationsw_pcap
	BuiltIn.Sleep    3800
    Enable Ipsec on Admin

	${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
	...    alias=ipsec_after_reauthenticationsw_pcap
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}
	...    analysis=ike_reauth_uplane_3600      filter_file_name=${ipsec_reauthentication_filter_file}
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}
	...    analysis=ike_reauth_cplane_3600      filter_file_name=${ipsec_reauthentication_filter_file}
    Verify IPSEC Association

Make BTS as responder
    Perform Recommissioning     type=delta       delta_file=${bts_responder_fsmf}
	...    skip_parameter_relation_errors=${True}      timeout=300

Check the ipsec tunnels established after bts as responder
	Enable ipsec on enb and sw
	Traffic Capture Start   capture_device=bts     alias=ipsec_after_reauthenticationsw_pcap
    BuiltIn.Sleep    3800
    Enable Ipsec on Admin

	${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
	...   alias=ipsec_after_reauthenticationsw_pcap
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}
	...   analysis=ike_noreauth_cplane      filter_file_name=${ipsec_reauthentication_filter_file}

Make BTS as initiator
    Perform Recommissioning     type=delta       delta_file=${bts_initiator}
	....    skip_parameter_relation_errors=${True}      timeout=300

Enable the reauth flag and reauth timer in enb and sw
	[Arguments]		${enable_reuath_flag_with_timer}
	Perform Recommissioning     type=delta       delta_file=${enable_reuath_flag_with_timer)}
	...    skip_parameter_relation_errors=${True}      timeout=300

Check the ipsec tunnels after reauth 300
	Traffic Capture Start   capture_device=bts    alias=ipsec_after_reauthenticationsw_pcap
    BuiltIn.Sleep   400
	${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
	...  alias=ipsec_after_reauthenticationsw_pcap
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}      analysis=wo_vlan_tagging
	...      filter_file_name=${ipsec_reauthentication_filter_file}
    Verify IPSEC Association

Enable the reauth flag and reauth timer as 300
	Perform Recommissioning     type=delta       delta_file=${enable_reauth_flag_300}
	...   skip_parameter_relation_errors=${True}      timeout=300

check the ipsec tunnels after reauth bts as responder
	Traffic Capture Start   capture_device=bts     alias=ipsec_after_reauthenticationsw_pcap
    BuiltIn.Sleep   400
	${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
	...   alias=ipsec_after_reauthenticationsw_pcap
	Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}      analysis=wo_vlan_tagging
	...     filter_file_name=${ipsec_reauthentication_filter_file}
    Verify IPSEC Association
