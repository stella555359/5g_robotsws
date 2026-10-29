*** Settings ***
Documentation
...	[Procedure]				"The test case performs commissioning and verifies max cell config of CB010449, SCTP, E2AP procedures also verified."
...	[Date]					"28-01-2025"
...	[Author]				"P Dineshkumar"
...	[Feature_ID] 			"CB010449"
...	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	[Validated_TestLine] 	"Classical_5G_4G_BTS-ASIL+ABIQ, AP-ASIL+ABIO topologies"
...	[Precondition] 			"BTS should be operational and on Air with NR RAT"
...	[QC_Path]               "QC_Path in Test Plan"
...	[QC_ID]					"QC_ID in Test Lab for reporting"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB010449_utilities.robot
Resource    	${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource	    ${CURDIR}/../resources/Admin_Common_Library.robot
Resource	    ${CURDIR}/../resources/common_emssim.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keyword And Ignore Error    Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

***Test Cases***
[1]CB010449-G#5 Verification of max configuration for ABIQ

    Upgrade SW build
    Get System Module HW Variant
    Perform IP Configuration on VM
    Configure and Verify NR FDD + LTE FDD split
    Configure and Verify NR FDD + NR TDD split
    Configure and Verify LTE FDD + NR TDD split