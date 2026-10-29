*** Settings ***
Force Tags    CRT
Documentation
...    | [5G25R1]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-C TC19 adapted for customer TMO on e.g. TL126, TL387                                       |
...    | UEs:          | Using QUALCOMM SDX80, SDX75, SDX60                                                                  |
...    | Author:       | new implementation with adaptions to TMO TL : Frank                                                 |
...    | Team:         | Ulm MN RAN RD VRF ULM 4                                                |
...    | Contact:      | OO_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com                       |
...    | Description:  | TC19 CB009267-A for TMO_v2, new implementation NOT based on CB010636   |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB009267_keywords.robot
Resource                        ../resources/attenuator.robot

Resource                        resources/CB009267_Verification.robot
Resource                        resources/CB009267_Commissioning.robot
Resource                        ../resources/UEs_handler.robot

Suite Setup                     CB009267_keywords.Prepare TL for Testing
Suite Teardown                  CB009267_keywords.Save all Logs and Teardown TL

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=2000 Mbits/sec
...                             UL_THROUGHPUT=250 Mbits/sec
...                             TPUT_DEVIATION=10%
...                             DURATION=6000s
...                             PROTOCOL=udp
${WITH_PM_COUNTER_CHECK}        ${true}
${WITH_TC_COMMISSIONING}        ${true}
${BLOCK_ENB}                    ${true}
${BLOCK_GNB_ADJACENT_CELLS}     ${true}
${INITIAL_SCF_FILE_ACTIVATION}  ${false}
${UE_ALIAS_1}                   UE_1
${GNB_ID}                       ${0}


*** Test Cases ***
CB009267-C_TC19_SA_4CC_DL-UL_CA_check_SCell_suspension_and _recovery_meas_gap_bufferBased_B201
    [Documentation]
    ...    | CB009267_TC19 for customer TMO on e.g. TL126, TL389            |
    [Tags]    CB009267-C_TC19_TMO
    [Setup]    CB009267_keywords.Setup Test for CB009267

    Log To Console    ${\n}This is testcase
    Log To Console    CB009267-C_TC19_SA_4CC_DL-UL_CA_check_SCell_suspension_and _recovery_meas_gap_bufferBased_B201  using the SDX75/80.

    #   The cell PCELL_UE_1_P2S is the PRIMARY cell
    #   The cell S_CELL_UE_1_S2P is a TDD SECONDARY cell
    #   The cell S_CELL_UE_1_SOURCE[0] and [1] are FDD SECONDARY cells
    ${nrbts_id}        scf_info.Get NRBTS-Id  ${GNB_ID}
    Set Test Variable     ${nrbts_id}
    Log To Console    NRBTS ID is ${nrbts_id}

    IF   ${nrbts_id} == 403891
    # correct scf configuration for TL389 has to be done or can be deleted
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=C-19
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${8}   S_CELL_UE_1_S2P=${9}   S_CELL_UE_1_SOURCE=${{ [4,13] }}
        ...   S_CELL_UE_1_TARGET=${6}
        ...   ADJ_CELLS_GNB0=${{ [3,5,14] }}

    ELSE IF    ${nrbts_id} == 401261
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=C-19
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${13}   S_CELL_UE_1_S2P=${10}   S_CELL_UE_1_SOURCE=${{ [4,7] }}
        ...   S_CELL_UE_1_TARGET=${0}
        ...   ADJ_CELLS_GNB0=${{ [5,6,9] }}
        Set Test Variable   ${UE_ALIAS_1}   UE_1

    ELSE IF    ${nrbts_id} == 403871
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=C-19
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${13}   S_CELL_UE_1_S2P=${10}   S_CELL_UE_1_SOURCE=${{ [4,7] }}
        ...   S_CELL_UE_1_TARGET=${0}
        ...   ADJ_CELLS_GNB0=${{ [5,6,9] }}
        Set Test Variable   ${UE_ALIAS_1}   UE_1
    ELSE
        Fail    No TC variables are defined for gNB with NRBTS ID ${NRBTS_ID}
    END

    Log To Console    ${\n}brief testcase scenario:
    Log To Console    5G call starts on gNB-${gnb_id} source p-cell is ${PCELL_UE_1_P2S} and
    Log To Console    5G s-cells are ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    Log To Console    Adjacent cells, which will be blocked on gNB-${gnb_id} are ${ADJ_CELLS_GNB0}

    CB009267_keywords.Perform Preconditions Of Test Scenario
    ...   gnb_id=${gnb_id}
    ...   enb_id=${enb_id}
    ...   capabilities=${capabilities}

    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Reboot UE  ${UE_ALIAS_1}

    #  Start Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Start Necessary Traces

    #  2. Attach UE to 5G cell ${PCELL_UE_1_P2S}
    Log To Console    ${\n}Attach UE to 5G source cell ${PCELL_UE_1_P2S} add add scells ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${PCELL_UE_1_P2S}  value=${10}  node_id=${gnb_id}  node_type=gnb
    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Attach Ue   ${UE_ALIAS_1}   timeout=40

    Sleep   20s  reason=wait for attach

    #  3. Add 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE} with attenuation 20 dBm
    Log To Console    Add 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_S2P}  value=${20}  node_id=${gnb_id}  node_type=gnb
    ${scells}   Set Variable    ${0}
    FOR  ${scells}  IN  @{S_CELL_UE_1_SOURCE}
         attenuator_scenario.Set Cell Attenuation
         ...   globalcellid=${scells}  value=${20}  node_id=${gnb_id}  node_type=gnb
    END

    #  4. Start UL + DL traffic on all cells
    Log To Console    ${\n}Start DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep   5s   reason=wait for traffic started up

    Log To Console    ${\n}Start UL traffic with datarate ${TRAFFIC.UL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=ul   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep   5s   reason=wait for traffic started up

    #  1. Wait for next PM counter measurement period STARTS
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${0}
       Log To Console    ${\n}Measurement Period STARTED, let traffic run for the whole period
    END
    Sleep   20sec  reason=wait for 20s until start of the scenario

    #  5. INCREASE attenuation of 5G pcell ${PCELL_UE_1_P2S} and scell ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    Log To Console    INCREASE attenuation of 5G pcell ${PCELL_UE_1_P2S} and scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${PCELL_UE_1_P2S}  value=${50}  node_id=${gnb_id}  node_type=gnb
        attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_S2P}  value=${80}  node_id=${gnb_id}  node_type=gnb
        attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_SOURCE}[0]  value=${70}  node_id=${gnb_id}  node_type=gnb
        attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_SOURCE}[1]  value=${70}  node_id=${gnb_id}  node_type=gnb

#    ${scells}   Set Variable    ${0}
#    FOR  ${scells}  IN  @{S_CELL_UE_1_SOURCE}
#         attenuator_scenario.Set cell attenuation
#         ...   globalcellid=${scells}  value=${80}  node_id=${gnb_id}  node_type=gnb
#    END
#    attenuator.Set gNB all ports attenuation    value_in_db=50    ru_id=${ru_id_UE_1}    # Cell_8 -> Cell_13
#    attenuator.Set gNB all ports attenuation    value_in_db=80    ru_id=4    # Cell_13 -> Cell_8
#    attenuator.Set gNB all ports attenuation    value_in_db=70    ru_id=3    # Cell_4 -> Cell_4
#    attenuator.Set gNB all ports attenuation    value_in_db=70    ru_id=6    # Cell_9 -> Cell_10

    Sleep    60sec     reason=let traffic run for 60 seconds over attenuated cells

    #  6. Set attenuation back to 20 dBm 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    Log To Console    Set attenuation back to 20 dBm 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${PCELL_UE_1_P2S}  value=${10}  node_id=${gnb_id}  node_type=gnb
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_S2P}  value=${20}  node_id=${gnb_id}  node_type=gnb
    ${scells}   Set Variable    ${0}
    FOR  ${scells}  IN  @{S_CELL_UE_1_SOURCE}
         attenuator_scenario.Set Cell Attenuation
         ...   globalcellid=${scells}  value=${20}  node_id=${gnb_id}  node_type=gnb
    END
 #   attenuator.Set gNB All Ports Attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8 -> Cell_13
 #   attenuator.Set gNB All Ports Attenuation    value_in_db=20    ru_id=4    # Cell_13 -> Cell_8
 #   attenuator.Set gNB All Ports Attenuation    value_in_db=20    ru_id=3    # Cell_4 -> Cell_4
 #   attenuator.Set gNB All Ports Attenuation    value_in_db=20    ru_id=6    # Cell_9 -> Cell_10
    Sleep    60sec

    #  7. Wait for next PM counter measurement period STOPS and verify counters
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait until current Measurement Period stops and verify PMcounters
       pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${gnb_id}
       Log To Console    ${\n}Measurement Period STOPPED and PMcounters are verified
       ${PM_FILES}=    Collect PM Counter
       Set Test Variable    ${PM_FILES}
       CB009267_Verification.Verify CB009267-C TC19 PM Values Per Cells TMO
    END

    #  8. Stop Tcpdump on gNB Common Unit and Test PC
    #  CB009267_keywords.Stop All Traces
    # do 3. tcpdump log file for check of NEW target pcell
    CB009267_keywords.Stop All Traces   tcpdump_filename=target_pcell.pcap
    Set Test Variable  ${tcp_file_gnb${gnb_id}_target_pcell}  ${tcp_file_gnb${gnb_id}}

    #  9. Stop DL traffic and detach UE
    Log To Console    ${\n}Stop UL and DL data transfer and detach UE
    taf.ue.Stop Data Transfer    UL_${UE_ALIAS_1}
    taf.ue.Stop Data Transfer    DL_${UE_ALIAS_1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources

    [Teardown]    Run Keywords
    ...           CB009267_keywords.Perform Postconditions of Test Scenario
    ...      AND
    ...           syve_testline.CCRT Test Cases Teardown


CB009267-C_TC19_SA_4CC_DL-UL_CA_check_SCell_suspension_and _recovery_meas_gap_bufferBased_B201___OLD
    [Documentation]
    ...    | CB009267_TC19 for customer TMO on e.g. TL126            |
    [Tags]    CB009267_TC19_TMO___OLD
    [Setup]    Setup Test Scenario for CB010636

    Log To Console    ${\n}CB009267 Uses one UE: SDX75

#    ... some lines are missing ...

# for TL387
    ${4CC_UE}    UEs_handler.Init UE With APN And Collect Trace Then Start BGD TPut    UE_id=${2}
    Set Test Variable    ${4CC_UE}
    ${physCellId_pcell_UE_1}=   Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${S_PCELL_UE_1}
    ${physCellId_scell_UE_1}=   Get Scell Physical ID   ${SCELL_UE_1}

    Start Data Transfer UL DL    ue_alias=${4CC_UE}    ue_DL_Rate=${DL_RATE_4CC_UE}    ue_UL_Rate=${UL_RATE_4CC_UE}

    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=4    # Cell_13: ru_id=8 -> Cell_8
    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=3    # Cell_4: ru_id=1 -> Cell_4
    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=6    # Cell_9: ru_id=5 -> Cell_10
    Sleep    60sec

    attenuator.Set gNB all ports attenuation    value_in_db=50    ru_id=${ru_id_UE_1}    # Cell_8 -> Cell_13
    attenuator.Set gNB all ports attenuation    value_in_db=80    ru_id=4    # Cell_13 -> Cell_8
    attenuator.Set gNB all ports attenuation    value_in_db=70    ru_id=3    # Cell_4 -> Cell_4
    attenuator.Set gNB all ports attenuation    value_in_db=70    ru_id=6    # Cell_9 -> Cell_10
    Sleep    60sec

    attenuator.Set gNB all ports attenuation    value_in_db=10    ru_id=${ru_id_UE_1}    # Cell_8 -> Cell_13
    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=4    # Cell_13 -> Cell_8
    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=3    # Cell_4 -> Cell_4
    attenuator.Set gNB all ports attenuation    value_in_db=20    ru_id=6    # Cell_9 -> Cell_10
    Sleep    60sec

    CB009267_Verification.Verify CB009267-C TC19 PM Values per Cells TMO

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
    ...  AND
    ...           syve_testline.CCRT Test Cases Teardown
