*** Settings ***
Documentation
...   author: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009059

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library     Collections
Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/test_specific_keywords_9059.py
Library     taf.sbts.oam.coam.admin                                                 WITH NAME  coam
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils  WITH NAME  AdminUtils
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                        WITH NAME  GnbCounter
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/pm_counter_collector.py              WITH NAME  pm


*** Variables ***
${MRBTS_5G_ID}        ${tl.gnbs[0].instance_id}
${MRBTS_5G}           MRBTS-${MRBTS_5G_ID}
${SYSLOG_ALIAS}       syslog_9059
${SCF_PATH}           ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources
${IMSI}               310260560002719
&{SCELL_REQ_MAPPING}  ${55200}=904396803
&{SCELL_RES_MAPPING}  ${55200}=263
&{SCELL2_REQ_MAPPING}  ${55200}=904396802
&{SCELL2_RES_MAPPING}  ${55200}=262
&{5QI_PORT_MAPPING}   5qi6=5006  5qi7=5007  5qi8=5008  5qi9=8021
&{5QI_USAGE_COUNT}    5qi6=${0}   5qi7=${0}  5qi8=${0}  5qi9=${0}
${PCELL_ID}           3
${PCELL_ID_BE2}       4
${SCELL_ID}           2
${SCELL_ID_BE2}           3
@{BTS_COUNTERS}       M55326C02006  M55326C02007  M55326C02008  M55326C02009
${IP_CAPTURE_FILE}    ${OUTPUT DIR}/ip_capture.pcap
${IP_CAPTURE_ALIAS}   ip_capture
${switcher}           Cell4


*** Keywords ***
Perform gNB commissioning with 9059 basic SCF
    [Arguments]  ${connection_alias}=gnb_connection  ${fetch_release_alias}=fetch_release
    Log to console  Performing gNB commissioning with 9059 SCF
    coam.connect to  name=${fetch_release_alias}
    ${release}       Wait Until Keyword Succeeds  5 min  1 min  Get Software release name  ${fetch_release_alias}
    coam.teardown    connection=${fetch_release_alias}
    Connect with runtime release  ${connection_alias}
    coam.perform commissioning    ${MRBTS_5G_ID}  ${SCF_PATH}/CB009059_${MRBTS_5G_ID}_${release}.xml  ${True}  ${True}
    ...                           600  ${connection_alias}
    AdminUtils.wait_for_all_cells_on_air_state
    coam.teardown   ${connection_alias}


Activate feature
    log to console  Activating feature 9059
    activate_feature_9059   ${MRBTS_5G_ID}


Activate feature BE2
    log to console  Activating feature 9059
    activate_feature_9059   ${MRBTS_5G_ID}      ${switcher}


Setup actBufferBasedSCellAddition
    [Arguments]      ${actBufferBasedSCellAddition}=disabled
    log to console   Setup actBufferBasedSCellAddition
    set_act_buffer_based_scell_addition  ${actBufferBasedSCellAddition}


Setup CellAggrLevel
    [Arguments]                 ${drb_to_change}
    log to console              Setup CellAggrLevel
    setup_cell_aggr_level_9059  ${MRBTS_5G_ID}  ${drb_to_change}


Setup RlcMode
    [Arguments]                 ${drb_to_change}
    log to console              Setup rlcMode
    setup_rlc_mode_9059         ${MRBTS_5G_ID}  ${drb_to_change}


Reset DRBs to default
    log to console  Reset DRBs to default
    ${default}   Set Variable       FR1 CA eligible
    ${drb_dict}  Create Dictionary  NRDRB-1=${default}   NRDRB-2=${default}   NRDRB-3=${default}
    ...                             NRDRB-4=${default}   NRDRB-5=${default}   NRDRB-6=${default}
    ...                             NRDRB-7=${default}   NRDRB-8=${default}   NRDRB-9=${default}
    ...                             NRDRB-10=${default}  NRDRB-11=${default}  NRDRB-12=${default}
    ...                             NRDRB-13=${default}  NRDRB-14=${default}  NRDRB-15=Not FR1 CA eligible
    setup_cell_aggr_level_9059      ${MRBTS_5G_ID}   ${drb_dict}
    ${default}   Set Variable       RLC_AM
    ${drb_dict}  Create Dictionary  NRDRB-1=${default}   NRDRB-2=${default}   NRDRB-3=${default}
    ...                             NRDRB-4=${default}   NRDRB-5=${default}   NRDRB-6=${default}
    ...                             NRDRB-7=${default}   NRDRB-8=${default}   NRDRB-9=${default}
    ...                             NRDRB-10=${default}  NRDRB-11=${default}  NRDRB-12=${default}
    ...                             NRDRB-13=${default}  NRDRB-14=${default}  NRDRB-15=RLC_UM
    setup_rlc_mode_9059             ${MRBTS_5G_ID}   ${drb_dict}


Start log collection
    log to console  Start BTSlog and cplane collection
    Start syslog capture    log_name=${SYSLOG_ALIAS}.LOG  alias=${SYSLOG_ALIAS}
    Setup cplane tcpdump collector
    Start cplane Logs


Stop log collection
    log to console  Stop BTSlog and cplane collection
    Stop syslog capture    alias=${SYSLOG_ALIAS}
    Stop cplane logs


Start IP Traffic Capturing
    log to console            Start IP Traffic Capturing
    Connect with runtime release     ${IP_CAPTURE_ALIAS}
    coam.start_ip_capture_file  measurement_point=NE_Terminated  uplane_capturing=${False}  connection=${IP_CAPTURE_ALIAS}


Stop IP Traffic Capturing
    log to console            Stop IP Traffic Capturing
    coam.stop_ip_capture_file      connection=${IP_CAPTURE_ALIAS}
    coam.generate_ip_capture_file  connection=${IP_CAPTURE_ALIAS}
    coam.download_ip_capture_file  connection=${IP_CAPTURE_ALIAS}  target_file_name=${IP_CAPTURE_FILE}
    coam.teardown             ${IP_CAPTURE_ALIAS}


Add custom data to PCF
    [Arguments]     ${pcf_key}  ${pcf_value}
    log to console  Add custom data to PCF
    update_custom_data_in_pcf  ${IMSI}  ${pcf_key}  ${pcf_value}


Fetch UE IP Address
    [Arguments]     ${adb_hash}
    log to console  Fetch UE IP Address
    ${ue_ip}        fetch_ue_ip  ${adb_hash}
    [Return]        ${ue_ip}


Perform custom call
    [Arguments]     ${ue_ip}
    log to console  Perform custom call
    trigger_iperf_tput_on_app_server  ${ue_ip}


Create init list of dts for tc
    ${all_dt_used_in_tc}    Create List
    Set Test Variable  ${all_dt_used_in_tc}


Start Data Transfer Wrapper
    [Arguments]          ${5qis}
    ...                  ${tput_duration}
    ...                  ${tput_DL_bandwidth}
    ...                  ${protocol}=udp
    ...                  ${ue_alias}=${UE_ALIAS}
    ...                  ${packet_size}=1400
    update_5qi_usage_count  ${5QI_USAGE_COUNT}  ${5qis}
    Start Data Transfer  dt_name=${5qis}_${5QI_USAGE_COUNT}[${5qis}]  ue_alias=${UE_ALIAS}  direction=dl
    ...                  duration=${tput_duration}  throughput=${tput_DL_bandwidth}  protocol=${protocol}
    ...                  packet_size=${packet_size}  port=${5QI_PORT_MAPPING}[${5qis}]
    Append To List       ${all_dt_used_in_tc}  ${5qis}_${5QI_USAGE_COUNT}[${5qis}]
    BuiltIn.Sleep       40s

Stop All Existing Data Transfers
    FOR  ${dt_name}  IN  @{all_dt_used_in_tc}
      Stop Data Transfer  ${dt_name}
    END


Stop All Data Transfers
    log to console  Stop all data transfers
    Run keyword if  ${all_dt_used_in_tc}  Stop All Existing Data Transfers


Perform call on specific 5qis
    [Arguments]          ${5qis_list}  ${tput_duration}=40s  ${tput_DL_bandwidth}=300 Mbits/sec
    log to console       Perform call on following 5qis: ${5qis_list}
    FOR  ${5qis}  IN  @{5qis_list}
        Start Data Transfer Wrapper  ${5qis}  ${tput_duration}  ${tput_DL_bandwidth}
    END


Start VoNR call
    [Arguments]                ${duration}=30s
    log to console             Start voice call
    taf.ue.Start Voice Call    vc_alias=${VC_ALIAS}  ue_alias=${UE_ALIAS}  to=${VONR_NUMBER}  duration=${duration}


Stop VoNR call
    [Arguments]                ${vc_alias}=${VC_ALIAS}
    log to console             Stop voice call
    taf.ue.Stop Voice call     vc_alias=${VC_ALIAS}


Verify logs A1
    [Arguments]         ${syslog_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${SYSLOG_ALIAS}.LOG
    ...                 ${cplane_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    Log to console      Verifying A1 logs

    ${output}  Run      grep "Dl.*Eligible.*sumQciWeight.*qosId" ${syslog_path}
    should contain      ${output}   dlCaEligible=1 ulCaEligible=1 sumQciWeight=1 qosId=9
    should contain      ${output}   dlCaEligible=1 ulCaEligible=1 sumQciWeight=2 qosId=7
    should contain      ${output}   dlCaEligible=0 ulCaEligible=1 sumQciWeight=3 qosId=8

    check_req_scell_id  ${cplane_path}  ${SCELL_REQ_MAPPING}[${MRBTS_5G_ID}]    ${SCELL2_REQ_MAPPING}[${MRBTS_5G_ID}]
    check_res_scell_id  ${cplane_path}  ${SCELL_RES_MAPPING}[${MRBTS_5G_ID}]    ${SCELL2_RES_MAPPING}[${MRBTS_5G_ID}]


Verify logs A3
    [Arguments]  ${path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    Log to console  Verifying A3 logs
    check_qos_flow_identifier  ${path}


Verify logs BA9
    [Arguments]          ${syslog_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${SYSLOG_ALIAS}.LOG
    ...                  ${criterion}=${True}
    Log to console       Verifying BA9 logs
    ${found_grep}   Run  grep -i "BufferMonitoringNotification" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "BufferCriterionInd" ${syslog_path}
    Run keyword if       ${criterion}
    ...                  Should Not Be Empty  ${found_grep}
    ...                  ELSE
    ...                  Should Be Empty  ${found_grep}


Verify logs C2
    [Arguments]          ${syslog_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${SYSLOG_ALIAS}.LOG
    Log to console       Verify logs C2
    ${found_grep}   Run  grep -i "BufferMonitoringNotification" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "BufferCriterionInd" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "rlcMode:RLCMODE_AM isFlowControlActive:1" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "rlcMode:RLCMODE_UM isFlowControlActive:1" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "rlcMode:RLCMODE_AM isFlowControlActive:0" ${syslog_path}
    Should Be Empty      ${found_grep}
    ${found_grep}   Run  grep -i "rlcMode:RLCMODE_UM isFlowControlActive:0" ${syslog_path}
    Should Be Empty      ${found_grep}


Verify logs F2
    [Arguments]           ${path}=${IP_CAPTURE_FILE}
    Log to console        Verifying F2 logs
    check_nsetapx_report  ${path}  ${SCELL_REQ_MAPPING}[${MRBTS_5G_ID}]
    log to console    Verify counters F2
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}  M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}


Verify logs BC4
    [Arguments]          ${syslog_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${SYSLOG_ALIAS}.LOG
    Log to console       Verifying BC4 logs
    ${found_grep}   Run  grep -i "BufferMonitoringNotification" ${syslog_path}
    Should Not Be Empty  ${found_grep}
    ${found_grep}   Run  grep -i "BufferCriterionInd" ${syslog_path}
    Should Not Be Empty  ${found_grep}


Wait for next counter interval
    log to console       Wait for next counter interval
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL}


Verify counters A1 part 1
    log to console    Verify counters A1 part 1
    ${counters_dict}  pm.get_counters  M55326C02007,M55326C02008,M55326C02009,M55308C26001,M55125C00039
    ${gt_zero}  Create List  M55326C02007  M55326C02009  M55308C26001_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ...                      M55125C00039_${PCELL_ID}
    ${eq_zero}  Create List  M55326C02008
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq


Verify counters A1 part 2
    log to console    Verify counters A1 part 2
    ${counters_dict}  pm.get_counters  M55326C02007,M55326C02008,M55326C02009,M55308C26001,M55125C00039
    ${gt_zero}  Create List  M55326C02008  M55308C26001_${PCELL_ID}
    ${eq_zero}  Create List  M55308C26001_${SCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq


Verify counters A3
    log to console    Verify counters A3
    ${counters_dict}  pm.get_counters  M55326C02006,M55326C02008,M55326C02009,M55308C26001,M55125C00039,M55125C00040
    ${gt_zero}  Create List  M55326C02006  M55326C02008  M55326C02009  M55125C00040_${PCELL_ID}
    ...                      M55308C26001_${PCELL_ID}
    ${eq_zero}  Create List  M55125C00039_${PCELL_ID}  M55308C26001_${SCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq


Verify counters A8
    log to console    Verify counters A8
    ${counters_dict}  pm.get_counters  M55326C02006,M55326C02009,M55308C26001,M55125C00039
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02006  M55326C02009  M55308C26001_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ...                      M55125C00039_${PCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}  M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}

Verify counters AB3
    log to console    Verify counters AB3
    ${counters_dict}  pm.get_counters  M55118C00036,M55118C00037,M55125C00039,M55118C07003,M55118C07004
    ${gt_zero}    Create List  M55125C00039_${PCELL_ID}
    ${eq_scells}  Create List  M55118C00036_${PCELL_ID}  M55118C00037_${PCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}  M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}    ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_scells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${2}
    verify_counters  ${counters_dict}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}


Verify counters AC4
    log to console    Verify counters AC4
    ${counters_dict}  pm.get_counters  M55326C02006,M55326C02008,M55326C02009,M55308C26001
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02006  M55326C02008  M55326C02009  M55308C26001_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}   M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}


Verify counters BA9 part 1
    log to console    Verify counters BA9 part 1
    ${counters_dict}  pm.get_counters  M55125C00039,M55125C00040,M55308C26001,M55326C02008,M55326C02009
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02009  M55125C00039_${PCELL_ID}  M55308C26001_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ${eq_zero}  Create List  M55326C02008  M55125C00040_${PCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}   M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}


Verify counters BA9 part 2
    log to console    Verify counters BA9 part 2
    ${counters_dict}  pm.get_counters  M55125C00039,M55125C00040,M55308C26001,M55326C02008,M55326C02009
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02008  M55125C00039_${PCELL_ID}  M55308C26001_${PCELL_ID}
    ${eq_zero}  Create List  M55326C02009  M55125C00040_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}   M55118C07004_${PCELL_ID}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${0}


Verify counters BE2 part 1
    log to console    Verify counters BE2 part 1
    ${counters_dict}  pm.get_counters  M55125C00039,M55125C00040,M55308C26001,M55326C02008,M55326C02009
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02009  M55125C00039_${PCELL_ID_BE2}  M55308C26001_${PCELL_ID_BE2}
    ...                      M55308C26001_${SCELL_ID_BE2}
    ${eq_zero}  Create List  M55326C02008  M55125C00040_${PCELL_ID_BE2}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID_BE2}   M55118C07004_${PCELL_ID_BE2}
    verify_counters  ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  gt
    verify_counters  ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  eq
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  gt


Verify counters BE2 part 2
    log to console    Verify counters BE2 part 2
    ${counters_dict}  pm.get_counters   M55125C00040
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${eq_one}   Create List   M55125C00040_${PCELL_ID_BE2}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID_BE2}   M55118C07004_${PCELL_ID_BE2}
    verify_counters   ${counters_dict}  ${eq_one}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  eq  ${1}
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  gt


Verify counters BE2 part 3
    log to console    Verify counters BE2 part 3
    ${counters_dict}  pm.get_counters   M55125C00039
    ${eq_one}   Create List   M55125C00039_${PCELL_ID_BE2}
    verify_counters   ${counters_dict}  ${eq_one}  ${MRBTS_5G_ID}  ${PCELL_ID_BE2}  ${SCELL_ID_BE2}  eq  ${1}


Verify counters C2 part 1
    log to console    Verify counters C2 part 1
    ${counters_dict}  pm.get_counters  M55308C26001,M55326C02008,M55326C02009,M55125C00039,M55125C00040
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02008  M55326C02009  M55308C26001_${PCELL_ID}  M55308C26001_${SCELL_ID}
    ${eq_zero}  Create List  M55125C00040_${PCELL_ID}
    ${eq_one}   Create List  M55125C00039_${PCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}   M55118C07004_${PCELL_ID}
    verify_counters   ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters   ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq
    verify_counters   ${counters_dict}  ${eq_one}   ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}


Verify counters C2 part 2
    log to console    Verify counters C2 part 2
    ${counters_dict}  pm.get_counters  M55308C26001,M55326C02008,M55326C02009
    ${counters_dict_CA}  pm.get_counters    M55118C07003,M55118C07004
    ${gt_zero}  Create List  M55326C02008  M55326C02009  M55308C26001_${PCELL_ID}
    ${eq_zero}  Create List  M55308C26001_${SCELL_ID}
    ${eq_cacells}   Create List  M55118C07003_${PCELL_ID}   M55118C07004_${PCELL_ID}
    verify_counters   ${counters_dict}  ${gt_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  gt
    verify_counters   ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq
    verify_counters  ${counters_dict_CA}  ${eq_cacells}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${0}

Verify counters BC4
    log to console    Verify counters BC4
    ${counters_dict}  pm.get_counters  M55125C00039,M55125C00040
    ${eq_zero}  Create List  M55125C00040_${PCELL_ID}
    ${eq_one}   Create List  M55125C00039_${PCELL_ID}
    verify_counters   ${counters_dict}  ${eq_zero}  ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq
    verify_counters   ${counters_dict}  ${eq_one}   ${MRBTS_5G_ID}  ${PCELL_ID}  ${SCELL_ID}  eq  ${1}
