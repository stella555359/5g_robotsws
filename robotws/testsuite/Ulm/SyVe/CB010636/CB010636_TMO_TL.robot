*** Settings ***
Documentation

...    | [5G25R3]      | CB010636 NR_Carrier_Aggregation_Counters-Data_Volumes_and_Throughput   |
...    | Test case:    | CB010636-A4 for CNI 126924                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                  |
...    | Author:       | Frank                                                                |
...    | Team:         | MN RAN RD VRF ULM 4                                                  |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                             |
...    | Description:  | TCs for CB010636-A4 for CNI 126924 which uses the 9267 keywords      |
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]


Library                         taf.ue
Resource                        ../CB009267/CB009267_keywords.robot
Resource                        ../resources/attenuator.robot

Resource                        resources/CB010636_Verification_KW.robot
# commissioning is implemented in CB009267_Commissioning.robot because CB009267_keywords is used
Resource                        ../CB009267/resources/CB009267_Commissioning.robot


Suite Setup                     CB009267_keywords.Prepare TL for Testing
Suite Teardown                  CB009267_keywords.Save all Logs and Teardown TL

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT_1=100 Mbits/sec
...                             DL_THROUGHPUT_2=1400 Mbits/sec
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
CB010636-A_TC04_NSA_2CC_DL_CA_check_CA_RLC_PDU_bufferBased_config_A202
    [Documentation]
    ...  | CB010636-A_TC04_TMOUS_NSA on the TMO_v2 testlines TL126 and TL387   |
    ...  | The purpose of test case is to verify the counters for CNI 126924 derived from CB010636-A_TC04 for |
    ...  | The 9267 keywords are used for this TC implementation |
    [Tags]    QCD_MN_RAN
    ...    CB010636-A_TC04_TMO
    [Setup]    CB009267_keywords.Setup Test for CB009267

    Log To Console    ${\n}This is testcase
    Log To Console    CB010636-A_TC04_TMOUS_NSA_2CC_DL_CA_check_CA_RLC_PDU_bufferBased_config_A202
    ${nrbts_id}        scf_info.Get NRBTS-Id  ${GNB_ID}
    Set Test Variable     ${nrbts_id}
    Log To Console    NRBTS ID is ${nrbts_id}

    IF   ${nrbts_id} == 403891
        CB009267_keywords.Set Test Case Variables For NSA
        ...   TC_NUMBER=A-04
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1=${101}    S_PCELL_UE_1=${11}      SCELL_UE_1=${10}
        ...                        S_PCELL_UE_2=${None}   SCELL_UE_2=${None}
        ...   PCELL_UE_3=${None}   S_PCELL_UE_3=${None}   SCELL_UE_3=${None}
        ...   ADJ_CELLS_GNB0=${{ [2,8] }}
    ELSE IF   ${nrbts_id} in [401261,403871]
        CB009267_keywords.Set Test Case Variables For NSA
        ...   TC_NUMBER=A-04
        ...   gnb_id=${0}  enb_id=${0}
        ...   capabilities=UE_1
        ...   PCELL_UE_1=${101}    S_PCELL_UE_1=${10}     SCELL_UE_1=${11}
        ...                       S_PCELL_UE_2=${None}   SCELL_UE_2=${None}
        ...   PCELL_UE_3=${None}  S_PCELL_UE_3=${None}   SCELL_UE_3=${None}
        ...   ADJ_CELLS_GNB0=${{ [5] }}
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
        admin.Unblock Cell  dist_name=${4g_mrbts_nidd}/LNCEL-${PCELL_UE_1}  timeout=${20}  connection=${enb_alias}
    END

    Log To Console    UE_Alias_1 paremeter is: ${UE_ALIAS_1}
#    taf.ue.Reboot Ue  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #  Start Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Start Necessary Traces

    #   Wait for next PM counter measurement period STARTS
    #   1. Part of TC: start call on LTE cell and add 5G spcell S_PCELL_UE_1, BLOCK 5G scell SCELL_UE_1
    #                  only counter M55349C00083 is pegged (>= 1)
    #                  counter M55349C00084 is == 0
    #                  ==> 1. Period

   Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${0}
    END
    Log To Console    ${\n}-> 1. Measurement Period STARTED

    #  Attach UE to 4G LTE cell ${PCELL_UE_1}
    Log To Console    ${\n}Attach UE to LTE source cell ${PCELL_UE_1}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${PCELL_UE_1}  value=${10}  node_id=${enb_id}  node_type=enb
    taf.ue.Attach Ue   ${UE_ALIAS_1}
    Sleep  10s  reason=wait for attach

    #  Add 5G leg ONLY for s-pcell ${S_PCELL_UE_1} and keep scell ${SCELL_UE_1} blocked with attenuator max value
    Log To Console    Add 5G leg to UE ONLY with sec.p-cell ${S_PCELL_UE_1}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${S_PCELL_UE_1}  value=${10}  node_id=${gnb_id}  node_type=gnb

    #  Start 1. low DL traffic on LTE and add afterwards 5G pscell  cell
    Log To Console    ${\n}Start 1. DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT_1}
    Log To Console    1. Measurement Period - only counter M55349C00083 is pegged
    taf.ue.Start Data Transfer
    ...    dt_name=DL_1_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT_1}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M
    Sleep  4s  reason=wait for traffic
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #   Wait for next PM counter measurement period STARTS
    #   2. Part of TC: UN-BLOCK and add 5G scell SCELL_UE_1 to the call and add 2. data DL traffic
    #                  both counter M55349C00083 is pegged (>= 1, UNtill scell is added)
    #                  and  counter M55349C00084 is pegged (>= 1, after scell is added)
    #                  ==> 2. Period
   Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${0}
    END
    Log To Console    ${\n}-> 2. Measurement Period STARTED, let traffic run for 120 sec
    Log To Console    then start 2. DL data traffic stream
    Log To Console    then add Scell ${SCELL_UE_1} with attenuaton = 10 -> both counters 83 + 84 are pegged
    Sleep    120sec  reason=let traffic run for 120 seconds

    #  Start 2. DL traffic with higher data rate and add 5G scell ${SCELL_UE_1}
    Log To Console    ${\n}Start 2. DL traffic with datarate ${TRAFFIC.DL_THROUGHPUT_2}
    taf.ue.Start Data Transfer
    ...    dt_name=DL_2_${UE_ALIAS_1}  ue_alias=${UE_ALIAS_1}
    ...    direction=dl  duration=${TRAFFIC.DURATION}
    ...    throughput=${TRAFFIC.DL_THROUGHPUT_2}    protocol=${TRAFFIC.PROTOCOL}
    ...    packet=1320  buffer=16M

    #  Add 5G leg for scell ${SCELL_UE_1}
    attenuator_scenario.Set Cell Attenuation
    ...   globalcellid=${SCELL_UE_1}  value=${10}  node_id=${gnb_id}  node_type=gnb
    Sleep  4s  reason=wait for traffic
    taf.ue.Log UE Info   ${UE_ALIAS_1}

    #   Wait for next PM counter measurement period STARTS
    #   3. Part of TC: keep 2CC NSA call with high traffic running, S_PCELL_UE_1
    #                  counter M55349C00083 is NOT pegged (== 0, because scell is there)
    #                  and  counter M55349C00084 is == pegged (>= 1, because scell is added)
    #                  ==> 3. Period
    Log To Console    $WITH_PM_COUNTER_CHECK is ${WITH_PM_COUNTER_CHECK}
    IF  $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: WAIT for START of next Measurement Period
       pmcounters.Wait Until The Next Measurement Period Starts    gnb_id=${0}
    END
    Log To Console    ${\n}-> 3. Measurement Period STARTED
    Log To Console    traffic in WHOLE period on PScell + Scell -> only counter 84 is pegged

    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Wait untill current Measurement Period stops
       pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${gnb_id}
       ${PM_FILES}=    Collect PM Counter
       Set Test Variable    ${PM_FILES}
    END
    Log To Console    ${\n}Last Measurement Period STOPPED

    #   Stop Tcpdump on gNB Common Unit and Test PC
    CB009267_keywords.Stop All Traces

    #   Stop DL traffic and detach UE
    Log To Console    ${\n}Stop all data transfer and detach UE ${UE_ALIAS_1}
    taf.ue.Stop Data Transfer    DL_1_${UE_ALIAS_1}
    taf.ue.Stop Data Transfer    DL_2_${UE_ALIAS_1}
    taf.ue.Stop Data Transfers For All Ues
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    taf.ue.Clear Naa Storage   ${UE_ALIAS_1}
    Sleep  10s  reason=wait release of resources

    #   Do verification of PM counters after stop of all traffic and detach UE
    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Verify PM Counters
       CB010636_Verification_KW.Verify CB010636-A_TC04_TMO PM Values Per Cells
    END


    [Teardown]    Run Keywords
    ...           CB009267_keywords.Perform Postconditions of Test Scenario
    ...      AND
    ...           syve_testline.CCRT Test Cases Teardown
