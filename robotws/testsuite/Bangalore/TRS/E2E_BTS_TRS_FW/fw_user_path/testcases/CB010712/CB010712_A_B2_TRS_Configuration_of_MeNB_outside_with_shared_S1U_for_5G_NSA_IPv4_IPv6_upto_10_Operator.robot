*** Settings ***
Documentation
...		[Author]     		        "Shreya C"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "20:05:2024"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB010712, CB006557"
...     [Validated_TestLine]        "KVM53-TRSIV-TL012"
...		[Procedure]   		        "CB010712_A_B2_TRS_Configuration_of_MeNB_outside_with_shared_S1U_for_5G_NSA_IPv4_IPv6_upto_10_Operator"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config_Comments]           "TRS_Configuration_of_MeNB_outside_with_shared_S1U_for_5G_NSA_IPv4_IPv6_upto_10_Operator"
...     [Function_Hash_Tags]        "NSA 10 Operator RAN Sharing, Shared S1U"

Resource        ${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${profile}         MeNB_outside_Shared_S1U
${routes}          ${CURDIR}/resources/MeNB_outside_Shared_S1U.sh
*** Test Cases ***
[1]CB010712_A_B2_TRS_Configuration_of_MeNB_outside_with_shared_S1U_for_5G_NSA_IPv4_IPv6_upto_10_Operator
    Add Interfaces on VM
	Perform Commissioning       scf_file=${Configuration_scf_basic}   verify_bts_status=False     timeout=600     alias=default
    Sleep       240
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_6op_MeNB_outside_shared_s1U}      timeout=300
    Sleep       180
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_10op_MeNB_outside_shared_s1U}      timeout=300
    Sleep       180
	Get IP Address
    Verify NGAP and S1AP Messages
	Trigger and Verify Random NSA call     1       10      3
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Trigger and Verify Random NSA call
	[Arguments]       ${start}=1      ${end}=1     ${operators}=1
    ${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	FOR   ${operator}   IN     @{operator_list}
	     ${ue}=     Evaluate     ${operator}+10
	     ${target_cell}=    Set Variable If    1<=${operator}<=6     1
	      ...     7<=${operator}<=10       2
         Traffic capture start           capture_device=l2_wireshark 		alias=operator_NSA
	     Attach DC UE to outside MeNB and send ul dl traffic   ${profile}   ${ue}     2     ${target_cell}
	     Stop traffic and detach DC UE        ${profile}    ${ue}
         ${pcap_file}=       Traffic capture stop	  alias=operator_NSA
         ${s1uplane_ip}=    Get from List      ${S1U_IP_List}     1
	     Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_ul_dl
    END

Get IP Address
    Get X2-C IP Address
	Get S1-U IP Address

Add Interfaces on VM
	Delete Interfaces
	Run     sh ${routes}

Verify NGAP and S1AP Messages
    Sleep    180
    Traffic capture start           capture_device=l2_wireshark 		alias=ngap_s1ap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    240
	Configure UE       5g=${profile}:data  command=enb_x2_link_up   enb=3   target=2
	Sleep    60
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
	${x2cplane_ip}=   Get from list       ${X2C_IP_List}        1
	Analyse Pcap        pcap_filename=${pcap_file}        analysis=x2ap_setup_ipV6
	Analyse Pcap        pcap_filename=${pcap_file}        analysis=x2ap_response_ipV6
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=ngap_s1ap

Keyword to Run at end
    Run     sudo killall edaemon egate
	Delete Interfaces