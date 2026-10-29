*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB012439

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library     Collections
Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py
Library     taf.sbts.oam.coam.admin                                                 WITH NAME  coam
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                        WITH NAME  GnbCounter
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/pm_counter_collector.py              WITH NAME  pm
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils        WITH NAME   AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008661/A/resources/test_specific_keywords.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2      WITH NAME    L1L2
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py
*** Variables ***
@{counter_ids_CB012439_NRMASA}      M55190C00001     M55190C00002
@{counter_ids_CB012439_IAF}         M55187C00001    M55187C00002
@{handover_id_counter}              M55147C00024
@{counter_ids_CB012439_IEF}         M55188C00001
@{counters_CA_IAF}                  M55187C00003    M55187C00004
@{counters_ids_IAF_2}               M55187C00003    M55187C00004
@{counters_ids_IEF}                 M55188C00001    M55188C00002
@{counter_bc}                       M55157C00033

${counter_string_1}     MRBTS-55200/NRBTS-55200/NRCELL-3/PLMN-PLMN/NRMASA-1
${counter_string_2}     MRBTS-55200/NRBTS-55200/NRCELL-4/PLMN-PLMN/NRMASA-1
${counter_string_3}     MRBTS-55200/NRBTS-55200/NRCELL-3/PLMN-PLMN/NRMIAF-1
${counter_string_4}     MRBTS-55200/NRBTS-55200/NRCELL-4/PLMN-PLMN/NRMIAF-1
${counter_string_5}     MRBTS-55200/NRBTS-55200/NRCELL-3/PLMN-PLMN/NRMIEF-1
${counter_string_6}     MRBTS-55200/NRBTS-55200/NRCELL-3
${counter_string_7}     MRBTS-55200/NRBTS-55200/NRCELL-4/PLMN-PLMN/NRMIEF-1
${counter_string_8}     MRBTS-55200/NRBTS-55200/NRCELL-4


*** Keywords ***
Verify counters with complicated name
    [Arguments]       ${counter_ids}     ${test_name}
    log to console    Collecting and veryfying counters
    ${counter_dir}  test_specific_keywords_8409.Collect Counters For Testcase   ${test_name}
    ${counters}  get_and_verify_counters_complicated_name    ${counter_dir}  ${counter_ids}
    ${counters_SA_3}    Finding Counters   ${counters}  ${counter_string_1}   ${counter_ids_CB012439_NRMASA}
    ${counters_SA_4}    Finding Counters   ${counters}  ${counter_string_2}   ${counter_ids_CB012439_NRMASA}
    ${counters_IAF_3}    Finding Counters   ${counters}  ${counter_string_3}   ${counter_ids_CB012439_IAF}
    ${counters_IAF_4}    Finding Counters   ${counters}  ${counter_string_4}   ${counter_ids_CB012439_IAF}
    ${counters_IEF_3}    Finding Counters   ${counters}  ${counter_string_5}   ${counter_ids_CB012439_IEF}
    ${counter_HO}        Finding Counters   ${counters}  ${counter_string_6}   ${handover_id_counter}
    Comparison of counters      ${counters_SA_3}    ${counters_SA_4}    ${counters_IAF_3}   ${counters_IAF_4}
     ...                        ${counters_IEF_3}   ${counter_HO}

Verify counters with complicated name part C
    [Arguments]       ${counter_ids}     ${test_name}
    log to console    Collecting and veryfying counters
    ${counter_dir}  test_specific_keywords_8409.Collect Counters For Testcase   ${test_name}
    ${counters}  get_and_verify_counters_complicated_name    ${counter_dir}  ${counter_ids}
    ${counters_SA-1}    Finding Counters   ${counters}  ${counter_string_2}   ${counter_ids_CB012439_NRMASA}
    ${counters_SA-2}    Finding Counters   ${counters}  ${counter_string_4}   ${counter_ids_CB012439_IAF}
    ${counters_SA-3}    Finding Counters   ${counters}  ${counter_string_4}   ${counters_ids_IAF_2}
    ${counters_SA-4}    Finding Counters   ${counters}  ${counter_string_7}   ${counters_ids_IEF}
    ${counters_SA-5}    Finding Counters   ${counters}  ${counter_string_8}   ${counter_bc}
    comparison_of_counters_BC     ${counters_SA-1}    ${counters_SA-2}    ${counters_SA-3}   ${counters_SA-4}
     ...                        ${counters_SA-5}


Data Transfer procedure 12439
    [Arguments]       ${UE_ALIAS}   ${tput}
    log to console  starting data transfer procedure
    Start Data Transfer  dt_name=DT_DL  ue_alias=${UE_ALIAS}  direction=${direction_A2}  duration=${tput_duration}
    ...                  throughput=${tput}  protocol=${protocol}  packet_size=${packet_size}
    Start Data Transfer  dt_name=DT_UL  ue_alias=${UE_ALIAS}  direction=${direction_ul}  duration=${tput_duration}
    ...                  throughput=${tput}  protocol=${protocol}  packet_size=${packet_size}
