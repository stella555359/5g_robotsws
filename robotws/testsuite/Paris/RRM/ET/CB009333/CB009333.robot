*** Settings ***
Documentation
...    author: Damian Zak, Mateusz Pajor, Damian Piasecki
...    maintainer: Damian Zak, Mateusz Pajor, Damian Piasecki
...    contact: damian.zak@nokia.com, mateusz.pajor@nokia.com, damian.piasecki@nokia.com
...    description: Merged Test Suite for CB009333-A, CB009333-B, CB009333-C, CB009333-D, CB009333-E, CB009333-F
...    topology: CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    resources/CB009333_keywords.robot

Suite Setup     CB009333 Suite Setup
Test Teardown   CB009333 Test Teardown

*** Test Cases ***
CB009333_A_001_Delay_parameters_depending_on_traffic_from_single_non-GBR_service_SA_FDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_A_TC001_DELTA}
    Attach With Traffic And Logs
    ...    net_arch=SA
    ...    num_of_ues=1
    ...    cells=3
    ...    qfi=1
    ...    burst=1
    ...    size_dl=3000
    ...    cells=3
    Validate Micro DTX Counters
    ...    cell_to_check=3
    ...    micro_dtx_no_bund_condition=>=0
    Validate SA Non GBR Counters
    ...    cell_to_check=3
    Validate TTITrace Logs

CB009333_A_004_Delay_parameters_depending_on_traffic_from_multiple_non-GBR_services_NSA_TDD
    [Tags]    CDRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_A_TC004_DELTA}
    ...    net_arch=NSA
    Attach With Traffic And Logs
    ...    net_arch=NSA
    ...    num_of_ues=1
    ...    bearer=2,3
    ...    burst=1
    ...    size_dl=3000
    ...    delay_traffic_stop=${True}
    Validate Micro DTX Counters
    ...    micro_dtx_no_bund_condition=>=0
    Validate NSA Non GBR Counters
    Validate TTITrace Logs

CB009333_B_006_Multiple_cells_with_low_traffic_dtxRoundingOffset_6_NSA_TDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_B_TC006_DELTA}
    ...    net_arch=NSA
    ...    arfcn_gscn_change=${True}
    ...    gscn_value=${GSCN_VALUE_TDD}
    Attach With Traffic And Logs
    ...    net_arch=NSA
    ...    num_of_ues=2
    ...    bearer=2
    ...    cells=1,2
    ...    burst=1
    ...    size_dl=3000
    ...    period_ms=100
    Validate Micro DTX Counters
    ...    cell_to_check=1
    ...    micro_dtx_no_bund_condition=>=0
    Validate NSA Non GBR Counters
    ...    cell_to_check=1
    ...    number_of_bearer_requests=2
    Validate Micro DTX Counters
    ...    cell_to_check=2
    ...    micro_dtx_no_bund_condition=>=0
    Validate NSA Non GBR Counters
    ...    cell_to_check=2
    ...    number_of_bearer_requests=2
    Validate TTITrace Logs

CB009333_C_007_CA_micro_DTX_optimized_scheduling_enabled_on_SCell_bufferBased_SA_FDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_C_TC007_DELTA}
    ...    nr_ue_caps=${UE_CAP_C}
    ...    arfcn_gscn_change=${True}
    ...    gscn_value=${GSCN_VALUE_FDD}
    Attach With Traffic And Logs
    ...    net_arch=SA
    ...    num_of_ues=1
    ...    cells=3
    ...    qfi=1
    ...    burst=22
    ...    size_dl=8000
    Validate Micro DTX Counters
    ...    micro_dtx_optim_condition=<10
    ...    micro_dtx_no_bund_condition=<10
    ...    cell_to_check=3
    Validate Micro DTX Counters
    ...    cell_to_check=4
    Validate SA Non GBR Counters
    ...    cell_to_check=3
    Validate TTITrace Logs
    Validate Syslog
    ...     syslog_prints=${SYSLOG_PRINTS_CA}

CB009333_C_011_CA_micro_DTX_optimized_scheduling_enabled_on_PCell_blind_SA_FDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_C_TC011_DELTA}
    ...    nr_ue_caps=${UE_CAP_C}
    ...    arfcn_gscn_change=${True}
    ...    gscn_value=${GSCN_VALUE_FDD}
    Attach With Traffic And Logs
    ...    net_arch=SA
    ...    num_of_ues=1
    ...    qfi=1
    ...    cells=3
    Validate Micro DTX Counters
    ...    cell_to_check=3
    Validate Micro DTX Counters
    ...    micro_dtx_optim_condition===0
    ...    micro_dtx_no_bund_condition===0
    ...    cell_to_check=4
    Validate SA Non GBR Counters
    ...    cell_to_check=3
    Validate TTITrace Logs
    Validate Syslog
    ...     syslog_prints=${SYSLOG_PRINTS_CA}

CB009333_D_013_micro-DTX_scheduler_with_DRX_SA_FDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_D_TC013_DELTA}
    Attach With Traffic And Logs
    ...    net_arch=SA
    ...    num_of_ues=1
    ...    cells=3
    ...    qfi=1
    ...    traffic_direction=bi
    ...    size_dl=600
    ...    size_ul=1000
    ...    cells=3
    Validate Micro DTX Counters
    ...    cell_to_check=3
    Validate SA Non GBR Counters
    ...    cell_to_check=3
    ...    number_of_bearer_requests=2
    Validate DRX Sleep Active Time
    Validate TTITrace Logs

CB009333_E_015_IWK_9084_micro-DTX_scheduler_with_Slice_Aware_Scheduler_SA_FDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_E_DELTA}
    ...    slice_scheduler=${True}
    ...    sib_reception_dict=${ALL_CELLS_SIB_RECEPTION_DICT}
    Attach With Traffic And Logs For Slice Aware Scheduler
    ...    net_arch=SA
    ...    num_of_ues=2
    ...    cells=3
    ...    qfi=1,2
    ...    nwslice=1,2
    ...    burst=17
    ...    size_dl=8192
    pm_counters.Validate Slice Scheduler Counters
    ...    resource_groups_nsa_sa={'SA': (1,2)}
    ...    nrresourcegroup_values={'1':(1,2)}
    ...    cell=3
    Validate Micro DTX Optim Condition
    ...    cell_to_check=3
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Validate Micro DTX Counters
    ...    cell_to_check=3
    Convert TTItrace Slice Scheduler
    Validate TTITrace Logs
    ...    pcap_file_name=tti_trace_traffic.pcap

CB009333_F_018_RLC_status_PDU_handling_NSA_TDD
    [Tags]    CRT    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Setup]    CB009333 Test Setup
    ...    delta_path=${CB009333_F_TC018_DELTA}
    ...    net_arch=NSA
    Attach With Traffic And Logs
    ...    net_arch=NSA
    ...    traffic_direction=ul
    ...    num_of_ues=1
    ...    bearer=2
    ...    size_ul=6000
    Validate NSA Non GBR Counters
    Validate Micro DTX Counters
    ...    micro_dtx_no_bund_condition=<5
    ...    micro_dtx_optim_condition=<5
    Validate Harq Counter
    Validate TTITrace Logs
