*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010762"
...     [Funtion_Hash_Tags]     "IPv4 SCTP Multihoming"
...     [Procedure]             "Testcase check LTE - SCTP Multihoming and both primary and secondary MME IPs with proper routes"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CB010762_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1]TRS_CB010762_B2_Verification_of_SCTP_association_for_10_operators_with_SCTP_multihoming

    Perform Commissioning    scf_file=${Multihoming_V4}   skip_parameter_relation_errors=${True}   verify_bts_status=${False}    timeout=400
    sleep   120
    Verify Bts Status       req_rat=lte     should_be_onair=${True}     wait_for=600
    Verify S1Link status is up for all 10 operators
    Traffic Capture Start     capture_device=oam_device       mode=file     uplane_capturing=True
    ...     measurement_point=NE_Terminated        timeout=180      alias=Multihoming_V4
    sleep   120
    Reset      operation=reset_rat      rat=lte     should_be_onair=${False}
    sleep  250
    Verify Bts Status       req_rat=lte     should_be_onair=${True}     wait_for=600
    Verify S1Link status is up for all 10 operators
	Block Primary Cplane of all IPV4 10 Operators
	sleep	300
	Verify Alarm        faultid=${fault_Num}        should_exist=${True}	timeout=200     occurrences=10
	Unblock Primary Cplane of all IPV4 10 Operators
	sleep	300
    Verify Alarm        faultid=${fault_Num}        should_exist=${False}    timeout=200
    Verify S1Link status is up for all 10 operators
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=Multihoming_V4
    Verify Captured File for Singlehoming_V4    ${filemode_capture}
    Verify Captured File for Multihoming_V4     ${filemode_capture}