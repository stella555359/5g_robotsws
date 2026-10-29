*** Settings ***
Documentation
...  contact: Szymon Startek

Library            ute_ue
Library            taf.analyzer.pmcounter
Library            taf.collectors.pmcounters
Library            taf.sbts.oam.coam.admin  WITH NAME  admin
Library            taf.hw.mcs  WITH NAME   MCS
Library            taf.transport.ssh
Library            ../../resources/parse_csv.py
Resource           ../../resources/ca_INTER_RAT.robot
Resource           RMOD_communication.robot



*** Variables ***
${NR_CELL_ID}                        # Global cell ID of the tested NR cell
${CAPABILITY_NR_UE}                  # Capability of UE used for NR data transfers
${NR_CALL_CELL_ID}                   # NR cell ID visible at UE
${RMOD_ID}                           # RMOD ID where NR cell is teseted
${BBMODULE_ADRESS}                   # Adress of BB module witch connected tested RMOD, 0x1018 for left and 0x2018 for right
${RMOD_IP}                           # IP of tested RMOD
${RU_INDEX}                          # Index of tested RMOD in __init__.py
${ON_TRESHOLD}                       # Sym_blank_on treshold defined in tcs.json at RMOD, should be provided as integer eg. 72
${OFF_TRESHOLD}                      # Sym_blank_off treshold defined in tcs.json at RMOD, should be provided as integer eg. 75
${BLANK_TIMER}                       # T_sym_blank_timer timer defined in tcs.json at RMOD, should be provided as integer eg. 60
${REVERT_CHANGES}                    # Determines whether the initial configuration will to be restored
${COUNTER_PERIOD}                    # Counter collecting interval in minutes


*** Keywords ***
TC__CB005788_SR_A_Counters
    Set Tags  CA-INTER_RAT  AUTHOR-szymon.startek@nokia.com  OWNER-anna.konior@nokia.com
    ...  MAINTAINER-szymon.startek@nokia.com  PHASE-CRT  SW-SBTS25R1  FEATURE-CNI-119369
    ...  GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Check If RMOD Is Ready For Test And To Start DL Call
    Step 2: Wait Until tgtMutingRatio Reach 35%
    Step 3: Collect And Check Counters


Preconditions
    Log  === Start Preconditions ===  console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  False
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${USERNAME}  Evaluate  $tl.gnbs[0].cu.oam_ssh_connection_details.username
    Set Test Variable  ${USERNAME}  ${USERNAME}
    ${PASSWORD}  Evaluate  $tl.gnbs[0].cu.oam_ssh_connection_details.password
    Set Test Variable  ${PASSWORD}  ${PASSWORD}

    ${RMOD_USERNAME}  Evaluate  $tl.gnbs[0].dus[0].rus[${RU_INDEX}].default_ssh_connection_details.username
    Set Test Variable  ${RMOD_USERNAME}  ${RMOD_USERNAME}
    ${RMOD_PASSWORD}  Evaluate  $tl.gnbs[0].dus[0].rus[${RU_INDEX}].default_ssh_connection_details.password
    Set Test Variable  ${RMOD_PASSWORD}  ${RMOD_PASSWORD}

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Parameters Activation

    Setup Temperature Thresholds at RMOD
    Sleep  120  reason=Wait until BTS catch RMOD reboot operation
    Wait Until Keyword Succeeds  6m  30s  _Verify Bts States For Iwk Test Helper  alias=gNB

    Print Thresholds After RU Reboot And Validating Threshold Values
    Require UE  UE_FOR_TA  capabilities=${CAPABILITY_NR_UE}
    Log  === Preconditions Finished ===  console=True


Step 1: Check If RMOD Is Ready For Test And To Start DL Call
    Log  === Step 1: Check If RMOD Is Ready For Test And To Start DL Call ===  console=True
    Check Temperature At Rmod

    ${sleep_time} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}  delta=120
    Log  Wait ${sleep_time} till new period of counter is started..  console=True
    Sleep  ${sleep_time}s  reason=Wait till new period of counter is started.

    Start Dl Call


Step 2: Wait Until tgtMutingRatio Reach 35%
    Log  === Step 2: Wait Until tgtMutingRatio Reach 35% ===  console=True

    Wait Until Keyword Succeeds  5x  ${BLANK_TIMER}  Check If Parameter Has Expected Value  35

    [Teardown]  Stop DL Call


Step 3: Collect And Check Counters
    Log  === Step 3: Collect And Check Counters ===  console=True
    Wait Until Keyword Succeeds  2x  0s  Collect And Check Counters


Collect And Check Counters
    ${sleep_time} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}  delta=120
    Log  Wait ${sleep_time}s for counters from last period to be available on SBTS...  console=True
    Sleep  ${sleep_time}s  reason=Waiting for counters from last period to be available on SBTS.

    Collect RD Counters From BTS  2  ${COUNTER_PERIOD}

    ${M55601C00016} =  Get Counters Values  ${LOG_PATH}/RD_counters  NR_CELL_RF_COOL_MODE0_SAMPLES
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ${M55601C00017} =  Get Counters Values  ${LOG_PATH}/RD_counters  NR_CELL_RF_COOL_MODE0_CHNG_TO
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ${M55601C00018} =  Get Counters Values  ${LOG_PATH}/RD_counters  NR_CELL_RF_COOL_MODE2_SAMPLES
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ${M55601C00019} =  Get Counters Values  ${LOG_PATH}/RD_counters  NR_CELL_RF_COOL_MODE2_CHNG_TO
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}

    ${int_M55601C00016} =  Evaluate  [int(i) for i in ${M55601C00016}]
    ${int_M55601C00017} =  Evaluate  [int(i) for i in ${M55601C00017}]
    ${int_M55601C00018} =  Evaluate  [int(i) for i in ${M55601C00018}]
    ${int_M55601C00019} =  Evaluate  [int(i) for i in ${M55601C00019}]

    Log  NR_CELL_RF_COOL_MODE0_SAMPLES: ${int_M55601C00016}  console=True
    Log  NR_CELL_RF_COOL_MODE0_CHNG_TO: ${int_M55601C00017}  console=True
    Log  NR_CELL_RF_COOL_MODE2_SAMPLES: ${int_M55601C00018}  console=True
    Log  NR_CELL_RF_COOL_MODE2_CHNG_TO: ${int_M55601C00019}  console=True

    ${c16_sum} =  Evaluate  sum(${int_M55601C00016})
    Should Be True  0<${c16_sum}<1800  msg=Sum of the values of counter M55601C00016 isn't in range (0;1800)
    ${c17_sum} =  Evaluate  sum(${int_M55601C00017})
    Should Be True  ${c17_sum}>0  msg=None of the values of counter M55601C00017 isn't greater than 0
    ${c18_sum} =  Evaluate  sum(${int_M55601C00018})
    Should Be True  0<${c18_sum}<1800  msg=Sum of the values of counter M55601C00018 isn't in range (0;1800)
    ${c19_sum} =  Evaluate  sum(${int_M55601C00019})
    Should Be True  ${c19_sum}>0  msg=None of the values of counter M55601C00019 isn't greater than 0
    Log  === All Counters Have Expected Values! ===  console=True


Start DL Call
    Log  === Prepare UE For Data Transfer And Wait Until Rmod Warms Up ===  console=True
    Set Attenuation  GNB_CELL_10  0dB
    Prepare UE For Data Transfer  UE_FOR_TA  ${NR_CALL_CELL_ID}  connection=gNB
    Start Data Transfer  NR_DL  UE_FOR_TA  dl  duration=900s  protocol=tcp  buffer=32M  max_segment_size=1400
    Sleep  10s  reason=for call stabilization


Stop DL Call
    Log  === Stop Data Transfer ===  console=True
    Stop Data Transfer  NR_DL
    Detach UE  UE_FOR_TA


Parameters Activation
    Set Test Variable  ${REVERT_CHANGES}  True

    &{parameters_dict} =  Create Dictionary
    ...                   frameStructureType=semiStatic
    ...                   guardPeriodLength=2Symbols
    ...                   tdLteUlDlConfig=tdLteConfig2
    ...                   ulDlDataSlotRatio=3/7
    Log  === Activate MicroDtx and RFCooling ===  console=True
    Create Delta
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...                           list_name=tddFrameStructure
    ...                           &{parameters_dict}
    ${delta}  Get Delta
    Log  Delta contents:\n${delta}  console=True
    Perform Delta Recommissioning  ${delta}  connection=gNB

    Wait Until Keyword Succeeds  10m  60s  _Verify Bts States For Iwk Test Helper  alias=gNB
    Log  === Parameters Configured Successfully ===  console=True
    [Teardown]  Remove Delta


Revert to Original SCF
    Log  Reverting to original SCF. Path:${SCF_PATH_GNB}  console=True
    ${modified_scf_path}  ${_} =  Save And Parse SCF  modified_SCF  alias=gNB
    Calculate Delta SCF  ${SCF_PATH_GNB}  ${modified_scf_path}  ${LOG_PATH}/misc_logs/delta_revert.json
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json  connection=gNB
    Wait Until Keyword Succeeds  10m  30s  _verify bts states for iwk test helper  alias=gNB


Get Counters Values
    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${counters_amount}=all
    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  Get PI Value
    ...  pi_list=${counter_list}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*
    ${pi_dict}  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...  ${pi_dict}
    ...  ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts}  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values}  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    [Return]  ${counter_values}


Check If Parameter Has Expected Value
    [Arguments]  ${expected value}
    Check Data Transfer Is Alive  NR_DL
    Check Temperature At Rmod
    Analyze tgtMutingRatio NR TTI  ${NR_CELL_ID}  ${expected value}


Analyze tgtMutingRatio NR TTI
    [Arguments]  ${cell}  ${tgtMutingRatio}

    Log  Collect NR TTI  console=True

    Check Data Transfer Is Alive  NR_DL
    ${cells_list}  Create List  ${cell}
    Setup TTI Decoder
    Collect NR TTI Trace General  ${cells_list}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace/${NR_SCELL_ID_1}
    ...  release=${RELEASE_LOCAL}  collecting_time=3s

    Log  Verify tgtMutingRatio  console=True

    ${path_exist} =  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.csv
    ...  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.0.csv


    ${target_muting_ratio} =  Parse And Group CSV  ${logs_path}  dlSlotBlankingInfo.targetMutingRatio
    ${correct_ratio} =  Evaluate  max([float(x) for x in ${target_muting_ratio}[${cell}]]) >= ${tgtMutingRatio}

    Should Be True  ${correct_ratio}  msg=tgtMutingRatio didn't reach ${tgtMutingRatio}% value
    Log To Console  === tgtMutingRatio reached ${tgtMutingRatio}% value ===


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  === TC Teardown ===  console=True
    Set Attenuation For All Cells  100%
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Run Keyword And Ignore Error  Detach UE  UE_FOR_TA
    Run Keyword If  ${REVERT_CHANGES}  Revert to Original SCF
    IWK Test Teardown  local_enb_connection=False  single_bts=True
