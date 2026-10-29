*** Settings ***

Documentation
...		[Author]     			"Meghana J"
...		[Maintenance]			"TRS I & V Tools Bangalore Team"
...		[QC_Path]               "QC_Path in Test Plan"
...		[QC_ID]					"QC_ID in Test Lab for reporting"
...		[Feature_ID] 			"NCDR"
...		[Procedure]   			"IPSEC_NCDR_INV"
...     [Precondition]          "ASIB+ABIL+ABIA"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/IPSEC_NCDR_common_keywords.robot

Force Tags  CLOUD_F CA_E2ET_BTSTRSPZ    SBTS00  SBTS25R1    RAN_4G  RAN_4G_FDD  QCD_MN_RAN  QCP_RAN_VRF CRT     QCD_MN_RAN      QCP_RAN_VRF

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test Cases***
[1]Verification_of_BTS_upgrade_and_Rollback_with_25_iteration
    Perform IPSEC Commisioning
    FOR    ${upgrade_iter}    IN RANGE    0    ${upgrade_iter}
	${DSCP}=    Get Iteration DSCP    ${upgrade_iter}
	    Perform Recommissioning		type=param	param_path=MPLANENW-1:mPlaneDscp	operation=update	value=${DSCP}
	    ...        timeout=300
        ${MPLANEdscp}=     Get Parameter     param_path=MPLANENW-1:mPlaneDscp
	    Should Be Equal As Strings    ${MPLANEdscp}    ${DSCP}
        Perform software download and update   package=${profile}   should_activate=True    timeout=2400
        Sleep    300
		Verify Bts Status    should_be_onair=${True}      timeout=600
		Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default
		Verify Established Tunnels    ${tunnels_number}
        Mplane ping test
        ${MPLANEdscp}=     Get Parameter     param_path=MPLANENW-1:mPlaneDscp
	    Should Be Equal As Strings    ${MPLANEdscp}    ${DSCP}
	    Perform Recommissioning		type=param	param_path=MPLANENW-1:mPlaneDscp	operation=update	value=30
	    ...        timeout=300
        Mplane ping test
        Rollback Software   timeout=1000
        Sleep    300
		Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default
		Verify Established Tunnels    ${tunnels_number}
        ${MPLANEdscp}=     Get Parameter     param_path=MPLANENW-1:mPlaneDscp
        Should Be Equal As Strings    ${MPLANEdscp}    ${DSCP}
        Mplane ping test
	    ${MPLANEdscp}=     Get Parameter     param_path=MPLANENW-1:mPlaneDscp
	    Should Be Equal As Strings    ${MPLANEdscp}    ${DSCP}
		Verify Alarm    faultid=4590    should_exist=${False}
        Verify Alarm    faultid=7504    should_exist=${False}
    END