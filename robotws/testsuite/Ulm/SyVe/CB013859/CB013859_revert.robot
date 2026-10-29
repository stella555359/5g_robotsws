*** Settings ***
Documentation   Generic Revert Commissioning for CB006139
...             This is a Robot Test Suite for feature: CB006139
...             Feature:  CB006139 Buffer-based step-wise NR FR1 SCell addition
...             Author:  Antje Jooss
...             Team: 'I_MN_RAN_RD_VRF_ULM_VT2_GMS'
...             Email: 'I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com'


Resource    ../resources/syve_commissioning.robot
Library     taf.config.scf


*** Keywords ***
Revert GNB Delta Commission JSON For CB013859 Source Node GNB
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB013859, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb

    scf.calculate delta scf
    ...    target_scf_path=${BASIC_SCF_NAME_GNB_${SOURCE_node_id}}
    ...    actual_scf_path=${target_scf_name_gnb}
    ...    delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}


Revert gNB Delta Commission JSON For CB013859 Target Node GNB
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB013859, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb

    scf.calculate delta scf
    ...    target_scf_path=${BASIC_SCF_NAME_GNB_${TARGET_node_id}}
    ...    actual_scf_path=${target_scf_name_gnb}
    ...    delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}
