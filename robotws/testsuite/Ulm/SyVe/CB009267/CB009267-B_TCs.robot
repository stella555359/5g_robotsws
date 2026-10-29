*** Settings ***
Documentation
...    | [5G25R2]      | CB009267-SR NR Carrier Aggregation Counters for Accessibility, Retainability and Utilization KPIs   |
...    | Test case:    | CB009267-B                                                           |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                  |
...    | Author:       | Frank                                                                |
...    | Team:         | MN RAN RD VRF ULM 4                                                  |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                             |
...    | Description:  | TCs for CB009267-B                                                   |
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library                         taf.ue
Resource                        CB009267_keywords.robot
Resource                        ../resources/attenuator.robot

Resource                        resources/CB009267_Verification.robot
Resource                        resources/CB009267_Commissioning.robot


Suite Setup                     CB009267_keywords.Prepare TL for Testing
Suite Teardown                  CB009267_keywords.Save all Logs and Teardown TL

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=2000 Mbits/sec
...                             UL_THROUGHPUT=50 Mbits/sec
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
CB009267-B_TC11_NSA_2CC_DL_CA_Scell_release_inact_badRLQ_B201
    [Documentation]
    ...  | CB009267-B_TC11_NSA     |
    ...  | The purpose of test case is to verify the counters for SCell release due to attenuation - bad radio link quality |
    ...  | and then SCell deactivation/release due to inactivity.  |
    [Tags]    QCD_MN_RAN
    ...    CB009267-B_TC11
    [Setup]    CB009267_keywords.Setup Test for CB009267

    Log To Console    ${\n}This is testcase
    Log To Console    CB009267-B_TC11_NSA_2CC_DL_CA_Scell_release_inact_badRLQ_B201 using the SDX75.
    ${nrbts_id}        scf_info.Get NRBTS-Id  ${GNB_ID}
    Set Test Variable     ${nrbts_id}
    Log To Console    NRBTS ID is ${nrbts_id}

    IF   ${nrbts_id} == 403891
        CB009267_keywords.Set Test Case Variables For NSA
        ...   TC_NUMBER=B-11
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1=${8}     S_PCELL_UE_1=${9}      SCELL_UE_1=${1}
        ...                       S_PCELL_UE_2=${None}   SCELL_UE_2=${None}
        ...   PCELL_UE_3=${None}  S_PCELL_UE_3=${None}   SCELL_UE_3=${None}
        ...   ADJ_CELLS_GNB0=${{ [2,8] }}
    ELSE IF   ${nrbts_id} in [401261,403871]
        CB009267_keywords.Set Test Case Variables For NSA
        ...   TC_NUMBER=B-11
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1=${101}    S_PCELL_UE_1=${10}     SCELL_UE_1=${11}
        ...                       S_PCELL_UE_2=${None}   SCELL_UE_2=${None}
        ...   PCELL_UE_3=${None}  S_PCELL_UE_3=${None}   SCELL_UE_3=${None}
        ...   ADJ_CELLS_GNB0=${{ [5,7,9] }}
    ELSE
        Fail    No TC variables are defined for gNB with NRBTS ID ${nrbts_id}
    END

    Log To Console    ${\n}LTE on eNB-${enb_id} primary cell is ${PCELL_UE_1}
    Log To Console    5G on gNB-${gnb_id} secondary p-cell is ${S_PCELL_UE_1} and 5G s-cell is ${SCELL_UE_1}

    CB009267_keywords.Perform Preconditions of Test Scenario
    ...   gnb_id=${gnb_id}
    ...   enb_id=${enb_id}
    ...   capabilities=${capabilities}

    #  UN - Block eNB LTE/4G pcell for NSA call and keep all other LTE cells blocked
    IF  $BLOCK_ENB
        Log To Console  UNBLOCK LTE cell NRCELL-${PCELL_UE_1} on eNB-${enb_id} to start NSA call
        ${mrbts_id_1}  scf_info.Get MRBTS-Id  enb_id=${enb_id}
        ${4g_mrbts_nidd}=   Set Variable    MRBTS-${mrbts_id_1}/LNBTS-${mrbts_id_1}
        ${enb_alias}  Setup OAM HTTP Session  node_type=enb  node_id=${enb_id}
        admin.unblock_cell  dist_name=${4g_mrbts_nidd}/LNCEL-${PCELL_UE_1}  timeout=${20}  connection=${enb_alias}
    END

    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
    taf.ue.Reboot Ue  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #  Start Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Start Necessary Traces

    #  Attach UE to 4G LTE cell ${PCELL_UE_1}
    Log To Console    ${\n}Attach UE to LTE source cell ${PCELL_UE_1}
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${PCELL_UE_1}  value=${10}  node_id=${enb_id}  node_type=enb
    taf.ue.Attach Ue   ${UE_ALIAS_1}
    Sleep  10s  reason=wait for attach

    #  Add 5G leg for s-pcell ${S_PCELL_UE_1} and scell ${SCELL_UE_1}
    Log To Console    ${\n}Add 5G leg to UE with sec.p-cell ${S_PCELL_UE_1} add add scell ${SCELL_UE_1}
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${S_PCELL_UE_1}  value=${10}  node_id=${gnb_id}  node_type=gnb
    Sleep  5s  reason=wait for attach to 5G secondary pcell before adding 5G scell
    attenuator_scenario.Set cell attenuation
    ...   globalcellid=${SCELL_UE_1}  value=${10}  node_id=${gnb_id}  node_type=gnb

    #  Start DL traffic on all cells
    Log To Console    ${\n}Start DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT}
    taf.ue.Start Data Transfer
    ...    dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep  10s  reason=wait for traffic

    #   Wait for next PM counter measurement period STARTS
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait until the next Measurement Period starts    gnb_id=${0}
       Log To Console    ${\n}Measurement Period STARTED
    END

    #   1. Part of TC: stop traffic after 60s to get inactivity timer expire
    #                  and this triggers counters M55118C11033 + 34, 43 + 44 in S_PCELL_UE_1
    #                  for Release of SCELL_UE_1
    Log To Console    ${\n}Stop traffic after 60 seconds and wait 90 sec for inactivity_timer exceed
    Sleep    60sec  reason=let traffic run for 60 seconds
    taf.ue.Stop Data Transfer    DL_${UE_ALIAS_1}
    Log To Console    ${\n}Traffic stopped
    Sleep    90sec  reason=wait for buffer getting empty and inactivity_timer exceeds
    Log To Console    ${\n}End of wait period (90sec) for inactivty_timer exceed

    #   2. Part of TC: start traffic again and
    #                  increase attenuation for scell SCELL_UE_1 from 40, step 5 to 75 dB
    #                  to get bad RLQ detected
    #                  and this triggers counters M55118C11035 + 36, 43 + 44 in S_PCELL_UE_1
    Log To Console    ${\n}Start traffic again and increase after 30 sec the attenuation
    Log To Console    in 5G secondary cell ${SCELL_UE_1} as specified in attenuator_scenario_9267.txt from 40 to 75 dB
    Log To Console    to get bad RLQ detected in the 5G secondary pcell S_PCELL_UE_1 = ${S_PCELL_UE_1}
    taf.ue.Start Data Transfer
    ...     dt_name=DL_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}  direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT}    protocol=${TRAFFIC.PROTOCOL}  packet=1320  buffer=16M
    Sleep    30sec  reason=let traffic run for 30s

    ${att_file}=  attenuator_scenario.prepare single scenario file
    ...   scenfile=${CURDIR}/attenuator_scenario_9267.txt
    ...   scenario=${TEST_NAME}
    attenuator_scenario.run attenuator scenario by cell
    ...   att_file=${att_file}  scenario=${TEST_NAME}

    Sleep    30sec  reason=wait for gNB to detect bad RLQ

    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait untill current Measurement Period stops
       pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}
       ${PM_FILES}=    Collect PM Counter
       Set Test Variable    ${PM_FILES}
    END
    Log To Console    ${\n}Measurement Period STOPPED

    #   Stop Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Stop All Traces

    #   Stop DL traffic and detach UE
    taf.ue.Stop Data Transfer    DL_${UE_ALIAS_1}
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    Sleep  20s  reason=wait release of resources

    #   Do verification of PM counters after stop of all traffic and  detach UE
    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Verify PM Counters
       CB009267_Verification.Verify CB009267-B TC11 PM Values per Cells
    END

    [Teardown]    Run Keywords
    ...           CB009267_keywords.Perform Postconditions of Test Scenario
    ...      AND
    ...           syve_testline.CCRT Test Cases Teardown
