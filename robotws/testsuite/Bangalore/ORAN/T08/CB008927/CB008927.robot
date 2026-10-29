*** Settings ***

Documentation    Script for CB008927 Simulated_Environment
...   author: krishna.murthy_m@nokia.com
...   Description: NR FDD ORAN FJT Radios configured for FDD DSS RAT1 and Dynamic Switch allocation verification
...   and Test case to verify CB008927: TC1_USCB008927-Q#IWK4_Single RAT1 and dynamic switch RAT0 UE in FDD DSS 20MHz cell in SA mode.
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB008927_$(date +%y%m%d) CB008927.robot


Resource          CB008927_resource.robot

Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CB008927     NR_FDD_DSS_CB008927_SPLIT-Q


*** Variables ***
${Dummy_variable}    1

*** Test Cases ***
CB008927-Q_Single_RAT1_and_dynamic_switch_RAT0_in_FDD_DSS_20MHz_cell
    #[Tags]    VRF_BLR1    RAN_ST    QC_252475    CRT
    [Documentation]
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
    ...    cell1    FDD    n1    DSS    50    20MHz
	L3 Call For DSS NR cell
	Rat1 Allocation Verification
    SA 5G Detach
	Activate Dynamic Swtich
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
	L3 Call For DSS NR cell
	Dynamic swtich Allocation Verification
    SA 5G Detach
    Counter Verification
    ADMIN Assert BTS is onAir    timeout=900
	Check Cells are ON-Air

***Keywords***
Check Cells are ON-Air
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    Log to console    \n--Test Completed--\n