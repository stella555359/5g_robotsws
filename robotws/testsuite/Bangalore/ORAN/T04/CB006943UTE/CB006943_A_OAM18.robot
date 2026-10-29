*** Settings ***

Documentation    Script for CB006943_A_OAM18 Simulated_Environment
...   author: sudarsha.kanapuram@nokia.com
...   Description: NR FDD ORAN FJT Radios configured for FDD DSS RAT1 and Dynamic Switch allocation verification
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB006943_TC18_$(date +%y%m%d) CB006943_A_OAM18.robot


Resource          ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/UTE_Common_resource.robot
Resource    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/AP_backdoor_Keywords.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00


*** Variables ***
${Dummy_variable}    1
${para_name}=    restart-cause
${snapshot1}=    ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

*** Test Cases ***
CB006943_A_TC018_OAM
    [Tags]    FL00    TRUNK_SG04    25R1    QCD_MN_RAN    QCP_RAN_VRF    6943G
    [Teardown]    run keywords
     ...      Test teardown
	#admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	Link SCOUT SCF to Configuration ID for Reporting
	Test steps


*** Keywords ***
Test steps

	Log to console  \n--Executing Test steps START--\n
	${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}
    Log to console  \n--Checking RMODs state and it should be unlock--\n
    ${adminstate_RU}=    Create List	${bts_info ['radioModules']['rmod'][0]['status']['administrativeState']}
	Should Be Equal As Strings    ${adminstate_RU}    ['Unlocked']
    sleep    30

	Log to console  \n--Lock ORU via WebEM--\n
	admin.lock    dist_name=${RMOD_ID}    timeout=300s    connection=${ADMIN_ALIAS}
    ${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}

    Log to console  \n--checking RMODs Lock status in WebEM--\n
	${adminstate_RU}=    Create List	${bts_info['radioModules']['rmod'][0]['status']['administrativeState']}
	Should Be Equal As Strings    ${adminstate_RU}    ['Locked']
	admin.get_active_alarms    connection=${ADMIN_ALIAS}
	Log to console  \n--Checking RU admin state for lock in backdoor--\n
	Check RU Admin State in AP    locked
	sleep    30
	Log to console  \n--Unlock ORU via WebEM--\n
	admin.unlock    dist_name=${RMOD_ID}    timeout=300s    connection=${ADMIN_ALIAS}
    ${bts_info}=    admin.get_bts_info    connection=${ADMIN_ALIAS}

    Log to console  \n--checking RMODs Unlock status in WebEM--\n
	${adminstate_RU}=    Create List	${bts_info['radioModules']['rmod'][0]['status']['administrativeState']}
	Should Be Equal As Strings    ${adminstate_RU}    ['Unlocked']
	admin.get_active_alarms    connection=${ADMIN_ALIAS}
	Log to console  \n--Checking RU admin state for unlock in backdoor--\n
	Check RU Admin State in AP    unlocked
	sleep    30
	Log to console  \n--Executing Test steps END--\n

Test teardown
    Log to console   \n--Test teardown Started--\n
    Check BTS is OnAir
    RP Settings
    sleep    5
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    sleep    10
    interface.Common step trigger
    Log to console   \n--Test teardown completed--\n

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    admin.get_bts_statuses    connection=admin_1
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}


