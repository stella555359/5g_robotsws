*** Settings ***

Documentation    Script for CB006943_A_TC016_OAM Simulated_Environment
...   author: sudarsha.kanapuram@nokia.com
...   Description: NR FDD ORAN FJT Radios configured for FDD DSS RAT1 and Dynamic Switch allocation verification
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB006943_TC16_$(date +%y%m%d) CB006943_OAM16.robot


Resource          ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/UTE_Common_resource.robot

Suite setup        Suite Setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CB006943OAM16


*** Variables ***
${Dummy_variable}    1
${para_name}=    restart-cause
${snapshot1}=    ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${RMOD_ID}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

*** Test Cases ***
[1.0] CB006943_A_TC016_OAM
    #[Tags]    VRF_BLR1    RAN_ST    QC_252475    CRT
    [Documentation]
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
    ...    cell1    FDD    n1    DSS    50    20MHz
	#admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	Check Cells are ON-Air
	Execute Test Case Scenario    restart_cause=OTHER-WATCHDOG-TIMER
	Execute Test Case Scenario    restart_cause=SOFTWARE-FAILURE
	Execute Test Case Scenario    restart_cause=SUPERVISION-WATCHDOG
	Execute Test Case Scenario    restart_cause=UNKNOWN
	Execute Test Case Scenario    restart_cause=MPLANE-TRIGGERED-RESTART


***Keywords***
Check Cells are ON-Air
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    Log to console    \n--Test Completed--\n

Execute Test Case Scenario
    [Arguments]    ${restart_cause}=None
    Log To Console      restart_cause ${restart_cause} started
    ${output1}    Run    grep ${para_name} ${snapshot1}
    @{lines}=    Split To Lines    ${output1}
    Log To Console      ${output1}
    ${runtime_parameter}=    Strip String    ${output1}
    Log To Console      ${runtime_parameter}
    Run    sed -i 's;${runtime_parameter};<restart-cause>${restart_cause}</restart-cause>;g' ${snapshot1}
    ${output2}    Run    grep ${para_name} ${snapshot1}
    Log To Console      ${output2}
    Run And Return Rc And Output    scp ${snapshot1} 192.168.200.1:/rom/simmode
    Log To Console      Restart cause ${restart_cause} updated
    #ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
	ADMIN Reset Unit    ${RMOD_ID}    Soft    300
	Sleep	30s
	Check Cells are ON-Air

ADMIN Reset Unit
    [Arguments]    ${dist_name}
    ...            ${reset_type}=Soft
    ...            ${timeout}=120
    ...            ${detailed_output}=False
    ...            ${alias}=${ADMIN_ALIAS}
    Log to console   \n--RMOD reset in progress--\n
    admin.Reset Unit   dist_name=${dist_name}
    ...                        reset_type=${reset_type}
	...						   force_radio_reset=True
    ...                        timeout=${timeout}
    ...                        connection=${alias}
	...						   detailed_output=${detailed_output}
	Log to console   \n--RMOD reset Completed--\n
ResetAllRadio

    Log to console   \n--RMOD reset in progress--\n
    taf.sbts.oam.coam.admin.reset_unit            dist_name=${RMOD_ID}
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=admin_1
        ...                     detailed_output=False
	Log to console   \n--RMOD reset Completed--\n
