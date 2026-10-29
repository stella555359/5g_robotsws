*** Settings ***
Documentation    This is for feature CB009008/9487 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    ../../5GC000702/Resources/5GC000702_common_ute.robot
Resource
...    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RU_lock_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Manual_SiSo_SM_BTS_Block_Site.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009363/Resources/CB009363_case_steps.robot


*** Keywords ***
CB009008-SR-B_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink
    ${cell_id}    Set Variable If    '${stream}'=='master' or '${stream}'=='24R2' or '${stream}'=='24R3'    1    3
    ${ul_layer}    Set Variable If    '${stream}'=='master' or '${stream}'=='24R2' or '${stream}'=='24R3'    ${2}    ${1}
    Run Keyword If    '${stream}'=='master'
    ...    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${scf_path_nrdim}    Run Keyword If    '${stream}'=='master'
    ...    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    Run Keyword If    '${stream}'=='master'    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${peak_dl}    ${peak_ul}    Run Keyword If    '${stream}'=='master'    get_theoretical_throughput    scf_path=${scf_path_nrdim}
    ...                                                                                                  cell_id=${cell_id}
    ...                                                                                                  pucchprb=${10}
    ...                                                                                                  ue_ul_layer=${ul_layer}
    Run Keyword If    '${stream}'=='master'    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                                                dl_data_transfer=1500M
    ...                                                                                expect_ul_tput=${peak_ul}
    ...                                                                                expect_dl_tput=${peak_dl}
    ...                                                                                target_avg_percent=0.98
    ...                                                                                min_percent=0.85
    ...                                                                                duration=300
    ...    ELSE IF    '${stream}'=='24R2' or '${stream}'=='24R3'     Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                                              dl_data_transfer=1500M
    ...                                                                              expect_ul_tput=190
    ...                                                                              expect_dl_tput=1480
    ...    ELSE    MTK L3 Call And Verify Throughput     ul_data_transfer=100M
    ...                                                  dl_data_transfer=1500M
    ...                                                  expect_ul_tput=90
    ...                                                  expect_dl_tput=1380
#    ...    ELSE    L3 Call And Verify Throughput For MTK UE     ul_data_transfer=100
#    ...                                                         dl_data_transfer=1480
#    ...                                                         duration=300
#    ...                                                         expect_ul_tput=${peak_ul}
#    ...                                                         expect_dl_tput=${peak_dl}
#    ...                                                         target_avg_percent=0.98
#    ...                                                         min_percent=0.85

CB009008-SR-A_04_General_SiSo_Cell_block_and_unblock
    Sleep    180s
    Run Keyword If    '${stream}'=='master'    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                                                dl_data_transfer=1500M
    ...                                                                                expect_ul_tput=190
    ...                                                                                expect_dl_tput=1480
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    General_SiSo_Cell_block_and_unblock.General_SiSo_Cell_block_and_unblock    with_call=${False}
    Sleep    120s
    Run Keyword If    '${stream}'=='master' or '${stream}'=='24R2'
    ...                    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                            dl_data_transfer=1500M
    ...                                                            expect_ul_tput=190
    ...                                                            expect_dl_tput=1480
    ...    ELSE    MTK L3 Call And Verify Throughput     ul_data_transfer=100M
    ...                                                  dl_data_transfer=1500M
    ...                                                  expect_ul_tput=90
    ...                                                  expect_dl_tput=1380

CB009008-SR-C_03_Manual_SiSo_SM_BTS_Block_Site
    FOR    ${i}    IN RANGE    ${2}
        Log To Console    Info: Ready to do BTS Block Site
        Selenium Login And Disable Screen Lock
        Manual_SiSo_SM_BTS_Block_Site.Manual_SiSo_SM_BTS_Block_Site
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
    END
    Sleep    120s
    Run Keyword If    '${stream}'=='master' or '${stream}'=='24R2'
    ...                    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                            dl_data_transfer=1500M
    ...                                                            expect_ul_tput=190
    ...                                                            expect_dl_tput=1480
    ...    ELSE    MTK L3 Call And Verify Throughput     ul_data_transfer=100M
    ...                                                  dl_data_transfer=1500M
    ...                                                  expect_ul_tput=90
    ...                                                  expect_dl_tput=1380

CB009487_B_07_General_SiSo_SM_BTS_Site_Reset_Configuration_#5
    Selenium Logout And Close Browser
    Perform BTS Site Reset
    Sleep    60s
    Wait Until Keyword Succeeds    30 min    20 sec   verify all cells should be onair
    csn.reset_cache
    Sleep    120s
    Run Keyword If    '${stream}'=='master' or '${stream}'=='24R2'
    ...                   Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                           dl_data_transfer=1500M
    ...                                                           expect_ul_tput=190
    ...                                                           expect_dl_tput=1480
    ...    ELSE    MTK L3 Call And Verify Throughput     ul_data_transfer=100M
    ...                                                  dl_data_transfer=1500M
    ...                                                  expect_ul_tput=90
    ...                                                  expect_dl_tput=1380
    [Teardown]    Selenium Logout And Close Browser

CB009487_A_04_General_SiSo_Cell_block_and_unblock_Configuration_#2
    Run Keyword If    '${stream}'=='24R2'    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}
    Sleep    180s
    Run Keyword If    '${stream}'=='master'    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                                                dl_data_transfer=1500M
    ...                                                                                expect_ul_tput=190
    ...                                                                                expect_dl_tput=1400
    ...                                                                                cellid=1
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    General_SiSo_Cell_block_and_unblock.General_SiSo_Cell_block_and_unblock    with_call=${False}
    Sleep    120s
    Run Keyword If    '${stream}'=='master'    Dingli L3 Call And Verify Throughput    ul_data_transfer=1950000
    ...                                                                                dl_data_transfer=1500M
    ...                                                                                expect_ul_tput=190
    ...                                                                                expect_dl_tput=1400
    ...                                                                                cellid=1
    ...    ELSE IF    '${stream}'=='24R2'    Dingli L3 Call And Verify Throughput    ul_data_transfer=800000
    ...                                                                              dl_data_transfer=600M
    ...                                                                              expect_ul_tput=65
    ...                                                                              expect_dl_tput=550
    ...    ELSE    MTK L3 Call And Verify Throughput     ul_data_transfer=80M
    ...                                                  dl_data_transfer=600M
    ...                                                  expect_ul_tput=30
    ...                                                  expect_dl_tput=550
    ...                                                  cellid=5
    ...                                                  min_percent=0
    Run Keyword If    '${stream}'=='24R1'    MTK L3 Call And Verify Throughput     ul_data_transfer=80M
    ...                                                                            dl_data_transfer=600M
    ...                                                                            expect_ul_tput=30
    ...                                                                            expect_dl_tput=550
    ...                                                                            cellid=6
    ...                                                                            min_percent=0
    ...                                                                            is_do_require_ue=${False}

CB009487_A_08_General_SiSo_SM_RF_Module_lock_unlock_Configuration_#2
#    Run Keyword If    '${stream}'=='24R2' or '${stream}'=='24R3'    SiSo RU Lock Unlock
#    ...    ELSE    General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=${False}
#    Run Keyword If   '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'   Mcs.Set Phases According To Angles For Two Output Groups
#    ...    mcs_type=${mcs_type}    mcs_index=${1}
#    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
#    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
#    ...    vertical_distance=${2}
#     Run Keyword If   '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'
#     ...               Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
#    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
#    Run Keyword If    '${stream}'=='master'    Update Paramter For CA
    Run Keyword If    '${stream}'=='master'    Wait Until Keyword Succeeds    2 min    5 sec
    ...    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${scf_path_nrdim}    Run Keyword If    '${stream}'=='master'
    ...    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    Run Keyword If    '${stream}'=='master'    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${peak_dl_pcell}    ${peak_ul_pcell}    Run Keyword If    '${stream}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=1
    ${peak_dl_scell}    ${peak_ul_scell}    Run Keyword If    '${stream}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=2
    sleep    10min
    Run Keyword If    '${stream}'=='master'    Dingli L3 Call And Verify Throughput For CA    ul_data_transfer=120M
    ...                                                                                       dl_data_transfer=2000M
    ...                                                                                       expect_ul_tput=${peak_ul_pcell}
    ...                                                                                       expect_dl_tput_pcell=${peak_dl_pcell}
    ...                                                                                       expect_dl_tput_scell=${peak_dl_scell}
    ...                                                                                       pcell_id=1
    ...                                                                                       scell_id=2
    ...                                                                                       target_avg_percent=0.98
    ...                                                                                       min_percent=0.85
    ...                                                                                       duration=300
    ...    ELSE IF    '${stream}'=='25R2' or '${stream}'=='25R1'
    ...                                      Dingli L3 Call And Verify Throughput    ul_data_transfer=800000
    ...                                                                              dl_data_transfer=600M
    ...                                                                              expect_ul_tput=65
    ...                                                                              expect_dl_tput=550
    ...                                                                              cellid=3
    ...    ELSE IF    '${stream}'=='24R3'    Dingli L3 Call And Verify Throughput    ul_data_transfer=800000
    ...                                                                              dl_data_transfer=600M
    ...                                                                              expect_ul_tput=65
    ...                                                                              expect_dl_tput=550
    ...                                                                              cellid=1
    ...    ELSE    Run Keywords    MTK L3 Call And Verify Throughput    ul_data_transfer=80M
    ...                                                                 dl_data_transfer=600M
    ...                                                                 expect_ul_tput=30
    ...                                                                 expect_dl_tput=550
    ...                                                                 cellid=5
    ...                     AND    MTK L3 Call And Verify Throughput    ul_data_transfer=80M
    ...                                                                 dl_data_transfer=600M
    ...                                                                 expect_ul_tput=30
    ...                                                                 expect_dl_tput=550
    ...                                                                 cellid=6
    ...                                                                 is_do_require_ue=${False}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic In Teardown

Upload Swconfig File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_path}=${CURDIR}/swconfig.txt    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=swconfig
    Log    ${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    Log To Console    Start update Swconfig file.
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${alias}

MTK L3 Call And Verify Throughput
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}    ${dl_data_transfer}    ${expect_ul_tput}    ${expect_dl_tput}
    ...            ${cellid}=3    ${is_do_require_ue}=${True}    ${target_avg_percent}=0.8    ${min_percent}=0.3    ${duration}=180
    Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
    Start L3 Call And Verify Throughput     ul_data_transfer=${ul_data_transfer}
    ...                                     dl_data_transfer=${dl_data_transfer}
    ...                                     expect_ul_tput=${expect_ul_tput}
    ...                                     expect_dl_tput=${expect_dl_tput}
    ...                                     4G_check=${False}
    ...                                     cellid=${cellid}
    ...                                     duration=${duration}
    ...                                     target_avg_percent=${target_avg_percent}
    ...                                     min_percent=${min_percent}
    ...                                     is_do_require_ue=${is_do_require_ue}

#L3 Call And Verify Throughput For MTK UE
#    [Documentation]    Author: jun.8.chen@nokia-sbell.com
#    [Arguments]    ${ul_data_transfer}=100    ${dl_data_transfer}=1400
#    ...            ${expect_ul_tput}=90    ${expect_dl_tput}=1300    ${transfer_duration}=900
#    ...            ${cellid}=3    ${is_do_require_ue}=${True}
#    ...            ${target_avg_percent}=0.9    ${min_percent}=0.3    ${duration}=180
#    Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
#    New_MTK_keywords.Start L3 Call And ChecK Throughput    cells=${cellid}
#    ...                                                    is_do_require_ue=${is_do_require_ue}
#    ...                                                    transfer_duration=${transfer_duration}
#    ...                                                    ul_throughput=${ul_data_transfer}
#    ...                                                    dl_throughput=${dl_data_transfer}
#    ...                                                    duration=${duration}
#    ...                                                    ultarget_throughput=${expect_ul_tput}
#    ...                                                    dltarget_throughput=${expect_dl_tput}
#    ...                                                    target_avg_percent=${target_avg_percent}
#    ...                                                    min_percent=${min_percent}

Dingli L3 Call And Verify Throughput
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}    ${dl_data_transfer}    ${expect_ul_tput}    ${expect_dl_tput}
    ...            ${cellid}=1    ${target_avg_percent}=0.8    ${min_percent}=0.3    ${duration}=180
    Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
    ${5G_band}    Set Variable    78
    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
    Start To Capture Mix Logs With gNB_logs
    Sleep    120s
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${${0}}    5G_band=${5G_band}
    Stop Capture Mix Logs With gNB_logs
    Run Keyword And Ignore Error    Get Captured Mixed File
    ${expect_pci}    Set Variable IF    '${stream}'=='master'    721    733
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=${expect_pci}
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=${ul_data_transfer}    dl_throughput=${dl_data_transfer}
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                         duration=${duration}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         cellid=${cellid}
    ...                         ue_type=huawei_sigspark
    ...                         check_source=aasyslog
    ...                         target_avg_percent=${target_avg_percent}
    ...                         min_percent=${min_percent}
    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
    Run Keyword And Ignore Error    Get Captured Mixed File
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    AND
    ...                           Run Keyword And Ignore Error    DingLi_Client.Detach

Dingli L3 Call And Verify Throughput For CA
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}    ${dl_data_transfer}
    ...            ${expect_ul_tput}    ${expect_dl_tput_pcell}    ${expect_dl_tput_scell}
    ...            ${pcell_id}=1    ${scell_id}=2
    ...            ${target_avg_percent}=0.9    ${min_percent}=0.3    ${duration}=180
    Change cellBarred Parameter Value On Gnb    pcell_index=${pcell_id}    exp_status=notBarred
#    ${5G_band}    Set Variable    78
#    DingLi_Client.UE Attach With Retry    ues_index=${${1}}    5G_band=${5G_band}
#    DingLi_Client.Start Data Transfer    ues_index=${${1}}    ul_throughput=${ul_data_transfer}    dl_throughput=${dl_data_transfer}
    Make_L3_Call_With_Power_UE    ul_data_transfer=${ul_data_transfer}
    ...                           dl_data_transfer=${dl_data_transfer}
    ...                           reset_sol=none
    ...                           ue_index=${0}
    ...                           4G_check=False
    ...                           is_do_require_ue=${True}
    ...                           throuput_duration=900
    Run Keyword And Continue On Failure    Check Tput With Power UE For CA    expect_ul_tput=${expect_ul_tput}
    ...                                duration=${duration}
    ...                                expect_dl_tput_pcell=${expect_dl_tput_pcell}
    ...                                expect_dl_tput_scell=${expect_dl_tput_scell}
    ...                                pcell_id=${pcell_id}
    ...                                scell_id=${scell_id}
    ...                                ue_type=huawei_sigspark
    ...                                check_source=aasyslog
    ...                                target_avg_percent=${target_avg_percent}
    ...                                min_percent=${min_percent}
#    Run Keyword And Ignore Error    Recover Collect Syslog For Gnb
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    AND
    ...                           Run Keyword And Ignore Error    DingLi_Client.Detach

Check Tput With Power UE For CA
    [Arguments]    ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput_pcell}=${None}
    ...            ${expect_dl_tput_scell}=${None}
    ...            ${duration}=300
    ...            ${pcell_id}=1
    ...            ${scell_id}=2
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${ignore_time}=1min
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.85
    ...            ${actCarrierAggregation}=${False}
    ...            ${all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${ue_type}=${ue_type}
    ${pcell_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${pcell_id}    connection=${connection}    list_all_cell_ids=${all_cell_ids}
    ${scell_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${scell_id}    connection=${connection}    list_all_cell_ids=${all_cell_ids}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}
    ...    du_index=${du_index}    duration=${duration}    ignore_time=${ignore_time}
    ...    check_source=${check_source}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${tput_log}    cells=${pcell_nrcell_ids}
    ...                                                           target_throughput=${expect_ul_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...                                                           log=${tput_log}    cells=${pcell_nrcell_ids}
    ...                                                           target_throughput=${expect_dl_tput_pcell}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${tput_log}    cells=${scell_nrcell_ids}    target_throughput=${expect_dl_tput_scell}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    check_source=${check_source}    min_percent=${min_percent}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Update Paramter For CA
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300    ${should_activate}=${True}
    Log To Console    \n***start to update paramters for ca case ***
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_bwpDN1}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-73','cellBwpId':'1'}]}
    ${update_bwpDN2}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'cellBwpList',
    ...    'value':[{'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7','cellBwpId':'0'},
    ...    {'bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-73','cellBwpId':'1'}]}
    ${update_chbw1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'chBw','value':'60MHz'}
    ${update_nrarfcn1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'nrarfcn','value':'634000'}
    ${update_chbw2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'chBw','value':'60MHz'}
    ${update_nrarfcn2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'nrarfcn','value':'638000'}
    ${update_cSRS}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'srsForBeamMgmt','value':[{'cSRS':'42'}]}
    ${all_update_params}    catenate    ${update_bwpDN1},${update_bwpDN2},${update_chbw1},${update_nrarfcn1},
    ...    ${update_chbw2},${update_nrarfcn2},${update_cSRS}
    ${update_param}     evaluate    [${all_update_params}]
    ${add_ca1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-11',
    ...    'parameter':'sCellAdditionMethod','value':'covBasedA1'}
    ${add_ca2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-11',
    ...    'parameter':'sCellOperationalMode','value':'dlOnly'}
    ${add_param}     evaluate    [${add_ca1},${add_ca2}]
    ${para_file_update}    coam_parameter.create_update_parameters_delta
    ...    parameters=${update_param}
    ...    connection=${connection}
    ${para_file_add}    coam_parameter.create_add_parameters_delta
    ...    parameters=${add_param}
    ...    connection=${connection}
    ${add_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file_add['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file_update['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ${msg_for_parameter_activation_not_executed}    Catenate    Parameter update activation is not executed,
    ...    due to flag should_activate is set to ${should_activate}
    Run keyword if    '${should_activate}'=='${True}'
    ...    Should contain    ${update_via_api_status}    PASS
    ...               msg=parameters do not update successfully.    ignore_case=${True}
    ...    ELSE    Log to console     ${msg_for_parameter_activation_not_executed}
    Should contain    ${add_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

SiSo RU Lock Unlock
    ${start_time}    robot.libraries.DateTime.get current date
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_list}
    sort list    ${cell_list}
    Lock RUs And Check Status   ru_index_list=${ru_index_list}   cell_list=${cell_list}   gnb_type='${gNb_CuType}'
    Close Start Up View    timeout=60
    Unlock RUs And Check Status   ru_index_list=${ru_index_list}   cell_list=${cell_list}   gnb_type='${gNb_CuType}'
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

Lock RUs And Check Status
    [Arguments]    ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'    ${check_alarm}=${True}
    log to console  \n**Lock all RUs and check all status***
    ${cell_list_new}    samelist    ${cell_list}
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        ${flag}    ${cell_list_new}    getusefulid    ${cell_id_ru}    ${cell_list_new}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'    sleep    ${X2_link_shutdown_time}min
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300

Unlock RUs And Check Status
    [Arguments]    ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'    ${check_alarm}=${True}
    log to console  \n**UnLock all RUs and check all status***
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

9008 Coam Test Setup
    [Arguments]    ${gnb_index}=0    ${update_params}=${None}
    robot_common_operations.Common Case Setup
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    log to console    Active_SW_version(gNB):${Active_SW_version}
    run keyword if    '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
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
#    ${SCF_Status}    set variable if      '${Status}'=='PASS'    @{key}[1]    ${False}
    perform_update_scf_params    update_params=${update_params}
    ...                          basic_scf_path=${SCF_Path}
    ...                          update_scf_path=${TS_CASE_LOG_PATH}/basic_update.xml
    Set Test Variable    ${Case_SCF_Path}    ${TS_CASE_LOG_PATH}/basic_update.xml
    Commissioning SCF And Check On Air    scf_path=${TS_CASE_LOG_PATH}/basic_update.xml    timeout=30
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${stream}    Get Active SW Version Based On Stream Version
    Set Test Variable    ${stream}
#    ${pa_vlaue}    Set Variable If    '${stream}'=='master'    127
#    ...                               '${stream}'=='24R1'    13
#    Run Keyword If    '${stream}'=='master' or '${stream}'=='24R1'
#    ...    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_vlaue}    RU_id=2
    Run Keyword If    '${stream}'=='master'    Set MCS Phase And ATT For 9363_E
    Run Keyword If    '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'    Set MCS Phase And ATT For 9363_E_24R2
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}

9008 Coam Test Teardown
    [Arguments]    ${gnb_index}=0    ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False}
#    Run Keyword And Ignore Error    Stop Traffic With Power UE
#    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
#    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    log to console    \n***SISO Coam Test Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status    connection=${connection}
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    ${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
    ${test_fail_flag}    set variable if    ${test_fail_flag}    ${True}    ${False}
    run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
#    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}     gnb_index=${gnb_index}
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
#    Run Keyword If    '${stream}'=='master' or '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'    Run Keywords
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_index=${1}     mcs_type=${mcs_type}
#    AND
#    ...    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    AND
#    ...    Run Keyword And Ignore Error    DingLi_Client.Detach
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASIK Master

9008 Suite Test Setup
    SISO Coam Suite Setup
    ${stream}    Get Active SW Version Based On Stream Version
#    Run Keyword If    '${stream}'=='master' or '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'    9008 Suite Setup For Master
    Upload Swconfig File

9008 Suite Teardown
    ${stream}    Get Active SW Version Based On Stream Version
#    Run Keyword If    '${stream}'=='master' or '${stream}'=='25R2' or '${stream}'=='24R3' or '${stream}'=='25R1'    Run Keyword And Ignore Error
#    ...    DingLi_Client.Teardown
    SISO Coam Suite Teardown

9008 Suite Setup For Master
    DingLi_Client.UE Prepare
    DingLi_Client.SA And NSA Mode Change
    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
    sleep    5sec
