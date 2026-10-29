*** Settings ***
Documentation
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASOF_1_Olympians_10.58.143.83"


Force Tags              CLOUD_5G_I_LO_AP_LO         CA_E2ET_BTSTRSPZ        SBTS00      SBTS24R3        SBTS25R1
...         [SBTS23R2]         QCD_MN_RAN        QCP_RAN_VRF        CRT



variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown



*** Test Cases ***
[1]LTE4944_BTS_Transport_bandwidth_Ethernet_utilization_counters_4vlan_ethernet_shaping

    Preconditon
    Bringup OnAir
    Set BW Util Parameters
    Send Traffic
    Pm Counters Start     analysis=verify_BW_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       180
    VLANIF Counter Verification
    ETHIF Counter Verification
    ETHLK Counter Verification for L2qos Enable
    Verify Pm Counters    analysis=verify_BW_counters      counter_analysis_file=${counter_analysis_file_name}
    Disable L2qos
    ETHLK Counter Verification for L2qos Disable
    Stop Traffic
***Keywords***

Preconditon


    Run     sudo killall egate edaemon
    Run     sudo ip a a 10.0.1.121/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.131/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.132/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.133/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.134/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.135/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.136/24 dev eth3.2733
    Run     sudo ip a a 10.0.1.137/24 dev eth3.2733
    sleep   10
###Enable L2 qos####
    Perform Recommissioning     type=delta      delta_file=${delta_l2qos}     timeout=300
    sleep  60

Bringup OnAir

    Call Setup     5g=Device_AP:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=120
    Sleep   60
#    Verify BTS status   should_be_onair=${True}
#    Sleep     10
Disable L2qos

    Perform Recommissioning     type=delta      delta_file=${delta_l2qos_Disable}     timeout=300
    sleep  900

Set BW Util Parameters

    Perform Recommissioning     type=delta      delta_file=${Configure_FSTSCH_VLAN_configuation}     timeout=300
    Perform Recommissioning     type=param  param_path=${Sampling_Interval}    operation=update    value=15sec     timeout=300
    Perform Recommissioning     type=param  param_path=${Vlan_Measurement_interval}    operation=update    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthIF_Measurement_Interval}    operation=update    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthIF_Untagged_Measurement_Interval}    operation=update    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${EthLK_Measurement_Interval}    operation=update    value=15min     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_FSTSCH}    operation=update    value=300000     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_ETHIF}    operation=update    value=400000     timeout=300
    Perform Recommissioning     type=param  param_path=${reference_bw_ETHLK}    operation=update    value=20000     timeout=300
    Perform Recommissioning     type=param  param_path=${shaping_overhead}    operation=update    value=Ethernet frame     timeout=300
    Verify BTS status   should_be_onair=${True}

Send Traffic

    Configure UE       5g=Device_AP:data     command=enb_x2_link_up  enb=1   target=2
    Sleep   5
    Configure UE       5g=Device_AP:data     command=ue_register     id=1
    Sleep   5
    Configure UE       5g=Device_AP:data     command=set_pdu_param  ue=1     pdu=1   trf_type=internal
    Sleep   5
    Configure UE       5g=Device_AP:data    command=ue_pdu_session_setup     pdu=1   gw=1  ue=1
    Sleep   5
    Configure UE       5g=Device_AP:data    command=trf_data_start   ue=1  pdu=1   qfi=1   dir=dl trf_id=1   mbps=175
    Sleep   5
    Configure UE       5g=Device_AP:data    command=trf_data_start   ue=1  pdu=1   qfi=1   dir=dl trf_id=2   mbps=25
    Sleep   5
    Configure UE       5g=Device_AP:data    command=trf_data_start   ue=1  pdu=1    qfi=1  dir=ul   mbps=175
   sleep      900
Stop Traffic

    Configure UE       5g=Device_AP:data    command=ue_deregister    id=1    ue_deregister_type=switch_off



VLANIF Counter Verification


    Set Suite Variable      ${VLANIF_Class1}             0
    Set Suite Variable      ${VLANIF_Class2}              0
    Set Suite Variable      ${VLANIF_Class3}              100
    Set Suite Variable      ${VLANIF_Class4}              0
    Set Suite Variable      ${VLANIF_Class5}              0
    Set Suite Variable      ${VLANIF_Value_out}           170000..220000
    Set Suite Variable      ${VLANIF_Value_in}            190000..220000


ETHIF Counter Verification


    Set Suite Variable      ${ETHIF_Class1}               0
    Set Suite Variable      ${ETHIF_Class2}               100
    Set Suite Variable      ${ETHIF_Class3}               0
    Set Suite Variable      ${ETHIF_Class4}               0
    Set Suite Variable      ${ETHIF_Class5}               0
    Set Suite Variable      ${ETHIF_Value_out}           170000..220000
    Set Suite Variable      ${ETHIF_Value_in}            190000..220000



ETHLK Counter Verification for L2qos Enable


    Set Suite Variable      ${ETHLK_Class1}               0
    Set Suite Variable      ${ETHLK_Class2}               0
    Set Suite Variable      ${ETHLK_Class3}               0
    Set Suite Variable      ${ETHLK_Class4}               0
    Set Suite Variable      ${ETHLK_Class5}               100
    Set Suite Variable      ${ETHLK_Value_out}            15000..25000
    Set Suite Variable      ${ETHLK_Value_in}             190000..220000


ETHLK Counter Verification for L2qos Disable

    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       180

    Set Suite Variable      ${Class1}               100
    Set Suite Variable      ${Class2}               0
    Set Suite Variable      ${Class3}               0
    Set Suite Variable      ${Class4}               0
    Set Suite Variable      ${Class5}               0
    Set Suite Variable      ${Value_out}            170000..220000
    Set Suite Variable      ${Value_in}            190000..220000

    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
