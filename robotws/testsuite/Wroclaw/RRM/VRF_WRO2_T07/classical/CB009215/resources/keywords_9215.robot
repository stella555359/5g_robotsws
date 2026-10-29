*** Settings ***
Documentation
...   author: Marta Irasiak
...   contact: marta.irasiak-gaciarek@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009215


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009215/resources/test_specific_keywords_9215.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/resources/test_specific_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py   WITH NAME    BTSLOG
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/vendorfile_tools/vendorfile_manager.py    WITH NAME    vf_man



*** Variables ***
${mplaneIP}     	         10.44.231.213
${destinationIP}             10.44.149.210
@{empty_cells}               2    4    6
@{traffic_cells}             1    3    5
${LAYER_PRB_DL}              722
${STREAM_PRB_DL}             722
${LAYER_PRB_UL}              324
${STREAM_PRB_UL}             1296
${WB_PRB_DL}                 424
${min_PRB_dl}                48
${min_PRB_ul}                36
${max_PRB}                   106
${cell_id_to_ignore}         10
${long_cell_id_to_ignore}    836239370
${raw_value_analysis}        10
${filter_dl}                 dlInterL1SubpoolReconfData
${filter_ul}                 ulInterL1SubpoolReconfData
${cellTddId}                 10
${subpoolid0}                0
${subpoolid1}                1


*** Keywords ***
CB009215_01_Enhancement_for_GBR_Non-GBR_load_estimation
    ${pre_change_scf}           test_specific_keywords_9215.Backup SCF
    test_specific_keywords_9215.Upload SCF    9215_01
    BTSLOG.start_btslog_on_local_machine
    Modify Vendor for FDD
    ${BTSLOG}           BTSLOG.stop_and_collect_btslog
    ${CELL_MAPPING}     Verify cell assignment to subpool with bts log     ${BTSLOG}
    Attach first UE      dl    DT_1   5
    Attach second UE     dl    DT_2   15
    Attach third UE      dl    DT_3   15
    BuiltIn.Sleep                5s
    GBR Tput             dl    DT_4
    BuiltIn.Sleep                5s
    Log to console    >>>>>>>>>>>>>>> start tti <<<<<<<<<<<<<<<<<<<<<<<<
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep     3s
    ${csv_file}     TTI.stop_tti_traces_in_streaming_mode
    BuiltIn.Sleep     10s
    Stop data
    ${TTI_dict_cell}       Convert TTI trace from csv to dict 9215 cell       ${csv_file}             dl
    ${TTI_dict_subpool}=    Convert TTI trace from csv to dict 9215 subpool
    ...    ${csv_file}
    ...    ${raw_value_analysis}
    ...    ${filter_dl}
    ...    ${cellTddId}
    ...    ${subpoolid0}
    ...    ${subpoolid1}
    ${cell_dict}    get cell subpool dict    ${TTI_dict_cell}       dl
    ...    ${cell_id_to_ignore}    ${long_cell_id_to_ignore}
    Log to console    >>>>> Verify Pool and Subpool for empty and trafiic cells basen on syslog <<<<<
    ${SubP_empty}  ${SubP_traffic}  Verify cells    ${cell_dict}  ${CELL_MAPPING}  ${empty_cells}  ${traffic_cells}
    Log to console    >>>>> subpool verification <<<<<
    Verify subpools with vendor                             ${TTI_dict_subpool}    ${STREAM_PRB_DL}
    Verify min and current PRB in cells based on cell type  ${TTI_dict_subpool}  ${cell_dict}  ${CELL_MAPPING}
    ...    ${SubP_empty}    ${SubP_traffic}     Dl    ${min_PRB_dl}
    Verify empty cells  ${TTI_dict_subpool}  ${cell_dict}  ${SubP_empty}  ${SubP_traffic}  ${empty_cells}           Dl
    ...    ${min_PRB_dl}    ${max_PRB}
    Verify traffic cells  ${TTI_dict_subpool}  ${cell_dict}   ${SubP_empty}    ${SubP_traffic}  ${traffic_cells}    Dl
    ...    ${min_PRB_dl}
    Zab verification    ${cell_dict}    Dl
    [Teardown]   Run Keywords
    ...          Run Keyword And Ignore Error
    ...          taf.ue.Detach Ue    UE_1       AND
    ...          taf.ue.Detach Ue    UE_2       AND
    ...          taf.ue.Detach Ue    UE_3       AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False



CB009215_02_ShortBsrLimitAdaptation
    ${pre_change_scf}           test_specific_keywords_9215.Backup SCF
    test_specific_keywords_9215.Upload SCF    9215_01
    BTSLOG.start_btslog_on_local_machine
    Modify Vendor for FDD
    ${BTSLOG}          BTSLOG.stop_and_collect_btslog
    ${CELL_MAPPING}     Verify cell assignment to subpool with bts log      ${BTSLOG}
    Attach first UE      ul    DT_1   5
    Attach second UE     ul    DT_2   15
    Attach third UE      ul    DT_3   15
    BuiltIn.Sleep                5s
    GBR Tput             ul    DT_4
    BuiltIn.Sleep                5s
    Log to console    >>>>>>>>>>>>>>>>> start tti <<<<<<<<<<<<<<<<<<<<<<<<<<
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep      3s
    ${csv_file}     TTI.stop_tti_traces_in_streaming_mode
    BuiltIn.Sleep      10s
    Stop data
    ${TTI_dict_cell}       Convert TTI trace from csv to dict 9215 cell       ${csv_file}           ul
    ${TTI_dict_subpool}=    Convert TTI trace from csv to dict 9215 subpool
    ...    ${csv_file}
    ...    ${raw_value_analysis}
    ...    ${filter_ul}
    ...    ${cellTddId}
    ...    ${subpoolid0}
    ...    ${subpoolid1}
    ${cell_dict}   get cell subpool dict    ${TTI_dict_cell}       ul
    ...    ${cell_id_to_ignore}    ${long_cell_id_to_ignore}
    Log to console    >>>>> Verify Pool and Subpool for empty and trafiic cells basen on syslog <<<<<
    ${SubP_empty}  ${SubP_traffic}  Verify cells    ${cell_dict}  ${CELL_MAPPING}  ${empty_cells}  ${traffic_cells}
    Log to console    >>>>> subpool verification <<<<<
    Verify subpools with vendor                     ${TTI_dict_subpool}    ${STREAM_PRB_UL}
    Verify current PRB in cells based on cell type  ${cell_dict}  ${CELL_MAPPING}    ${SubP_empty}    ${SubP_traffic}
    ...     Ul
    Verify empty cells  ${TTI_dict_subpool}  ${cell_dict}  ${SubP_empty}  ${SubP_traffic}  ${empty_cells}           Ul
    ...    ${min_PRB_ul}    ${max_PRB}
    Verify traffic cells  ${TTI_dict_subpool}  ${cell_dict}   ${SubP_empty}    ${SubP_traffic}  ${traffic_cells}    Ul
    ...    ${min_PRB_ul}
    [Teardown]   Run Keywords
    ...          Run Keyword And Ignore Error
    ...          taf.ue.Detach Ue    UE_1       AND
    ...          taf.ue.Detach Ue    UE_2       AND
    ...          taf.ue.Detach Ue    UE_3       AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False



###################################### OTHER KEYWORDS ##################################################

Attach first UE
    [Arguments]    ${direction}    ${name}    ${tput}
    Prepare cell for attach    FDD
    Require UE                 UE_1    SA_UE
    Attach UE                  UE_1
    Start data transfer   dt_name=${name}       ue_alias=UE_1         direction=${direction}       duration=1000s
    ...                   packet_size=1200      throughput=${tput} Mbits/sec   protocol=udp
    ...                   iperf_version=2       apn=n26wro
    check_data_transfer_is_alive    ${name}
    log to console      >>>>>>>>>> Tput transfer started <<<<<<<<<<<<<<<<<<<<


Attach second UE
    [Arguments]     ${direction}    ${name}    ${tput}
    Prepare cell for attach    AHLOA2    FDD
    Require UE                 UE_2   NSA_UE
    Attach UE                  UE_2
    Start data transfer   dt_name=${name}       ue_alias=UE_2       direction=${direction}       duration=1000s
    ...                   packet_size=1200      throughput=${tput} Mbits/sec   protocol=udp
    ...                   iperf_version=2       apn=n26wro
    check_data_transfer_is_alive    ${name}
    log to console      >>>>>>>>>> Tput transfer started <<<<<<<<<<<<<<<<<<<<


Attach third UE
    [Arguments]    ${direction}    ${name}    ${tput}
    TcpdumpSmod.start_tcpdump_on_smod      smod_master=${true}    smod_slave=${tl.smod_slave}
    Prepare cell for attach    AHLOA1
    Require UE                 UE_3   VONR_UE
    Attach UE                  UE_3
    Start data transfer   dt_name=${name}       ue_alias=UE_3       direction=${direction}       duration=1000s
    ...                   packet_size=1200      throughput=${tput} Mbits/sec   protocol=udp
    ...                   iperf_version=2       apn=n26wro
    check_data_transfer_is_alive    ${name}
    test_specific_keywords_9215.Nullify attenuation on all cells
    taf.ue.Start Voice Call    vc_alias=VOICE_CALL    ue_alias=UE_3    to=UE_1  duration=1000s
    taf.ue.Await Incoming Voice Call     vc_alias=VOICE_CALL    ue_alias=UE_1  action=answer    timeout=20s
    log to console      >>>>>>>>>> Voice started <<<<<<<<<<<<<<<<<<<<
    BuiltIn.Sleep    10s
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    test_specific_keywords_9215.Check 5qi Setup  ${sctp_logs}


GBR Tput
    [Arguments]     ${direction}    ${name}
    Start data transfer   dt_name=${name}       ue_alias=UE_3       direction=${direction}       duration=1000s
    ...                   packet_size=1400      throughput=1 Mbits/sec   protocol=udp      port=8008
    ...                   iperf_version=2       apn=n26wro
    log to console    >>>>>>>>>>>>>>>>>> GBR started <<<<<<<<<<<<<<<<<<<<<<<<<


Stop data
    Stop data transfer    DT_1
    Stop data transfer    DT_2
    Stop data transfer    DT_3
    Stop data transfer    DT_4
    taf.ue.Stop Voice Call    vc_alias=VOICE_CALL


Modify Vendor for FDD
    vf_man.Download Default Vendorfile      local_path=${LOG_PATH}
    ${filter_criteria}=     Create Dictionary
    ...     bbHwVariant=ABIP
    ...     csSize=48
    ...     direction=DL
    ...     l1PoolType=NR_L1Pool_Thor_FDD_FR1_CPRI
    ${data_to_be_modified}=     Create Dictionary
    ...     maxNumLayerPrbL1Sp=${LAYER_PRB_DL}
    ...     maxNumStreamPrbL1Sp=${STREAM_PRB_DL}
    ...     maxNumWbStreamPrbL1Sp=${WB_PRB_DL}
    ${path_to_xml}=   Get Xml Path For List
    ...     listname=bbL1SpPrbInitCapacity
    ${filter_criteria_bbPool}=    Create Dictionary
    ...     bbHwVariant=ABIP
    ...     csSize=48
    ...     direction=UL
    ...     l1PoolType=NR_L1Pool_Thor_FDD_FR1_CPRI
    ${data_to_be_modified_bbPool}=    Create Dictionary
    ...     maxNumLayerPrbL1Sp=${LAYER_PRB_UL}
    ...     maxNumStreamPrbL1Sp=${STREAM_PRB_UL}
    ${path_to_xml_bbPool}=  Get Xml Path For List
    ...     listname=bbL1SpPrbInitCapacity

    vf_man.Modify Vendorfile               local_path=${LOG_PATH}
    ...                             filter_criteria=${filter_criteria}
    ...                             data_to_be_modified=${data_to_be_modified}
    ...                             xml_path=${path_to_xml}

    vf_man.Modify Vendorfile               local_path=${LOG_PATH}
    ...                             filter_criteria=${filter_criteria_bbPool}
    ...                             data_to_be_modified=${data_to_be_modified_bbPool}
    ...                             xml_path=${path_to_xml_bbPool}

    vf_man.Upload Vendorfile               local_path=${LOG_PATH}
    AdminUtils.Wait For All Cells On Air State
    log to console    >>>>>>>>>>> Vendor modified cells on air <<<<<<<<<<<<<<<<<


Convert TTI trace from csv to dict 9215 cell
    [Arguments]     ${tti_file_path}    ${direction}
    ${tti_dict_cell}    read and parse tti data for cell   ${tti_file_path}    ${direction}
    [Return]       ${tti_dict_cell}


Convert TTI trace from csv to dict 9215 subpool
    [Arguments]     ${tti_file_path}    ${raw_value_analysis}   ${direction}    ${cellTddId}    ${subpoolid0}   ${subpoolid1}
    ${data_analysis}     tti analysis 9215   ${tti_file_path}    ${raw_value_analysis}   ${direction}
    ${data}    ${lcrId}=    Doubled Data    ${data_analysis}    ${cellTddId}
    ${dictionarysubpool0}   create pool dictionary  ${data}     ${lcrId}    ${subpoolid0}
    ${dictionarysubpool1}   create pool dictionary  ${data}     ${lcrId}    ${subpoolid1}
    ${tti_dict_subpool}     create_list_two_dict    ${dictionarysubpool0}   ${dictionarysubpool1}
    [Return]       ${tti_dict_subpool}
