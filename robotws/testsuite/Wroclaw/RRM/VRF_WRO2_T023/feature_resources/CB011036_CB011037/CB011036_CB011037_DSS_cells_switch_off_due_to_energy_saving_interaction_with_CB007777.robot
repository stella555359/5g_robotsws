*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Library    ute_ue
Library    taf.config.scf
Library    taf.analyzer.pmcounter
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource   ../../resources/ca_IWK.robot


*** Variables ***
${NR_DSS_CELL}                                 # NR DSS global cell ID
${NR_NON_DSS_CELL}                             # NR non DSS global cell ID
${LTE_DSS_CELL}                                # ID of main tested LTE DSS cell belonging to power group
${LTE_NON_DSS_CELL}                            # ID of LTE non DSS cell belonging to power group
${NR_POWER_GROUP_ID}                           # ID of NR power group used in TC
${LTE_POWER_GROUP_ID}                          # ID of LTE power group used in TC
${NR_UE_CAPABILITY}                            # NR UE capability
${NR_CALL_CELL_ID}                             # NR non DSS cell ID for making call
${COUNTER_PERIOD}                              # Period of checked counters (value of parameters miNrCaDuCp and miNrPowerSavingBwp in minutes)
${RMOD_ID}                                     # RMOD ID on which NR DSS cell is set up
${SMOD_ID}                                     # SMOD ID on which NR DSS cell is set up


*** Keywords ***
TC__CB011036_CB011037_DSS_cells_switch_off_due_to_energy_saving_interaction_with_CB007777
    Set Tags    CA-INTER_RAT    AUTHOR-magdalena.swierbutowicz@nokia.com    OWNER-dawid.1.kurowski@nokia.com
    ...  MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R3    FEATURE-CB011036_CB011037
    ...  GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Collect Counters In Not Energy Saving State
    Step 2: Feature Activation
    Step 3: Collect Counters In Energy Saving State
    Step 4: Analyze Counters Related To CB007777
    Step 5: Start Traffic Load To Switch On DSS Cells


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Global Variables
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Set Attenuation  GNB_CELL_8_1  0dB
    Set Attenuation  GNB_CELL_8_2  0dB
    Change Power Saving Parameter  false
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
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/SCF_eNB.xml  console=True

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${ORIGINAL_GNB_SCF_PATH}  ${scf_path_gnb}
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/SCF_gNB.xml  console=True


Step 1: Collect Counters In Not Energy Saving State
    Log  \n==== Step 1: Collect Counters In Not Energy Saving State ====  console=True

    Check Energy Saving States  notEnergySaving  notEnergySaving  NotEnergySaving  NotEnergySaving

    ${sm_counters_dict_not_es}  ${rfm_counters_dict_not_es}  ${mt_counters_dict_not_es}  ${ps_counters_dict_not_es}=
    ...  Collect Counters Related To CB007777  ${LOG_PATH}/pm_counters_not_es
    Set Test Variable  ${SM_COUNTERS_DICT_NOT_ES}  ${sm_counters_dict_not_es}
    Set Test Variable  ${RFM_COUNTERS_DICT_NOT_ES}  ${rfm_counters_dict_not_es}
    Set Test Variable  ${MT_COUNTERS_DICT_NOT_ES}  ${mt_counters_dict_not_es}
    Set Test Variable  ${PS_COUNTERS_DICT_NOT_ES}  ${ps_counters_dict_not_es}

    Should Be Equal  ${ps_counters_dict_not_es['M55601C00501'][0]}  0
    ...  msg=The value of counter M55601C00501 is other than 0
    Should Be Equal  ${ps_counters_dict_not_es['M55601C00502'][0]}  0
    ...  msg=The value of counter M55601C00502 is other than 0


Step 2: Feature Activation
    Log  \n==== Step 2: Feature Activation ====  console=True

    Feature Activation On GNB
    Feature Activation On ENB
    Verify BTS States For IWK Test
    Check Energy Saving States  energySaving  notEnergySaving  EnergySaving  ReducedEnergySaving


Step 3: Collect Counters In Energy Saving State
    Log  \n==== Step 3: Collect Counters In Energy Saving State ====  console=True

    ${sm_counters_dict_es}  ${rfm_counters_dict_es}  ${mt_counters_dict_es}  ${ps_counters_dict_es}=
    ...  Collect Counters Related To CB007777  ${LOG_PATH}/pm_counters_es
    Set Test Variable  ${SM_COUNTERS_DICT_ES}  ${sm_counters_dict_es}
    Set Test Variable  ${RFM_COUNTERS_DICT_ES}  ${rfm_counters_dict_es}
    Set Test Variable  ${MT_COUNTERS_DICT_ES}  ${mt_counters_dict_es}
    Set Test Variable  ${PS_COUNTERS_DICT_ES}  ${ps_counters_dict_es}

    Should Be True  ${ps_counters_dict_es['M55601C00501'][0]} > 0
    ...  msg=The value of counter M55601C00501 is equal 0
    Should Be Equal  ${ps_counters_dict_es['M55601C00502'][0]}  1
    ...  msg=The value of counter M55601C00502 is other than 1


Step 4: Analyze Counters Related To CB007777
    Log  \n==== Step 4: Analyze Counters Related To CB007777 ====  console=True

    FOR  ${key}  IN  @{SM_COUNTERS_DICT_NOT_ES.keys()}
        Run Keyword And Continue On Failure
        ...  Should Be True  ${SM_COUNTERS_DICT_NOT_ES["${key}"][0]} > ${SM_COUNTERS_DICT_ES["${key}"][0]}*0.95
        ...  msg=The value of counter ${key} is too high with energy saving
    END

    FOR  ${key}  IN  @{RFM_COUNTERS_DICT_NOT_ES.keys()}
        Run Keyword And Continue On Failure
        ...  Should Be True  ${RFM_COUNTERS_DICT_NOT_ES["${key}"][0]} > ${RFM_COUNTERS_DICT_ES["${key}"][0]}*0.95
        ...  msg=The value of counter ${key} is too high with energy saving
    END

    FOR  ${key}  IN  @{MT_COUNTERS_DICT_NOT_ES.keys()}
        Run Keyword And Continue On Failure
        ...  Should Be True  ${MT_COUNTERS_DICT_NOT_ES["${key}"][0]} >= ${MT_COUNTERS_DICT_ES["${key}"][0]}*0.95
        ...  msg=The value of counter ${key} is too high with energy saving
    END


Step 5: Start Traffic Load To Switch On DSS Cells
    Log  \n==== Step 5: Start Traffic Load To Switch On DSS Cells ====  console=True

    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}
    Log  Start NR DL data transfer in cell ${NR_NON_DSS_CELL} on UE.  console=True
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=500 Mbits/sec  protocol=udp  packet_size=1400
    ...  duration=400s  buffer=32M
    Check Energy Saving States  notEnergySaving  notEnergySaving  NotEnergySaving  ReducedEnergySaving

    Check Data Transfer Is Alive  NR_DT
    Stop Data Transfer  NR_DT


Change Power Saving Parameter
    [Arguments]  ${parameter_value}

    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}  actNrLBRTXPowerSaving  update
    ...  ${parameter_value}  connection=gNB
    Verify BTS States For IWK Test


Feature Activation On GNB
    Log  Feature Activation On GNB.  console=True

    Change Power Saving Parameter  true

    ${act_feature_list_gnb} =  Create List
    ...  modify:NRPGRP-${NR_POWER_GROUP_ID}:lbpsCellList:lbpsCellSOOrder=100|nrCellId=${NR_NON_DSS_CELL}
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsCellList:{"lbpsCellSOOrder": "1", "lbpsUseExtConfig": "false", "nrCellId": "${NR_DSS_CELL}"}
    ...  modify:NRBTS-${NRBTS_ID}:actCoordinated4g5gPowerSaving=cellDeactivation
    ...  modify:NRPGRP-${NR_POWER_GROUP_ID}:lbpsLastCellSOEnabled=false
    ...  modify:NRPGRP-${NR_POWER_GROUP_ID}:lbpsSOMethod=cell switch off
    ...  modify:NRBTS-${NRBTS_ID}:actCoordEnDssPowerSaving=true
    ...  modify:NRBTS-${NRBTS_ID}:actNrLBPowerSaving=true
    ...  modify:NRBTS-${NRBTS_ID}:actLbpsCtrlLogicEnh=true
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsMonWinForCellSOff=60
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsMonWinForCellSOn=60
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsLoadCalcMethod=Max(G_N_combined, P)
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsSOffTrRule=MaxValueMethod
    ...  add:NRPGRP-${NR_POWER_GROUP_ID}:lbpsSOnTrRule=MinValueMethod

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
    ...  modify:PSGRP-${LTE_POWER_GROUP_ID}:lbpsCellList:lbpsCellSOOrder=1|lnCelId=${LTE_DSS_CELL}
    ...  modify:PSGRP-${LTE_POWER_GROUP_ID}:lbpsCellList:lbpsCellSOOrder=100|lnCelId=${LTE_NON_DSS_CELL}
    ...  modify:PSGRP-${LTE_POWER_GROUP_ID}:lbpsSOMethod=Cell Switch Off
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actLBPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actLBRTXPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actCoordEnDssPowerSaving=true
    ...  modify:MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}:actCoordinated4g5gPowerSaving=cellDeactivation
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


Collect Counters Related To CB007777
    [Arguments]  ${path_to_counters}

    ${sleep_time} =  Count Measurement Period    ip=${GNB_OAM_IP}    counter_period=${COUNTER_PERIOD}    delta=60
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for counters collection until ${end_of_sleep_date}  console=True
    Sleep  ${${sleep_time}+${30}}s  reason=Wait till counters are collected.

    Wait Until Keyword Succeeds  5x  10s  Collect PM Counters  ${path_to_counters}  host=${GNB_OAM_IP}
    ...  time_interval=${COUNTER_PERIOD} min  intervals=${COUNTER_PERIOD}
    ${sm_counter_list}  Create List  M40004C0  M40004C1  M40004C2  M40004C3  M40004C4  M40004C5
    ${sm_counters_dict}  Get Values Of Counters From List  ${path_to_counters}  ${sm_counter_list}
    ...  MRBTS-${NRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-${SMOD_ID}  1

    ${rfm_counter_list}  Create List  M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
    ${rfm_counters_dict}  Get Values Of Counters From List  ${path_to_counters}  ${rfm_counter_list}
    ...  MRBTS-${NRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}  1

    ${mt_counter_list}  Create List  M40002C0  M40002C1  M40002C2
    ${mt_counters_dict}  Get Values Of Counters From List  ${path_to_counters}  ${mt_counter_list}
    ...  MRBTS-${NRBTS_ID}  1

    ${ps_counter_list}  Create List  M55601C00502  M55601C00501
    ${ps_counters_dict}  Get Values Of Counters From List  ${path_to_counters}  ${ps_counter_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_DSS_CELL}  1

    [Return]  ${sm_counters_dict}  ${rfm_counters_dict}  ${mt_counters_dict}  ${ps_counters_dict}


Check Energy Saving States
    [Arguments]  ${nr_dss_exp_es_status}  ${nr_non_dss_exp_es_status}
    ...  ${lte_dss_exp_es_status}  ${lte_non_dss_exp_es_status}

    Log  Wait 240s to check if energy saving status changed.  console=True
    Sleep  240s  reason=Waiting to check if energy saving status changed.

    Log  \nChecking Energy Saving State For NR DSS Cell...  console=True
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_DSS_CELL}  ${nr_dss_exp_es_status}  connection=gNB
    Log  \nChecking Energy Saving State For NR non DSS Cell...  console=True
    Check Energy Saving State For NR Cell  ${NRBTS_ID}  ${NR_NON_DSS_CELL}  ${nr_non_dss_exp_es_status}  connection=gNB
    Log  \nChecking Energy Saving State For LTE DSS Cell...  console=True
    Check Energy Saving State For LTE Cell
    ...  ${LNBTS_ID}  ${LNBTS_ID}  ${LTE_DSS_CELL}  ${lte_dss_exp_es_status}  connection=default
    Log  \nChecking Energy Saving State For LTE non DSS Cell...  console=True
    Check Energy Saving State For LTE Cell
    ...  ${LNBTS_ID}  ${LNBTS_ID}  ${LTE_NON_DSS_CELL}  ${lte_non_dss_exp_es_status}  connection=default


TC Setup
    IWK Test Setup  local_enb_connection=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach Ue  NR_UE
    Run Keyword If  ${MODULATION_CHANGED_ENB}  Perform Delta Recommissioning  ${DELTA_REVERT_ENB}  connection=default
    Run Keyword If  ${MODULATION_CHANGED_GNB}  Perform Delta Recommissioning  ${DELTA_REVERT_GNB}  connection=gNB
    Verify BTS States For IWK Test
    IWK Test Teardown  stop_wireshark=True  delta_exists=False  local_enb_connection=False
