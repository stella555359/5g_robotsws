*** Settings ***

Documentation    Script for CB013328_Airphone_NR_FDD_KDDI
...   author: krishna.murthy_m@nokia.com
...   Description:  PRACH configuration using section type3 FCP message when O-RU dont report PRACH-STATIC-CONFIGURATION-SUPPORTED
...                 capability to DU
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB013328_$(date +%y%m%d) CB013328.robot


Resource          CB013328_resource.robot

Suite setup        Suite Setup
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CB013328     NR_FDD_ORAN

*** Variables ***
${Test_variable}    1

*** Test Cases ***
CB013328_A_Verification of PRACH configuration using section type3 FCP message when O-RU dont report PRACH-STATIC-CONFIGURATION-SUPPORTED capability
    [Tags]    VRF_BLR1    VRF_ORAN    QC_183253    CRT
    [Documentation]   Validation of PRACH-STATIC-CONFIGURATION-SUPPORTED Not present in Netconf.
	Check Cells are ON-Air
	L3 Call
	SA 5G Detach
	Log collection and validation
	Search Phrase In File    ${output}    ${Prach_phrase}
	EAXCID Verification
    Check Cells are ON-Air
	Multiple cell block and unblock
	Multiple RMOD Reset
	Multiple BBMOD Reset
	Multiple Site Reset
    Check Cells are ON-Air

***Keywords***
Check Cells are ON-Air
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    ADMIN Assert BTS is onAir    timeout=900
    Log to console    \n--Test Completed--\n