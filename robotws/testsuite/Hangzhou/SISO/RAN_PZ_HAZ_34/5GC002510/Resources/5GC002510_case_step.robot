*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_variables.py
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002510/Resources/TestCaseVariables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot

*** Keywords ***
CB005739_5GC001301_05_C2_ForamtCell setup with PRACH format switchover bewteen B4 and C2
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...    This test case is used to test 5GC001301 case. Prach index changes from 206 to 158.
    ...    CHBW:80MHz, Feature_ID:5GC001301;CB005739-LA
    [Arguments]    ${cell_index_list}
    ${restore_prachConfigurationIndex}   coam_parameter.get_single_value_from_scf_file    parameter=prachConfigurationIndex
    ...                  dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ...                  connection=GNB_OAM
    &{para_restore}    Create Dictionary    abbr=prachConfigurationIndex    dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${para_modify}    Catenate    {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[0]',
    ...                             'parameter': 'prachConfigurationIndex',
    ...                             'value': '206'},
    ...                           {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[1]',
    ...                             'parameter': 'prachConfigurationIndex',
    ...                             'value': '206'}
    ${para_restore}    Catenate    {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[0]',
    ...                             'parameter': 'prachConfigurationIndex',
    ...                             'value': '${restore_prachConfigurationIndex}'},
    ...                           {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[1]',
    ...                             'parameter': 'prachConfigurationIndex',
    ...                             'value': '${restore_prachConfigurationIndex}'}
    ${update_tiltOffset_value}    Catenate    {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[0]',
    ...                             'parameter': 'beamSet',
    ...                             'value': [{'tiltOffset':'-2'}]},
    ...                           {'dist_name': '${dis_name_dir}/NRCELL-${cell_index_list}[1]',
    ...                             'parameter': 'beamSet',
    ...                             'value': [{'tiltOffset':'-2'}]}
    ${para_restore}    Evaluate    [${para_restore}]
    ${para_modify}    Evaluate    [${para_modify}]
    ${update_tiltOffset_value}    Evaluate    [${update_tiltOffset_value}]
#    ${para_modify}    run keyword if     '${stream}'=='SBTS00'    Combine Lists    ${para_modify}    ${update_tiltOffset_value}
#    ...               ELSE       set variable    ${para_modify}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_modify}    timeout=900
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}' or 'SBTS23R3' in '${stream}'    70M     55M
    ${dl_data_transfer}    set variable if  'SBTS00' in '${stream}' or 'SBTS23R3' in '${stream}'    750M     800M
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}' or 'SBTS23R3' in '${stream}'    49     50
    ${expect_dl_tput}    set variable if  'SBTS00' in '${stream}' or 'SBTS23R3' in '${stream}'    520    670
    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=${expect_dl_tput}
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index_list}[0]
    ...                                    target_avg_percent=0.95
    ...                                    reset_sol=${reset_sol}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_restore}    timeout=900
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=${expect_dl_tput}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index_list}[0]
    ...                                    target_avg_percent=0.95
    ...                                    is_do_require_ue=${False}

5GC002548_B_006_5GC000399_eCPRI_FREERUN_state_handling_ASIB
    [Arguments]    ${cell_index}=1
    [Documentation]    Sub-feature:5GC002548-C
    ${restore_topDomainNumber}   coam_parameter.get_single_value_from_scf_file    parameter=topDomainNumber
    ...                  dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...                  connection=GNB_OAM
    &{para_restore}    Create Dictionary   dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    parameter=topDomainNumber    value=${restore_topDomainNumber}
    &{para_modify}    Create Dictionary   dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    parameter=topDomainNumber    value=43
    ${para_restore}    Evaluate    [&{para_restore}]
    ${para_modify}    Evaluate    [&{para_modify}]
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update several parameters via rest api     parameters_to_update_via_api=${para_modify}
    ...                                             timeout=${180}
    Wait Until Keyword Succeeds    5 min    10 sec   Connect to gnb coam via ssl
    Wait For Expect Fault Present   faultId=${16}     timeout=600
    Wait For Expect Fault Present   faultId=${4298}     timeout=600
    ${allowed_fault_list}    Create list    @{ALLOWED_FAULT}    ${fault_16}    ${fault_4298}    ${fault_7300}   ${fault_7319}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_fault_list}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update several parameters via rest api     parameters_to_update_via_api=${para_restore}
    ...                                             timeout=${180}
    Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear   faultId=${4298}   timeout=180
    COAM Wait For Gnb Ready And Cell Setup
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    160M    80M
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    130    73
#    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
#    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.9
    [Teardown]   Run Keyword And Ignore Error    COAM Update several parameters via rest api
    ...                                          parameters_to_update_via_api=${para_restore}
    ...                                          timeout=${180}

5GC002510_A_04_SiSo_RF_module_reset_from_GUI_under_creation
    [Arguments]    ${ru_index}=1    ${cell_index}=1
    Perform RF Module Reset from GUI    ru_index=${ru_index}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    160M    80M
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    130    73
    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.9

5GC002510_A_05_SiSo_RF_module_power_reset
    [Arguments]    ${ru_index}=1    ${cell_index}=1
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    Perform RU Power On    ru_index=${ru_index}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Online    ru_index=${ru_index}
    COAM Wait For Gnb Ready And Cell Setup    timeout=5 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    90M    80M
    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95

5GC002510_A_08_SiSo_RU_lock_unlock_ASIK
    [Arguments]    ${ru_index}=1    ${cell_index}=1    ${cell_group_idx}=0    ${ue_index}=0    ${throuput_duration}=1200    ${ignore_time}=5min
    Perform RU lock via rest api    ru_idx=${ru_index}    timeout=120
    Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}
#    ${cell_idx}    Evaluate    ${ru_index}-1
    Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    ${allowed_fault_list}    Create list    @{ALLOWED_FAULT}    ${fault_16}    ${fault_4298}    ${fault_7300}   ${fault_7319}    ${fault_7312}
    ...                       ${fault_7313}
    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_fault_list}
    Perform RU unlock via rest api    ru_idx=${ru_index}    timeout=120
    Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}
    Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Enabled    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    COAM Wait For Gnb Ready And Cell Setup    timeout=5 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    ${ul_data_transfer}    set variable if    'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    160M    80M
    ${expect_ul_tput}    set variable if    'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    130    73
#    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    ${gnb_version}    set variable if     'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    True    Fasle
    Run keyword if    '${gnb_version}'=='True'
    ...                                       Start L3 Call And Verify Throughput With NRDIM     ul_data_transfer=${ul_data_transfer}
    ...                                                                                             dl_data_transfer=1000M
    ...                                                                                             4G_check=${False}
    ...                                                                                             cellid=${cell_index}
    ...                                                                                             pucchprb=${4}
    ...                                                                                             ue_index=${ue_index}
    ...               ELSE IF     '${gnb_version}'=='False'
    ...                                       Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                                                                 dl_data_transfer=1000M
    ...                                                                                 expect_ul_tput=${expect_ul_tput}
    ...                                                                                 expect_dl_tput=840
    ...                                                                                 4G_check=${False}
    ...                                                                                 cellid=${cell_index}
    ...                                                                                 duration=360
    ...                                                                                 target_avg_percent=0.98
    ...                                                                                 min_percent=0.85
    [Teardown]    Run Keyword And Ignore Error     run keywords
    ...    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error   Perform RU unlock via rest api    ru_idx=${ru_index}

5GC002510_A_12_SiSo_E2E_system_setup_with_data_transfer_conducted_60M_30KM
    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 5% bler
    ...               CHBW:60MHz
    [Arguments]    ${ru_index}=1    ${cell_index}=1    ${cell_group_idx}=0    ${ue_index}=0      ${throuput_duration}=600    ${ignore_time}=1min
    ${ul_data_transfer}    set variable if    'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    160M    80M
    ${gnb_version}    set variable if     'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    True    Fasle
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    ${ul_data_transfer_spark}    set variable if    '${gnb_version}'=='True' and '${ue_type}'=='huawei_sigspark'    160MKbits/sec    80MKbits/sec
    ${expect_ul_tput}    set variable if    'SBTS00' in '${stream}' or 'SBTS24R1' in '${stream}' or 'SBTS24R2' in '${stream}'    130    73
    ${ul_data_transfer_ue}     set variable if     '${ue_type}'=='huawei_sigspark'      ${ul_data_transfer_spark}     ${ul_data_transfer}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer_ue}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=840
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    duration=360
    ...                                    target_avg_percent=0.98
    ...                                    min_percent=0.85
    ...                                    ue_index=${ue_index}
    ...                                    throuput_duration=${throuput_duration}
    ...                                    ignore_time=${ignore_time}

5GC002510_A_07_SiSo_Cell_lock_and_unlock_ASIK
    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 10% bler
    ...               CHBW:60MHz
    [Arguments]    ${cell_list}
    Get X2 link shutdown waiting time
    Update x2LinkSupervisionTmr Value
    ${expected_dl_tput}    Set Variable If    '${gNbCuType}' == 'NSA'    720    670
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_list}    is_group=${False}
    Sleep    60 sec
    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95
    [Teardown]    Run Keyword And Ignore Error   Run Keywords
    ...           Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    AND
    ...           Recover Cell If Test Case Failed    AND
    ...           Run Keyword And Ignore Error
    ...           Update x2LinkSupervisionTmr Value    x2LinkSupervisionTmr=${X2_link_shutdown_time}

5GC002548_B_124_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak
    [Documentation]   Sub-feature:5GC002548-B
    ...               CHBW:100MHz
    ${ul_data_transfer}     set variable if    'SBTS00' in '${stream}'    240M    160M
    ${expected_ul_tput}     set variable if    'SBTS00' in '${stream}'    215    135
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1600M
    ...                                    expect_ul_tput=${expected_ul_tput}
    ...                                    expect_dl_tput=1400
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.9

5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_bandwidth_with_256QAM_mcs_27_AEHC
    [Documentation]
    ...    This test case is used to test 1077 256QAM peak TP.
    ...    CHBW:40MHz
    Start L3 Call And Verify Throughput    ul_data_transfer=60M
    ...                                    dl_data_transfer=700M
    ...                                    expect_ul_tput=42
    ...                                    expect_dl_tput=520
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95

5GC002244-A_BF_enable_Refine_disable_Traffic_2SSB_4Rx
    [Documentation]
    ...    This test case is used to test 5GC002244 case.
    ...    CHBW:60MHz, Feature_ID:5GC002244-A, DL 4x4 MIMO
    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95

5GC002548_B_011_5GC000561_eCPRI_sync_counters
    [Documentation]   Sub-feature:5GC002548-BF
    [Arguments]    ${ethlk_id}=7
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/PMMNL-1
    ${para_modify}    Catenate    {'dist_name': '${dis_name_dir}', 'parameter': 'eCpriMasterStatisticsInterval', 'value': '5min'}
    ${2548_B_002_para_modify}    Evaluate     [${para_modify}]
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${2548_B_002_para_modify}    timeout=900
    Sleep    5min
    Wait Until Next Counter Update
    ${SyncMsg_Latest_value}    Get Transport Counters    counter_id=M40102C0
    ...                                        full_path=TNL-2/ETHLK/ETHLK-${ethlk_id}/SBTS_NCPRI/topTxEcpriMstSyncMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    ${AnnMsg_Latest_value}    Get Transport Counters    counter_id=M40102C1
    ...                                       full_path=TNL-2/ETHLK/ETHLK-${ethlk_id}/SBTS_NCPRI/topTxEcpriMstAnnounceMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    ${DelayRespMsg_Latest_value}    Get Transport Counters    counter_id=M40102C2
    ...                                       full_path=TNL-2/ETHLK/ETHLK-${ethlk_id}/SBTS_NCPRI/topTxEcpriMstDelayRespMessg
    ${DelayReqMsg_Latest_value}    Get Transport Counters    counter_id=M40102C3
    ...                                       full_path=TNL-2/ETHLK/ETHLK-${ethlk_id}/SBTS_NCPRI/topRxEcpriMstDelayReqMessg
    Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    ${SsmMsg_Latest_value}    Get Transport Counters    counter_id=M40102C4
    ...                                       full_path=TNL-2/ETHLK/ETHLK-${ethlk_id}/SBTS_NCPRI/synceTxEcpriMstSsmMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302

5GC002548_B_002_5GC000399_eCPRI_U-plane_Fast_C-plane_counters_ASIK
    [Documentation]    Sub-feature:5GC002548-BG,set miNrEcpriUpFCp=5 to trigger M55318 measurement enable
    [Arguments]    ${mr_bts_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ${restore_topDomainNumber}   coam_parameter.get_single_value_from_scf_file    parameter=topDomainNumber
    ...                  dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...                  connection=GNB_OAM
    &{para_restore}    Create Dictionary   dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    parameter=topDomainNumber    value=${restore_topDomainNumber}
    ${para_restore}    Evaluate    [&{para_restore}]

    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1
    ${para_modify}    Catenate    {'dist_name': '${dis_name_dir}', 'parameter': 'miNrEcpriUpFCp', 'value': '5min'},
    ...                           {'dist_name': 'MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1', 'parameter' : 'topDomainNumber', 'value': '43'}
    ${2548_B_002_para_modify}    Evaluate     [${para_modify}]
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${2548_B_002_para_modify}    timeout=900
    Wait Until Keyword Succeeds    5 min    10 sec   Connect to gnb coam via ssl
    Wait For Expect Fault Present   faultId=${16}     timeout=600
    Wait For Expect Fault Present   faultId=${4298}     timeout=600
    ${allowed_fault_list}    Create list    @{ALLOWED_FAULT}    ${fault_16}    ${fault_4298}    ${fault_7300}   ${fault_7319}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_fault_list}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update several parameters via rest api     parameters_to_update_via_api=${para_restore}
    ...                                             timeout=${180}
    Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear   faultId=${4298}   timeout=180
    COAM Wait For Gnb Ready And Cell Setup
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}' and 'SBTS24R2' in '${stream}'    160M    80M
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}' and 'SBTS24R2' in '${stream}'    130    73
#    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1500M
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
#    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.9
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${M55318C00002_full_path_SBTS00}    set variable    ${dis_name_dir}/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RU_RCV_ALL
    ${M55318C00002_full_path_SBTS24R1}    set variable    [N41Cell1] CELLS/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RU_RCV_ALL
    ${M55318C00002_full_path_SBTS23R4}    set variable    CELLS/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RU_RCV_ALL
#    ${M55318C00002_full_path_SBTS23R4}    set variable    [AEHC_cell-${cell_index}] CELLS/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RU_RCV_ALL
#    ...                                                                      [N41Cell1] CELLS/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RU_RCV_ALL
#    ${M55318C00001_value}    Get Bts Counters Info    counter_id=M55318C00001
#    ...                                               full_path=CELLS/NRCELL-${cell_index}/NECUP/ECPRI_UP_MSG_RAU_RCV_ALL
#    Run Keyword And Ignore Error    Should Be True    ${M55318C00001_value} >0
    run keyword and ignore error   COAM Teardown gnb connections
    run keyword and ignore error    Connect to gnb coam via ssl
    ${M55318C00002_value}    Run keyword if    'SBTS00' in '${stream}' or 'SBTS24R2' in '${stream}'
    ...                                                                   Get counter latest value    BTS_or_TRS=BTS    counter_id=M55318C00002
    ...                                                                                        counter_full_path=${M55318C00002_full_path_SBTS00}
    ...                      ELSE
    ...                                                                   Get Bts Counters Info    counter_id=M55318C00002
    ...                                                                                            full_path=${M55318C00002_full_path_${stream}}
    Run Keyword And Ignore Error    Should Be True    ${M55318C00002_value} >0
    [Teardown]   Run Keyword And Ignore Error    COAM Update several parameters via rest api
    ...                                          parameters_to_update_via_api=${para_restore}
    ...                                          timeout=${180}


5GC002522-CB-SyVe_TC03_NSA_PeakThrough_20MhzBW_4X4MIMO_256QAM_UDP
    [Documentation]
    ...    This test case is used to test 1077 256QAM peak TP.
    ...    CHBW:20MHz
    Update msg1FrequencyStart Value    cell_id=1    msg1FrequencyStart=10
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                    dl_data_transfer=400M
    ...                                    expect_ul_tput=16
    ...                                    expect_dl_tput=250
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95

5GC002083_Check_all_phases
    [Documentation]    Feature_ID:FGCR-7855-5GC002083-sleeping cell 2 detection and recovery via RACH
    ...                Author: xiangyue.zhou@nokia-sbell.com
    ${para_modify}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1',
    ...                            'parameter': 'actAutRachBasedSlCellDetRec',
    ...                             'value': 'true'},
    ...                           {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRachAtmpThr',
    ...                             'value': '0'}
    ${para_to_modify}    Evaluate     [${para_modify}]
    ${para_modify_for_sleeping_cell}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                             'parameter': 'autRachBasedSlCellRecPhase3Act',
    ...                             'value': 'true'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPhase2Act',
    ...                             'value': 'true'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellDetHCheckFreq',
    ...                             'value': '120'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPh1Timer',
    ...                             'value': '300'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPh2Timer',
    ...                             'value': '300'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPh3Timer',
    ...                             'value': '300'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1',
    ...                            'parameter': 'nrCntRachStpSlCellDetHChFrq',
    ...                             'value': '120'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1',
    ...                            'parameter': 'nrCntRachStpSlCellDetMsg3Thr',
    ...                             'value': '1000'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1',
    ...                            'parameter': 'nrCntRachStpSlCellRecPh1Tmr',
    ...                             'value': '300'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1',
    ...                            'parameter': 'nrCntRachStpSlCellRecPh2Tmr',
    ...                             'value': '300'},
    ...                          {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1',
    ...                            'parameter': 'nrCntRachStpSlCellRecPh3Tmr',
    ...                             'value': '300'}
    ${para_for_sleeping_cell}    Evaluate     [${para_modify_for_sleeping_cell}]
    ${restore_modify}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1',
    ...                            'parameter': 'actAutRachBasedSlCellDetRec',
    ...                             'value': 'false'},
    ...                            {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPhase2Act',
    ...                             'value': 'false'},
    ...                            {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRecPhase3Act',
    ...                             'value': 'false'},
    ...                            {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'autRachBasedSlCellRachAtmpThr',
    ...                             'value': '1000'}
    ${para_to_restore}    Evaluate     [${restore_modify}]
    ${delete_4547_param}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/TRBLCADM-1',
    ...                            'parameter': 'faultSnapshotTriggers'}
    ${delete_4547_first}    Evaluate     [${delete_4547_param}]
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_for_sleeping_cell}    timeout=900
    COAM delete parameters via rest api    parameters_to_delete_via_api=${delete_4547_first}    timeout=900
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_to_modify}    timeout=900
    Wait Until Keyword Succeeds    15min   5 sec     COAM Check GNB with sleeping cell
    Wait For Expect Fault Present   faultId=${4547}    timeout=10min
    Sleep  5min
    Wait Until Keyword Succeeds    5min   5 sec     Verify ABIL Restart
    Wait Until Keyword Succeeds    15min   5 sec     COAM Check GNB with sleeping cell
    Wait For Expect Fault Present   faultId=${4547}   timeout=10min
    [Teardown]   Run Keyword And Ignore Error    Run Keywords
    ...            COAM Update Several Parameters Via Rest Api     parameters_to_update_via_api=${para_to_restore}    timeout=900    AND
    ...            COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    AND
    ...            Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    AND
    ...            Wait Until Keyword Succeeds    5min   5 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}

5GC002548_B_011_5GC000561_eCPRI_sync_counters_Trunk
    [Documentation]   Sub-feature:5GC002548-BF
    ...    modified: 2021-08-23 Jia Lei add fiberswitch on AEHC Trunk, it will cause about 6 hours.
    Log To Console    \nStart L3 call for the first time.
    run keyword and continue on failure    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                                                           dl_data_transfer=1000M
    ...                                                                           expect_ul_tput=70
    ...                                                                           expect_dl_tput=800
    ...                                                                           4G_check=${False}
    ...                                                                           cellid=${cell_index}
    ...                                                                           target_avg_percent=0.95
    Log To Console    \nBegin to check counters.
    5GC002548_B_011_5GC000561_eCPRI_sync_counters
    FOR    ${count}    IN RANGE    3
        Log To Console    \nBegin to perform link break 10 times in try ${count}.
        5G_Site_eCPRI_link_failure_break_2mins_recovery 10 times with L3 call
    END

CB006915_D_01_L3call_test_2S_1CC_8D4U
    [Documentation]   SA100M: DL: 1400M UL: 150M 0% (case bler: UL:5% DL:5%)
    Get gNb Cu Type Value
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    1400    1350
    Start L3 Call And Verify Throughput   ul_data_transfer=160M
    ...                                   dl_data_transfer=1500M
    ...                                   expect_ul_tput=135
    ...                                   expect_dl_tput=${expected_dl_tput}
    ...                                   reset_sol=pc_reset
    ...                                   4G_check=${False}
    ...                                   target_avg_percent=0.95

CB009403_01_06_General_SiSo_RU_lock_unlock
    [Documentation]   Sub-feature:CB009403-A,L3 call DL TP expect value is 10% bler
    ...               CHBW:100MHz
    [Arguments]    ${cell_list}
    Get X2 link shutdown waiting time
    Update x2LinkSupervisionTmr Value
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_list}    is_group=${False}
    Sleep    60 sec
    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                    dl_data_transfer=1600M
    ...                                    expect_ul_tput=120
    ...                                    expect_dl_tput=1300
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95
    [Teardown]    Run Keyword And Ignore Error   Run Keywords
    ...           Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    AND
    ...           Recover Cell If Test Case Failed    AND
    ...           Run Keyword And Ignore Error
    ...           Update x2LinkSupervisionTmr Value    x2LinkSupervisionTmr=${X2_link_shutdown_time}

CB009403_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Documentation]   Sub-feature:CB009403-A,L3 call DL TP expect value is 10% bler
    ...               CHBW:60MHz
    [Arguments]    ${scf_file_name}=Configuration_CB009403_${stream}.xml
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    Modify SCF and Perform Commission    ParamterToModify=${PARAMS_TO_MODIFY_FOR_60_60_60}
    ...                                  ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_60_60_60}
    ...                                  scf_path=${scf_file_path}
    ...                                  scf_file_name=${scf_file_name}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    90s    Wait for calibration setup
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    160M    80M
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    130    73
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=850
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.9

CB006915_I_03_L3call_3S_1CC_8D4U_1fiber
    [Documentation]   SA100M: DL: 1400M UL: 150M 0% (case bler: UL:5% DL:5%)
#    Get gNb Cu Type Value
    ${ul_data_transfer}     set variable if    'SBTS00' in '${stream}'    240M    160M
    ${expected_ul_tput}     set variable if    'SBTS00' in '${stream}'    215    135
    Run keyword if    'SBTS00' in '${stream}'    Start L3 Call And Verify Throughput With NRDIM     ul_data_transfer=${ul_data_transfer}
    ...                                                                                             dl_data_transfer=1700M
    ...                                                                                             4G_check=${False}
    ...                                                                                             cellid=${cell_index}
    ...          ELSE
    ...                                          Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                                                                 dl_data_transfer=1700M
    ...                                                                                 expect_ul_tput=${expected_ul_tput}
    ...                                                                                 expect_dl_tput=1400
    ...                                                                                 reset_sol=pc_reset
    ...                                                                                 4G_check=${False}
    ...                                                                                 target_avg_percent=0.9


CB006915_G_01_L3call_test_3S_1CC_8D4U
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Sleep    90s    Wait for calibration setup
    ${ul_data_transfer}     set variable if    'SBTS00' in '${stream}'    240M    160M
    ${expected_ul_tput}     set variable if    'SBTS00' in '${stream}'    215    135
    Start L3 Call And Verify Throughput   ul_data_transfer=${ul_data_transfer}
    ...                                   dl_data_transfer=1500M
    ...                                   expect_ul_tput=${expected_ul_tput}
    ...                                   expect_dl_tput=1400
    ...                                   reset_sol=pc_reset
    ...                                   4G_check=${False}
    ...                                   target_avg_percent=0.9

CB009359-SR-A_01_NR_only_8DL_8UL_2CC_NR100_NR90
    [Arguments]    ${cellid}=0    ${lock_cell_id}=1
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=150M
    ...                                    dl_data_transfer=1500M
    ...                                    expect_ul_tput=140
    ...                                    expect_dl_tput=1400
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cellid}
    ...                                    target_avg_percent=0.95
    Lock Cell    cell_id=${lock_cell_id}
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${lock_cell_id}
    Sleep    10sec
    Unlock Cell    cell_id=${lock_cell_id}
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${lock_cell_id}
    Sleep    60sec
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput     ul_data_transfer=150M
    ...                                            dl_data_transfer=1500M
    ...                                            expect_ul_tput=140
    ...                                            expect_dl_tput=1400
    ...                                            4G_check=${False}
    ...                                            reset_sol=${reset_sol}
    ...                                            cellid=${cellid}
    ...                                            is_do_require_ue=${False}
    ...                                            target_avg_percent=0.95
    [Teardown]     run keywords    Run Keyword And Ignore Error    Stop Traffic In Teardown    AND
    ...                            Run Keyword And Ignore Error    Unlock Cell    cell_id=${lock_cell_id}
