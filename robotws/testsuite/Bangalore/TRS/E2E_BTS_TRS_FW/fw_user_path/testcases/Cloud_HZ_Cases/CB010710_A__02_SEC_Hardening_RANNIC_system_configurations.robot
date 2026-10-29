*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722
...		[Feature ID]			5GC002072-C
...		[Validated_TestLine]	7-2-UTE5GCLOUDIAVTL03(10.58.66.134)
...		[Config_Comments]		Basic Configuration
...		[Funtion_Hash_Tags]		Security_Hardening

Force Tags		SBTS00		QCD_MN_RAN		QCP_RAN_VRF		CRT

Resource		${CURDIR}/resources/common_HZ_keywords.robot

Suite Setup			Setup Oamops        dut=vdu_cran12
Suite Teardown		Run Keywords	Collect Snapshot	dut=vdu_cran12		operation_timeout=300		AND
...					Teardown Oamops     dut=vdu_cran12	AND	Teardown Remote Access

*** Test Cases ***
[1][2.0] CB010710_A__02_SEC_Hardening_RANNIC_system_configurations
#Step1:
	Perform Recommissioning	    dut=vdu_cran12	type=delta      delta_file=${RANNIC_delta_file}     timeout=400
	Sleep   120
	Change the service account password
	Enable ssh tunnel
	Login to RANNIC
	Check ICMP Echo Ignore Broadcasts
	Check Disable ICMP Routing Redirects
	Check Memory Protection Settings
	Check Ip Source Routing
	Check Ip Forwarding
	Check RANNIC System Accounts
	Find Writeable Files
	Find Writeable Directories
	Check Whether Root Files Writable By Others
	Find Orphaned Files
	Check Permission for Passwd and Group file
	Check Permission for Shadow and Gshadow file
	Check SUID/GID Bit Set File
	Check Default Permission by Umask
	[Teardown]	Disable ssh tunnel