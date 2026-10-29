*** Settings ***
Documentation
...   author: Aleksandra Zbieg, Przemyslaw Herian, Anna Bien
...   maintainer: Aleksandra Zbieg, Przemyslaw Herian, Anna Bien
...   contact: aleksandra.zbieg@nokia.com, przemyslaw.herian@nokia.com, anna.bien@nokia.com
...   description: The goal of these tests is to verify US-CNI111300#1 and US-CNI111300#IWK4.

Resource    resources/CNI_111300_resources.robot

Suite Setup      CNI_111300_resources.Suite Setup
Test Teardown    CNI_111300_resources.Test Teardown

*** Test Cases ***
[1]CNI111300-A-B1-04_DL_data_split_FR2_SA_CA_8CC_DL_4CC
    [Setup]    CNI_111300_resources.Test Setup    mib_dict=${SIB_DICT_FR2}    delta=${DELTA_CNI111300_A_B1_04}
    Setup.Produce Scout Data
    ta5g_pm_counters.Wait For Next Full PM Interval
    common_wts.Attach Ue And Establish Pdu Session
    ...    ue_id=1
    ...    cell_id=1
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    traffic_direction=bi
    ...    first_ue_id=1
    ...    net_arch=sa
    ...    ul_mbps=150
    ...    dl_mbps=150
    _internal.Wait For Traffic Running
    ${kpi_cni_disabled_low} =    _validation.Get NR 70b KPI Value
    ${cni_disabled_low_dl_tput}    ${cni_disabled_low_ul_tput}=    _internal.Get UE Throughput Sum
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    traffic_direction=bi
    ...    first_ue_id=1
    ...    net_arch=sa
    ...    dl_mbps=1000
    ...    first_trf_id=3
    _internal.Wait For Traffic Running
    ${kpi_cni_disabled_high} =    _validation.Get NR 70b KPI Value
    ${cni_disabled_high_dl_tput}    ${cni_disabled_high_ul_tput}=    _internal.Get Average UE Tput Sum From Intervals
    _logs.Collect Snapshot
    ...    filename=snapshot_cni_disabled.zip
    common_wts.Deregister UE
    ...    ue_id=1
    _internal.Change ActOptimizedFlowControl Value
    ...    value=optimizedAllUe
    ta5g_pm_counters.Wait For Next Full PM Interval
    common_wts.Attach Ue And Establish Pdu Session
    ...    ue_id=1
    ...    cell_id=1
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    traffic_direction=bi
    ...    first_ue_id=1
    ...    net_arch=sa
    ...    ul_mbps=150
    ...    dl_mbps=150
    _internal.Wait For Traffic Running
    ${kpi_cni_enabled_low} =    _validation.Get NR 70b KPI Value
    ${cni_enabled_low_dl_tput}    ${cni_enabled_low_ul_tput}=    _internal.Get UE Throughput Sum
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    traffic_direction=bi
    ...    first_ue_id=1
    ...    net_arch=sa
    ...    dl_mbps=1000
    ...    first_trf_id=3
    _internal.Wait For Traffic Running
    ${kpi_cni_enabled_high} =    _validation.Get NR 70b KPI Value
    ${cni_enabled_high_dl_tput}    ${cni_enabled_high_ul_tput}=     _internal.Get Average UE Tput Sum From Intervals
    _validation.Compare NR 70b KPI Values
    ...    value_fr_enabled=${kpi_cni_enabled_low}
    ...    value_fr_disabled=${kpi_cni_disabled_low}
    _validation.Compare NR 70b KPI Values
    ...    value_fr_enabled=${kpi_cni_enabled_high}
    ...    value_fr_disabled=${kpi_cni_disabled_high}
#    _validation.Compare UE Throughput Values
#    ...    value_dl_fr_enabled=${cni_enabled_low_dl_tput}
#    ...    value_dl_fr_disabled=${cni_disabled_low_dl_tput}
#    ...    value_ul_fr_enabled=${cni_enabled_low_ul_tput}
#    ...    value_ul_fr_disabled=${cni_disabled_low_ul_tput}
    _validation.Compare UE Throughput Values
    ...    value_dl_fr_enabled=${cni_enabled_high_dl_tput}
    ...    value_dl_fr_disabled=${cni_disabled_high_dl_tput}
    ...    value_ul_fr_enabled=${cni_enabled_high_ul_tput}
    ...    value_ul_fr_disabled=${cni_disabled_high_ul_tput}
