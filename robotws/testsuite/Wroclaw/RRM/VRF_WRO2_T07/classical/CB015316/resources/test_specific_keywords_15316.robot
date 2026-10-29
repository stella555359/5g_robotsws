*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB015316

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
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/resources/test_specific_keywords_15316.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_8409.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py

*** Variables ***
${MRBTS_5G_ID}        ${tl.gnbs[0].instance_id}
${MRBTS_5G}           MRBTS-40812
${PM_INTERVAL}          5
${protocol}             udp
${tput_duration}        120s
${tput_value}      100 Mbits/sec
${packet_size}          1400
${direction_dl}          dl
${direction_ul}          ul
${rats}                     ${None}
${ammount_of_collected_counters}        2

*** Keywords ***

Setup Test Variables
    ${result}    Get Active RATs
    Set Global Variable    ${rats}    ${result}


Wait for next counter interval
    log to console       Wait for next counter interval
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL}


Collect Counters For Testcase CNI126050
    [Arguments]  ${testcase}
    ${pi_dir} =   Collect Counters    log_name=${testcase}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True
    [Return]  ${pi_dir}


Data Transfer procedure 15316
    [Arguments]  ${UE_1_alias}
    log to console  starting data transfer procedure
    Start Data Transfer  dt_name=${UE_1_alias}_DT_DL  ue_alias=${UE_1_alias}  direction=${direction_dl}
    ...                  duration=${tput_duration}   throughput=${tput_value}  protocol=${protocol}
    ...                  packet_size=${packet_size}
    Wait for next counter interval


Data Transfer Stop procedure 15316
    [Arguments]  ${UE_1_alias}
    log to console  stopping data transfer procedure
    Stop Data Transfer  dt_name=${UE_1_alias}_DT_DL


Data transfer check procedure 15316
    [Arguments]  ${UE_1_alias}
    verify_tput_15316    ue1=${UE_1_alias}


Collect Counters For Testcase 15316
    [Arguments]       ${cellId}     ${counter_id_15316}     ${test_name}
    log to console    Collecting   and veryfying counters
    ${counter_dir}  test_specific_keywords_8409.Collect Counters For Testcase   ${test_name}
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_id_15316}
    ${cell_counters}    get counters for cell Id   ${counters}    ${cellId}    ${ammount_of_collected_counters}
    [return]    ${cell_counters}



