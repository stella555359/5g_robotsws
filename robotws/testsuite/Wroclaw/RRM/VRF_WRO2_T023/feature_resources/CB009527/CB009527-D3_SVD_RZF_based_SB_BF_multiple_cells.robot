*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Library    SSHLibrary
Library    OperatingSystem
Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    ta5g_pm_counters
Library    ute_fsmaccess


*** Variables ***
${NR_UE_1_ALIAS}                # NR SA UE 1 capability
${NR_CELL_ID_1}                 # NR SA cell ID 1
${NR_CELL_ID_2}                 # NR SA cell ID 2
${NR_CELL_ID_3}                 # NR SA cell ID 3
${NR_CELL_ID_4}                 # NR SA cell ID 4
${APN}                          # APN name


*** Keywords ***
TC__CB009527-D3_SVD_RZF_based_SB_BF_multiple_cells
    Set Tags    AUTHOR, MAINTAINER-magdalena.swierbutowicz@nokia.com    OWNER-adam.szczerba@nokia.com
    ...  PHASE-CRT   SW-SBTS25R3    FEATURE-CB009527-D    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Enable Subband BF On All Cells
    Looped Steps
    Step 5: Check SCF Modifications


Looped Steps
    FOR  ${cell_id}  IN  @{NR_CELL_LIST}
        Set Test Variable  ${CELL_ID}  ${cell_id}
        Log  \n----- Performing operations for: ${CELL_ID} -----  console=True
        Step 2: Perform L3 Call
        Step 3: Get Counters Values
        Step 4: Check Counters Values
        Log  \n----- END of operations for: ${CELL_ID} -----\n  console=True
    END


Preconditions
    Log  \n==== Preconditions ====  console=True

    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Require Ue  SA_UE_1  ${NR_UE_1_ALIAS}
    Set Attenuation  AVHA_IN_CELLS  0dB

    ${nr_cell_list} =  Create List
    ...  ${NR_CELL_ID_1}
    ...  ${NR_CELL_ID_2}
    ...  ${NR_CELL_ID_3}
    ...  ${NR_CELL_ID_4}
    Set Test Variable  ${NR_CELL_LIST}  ${nr_cell_list}

    Log  = Preconditions passed =  console=True


Step 1: Enable Subband BF On All Cells
    Log  \n==== Step 1: Enable Subband BF On All Cells ====  console=True

    Log  Creating delta.  console=True
    Create Delta  alias=delta
    Append Parameter Update To Delta
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_1}  actDlSrsSubbandBm  true  alias=delta
    Append Parameter Update To Delta
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_2}  actDlSrsSubbandBm  true  alias=delta
    Append Parameter Update To Delta
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_3}  actDlSrsSubbandBm  true  alias=delta
    Append Parameter Update To Delta
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_4}  actDlSrsSubbandBm  true  alias=delta
    ${delta}  Get Delta  alias=delta
    Log  Delta contents:\n${delta}\n  console=True
    Perform Delta Recommissioning  delta_file=${delta}  connection=gNB
    Wait Until Keyword Succeeds  2m  30s  _verify bts states for iwk test helper  alias=gNB


Step 2: Perform L3 Call
    Log  \n==== Step 2: Perform L3 Call ====  console=True

    Change qRxLevMin Parameter  ${cell_id}  -70

    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${cell_id}
    Prepare UE For Data Transfer  SA_UE_1  ${global_nr_cell_id}  connection=gNB
    Wait For Next Full Pm Interval
    Log  Start NR DL data transfer in cell NR-${cell_id} on UE.  console=True
    Start Data Transfer  DT_DL_SA_1  SA_UE_1  dl  throughput=500Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=300s  apn=${APN}
    Wait For Next Full Pm Interval

    [Teardown]  UE Teardown


Change qRxLevMin Parameter
    [Arguments]  ${cell_id}  ${parameter_value}

    Perform Parameter Recommissioning  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...  qRxLevMin  update  ${parameter_value}  connection=gNB
    _verify bts states for iwk test helper  alias=gNB


Step 3: Get Counters Values
    Log    === Step 3: Get Counters Values ===    console=True

    &{counters_dict} = 	Create Dictionary
    ${nr_pm_counter_file} =  Get Counters File  ${cell_id}

    ${nr_counters_list} =  Create List
    ...    M55330C00017
    ...    M55330C00018
    ...    M55330C00042
    ...    M55330C00020
    ...    M55330C00021
    ...    M55196C00010
    ...    M55196C00012

    FOR  ${counter_id}  IN  @{nr_counters_list}
        ${nr_counter_value} =  Get Latest Pm Counter Value  ${counter_id}
        ...    filepath=${nr_pm_counter_file}
        ...    local_moid=MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Set To Dictionary  ${counters_dict}  ${counter_id}  ${nr_counter_value}
    END
    Set Test Variable  ${COUNTERS_DICT}  ${counters_dict}
    Log  List of counters: &{COUNTERS_DICT}  console=True


Get Counters File
    Log    === Get Counters File ===    console=True

    [Arguments]  ${cell_id}

    ${pm_counter_file} =  Get Latest Unpacked Full Pm Counters File
    ...  output_dirpath=${LOG_PATH}/pm_counters_NRCELL-${cell_id}
    [Return]  ${pm_counter_file}


Step 4: Check Counters Values
    Log    === Step 4: Check Counters Values ===    console=True

    Dictionary Should Not Contain Value  dictionary=${COUNTERS_DICT}  value=${0}
    ...  msg=One or more counters are equal to 0
    Log  All cells have correct value in all subband BF counters.  console=True


Step 5: Check SCF Modifications
    Log    === Step 5: Check SCF Modifications ===    console=True

    Perform Delta Recommissioning    ${CURDIR}/delta/delta_SCF.json    alias=gNB
    Wait Until Keyword Succeeds  2m  30s  _verify bts states for iwk test helper  alias=gNB


UE Teardown
    Log  Stop Data Transfer and detach UE.  console=True
    Stop Data Transfer  DT_DL_SA_1
    Detach UE  SA_UE_1
    Change qRxLevMin Parameter  ${cell_id}  -22


Save Original SCF
    Log  = Save original SCF =  console=True
    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${ORIGINAL_SCF_PATH}  ${scf_path_gnb}
    Log  Saved SCF under: ${LOG_PATH}/misc_logs/original_SCF.xml  console=True


Revert Changes
    Log  Performing delta recommissioning...  console=True
    ${modified_scf_path}  ${_} =  Save And Parse SCF  SCF_reverted  alias=gNB
    Calculate Delta SCF  ${ORIGINAL_SCF_PATH}  ${modified_scf_path}  ${LOG_PATH}/misc_logs/delta_revert.json
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json  connection=gNB
    Wait Until Keyword Succeeds  2m  30s  _verify bts states for iwk test helper  alias=gNB


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True
    Save Original SCF


TC Teardown
    Log  === TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfer  DT_DL_SA_1
    Run Keyword And Ignore Error  Detach UE  SA_UE_1
    Revert Changes
    IWK Test Teardown  local_enb_connection=False  single_bts=True
