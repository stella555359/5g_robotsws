*** Settings ***

Documentation    Script for CB009301_Airphone_NR_TDD_AWHQN
...   author: krishna.murthy_m@nokia.com
...   Description:  This script is used to activate the dynamic computation/optimization of fronthaul delay timing (T12min/T34min) and validate
...                 the measuremed values for T12min/T34min are updated correctly based on eCPRI delay measurements (eCPRI message type #5).
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB009301_$(date +%y%m%d) CB009301.robot


Resource          CB009301_resource.robot

Suite setup        Suite Setup
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CB009301     NR_TDD_ORAN

*** Variables ***
${Test_variable}    1

*** Test Cases ***
CB009301_Verify_feature_activation_Validate_Measured_delay_values
    [Tags]    VRF_BLR1    VRF_ORAN    QC_172980    CRT
    [Documentation]   Validation of Dynamic FH Delay measurement
	L3 Call
    SA 5G Detach
    Get Measured Delay
    Check Cells are ON-Air

***Keywords***
Check Cells are ON-Air
    Check vDU Cell status
    Log to console    \n--Test Completed--\n