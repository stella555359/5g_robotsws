*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      ../../step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      ../../step_keywords/Common/snapshot_check.robot
*** Variables ***

*** Keywords ***
General_SiSo_Loop_Collect_Snapshot
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case to check ue attach
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.03.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${total_times}=${20}    ${connection}=GNB_OAM    ${with_call}=${True}    ${with_peak}=${False}
    ...    ${snapshot_path}=${SAVE LOG DIRECTORY}    ${duration}=${60}
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${itime}    IN RANGE    1    ${total_times}+1
        Log to console    \n---------------------\nstability run: ${itime}/${total_times}
        ${snapshot_zip_file_path}    COAM Save snapshot via webUI    download_dir=${snapshot_path}
        sleep  30s
        Check Log File From Snapshot File List    snapshot_zip_file_path=${snapshot_zip_file_path}
        gnb should be onair with cell up    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
    END
