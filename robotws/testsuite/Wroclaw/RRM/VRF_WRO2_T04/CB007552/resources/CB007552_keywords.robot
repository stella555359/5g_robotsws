*** Settings ***
Documentation
...   feature keywords

Library     ute_ue
Library     CB007552.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource    ../../resources/attach_verification.robot
Resource    ../../../resources/connections.robot
Resource    ../../regression/regression_keywords.robot
Resource   ../../../resources/logs.robot
Resource   ../../../resources/swconfig_operations.robot
Library    ../../5GC001167/resources/pcap_verifiers.py
Variables   ./variables_7552.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Library       ta5g_cell_operations


*** Keywords ***
Env teardown
    Stop tracing on SMOD
    ute_ue.Detach Ue           UE_1

Set att environment
    [Arguments]     ${cell_101_value}=90  ${cell_104_value}=90  ${cell_51_value}=90
    ...             ${cell_105_value}=90  ${cell_106_value}=90  ${cell_107_value}=0
    Initialise Attenuator
    Set Attenuation   ${cell_101_value}   confirm=${TRUE}  port=${ATTENUATOR['NRCELL_101']['ports']}
    Set Attenuation   ${cell_104_value}   confirm=${TRUE}  port=${ATTENUATOR['NRCELL_104']['ports']}
    Set Attenuation   ${cell_51_value}    confirm=${TRUE}  port=${ATTENUATOR['LNCELL_51']['ports']}
    Set Attenuation   ${cell_105_value}   confirm=${TRUE}  port=${ATTENUATOR['NRCELL_105']['ports']}
    Set Attenuation   ${cell_106_value}  confirm=${TRUE}  port=${ATTENUATOR['NRCELL_106']['ports']}
    Set Attenuation   ${cell_107_value}  confirm=${TRUE}  port=${ATTENUATOR['NRCELL_107']['ports']}

prepare testline for NSA
    Set att environment   cell_105_value=90  cell_106_value=0  cell_107_value=0

Check CA status
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    check CA      ${log_path}   1

Verify expected Large Pcell BWP for NSA
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    ...    ${PC_physCellId}=51    ${PC_FreqBandIndicatorNR}=28    ${PC_carrierBandwidth}=106
    ...    ${SC_physCellId}=52    ${SC_FreqBandIndicatorNR}=41    ${SC_carrierBandwidth}=273
    Verify Pcell dedicated channel bandwidth for NSA    ${log_path}
    ...    ${PC_physCellId}    ${PC_FreqBandIndicatorNR}    ${PC_carrierBandwidth}
    ...    ${SC_physCellId}    ${SC_FreqBandIndicatorNR}    ${SC_carrierBandwidth}

Verify expected Large Pcell BWP for SA
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap    ${freqBand_nrofRBs}=160   ${scramblingID}=107
    Verify Pcell dedicated channel bandwidth for SA    ${log_path}    ${freqBand_nrofRBs}    ${scramblingID}

Unblock Previous Target Cell
    [Arguments]   ${cell}=${old_target_cell}
    WebUI.create_session
    WebUI.cell_unlock   cell_id=${CELL_SETTINGS['${cell}']['cell_no']}
    Log To Console    \n Target cell, Global cell ID: ${CELL_SETTINGS['${cell}']['cell_no']} is UNBLOCKED
    [Teardown]  WebUI.teardown_session
