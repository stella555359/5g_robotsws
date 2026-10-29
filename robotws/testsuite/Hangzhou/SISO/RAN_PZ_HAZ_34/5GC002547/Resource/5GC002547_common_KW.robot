*** Settings ***
Documentation     author: yang.yang
...               Group: HGZ_SG5
...               contact: yang.9.yang@nokia-sbell.com


Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot



*** Variables ***
${gnb_name_0}        test_name

*** Keywords ***

"${Step}" Login WebUI and Get Parameter
    log to console    \n"${Step}" Login WebUI and get parameter
    Wait Until Keyword Succeeds    10min    1min    Check Cell is UP
    ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID

"${Step}" Determine and Set chBw
    log to console    \n"${Step}" Determine and Set chBw
    ${cells_list}    Get list of all cells
    set suite variable    ${cells_list}
    log to console   \n cell_list: ${cells_list}
    ${chBw_list}    Create List
    sleep    1s
    FOR    ${cell_id}    IN    @{cells_list}
        ${chBw_0}                 selenium_coam.get_parameter_value
    ...                          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...                          filter_param=Channel bandwidth  
                                Append To List   ${chBw_list}    ${chBw_0}
    END
    log to console   \n chBw_list: ${chBw_list}
    ${output_0}   Run Keyword And Ignore Error    Should Not Be Equal    ${chBw_list[0]}    ${chBw}
    log to console   \n ${output_0}
    ${output_1}   Run Keyword And Ignore Error    Should Not Be Equal    ${chBw_list[1]}    ${chBw}
    log to console   \n ${output_1}
    ${output}   Run Keyword And Ignore Error        should be true    '${output_0[0]}'=='PASS' and '${output_1[0]}'=='PASS'
    log to console   \n ${output}
    #run keyword if     '${output[0]}' == 'PASS'    log to console   \n welcome
    run keyword if     '${output[0]}' == 'PASS'    Set chBw Parameter

Set chBw Parameter
    [Arguments]   
    #Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    #virtual_enable=${False}
    sleep    1s
    FOR    ${cell_id}    IN    @{cells_list}
        Change Parameter via webUI                    expected_val=${chBw}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...                                                        filter_param=Channel bandwidth    
    ...                                                        p_name=chBw    
    ...                                                        need_active=${False}
        Change Parameter via webUI                    expected_val=${type0Cor_In}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...                                                        filter_param=Coreset configuration Index    
    ...                                                        p_name=type0CoresetConfigurationIndex  
    ...                                                        need_active=${False}
    END
    sleep    5s
    Validate and activate and check activate plan status
    Run Keyword And Ignore Error    WEBUI Logout
    sleep    1min
    Wait Until Keyword Succeeds    15min    1min    Check Cell is UP

"${Step}" Verify Param Modification
    log to console    \n"${Step}" verify parameter modification
    #Modification type - online
    wait until keyword succeeds     2min    30s   siso_resource.WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name    new_value=${gnb_name_0}
    sleep    3s
    Validate and activate and check activate plan status
    sleep    3s
    ${output}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name   timeout=10
    should be equal      ${output}    ${gnb_name_0}
    #Modification type - Conditional BTS restart
    ${output_0}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Maximum output power   timeout=10
    log to console    \n pMax is ${output_0}
    ${pMax_origin}    string.get substring    ${output_0}    start=0    end=-3
    ${result_0}    Convert To Number    ${pMax_origin}
    ${pMax_test_val_f} =    Evaluate    ${result_0} + 0.1
    ${pMax_test_val}    convert to string    ${pMax_test_val_f}
    log to console    \n pMax test value is ${pMax_test_val}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Maximum output power    new_value=${pMax_test_val}
    sleep    3s
    Validate and activate and check activate plan status
    Run Keyword And Ignore Error    WEBUI Logout
    sleep    1min
    Wait Until Keyword Succeeds    15min    1min    Check Cell is UP

"${Step}" gNB Commission With Loading Scf
    log to console    \n"${Step}" gNB commission with loading scf
    WEBUI Login
    siso_resource.reload scf
    Wait Until Keyword Succeeds    5min    1min    Check Cell is UP

"${Step}" Modify pMax to tirgger fault with 2CC
    log to console           \n"${Step}": Modify pMax to tirgger fault
#   get original pMax
    ${pMax_origin_dBm}   selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power   timeout=30
    ${pMax_origin_tmp}    string.get substring    ${pMax_origin_dBm}    start=0    end=-3
    set test variable    ${pMax_origin}    ${pMax_origin_tmp}
#   get norminal pMax
    ${bpf_gzfileName}=         get bpf gz fileName
    ${bpf_content}   ${bpf_file}   get BPF file content    ${bpf_gzfileName}
    ${xml handler}=    ParseXML.Parse Xml    source=${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    source=${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power.5G"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    #PowerAllocated <= 10*log10(PowerRated*1000)+DLPowerAccuracy; DLPowerAccuracy is set 0.1dB #PR509046
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    log to console    \nMaxPower is ${MaxPower}
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f_1} =    Evaluate    ${MaxPower} - 3        #
    ${pMax_modify_f_2} =    Evaluate    ${MaxPower} - 3.1
    ${pMax_modify_1}    convert to string    ${pMax_modify_f_1}
    ${pMax_modify_2}    convert to string    ${pMax_modify_f_2}
    set test variable    ${pMax_modify_1}
    set test variable    ${pMax_modify_2}
    log to console    \npMax_modify_1 is ${pMax_modify_1}
    log to console    \npMax_modify_2 is ${pMax_modify_2}
    Change Parameter via webUI                    expected_val=${pMax_modify_1}
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                        filter_param=Maximum output power
    ...                                                        p_name=pMax    
    ...                                                        need_active=${False}
    Change Parameter via webUI                    expected_val=${pMax_modify_2}  
    ...                                                        dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2
    ...                                                        filter_param=Maximum output power
    ...                                                        p_name=pMax
    ...                                                        need_active=${False}
    sleep    2s
    Validate and activate and check activate plan status
    Run Keyword And Ignore Error    WEBUI Logout

#juanjuan_kw
"${Step}" Lock One Cell And Check Cell Status
    Lock Cell Group    cell_group_idx=${0}    cell_idx=${1}
    Check Cell Be UnLocked    cell_idx=${2}
    UnLock Cell Group    cell_group_idx=${0}    cell_idx=${1}
    Lock Cell Group    cell_group_idx=${1}    cell_idx=${2}
    Check Cell Be UnLocked    cell_idx=${1}
    UnLock Cell Group    cell_group_idx=${1}    cell_idx=${2}

"${Step}" Lock All Cell Groups
    Lock Cell Group    cell_group_idx=${0}    cell_idx=${1}
    Lock Cell Group    cell_group_idx=${1}    cell_idx=${2}

"${Step}" UnLock All Cell Groups
   UnLock Cell Group    cell_group_idx=${0}    cell_idx=${1}
   UnLock Cell Group    cell_group_idx=${1}    cell_idx=${2}
   Wait Until Keyword Succeeds    10min    10s     Check Cell is UP

"${Step}" Lock One Cell And Check Cell Status With 6CC
    Lock Cell Group    cell_group_idx=${0}    cell_idx=${1}
    Check Cell Be UnLocked    cell_idx=${2}
    UnLock Cell Group    cell_group_idx=${0}    cell_idx=${1}
    Lock Cell Group    cell_group_idx=${1}    cell_idx=${2}
    Check Cell Be UnLocked    cell_idx=${1}
    UnLock Cell Group    cell_group_idx=${1}    cell_idx=${2}
    Lock Cell Group    cell_group_idx=${2}    cell_idx=${3}
    Check Cell Be UnLocked    cell_idx=${4}
    UnLock Cell Group    cell_group_idx=${2}    cell_idx=${3}
    Lock Cell Group    cell_group_idx=${3}    cell_idx=${4}
    Check Cell Be UnLocked    cell_idx=${3}
    UnLock Cell Group    cell_group_idx=${3}    cell_idx=${4}
    Lock Cell Group    cell_group_idx=${4}    cell_idx=${5}
    Check Cell Be UnLocked    cell_idx=${6}
    UnLock Cell Group    cell_group_idx=${4}    cell_idx=${5}
    Lock Cell Group    cell_group_idx=${5}    cell_idx=${6}
    Check Cell Be UnLocked    cell_idx=${5}
    UnLock Cell Group    cell_group_idx=${5}    cell_idx=${6}

"${Step}" Lock All Cell Groups With 6CC
    ${result}    Convert To Integer    6
    FOR    ${id}    IN    ${result}
          Lock Cell Group    cell_group_idx=${id}    cell_idx=${id+1}
    END

"${Step}" UnLock All Cell Groups With 6CC
    ${result}    Convert To Integer    6
    FOR    ${id}    IN    ${result}
         UnLock Cell Group    cell_group_idx=${id}    cell_idx=${id+1}
    END 
   Wait Until Keyword Succeeds    10min    10s     Check Cell is UP

Lock Cell Group
    [Arguments]    ${cell_group_idx}    ${cell_idx}
    log to console    Lock Cell
    Perform Cell Group Lock    cell_group_idx=${cell_group_idx}    download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    5min    30s    Check Cell Be Locked     cell_idx=${cell_idx}
    sleep    10s
    WEBUI Logout

UnLock Cell Group
    [Arguments]    ${cell_group_idx}    ${cell_idx}
    log to console    Unlock Cell
    Run Keyword And Ignore Error       selenium_coam.logout
    Perform Cell Group Unlock    cell_group_idx=${cell_group_idx}    download_dir=${SAVE LOG DIRECTORY}
    Wait Until Keyword Succeeds    5min    30s    Check Cell Be UnLocked     cell_idx=${cell_idx}

Check Cell Be UnLocked
    [Arguments]  ${cell_idx}   
    WEBUI Login
    ${output_tmp}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    ${cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${cell_info}[Administrative state]    Unlocked
    should be equal      ${cell_info}[Availability status]     Online
    should be equal      ${cell_info}[Operational state]        Enabled
    WEBUI Logout

Lock RU
    [Arguments]    ${ru_index}
    log to console        Lock RU
    Perform RU Lock    ru_index=${ru_index}    download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    5min    10s    Check RU Be Locked    ${ru_index}
    WEBUI Logout

Unlock RU
    [Arguments]    ${ru_index}
    log to console        Lock RU
    Perform RU Unlock    ru_index=${ru_index}    download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    5min    10s    Check RU Be Unlocked    ru_index=${ru_index}
    WEBUI Logout

Check RU Be Unlocked
    [Arguments]    ${ru_index}
    ${output_tmp}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Enabled
    should match regexp    ${RU_info}[Availability status]    Online
    should match regexp    ${RU_info}[Administrative state]    Unlocked
    should match regexp    ${RU_info}[Procedural status]    configured

Unlock All RUs
   [Arguments]    ${ru_num}
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
        Unlock RU    ru_index=${ru_id}
    END
