*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: bartosz.1.kozlowski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB008409

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
${MRBTS_5G_ID}        ${tl.gnbs[0].instance_id}
${MRBTS_5G}           MRBTS-55200
${SYSLOG_ALIAS}       8409_syslog
${IMSI}               310260560003293
${PCELL_ID}           1
${IP_CAPTURE_FILE}    ${OUTPUT DIR}/ip_capture.pcap
${IP_CAPTURE_ALIAS}   ip_capture
@{CELLS_TO_LOCK_IN_Test_A}=           3     4    5     6    7   8   9
${PM_INTERVAL}          5
${protocol}             udp
${tput_duration}        1200s
${tput_DL_8409_A2}      5 Mbits/sec
${packet_size}          1400
${direction_A2}          dl
${direction_ul}          ul


*** Keywords ***
Preparing for feature 8409
    log to console  Preparing scf for test 8409
    preparing_for_feature_8409 set
    AdminUtils.Wait For All Cells On Air State
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_Test_A}

Preparing for feature 8409 pooling off
    log to console  Preparing scf for test 8409
    preparing_for_feature_8409_set_pooling_off
    AdminUtils.Wait For All Cells On Air State
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_Test_A}


Dectivate feature A2
    log to console  Deactivating scf for test 8409 A2
    AdminUtils.unlock_all_cells
    AdminUtils.Wait For All Cells On Air State
    SCF_Revert_8409

Dectivate feature A2 pooling
    log to console  Deactivating scf for test 8409 A2 without pooling
    AdminUtils.unlock_all_cells
    AdminUtils.Wait For All Cells On Air State
    SCF_Revert_8409_pooling


Activation feature 8409 part A C
    log to console      Activating feature 8409 Part A C
    ActivatingFeature8409 A C combine
    AdminUtils.Lock Cells     ${CELLS_TO_LOCK_IN_Test_A}


Activation feature 8409 part B
    log to console      Activating feature 8409 Part B
    ActivatingFeature8409_B


Dectivate feature B
    log to console  Deactivating scf for test 8409 B
    AdminUtils.unlock_all_cells
    SCF_Revert_8409_B


Attenuation 8409 A2 for test
    [Arguments]    ${attenuation_8409_A2}
    log to console  Starting attenuation process for feature
    attenuation_8409_A2     ${attenuation_8409_A2}


Start log collection 8409
    [Arguments]       ${tti_file_name}
    log to console  Start TTI collection
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts   tcpdump_filename=${tti_file_name}


Data Transfer procedure
    [Arguments]       ${UE_ALIAS}
    log to console  starting data transfer procedure
    Start Data Transfer  dt_name=DT_DL  ue_alias=${UE_ALIAS}  direction=${direction_A2}  duration=${tput_duration}
    ...                  throughput=${tput_DL_8409_A2}  protocol=${protocol}  packet_size=${packet_size}
    Start Data Transfer  dt_name=DT_UL  ue_alias=${UE_ALIAS}  direction=${direction_ul}  duration=${tput_duration}
    ...                  throughput=${tput_DL_8409_A2}  protocol=${protocol}  packet_size=${packet_size}


Data Transfer Stop procedure
    log to console  stopping data transfer procedure
    Stop Data Transfer  dt_name=DT_DL
    Stop Data Transfer  dt_name=DT_UL


Check data transfer procedure
    Check Data Transfer Is Alive   dt_name=DT_DL
    Check Data Transfer Is Alive   dt_name=DT_UL
    log to console  checking DT is alive


Stop log collection 8409
    [Arguments]    ${tti_file_name}
    log to console  Stop TTI logs
    ${tti_file_path}=    Stop Tti Traces In Streaming Mode 8409
    ...    tcpdump_filename=${tti_file_name}
    [return]          ${tti_file_path}


Start Syslog collection
    log to console  Start syslog collection
    Start syslog capture    log_name=${SYSLOG_ALIAS}.LOG  alias=${SYSLOG_ALIAS}


Stop syslog collection
    Stop syslog capture    alias=${SYSLOG_ALIAS}


Fetch UE IP Address
    [Arguments]     ${adb_hash}
    log to console  Fetch UE IP Address
    ${ue_ip}        fetch_ue_ip  ${adb_hash}
    [Return]        ${ue_ip}


Stop All Existing Data Transfers 8409
    FOR  ${dt_name}  IN  @{all_dt_used_in_tc}
      Stop Data Transfer  ${dt_name}
    END


Stop All Data Transfers 8409
    log to console  Stop all data transfers
    Run keyword if  ${all_dt_used_in_tc}  Stop All Existing Data Transfers 8409


Verify counters with interferences
    [Arguments]       ${CellFilter}     ${counter_ids_8049_A_C}     ${test_name}
    log to console    Collecting   and veryfying counters
    ${counter_dir}  test_specific_keywords_8409.Collect Counters For Testcase   ${test_name}
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_ids_8049_A_C}
    ${counters_dict_2}   get dataNRcell1 Id   ${counters}    ${CellFilter}    ${counter_ids_8049_A_C}
    [return]    ${counters_dict_2}


Verify counters with interferences part B
    [Arguments]       ${CellFilter}     ${counter_ids_8049_A_C}     ${test_name}
    log to console    Collecting and veryfying counters
    ${counter_dir}  test_specific_keywords_8409.Collect Counters For Testcase   ${test_name}
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_ids_8049_A_C}
    ${counters_dict_2}   get dataNRcell1 Id   ${counters}    ${CellFilter}    ${counter_ids_8049_A_C}
    [return]    ${counters_dict_2}


Wait for next counter interval 8409
    log to console       Wait for next counter interval
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL}


Collect Counters For Testcase
    [Arguments]  ${testcase}
    ${pi_dir} =   Collect Counters    log_name=${testcase}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True
    [Return]  ${pi_dir}


Data transfer in interval
    Check data transfer procedure
    Wait for next counter interval 8409
    Check data transfer procedure
    Wait for next counter interval 8409
    Data Transfer Stop procedure


Bip and pcap check
    [Arguments]     ${LOG_PATH}     ${protocol_pcap}    ${filter_pcap_tcp}  ${parameters_pcap}  ${bip_log_path}
    ...                     ${filter_bip1}  ${filter_bip2}  @{bip_values}
    log to console  analysis of bip and pcap onging
    check pcap 8409    pcap_file=${LOG_PATH}/CB008409A_C_tcpdump_SMOD_MASTER.pcap  protocol=${protocol_pcap}
        ...             filter_pcap=${filter_pcap_tcp}   parameter_1=${parameters_pcap}
        ...             value_to_check_list=@{bip_values}
    ${bip_log_analysed}     Check CB008409 L1l2    pcap_file=${LOG_PATH}/${bip_log_path}
         ...                filter_bip1=${filter_bip1}    filter_bip2=${filter_bip2}
    analysis_bip_8409      replaced_list=${bip_log_analysed}  parameter1=${parameterl1l2_1}
        ...                parameter2=${parameterl1l2_2}


Bip and pcap check pooling off
    [Arguments]     ${LOG_PATH}     ${protocol_pcap}    ${filter_pcap_tcp}  ${parameters_pcap}  ${bip_log_path}
    ...                     ${filter_bip1}  ${filter_bip2}  ${bip_values}   ${bip_values2}
    log to console  analysis of bip and pcap onging
    check pcap 8409 pooling off     pcap_file=${LOG_PATH}/CB008409A_C_tcpdump_SMOD_MASTER.pcap  protocol=${protocol_pcap}
        ...             filter_pcap=${filter_pcap_tcp}   parameter_1=${parameters_pcap}
        ...             value_to_check_list1=@{bip_values}  value_to_check_list2=@{bip_values2}
    ${bip_log_analysed}     Check CB008409 L1l2    pcap_file=${LOG_PATH}/${bip_log_path}
         ...                filter_bip1=${filter_bip1}    filter_bip2=${filter_bip2}
    analysis_bip_8409      replaced_list=${bip_log_analysed}  parameter1=${parameterl1l2_1}
        ...                parameter2=${parameterl1l2_2}


Voice Call start
    [Arguments]     ${UE_ALIAS}     ${VC_ALIAS}
    log to console  Start VC
    ${auto_responder}=     Set variable   +555800903300998
    taf.ue.Start voice call     vc_alias=${VC_ALIAS}   ue_alias=${UE_ALIAS}    to=${auto_responder}   duration=1000s
    BuiltIn.Sleep   10s

Stop Voice call
    [Arguments]     ${VC_ALIAS}
    log to console  Stop VC
    taf.ue.Stop Voice Call    ${VC_ALIAS}
