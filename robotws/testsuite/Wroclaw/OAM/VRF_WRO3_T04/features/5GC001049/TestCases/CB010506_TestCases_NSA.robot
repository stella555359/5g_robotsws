*** Settings ***
Documentation
...              test scenario author: Jakub Zapadka
...              contact: jakub.zapadka@nokia.com
...              test automation author: Konrad Krymowski, Tomasz Domagala
...              contact: konrad.krymowski@nokia.com; tomasz.domagala@nokia.com
...              maintenance: Tomasz Domagala    contact: tomasz.domagala@nokia.com

Resource    ../Resources/CB001049_keywords.robot

*** Keywords ***
CB010506_F_SR_5GC001049-A06_Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane_IPv4_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CRDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-A06_Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane_IPv6_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B10_Adding_new_O&M_controlled_peer_UPlane_IPv4_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B10_Adding_new_O&M_controlled_peer_UPlane_IPv6_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B12_Blocking_access_of_O&M_controlled_peer_UPlane_IPv4_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

CB010506_F_SR_5GC001049-B12_Blocking_access_of_O&M_controlled_peer_UPlane_IPv6_NSA
    [Arguments]    ${scf_file}    ${state}
    Commission BTS And Wait Until Given State
    ...    scf_file=${CURDIR}/../Resources/scf/SubFeature_A/${scf_file}
    ...    state=${state}

