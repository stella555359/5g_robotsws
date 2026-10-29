*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Karol.Sadowski@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Elzbieta.Wlodarczyk@nokia.com
...    Aleksandra.Chudzik@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1198/

*** Keywords ***
CBRS_CB008735_FeVe_01_Grant_Update_Procedure_maxEirp
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.547;OM_GEN_SFS_CBRS.523;OM_GEN_SFS_CBRS.538;OAM_REQ_CBRS_131
    ...              Purpose: This user scenario describes replacement of an existing Grant
    ...              by a new Grant without Grant Relinquishment procedure, where only maxEirp is
    ...              modified in the new Grant request. New value of maxEirp is sent in HB response (OperationParam)
    ...              Test Steps:
    ...              Step 1: Raise power level on each cell
    ...              Step 2: Query infomodel for a change in GRANT_INFO objects (forced by maxEIRP update in HBreq)
    ...              Step 3: Compare maxEIRP and power levels prior and after grantUpdate procedure (twice)


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${updated_grantId}   Set Variable    3570000000_3580000000

    Kill All SAS Processes

    Replace Variables In File    ${CURDIR}/Data/Feve01/Feve01_precondition.json
    ...                          ${OUTPUT_DIR}/Feve01_precondition.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Feve01/Feve01_postcondition.json
    ...                          ${OUTPUT_DIR}/Feve01_postcondition.json
    ...                          enb_id=${enb_id}

    Wait Until BTS Is Not Busy

    Log To Console    ${\n}Step 1: Raising power level on each cell
    Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/Feve01_precondition.json
    ...                                         connection=RAT_1ST

    ${time_start}   Get Time
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Feve01/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    ${grant_info}   Get Grant Details For Each CBSD Cell
    ${grantMaxEirp_before_grant_update}   Get grantMaxEirp For Selected GrantId
    ...                                     grant_info=${grant_info}
    ...                                     selected_grantId=${updated_grantId}
    ${pMax_list_before_grant_update}   List pMax Values For All Cells
    ...                                  enb_id=${enb_id}
    Log To Console    pMax values before grant update procedure: ${pMax_list_before_grant_update}
    Log To Console    Waiting for first grantMaxEirp change. This is forced in heartBeatResponse.
    Log To Console    Step 2: Query infomodel for a change in GRANT_INFO objects (forced by maxEIRP update in HBreq)
    ute_admin_infomodel.Wait For Infomodel Event    event=change /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* [grantMaxEirp]
    ...                                             timeout=300
    ...                                             alias=RAT_1ST
    ${grant_info}   Get Grant Details For Each CBSD Cell
    ${grantMaxEirp_first_grant_update}   Get grantMaxEirp For Selected GrantId
    ...                                    grant_info=${grant_info}
    ...                                    selected_grantId=${updated_grantId}

    Log To Console    Waiting for cell drop due to grant update.
    Wait For Any Cell To Be Dropped    wait_time=3min
    Log To Console    Waiting for cell onAir after grant update.
    Wait For All Cells To Be OnAir

    ${pMax_list_first_grant_update}   List pMax Values For All Cells
    ...                                 enb_id=${enb_id}
    Log To Console   pMax values after first grant update procedure: ${pMax_list_first_grant_update}
    Log To Console   Waiting for second grantMaxEirp change. This is forced in heartBeatResponse.
    ute_admin_infomodel.Wait For Infomodel Event    event=change /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* [grantMaxEirp]
    ...                                     timeout=300
    ...                                     alias=RAT_1ST
    ${grant_info}   Get Grant Details For Each CBSD Cell
    ${grantMaxEirp_second_grant_update}   Get grantMaxEirp For Selected GrantId
    ...                                     grant_info=${grant_info}
    ...                                     selected_grantId=${updated_grantId}

    Log To Console    Waiting for cell drop due to grant update.
    Wait For Any Cell To Be Dropped    wait_time=3min
    Log To Console    Waiting for cell onAir after grant update.
    Wait For All Cells To Be OnAir

    ${pMax_list_second_grant_update}   List pMax Values For All Cells    enb_id=${enb_id}
    Log To Console    pMax values after second grant update procedure: ${pMax_list_second_grant_update}
    Log To Console    Step 3: Compare maxEIRP and power levels prior and after grantUpdate procedure
    Should Not Be Equal    first=${pMax_list_before_grant_update}
    ...                    second=${pMax_list_first_grant_update}
    ...                    msg=pMax value did not change after grant update procedure.
    Should Not Be Equal    first=${pMax_list_first_grant_update}
    ...                    second=${pMax_list_second_grant_update}
    ...                    msg=pMax value did not change after grant update procedure.
    Should Not Be Equal    first=${grantMaxEirp_before_grant_update}
    ...                    second=${grantMaxEirp_first_grant_update}
    ...                    msg=grantMaxEIRP value did not change after grant update procedure.
    Should Not Be Equal    first=${grantMaxEirp_first_grant_update}
    ...                    second=${grantMaxEirp_second_grant_update}
    ...                    msg=grantMaxEIRP value did not change after grant update procedure.

    ${time_stop}   Get Time

    Log To Console    Checking SASSim.log. No relinquishmentRequest is expected.
    ${parsed_log_file}   Parse Sas Log File
    ...                    log_file_name=${sas_logs_dir}
    ...                    date_start=${time_start}
    ...                    date_stop=${time_stop}
    ${relinquishmentRequest}   Extract Values From Sas Log
    ...                          log_name=${parsed_log_file}
    ...                          parameter=grantId
    ...                          data_type=relinquishmentRequest
    Should Be Empty    ${relinquishmentRequest}
    ...                msg=With grant update procedure, CBSD should not relinquish old grant.
    Log To Console    SASSim.log correct. No relinquishmentRequest is recorded. Running postconditions now.

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/Feve01_postcondition.json
    ...                                                                       connection=RAT_1ST    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}
