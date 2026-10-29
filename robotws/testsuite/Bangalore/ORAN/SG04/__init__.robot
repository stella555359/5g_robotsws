*** Settings ***
Documentation    Suite for all CRT4 CRT executions.
Library    OperatingSystem     WITH NAME    os
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/Suite_pre_check.robot



Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions



*** Keywords ***

Suite Preconditions
	Log To Console      Suite Preconditions started
	BTS SW Download and Update
    	#LTE BTS SW Download and Update


Suite Postconditions
	Log To Console      suite_teardown



