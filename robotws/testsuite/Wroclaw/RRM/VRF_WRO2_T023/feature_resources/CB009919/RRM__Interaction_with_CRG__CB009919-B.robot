*** Settings ***
Documentation
...  contact: Szymon Startek

Library           ute_ue
Library           taf.converters.ttitracer
Library           taf.collectors.ttitrace_4g    WITH NAME  ttitrace_4g
Library           CB009919_keywords.py
Resource          ../../resources/ca_IWK.robot
Resource          ../../resources/ca_INTER_RAT.robot
Variables         testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/TMO/resources/scenario.py


*** Variables ***
${GLOBAL_CELL_ID_LTE}                                  # Global cell ID of the tested LTE cell
${CAP_LTE_UE1}                LTE_TRINITY              # Capability of UE1 configured for first MME
${CAP_LTE_UE2}                LTE_TATRA                # Capability of UE2 configured for second MME
${SCF_PATH}                                            # Path to the SCF with initial config prepared
${REVERT_CHANGES}             True                     # Determines whether the initial configuration will to be restored
${ATTENUATED_CELL}                                     # Name of attenuated cell taken from ${TA_ATTENUATOR_CONFIG}
${LOCAL_CONNECTION}                                    # Alias of BTS. Value can be eNB or gNB
${CELL1_PATH}                                          # Path to qrxlevmin of cell used in the test
${CELL1_QRXLEVMIN}                                     # qrxlevmin to be set on cell used in the test
${CELL2_PATH}                                          # Path to qrxlevmin of cell not used in the test
${CELL2_QRXLEVMIN}                                     # qrxlevmin to be set on cell not used in the test


*** Keywords ***
TC__RRM__Interaction_with_CRG__CB009919-B
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-dawid.kurowski@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS23R3    FEATURE-CB009919    GROUP_IN_CHARGE-WRO_4_Vrf


    Preconditions
    Step 1: Start Calls
    Step 2: Collect TTI Traces
    Step 3: Verify DL TTI Results
    Step 4: Verify UL TTI Results


Preconditions
    Log   === Start Preconditions ===    console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  False
    ${lte_id}  Get BTS ID From ADMIN  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${LTE_ID}  ${lte_id}
    Initial Config
    Set qrxlevmin Level  ${CELL1_PATH}  ${CELL1_QRXLEVMIN}  LTE
    Set qrxlevmin Level  ${CELL2_PATH}  ${CELL2_QRXLEVMIN}  LTE
    Require UE  LTE_UE1  capabilities=${CAP_LTE_UE1}
    Require UE  LTE_UE2  capabilities=${CAP_LTE_UE2}
    Attenuation Setting
    ${sw_version}=  Get SW Version  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${SW_VERSION}  ${sw_version}
    Log  === Preconditions Finished ===  console=True


Initial Config
    Set Test Variable  ${COMMISIONING_PERFORMED}  True
    Log  === Perform Commissioning SCF With Required Parameters ===  console=True
    Get Current Scf File  ${LOG_PATH}  scf_original.xml  connection=${LOCAL_CONNECTION}
    Perform Commissioning  ${LTE_ID}  ${SCF_PATH}  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}

    Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False

Attenuation Setting
    Log To Console   === Attenuation Setting ===
    Set Attenuation For All Cells  100%
    Set Attenuation  ${ATTENUATED_CELL}  0%
    Sleep  2  reason=Time for setup attenuation
    ${attenuation_level}  Read Attenuation  ${ATTENUATED_CELL}
    Sleep  2  reason=Time for read attenuation
    Log To Console    ${attenuation_level}


Step 1: Start Calls
    Log  ==== Step 1: Start Calls ====  console=True
    Log  = Prepare UEs For Data Transfer =  console=True
    Prepare UE For Data Transfer  LTE_UE1  ${GLOBAL_CELL_ID_LTE}  connection=${LOCAL_CONNECTION}
    Prepare UE For Data Transfer  LTE_UE2  ${GLOBAL_CELL_ID_LTE}  connection=${LOCAL_CONNECTION}
    Start Data Transfer  LTE_DL1  LTE_UE1  dl  duration=600s  protocol=tcp  buffer=32M  max_segment_size=1400
    Start Data Transfer  LTE_DL2  LTE_UE2  dl  duration=600s  protocol=tcp  buffer=32M  max_segment_size=1400
    Start Data Transfer  LTE_UL1  LTE_UE1  ul  duration=600s  protocol=tcp  buffer=32M  max_segment_size=1400
    Start Data Transfer  LTE_UL2  LTE_UE2  ul  duration=600s  protocol=tcp  buffer=32M  max_segment_size=1400
    Sleep  10s  reason=for calls to stabilize


Step 2: Collect TTI Traces
    Log  ==== Step 2: Collecting TTI Traces ====  console=True
    Check Data Transfer Is Alive  LTE_DL1
    Check Data Transfer Is Alive  LTE_DL2
    Collect 4G TTI Trace  cell_id=${GLOBAL_CELL_ID_LTE}
    ...             trace_time=10 seconds
    ...             output_path=${LOG_PATH}/trace
    Parse 4G TTI Trace  ${SW_VERSION}  duplex=tdd
    Parse 4G TTI Trace  ${SW_VERSION}  UL  install_decoder=False  duplex=tdd
    [Teardown]  Stop Data Transfers For All Ues


Step 3: Verify DL TTI Results
    Log  ==== Step 3: Verify DL TTI Results ====  console=True
    ${list_of_ueIndex}  Get Column With Name  ${LOG_PATH}/trace/ttitrace/lte_tti_DL.txt  ETtiTraceDlParUe_ueIndex
    ${first_ueIndex_in_percents}  ${second_ueIndex_in_percents}  Get Values In Percents  ${list_of_ueIndex}
    Log  ==== Percentage of occurrences for first UE is ${first_ueIndex_in_percents}% ====  console=True
    Log  ==== Percentage of occurrences for second UE is ${second_ueIndex_in_percents}% ====  console=True
    Should Be True  57 <= ${first_ueIndex_in_percents} <= 63
    ...    msg=The percentage of occurrences first ueIndex is different than 60%
    Should Be True  37 <= ${second_ueIndex_in_percents} <= 43
    ...    msg=The percentage of occurrences second ueIndex is different than 40%


Step 4: Verify UL TTI Results
    Log  ==== Step 4: Verify UL TTI Results ====  console=True
    ${list_of_ueIndex}  Get Column With Name  ${LOG_PATH}/trace/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_ueIndex
    ${first_ueIndex_in_percents}  ${second_ueIndex_in_percents}  Get Values In Percents  ${list_of_ueIndex}
    Log  ==== Percentage of occurrences for first UE is ${first_ueIndex_in_percents}% ====  console=True
    Log  ==== Percentage of occurrences for second UE is ${second_ueIndex_in_percents}% ====  console=True
    Should Be True  55 <= ${first_ueIndex_in_percents} <= 65
    ...    msg=The percentage of occurrences first ueIndex is different than 60%
    Should Be True  35 <= ${second_ueIndex_in_percents} <= 45
    ...    msg=The percentage of occurrences second ueIndex is different than 40%


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  === TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  LTE_UE1
    Detach UE  LTE_UE2
    Stop Wireshark Log Collection For IWK Test
    Run Keyword If  ${COMMISIONING_PERFORMED} and ${REVERT_CHANGES}  Perform Commissioning
    ...  ${LTE_ID}  ${LOG_PATH}/scf_original.xml  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True  stop_wireshark=False
