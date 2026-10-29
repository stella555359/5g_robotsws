*** Settings ***
Documentation
    ...     [Procedure]             "This testcase covers check for 10G,1G and 50G SFP"
    ...     [Date]                  "01-09-23"
    ...     [Author]                "Sushma R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "SFP"
    ...     [Feature_ID]            "RP000502,RP000371,CB007839"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-3907"
	...     [Config]    			"Basic SCF with ETHLK-1,2 and 3 connected with 10G,1G,50G SFP respectively"


Suite Setup		Setup Oamops
Suite Teardown	Teardown Oamops

Resource        ${CURDIR}/resources/common_keyword_sfp.robot


*** Variables ***
${counter}        0

*** Test Cases ***
[1]Non_compliant_SFP_Check
    [Documentation]     THis testcase covers scenario with incompatible SFP raising relevant alarm.
    Comment     This testcase is only on EIF2 interface and only for Non-complicance check.
    Perform Commissioning   scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
    Sleep   100
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState   operation=update    value=locked
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState   operation=update
    ...     value=unlocked
    Sleep   20
    Verify Alarm     faultid=61029    should_exist=${True}
    Verify Alarm     faultid=4656   should_exist=${True}
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState   operation=update    value=locked
