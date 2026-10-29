*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     ute_ue
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of tested NR cell
${NR_UE_CAPABILITY}                             # Capability of UE used for test
${NR_EXPECTED_DL_TPUT}                          # Expected NR DL tput in Mbps
${CELL_ALIAS}                                   # Alias set for tested cell in attenuator configuration file
${NAMESPACE}                                    # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}        5                      # Counter collecting interval in minutes. Default value: 5
${APN_CONTAINS}          n26wro/rmnet_data      # Part of APN name that does not change. Default value: n26wro/rmnet_data.

*** Keywords ***
TC__CB008370-A_B1-Activation_of_the_feature_for_single_UE_in_good_radio_conditions

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         PHASE-CRT   SW-SBTS24R3    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Perform Data Transfer
    Step 2: Collect Counters
    Step 3: Activate CB008370
    Step 4: Perform Data Transfer
    Step 5: Collect Counters
    Step 6: Analyze Counter Values
    Step 7: Compare Throughput Values


Preconditions
    Log  \n==== Preconditions ====  console=True

    ${waiting_time1} =  Count Measurement Period  ${VDU_MASTER_SSH_DETAILS.addr}  ${COUNTER_PERIOD}
    ...  user=${VDU_MASTER_SSH_DETAILS.username}  password=${VDU_MASTER_SSH_DETAILS.password}

    Create Global Variables

    Save SCF VDU  vDU_SCF_original.xml
    Save SCF VCU  vCU_SCF_original.xml

    Verify CB008370 Value On VDU  false
    Verify CB008370 Value On VCU  false

    Prepare Deltas For Toggling On VDU
    Prepare Deltas For Toggling On VCU

    Require UE  NR_UE  ${NR_UE_CAPABILITY}

    Wait For New Counter Period  ${waiting_time1}
    Wait For New Counter Period

    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${CELL_ALIAS}  ${0}

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Create Global Variables
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${CB008370_ACTIVATED_ON_VDU}  False
    Set Test Variable  ${CB008370_ACTIVATED_ON_VCU}  False

    Get Start Time

    Get MRBTS ID From VCU
    Get MRBTS ID From VDU
    Get NRBTS ID From VDU

    ${nr_cell_identity} =  Get NR Cell Identity From VDU  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${nr_cell_identity}

    &{tput_dict} =  Create Dictionary
    Set Test Variable  ${TPUT_DICT}


Verify CB008370 Value On VDU
    [Arguments]  ${expected_value}

    Connect To VDU
    ${current_value} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  para_name=actPdcchSharingWithPdsch
    Should Be True  '${current_value}' == '${expected_value}'
    ...  msg=Value for actPdcchSharingWithPdsch (${current_value}) on vDU is different than expected (${expected_value}).
    Log  CB008370 check on vDU successful.  console=True

    [Teardown]  vdu.Disconnect


Verify CB008370 Value On VCU
    [Arguments]  ${expected_value}

    Connect To VCU
    ${nrcell_parameters} =  vcu.Get Parameters  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ${parameter_data} =  Evaluate  [x for x in @{nrcell_parameters['parameters']} if 'actPdcchSharingWithPdsch' in str(x)]
    Should Be True  '${parameter_data[0]['simple_parameter']['name']}' == 'actPdcchSharingWithPdsch'
    ...  msg=Parameter name (${parameter_data[0]['simple_parameter']['name']}') is different from 'actPdcchSharingWithPdsch'.
    ${current_value} =  Set Variable  ${parameter_data[0]['simple_parameter']['value']}
    Should Be True  '${current_value}' == '${expected_value}'
    ...  msg=Value for actPdcchSharingWithPdsch (${current_value}) on vCU is different than expected (${expected_value}).
    Log  CB008370 check on vCU successful.  console=True

    [Teardown]  vcu.Disconnect


Prepare Deltas For Toggling On VDU
    Load SCF  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    Modify SCF Element  value=true  dist_name=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  p_name=actPdcchSharingWithPdsch
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_vdu.xml
    Calculate Delta Between SCFs  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml  ${LOG_PATH}/misc_logs/modified_SCF_vdu.xml
    ...  pdcch_sharing_vdu


Prepare Deltas For Toggling On VCU
    Load SCF  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml
    Modify SCF Element  value=true  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  p_name=actPdcchSharingWithPdsch
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_vcu.xml
    Calculate Delta Between SCFs  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml  ${LOG_PATH}/misc_logs/modified_SCF_vcu.xml
    ...  pdcch_sharing_vcu


Step ${index}: Perform Data Transfer
    Log  \n==== Step ${index}: Perform Data Transfer ====  console=True

    ${waiting_time1} =  Count Measurement Period  ${VDU_MASTER_SSH_DETAILS.addr}  ${COUNTER_PERIOD}
    ...  user=${VDU_MASTER_SSH_DETAILS.username}  password=${VDU_MASTER_SSH_DETAILS.password}

    cloud_bts.Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}
    Log  \nUE attached to cell ${NR_CALL_CELL_ID}.  console=True

    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=NR_UE
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=200 Mbits/sec  duration=600s
    ...  protocol=udp  packet=1400  parallel_streams=4  apn=${apn}

    Sleep  150s  reason=Running data transfer.

    Check Data Transfer Is Alive  NR_DL
    ${nr_dl_tput} =  Get Average Throughput  NR_DL  omit=30
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    Log  \nDL:${nr_dl_tput} Mbps  console=True

    Set To Dictionary  ${TPUT_DICT}  ${index}=${nr_dl_tput}
    Set Test Variable  ${TPUT_DICT}

    Run Keyword And Continue On Failure  Should Be True  ${nr_dl_tput} >= ${NR_EXPECTED_DL_TPUT}
    ...  msg=DL tput (${nr_dl_tput} Mbps) is lower than expected (${NR_EXPECTED_DL_TPUT} Mbps)

    [Teardown]  Run Keywords  Stop Data Transfer  NR_DL
    ...    AND  Detach UE  NR_UE
    ...    AND  Wait For New Counter Period  ${waiting_time1}


Step ${index}: Collect Counters
    Log  \n==== Step ${index}: Collect Counters ====  console=True

    ${for_last} =  Evaluate  ${COUNTER_PERIOD} * 2
    Sleep  60s    reason=Additional waiting time for counters to update.
    Connect To VDU

    ${m55308c03001} =  Get Counter List For VDU  counter_id=M55308C03001  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  counter_amount=2  start_time=${START_TIME}
    Log  M55308C03001 = ${m55308c03001}  console=True
    Set Test Variable  ${M55308C03001_STEP${index}}  ${m55308c03001}

    ${m55308c03005} =  Get Counter List For VDU  counter_id=M55308C03005  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  counter_amount=2  start_time=${START_TIME}
    Log  M55308C03005 = ${m55308c03005}  console=True
    Set Test Variable  ${M55308C03005_STEP${index}}  ${m55308c03005}

    ${m55335c02019} =  Get Counter List For VDU  counter_id=M55335C02019  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  counter_amount=2  start_time=${START_TIME}
    Log  M55335C02019 = ${m55335c02019}  console=True
    Set Test Variable  ${M55335C02019_STEP${index}}  ${m55335c02019}

    ${m55335c02020} =  Get Counter List For VDU  counter_id=M55335C02020  dimension_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...  counter_amount=2  start_time=${START_TIME}
    Log  M55335C02020 = ${m55335c02020}  console=True
    Set Test Variable  ${M55335C02020_STEP${index}}  ${m55335c02020}

    [Teardown]  Collect PM Counters  xml_files_left=2  host=${VDU_OAM_CONNECTION.addr}  user=${VDU_OAM_CONNECTION.username}
    ...  password=${VDU_OAM_CONNECTION.password}  time_interval=${for_last} min  intervals=${COUNTER_PERIOD}  bts_type=vdu
    ...  target_dir_path=${LOG_PATH}/pm_counters/step${index}



Step 3: Activate CB008370
    Log  \n==== Step 3: Activate CB008370 ====  console=True


    Set Test Variable  ${CB008370_ACTIVATED_ON_VCU}  True
    Toggle CB008370 On VCU  true

    Set Test Variable  ${CB008370_ACTIVATED_ON_VDU}  True
    Toggle CB008370 On VDU  true

    Wait Until Keyword Succeeds  5min  5s  Verify BTS States For Cloud BTS
    ...  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Get Start Time  ${COUNTER_PERIOD}
    Wait For New Counter Period


Toggle CB008370 On VCU
    [Arguments]  ${value}
    Log  Toggle CB008370 On VCU - value:${value}  console=True

    ${file_name} =  Set Variable If  '${value}' == 'true'  pdcch_sharing_vcu.json  pdcch_sharing_vcu_revert.json
    Connect To VCU
    Log  Performing recommissioning on vCU...  console=True
    vcu.Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/${file_name}
    Verify CB008370 Value On VCU  ${value}
    Log  Update on vCU finished.  console=True

    [Teardown]  Run Keyword And Ignore Error  vcu.Disconnect


Toggle CB008370 On VDU
    [Arguments]  ${value}
    Log  Toggle CB008370 On VDU - value:${value}  console=True

    ${file_name} =  Set Variable If  '${value}' == 'true'  pdcch_sharing_vdu.json  pdcch_sharing_vdu_revert.json
    Connect To VDU
    Log  Performing recommissioning on vDU...  console=True
    vdu.Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/${file_name}
    Verify CB008370 Value On VDU  ${value}
    Log  Update on vDU finished.  console=True

    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect


Step 6: Analyze Counter Values
    Log  \n==== Step 6: Analyze Counter Values ====  console=True

    Should Be True  ${M55308C03001_STEP2[0]} < ${M55308C03001_STEP2[1]} and ${M55308C03001_STEP2[0]} < ${M55308C03001_STEP5[1]}
    ...  msg=One or more of the values of counter M55308C03001 are incorrect.
    Should Be True  ${M55308C03005_STEP2[0]} < ${M55308C03005_STEP2[1]} and ${M55308C03005_STEP2[0]} < ${M55308C03005_STEP5[1]}
    ...  msg=One or more of the values of counter M55308C03005 are incorrect.
    Should Be True  ${M55335C02019_STEP2[0]} == ${M55335C02019_STEP2[1]} and ${M55335C02019_STEP2[0]} < ${M55335C02019_STEP5[1]}
    ...  msg=One or more of the values of counter M55335C02019 are incorrect.
    Should Be True  ${M55335C02020_STEP2[0]} == ${M55335C02020_STEP2[1]} and ${M55335C02020_STEP2[0]} == ${M55335C02020_STEP5[1]}
    ...  msg=One or more of the values of counter M55335C02020 are incorrect.


Step 7: Compare Throughput Values
    Log  \n==== Step 7: Compare Throughput Values ====  console=True

    Should Be True  ${TPUT_DICT['1']} <= ${TPUT_DICT['4']}
    ...  msg=Thoughput value for execution with activated feature is lower than with disabled feature.


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Set Test Variable  ${WIRESHARK_STARTED}  True
    Start Wireshark Log Collection For VCU  namespace=${NAMESPACE}


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Run Keyword If  ${CB008370_ACTIVATED_ON_VDU}  Toggle CB008370 On VDU  false
    Run Keyword If  ${CB008370_ACTIVATED_ON_VCU}  Toggle CB008370 On VCU  false
    Wait Until Keyword Succeeds  5min  5s  Verify BTS States For Cloud BTS
    ...  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  ${WIRESHARK_STARTED}  Stop Wireshark Log Collection
    Cloud BTS Test Teardown
