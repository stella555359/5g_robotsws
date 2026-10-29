*** Settings ***
Documentation
...    = Author =
...    _marek.kot@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...
...    = Summary =
...    Purpose: Verify whether eNB use querySasServerPeriod to check available specturm.

*** Keywords ***
CBRS_LTE4237_FeVe_02_Cell_behaviour_with_active_querySasServerPeriod
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.286, OM_GEN_SFS_CBRS.287, OM_GEN_SFS_CBRS.291

    ${enb_id}     Set Variable    ${testlines.${testline_id}.enb_id}
    ${expected_alarms}   Create List    SAS Grant Failure    SAS Grant Termination Revocation Failure    SAS Grant Suspension Failure
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_set_chBw_to_20_MHz.json    ${OUTPUT_DIR}/FEVE_2_set_chBw_to_20_MHz.json
    ...    ENB_ID=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_set_chBw_to_10_MHz.json    ${OUTPUT_DIR}/FEVE_2_set_chBw_to_10_MHz.json
    ...    ENB_ID=${enb_id}

    Enable CBRS Feature On eNB

    #Checking if channel bandwidth is set to 20 MHz for all CBSD cells
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${is_chBw_20MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
        ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i} is [ulChBw=20000000]
        IF  '${is_chBw_20MHz}'=='False'  Wait Until BTS Is Not Busy
        IF  '${is_chBw_20MHz}'=='False'  Perform Delta Recommissioning
        ...   delta_file=${OUTPUT_DIR}/FEVE_2_set_chBw_to_20_MHz.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST
        IF  '${is_chBw_20MHz}'=='False'  BREAK
    END
    Log    Channel bandwidth is set to 20 MHz for all CBSD cells    console=true

    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3590    3595
    ...                                     3600    3605    3610    3615    3620    3625    3630    3635
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process     default
    ...                                                     4433
    ...                                                     config=${CURDIR}/Data/FeVe02/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}

    #Prepare all neccessary variables
    ${cbsd_mo}    Get Random Cbsd
    ${cell_id}    Get Random Cell From Cbsd Object    ${cbsd_mo}
    ${cbsd_id} =     Get Cbsd Id From Cbsd Object    ${cbsd_mo}
    ${cbsd_a_mo}   Query Infomodel    alias=RAT_1ST
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/CBSD_A-${cbsd_id}
    ${cbrspr_id}   Set Variable    ${cbsd_a_mo["cbrsPrId"]}

    #Prepare preconditon
    #For whole test we have grants for 4 cells 20MHz and one 10 MHz
    #querySasServerPeriod is set to 2 min
    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_Precond_delta.json    ${OUTPUT_DIR}/FEVE_2_Precond_delta.json
    ...     ENB_ID=${enb_id}
    ...     LNCEL_ID=${cell_id}
    ...     CBSD_ID=${cbsd_id}
    ...     CBRSPR_ID=${cbrspr_id}
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_2_Precond_delta.json    connection=RAT_1ST

    Wait For All Cells To Be OnAir
    ${grant_id}   Get Grant Value By Cell Id    ${cell_id}
    Start Capturing Historical Alarms

    Log    Step 1. Suspend grant for choosen cell    console=True
    #Due to maxGrantChBWRed, cell bw should change from 20 MHz to 10 MHz
    Send Command To SAS Manager    default    grant_suspend ${cbsd_mo["assignedCbsdId"]} ${grant_id}
    Wait Until Keyword Succeeds    10x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell_id}/LNCEL_M-${cell_id} is [ulChBw=10000000]
    Wait For All Cells To Be OnAir

    Log    Step 2. Free grant for chosen cell    console=True
    #Using querySasServerPeriod timer eNB checks new grants on SAS
    #When querySasServerPeriod expire, cell bw should change from 10 MHz to 20 MHz
    Send Command To SAS Manager    default    grant_free ${cbsd_mo["assignedCbsdId"]} ${grant_id}
    Wait Until Keyword Succeeds    10x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell_id}/LNCEL_M-${cell_id} is [ulChBw=20000000]
    Wait For All Cells To Be OnAir

    Log    Step 3. Terminate grant for chosen cell    console=True
    #Due to maxGrantChBWRed, cell bw should change from 20 MHz to 10 MHz
    Send Command To SAS Manager    default    grant_terminate ${cbsd_mo["assignedCbsdId"]} ${grant_id}
    Wait Until Keyword Succeeds    10x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell_id}/LNCEL_M-${cell_id} is [ulChBw=10000000]
    Wait For All Cells To Be OnAir

    Log    Step 4. Free grant for chosen cell    console=True
    #Using querySasServerPeriod timer eNB checks new grants on SAS
    #When querySasServerPeriod expire, cell bw should change from 10 MHz to 20 MHz
    Send Command To SAS Manager    default    grant_free ${cbsd_mo["assignedCbsdId"]} ${grant_id}
    Wait Until Keyword Succeeds    10x    30s    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell_id}/LNCEL_M-${cell_id} is [ulChBw=20000000]
    Wait For All Cells To Be OnAir

    Replace Variables In File    ${CURDIR}/Data/FeVe02/FEVE_2_Postcond_delta.json    ${OUTPUT_DIR}/FEVE_2_Postcond_delta.json
    ...     ENB_ID=${enb_id}
    ...     LNCEL_ID=${cell_id}
    ...     CBSD_ID=${cbsd_id}
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_2_Postcond_delta.json    connection=RAT_1ST
    Wait For All Cells To Be OnAir

    [Teardown]    Run Keywords
    ...    Save And Check Historical Alarms    expected_alarms=${expected_alarms}   AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    3x    60s  Perform Delta Recomissioning For Teardown Feve 02  ${is_chBw_20MHz}  AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Kill All SAS Processes


Perform Delta Recomissioning For Teardown Feve 02
    [Arguments]  ${is_chBw_20MHz}

    IF  '${is_chBw_20MHz}'=='False'  Perform Delta Recommissioning
    ...    ${OUTPUT_DIR}/FEVE_2_set_chBw_to_10_MHz.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST
