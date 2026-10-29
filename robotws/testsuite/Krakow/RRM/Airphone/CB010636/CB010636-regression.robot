*** Settings ***
Documentation
...   author: Przemyslaw Herian
...   maintainer: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Library     ta_emss
Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-A-B103_01_RLC_PDU_volume_counters_new_flag_bearerType_SANSA_FR1
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
    [Setup]    Test Setup    delta_gnb1=${DELTA_A_B103_01}
    _logs.Start Syscom Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${A_B103_01_UE_CFG}
    _logs.Stop Syscom Collection
    Check Hi User Du Bearer Setup Req Messages

CB010636-SR-A-B104_01_L2HI_RLC_PDU_volume_counters_for_CA_Ues_SANSA_FR1
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup
    ...    delta_gnb1=${DELTA_A_A1_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    _wts.Deregister UEs
    ...    sa_ues=1,2,3,4,5,7,8
    ...    nsa_ues=11,12,13
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    ...    direct_pm_counters_path=${pm_counters_filepath}
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate LoUser SetupReq
    [Teardown]    Run Keywords
    ...    Produce Scout Data
    ...    _logs.Collect Logs After Test
    ...    common_wts.Stop WTS And Clear
    ...    _env.Restore Default Iphy
    ...    _env.Restore Default SCFs

CB010636-SR-A-B104_03_L2HI_RLC_PDU_volume_counters_for_CA_Ues_SA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_A_A1_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${A_B104_03_CELL2_UE_CFG}
    ...    trf_duration=2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell2_pcell
    _wts.Deregister UEs
    ...    sa_ues=1,2,3,5,9,10
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell2_pcell_gnb1.zip
    _validation.Validate PM Counters
    ...    dir_to_search=utf_lab_cell2_pcell_gnb1
    ...    suffix=PM_COUNTERS_1
    _env.Configure Cell1 As A Pcell
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${A_B104_03_CELL1_UE_CFG}
    ...    trf_duration=2
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_cell1_pcell
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_cell1_pcell_gnb1.zip
    _validation.Validate PM Counters
    ...    dir_to_search=utf_lab_cell1_pcell_gnb1
    ...    suffix=PM_COUNTERS_2
    _validation.Validate UL RLC PM Counters distribution

[1]CB010636-SR-A-B104_04_L2HI_RLC_PDU_volume_counters_for_CA_Ues_NSA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_A_A1_04}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    ...    counters_type=PM
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    _validation.Validate UL RLC PM Counters distribution

CB010636-SR-A-B201_01_DRB_CA_eligible_flag_for_RLC_PDU_volume_counters_SANSA_FR1
    [Tags]     CLOUD_5G_I_[LO][LO]_AP_[LOO]    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    [Setup]    Test Setup    ${DELTA_A_B201_01_GNB1}    ${DELTA_A_B201_01_GNB2}
    _logs.Start Syscom Collection
    ...    file_name_prefix=before
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${A_B201_01_UE_CFG_1}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${A_B201_01_UE_CFG_PDU_MODIFICATION_01}
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${A_B201_01_UE_CFG_TRAFFIC_1}
    _logs.Stop Syscom Collection
    ...    file_name_prefix=before
    Check BearerSetupReq Messages Before Online Change

    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_A_B201_01_DRB_ONLINE}

    _logs.Start Syscom Collection
    ...    file_name_prefix=after
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${A_B201_01_UE_CFG_2}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${A_B201_01_UE_CFG_PDU_MODIFICATION_02}
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${A_B201_01_UE_CFG_TRAFFIC_2}
    _logs.Stop Syscom Collection
    ...    file_name_prefix=after
    Check BearerSetupReq Messages After Online Change

CB010636-SR-A-B202_01_RLC_PDU_volume_counters_for_CA_and_non_CA_DRBs_of_CA_Active_UE_SANSA_FR1
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
    [Setup]    Test Setup    ${DELTA_A_B202_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${A_B202_01_UE_CFG}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=151    bearer=3    cell_id=3    enb_id=2
    _wts.Add Bearer For Nsa Ue    ${ADD_BEARER_3_UE_151}
    _wts.Define Pdu Session Modification    ${A_B202_01_UE_CFG_PDU_MODIFICATION}
    _wts.Define Pdu Session Modification Nsa    ${ADD_BEARER_3_MODIFY_UE_151}
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _wts.Start Traffic Multiple Ues    ${A_B202_01_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    5
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-A-B202_03_RLC_PDU_volume_counters_for_CA_and_non_CA_DRBs_of_CA_Active_UE_interaction_with_UL_CB009059_FR1
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
    [Setup]    Test Setup    ${DELTA_A_B202_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${A_B202_03_UE_CFG}
    _wts.Define Pdu Session Modification    ${A_B202_03_UE_CFG_PDU_MODIFICATION}
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _wts.Start Traffic Multiple Ues    ${A_B202_03_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    5
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-B-B101_01_Online_activation_of_reporting_of_DL_MAC_SDU_handling_miNrLowRlcCellNrpmqap_SA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    delta_gnb1=${DELTA_B_B101_01}    reboot=False    delta_reboot=True
    _env.Activate Act Per Cc Ul Dl User Thpt
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${B_B101_01_UE_CFG}
    _wts.Define Pdu Session Modification    ${B_B101_01_UE_CFG_PDU_MODIFICATION}
    _wts.Start Traffic Multiple Ues    ${B_B101_01_UE_CFG_TRAFFIC}
    _logs.Stop Syscom Collection For Selected TCs
    Check Lo Cell Cell Setup Req Messages
    Check Lo Cell Cell Reconfiguration Req Messages
    Check Lo User Bearer Setup Req Messages

CB010636-SR-B-B102_01_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_SANSA_FR1
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
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

CB010636-SR-B-B103_01_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_NSA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_B_B103_01_${RELEASE}_STEP_1}
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

CB010636-SR-B-B301_01_Counters_to_measure_DL_MAC_layer_UE_throughput_SA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_B_B301_01_${RELEASE}}
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

CB010636-SR-B-B301_02_Counters_to_measure_DL_MAC_layer_UE_throughput_multiple_bursts_NSA_FR2
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_B_B301_02_${RELEASE}}
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

CB010636-SR-B-B301_03_Counters_to_measure_DL_MAC_layer_UE_throughput_HARQ_SANSA_FR1
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_B_B301_03_${RELEASE}}
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

CB010636-SR-C-6CC_019_counters_to_measure_DL_MAC_layer_UE_throughput_at_profile_level_and_non_profile_level_CB011081_interworking
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_C_6CC_019_${RELEASE}}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_6CC_019_UE_CFG}
    ...    trf_duration=15
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate PM Counters
    [Teardown]    Test Teardown
    ...    syslog_stopped_before=${True}

CB010636-SR-C-6CC_022_UE_throughput_per_Mhz_BW_CB011080_interworking
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_C_6CC_022}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_6CC_022_UE_CFG}
    ...             trf_duration=15
    ...             deregister=${True}
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-C-B101_001_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CellSetupReq_CellReconfigurationReq
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_C_B101_001}    config_param_req=${True}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B101_001_UE_CFG}
    ...    trf_duration=${None}
    ...    deregister=False
    ta_emss.Setup EMSS
    ...    bts_id=1
    ...    port=4001
    ta_emss.Configure And Wait
    ...    {'MOC': 'NRBTS', 'ID': '1', 'actPerCCDLUserThpt': 'true', 'actPerCCULUserThpt': 'true', 'thpTimeCalc': 'enabled'}
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=1    trf_dir=dl    expected_traffic_rate_mbps=105
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=2    trf_dir=dl    expected_traffic_rate_mbps=105
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=1    trf_dir=ul    expected_traffic_rate_mbps=53
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=2    trf_dir=ul    expected_traffic_rate_mbps=27
    _logs.Stop Syscom Collection
    _validation.Verify Lo Cell Cell Setup Request Messages
    ...    exp_actperccdluserthpt=0
    ...    exp_actpercculuserthpt=0
    _validation.Verify Lo Cell Cell Reconfiguration Request Messages
    ...    exp_actperccdluserthpt=1
    ...    exp_actpercculuserthpt=1
    _validation.Verify Hi Du Cnfg Config Param Request Messages

CB010636-SR-C-B103_006_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_5GC000527_interworking_discard_parameters
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_C_B103_006}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B103_006_UE_CFG}
    ...             trf_duration=15
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    ...    skip_checking_tti=${True}
    ...    direct_pm_counters_path=${pm1_counters_filepath}
    _env.Toggle Per CC User Throughput Counters
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${C_B103_006_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=11
    _wts.Stop Traffic
    ...    number_of_ues=11
    _logs.Stop TTI Traces Collection
    ${pm2_counters_filepath}=    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    ${discard_thres_0_counters}=    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2
    ...    direct_pm_counters_path=${pm2_counters_filepath}
    _env.Set Data Thres DL Mac Sdu
    ...    type=duration
    ...    value=400
    ...    nrdrb_id=6
    _env.Set Data Thres DL Mac Sdu
    ...    type=volume
    ...    value=5000
    ...    nrdrb_id=6
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${C_B103_006_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=11
    _wts.Stop Traffic
    ...    number_of_ues=11
    ${pm3_counters_filepath}=    _logs.Download Counters Reports
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_3
    ...    direct_pm_counters_path=${pm3_counters_filepath}
    ...    diff_period_counters=${discard_thres_0_counters}

CB010636-SR-C-B201_008_DL_per_CC_UE_throughput_counters_FR1_CB008053_interworking
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_C_B201_008}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=1
    ...    enb_id=2
    _wts.Start Burst Traffic
    ...    ue_id=1
    ...    direction=dl
    ...    burst=60
    ...    size=9000
    ...    period_ms=10
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Stop Traffic
    ...    number_of_ues=1
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    Extract CSV From TTI Trace
     _validation.Validate PM Counters
     ...    suffix=PM_COUNTERS_1

CB010636-SR-C-B201_010_DL_per_CC_UE_throughput_counters_FR1_CB009854_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC
    [Setup]    Test Setup    ${DELTA_C_B201_010}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=1
    ...    enb_id=2
    _wts.Start Burst Traffic
    ...    ue_id=1
    ...    direction=dl
    ...    burst=60
    ...    size=9000
    ...    period_ms=10
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Stop Traffic
    ...    number_of_ues=1
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    ...    direct_pm_counters_path=${pm_counters_filepath}

CB010636-SR-C-B201_011_DL_per_CC_UE_throughput_counters_FR1_CB009855_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC
    [Setup]    Test Setup    ${DELTA_C_B201_011}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=3
    ...    cell_id=3
    ...    enb_id=2
    _wts.Start Burst Traffic
    ...    ue_id=3
    ...    direction=dl
    ...    burst=60
    ...    size=9000
    ...    period_ms=10
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=3
    _wts.Stop Traffic
    ...    number_of_ues=1
    ...    first_ue_id=${3}
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    ...    direct_pm_counters_path=${pm_counters_filepath}

CB010636-SR-C-B202_013_DL_per_CC_UE_throughput_counters_FR2_5GC001726_CB008386_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    ${DELTA_C_B202_013}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B202_013_UE_CFG}
    ...             trf_duration=15
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-C-B202_014_DL_per_CC_UE_throughput_counters_FR2_CB008294_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL_GMC
    [Setup]    Test Setup    scf_gnb1=${SCF_C_B202_014}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Wait For Traffic Running
    ...    duration=5
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B202_014_UE_CFG}
    ...             trf_duration=25
    _wts.Wait For Traffic Running
    ...    duration=5
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-C-B301_015_UL_per_CC_UE_throughput_counters_CB009169_interworking_discard_parameters
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
    [Setup]    Test Setup    ${DELTA_C_B301_015}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    ...    provided_gnb1_ip=10.0.1.2
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B301_015_UE_CFG}
    ...    deregister=${True}
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_1
    ...    provided_gnb1_ip=10.0.1.2
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_1_gnb1.zip
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    ...    dir_to_search=utf_lab_1_gnb1
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_C_B301_VOLTHRES}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    ...    provided_gnb1_ip=10.0.1.2
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B301_015_UE_CFG}
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_2
    ...    provided_gnb1_ip=10.0.1.2
    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_2_gnb1.zip
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2
    ...    dir_to_search=utf_lab_2_gnb1

CB010636-SR-D-B104_01_Update_counters_for_UE_throughput_per_Mhz_BW_SANSA_FR1
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_D_B104_01_${RELEASE}}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${D_B104_01_UE_CFG}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${D_B104_01_UE_CFG_PDU_MODIFICATION_01}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=31   bearer=2    cell_id=12    enb_id=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=32    bearer=2    cell_id=1    enb_id=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=33    bearer=2    cell_id=4    enb_id=2
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_01_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    5
    _wts.Stop Traffic
    ...    number_of_ues=${6}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${2}
    ...    first_ue_id=${7}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${5}
    ...    first_ue_id=${2}
    ...    net_arch=sa
    ...    qfi=2
    _wts.Stop Traffic
    ...    number_of_ues=${3}
    ...    first_ue_id=${31}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Deregister Ues
    ...   sa_ues=1,2,3,4,5,6,7,8
    ...   nsa_ues=31,32,33
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-D-B104_03_Update_counters_for_UE_throughput_per_Mhz_BW_multiple_bursts_FR1
    [Tags]     CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
    [Setup]    Test Setup    ${DELTA_D_B104_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${D_B104_03_UE_CFG}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${D_B104_03_UE_CFG_PDU_MODIFICATION_01}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=102    bearer=2    cell_id=3    enb_id=2
    _wts.Wait For Traffic Running    10
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_03_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${4}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${3}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${102}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_03_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${4}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${3}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${102}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Deregister Ues
    ...   sa_ues=3,4
    ...   nsa_ues=102
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    ${pcapfilepath}    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    direct_pm_counters_path=${pcapfilepath}

CB010636-SR-C-6CC_016_RLC_PDU_volume_counters_for_SA_CA_UEs_and_NSA_CA_UEs_CB011080_interworking
    [Tags]     CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_4CC+ECPRI_CMWV_TDD_4CC
    [Setup]    Test Setup    ${DELTA_C_6CC_016}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_6CC_016_UE_CFG}
    ...    trf_duration=15
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-C-B103_007_BEP
    [Setup]    Test Setup    ${DELTA_C_B103_007}
     ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B103_007_UE_CFG}
    ...    deregister=${True}
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
     Run Keyword And Ignore Error    _validation.Validate PM Counters
     ...    suffix=PM_COUNTERS_1
     _env.Toggle thpTimeCalc
     ...    value=disabled
     ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B103_007_UE_CFG}
    ...    deregister=${True}
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
     Run Keyword And Ignore Error    _validation.Validate PM Counters
     ...    suffix=PM_COUNTERS_1
     _env.Toggle Per CC User Throughput Counters
     ...    counter_status=false
     ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B103_007_UE_CFG}
    ...    deregister=${True}
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
     Run Keyword And Ignore Error     _validation.Validate PM Counters
     ...    suffix=PM_COUNTERS_2
