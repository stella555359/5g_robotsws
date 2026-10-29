*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library       SSHLibrary
Library       ute_ue
Library       taf.sbts.oam.coam.admin  WITH NAME  admin
Resource      ../../resources/ca_IWK.robot
Resource      ../../resources/ca_INTER_RAT.robot
Resource      ../../resources/BLER.robot


*** Variables ***
${NR_UE_CAPABILITY}                                    # Capability of NR UE used in test
${NR_CELL_N7}                                          # NR Cell ID on band n7
${ATTACH_CELL_ID}                                      # LTE anchor cell Id
${APN}                                                 # APN name
${DURATION}                                            # Data transfer duration (sek.)
${PM_COUNER_INTERVAL}                                  # PM counter collection interval (sek.)
${PERFORM_OAM_OPERATIONS}                              # Boolean, True if OAM operations should be performed
${RMOD_SERIAL_NUMBER}                                  # RMOD serial number
${TPUT_DL_256QAM_TRUE}                                 # Avg downlink throughput when modulation is 256QAM
${TPUT_UL_256QAM_TRUE}                                 # Avg uplink throughput when modulation is 256QAM
${TPUT_DL_256QAM_FALSE}                                # Avg downlink throughput when modulation is not 256QAM
${TPUT_UL_256QAM_FALSE}                                # Avg uplink throughput when modulation is not 256QAM


*** Keywords ***
TC__CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ

    Set Tags    CA-RRM    AUTHOR-magdalena.swierbutowicz@nokia.com    OWNER-dawid.1.kurowski@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008935_CB011006
    ...         GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Perform NR DL And UL Data Transfer
    Step 2: Disable UL And DL 256QAM
    Step 3: Check Data Transfer Without 256QAM
    Return From Keyword If  not ${PERFORM_OAM_OPERATIONS}
    Step 4: Perform OAM Operations


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    Require Ue  NR_UE  ${NR_UE_CAPABILITY}
    Attach Ue    NR_UE    timeout=10
    ${cell_id}  Get Ue Info  NR_UE  CELL_ID
    Should Be Equal As Strings  ${ATTACH_CELL_ID}  ${cell_id}    msg=UE is not attached to the appropriate cell.
    ${ip}  Get Ue Info  NR_UE  IP
    Should Not Be Empty  ${ip}  msg=UE has not assigned IP
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${MODULATION_CHANGED}  False

    ${mrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${ORIGINAL_SCF_PATH}  ${scf_path_gnb}
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/original_SCF.xml  console=True


Step 1: Perform NR DL And UL Data Transfer
    Log  \n==== Step 1: Perform NR DL Data Transfer ====  console=True

    Perform And Verify Data Transfer  dt_dl_name=NR_DL_1  dt_ul_name=NR_UL_1  avg_tput_dl=${TPUT_DL_256QAM_TRUE}  avg_tput_ul=${TPUT_UL_256QAM_TRUE}

    Log  Check BLER and avg MCS  console=True
    ${number_of_traffic_period_to_check}  Evaluate  math.ceil(${DURATION} / ${PM_COUNER_INTERVAL})  math
    Set Test Variable   ${number_of_traffic_period_to_check}
    Log   Traffic will be checked in ${number_of_traffic_period_to_check} PM counter interval(s), each ${PM_COUNER_INTERVAL}s  console=True
    Check BLER And Average MCS   cells_ids=${NR_CELL_N7}  tput_direction=both
    ...  interval_pm_number=${number_of_traffic_period_to_check}  show_on_console=True


Perform And Verify Data Transfer
    [Arguments]  ${dt_dl_name}  ${dt_ul_name}    ${avg_tput_dl}    ${avg_tput_ul}

    Get Ue Info  NR_UE  ALL
    Log  Start DL data transfer  console=True
    Start Data Transfer  ${dt_dl_name}  NR_UE  DL  duration=${DURATION}s  throughput=900Mbits/sec  protocol=tcp  max_segment_size=1400  apn=${APN}
    Log  Start UL data transfer  console=True
    Start Data Transfer  ${dt_ul_name}  NR_UE  UL  duration=${DURATION}s  throughput=600Mbits/sec  protocol=tcp  max_segment_size=1400  apn=${APN}
    Await Data Transfer Finish  ${dt_dl_name}
    Await Data Transfer Finish  ${dt_ul_name}
    Log  Verifying Average DL Throughput  console=True
    Verify Average Throughput With Deviation  ${dt_dl_name}  tput=${avg_tput_dl}  deviation=20%
    Log  Verifying Average UL Throughput  console=True
    Verify Average Throughput With Deviation  ${dt_ul_name}  tput=${avg_tput_ul}  deviation=20%


Step 2: Disable UL And DL 256QAM
    Log  \n==== Step 2: Disable UL And DL 256QAM ====  console=True

    Log  Creating delta.  console=True
    Create Delta  alias=delta
    Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${NR_CELL_N7}  actDlLaDynBlerTarget  false  alias=delta
    Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${NR_CELL_N7}  actDl256Qam  false  alias=delta
    Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${NR_CELL_N7}  actUl256Qam  false  alias=delta
    ${delta}  Get Delta  alias=delta
    Log  Delta contents:\n${delta}\n  console=True
    Set Test Variable  ${MODULATION_CHANGED}  True
    Perform Delta Recommissioning  delta_file=${delta}  connection=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB


Step 3: Check Data Transfer Without 256QAM
    Log  \n==== Step 3: Check Data Transfer Without 256QAM ====  console=True

    Perform And Verify Data Transfer  dt_dl_name=NR_DL_2  dt_ul_name=NR_UL_2  avg_tput_dl=${TPUT_DL_256QAM_FALSE}  avg_tput_ul=${TPUT_UL_256QAM_FALSE}


Step 4: Perform OAM Operations
    Log  \n==== Step 4: Perform OAM Operations ====  console=True

    Log  \n== Block/Unblock NR 50MHz cell ==  console=True
    Block Unblock 50MHz Cell
    Stop Wireshark Log Collection

    Log  \n== Restart 50MHz RU- AHEGHA ==  console=True
    ${rmod_distname}  Get Runtime Dist Name For RMOD  rmod_serial_number=${RMOD_SERIAL_NUMBER}  connection=gNB
    Log  RMOD dist-name: ${rmod_distname}  console=True
    Reset Unit  ${rmod_distname}  timeout=300  connection=gNB
    Wait Until Keyword Succeeds  6m  30s  _verify bts states for iwk test helper  alias=gNB


Block Unblock 50MHz Cell

    ${nr_cell_runtime_distname}  Get Runtime Dist Name For NR Cell  ${NR_CELL_N7}  connection=gNB
    Block Cell  ${nr_cell_runtime_distname}  timeout=90  connection=gNB
    Assert Alarm Active    faultId=49    timeout=60    connection=gNB
    Log  Fault 49 Cell blocked is visibele  console=True
    Unblock Cell  ${nr_cell_runtime_distname}  timeout=90  connection=gNB
    Wait Until Keyword Succeeds  2m  20s  _verify bts states for iwk test helper  alias=gNB


Revert Changes
    Log  Performing delta recommissioning...  console=True
    ${modified_scf_path}  ${_} =  Save And Parse SCF  SCF_reverted  alias=gNB
    Calculate Delta SCF  ${ORIGINAL_SCF_PATH}  ${modified_scf_path}  ${LOG_PATH}/misc_logs/delta_revert.json
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json    connection=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach Ue  NR_UE
    Run Keyword If  ${MODULATION_CHANGED}  Revert Changes
    IWK Test Teardown  stop_wireshark=False  delta_exists=False  local_enb_connection=False  single_bts=True
