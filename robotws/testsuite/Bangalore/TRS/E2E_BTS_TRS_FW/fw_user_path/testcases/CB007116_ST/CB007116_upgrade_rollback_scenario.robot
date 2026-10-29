*** Settings ***
Documentation
...	    [Procedure]				"The test case performs commissioning and verifies config of CB007116 parameters. SCTP, E2AP procedures also verified."
...	    [Date]					"13-07-2022"
...	    [Author]				"Sharavathi & Vishal"
...	    [Feature_ID] 			"CB007116"
...	    [Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags] 	"E2LINK_RIC"
...	    [Validated_TestLine] 	"CLASSICAL_5G - ASIB, ASIL, ASIK, ASOE topologies"
...	    [Config_Comments] 		"5G classical mode SA configuration with IPv4"
...	    [Precondition] 			"BTS should be operational and on Air with NR RAT"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007116_utilities.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

*** Test Cases ***
[1]CB007116_upgrade_rollback_scenario
    Perform Commissioning       scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
    Sleep    300

    Setup Ems  config_device=netact   alias=lab1042
    Cm Upload   config_device=netact   alias=lab1042

    Verify Bts Status   should_be_onair=${True}
    Verify E2 interface alarms        ${False}

    Software Manage     config_device=netact        operation=Provision      package=${sw_package}      alias=lab1042
    Sleep   300
    Verify Bts Status   should_be_onair=${True}
    Verify E2LinkStatus     Unlocked    active
    Verify E2 interface alarms        ${False}

    Rollback Software From EMS       config_device=netact       dist_names=PLMN-PLMN/MRBTS-${bts_id}    alias=lab1042
    Sleep   300
    Verify Bts Status   should_be_onair=${True}
    Verify E2 interface alarms        ${False}
    Verify E2LinkStatus     Unlocked    active

    [Teardown]      Run Keyword     Teardown Ems      config_device=netact       alias=lab1042
