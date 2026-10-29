*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...	    [Procedure]	"The test case is planned to validate Sync"

Resource   taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource  testcases/resources/common_oam_gui_keywords.robot
*** Variables ***
${tc_variables}		testcase_variables.json

*** Keywords ***
Suite Setup Preconditions
	Start Syslog	log_dir=${EXECDIR}/execution_logs		log_name=background_syslog.txt		file_limit=50000000     alias=collect_syslog

Suite Teardown Postconditions
	Run Keyword And Ignore Error	Setup Oamops
	Collect Im Snapshot     timeout=300
	Collect Snapshot        timeout=1200
#	[Teardown]	Run Keywords	Verify Basic Syslog Error Prints       alias=collect_syslog
#	...	AND	Stop Syslog       alias=collect_syslog

Verify Basic Syslog Error Prints
	[Arguments]		${alias}
	${tas_err_count}=	Analyse Syslog		analysis=verify_tas_error_signature     alias=${alias}
	Should Be True	${tas_err_count}<1
	${lfs_err_count}=	Analyse Syslog		analysis=verify_lfs_error_signature     alias=${alias}
	Should Be True	${lfs_err_count}<1
	${wrn_err_count}=	Analyse Syslog		analysis=verify_wrn_error_signature     alias=${alias}
	Should Be True	${wrn_err_count}<1
	${trswsyslog_err_count}=	Analyse Syslog		analysis=verify_trswsyslog_error_signature     alias=${alias}
	Should Be True	${trswsyslog_err_count}<1
	${trs_fatal_err_count}=	    Analyse Syslog		analysis=verify_trs_fatal_error_signature     alias=${alias}
	Should Be True	${trs_fatal_err_count}<1
    ${trswsyslog_wrn_count}=    Analyse Syslog      analysis=verify_trswsyslog_warning_signature    alias=${alias}
    Should Be True  ${trswsyslog_wrn_count}<1