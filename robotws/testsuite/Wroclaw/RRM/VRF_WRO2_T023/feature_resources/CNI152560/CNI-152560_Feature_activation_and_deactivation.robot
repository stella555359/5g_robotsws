*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library       ute_ue
Library       taf.config.scf
Library       taf.sbts.oam.coam.admin  WITH NAME  admin
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${NR_UE_CAPABILITY}                # NR UE capability
${CELL_ID_FOR_CALL}                # ID of cell to which UE should attach during the test
${DELTA_PATH}                      # Path to delta file
${TPUT_DL}                         # Avg downlink throughput when CNI-152560 is activated or deactivated
${TPUT_UL}                         # Avg uplink throughput when CNI-152560 is activated or deactivated


*** Keywords ***
TC__CNI-152560_Feature_activation_and_deactivation
    Set Tags    CA-INTER_RAT    AUTHOR-igor.kleschenok@nokia.com    OWNER-adam.szczerba@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com    PHASE-CRT   SW-SBTS26R2    FEATURE-CNI-152560   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Perform And Verify NR DL And UL Data Transfer
    Step 2: CNI-152560 Feature Activation
    Step 3: Perform And Verify NR DL And UL Data Transfer

Preconditions
    Log  \n=== Preconditions ===  console=True

    Set Global Variables
    Require UE  NR_UE  ${NR_UE_CAPABILITY}


Set Global Variables

    Set Test Variable  ${PARAMETERS_CHANGED}  False

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}


Step ${index}: Perform And Verify NR DL And UL Data Transfer
    Log  \n=== Step ${index}: Perform And Verify NR DL And UL Data Transfer ===  console=True

    Perform And Verify Data Transfer  ${TPUT_DL}  ${TPUT_UL}


Step 2: CNI-152560 Feature Activation
    Log  \n=== Step 2: CNI-152560 Feature Activation ===  console=True

    Set Test Variable  ${PARAMETERS_CHANGED}  True
    Perform Delta Recommissioning  ${DELTA_PATH}  alias=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB
    Log  CNI-152560 Feature Is Activated  console=True


Perform And Verify Data Transfer
    [Arguments]  ${avg_tput_dl}  ${avg_tput_ul}

    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=gNB
    Log  Start NR DL data transfer on UE.  console=True
    Start Data Transfer  DT_DL  NR_UE  dl  protocol=tcp  duration=60s  buffer=32M  apn=n26wro
    Log  Start NR UL data transfer on UE.  console=True
    Start Data Transfer  DT_UL  NR_UE  ul  protocol=tcp  duration=60s  buffer=32M  apn=n26wro
    Log  NR data transfer has started. Wait for it to stabilize...  console=True
    Await Data Transfer Finish  DT_DL
    Await Data Transfer Finish  DT_UL
    Log  Verifying Average DL Throughput  console=True
    Verify Average Throughput With Deviation  DT_DL  tput=${avg_tput_dl}  deviation=20%
    Log  Verifying Average UL Throughput  console=True
    Verify Average Throughput With Deviation  DT_UL  tput=${avg_tput_ul}  deviation=20%


Revert to Original SCF
    Log  Reverting to original SCF. Path:${SCF_PATH_GNB}  console=True

    ${modified_scf_path}  ${_} =  Save And Parse SCF  modified_SCF  alias=gNB
    Calculate Delta SCF  ${SCF_PATH_GNB}  ${modified_scf_path}  ${LOG_PATH}/misc_logs/delta_revert.json
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json    connection=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB


TC Setup
    Log  \n=== TC Setup ===  console=True

    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach Ue  NR_UE  timeout=40
    IF  ${PARAMETERS_CHANGED}  Revert to Original SCF
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
