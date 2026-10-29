*** Settings ***
Documentation
...		[Author]     	"Nandini R"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../../resources/common_keywords.robot
Library         SSHLibrary

*** Variables ***
${tc_variables}		testcase_variables.json

*** Keywords ***
Enable Ipsec on SecureGW
	Run		sudo ipsec start

Disable Ipsec on SecureGW
	Run		sudo ipsec stop

Enable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		param_path=${ipsec_enable_moc}	operation=update	value=true		timeout=300		alias=${alias}
	Sleep	120

Disable Ipsec on Admin
	[Arguments]		${alias}=default
	Perform Recommissioning		type=param		rat=lte		param_path=${ipsec_enable_moc}	operation=update	value=false		timeout=300
    ...	   alias=${alias}

Verify GTP alarm
    Verify Alarm        faultid=6150     rat=lte     should_exist=True   occurrences=2

Verify No GTP alarm
    Verify Alarm        faultid=6150     rat=lte     should_exist=${False}

Get Ipsec Tunnels Status
    [Arguments]    ${dut}=default
     @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}     alias=${dut}
    FOR    ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
        Log         ${ike_tunnel}
        ${parent_tunnel_stateInfo}=       Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
        ${parent_tunnel_proceduralState}=     Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
        Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END

     @{child_tunnel_moc_list} =  Query Admin Infomodel       query=get list ${ipsec_sa_l_moc_path}       alias=${dut}
    FOR    ${child_tunnel}    IN  @{child_tunnel_moc_list}
        Log         ${child_tunnel}
        ${child_tunnel_stateInfo}=  Get From Dictionary     dictionary=${child_tunnel}      key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary     dictionary=${child_tunnel_stateInfo}        key=proceduralState
        Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END

Execute command on ENodeB
    [Arguments]    ${cmd}           ${enb_ip}=192.168.255.129       ${enb_root_user}=toor4nsn    ${enb_root_passwd}=oZPS0POrRieRtu
    ${ssh_enb_handle}      SSHLibrary.Open Connection    ${enb_ip}
    SSHLibrary.Login                  ${enb_root_user}    ${enb_root_passwd}
    SSHLibrary.Switch Connection      ${ssh_enb_handle}
    ${stdout}  ${stderr}   SSHLibrary.Execute Command       ${cmd}    return_stdout=${True}  return_stderr=${True}
    Set Suite Variable    ${stdout}
    Set Suite Variable    ${stderr}
    SSHLibrary.Close Connection

Add IP Certificates
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain     cert_format=P12
    ...     password=${IP_BTSCertpass}
    Sleep    20
    Certificate Configure    operation=install_certificate    cert_file=${ca1pem}    cert_type=AdditionalCa      cert_format=PEM
    Sleep    20
