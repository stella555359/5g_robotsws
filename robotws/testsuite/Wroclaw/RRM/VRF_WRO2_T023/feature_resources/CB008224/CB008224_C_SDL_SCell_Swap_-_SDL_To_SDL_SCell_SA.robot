*** Settings ***
Documentation
...  contact: Szymon Startek

Library       ute_ue
Library       taf.config.scf
Library       taf.sbts.oam.coam.admin  WITH NAME  admin
Library       taf.sw.dcap.rd
Library       testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  dcap_manager
Library       ../../resources/parse_csv.py
Resource      ../../resources/ca_IWK.robot
Resource      ../../resources/attenuator.robot


*** Variables ***
${NR_UE_CAPABILITY}              # NR UE capability
${NR_PCELL_ID}                   # ID of primary CA NR cell
${NR_SCELL_ID_1}                 # ID of first CA NR Scell
${NR_SCELL_ID_2}                 # ID of second CA NR Scell
${MAX_DCAP_LOGS_DELAY}           # Max time in seconds needed for change of DCAP logs collecting status to 'Running'
${CELL_ID_FOR_CALL}              # ID of cell to which UE should attach during the test
${ATT_SCELL_1}                   # Attenuator alias of first CA NR Scell
${ATT_SCELL_2}                   # Attenuator alias of second CA NR Scell
${TRUNK_SW}                      # Determines whether the tested SW is trunk

*** Keywords ***
TC__CB008224_C_SDL_SCell_Swap_-_SDL_To_SDL_SCell_SA
    Set Tags    CA-INTER_RAT    AUTHOR-michal.hadrysiak@nokia.com    OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-michal.hadrysiak@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008224   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Perform NR DL Data Transfer
    Step 2: Collect NR TTI
    Step 3: Verify CA activation
    Step 4: Perform SDL Cell Swap
    Step 5: Collect NR TTI
    Step 6: Verify CA activation


Preconditions
    Log  \n=== Preconditions ===  console=True

    Set Global Variables
    Require UE  NR_UE  ${NR_UE_CAPABILITY}


Set Global Variables
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}


Step 1: Perform NR DL Data Transfer
    Log  \n=== Step 1: Perform dl Data Transfer ===  console=True

    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=gNB
    Start Data Transfer  NR_DL  NR_UE  DL  duration=1200s  throughput=1000Mbits/sec  protocol=tcp  packet=1400  port=5407  apn=${APN}

    Log  NR data transfer has started. Wait for it to stabilize...  console=True
    Sleep  30s  Reason=Wait for data transfer to stabilize.


Step 2: Collect NR TTI
    Log  \n=== Step 2: Collect NR TTI ===  console=True

    Check Data Transfer Is Alive  NR_DL
    ${cells_list}  Create List  ${NR_PCELL_ID}  ${NR_SCELL_ID_1}
    Setup TTI Decoder
    Collect NR TTI Trace General  ${cells_list}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace/${NR_SCELL_ID_1}
    ...  release=${RELEASE_LOCAL}  collecting_time=3s  profile_filters=Use RnD parameters


Step 3: Verify CA activation
    Log  ==== Step 3: Verify CA activation ====  console=True

    ${path_exist}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.csv
    ...  ${LOG_PATH}/trace/${NR_SCELL_ID_1}/tcpdump_dl.0.csv
    ${max_data_per_cell_id}  parse_and_group_csv  ${logs_path}  dlFdSchedAdditionalData.maxDataVolumeDl
    ${cells_num}  Get Length  ${max_data_per_cell_id}
    Should Be Equal As Integers  ${cells_num}  2    msg=number of cells is not equal to expected value


Step 4: Perform SDL Cell Swap
    Log  ==== Step 4: Perform SDL Cell Swap ====  console=True

    Set Attenuation  ${ATT_SCELL_2}  0
    FOR  ${loop_iteration}  IN RANGE  0  70
        Set Attenuation  ${ATT_SCELL_1}  ${loop_iteration}
    END


Step 5: Collect NR TTI
    Log  \n=== Step 5: Collect NR TTI ===  console=True

    Check Data Transfer Is Alive  NR_DL
    ${cells_list}  Create List  ${NR_PCELL_ID}  ${NR_SCELL_ID_2}
    Setup TTI Decoder
    Collect NR TTI Trace General  ${cells_list}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace/${NR_SCELL_ID_2}
    ...  release=${RELEASE_LOCAL}  collecting_time=3s  profile_filters=Use RnD parameters


Step 6: Verify CA activation
    Log  ==== Step 6: Verify CA activation ====  console=True

    ${path_exist}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/${NR_SCELL_ID_2}/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/${NR_SCELL_ID_2}/tcpdump_dl.csv
    ...  ${LOG_PATH}/trace/${NR_SCELL_ID_2}/tcpdump_dl.0.csv
    ${max_data_per_cell_id}  parse_and_group_csv  ${logs_path}  dlFdSchedAdditionalData.maxDataVolumeDl
    ${cells_num}  Get Length  ${max_data_per_cell_id}
    Should Be Equal As Integers  ${cells_num}  2    msg=number of cells is not equal to expected value
    [Teardown]  Stop Data Transfer  NR_DL


Start Collecting Control Plane Logs
    Log  \n==== Start Collecting Control Plane Logs ====  console=True

    ${nr_cell_list} =  Create List  ${NR_PCELL_ID}

    ${nr_log_profile} =  Create List  cp_5g
    ${profiles_dictionary} =  Create Dictionary  gnb_custom_profile=${nr_log_profile}
    ${user} =  Evaluate  $tl.gnbs[0].cu.oam_http_connection_details.username
    ${password} =  Evaluate  $tl.gnbs[0].cu.oam_http_connection_details.password

    Start Dcap Helper  ${nr_cell_list}  ${profiles_dictionary}  ${user}  ${password}

    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_DCAP_LOGS_DELAY}  5s  Check If Traces Are Running

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL' and ${DCAP_STARTED}
    ...  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}


Start Dcap Helper
    [Arguments]  ${nr_cell_list}  ${profiles_dictionary}  ${user}  ${password}

    Log  Connecting to DCAP server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    dcap_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}


    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${GNB_OAM_IP}...  console=True
    Set Test Variable  ${DCAP_STARTED}  True
    ${trace_id} =  dcap_manager.Start New Trace  mplane=${GNB_OAM_IP}  user=${user}  passwd=${password}
    ...  port=${DCAP_HOST['port']}  nr_cells=${nr_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  dcap_manager.Stop Trace  trace=${trace_id}
    ...  AND  dcap_manager.Teardown
    ...  AND  Set Test Variable  ${DCAP_STARTED}  False
    ...  AND  Log  Start UTF failed. Please check logs for details.  console=True  level=WARN


Check If Traces Are Running
    ${trace_status} =  Get Trace Info By ID  trace_id=${TRACE_ID}  connection=dcap_collector
    Should Be Equal As Strings  ${trace_status['status']}  running
    ...  msg=Trace status is ${trace_status['status']}. Should be: 'running'.
    Log  Trace status ${trace_status['status']}  console=True


Stop DCAP Traces And Download Logs
    [Arguments]  ${trace_id}

    Log  Stopping DCAP traces...  console=True
    dcap_manager.Stop Trace  trace=${trace_id}
    Set Test Variable  ${DCAP_STARTED}  False
    Log  Downloading logs...  console=True
    ${dcap_logs_path} =  dcap_manager.Download Logs  trace=${trace_id}  target_dir=${LOG_PATH}/dcap_logs
    Log  Logs downloaded to ${dcap_logs_path}.  console=True
    Set Test Variable  ${DCAP_LOGS_PATH}  ${dcap_logs_path}
    dcap_manager.Teardown
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Log  Stop UTF failed. Please check logs for details.  console=True  level=WARN


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True
    Run Keyword and Ignore Error  Start Collecting Control Plane Logs


TC Teardown
    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Detach UE  NR_UE
    Run Keyword If  ${DCAP_STARTED}  Run Keyword and Ignore Error  Stop DCAP Traces and Download Logs  trace_id=${TRACE_ID}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
