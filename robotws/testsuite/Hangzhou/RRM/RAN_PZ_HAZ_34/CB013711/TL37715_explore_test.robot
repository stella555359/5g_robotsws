*** Settings ***
Documentation     TL37715_explore_test.robot
Test Timeout      180 minutes
Suite Setup       Sg13 Common Suite Setup
#Suite Teardown    Sg13 Common Suite Teardown
#Test Setup        SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_SPARK_ASILR_ABIOB4_ABIPB5_AVHA    for_gNB37715


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Library           taf.selenium.sbts    WITH NAME    seleLib
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013711/Resources/nr_rim.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013711/Resources/CB013711_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot


*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}           gnb_snapshot
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${UE_INDEX}                   0
${PORT}                    5002
${UE_NUM_SA}               2
${NRCELL1_CELLID}          617922561
${NRCELL2_CELLID}          617922562
${NRCELL3_CELLID}          617922563
${scfc_configuration}      ${CURDIR}/config/SCFC_TL37715_explore_test.xml
${swconfig_file}           ${CURDIR}/config/swconfig.txt
${NSA_SA}      SA
${dist_name_NRF}    MRBTS-37715/NRBTS-37715/NRCELL
${download_dir}    ${CURDIR}
${driver_alias}    myDriver
${driver_scope}    suite

*** Test Cases ***
TL37715_explore_test
    step1:Commission the above configuration on WebUI
    #step2:reset site
    #step3:block unblock RRUs
    step4:block unblock cells
    step5:attach UEs in cell1 and check logs

*** Keywords ***
step1:Commission the above configuration on WebUI
    Log To Console   \n----------step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'step1_bts_onair' File
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Add RD
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '300s' for stabible
    #check alarm
    #[Teardown]    COAM Teardown gnb connections
    [Teardown]    Stop Collecting GNB Syslog in 'step1_bts_onair' File

step2:reset site
    Log To Console   \n----------step2:reset site-------
    Start Collecting GNB Syslog in 'step2_reset_site' File
    FOR	   ${i}	   IN RANGE    1    2
        Perform BTS Site Reset
        Wait '300s' for stabible
        Wait until keyword succeeds    1500s    10s    Verify BTS Is Onair
    END
    check alarm
    [Teardown]    Stop Collecting GNB Syslog in 'step2_reset_site' file

step3:block unblock RRUs
    Log To Console   \n----------step3:block unblock RRUs-------
    Start capture only gnb syslog in 'step3_block_cells' file
    Connect to gnb coam via ssl
    ${ru_index_list}    get all ru index
    #[Teardown]    COAM Teardown gnb connections
    FOR	${i}    IN RANGE    1    2
	    Perform all RRU block unblock    ${ru_index_list}
        Wait '30s' for stabible
	END
    Wait '300s' for stabible
    check alarm
    [Teardown]    Stop capture only gnb syslog in 'step3_block_cells' file

step4:block unblock cells
    Log To Console   \n----------step4:block unblock cells-------
    Start Collecting GNB Syslog in 'step4_block_cells' file
    FOR    ${i}    IN RANGE    1    5
        block all cells
        Wait '60s' for stabible
        ublock all cells
        Wait '60s' for stabible
    END
    Wait '120s' for stabible
    check alarm
    [Teardown]    Stop Collecting GNB Syslog in 'step4_block_cells' file

step5:attach UEs in cell1 and check logs
    Log To Console   \n-------------step5:attach UEs--------------
    Start Collecting GNB Syslog in 'step5_attach_ues_cell1' file
    Attach UEs and send full buffer and check tput
    #Start collect ttitrace
    #Wait for '1s' to stop ttitrace with name'tti_cell1'
    Wait '600s' for stable running2
    ${DL_throughput}    ${UL_throughput}    get tput from PM counter
    run keyword and continue on failure    should be true    2000>${DL_throughput}>1800
    run keyword and continue on failure    should be true    100>${UL_throughput}>85
    ${DFT_UE}    ${SUBBAND_UE}    get DFT SUBBAND UE number
    run keyword and continue on failure    should be true    ${DFT_UE}==2
    run keyword and continue on failure    should be true    ${SUBBAND_UE}==0
    Stop all UEs data and detach all UEs
    [Teardown]    Stop Collecting GNB Syslog in 'step5_attach_ues_cell1' file


Attach UEs and send full buffer and check tput
    #[Arguments]    ${cell_id}=1
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true
	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1326MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=205MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	END
#	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
#	#${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.9
#	#${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.9
#	#run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    expect_traffic=${expect_dl_tput}
#	#...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8
#	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    direction=ul    expect_traffic=${expect_ul_tput}
#	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8

Stop all UEs data and detach all UEs
    Log To Console   \n-------------Stop all UEs data and detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Spark UE Stop traffic    dl    ue_index=${num}    apn_address=wustatic    ue_mode=None
       Spark UE Stop traffic    ul    ue_index=${num}    apn_address=wustatic    ue_mode=None
       Spark UE Detach    ue_index=${num}
    END

block all cells
    Log To Console   \n-------------block all cells--------------
    cell block    101
    cell block    102
    cell block    103
    cell block    104
    cell block    91
    cell block    92
    cell block    93
    cell block    94

cell block
    [Arguments]    ${physCellId}=51
    Block cell    ${physCellId}    gnb37715

cell unblock
    [Arguments]    ${physCellId}=51
    Log To Console   \n-------------block cell and unblock--------------
    Unblock cell    ${physCellId}    gnb37715

ublock all cells
    Log To Console   \n-------------ublock all cells--------------
    Unblock cell    101    gnb37715
    Unblock cell    102    gnb37715
    Unblock cell    103    gnb37715
    Unblock cell    104    gnb37715
    Unblock cell    91    gnb37715
    Unblock cell    92    gnb37715
    Unblock cell    93    gnb37715
    Unblock cell    94    gnb37715

check alarm
    ####add allow alarm list
    ${alarm_dict1}    Create Dictionary   faultId=${{int(61652)}}
    ${alarm_dict2}    Create Dictionary   faultId=${{int(4654)}}
    ${alarm_dict3}    Create Dictionary   faultId=${{int(61524)}}
    ${alarm_dict4}    Create Dictionary   faultId=${{int(4655)}}
    ${alarm_dict5}    Create Dictionary   faultId=${{int(61649)}}
    ${alarm_dict6}    Create Dictionary   faultId=${{int(4592)}}
    ${allow_alarms}    Create List    ${alarm_dict1}    ${alarm_dict2}    ${alarm_dict3}    ${alarm_dict4}    ${alarm_dict5}    ${alarm_dict6}
    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${allow_alarms}    file_path=${TEST_LOG_DIRECTORY()}/All/    connection=GNB_OAM    timeout=60


Detach all UEs
    Log To Console   \n-------------Detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Spark UE Detach    ue_index=${num}
    END

Perform all RRU block unblock
    [Arguments]    ${ru_index_list}
    #Selenium Login And Disable Screen Lock
    FOR  ${lock_id}  IN  @{ru_index_list}
        Sleep    3s
        ${operate_list}    create list    ${lock_id}
        Lock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
        Unlock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
    END

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell1_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

    ${cell2_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2

    ${cell3_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=3
    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Set Test Variable   ${cell3_expect_tput}

Add RD
    Add GNB swconfig   0x9D0000:15

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt


Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${CURDIR}/config/${ATT_FILE_PATH}    ${CURDIR}/config/${PHASE_FILE_PATH}
    ...    frequency=3500_1_ALL


Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    add_txt_node    0x580539:10   #Num UE threshold,to collect trace
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

Get Current Parameter Value from selenium
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get parameter value
    Log to console      \nChecking gnb parameter ${param_name} value
    seleLib.Enable Virtual Display    width=2220    height=1580
    seleLib.login    url=https://192.168.255.129    username=Nemuadmin    password=nemuuser    alias=connection
    ${view}     seleLib.start_up_view_window_exists         sbts=connection
    Run Keyword If       '${view}'== 'True'     seleLib.close_start_up_view_window      sbts=connection
    ${curr_value}    seleLib.get_parameter_value    dist_name=${dist_name}    filter_param=${param_name}    sbts=connection
    seleLib.close_browser       sbts=connection
    [Return]    ${curr_value}

others step
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    Start capture only gnb syslog in 'step2_attach_ues_cell1' file
    Attach UEs and send full buffer and check tput
    #${state}		Get Current Parameter Value from selenium       ${dist_name_NRF}-1 	Energy saving state
    #Should Be Equal As Strings    ${state}    notEnergySaving
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_cell1'
    step6:stop all UEs data and detach all UEs
    #Wait '300s' for stabible
    #${state}		Get Current Parameter Value from selenium       ${dist_name_NRF}-1 	Energy saving state
    #Should Be Equal As Strings    ${state}    reducedEnergySaving
    #Attach UEs and send full buffer and check tput
    #Wait '30s' for stabible
    #${state}		Get Current Parameter Value from selenium       ${dist_name_NRF}-1 	Energy saving state
	#Should Be Equal As Strings    ${state}    notEnergySaving

online change cells qRxLevMin
    [Arguments]    ${cel11_value}    ${cell2_value}    ${cell3_value}
    #change cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-37715/NRBTS-37715/NRCELL-51    parameter=qRxLevMin
    ...    operation=update    value=${cel11_value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
    #change cell2
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-37715/NRBTS-37715/NRCELL-52    parameter=qRxLevMin
    ...    operation=update    value=${cell2_value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
    #change cell3
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-37715/NRBTS-37715/NRCELL-53    parameter=qRxLevMin
    ...    operation=update    value=${cell3_value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

get tput from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${dl_tput_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=91
    ${dl_tput_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=92
    ${dl_tput_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=93
    ${ul_tput_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=91
    ${ul_tput_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=92
    ${ul_tput_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=93
    ${dl_tput_bts}    evaluate    (${dl_tput_cell1} + ${dl_tput_cell2} + ${dl_tput_cell3})*8/1024/1024
    ${ul_tput_bts}    evaluate    (${ul_tput_cell1} + ${ul_tput_cell2} + ${ul_tput_cell3})*8/1024/1024
    [Return]    ${dl_tput_bts}    ${ul_tput_bts}

get DFT SUBBAND UE number
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DFT_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00003    cell_id=91
    ${DFT_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00003    cell_id=92
    ${DFT_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00003    cell_id=93
    ${SUBBAND_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=91
    ${SUBBAND_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=92
    ${SUBBAND_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=93
    ${DFT_UE_bts}    evaluate    ${DFT_UE_cell1} + ${DFT_UE_cell2} + ${DFT_UE_cell3}
    ${SUBBAND_UE_bts}    evaluate    ${SUBBAND_UE_cell1} + ${SUBBAND_UE_cell2} + ${SUBBAND_UE_cell3}
    [Return]    ${DFT_UE_bts}    ${SUBBAND_UE_bts}

Wait '${time}' for stable running2
    sleep    ${time}