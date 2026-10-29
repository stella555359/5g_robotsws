*** Settings ***
Documentation      author: Shi Jeffrey
...                contact: jeffrey.shi@nokia-sbell.com
...                This robot file is for CB012702

Resource    ../../5GC001178-A/Resource/5GC001178-A-5GC000157_Common_KW.robot
Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009576_SG05/resource/CB009576_X_resource.robot
Library    taf.collectors.core   WITH NAME   core
Library    taf.sbts.oam.coam.admin  WITH NAME   admin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.selenium.sbts   WITH NAME   selenium_sbts
Library    taf.transport.ssh   WITH NAME   csn

*** Keywords ***
OAM_KPI_1a_Site_Reset_with_faulty_BBMOD
    [Arguments]    ${with_graceful}
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    log to console    start to reset gnb with faulty BBMOD_1
    selenium_coam.reset_site    ${with_graceful}
    log to console    site reset triggered!!
    selenium logout and close browser
    sleep    10min
    wait until keyword succeeds    15min    1min    All_other_celles_should_be_onair_after_BBMOD_faulty
    Check_Alarm_Expected
Check_Alarm_Expected
    @{Fault_whitelist}    create list    10    4655    4654    61524    61652    4592    61649    16    1868    7311
    log to console    start to run Check_Alarm_Expected
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    @{active_alarm_list}    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_active_alarm_info
    @{history_alarm_list}    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_history_alarm_info
    ${fault_id_list}    Create List
    ${unexpect_fault}    Create List
    FOR   ${alarm}   IN    @{active_alarm_list}
        ${faultid}    Set Variable    ${alarm['Fault ID']}
        Append to list    ${fault_id_list}    ${faultid}
    END
    log to console   active alarm check complete!
    FOR   ${alarm}   IN    @{history_alarm_list}
        ${faultid}    Set Variable    ${alarm['Fault ID']}
        Append to list    ${fault_id_list}    ${faultid}
    END
    log to console   history alarm check complete!
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    Should Be Empty    ${unexpect_fault}
    [Teardown]  run keyword and ignore error    selenium logout and close browser
All_other_celles_should_be_onair_after_BBMOD_faulty
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    Log to console    All LTE cells should be onair after BBMOD-2 faulty while impacted NR cells shoud not onair
    ${possible_onair_NRCell}    Create List   MRBTS-2463/NRBTS-2463/NRCELL-9    MRBTS-2463/NRBTS-2463/NRCELL-10
    ...    MRBTS-2463/NRBTS-2463/NRCELL-11
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    FOR    ${cell}    IN    @{nr_cells_info}
        Run keyword if     '${cell['status']['operationalState'].lower()}' == 'enabled'
        ...    list should contain value   ${possible_onair_NRCell}   ${cell['id']['configuration']}
        ...    ELSE    Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   disabled
    END
Set_flag_for_BBMOD_faulty
    csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    csn.execute    command=touch /ffs/run/config/hpd_debug_config.txt   connection=gnb
    csn.execute    command=echo -e "\nhpd_detect_only_mask=0x40\n" >> /ffs/run/config/hpd_debug_config.txt   connection=gnb
    csn.execute    crasign /ffs/run/config/hpd_debug_config.txt    connection=gnb
    csn.execute    command=cat /ffs/run/config/hpd_debug_config.txt   connection=gnb
    csn.Disconnect    connection=gnb
Clear_flag_for_BBMOD_faulty
    csn.Connect to   hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    csn.execute    command=rm /ffs/run/config/hpd_debug_config.txt   connection=gnb
    [Teardown]    csn.Disconnect     connection=gnb
Reset_gNB_after_clear_flag
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds    3X    1min    selenium_coam.reset_site
    run keyword and ignore error    selenium logout and close browser
    sleep    10min
    wait until keyword succeeds    15min    30s    Check all cells Info Should Be On Air