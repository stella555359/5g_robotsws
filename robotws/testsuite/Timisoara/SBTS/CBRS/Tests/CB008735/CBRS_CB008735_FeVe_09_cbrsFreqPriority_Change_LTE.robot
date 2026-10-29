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
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1249/

*** Keywords ***
CBRS_CB008735_FeVe_09_cbrsFreqPriority_Change_LTE
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.544
    ...              Purpose: In this user scenario, CBSD shall relinquish all the grants and reselect channels
    ...              for the CBSD when cbrsFreqPriory is changed. This user scenario obsoletes the legacy behavior
    ...              for cbrsFreqPriority change defined in LTE5659
    ...              Test Steps:
    ...              Step 1: Change cbrsFreqType to PAL
    ...              Step 2: Change cbrsFreqPriority on a single cell. Relinquishment of all grants is expected.


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${assigned_grant_list}   Create List    3550000000_3560000000
    ...                                       3560000000_3570000000
    ...                                       3570000000_3580000000
    ...                                       3580000000_3590000000

    Kill All SAS Processes

    Replace Variables In File    ${CURDIR}/Data/Feve09/Feve09_precondition.json
    ...                          ${OUTPUT_DIR}/Feve09_precondition.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Feve09/Feve09_postcondition.json
    ...                          ${OUTPUT_DIR}/Feve09_postcondition.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Feve09/Feve09_cbrsFreqPriority.json
    ...                          ${OUTPUT_DIR}/Feve09_cbrsFreqPriority.json
    ...                          enb_id=${enb_id}

    Wait Until BTS Is Not Busy

    Log To Console   changing cbrsFreqType to PAL

    Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/Feve09_precondition.json
    ...                                         connection=RAT_1ST

    ${time_start}   Get Time
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Feve09/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    ${grant_info}   Get Grant Details For Each CBSD Cell
    Log To Console   Active Grants: ${grant_info}

    Log To Console   Changing cbrsFreqPriority on a single cell. Relinquishment of all grants is expected.
    Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/Feve09_cbrsFreqPriority.json
    ...                                         connection=RAT_1ST

    Wait For Any Cell To Be Dropped    wait_time=3min
    Wait For All Cells To Be OnAir
    ${time_stop}   Get Time

    Log To Console   Checking SASSim.log for 4xRelinquishmentRequest.
    ${parsed_log_file}   Parse Sas Log File
    ...                    log_file_name=${sas_logs_dir}
    ...                    date_start=${time_start}
    ...                    date_stop=${time_stop}
    ${relinquishmentRequests}   Extract Values From Sas Log
    ...                           log_name=${parsed_log_file}
    ...                           parameter=grantId
    ...                           data_type=relinquishmentRequest
    List Should Contain Sub List    list1=${relinquishmentRequests}
    ...                             list2=${assigned_grant_list}
    ...                             msg=All grants should be relinquished after change of cbrsFreqPriority.

    Log To Console   SASSim.log correct. RelinquishmentRequests are present. Running postconditions now....


    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/Feve09_postcondition.json
    ...                                                                       connection=RAT_1ST    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}


