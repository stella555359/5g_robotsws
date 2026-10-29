*** Settings ***
Documentation
...    | [5G25R2]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-A                                                           |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                  |
...    | Author:       | Frank                                                                |
...    | Team:         | MN RAN RD VRF ULM 4                                                  |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                             |
...    | Description:  | TCs for CB009267-A, new implementation NOT based on CB010636         |
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB009267_keywords.robot
Resource                        ../resources/attenuator.robot

Resource                        resources/CB009267_Verification.robot
Resource                        resources/CB009267_Commissioning.robot


Suite Setup                     CB009267_keywords.Prepare TL for Testing
Suite Teardown                  CB009267_keywords.Save all Logs and Teardown TL

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

*** Test Cases ***
CB009267-A_TC04_SA_4CC_DL-UL_CA_and_PCell_switch_reestablishment_bufferBased_B4
    [Documentation]
    ...  | CB009267-A_TC04_SA     |
    ...  | The purpose of test case is to verify the counters after A2 based PCell switch or call reestablishment  |
    [Tags]    QCD_MN_RAN
    ...    CB009267-A_TC04
    [Setup]    CB009267_keywords.Setup Test for CB009267

    Log To Console    ${\n}This is testcase
    Log To Console    CB009267-A_TC04_SA_4CC_DL-UL_CA_and_PCell_switch_reestablishment_bufferBased_B4  using the SDX75.

    #   The cell PCELL_UE_1_P2S is the source PRIMARY cell and gets a target SECONDARY cell
    #   The cell S_CELL_UE_1_S2P is a source SECONDARY cell and becomes a target PRIMARY cell
    ${nrbts_id}        scf_info.Get NRBTS-Id  ${GNB_ID}
    Set Test Variable     ${nrbts_id}
    Log To Console    NRBTS ID is ${nrbts_id}

    IF   ${nrbts_id} == 403891
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=A-04
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${8}   S_CELL_UE_1_S2P=${9}   S_CELL_UE_1_SOURCE=${{ [4,13] }}
        ...   S_CELL_UE_1_TARGET=${6}
        ...   ADJ_CELLS_GNB0=${{ [3,5,14] }}
    ELSE IF   ${nrbts_id} in [401261,403871]
        CB009267_keywords.Set Test Case Variables For SA
        ...   TC_NUMBER=A-04
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1_P2S=${13}   S_CELL_UE_1_S2P=${10}   S_CELL_UE_1_SOURCE=${{ [4,7] }}
        ...   S_CELL_UE_1_TARGET=${8}
        ...   ADJ_CELLS_GNB0=${{ [5,6,9] }}
        # NRHOIF_... variables are needed, because the NRHOIF objects are numbered sequential and not cell-id related
        # therefore they are testline specific - check the ssbFrequency in the target cells
        Set Test Variable   ${NRHOIF_S2PCELL_ID}   ${4}
        Set Test Variable   ${NRHOIF_P2SCELL_ID}   ${7}

        Set Test Variable   ${UE_ALIAS_1}   UE_1
    ELSE
        Fail    No TC variables are defined for gNB with NRBTS ID ${nrbts_id}
    END

    Log To Console    ${\n}brief testcase scenario:
    Log To Console    5G call starts on gNB-${gnb_id} source p-cell is ${PCELL_UE_1_P2S} and
    Log To Console    5G s-cells are ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    Log To Console    pcell switch due to A2 based measurement is done to
    Log To Console    gNB-${gnb_id} target p-cell is ${S_CELL_UE_1_S2P} and
    Log To Console    5G target s-cells are ${S_CELL_UE_1_TARGET} and ${PCELL_UE_1_P2S}
    Log to Console    Adjacent cells on gNB-${gnb_id} are ${ADJ_CELLS_GNB0}

    CB009267_keywords.Perform Preconditions of Test Scenario
    ...   gnb_id=${gnb_id}
    ...   enb_id=${enb_id}
    ...   capabilities=${capabilities}

    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Reboot Ue  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #  Start Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Start Necessary Traces

    #  1. Wait for next PM counter measurement period STARTS
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait until the next Measurement Period starts    gnb_id=${0}
       Log To Console    ${\n}Measurement Period STARTED, let traffic run for the whole period
    END
    Sleep   20sec  reason=wait for 20s until start of the scenario

    #  2. Attach UE to 5G cell ${PCELL_UE_1_P2S}
    Log To Console    ${\n}Attach UE to 5G source cell ${PCELL_UE_1_P2S} add add scells ${S_CELL_UE_1_S2P} and ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${PCELL_UE_1_P2S}  value=${10}  node_id=${gnb_id}  node_type=gnb
    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Attach Ue   ${UE_ALIAS_1}   timeout=40

    Sleep   20s  reason=wait for attach

    #  3. Add 5G scells ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_SOURCE}
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${S_CELL_UE_1_S2P}  value=${40}  node_id=${gnb_id}  node_type=gnb
    ${scells}   Set Variable    ${0}
    FOR  ${scells}  IN  @{S_CELL_UE_1_SOURCE}
         attenuator_scenario.Set cell attenuation
         ...   globalcellid=${scells}  value=${40}  node_id=${gnb_id}  node_type=gnb
    END

    #  4. Set the upcoming target scell to 60 at the testcase scenario start
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${S_CELL_UE_1_TARGET}  value=${60}  node_id=${gnb_id}  node_type=gnb
    Sleep  5s  reason=wait before start of traffic

    #  5. Start UL + DL traffic on all cells
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

    # do 1. tcpdump log file for attach to source cell and start traffic and start (2.) tcpdump logs again
    CB009267_keywords.Stop All Traces   tcpdump_filename=attach_source_pcell+scells.pcap
    Set Test Variable  ${tcp_file_gnb${gnb_id}_attach+startTraffic}  ${tcp_file_gnb${gnb_id}}
    CB009267_keywords.Start Necessary Traces

    #  6. Start pcell switch attenuator scenario from source to target pcell and scells
    Log To Console    ${\n}Start pcell switch attenuator scenario:
    Log To Console    Increase attenuation of 5G source pcell ${PCELL_UE_1_P2S} and scells ${S_CELL_UE_1_SOURCE}
    Log To Console    Decrease attenuation for new target pcell ${S_CELL_UE_1_S2P} and scells ${S_CELL_UE_1_TARGET}
    ${att_file}=  attenuator_scenario.prepare single scenario file
    ...   scenfile=${CURDIR}/attenuator_scenario_9267.txt
    ...   scenario=${TEST_NAME}
    attenuator_scenario.run attenuator scenario by cell
    ...   att_file=${att_file}  scenario=${TEST_NAME}
    Sleep    5sec  reason=wait for pcell switch is done

    # do 2. tcpdump log file for pcell switch scenario and start (3.) tcpdump logs again
    CB009267_keywords.Stop All Traces   tcpdump_filename=pcell_switch.pcap
    Set Test Variable  ${tcp_file_gnb${gnb_id}_pcell_switch}  ${tcp_file_gnb${gnb_id}}
    CB009267_keywords.Start Necessary Traces

    #  7. Wait for next PM counter measurement period STOPS
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait until current Measurement Period stops
       pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}
       Log To Console    ${\n}Measurement Period STOPPED
       ${PM_FILES}=    Collect PM Counter
       Set Test Variable    ${PM_FILES}
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

    #   10. Do verification of PM counters after stop of all traffic and  detach UE
    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Verify PM Counters
       CB009267_Verification.Verify CB009267-A TC04 PM Values per Cells
    END

    [Teardown]    Run Keywords
    ...           CB009267_keywords.Perform Postconditions of Test Scenario
    ...      AND
    ...           syve_testline.CCRT Test Cases Teardown
