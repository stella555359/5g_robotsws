*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify the behavior of both of cell pMax and EARFCN reconfiguration to match SAS grant response with Interference

*** Keywords ***
LTE4236_FeVe_03_Verify_the_behavior_of_both_of_cell_pMax_and_EARFCN_reconfiguration
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.309

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Wait Until BTS Is Not Busy

    &{expected_alarm_1}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    # SAS Grant Failure is not visible during scenario execution on AEQM
    &{expected_alarm_2}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    ${20Mhz_cell_present}   Check If 20MHz Cell Is Present    enb_id=${enb_id}
    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...                 query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    ${earfcn_precondition}   Create Dictionary
    ...                            "CELL1"=${55990}    "CELL2"=${56190}    "CELL3"=${56390}    "CELL4"=${56590}

    IF  '${AEQM_present}'=='False'
        ${pMax_precondition}  Create Dictionary    "CELL1"=${25}    "CELL2"=${26}    "CELL3"=${27}    "CELL4"=${28}
    ELSE
        ${pMax_precondition}  Create Dictionary    "CELL1"=${20}    "CELL2"=${19}    "CELL3"=${20}    "CELL4"=${19}
    END

    IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='False'
        ${pMax_from_SAS}  Create Dictionary    "CELL1"=${17}    "CELL2"=${18}    "CELL3"=${19}    "CELL4"=${20}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='False'
        ${pMax_from_SAS}  Create Dictionary    "CELL1"=${20}    "CELL2"=${21}    "CELL3"=${22}    "CELL4"=${23}
    ELSE IF  '${20Mhz_cell_present}'=='True' and '${AEQM_present}'=='True'
        ${pMax_from_SAS}  Create Dictionary    "CELL1"=${17.9}    "CELL2"=${17.9}    "CELL3"=${17.9}    "CELL4"=${17}
    ELSE IF  '${20Mhz_cell_present}'=='False' and '${AEQM_present}'=='True'
        ${pMax_from_SAS}  Create Dictionary    "CELL1"=${14.9}    "CELL2"=${14.9}    "CELL3"=${14.9}    "CELL4"=${14}
    END
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Wait Until Keyword Succeeds    2x    60s    Check If Cells Are Disabled    ${enb_id}

    Wait Until BTS Is Not Busy
    IF  '${AEQM_present}'=='True'
        Create generic delta and perform commissioning  enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_eCPRI_AEQM_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_eCPRI_AEQM.json
    ELSE
        Create generic delta and perform commissioning  enb_id=${enb_id}
        ...  delta_file_tmp=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta_tmp.json
        ...  delta_file_final=${CURDIR}/Data/FeVe03/FEVE_3_Precond_delta.json
    END
    IF  '${20Mhz_cell_present}'=='True'
        ${required_spectrum}  Create List  3550  3555  3560  3565
        ...  3570  3575  3580  3585  3590  3595  3600  3605  3610  3615  3620  3625
    ELSE
        ${required_spectrum}  Create List  3550  3555  3560  3565  3570  3575  3580  3585
    END
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    ${pMax_values}  List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_precondition}

    ${earfcn_values}    ${cell_count}   List earfcn Values For All Cells    ${enb_id}
    FOR    ${i}    IN RANGE    ${cell_count}
        Dictionary Should Contain Value    ${earfcn_precondition}    ${earfcn_values}[${i}]
    END

    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process
    ...    default    4433    config=${CURDIR}/Data/FeVe03/SAS_Sim.conf

    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Wait For All Cells To Be OnAir
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]
    ${pMax_values}   List pMax Values For All Cells    ${enb_id}
    Compare pMax Values For All Cells    ${pMax_values}    ${pMax_from_SAS}
    ${earfcn_values}    ${cell_count}    List earfcn Values For All Cells    ${enb_id}

    FOR    ${i}    IN RANGE    ${cell_count}
        Dictionary Should Not Contain Value    ${earfcn_precondition}    ${earfcn_values[${i}]}
    END

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes
