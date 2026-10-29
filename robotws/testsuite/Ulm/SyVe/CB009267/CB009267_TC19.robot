*** Settings ***
Force Tags    CRT
Documentation
...    | [5G25R1]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-C TC19                                                        |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Sara                                                                   |
...    | Team:         | Ulm MN RAN RD VRF ULM 4                                                |
...    | Contact:      | OO_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com                       |
...    | Description:  | TC19                                                                   |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../resources/scf_info.robot
Resource    resources/CB009267_Verification.robot
Resource    resources/CB009267_Commissioning.robot
Resource    ../CB010636/resources/CB010636_Workbench_KW.robot

Resource    ../resources/UEs_handler.robot
Resource    ../resources/syve_testline.robot


Suite Setup     Prepare TL for CB010636 Testing
Suite Teardown  Save all Logs and Teardown TL for CB010636


*** Variables ***
${withPMcountersCheck}    True
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE_4CC_UE}         2000
${UL_RATE_4CC_UE}         250


*** Test Cases ***
CB009267-C_TC19_SA_4CC_DL-UL_CA_check_SCell_suspension_and _recovery_meas_gap_bufferBased_B201
    [Documentation]
    ...    | CB009267_TC19            |
    [Tags]    CB009267_TC19
    [Setup]    Setup Test Scenario for CB010636

    Log To Console    ${\n}CB009267 Uses one UE: SDX75

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=gnb

    Set all Suite Variables
    CB009267_Commissioning.Commission delta gnb_scf    gnb_id=${0}

    Set test case variables for NSA   PCELL_UE_1=None   PCELL_UE_3=None   S_PCELL_UE_1=8   S_PCELL_UE_2=None   S_PCELL_UE_3=None    SCELL_UE_1=4,9,13
    ...    SCELL_UE_2=@{EMPTY}   SCELL_UE_3=@{EMPTY}

    Log To Console    ${\n}SA Call: Block the gNB cells that share same RM as the needed cells.
    Block unBlock cells
    ...    operated_cell_1=${3}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    Block unBlock cells
    ...    operated_cell_1=${14}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    ${ru_id_UE_1}=    Correlate Cell ID to Radio Module ID    node_type=gnb    node_id=${0}    Cell_ID=${S_PCELL_UE_1}
    ${ru_id_UE_1}   Evaluate    ${ru_id_UE_1}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8
    ${4CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${4CC_UE}
    ${physCellId_pcell_UE_1}=   Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${S_PCELL_UE_1}
    ${physCellId_scell_UE_1}=   Get Scell Physical ID   ${SCELL_UE_1}

    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    Set Test Variable    ${value_in_db}    ${0}
    FOR   ${value_in_db}   IN RANGE    20    81    10    # From 20db to 80db with step of 10db...
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${1}    # Cell_4
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${5}    # Cell_9
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${8}    # Cell_13
        Sleep    2sec
    END
    attenuator.Set gNB all ports attenuation    value_in_db=50    ru_id=${ru_id_UE_1}    # Cell_8
    Sleep    10sec
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8
    FOR   ${value_in_db}   IN RANGE    15    76    10    # From 75db to 15db with step of 10db...
        ${value_in_db}        evaluate   90- ${value_in_db}
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${1}    # Cell_4
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${5}    # Cell_9
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${8}    # Cell_13
        Sleep    2sec
    END
    Sleep    10sec

    Verify CB009267-C TC19 PM Values per Cells
    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_UL}_${4CC_UE}    tput=${UL_RATE_4CC_UE} Mbits/sec    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_DL}_${4CC_UE}    tput=${DL_RATE_4CC_UE} Mbits/sec    deviation=10%

    Sleep    3s    reason=Wait for logging...
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${4CC_UE}

    [Teardown]    Run Keywords
    ...           CB010636_Workbench_KW.Test Scenario Teardown
    ...  AND      CB009267_Commissioning.Revert Commission delta gnb_scf
    ...  AND      syve_testline.CCRT Test Cases Teardown
