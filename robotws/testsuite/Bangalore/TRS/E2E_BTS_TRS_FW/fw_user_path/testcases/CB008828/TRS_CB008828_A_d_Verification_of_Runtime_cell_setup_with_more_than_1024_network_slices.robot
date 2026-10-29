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
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource          ${CURDIR}/resources/CB008828_common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${call_profile}          enable_2000_slices_ransharing

*** Test Cases ***
[1]TRS_CB008828_Verification_of_Runtime_cell_setup_with_more_than_1024_network_slices
    Perform Commissioning       scf_file=${Configuration_scf_basic_ransharing}     verify_bts_status=False
    ...    timeout=400     alias=default
    Sleep     120
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface     uplane_capturing=${True}
    ...    timeout=120   alias=point_A_20
    Call Setup      5g=${call_profile}:data    parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Sleep       200
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_20
    Verify NG and XN Link Status    6
    Verify Messages in wireshark for 20 Slices   ${Point_B_Capture}      6
    Verify All Network Slice Status
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
    ...    timeout=120   alias=point_A_2000
    Perform Recommissioning   type=delta    delta_file=${enable_2000_slices_ransharing_with_profileDN}     timeout=300
    Sleep    120
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_2000
    Verify NG and XN Link Status    6
    Verify All Network Slice Status
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}     6
	Verify Supported Slices on AMF       ${slices_supported_ransharing_dual_stack_amf}
	Perform and Verify Random Calls with Ransharing
