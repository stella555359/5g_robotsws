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
${routes}     ${CURDIR}/resources/2asik_fstsch_slicing.sh
${profile}        Configuration_QOS_Slicing_10_Operator
*** Test Cases ***
[1]CB010712_A_B1_TRS_Configuration_of_First_Level_Scheduler_Flow_Classifier_and_Networking_Slice_for_5G_SA_for_10_Operator
    Add Interfaces on VM
    Restore all Certificate
    Perform Commissioning       scf_file=${Configuration_scf_2ASIK_IPsec_basic_10-OP}     verify_bts_status=False     timeout=400
	Sleep   240
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_First_Level_Scheduler_Flow_Classifier_and_Networking_Slice}
    ...    timeout=600
    Sleep   180
    Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep   180
    Configure UE       5g=${profile}:data  command=enb_x2_link_up   target=2  enb=1
	Sleep    15
    Verify NG link Status      20
    Verify X2 link Status      1
    Verify Slice Status     enabled
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

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Preconditions
	Delete Interfaces

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

Verify Slice Status
    [Arguments]      ${Slice_State}
    ${slice_list}=    Query Admin Infomodel    query=get list //SNSSAI_R-*   timeout=180
    ${len}=    Get Length   ${slice_list}
    FOR   ${item}  IN  @{slice_list}
        ${state}=    Get From Dictionary   ${item}    operationalState
        Should be Equal   ${state}    ${Slice_State}
    END

Keyword to Run at end
    Run     sudo killall edaemon egate
	Run Keyword And Ignore Error         Traffic capture stop	alias=slice_${operator_str}
    Run Keyword And Ignore Error         Stop traffic and detach UE    ${operator}            ${profile}
	Delete Interfaces