*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ute_ue
Library     taf.ul.alarms_watchdog
Library     ../../resources/parse_csv.py
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of primary NR cell
${SECONDARY_NR_CELL_ID}                         # ID of secondary NR cell
${NR_EXPECTED_DL_TPUT}                          # Expected NR DL tput for CA cell in Mbps
${NR_EXPECTED_UL_TPUT}                          # Expected NR UL tput for CA cell in Mbps
${TA_ATTENUATOR_CONFIG}                         # Absolute path to YAML file with attenuator configuration
${ADDITIONAL_UE_CAPABILITY}                     # Additional capability of UE (mainly for differentiating between android and iphone)
${APN_CONTAINS}                  n26wro         # Part of APN name that does not change. Default value: n26wro
${PRIMARY_CELL_ALIAS}                           # Alias set for primary cell in attenuator configuration file
${SECONDARY_CELL_ALIAS}                         # Alias set for secondary cell in attenuator configuration file
${PROFILE_FILTERS}                              # Allowed L2PsProfileFilter
${MAX_DATA_VOLUME_DL}                           # Name of column with max data volume dl per cell
${PHYSICAL_NR_CELL_ID}                          # Physical cell ID of primary NR cell
${PHYSICAL_SECONDARY_NR_CELL_ID}                # Physical cell ID of secondary NR cell


*** Keywords ***
TC__Rjio_E2E_26_CA_Call

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-marcel.behen@nokia.com
    ...         PHASE-CDRT   SW-SBTS24R1    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Perform Data Transfer In Cell With Carrier Aggregation
    Step 2: Verify Througput Values
    Step 3: Collect NR TTI
    Step 4: Verify CA activation
    Step 5: Check BTS State


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${CHECK_IN_TEARDOWN}  True
    Set Test Variable  ${ATTENUATOR_SET}  False
    Check If Carrier Aggregation Is Enabled
    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${global_nr_cell_id}

    _choose ue type helper
    ${ue_capabilities} =  Create List  NR_LOCKED_CA  ${ADDITIONAL_UE_CAPABILITY}
    Require UE  CA_UE  ${ue_capabilities}
    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${PRIMARY_CELL_ALIAS}  ${0}
    Set Attenuation  ${SECONDARY_CELL_ALIAS}  ${0}

    Run Keyword If  '${UE_TYPE}' == 'iphone'  Remove Baseband Logs  CA_UE


Check If Carrier Aggregation Is Enabled
    ${_}  ${scf_gnb} =  Save And Parse SCF  SCF_gNB_changed  alias=gNB
    Log  Checking if NRREL for NRCELL-${NR_CELL_ID} has lcrId=${SECONDARY_NR_CELL_ID}...  console=True
    Check Element In SCF  ${scf_gnb}  NRREL  NRCELL-${NR_CELL_ID}  /p[@name='lcrId']
    ...  <p name="lcrId">${SECONDARY_NR_CELL_ID}</p>

    ${ca_support_list_string} =  Get Parameter Value From SCF  ${scf_gnb}  NRDU  NRDU
    ...  /list[@name='carrierAggregationSupportList']
    ${ca_support_list_string} =  Remove String  ${ca_support_list_string}  ${SPACE}
    ${ca_support_list} =  Split To Lines  ${ca_support_list_string}
    List Should Contain Value  ${ca_support_list}  ca_Fdd_Fr1Tdd_Sa
    ...  msg=NRDU does not have 'ca_Fdd_Fr1Tdd_Sa' configured in carrierAggregationSupportList.
    Log  NRDU/carrierAggregationSupportList contains 'ca_Fdd_Fr1Tdd_Sa' vaule.  console=True


Step 1: Perform Data Transfer In Cell With Carrier Aggregation
    Log  \n==== Step 1: Perform Data Transfer In Cell With Carrier Aggregation ====  console=True

    Get UE Info  CA_UE  ALL
    Prepare UE For Data Transfer  CA_UE  ${NR_CALL_CELL_ID}  connection=gNB  apn=${APN_CONTAINS}  ue_type=${UE_TYPE}
    ...  lte_cell=False
    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=CA_UE
    Log  \nUE attached to cell ${NR_CALL_CELL_ID}.  console=True
    Start Data Transfer  NR_DL  CA_UE  dl  throughput=400 Mbits/sec  duration=1800s
    ...  protocol=udp  packet=1400  parallel_streams=4  buffer=32M  apn=${apn}
    Log  \nDL data transfer ongoing...  console=True
    Start Data Transfer  NR_UL  CA_UE  ul  throughput=25 Mbits/sec  duration=1800s
    ...  protocol=udp  packet=1400  parallel_streams=4  buffer=32M  apn=${apn}
    Log  \nUL data transfer ongoing...  console=True
    Sleep    360s


Step 2: Verify Througput Values
    Log  \n==== Step 2: Verify Througput Values ====  console=True

    Get UE Info  CA_UE  ALL
    Check Data Transfer Is Alive  NR_DL
    Check Data Transfer Is Alive  NR_UL
    ${nr_dl_tput} =  Get Average Throughput  NR_DL
    ${nr_ul_tput} =  Get Average Throughput  NR_UL
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    ${nr_ul_tput} =  Evaluate  ${nr_ul_tput}/1000.0
    Log  \nDL:${nr_dl_tput} Mbps\nUL:${nr_ul_tput} Mbps  console=True

    Run Keyword And Continue On Failure  Should Be True  ${nr_dl_tput} >= ${NR_EXPECTED_DL_TPUT}
    ...  msg=DL tput (${nr_dl_tput} Mbps) is lower than expected (${NR_EXPECTED_DL_TPUT} Mbps)
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation
    ...  NR_UL  ${NR_EXPECTED_UL_TPUT} Mbits/sec  20%  10


Step 3: Collect NR TTI
    Log  \n=== Step 3: Collect NR TTI ===  console=True

    Check Data Transfer Is Alive  NR_DL
    ${cells_list} =  Create List  ${PHYSICAL_NR_CELL_ID}  ${PHYSICAL_SECONDARY_NR_CELL_ID}
    Setup TTI Decoder
    Collect NR TTI Trace General  ${cells_list}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace  release=${RELEASE_LOCAL}
    ...                           collecting_time=3s  profile_filters=${PROFILE_FILTERS}

    [Teardown]  Run Keywords  Get UE Info  CA_UE
    ...    AND  Stop Data Transfer  NR_DL
    ...    AND  Stop Data Transfer  NR_UL
    ...    AND  Detach UE  CA_UE


Step 4: Verify CA activation
    Log  ==== Step 4: Verify CA activation ====  console=True

    ${path_exist} =  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${LOG_PATH}/trace/tcpdump_dl.csv
    ${logs_path} =  Set Variable If  ${path_exist}  ${LOG_PATH}/trace/tcpdump_dl.csv  ${LOG_PATH}/trace/tcpdump_dl.0.csv
    ${max_data_per_cell_id} =  Parse And Group CSV  ${logs_path}  ${MAX_DATA_VOLUME_DL}
    ${cells_num} =  Get Length  ${max_data_per_cell_id}
    Should Be Equal As Integers  ${cells_num}  2  msg=number of cells is not equal to expected value


Step 5: Check BTS State
    Log  \n==== Step 5: Check BTS State ====  console=True

    _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    Set Test Variable  ${CHECK_IN_TEARDOWN}  False
    taf.ul.alarms_watchdog.Check Detected Alarms


_choose ue type helper
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE'
        Set Test Variable  ${UE_TYPE}  iphone
    ELSE
        Set Test Variable  ${UE_TYPE}  android
    END


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  gnb_ignored_alarms=${IGNORED_ALARMS}
    Alarm Watchdog Setup  ${CA_ALLOWED_FAULT_IDS}


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Run Keyword And Ignore Error  Stop Data Transfer  NR_UL
    Detach UE  CA_UE
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Collect And Save Baseband Logs For Iphone  CA_UE
    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
