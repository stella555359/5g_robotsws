*** Settings ***
Documentation     author: Han Ruiyu
...               contact: ruiyu.han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009499

Library           OperatingSystem
Library           Collections
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Library           taf.hw.rf_attenuator    WITH NAME    att

*** Keywords ***
Block Cell for L3call
    [Arguments]   ${4G_call}=${false}   ${5G_call}=${false}   ${5G_operation}=Locked   ${4G_operation}=locked
    Run keyword if   ${4G_call}==${true}   Block Unblock 4G cell  5G_operation=${5G_operation}  4G_operation=${4G_operation}
    Run keyword if   ${5G_call}==${true}   Block Unblock 5G cell  5G_operation=${5G_operation}  4G_operation=${4G_operation}


Block Unblock 5G cell
    [Arguments]   ${5G_operation}=Unlocked   ${4G_operation}=unlocked
    Log   ${5G_operation}
    Log   ${4G_operation}
    ${nr_cells}    coam.Get cells info    connection=COAM
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=COAM   timeout=30
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        Run Keyword If    '${index['globalCellId']}'!='${nrcall_cell_index}'    Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{lte_cells}
        run keyword and ignore error   Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword if  '${5G_operation.lower()}'=='locked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=${index}
        ...   ELSE IF   '${5G_operation.lower()}'=='unlocked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status    cell_index=${index}
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword if  '${4G_operation.lower()}'=='locked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN Block LTE cell and check status  cell_index=${index}
        ...   ELSE IF   '${4G_operation.lower()}'=='unlocked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock LTE cell and check status    cell_index=${index}
    END


Block Unblock 4G cell
    [Arguments]   ${5G_operation}=Unlocked   ${4G_operation}=unlocked
    Log   ${5G_operation}
    Log   ${4G_operation}
    ${nr_cells}    coam.Get cells info    connection=COAM
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=COAM   timeout=30
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{lte_cells}
        Run Keyword If    '${index['globalCellId']}'!='${ltecall_cell_index}'    Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{nr_cells}
        run keyword and ignore error   Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword if   '${5G_operation.lower()}'=='locked'
        ...   run keyword and ignore error
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=${index}
        ...   ELSE IF   '${5G_operation.lower()}'=='unlocked'
        ...   run keyword and ignore error
        ...    wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status    cell_index=${index}
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword if   '${4G_operation.lower()}'=='locked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN Block LTE cell and check status  cell_index=${index}
        ...   ELSE IF   '${4G_operation.lower()}'=='unlocked'
        ...   ADMIN UnBlock LTE cell and check status    cell_index=${index}
    END


Block Unblock All cell
    ${nr_cells}    coam.Get cells info    connection=COAM
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=COAM   timeout=30
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{lte_cells}
        Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{nr_cells}
        Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        ADMIN Block NR cell and check status   cell_index=${index}
    END
    FOR   ${index}    IN   @{ltecells_info}
        ADMIN Block LTE cell and check status   cell_index=${index}
    END
    FOR   ${index}    IN   @{nrcells_info}
        ADMIN UnBlock NR cell and check status    cell_index=${index}
    END
    FOR   ${index}    IN   @{ltecells_info}
        ADMIN UnBlock LTE cell and check status    cell_index=${index}
    END
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair


Unblock All Cells
    ${nr_cells}    coam.Get cells info    connection=COAM
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=COAM   timeout=30
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        run keyword and ignore error   Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{lte_cells}
        run keyword and ignore error   Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword and ignore error   ADMIN UnBlock NR cell and check status    cell_index=${index}
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword and ignore error   ADMIN UnBlock LTE cell and check status    cell_index=${index}
    END
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair


Lock Cell for L3call
    [Arguments]   ${4G_call}=${false}   ${5G_call}=${false}   ${5G_operation}=Locked   ${4G_operation}=locked
    Run keyword if   ${4G_call}==${true}   Lock Unlock 4G cell   5G_operation=${5G_operation}  4G_operation=${4G_operation}
    Run keyword if   ${5G_call}==${true}   Lock Unlock 5G cell   5G_operation=${5G_operation}  4G_operation=${4G_operation}
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  60s


Lock Unlock 5G cell
    [Arguments]   ${5G_operation}=Unlocked   ${4G_operation}=unlocked
    log to console    \n| ${5G_operation} 5G cell start...\n
    COAM Login   alias=lockNR
    ${nr_cells}    coam.Get cells info    connection=lockNR
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=lockNR   timeout=30
    COAM Logout   connection=lockNR
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        Run Keyword If    '${index['globalCellId']}'!='${nrcall_cell_index}'    Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{lte_cells}
        run keyword and ignore error   Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${index}
        ...    filter_param=Administrative state    new_value=${5G_operation}
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
        ...    filter_param=Administrative state    new_value=${4G_operation}
    END
    log to console    \n| ${5G_operation} 5G cell finished\n


Lock Unlock 4G cell
    [Arguments]   ${5G_operation}=Unlocked   ${4G_operation}=unlocked
    log to console    \n| ${4G_operation} 4G cell start...\n
    COAM Login   alias=lockLTE
    ${nr_cells}     coam.Get cells info    connection=lockLTE   timeout=30
    ${lte_cells}    coam.Get cells info    cell_type=lte   connection=lockLTE
    COAM Logout   connection=lockLTE
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{lte_cells}
        Run Keyword If    '${index['globalCellId']}'!='${ltecall_cell_index}'    Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{nr_cells}
        run keyword and ignore error   Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${index}
        ...    filter_param=Administrative state    new_value=${5G_operation}
    END
    FOR   ${index}    IN   @{ltecells_info}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
        ...    filter_param=Administrative state    new_value=${4G_operation}
    END
    log to console    \n| ${4G_operation} 4G cell finished\n


Lock Unlock All cell
    log to console    \n| Lock Unlock All cell start...\n
    COAM Login   alias=lock
    ${nr_cells}    coam.Get cells info    connection=lock
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=lock   timeout=30
    COAM Logout   connection=lock
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        run keyword and ignore error   Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{lte_cells}
        run keyword and ignore error   Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${index}
        ...    filter_param=Administrative state    new_value=Locked
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
        ...    filter_param=Administrative state    new_value=locked
    END
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  60s
    FOR   ${index}    IN   @{nrcells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${index}
        ...    filter_param=Administrative state    new_value=Unlocked
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
        ...    filter_param=Administrative state    new_value=unlocked
    END
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  60s
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    log to console    \n| Lock Unlock All cell finished\n


Unlock All Cells
    log to console    \n| Unlock All Cells start...\n
    COAM Login   alias=unlock
    ${nr_cells}    coam.Get cells info    connection=unlock
    ${lte_cells}   coam.Get cells info    cell_type=lte   connection=lock   timeout=30
    COAM Logout   connection=unlock
    @{nrcells_info}   Create List
    @{ltecells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        run keyword and ignore error   Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR    ${index}    IN    @{lte_cells}
        run keyword and ignore error   Append To List    ${ltecells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${index}
        ...    filter_param=Administrative state    new_value=Unlocked
    END
    FOR   ${index}    IN   @{ltecells_info}
        run keyword and ignore error   selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${index}
        ...    filter_param=Administrative state    new_value=unlocked
    END
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  60s
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    log to console    \n| Unlock All Cells finished\n

CIT Check Point 1 Lock RU1 check cells
    ${smod_dist_list}=    Get Runtime FRM info
    ${smod_dist}    set variable    ${smod_dist_list[0]}
    @{MO_list}    Split String    ${smod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    COAM Lock RU    dist_name=${runtime_info}/EQM_R-1/APEQM_R-1/RMOD_R-1
    wait until keyword succeeds   1min    20s   ADMIN check NR cell status    cell_index=1    expected_status=degraded
    wait until keyword succeeds   1min    20s   ADMIN check NR cell status    cell_index=2    expected_status=degraded
    COAM Unlock RU   dist_name=${runtime_info}/EQM_R-1/APEQM_R-1/RMOD_R-1
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=1    expected_status='availabilitystatus': '-'
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'

CIT Check Point 2 Reset RU1 check cells
    ${smod_dist_list}=    Get Runtime FRM info
    ${smod_dist}    set variable    ${smod_dist_list[0]}
    @{MO_list}    Split String    ${smod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    COAM Reset RMOD   dist_name=${runtime_info}/EQM_R-1/APEQM_R-1/RMOD_R-1
    wait until keyword succeeds   1min    20s   ADMIN check NR cell status    cell_index=1    expected_status=degraded
    wait until keyword succeeds   1min    20s   ADMIN check NR cell status    cell_index=2    expected_status=degraded
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=1    expected_status='availabilitystatus': '-'
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'

CIT Check Point 3 Block Cell1 check cells
    ADMIN Block NR cell and check status    cell_index=1
    ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'
    ADMIN UnBlock NR cell and check status    cell_index=1
    ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=1    expected_status='availabilitystatus': '-'

CIT Check Point 4 Reset Cell1 check cells
    ${smod_dist_list}=    Get Runtime FRM info
    ${smod_dist}    set variable    ${smod_dist_list[0]}
    @{MO_list}    Split String    ${smod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    coam.reset_cell   cell_id=${runtime_info}/NRBTS_R-${MRBTS_ID}/NRCELL_R-1    connection=COAM
    ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=1    expected_status='availabilitystatus': '-'
    wait until keyword succeeds   10min    20s
    ...   ADMIN check NR cell availability Status    cell_index=2    expected_status='availabilitystatus': '-'

