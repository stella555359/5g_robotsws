*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Katarzyna Olszewska
...    Justyna Durak
...    Jakub Klein
...    Piotr Lukaszewicz
...    Aleksandra Chudzik
...    = Review location =
...    http://reviews.emea.nsn-net.net/r/57275/


*** Keywords ***
CBRS_CB007405_FeVe_08_eNB_Based_CBRS_Mobility_auto-configuration_triggered_by_multiple_cells_reconfiguration
    [Documentation]     Requirement: OM_GEN_SFS_CBRS.340; OM_GEN_SFS_CBRS.341
    ...                 Purpose: Verify whether neighbor eNB does CBRS band EARFCN auto adaption
    ...                 in TDD/FDD cells with LNBTS::actCbrsMobEnh feature flag activated.
    ...                 eNB shall execute Cell Based CBRS Mobility auto-configuration scenario.
    ...                 This scenario covers simultaneous reconfiguration of two CBRS Cells.
    ...                 This automated testcase is designed only for double eNB setup (CBRS_3)

#Variables setup
    ${enb1_id}                 Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb2_id}                 Set Variable    ${testlines.${testline_id}.node2.enb_id}
    ${cplane_addr_enb2}          Set Variable    ${testlines.${testline_id}.node2.cplane_ip_addr}
    &{expected_alarm}          Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ${expected_alarm_object}   Create Watchdog Alarm List    ${expected_alarm}

#Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb1_id}

#Activate CBRS feature on eNB1 and eNB2
    Enable CBRS Feature On eNB    alias=RAT_1ST
    Enable CBRS Feature On eNB    alias=RAT_2ND    target_enb=${testlines.${testline_id}.node2.enb_id}

#Start a new SAS instance
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process
    ...    config=/home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/CBRS/CNI_NIDD/Tests/CB007405/Data/Feve08/SAS_Sim.conf
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For All Cells To Be OnAir    alias=RAT_2ND
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarm_object}

#Create LNADJ between eNB1 and eNB2 so they can exchange information
    Replace Variables In File    ${CURDIR}/Data/Feve08/Feve08_LNADJ_update.json
    ...                          ${OUTPUT_DIR}/Feve08_LNADJ_update.json
    ...                          ENB_ID=${enb1_id}
    ...                          NEIGHBOUR_ID=${enb2_id}
    ...                          C_PLANE=${cplane_addr_enb2}
    Wait Until BTS Is Not Busy
    Run Keyword And Ignore Error    Perform Delta Recommissioning
    ...                             ${OUTPUT_DIR}/Feve08_LNADJ_update.json
    ...                             connection=RAT_1ST
    Wait Until Keyword Succeeds    3x
    ...                            30s
    ...                            ute_admin_infomodel.Query Infomodel
    ...                            alias=RAT_2ND
    ...                            query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNADJ_A-* is [adjEnbId=${enb1_id}]

    Enable CRBS Mobility enhancement Feature On eNB    alias=RAT_2ND    enb_id=${enb2_id}

#Pick random cells on eNB1 and get their EARFCN as termination candidates
    ${cbsd_1st}   Get Random Cbsd Object    alias=RAT_1ST
    ${enb1_cbsd_assigned_id}   Set Variable    ${cbsd_1st["assignedCbsdId"]}
    ${first_termination_candidate_cell_id}   Get Random Cell From Cbsd Object    cbsd_object=${cbsd_1st}
    ...                                                                        alias=RAT_1ST
    FOR    ${i}    IN RANGE    999    #do-while loop to make sure we pick two different cells
        ${second_termination_candidate_cell_id}   Get Random Cell From Cbsd Object    cbsd_object=${cbsd_1st}
        ...                                                                             alias=RAT_1ST
        Exit For Loop If    '${second_termination_candidate_cell_id}'!='${first_termination_candidate_cell_id}'
    END
    ${first_termination_candidate_earfcn}   Get Earfcn Value By Cell Id    cell_id=${first_termination_candidate_cell_id}
    ...                                                                  alias=RAT_1ST
    ${second_termination_candidate_earfcn}   Get Earfcn Value By Cell Id    cell_id=${second_termination_candidate_cell_id}
    ...                                                                  alias=RAT_1ST
    ${first_termination_candidate_grant_id}    Get Grant Value By Cell Id    cell_id=${first_termination_candidate_cell_id}
    ...                                                                  alias=RAT_1ST
    ${second_termination_candidate_grant_id}    Get Grant Value By Cell Id    cell_id=${second_termination_candidate_cell_id}
    ...                                                                  alias=RAT_1ST

#On eNB2 create mobility objects that point at eNB1 termination candidates
    Replace Variables In File    ${CURDIR}/Data/Feve08/Feve08_mobility_objects.json
    ...                          ${OUTPUT_DIR}/Feve08_mobility_objects.json
    ...                          ENB_ID=${enb2_id}
    ...                          ADJ_ENB_ID=${enb1_id}
    ...                          ADJ_LNCEL_ID_1=${first_termination_candidate_cell_id}
    ...                          ADJ_LNCEL_ID_2=${second_termination_candidate_cell_id}

    Replace Variables In File    ${CURDIR}/Data/Feve08/Feve08_mobility_objects_for_SBTS22R2_onwards.json
    ...                          ${OUTPUT_DIR}/Feve08_mobility_objects_for_SBTS22R2_onwards.json
    ...                          ENB_ID=${enb2_id}
    ...                          ADJ_ENB_ID=${enb1_id}
    ...                          ADJ_LNCEL_ID_1=${first_termination_candidate_cell_id}
    ...                          ADJ_LNCEL_ID_2=${second_termination_candidate_cell_id}

    ${release_version}       Get Active Release Version
    Wait Until BTS Is Not Busy    alias=RAT_2ND

    IF  '${release_version}'=='SBTS21B' or '${release_version}'=='SBTS22R1'
        Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/Feve08_mobility_objects.json  connection=RAT_2ND
    ELSE
        Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/Feve08_mobility_objects_for_SBTS22R2_onwards.json  connection=RAT_2ND
    END
#Terminate candidates on eNB1 and wait for the reconfiguration
    ${timestamp_before_termination}   Get Time
    ${timestamp_before_termination}   Subtract Time From Date    ${timestamp_before_termination}    00:00:05    exclude_millis=True
    Terminate Two Grants And Confirm Cells Drop    cbsd_id_1=${enb1_cbsd_assigned_id}    grant_id_1= ${first_termination_candidate_grant_id}
    ...    cbsd_id_2=${enb1_cbsd_assigned_id}    grant_id_2=${second_termination_candidate_grant_id}
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    ${timestamp_after_termination}   Get Time
    Check If Grant Terminate Message Appeared In Sas Log    sas_log_name=${sas_logs_dir}
    ...    start_timestamp=${timestamp_before_termination}    stop_timestamp=${timestamp_after_termination}
    ...    grant_id=${first_termination_candidate_grant_id}
    Check If Grant Terminate Message Appeared In Sas Log    sas_log_name=${sas_logs_dir}
    ...    start_timestamp=${timestamp_before_termination}    stop_timestamp=${timestamp_after_termination}
    ...    grant_id=${second_termination_candidate_grant_id}
    Wait For All Cells To Be OnAir    alias=RAT_1ST

#Get updated EARFCN of terminated cells
    ${first_cell_updated_earfcn}   Get Earfcn Value By Cell Id    ${first_termination_candidate_cell_id}    alias=RAT_1ST
    ${second_cell_updated_earfcn}   Get Earfcn Value By Cell Id    ${second_termination_candidate_cell_id}    alias=RAT_1ST

    ${updated_earfcn_list}   Create List    ${first_cell_updated_earfcn}    ${second_cell_updated_earfcn}

#On eNB2 check if Mobility objects (AMPLER, IRFIM, LNHOIF, REDRT) have updated the EARFCN
    Verify Update of eNB Based Mobility Objects    alias=RAT_2ND
    ...                                            updated_earfcn_list=${updated_earfcn_list}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Remove BTS Mobility Objects From eNB    enb_id=${enb2_id}    AND
    ...                           Disable CBRS Feature On eNB    alias=RAT_1ST    AND
    ...                           Disable CBRS Feature On eNB    alias=RAT_2ND    target_enb=${testlines.${testline_id}.node2.enb_id}    AND
    ...                           Kill All SAS Processes


Remove BTS Mobility Objects From eNB
    [Documentation]    Removes mobility objects (LNREL, AMPLER, IRFIM, LNHOIF, REDRT) created for test purpose
    [Arguments]    ${enb_id}

    Replace Variables In File    ${CURDIR}/Data/Feve08/Feve08_mobility_objects_removal.json
    ...                          ${OUTPUT_DIR}/Feve08_mobility_objects_removal.json
    ...                          ENB_ID=${enb_id}

    Wait Until Keyword Succeeds    6x    30s    Run Keywords
    ...                            Wait Until BTS Is Not Busy    AND
    ...                            Run Keyword And Ignore Error    Perform Delta Recommissioning
    ...                            ${OUTPUT_DIR}/Feve08_mobility_objects_removal.json
    ...                            connection=RAT_2ND


Verify Update of eNB Based Mobility Objects
    [Documentation]    Checks whether AMPLER, IRFIM, LNHOIF, REDRT objects have updated their EARFCN values according to the reconfiguration
    [Arguments]    ${alias}    ${updated_earfcn_list}

    ${modred_object}   Query Infomodel    query=get object /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/MODPR_A-*/MODRED_A-*
    ...                  timeout=30
    ...                  alias=${alias}

    ${redirFreqEutra_before_update}   Set Variable    ${modred_object['redirFreqEutra']}
    ${query}   Set Variable    /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/MODPR_A-*/MODRED_A-*
    ${modred_object}   Query Infomodel    alias=${alias}    timeout=700
    ...    query=get object ${query} is [redirFreqEutra!=${redirFreqEutra_before_update}]


    Sleep    60s
    ${mopr_object}   Query Infomodel    query=get object /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/MOPR_A-*
    ...                timeout=30
    ...                alias=${alias}
    ${mored_object}   Query Infomodel    query=get object /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/MOPR_A-*/MORED_A-*
    ...                 timeout=30
    ...                 alias=${alias}
    ${modpr_object}   Query Infomodel    query=get object /MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/MODPR_A-*
    ...                 timeout=30
    ...                 alias=${alias}


    List Should Contain Sublist    ${mopr_object['freqLayListDedLteLB']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${mopr_object['freqLayListServiceBasedHo']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${mopr_object['freqLayListDedLteLB']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${mopr_object['freqLayListDedVoLteHo']}    ${updated_earfcn_list}

    ${mored_redirFreqEutra}   Create List    ${mored_object['redirFreqEutra']}
    Should Contain Any    ${mored_redirFreqEutra}    ${updated_earfcn_list[0]}    ${updated_earfcn_list[1]}

    List Should Contain Sublist    ${modpr_object['freqLayListDedLteLB']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${modpr_object['freqLayListServiceBasedHo']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${modpr_object['freqLayListDedLteLB']}    ${updated_earfcn_list}
    List Should Contain Sublist    ${modpr_object['freqLayListDedVoLteHo']}    ${updated_earfcn_list}
    ${modred_redirFreqEutra}   Create List    ${modred_object['redirFreqEutra']}
    Should Contain Any    ${modred_redirFreqEutra}    ${updated_earfcn_list[0]}    ${updated_earfcn_list[1]}
