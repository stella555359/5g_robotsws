*** Settings ***
Documentation
...   author: Anna Bien, Przemysław Herian, Kamil Pokusa, Mateusz Pajor
...   maintainer: Anna Bien, Przemysław Herian, Kamil Pokusa, Mateusz Pajor
...   contact: anna.bien@nokia.com

Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-B-B101_01_Online_activation_of_reporting_of_DL_MAC_SDU_handling_miNrLowRlcCellNrpmqap_SA_FR2
    [Setup]    Test Setup    delta_gnb1=${DELTA_B_B101_01}    reboot=False    delta_reboot=True
    _env.Activate Act Per Cc Ul Dl User Thpt
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B101_01_UE_CFG}
    _wts.Define Pdu Session Modification    ${B_B101_01_UE_CFG_PDU_MODIFICATION}
    _wts.Start Traffic Multiple Ues    ${B_B101_01_UE_CFG_TRAFFIC}
    _logs.Stop Syscom Collection For Selected TCs
    Check Lo Cell Cell Setup Req Messages
    Check Lo Cell Cell Reconfiguration Req Messages
    Check Lo User Bearer Setup Req Messages

[1]CB010636-SR-A-A1_02_L2LO_RLC_PDU_volume_counters_for_inter_CA_Ues_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_A_A1_02_GNB1}    ${DELTA_A_A1_02_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    ...    counters_type=RD
    _logs.Download Counters Reports
    ...    counters_type=pm
    ...    wait_for_next_interval=${False}
    Extract Csv From TTI Trace
    _validation.Validate PM Counters

[1]CB010636-SR-A-A1_03_L2LO_RLC_PDU_volume_counters_for_CA_Ues_SA_FR2
    [Setup]    Test Setup    ${DELTA_A_A1_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${A_A1_03_CELL2_UE_CFG}
    ...    trf_duration=2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell2_pcell
    _wts.Deregister UEs
    ...    sa_ues=1,2,3,5,9,10

    _env.Configure Cell1 As A Pcell
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${A_A1_03_CELL1_UE_CFG}
    ...    trf_duration=2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell1_pcell
    _logs.Download Counters Reports
    ...    wait_for_next_interval=${False}
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell2_pcell_gnb1.zip
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell1_pcell_gnb1.zip
    _validation.Validate PM Counters

CB010636-SR-B-B102_01_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_B_B102_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${B_B102_01_UE_CFG}
    ...    deregister=${True}
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    _validation.validate pm counters
    ...    skip_checking_tti=${True}
    ...    suffix=PM_COUNTERS_1
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_B_B102_DL_MAC_SDU}
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${B_B102_01_UE_CFG}
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    Extract CSV From TTI Trace
    _logs.Stop Collecting Syslog And Download Files
    _validation.validate pm counters
    ...    suffix=PM_COUNTERS_2
    [Teardown]    Test Teardown
    ...    syslog_stopped_before=${True}

CB010636-SR-B-B301_02_Counters_to_measure_DL_MAC_layer_UE_throughput_multiple_bursts_NSA_FR2
    [Setup]    Test Setup    ${DELTA_B_B301_02}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach NSA UE And Perform SgNB Addition
    ...    ue_id=11
    ...    cell_id=1
    ...    enb_id=2
    _wts.Attach NSA UE And Perform SgNB Addition
    ...    ue_id=12
    ...    cell_id=1
    ...    enb_id=2
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=2
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    first_ue_id=${11}
    ...    number_of_ues=2
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    30
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=2
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    number_of_ues=${2}
    ...    first_ue_id=${11}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    10
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    Extract Csv From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-B-B102_02_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_inter_discard_SANSA_FR1
    [Tags]     CLOUD_5G_I_[LO][LO]_AP_[LOO]    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    [Setup]    Test Setup    ${DELTA_B_B102_02_GNB1}    ${DELTA_B_B102_02_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=1
    ...    enb_id=2
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=2
    ...    cell_id=2
    ...    enb_id=2
    _wts.Attach NSA UE And Perform SgNB Addition
    ...    ue_id=11
    ...    cell_id=8
    ...    enb_id=3
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=2
    ...    first_ue_id=1
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running
    ...    duration=20
    _wts.Stop Traffic
    ...    number_of_ues=2
    _wts.Stop Traffic
    ...    first_ue_id=${11}
    ...    number_of_ues=1
    ...    net_arch=nsa
    _wts.Wait For Traffic Running
    ...    duration=5
    _logs.Download Counters Reports
    ...    counters_type=pm
    ...    wait_for_next_interval=${True}
    _validation.Validate PM Counters
    ...    skip_checking_tti=${True}
    ...    suffix=PM_COUNTERS_1
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_B_B102_02_GNB1_DL_MAC_SDU}
    ...    delta_path_gnb2=${DELTA_B_B102_02_GNB2_DL_MAC_SDU}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=2
    ...    first_ue_id=1
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running
    ...    duration=20
    _wts.Stop Traffic
    ...    number_of_ues=2
    _wts.Stop Traffic
    ...    first_ue_id=${11}
    ...    number_of_ues=1
    ...    net_arch=nsa
    _wts.Wait For Traffic Running
    ...    duration=5
    _wts.Wait For Traffic Running
    ...    duration=15
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    ...    counters_type=pm
    ...    wait_for_next_interval=${True}
    Extract CSV From TTI Trace
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2
    [Teardown]    Test Teardown
    ...    syslog_stopped_before=${True}

CB010636-SR-B-B103_01_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_NSA_FR2
    [Setup]    Test Setup    ${DELTA_B_B103_01_STEP_1}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${B_B103_01_UE_CFG}
    ...    deregister=${True}
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
    _validation.Validate PM Counters
    ...    skip_checking_tti=${True}
    ...    suffix=PM_COUNTERS_1
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_B_B103_01_STEP_2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${B_B103_01_UE_CFG}
    _logs.Stop TTI Traces Collection
    ${pm2_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2
    ...    direct_pm_counters_path=${pm2_counters_filepath}

CB010636-SR-B-B201_01_Online_modification_of_discard_parameters_NSA_FR2
    [Setup]    Test Setup    ${DELTA_B_B201_01}
    #1 Attach UE ${B_B201_01_UE_CFG_1}
    #2 Strat bursty traffic
    #3 ONLINECHANGE
    #4 Attach UE ${B_B201_01_UE_CFG_2}
    #5.2 Strat bursty traffic
    #5.3 ONLINECHANGE
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    #.......

CB010636-SR-B-B301_01_Counters_to_measure_DL_MAC_layer_UE_throughput_SA_FR2
    [Setup]    Test Setup    ${DELTA_B_B301_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B301_01_UE_CFG_1}
    _wts.Define Pdu Session Modification    ${B_B301_01_UE_CFG_PDU_MODIFICATION_1}
    _wts.Start Traffic Multiple Ues    ${B_B301_01_UE_CFG_TRAFFIC_1}
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Get UE Throughput Stats
    ...    ue_id=2
    _wts.Get UE Throughput Stats
    ...    ue_id=3
    _wts.Get UE Throughput Stats
    ...    ue_id=4
    _wts.Stop Traffic
    ...    number_of_ues=${6}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    _wts.Deregister UEs
    ...    sa_ues=1,2,3,4,5,6
    _wts.Wait For Traffic Running    2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell2_pcell
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell2_pcell_gnb1.zip
    _validation.Validate PM Counters
    ...    dir_to_search=utf_lab_cell2_pcell_gnb1
    ...    suffix=PM_COUNTERS_1
    _env.Configure Cell1 As A Pcell
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B301_01_UE_CFG_2}
    _wts.Define Pdu Session Modification    ${B_B301_01_UE_CFG_PDU_MODIFICATION_2}
    _wts.Start Traffic Multiple Ues    ${B_B301_01_UE_CFG_TRAFFIC_2}
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=7
    _wts.Get UE Throughput Stats
    ...    ue_id=8
    _wts.Stop Traffic
    ...    number_of_ues=${4}
    ...    first_ue_id=${7}
    ...    net_arch=sa
    _wts.Deregister UEs
    ...    sa_ues=7,8,9,10
    _wts.Wait For Traffic Running    2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell1_pcell
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell1_pcell_gnb1.zip
    _validation.Validate PM Counters
    ...    dir_to_search=utf_lab_cell1_pcell_gnb1
    ...    suffix=PM_COUNTERS_2

CB010636-SR-B-B301_03_Counters_to_measure_DL_MAC_layer_UE_throughput_HARQ_SANSA_FR1
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_B_B301_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B301_03_UE_CFG_1}
    _wts.Define Pdu Session Modification    ${B_B301_03_UE_CFG_PDU_MODIFICATION_1}
    _wts.Start Traffic Multiple Ues    ${B_B301_03_UE_CFG_TRAFFIC_1}
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Get UE Throughput Stats
    ...    ue_id=2
    _wts.Get UE Throughput Stats
    ...    ue_id=3
    _wts.Get UE Throughput Stats
    ...    ue_id=4
    _wts.Stop Traffic
    ...    number_of_ues=${4}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    _wts.Deregister UEs
    ...    sa_ues=1,2,3,4
    _wts.Wait For Traffic Running    2
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B301_03_UE_CFG_2}
    _wts.Define Pdu Session Modification    ${B_B301_03_UE_CFG_PDU_MODIFICATION_2}
    _wts.Start Traffic Multiple Ues    ${B_B301_03_UE_CFG_TRAFFIC_2}
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=5
    _wts.Get UE Throughput Stats
    ...    ue_id=6
    _wts.Get UE Throughput Stats
    ...    ue_id=7
    _wts.Get UE Throughput Stats
    ...    ue_id=8
    _wts.Stop Traffic
    ...    number_of_ues=${4}
    ...    first_ue_id=${5}
    ...    net_arch=sa
    _wts.Deregister UEs
    ...    sa_ues=5,6,7,8
    _wts.Wait For Traffic Running    2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=11
    ...    cell_id=12
    ...    enb_id=2
    ...    bearer=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=12
    ...    cell_id=1
    ...    enb_id=2
    ...    bearer=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=13
    ...    cell_id=4
    ...    enb_id=2
    ...    bearer=2
    _wts.Define Pdu Session Modification    ${B_B301_03_UE_CFG_PDU_MODIFICATION_3}
    _wts.Start Traffic Multiple Ues    ${B_B301_03_UE_CFG_TRAFFIC_3}
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=11
    _wts.Get UE Throughput Stats
    ...    ue_id=12
    _wts.Get UE Throughput Stats
    ...    ue_id=13
    _wts.Stop Traffic
    ...    number_of_ues=${3}
    ...    first_ue_id=${11}
    ...    net_arch=nsa
    _wts.Deregister UEs
    ...    nsa_ues=11,12,13
    _wts.Wait For Traffic Running    2
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-B-B301_04_Counters_to_measure_DL_MAC_layer_UE_throughput_robustness_NSA_FR2
    [Setup]    Test Setup    ${DELTA_B_B301_04}
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${B_B301_04_UE_CFG_1}
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${B_B301_04_UE_CFG_2_burst}
    #2 ONLINE CHANGE
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${B_B301_04_UE_CFG_3}
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${B_B301_04_UE_CFG_4_burst}
