*** Settings ***
Documentation     [Procedure] "CB010712_C_B2_TRS_Seperation_with_dedicated_SecGW_with_dedicated_PKI_with_Cross-Signed_CA_and_
...                            additional_Intermediate_CA"
...               [Date] "Date of creation 01-05-2024"
...               [Author] "Shreya"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB010712-A"
...               [Funtion_Hash_Tags] "RAN SHARING"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIK

Resource        ${CURDIR}/resources/CB010712_common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Variables ***
${routes}     ${CURDIR}/resources/2asik_ipsec_routes.sh
${profile}        Configuration_IPSec_SA_NSA_10_Operator
*** Test Cases ***
[1]CB010712_C_B2_TRS_Seperation_with_dedicated_SecGW_for_10_Operators_with_dedicated_PKI_with_Cross-Signed_CA_and_additional_Intermediate_CA
    Add Interfaces on VM
    Restore all Certificate
    Perform Commissioning       scf_file=${Configuration_scf_2ASIK_IPsec_basic_10-OP}     verify_bts_status=False     timeout=400
	Sleep   240
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_Ransharing_IPsec}      timeout=300
    Sleep   240
    Verify IPSec Status     NO_STATE
    Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled     operation=update     value=true    timeout=120
    Sleep   60
    Verify IPSec Status     NO_STATE
    Bring External Strongswans with Dedicated PKI using CA and TA
    Install Certificates on BTS for Dedicated PKI CA TA
    Verify IPSec Status     ESTABLISHED
    Verify IPSec Status after CMP Initialization
    Get IP Address
    Verify NGAP Messages
    Verify X2AP Messages       6
    Verify NG link Status      20
    Verify X2 link Status      6
	Perform Recommissioning     type=param     param_path=NRBTS-1:actDynamicFirewall     operation=update     value=true    timeout=180
	Sleep   60
	Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv4_ipsec}      timeout=300
	Trigger and Verify Random SA IPsec IPv4 call    1   10    4
	Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv6_ipsec}      timeout=300
	Trigger and Verify Random SA IPsec IPv6 call    1   10    4
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_nsa_ipsec}      timeout=300
    Trigger and Verify Random NSA IPsec call    1   6    4
    Disable IPSEC authentication with SHA1 digital signature certificates
	[TEARDOWN]    Keyword to Run at end

*** Keywords ***
Add Interfaces on VM
	Delete Interfaces
	Run     sh ${routes}

Get IP Address
	Get AMF IP Address       20
	Get NG-U IP Address      10
	Get NG-C IP Address      10
	Get X2-C IP Address      6
    Get S1-U IP Address      10

Disable IPSEC authentication with SHA1 digital signature certificates
   Perform Recommissioning     type=param     param_path=FEATCADM-1:ipsecSHA1DigitalSignDisable     operation=update     value=true   timeout=120
   Sleep  60
   ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1   timeout=30
   ${ikep_list}=    Evaluate    sorted(${ikep_list}, key=lambda x: x['remoteTunnelEndpointIP'] or '')
   ${current_tunnel_status}=      Create List
   FOR   ${item}  IN  @{ikep_list}
        ${state}=    Get From Dictionary   ${item}    ikePeerState
        Append To List    ${current_tunnel_status}     ${state}
   END
   Lists Should Be Equal       ${current_tunnel_status}    ${weak_algorithm_tunnel_status}
   Perform Recommissioning     type=param     param_path=FEATCADM-1:ipsecSHA1DigitalSignDisable     operation=update     value=false   timeout=120
   Sleep  30
   Verify IPSec Status     ESTABLISHED

Verify IPSec Status after CMP Initialization
    Perform Recommissioning     type=param     param_path=CMP-1:caSubjectName     operation=update     value=${CMP_subjectname}   timeout=90
    Sleep   120
    Certificate Configure       operation=install_cmp_certificate    timeout=120
    Sleep   10
    Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled     operation=update     value=false    timeout=120
    Sleep   60
    Verify IPSec Status     NO_STATE
    Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled     operation=update     value=true    timeout=120
    Sleep   60
    Verify IPSec Status     ESTABLISHED
    Certificate Configure       operation=cmp_update_key    timeout=120
    FOR   ${strongswan}  IN  @{strongswan_list}
         Setup Remote Access      remote_device=${strongswan}
         Execute Commands on Remote Device    ${restart_strongswan}
         Teardown Remote Access
    END
    Sleep   60
    Verify IPSec Status     ESTABLISHED
    [TEARDOWN]    Run Keyword And Ignore Error     Teardown Remote Access

Verify NGAP Messages
    Verify Alarm     faultid=7305   severity=critical     should_exist=True    occurrences=20
    Traffic capture start        capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=120
    ...  	 alias=ngap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    180
    ${pcap_file}=       Traffic capture stop	mode=file       timeout=120    alias=ngap
    FOR   ${operator}   IN RANGE   0   20
	    ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
		${amf_ip}=		Get from List     ${AMF_IP_List}       ${operator}
	    Get IP Version      ${amf_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END
    Verify Alarm     faultid=7305   should_exist=${False}
    [TEARDOWN]      Run Keyword And Ignore Error        Traffic capture stop    mode=file    timeout=120    alias=ngap

Verify X2AP Messages
    [Arguments]       ${operators}=1
	Traffic capture start         capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=120
    ...  		alias=x2ap
	FOR   ${operator}   IN RANGE   0   ${operators}
        ${index}=    Set Variable IF
         ...     ${operator} == 0     0
         ...     ${operator} == 1     2
         ...     ${operator} == 2     4
         ...     ${operator} == 3     6
         ...     ${operator} == 4     8
         ...     ${operator} == 5     10
	    ${enb}=      Evaluate      ${operator}+3
	    ${x2cplane_ip}=	Get from List     ${X2C_IP_List}       ${index}
	    Configure UE       5g=${profile}:data  command=enb_x2_link_up   target=2  enb=${enb}  x2_link_addr=${x2cplane_ip}
	    Sleep    15
    END
	${pcap_file}=       Traffic capture stop	mode=file       timeout=120   alias=x2ap
	FOR   ${operator}   IN RANGE   0   ${operators}
	    ${index}=     Set Variable IF
         ...     ${operator} == 0     0
         ...     ${operator} == 1     2
         ...     ${operator} == 2     4
         ...     ${operator} == 3     6
         ...     ${operator} == 4     8
         ...     ${operator} == 5     10
	    ${x2cplane_ip}=	Get from List     ${X2C_IP_List}       ${index}
	    Get IP Version      ${x2cplane_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=x2ap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=x2ap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END
    [TEARDOWN]      Run Keyword And Ignore Error        Traffic capture stop    mode=file       timeout=120   alias=x2ap

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Install Certificates on BTS for Dedicated PKI CA TA
   Certificate Configure     operation=install_certificate     cert_file=${cert_path}${Dedicated_PKI_TA_MLCA_Cert}     cert_type=BtsTrustChain
   ...    cert_format=P12     password=Nokia
   Sleep    60
   Verify Alarm      faultid=61644    severity=major     should_exist=${True}    occurrences=18
   FOR   ${cert}  IN  @{Dedicated_PKI_TA_additional_Cert}
         Certificate Configure      operation=install_certificate   cert_file=${cert_path}${cert}     cert_type=AdditionalCa    cert_format=PEM
         Sleep  10
   END
   Sleep  30
   Verify Alarm      faultid=61644    should_exist=${False}

Bring External Strongswans with Dedicated PKI using CA and TA
    FOR   ${strongswan}  IN  @{strongswan_list}
         Setup Remote Access      remote_device=${strongswan}
         Execute Commands on Remote Device    ${${strongswan}_dedPKI_CA_TA_commands}
         Teardown Remote Access
    END
    [TEARDOWN]    Run Keyword And Ignore Error     Teardown Remote Access

Execute Commands on Remote Device
   [Arguments]      ${command_list}
   Log    ${command_list}
   FOR   ${command}  IN  @{command_list}
        Remote Command Execute     command=${command}
   END

Verify IPSec Status
    [Arguments]      ${IKEP_State}
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1   timeout=30
    ${len}=    Get Length   ${ikep_list}
    FOR   ${item}  IN  @{ikep_list}
        ${state}=    Get From Dictionary   ${item}    ikePeerState
        Should be Equal   ${state}    ${IKEP_State}
    END

Verify NG link Status for 10 Operator
	FOR   ${operator}   IN RANGE   1   21
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
		   ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Verify Xn link Status for 10 Operator
	FOR   ${operator}   IN RANGE   1   21
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${Xn_status}=      Query Admin Infomodel    query=get object ${Xn_link_path}-${operator_str}
          ${Xn_link_status}=       Get From Dictionary     ${Xn_status}      xnLinkStatus
          Should Be Equal    ${Xn_link_status}      available
    END

Delete Routes from External Strongswan
	FOR   ${strongswan}  IN  @{strongswan_list}
         Setup Remote Access      remote_device=${strongswan}
         Execute Commands on Remote Device    ${external_strongswan_delete_routes}
         Teardown Remote Access
	END
    [TEARDOWN]    Run Keyword And Ignore Error     Teardown Remote Access


Keyword to Run at end
    Run     sudo killall edaemon egate
	Run Keyword And Ignore Error         Traffic capture stop	alias=slice_${operator_str}
    Run Keyword And Ignore Error         Stop traffic and detach UE    ${operator}            ${profile}
	Delete Interfaces
    Delete Routes from External Strongswan