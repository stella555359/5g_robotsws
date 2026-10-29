*** Settings ***
Force Tags    CRT
Documentation
...    | [5G25R2]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-A                                                           |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                  |
...    | Author:       | Frank                                                                |
...    | Team:         | MN RAN RD VRF ULM 4                                                  |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                             |
...    | Description:  | TCs for CB009267-A                                                   |
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library            taf.ue
Resource           CB009267_keywords.robot
Resource           ../resources/attenuator.robot

Resource           resources/CB009267_Verification.robot
Resource           resources/CB009267_Commissioning.robot


Suite Setup        CB009267_keywords.Prepare TL for Testing
Suite Teardown     CB009267_keywords.Save all Logs and Teardown TL


*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=1500 Mbits/sec
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
${ENB_ID}                       ${0}

*** Test Cases ***
CB009267-A_TC05_SA_4CC_DL-UL_CA_Scell_release_inact_badRLQ_B201
    [Documentation]
    ...  | CB009267-A_TC05_SA     |
    ...  | The purpose of test case is to verify the counters for SCell release due to attenuation - bad radio link quality |
    ...  | and then SCell deactivation/release due to inactivity.  |
    [Tags]    CB009267-A
    ...    CB009267-A_TC05
    [Setup]    CB009267_keywords.Setup Test for CB009267
    Log To Console    ${\n}This is testcase
    Log To Console    CB009267-A_TC05_SA_3CC_DL-UL_CA_Scell_release_inact_badRLQ_B201 using the SDX75.

    #  nrbts_id variable has to be fetched in testcase setup / precondition part
    ${NRBTS_ID}  scf_info.Get NRBTS-Id  ${GNB_ID}
    Set Test Variable   ${NRBTS_ID}
    Log To Console    gNB NRBTS ID is  ${NRBTS_ID}

    IF   ${NRBTS_ID} == 403891
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=A-05
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${8}   S_CELL_UE_1_S2P=${4}   S_CELL_UE_1_SOURCE=${{ [9,13] }}
        ...   ADJ_CELLS_GNB0=${{ [3,5,14] }}
        Set Test Variable  ${TL_UE_id}  ${1}
    ELSE IF   ${nrbts_id} in [401261,403871]
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=A-05
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${13}   S_CELL_UE_1_S2P=${4}   S_CELL_UE_1_SOURCE=${{ [10,7] }}
        ...   ADJ_CELLS_GNB0=${{ [5,6,8,9] }}
        Set Test Variable   ${UE_ALIAS_1}   UE_1
    ELSE
        Fail    No TC variables are defined for gNB with NRBTS ID ${NRBTS_ID}
    END

    Log To Console    ${\n}brief testcase scenario:
    Log To Console    5G call starts on gNB-${gnb_id} source p-cell is ${PCELL_UE_1_P2S} and
    Log To Console    5G s-cells are ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    Log To Console    gNB-${gnb_id} target p-cell is ${S_CELL_UE_1_S2P} and
    Log To Console    5G target s-cells are ${S_CELL_UE_1_TARGET} and ${PCELL_UE_1_P2S}
    Log to Console    Adjacent cells, which will be blocked on gNB-${gnb_id} are ${ADJ_CELLS_GNB0}

    CB009267_keywords.Perform Preconditions Of Test Scenario
    ...   gnb_id=${gnb_id}
    ...   enb_id=${enb_id}
    ...   capabilities=${capabilities}

    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Reboot UE  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #  Start Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Start Necessary Traces

    #  1. start call on pcell with attenuator to 10 dBm and add in the next step the 3 scells with attenuator to 20 dBm
    Log To Console    ${\n}Attach UE to 5G source cell ${PCELL_UE_1_P2S} add add scells ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${PCELL_UE_1_P2S}  value=${10}  node_id=${gnb_id}  node_type=gnb
    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Attach UE   ${UE_ALIAS_1}   timeout=40
    Sleep   20s  reason=wait for attach

    #  2. Add 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_S2P}  value=${20}  node_id=${gnb_id}  node_type=gnb
    ${scells}   Set Variable    ${0}
    FOR  ${scells}  IN  @{S_CELL_UE_1_SOURCE}
         attenuator_scenario.Set Cell Attenuation
         ...   globalcellid=${scells}  value=${20}  node_id=${gnb_id}  node_type=gnb
    END

    #  3. Start UL + DL traffic on all cells
    # start date transfer on pcell, scells are added, when the traffc is high, because of buffer based configuration
    Log To Console    ${\n}Start DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep  5s  reason=wait for traffic started up

    Log To Console    ${\n}Start UL traffic with datarate ${TRAFFIC.UL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=UL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=ul   duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.UL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep    30sec  reason=let traffic run for 30 seconds until start of attenuation scenario

    #  4. Wait for next PM counter measurement period STARTS
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${0}
       Log To Console    ${\n}Measurement Period STARTED, let traffic is running
    END

    # 5. after 20 sec. attenuate cell-${S_CELL_UE_1_SOURCE}[0] to maximum -> release of scell-${S_CELL_UE_1_SOURCE}[0] because of RL release
    Sleep    20sec
    Log To Console    ${\n} after 20 sec. attenuate cell-${S_CELL_UE_1_SOURCE}[0] to maximum 110 dBm:
    ...   -> release of scell-${S_CELL_UE_1_SOURCE}[0] because of RL release
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_CELL_UE_1_SOURCE}[0]  value=${110}  node_id=${gnb_id}  node_type=gnb

    # 6. after 60 sec. stop traffic to release scells:
    # cell-${S_CELL_UE_1_S2P} and cell-${S_CELL_UE_1_SOURCE}[1] due to inactivity (timer expired 1280ms)
    # Stop UL + DL traffic and detach UE
    Sleep    60sec
    Log To Console
    ...    ${\n}Stop UL and DL data transfer and release scells cell-${S_CELL_UE_1_S2P} and cell-${S_CELL_UE_1_SOURCE}[1] due to inactivity
    taf.ue.Stop Data Transfer    UL_${UE_ALIAS_1}
    taf.ue.Stop Data Transfer    DL_${UE_ALIAS_1}

    Sleep  30s  reason=wait release of resources
    taf.ue.Detach UE  ${UE_ALIAS_1}

    #  7. Wait for next PM counter measurement period STOPS and verify counters
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait until current Measurement Period stops and verify PMcounters
       pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${gnb_id}
       Log To Console    ${\n}Measurement Period STOPPED and PMcounters are verified
       ${PM_FILES}=    Collect PM Counter
       Set Test Variable    ${PM_FILES}
       CB009267_Verification.Verify CB009267-A TC05 PM Values Per Cells
    END

    #  8. Stop Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Stop All Traces

    Log To Console    ${\n}Verify iPerf Average Throughput...
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=UL_${UE_ALIAS_1}
    ...    tput=${TRAFFIC.UL_THROUGHPUT} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=DL_${UE_ALIAS_1}
    ...    tput=${TRAFFIC.DL_THROUGHPUT} Mbits/sec
    ...    deviation=10%

    Log To Console    ${\n}The End...

    [Teardown]    Run Keywords
    ...           CB009267_keywords.Perform Postconditions Of Test Scenario
    ...      AND
    ...           syve_testline.CCRT Test Cases Teardown
