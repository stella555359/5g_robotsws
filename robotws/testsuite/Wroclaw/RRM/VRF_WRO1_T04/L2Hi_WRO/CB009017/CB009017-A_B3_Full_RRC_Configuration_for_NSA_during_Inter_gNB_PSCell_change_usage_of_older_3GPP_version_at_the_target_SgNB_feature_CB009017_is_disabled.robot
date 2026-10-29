*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py

Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    release: 24R1

Suite Setup     Run Keywords    Enable NSA HO    AND    Enable Full Rrc Reconfiguration
Test Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure NSA VM interfaces
    ...       AND    Reach OnAir    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Setup X2 Links And Create Aliases For Gnb2 And Gnb3
    ...       AND    Disable Full Rrc Reconfiguration

Test Teardown    Send Configuration ID To Scout

Suite Teardown    Run Keywords   Detach Ue    ue_id=${ue_id}
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs
    ...           AND            Check For An Unexpected Alarm

*** Variables ***
${UE_NR_CAPA}=   2D000000010800200004D000082606DFB5F780000000000001150000000000000150

*** Test Cases ***
CB009017-A_B3_Full_RRC_Conf_for_NSA_during_Inter_gNB_PSCell_change_usage_of_older_3GPP_version_at_the_target_SgNB_feature_CB009017_is_disabled
    Attach NSA Ue And Start Data Traffic    ue_nr_capabilities=${UE_NR_CAPA}
    Handling Critical Ext And RRCReconf-v1700 IEs in SgNB Change Required
    Verify That Expected Throughput Is Achieved
    Expect PSCell change flow for UE11
    UE11 sends measurement with eventA5 triggering PSCell change to gNB3
    Verify successful PSCell change for UE11
