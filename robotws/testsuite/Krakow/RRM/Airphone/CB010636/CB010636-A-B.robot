*** Settings ***
Documentation
...   author: Anna Bien
...   maintainer: Anna Bien
...   contact: anna.bien@nokia.com

Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-A-B103_01_RLC_PDU_volume_counters_new_flag_bearerType_SANSA_FR1
    [Setup]    Test Setup    delta_gnb1=${DELTA_A_B103_01}
    _logs.Start Syscom Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${A_B103_01_UE_CFG}
    _logs.Stop Syscom Collection
    Check Hi User Du Bearer Setup Req Messages

CB010636-SR-A-B104_01_L2HI_RLC_PDU_volume_counters_for_CA_Ues_SANSA_FR1
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
    ...    _logs.Collect Logs After Test
    ...    common_wts.Stop WTS And Clear
    ...    _env.Restore Default Iphy
    ...    _env.Restore Default SCFs

CB010636-SR-A-B104_02_L2HI_RLC_PDU_volume_counters_for_inter_CA_Ues_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_A_A1_02_GNB1}    ${DELTA_A_A1_02_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${A_B104_02_UE_CFG}
    _logs.Stop TTI Traces Collection
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-A-B104_03_L2HI_RLC_PDU_volume_counters_for_CA_Ues_SA_FR2
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

CB010636-SR-A-B202_02_RLC_PDU_volume_counters_for_CA_and_non_CA_DRBs_of_CA_Active_UE_inter_CA_SA_FR1
    [Setup]    Test Setup    ${DELTA_A_B202_02_GNB1}      ${DELTA_A_B202_02_GNB2}
     _wts.Attach Multiple SA Ues And Establish Pdu Session    ${A_B202_02_UE_CFG}
     _wts.Define Pdu Session Modification       ${A_B_202_02_UE_CFG_PDU_MODIFICATION_1}
     ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Start Traffic Multiple Ues    ${A_B202_02_UE_CFG_TRAFFIC_1}
    _wts.Wait For Traffic Running    10
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    _logs.Restart Dcap
    _env.Perform Delta Recommissioning
    ...     delta_path_gnb1=${DELTA_A_B202_02_ONLINE_CHANGE_GNB1}
    ...     delta_path_gnb2=${DELTA_A_B202_02_ONLINE_CHANGE_GNB2}
    _wts.Define Pdu Session Modification       ${A_B_202_02_UE_CFG_PDU_MODIFICATION_2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Start Traffic Multiple Ues    ${A_B202_02_UE_CFG_TRAFFIC_2}
    _wts.Wait For Traffic Running    10
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_2

CB010636-SR-A-B202_03_RLC_PDU_volume_counters_for_CA_and_non_CA_DRBs_of_CA_Active_UE_interaction_with_UL_CB009059_FR1
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
