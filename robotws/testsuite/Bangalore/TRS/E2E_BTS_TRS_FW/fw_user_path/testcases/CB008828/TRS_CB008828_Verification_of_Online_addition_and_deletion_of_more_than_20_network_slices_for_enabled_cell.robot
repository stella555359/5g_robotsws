*** Settings ***
Documentation     [Procedure] "CB008828-A-d_Verification_of_Runtime_cell_setup_with_more_than_1024_network_slices"
...               [Date] "Date of creation 25-10-2023"
...               [Author] "Mansi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008828"
...               [Funtion_Hash_Tags] "Slices,AMF,gNB"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIM-118
...               [Validation Date] 25-10-2023


Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource          ${CURDIR}/resources/CB008828_common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${call_profile}             enable_20_slices_handover

*** Test Cases ***
[1]TRS_CB008828_Verification_of_Online_addition_and_deletion_of_more_than_20_network_slices_for_enabled_cell
    Perform Commissioning       scf_file=${basic_ipsec_handover}     verify_bts_status=False
    ...    timeout=400     alias=default
    Sleep       180
	Certificate Configure    operation=install_certificate	 cert_file=${IPsec_certificate}	 cert_type=BtsTrustChain
	...    cert_format=P12	password=nsnCERT
	Enable Ipsec on Admin
	Enable Ipsec on SecureGW
	Verify IPSEC Status      ESTABLISHED
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_handover
    Call Setup      5g=${call_profile}:data  parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_handover
	Verify NG and XN Link Status		1
	Verify All Network Slice Status
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_2000_slices
	Perform Recommissioning   type=delta    delta_file=${enable_2000_slice_with_profileDN}      timeout=300
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_2000_slices
	Add 2000 Network Slices on AMF and verify
	Verify Random Network Slice Status		1		1500		enabled
	Verify Random Network Slice Status		1501		2000	disabled
	Modify Tracking Area and Verify Slices
    Select Random Slices for Calls
	Perform and Verify Random Slice Calls with NRTRS Profile		${slice_list}
	Modify NRTRS Profile in SNSSAI
	Perform and Verify Random Slice Calls with NRTRS Profile		${slice_list}
    Select Random Slices for Calls
	Delete NRTRS Profile in SNSSAI
	Perform and Verify Random Slice Calls without NRTRS Profile		${slice_list}
    Verify All Network Slice Status
	Enable and Verify 2000 Network Slices without NRTRS Profile
	Select Random Slices for Calls
    Perform and Verify Random Slice Calls without NRTRS Profile     ${slice_list}
    Add NRTRS Profiles for Enabled Slices
	Perform and Verify Random Calls with XN Handover
