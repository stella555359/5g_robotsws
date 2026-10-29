*** Settings ***
Documentation
...	    [Procedure]		"The test case is planned to validate the lock and unlock of RMOD, NRDU AND NRCELL object with BTS reset."
...	    [Date]		"11-10-2022"
...	    [Author]		"Shweta"
...	    [Feature_ID] 	"SR001825"
...	    [Maintenance]	"TRS I & V Tools Bangalore Team"
...	    [Validated_TestLine]"CLASSICAL_5G - ASIM topologies"
...	    [Config_Comments] 	"5G classical mode SA configuration with IPv4"
...	    [Precondition] 	"BTS should be operational and on Air with NR RAT"
...	    [QC_Path]           "QC_Path in Test Plan"
...	    [QC_ID]		"QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

***Test Cases***
[1][1.0] Locking and unlocking of NRDU, RMOD and NRCELL objects with reset of BTS

#Step1
     Perform Commissioning       scf_file=${Full_Configuration}      verify_bts_status=True      timeout=400      alias=default
     Sleep   600

#Step2
    Perform Recommissioning     type=param    param_path=${NRCELL}    operation=update      value=Locked    timeout=300

#Step3
    Perform Recommissioning     type=param     param_path=${NRDU}    operation=update      value=Locked     timeout=300

#Step4
    Perform Recommissioning     type=param     param_path=${NRCELL}    operation=update      value=Unlocked    timeout=300

#Step5
    Perform Commissioning       scf_file=${SWTESERREQ_Configuration}      verify_bts_status=False      timeout=500      alias=default

#Step6
    Perform Recommissioning     type=param    param_path=${RMOD}    operation=update      value=Locked   timeout=300

#Step7
    Perform Recommissioning     type=param     param_path=${RMOD}    operation=update      value=Unlocked    timeout=300


#Step8
    Perform Recommissioning     type=param     param_path=${NRDU}    operation=update      value=Unlocked    timeout=300

#Step9
    Perform Commissioning       scf_file=${SWTESERREQ_Configuration}      verify_bts_status=True      timeout=600      alias=default

#Step10
    Perform Recommissioning     type=param    param_path=${RMOD}    operation=update      value=Locked  timeout=300

#Step11
    Perform Commissioning       scf_file=${SWTESERREQ_Configuration}      verify_bts_status=False      timeout=500      alias=default

#Step12
    Perform Recommissioning     type=param      param_path=${NRDU}    operation=update      value=Locked    timeout=300

#Step13
    Perform Commissioning       scf_file=${SWTESERREQ_Configuration}      verify_bts_status=False      timeout=500      alias=default

##Step14
    Perform Recommissioning     type=param     param_path=${NRDU}    operation=update      value=Unlocked  timeout=300

#Step15
    Perform Recommissioning     type=param      param_path=${RMOD}    operation=update      value=Unlocked   timeout=700
	Verify Bts Status   should_be_onair=${True}
