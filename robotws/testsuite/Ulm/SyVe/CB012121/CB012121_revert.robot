*** Settings ***
Documentation   Generic Revert Commissioning for CB012121
...             This is a Robot Test Suite for feature: CB012121
...             Feature:  CB012121
...             Author:  Antje Jooss
...             Team: 'I_MN_RAN_RD_VRF_ULM_VT2_GMS'
...             Email: 'I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com'


Resource    ../resources/sqd63/common_keywords.robot
Resource    ../resources/syve_commissioning.robot
Resource    ../resources/syve_testline.robot
Library     taf.sbts.oam.coam.admin            WITH NAME      admin


*** Keywords ***
Revert GNB Delta Commission JSON For CB012121 GNB-0
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb for CB012121_A, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    Log To Console  Start commissioning for gnb

    scf.Calculate Delta SCF
    ...    target_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...    actual_scf_path=${target_scf_name_gnb}
    ...    delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}

######################################################

Revert GNB Delta Commission JSON For CB012121 gnb-1
    [Documentation]    Commissioning of gnb for TC CB012121_A gnb-1, create new updated SCF with delta changes.
    ...            Only one file is required for updating gnb with delta changes.
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}

    scf.Load SCF  ${basic_scf_name_gnb_${target_node_id}}

    scf.Calculate Delta SCF
    ...  target_scf_path=${basic_scf_name_gnb_${target_node_id}}
    ...  actual_scf_path=${target_scf_name_gnb}
    ...  delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}

