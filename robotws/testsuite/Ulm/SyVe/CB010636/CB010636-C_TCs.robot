*** Settings ***
Force Tags    CRT
Documentation
...    | [5G24R3]      | CB010636 NR_Carrier_Aggregation_Counters-Data_Volumes_and_Throughput   |
...    | Test case:    | CB010636-C                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for CB010636                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    resources/CB010636_Workbench_KW.robot
Resource    resources/CB010636_Verification_KW.robot
Resource    resources/CB010636_Commissioning.robot

Resource    testsuite/Ulm/SyVe/resources/UEs_handler.robot

Suite Setup     Prepare TL for CB010636 Testing
Suite Teardown  Save all Logs and Teardown TL for CB010636


*** Variables ***
${withPMcountersCheck}    true
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE}                20
${UL_RATE}                10
${DL_RATE_3CC_UE}         700
${UL_RATE_3CC_UE}         10
${DL_RATE_4CC_UE}         1000
${UL_RATE_4CC_UE}         40


*** Test Cases ***
CB010636-C_TC19_SA_3CC_DL-UL_CA_RLC_VOL_TIME_C301
    [Documentation]
    ...  | CB010636-C_TC19_SA     |
    ...  | This test case is aimed at verifying the counters that are introduced as part of CB010636-C |
    ...  | to monitor DL Per CC UE Throughput Counters and UL Per CC UE Throughput Counters in SA mode.             |
    [Tags]    3UEs    QCD_MN_RAN
    ...    CB010636-C_TC19
    [Setup]    Setup Test Scenario for CB010636
    Log To Console    ${\n}CB010636-C_TC19_SA Using Three UEs: SDX75, SDX70, SDX60

    Log To Console    ${\n}Set here your PCell and SCells for every UEs.
    Set Test Case Variables for UEs HOs

    ${ru_id_for_4CC_UE_PCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_PCell}
    ${ru_id_for_4CC_UE_PCell}   Evaluate    ${ru_id_for_4CC_UE_PCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_for_4CC_UE_PCell}    # Cell_8
    ${4CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}    APN_name=ulmsamqi4.nokia.com.mnc001.mcc540.gprs
    Set Test Variable    ${4CC_UE}

    ${ru_id_for_3CC_UE_PCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_2_PCell}
    ${ru_id_for_3CC_UE_PCell}   Evaluate    ${ru_id_for_3CC_UE_PCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=11    ru_id=${ru_id_for_3CC_UE_PCell}    # Cell_9
    ${3CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${2}    APN_name=ulmsa
    Set Test Variable    ${3CC_UE}

    ${ru_id_for_NoCC_UE_Cell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_3_Cell}
    ${ru_id_for_NoCC_UE_Cell}   Evaluate    ${ru_id_for_NoCC_UE_Cell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=12    ru_id=${ru_id_for_NoCC_UE_Cell}    # Cell_13 and Cell_14
    ${Without_Aggregated_Carrier}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${3}
    Set Test Variable    ${Without_Aggregated_Carrier}

    Add Cells for the Aggregated Carrier

    Set Test Variable    ${DL_RATE_3CC_UE}    350    #Less TPut if the APN is set to ulmsamqi4.nokia.com.mnc001.mcc540.gprs
    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}    port_value=50006
    Start Data Transfer UL DL    ue_alias=${3CC_UE}    ue_DL_Rate=${DL_RATE_3CC_UE}    ue_UL_Rate=${UL_RATE_3CC_UE}
    Start Data Transfer UL DL    ue_alias=${Without_Aggregated_Carrier}    ue_DL_Rate=${DL_RATE}    ue_UL_Rate=${UL_RATE}

    IF    '${withPMcountersCheck}'=='true'
        CB010636_Verification_KW.CB010636-B Performance Counters    PCell_id=8    2CC_SCell_id=4    3CC_SCell_id=9    4CC_SCell_id=13
        CB010636_Verification_KW.CB010636-C PCell Counters
    END

    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    taf.ue.Stop Data Transfer    ${DT_DL}_${3CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${3CC_UE}

    taf.ue.Stop Data Transfer    ${DT_DL}_${Without_Aggregated_Carrier}
    taf.ue.Stop Data Transfer    ${DT_UL}_${Without_Aggregated_Carrier}

    Verify iPerf Average Throughput

    # ToDo: if I use UE_id=${4CC_UE} will run in the issue "UE_UE_1"...
    Log To Console    ${\n}Revert Back the APN to the default...
    Switch APN    UE_id=${1}    APN_name=ulmsa

    Sleep    3s    reason=Wait for logging...
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${4CC_UE}
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${3CC_UE}
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${Without_Aggregated_Carrier}

    [Teardown]    Run Keywords
    ...           CB010636_Workbench_KW.Test Scenario Teardown
    ...    AND    syve_testline.CCRT Test Cases Teardown


*** Keywords ***
Verify iPerf Average Throughput
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_UL}_${4CC_UE}
    ...    tput=${UL_RATE_4CC_UE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_DL}_${4CC_UE}
    ...    tput=${DL_RATE_4CC_UE} Mbits/sec
    ...    deviation=10%

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_UL}_${3CC_UE}
    ...    tput=${UL_RATE_3CC_UE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_DL}_${3CC_UE}
    ...    tput=${DL_RATE_3CC_UE} Mbits/sec
    ...    deviation=10%

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_UL}_${Without_Aggregated_Carrier}
    ...    tput=${UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_DL}_${Without_Aggregated_Carrier}
    ...    tput=${DL_RATE} Mbits/sec
    ...    deviation=10%
