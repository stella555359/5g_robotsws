*** Settings ***
Force Tags    CRT
Documentation
...    | [5G25R1]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-C                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | MN RAN RD VRF ULM 3                                                    |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                               |
...    | Description:  | TCs for CB009267-C                                                     |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    testsuite/Ulm/SyVe/resources/UEs_handler.robot
Resource    testsuite/Ulm/SyVe/resources/syve_testline.robot
Resource    testsuite/Ulm/SyVe/resources/scf_info.robot

Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot

Resource    resources/CB009267_Verification.robot
Resource    resources/CB009267_Commissioning.robot


Suite Setup     Prepare TL for CB010636 Testing
Suite Teardown  Save all Logs and Teardown TL for CB010636


*** Variables ***
${withPMcountersCheck}    true
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE_4CC_UE}         1000
${UL_RATE_4CC_UE}         40


*** Test Cases ***
CB009267-C_TC24_NSA_2CC_DL_CA_check_SCell_suspension_meas_gap_and_deact_inactivity_bufferBased_B301
    [Documentation]
    ...  | CB009267-C_TC24_NSA     |
    ...  | The purpose of test case is to verify the counters for SCell suspension due to Attenuation  |
    ...  | and then SCell deactivation due to inactivity.  |
    [Tags]    QCD_MN_RAN
    ...    CB009267-C_TC24
    [Setup]    Setup Test Scenario for CB010636
    Log To Console    ${\n}CB009267-C_TC24_NSA Using The SDX75.

    ${qc_project_to_Use}=    Setup QCP_ for report    SBTS00=RAN_VRF    SBTS25R3=RAN_VRF    SBTS25R2=RAN_VRF    SBTS25R1=RAN_VRF
    ${QC_ID_to_Use}=    Setup QC_ID for report    SBTS00=50867    SBTS25R3=211371    SBTS25R2=155342    SBTS25R1=133752
    Log To Console    ${\n}Report to: ${qc_project_to_Use} ${QC_ID_to_Use}.

    Log To Console    ${\n}Commissioning...
    CB009267-C_TC24_NSA_Commissioning

    Set Test Case Variables for UEs HOs   UE_1_PCell=${8}  UE_1_SCell1=${9}  UE_1_SCell2=${1}  UE_1_SCell3=${None}

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM. So, Blocking the 5G leg we force the LTE attach...
    CB010636_Workbench_KW.Block unBlock cells
    ...    operated_cell_1=${UE_1_PCell}
    ...    node_type=enb
    ...    cell_op=unblock
    ...    node_id=${0}
    CB010636_Workbench_KW.Block unBlock cells
    ...    operated_cell_1=${UE_1_PCell}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    ${ru_id_UE1_PCell}=    syve_testline.Correlate Cell ID to Radio Module ID    node_type=eNB    node_id=${0}    Cell_ID=${UE_1_PCell}
    ${ru_id_UE1_PCell}   Evaluate    ${ru_id_UE1_PCell}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE1_PCell}    # Cell_8 LTE + 5G

    ${4CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${4CC_UE}

    ${ru_id_UE1_SCell1}=    syve_testline.Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell1}
    ${ru_id_UE1_SCell1}   Evaluate    ${ru_id_UE1_SCell1}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=11    ru_id=${ru_id_UE1_SCell1}    # Cell_9

    ${ru_id_UE1_SCell2}=    syve_testline.Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell2}
    ${ru_id_UE1_SCell2}   Evaluate    ${ru_id_UE1_SCell2}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=12    ru_id=${ru_id_UE1_SCell2}    # Cell_1

    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    Log To Console    ${\n}"PMcounters: Wait next Measurement Period Starts."
    pmcounters.Wait until the next Measurement Period starts    gnb_id=${0}

    Log To Console    ${\n}Wait...
    Sleep    60sec

    Log To Console    ${\n}Stop Data...
    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    Sleep    60sec
    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    ${ru_id_UE1_SCell1}=    syve_testline.Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell1}
    ${ru_id_UE1_SCell1}   Evaluate    ${ru_id_UE1_SCell1}[0]-${1}

    Set Test Variable    ${value_in_db}    ${11}
    FOR   ${value_in_db}   IN RANGE    11    101    10    # From 11db to 101db with step of 10db...
        ${value_in_db}        evaluate   ${value_in_db}+10
        attenuator.Set gNB all ports attenuation    value_in_db=${value_in_db}    ru_id=${ru_id_UE1_SCell1}    # Cell_9
        Sleep    5sec
    END

    ${ru_id_UE1_SCell2}=    syve_testline.Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell2}
    ${ru_id_UE1_SCell2}    Evaluate    ${ru_id_UE1_SCell2}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=80    ru_id=${ru_id_UE1_SCell2}    # Cell_1

    Log To Console    ${\n}"PMcounters: Wait next Measurement Period Stops."
    pmcounters.Wait until the current Measurement Period stops    gnb_id=${0}

    ${PM_FILES}=    Collect PM Counter
    Set Test Variable    ${PM_FILES}

    Verify CB009267-C TC24 PM Values per Cells

    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    Log To Console    ${\n}Verify iPerf Average Throughput...
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

    Log To Console    ${\n}The End...

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}DeCommissioning...
    ...    AND
    ...    CB009267-C_TC24_NSA_DeCommissioning
    ...    AND
    ...    Test Scenario Teardown


*** Keywords ***
CB009267-C_TC24_NSA_Commissioning
    Log To Console    ${\n}ActCarAgPmCount=true, actBufferBasedSCellAddition=disabled and miNrCaDu=5min SHOULD be inside the BASE SCF.
    CB009267_Commissioning.Modify sCellActivationMethod with Delta Recommissioning    sCellActivationMethod_Value=bufferBased
    Sleep    60Sec
    CB009267_Commissioning.Modify sCellDeactivationTimerGNB with Delta Recommissioning    sCellDeactivationTimerGNB_Value=ms1280    nrcell_id=${1}
    Sleep    60Sec
    scf_info.Collect and Validate the Current SCF file


CB009267-C_TC24_NSA_DeCommissioning
    Block unBlock cells
    ...    operated_cell_1=${UE_1_PCell}
    ...    node_type=gnb
    ...    cell_op=unblock
    ...    node_id=${0}
    CB009267_Commissioning.Modify sCellDeactivationTimerGNB with Delta Recommissioning    sCellDeactivationTimerGNB_Value=infinity    nrcell_id=${1}
    Sleep    30Sec
    CB009267_Commissioning.Modify sCellActivationMethod with Delta Recommissioning    sCellActivationMethod_Value=blind
    scf_info.Collect and Validate the Current SCF file
