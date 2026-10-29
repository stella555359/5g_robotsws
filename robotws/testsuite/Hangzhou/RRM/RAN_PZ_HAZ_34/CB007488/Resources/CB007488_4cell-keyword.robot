*** Settings ***
Documentation     author: y6lu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: lu.yu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py

*** Variables ***

${counter_1_path}    BTS/CELLS/NRCELL-1/NRACH
${counter_2_path}    BTS/CELLS/NRCELL-2/NRACH
${counter_3_path}    BTS/CELLS/NRCELL-3/NRACH



${prachconfig_1_path}    MRBTS-10048/NRBTS-10048/NRCELL-1
${prachconfig_2_path}    MRBTS-10048/NRBTS-10048/NRCELL-2
${prachconfig_3_path}    MRBTS-10048/NRBTS-10048/NRCELL-3

*** Keywords ***

L3 call setup
    [Arguments]    ${UE_TYPE}=samsung    ${dltp}=${0}    ${ultp}=${0}    ${4G_check}=${True}
    ${cellid}    Run Keyword If    ${defaultLnRelGnbCellId}==1    set variable    ${160769}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==2    set variable    ${160770}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==5    set variable    ${160771}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==6    set variable    ${160772}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    #Log To Console    \n ###UE Start traffic and check TP ###
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=150M    duration=600    iperf_type=via_command
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=150M    duration=600
    #power_ue.Check throughput    ue_index=${0}    direction=dl    ue_type=${UE_TYPE}    throughput=${dltp}
    #power_ue.Check throughput    ue_index=${0}    direction=ul    ue_type=${UE_TYPE}    throughput=${ultp}    cellid=${cellid}
    #power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup second
    [Arguments]    ${UE_TYPE}=samsung    ${dltp}=${0}    ${ultp}=${0}    ${4G_check}=${True}
    ${cellid}    Run Keyword If    ${defaultLnRelGnbCellId}==1    set variable    ${160769}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==2    set variable    ${160770}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==5    set variable    ${160771}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==6    set variable    ${160772}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    #power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    #Log To Console    \n ###UE Start traffic and check TP ###
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=150M    duration=600    iperf_type=via_command
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=150M    duration=600
    #power_ue.Check throughput    ue_index=${0}    direction=dl    ue_type=${UE_TYPE}    throughput=${dltp}
    #power_ue.Check throughput    ue_index=${0}    direction=ul    ue_type=${UE_TYPE}    throughput=${ultp}    cellid=${cellid}
    #power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


Check PM counters
    [Arguments]    ${counter_id}=M55306C06001    ${sleep}=${0}    ${num_count}=${0}
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    run keyword if    ${sleep}==${1}    sleep    ${reportingIntervalPm}
    ${counter_path}    Run Keyword If    ${defaultLnRelGnbCellId}==1    set variable    ${counter_1_path}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==2    set variable    ${counter_2_path}
    ...    ELSE IF    ${defaultLnRelGnbCellId}==5    set variable    ${counter_3_path}
    ${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=${counter_id}
    ...    dic_path=${counter_path}    min_len=${0}
    log to console    ${counter_id}=${sb1_dlcounter}
    should be true    ${sb1_dlcounter} > ${num_count}

    #${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=M55306C00001
    #...    dic_path=${counter_path}    min_len=${0}
    #log to console    ${sb1_dlcounter}
    #should be true    ${sb1_dlcounter} > 0

    #${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=M55306C03001
    #...    dic_path=${counter_path}    min_len=${0}
    #log to console    ${sb1_dlcounter}
    #should be true    ${sb1_dlcounter} > 0

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    log to console    ${counter_id}    ${dic_path}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length    ${counter_value}
    should be true    ${len} > ${min_len}
    [Return]    ${counter_value[0]}

Check X2 Status
    #${X2linkstatus}    Get NIDD parameter value    class_name=LTEENB_A    pattern=x2LinkStatus    connection=COAM
    #log to console    ${X2linkstatus}
    ${X2linkstatus}    selenium_coam.get_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/LTEENB-1    filter_param=X2C link status
    Should be equal    ${X2linkstatus}    available
    #${X2linkstatus-2}    admin_cli.get_parameters    dist_name=MRBTS-1099/NRBTS-1099/LTEENB-1    pattern=x2LinkStatus    connection=COAM
    #log to console    ${X2linkstatus-2}
    #Should Contain    ${X2linkstatus}   available


Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-10048/NRBTS-10048/NRCELL-1
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    3s



set bandwidth
    [Arguments]    ${value}    ${gscn_n66}=5364

    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-9    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-30    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}

    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-31    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}

    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-32    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}

    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}

    run keyword if    '${value}'=='5MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_5}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_5}

    run keyword if    '${value}'=='10MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_10}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_10}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_10}

    run keyword if    '${value}'=='15MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_15}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_15}

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_20}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_20}

    selenium_coam.enable_virtual_display

    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser

    run keyword if    '${value}'=='5MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=2    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=0    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=0

    run keyword if    '${value}'=='10MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    run keyword if    '${value}'=='15MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=135600
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=349000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=349000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=126400
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=429000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=429000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=1580
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Global synchronization channel number    new_value=${gscn_n66}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Global synchronization channel number    new_value=${gscn_n66}

    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=COAM
    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9


set NSA bandwidth
    [Arguments]    ${value}    ${gscn_n66}=5364
    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=${value}   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=${value}    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}


    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-2    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-20    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}

    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-2    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-21    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}

    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-2    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-22    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}

    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-2    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-10048/NRBTS-10048/BWP_PROFILE-23    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}

    run keyword if    '${value}'=='5MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_5}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_5}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_5}

    run keyword if    '${value}'=='10MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_10}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_10}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_10}

    run keyword if    '${value}'=='15MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_15}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_15}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_15}

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-1    key=cellBwpList    value=${cellBwpList_params_20}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_20}    AND
    ...    Set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3    key=cellBwpList    value=${cellBwpList_params_20}

    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser

    run keyword if    '${value}'=='5MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=2    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=0    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=0

    run keyword if    '${value}'=='10MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    run keyword if    '${value}'=='15MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    run keyword if    '${value}'=='20MHz'    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Coreset configuration Index    new_value=7

    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=135600
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=349000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=349000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=126400
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=429000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=429000
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=1580
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=Global synchronization channel number    new_value=${gscn_n66}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=Global synchronization channel number    new_value=${gscn_n66}

    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=COAM
    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

Lock SA first
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10048/NRBTS-10048/SNSSAI-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=true    connection=COAM
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10048/NRBTS-10048/SERVEDAMF-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=true    connection=COAM

set NSA condition
    #${is_SA}    Get NIDD parameter value    class_name=NRCELL_A    pattern=cellDepType    connection=COAM
    #run keyword if    '${is_SA}' != 'NSA'    Lock SA first
    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/CB007488-NSA-20M.xml    connection=COAM

Modify HBTE Channel Vaules
    [Arguments]    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}


Set PA
    Connect to eNB via ssl
    ${defaultLnRelGnbCellId}    Get NIDD parameter value    class_name=LNCEL_A    pattern=defaultLnRelGnbCellId    connection=enblte
    Enblte close down
    set suite variable    ${defaultLnRelGnbCellId}
    run keyword if    ${defaultLnRelGnbCellId}==1    run keywords
    ...    Modify HBTE Channel Vaules    value=0    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=1    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=2    gnb_id=0
    run keyword if    ${defaultLnRelGnbCellId}==2    run keywords
    ...    Modify HBTE Channel Vaules    value=0    ru_id=1    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=2    gnb_id=0
    run keyword if    ${defaultLnRelGnbCellId}==5    run keywords
    ...    Modify HBTE Channel Vaules    value=0    ru_id=2    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=0    gnb_id=0    AND
    ...    Modify HBTE Channel Vaules    value=60    ru_id=1    gnb_id=0

Precondition
    [Arguments]    ${prachconfigurationindex_1_expect}=${40}    ${prachconfigurationindex_2_expect}=${41}
    ...    ${prachconfigurationindex_3_expect}=${42}    ${prachsequencetype_expect}=Unrestricted
    ...    ${zeroCorrelationZoneconfig_1_except}=${0}    ${zeroCorrelationZoneconfig_2_except}=${8}
    ...    ${zeroCorrelationZoneconfig_3_except}=${15}
    ...    ${cbraPreamblesPerSsb_except}=n64    ${ChBwdl_except}=20MHz
    ...    ${ChBwul_except}=20MHz
    ...    ${actPrachMultiplexing_except}=${true}    ${pucchModeSelect_except}=longPucch    ${raResponseWindow_except}=sl20
    ...    ${msg1FrequencyStart_except}=${7}
    ...    ${nbrOfSsbPerRachOccasion_except}=one    ${powerRampingStep_except}=dB2    ${powerRampingStepHighPriorityCfra_except}=dB2
    ...    ${prachRootSequenceIndex_except}=${0}    ${initialPreambleReceivedTargetPower_except}=${-104}    ${preambleTransMax_except}=n10
    ...    ${totalNumberOfRAPreambles_except}=${64}    ${raContentionResolutionTmr_expect}=sf64    ${rsrpThresholdSSB_expect}=${19}
    ...    ${maxHarqMsg3Tx_except}=${5}    ${maxUlHarqTx_except}=${5}    ${type}=SA    ${pucchF3ModulationScheme_except}=qpsk_4psk
    ...    ${pucchF3MaxCodeRate_except}=zeroDot15    ${srPeriodicity_except}=slots80    ${csiReportPeriodicity_except}=slots160
    ...    ${reqMinNumPuschPrb_except}=${19}    ${p0NominalPucchF1F3_except}=${-108}    ${pucchF1DeltaF_except}=${-10}
    ...    ${pucchF3DeltaF_except}=${0}    ${gscn_n66_except}=${5364}
    log to console    \n in precondition stage
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=COAM
    run keyword if    '${type}'=='NSA' and '${ChBwdl_except}'=='20MHz'    set NSA condition

    run keyword if    '${type}'=='SA' and '${ChBwdl_except}'=='5MHz'
    ...    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/ABIL-922-FDD-4cell-both-5M-longpucch.xml    connection=COAM

    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=COAM

    @{MOs}    admin_cli.get_managed_objects    class_name=NRCELL_A    connection=COAM
    &{dict_pattern_0}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}   connection=COAM
    set suite variable    &{dict_pattern_0}
    &{dict_pattern_1}=    enblte.get_parameters    dist_name=${MOs[1]['distName']}   connection=COAM
    set suite variable    &{dict_pattern_1}
    &{dict_pattern_2}=    enblte.get_parameters    dist_name=${MOs[2]['distName']}   connection=COAM
    set suite variable    &{dict_pattern_2}

    run keyword if    ${dict_pattern_0['prachConfigurationIndex']} != ${prachconfigurationindex_1_expect}
    ...    Set parameter    key=prachConfigurationIndex    value=${prachconfigurationindex_1_expect}
    run keyword if    ${dict_pattern_1['prachConfigurationIndex']} != ${prachconfigurationindex_2_expect}
    ...    Set parameter    key=prachConfigurationIndex    value=${prachconfigurationindex_2_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    run keyword if    ${dict_pattern_2['prachConfigurationIndex']} != ${prachconfigurationindex_3_expect}
    ...    Set parameter    key=prachConfigurationIndex    value=${prachconfigurationindex_3_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['prachSequenceType']}' != '${prachsequencetype_expect}'
    ...    run keywords
    ...    Set parameter    key=prachSequenceType    value=${prachsequencetype_expect}    AND
    ...    Set parameter    key=prachSequenceType    value=${prachsequencetype_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=prachSequenceType    value=${prachsequencetype_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    ${dict_pattern_0['zeroCorrelationZoneConfig']} != ${zeroCorrelationZoneconfig_1_except}
    ...    Set parameter    key=zeroCorrelationZoneConfig    value=${zeroCorrelationZoneconfig_1_except}
    run keyword if    ${dict_pattern_1['zeroCorrelationZoneConfig']} != ${zeroCorrelationZoneconfig_2_except}
    ...    Set parameter    key=zeroCorrelationZoneConfig    value=${zeroCorrelationZoneconfig_2_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    run keyword if    ${dict_pattern_2['zeroCorrelationZoneConfig']} != ${zeroCorrelationZoneconfig_3_except}
    ...    Set parameter    key=zeroCorrelationZoneConfig    value=${zeroCorrelationZoneconfig_3_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['cbraPreamblesPerSsb']}' != '${cbraPreamblesPerSsb_except}'
    ...    run keywords
    ...    Set parameter    key=cbraPreamblesPerSsb    value=${cbraPreamblesPerSsb_except}    AND
    ...    Set parameter    key=cbraPreamblesPerSsb    value=${cbraPreamblesPerSsb_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=cbraPreamblesPerSsb    value=${cbraPreamblesPerSsb_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['pucchModeSelect']}' != '${pucchModeSelect_except}'
    ...    run keywords
    ...    Set parameter    key=pucchModeSelect    value=${pucchModeSelect_except}    AND
    ...    Set parameter    key=pucchModeSelect    value=${pucchModeSelect_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=pucchModeSelect    value=${pucchModeSelect_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['raResponseWindow']}' != '${raResponseWindow_except}'
    ...    run keywords
    ...    Set parameter    key=raResponseWindow    value=${raResponseWindow_except}    AND
    ...    Set parameter    key=raResponseWindow    value=${raResponseWindow_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=raResponseWindow    value=${raResponseWindow_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['nbrOfSsbPerRachOccasion']}' != '${nbrOfSsbPerRachOccasion_except}'
    ...    run keywords
    ...    Set parameter    key=nbrOfSsbPerRachOccasion    value=${nbrOfSsbPerRachOccasion_except}    AND
    ...    Set parameter    key=nbrOfSsbPerRachOccasion    value=${nbrOfSsbPerRachOccasion_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2     AND
    ...    Set parameter    key=nbrOfSsbPerRachOccasion    value=${nbrOfSsbPerRachOccasion_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['powerRampingStep']}' != '${powerRampingStep_except}'
    ...    run keywords
    ...    Set parameter    key=powerRampingStep    value=${powerRampingStep_except}    AND
    ...    Set parameter    key=powerRampingStep    value=${powerRampingStep_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=powerRampingStep    value=${powerRampingStep_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['powerRampingStepHighPriorityCfra']}' != '${powerRampingStepHighPriorityCfra_except}'
    ...    run keywords
    ...    Set parameter    key=powerRampingStepHighPriorityCfra    value=${powerRampingStepHighPriorityCfra_except}    AND
    ...    Set parameter    key=powerRampingStepHighPriorityCfra    value=${powerRampingStepHighPriorityCfra_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=powerRampingStepHighPriorityCfra    value=${powerRampingStepHighPriorityCfra_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL_3

    run keyword if    ${dict_pattern_0['prachRootSequenceIndex']} != ${prachRootSequenceIndex_except}
    ...    run keywords
    ...    Set parameter    key=prachRootSequenceIndex    value=${prachRootSequenceIndex_except}    AND
    ...    Set parameter    key=prachRootSequenceIndex    value=${prachRootSequenceIndex_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=prachRootSequenceIndex    value=${prachRootSequenceIndex_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    ${dict_pattern_0['initialPreambleReceivedTargetPower']} != ${initialPreambleReceivedTargetPower_except}
    ...    run keywords
    ...    Set parameter    key=initialPreambleReceivedTargetPower    value=${initialPreambleReceivedTargetPower_except}    AND
    ...    Set parameter    key=initialPreambleReceivedTargetPower    value=${initialPreambleReceivedTargetPower_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=initialPreambleReceivedTargetPower    value=${initialPreambleReceivedTargetPower_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['preambleTransMax']}' != '${preambleTransMax_except}'
    ...    run keywords
    ...    Set parameter    key=preambleTransMax    value=${preambleTransMax_except}    AND
    ...    Set parameter    key=preambleTransMax    value=${preambleTransMax_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=preambleTransMax    value=${preambleTransMax_except}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    ${dict_pattern_0['totalNumberOfRAPreambles']} != ${totalNumberOfRAPreambles_except}
    ...    run keywords
    ...    Set parameter    key=totalNumberOfRAPreambles    value=${totalNumberOfRAPreambles_except}    AND
    ...    Set parameter    key=totalNumberOfRAPreambles    value=${totalNumberOfRAPreambles_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=totalNumberOfRAPreambles    value=${totalNumberOfRAPreambles_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['raContentionResolutionTmr']}' != '${raContentionResolutionTmr_expect}'
    ...    run keywords
    ...    Set parameter    key=raContentionResolutionTmr    value=${raContentionResolutionTmr_expect}    AND
    ...    Set parameter    key=raContentionResolutionTmr    value=${raContentionResolutionTmr_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=raContentionResolutionTmr    value=${raContentionResolutionTmr_expect}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    ${dict_pattern_0['rsrpThresholdSSB']} != ${rsrpThresholdSSB_expect}
    ...    run keywords
    ...    Set parameter    key=rsrpThresholdSSB    value=${rsrpThresholdSSB_expect}    AND
    ...    Set parameter    key=rsrpThresholdSSB    value=${rsrpThresholdSSB_expect}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=rsrpThresholdSSB    value=${rsrpThresholdSSB_expect}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    run keyword if    '${dict_pattern_0['pucchF3ModulationScheme']}' != '${pucchF3ModulationScheme_except}'
    ...    run keywords    Set parameter    key=pucchF3ModulationScheme    value=qpsk_4psk    AND
    ...    Set parameter    key=pucchF3ModulationScheme    value=qpsk_4psk    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=pucchF3ModulationScheme    value=qpsk_4psk    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    run keyword if    '${dict_pattern_0['pucchF3MaxCodeRate']}' != '${pucchF3MaxCodeRate_except}'
    ...    run keywords    Set parameter    key=pucchF3MaxCodeRate    value=zeroDot15    AND
    ...    Set parameter    key=pucchF3MaxCodeRate    value=zeroDot15    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=pucchF3MaxCodeRate    value=zeroDot15    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    run keyword if    '${dict_pattern_0['srPeriodicity']}' != '${srPeriodicity_except}'
    ...    run keywords    Set parameter    key=srPeriodicity    value=slots80    AND
    ...    Set parameter    key=srPeriodicity    value=slots80    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=srPeriodicity    value=slots80    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    ${csi_report}    Create Dictionary    csiReportPeriodicity=${csiReportPeriodicity_except}
    @{csi}    create list    ${csi_report}

    run keyword if    '${dict_pattern_0['periodicCsiAcquisition']['csiReportPeriodicity']}' != '${csiReportPeriodicity_except}'
    ...    run keywords    Set parameter    key=periodicCsiAcquisition    value=${csi}    AND
    ...    Set parameter    key=periodicCsiAcquisition    value=${csi}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=periodicCsiAcquisition    value=${csi}    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    run keyword if    '${dict_pattern_0['reqMinNumPuschPrb']}' != '${reqMinNumPuschPrb_except}'
    ...    run keywords    Set parameter    key=reqMinNumPuschPrb    value=${reqMinNumPuschPrb_except}    AND
    ...    Set parameter    key=reqMinNumPuschPrb    value=${reqMinNumPuschPrb_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=reqMinNumPuschPrb    value=${reqMinNumPuschPrb_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    ${ulPowerControlCommon_change}    Create Dictionary    p0NominalPucchF1F3=${p0NominalPucchF1F3_except}
    ...    pucchF1DeltaF=${pucchF1DeltaF_except}
    ...    pucchF3DeltaF=${pucchF3DeltaF_except}
    @{ulPowerControlCommon}    create list    ${ulPowerControlCommon_change}


    run keyword if    '${dict_pattern_0['ulPowerControlCommon']['p0NominalPucchF1F3']}' != '${p0NominalPucchF1F3_except}'
    ...    run keywords    Set parameter    key=ulPowerControlCommon    value=${ulPowerControlCommon}    AND
    ...    Set parameter    key=ulPowerControlCommon    value=${ulPowerControlCommon}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=ulPowerControlCommon    value=${ulPowerControlCommon}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3

    ${maxHarqMsg3Tx}    Get NIDD parameter value    class_name=NRCELLGRP_A    pattern=maxHarqMsg3Tx    connection=COAM
    run keyword if    ${maxHarqMsg3Tx} != ${maxHarqMsg3Tx_except}
    ...    run keywords
    ...    set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELLGRP-0    key=maxHarqMsg3Tx    value=${maxHarqMsg3Tx_except}    AND
    ...    set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELLGRP-1    key=maxHarqMsg3Tx    value=${maxHarqMsg3Tx_except}    AND
    ...    set parameter    dict_name=MRBTS-10048/NRBTS-10048/NRCELLGRP-2    key=maxHarqMsg3Tx    value=${maxHarqMsg3Tx_except}

    ${maxUlHarqTx}    Get NIDD parameter value    class_name=NRCELLGRP_A    pattern=maxUlHarqTx    connection=COAM
    run keyword if    ${maxUlHarqTx} != ${maxUlHarqTx_except}
    ...    run keywords
    ...    Set parameter    dict_name=MRBTS-923/NRBTS-923/NRCELLGRP-0    key=maxUlHarqTx    value=${maxUlHarqTx_except}    AND
    ...    Set parameter    dict_name=MRBTS-923/NRBTS-923/NRCELLGRP-1    key=maxUlHarqTx    value=${maxUlHarqTx_except}    AND
    ...    Set parameter    dict_name=MRBTS-923/NRBTS-923/NRCELLGRP-2    key=maxUlHarqTx    value=${maxUlHarqTx_except}

    run keyword if    ${dict_pattern_0['actPrachMultiplexing']} != ${actPrachMultiplexing_except}
    ...    run keywords
    ...    Set parameter    key=actPrachMultiplexing    value=${actPrachMultiplexing_except}   AND
    ...    Set parameter    key=actPrachMultiplexing    value=${actPrachMultiplexing_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-2    AND
    ...    Set parameter    key=actPrachMultiplexing    value=${actPrachMultiplexing_except}
    ...    dict_name=MRBTS-10048/NRBTS-10048/NRCELL-3


    ${ChBwdl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwDl    connection=COAM
    run keyword if    '${ChBwdl}' != '${ChBwdl_except}' and '${type}'=='NSA'
    ...    set NSA bandwidth    value=${ChBwdl_except}    gscn_n66=${gscn_n66_except}
    run keyword if    '${ChBwdl}' != '${ChBwdl_except}' and '${type}'=='SA'
    ...    set bandwidth    value=${ChBwdl_except}    gscn_n66=${gscn_n66_except}

    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser    version=5G21A

    run keyword if    ${dict_pattern_0['msg1FrequencyStart']} != ${msg1FrequencyStart_except}
    ...    run keywords
    ...    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-1
    ...    filter_param=PRACH Frequency start    new_value=${msg1FrequencyStart_except}    AND
    ...    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-2
    ...    filter_param=PRACH Frequency start    new_value=${msg1FrequencyStart_except}    AND
    ...    selenium_coam.set_parameter_value   dist_name=MRBTS-10048/NRBTS-10048/NRCELL-3
    ...    filter_param=PRACH Frequency start    new_value=${msg1FrequencyStart_except}    AND
    ...    selenium_coam.validate_plan    AND
    ...    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

    Set PA



teardown
    [Arguments]    ${UE_TYPE}=samsung
    log to console    \n in teardown stage
    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/CB007488-NSA-20M.xml    connection=COAM
    admin_cli.teardown    connection=COAM
    #power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}



teardown for SA
    [Arguments]    ${UE_TYPE}=samsung
    log to console    \n in teardown stage
    admin_cli.perform_commissioning    scf_file=/home/ute/casetest/ABIL-922-FDD-4cell-both-5M-longpucch.xml    connection=COAM
    admin_cli.teardown    connection=COAM
    #power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
