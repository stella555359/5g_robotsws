*** Settings ***
Force Tags    CRT
Documentation
...    | [5G24R3]      | CB010636 NR_Carrier_Aggregation_Counters-Data_Volumes_and_Throughput   |
...    | Test case:    | CB010636-D                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for CB010636                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../resources/scf_info.robot
Resource    resources/CB010636_Verification_KW.robot
Resource    resources/CB010636_Commissioning.robot

Resource    testsuite/Ulm/SyVe/resources/UEs_handler.robot

Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot

Suite Setup     Prepare TL for CB010636 Testing
Suite Teardown  Save all Logs and Teardown TL for CB010636


*** Variables ***
${withPMcountersCheck}    true
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE_4CC_UE}         1000
${UL_RATE_4CC_UE}         40


*** Test Cases ***
CB010636-D_TC23_SA_3CC_DL-UL_CA_check_Tput_per_Mhz_multiple_BWP_C104
    [Documentation]
    ...    | CB010636-D_TC23            |
    ...    | multiple_BWP               |
    [Tags]     One_UE
    ...    CB010636-D_TC23
    [Setup]    Setup Test Scenario for CB010636

    Log To Console    ${\n}CB010636-D_TC23_SA Using One UE: SDX752.

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=gnb

    Set all Suite Variables
    CB010636_Commissioning.Commission delta gnb_scf    gnb_id=${0}

    Set test case variables for NSA   PCELL_UE_1=None   PCELL_UE_3=None   S_PCELL_UE_1=4   S_PCELL_UE_2=None   S_PCELL_UE_3=None    SCELL_UE_1=2,6,9
    ...     SCELL_UE_2=@{EMPTY}  SCELL_UE_3=@{EMPTY}

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM. Blocking the 5G leg we force the LTE attach.
    Block unBlock cells
    ...    operated_cell_1=${3}
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
#    Verify Pcell and Scell Addition    ${physCellId_pcell_UE_1}  ${physCellId_scell_UE_1}  tcp_file=${tcp_file_gnb${0}_UE_1}

    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=0    # Cell_2 and Cell_1
    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=2    # Cell_6
    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=5    # Cell_9

    ${DL_RATE_4CC_UE} =  Set Variable       1300
    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    Set Test Variable    ${withPMcountersCheck}    true
    Sleep    60sec
    IF    '${withPMcountersCheck}'=='true'   CB010636-D TC23 PM Values per Cells

    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_UL}_${4CC_UE}  tput=${UL_RATE_4CC_UE} Mbits/sec  deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_DL}_${4CC_UE}  tput=${DL_RATE_4CC_UE} Mbits/sec  deviation=10%

    Sleep    3s    reason=Wait for logging...
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${4CC_UE}

    [Teardown]    Run Keywords
    ...           Test Scenario Teardown
    ...  AND      CB010636_Commissioning.Revert Commission delta gnb_scf
    ...  AND      syve_testline.CCRT Test Cases Teardown


CB010636-D_TC24_NSA_2CC_DL_CA_check_Tput_per_Mhz_multiple_BWP_C104
    [Documentation]
    ...    | CB010636-D_TC24            |
    ...    | multiple_BWP               |
    [Tags]     One_UE
    ...    CB010636-D_TC24
    [Setup]    Setup Test Scenario for CB010636

    Log To Console    ${\n}CB010636-D_TC24_NSA Using One UE: SDX75.

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=gnb

    Set all Suite Variables
    CB010636_Commissioning.Commission delta gnb_scf    gnb_id=${0}

    Set test case variables for NSA   PCELL_UE_1=8   PCELL_UE_3=None   S_PCELL_UE_1=9   S_PCELL_UE_2=None   S_PCELL_UE_3=None    SCELL_UE_1=1
    ...     SCELL_UE_2=@{EMPTY}  SCELL_UE_3=@{EMPTY}

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM. Blocking the 5G leg we force the LTE attach.
    Block unBlock cells
    ...    operated_cell_1=${8}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}
    Block unBlock cells
    ...    operated_cell_1=${PCELL_UE_1}
    ...    node_type=enb
    ...    cell_op=unblock
    ...    node_id=${0}

    ${ru_id_UE_1}=    Correlate Cell ID to Radio Module ID    node_type=enb    node_id=${0}    Cell_ID=${PCELL_UE_1}
    ${ru_id_UE_1}   Evaluate    ${ru_id_UE_1}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM.
    Block unBlock cells
    ...    operated_cell_1=${3}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    ${4CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${4CC_UE}

    ${ru_id_UE_11}=    Correlate Cell ID to Radio Module ID    node_type=gnb    node_id=${0}    Cell_ID=${S_PCELL_UE_1}
    ${ru_id_UE_11}   Evaluate    ${ru_id_UE_11}[0]-${1}
    Start Tcpdump on gNB trace   UE_id=${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_11}    # Cell_8
    ${physCellId_pcell_UE_1}=   Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${S_PCELL_UE_1}
    Sleep    30s    reason=Wait for logging...
    Stop Tcpdump on gNB trace   UE_id=${1}
#    Check Pcell Addition   ${physCellId_pcell_UE_1}  tcp_file=${tcp_file_gnb${0}_UE_1}   packet_filter=f1ap.procedureCode == 7

    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=1    # Cell_1

    ${DL_RATE_4CC_UE} =  Set Variable       1300
    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    Set Test Variable    ${withPMcountersCheck}    true
    Sleep    60sec
    IF    '${withPMcountersCheck}'=='true'    CB010636-D TC24 PM Values per Cells

    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_UL}_${4CC_UE}  tput=${UL_RATE_4CC_UE} Mbits/sec  deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_DL}_${4CC_UE}  tput=${DL_RATE_4CC_UE} Mbits/sec  deviation=10%

    Sleep    3s    reason=Wait for logging...
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${4CC_UE}

    [Teardown]    Run Keywords
    ...           Test Scenario Teardown
    ...  AND      CB010636_Commissioning.Revert Commission delta gnb_scf
    ...  AND      syve_testline.CCRT Test Cases Teardown
