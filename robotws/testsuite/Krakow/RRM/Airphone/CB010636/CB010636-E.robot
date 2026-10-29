*** Settings ***
Documentation
...   author: Anna Bien, Przemysław Herian, Kamil Pokusa
...   maintainer: Anna Bien, Przemysław Herian, Kamil Pokusa
...   contact: anna.bien@nokia.com

Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-E-B101_01_Online_activation_of_reporting_of_DL_MAC_SDU_user_throughput_PM_counters_inter_CA_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_E_B101_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${E_B101_01_UE_CFG}
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    # Verification PMC

CB010636-SR-E-B201_01_Counters_to_measure_DL_MAC_layer_UE_throughput_at_profile_and_non_profile_level_inter_CA_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_E_B201_01_GNB1}    ${DELTA_E_B201_01_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${E_B201_01_UE_CFG}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${E_B201_01_UE_CFG_PDU_MODIFICATION_01}
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${E_B201_01_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    20
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${5}
    ...    net_arch=sa
    ...    qfi=2
    _wts.Deregister Ues
    ...   sa_ues=1,2,3,4,5
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1


CB010636-SR-E-B201_02_Counters_to_measure_DL_MAC_layer_UE_throughput_at_profile_and_non_profile_level_inter_CA_SANSA_FR1_robustness
    [Setup]    Test Setup    ${DELTA_E_B201_02}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Register Multiple UEs And Handle Traffic
    ...             ues_conf=${E_B201_02_UE_CFG}
    ta5g_pm_counters.Wait For Next Full PM Interval
    #2 Check following counters. TTI traces will be helpful.
