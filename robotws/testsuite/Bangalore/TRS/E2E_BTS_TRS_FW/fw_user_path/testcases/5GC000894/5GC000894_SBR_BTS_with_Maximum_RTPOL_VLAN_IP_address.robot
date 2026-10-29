*** Settings ***
Documentation
	...		[Procedure]             "The test case is to verify functionality of source based routing with maximum configuration"
    ...     [Date]                  "09-05-2025"
    ...     [Author]                "Mansi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Source Based Routing"
    ...     [Feature_ID]            "5GC000894"
    ...     [Validation_status]     "Tested"
    ...     [Validated_TestLine]    "5G-9003"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource	${CURDIR}/resources/5GC000894_common_keywords.robot
Library    taf.sw.scout    WITH NAME    scout


Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown


***Test Cases***
[1][1.0] 5GC000894_ASIB_SBR_BTS commission with Maximum RTPOL, VLAN and IP address configuration
		${alarms_before_feature}             Verify Alarm
        Perform Commissioning       scf_file=${SBR_functionality}     verify_bts_status=False     timeout=400     alias=default
        Sleep   360
		Perform Recommissioning   type=delta    delta_file=${Maximum_VLANIF}     timeout=300
        Sleep   30
        Perform Recommissioning   type=delta    delta_file=${Maximum_IPIF}     timeout=300
        Sleep   90
        Perform Recommissioning   type=delta    delta_file=${Maximum_IPRT}     timeout=300
        Sleep   30
        Perform Recommissioning   type=delta    delta_file=${Maximum_IPRTv6}     timeout=300
		Sleep   30
		Perform Recommissioning   type=delta    delta_file=${Maximun_RTPOL}     timeout=300
		Sleep   30
		Reset Bts        verify_bts=False		should_be_onair=False    wait_for=300
        Verify if IPV4 address is configured in gui
        Verify if IPV6 address is configured in gui
        Setup Remote Access    remote_device=bts
        Check 138 IPV4 RTPOL are configured in board
        Check 138 IPV6 RTPOL are configured in board
        Teardown remote Access

		[Teardown]      Keywords to run at end
		Verify Alarm      prev_alarms=${alarms_before_feature}              check_unexpected_alarms=${True}