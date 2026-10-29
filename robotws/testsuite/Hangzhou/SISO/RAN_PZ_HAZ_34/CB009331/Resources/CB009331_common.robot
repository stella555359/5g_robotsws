*** Settings ***
Documentation    This is for feature CB009331 related common keywords.
...              Please do not modify the file without notification to author
...              Author:stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RU_lock_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    ../../5GC000702/Resources/5GC000702_common_ute.robot

*** Variables ***
@{SWCONFIG_8941}    0x600012=1    0x190297=1    0x190305=1    0x600017=1    0x190306=1    0x600018=1

*** Keywords ***
CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    100    60
    ${expect_dl_tput}    set variable if  'SBTS00' in '${stream}'    770    680
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput    ul_data_transfer=120M
    ...                                                                           dl_data_transfer=1200M
    ...                                                                           expect_ul_tput=${expect_ul_tput}
    ...                                                                           expect_dl_tput=${expect_dl_tput}
    ...                                                                           4G_check=${False}
    ...                                                                           cellid=${1}
    ...                                                                           target_avg_percent=0.90
    ...                                                                           reset_sol=${none}
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}    set variable if  'SBTS25R3' in '${stream}'    2    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput     ul_data_transfer=120M
    ...                                     dl_data_transfer=1200M
    ...                                     expect_ul_tput=${expect_ul_tput}
    ...                                     expect_dl_tput=${expect_dl_tput}
    ...                                     4G_check=${False}
    ...                                     cellid=${second_cell_index}
    ...                                     target_avg_percent=0.90
    ...                                     is_do_require_ue=${False}
    ...                                     reset_sol=${none}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                 scf_file_name=SCF_${stream}
    ...                                                                 is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                is_x2_check_from_gnb_needed=${False}

CB009331-SR-A_05_NR_only_16DL_8UL_3Sector_2CC_NR100_NR50
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                                                            dl_data_transfer=1600M
    ...                                                                            expect_ul_tput=140
    ...                                                                            expect_dl_tput=1350
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}     Set Variable If    '${testline}'=='7_5_UTE5G402T271'    2
    ...                                         '${testline}'=='7_5_UTE5G402T281'    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput    ul_data_transfer=120M
    ...                                    dl_data_transfer=1200M
    ...                                    expect_ul_tput=60
    ...                                    expect_dl_tput=680
    ...                                    4G_check=${False}
    ...                                    cellid=${second_cell_index}
    ...                                    target_avg_percent=0.90
    ...                                    is_do_require_ue=${False}

CB009331-General_SiSo_RU_lock_unlock
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
#    Power Reset All RF    is_reset_all_RF=${True}
#    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=${False}
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                                                            dl_data_transfer=1600M
    ...                                                                            expect_ul_tput=140
    ...                                                                            expect_dl_tput=1350
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    ...                                                                            reset_sol=${none}
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}     Set Variable If    '${testline}'=='7_5_UTE5G402T271'    2
    ...                                         '${testline}'=='7_5_UTE5G402T281'    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                     dl_data_transfer=1600M
    ...                                     expect_ul_tput=120
    ...                                     expect_dl_tput=1270
    ...                                     4G_check=${False}
    ...                                     cellid=${second_cell_index}
    ...                                     target_avg_percent=0.90
    ...                                     is_do_require_ue=${False}
    ...                                     reset_sol=${none}

CB009331-General_SiSo_RU_module_reset_from_GUI
    #General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI
    Perform RF Module Reset from GUI    ru_index=1
    Run keyword if    'SBTS00' in '${stream}'    Power Off RF
    Sleep    60sec
    Run keyword if    'SBTS00' in '${stream}'    Wait until keyword succeeds    30 min    20 sec
    ...                                                     Expect Fault Should Present    faultId=10    supplementary=RU not detected after reset
    Run keyword if    'SBTS00' in '${stream}'    Power On RF
    COAM Wait For Gnb Ready And Cell Setup    timeout=20 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=120M
    ...                                                                            dl_data_transfer=1200M
    ...                                                                            expect_ul_tput=75
    ...                                                                            expect_dl_tput=850
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}     Set Variable If    '${testline}'=='7_5_UTE5G402T271'    2
    ...                                         '${testline}'=='7_5_UTE5G402T281'    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput    ul_data_transfer=120M
    ...                                    dl_data_transfer=1200M
    ...                                    expect_ul_tput=75
    ...                                    expect_dl_tput=850
    ...                                    4G_check=${False}
    ...                                    cellid=${second_cell_index}
    ...                                    target_avg_percent=0.90
    ...                                    is_do_require_ue=${False}
    [Teardown]    Run Keyword And Ignore Error    Run keyword if    'SBTS00' in '${stream}'    Power On RF

CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    Enable capture soap log
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=@{SWCONFIG_8941}
    Do gNB Reset site and Wait Onair
    Download SOAP log
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                                                            dl_data_transfer=1600M
    ...                                                                            expect_ul_tput=140
    ...                                                                            expect_dl_tput=1350
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    Run Keyword And Continue On Failure    Verify SOAP Parameter Change Ind
    ...    distName_value=endpointCapacitySharingGroup1    expected_value=26
    ...    log_path=${SOAP_LOG_PATH}    parameter_name=maxUplaneSectionHeadersPerSymbol
    Run Keyword And Continue On Failure    Verify SOAP Parameter Change Ind
    ...    distName_value=endpointCapacitySharingGroup1   expected_value=78
    ...    log_path=${SOAP_LOG_PATH}    parameter_name=maxUplaneSectionHeadersPerSlot
    Run Keyword And Continue On Failure    Verify SOAP Parameter Change Ind
    ...    distName_value=endpointCapacitySharingGroup0    expected_value=18
    ...    log_path=${SOAP_LOG_PATH}    parameter_name=maxUplaneSectionHeadersPerSymbol
    Run Keyword And Continue On Failure    Verify SOAP Parameter Change Ind
    ...    distName_value=endpointCapacitySharingGroup0   expected_value=252
    ...    log_path=${SOAP_LOG_PATH}    parameter_name=maxUplaneSectionHeadersPerSlot
    [Teardown]    run keywords
    ...    Connect to Common Unit Master    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...    Run Keyword And Ignore Error    Do gNB Reset site and Wait Onair    AND    Run Keyword And Ignore Error
    ...    COAM Teardown gnb connections    connection=GNB_OAM

CB009331-Manual_SiSo_SM_BTS_Site_Reset
    Run keyword if    'SBTS00' in '${stream}'    Power Off RF
    Selenium Logout And Close Browser
    Perform BTS Site Reset
    Run keyword if    'SBTS00' in '${stream}'    Wait until keyword succeeds    30 min    20 sec
    ...                                                 Expect Fault Should Present    faultId=10    supplementary=RU not detected after BTS startup
    Run keyword if    'SBTS00' in '${stream}'    Power On RF
    sleep    60s
    Wait until keyword succeeds    30 min    20 sec   verify all cells should be onair
    csn.reset_cache
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                                                            dl_data_transfer=1600M
    ...                                                                            expect_ul_tput=140
    ...                                                                            expect_dl_tput=1350
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}     Set Variable If    '${testline}'=='7_5_UTE5G402T271'    2
    ...                                         '${testline}'=='7_5_UTE5G402T281'    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput    ul_data_transfer=130M
    ...                                    dl_data_transfer=1500M
    ...                                    expect_ul_tput=100
    ...                                    expect_dl_tput=1100
    ...                                    4G_check=${False}
    ...                                    cellid=${second_cell_index}
    ...                                    target_avg_percent=0.90
    ...                                    is_do_require_ue=${False}
    [Teardown]    run keywords    Selenium Logout And Close Browser    AND
    ...                           Run Keyword And Ignore Error    Run keyword if    'SBTS00' in '${stream}'    Power On RF

CB009331-SR-A_06_NR_only_16DL_8UL_3Sector_2CC_NR80_NR80
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    Run Keyword And Continue On Failure    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                                                            dl_data_transfer=1600M
    ...                                                                            expect_ul_tput=100
    ...                                                                            expect_dl_tput=1100
    ...                                                                            4G_check=${False}
    ...                                                                            cellid=${1}
    ...                                                                            target_avg_percent=0.90
    ${stream_version}    Get Active SW Version Based On Stream Version
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${second_cell_index}     Set Variable If    '${testline}'=='7_5_UTE5G402T271'    2
    ...                                         '${testline}'=='7_5_UTE5G402T281'    4
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${second_cell_index}
    ...    connection=GNB_OAM    timeout=300
    Start L3 Call And Verify Throughput    ul_data_transfer=130M
    ...                                    dl_data_transfer=1500M
    ...                                    expect_ul_tput=100
    ...                                    expect_dl_tput=1100
    ...                                    4G_check=${False}
    ...                                    cellid=${second_cell_index}
    ...                                    target_avg_percent=0.90
    ...                                    is_do_require_ue=${False}

9331 Coam Suite Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    set suite variable    ${suite_setup_fail_flag}    ${False}

9331 Coam Test Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Case Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_info}    COAM get all ru detail info    connection=${connection}
    ${ru_value}    get dictionary values    ${ru_info}
    ${ru_info}    Set variable    ${ru_value}[0]
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} or ${SCF_Status}==${True} and ${gnb_index}==0
    ...    Commissioning SCF And Check On Air      scf_path=${SCF_Path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser
