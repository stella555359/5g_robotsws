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
${GLOBAL_CELL_ID_LTE}                          # Global cell ID of the tested LTE cell
${CAP_LTE_UE1}                                 # Capability of UE used to LTE UL call
${TPUT_DL_BANDWIDTH}      50 Mbits/sec         # Value of downlink t-put
${TPUT_UL_BANDWIDTH}      10 Mbits/sec         # Value of uplink t-put
${SCF_PATH}                                    # Path to the SCF with initial config prepared
${REVERT_CHANGES}             True             # Determines whether the initial configuration will to be restored
${ATTENUATION}            15db                 # Attenuation used in 3rd step
${ATTENUATED_CELL}                             # Name of attenuated cell taken from ${TA_ATTENUATOR_CONFIG}
${LOCAL_CONNECTION}                            # Alias of BTS. Value can be eNB or gNB
${CELL1_PATH}                                  # Path to qrxlevmin of cell used in the test
${CELL1_QRXLEVMIN}                             # qrxlevmin to be set on cell used in the test
${CELL2_PATH}                                  # Path to qrxlevmin of cell not used in the test
${CELL2_QRXLEVMIN}                             # qrxlevmin to be set on cell not used in the test


*** Keywords ***
TC__RRM__UL_256QAM_support_with_channel_quality_monitoring_enabled__CB009919-B
    Set Tags    CA-INTER_RAT    AUTHOR-michal.hadrysiak@nokia.com    OWNER-dawid.kurowski@nokia.com
    ...         MAINTAINER-michal.hadrysiak@nokia.com    PHASE-CRT   SW-SBTS23R3    FEATURE-CB009919    GROUP_IN_CHARGE-WRO_4_Vrf

    Preconditions
    Step 1: Start UL Call
    Step 2: Check 256QAM Modulation
    Step 3: Reconfigure To non-256QAM Modulation
    Step 4: Reconfigure To 256QAM Modulation
    Step 5: Verify Max T-puts


Preconditions
    Log   === Start Preconditions ===    console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  False
    ${lte_id}  Get BTS ID From ADMIN  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${LTE_ID}  ${lte_id}
    Initial Config
    Set qrxlevmin Level  ${CELL1_PATH}  ${CELL1_QRXLEVMIN}  LTE
    Set qrxlevmin Level  ${CELL2_PATH}  ${CELL2_QRXLEVMIN}  LTE
    Require UE  LTE_UE1  capabilities=${CAP_LTE_UE1}
    Attenuation Setting
    ${sw_version}=  Get SW Version  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${SW_VERSION}  ${sw_version}
    Log  === Preconditions Finished ===  console=True


Attenuation Setting
    Log To Console   === Attenuation Setting ===
    Set Attenuation For All Cells  90db
    Set Attenuation  ${ATTENUATED_CELL}  0db
    Sleep  2  reason=Time for setup attenuation
    ${attenuation_level}  Read Attenuation  ${ATTENUATED_CELL}
    Log To Console    ${attenuation_level}


Initial Config
    Log  === Perform Commissioning SCF With Required Parameters ===  console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  True
    Get Current Scf File  ${LOG_PATH}  scf_original.xml  connection=${LOCAL_CONNECTION}
    Perform Commissioning  ${LTE_ID}  ${SCF_PATH}  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}

    Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False

Step 1: Start UL Call
    Log  ==== Step 1: Start UL Call ====  console=True
    Log  = Prepare UEs For Data Transfer =  console=True
    Prepare UE For Data Transfer  LTE_UE1  ${GLOBAL_CELL_ID_LTE}  connection=${LOCAL_CONNECTION}
    Start Data Transfer  LTE_UL  LTE_UE1  ul  duration=600s  protocol=tcp
    ...                  max_segment_size=1400  buffer=32M
    Sleep  20s  reason=for calls to stabilize
    Check Data Transfer Is Alive  LTE_UL


Step 2: Check 256QAM Modulation
    Log  ==== Step 2: Check 256QAM Modulation ====  console=True
    Collect TTI Trace  step_2
    Verify Modulation  step_2  256QamTableCqm


Step 3: Reconfigure To non-256QAM Modulation
    Log  ==== Step 3: Reconfigure To non-256QAM Modulation ====  console=True
    Set Attenuation  ${ATTENUATED_CELL}  ${ATTENUATION}
    Sleep  20  reason=Time for setup attenuation and change modulation
    Collect TTI Trace  step_3
    Verify Modulation  step_3  non256QamTableCqm


Step 4: Reconfigure To 256QAM Modulation
    Log  ==== Step 4: Reconfigure To 256QAM Modulation ====  console=True
    Set Attenuation  ${ATTENUATED_CELL}  0db
    Sleep  20  reason=Time for setup attenuation and change modulation
    Collect TTI Trace  step_4
    Verify Modulation  step_4  256QamTableCqm
    Stop Data Transfer  LTE_UL


Step 5: Verify Max T-puts
    Log  ==== Step 5: Verify Max T-puts ====  console=True
    Start Data Transfer  DT_UL  LTE_UE1  ul  duration=100s  protocol=tcp
    ...                  max_segment_size=1400  buffer=32M
    Start Data Transfer  DT_DL  LTE_UE1  dl  duration=100s  protocol=tcp
    ...                  max_segment_size=1400  buffer=32M
    Sleep  30s  Wait for t-put to stabilize
    Verify Average Throughput With Deviation  dt_name=DT_DL  tput=${TPUT_DL_BANDWIDTH}  deviation=10%  omit=5  tput_collection_src=control_app
    Verify Average Throughput With Deviation  dt_name=DT_UL  tput=${TPUT_UL_BANDWIDTH}  deviation=10%  omit=5  tput_collection_src=control_app


Collect TTI Trace
    [Arguments]  ${step}
    Collect 4G TTI Trace  cell_id=${GLOBAL_CELL_ID_LTE}
    ...  trace_time=1 seconds
    ...  output_path=${LOG_PATH}/trace/${step}
    Parse 4G TTI Trace  ${SW_VERSION}  UL  dict_path=${LOG_PATH}/trace/${step}/ttitrace  duplex=tdd


Verify Modulation
    [Arguments]  ${step}  ${modulation}
    ${modulation_table}  Get Column With Name  ${LOG_PATH}/trace/${step}/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_256QamModulationTable
    List Should Contain Value  ${modulation_table}  ${modulation}
    ...  msg=UE is using wrong modulation table.
     Log  ==== UE is using ${modulation} ====  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  === TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  LTE_UE1
    Stop Wireshark Log Collection For IWK Test
    Run Keyword If  ${COMMISIONING_PERFORMED} and ${REVERT_CHANGES}  Perform Commissioning
    ...  ${LTE_ID}  ${LOG_PATH}/scf_original.xml  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True  stop_wireshark=False
