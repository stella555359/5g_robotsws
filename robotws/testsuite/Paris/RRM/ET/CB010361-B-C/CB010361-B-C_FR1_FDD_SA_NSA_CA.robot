*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Test suite for feature CB010361-B-C - SR - VRF - RRM - ET
...   Requested topology : CLOUD_5G_I_LPQ_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD

Resource            ./resources/robot/CB010361-Common-Keywords.robot

Suite Setup         CB010361-Common-Keywords.Suite_Setup
Suite Teardown      CB010361-Common-Keywords.Suite_Teardown

Force Tags      CA_VRF_RRM    QCD_MN_RAN    QCP_RAN_VRF   SBTS00

*** Variables ***

${JSON_FILE_PATH}    ${CURDIR}/resources/config/CB010361-B-C_pcmd_activation.json
${JSON_CA_UL_FILE_PATH}    ${CURDIR}/resources/config/CB010361-B-C_ca_ul_activation.json

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

[1][1.0] CB010361-SR-B1_1_Monitoring_PCMD_RLC_layer_L2-LO_DL_FR1_FDD_SA_CA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-B1_1_Monitoring_PCMD_RLC_layer_L2-LO_DL_FR1_FDD_SA_CA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for RLC |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_B_LO_DL_FR1_FDD_SA_CA
    ##########################################################################################
    #2. Verify PCMD counters for RLC
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbRlcMeasRecord_numOfRlcPduTx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${dlRbRlcMeasRecord_numOfReTx}' == 'True'
    Run Keyword If    '${dlRbRlcMeasRecord_numOfRlcPduTx}'=='False'
    ...    Log To Console    dlRbRlcMeasRecord_numOfRlcPduTx not found please check logs
    Run Keyword If    '${dlRbRlcMeasRecord_numOfReTx}'=='False'
    ...    Log To Console    dlRbRlcMeasRecord_numOfReTx not found please check logs

    run keyword and continue on failure    BuiltIn.Should Be True    '${caSCellDlRbRlcMeasRecord_numOfRlcPduTx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${caSCellDlRbRlcMeasRecord_numOfReTx}' == 'True'
    Run Keyword If    '${caSCellDlRbRlcMeasRecord_numOfRlcPduTx}'=='False'
    ...    Log To Console    caSCellDlRbRlcMeasRecord_numOfRlcPduTx not found please check logs
    Run Keyword If    '${caSCellDlRbRlcMeasRecord_numOfReTx}'=='False'
    ...    Log To Console    caSCellDlRbRlcMeasRecord_numOfReTx not found please check logs

    run keyword and continue on failure    BuiltIn.Should Be True    '${caSCellUlRbRlcMeasRecord_numOfRlcPduRx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${caSCellUlRbRlcMeasRecord_numOfReTx}' == 'True'
    Run Keyword If    '${caSCellUlRbRlcMeasRecord_numOfRlcPduRx}'=='False'
    ...    Log To Console    caSCellUlRbRlcMeasRecord_numOfRlcPduRx not found please check logs
    Run Keyword If    '${caSCellUlRbRlcMeasRecord_numOfReTx}'=='False'
    ...    Log To Console    caSCellUlRbRlcMeasRecord_numOfReTx not found please check logs

Transfer the logs CB010361-SR-B SA CA
    [Documentation]
    ...    | Description | Transfer the logs CB010361-SR-B SA CA |
    ...    | . | .       |
	...    | Test Steps  | 1. Transfer the logs CB010361-SR-B SA CA |

    ##########################################################################################
    #1. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_B}

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

[1][1.0] CB010361-SR-B1_3_Monitoring_PCMD_RLC_layer_L2-LO_UL_FR1_FDD_SA_CA
    [Documentation]
    ...    | Description | [1][1.0] CB010361-SR-B1_3_Monitoring_PCMD_RLC_layer_L2-LO_UL_FR1_FDD_SA_CA |
    ...    | . | .       |
    ...    | Test Steps  | 1. verify the logs using script python |
	...    | Test Steps  | 2. Verify PCMD counters for RLC |
    [Teardown]   TC Teardown Action
    ##########################################################################################
    #1. verify the logs using script python
    ##########################################################################################
    run keyword and continue on failure    Run Python Script CB010361_B_LO_UL_FR1_FDD_NSA_CA
    ##########################################################################################
    #2. Verify PCMD counters for RLC
    ##########################################################################################
    run keyword and continue on failure    BuiltIn.Should Be True    '${ulRbRlcMeasRecord_numOfRlcPduRx}' == 'True'
    run keyword and continue on failure    BuiltIn.Should Be True    '${ulRbRlcMeasRecord_numOfReTx}' == 'True'
    Run Keyword If    '${ulRbRlcMeasRecord_numOfRlcPduRx}'=='False'
    ...    Log To Console    ulRbRlcMeasRecord_numOfRlcPduRx not found please check logs
    Run Keyword If    '${ulRbRlcMeasRecord_numOfReTx}'=='False'
    ...    Log To Console    ulRbRlcMeasRecord_numOfReTx not found please check logs

Transfer the logs CB010361-SR-B NSA CA
    [Documentation]
    ...    | Description | Transfer the logs CB010361-SR-B NSA CA |
    ...    | . | .       |
	...    | Test Steps  | 1. Transfer the logs CB010361-SR-B NSA CA |

    ##########################################################################################
    #1. Transfer the logs
    ##########################################################################################
    run keyword and continue on failure    Transfer Files    wire_path_feature=${wire_path_parsed_CB010361_B}
