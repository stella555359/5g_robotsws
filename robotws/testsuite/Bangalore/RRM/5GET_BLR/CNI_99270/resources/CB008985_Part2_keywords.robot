*** Settings ***
Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_commissioning
Library    ta5g_egate
Library    taf.config.wts              WITH NAME    wtscfg
Library    Collections
Library    String
Library    ta5g_ue_mobility
Library    ta5g_iperf_traffic
Library    ta5g_enb
Library    ta5g_commissioning
Library    ta5g_throughput
Library    CB008985_Part2-lib.py
Library    ta_messaging
Library    taf.sbts.oam.coam.admin     WITH NAME    admin
#Variables      ue_cap_variables.py

Resource   CB008985_Part1-keywords.robot

*** Variables ***
${WTS_CONFIG}                       /opt/wts/latest/basic_setup.cfg
${LOG_DIR}                          ${OUTPUT DIR}/Logs/
${WTS_LOG_DIR}                      ${LOG_DIR}/WTS/
${WTS_CONFIG_NEW}                   ${WTS_LOG_DIR}/basic_setup_mod.cfg
${rdMinPrbPtrsSAUL}                 ${3}

*** Keywords ***
Remove Non-printable Characters And Tab From File
    [Arguments]       ${file_path}
    Run Process     sed  -i  \'s/[^[:print:]\\t]//g\'  ${file_path}    shell=True

Send Delta Commissioning and Reach OnAir
    [Arguments]    ${json_file_path}
    ...            ${ue_capa}
    ...            ${ue_id}=1
    ...            ${wts_config_path}=${WTS_CONFIG}
    Send Delta Commissioning    ${json_file_path}
    Wait Until Radio Unit Online
    Create Directory    ${WTS_LOG_DIR}
    Change UE Capabilities    ue_capa=${ue_capa}    ue_id=${ue_id}
    Start WTS And Reach OnAir    ${WTS_CONFIG_NEW}

Change UE Capabilities And Reach OnAir
    [Arguments]    ${ue_capa}    ${ue_id}=1    ${wts_config_path}=${WTS_CONFIG}
    Wait Until Radio Unit Online
    Create Directory    ${WTS_LOG_DIR}
    Change UE Capabilities    ue_capa=${ue_capa}    ue_id=${ue_id}
    Start WTS And Reach OnAir    ${WTS_CONFIG_NEW}
    Check NG Link Status, Cell Setup and wait till SIB messages are received

Start WTS And Reach OnAir
    [Documentation]    Start WTS till it reach OnAir
    [Arguments]    ${wts_cfg}=${DEFAULT_WTS_CFG}
    Stop Edaemon and Egate process
    Sleep    40s
    Configure UTE ETH3 interface
    Connect to virtual machine
    initialize egate with sa 2 cell on air regex validation
    ...                   edaemon_egate_ssh_alias=${WTS.Connection}
    ...                   dir_path=${WTS_DIR}
    ...                   edaemon_port=22222
    ...                   egate_port=20000
    ...                   egate_console_ip=${WTS.Ip}
    ...                   sudo_pass=ute
    ...                   wts_file=${wts_cfg}

Wait Until Radio Unit Online
    admin.Setup admin
    Log to Console    Wait until Radio Unit online...
    Wait Until Keyword Succeeds    3x    2 min    Reboot If Radio Unit Offline
    Log to Console    Radio Unit Online
    [Teardown]      admin.Teardown admin

Configure UTE ETH3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3

Change UE Capabilities
    [Arguments]    ${ue_capa}    ${ue_id}=1    ${wts_config_path}=${WTS_CONFIG}
    wtscfg.Load Wts Cfg    ${wts_config_path}
    wtscfg.Modify    ue_param id=${ue_id}    ue_nr_capabilities=${ue_capa}
    wtscfg.Save Wts Cfg    ${WTS_CONFIG_NEW}

Modify ${param_name} Parameter To ${param_value} in ${dist_name}
    Log to Console    Setting ${param_name} value to ${param_value}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${param_name}
    ...    operation=update
    ...    value=${param_value}
    ...    skip_parameter_relation_errors=True
    Sleep    10s    reason=Wait for start recommissioning
    [Teardown]      admin.Teardown admin

Reboot If Radio Unit Offline
    [Arguments]    ${timeout}=5 min
    ${passed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${timeout}    10 sec    Check If Radio Unit Online
    Run Keyword If    ${passed}==False    Log to Console    Radio Unit offline after ${timeout}, rebooting.
    Run Keyword If    ${passed}==False    Run Keywords    admin.Reset site    Fail

Check If Radio Unit Online
    ${frm_list}    admin.Get FRM
    ${availability}    Get variable value    ${frm_list[0]['status']['availabilityStatus']}
    ...                                      Online
    Should Be Equal    ${availability}    Online

Configure UE-${ue_id} UL Sinr Testmode Before Attach
    configure_ul_sinr_testmode      ue_id=${ue_id}

Register UE-${ue_id} With PDU session
    ue_register_with_internal_trf_type      ue_id=${ue_id}
    establish_pdu_session_for_user_equipment       ue_id=${ue_id}

Verify That Nr Rrc Dmrs-Uplinkforpusch_Mappingtype${mapping_type} Not Contains dmrs-Additionalposition
    verify_that_nr_rrc_dmrs_uplinkforpusch_does_not_contain_dmrs_additionalposition     pdml_file=${filtered_pdml_file}
    ...                                                                                 mapping_type=${mapping_type}

Verify That Nr Rrc Dmrs-Downlinkforpdsch_MappingtypeA Not Contains dmrs-Additionalposition
    verify_that_nr_rrc_dmrs_downlinkforpdsch_does_not_contain_dmrs_additionalposition    ${filtered_pdml_file}

Verify That Nr Rrc Dmrs-${direction}_Mappingtype${mapping_type} Contains dmrs-Additionalposition equal to ${value}
    verify_the_value_of_dmrs_additionalposition          pdml_file=${filtered_pdml_file}
    ...                                                  mapping_type=${mapping_type}
    ...                                                  value=${value}
    ...                                                  direction=${direction}

Check if ${channel} ServingCellConfig Contains maxMIMO_layers equal to ${max_mimo_value}
    verify_max_mimo_layers_value
    ...       pdml_file=${filtered_pdml_file}
    ...       max_mimo_value=${max_mimo_value}
    ...       channel=${channel}

Configure testmode for ${ue_fo_velocity}
    configure_ue_testmode    ue_velocity=${ue_fo_velocity}

Configure UE-${ue_id} test profile for speed
    configure_speed_profile_for_ue      ue_id=${ue_id}

Register UE-${ue_id} as ${speed} Speed UE ${speed_direction} gNB

    Run Keyword If      '${speed}' == "low" and '${speed_direction}' == "approaching"
    ...                  Set UE as low speed and approaching gNB

    Run Keyword If      '${speed}' == "low" and '${speed_direction}' == "leaving"
    ...                  Set UE as low speed and leaving gNB

    Run Keyword If      '${speed}' == "high" and '${speed_direction}' == "approaching"
    ...                  Set UE as high speed and approaching gNB

    Run Keyword If      '${speed}' == "high" and '${speed_direction}' == "leaving"
    ...                  Set UE as high speed and leaving gNB

    register_ue_and_validate        ue_id=${ue_id}
    establish_pdu_session_for_user_equipment        ue_id=${ue_id}

Set UE as low speed and leaving gNB
    Configure testmode for VELOCITY_LEAVING_GNB_AT_100KMPH
    Configure UE-1 test profile for speed

Set UE as high speed and leaving gNB
    Configure testmode for VELOCITY_LEAVING_GNB_AT_350KMPH
    Configure UE-1 test profile for speed

Set UE as low speed and approaching gNB
    Configure testmode for VELOCITY_APPROACHING_GNB_AT_100KMPH
    Configure UE-1 test profile for speed

Set UE as high speed and approaching gNB
    Configure testmode for VELOCITY_APPROACHING_GNB_AT_350KMPH
    Configure UE-1 test profile for speed

Setup devices aliases
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable Internal Mirroring For Alias    gNB2

Start UE-${ue_id} ${ul_rate} Mbps Uplink Traffic With SINR Below Ultransprecodeonsinrthresh And Measure Average Tput
    Expect message flow
    ...    UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    alias=TransformPrecoder_change   overall_timeout=20

    start_sa_uplink_traffic_with_degraded_rf_condition_below_ultransprecodeonsinrthresh
    ...     ue_id=${ue_id}    rate=${ul_rate}    duration=20

    ${avg_tput}    measure_average_ul_data_rate    ue_id=1
    Flow occurred as expected  alias=TransformPrecoder_change

    ${ul_rate_bps}    Evaluate    ${ul_rate}*1000000
    verify_tput_deviation_is_within_margin    ${ul_rate_bps}   ${avg_tput}   ${margin}

    [Return]    ${avg_tput}

Verify that both values for UL throughput are similar
    [Arguments]         ${tput_value_1}         ${tput_value_2}
    verify_tput_deviation_is_within_margin      ${tput_value_1}     ${tput_value_2}     ${margin}

${tput_1} should be greater than ${tput_2}
    Should Be True    ${tput_1}>${tput_2}

Start ${ul_rate} Mbps ${dir} traffic for UE-${ue_id} in ${mode} Mode And Verify Avg Througphut
    Start ${ul_rate} Mbps ${dir} traffic for UE-${ue_id} in ${mode} Mode
    Sleep      20s     reason=Wait traffic to be stable
    ${avg_tput}    measure_average_ul_data_rate    ue_id=${ue_id}    mode=${mode}

    ${ul_rate_bps}    Evaluate    ${ul_rate}*1000000
    verify_tput_deviation_is_within_margin    ${ul_rate_bps}   ${avg_tput}   500000

    [Return]    ${avg_tput}

Update ulPtrs parameter
    [Arguments]    ${actUlPtrs}    ${ThresNrb0}    ${ThresNrb1}
    ${dict}    Create Dictionary
    ...    actUlPtrs    ${actUlPtrs}
    ...    ulPtrsFreqDensityThresNrb0    ${ThresNrb0}
    ...    ulPtrsFreqDensityThresNrb1    ${ThresNrb1}
    ${ulPtrs}    Create List    ${dict}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=ulPtrs
    ...    operation=update
    ...    value=${ulPtrs}
    ...    skip_parameter_relation_errors=True
    [Teardown]      admin.Teardown admin

Update dlPtrs parameter
    [Arguments]    ${actDlPtrs}    ${ThresNrb0}    ${ThresNrb1}
    ${dict}    Create Dictionary
    ...    actDlPtrs    ${actDlPtrs}
    ...    dlPtrsFreqDensityThresNrb0    ${ThresNrb0}
    ...    dlPtrsFreqDensityThresNrb1    ${ThresNrb1}
    ${dlPtrs}    Create List    ${dict}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=dlPtrs
    ...    operation=update
    ...    value=${dlPtrs}
    ...    skip_parameter_relation_errors=True
    [Teardown]      admin.Teardown admin

Set observer for PDU session for UE_${ue_id}
    Expect message flow
    ...    gNB2:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB2:F1AP_UEContextSetupResponse (DUtoCURRCInformation is present) as UEContextSetupResponse
    ...    UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    alias=pdu_session_${ue_id}   overall_timeout=60

Verify that ${feature_name} is ${expected_result} in UE_${ue_id} Capability
    [Documentation]    This keyword verify ue capa field value or filed is off in Ue Capa (${expected_result}=off)
    ...  Supported ${feature_name} parameters:
    ...      ss-SINR-Meas
    ...      pusch-256QAM
    ...      absoluteTPC-Command
    ...      pucch-F3-4-HalfPi-BPSK
    ...      channelBWs-DL
    ...      twoFL-DMRS-TwoAdditionalDMRS-UL
    ...      oneFL-DMRS-TwoAdditionalDMRS-UL
    ...      oneFL-DMRS-TwoAdditionalDMRS-DL
    ...      ptrs-DensityRecommendationSetUL_freqDensity1
    ...      ptrs-DensityRecommendationSetUL_freqDensity2
    ...      ptrs-DensityRecommendationSetDL_freqDensity1
    ...      ptrs-DensityRecommendationSetDL_freqDensity2
    ...      onePortsPTRS
    ...      supportedDMRS-TypeDL
    ...      supportedDMRS-TypeUL
    ...
    ...      Examples:
    ...      Verify that onePortsPTRS is 0b11 in UE_1 Capability
    ...      Verify that oneFL-DMRS-TwoAdditionalDMRS-DL is supported in UE_1 Capability

    Flow occurred as expected  alias=pdu_session_${ue_id}

    verify_that_ue_supports_feature      flow_alias=pdu_session_${ue_id}
    ...                   message_alias=UEContextSetupRequest
    ...                   field=uE-CapabilityRAT-ContainerList
    ...                   feature_name=${feature_name}
    ...                   expected_result=${expected_result}

Verify that maxMIMO-Layers in F1AP_UEContextSetupResponse is equal to ${value} in ${phy_channel} for UE_${ue_id}
    Flow occurred as expected  alias=pdu_session_${ue_id}
    ${mimo_layer_dl}=     Set variable      pdsch-ServingCellConfig..setup..maxMIMO-Layers eq ${value}
    ${mimo_layer_ul}=     Set variable      pusch-ServingCellConfig..setup..maxMIMO-Layers eq ${value}
    Run keyword if      '${phy_channel}' == 'PUSCH'     Verify That Message Has Fields     ${mimo_layer_ul}
    ...                  message_alias=UEContextSetupResponse
    ...                  flow_alias=pdu_session_${ue_id}
    Run keyword if      '${phy_channel}' == 'PDSCH'     Verify That Message Has Fields     ${mimo_layer_dl}
    ...                  message_alias=UEContextSetupResponse
    ...                  flow_alias=pdu_session_${ue_id}

Verify that ptrs-Config in ${phy_channel} is not present for UE_${ue_id}
    Flow occurred as expected  alias=pdu_session_${ue_id}
    Run keyword if    '${phy_channel}' == 'PUSCH'   Verify That Message Fulfills Query
    ...    uplinkConfig contains (phaseTrackingRS is not present)
    ...    flow_alias=pdu_session_${ue_id}
    ...    message_alias=RRCReconfiguration
    Run keyword if    '${phy_channel}' == 'PDSCH'   Verify That Message Fulfills Query
    ...    dmrs-DownlinkForPDSCH-MappingTypeA contains (phaseTrackingRS is not present)
    ...    flow_alias=pdu_session_${ue_id}
    ...    message_alias=RRCReconfiguration

Verify that frequencyDensity in NR-RRC_RRCReconfiguration is equal to ${val1}, ${val2} in ${phy_channel} for UE_${ue_id}
    Flow occurred as expected  alias=pdu_session_${ue_id}
    Run keyword if     '${phy_channel}' == 'PUSCH'
    ...                 Verify That Message Fulfills Query    uplinkConfig contains (phaseTrackingRS is present)
    ...                 and (frequencyDensity contains (${val1},${val2}))
    ...                 message_alias=RRCReconfiguration
    ...                 flow_alias=pdu_session_${ue_id}
    Run keyword if     '${phy_channel}' == 'PDSCH'
    ...                 Verify That Message Fulfills Query    pdsch-Config contains (phaseTrackingRS is present)
    ...                 and (frequencyDensity contains (${val1}, ${val2}))
    ...                 message_alias=RRCReconfiguration
    ...                 flow_alias=pdu_session_${ue_id}

Verify that frequencyDensity1 and frequencyDensity2 are set according to ulPtrsFreqDensityThresNrb0/1 and rdValues
    [Documentation]         This keyword checks that freq densities are set according to gNB settings
    ...                     5G-CP-RT shall configure frequencyDensity parameters with
	...                      (max(rdMinPrbPtrsSAUL+1, MRBTS/NRBTS/NRCELL/ulPtrs/ulPtrsFreqDensityThresNrb0),
    ...                       max(rdMinPrbPtrsSAUL+1, MRBTS/NRBTS/NRCELL/ulPtrs/ulPtrsFreqDensityThresNrb1))
    [Arguments]           ${ul_ptrs_freq_density_nrb0}              ${ul_ptrs_freq_density_nrb1}     ${ue_id}

    Flow occurred as expected  alias=pdu_session_${ue_id}
    ${rdMinPrbPtrsSAUL_plus_one}=       Evaluate       ${rdMinPrbPtrsSAUL} + 1
    ${expected_freq_density1}=        Set variable if      ${rdMinPrbPtrsSAUL_plus_one}>${ul_ptrs_freq_density_nrb0}
    ...                               ${rdMinPrbPtrsSAUL_plus_one}     ${ul_ptrs_freq_density_nrb0}
    ${expected_freq_density2}=        Set variable if      ${rdMinPrbPtrsSAUL_plus_one}>${ul_ptrs_freq_density_nrb1}
    ...                               ${rdMinPrbPtrsSAUL_plus_one}     ${ul_ptrs_freq_density_nrb1}
    Verify That Message Fulfills Query    pusch-Config contains (phaseTrackingRS is present)
    ...                 and (frequencyDensity contains (${expected_freq_density1}, ${expected_freq_density2}))
    ...                 message_alias=RRCReconfiguration
    ...                 flow_alias=pdu_session_${ue_id}

Save Pcap Log With New Name
    [Arguments]    ${new_name}
    Copy File    ${cprt_pcap_path}    ${OUTPUT_DIR}/${new_name}

Verify that ptrs-Config in ${phy_channel} is not present
    Run keyword if    '${phy_channel}' == 'PUSCH'   Verify That Message Fulfills Query
    ...    uplinkConfig contains (phaseTrackingRS is not present)
    ...    flow_alias=pdu_session_${ue_id}
    ...    message_alias=RRCReconfiguration
    Run keyword if    '${phy_channel}' == 'PDSCH'   Verify That Message Fulfills Query
    ...    dmrs-DownlinkForPDSCH-MappingTypeA contains (phaseTrackingRS is not present)
    ...    flow_alias=pdu_session_${ue_id}
    ...    message_alias=RRCReconfiguration

Verify that additionalDMRS in NR-RRC_RRCReconfiguration is True in PUCCH-Config
    verify_the_value_of_pucch_additional_dmrs     ${filtered_pdml_file}
