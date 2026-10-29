*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate TRS_Security-Certificate_Based_Authentication"
    ...     [Date]                  "31-08-25"
    ...     [Author]                "Shivani Patil"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"TL-1"
    ...     [Config]    "This script verifies long duration call test with fronthaul feature flag enabled"
    ...     [RunTime Parameters]    "[bts_id used is 1]"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/common_keywords_PET.robot
Library         ${CURDIR}/resources/egate_library.py

Suite Setup     Run Keywords                    Setup Oamops
               ...     AND    Start Syslog     ${EXECDIR}/execution_logs    background_syslog.txt      alias=collect_syslog
Suite Teardown     Run Keywords              Teardown Oamops
                ...            AND       Stop Syslog       alias=collect_syslog

*** Test Cases ***
[1] Verify long duration call test with fronthaul feature flag enabled
    Load base scf
    Sleep    300
    Verify RMOD is up
    Make 5G Calls FH

    Delete Logs From Current VM
    Enable 6114 FH ipsec
    Verify Calls Working

    Delete Logs From Current VM
    Enable 5832 LBM functionality and verify working
    Verify Calls Working
    Stop Calls

    Delete Logs From Current VM
    Enable 6436 FH Firewall and verify
    sleep    500
    Make 5G Calls FH
    Verify Calls Working
    Stop Calls

    Delete Logs From Current VM
    Enable 8016 Mplane IP traffic routing between Fronthaul and Backhaul
    sleep    500
    Make 5G Calls FH
    Verify Calls Working
    Stop Calls

    Delete Logs From Current VM
    Enable 6533 actEcpriMplaneIpv6 flag
    sleep    500
    Make 5G Calls FH
    Verify Calls Working
    Stop Calls

    Delete Logs From Current VM
    Enable 7255 actECPRITransportForORANAndTSN flag
    Make 5G Calls FH
    Verify Calls Working

    Delete Logs From Current VM
    Verify Call Stability
    Stop Calls
    Verify BTS Status      should_be_onair=${True}     rat=5g
