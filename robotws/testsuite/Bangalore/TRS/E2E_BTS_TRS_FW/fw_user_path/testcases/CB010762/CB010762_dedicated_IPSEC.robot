*** Settings ***
Documentation     [Procedure] "CB010762_B_B2_TRS_Seperation_with_dedicated_SecGW_with_dedicated_PKI"
...               [Date] "Date of creation 01-05-2024"
...               [Author] "Pranitha"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB010762-B"
...               [Funtion_Hash_Tags] "RAN SHARING"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIL

Resource          ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_keywords_CB010762.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${routes}     ${CURDIR}/resources/ASIL_ipsec_routes.sh

*** Test Cases ***
[1]CB010762-B_B1_Feature_10_operators_dedicated_secgw_IPSEC_common_PKI_and_cross_signed_CA_IPV4_IPV6
    	Add Interfaces on VM
    	Restore all Certificate
	Perform Commissioning       scf_file=${basic_6op}    verify_bts_status=False     timeout=400
  	Sleep       180
	Perform Recommissioning     type=delta      delta_file=${10op_CB010762}     timeout=300
	Sleep   120
	Verify IPSec Status     NO_STATE
    	Perform Commissioning       type=delta      delta_file=${ASIL_IPsec_basic}     verify_bts_status=False     timeout=400
	Sleep   240
    	Perform Recommissioning     type=param     param_path=IPSECC-1:ipSecEnabled     operation=update    value=true   timeout=60
    	Sleep   60
    	Verify IPSec Status     CONNECTING
    	Bring External Strongswans with Dedicated PKI using CA and TA
    	Install Certificates on BTS for Dedicated PKI CA TA
    	Verify IPSec Status     ESTABLISHED
    	Get IP Address
	Perform Recommissioning     type=param     param_path=IPSECC-1:actDynamicFirewall    operation=update     value=true   timeout=180
	Sleep   60
	Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv4_ipsec}      timeout=300
	Randomize Additional operators			1		6
	Make LTE call and verify for each operators			11
	Randomize Additional operators			7		10
   	Make LTE call and verify for each operators			12
	Perform Recommissioning     type=delta    delta_file=${Configuration_delta_ipv6_ipsec}      timeout=300
	Randomize Additional operators			1		6
	Make LTE call and verify for each operators			11
	Randomize Additional operators			7		10
   	Make LTE call and verify for each operators			12
	[TEARDOWN]    Keyword to Run at end


*** Keywords ***
Add Interfaces on VM
	Delete Interfaces
	Run     sh ${routes}

Get IP Address
	Get MME IP Address     10
	Get LTE-C IP Address    ipV4    10
	Get LTE-U IP Address    ipV4    10
	Get SGW IP Address      10

Verify NGAP Messages
    Verify Alarm     faultid=7305   severity=critical     should_exist=True    occurrences=20
    Traffic capture start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True} timeout=120 alias=ngap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    180
    ${pcap_file}=       Traffic capture stop	mode=file       timeout=120    alias=ngap
    FOR   ${operator}   IN RANGE   0   20
	    ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
	    ${amf_ip}=		Get from List     ${AMF_IP_List}       ${operator}
	    Get IP Version      ${amf_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_setup_${version}    filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_response_${version}  filter_file_name=${traffic_filter_file_name}
	END
    Verify Alarm     faultid=7305   should_exist=${False}
    [TEARDOWN]      Run Keyword And Ignore Error        Traffic capture stop    mode=file    timeout=120    alias=ngap

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Install Certificates on BTS for Dedicated PKI CA TA
   Certificate Configure     operation=install_certificate   cert_file=${cert_path}  cert_type=BtsTrustChain     cert_format=P12     password=Nokia
   Sleep    60
   Verify Alarm      faultid=61644    severity=major     should_exist=${True}    occurrences=18
   FOR   ${cert}  IN  @{Dedicated_PKI_TA_additional_Cert}
         Certificate Configure      operation=install_certificate   cert_file=${cert_path}${cert}    cert_type=AdditionalCa    cert_format=PEM
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

Preconditions
	Delete Interfaces
	FOR   ${IP}  IN   @{eth3_IPv4}
	    Run      sudo ip addr add ${IP} dev eth3
	END

	FOR   ${vlan}  IN   @{eth3_vlan_Ipv4}
	    ${ip}=    Get From Dictionary       ${eth3_vlan_Ipv4}     ${vlan}
	    Run   sudo ip link add link eth3 name eth3.${vlan} type vlan id ${vlan}
        Run   sudo ip addr add ${ip} dev eth3.${vlan}
        Run   sudo ip link set dev eth3.${vlan} up
    END

	FOR   ${vlan}  IN   @{vlan_xnc}
	    ${ip}=    Get From Dictionary       ${vlan_xnc}     ${vlan}
	    Run   sudo ip addr add ${ip} dev eth3.${vlan}
	END

	FOR   ${vlan}  IN   @{vlan_xnu}
	    ${ip}=    Get From Dictionary       ${vlan_xnu}     ${vlan}
	    Run   sudo ip addr add ${ip} dev eth3.${vlan}
	END

Delete IP Interface from eth3
    [Arguments]      ${IP_list}
	FOR   ${IP}  IN   @{IP_list}
		Run     sudo ip a delete ${IP} dev eth3
	END

Delete Vlan Interface of eth3
    [Arguments]      ${Vlan_list}
	FOR   ${vlanid}  IN   @{Vlan_list}
	   Run    sudo ip link delete dev ${vlanid}
	END

Delete Interfaces
	${IPv4}=     Run    ip -4 addr show eth3 | grep -i "global" | awk '{print $2}'
	@{IPv4_list}=     Split String      ${IPv4}

	Delete IP Interface from eth3     ${IPv4_list}

	${vlan}=   Run   ip a s | grep -i "global eth3." | awk '{print $5}'
	@{Vlan_list}=     Split String      ${vlan}

	Delete Vlan Interface of eth3    ${Vlan_list}

Keyword to Run at end
    Run     sudo killall edaemon egate
	Run Keyword And Ignore Error         Traffic capture stop	alias=slice_${operator_str}
    Run Keyword And Ignore Error         Stop traffic and detach LTE UE    ${operator}            ${profile}
	Delete Interfaces

Randomize Additional operators
	[Arguments]		${start}	${End}
    ${operators}=         Evaluate    random.sample(range(${start}, ${End}), 1)    random
    Set Suite Variable      ${operators}        ${operators}

Make LTE call and verify for each operators
	[Arguments]    	${cell}
	FOR  ${operator}   IN   @{operators}
		${index}= 		Evaluate	${operator}-1
	    ${operator_str}= 	Convert To String	${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator_str}
	    Attach LTE UE with operator and send ul dl traffic      ${operator}      ${profile}	     ${cell}
		Verify Alarm		faultid=${gtpu_alarm}	 	occurrences=${0}		should_exist=${False}
		Verify Alarm		faultid=${s1_interface}	 	occurrences=${0}		should_exist=${False}
	    Stop traffic and detach LTE UE          ${operator}      ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator_str}
	    ${mme_ip}=     Get from List        ${MME_IP_List}     ${index}
	    ${sgw_ip}=     Get from List        ${SGW_IP_List}     ${index}
	    ${cplaneIp}=   Get from List        ${LTE_C_IP_List}     ${index}
	    ${uplaneIp}=   Get from List        ${LTE_U_IP_List}     ${index}
	    Get IP Version      ${mme_ip}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_request_${version}    filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=s1ap_attach_accept_${version}     filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_ul_${version}   filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap      pcap_filename=${pcap_file}      analysis=lte_call_dl_${version}   filter_file_name=${traffic_filter_file_name}
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator_str}
