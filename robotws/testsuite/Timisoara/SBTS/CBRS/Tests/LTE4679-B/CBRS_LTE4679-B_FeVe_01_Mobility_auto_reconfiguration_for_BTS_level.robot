*** Settings ***
Documentation
...    = Author =
...    marek.kot@nokia.com
...    = Maintainer =
...    marek.kot@nokia.com
...    = Reviewer =
...    marek.kot@nokia.com
...    = Summary =
...    Purpose: Verify Mobility Auto Configuration for BTS level

*** Keywords ***
CBRS_LTE4679-B_FeVe_01_Mobility_auto_reconfiguration_for_BTS_level
    [Documentation]    Requirement: OM_LTE_SFS_RNL.21928, OM_LTE_SFS_RNL.21929

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure
    ...                                        severity=Critical    reason=Heartbeat Exception with Reason: 500.
    Kill All SAS Processes
	Check If Cells Are Disabled    ${enb_id}
	Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/FeVe01/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}

    #Prepare all neccessary variables
    ${cbsd_mo}   Get Random Cbsd Object
    ${cells_list}   Get Cells List From Cbsd Object    ${cbsd_mo}
    ${cell_pair}   Get N Random Cells From Cells List    cell_list=${cells_list}    n=2
    ${neighbour_cell_tdd}   Query Infomodel    alias=RAT_1ST
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_pair[0]}/LNCEL_TDD_A-*
    ${neighbour_cell_cbsdcell}    Query Infomodel    alias=RAT_1ST
    ...    query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-*/LNCEL_R-${cell_pair[0]}/CBSDCEL_R-*
    ${radio_id}                   Set Variable    ${cbsd_mo["assignedCbsdId"]}
    ${neighbour_cell_earfcn}      Set Variable    ${neighbour_cell_tdd["earfcn"]}
    ${neighbour_cell_grant}       Set Variable    ${neighbour_cell_cbsdcell["grantId"]}

    Start Watchdog Alarm Detection

    #Step 1
    #Create objects: LNREL, AMPLER, IRFIM, LNHOIF, REDRT
    #All mo have parameter which point to neighbour cell by using earfcn
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Precond_delta.json    ${OUTPUT_DIR}/FEVE_1_Precond_delta.json
    ...    ENB_ID=${enb_id}    D_ENB_ID=${enb_id}    N_LNCEL_ID=${cell_pair[0]}    LNCEL_ID=${cell_pair[1]}
    ...    N_EARFCN=${neighbour_cell_earfcn}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_Post_delta.json    ${OUTPUT_DIR}/FEVE_1_Post_delta.json
    ...    ENB_ID=${enb_id}    LNCEL_ID=${cell_pair[1]}
    Wait Until Keyword Succeeds    3x    60s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_1_Precond_delta.json    connection=RAT_1ST
    ...                                     skip_parameter_relation_errors=${TRUE}

    #Step 2
    #Terminate neighbour cell to change earfcn
    ${query}   Catenate    SEPARATOR=${SPACE}
    ...    /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_pair[0]}/LNCEL_TDD_A-*
    ...    is [earfcn!=${neighbour_cell_earfcn}]
    Add Fault To Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Terminate Grant And Confirm Cell Drop    cbsd_id=${radio_id}    grant_id=${neighbour_cell_grant}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Wait Until Keyword Succeeds    6x    30s    Query Infomodel    alias=RAT_1ST    timeout=10    query=check ${query}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=120
    Wait For All Cells To Be OnAir
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    ${neighbour_cell_tdd}   Wait Until Keyword Succeeds    6x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_pair[0]}/LNCEL_TDD_A-*
    ${neighbour_cell_earfcn}   Set Variable    ${neighbour_cell_tdd["earfcn"]}

    #Step 3
    #eNB perform recommisioning of all earfcn in affected mo
    #All mo have parameter which point to neighbour cell by using new earfcn
    ${query}   Set Variable    /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_pair[1]}
    Wait Until Keyword Succeeds    20x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=check ${query}/AMLEPR_A-5 is [targetCarrierFreq=${neighbour_cell_earfcn}]
    Query Infomodel    alias=RAT_1ST
    ...    query=check ${query}/IRFIM_A-5 is [dlCarFrqEut=${neighbour_cell_earfcn}]
    Query Infomodel    alias=RAT_1ST
    ...    query=check ${query}/LNHOIF_A-5 is [eutraCarrierInfo=${neighbour_cell_earfcn}]
    Query Infomodel    alias=RAT_1ST
    ...    query=check ${query}/REDRT_A-5 is [redirFreqEutra=${neighbour_cell_earfcn}]

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    connection=RAT_1ST
           ...    delta_file=${OUTPUT_DIR}/FEVE_1_Post_delta.json    skip_parameter_relation_errors=${TRUE}    AND
    ...    Kill All SAS Processes
