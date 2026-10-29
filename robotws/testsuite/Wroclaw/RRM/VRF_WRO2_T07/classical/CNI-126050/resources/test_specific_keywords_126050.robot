*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CNI-126050

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library     Collections
Library     taf.ue
Library     taf.sbts.oam.coam.admin                                                 WITH NAME  coam
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                        WITH NAME  GnbCounter
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/pm_counter_collector.py              WITH NAME  pm
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils        WITH NAME   AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py
Library      ../../feature_CB008661/A/resources/test_specific_keywords.py   WITH NAME    keywords_8661_A
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2      WITH NAME    L1L2
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/test_specific_keywords_126050.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py

*** Variables ***
${MRBTS_5G_ID}        ${tl.gnbs[0].instance_id}
${MRBTS_5G}           MRBTS-55200
${SYSLOG_ALIAS}       126050_syslog
${IMSI}               310260560003293
${firstCELL_ID}           1
${secondCELL_ID}          2
@{CELLS_TO_LOCK_IN_Test}=      2     3     4    5     6    7   8   9
${PM_INTERVAL}          5
${protocol}             udp
${tput_duration}        1200s
${tput_value}      100 Mbits/sec
${packet_size}          1400
${direction_dl}          dl
${direction_ul}          ul
${atten_level_cell1}     5
${PRBs_to_exclude}      1   2    3   4  5   73  74  75  76  77
${bip_log_path_126050}      126050_dbm_L1L2.pcap
${filter_bip_1}          uldata_puschreceiverespps
${filter_bip_2}          UlData_PuschReceiveRespPs_t

*** Keywords ***

Verify counters with interferences 126050
    [Arguments]       ${cou_s_avg}   ${cou_e_avg}  ${test_name}   ${counter_group_avg}
    ...               ${cou_s_max}      ${cou_e_max}   ${counter_group_max}
    log to console    Collecting   and veryfying counters
    ${counter_dir}  test_specific_keywords_126050.Collect Counters For Testcase CNI126050   ${test_name}
    ${counters_cell1_avg}   get_and_verify_counters_CNI_126050  ${counter_dir}  ${cou_s_avg}
    ...     ${cou_e_avg}  ${firstCELL_ID}   ${counter_group_avg}
    ${counters_cell2_avg}   get_and_verify_counters_CNI_126050  ${counter_dir}  ${cou_s_avg}
    ...     ${cou_e_avg}  ${secondCELL_ID}  ${counter_group_avg}
    ${counters_cell1_max}   get_and_verify_counters_CNI_126050  ${counter_dir}  ${cou_s_max}
    ...     ${cou_e_max}  ${firstCELL_ID}   ${counter_group_max}
    ${counters_cell2_max}   get_and_verify_counters_CNI_126050  ${counter_dir}  ${cou_s_max}
    ...     ${cou_e_max}  ${secondCELL_ID}  ${counter_group_max}
    ${result1}  Compare counters CNI 126050    ${counters_cell1_avg}  ${counters_cell1_max}      ${firstCELL_ID}
    ...                            ${PRBs_to_exclude}
    ${result2}  Compare counters CNI 126050    ${counters_cell2_avg}  ${counters_cell2_max}      ${secondCELL_ID}
    ...                            ${PRBs_to_exclude}
    check_test_results_126050      ${result1}      ${result2}


Wait for next counter interval 126050
    log to console       Wait for next counter interval
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL}


Collect Counters For Testcase CNI126050
    [Arguments]  ${testcase}
    ${pi_dir} =   Collect Counters    log_name=${testcase}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True
    [Return]  ${pi_dir}

preparing for counters time setting CNI 126050
    CNI_126050_activation
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_Test}

Unlock Cell for test
    AdminUtils.unlock cells     ${secondCELL_ID}

Dectivate CNI126050
    Dectivate feature CNI126050   ${firstCELL_ID}

lock cell 126050 2
    lock_cell_126050    ${secondCELL_ID}

QRX lev min and attenuation for cell
    log to console  starting qrxlevmin setup
    qrx_levmin_setup   ${firstCELL_ID}


attenuation 126050 attach cell 1
    log to console  starting attenuation setup
    attenuation 126050 attach   ${atten_level_cell1}
Data Transfer procedure 126050
    [Arguments]  ${UE_ALIAS}
    log to console  starting data transfer procedure
    Start Data Transfer  dt_name=${UE_ALIAS}_DT_DL  ue_alias=${UE_ALIAS}  direction=${direction_dl}
    ...                  duration=${tput_duration}   throughput=${tput_value}  protocol=${protocol}
    ...                  packet_size=${packet_size}
    Start Data Transfer  dt_name=${UE_ALIAS}_DT_UL  ue_alias=${UE_ALIAS}  direction=${direction_ul}
    ...                  duration=${tput_duration}  throughput=${tput_value}  protocol=${protocol}
    ...                  packet_size=${packet_size}

Data Transfer Stop procedure 126050
    [Arguments]  ${UE_ALIAS}  ${UE_ALIAS_2}
    log to console  stopping data transfer procedure
    Stop Data Transfer  dt_name=${UE_ALIAS}_DT_DL
    Stop Data Transfer  dt_name=${UE_ALIAS}_DT_UL
    Stop Data Transfer  dt_name=${UE_ALIAS_2}_DT_DL
    Stop Data Transfer  dt_name=${UE_ALIAS_2}_DT_UL

Data transfer check procedure 126050
    [Arguments]  ${UE_ALIAS}  ${UE_ALIAS_2}
    verify tput 126050     ue1=${UE_ALIAS}    ue2=${UE_ALIAS_2}

Bip and pcap check 126050
    [Arguments]     ${LOG_PATH}    ${filter_bip1}  ${filter_bip2}
    log to console  analysis of bip starting
    ${bip_log_analysed}     check 126050 l1l2    pcap_file=${LOG_PATH}/${bip_log_path_126050}
         ...                filter_bip1=${filter_bip_1}    filter_bip2=${filter_bip_2}


