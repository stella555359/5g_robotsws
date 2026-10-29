*** Settings ***
Documentation
...    = Author =
...    _marek.kot@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...    _lukasz.lechowicz@nokia.com_
...    = Summary =
...    Purpose: Verify cell bandwidth maxGrantChBwRed/desiredPmax change procedure.

*** Keywords ***
CBRS_LTE4237_FeVe_01_Cell_bandwidth_maxGrantChBwRed_desiredPmax_change_procedure
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.283;OM_GEN_SFS_CBRS.284;OM_GEN_SFS_CBRS.285

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}
    Enable CBRS Feature On eNB

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3590    3595
    ...                                     3600    3605    3610    3615    3620    3625    3630    3635
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    default    4433    config=${CURDIR}/Data/FeVe02/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}

    #Prepare all neccessary variables
    ${cbsd_mo}   Get Random Cbsd Object
    ${cells_list}   Get Cells List From Cbsd Object    ${cbsd_mo}
    ${cbsd_id}   Get Cbsd Id From Cbsd Object    ${cbsd_mo}
    ${cbsd_a_mo}   Query Infomodel    alias=${alias}
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/CBSD_A-${cbsd_id}
    ${cbrspr_profile_id}   Set Variable    ${cbsd_a_mo["cbrsPrId"]}

    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta.json    ${OUTPUT_DIR}/FEVE_1_Precond_delta.json
    ...    ENB_ID=${enb_id}    CBSD_ID=${cbsd_id}    CBRSPR_ID=${cbrspr_profile_id}
    ...    LNCEL_0=${cells_list[0]}    LNCEL_1=${cells_list[1]}    LNCEL_2=${cells_list[2]}    LNCEL_3=${cells_list[3]}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Scenario1.json    ${OUTPUT_DIR}/FEVE_1_Scenario1.json
    ...    ENB_ID=${enb_id}    CBSD_ID=${cbsd_id}    CBRSPR_ID=${cbrspr_profile_id}
    ...    LNCEL_0=${cells_list[0]}    LNCEL_1=${cells_list[1]}    LNCEL_2=${cells_list[2]}    LNCEL_3=${cells_list[3]}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Scenario2.json    ${OUTPUT_DIR}/FEVE_1_Scenario2.json
    ...    ENB_ID=${enb_id}    LNCEL_2=${cells_list[2]}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Scenario3.json    ${OUTPUT_DIR}/FEVE_1_Scenario3.json
    ...    ENB_ID=${enb_id}    LNCEL_2=${cells_list[2]}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Postcond_delta.json    ${OUTPUT_DIR}/FEVE_1_Postcond_delta.json
    ...    ENB_ID=${enb_id}    LNCEL_2=${cells_list[2]}    LNCEL_3=${cells_list[3]}    CBSD_ID=${cbsd_id}

    #Preconditons
    #For whole test we have grants for 4 cells 20MHz and one 10 MHz
    #querySasServerPeriod is set to 2 min

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Precond_delta.json    connection=RAT_1ST
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    #Step 1
    #Preconditions: 		 CBSDCEL:maxGrantChBwRed = 10MHz (cell 1, 2)|  0MHz (cell 3, 4), CBSDCEL:desiredChBw = 20MHz,
    #                        Grant is authorized as 20MHz(chBw=20MHz)
    #Change Configuration:	 CBSDCEL:maxGrantChBwRed =  0MHz (cell 1, 2)| 10MHz (cell 3, 4)
    #CBSD Action: 		     Do nothing, continue next HeartBeat progress.

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Scenario1.json    connection=RAT_1ST
    ${is_service_dropped}   Run Keyword And Return Status    Wait Until Keyword Succeeds    30x    2sec    Check If Any Cell is Disabled
    IF  ${is_service_dropped}  Fail  One of the cells was dropped after recomissioning

    #Step 2
    #Preconditions: 		CBSDCEL:maxGrantChBwRed = 10MHz, CBSDCEL:desiredChBw = 20MHz, Grant is authorized as 20MHz(chBw=20MHz)
    #Change Configuration: 	CBSDCEL:maxGrantChBwRed = 0MHz. LTE_TDD_A.chBw = 10MHz
    #CBSD Action: 			Tear down the cell, relinquishes Grant, clear all resource, Inquiry Spectrum again based on chBw.

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Scenario2.json    connection=RAT_1ST
    ...                                     skip_parameter_relation_errors=true
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    30s    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cells_list[2]}/LNCEL_M-${cells_list[2]} is [ulChBw=10000000]

    #Step 3
    #Preconditions: 		CBSDCEL:maxGrantChBwRed = 0MHz, CBSDCEL:desiredChBw = 20MHz, Grant is authorized as 10MHz(chBw=10MHz)
    #Change Configuration: 	CBSDCEL:maxGrantChBwRed = 10MHz. LTE_TDD_A.chBw = 20MHz
    #CBSD Action: 			Tear down the cell, relinquishes Grant, clear all resource, Inquiry Spectrum again based on desiredChBw.

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Scenario3.json    connection=RAT_1ST
    ...        skip_parameter_relation_errors=true
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    30s    Query Infomodel    alias=${alias}
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cells_list[2]}/LNCEL_M-${cells_list[2]} is [ulChBw=20000000]

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Postcond_delta.json
    ...                                                            connection=RAT_1ST    AND
    ...                           Wait For All Cells To Be OnAir    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
