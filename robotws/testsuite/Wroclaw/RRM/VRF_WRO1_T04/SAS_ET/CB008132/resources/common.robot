*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team common keywords for CB008132 feature

Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_syslog
Library    suite_kws.py                                             WITH NAME    suite__
Library    validation_bip.py                                        WITH NAME    bip__
Library    validation_syslog.py                                     WITH NAME    syslog__
Library    validation_counters.py                                   WITH NAME    counters__
Library    utilities.py                                             WITH NAME   util__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/file_management.py             WITH NAME    file__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py                  WITH NAME    gnb__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py                  WITH NAME    wts__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_airphone.py             WITH NAME    ap__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/traffic_management.py          WITH NAME    traffic__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/bip_management.py              WITH NAME    bip_manag__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py                   WITH NAME    utilities__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/bip_asoe_keywords.py           WITH NAME    bip_asoe__

Resource    tti_trace.robot

Variables    variables.py

*** Keywords ***

Prepare Environment For Tests without rebooting
    [Arguments]         ${tc}
    wts__.Ensure Wts Is Not Running
#    gnb__.Ensure Short Pmstats Flag Existence In Swconfig
    gnb__.Ensure Cplane Flags Existence In Swconfig
    gnb__.Ensure Cp Runtime Ini Has LoggingSeverity Set On Trace
    suite__.Create Output Dir Tc            tc=${tc}

Send DL Iperf For
    [Arguments]   ${seconds}
    ...           ${tput}
    ...           ${ip}
    Log    Send DL Iperf For
    traffic__.Send Downlink Iperf       duration_tput=${seconds}
    ...                                 dl_tput=${tput}
    ...                                 ue_ip=${ip}
    [Teardown]  traffic__.Stop Downlink Iperf

Register 1st UE to 1st slice
    wts__.Register Ue                   ue_id=${UE_ID_1}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_1}
    ...                                 gw_id=${GW_ID_1}

Register 4th UE to 1st slice
    wts__.Register Ue                   ue_id=${UE_ID_4}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_4}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_1}
    ...                                 gw_id=${GW_ID_1}

Register 2nd UE to 2nd slice
    wts__.Register Ue                   ue_id=${UE_ID_2}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_2}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_2}
    ...                                 gw_id=${GW_ID_2}

Register 3rd UE to 3rd slice
    wts__.Register Ue                   ue_id=${UE_ID_3}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_3}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_3}
    ...                                 gw_id=${GW_ID_3}

Register 2nd UE to 4th slice
    wts__.Register Ue                   ue_id=${UE_ID_2}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_2}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_4}
    ...                                 gw_id=${GW_ID_2}

Register 1st UE to 2nd slice
    wts__.Register Ue                   ue_id=${UE_ID_1}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_2}
    ...                                 gw_id=${GW_ID_1}

Register 2nd UE to 3rd slice
    wts__.Register Ue                   ue_id=${UE_ID_2}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_2}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_3}
    ...                                 gw_id=${GW_ID_2}

Reconfigure 3 Quotas And Validate Them
    [Arguments]     ${quotas}
    recom__.set_3_quota_on_delta           delta_file=${DELTA_QUOTA_DEFAULT}
    ...                                    quotas=${quotas}
    SYSCOM Start
    recom__.Perform Delta Recomissioning      output_dir=${OUTPUT_DIR_TC}
    ...                                       delta=${DELTA_READY_TO_COM}
    ...                                       time_after_recom=0
    SYSCOM Stop
    Ensure Bip Contain Proper CellReconfigurationReq And Validate Quotas With Sd Values        quotas=${quotas}
    ...                                                                                        sd=${SD_VALUES}

Reconfigure 6 Quotas And Validate Them
    [Arguments]     ${quotas}
    recom__.set_6_quota_on_delta           delta_file=${DELTA_QUOTA_6_SLICE}
    ...                                    quotas=${quotas}
    SYSCOM Start
    recom__.Perform Delta Recomissioning      output_dir=${OUTPUT_DIR_TC}
    ...                                       delta=${DELTA_READY_TO_COM}
    ...                                       time_after_recom=0
    SYSCOM Stop
    Ensure Bip Contain Proper CellReconfigurationReq And Validate Quotas With Sd Values        quotas=${quotas}
    ...                                                                                        sd=${SD_VALUES}

Register 2 UEs to 1st 2nd slice
    Register 1st UE to 1st slice
    Register 2nd UE to 2nd slice

Register 2 UEs to 2nd 3rd slice
    Register 1st UE to 2nd slice
    Register 2nd UE to 3rd slice

Register 3 UEs to 1st 2nd 3rd slice
    Register 1st UE to 1st slice
    Register 2nd UE to 2nd slice
    Register 3rd UE to 3rd slice

Register 3 UEs to 1st 4th 3rd slice
    Register 1st UE to 1st slice
    Register 2nd UE to 4th slice
    Register 3rd UE to 3rd slice

Send Downlink Max Tput To 1st UE
    [Arguments]         ${seconds}
    log  Send Downlink Max Tput To 1st UE
    traffic__.Send Downlink V2 Iperf    duration_tput=${seconds}
    ...                                 dl_tput=${MAX_TPUT}
    ...                                 ue_ip=${UE_IP_DL_1}

Send Downlink Max Tput To 2nd UE
    [Arguments]         ${seconds}
    Log    Send Downlink Max Tput To 2nd UE
    traffic__.Send Downlink V2 Iperf    duration_tput=${seconds}
    ...                                 dl_tput=${MAX_TPUT}
    ...                                 ue_ip=${UE_IP_DL_2}

Send Downlink Max Tput To 3rd UE
    [Arguments]         ${seconds}
    log    Send Downlink Max Tput To 3rd UE
    traffic__.Send Downlink V2 Iperf    duration_tput=${seconds}
    ...                                 dl_tput=${MAX_TPUT}
    ...                                 ue_ip=${UE_IP_DL_3}

Send Downlink Half Of Max Tput To VONR UE
    [Arguments]         ${seconds}
    Log    Send Downlink Half Of Max Tput To VONR UE
    traffic__.Send Downlink V2 Iperf    duration_tput=${seconds}
    ...                                 dl_tput=${MAX_TPUT_HALF}
    ...                                 ue_ip=${UE_IP_DL_4}

Stop Downlink Max Tput For 1st UE
    Log    Stop Downlink Max Tput For 1st UE
    traffic__.Stop Downlink V2 Iperf    i=0

Stop Downlink Max Tput For 2nd UE
    Log    Stop Downlink Max Tput For 2nd UE
    traffic__.Stop Downlink V2 Iperf    i=1

Stop Downlink Max Tput For 3rd UE
    Log    Stop Downlink Max Tput For 3rd UE
    traffic__.Stop Downlink V2 Iperf    i=2

Deregister 1st UE And Release Its PDU Session
    wts__.Release PDU Session           ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_1}
    wts__.Deregister Ue                 ue_id=${UE_ID_1}

Deregister 2 UEs And Release Its PDU Sessions
    Deregister 1st UE And Release Its PDU Session

    wts__.Release PDU Session           ue_id=${UE_ID_2}
    ...                                 pdu_id=${PDU_ID_1}
    wts__.Deregister Ue                 ue_id=${UE_ID_2}

Deregister 3 UEs And Release Its PDU Sessions
    Deregister 2 UEs And Release Its PDU Sessions

    wts__.Release PDU Session           ue_id=${UE_ID_3}
    ...                                 pdu_id=${PDU_ID_1}
    wts__.Deregister Ue                 ue_id=${UE_ID_3}

SYSLOG Start
    Log    SYSLOG Start
    suite__.Start Syslog Capture          output_dir=${OUTPUT_DIR_TC}

SYSLOG Stop
    Log    SYSLOG Stop
    suite__.Stop Syslog Capture

SHERPA Start
    Log    SHERPA Start
    suite__.Start Sherpa Capture        output_dir=${OUTPUT_DIR_TC}

SHERPA Stop
    Log    SHERPA Stop
    suite__.Stop Sherpa Capture         output_dir_csv=${OUTPUT_DIR_TC}

BIP Start
    Run Keyword If   '${UNIT_NAME}'=='ASOE'    bip_asoe__.Start Bip Collection On Ap
    Run Keyword If   '${UNIT_NAME}'=='ASIB'    bip_manag__.Start Collecting Bip        hw_type=${HW_TYPE_ASIB_ABIO}
    Run Keyword If   '${UNIT_NAME}'=='ASIL'    bip_manag__.Start Collecting Bip        hw_type=${HW_TYPE_ASIL_ABIO}

BIP Stop
    Run Keyword If   '${UNIT_NAME}'=='ASOE'    bip_asoe__.Stop Bip Collection On Ap      output_dir_name=${OUTPUT_DIR_TC}
    Run Keyword If   '${UNIT_NAME}'=='ASIB'    suite__.Pkill Tcpdump
    Run Keyword If   '${UNIT_NAME}'=='ASIB'    bip_manag__.Stop Collecting Bip        ${HW_TYPE_ASIB_ABIO}     ${OUTPUT_DIR_TC}
    Run Keyword If   '${UNIT_NAME}'=='ASIL'    suite__.Pkill Tcpdump
    Run Keyword If   '${UNIT_NAME}'=='ASIL'    bip_manag__.Stop Collecting Bip        ${HW_TYPE_ASIL_ABIO}     ${OUTPUT_DIR_TC}

TTI TRACE Start
    Log    TTI TRACE Start
    tti_trace.Start TTI trace collecting        collector_name=${COLLECTOR_NAME}

TTI TRACE Stop
    Log    TTI TRACE Stop
    tti_trace.Stop TTI trace collecting      collector_name=${COLLECTOR_NAME}
    ...                                      target_path=${OUTPUT_DIR_TC}

TTI TRACE Convert
    tti_trace.Convert TTI Trace             format=excelCsv
    ...                                     source_file_path=${OUTPUT_DIR_TC}/tcpdump.pcap
    ...                                     target_path=${OUTPUT_DIR_TC}
    suite__.Change Tti Trace Log Pcap Name              file_path=${OUTPUT_DIR_TC}/tcpdump.pcap

LOGS Start
    TTI TRACE Start
    SYSLOG Start
    BIP Start

SYSCOM Start
    Log    SYSCOM Start
    bip_manag__.Start Syscom Collection                        syscom_file_name=${SYSCOM_FILE_NAME}

SYSCOM Stop
    Log    SYSCOM Stop
    bip_manag__.Stop Syscom Collection                         output_path=${OUTPUT_DIR_TC}
    ...                                                        syscom_file_name=${SYSCOM_FILE_NAME}

LOGS Start Without TTI and BIP
#    BIP Start
    BuiltIn.Sleep   25s
    SYSLOG Start

LOGS Stop Without TTI and BIP
    Log    LOGS Stop Without TTI and BIP
#    BIP Stop
    SYSLOG Stop

LOGS Stop
    TTI TRACE Stop
    BIP Stop
    SYSLOG Stop

LOGS Start Without TTI
    SYSCOM Start
    BuiltIn.Sleep   25s
    SYSLOG Start

LOGS Stop Without TTI
    SYSCOM Stop
    SYSLOG Stop

Teardown Wts And Collect Logs Without GNB Commissioning
    Run Keyword And Ignore Error            TTI TRACE Stop
    Run Keyword And Ignore Error            BIP Stop
    Run Keyword And Ignore Error            SHERPA Stop
    Run Keyword And Ignore Error            SYSLOG Stop
#    suite__.Get AP Snapshot                             output_dir=${OUTPUT_DIR_TC}
    suite__.Get GNB Snapshot                            output_dir=${OUTPUT_DIR_TC}
    Run Keyword And Ignore Error                        wts__.Stop Wts And Clear
#    suite__.Save Swconfigs To Files                     output_dir=${OUTPUT_DIR_TC}
#    suite__.Try To Send Result To Rep Portal            output_dir=${OUTPUT_DIR_TC}

Teardown Wts And Collect Logs CA
    Teardown Wts And Collect Logs Without GNB Commissioning
    gnb__.Perform GNB Commissioning                     scf_file=${BASIC_SCF_FILE_CA}

Teardown Wts And Collect Logs
    Teardown Wts And Collect Logs Without GNB Commissioning
    gnb__.Perform GNB Commissioning                     scf_file=${BASIC_SCF_FILE}

Register 1st UE To Selected Slice And Collect Logs During Downlink Traffic
    [Arguments]     ${nwslice_id}
    ...             ${allow_wts_start}
    ...             ${wts_cfg}
    SYSCOM Start
    SYSLOG Start
    BuiltIn.Sleep   15
    Run Keyword If  '${allow_wts_start}'=='True'     wts__.Start Wts And Wait For Ready State     wts_config_filename=${wts_cfg}
    ...                                                                                           wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                                                           edaemon_port=${EDAEMON_PORT}
    ...                                                                                           egate_port=${EGATE_PORT}
    ...                                                                                           sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    BuiltIn.Sleep   15
    SYSCOM Stop
    SYSLOG Stop

    wts__.attach_ue_and_establish_pdu_session    ue_id=${UE_ID_1}
    ...                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                          enb_id=${GNB_ID}
    ...                                          pdu=${PDU_ID_1}
    ...                                          nwslice=${nwslice_id}
    suite__.Wait For Pdu Session Setup     seconds=10
    wts__.Start Traffic For Multiple Ues    number_of_ues=1
    ...                                     traffic_direction=${TRAFFIC_DIR_DL}
    ...                                     dl_mbps=${MAX_TPUT_VAL}

    suite__.Wait For Tput End State                         seconds=150

Start WTS And Check Proper Quotas
    [Arguments]     ${quotas}
    Log    ${quotas}
    LOGS Start Without TTI
    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    LOGS Stop Without TTI


Attach Ue And Collect Logs During Downlink Traffic
    [Arguments]     ${traffic}
    ...             ${traffic_time_after_logs}
    ...             ${allow_wts_start}
    Log     ${traffic}
    SYSCOM Start

    Run Keyword If  '${allow_wts_start}'=='True'     wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG}
    ...                                                                                           wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                                                           edaemon_port=${EDAEMON_PORT}
    ...                                                                                           egate_port=${EGATE_PORT}
    ...                                                                                           sib_reception_dict=${SIB_RECEPTION_DICT_SA_FDD}
    suite__.Wait Wts Ready State Before X2 Link                         seconds=20
    wts__.Setup X2 Link    initiator_device=${ENB_ID}
    ...                    complementary_device=${GNB_ID}
    ...                    timeout=10
    wts__.Attach Ue And Perform Sgnb Addition                    ue_id=${UE_ID_11}
    ...                                                          bearer=${BEARER_ID_2}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    Run Downlink Throughput NSA 4 times To Achieve Max Tput For 1st UE    ${UE_ID_11}
    ...                                                                   ${MAX_INTERNAL_TPUT}
    ...                                                                   ${BEARER_ID_2}
    suite__.Wait For Tput End State                         seconds=15

    Stop Max Downlink Throughput NSA 4 times For 1st UE    ${UE_ID_11}
    ...                                                    ${BEARER_ID_2}

    SYSCOM Stop

    Run Downlink Throughput NSA 4 times To Achieve Max Tput For 1st UE    ${UE_ID_11}
    ...                                                                   ${MAX_INTERNAL_TPUT}
    ...                                                                   ${BEARER_ID_2}

    suite__.Wait For Tput End State                         seconds=${traffic_time_after_logs}

    Stop Max Downlink Throughput NSA 4 times For 1st UE    ${UE_ID_11}
    ...                                                    ${BEARER_ID_2}

Detach NSA UE
    Log    Detach NSA UE
    wts__.Detach Ue                 ue_id=${UE_ID_1}

Deregister Ue And Release PDU Session
    wts__.Release PDU Session           ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_1}
    wts__.Deregister Ue                 ue_id=${UE_ID_1}

Register 2 UEs to 1st 2nd slice and collect logs during downlink traffic
    [Arguments]     ${validate_ue_tput_stats}
    LOGS Start Without TTI

    Register 2 UEs to 1st 2nd slice

    wts__.Start Traffic For Multiple Ues    number_of_ues=2
    ...                                     traffic_direction=${TRAFFIC_DIR_DL}
    ...                                     dl_mbps=${MAX_TPUT_VAL}

    suite__.Wait For Tput End State     seconds=9

    Run Keyword If      ${validate_ue_tput_stats}=='True'      wts__.Check UE Thput Stats      ues_ids=${UE_ID_1},${UE_ID_2},${UE_ID_3}

    LOGS Stop Without TTI

Register 3 UEs to 1st 2nd 3rd slice and collect logs during downlink traffic
    [Arguments]     ${validate_ue_tput_stats}
    LOGS Start Without TTI

    Register 3 UEs to 1st 2nd 3rd slice

    wts__.Start Traffic For Multiple Ues    number_of_ues=3
    ...                                     traffic_direction=${TRAFFIC_DIR_DL}
    ...                                     dl_mbps=${MAX_TPUT_VAL}

    suite__.Wait For Tput End State     seconds=9

    Run Keyword If      ${validate_ue_tput_stats}=='True'      wts__.Check UE Thput Stats      ues_ids=${UE_ID_1},${UE_ID_2},${UE_ID_3}

    LOGS Stop Without TTI

Register 3 UEs to slice to 1st 4th 3rd slice and collect logs during downlink traffic
    [Arguments]     ${validate_ue_tput_stats}
    LOGS Start Without TTI

    Register 3 UEs to 1st 4th 3rd slice

    Send Downlink Max Tput To 1st UE    seconds=10
    Send Downlink Max Tput To 2nd UE    seconds=10
    Send Downlink Max Tput To 3rd UE    seconds=10

    suite__.Wait For Tput End State     seconds=9

    Run Keyword If      ${validate_ue_tput_stats}=='True'      wts__.Check UE Thput Stats      ues_ids=${UE_ID_1},${UE_ID_2},${UE_ID_3}

    LOGS Stop Without TTI

Ensure Feature Is Activated And Quotas Contain Correct Values In Syslog
    [Arguments]     ${quotas}
    Log    ${quotas}
    syslog__.Ensure Plmn Config List Exist


Ensure Feature Is Activated And Quotas Contain Correct Values In Single NSA Slice
    [Arguments]     ${quotas}
	syslog__.Ensure Plmn Config List Exist
	syslog__.ensure_quotas_contain_correct_values_for_single_NSA_slice           slices=${quotas}

Ensure Feature Is Activated And Quotas Contain Correct Values In Both Slices
    [Arguments]     ${quotas}
    syslog__.Ensure Plmn Config List Exist
    syslog__.ensure_quotas_contain_correct_values_for_2_NSA_slices           slices=${quotas}

Ensure Feature Is Activated And Quotas Contain Correct Values For 3PLMN
    [Arguments]     ${quotas}
    ...             ${resourceGroup_dn_list}
    ...             ${plmn_list}
    ...             ${valid_hardcoded_quota}
    ...             ${hardcoded_quota}
    syslog__.Ensure Slice Aware Scheduler Is Activated
    syslog__.Ensure Plmn Config List Exist
    syslog__.ensure_quotas_contain_correct_values_for_all_slices           slices=${quotas}
    ...                                                                    resourceGroup_dn_list=${resourceGroup_dn_list}
    ...                                                                    plmn_list=${plmn_list}
    ...                                                                    valid_hardcoded_quota=${valid_hardcoded_quota}
    ...                                                                    hardcoded_quota=${hardcoded_quota}

Ensure Bip Contain Proper CellSetupReq And Validate Quotas with Sd Values
    [Arguments]     ${quotas}
    ...             ${sd}
    bip__.Save Filtered Pcap To Txt File            output_dir=${OUTPUT_DIR_TC}
    ...                                             prefix=${BIP_MSG_CELLSETUPREQ}
    ...                                             using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...                                             filter=${BIP_FILTER_CELLSETUPREQ}
    ...                                             syscom=${IS_SYSCOM}
    bip__.Ensure Decoded Txt File Exists
    bip__.Ensure Cell Ids Consists Of The Same Cellgrp Ids      cell=${CELL_ID_VALIDATION_LIST_TO_GRP_IDS}
    bip__.Ensure Slice Aware Scheduler Is Activated
    bip__.Ensure Quotas Contain Correct Values      expected_quotas=${quotas}
    ...                                             slice_list_id=0
    bip__.Ensure Quotas Contain Correct Values      expected_quotas=${quotas}
    ...                                             slice_list_id=1
    bip__.Ensure Sd Has Values As In Scf      expected_sd=${sd}
    ...                                       slice_list_id=0
    bip__.Ensure Sd Has Values As In Scf      expected_sd=${sd}
    ...                                       slice_list_id=1

Ensure Bip Contain Proper CellSetupReq And Validate Only One Quota with Sd Values
    [Arguments]     ${quotas}
    ...             ${sd}
    bip__.Save Filtered Pcap To Txt File            output_dir=${OUTPUT_DIR_TC}
    ...                                             prefix=${BIP_MSG_CELLSETUPREQ}
    ...                                             using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...                                             filter=${BIP_FILTER_CELLSETUPREQ}
    ...                                             syscom=${IS_SYSCOM}
    bip__.Ensure Decoded Txt File Exists
    bip__.Ensure Slice Aware Scheduler Is Activated
    bip__.Ensure Sd Has Values As In Scf      expected_sd=${sd}
    ...                                       slice_list_id=0
    bip__.Ensure Quotas Contain Correct Values      expected_quotas=${quotas}
    ...                                             slice_list_id=0
    ...                                             is_nsa=${True}

Add Default Quota To NSA
    [Arguments]     ${quotas}
    ...             ${name}
    Log    ${name}&${quotas}
     suite__.create_default_value_quotas             quotas=${quotas}
    ...                                              name=${name}

Ensure Bip Contain Proper CellReconfigurationReq And Validate Quotas With Sd Values
    [Arguments]     ${quotas}
    ...             ${sd}
    Log     Not used? ${quotas}&${sd}
    bip__.Save Filtered Pcap To Txt File            output_dir=${OUTPUT_DIR_TC}
    ...                                             prefix=${BIP_MSG_CELLRECONFREQ}
    ...                                             using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...                                             filter=${BIP_FILTER_CELLRECONFREQ}
    ...                                             syscom=${IS_SYSCOM}
    bip__.Ensure Decoded Txt File Exists

Ensure Counters Contain Proper Values
    [Arguments]     ${actual_tput}
    ...             ${nwslice_id}
    ...             ${quotas}
    ...             ${mcc}
    ...             ${mnc}
    counters__.Set All Counter Variables                        output_dir=${OUTPUT_DIR_TC}
    counters__.Ensure Max Utilization Ratio For Prbs Per Slice Is Correct          slice_list=1
    ...                                                                            used_slice_list=${nwslice_id}
    ...                                                                            quotas=${quotas}
    ...                                                                            mnc=${mnc}
    ...                                                                            mcc=${mcc}
    counters__.Ensure Dl Pdcp Per Slice Are Correct             expected_tput=${actual_tput}
    ...                                                         slice_list=1
    ...                                                         used_slice_list=${nwslice_id}

Ensure VONR Counters Contain Proper Values At Stage
    [Arguments]     ${ue_id}
    ...             ${vonr_plmn_list}
    counters__.Set All Counter Variables                        output_dir=${OUTPUT_DIR_TC}
    counters__.Ensure Max Utilization Ratio For Prbs Per Slice With Ue Is Correct       ue_id=${ue_id}
    ...                                                                                 quotas=${QUOTAS_EXPECTED_B_VONR}
    ...                                                                                 plmn_list=${vonr_plmn_list}

Ensure NSA VONR Counters Contain Proper Values At Stage
    [Arguments]     ${ue_id}
    ...             ${vonr_plmn_list}
    counters__.Set All Counter Variables                        output_dir=${OUTPUT_DIR_TC}
    counters__.Ensure Max Utilization Ratio For Prbs Per Slice With Ue Is Correct       ue_id=${ue_id}
    ...                                                                                 quotas=${QUOTAS_EXPECTED_C_VONR}
    ...                                                                                 plmn_list=${vonr_plmn_list}

Ensure NSA Dl Prb Share Counters Contain Proper Values
    [Arguments]     ${ue_id}
    ...             ${quotas}
    ...             ${skip_sa_std}
    counters__.Set All Counter Variables                        output_dir=${OUTPUT_DIR_TC}
    ...                                                         skip_sa_std=${skip_sa_std}
    counters__.Ensure Max Utilization Ratio For Prbs Per Slice With Ue Is Correct       ue_id=${ue_id}
    ...                                                                                 quotas=${quotas}
    ...                                                                                 plmn_list=${DL_PRB_SHARE_PLMN_LIST}

Ensure CA Counters Contain Proper Values At Stage
    [Arguments]     ${ue_ids}
    ...             ${quotas}
    ...             ${plmn_list}
    counters__.Set All Counter Variables                        outputdir=${OUTPUT_DIR_TC}
    counters__.Ensure DL Pdcp Per Slice With Ue Are Correct     ue_ids=${ue_ids}
    ...                                                         quotas=${quotas}
    ...                                                         plmn_list=${plmn_list}

Ensure NSA Counters Contain Proper Values At Stage
    [Arguments]    ${actual_tput}
    ...            ${nrresourcegroup_id}
    ...            ${quotas}
    ...            ${skip_sa_std}
    counters__.Set All Counter Variables                            output_dir=${OUTPUT_DIR_TC}
    ...                                                             skip_sa_std=${skip_sa_std}
    counters__.Ensure Prbs Availability Per Plmn NSA                used_resource_group=${nrresourcegroup_id}
    counters__.Ensure Prbs Allocation Per Plmn NSA                  used_resource_group=${nrresourcegroup_id}
    counters__.Ensure DL Pdcp Per Resource Group Are Correct NSA    expected_tput=${actual_tput}
    ...                                                             used_resource_group=${nrresourcegroup_id}
    ...                                                             quotas=${quotas}

Ensure NSA CA 3PLMN 3UE Counters Contain Proper Values At Stage
    [Arguments]     ${ue_ids}
    ...             ${quotas}
    ...             ${mcc_mnc_list}
    ...             ${pdcp_validation_dictionary}
    ...             ${validation_step}
    ...             ${succes_admission_validation_dictionary}
    ...             ${additional_counters}

    counters__.Set All Counter Variables                        outputdir=${OUTPUT_DIR_TC}
    ...                                                         create_directory=${TRUE}
    ...                                                         additional_counters=${additional_counters}
    counters__.Ensure DL Pdcp Per Slice With Ue Are Correct 3PLMN 3UE       ue_ids=${ue_ids}
    ...                                                                     quotas=${quotas}
    ...                                                                     mcc_mnc_list=${mcc_mnc_list}
    ...                                                                     validation_dictionary=${pdcp_validation_dictionary}
    ...                                                                     validation_step=${validation_step}

    counters__.Ensure Successful Radio Admissions Are Correct By Dictionary     validation_dictionary=${succes_admission_validation_dictionary}
    ...                                                                         validation_step=${validation_step}


Ensure NSA CA 1PLMN 3UE Counters Contain Proper Values At Stage
    [Arguments]     ${ue_ids}
    ...             ${quotas}
    ...             ${mcc_mnc_list}
    ...             ${pdcp_validation_dictionary}
    ...             ${validation_step}
    ...             ${succes_admission_validation_dictionary}
    ...             ${additional_counters}

    Log    ${succes_admission_validation_dictionary}
    counters__.Set All Counter Variables                        outputdir=${OUTPUT_DIR_TC}
    ...                                                         create_directory=${TRUE}
    ...                                                         additional_counters=${additional_counters}
    counters__.Ensure DL Pdcp Per Slice With Ue Are Correct 1PLMN 3UE       ue_ids=${ue_ids}
    ...                                                                     quotas=${quotas}
    ...                                                                     mcc_mnc_list=${mcc_mnc_list}
    ...                                                                     validation_dictionary=${pdcp_validation_dictionary}
    ...                                                                     validation_step=${validation_step}



Start Wts And Ensure Feature Is Activated
    [Arguments]     ${quotas}
    common.LOGS Start Without TTI
    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    common.LOGS Stop Without TTI
    common.Ensure Feature Is Activated And Quotas Contain Correct Values In Both Slices          quotas=${quotas}

Reconfigure Quotas And Run Traffic
    util__.stop_traffic_one_ue
    ...         ue_id=11
    ...         tput=150
    ...         bearer=2
    ...         net_arch='nsa'
    util__.stop_traffic_one_ue
    ...         ue_id=12
    ...         tput=300
    ...         bearer=3
    ...         net_arch='nsa'
    util__.stop_traffic_one_ue
    ...         ue_id=13
    ...         tput=450
    ...         bearer=4
    ...         net_arch='nsa'
    util__.stop_traffic_one_ue
    ...         ue_id=14
    ...         tput=230
    ...         bearer=5
    ...         net_arch='nsa'
    util__.stop_traffic_one_ue
    ...         ue_id=15
    ...         tput=80
    ...         bearer=6
    ...         net_arch='nsa'
    util__.stop_traffic_one_ue
    ...         ue_id=16
    ...         tput=300
    ...         bearer=7
    ...         net_arch='nsa'

    Reconfigure 6 Quotas And Validate Them                             quotas=${QUOTAS_EXPECTED_C_B301_RECONF}

    util__.run_full_internal_traffic    ue_id=11
    ...                                 bearer=2
    ...                                 mbps=120
    ...                                 net_arch='nsa'

    util__.run_full_internal_traffic    ue_id=12
    ...                                 bearer=3
    ...                                 mbps=210
    ...                                 net_arch='nsa'

    util__.run_full_internal_traffic    ue_id=13
    ...                                 bearer=4
    ...                                 mbps=240
    ...                                 net_arch='nsa'

    util__.run_full_internal_traffic    ue_id=14
    ...                                 bearer=5
    ...                                 mbps=400
    ...                                 net_arch='nsa'

    util__.run_full_internal_traffic    ue_id=15
    ...                                 bearer=6
    ...                                 mbps=270
    ...                                 net_arch='nsa'

    util__.run_full_internal_traffic    ue_id=16
    ...                                 bearer=7
    ...                                 mbps=360
    ...                                 net_arch='nsa'

    BuiltIn.Sleep    10m     Wait for pm counter to change after the traffic starts

Attach 3 NSA UE Run Traffic And Collect Logs FDD
    LOGS Start Without TTI and BIP
    wts__.setup_x2_link
    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=${UE_ID_11}
    ...                                                          bearer=${BEARER_ID_2}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_DEFAULT}
    ...                                                          serving_plmn=${UE_PLMN_DEFAULT}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput
    ...     ue_id=${UE_ID_11}
    ...     mbps=175
    ...     bearer_id=${BEARER_ID_2}

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=${UE_ID_12}
    ...                                                          bearer=${BEARER_ID_3}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_312_490}
    ...                                                          serving_plmn=${UE_PLMN_312_490}
    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=${UE_ID_13}
    ...                                                          bearer=${BEARER_ID_4}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_313_491}
    ...                                                          serving_plmn=${UE_PLMN_313_491}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput
    ...     ue_id=${UE_ID_12}
    ...     mbps=175
    ...     bearer_id=${BEARER_ID_3}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput
    ...     ue_id=${UE_ID_13}
    ...     mbps=175
    ...     bearer_id=${BEARER_ID_4}

    BuiltIn.Sleep    10m     Wait for pm counter to change after the traffic starts

    wts__.check_uec_stats
    wts__.check_bearer_stats       bearer_id=${BEARER_ID_2}
    ...                            ue_id=${UE_ID_11}

    LOGS Stop Without TTI and BIP

Attach 6 NSA UE Run Traffic And Collect Logs
    LOGS Start Without TTI and BIP
    wts__.setup_x2_link
    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=11
    ...                                                          bearer=2
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_DEFAULT}
    ...                                                          serving_plmn=${UE_PLMN_DEFAULT}

    util__.run_full_internal_traffic    ue_id=11
    ...                                 bearer=2
    ...                                 mbps=150
    ...                                 net_arch='nsa'

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=12
    ...                                                          bearer=3
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_312_490}
    ...                                                          serving_plmn=${UE_PLMN_312_490}
    util__.run_full_internal_traffic    ue_id=12
    ...                                 bearer=3
    ...                                 mbps=300
    ...                                 net_arch='nsa'

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=13
    ...                                                          bearer=4
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_313_491}
    ...                                                          serving_plmn=${UE_PLMN_313_491}
    util__.run_full_internal_traffic    ue_id=13
    ...                                 bearer=4
    ...                                 mbps=450
    ...                                 net_arch='nsa'

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=14
    ...                                                          bearer=5
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_314_492}
    ...                                                          serving_plmn=${UE_PLMN_314_492}
    util__.run_full_internal_traffic    ue_id=14
    ...                                 bearer=5
    ...                                 mbps=230
    ...                                 net_arch='nsa'

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=15
    ...                                                          bearer=6
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_315_493}
    ...                                                          serving_plmn=${UE_PLMN_315_493}
    util__.run_full_internal_traffic    ue_id=15
    ...                                 bearer=6
    ...                                 mbps=80
    ...                                 net_arch='nsa'

    wts__.attach_ue_to_plmn_and_perform_sgnb_addition            ue_id=16
    ...                                                          bearer=7
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    ...                                                          selected_plmn=${UE_PLMN_316_494}
    ...                                                          serving_plmn=${UE_PLMN_316_494}
    util__.run_full_internal_traffic    ue_id=16
    ...                                 bearer=7
    ...                                 mbps=300
    ...                                 net_arch='nsa'

    BuiltIn.Sleep    10m     Wait for pm counter to change after the traffic starts

    LOGS Stop Without TTI and BIP

Run Downlink Throutghput 3 UE NSA FDD
    LOGS Start Without TTI and BIP
    Run Downlink Throughput NSA    ue_id=${UE_ID_11}
    ...                            mbps=175
    ...                            bearer_id=${BEARER_ID_2}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${UE_ID_12}
    ...                            mbps=175
    ...                            bearer_id=${BEARER_ID_3}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${UE_ID_13}
    ...                            mbps=175
    ...                            bearer_id=${BEARER_ID_4}
    ...                            traffic_id=${TRAFFIC_ID_1}

    BuiltIn.Sleep    10m     Wait for pm counter to change after the traffic starts

    LOGS Stop Without TTI and BIP

Run Downlink Throutghput 3 UE NSA
    LOGS Start Without TTI and BIP
    Run Downlink Throughput NSA 9 times To Achieve Max Tput                              ue_id=${UE_ID_11}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_2}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput                              ue_id=${UE_ID_12}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_3}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput                              ue_id=${UE_ID_13}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_4}

    BuiltIn.Sleep    3m     Wait for pm counter to change after the traffic starts

    LOGS Stop Without TTI and BIP

Run Downlink Throughput NSA
    [Arguments]    ${ue_id}
    ...            ${mbps}
    ...            ${bearer_id}
    ...            ${traffic_id}
    Log    Run Downlink Throughput NSA
    wts__.Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                  direction=dl
    ...                                  mbps=${mbps}
    ...                                  bearer=${bearer_id}
    ...                                  trf_id=${traffic_id}
    ...                                  net_arch=nsa

Stop Downlink Throughput NSA
    [Arguments]    ${ue_id}
    ...            ${traffic_id}
    ...            ${bearer_id}
    Log    Stop Downlink Throughput NSA
    wts__.Stop Data Traffic In Egate    ue_id=${ue_id}
    ...                                 direction=dl
    ...                                 trf_id=${traffic_id}
    ...                                 net_arch=nsa
    ...                                 bearer=${bearer_id}

Deregister 1 NSA UE And Stop Traffic
    Stop Downlink Throughput NSA        ue_id=${UE_ID_11}
    ...                                 bearer_id=${BEARER_ID_2}
    ...                                 traffic_id=${TRAFFIC_ID_1}
    wts__.ue_detach                     ue_id=${UE_ID_11}

Run Downlink Throughput NSA 3 times To Achieve Max Tput For 1st UE
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_2}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_3}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_4}

Run Downlink Throughput NSA 5 times To Achieve Max Tput For 1st UE
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_2}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_3}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_4}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_5}

Run Downlink Throughput NSA 9 times To Achieve Max Tput
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_2}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_3}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_4}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_5}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_6}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_7}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_8}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_9}

Run Downlink Throughput SA Max
        [Arguments]     ${ue_id}
        ...             ${pdu_id}
        ...             ${qfi}
        ...             ${mbps}
        wts__.start_data_traffic_in_egate
        ...    ue_id=${ue_id}
        ...    pdu=${pdu_id}
        ...    trf_id=1
        ...    direction=dl
        ...    mbps=${mbps}
        ...    qfi=${qfi}
        wts__.start_data_traffic_in_egate
        ...    ue_id=${ue_id}
        ...    pdu=${pdu_id}
        ...    trf_id=2
        ...    direction=dl
        ...    mbps=50
        ...    qfi=${qfi}

Run Downlink Throughput NSA 3 times To Achieve Max Tput For 2nd UE
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_4}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_5}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_6}

Run Downlink Throughput NSA 3 times To Achieve Max Tput For 3rd UE
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_7}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_8}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_9}

Run Downlink Throughput NSA 4 times To Achieve Max Tput For 1st UE
    [Arguments]     ${ue_id}
    ...             ${mbps}
    ...             ${bearer_id}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_1}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_2}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_3}
    Run Downlink Throughput NSA    ue_id=${ue_id}
    ...                            mbps=${mbps}
    ...                            bearer_id=${bearer_id}
    ...                            traffic_id=${TRAFFIC_ID_4}

Stop Max Downlink Throughput NSA 4 times For 1st UE
    [Arguments]    ${ue_id}
    ...            ${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_1}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_2}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_3}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_4}
    ...                             bearer_id=${bearer_id}

Stop Max Downlink Throughput NSA 9 times For 1st UE
    [Arguments]    ${ue_id}
    ...            ${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_1}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_2}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_3}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_4}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_5}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_6}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_7}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_8}
    ...                             bearer_id=${bearer_id}
    Stop Downlink Throughput NSA    ue_id=${ue_id}
    ...                             traffic_id=${TRAFFIC_ID_9}
    ...                             bearer_id=${bearer_id}

Register 3 NSA UEs And Run Max Tput For Every Of Them
    wts__.Attach Ue And Perform Sgnb Addition                    ue_id=${UE_ID_11}
    ...                                                          bearer=${BEARER_ID_2}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    Run Downlink Throughput NSA 3 times To Achieve Max Tput For 1st UE                   ue_id=${UE_ID_11}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_2}

    wts__.Attach Ue And Perform Sgnb Addition                    ue_id=${UE_ID_12}
    ...                                                          bearer=${BEARER_ID_3}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    Run Downlink Throughput NSA 3 times To Achieve Max Tput For 2nd UE                   ue_id=${UE_ID_12}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_3}

    wts__.Attach Ue And Perform Sgnb Addition                    ue_id=${UE_ID_13}
    ...                                                          bearer=${BEARER_ID_4}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    Run Downlink Throughput NSA 3 times To Achieve Max Tput For 2nd UE                   ue_id=${UE_ID_13}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_4}

Register 1 NSA 2 SA UEs And Run Max Tput For Every Of Them
    wts__.Attach Ue And Perform Sgnb Addition                    ue_id=${UE_ID_11}
    ...                                                          bearer=${BEARER_ID_2}
    ...                                                          cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                                          enb_id=${GNB_ID}
    Run Downlink Throughput NSA 9 times To Achieve Max Tput                              ue_id=${UE_ID_11}
    ...                                                                                  mbps=175
    ...                                                                                  bearer_id=${BEARER_ID_2}

    Register 2 UEs to 1st 2nd slice
    Send Downlink Max Tput To 1st UE        seconds=1200
    Send Downlink Max Tput To 2nd UE        seconds=1200
