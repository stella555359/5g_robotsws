*** Settings ***
Documentation
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "CLOUD_5G_I_MP_AP_LO"



variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown


*** Test Cases ***
[1][2.0] LTE4944_BTS_Transport_bandwidth_Ethernet_utilization_counters_after_upgrade
    Precondition
    Bringup OnAir
    Set BW Util Parameters
    Bringup OnAir
    Send Traffic
    VLANIF Counter Verification
    ETHIF Counter Verification
    ETHLK Counter Verification for L2qos Enable
    Disable L2qos
    ETHLK Counter Verification for L2qos Disable
    Stop Traffic
    Perform software upgrade
    Send Traffic
    ETHLK Counter Verification for L2qos Disable
    Perform Recommissioning     type=delta      delta_file=delta_l2_qos_enable.xml     timeout=300
    sleep  60
    VLANIF Counter Verification
    ETHIF Counter Verification
    ETHLK Counter Verification for L2qos Enable
    Stop Traffic

***Keywords***
Precondition
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=true     timeout=400     alias=default
    Sleep    300
    Perform Recommissioning     type=delta      delta_file=${delta_l2qos}     timeout=300
    sleep  60

Bringup OnAir
    Call Setup     lte=Plain_config_CUS:data    parallel=${False}    attach=${False}
    ...      verify_attach=${false}    timeout=120
    Sleep   10
    Verify BTS status   should_be_onair=${True}
    Sleep     10
Disable L2qos
    Perform Recommissioning     type=delta      delta_file=${delta_l2qos_Disable}     timeout=300
    sleep  900

Set BW Util Parameters
    Perform Recommissioning     type=delta      delta_file=${Configure_FSTSCH_VLAN_configuation}     timeout=300
    Perform Recommissioning     type=param  param_path=${Sampling_Interval}    operation=update
    ...    value=15sec     timeout=300
    Perform Recommissioning     type=param  param_path=${Vlan_Measurement_interval}    operation=update
    ...    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthIF_Measurement_Interval}    operation=update
    ...    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthIF_Untagged_Measurement_Interval}    operation=update
    ...    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthLK_Measurement_Interval}    operation=update
    ...    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_FSTSCH}    operation=update
    ...    value=50000     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_ETHIF}    operation=update
    ...    value=35000     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_ETHLK}    operation=update
    ...    value=20000     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_ETHLK_1}    operation=update
    ...    value=20000     timeout=300
    Perform Recommissioning     type=param  param_path=${shaping_overhead}    operation=update
    ...    value=Ethernet frame     timeout=300
    Verify BTS status   should_be_onair=${True}

Send Traffic
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=11
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=200 protocol=udp
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=dl Mbps=200 protocol=udp
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=11 cell=12
    Sleep   5
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=11 dir=ul Mbps=200 protocol=udp
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=21 cell=13
    Sleep   5
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=21 dir=ul Mbps=200 protocol=udp
    sleep      100

Stop Traffic
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=1
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=11
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=21
VLANIF Counter Verification
    Pm Counters Start     analysis=verify_vlan_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       120
    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               0..10
    Set Suite Variable      ${Class3}               90..100
    Set Suite Variable      ${Class4}               0
    Set Suite Variable      ${Class5}               0
    Set Suite Variable      ${Value_out}               30000..40000
    Set Suite Variable      ${Value_in}            190000..220000
    Sleep       120
    Verify Pm Counters    analysis=verify_vlan_counters       counter_analysis_file=${counter_analysis_file_name}

ETHIF Counter Verification
    Pm Counters Start     analysis=verify_tagged_untagged_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       120
    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               0..10
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               90..100
    Set Suite Variable      ${Value_out}               30000..40000
    Set Suite Variable      ${Value_in}            190000..220000
    sleep       120
    Verify Pm Counters      analysis=verify_tagged_untagged_counters       counter_analysis_file=${counter_analysis_file_name}

ETHLK Counter Verification for L2qos Enable
    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       120
    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               0..10
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               90..100
    Set Suite Variable      ${Value_out}               15000..25000
    Set Suite Variable      ${Value_in}            190000..220000
    sleep       120
    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}

ETHLK Counter Verification for L2qos Disable
    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       180
    Set Suite Variable      ${Class1}               100
    Set Suite Variable      ${Class2}               0
    Set Suite Variable      ${Class3}               0
    Set Suite Variable      ${Class4}               0
    Set Suite Variable      ${Class5}               0
    Set Suite Variable      ${Value_out}               30000..40000
    Set Suite Variable      ${Value_in}            190000..220000
    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}

Perform software upgrade
    Perform software download and update     wft_profile=sbtstrunk_00      package=auto
    ...         activate_sw=true      update_timeout=900
    Sleep   900

