*** Settings ***
Documentation
...   author: Anna Bien, Przemysław Herian, Kamil Pokusa, Damian Zak
...   maintainer: Przemysław Herian
...   contact: przemyslaw.herian@nokia.com

Library     ta_emss
Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-C-B101_001_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CellSetupReq_CellReconfigurationReq
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL
    [Setup]    Test Setup    config_param_req=${True}
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
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=1    trf_dir=ul    expected_traffic_rate_mbps=40
    _wts.Verify Traffic On SCell For UE    ue_id=11    scell_id=2    trf_dir=ul    expected_traffic_rate_mbps=35
    _logs.Stop Syscom Collection
    _validation.Verify Lo Cell Cell Setup Request Messages
    ...    exp_actperccdluserthpt=0
    ...    exp_actpercculuserthpt=0
    _validation.Verify Lo Cell Cell Reconfiguration Request Messages
    ...    exp_actperccdluserthpt=1
    ...    exp_actpercculuserthpt=1
    _validation.Verify Hi Du Cnfg Config Param Request Messages

CB010636-SR-C-B102_003_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_DU_DDDS_modification
    [Setup]    Test Setup    delta_gnb1=${DELTA_C_B102_003_GNB1}    delta_gnb2=${DELTA_C_B102_003_GNB2}    reboot=False    delta_reboot=True
    _wts.Wait For Traffic Running
    ...    duration=45
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${C_B102_003_UE_CFG}
    ...    trf_duration=${None}
    ...    deregister=False
    _wts.Wait For Traffic Running
    ...    duration=30
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=0    trf_dir=dl    expected_traffic_rate_mbps=100    error_margin=50
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=1    trf_dir=dl    expected_traffic_rate_mbps=100    error_margin=50
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=0    trf_dir=ul    expected_traffic_rate_mbps=80     error_margin=50
    _logs.Collect IP Traffic Capturing Traces To File
    ...    time=1
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=${True}
    ...    file_name=${OUTPUTDIR}/${TEST_NAME}/legacy_DDDS
    _validation.Verify DDDS Messages
    ...    is_feature_enabled=${False}
    ...    file_path=${OUTPUTDIR}/${TEST_NAME}/legacy_DDDS.pcap
    _wts.Wait For Traffic Running
    ...    duration=15
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_C_B102_003_GNB1_activation}
    ...    delta_path_gnb2=${DELTA_C_B102_003_GNB2_activation}
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=0    trf_dir=dl    expected_traffic_rate_mbps=100    error_margin=50
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=1    trf_dir=dl    expected_traffic_rate_mbps=100    error_margin=50
    _wts.Verify Traffic On SCell For UE    ue_id=1    scell_id=0    trf_dir=ul    expected_traffic_rate_mbps=80     error_margin=50
    _logs.Collect IP Traffic Capturing Traces To File
    ...    time=1
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=${True}
    ...    file_name=${OUTPUTDIR}/${TEST_NAME}/new_DDDS
    _validation.Verify DDDS Messages
    ...    is_feature_enabled=${True}
    ...    file_path=${OUTPUTDIR}/${TEST_NAME}/new_DDDS.pcap
    [Teardown]    Run Keyword If Test Failed    Stop Ip Traffic Capturing And Download File    file_name=${OUTPUTDIR}/teardown.pcap.gz

CB010636-SR-C-B103_004_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CB005934_interworking_discard_parameters
    [Setup]    Test Setup    ${DELTA_C_B103_004}
     ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=11
    ...    enb_id=2
     _wts.Start Burst Traffic
     ...    ue_id=1
     ...    direction=dl
     ...    burst=60
     ...    size=9000
     ...    period_ms=40
     _wts.Wait For Traffic Running
     ...    duration=15
     _wts.Get UE Throughput Stats
     ...    ue_id=1
     _wts.Stop Traffic
     ...    number_of_ues=1
     ${pm1_counters_filepath}=    _logs.Download Counters Reports
     _validation.Validate PM Counters
     ...    suffix=PM_COUNTERS_1
     ...    skip_checking_tti=${True}
     ...    direct_pm_counters_path=${pm1_counters_filepath}
    _env.Toggle Per CC User Throughput Counters
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Start Burst Traffic
    ...    ue_id=1
    ...    direction=dl
    ...    burst=60
    ...    size=9000
    ...    period_ms=40
     _wts.Start Burst Traffic
     ...    ue_id=1
     ...    direction=dl
     ...    burst=60
     ...    size=200
     ...    period_ms=100
     ...    trf_id=2
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Stop Traffic
    ...    number_of_ues=1
    _logs.Stop TTI Traces Collection
    ${pm2_counters_filepath}=    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    ${discard_thres_0_counters}=    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2
    ...    direct_pm_counters_path=${pm2_counters_filepath}
    _env.Set Data Thres DL Mac Sdu
    ...    type=duration
    ...    value=300
    ...    nrdrb_id=11
    _env.Set Data Thres DL Mac Sdu
    ...    type=volume
    ...    value=20000
    ...    nrdrb_id=11
    ta5g_pm_counters.Wait For Next Full PM Interval
     _wts.Start Burst Traffic
     ...    ue_id=1
     ...    direction=dl
     ...    burst=60
     ...    size=9000
     ...    period_ms=40
     ...    trf_id=1
     _wts.Start Burst Traffic
     ...    ue_id=1
     ...    direction=dl
     ...    burst=60
     ...    size=200
     ...    period_ms=100
     ...    trf_id=2
    _wts.Wait For Traffic Running
    ...    duration=15
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Stop Traffic
    ...    number_of_ues=1
    ${pm3_counters_filepath}=    _logs.Download Counters Reports
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_3
    ...    direct_pm_counters_path=${pm3_counters_filepath}
    ...    diff_period_counters=${discard_thres_0_counters}

CB010636-SR-C-B103_005_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CB007949_interworking_multiple_UE
    [Setup]    Test Setup    ${DELTA_C_B103_005}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B103_005_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    #Activate the per CC user throughput PM counters
    #7 Start traffic only for 15s
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-B103_006_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_5GC000527_interworking_discard_parameters
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

CB010636-SR-C-B103_007_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CB005935_interworking
    [Setup]    Test Setup    ${DELTA_C_B103_007}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B103_007_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    #6 Activate the per CC user throughput PM counters
    #7 Start traffic only for 15s
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-B201_008_DL_per_CC_UE_throughput_counters_FR1_CB008053_interworking
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

CB010636-SR-C-B201_009_DL_per_CC_UE_throughput_counters_FR1_CB008140_interworking
    [Setup]    Test Setup    ${DELTA_C_B201_009}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B201_009_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-B201_010_DL_per_CC_UE_throughput_counters_FR1_CB009854_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
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
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
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

CB010636-SR-C-B202_012_DL_per_CC_UE_throughput_counters_FR2_5GC001725_interworking_multiple_UE
    [Setup]    Test Setup    ${DELTA_C_B201_012}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_B202_012_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-B202_013_DL_per_CC_UE_throughput_counters_FR2_5GC001726_CB008386_interworking
    [Tags]     CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL
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


CB010636-SR-C-6CC_016_RLC_PDU_volume_counters_for_SA_CA_UEs_and_NSA_CA_UEs_CB011080_interworking
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

CB010636-SR-C-6CC_017_RLC_PDU_volume_counters_for_SA_CA_UEs_and_NSA_CA_UEs_CB011081_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_017}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_6CC_017_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-6CC_018_online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_CB011080_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_018}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_6CC_018_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    #6 Activate the DL MAC SDU user throughput PM
    #7 Start traffic only for 15s
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC



CB010636-SR-C-6CC_019_counters_to_measure_DL_MAC_layer_UE_throughput_at_profile_level_and_non_profile_level_CB011081_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_019}
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

CB010636-SR-C-6CC_020_online_activation_of_reporting_of_per_CC_combination_user_throughput_PM_counters_CB011080_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_020}
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
    ${pm1_counters_filepath}=    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    ...    skip_checking_tti=${True}
    ...    direct_pm_counters_path=${pm1_counters_filepath}
    _env.Toggle Per CC User Throughput Counters
    ta5g_pm_counters.Wait For Next Full PM Interval
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
    ${pm2_counters_filepath}=    _logs.Download Counters Reports
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2

CB010636-SR-C-6CC_021_DL_per_CC_UE_throughput_counters_CB011081_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_021}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_6CC_021_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-C-6CC_022_UE_throughput_per_Mhz_BW_CB011080_interworking
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


CB010636-SR-C-6CC_023_UE_throughput_per_Mhz_BW_CB011081_interworking
    [Setup]    Test Setup    ${DELTA_C_6CC_023}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${C_6CC_023_UE_CFG}
    ...             trf_duration=15
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC
