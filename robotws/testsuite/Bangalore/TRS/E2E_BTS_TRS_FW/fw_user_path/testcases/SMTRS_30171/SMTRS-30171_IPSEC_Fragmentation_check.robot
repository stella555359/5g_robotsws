*** Settings ***
Documentation           [Author]      "Sushma R"
...              	[Maintenance] "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
 

Suite setup     Run Keywords    Pre-conditions for testsuite
Suite Teardown  Teardown Oamops   
***Test Cases ***
[1]Copy_of_02724102 Enhance the IPSEC CRT coverage to configure multiple TS with packet sie of 1411 or above
    IPSEC with Multiple TS  ${Multiple_TS_scf}
    BuiltIn.Sleep   300
    Check for IPSEC with Multiple TS for Ipv4 and IPv6

***Keywords***
Check for IPSEC with Multiple TS for Ipv4 and IPv6
    Read Mplane IP
    Read IKE Remote IP
    Verify Ipsec Tunnels Status
    Setup calls and verify bts status

Read Mplane IP
    ${enb_mPlane_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}
    Set Suite Variable  ${enb_mPlane_ip}    ${enb_mPlane_ip}

Read IKE Remote IP
    ${IKEP_Remote_IP}=  Get Parameter       param_path=${ike_remote_path}
    Set Suite Variable  ${IKEP_Remote_IP}   ${IKEP_Remote_IP}


IPSEC with Multiple TS
    [Arguments]     ${Multiple_TS_scf}
    Setup Oamops    dut=bts    alias=con22
    Perform Commissioning   dut=bts     scf_file=${Multiple_TS_scf}      verify_bts_status=False
    ...		timeout=300     alias=con22
    BuiltIn.Sleep   300
    Teardown Oamops     dut=bts     alias=con22

Setup calls and verify bts status
    Call Setup     5g=Device_AP:data    parallel=${False}    attach=${False}      verify_attach=${false}    ipv4_or_6=ipv4    timeout=120
    BuiltIn.Sleep   10
    Verify BTS status
    Check ping
    Call Teardown   5g=Device_AP:data

Check ping
    Traffic Capture Start   capture_device=oam_device   mode=file    measurement_point=Transport_Interface      uplane_capturing=${True}
    ...		timeout=120     alias=cap2
    ${output}=  Run     command=ping -6 fc00::1:2 -I fc00::1:10 -s 500 -c 20
    Should Contain  ${output}   20 packets transmitted, 20 received, 0% packet loss
    ${output}=  Run     command=ping 10.0.1.2 -I 10.0.1.33 -s 500 -c 20
    Should Contain  ${output}   20 packets transmitted, 20 received, 0% packet loss
    ${output}=  Run     command=ping -6 fc00::1:2 -I fc00::1:10 -s 1456 -c 20
    Should Contain  ${output}   20 packets transmitted, 20 received, 0% packet loss
    ${output}=  Run     command=ping 10.0.1.2 -I 10.0.1.33 -s 1425 -c 20
    Should Contain  ${output}   20 packets transmitted, 20 received, 0% packet loss
    ${pcap_icmp}=   Traffic Capture Stop    mode=file   timeout=120     alias=cap2
    Set Suite Variable  ${pcap_icmp}    ${pcap_icmp}
    Check Capture for icmp  ${pcap_icmp}

Check Capture for icmp
    [Arguments]     ${pcap_file}
    Analyse Pcap    pcap_filename=${pcap_file}  analysis=ICMPv4     filter_file_name=${eda_traffic_capture}
    Analyse Pcap    pcap_filename=${pcap_file}  analysis=ICMPv6     filter_file_name=${eda_traffic_capture}

Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}                key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary             dictionary=${parent_tunnel_stateInfo}	key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END
        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}              key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary             dictionary=${child_tunnel_stateInfo}	key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END

Check Capture
    [Arguments]     ${pcap_file}
    Analyse Pcap    pcap_filename=${pcap_file}  analysis=ESP_UL     filter_file_name=${eda_traffic_capture}
    Analyse Pcap    pcap_filename=${pcap_file}  analysis=ESP_DL     filter_file_name=${eda_traffic_capture}

