*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library       ute_ue
Library       taf.config.scf
Library       taf.sbts.oam.coam.admin  WITH NAME  admin
Library       ../../resources/parse_csv.py
Resource      ../../resources/ca_IWK.robot


*** Variables ***
${NR_UE_CAPABILITY}              # NR UE capability
${NR_PCELL_ID}                   # ID of primary CA NR cell
${NR_SCELL_ID}                   # ID of secondary CA NR cell
${CELL_ID_FOR_CALL}              # ID of cell to which UE should attach during the test
${APN_CONTAINS}                  # Part of APN name that does not change. Default value: n26wro
${DELTA_PATH}                    # Path to delta file
${PROFILE_FILTERS}               # List of allowed L2PsProfileFilter
${MAX_DATA_VOLUME_DL}            # Name of column with max data volume dl per cell

*** Keywords ***
TC__CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
    Set Tags    CA-INTER_RAT    AUTHOR-szymon.kotlinski@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-szymon.kotlinski@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008224   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Perform NR DL Data Transfer
    Step 2: Collect NR TTI
    Step 3: Verify CA activation

Preconditions
    Log  \n=== Preconditions ===  console=True

    Set Global Variables
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Test Preconditions Setup


Set Global Variables

    Set Test Variable  ${PARAMETERS_CHANGED}  False

    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}


Step 1: Perform NR DL Data Transfer
    Log  \n=== Step 1: Perform dl Data Transfer ===  console=True

    Attach Ue  NR_UE  timeout=60
    ${apn_dictionary} =  Get UE Info  NR_UE  IPS
    ${apn_list} =  Get Dictionary Keys  ${apn_dictionary}
    ${apn} =  Evaluate  [x for x in @{apn_list} if '${APN_CONTAINS}' in x]
    ${ue_ip} =  Set Variable  ${apn_dictionary['${apn[0]}'][0]}
    Should Match Regexp  ${ue_ip}  \\d+\\.\\d+\\.\\d+\\.\\d+
    ${cell_id}  Get Ue Info  NR_UE  CELL_ID
    Should Be Equal As Strings  ${CELL_ID_FOR_CALL}  ${cell_id}
    Start Data Transfer  NR_DL  NR_UE  DL  duration=1200s  throughput=1000Mbits/sec  protocol=tcp  packet=1400  port=5407  apn=${apn[0]}

    Log  NR data transfer has started. Wait for it to stabilize...  console=True
    Sleep  30s  Reason=Wait for data transfer to stabilize.


Step 2: Collect NR TTI
    Log  \n=== Step 2: Collect NR TTI ===  console=True

    Check Data Transfer Is Alive  NR_DL
    ${cells_list}  Create List  ${NR_PCELL_ID}  ${NR_SCELL_ID}
    Setup TTI Decoder
    Collect NR TTI Trace General  ${cells_list}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace  release=${RELEASE_LOCAL}
    ...                           collecting_time=3s  profile_filters=${PROFILE_FILTERS}
    [Teardown]  Stop Data Transfer  NR_DL


Step 3: Verify CA activation
    Log  ==== Step 3: Verify CA activation ====  console=True

    ${path_exist}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/tcpdump_dl.csv  ${LOG_PATH}/trace/tcpdump_dl.0.csv
    ${max_data_per_cell_id}  parse_and_group_csv  ${logs_path}  ${MAX_DATA_VOLUME_DL}
    ${cells_num}  Get Length  ${max_data_per_cell_id}
    Should Be Equal As Integers  ${cells_num}  2    msg=number of cells is not equal to expected value


Test Preconditions Setup
    Log  \n Test Preconditions Setup  console=True
    Set Test Variable  ${PARAMETERS_CHANGED}  True
    Perform Delta Recommissioning  ${DELTA_PATH}  alias=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB


Revert to Original SCF
    Log  Reverting to original SCF. Path:${SCF_PATH_GNB}  console=True
    ${modified_scf_path}  ${_} =  Save And Parse SCF  modified_SCF  alias=gNB
    Calculate Delta SCF  ${SCF_PATH_GNB}  ${modified_scf_path}  ${LOG_PATH}/misc_logs/delta_revert.json
    Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/delta_revert.json    connection=gNB
    Wait Until Keyword Succeeds  6m  20s  _verify bts states for iwk test helper  alias=gNB


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE
    Run Keyword If  ${PARAMETERS_CHANGED}  Revert to Original SCF
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
