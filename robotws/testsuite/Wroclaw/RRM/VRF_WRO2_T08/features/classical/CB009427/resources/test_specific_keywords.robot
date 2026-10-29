*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Library    ./test_specific_keywords.py

*** Variables ***
${UE_ALIAS}    UE_1
${DT_ALIAS}    DT_1
${UE_APP}  ELT
${CELL_ID}   193
${INIT_ATTEN}  ${20}
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT192/ue_config.yaml


*** Keywords ***
[1][1.0]_CB009427_A_Activation_and_deactivation_of_Adaptive_UL_BLER_from_WebEM
    Disable Adaptive UL Bler Target   ${SCF_params}
    Force Good Condition Only On Cell   GNB_1_CELL_${CELL_ID}   ${INIT_ATTEN}dB
    Attach UE     ${UE_ALIAS}
    Start Data Transfer   ${DT_ALIAS}   ${UE_ALIAS}   ul  1800s   protocol=tcp
    ${disabled_values}=   Tput Curve CB009427   ${CELL_ID}   ${INIT_ATTEN}   ${UE_APP}   ${SCF_params}
    Verify Feature Disabled   ${disabled_values}
    Stop Data Transfer   ${DT_ALIAS}
    Detach UE    ${UE_ALIAS}
    Enable Adaptive UL BLER Target    ${SCF_params}
    Force Good Condition Only On Cell   GNB_1_CELL_${CELL_ID}   ${INIT_ATTEN}dB
    Attach UE    ${UE_ALIAS}
    Start Data Transfer   ${DT_ALIAS}   ${UE_ALIAS}   ul  1800s   protocol=tcp
    ${enabled_values}=    Tput Curve CB009427   ${CELL_ID}   ${INIT_ATTEN}   ${UE_APP}   ${SCF_params}
    Verify Feature Enabled   ${enabled_values}
    [Teardown]  Teardown CB009427


Setup CB009427
    ${SCF_file}=   Backup Current SCF   ${OUTPUT_DIR}   backup_nr_scf.xml
    ${SCF_params}=  Get Current NRCELL Parameter Dict   ${CELL_ID}  ${SCF_file}
    Set Test Variable   ${SCF_params}
    Ensure Pre Set SCF Parameters   ${SCF_params}
    Setup Attenuator
    Require UE    ${UE_ALIAS}   capabilities=REAL_UE


Teardown CB009427
    Stop Data Transfer  ${DT_ALIAS}
    Detach UE   ${UE_ALIAS}
    Restore Original SCF   ${SCF_params}
    Release Attenuator
