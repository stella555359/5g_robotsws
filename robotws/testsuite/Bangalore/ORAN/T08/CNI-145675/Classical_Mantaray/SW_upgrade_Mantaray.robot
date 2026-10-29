*** Settings ***
Documentation
...   author: T08
...   contact: Veena
...   Description: SW upgrade via Mantaray

Resource    ./testsuite/Bangalore/ORAN/T08/CNI-145675/Classical_Mantaray/SW_upgrade_Mantaray_keywords.robot

Suite setup        Suite Setup
Suite Teardown    Suite Teardown
*** Variables ***
${testcase_name}=    Software update via Mantaray

*** Test Cases ***
SW_upgrade_mantaray
	Setup_netact
	Assert Mrbts Is In Onair State
	#Attach UE
	#Start DL Throughput
	#Detach UE
    Download target build and import to NMS
	Download and activate build from NMS