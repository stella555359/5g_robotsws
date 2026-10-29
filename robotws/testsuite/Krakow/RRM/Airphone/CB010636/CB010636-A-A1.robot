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
[1]CB010636-SR-A-A1_01_L2LO_RLC_PDU_volume_counters_for_CA_Ues_SANSA_FR1
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
    ...    ues_conf=${A_A1_03_CELL1_UE_CFG}
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

[1]CB010636-SR-A-A1_04_L2LO_RLC_PDU_volume_counters_for_CA_Ues_NSA_FR2
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

[1]CB010636-SR-A-B202_01_RLC_PDU_volume_counters_for_CA_and_non_CA_DRBs_of_CA_Active_UE_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_A_B202_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ${pm_counters_filepath}=    _logs.Download Counters Reports
