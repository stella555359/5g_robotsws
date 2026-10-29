*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${SLAVE_TECHNO_UE2}    LTE               # Specified techno used for UE2; possible values: "LTE", "SBTS_LTE" (if not only LTE RAT on BTS2)
${NR_UE_CAPABILITIES}    None            # For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${LTE_UE_CAPABILITIES}    None           # For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CELLS_LIST_NR_UE}    DEFAULT           # Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
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
${CHECK_NR_ATTACH}    None                    # Flag to check if attach was correctly performed on 5G; Possible values:
                                              # None (default) or ADB (check performed using
                                              # adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
                                              # primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
                                              # before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
                                              # RRC messages - QCAT license need to be activated or AT
                                              # (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
                                              # or aashell - for checking NR attach from BTS based on resources usage
                                              # before test start, and Ue need to be disconnected from QXDM)
${BANDWIDTH}    60 Mbits/sec                  # max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
${DETACH_UE}    False                         # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False
${CHECK_ATTACH_ONLY}    False                  # Flag for skipping data transfer part and perform check of attach only;
                                              # Possible values:True/False. Default value: False

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25045
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing simultaneous NR NSA and LTE data transfer calls on 2 UEs.
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...
    ...  - SLAVE_TECHNO_UE2         ----  Specified techno used for UE2; possible values: "LTE", "SBTS_LTE", "SBTS_WCDMA", "SBTS_GSM"
    ...
    ...  - NR_UE_CAPABILITIES       ----  For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - LTE_UE_CAPABILITIES      ----  For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - CELLS_LIST_NR_UE         ----  Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                  for NR - LTE Eutran cell ids of anchor cell is provided
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
    ...  - CHECK_NR_ATTACH ----  Flag to check if attach was correctly performed on 5G; Possible values: None (default) or ADB (check performed using
    ...  adb commands-only applicable for CLASS: AndroidUe, for this check is mandatory to set primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...  before test!) or QCAT (check performed by analyzing RRC messages- check performed by analyzing RRC messages- QCAT license need to be
    ...  activated before test start, and Ue need to be disconnected from QXDM) or AT (check performed using AT command AT+QENG="servingcell")
    ...  for Quectel UEs or aashell - for checking NR attach from BTS based on resources usage
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UEs after the test execution; Possible values: True/False. Default value: False
    ...  - CHECK_ATTACH_ONLY  ----  Flag for skipping data transfer part and perform check of attach only;
    ...                             Possible values: True/False. Default value: False
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
    ...  - 09.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25045 - RRM__RFS__NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue -TC delivery
    ...  - 18.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25607 -
    ...  [5G][Refactoring][CNI-85214] LNRELGNBCELL_R object refactoring - RRM_RFS_NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26313 - [Calls][P1]Check attach only option
    ...  RRM__RFS__NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26605 - [Calls] Adapt Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26606 - [Calls] Remove Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 25.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26724 - [Calls] Add aashell check option for
    ...  RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.robot
    ...  - 17.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27309 - NR call was not verified on aashell for NR cells
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27532 - bug after Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27537 - Test adaptation following common test setup variable removal
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25045_RRM__RFS__NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-daniel.barbu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-CR1
    ...    SBTS23R3    CABLING-RFS_01_UE

    Step 1: Get Cells List of LTE UE
    Step 2: Get LTE Anchor Cells List and NR Cells Mapping
    Step 3: Perform Simultaneous call for both UEs
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Get Cells List of LTE UE
    Log  Step ${index}: Get Cells List of LTE UE  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Run Keyword If  ${BTS_nb}==1  Run Keywords
    ...  Get LTE Cells List of LTE UE for RF Split
    ...  AND  Return From Keyword
    ${cells_list}=  Get Cells list  TECHNO=${SLAVE_TECHNO_UE2}  CELLS_LIST=${CELLS_LIST_LTE_UE}
    Log  ${SLAVE_TECHNO_UE2} cells list: ${cells_list}  console=True
    Set Test Variable  ${cells_list_UE2}  ${cells_list}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${SLAVE_TECHNO_UE2.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_LTE_UE}  cells_list=${cells_list}  techno=${SLAVE_TECHNO_UE2}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping
    Log  Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Run Keyword If  ${BTS_nb}==1  Get Cells List for RF Split
    ...  ELSE  Get Cells List for RF Sharing
    ${NRCellid_PCI}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRCellid_PCI}
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=Master
        Set To Dictionary  ${NRCellid_PCI}  ${NR_cell_params.nrCellIdentity}  ${NR_cell_params.physCellId}
    END
    ${NRpci_lteCellId}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRpci_lteCellId}
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    ${all_expected_NR_PCI_list}=  Create List
    Set Test Variable  ${all_expected_NR_PCI_list}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Create lteCell Id NR pci  ${lte_anchor}
    END
    Log  Mapping LTE anchor cell - NR cell: ${LTE_Anchor_Cell_NR_Cell_mapping}  console=True
    Log  Mapping LTE anchor cell - PCI of NR Cell: ${NRpci_lteCellId}  console=True
    ${cells_list_tmp}=  Create List  @{EMPTY}
    Log  Omitting non-anchor LTE cells from cells list  console=True
    FOR  ${cell}  IN  @{cells_list_UE1}
        Run Keyword If  ${cell} in ${LTE_Anchor_Cell_NR_Cell_mapping_keys}  Append To List  ${cells_list_tmp}  ${cell}
    END
    Set Test Variable  ${cells_list_UE1}  ${cells_list_tmp}
    ${cells_list_len}=  Get Length  ${cells_list_UE1}
    Run Keyword If  '${cells_list_len}' == '0'
    ...  Fail  No anchor cells among cell list eligible for NR LTE NSA call!
    ...  ELSE  Log  List of anchor cells eligible for NR LTE NSA call is: ${cells_list_UE1}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${lte_ues}  ${ue_list}
    ${timeout}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data  call_direction=${CALL_DIRECTION_NR_UE}
    ...  cells_list=${cells_list_UE1}  techno=LTE  attenuator=NO
    Set Test Variable  ${timeout}

Step ${index}: Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    Log  Step ${index}: Perform Simultaneous call for both UEs  console=True
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    Set Test Variable  ${alias_UE1}  NR_UE_alias
    Set Test Variable  ${alias_UE2}  LTE_UE_alias
    Taf Ue Require Single UE  ue_alias=${alias_UE1}  capabilities=${NR_UE_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_UE2}  capabilities=${LTE_UE_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_UE1}, ${alias_UE2}  console=True
    Log  Attempting to attach UEs on expected cells  console=True
    Log  Attaching NR UE  console=True
    Perform NR Attach
    Log  Succesfully Attached NR UE  console=True
    Log  Attaching LTE UE  console=True
    Taf Ue Attach Single UE  ue_alias=${alias_UE2}  expected_serving_cell_list=${cells_list_UE2}  call_type=data
    Log  Succesfully Attached LTE UE  console=True
    Log  Succesfully attached both UEs on expected cells  console=True

    Run Keyword If  '${CHECK_ATTACH_ONLY}' == 'True'
    ...  Log  Data transfer part will be skipped due to CHECK_ATTACH_ONLY flag set to True!  console=True
    ...  ELSE  Start Simultaneous call for both UEs

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

Start Simultaneous call for both UEs
    Log  Attempting start data call on NR UE  console=True
    Proceed to data transfer start on NR_UE
    Log  Successfully started data call on NR UE  console=True
    Log  Attempting start data call on LTE UE  console=True
    Proceed to data transfer start on LTE_UE
    Log  Successfully started data call on LTE UE  console=True
    Log  Wait for the call operations to end  console=True
    Log  Wait for the NR UE data call operation to end  console=True
    Await data call finish on NR_UE
    Log  Wait for the LTE UE data call operation to end  console=True
    Await data call finish on LTE_UE
    Log  Call operations ended successfully for both UEs  console=True
    Log  Checking call results for both UEs  console=True
    Log  Checking call results for NR UE  console=True
    Stop and check data call on NR_UE
    Log  Checking call results for LTE UE  console=True
    Stop and check data call on LTE_UE
    Log  Checking call results for both UEs successful!  console=True

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

Perform NR Attach
    ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
    ${mbn_profile_used}=  Set Variable if  '${mbn_profile}' == 'None'  False  True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_UE_CAPABILITIES}  ${mbn_profile_used}
    Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
    Run Keyword If  '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
    ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}
    ...  timeout=30
    ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was acquired!  console=True
    ${status1}=  Run Keyword And Return Status  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}
    ...  ue_info=${ue_info}  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_expected_NR_PCI_list}  alias_nr=Master
    Run Keyword If  '${status1}' == 'False' and '${check_nr_attach}' != 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE1}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}  ue_info=${ue_info}
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_expected_NR_PCI_list}  alias_nr=Master
    ...  ELSE IF  '${status1}' == 'False' and '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE1}  timeout=300
    ...  AND  Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}  ue_info=${ue_info}  second_run=True
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_expected_NR_PCI_list}  alias_nr=Master

Create lteCell Id NR pci
    [Arguments]  ${lte_anchor}
    ${current_nr_pci_list}=  Create List  @{EMPTY}
    FOR  ${nr_id}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping[${lte_anchor}]}
        Append To List  ${current_nr_pci_list}  ${NRCellid_PCI[${nr_id}]}
        Run Keyword If  "${lte_anchor}" in ${cells_list_UE1}
        ...  Append To List  ${all_expected_NR_PCI_list}  ${NRCellid_PCI[${nr_id}]}
    END
    Set To Dictionary  ${NRpci_lteCellId}  ${lte_anchor}  ${current_nr_pci_list}
    Set Test Variable  ${current_nr_pci_list}

Get Cells List for RF Sharing
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=Master
    Set Test Variable  ${nr_cell_list}
    ${cells_list_UE1}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}' == 'LTE'
    ...  Get Cells list  TECHNO=LTE  CELLS_LIST=${CELLS_LIST_NR_UE}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'SBTS'  Get Cells list  TECHNO=SBTS_LTE  CELLS_LIST=${CELLS_LIST_NR_UE}
    Set Test Variable  ${cells_list_UE1}
    ${LTE_cell_ids}=  Get Ids For All  class_name=LNCEL  connection=Slave
    ${LTE_cell_ids_tmp}=  Set Variable If  '${SLAVE['SLAVE_TECH']}' == 'LTE'  ${LTE_cell_ids}  '${SLAVE['SLAVE_TECH']}' == 'SBTS'
    ...  ${SBTS_LTE_cell_ids}
    Set Test Variable  ${LTE_cell_ids}  ${LTE_cell_ids_tmp}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_cell_ids}  Slave
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get Cells List for RF Split
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=${alias_local}
    ${SBTS_LTE_cell_ids}=  Get Ids For All  LNCEL  alias=${alias_local}
    Set Test Variable  ${nr_cell_list}
    ${cells_list_UE1}  ${temp_cell_id_internal_id_mapping}=  Get SBTS Cell Ids from admin  ${alias_local}  LTE
    ${cell_count}=  Get Length  ${cells_list_UE1}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No LTE cells are found on BTS!  level=ERROR
    ...  AND  Fail  No LTE cells are found on BTS!
    Sort list  ${cells_list_UE1}
    Set Test Variable  ${cells_list_UE1}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${SBTS_LTE_cell_ids}  ${alias_local}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get LTE Cells List of LTE UE for RF Split
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Get SBTS Cell Ids from admin  ${alias_local}  LTE
    Log  LTE cells list: ${cells_list}  console=True
    Set Test Variable  ${cells_list_UE2}  ${cells_list}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${SLAVE_TECHNO_UE2.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_LTE_UE}  cells_list=${cells_list}  techno=${SLAVE_TECHNO_UE2}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Particular teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs
    Run Keyword If  '${CHECK_NR_ATTACH}' == 'QCAT'  Run Keywords
    ...  Taf Ue Release QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was released!  console=True
    ...  AND  Taf Ue License Keeper Teardown

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
