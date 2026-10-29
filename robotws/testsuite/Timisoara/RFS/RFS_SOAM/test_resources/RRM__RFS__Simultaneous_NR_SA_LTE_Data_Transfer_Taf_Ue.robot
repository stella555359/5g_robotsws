*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${NR_TYPE}    NR                         # Possible values: NR (default, when NR is the only RAT on BTS); SBTS_NR
${LTE_TYPE}    LTE                       # Possible values: LTE (default, when LTE is the only RAT on BTS); SBTS_LTE
${NR_UE_CAPABILITIES}    None            # For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${LTE_UE_CAPABILITIES}    None           # For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CELLS_LIST_NR_UE}    DEFAULT           # Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id.
${CELLS_LIST_LTE_UE}    DEFAULT          # Specify the cells list on which LTE_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. LTE -  Eutran Cell Id is used.
${CALL_DURATION}    100                  # Duration of data call for both UEs (in seconds);
${CALL_DIRECTION_NR_UE}    downlink      # Direction of data transfer call for NR_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_LTE_UE}    downlink     # Direction of data transfer call for LTE_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${PROTOCOL_NR_UE}    udp                       # Data transfer protocol for NR_UE. e.q. udp, tcp, ftp
${PROTOCOL_LTE_UE}    udp                      # Data transfer protocol for LTE_UE. e.q. udp, tcp, ftp
${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec   # DL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec   # DL Minmum acceptable t-put for NR_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec      # UL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec      # UL Minimum acceptable t-put for NR_UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec  # DL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec  # DL Minmum acceptable t-put for LTE_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec     # UL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec     # UL Minimum acceptable t-put for LTE_UE; acceptable values: e.q.  - 3 Mbits/sec;
${BANDWIDTH}    60 Mbits/sec                  # max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
${DETACH_UE}    False                         # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False.
${CHECK_ATTACH_ONLY}    False             # Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
                                         # Default value: False

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-26031
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing simultaneous NR SA and LTE data transfer calls on 2 UEs.
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - NR_TYPE                    ---- Possible values: NR (default, when NR is the only RAT on BTS); SBTS_NR
    ...
    ...  - LTE_TYPE                   ---- Possible values: LTE (default, when LTE is the only RAT on BTS); SBTS_LTE
    ...
    ...  - NR_UE_CAPABILITIES       ----  For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - LTE_UE_CAPABILITIES      ----  For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - CELLS_LIST_NR_UE         ----  Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - - User provides cells list
    ...                                  with space between Cells Id
    ...  - CELLS_LIST_LTE_UE        ----  Specify the cells list on which LTE_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...
    ...  - CALL_DIRECTION_NR_UE     ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DIRECTION_LTE_UE    ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DURATION            ----  Duration of data call in seconds
    ...
    ...  - PROTOCOL_NR_UE           ----  Data transfer protocol for NR_UE. e.q. udp, tcp, ftp
    ...
    ...  - PROTOCOL_LTE_UE          ----  Data transfer protocol for LTE_UE. e.q. udp, tcp, ftp
    ...
    ...  - downlink_MAX_TPUT_NR_UE  ----  DL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_NR_UE  ----  DL Minmum acceptable t-put for NR_UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_NR_UE    ----  UL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_NR_UE    ----  UL Minimum acceptable t-put for NR_UE; acceptable values: e.q.  - 3 Mbits/sec;
    ...
    ...  - downlink_MAX_TPUT_LTE_UE ----  DL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_LTE_UE ----  DL Minmum acceptable t-put for LTE_UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_LTE_UE   ----  UL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_LTE_UE   ----  UL Maximum acceptable t-put for LTE_UE; acceptable values: e.q. - 3 Mbits/sec;
    ...
    ...  - BANDWIDTH                ----  max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UEs after the test execution; Possible values: True/False. Default value: False
    ...
    ...  - CHECK_ATTACH_ONLY        ----  Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
    ...                                   Default value: False
    ...
    ...  Test scenario:
    ...
    ...  -    UE is attached to the cell under test on NR technology BTS. 2nd UE is attached on LTE BTS technology
    ...  -    UEs successfully attached to the cell under test on NR/LTE technology BTSs.
    ...  -    UDP Data transfer is started. DL+UL started on 1st UE on NR. DL+UL started on 2nd UE on LTE.
    ...  -    When data transfer is established, throughput is measured for at least 5min to be as expected.
    ...  -    Data transfer is successfully started and throughput levels are acceptable
    ...  -    Data transfer is disconnected. All services are terminated and UE is detached.
    ...  -    Disconnection is successful and resources are released correctly
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26031 -  NEW TC 5 G SA call parallel w LTE call (no attenuator, any sector)
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26605 - [Calls] Adapt Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 08.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26315 -
    ...  [Calls][P1]Check attach only option RRM__RFS__NR_LTE_Simultaneous_NR_SA_LTE_Data_Transfer_Taf_Ue
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26606 - [Calls] Remove Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 26.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26793 - [Calls]Need UE reboot action added for
    ...  RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26031_RRM__RFS__NR_LTE_Simultaneous_NR_SA_LTE_Data_Transfer_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-roxana.micusan@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-CR1
    ...    SBTS23R3    CABLING-RFS_01_UE

    Step 1: Get Cells List of NR
    Step 2: Get Cells List of LTE
    Step 3: Perform Simultaneous call for both UEs
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Get Cells List of ${TECHNO}
    Log  Step ${index}: Get Cells List of selected techno: ${TECHNO}  console=True
    ${ue_index}=  Set Variable If  '${TECHNO}'=='NR'  1  '${TECHNO}'=='LTE'  2
    ${BTS_nb}=  Get Length  ${alias_list}
    ${cells_list}=  Run Keyword If  ${BTS_nb}==1
    ...  Get Cells list RF Split  TECHNO=${TECHNO}  CELLS_LIST=${CELLS_LIST_${TECHNO}_UE}
    ...  ELSE  Get Cells list  TECHNO=${${TECHNO}_TYPE}  CELLS_LIST=${CELLS_LIST_${TECHNO}_UE}
    Log  ${TECHNO} cells list: ${cells_list}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${TECHNO.lower()}_ues}  ${ue_list}
    Set Test Variable  ${cells_list_UE${ue_index}}  ${cells_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_${TECHNO}_UE}  cells_list=${cells_list}  techno=${TECHNO}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Step ${index}: Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    Log  Step ${index}: Perform Simultaneous call for both UEs  console=True
    Log  Attempting to reserve UEs to be handled by taf-ue library  console=True
    Set Test Variable  ${alias_UE1}  NR_UE_alias
    Set Test Variable  ${alias_UE2}  LTE_UE_alias
    Taf Ue Require Single UE  ue_alias=${alias_UE1}  capabilities=${NR_UE_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_UE2}  capabilities=${LTE_UE_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_UE1}, ${alias_UE2}  console=True
    Log  Attempting to attach UEs on expected cells  console=True
    Log  Attaching NR UE  console=True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_UE_CAPABILITIES}  False
    ${status}=  Run Keyword And Return Status  Taf Ue Attach Single UE  ue_alias=${alias_UE1}
    ...  expected_serving_cell_list=${cells_list_UE1}  call_type=data
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE1}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE1}  timeout=300
    ...  AND  Taf Ue Attach Single UE  ue_alias=${alias_UE1}
    ...  expected_serving_cell_list=${cells_list_UE1}  call_type=data
    Log  Succesfully Attached NR UE  console=True
    Log  Attaching LTE UE  console=True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${LTE_UE_CAPABILITIES}  False
    ${status}=  Run Keyword And Return Status  Taf Ue Attach Single UE  ue_alias=${alias_UE2}
    ...  expected_serving_cell_list=${cells_list_UE2}  call_type=data
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE2}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE2}  timeout=300
    ...  AND  Taf Ue Attach Single UE  ue_alias=${alias_UE2}
    ...  expected_serving_cell_list=${cells_list_UE2}  call_type=data
    Log  Succesfully Attached LTE UE  console=True
    Log  Succesfully attached both UEs on expected cells  console=True
    Run Keyword If  '${CHECK_ATTACH_ONLY}'== 'True'  Run Keywords
    ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
    ...  AND  Log  Detaching UEs  console=True
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    ...  AND  Log  Succesfully released usage of UEs  console=True
    ...  AND  Return From Keyword
    Log  Attempting start data call on NR UE  console=True
    Proceed to data transfer start on NR_UE
    Log  Succesfully started data call on NR UE  console=True
    Log  Attempting start data call on LTE UE  console=True
    Proceed to data transfer start on LTE_UE
    Log  Succesfully started data call on LTE UE  console=True
    Log  Wait for the call operations to end  console=True
    Log  Wait for the NR UE data call operation to end  console=True
    Await data call finish on NR_UE
    Log  Wait for the LTE UE data call operation to end  console=True
    Await data call finish on LTE_UE
    Log  Call operations ended succesfully for both UEs  console=True
    Log  Checking call results for both UEs  console=True
    Log  Checking call results for NR UE  console=True
    Stop and check data call on NR_UE
    Log  Checking call results for LTE UE  console=True
    Stop and check data call on LTE_UE
    Log  Checking call results for both UEs succesful!  console=True
    Run Keyword If  '${DETACH_UE}' == 'True'  Run Keywords
    ...  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    ...  AND  Log  Succesfully released usage of UEs  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Proceed to data transfer start on ${ue}
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION_${ue}}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_${ue}}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${CALL_DIRECTION}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    Run Keyword If  '${CALL_DIRECTION}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_${CALL_DIRECTION}
    ...  call_duration=${CALL_DURATION}  call_direction=${CALL_DIRECTION}  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${BANDWIDTH}  protocol=${PROTOCOL}

Await data call finish on ${ue}
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2
    Translate Call Direction  ${CALL_DIRECTION_${ue}}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_dl

Stop and check data call on ${ue}
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2
    Translate Call Direction  ${CALL_DIRECTION_${ue}}
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL_${ue}}
    ...  ${downlink_MIN_TPUT_${ue}}  ${downlink_MAX_TPUT_${ue}}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_dl
    ...  tput_min=${downlink_MIN_TPUT_${ue}}  tput_max=${downlink_MAX_TPUT_${ue}}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL_${ue}}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    ...  ${uplink_MIN_TPUT_${ue}}  ${uplink_MAX_TPUT_${ue}}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    ...  tput_min=${uplink_MIN_TPUT_${ue}}  tput_max=${uplink_MAX_TPUT_${ue}}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    Log  Stop and check data call for ${ue} finished succesfully!  console=True

Get Cells list RF Split
    [Arguments]   ${TECHNO}  ${CELLS_LIST}
    ${ue_index}=  Set Variable If  '${TECHNO}'=='NR'  1  '${TECHNO}'=='LTE'  2
    ${get_bts_cells_list}=  Set Variable If  '${CELLS_LIST}' == 'DEFAULT'  ${True}  ${False}
    ${CELLS_LIST}=  Run Keyword If  '${CELLS_LIST}' != 'DEFAULT'  Split String  ${CELLS_LIST}
    Run Keyword If  not ${get_bts_cells_list}  Return From Keyword  ${CELLS_LIST}
    ${SBTS_LTE_cell_ids}=  Get Ids For All  LNCEL  alias=${alias_local}
    ${SBTS_NR_cell_ids}=  Get Ids For All  NRCEL  alias=${alias_local}
    ${CELLS_LIST}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO}'=='NR' and not ${SBTS_NR_cell_ids}
    ...  Fail  TECHNO=${TEHNO} but no NR cells present in this RF Split Config!
    ...  ELSE IF  '${TECHNO}'=='NR'  Get NR Cell Ids from admin  ${alias_local}
    ...  ELSE  Set Variable  ${CELLS_LIST}
    ${CELLS_LIST}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO}'=='LTE' and not ${SBTS_LTE_cell_ids}
    ...  Fail  TECHNO=${TEHNO} but no LTE cells present in this RF Split Config!
    ...  ELSE IF  '${TECHNO}'=='LTE'  Get SBTS Cell Ids from admin  ${admin_alias}  ${TECHNO.upper()}
    ...  ELSE  Set Variable  ${CELLS_LIST}
    Set Test Variable  ${cells_list_UE${ue_index}}  ${CELLS_LIST}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${TECHNO.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_${TECHNO}_UE}  cells_list=${CELLS_LIST}  techno=${TECHNO}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}
    [Return]  ${CELLS_LIST}

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Particular teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
