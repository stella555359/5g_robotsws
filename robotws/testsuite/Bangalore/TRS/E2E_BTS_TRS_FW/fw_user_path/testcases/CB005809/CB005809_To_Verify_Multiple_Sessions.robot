*** Settings ***

Documentation
    ...     [Procedure]             "The test case is to verify alarms across multiple sessions and BTS behaviour"
    ...     [Date]                  "09-05-2021"
    ...     [Author]                "Mansi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     ""
    ...     [Feature_ID]            "CB005809"
    ...     [Validation_status]     "Not yet tested"
    ...     [Validated_TestLine]    "5G-9010"

variables       ta_e2e_bts_trs_fw
Library         Selenium2Library
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB005809_common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test Cases***
[1][1.0] CB005809_To Verify multiple sessions
    [Documentation]      The test case is to verify alarms across multiple sessions
	Perform Commissioning       scf_file=${BASIC_SCF}   verify_bts_status=False     timeout=400     alias=default
    BuiltIn.Sleep   200
    Open WebUI Session     gc    chrome1
    Open WebUI Session     firefox    ff1
    Open WebUI Session     gc     chrome2
    Open WebUI Session     gc     chrome3
    Perform Recommissioning   type=param    rat=lte    param_path=SECADM-1:ethernetPortSecurityEnabled    operation=update
    ...     value=${FALSE}     timeout=300
	Sleep    15s
	Verify Alarm    faultid=${4654_ALARM}     should_exist=${TRUE}    alarm_type=active    occurrences=1
    Verify 4654 alarm across all open sessions    1
    Verify 4654 alarm across all open sessions    2
    Verify 4654 alarm across all open sessions    3
    Verify 4654 alarm across all open sessions    4
	Verify eNB local port connectivity
	Perform Recommissioning   type=param    rat=lte    param_path=SECADM-1:ethernetPortSecurityEnabled    operation=update
	...     value=${TRUE}     timeout=300
    Sleep   15s
    Verify Alarm    faultid=${4654_ALARM}     should_exist=${FALSE}
	Verify 4654 alarm across all open sessions    1
    Verify 4654 alarm across all open sessions    2
    Verify 4654 alarm across all open sessions    3
    Verify 4654 alarm across all open sessions    4
	Reset Bts        verify_bts=False		should_be_onair=False    wait_for=300
    Perform Recommissioning   type=param    rat=lte    param_path=FEATCADM-1:systemAcctPermEnable     operation=update
    ...     value=${TRUE}     timeout=300
    Sleep   15s
    Verify Alarm    faultid=${4654_ALARM}     should_exist=${FALSE}
	Verify 4655 alarm across all open sessions    1
    Verify 4655 alarm across all open sessions    2
    Verify 4655 alarm across all open sessions    3
    Verify 4655 alarm across all open sessions    4
	Reset Bts        verify_bts=False		should_be_onair=False    wait_for=300
    Perform Recommissioning   type=param    rat=lte    param_path=FEATCADM-1:systemAcctPermEnable     operation=update
    ...     value=${FALSE}     timeout=300
	Sleep   15s
	Check SSH and SFTP
    Verify Alarm    faultid=${4655_ALARM}     should_exist=${TRUE}   alarm_type=active    occurrences=1
    Verify 4655 alarm across all open sessions    1
    Verify 4655 alarm across all open sessions    2
    Verify 4655 alarm across all open sessions    3
    Verify 4655 alarm across all open sessions    4
	Reset Bts        verify_bts=False		should_be_onair=False    wait_for=300
	Add LSS and Remote server configuration
	Check ping test for LSS server
    Verify for core files
	Reset Bts        verify_bts=False		should_be_onair=False    wait_for=300
    [Teardown]     Reset Ethernetport security and toor4nsn access to default