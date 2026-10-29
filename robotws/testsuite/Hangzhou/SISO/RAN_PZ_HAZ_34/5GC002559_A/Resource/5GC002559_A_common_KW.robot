*** Settings ***
Documentation
...   author: yang.9.yang
...   contact: yang.9.yang@nokia-sbell.com


Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           ../../../../OAM/RAN_PZ_HAZ_34/libraries/snapshot_structure.py
Library           ../../../../OAM/RAN_PZ_HAZ_34/libraries/verify_snapshot.py
Library           verify_snapshot.VerifySnapshot    WITH NAME    snapshotlib


*** Variables ***
${tim_advan_offset_0}       n25600


*** Keywords ***
Collect Snapshot Log
    [Arguments]    ${coverage}=All log files    ${save_location}=Local
    WEBUI Login
    selenium_coam.snapshot_collection_settings    coverage=${coverage}    save_location=${save_location}
    ${snapshot_log}   selenium_coam.collect_snapshot    snapshot_waiting_timeout=1800
    set suite variable    ${snapshot_log}
    ${snap_tmp_path}    ${snapshot_name}    Split Path   ${snapshot_log}
    set suite variable    ${snap_tmp_path}
    set suite variable    ${snapshot_name}
    wait until keyword succeeds      20min    30s    check snapshot collected
    OperatingSystem.Copy File     ${snapshot_log}     ${SAVE LOG DIRECTORY}
    WEBUI Logout
    sleep    2s
    log to console    ${snapshot_log}
    #log to console    ${snap_tmp_path} is ok!
    #log to console    ${snapshot_name}
    log to console    Snapshot Collect Complete

check snapshot collected
    ${rc}    ${output}    Run And Return Rc And Output    ls -l ${snap_tmp_path}
    should not contain    ${output}     ${snapshot_name}.part

Unzip Snapshot Log
    csn.Connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.execute    command=killall -9 firefox    connection=VM
    #sleep    2s
    #csn.execute    command=cp ${snapshot_log} ${SAVE LOG DIRECTORY}    connection=VM
    sleep    5s
    snapshotlib.un_zip    path_name=${SAVE LOG DIRECTORY}    file_name=${snapshot_name}
    sleep    5s
    ${output_1}    csn.execute    command=find ${SAVE LOG DIRECTORY} -type d -name "*RMOD_L_1_startup*"    connection=VM
    ${output_2}    should match regexp      ${output_1}    (.*)\r\n
    ${file_path}    set variable      ${output_2}[1]
    log to console    ${file_path}
    set suite variable     ${file_path}
    csn.execute    command=xz -dvf ${file_path}/startup_DEFAULT.log.xz    connection=VM
    sleep    1s
    log to console    xz complete
    csn.disconnect    connection=VM 

Analyze Snapshot Log
    [Arguments]    ${Analy_size}=PaId_pattern_X    ${Analy_size_t}=PaId_pattern_Y
    csn.Connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    ${output}    csn.execute    command=cat ${file_path}/startup_DEFAULT.log | grep pattern     connection=VM
    log to console    ${output}
    ${output_0}    Run Keyword And Ignore Error    should contain    ${output}    ${Analy_size}
    ${output_1}    Run Keyword And Ignore Error    should contain    ${output}    ${Analy_size_t}
    ${result_0}    Create List
    Append To List   ${result_0}    ${output_0}
    Append To List   ${result_0}    ${output_1}
    ${result}    convert to string    ${result_0}
    should contain    ${result}    PASS
    csn.disconnect    connection=VM 

Set TDD Frame Structure
    [Arguments]    ${lteToNrFrameShift_Set}=${TRUE}    ${tim_advan_offset}=${tim_advan_offset_0}
    #Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    #virtual_enable=${False}
    sleep    1s
    Change Parameter via webUI                    expected_val=${fram_st}     
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=Frame Structure Type    
    ...                                                        p_name=frameStructureType    
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${guar_per}  
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=Guard Period length    
    ...                                                        p_name=guardPeriodLength    
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${tdlte_uldl_con}      
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=TDLTE UL-DL configuration    
    ...                                                        p_name=tdLteUlDlConfig
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${uldl_log}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=UL to DL logical data slot ratio
    ...                                                        p_name=ulDlDataSlotRatio
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${prach_con}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=PRACH configuration index
    ...                                                        p_name=prachConfigurationIndex
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${tim_off_lte_nr}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=Time offset between the LTE PCell and the NR cell
    ...                                                        p_name=lteToNrTimeOffset
    ...                                                        need_active=${False}
    run keyword if    ${lteToNrFrameShift_Set}                 Set LTE NR Frame Shift
    Change Parameter via webUI                    expected_val=${tim_advan_offset}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=Timing Advance Offset
    ...                                                        p_name=timingAdvanceOffset
    ...                                                        need_active=${False}
    sleep    5s
    Validate and activate and check activate plan status
    Run Keyword And Ignore Error    WEBUI Logout
    sleep    5min

Set LTE NR Frame Shift
    Change Parameter via webUI                    expected_val=${lte_NR_fram}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=LTE to NR frame shift
    ...                                                        p_name=lteToNrFrameShift
    ...                                                        need_active=${False}

"${Step}" Login WebUI and Get Parameter
    log to console    Step1:Login WebUI and get parameter
    Wait Until Keyword Succeeds    10min    1min    Check Cell is UP
    ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID
    #${mrbts_id}  ${nrbts_id}    Get BTS ID
    Backup commission file via WebUI

"${Step}" Set Parameter
    log to console    Step2:Set Parameter
    #Backup commission file via WebUI
    Set TDD Frame Structure
    Wait Until Keyword Succeeds    10min    1min    Check Cell is UP

"${Step}" Collect Snapshot
    log to console    Step3:Collect Snapshot
    5GC002559_A_common_KW.Collect Snapshot Log
    5GC002559_A_common_KW.Unzip Snapshot Log
    5GC002559_A_common_KW.Analyze Snapshot Log    Analy_size=${Analy_size_0}    Analy_size_t=${Analy_size_1}
