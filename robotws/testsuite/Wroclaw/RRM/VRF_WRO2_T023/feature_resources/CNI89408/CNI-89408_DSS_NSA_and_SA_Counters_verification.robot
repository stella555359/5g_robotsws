*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library    ute_ue
Library    taf.analyzer.pmcounter
Library    ute_tshark
Resource   ../../resources/ca_IWK.robot


*** Variables ***
${NSA_ANCHOR_CELL_ID}                         # ID of LTE Anchor cell in NSA mode for which counter will be tested.
${SA_CELL_ID}                                 # ID of NR SA DSS cell for which counter will be tested.
${NR_CELL_ID}                                 # GLOBAL ID of NR SA DSS cell for which counter will be tested.
${LTE_CELL_ID}                                # GLOBAL ID of LTE DSS cell.
${SA_UE_CAP}                                  # Capability indicates proper SA UE
${NSA_UE_CAP}                                 # Capability indicates proper NSA UE
${BLANKED_PUCCH}                              # Expected value for 'blankedPucch' parameter.
${LNRELGNBCELL_ID}                            # ID of LNRELGNBCELL_A cell for 'Set Test Variables For CB005860 Test Single BTS' check
${CONNECTIVITY}                               # Alias of admin connection
${GNB_MPLANE}                                 # IP address of GNB MPlane
${INTER_RAT_SETUP}                            # Parameter for 'Set Test Variables For CB005860 Test Single BTS'

*** Keywords ***
TC__CNI-89408_DSS_NSA_and_SA_Counters_verification
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-adam.szczerba@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS23R2    FEATURE-CNI89408    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Attach NSA Ue
    Step 2: Attach SA Ue
    Step 3: Collect Counters
    Step 4: Check All Counters Values
    Step 5: Check Number Of Packets


Preconditions
    Log  \n=== Preconditions ===  console=True
    Set Test Variables For CB005860 Test Single BTS  ${LNRELGNBCELL_ID}  ${CONNECTIVITY}
    Check Preconditions For CB005860 Test  ${BLANKED_PUCCH}
    Require UE  NR_NSA  ${NSA_UE_CAP}
    Require UE  NR_SA   ${SA_UE_CAP}
    Log  Preconditions passed!  console=True
    ${waiting_time} =  ca_IWK.Count Measurement Period  ${MPLANE_IP}  15
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.


Step ${nr}: Attach ${deptype} Ue
    Log  \n=== Step ${nr}: Attach UE to ${deptype} cell ===  console=True
    Start Wireshark Log Collection For IWK Test  options=-i any host ${GNB_MPLANE} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False  alias=tcpdump_${deptype}
    ${cell} =  Set Variable  ${EMPTY}
    Run Keyword If  '${deptype}'=='NSA'  Set Test Variable  ${cell}  ${NSA_ANCHOR_CELL_ID}
    ...    ELSE IF  '${deptype}'=='SA'   Set Test Variable  ${cell}  ${SA_CELL_ID}
    FOR  ${index}  IN RANGE  1  4
        Log  === ${index} attach attempt ===  console=True
        Attach Ue  NR_${deptype}
        Validate Ue Info  NR_${deptype}  CELL_ID  ${cell}
        Sleep  10s
        Detach UE  NR_${deptype}  timeout=40
    END
    [Teardown]
    Stop Wireshark Log Collection For IWK Test  log_directory=${LOG_PATH}/pcap_logs/${deptype}  alias=tcpdump_${deptype}

Step 3: Collect Counters
    Log  \n=== Step 3: Collect Counters ===  console=True
    Log  \nWaiting for counters, that may take a while ...  console=True
    ${waiting_time} =  ca_IWK.Count Measurement Period  ${MPLANE_IP}  15    delta=120
    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.
    Collect PM Counters  ${LOG_PATH}/pm_counters_s  host=${MPLANE_IP}  xml_files_left=2  time_interval=15 min   intervals=15
    ${m55112c08002} =  Get Counters Values  ${LOG_PATH}/pm_counters_s  M55112C08002  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  1
    Set Test Variable  ${M55112C08002}  ${m55112c08002}
    ${m55125c13026} =  Get Counters Values  ${LOG_PATH}/pm_counters_s  M55125C13026  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  1
    Set Test Variable  ${M55125C13026}  ${m55125c13026}
    Log  \nCounters collected!  console=True

Get Counters Values
    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${counters_amount}=all
    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  Get PI Value
    ...  pi_list=${counter_list}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*
    ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...                             ${pi_dict}
    ...                             ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    [Return]  ${counter_values}

Step 4: Check All Counters Values
    Log  \n=== Step 4: Check All Counters Values ===  console=True
    ${int_M55125C13026} =  Evaluate  [int(i) for i in ${M55125C13026}]
    ${M55125C13026_sum} =  Evaluate  sum(${int_M55125C13026})
    ${int_M55112C08002} =  Evaluate  [int(i) for i in ${M55112C08002}]
    ${M55112C08002_sum} =  Evaluate  sum(${int_M55112C08002})
    Should Be True  ${M55125C13026_sum}>0  msg=None of the values of counter M55125C13026 isn't greater than 0
    Should Be True  ${M55112C08002_sum}>0  msg=None of the values of counter M55112C08002 isn't greater than 0
    Set Test Variable  ${M55125C13026_SUM}  ${M55125C13026_sum}
    Set Test Variable  ${M55112C08002_SUM}  ${M55112C08002_sum}
    Log  \nAll counters values are corect!  console=True

Step 5: Check Number Of Packets
    Log  \n=== Step 5: Check Number Of Packets ===  console=True
    Move File  ${LOG_PATH}/pcap_logs/NSA/tcpdump_NSA*.pcap  ${LOG_PATH}/pcap_logs/NSA/tcpdump_NSA.pcap
    Move File  ${LOG_PATH}/pcap_logs/SA/tcpdump_SA*.pcap    ${LOG_PATH}/pcap_logs/SA/tcpdump_SA.pcap
    Setup Tshark  lo  alias=shark
    ${sa_packet_number}  Get Packets Count  packet_filter=(ngap.procedureCode == 14) && (ngap.radioNetwork == 3)
    ...  pcap_file_path=${LOG_PATH}/pcap_logs/SA/tcpdump_SA.pcap
    ...  alias=shark
    ${nsa_packet_number}  get_packets_count  packet_filter=(x2ap.procedureCode == 27) && (x2ap.radioNetwork == 30)
    ...    pcap_file_path=${LOG_PATH}/pcap_logs/NSA/tcpdump_NSA.pcap
    ...    alias=shark
    Teardown Tshark   alias=shark
    Should Be Equal  ${M55125C13026_SUM}  ${sa_packet_number}
    ...  msg=Number of packets is different than value of counter M55125C13026
    Should Be Equal  ${M55112C08002_SUM}  ${nsa_packet_number}
    ...  msg=Number of packets is different than value of counter M55112C08002
    Log  \nNumber of wireshark packets is corect!  console=True

TC Setup
    Inter RAT Test Setup

TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True
    Inter RAT Test Teardown
