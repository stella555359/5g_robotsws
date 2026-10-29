*** Settings ***
Documentation

...		[Procedure]	"SR001941 Verification of Dynamic Inner IP address support in enb by peer secgw to non main operator with FQDN is configured
...      in ENB"
...		[Date]		"30-08-2023"
...		[Author]	"Dineshkumar"
...		[Feature_ID]	"SR001941"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"
...		[Funtion_Hash_Tags]		"IPSEC,LTE,CERT,IPv6,MORAN"
...		[Validated_TestLine] 	"BTS_ID-2356"

Library         ute_fsmaccess
Library        taf.sw.scout    WITH NAME   scout
Variables		ta_e2e_bts_trs_fw
Resource     taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource	${CURDIR}/../resources/common_keywords.robot
Resource    ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Variables ***
${IKEP_8}   2a00:8a00:a000:1105::a2b:1551
${IKEP_7}   172.16.202.21

*** Test Cases ***
[1][1.0] SR001941_Verification of Dynamic Inner_IP address support in enb by peer secgw_to_non_main_operator with FQDN is configured in ENB

	Perform Commissioning       scf_file=${1941_scf}   verify_bts_status=True     timeout=1200     alias=default
    Sleep   180
    Get Scout configuration
    Install Certificate
	Verify wireshark for DNS packets
    Verify Ipsec tunnel status
    Verify IPv4 FQDN
    Verify IPv6 FQDN
    Verify IPv4 IP
    Verify IPv6 IP
    Teardown testcase

*** Keywords ***
Verify wireshark for DNS packets
	    Perform Recommissioning     type=param     param_path=${ipsec_param}  operation=update    value=false
        Sleep   20
        Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated  uplane_capturing=True   timeout=120
        ...     alias=no_password
		Perform Recommissioning     type=param     param_path=${ipsec_param}  operation=update    value=true
        Sleep  60
        ${PointA_noPwd}=   Traffic Capture Stop   mode=file  alias=no_password  timeout=350
        Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=dns
	    [Teardown]      Run Keyword and Ignore Error	Traffic Capture Stop   mode=file  alias=no_password  timeout=350

Verify IPv4 FQDN
        Perform Recommissioning     type=param     param_path=${ikep_ipv4}  operation=update    value=${wrong_fqdn_value}
        sleep	60
		Verify Alarm    faultid=61654      should_exist=${true}    alias=default
		Perform Recommissioning     type=param     param_path=${ikep_ipv4}  operation=update    value=${correct_fqdn_ipv4}
        sleep   60
        Verify IPv4 FQDN tunnel status
        Verify Alarm    faultid=61654      should_exist=${false}    alias=default

Verify IPv6 FQDN
        Perform Recommissioning     type=param     param_path=${ikep_ipv6}  operation=update    value=${wrong_fqdn_value}
        sleep   60
        Verify Alarm    faultid=61654      should_exist=${true}    alias=default
        Perform Recommissioning     type=param     param_path=${ikep_ipv6}  operation=update    value=${correct_fqdn_ipv6}
        sleep   60
        Verify IPv6 FQDN tunnel status
        Verify Alarm    faultid=61654      should_exist=${false}    alias=default

Verify IPv4 IP
		Perform Recommissioning     type=param     param_path=${ikep_ipv4}  operation=update    value=${wrong_ipv4_value}
		sleep	60
		Verify Alarm    faultid=61030      should_exist=${true}    alias=default
        Perform Recommissioning     type=param     param_path=${ikep_ipv4}  operation=update    value=${correct_ipv4_value}
        sleep   60
        Verify IPv4 IP tunnel status
        Verify Alarm    faultid=61030      should_exist=${false}    alias=default
        Verify Alarm    faultid=61654      should_exist=${false}    alias=default

Verify IPv6 IP
        Perform Recommissioning     type=param     param_path=${ikep_ipv6}  operation=update    value=${wrong_ipv6_value}
        sleep   60
        Verify Alarm    faultid=61030      should_exist=${true}    alias=default
        Perform Recommissioning     type=param     param_path=${ikep_ipv6}  operation=update    value=${correct_ipv6_value}
        sleep   60
        Verify IPv6 IP tunnel status
        Verify Alarm    faultid=61030      should_exist=${false}    alias=default
        Verify Alarm    faultid=61654      should_exist=${false}    alias=default

Install Certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Cert_password}
    Sleep   60
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}

Get Scout configuration
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting        ${Hostname}

Get Hostname
  [Documentation]    Get hosename of test machine
  ${output}      Run      hostname
  ${Hostname}    Replace String   string=${output}     search_for=-     replace_with=_
   Set Suite variable  ${Hostname}

Link SCOUT SCF to Configuration ID for Reporting
  [Arguments]    ${tl_name_only}

   Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

  ${scout_testline_name}=    Set Variable    ${tl_name_only}
  ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
  ${TC_ID}=    Set Variable      ute:id:${external_scf_id}
   Set Suite Variable  ${external_scf_id}
   Set Tags  ${TC_ID}

Request Scout SCF
  [Arguments]  ${scout_testline_name}
  scout.setup_scout     scout_testline_name=${scout_testline_name}
  ${external_scf_id}=   scout.request_scf    use_scout_internal_id=True
  scout.teardown_scout_api
  [Return]   ${external_scf_id}

Teardown testcase
    Stop Syslog
    Disable_ipsec

Disable_ipsec
    Perform Recommissioning     type=param   param_path=${ipsec_path}     operation=update    value=${ipsec_disable}

Verify IPv6 FQDN tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_8}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     mail1.marvels.com

Verify IPv4 FQDN tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings  ${remoteTunnelEndpointFQDN}    www2.marvels.com

Verify IPv6 IP tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_8}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify IPv4 IP tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${IKEP_7}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
    ${remoteTunnelEndpointFQDN}=    Get From Dictionary     dictionary=${dict}      key=remoteTunnelEndpointFQDN
    Should Be Equal As Strings      ${remoteTunnelEndpointFQDN}     None

Verify Ipsec tunnel status
    Verify IPv4 FQDN tunnel status
    Verify IPv6 FQDN tunnel status