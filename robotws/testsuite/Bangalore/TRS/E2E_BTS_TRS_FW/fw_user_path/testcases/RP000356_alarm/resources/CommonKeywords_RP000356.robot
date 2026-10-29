*** Settings ***
Documentation
...     [Author]        "Vivin"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../../resources/Common_Wireshark_Capture.robot
Resource        ${CURDIR}/../../resources/common_keywords.robot
Library			ute_fsmaccess
Library			Collections
Library			String
Library     	XML     lxml=True



*** Keywords ***
Verify Ipsec Tunnel Status
    [Documentation]     This test case keyword is to verify IPSec tunnels status
    @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}
    FOR     ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
        ${parent_tunnel_proceduralState}=   Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'    timeout=800
    END

    @{child_tunnel_moc_list} =  Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}
    FOR     ${child_tunnel}     IN      @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary     dictionary=${child_tunnel}      key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'   timeout=800
    END


Dead Peer Alarm Validation
	Comment		Disable IPSec in secgw
    Run     sudo ipsec stop
    Sleep    60
	Comment		Dead Peer Detected. (61030)
    Verify Alarm    faultid=61030    occurrences=8
    Run     sudo ipsec start            #Enable IPSec in secgw
    Sleep    60
	Comment		Dead Peer Detected. (61030)/Alarm not present
    Verify Alarm    faultid=61030    should_exist=${False}


IKE Auth Alarm Validation
    Certificate Configure    operation=install_certificate    cert_file=${invalid_ipsec_cert}    cert_type=BtsTrustChain    cert_format=P12
    ...     password=${invalid_ipsec_cert_password}
    Sleep    30
	Comment		IKE authentication failure. (61644)
    Verify Alarm    faultid=61644    occurrences=8
    Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert}    cert_type=BtsTrustChain    cert_format=P12
    ...     password=${valid_ipsec_cert_password}
    Sleep    30
	Comment		IKE authentication failure. (61644)/Alarm not present
    Verify Alarm    faultid=61644    should_exist=${False}


IPSec SA Mismatch Alarm Validation
    Perform Recommissioning     type=delta       delta_file=${deltascf_secpol_wrong_modify}        skip_parameter_relation_errors=${True}
    ...       timeout=300
    Sleep    30
	Comment		IPSec SA failure. (61646)
    Verify Alarm    faultid=61646    occurrences=2
    Perform Recommissioning     type=delta       delta_file=${deltascf_secpol_revert_modify}        skip_parameter_relation_errors=${True}
    ...       timeout=300
    Sleep    30
	Comment		IPSec SA failure. (61646)/Alarm not present
    Verify Alarm    faultid=61646    should_exist=${False}


IKE SA Mismatch Alarm Validation
	Comment		IKEP_wrong_modify
    Perform Recommissioning     type=param      param_path=IPSECC-1/IKEP-50:ikeEncryptionMethod      operation=update
    ...     value=${ikeEncryptionMethod_modify_wrong}    timeout=300
	Comment		IKEP_wrong_modify
    Perform Recommissioning     type=param      param_path=IPSECC-1/IKEP-60:ikeEncryptionMethod      operation=update
    ...     value=${ikeEncryptionMethod_modify_wrong}    timeout=300
    Sleep    30
	Comment		IKEP SA failure. (61645)
    Verify Alarm    faultid=61645    occurrences=2

	Comment		IKEP_revert_modify
    Perform Recommissioning     type=param      param_path=IPSECC-1/IKEP-50:ikeEncryptionMethod      operation=update
    ...     value=${ikeEncryptionMethod_modify_revert}    timeout=300
	Comment		IKEP_revert_modify
    Perform Recommissioning     type=param      param_path=IPSECC-1/IKEP-60:ikeEncryptionMethod      operation=update
    ...     value=${ikeEncryptionMethod_modify_revert}    timeout=300
    Sleep    30
	Comment		IKEP SA failure. (61645)/Alarm not present
    Verify Alarm    faultid=61645    should_exist=${False}


