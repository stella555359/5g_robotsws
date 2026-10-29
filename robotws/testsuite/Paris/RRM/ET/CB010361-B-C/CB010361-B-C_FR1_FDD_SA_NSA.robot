*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Test suite for feature CB010361-B-C - SR - VRF - RRM - ET
...   Requested topology : CLOUD_5G_I_MP_AP_LO    SANSA_FS_CPRI_CMWV_FDD

Resource            ./resources/robot/CB010361-Common-Keywords.robot

Suite Setup         CB010361-Common-Keywords.Suite_Setup
Suite Teardown      CB010361-Common-Keywords.Suite_Teardown

Force Tags      CA_VRF_RRM    QCD_MN_RAN    QCP_RAN_VRF   SBTS00

*** Variables ***

${JSON_FILE_PATH}    ${CURDIR}/resources/config/CB010361-B-C_pcmd_activation.json

*** Test Cases ***

CB010361-B-C_SA
    [Setup]    Run Keywords    CB010361-Common-Keywords.Test Setup
	...                         AND
	...                        Test Setup CB010361-SR-C
    [Documentation]
    ...    | Description | CB010361-B-C SA |
    ...    | . | .       |
	...    | Test Steps  | 1. test preparation |
    ...    | Test Steps  | 2. Start wireshark Logs |
    ...    | Test Steps  | 3. Do UL and DL traffic SA |
    ...    | Test Steps  | 4. Stop wireshark Logs collections |
    ...    | Test Steps  | 5. Stop traffic |

	${ue1}    Set Variable    1
	${ue2}    Set Variable    2
    ##########################################################################################
    #2. start wireshark Logs
    ##########################################################################################
    Start To Capture UTE Wireshark
    sleep    30s
    ##########################################################################################
    #3. Do UL and DL traffic SA
    ##########################################################################################
    Traffic_DL_UL_SA    ue=${ue1}
    Traffic_DL_UL_SA    ue=${ue2}
    ##########################################################################################
    #4. Stop wireshark Logs collections
    ##########################################################################################
    Stop Capture UTE Wireshark
	##########################################################################################
    #5. Stop traffic
    ##########################################################################################
	Traffic_DL_UL_SA_stop    ue=${ue1}
    Traffic_DL_UL_SA_stop    ue=${ue2}
    [Teardown]    CB010361-Common-Keywords.Test Teardown

[1][1.0] CB010361-SR-B2_8_Monitoring_PCMD_RLC_layer_L2-HI_UL_FR1_FDD_SA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-B2_8_Monitoring_PCMD_RLC_layer_L2-HI_UL_FR1_FDD_SA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for RLC |
    ...    | Test Steps  | 3. Transfer the logs |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_B_HI_UL_FR1_FDD_SA
    ##########################################################################################
    #2. Verify PCMD counters for RLC
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${ulRbHighRlcMeasRecord_numOfRlcSduRx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${ulRbHighRlcMeasRecord_sumOfRlcSduRxBytes}' == 'True'
    Run Keyword If    '${ulRbHighRlcMeasRecord_numOfRlcSduRx}'=='False'
    ...    Log To Console    ulRbHighRlcMeasRecord_numOfRlcSduRx not found please check logs
    Run Keyword If    '${ulRbHighRlcMeasRecord_sumOfRlcSduRxBytes}'=='False'
    ...    Log To Console    ulRbHighRlcMeasRecord_sumOfRlcSduRxBytes not found please check logs
    ##########################################################################################
    #3. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_B}

[1][1.0] CB010361-SR-C1_9_Monitoring_PCMD_PDCP_layer_MBA_DL_FR1_FDD_SA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-C1_9_Monitoring_PCMD_PDCP_layer_MBA_DL_FR1_FDD_SA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for PDCP layers |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_C
    ##########################################################################################
    #2. Verify PCMD counters for PDCP layers
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbPdcpMeasRecord_numOfPdcpSduTx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}' == 'True'
    Run Keyword If    '${dlRbPdcpMeasRecord_numOfPdcpSduTx}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    Run Keyword If    '${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs

[1][1.0] CB010361-SR-C1_16_Monitoring_PCMD_PDCP_layer_SBA_UL_FR1_FDD_SA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-C1_16_Monitoring_PCMD_PDCP_layer_SBA_UL_FR1_FDD_SA |
    ...    | . | .       |
	...    | Test Steps  | 1. Verify PCMD counters for PDCP layers |
    ...    | Test Steps  | 2. Transfer the logs |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. Verify PCMD counters for PDCP layers
    ##########################################################################################
    run keyword and continue on failure   BuiltIn.Should Be True    '${ulRbPdcpMeasRecord_numOfPdcpSduRx}' == 'True'
    run keyword and continue on failure   BuiltIn.Should Be True    '${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}' == 'True'
    Run Keyword If    '${ulRbPdcpMeasRecord_numOfPdcpSduRx}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    Run Keyword If    '${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    ##########################################################################################
    #2. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_C}

CB010361-B-C_NSA
    [Setup]    Run Keywords    CB010361-Common-Keywords.Test Setup
	...                         AND
	...                        Test Setup CB010361-SR-C
   [Documentation]
    ...    | Description | CB010361-B-C NSA |
    ...    | . | .       |
	...    | Test Steps  | 1. test preparation |
    ...    | Test Steps  | 2. Start wireshark Logs |
    ...    | Test Steps  | 3. Do UL and DL traffic NSA |
    ...    | Test Steps  | 4. Stop wireshark Logs collections |
    ...    | Test Steps  | 5. Stop traffic |

	${ue1}    Set Variable    11
	${ue2}    Set Variable    12
    ##########################################################################################
    #2. start wireshark Logs
    ##########################################################################################
    Start To Capture UTE Wireshark
    sleep    30s
    ##########################################################################################
    #3. Do UL and DL traffic NSA
    ##########################################################################################
    Traffic_DL_UL_NSA    ue=${ue1}
    Traffic_DL_UL_NSA    ue=${ue2}
    ##########################################################################################
    #4. Stop wireshark Logs collections
    ##########################################################################################
    Stop Capture UTE Wireshark
	##########################################################################################
    #5. Stop traffic
    ##########################################################################################
	Traffic_DL_UL_NSA_stop    ue=${ue1}
    Traffic_DL_UL_NSA_stop    ue=${ue2}
    [Teardown]    CB010361-Common-Keywords.Test Teardown

[1][1.0] CB010361-SR-B2_6_Monitoring_PCMD_RLC_layer_L2-HI_DL_FR1_FDD_NSA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-B2_6_Monitoring_PCMD_RLC_layer_L2-HI_DL_FR1_FDD_NSA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for RLC |
    ...    | Test Steps  | 3. Transfer the logs |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_B_HI_DL_FR1_FDD_NSA
    ##########################################################################################
    #2. Verify PCMD counters for RLC
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbHighRlcMeasRecord_numOfRlcSduTx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbHighRlcMeasRecord_sumOfRlcSduTxBytes}' == 'True'
    Run Keyword If    '${dlRbHighRlcMeasRecord_numOfRlcSduTx}'=='False'
    ...    Log To Console    dlRbHighRlcMeasRecord_numOfRlcSduTx not found please check logs
    Run Keyword If    '${dlRbHighRlcMeasRecord_sumOfRlcSduTxBytes}'=='False'
    ...    Log To Console    dlRbHighRlcMeasRecord_sumOfRlcSduTxBytes not found please check logs
    ##########################################################################################
    #3. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_B}

[1][1.0] CB010361-SR-C1_14_Monitoring_PCMD_PDCP_layer_SBA_DL_FR1_FDD_NSA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-C1_14_Monitoring_PCMD_PDCP_layer_SBA_DL_FR1_FDD_NSA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for PDCP layers |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_C
    ##########################################################################################
    #2. Verify PCMD counters for PDCP layers
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbPdcpMeasRecord_numOfPdcpSduTx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}' == 'True'
    Run Keyword If    '${dlRbPdcpMeasRecord_numOfPdcpSduTx}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    Run Keyword If    '${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs

[1][1.0] CB010361-SR-C1_11_Monitoring_PCMD_PDCP_layer_MBA_UL_FR1_FDD_NSA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-C1_11_Monitoring_PCMD_PDCP_layer_MBA_UL_FR1_FDD_NSA |
    ...    | . | .       |
	...    | Test Steps  | 1. Verify PCMD counters for PDCP layers |
    ...    | Test Steps  | 2. Transfer the logs |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. Verify PCMD counters for PDCP layers
    ##########################################################################################
    run keyword and continue on failure   BuiltIn.Should Be True    '${ulRbPdcpMeasRecord_numOfPdcpSduRx}' == 'True'
    run keyword and continue on failure   BuiltIn.Should Be True    '${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}' == 'True'
    Run Keyword If    '${ulRbPdcpMeasRecord_numOfPdcpSduRx}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    Run Keyword If    '${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}'=='False'
    ...    Log To Console    dlRbPdcpMeasRecord_numOfPdcpSduTx not found please check logs
    ##########################################################################################
    #2. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_C}