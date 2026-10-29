*** Settings ***
Documentation
...              test scenario author: Jakub Zapadka
...              contact: jakub.zapadka@nokia.com
...              test automation author: Konrad Krymowski, Tomasz Domagala
...              contact: konrad.krymowski@nokia.com; tomasz.domagala@nokia.com
...              maintenance: Tomasz Domagala    contact: tomasz.domagala@nokia.com

Resource    ../Resources/CB001049_keywords.robot

*** Keywords ***
CB010506_F_SR_5GC001049-A01_Feature_status_change_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A02_BTS_startup_first_startup_or_after_reset_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A03_Allowing_access_of_gNB_controlled_neighbor_BTS_using_ANR_procedure_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A04_Blocking_access_of_gNB_controlled_neighbor_BTS_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A05_Adding_new_O&M_controlled_peer_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A06_Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A07_Blocking_access_of_O&M_controlled_peer_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A08_X2_Addition_Modification_access_on_SgNB_CPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B09_BTS_startup_first_startup_or_after_reset_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B10_Adding_new_O&M_controlled_peer_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B11_Change_of_O&M_controlled_peers_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B12_Blocking_access_of_O&M_controlled_peer_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B13_NG_PDU_Session_Resource_Setup_Modification_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B14_NG_based_Handover_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B15_XN_based_Handover_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B16_X2_Addition_Modification_access_on_SgNB_UPlane_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B17_Robustness_Frequent_addition_removal_of_firewall_rules_IPv4
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}
