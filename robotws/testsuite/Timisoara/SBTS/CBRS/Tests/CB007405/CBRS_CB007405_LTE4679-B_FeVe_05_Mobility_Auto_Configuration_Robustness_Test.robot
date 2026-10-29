*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Aleksandra.Chudzik@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    = Review location =
...    http://krlnxaw03.emea.nsn-net.net/r/525/


*** Keywords ***
CBRS_CB007405_LTE4679-B_FeVe_05_Mobility_Auto_Configuration_Robustness_Test
    [Documentation]    Requirement: EDA 02120870 ACTION
    ...                OM_GEN_SFS_CBRS.340; OM_GEN_SFS_CBRS.341
    ...                Purpose: Verify whether neighbor eNB does CBRS band EARFCN auto adaption
    ...                in TDD/FDD cells with LNBTS::actCbrsMobEnh feature flag activated.
    ...                eNB shall execute Cell Based CBRS Mobility auto-configuration scenario.
    ...                This scenario includes configuration of eNB with 5000 mobility objects on neighbor eNB and this simulating customer
    ...                network - SCF is located in /testline_configuration/1_16_UTE4G3766/node2/FULL_SCFC_eNB1809_5000_LNADJL.xml.
    ...                This automated testcase is designed only for double eNB setup (CBRS_3)

#Variables setup
    ${enb1_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${enb2_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}
    &{expected_alarm_1}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6304    fault_name=X2 interface setup failure    severity=Major
    &{expected_alarm_3}   Create Dictionary    fault_id=6203    fault_name=Transport layer connection failure in X2 interface    severity=Major
    ${expected_alarms_list}      Create List    ${expected_alarm_1}    ${expected_alarm_2}    ${expected_alarm_3}
    ${expected_alarm_object}     Create Watchdog Alarm List    ${expected_alarms_list}
    ${eNB1809_5000_LNADJL_SCF}   Set Variable    /home/ute/testline_configuration/1_16_UTE4G3766/node2/FULL_SCFC_eNB1809_5000_LNADJL.xml

#Make sure there is no active legacy SAS connection on eNB1
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb1_id}

#Activate CBRS feature on eNB1
    Enable CBRS Feature On eNB    alias=RAT_1ST

#Activate full SCFC on eNB2 - 5000 LNADJL, 1500 LNREL
    Log To Console    Full Recommissioning is in progress. May take up to 10 minutes.
    Wait Until BTS Is Not Busy

    Perform Commissioning    bts_id=${enb2_id}
    ...                      scf_file=${eNB1809_5000_LNADJL_SCF}
    ...                      skip_parameter_relation=True
    ...                      timeout=600s
    ...                      connection=RAT_2ND

    Wait Until BTS Is Not Busy

    Log To Console    Recommissioning completed.

#Start a new SAS instance
    ${sas_parser_time_start}   Get Time
    Log To Console    Starting SAS (30s HB timer, 60s transmitTimer)
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/Feve05/SAS_Sim.conf

    Log To Console    Waiting for cells activation
    Wait For All Cells To Be OnAir    alias=RAT_1ST
    Wait For All Cells To Be OnAir    alias=RAT_2ND
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarm_object}

#Check if LNADJ object is auto-generated on eNB1 after X2 establishment with eNB2.
    Wait Until Keyword Succeeds    3x
    ...                            30s
    ...                            ute_admin_infomodel.Query Infomodel
    ...                            alias=RAT_1ST
    ...                            query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNADJ_A-* is [adjEnbId=${enb2_id}]

    Log To Console    Grant Terminations are in progress. Expected cell service drop on eNB1.

#Pick random cell on eNB1 and get its grant ID as termination candidate.
#Then terminate selected grant, wait for service drop and possible neighbouring cell reconfiguration.
#This part is repeated three times.
    FOR    ${i}    IN RANGE    ${3}
        Wait For All Cells To Be OnAir    alias=RAT_1ST
        ${cbsd_1st}   Get Random Cbsd Object    alias=RAT_1ST
        ${enb1_cbsd_assigned_id}   Set Variable    ${cbsd_1st["assignedCbsdId"]}
        ${termination_candidate_cell_id}   Get Random Cell From Cbsd Object
        ...                                  cbsd_object=${cbsd_1st}
        ...                                  alias=RAT_1ST
        ${termination_candidate_grant_id}    Get Grant Value By Cell Id
        ...                                  cell_id=${termination_candidate_cell_id}
        ...                                  alias=RAT_1ST
        Wait Until Keyword Succeeds    3x    600s    Terminate Grant And Confirm Cell Drop    cbsd_id=${enb1_cbsd_assigned_id}
        ...                                                                                   grant_id=${termination_candidate_grant_id}
        ...                                                                                   enb_alias=RAT_1ST
        Log To Console    Waiting for possible neigbour cell reconfiguration
        Sleep And Display Progress    60    sec
        Wait For All Cells To Be OnAir    alias=RAT_1ST
        Log To Console    Termination successfull. Preparation for another one out of ${3}.
    END
    Log To Console    Three Terminations are finished.

    Log To Console    Checking if CB007405 worked - LNADJLs on eNB2 should update fDlEarfcn after channels change on eNB1 cells.
    Wait Until Keyword Succeeds    10x    60s    Check If CB007405 MOC Updates Worked    enb1_id=${enb1_id}    enb2_id=${enb2_id}
    Log To Console    CB007405 worked.

    Log To Console    Analysing the logs looking for unexpected HB with RC: 502.
    ${sas_parser_time_stop}   Get Time
    ${sas_log_parsed}   Parse Sas Log File
    ...                   log_file_name=${sas_logs_dir}
    ...                   date_start=${sas_parser_time_start}
    ...                   date_stop=${sas_parser_time_stop}

    ${HB_response_codes}   Extract Values From Sas Log
    ...                      log_name=${sas_log_parsed}
    ...                      data_type=heartbeatResponse
    ...                      parameter=responseCode

    Should Not Contain    container=${HB_response_codes}    item=${502}
    ...    msg=Undexpected behaviour detected, check logs - heartbeatResponse with responseCode 502 detected!

    Log To Console    No unexpected breaks in communication. Checking historical alarms. And then env cleanup.

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    5x    90s    Perform Commissioning
    ...                           bts_id=${enb2_id}
    ...                           scf_file=${SUITE_LOGS_DIR_PATH}RAT_2ND_SCFC_Before_Suite.xml
    ...                           connection=RAT_2ND


List EARFCN Values Under LNADJL objects
    [Arguments]        ${enb_id}    ${enb_ims_alias}
    [Documentation]    Queries the eNB for details of each LNADJL objects under defined LNADJ, extracts their fDlEarfcn and adds to a list.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    ...                enb_ims_alias - alias of infomodel where you connect
    ...                lnadj_obj - specify the ID of LNADJ to check

    @{lnadjl_param_list}   ute_admin_infomodel.Query Infomodel    alias=${enb_ims_alias}
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/LNADJ_A-${255}/LNADJL_A-*
    ${cell_num}   Get Length    ${lnadjl_param_list}
    ${earfcn_list}   Create List
    FOR    ${i}    IN RANGE    ${cell_num}
        Append To List    ${earfcn_list}    ${lnadjl_param_list[${i}]['fDlEarfcn']}
    END

    RETURN  ${earfcn_list}  ${cell_num}


Check If CB007405 MOC Updates Worked
    [Arguments]        ${enb1_id}    ${enb2_id}
    [Documentation]    Gathers EARFCN values on eNB1 cells and compares with EARFCN values of LNADJL objects on eNB2

    ${earfcn_list_cells_enb1}    ${cell_count}   List earfcn Values For All Cells    enb_id=${enb1_id}
    ${earfcn_list_lnadjl_enb2}   ${cell_count}   List EARFCN Values Under LNADJL objects    enb_id=${enb2_id}    enb_ims_alias=RAT_2ND
    List Should Contain Sub List    ${earfcn_list_cells_enb1}
    ...                             ${earfcn_list_lnadjl_enb2}
    ...                             msg=eNB2 LNADJL objects have not updated fDlEarfcn parameter after update on eNB1. This is against CB007405.
