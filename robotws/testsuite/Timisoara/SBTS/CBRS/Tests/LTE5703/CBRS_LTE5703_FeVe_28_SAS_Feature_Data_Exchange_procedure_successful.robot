*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Michal Moskala

*** Keywords ***
CBRS_LTE5703_FeVe_28_SAS_Feature_Data_Exchange_procedure_successful
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.374
    ...                Purpose: The purpose of this test is to verify whether Feature Data Exchange procedure
    ...                fulfils requirements stated by WInnForum Technical Specification version 2.0.
    ...                This scenario verifies if CBSD and SAS successfully exchange supported feature lists.

    #NEW SAS SIM SYNTAX FIX IFOLOGY
    IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
        ${sasSimConfig}  Set Variable    ${CURDIR}/Data/FeVe28/SAS_Sim.conf
    ELSE
        ${sasSimConfig}  Set Variable    ${CURDIR}/Data/FeVe28/SAS_Sim_oldbranch.conf
    END
    #NEW SAS SIM SYNTAX FIX IFOLOGY

    ${alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}

    Wait Until BTS Is Not Busy
    Kill All SAS Processes

    ${add_Icg_Ccg_plan}   Replace Variables In File
    ...                     file_path=${CURDIR}/Data/FeVe28/FeVe_28_add_Icg_Ccg_tmp.json
    ...                     file_destination=${OUTPUT DIR}/FeVe_28_add_Icg_Ccg.json
    ...                     enb_id=${enb_id}

    Wait Until Keyword Succeeds    6x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${add_Icg_Ccg_plan}    connection=${alias}

    #Checking if channel bandwidth is set to 10 MHz for all CBSD cells (if not - perform recommissionig)
    FOR    ${i}    IN RANGE    ${1}    ${num_of_cells}+1
        ${is_chBw_10MHz}   Run Keyword And Return Status    Query Infomodel    alias=${alias}
        ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i} is [ulChBw=10000000]
        IF  '${is_chBw_10MHz}'=='False'
            Modify Bandwidth For All Cbsd Cells    enb_id=${enb_id}    required_chbw=10
            BREAK
        END
    END

    Disable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${sasSimConfig}

    Wait Until BTS Is Not Busy
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Start Watchdog Alarm Detection
    Wait For Any Grant To Be Authorized    alias=${alias}

    ${grant_info}   Get Grant Details For Each CBSD Cell    alias=${alias}
    ${time_stop}   Get Time

    Check If Inquiry is TS2.0 Compliant    alias=${alias}
    ...                                    time_start=${time_start}
    ...                                    time_stop=${time_stop}
    ...                                    sas_log_path=${sas_logs_dir}
    ...                                    enb_id=${enb_id}

    Verify Presence of featureDataExchange After Certain Procedure    start_from=spectrumInquiryResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}

    Verify Presence of featureDataExchange After Certain Procedure    start_from=grantResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}

    Verify Presence of featureDataExchange After Certain Procedure    start_from=heartbeatResponse
    ...                                                               time_start=${time_start}
    ...                                                               time_stop=${time_stop}
    ...                                                               sas_log_path=${sas_logs_dir}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
