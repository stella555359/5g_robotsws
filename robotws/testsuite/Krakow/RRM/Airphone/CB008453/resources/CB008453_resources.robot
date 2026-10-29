*** Settings ***
Documentation
...        Maintainers:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Michal Obszarny, michal.obszarny@nokia.com
...        Authors:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Michal Obszarny, michal.obszarny@nokia.com
...        Description:  Common keywords for CB008453

Library     OperatingSystem
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ute_tshark
Library     ute_syslog
Library     ta_emss
Library     ta5g_tshark
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.ul.ue.sim.env_setup
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/ue_handling.py
Library     CB008453_resources.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/ssh.robot

*** Keywords ***
Prepare NR-DC suite environment setup
    Copy iphy packet lua
    Log to console    Setup started
    Logcollector start

    ${CONFIGURE_ENV}    Get variable value    ${configure}    "True"
    Run keyword if    ${CONFIGURE_ENV}=="True"    Configure suite environment

    Setup egate    egate_port=20000    alias=default
    Setup devices aliases

    Enable internal mirroring for alias    gNB2
    Enable internal mirroring for alias    gNB3
    Teardown emss    bts_id=1
    Setup emss       bts_id=1
    Teardown emss    bts_id=2
    Setup emss       bts_id=2

Configure suite environment
    Add gnb configuration    host_id=1    scfc=${SCF_gnb2_MN}
    Add gnb configuration    host_id=2    scfc=${SCF_gnb3_SN}
    Add simulator    sim_type=airphone    config=${AP_XML}
    Add 5gc    config=${egate_config}    edaemon_ports=22222
    Configure environment    rmod_detection_timeout=420s    validate_gnb=False

IWF Suite teardown after execution
    Teardown egate
    IWF preconfigs teardown
    Clean suite environment

Setup devices aliases
    Create UEs alias    alias=UE    id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.4
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

CB008453 feature enable
    Configure and wait    ${CURDIR}/../config/CB008453_feature_enable.yaml
    Wait for enb on air    timeout=600    bts_id=1

CB008453 B_ITW6 feature enable
    Configure and wait    ${CURDIR}/../config/CB008453_B_ITW6_NR-DC.yaml    bts_id=2

CB008453 B_ITW7 feature enable
    Configure and wait    ${CURDIR}/../config/CB008453_B_ITW7.yaml
    Wait for enb on air    timeout=600    bts_id=1

CB008453 E_B2 feature enable
    Configure and wait    ${CURDIR}/../config/CB008453_E_B2.yaml

Configure intrafreq A3 RSRP HO NR-DC configuration
    Configure and wait    ${CURDIR}/../config/intra_gNB_intra_freq_A3_RSRP_based_HO_NR-DC.yaml    bts_id=1

Disable CA
    Configure and wait    {'MOC':'NRBTS', 'ID':'1', 'actCarrierAggregation':"false", 'caConfigurationSupport':0}

Disable SA CA
    Configure and wait    {'MOC':'NRBTS', 'ID':'1', 'actCarrierAggregationFr2SA':"false", 'caConfigurationSupportFr2SA':0}

Set maxNumScellsDl and maxNumScellsUl to value
    [Arguments]    ${dl_scells}=1    ${ul_scells}=0
    Configure and wait    {'MOC':'NRBTS', 'ID':'1', 'maxNumScellsDl':${dl_scells}, 'maxNumScellsUl':${ul_scells}}

Set maxNumScellsDlFr2SA and maxNumScellsUlFr2SA to value
    [Arguments]    ${dl_scells}=1    ${ul_scells}=0
    Configure and wait    {'MOC':'NRBTS', 'ID':'1', 'maxNumScellsDlFr2SA':${dl_scells}, 'maxNumScellsUlFr2SA':${ul_scells}}

Verify tdd-UL-DL-ConfigurationCommon on pcell with
    [Arguments]    ${guardPeriod}=10    ${pcell_id}=51    ${ue_id}=107
    ${SS_downlink_symbols}    Evaluate    12-${guardPeriod}
    Verify that message fulfills query
    ...    (spCellConfigCommon contains (physCellId eq ${pcell_id})) and
    ...    (tdd-UL-DL-ConfigurationCommon contains (
    ...        pattern1 contains (
    ...            dl-UL-TransmissionPeriodicity eq 'ms1' and
    ...            nrofDownlinkSlots eq 3 and
    ...            nrofDownlinkSymbols eq ${SS_downlink_symbols} and
    ...            nrofUplinkSlots eq 4 and
    ...            nrofUplinkSymbols eq 2
    ...            )
    ...        )
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=SgNBAddition_X2AP_UE${ue_id}

Verify tdd-UL-DL-ConfigurationCommon on scell with
    [Arguments]    ${guardPeriod}=10    ${scell_id}=52    ${ue_id}=107
    ${SS_downlink_symbols}    Evaluate    12-${guardPeriod}
    Verify that message fulfills query
    ...    (sCellConfigCommon contains (physCellId eq ${scell_id})) and
    ...    (tdd-UL-DL-ConfigurationCommon contains (
    ...        pattern1 contains (
    ...            dl-UL-TransmissionPeriodicity eq 'ms1' and
    ...            nrofDownlinkSlots eq 3 and
    ...            nrofDownlinkSymbols eq ${SS_downlink_symbols} and
    ...            nrofUplinkSlots eq 4 and
    ...            nrofUplinkSymbols eq 2
    ...            )
    ...         )
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=SgNBAddition_X2AP_UE${ue_id}

Verify tdd-UL-DL-ConfigurationCommon on SA pcell with
    [Arguments]    ${guardPeriod}=10    ${pcell_id}=51    ${ue_id}=1
    ${SS_downlink_symbols}    Evaluate    12-${guardPeriod}
    Verify that message fulfills query
    ...    (cellGroupConfig contains (spCellConfigCommon contains (physCellId eq ${pcell_id}))) and
    ...    (cellGroupConfig contains (tdd-UL-DL-ConfigurationCommon contains (
    ...        pattern1 contains (
    ...            dl-UL-TransmissionPeriodicity eq 'ms1' and
    ...            nrofDownlinkSlots eq 3 and
    ...            nrofDownlinkSymbols eq ${SS_downlink_symbols} and
    ...            nrofUplinkSlots eq 4 and
    ...            nrofUplinkSymbols eq 2
    ...            )
    ...        )
    ...    ))
    ...    message_alias=UEContextModificationResponse_2nd
    ...    flow_alias=Established_PDU_for_UE${ue_id}

Position UE${ue_id} in distance to cell - ${dist}m
    ${ta}    Calculate timing advance    ${dist}
    Execute egate command    cmd=ue_ta_nr
    ...                      ue_p_delay_initial=${ta}
    ...                      ue_p_delay_min=${ta}
    ...                      ue_p_delay_max=${ta}
    ...                      nb_reps_ta_sim=1
    ...                      ue_speed=30
    ...                      profile_id=2
    Execute egate command    cmd=ue_testmode_set_nr
    ...                      action=activate
    ...                      testmode=ta
    ...                      profile_id=2
    ...                      cell_group=SCG
    ...                      id=${ue_id}

Configure Airphone test modes supported high throughput scenarios on IWF setup
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    Sleep    2s     reason=Wait for env stabilization
    Execute egate command    cmd=uec_l2_testmode_params fixed_csi_report=true
    Sleep    2s    reason=Wait for env stabilization
    Execute egate command    cmd=ul_sinr_testmode_nr profile_id=1 pusch_tx_powe pcmax=23
    Sleep    2s    reason=Wait for env stabilization
    Execute egate command    cmd=ue_testmode_set_nr id=${first_ue_id}-${last_ue_id} testmode=ul_sinr profile_id=1 action=activate
    Sleep    2s    reason=Wait for env stabilization

Verify DL NSA throughput at gNB level
    [Arguments]    ${expected_dl_traffic_mbps}    ${margin_mbps}    ${first_ue}    ${last_ue}    ${min_active_cc}     ${max_active_cc}
    Verify that number of active UEs is between thresholds
    ...    dir=dl    scells=8-16    first_ue_id=${first_ue}    last_ue_id=${last_ue}    low_limit=${min_active_cc}    up_limit=${max_active_cc}
    ${all_ues_traffic}    Get summarize data rate for multiple NSA UEs
    ...    dir=dl    first_ue=${first_ue}     last_ue=${last_ue}    data_rate_type=Average    bearer_type=scg    bearer=2
    ${min_dl_traffic_mbps}    Evaluate    ${expected_dl_traffic_mbps} - ${margin_mbps}
    ${max_dl_traffic_mbps}    Evaluate    ${expected_dl_traffic_mbps} + ${margin_mbps}
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    >    ${min_dl_traffic_mbps}    Total NSA DL throughput
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    <    ${max_dl_traffic_mbps}    Total NSA DL throughput
    Log to console    *** Total NSA DL throughput: ${all_ues_traffic} Mbps

Verify UL NSA throughput at gNB level
    [Arguments]    ${expected_ul_traffic_mbps}    ${margin_mbps}    ${first_ue}    ${last_ue}    ${min_active_cc}     ${max_active_cc}
    Verify that number of active UEs is between thresholds
    ...    dir=ul    scells=8-16    first_ue_id=${first_ue}    last_ue_id=${last_ue}    low_limit=${min_active_cc}    up_limit=${max_active_cc}
    ${all_ues_traffic}    Get summarize data rate for multiple NSA UEs
    ...    dir=ul    first_ue=${first_ue}     last_ue=${last_ue}    data_rate_type=Average    bearer_type=mcg    bearer=2
    ${min_dl_traffic_mbps}    Evaluate    ${expected_ul_traffic_mbps} - ${margin_mbps}
    ${max_dl_traffic_mbps}    Evaluate    ${expected_ul_traffic_mbps} + ${margin_mbps}
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    >    ${min_dl_traffic_mbps}    Total NSA UL throughput
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    <    ${max_dl_traffic_mbps}    Total NSA UL throughput
    Log to console    *** Total NSA UL throughput: ${all_ues_traffic} Mbps

Start TTI trace collection
    Start TTI trace

Stop and convert TTI trace collection
    [Arguments]    ${directory_name}=TtiTraces    ${conversion_filter}=None    ${delay}=0
    ${parent_directory}    Set variable    ${directory_name}
    Set test variable    ${parent_directory}
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/${parent_directory}    delay=${delay}
    Convert TTI trace pcap
    ...    input=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
    ...    output=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output
    ...    conversion_filter=${conversion_filter}
