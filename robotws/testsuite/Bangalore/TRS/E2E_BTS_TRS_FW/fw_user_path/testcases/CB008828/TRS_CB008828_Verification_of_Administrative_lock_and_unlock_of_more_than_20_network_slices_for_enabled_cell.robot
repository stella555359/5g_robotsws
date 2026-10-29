*** Settings ***
Documentation     [Procedure] "TRS_CB008828_Verification_of_Administrative_lock_and_unlock_of_more_than_20_network_slices_for_enabled_cell"
...               [Date] "Date of creation 25-10-2023"
...               [Author] "Mansi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008828"
...               [Funtion_Hash_Tags] "Slices,AMF,gNB"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIB_FR_58
...               [Validation Date] 25-10-2023


Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource          ${CURDIR}/resources/CB008828_common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Variables ***
${call_profile}          Configuration_2000_Slices

*** Test Cases ***
[1]TRS_CB008828_Verification_of_Administrative_lock_and_unlock_of_more_than_20_network_slices_for_enabled_cell
    Perform Commissioning       scf_file=${basic_scfc}     verify_bts_status=False     timeout=400     alias=default
    Sleep     180
	Traffic capture start           capture_device=vm_eth3_interface 		alias=point_B_20
    Call Setup      5g=${call_profile}:data    parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Sleep       200
	${Point_B_Capture}=   Traffic capture stop	  alias=point_B_20
    Verify NG and XN Link Status    1
    Verify All Network Slice Status
	Enable and Verify 2000 Network Slices without NRTRS Profile
	Select Random Slices for Calls
	Perform and Verify Random Slice Calls without NRTRS Profile     ${slice_list}
	Add NRTRS Profiles for Enabled Slices
	Lock 1900 Network Slices and Verify
	Unlock 1900 Network Slices and Verify
	Perform and Verify Random Slice Calls with NRTRS Profile        ${slice_list}
    Delete 100 Enabled Slices and Verify
	Reset     operation=reset_bts       verify_bts=true     should_be_onair=false     timeout=300
	Sleep     360
	Verify All Network Slice Status
