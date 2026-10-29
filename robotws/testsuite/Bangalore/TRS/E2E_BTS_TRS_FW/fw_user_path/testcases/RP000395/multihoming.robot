*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "RP000395"
...     [Funtion_Hash_Tags]     "IPv4 SCTP Multihoming"
...     [Procedure]             "Testcase check LTE - SCTP Multihoming and both primary and secondary MME IPs with proper routes "

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_RP000395_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1][2.0] TRS-SCTP_Multihoming-RP000395
     Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}     verify_bts_status=${False}        timeout=400
    Sleep    500
     Traffic Capture Start    capture_device=oam_device    mode=file     uplane_capturing=True
    ...     measurement_point=NE_Terminated     timeout=300     alias=SCTP_Multihoming-RP000395
	sleep	30
    Reset      operation=reset_rat      rat=lte     should_be_onair=${False}
    sleep  250
    Verify Bts Status      req_rat=lte      should_be_onair=${True}      wait_for=300
    sleep   200
	Block Primary Cplane
	sleep	200
	Verify Alarm        faultid=${fault_Num}        should_exist=${True}	timeout=200
	Unblock Primary Cplane
	sleep	120
    Verify Alarm        faultid=${fault_Num}        should_exist=${False}    timeout=200
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=SCTP_Multihoming-RP000395
    Verify Captured File   ${filemode_capture}

