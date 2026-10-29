*** Settings ***

Documentation
...   author: partheeban.asokan@nokia.com
...   contact: partheeban.asokan@nokia.com
...   Description: This feature aims to measure energy efficiency and power consumption in SBTS each releases
...				 : -A focuses on collecting energy consumption counters for reference configurations in various use cases
...				 : and validating against previous releases, and providing data for the EE Score Card.
...				 : BTS needs to be commissioned with SCF available in resource folder.
...				 : Update all variables correctly as per testline usage, remaining script is generalised.
...				 : Do not delete any of the variables in this test suite, when you are creating separate suite.

Library     	Process
Library     	String
Library         BuiltIn
Library     	DateTime
Library     	Collections
Library     	OperatingSystem
Library     	taf.sbts.oam.coam.admin    WITH NAME    COAM
Resource    	./testsuite/Bangalore/ORAN/T04/resources/reportingportal_Keywords.robot
Resource    	./testsuite/Bangalore/ORAN/T04/resources/alarm.robot
Library     	taf.sw.scout    WITH NAME    scout
Library     	taf.config.scf.interface.scf     WITH NAME    scf

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***

${BTSID}=    1213
${TestModel}=   TM1_1
@{BeamPatternId} =	0	0	0	0
${polarization}=    P_plus45_or_0
@{powerBackoff}=   51    29    0
${ruMode}=   NR_Only
${pmax}=    43
${nrarfcnDl}=   366000
${nrarfcnUl}=	347000
${MIMOrank}=    1
${codebook2antports}=    0
${i11Codebook4antports}=   0
${i2codebook4antports}=    0
${i13codebook4antports}=    0

@{Required_bts_status} =   Test    OnAir
${scout_tl_name}=	1_2_CLOUD1213

${No_of_Counter_Samples}    5
@{IDS}	1    2    3
@{cells}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1213/LNCEL_R-1    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1213/LNCEL_R-25
...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1213/LNCEL_R-27    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1213/NRCELL_R-1
...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1213/NRCELL_R-2    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1213/NRCELL_R-3

*** Test Cases ***
TC01_Energy_Consumption_Measurements_Medium_burstLoad_TM1-1_backoff_51_EE_disabled
    [Tags]    FL00    TC1    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
    ...      Test teardown
    Disable Feature and Activate the Counters
    move_to_test_dedicated_state_Enable
    FOR    ${i}    IN RANGE    1    ${No_of_Counter_Samples}
        Log to console      \n -- Counter collection Iteration No: ${i} --
        FOR    ${id}    IN    @{IDS}
            Log to console      \n -- Start Downlink NR Test on NRCELL-${id} --
            start_downlinkNr_test	${powerBackoff}[0]    ${id}    ${id}
            Sleep    20m
            EPE counters collection and validation
            SM counters collection and validation
            Log to console      \n -- Counter updates for RMOD-${id}
            RFM counters collection and validation    ${id}
            stop_downlinkNr_test	${id}
            Sleep    10
    	END
    END
    move_to_test_dedicated_state_Disable

TC02_Energy_Consumption_Measurements_Busy_burstLoad_TM1-1_backoff_29_EE_disabled
    [Tags]    FL00    TC2    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
    ...      Test teardown
    Disable Feature and Activate the Counters
    move_to_test_dedicated_state_Enable
    FOR    ${i}    IN RANGE    1    ${No_of_Counter_Samples}
        Log to console      \n -- Counter collection Iteration No: ${i} --
        FOR    ${id}    IN    @{IDS}
            Log to console      \n -- Start Downlink NR Test on NRCELL-${id} --
            start_downlinkNr_test	${powerBackoff}[1]    ${id}    ${id}
            Sleep    20m
            EPE counters collection and validation
            SM counters collection and validation
            Log to console      \n -- Counter updates for RMOD-${id}
            RFM counters collection and validation    ${id}
            stop_downlinkNr_test	${id}
            Sleep    10
    	END
    END
    move_to_test_dedicated_state_Disable

TC03_Energy_Consumption_Measurements_Low_Cells_Onair_EE_disabled
    [Tags]    FL00    TC3    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
    ...      Test teardown
    Disable Feature and Activate the Counters
    FOR    ${i}    IN RANGE    1    ${No_of_Counter_Samples}
        Log to console      \n -- Wait 20m for Counters to update, Iteration No: ${i} --
        Sleep    20m
        EPE counters collection and validation
        SM counters collection and validation
        FOR    ${RMOD}    IN    @{IDS}
        	Log to console      \n -- Counter updates for RMOD-${RMOD}
        	RFM counters collection and validation    ${RMOD}
    	END
    END

TC04_Energy_Consumption_Measurements_Full_burstLoad_TM1-1_backoff_0_EE_disabled
    [Tags]    FL00    TC4    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords
    ...      Test teardown
    Disable Feature and Activate the Counters
    move_to_test_dedicated_state_Enable
    FOR    ${i}    IN RANGE    1    ${No_of_Counter_Samples}
        Log to console      \n -- Counter collection Iteration No: ${i} --
        FOR    ${id}    IN    @{IDS}
            Log to console      \n -- Start Downlink NR Test on NRCELL-${id} --
            start_downlinkNr_test	${powerBackoff}[2]    ${id}    ${id}
            Sleep    20m
            EPE counters collection and validation
            SM counters collection and validation
            Log to console      \n -- Counter updates for RMOD-${id}
            RFM counters collection and validation    ${id}
            stop_downlinkNr_test	${id}
            Sleep    10
    	END
    END
    move_to_test_dedicated_state_Disable

TC05_Energy_Consumption_Measurements_Idle_Cells_Locked_EE_disabled
    [Tags]    FL00    TC5    QCD_MN_RAN    QCP_RAN_VRF
    [Teardown]    run keywords	  UnLock All Cells
    ...      Test teardown
    Disable Feature and Activate the Counters
    Lock Cells    ${cells}
    Log to console      \n -- Wait 20m for Counters to update--
    Sleep    20m
    FOR    ${i}    IN RANGE    1    ${No_of_Counter_Samples}
        Log to console      \n -- Counters Collection Iteration No: ${i}
        EPE counters collection and validation
        SM counters collection and validation
        FOR    ${RMOD}    IN    @{IDS}
        	Log to console      \n -- Counter updates for RMOD-${RMOD}
        	RFM counters collection and validation    ${RMOD}
    	END
    END

*** Keywords ***

Test Setup
    Log to console    \n--Test Setup--\n
    COAM.setup_admin	bts_host=${non_def_BTS_IP}
    ${BTS_details}      taf.sbts.oam.coam.admin.get_bts_info       connection=default
    Log    ${BTS_details}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Set global variable    ${dist_name1}     MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    Set global variable    ${dist_name2}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${sw_version}=    COAM.get_sw_version
    Log to console  \n ${sw_version} \n
    Check BTS is OnAir
    ##### Alarm validation start ###
    ${Active_alarm}    COAM.get_active_alarms
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    Verify Active Alarm Is In List    ${Active_alarm}    ${allowed_alarms}
    ##### Alarm validation end ###

move_to_test_dedicated_state_Enable
    Log to console    \n -- Enable Test Dedicated State --
    COAM.reset_to_test_dedicated     detailed_output=True
    Wait for BTS to TDS
    Validate_BTS_STATUS    ${Required_bts_status}[0]

move_to_test_dedicated_state_Disable
    Log to console    \n -- Disable Test Dedicated State --
    COAM.reset_site
    Wait for BTS OnAir
    Validate_BTS_STATUS    ${Required_bts_status}[1]

start_downlinkNr_test
     [Arguments]    ${powerBackoff}	${NrcellId}    ${PhyCellId}
     Log to console    \n -- Start Downlink NR Test --
     COAM.start_5g_downlink_test    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${BTSID}/NRCELL_R-${NrcellId}
     ...								test_model=${TestModel}
     ...								beam_pattern_id=@{BeamPatternId}
     ...								polarization=${polarization}
     ...								power_backoff=${powerBackoff}
     ...								ru_mode=${ruMode}
     ...								phys_cell_id=${PhyCellId}
     ...								codebook_2_antports=${codebook2antports}
     ...								i11_codebook_4_antports=${i11Codebook4antports}
     ...								i2_codebook_4_antports=${i2codebook4antports}
     ...								i13_codebook_4_antports=${i13codebook4antports}
     ...								mimo_rank=${MIMOrank}
     ...								p_max=${pmax}
     ...								nrarfcn_dl=${nrarfcnDl}
     ...								nrarfcn_ul=${nrarfcnUl}
     sleep   5

stop_downlinkNr_test
     [Arguments]    ${NrcellId}
     Log to console    \n -- Stop Downlink NR Test --
     COAM.stop_5g_downlink_test    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${BTSID}/NRCELL_R-${NrcellId}

Validate_BTS_STATUS
    [Arguments]    ${Required_BTS_Status}
    ${bts_status}=  COAM.get_bts_statuses
    ${var}  Set Variable    ${bts_status['proceduralState']}
    ${str}  BuiltIn.Convert To String    ${var}
    Should Be Equal    ${str}    ${Required_BTS_Status}

Lock Cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${cell}      timeout=180
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${cell}            locking_status=locked
        ...                                                                         operational_status=disabled
		...                                                                         blocking_status=Unblocked
    END

Check cell details
    [Documentation]             Check cell details
    [Arguments]                 ${cell}
    ...                         ${locking_status}=unlocked  ${operational_status}=enabled   ${blocking_status}=Unblocked
    ${cell_status}              COAM.get_cell_specific_info    cell_id=${cell}
    ${administrativeState}      Set Variable    ${cell_status['status']['administrativeState']}
    Run keyword And Continue On Failure    Should Be Equal    ${administrativeState.upper()}    ${locking_status.upper()}
    ${operationalState}         Set Variable    ${cell_status['status']['operationalState']}
    Run keyword And Continue On Failure    Should Be Equal    ${operationalState.upper()}    ${operational_status.upper()}
    ${usageState}               Set Variable    ${cell_status['status']['usageState']}
    ${blockingState}            Set Variable    ${cell_status['status']['blockingState']}
    Run keyword And Continue On Failure    Should Be Equal    ${blockingState.upper()}    ${blocking_status.upper()}

UnLock All Cells
    UnLock cells	${cells}

UnLock cells
    [Documentation]     UNLock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nunLocking cell : ${cell}
        COAM.unlock           dist_name=${cell}      timeout=180
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${cell}            locking_status=unlocked
        ...                                                                         operational_status=enabled
		...                                                                         blocking_status=Unblocked
    END

Disable Feature and Activate the Counters
    Log to console  \n-- Enabling Power Savings Measurements --
    Parameter value change	${dist_name}	miOranEpeStats    15min
    Parameter value change	${dist_name}	mtSBTSRfmEnergyMonitoring    15min
    Parameter value change	${dist_name}	mtSBTSSmEnergyMonitoring    15min
    Parameter value change	${dist_name1}	actLBPowerSaving	False
    Parameter value change	${dist_name2}	actNrLBPowerSaving	False
    Log to console    \n--Test Setup finished--\n

Parameter value change
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter value in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
    @{parameter_list}=    create list    ${parameter}
    ${current_value}    COAM.Get Parameter by distname   ${dist_name}    ${parameter_list}    connection=default
    LOG    ${current_value[0]['parameters']['${parameter}']}
    Run Keyword If    '${current_value[0]['parameters']['${parameter}']}'!='${value}'
    ...    COAM.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...     parameter=${parameter}      operation=update    value=${value}    skip_parameter_relation_errors=True    connection=default
    ${current_value}    COAM.Get Parameter by distname   ${dist_name}    ${parameter_list}    connection=default
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value[0]['parameters']['${parameter}']}    ${value}

EPE counters collection and validation
    Log to console   \n--Step1: EPE Counter Verification from BTS Started--\n
    sleep    10s
    @{counter_list}=    create list    'M40002C0'    'M40002C1'    'M40002C2'
    ${result} =    coam.get_pm_counters    counter_ids=${PowerSavingCounter1}    timeout=600    connection=default
	FOR    ${I}    IN    @{counter_list}
		${values}=    Get Dictionary Values
		...	${result['BTS']['MRBTS-${BTS_ID}']['SBTS_Energy_Consumption'][${I}]}
		${last_value}=     Set Variable     ${values[-1]}
		${float_value}=    Convert To Number    ${last_value}

		${int_part}=       Evaluate    int(${float_value})
		IF    ${I} in ['M40002C0', 'M40002C1', 'M40002C2']
			Log to console  \n-- SBTS_Energy_Consumption ${I}: ${int_part} \n
		END
	END

SM counters collection and validation
    Log to console   \n--Step2: SM Counter Verification from BTS Started--\n
    sleep    10s
    @{counter_list}=    create list    'M40004C0'    'M40004C1'    'M40004C2'    'M40004C3'
    ${result1} =    coam.get_pm_counters    counter_ids=${PowerSavingCounter2}    timeout=600    connection=default
    FOR    ${I}    IN    @{counter_list}
    	${values}=    Get Dictionary Values
	...	${result1['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['CABINET-1']['SMOD-1']['SBTS_SM_Energy_Monitoring'][${I}]}
	${last_value}=     Set Variable     ${values[-1]}
	${float_value}=    Convert To Number    ${last_value}

	${int_part}=       Evaluate    int(${float_value})
	IF    ${I} in ['M40004C0', 'M40004C1', 'M40004C2', 'M40004C3']
		Log to console  \n-- SBTS_SM_Energy_Monitoring ${I}: ${int_part} \n
	END
    END

RFM counters collection and validation
   [Arguments]    ${RMOD_ID}
    Log to console   \n--Step3: RFM Counter Verification from BTS Started--\n
    sleep    10s
    @{counter_list}=    create list    'M40003C2'    'M40003C3'    'M40003C4'    'M40003C5'
    ${result} =    coam.get_pm_counters    counter_ids=${PowerSavingCounter3}    timeout=600    connection=default
    FOR    ${I}    IN    @{counter_list}
	${values}=    Get Dictionary Values
	...	${result['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['RMOD-${RMOD_ID}']['SBTS_RFM_Energy_Monitoring'][${I}]}
	${last_value}=     Set Variable     ${values[-1]}
	${float_value}=    Convert To Number    ${last_value}

	${int_part}=       Evaluate    int(${float_value})
	IF    ${I} in ['M40003C2', 'M40003C3', 'M40003C4', 'M40003C5']
	    Log to console  \n-- SBTS_RFM_Energy_Monitoring RMOD-${RMOD_ID} ${I}: ${int_part} \n
	END
    END

Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    taf.sbts.oam.coam.admin.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    2m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Wait for BTS to TDS
    Log to console      \nWaiting for BTS to be on Test Mode
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    taf.sbts.oam.coam.admin.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='Test'
        Sleep    3m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='Test'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    taf.sbts.oam.coam.admin.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Verify Active Alarm Is In List
   [Arguments]    ${alarm}    ${list}
   ${result} =    Run Keyword And Return Status    List Should Not Contain Value    ${list}    ${alarm}
   Should Be True    ${result}

Test Teardown
    Log to console   --\n Test teardown Started\n--
    Log to console  \n--Epe_stats_update started-- \n
    Check BTS is OnAir
    ##### Alarm validation start ###
    ${Active_alarm}    COAM.get_active_alarms
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    Verify Active Alarm Is In List    ${Active_alarm}    ${allowed_alarms}
    ##### Alarm validation end ###
    coam.Teardown All Aliases For Admin
    Log to console   --\n Test teardown COMPLETED \n--
