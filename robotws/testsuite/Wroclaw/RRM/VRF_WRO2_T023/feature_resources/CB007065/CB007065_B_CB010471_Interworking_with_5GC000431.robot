*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     taf.config.scf
Library     ta5g_ue_mobility
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Variables ***
${NR_CELL_ID1}                                  # ID of tested NR cell in power group with lbpsSOMethod = 'TX switch off'
${NR_CELL_ID2}                                  # ID of tested NR cell in power group with lbpsSOMethod = 'cell switch off'
${TX_POWER_GROUP_ID}                            # ID of power group with lbpsSOMethod = 'TX switch off'
${CELL_POWER_GROUP_ID}                          # ID of power group with lbpsSOMethod = 'cell switch off'
${UE_ID1}                                       # ID of UE from EGATE configuration file connected to NSA cell in power group
# with lbpsSOMethod = 'TX switch off'
${UE_ID2}                                       # ID of UE from EGATE configuration file connected to NSA cell in power group
# with lbpsSOMethod = 'cell switch off'
${SWITCH_ON_TIMEOUT}                            # Timeout for switch on operation in seconds
${SWITCH_OFF_TIMEOUT}                           # Timeout for switch off operation in seconds
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs

*** Keywords ***
TC__CB007065_B_CB010471_Interworking_with_5GC000431

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT   SW-SBTS24R3    GROUP_IN_CHARGE-Pz_2_WRO_2    NoResUsage


    Preconditions
    Step 1: Attach UE To Cell With TX Switch Off
    Step 2: Attach UE To Cell With Cell Switch Off
    Step 3: Activate TX And Cell Switch Off
    Step 4: Check Energy Saving State
    Step 5: Check Tcpdump


Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables

    Save SCF VDU  vDU_SCF_original.xml
    Save SCF VCU  vCU_SCF_original.xml

    Log  \nWaiting for cells to go into reducedEnergySaving and energySaving state...  console=True
    Wait Until Keyword Succeeds  ${SWITCH_OFF_TIMEOUT}  10s
    ...  Check If Cells Are In Energy Saving State

    Prepare Deltas For Toggling
    Deactivate TX And Cell Energy Saving On VDU
    Verify Preconditions For CB007065 On VDU


Create Global Variables
    Set Test Variable  ${PARAMETERS_MODIFIED}  False
    Set Test Variable  ${WIRESHARK_STARTED}  False

    Get MRBTS ID From VDU
    Get NRBTS ID From VDU


Prepare Deltas For Toggling
    Load SCF  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    Modify SCF Element  value=false  dist_name=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${CELL_POWER_GROUP_ID}
    ...  p_name=lbpsLastCellSOEnabled
    Modify SCF Element  value=false  dist_name=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${TX_POWER_GROUP_ID}
    ...  p_name=lbpsLastCellSOEnabled
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_vdu.xml
    Calculate Delta Between SCFs  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml  ${LOG_PATH}/misc_logs/modified_SCF_vdu.xml
    ...  energy_saving_deactivated


Deactivate TX And Cell Energy Saving On VDU
    Set Test Variable  ${PARAMETERS_MODIFIED}  True
    Toggle Energy Saving Parameters On VDU  false
    Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}

    Log  \nWaiting for energy saving state change...  console=True
    Wait Until Keyword Succeeds  ${SWITCH_ON_TIMEOUT}  10s
    ...  Check If Cells Are Out Of Energy Saving State

    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID1}  notEnergySaving
    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID2}  notEnergySaving
    Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}


Verify Preconditions For CB007065 On VDU
    Connect To VDU
    ${act_nr_lb_mmimo_rtx_power_saving} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  para_name=actNrLBmMimoRTXPowerSaving
    ${act_lb_ps_ctrl_logic_enh} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  para_name=actLbpsCtrlLogicEnh
    ${act_nr_lb_power_saving} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...  para_name=actNrLBPowerSaving
    ${msg} =  Catenate  SEPARATOR=
    ...  Value for one of parameters on vDU is different than expected (true). Parameters:\n
    ...  actNrLBmMimoRTXPowerSaving=${act_nr_lb_mmimo_rtx_power_saving}
    ...  actLbpsCtrlLogicEnh=${act_lb_ps_ctrl_logic_enh}
    ...  actNrLBPowerSaving=${act_nr_lb_power_saving}.
    Should Be True
    ...  '${act_nr_lb_mmimo_rtx_power_saving}' == 'true' and '${act_lb_ps_ctrl_logic_enh}' == 'true' and '${act_nr_lb_power_saving}' == 'true'
    ...  msg=${msg}
    Log  CB007065 check on vDU successful.  console=True

    [Teardown]  vdu.Disconnect


Toggle Energy Saving Parameters On VDU
    [Arguments]  ${value}

    Log  \nChanging lbpsLastCellSOEnabled to ${value}...  console=True
    ${file_name} =  Set Variable If  '${value}' == 'true'  energy_saving_deactivated_revert.json  energy_saving_deactivated.json
    Connect To VDU
    vdu.Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/${file_name}

    [Teardown]  vdu.Disconnect


Step 1: Attach UE To Cell With TX Switch Off
    Log  \n==== Step 1: Attach UE To Cell With TX Switch Off ====  console=True

    Set Test Variable  ${WIRESHARK_STARTED}  True
    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}
    Attach UE To Enb  ue_id=${UE_ID1}
    Start Gnb Addition Procedure  ue=${UE_ID1}  bearer=2  target_gnb=2  target_cells=${NR_CELL_ID1}
    ...  dc_type=split_scg  timeout=30
    ta5g_ue_mobility.Get UE Disp Table  pass_regexp=.*${UE_ID1}\\s*?INT\\s*?ACTIVE\\s*?\\d+?\\.\\d=?\\.\\d+?\\.\\d+.*


Step 2: Attach UE To Cell With Cell Switch Off
    Log  \n==== Step 2: Attach UE To Cell With Cell Switch Off ====  console=True

    Attach UE To Enb  ue_id=${UE_ID2}
    Start Gnb Addition Procedure  ue=${UE_ID2}  bearer=2  target_gnb=2  target_cells=${NR_CELL_ID2}
    ...  dc_type=split_scg  timeout=30
    ta5g_ue_mobility.Get UE Disp Table  pass_regexp=.*${UE_ID2}\\s*?INT\\s*?ACTIVE\\s*?\\d+?\\.\\d=?\\.\\d+?\\.\\d+.*


Step 3: Activate TX And Cell Switch Off
    Log  \n==== Step 3: Activate TX And Cell Switch Off ====  console=True

    Check UEs  .*DC state\\s+ACTIVE.*
    Toggle Energy Saving Parameters On VDU  true
    Set Test Variable  ${PARAMETERS_MODIFIED}  False
    Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}


Step 4: Check Energy Saving State
    Log  \n==== Step 4: Check Energy Saving State ====  console=True

    Check UEs  .*
    Log  \nWaiting for energy saving state change...  console=True
    Wait Until Keyword Succeeds  ${SWITCH_OFF_TIMEOUT}  10s
    ...  Check If Cells Are In Energy Saving State

    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving
    Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID2}  energySaving
    Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}
    Check UEs  .*DC state\\s+INACTIVE.*


Step 5: Check Tcpdump
    Log  \n==== Step 5: Check Tcpdump ====  console=True

    ${tcpdump_path} =  Stop Wireshark Log Collection
    Set Test Variable  ${WIRESHARK_STARTED}  False
    Run Keyword And Continue On Failure  Check If Message Appeared  x2ap.procedureCode == 27  4  ${tcpdump_path}
    Run Keyword And Continue On Failure  Check If Message Appeared  x2ap.procedureCode == 28  2  ${tcpdump_path}
    Run Keyword And Continue On Failure  Check If Message Appeared  x2ap.radioNetwork == 11  1  ${tcpdump_path}


Detach For Simulated UE
    [Arguments]  ${ue_id}
    Detach UE  ue_id=${ue_id}
    ta5g_ue_mobility.Get UE Disp Table  pass_regexp=.*${ue_id}\\s*?INT\\s*?OFF.*


Check If Cells Are Out Of Energy Saving State
    ${tx_energy_saving_status} =  Run Keyword And Return Status
    ...  Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID1}  notEnergySaving
    ...  log_messages=False
    ${cell_energy_saving_status} =  Run Keyword And Return Status
    ...  Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID2}  notEnergySaving
    ...  log_messages=False
    Should Be True  ${tx_energy_saving_status} and ${cell_energy_saving_status}
    ...  msg=At least one of the cells is not out of energy saving state.


Check If Cells Are In Energy Saving State
    ${tx_energy_saving_status} =  Run Keyword And Return Status
    ...  Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID1}  reducedEnergySaving
    ...  log_messages=False
    ${cell_energy_saving_status} =  Run Keyword And Return Status
    ...  Check Energy Saving State For NR Cell On VDU  ${VDU_MRBTS_ID}  ${NRBTS_ID}  ${NR_CELL_ID2}  energySaving
    ...  log_messages=False
    Should Be True  ${tx_energy_saving_status} and ${cell_energy_saving_status}
    ...  msg=At least one of the cells is not in energy saving state.


Check UEs
    [Arguments]  ${pass_regexp_ue2}
    Execute EGATE Command  cmd=ue_disp id=${UE_ID1}  pass_regexp=.*DC state\\s+ACTIVE.*
    Execute EGATE Command  cmd=ue_disp id=${UE_ID2}  pass_regexp=${pass_regexp_ue2}
    ta5g_ue_mobility.Get UE Disp Table  pass_regexp=.*


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True

    Check UEs  .*
    Detach For Simulated UE  ue_id=${UE_ID1}
    Detach For Simulated UE  ue_id=${UE_ID2}
    Run Keyword If  ${PARAMETERS_MODIFIED}  Run Keywords  Toggle Energy Saving Parameters On VDU  true
    ...  AND  Verify BTS States For Cloud BTS  ${IGNORED_ALARMS_VCU}  ${IGNORED_ALARMS_VDU}
    Run Keyword If  ${WIRESHARK_STARTED}  Stop Wireshark Logs
    Cloud BTS Test Teardown
