***Settings ***
Documentation
    ...     [Feature_ID]            "CB008128"
    ...     [Author]                "Dineshkumar"

#Resource	  setup/framework.robot

*** Variables ***
${Base_Build}       /home/ute/Downloads/SBTS25R3_ENB_0000_000390_000000_release_BTSSM_downloadable_A54.zip
${Build}       SBTS00
${New_Build}    /home/ute/Downloads/SBTS25R3_ENB_0000_000390_000000_release_BTSSM_downloadable_A54.zip
${Static_AMFID}    1
${Dynamic_AMFID}    2
${secgw}    CN = SECGW_TA

*** Keywords ***
Configure Static Ipsec and verify tunnel status
    Perform Recommissioning    type=delta      delta_file=${static_ipsec_scf}      skip_parameter_relation_errors=False
    Sleep   120
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
    ...     password=${Cert_password}
    Sleep   60
    Verify Static Onair status
    Verify Static tunnels status
    Verify failure Alarms

Configure Dynamic Ipsec and verify tunnel status
    Perform Recommissioning    type=delta      delta_file=${dynamic_ipsec_scf}      skip_parameter_relation_errors=False
    Sleep   120
    Verify Dynamic Onair status
    Verify Dynamic tunnels status
    Verify failure Alarms

Verify Static tunnels status
    IKEP_1
    IKEP_2
    IKEP_3
    IKEP_4
    IKEP_5
    IKEP_6
    IKEP_7
    IKEP_8

IKEP_1
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_2
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_3
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_3}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     st3.marvels.dyn.com

IKEP_4
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_4}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_5
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_5}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_6
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_6}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     st6.marvels.dyn.com

IKEP_7
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     st7.marvels.dyn.com

IKEP_8
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_8}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify Dynamic tunnels status
    IKEP_9
    IKEP_10
    IKEP_11
    IKEP_12
    IKEP_13
    IKEP_14
    IKEP_15
    IKEP_16

IKEP_9
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_9}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn1.marvels.dyn.com

IKEP_10
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_10}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn2.marvels.dyn.com

IKEP_11
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_11}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn3.marvels.dyn.com

IKEP_12
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_12}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn4.marvels.dyn.com

IKEP_13
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_13}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_14
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_14}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn6.marvels.dyn.com

IKEP_15
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_15}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_16
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_16}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn8.marvels.dyn.com

Verify Ipsec Enable and Disable
    Get Inbound and Outbound SPI value
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   120
    Verify Ipsec Tunnels and Alarm status
    Verify new Inbound and Outbound SPI value

Verify Primary FQDN changes and failures
    Get Inbound and Outbound SPI value
    Perform Recommissioning    type=delta      delta_file=${delta_new_fqdn_value}      skip_parameter_relation_errors=False
    Sleep   60
    Verify new FQDN tunnels status
    Verify failure Alarms
    Verify new Inbound and Outbound SPI value
    Configure and verify wrong FQDN value
    Reconfigure and verify correct FQDN value

Configure and verify wrong FQDN value
    Perform Recommissioning     type=param      param_path=${IKEP3_RTEP_path}  operation=update
    ...     value=${IKEP3_wrong_FQDN_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP7_RTEP_path}  operation=update
    ...     value=${IKEP7_wrong_FQDN_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP9_RTEP_path}  operation=update
    ...     value=${IKEP9_wrong_FQDN_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP14_RTEP_path}  operation=update
    ...     value=${IKEP14_wrong_FQDN_value}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=4
    Verify wrong FQDN tunnel status
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   60
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=4
    Verify wrong FQDN tunnel status

Reconfigure and verify correct FQDN value
    Perform Recommissioning     type=param      param_path=${IKEP3_RTEP_path}  operation=update
    ...     value=${IKEP3_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP7_RTEP_path}  operation=update
    ...     value=${IKEP7_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP9_RTEP_path}  operation=update
    ...     value=${IKEP9_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP14_RTEP_path}  operation=update
    ...     value=${IKEP14_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status

Verify Primary RTEP IP changes and failures
    Get Inbound and Outbound SPI value
    Perform Recommissioning    type=delta      delta_file=${delta_new_rtep_value}      skip_parameter_relation_errors=False
    Sleep   120
    Verify new RTEP IP tunnels status
    Verify failure Alarms
    Verify new Inbound and Outbound SPI value
    Configure and verify wrong RTEP IP value
    Reconfigure and verify correct RTEP IP value

Configure and verify wrong RTEP IP value
    Perform Recommissioning     type=param      param_path=${IKEP5_RTEP_path}  operation=update
    ...     value=${IKEP5_wrong_IP_value}       skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP13_RTEP_path}  operation=update
    ...     value=${IKEP13_wrong_IP_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP15_RTEP_path}  operation=update
    ...     value=${IKEP15_wrong_IP_value}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${true}     occurrences=3
    Verify wrong RTEP IP tunnel status
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   60
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${true}     occurrences=3
    Verify wrong RTEP IP tunnel status

Reconfigure and verify correct RTEP IP value
    Perform Recommissioning     type=param      param_path=${IKEP5_RTEP_path}  operation=update
    ...     value=${IKEP_5}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP13_RTEP_path}  operation=update
    ...     value=${IKEP_13}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP15_RTEP_path}  operation=update
    ...     value=${IKEP_15}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status

Verify Primary and Secondary FQDN
    Perform Recommissioning    type=delta      delta_file=${delta_config_secondary_fqdn}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status
    Perform Recommissioning    type=delta      delta_file=${delta_wrong_primary_fqdn}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=3
    Verify Secondary FQDN tunnels status
    Perform Recommissioning    type=delta      delta_file=${delta_correct_primary_fqdn}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status
    Verify Primary IP Secondary FQDN

Verify Ipsec Tunnels and Alarm status
#    Verify Static Onair status
#    Verify Dynamic Onair status
    Verify Static tunnels status
    Verify Dynamic tunnels status
    Verify failure Alarms

Verify Primary IP Secondary FQDN
    Perform Recommissioning    type=delta      delta_file=${delta_correct_primary_ip}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify RTEP IP tunnels status
    Verify failure Alarms
    Configure wrong primary IP value
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Secondary FQDN tunnels status
    Configure wrong Secondary FQDN value
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=3
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${true}     occurrences=3
    Configure correct primary IP value
    Verify RTEP IP tunnels status
    Verify Static Onair status
    Verify Dynamic Onair status
    Verify failure Alarms
    Perform Recommissioning    type=delta      delta_file=${delta_correct_primary_fqdn}
    ...     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Ipsec Tunnels and Alarm status

Configure wrong Secondary FQDN value
    Perform Recommissioning    type=delta      delta_file=${delta_wrong_secondary_fqdn}
    ...     skip_parameter_relation_errors=${True}
    Sleep   180

Configure wrong primary IP value
    Perform Recommissioning     type=param      param_path=${IKEP7_RTEP_path}  operation=update
    ...     value=${IKEP7_wrong_IP_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP9_RTEP_path}  operation=update
    ...     value=${IKEP9_wrong_IP_value}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP14_RTEP_path}  operation=update
    ...     value=${IKEP14_wrong_IP_value}    skip_parameter_relation_errors=${True}
    Sleep   60

Configure correct primary IP value
    Perform Recommissioning     type=param      param_path=${IKEP7_RTEP_path}  operation=update
    ...     value=${IKEP_7}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP9_RTEP_path}  operation=update
    ...     value=${IKEP_9}    skip_parameter_relation_errors=${True}
    Sleep   5
    Perform Recommissioning     type=param      param_path=${IKEP14_RTEP_path}  operation=update
    ...     value=${IKEP_14}    skip_parameter_relation_errors=${True}
    Sleep   60

Verify IKE SA failure tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_9}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_12}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_14}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

Verify Tunnels during NW fluctuation
    Verify Ipsec Tunnels and Alarm status
    Configure Switch    device=dev_1        command_profile=disable_ports
    Sleep   300
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${true}      occurrences=7
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=9
    Configure Switch	device=dev_1		command_profile=enable_ports
    Sleep   240
    Verify Ipsec Tunnels and Alarm status

Teardown testcase
    Stop Syslog
    Install Certificate
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   10

Verify IPsec Alarms
    Verify IKE Authentication Alarm
    Verify IKE SA Failure Alarm
    Verify IPsec SA Failure Alarm

Verify IKE Authentication Alarm
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Wrong_cert_file}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Cert_password}
    Sleep   60
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${true}     occurrences=16
    Verify tunnels status with wrong certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Cert_password}
    Sleep   120
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=2
    Verify Static tunnels status
    Verify Dynamic tunnels status
    Verify failure Alarms

Verify IKE SA Failure Alarm
    Perform Recommissioning    type=delta      delta_file=${delta_wrong_ike_auth_value}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=${IKE_SA_Failure}    severity=major     should_exist=${true}     occurrences=5
    Verify IKE SA failure tunnel status
    Perform Recommissioning    type=delta      delta_file=${delta_correct_ike_auth_value}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status
    Perform Recommissioning    type=delta      delta_file=${delta_wrong_ike_encryp_value}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm        faultid=${IKE_SA_Failure}    severity=major     should_exist=${true}     occurrences=5
    Verify IKE SA failure tunnel status
    Perform Recommissioning    type=delta      delta_file=${delta_correct_ike_encryp_value}
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status

Verify IPsec SA Failure Alarm
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   60
    Get Inbound and Outbound SPI value
    Perform Recommissioning    type=delta      delta_file=${delta_config_IPsec_SA_failure}      skip_parameter_relation_errors=${True}
    Sleep   300
    Verify Alarm        faultid=${IPSEC_SA_Failure}    severity=major     should_exist=${true}     occurrences=2
    Verify new Inbound and Outbound SPI value
    Sleep   900
    Verify Alarm        faultid=${IPSEC_SA_Failure}    severity=major     should_exist=${false}     occurrences=1
    Verify Ipsec Tunnels and Alarm status
    Perform Recommissioning    type=delta      delta_file=${delta_config_revert}      skip_parameter_relation_errors=${True}
    Sleep   30

Verify wireshark for DNS packets via Mplane
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   30
    Check BTS and TRS is commissioned or configured or OnAir
    Verify tunnels status
    Verify Alarm   faultid=${IPsec FQDN failure}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    ${PointA_noPwd}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=dns_mplane

Verify wireshark for DNS packets via LTEP
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=IPSECC-1:dnsSrcIpSelection     operation=update    value=LTEP
    Sleep   60
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   30
    Check BTS and TRS is commissioned or configured or OnAir
    Verify tunnels status
    Verify Alarm   faultid=${IPsec FQDN failure}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    ${PointA_noPwd}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=dns_ltep

Verify build and load TA scfc
    ${active_sw}    ${passive_sw} =    Get Sw Version    timeout=30    alias=default
    ${split}=    Split String    ${active_sw}    _
    ${build_version}=  Set Variable    ${split[3]}
    Log    ${build_version}
    Run Keyword If      '${build_version}' == '9999'     Load Trunk TA SCF      ELSE    Load Branch TA SCF

Load Trunk TA SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${multi_ta_tr_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   240
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Load Branch TA SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${multi_ta_br_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   240
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Verify Multi TA certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   20
    Verify build and load TA scfc
    Certificate Configure    operation=install_cmp_certificate
    Sleep   20
    Certificate Configure   operation=install_certificate   cert_file=${Additional_cert_file}    cert_type=AdditionalCa
    ...     cert_format=PEM
    Sleep   80
    Verify Multi TA FQDN tunnel status
    Verify failure Alarms
    Configure and Verify Multi TA tunnel status with diff RTEP value
    Reinstall and Verify Multi TA tunnel status

Configure and Verify Multi TA tunnel status with diff RTEP value
    Get Inbound and Outbound SPI value
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${mta2_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify new Multi TA FQDN tunnel status
    Verify failure Alarms
    Verify new Inbound and Outbound SPI value
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${mta2}    skip_parameter_relation_errors=${True}
    Sleep   60
    Verify new Multi TA IP tunnel status
    Verify failure Alarms
    Perform Recommissioning     type=param      param_path=${IKEP1_RTEP_path}  operation=update
    ...     value=${mta1_fqdn_value}    skip_parameter_relation_errors=${True}
    Sleep   30
    Verify Multi TA FQDN tunnel status
    Verify failure Alarms

Reinstall and Verify Multi TA tunnel status
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   20
    Verify Multi TA failure tunnel status
    ${certificate_details}=     Certificate Configure 		operation=get_certificate_details		type=TrustAnchor   source=Operator
    ${dict}=        set variable       ${certificate_details}[0]
    ${issuer}=     Get From Dictionary     dictionary=${dict}      key=issuer
    Should Be Equal As Strings      ${issuer}     CN = SECGW_TA
    Certificate Configure    operation=install_cmp_certificate
    Sleep   60
    Verify Multi TA FQDN tunnel status
    Verify failure Alarms
    certificate configure           operation=cmp_update_key
    Sleep   60
    Verify Multi TA FQDN tunnel status
    Verify failure Alarms

Base Software Download And Update
    Perform Software Download And Update        package=${Base_Build}       activate_sw=True        timeout=2600
    Sleep   60
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   30
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
    ...     password=${Cert_password}
    Sleep   60
    Verify build and load working scfc
    Verify Ipsec Tunnels and Alarm status

Software Download And Update
#    Perform Software Download And Update        package=auto        wft_profile=${Build}       activate_sw=True        timeout=2600
    Perform Software Download And Update        package=${New_Build}       activate_sw=True        timeout=2600
    Sleep   120
    Verify Ipsec Tunnels and Alarm status

Verify build and load Plain scfc
    ${active_sw}    ${passive_sw} =    Get Sw Version    timeout=30    alias=default
    ${split}=    Split String    ${active_sw}    _
    ${build_version}=  Set Variable    ${split[2]}
    Log    ${build_version}
    Run Keyword If      '${build_version}' == '9999'     Load Trunk Plain SCF      ELSE    Load Branch Plain SCF

Verify build and load working scfc
    ${active_sw}    ${passive_sw} =    Get Sw Version    timeout=30    alias=default
    ${split}=    Split String    ${active_sw}    _
    ${build_version}=  Set Variable    ${split[3]}
    Log    ${build_version}
    Run Keyword If      '${build_version}' == '9999'    Load Trunk working SCF      ELSE    Load Branch working SCF

Load Trunk working SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${8128_working_tr_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Load Branch working SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${8128_working_br_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Load Trunk Plain SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${8128_trunk_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Load Branch Plain SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${8128_branch_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1

Install Certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   20
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Cert_password}
    Sleep   20

Verify tunnels status with wrong certificate
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_3}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_4}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_5}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_6}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_8}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_9}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_10}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_11}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_12}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_13}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_14}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_15}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_16}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

Verify failure Alarms
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm        faultid=${IKE_SA_Failure}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=1

Verify Static Onair status
    Verify Bts Status   should_be_onair=${True}     req_rat=nr
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${Static_AMFID}
    ${Static_ngLinkStatus}=     Get From Dictionary     dictionary=${nglink}      key=ngLinkStatus
    Should Be Equal As Strings      ${Static_ngLinkStatus}     Active
#    ${Static_MME_status}=    Get Parameter      param_path=MRBTS-2357/LNBTS-2357/LNMME-0:s1LinkStatus
#    Should Be Equal As Strings      ${Static_MME_status}     available
    Verify Alarm    faultid=${NG_SCTP_setup_fail}   should_exist=${false}
	Verify Alarm    faultid=${Transport_layer_connection_failure_in_S1_interface}   should_exist=${false}

Verify Dynamic Onair status
    Verify Bts Status   should_be_onair=${True}     req_rat=nr
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${Dynamic_AMFID}
    ${Dynamic_ngLinkStatus}=     Get From Dictionary     dictionary=${nglink}      key=ngLinkStatus
    Should Be Equal As Strings      ${Dynamic_ngLinkStatus}     Active
#    ${Dynamic_MME_status}=    Get Parameter      param_path=MRBTS-2357/LNBTS-2357/LNMME-1:s1LinkStatus
#    Should Be Equal As Strings      ${Dynamic_MME_status}     available
    Verify Alarm    faultid=${NG_SCTP_setup_fail}   should_exist=${false}
    Verify Alarm    faultid=${Transport_layer_connection_failure_in_S1_interface}   should_exist=${false}

Verify new FQDN tunnels status
    IKEP_2
    IKEP_3_new
    IKEP_4
    IKEP_5
    IKEP_6
    IKEP_7_new
    IKEP_8
    IKEP_9_new
    IKEP_10
    IKEP_11
    IKEP_12
    IKEP_13
    IKEP_14_new
    IKEP_15
    IKEP_16

Verify new RTEP IP tunnels status
    IKEP_1
    IKEP_2
    IKEP_3
    IKEP_4
    IKEP_5_new
    IKEP_6
    IKEP_7
    IKEP_8
    IKEP_9
    IKEP_10
    IKEP_11
    IKEP_12
    IKEP_13_new
    IKEP_14
    IKEP_15_new
    IKEP_16

IKEP_3_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_3_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     st10.marvels.dyn.com

IKEP_5_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_5_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_7_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     st12.marvels.dyn.com

IKEP_9_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_9_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn9.marvels.dyn.com

IKEP_13_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_13_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP_14_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_14_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     dyn11.marvels.dyn.com

IKEP_15_new
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_15_new}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify wrong FQDN tunnel status
    IKEP3_fqdn_fail
    IKEP7_fqdn_fail
    IKEP9_fqdn_fail
    IKEP14_fqdn_fail

IKEP3_fqdn_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointFQDN=${IKEP3_wrong_fqdn_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     NO_STATE
    ${remoteTunnelEndpointIP}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointIP
    Should Be Equal As Strings      ${remoteTunnelEndpointIP}     UNKNOWN

IKEP7_fqdn_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointFQDN=${IKEP7_wrong_fqdn_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     NO_STATE
    ${remoteTunnelEndpointIP}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointIP
    Should Be Equal As Strings      ${remoteTunnelEndpointIP}     UNKNOWN

IKEP9_fqdn_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointFQDN=${IKEP9_wrong_fqdn_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     NO_STATE
    ${remoteTunnelEndpointIP}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointIP
    Should Be Equal As Strings      ${remoteTunnelEndpointIP}     UNKNOWN

IKEP14_fqdn_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointFQDN=${IKEP14_wrong_fqdn_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     NO_STATE
    ${remoteTunnelEndpointIP}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointIP
    Should Be Equal As Strings      ${remoteTunnelEndpointIP}     UNKNOWN

Verify wrong RTEP IP tunnel status
    IKEP5_ip_fail
    IKEP13_ip_fail
    IKEP15_ip_fail

IKEP5_ip_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP5_wrong_IP_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP13_ip_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP13_wrong_IP_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP15_ip_fail
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP15_wrong_IP_value}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify Secondary FQDN tunnels status
    IKEP_7_new
    IKEP_9_new
    IKEP_14_new

Verify RTEP IP tunnels status
    IKEP1_ip
    IKEP7_ip
    IKEP9_ip
    IKEP14_ip

IKEP1_ip
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP7_ip
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP9_ip
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_9}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

IKEP14_ip
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_14}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify Multi TA FQDN tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${mta1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     mta1.marvels.dyn.com

Verify new Multi TA FQDN tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${mta2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     mta2.marvels.dyn.com

Verify new Multi TA IP tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${mta2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify Multi TA failure tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     NO_STATE
    ${remoteTunnelEndpointIP}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointIP
    Should Be Equal As Strings      ${remoteTunnelEndpointIP}     None

Get Inbound and Outbound SPI value
    ${IKE_Association1}=       Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESTABLISHED"
    Set Suite Variable    ${IKE_Association1}      ${stdout}
    ${Association_info1}=      Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESP SPIs"
    Set Suite Variable    ${Association_info1}      ${stdout}

Verify new Inbound and Outbound SPI value
    ${IKE_Association2}=       Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESTABLISHED"
    Set Suite Variable    ${IKE_Association2}      ${stdout}
    Should Not Be Equal     ${IKE_Association1}     ${IKE_Association2}
    ${Association_info2}=       Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESP SPIs"
    Set Suite Variable    ${Association_info2}      ${stdout}
    Should Not Be Equal     ${Association_info1}    ${Association_info2}

Verify same Inbound and Outbound SPI value
    ${IKE_Association3}=       Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESTABLISHED"
    Set Suite Variable    ${IKE_Association3}      ${stdout}
    Should Be Equal     ${IKE_Association1}     ${IKE_Association3}
    ${Association_info3}=       Admin_Common_Library.Execute command on ENodeB       ipsec status | grep "ESP SPIs"
    Set Suite Variable    ${Association_info3}      ${stdout}
    Should Be Equal     ${Association_info1}    ${Association_info3}

Perform Site Reset and verify tunnels
    Reset Bts
    Sleep   240
    Verify Ipsec Tunnels and Alarm status

Netact
    Setup Ems  config_device=netact1   alias=lab1042
    Configuration Manage  config_device=netact1    config=${disable_ipsec_nms}      plan_name=fw_plan       alias=lab1042   operation=edit
    Sleep   60
    Configuration Manage  config_device=netact1    config=${enable_ipsec_nms}      plan_name=fw_plan       alias=lab   operation=edit
    Sleep   60
    Teardown Ems  config_device=netact1   alias=lab

Verify IKE and IPSEC SA Rekeying
    Perform Recommissioning    type=delta      delta_file=${delta_config_IKE_rekeying}      skip_parameter_relation_errors=${True}
    Sleep   60
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   60
    Verify Ipsec Tunnels and Alarm status
    Get Inbound and Outbound SPI value
    Sleep   1500
    Verify Ipsec Tunnels and Alarm status
    Verify new Inbound and Outbound SPI value
    Perform Recommissioning    type=delta      delta_file=${delta_config_new_IKE_rekeying}      skip_parameter_relation_errors=${True}
    Sleep   60
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}
    Sleep   30
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_enable}
    Sleep   60
    Get Inbound and Outbound SPI value
    Sleep   300
    Verify Ipsec Tunnels and Alarm status
    Verify new Inbound and Outbound SPI value
    Perform Recommissioning    type=delta      delta_file=${delta_config_revert}      skip_parameter_relation_errors=${True}
    Sleep   30

Get Hostname
    [Documentation]    Get hosename of test machine
    ${output}      Run      hostname
    ${Hostname}    Replace String   string=${output}     search_for=-     replace_with=_
    Set Suite variable  ${Hostname}

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]    ${tl_name_only}

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   common_8128.Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable      ute:id:${external_scf_id}
    Set Suite Variable  ${external_scf_id}
    Set Tags  ${TC_ID}

common_8128.Request Scout SCF
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}