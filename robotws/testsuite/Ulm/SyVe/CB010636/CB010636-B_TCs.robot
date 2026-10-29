*** Settings ***
Force Tags    CRT
Documentation
...    | [5G24R3]      | CB010636 NR_Carrier_Aggregation_Counters-Data_Volumes_and_Throughput   |
...    | Test case:    | CB010636-B                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for CB010636                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../resources/scf_info.robot
Resource    resources/CB010636_Verification_KW.robot
Resource    resources/CB010636_Commissioning.robot
Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot

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
${PCELL_UE_1}             8
${PCELL_UE_2}             9
${CELL_UE_3}              13


*** Test Cases ***
CB010636-B_TC12_NSA_2CC_DL_check_ RLC_PDU_counters_for_FR1_B103
    [Documentation]
    ...  | CB010636-B_TC12 TC. |
    ...  | The purpose of test case is to verify the counters that are introduced as part of CB010636-B |
    ...  | to monitor DL MAC SDU user throughput when both NSA CA UEs and SA CA UEs are present in the same cells. |
    [Tags]     Three_UEs
    ...    CB010636-B_TC12
    [Setup]    Setup Test Scenario for CB010636
    Log To Console    ${\n}CB010636-B_TC12 NSA Using Three UEs: SDX75, SDX70, SDX60.

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=gnb

    Set all Suite Variables
    CB010636_Commissioning.Commission delta gnb_scf    gnb_id=${0}

    Set test case variables for NSA   PCELL_UE_1=8   PCELL_UE_3=4   S_PCELL_UE_1=9   S_PCELL_UE_2=9   S_PCELL_UE_3=6    SCELL_UE_1=1
    ...     SCELL_UE_2=6,7  SCELL_UE_3=@{EMPTY}

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM. Blocking the 5G leg we force the LTE attach.
    Block unBlock cells
    ...    operated_cell_1=${PCELL_UE_1}
    ...    node_type=enb
    ...    cell_op=unblock
    ...    node_id=${0}
    Block unBlock cells
    ...    operated_cell_1=${PCELL_UE_1}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    ${ru_id_UE_1}=    Correlate Cell ID to Radio Module ID    node_type=enb    node_id=${0}    Cell_ID=${PCELL_UE_1}
    ${ru_id_UE_1}   Evaluate    ${ru_id_UE_1}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8

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

    ${ru_id_UE_2}=    Correlate Cell ID to Radio Module ID    node_type=gnb    node_id=${0}    Cell_ID=${S_PCELL_UE_2}
    ${ru_id_UE_2}   Evaluate    ${ru_id_UE_2}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_2}    # Cell_9

    ${3CC_UE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${2}
    Set Test Variable    ${3CC_UE}

    ${physCellId_pcell_UE_2}=   Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${S_PCELL_UE_2}
    Sleep    30s    reason=Wait for logging...

#    Check Pcell Addition   ${physCellId_pcell_UE_2}  tcp_file=${tcp_file_gnb${0}_UE_2}

    Log To Console    ${\n}NSA Call: eNB and gNB have the same RM. Blocking the 5G leg we force the LTE attach.
    Block unBlock cells
    ...    operated_cell_1=${PCELL_UE_3}
    ...    node_type=enb
    ...    cell_op=unblock
    ...    node_id=${0}
    Block unBlock cells
    ...    operated_cell_1=${3}
    ...    operated_cell_2=${4}
    ...    node_type=gnb
    ...    cell_op=block
    ...    node_id=${0}

    ${ru_id_UE_3}=    Correlate Cell ID to Radio Module ID    node_type=enb    node_id=${0}    Cell_ID=${PCELL_UE_3}
    ${ru_id_UE_3}   Evaluate    ${ru_id_UE_3}[0]-${1}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_3}

    ${Without_Aggregated_Carrier}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${3}
    Set Test Variable    ${Without_Aggregated_Carrier}

    ${ru_id_UE_31}=    Correlate Cell ID to Radio Module ID    node_type=gnb    node_id=${0}    Cell_ID=${S_PCELL_UE_3}
    ${ru_id_UE_31}   Evaluate    ${ru_id_UE_31}[0]-${1}
    Start Tcpdump on gNB trace   UE_id=${3}
    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_31}    # Cell_8
    ${physCellId_pcell_UE_3}=    Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${S_PCELL_UE_3}
    Sleep    30s    reason=Wait for logging...
    Stop Tcpdump on gNB trace   UE_id=${3}
#    Check Pcell Addition   ${physCellId_pcell_UE_3}  tcp_file=${tcp_file_gnb${0}_UE_3}   packet_filter=f1ap.procedureCode == 7

    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=0    # Cell_2 and Cell_1
    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=3    # Cell_7

    ${DL_RATE_4CC_UE} =  Set Variable       1300
    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}
    Start Data Transfer UL DL    ue_alias=${3CC_UE}    ue_DL_Rate=${DL_RATE_3CC_UE}    ue_UL_Rate=${UL_RATE_3CC_UE}
    Start Data Transfer UL DL    ue_alias=${Without_Aggregated_Carrier}    ue_DL_Rate=${DL_RATE}    ue_UL_Rate=${UL_RATE}

    Set Test Variable    ${withPMcountersCheck}    true
    Sleep    60sec
    IF    '${withPMcountersCheck}'=='true'
        CB010636-B TC12 PM Values per Cells
        CB010636-B Performance Counters    PCell_id=9    2CC_SCell_id=1
        CB010636-B Performance Counters    PCell_id=9    2CC_SCell_id=6    3CC_SCell_id=7
        CB010636-B Performance Counters    PCell_id=6
    END

    taf.ue.Stop Data Transfer    ${DT_DL}_${4CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${4CC_UE}

    taf.ue.Stop Data Transfer    ${DT_DL}_${3CC_UE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${3CC_UE}

    taf.ue.Stop Data Transfer    ${DT_DL}_${Without_Aggregated_Carrier}
    taf.ue.Stop Data Transfer    ${DT_UL}_${Without_Aggregated_Carrier}

    IF    '${withPMcountersCheck}'=='true'
        Verification of Former Performance Counters    PCell_id=9    2CC_SCell_id=1
        Verification of Former Performance Counters    PCell_id=9    2CC_SCell_id=6    3CC_SCell_id=7
    END

    IF    '${withPMcountersCheck}'=='true'
        Verification of performance counters    PCell_id=9    2CC_SCell_id=1
        Verification of performance counters    PCell_id=9    2CC_SCell_id=6    3CC_SCell_id=7
    END

    # ToDo: Use "Verify iPerf Average Throughput" KW with ${UL_RATE_4CC_UE}...
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_UL}_${4CC_UE}  tput=${UL_RATE_4CC_UE} Mbits/sec  deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_DL}_${4CC_UE}  tput=${DL_RATE_4CC_UE} Mbits/sec  deviation=10%

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_UL}_${3CC_UE}  tput=${UL_RATE_3CC_UE} Mbits/sec  deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DT_DL}_${3CC_UE}  tput=${DL_RATE_3CC_UE} Mbits/sec  deviation=10%

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

    Sleep    3s    reason=Wait for logging...
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${4CC_UE}
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${3CC_UE}
    Run Keyword And Warn On Failure    taf.ue.Detach UE    ${Without_Aggregated_Carrier}

    [Teardown]    Run Keywords
    ...           Test Scenario Teardown
    ...  AND      CB010636_Commissioning.Revert Commission delta gnb_scf
    ...  AND      syve_testline.CCRT Test Cases Teardown


CB010636-B_TC15_SA_3CC_DL-UL_CA_check_ RLC_PDU_counters_for_FR1_different_5QIs_profiles_PMQAP_B301
    [Documentation]
    ...  | CB010636-B_TC15_SA |
    ...  | Checks DL MAC SDU counters and RLC PDU counters for different PMQAP profiles for different 5QIs in SA mode.  |
    [Tags]    3UEs    QCD_MN_RAN
    ...    CB010636-B_TC15
    [Setup]    Setup Test Scenario for CB010636
    Log To Console    ${\n}CB010636-B_TC15_SA Using Three UEs: SDX75, SDX70, SDX60

    Log To Console    ${\n}Set here your PCell and SCells for every UEs.
    Set Test Case Variables for UEs HOs

    CB010636_Commissioning.Create cfg5qiRange with Delta Recommissioning

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

    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}    port_value=50006
    Start Data Transfer UL DL    ue_alias=${3CC_UE}    ue_DL_Rate=${DL_RATE_3CC_UE}    ue_UL_Rate=${UL_RATE_3CC_UE}
    Start Data Transfer UL DL    ue_alias=${Without_Aggregated_Carrier}    ue_DL_Rate=${DL_RATE}    ue_UL_Rate=${UL_RATE}

    IF    '${withPMcountersCheck}'=='true'
        CB010636-B Performance Counters    PCell_id=8    2CC_SCell_id=4    3CC_SCell_id=9    4CC_SCell_id=13
        CB010636-B Performance Counters    PCell_id=9    2CC_SCell_id=6    3CC_SCell_id=7
        CB010636-B Performance Counters    PCell_id=13
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
    ...    AND    CB010636_Commissioning.Delete cfg5qiRange with Delta Recommissioning


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
