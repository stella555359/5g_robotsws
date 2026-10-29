*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource   ../../resources/ca_IWK.robot


*** Variables ***
${NR_DSS_CELL}                                 # ID of NR DSS cell
${LTE_DSS_CELL}                                # ID of main tested LTE DSS cell belonging to power group
${LTE_NON_DSS_CELL}                            # ID of LTE non DSS cell belonging to power group
${NR_POWER_GROUP_ID}                           # ID of NR power group used in TC
${LTE_UE_CAPABILITY}                           # LTE UE capability


*** Keywords ***
TC__CB011037_LTE_DSS_cell_TX_paths_switching_off_on_when_LTE1103_and_LTE1203_are_activated
    Set Tags    CA-INTER_RAT    AUTHOR-magdalena.swierbutowicz@nokia.com    OWNER-dawid.1.kurowski@nokia.com
    ...  MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R3    FEATURE-CB011037    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Start DL Data Transfer
    Step 2: Reduce Traffic Load To Switch Off Non DSS Cell
    Step 3: Continue To Reduce Traffic Load To Switch Off DSS Cell
    Step 4: Check If TX Paths Are Switched Off
    Step 5: Increase Traffic Load To Switch On DSS Cell


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    Feature Activation On ENB
    Feature Activation On GNB
    Verify BTS States For IWK Test
    Require UE  LTE_UE  ${LTE_UE_CAPABILITY}
    Set Attenuation  GNB_CELL_8_1  0dB
    Set Attenuation  GNB_CELL_8_2  0dB
    Log  = Preconditions passed =  console=True


Set Global Variables
    Set Test Variable  ${MODULATION_CHANGED_ENB}  False
    Set Test Variable  ${MODULATION_CHANGED_GNB}  False

    ${LNBTS_ID} =  Get BTS ID From ADMIN
    Set Test Variable  ${LNBTS_ID}
    Log  LTE BTS ID ${LNBTS_ID}  console=True

    ${NRBTS_ID} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}
    Log  NR BTS ID ${NRBTS_ID}  console=True

    ${scf_path_enb}  ${_} =  Save And Parse SCF  SCF_eNB
    Set Test Variable  ${ORIGINAL_ENB_SCF_PATH}  ${scf_path_enb}
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/original_enb_SCF.xml  console=True

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${ORIGINAL_GNB_SCF_PATH}  ${scf_path_gnb}
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/original_gnb_SCF.xml  console=True


Feature Activation On GNB
    Log  Feature Activation On GNB.  console=True

    ${act_feature_list_gnb} =  Create List
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsCellList:{"lbpsCellSOOrder": "100", "lbpsUseExtConfig": "false", "nrCellId": "${NR_DSS_CELL}"}
    ...  modify:NRPGRP-${NR_POWER_GROUP_ID}:lbpsLastCellSOEnabled=false
    ...  modify:NRPGRP-${NR_POWER_GROUP_ID}:lbpsSOMethod=cell switch off
    ...  modify:NRBTS-${NRBTS_ID}:actCoordEnDssPowerSaving=true
    ...  modify:NRBTS-${NRBTS_ID}:actNrLBPowerSaving=true

    Load SCF  ${ORIGINAL_GNB_SCF_PATH}
    Perform SCF Modification  ${act_feature_list_gnb}

    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_gnb.xml
    ${delta_path_gnb}  ${delta_revert_gnb} =  Calculate Delta Between SCFs
    ...  ${ORIGINAL_GNB_SCF_PATH}
    ...  ${LOG_PATH}/misc_logs/modified_SCF_gnb.xml
    ...  gnb_feature_activation
    Set Test Variable  ${DELTA_REVERT_GNB}  ${delta_revert_gnb}

    Log  Performing gnb delta recommissioning...  console=True
    Perform Delta Recommissioning  ${delta_path_gnb}  connection=gNB
    Set Test Variable  ${MODULATION_CHANGED_GNB}  True


Feature Activation On ENB
    Log  Feature Activation On ENB.  console=True

    ${act_feature_list_enb} =  Create List
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actLBPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actLBRTXPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actCoordEnDssPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actOnlineTXSwitch=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actLbpsCtrlLogicEnh=true

    Load SCF  ${ORIGINAL_ENB_SCF_PATH}
    Perform SCF Modification  ${act_feature_list_enb}

    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_enb.xml
    ${delta_path_enb}  ${delta_revert_enb} =  Calculate Delta Between SCFs
    ...  ${ORIGINAL_ENB_SCF_PATH}
    ...  ${LOG_PATH}/misc_logs/modified_SCF_enb.xml
    ...  enb_feature_activation
    Set Test Variable  ${DELTA_REVERT_ENB}  ${delta_revert_enb}

    Log  Performing enb delta recommissioning...  console=True
    Perform Delta Recommissioning  ${delta_path_enb}
    Set Test Variable  ${MODULATION_CHANGED_ENB}  True


Step 1: Start DL Data Transfer
    Log  \n==== Step 1: Start DL Data Transfer ====  console=True

    Prepare UE For Data Transfer  LTE_UE  ${LTE_DSS_CELL}  lte_cell=True
    Log  Start LTE DL data transfer in cell ${LTE_DSS_CELL} on UE.  console=True
    Start Data Transfer And Check Energy Saving Status
    ...  LTE_DL1  200  NotEnergySaving  NotEnergySaving

    ${avg_tput_all_tx} =  Get Average Throughput  LTE_DL1
    Log  Average tput for LTE DSS cell with all TX paths is ${avg_tput_all_tx} Kbits/sec  console=True
    Set Test Variable  ${AVG_TPUT_ALL_TX}  ${avg_tput_all_tx}


Step 2: Reduce Traffic Load To Switch Off Non DSS Cell
    Log  \n==== Step 2: Reduce Traffic Load To Switch Off Non DSS Cell ====  console=True

    Start Data Transfer And Check Energy Saving Status
    ...  LTE_DL2  10  NotEnergySaving  EnergySaving


Step 3: Continue To Reduce Traffic Load To Switch Off DSS Cell
    Log  \n==== Step 3: Continue To Reduce Traffic Load To Switch Off DSS Cell ====  console=True

    Start Data Transfer And Check Energy Saving Status
    ...  LTE_DL3  1  ReducedEnergySaving  EnergySaving


Step 4: Check If TX Paths Are Switched Off
    Log  \n==== Step 4: Check If TX Paths Are Switched Off ====    console=True

    Start Data Transfer  LTE_DL4  LTE_UE  dl  throughput=200 Mbits/sec  protocol=udp
    ...  packet_size=1400  duration=200s  buffer=32M
    Sleep  50s  reason=Waiting to check average data transfer.
    Check Data Transfer Is Alive  LTE_DL4
    ${avg_tput_half_tx} =  Get Average Throughput  LTE_DL4  omit=20  end=50
    Log  Average tput for LTE DSS cell with half TX paths is ${avg_tput_half_tx} Kbits/sec  console=True
    ${tput_min}  Evaluate  round(${0.4}*${AVG_TPUT_ALL_TX}, 1)
    ${tput_max}  Evaluate  round(${0.7}*${AVG_TPUT_ALL_TX}, 1)
    Run Keyword And Continue On Failure  Verify Average Throughput  LTE_DL4
    ...  tput_min=${tput_min} Kbits/sec  tput_max=${tput_max} Kbits/sec  omit=20  end=50
    Stop Data Transfer  LTE_DL4
    Log  In ReducedEnergySaving state tput is up to half of original tput, so 2 TXs are switched off  console=True


Step 5: Increase Traffic Load To Switch On DSS Cell
    Log  \n==== Step 5: Increase Traffic Load To Switch On DSS Cell ====  console=True

    Start Data Transfer And Check Energy Saving Status
    ...  LTE_DL5  80  NotEnergySaving  NotEnergySaving


Start Data Transfer And Check Energy Saving Status
    [Arguments]  ${dt_name}  ${tput_value}  ${lte_dss_exp_es_status}  ${lte_non_dss_exp_es_status}

    Start Data Transfer  ${dt_name}  LTE_UE  dl  throughput=${tput_value} Mbits/sec  protocol=udp  packet_size=1400
    ...  duration=400s  buffer=32M

    Log  Wait 180s to check if energy saving status changed.  console=True
    Sleep  180s  reason=Waiting to check if energy saving status changed.

    Log  \nChecking Energy Saving State For LTE DSS Cell...  console=True
    Check Energy Saving State For LTE Cell
    ...  ${LNBTS_ID}  ${LNBTS_ID}  ${LTE_DSS_CELL}  ${lte_dss_exp_es_status}  connection=default
    Log  \nChecking Energy Saving State For LTE non DSS Cell...  console=True
    Check Energy Saving State For LTE Cell
    ...  ${LNBTS_ID}  ${LNBTS_ID}  ${LTE_NON_DSS_CELL}  ${lte_non_dss_exp_es_status}  connection=default
    Log  \nChecking Energy Saving State For NR DSS Cell...  console=True
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_DSS_CELL}  notEnergySaving  connection=gNB

    Check Data Transfer Is Alive  ${dt_name}
    Stop Data Transfer  ${dt_name}


TC Setup
    IWK Test Setup  local_enb_connection=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach Ue  LTE_UE
    Run Keyword If  ${MODULATION_CHANGED_ENB}  Perform Delta Recommissioning  ${DELTA_REVERT_ENB}  connection=default
    Run Keyword If  ${MODULATION_CHANGED_GNB}  Perform Delta Recommissioning  ${DELTA_REVERT_GNB}  connection=gNB
    Verify BTS States For IWK Test
    IWK Test Teardown  stop_wireshark=True  delta_exists=False  local_enb_connection=False
