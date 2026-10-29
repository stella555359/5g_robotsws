*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${SLAVE_TECHNO_UE2}    LTE               # Specified techno used for UE2; possible values: "LTE", "SBTS"
${NR_UE_CAPABILITIES}    None            # For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${LTE_UE_CAPABILITIES}    None           # For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${WCDMA_UE_CAPABILITIES}    None         # For WCDMA_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${GSM_UE_CAPABILITIES}    None           # For GSM_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CELLS_LIST_NR_UE}    DEFAULT           # Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
${CELLS_LIST_LTE_UE}    DEFAULT          # Specify the cells list on which LTE_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. LTE -  Eutran Cell Id is used.
${CELLS_LIST_WCDMA_UE}    DEFAULT        # Specify the cells list on which GSM_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. WCDMA -  Global Cell Id is used.
${CELLS_LIST_GSM_UE}    DEFAULT          # Specify the cells list on which GSM_UE will be chekced; Possible values: "DEFAULT" - means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. GSM -  Cell CI is used.
${CALL_DURATION}    100                  # Duration of data call for all UEs (in seconds);
${CALL_DIRECTION_NR_UE}    downlink      # Direction of data transfer call for NR_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_LTE_UE}    downlink     # Direction of data transfer call for LTE_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_WCDMA_UE}    downlink   # Direction of data transfer call for WCDMA_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_GSM_UE}    downlink     # Direction of data transfer call for GSM_UE; possible values: "downlink", "uplink" and "uplink_downlink"
${PROTOCOL_NR_UE}    udp                         # Data transfer protocol for NR_UE. e.q. udp, tcp, ftp
${PROTOCOL_LTE_UE}    udp                        # Data transfer protocol for LTE_UE. e.q. udp, tcp, ftp
${PROTOCOL_WCDMA_UE}    udp                      # Data transfer protocol for WCDMA_UE. e.q. udp, tcp, ftp
${PROTOCOL_GSM_UE}    udp                        # Data transfer protocol for GSM_UE. e.q. udp, tcp, ftp
${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec     # DL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec     # DL Minmum acceptable t-put for NR_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec        # UL Maximum acceptable t-put for NR_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec        # UL Minimum acceptable t-put for NR_UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec    # DL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec    # DL Minmum acceptable t-put for LTE_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec       # UL Maximum acceptable t-put for LTE_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec       # UL Minimum acceptable t-put for LTE_UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_WCDMA_UE}    150 Mbits/sec  # DL Maximum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_WCDMA_UE}    145 Kbits/sec  # DL Minmum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_WCDMA_UE}    50 Mbits/sec     # UL Maximum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_WCDMA_UE}    78 Kbits/sec     # UL Minimum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_GSM_UE}    150 Mbits/sec    # DL Maximum acceptable t-put for GSM_UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_GSM_UE}    145 Kbits/sec    # DL Minmum acceptable t-put for GSM_UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_GSM_UE}    50 Mbits/sec       # UL Maximum acceptable t-put for GSM_UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_GSM_UE}    78 Kbits/sec       # UL Minimum acceptable t-put for GSM_UE; acceptable values: e.q.  - 3 Mbits/sec;
${CHECK_NR_ATTACH}    None                    # Flag to check if attach was correctly performed on 5G; Possible values:
                                              # None (default) or ADB (check performed using
                                              # adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
                                              # primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
                                              # before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
                                              # RRC messages - QCAT license need to be activated
                                              # or AT(check performed using AT command AT+QENG="servingcell") - for Quectel UEs
                                              # or aashell - for checking NR attach from BTS based on resources usage
                                              # before test start, and Ue need to be disconnected from QXDM)
${BANDWIDTH}    60 Mbits/sec                  # max bandwidth for UDP in bits (used for all UEs); acceptable values: e.q.  - 60 Mbits/sec;
${SKIP_FAILING_UE}    False                   # Flag for skipping failing UEs. If set to True, will skip all UEs where at least an operation failed
                                              # from that point on. In the case of Attach operation or throughput operation, additional instant
                                              # BTS snapshot will be collected. Possible values: True, False. Default value: False
${DELAY_BETWEEN_SNAPSHOTS}    30              # In case of Snapshot collections during test (SKIP_FAILING_UE=True), defined as the delay time between
                                              # Snapshot collections measured in seconds. Default value: 30
${DETACH_UE}    False                         # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False
${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False  # Flag used to specify if cell Data Transfer Bandwith related parameters are read from Input Arguments
                                              # (False, default value) or from CELL_TARGET_BW file (True)

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25046
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing simultaneous NR NSA, LTE, WCDMA adn GSM data transfer calls on 4 UEs.
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
    ...  - WCDMA_UE_CAPABILITIES      ----  For WCDMA_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - GSM_UE_CAPABILITIES      ----  For GSM_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - CELLS_LIST_NR_UE         ----  Specify the cells list on which NR_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                  for NR - LTE Eutran cell ids of anchor cell is provided
    ...  - CELLS_LIST_LTE_UE        ----  Specify the cells list on which LTE_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                  for LTE - Eutran cell id is used
    ...  - CELLS_LIST_WCDMA_UE      ----  Specify the cells list on which WCDMA_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                  for WCDMA - Global Cell Id is used.
    ...  - CELLS_LIST_GSM_UE        ----  Specify the cells list on which LTE_UE will be chekced; Possible values: "DEFAULT" - means that UE is
    ...                                  checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                  for GSM - Cell CI is used
    ...  - CALL_DIRECTION_NR_UE     ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DIRECTION_LTE_UE    ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DIRECTION_WCDMA_UE   ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DIRECTION_GSM_UE    ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DURATION            ----  Duration of data call in seconds
    ...
    ...  - PROTOCOL_NR_UE           ----  Data transfer protocol for NR_UE. e.q. udp, tcp, ftp
    ...
    ...  - PROTOCOL_LTE_UE          ----  Data transfer protocol for LTE_UE. e.q. udp, tcp, ftp
    ...
    ...  - PROTOCOL_WCDMA_UE        ----  Data transfer protocol for WCDMA_UE. e.q. udp, tcp, ftp
    ...
    ...  - PROTOCOL_GSM_UE          ----  Data transfer protocol for GSM_UE. e.q. udp, tcp, ftp
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
    ...  - downlink_MAX_TPUT_WCDMA_UE ----  DL Maximum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_WCDMA_UE ----  DL Minmum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_WCDMA_UE   ----  UL Maximum acceptable t-put for WCDMA_UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_WCDMA_UE   ----  UL Maximum acceptable t-put for WCDMA_UE; acceptable values: e.q. - 3 Mbits/sec;
    ...
    ...  - downlink_MAX_TPUT_GSM_UE ----  DL Maximum acceptable t-put for GSM_UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_GSM_UE ----  DL Minmum acceptable t-put for GSM_UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_GSM_UE   ----  UL Maximum acceptable t-put for GSM_UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_GSM_UE   ----  UL Maximum acceptable t-put for GSM_UE; acceptable values: e.q. - 3 Mbits/sec;
    ...
    ...  - BANDWIDTH                ----  max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec
    ...
    ...  - CHECK_NR_ATTACH ----  Flag to check if attach was correctly performed on 5G; Possible values: None (default) or ADB (check performed using
    ...  adb commands-only applicable for CLASS: AndroidUe, for this check is mandatory to set primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...  before test!) or QCAT (check performed by analyzing RRC messages- check performed by analyzing RRC messages- QCAT license need to be
    ...  activated or AT(check performed using AT command AT+QENG="servingcell") - for Quectel UEs or aashell - for checking NR attach from BTS
    ...  based on resources usage;
    ...  before test start, and Ue need to be disconnected from QXDM)
    ...
    ...  - SKIP_FAILING_UE             ---- Flag for skipping failing UEs. If set to True, will skip all UEs that had at least an operation failed
    ...                                     from that point on. In the case of Attach operation or Throughput operations, additional instant
    ...                                     BTS snapshot will be collected. Possible values: True, False. Default value: False
    ...
    ...  - DELAY_BETWEEN_SNAPSHOTS     ---- In case of Snapshot collections during test (SKIP_FAILING_UE=True), defined as the delay time between
    ...                                     Snapshot collections measured in seconds. Default value: 30
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UEs after the test execution; Possible values: True/False. Default value: False
    ...
    ...  - IMPORT_CELL_TARGET_BW_FROM_CONFIG  ---- Flag used to specify if cell Data Transfer Bandwith related parameters are read from
    ...                                            Input Arguments. (False, default value) or from CELL_TARGET_BW file (True)
    ...
    ...  Test scenario:
    ...
    ...  -    UE is attached to the cell under test on NR technology BTS. 2nd UE is attached on LTE BTS technology; 3rd UE is attached on WCDMA BTS
    ...  technology; 4th UE is attached on GSM BTS technology
    ...  -    UEs successfully attached to the cell under test on NR/LTE/WCDMA/GSM technology BTSs.
    ...  -    UDP Data transfer is started on all UEs
    ...  -    When data transfer is established, throughput is measured for at least 5min to be as expected.
    ...  -    Data transfer is successfully started and throughput levels are acceptable
    ...  -    Data transfer is disconnected. All services are terminated and UE is detached.
    ...  -    Disconnection is successful and resources are released correctly
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25046 - TC Creation
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25609 - [5G][Refactoring][CNI-85214] LNRELGNBCELL_R object refactoring -
    ...  RRM_RFS_NR_LTE_Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 10.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26441 - Update packet size for start data transfer
    ...  - 26.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26725 - [Calls] Add aashell check option for
    ...  RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue.robot
    ...  - 14.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26905 - [Calls] [RF Split]
    ...  RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue must be redesigned to allow for less that 4 calls if tech not preset on
    ...  BTs - after TAT-26725
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27095 - [Calls] [Parameters per cell] [RF Split]
    ...  RRM__RFS__Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue must be redesigned to allow to set personalized bandwidth and tput
    ...  thresholds at cell level
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 05.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27331 - adjustment for FAILED case when call is performed on multiple UEs
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases - NRL, NR_NR, NR_SBTS, RRM,
    ...  PM, LOGS
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25046_RRM__RFS__NR_LTE_Simultaneous_NR_NSA_LTE_WCDMA_GSM_Data_Transfer_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-raluca-elena.butcovan@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-CR1
    ...    SBTS23R3    CABLING-RFS_01_UE

    TC Parameter Check
    Step 1: Get Cells List of LTE WCDMA AND GSM UE
    Step 2: Get LTE Anchor Cells List and NR Cells Mapping
    Step 3: Perform Simultaneous call for all UEs
    Step 4: Check final number and state of Cells and RMs
    Check Test Verdict

    [Teardown]  Particular Teardown

TC Parameter Check
    Log  TC Parameter Check  console=True

    ${CELL_TARGET_BW_exists}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_TARGET_BW}
    Run Keyword If  not ${CELL_TARGET_BW_exists} and '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True'
    ...  Fail  IMPORT_CELL_TARGET_BW_FROM_CONFIG is set to True but CELL_TARGET_BW is not found!
    Run Keyword If  '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True' and '${NR_UE_CAPABILITIES}'!='None' and '${CHECK_NR_ATTACH}'=='None'
    ...  Fail  If using CELL_TARGET_BW feature with NR call CHECK_NR_ATTACH cannot be None!

Step ${index}: Get Cells List of LTE WCDMA AND GSM UE
    Log  Step ${index}: Get Cells List of LTE WCDMA AND GSM UE  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Run Keyword If  ${BTS_nb}==1  Run Keywords
    ...  Get LTE Cells List for RF Split
    ...  AND  Get WCDMA Cells List for RF Split
    ...  AND  Get GSM Cells List for RF Split
    ...  AND  Return From Keyword
    ...  ELSE  Fail  TC Only compatible with RF Split Config!

Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping
    Log  Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Run Keyword If  ${BTS_nb}==1  Get Cells List for RF Split
    ...  ELSE  Fail  TC Only compatible with RF Split Config!
    ${NRCellid_PCI}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRCellid_PCI}
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=Master
        Set To Dictionary  ${NRCellid_PCI}  ${NR_cell_params.nrCellIdentity}  ${NR_cell_params.physCellId}
    END
    ${NRpci_lteCellId}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRpci_lteCellId}
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    ${all_nr_pci_list}=  Create List  @{EMPTY}
    Set Test Variable  ${all_nr_pci_list}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Create lteCell Id NR pci  ${lte_anchor}
    END
    ${all_nr_pci_list}=  Remove Duplicates  ${all_nr_pci_list}
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
    ${timeout}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=data  call_direction=${CALL_DIRECTION_NR_UE}
    ...  cells_list=${cells_list_UE1}  techno=LTE  attenuator=NO
    Set Test Variable  ${timeout}

Step ${index}: Perform Simultaneous call for all UEs
    [Timeout]  ${timeout}
    Log  Step ${index}: Perform Simultaneous call for all UEs  console=True
    ${index_to_techno_dict}=  Create Dictionary  1=NR  2=LTE  3=WCDMA  4=GSM
    ${ue_indexes_temp}=  Create List  1  2  3  4
    ${ue_indexes}=  Create List
    ${skipped_ues}=  Create List
    Set Test Variable  ${skipped_ues}
    FOR  ${ue_index}  IN  @{ue_indexes_temp}
        ${techno}=   Get From Dictionary  ${index_to_techno_dict}  ${ue_index}
        Run Keyword If  '${${techno.upper()}_UE_CAPABILITIES}' != 'None'  Append To List  ${ue_indexes}  ${ue_index}
    END
    FOR  ${ue_index}  IN  @{ue_indexes}
        Set Test Variable  ${alias_UE${ue_index}}  ${index_to_techno_dict["${ue_index}"]}_UE_alias
    END
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    FOR  ${ue_index}  IN  @{ue_indexes}
        ${status}=  Run Keyword And Return Status  Taf Ue Require Single UE  ue_alias=${alias_UE${ue_index}}
        ...  capabilities=${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}  timeout=180
        Run Keyword If  '${status}'=='True'
        ...  Log Long String  Succesfully required UE capability ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} and assigned alias
        ...  ${alias_UE${ue_index}}  console=True
        Run Keyword If  '${status}'=='False' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to Require UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES},
        ...  this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}
        Run Keyword If  '${status}'=='False' and "${SKIP_FAILING_UE}"!="True"
        ...  Fail  Failed to require UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}!
    END
    Log  Attempting to attach UEs on expected cells  console=True
    ${cell_call_IDs_mapping}=  Create Dictionary
    FOR  ${ue_index}  IN  @{ue_indexes}
        Run Keyword If  '${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} will be skipped!  console=True
        ...  AND  Continue For Loop
        Log  Attaching ${index_to_techno_dict["${ue_index}"]} UE  console=True
        ${status}=  Run Keyword If  '${index_to_techno_dict["${ue_index}"]}' == 'NR'   Run Keyword And Return Status  Perform NR Attach
        ...  ELSE  Run Keyword And Return Status
        ...  Perform non NR attach  ue_alias=${alias_UE${ue_index}}  expected_serving_cell_list=${cells_list_UE${ue_index}}  call_type=data
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully Attached ${index_to_techno_dict["${ue_index}"]} UE  console=True
        ...  ELSE IF  '${status}'!='True' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to Attach UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}, this UE
        ...  will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}
        ...  AND  Mid Test Snapshot collection  ${alias_local}  Attach_Failed
        ...  ELSE  Fail  Failed to attach UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}!
        Run Keyword If  '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='False'  Continue For Loop
        ${cell_call_succesful}=  Set Variable If  '${index_to_techno_dict["${ue_index}"]}' == 'NR'  ${nr_cell_call_succesful}  ${actual_cell_id}
        Set To Dictionary  ${cell_call_IDs_mapping}  UE_${ue_index}=${cell_call_succesful}
    END
    Set Test Variable  ${cell_call_IDs_mapping}
    Log  Succesfully attached all UEs on expected cells  console=True
    FOR  ${ue_index}  IN  @{ue_indexes}
        Run Keyword If  '${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${ue}=  Get From Dictionary   ${index_to_techno_dict}  ${ue_index}
        Log  Attempting start data call on ${ue}_UE  console=True
        ${status}=  Run Keyword And Return Status  Proceed to data transfer start on ${ue}_UE
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully started data call on ${ue}_UE  console=True
        ...  ELSE IF  '${status}'!='True' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to start data transfer for UE
        ...  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}, this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}
        ...  ELSE  Fail  Failed to start data transfer for UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}!
    END
    Log  Wait for the call operations to end  console=True
    FOR  ${ue_index}  IN  @{ue_indexes}
        Run Keyword If  '${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${ue}=  Get From Dictionary   ${index_to_techno_dict}  ${ue_index}
        Log  Wait for the ${ue}_UE data call operation to end  console=True
        ${status}=  Run Keyword And Return Status  Await data call finish on ${ue}_UE
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully ended data transfer on ${ue}_UE  console=True
        ...  ELSE IF  '${status}'!='True' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and failed to end data transfer for UE
        ...  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}, this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}
        ...  ELSE  Fail  Failed to start data transfer for UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}!
    END
    Log  Call operations ended succesfully for all UEs  console=True
    Log  Checking call results for all UEs  console=True
    FOR  ${ue_index}  IN  @{ue_indexes}
        Run Keyword If  '${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} will be skipped!  console=True
        ...  AND  Continue For Loop
        ${ue}=  Get From Dictionary   ${index_to_techno_dict}  ${ue_index}
        Log  Checking call results for ${ue}_UE  console=True
        ${status}=  Run Keyword And Return Status  Stop and check data call on ${ue}_UE
        Run Keyword If  '${status}'=='True'
        ...  Log  Succesfully checked data transfer results on ${ue}_UE  console=True
        ...  ELSE IF  '${status}'!='True' and ${SKIP_FAILING_UE}  Run Keywords
        ...  Log Long String  Since SKIP_FAILING_UE=True and check data transfer failed on UE
        ...  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}, this UE will be skipped for the rest of the test
        ...  AND  Append To List  ${skipped_ues}  ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}
        ...  AND  Mid Test Snapshot collection  ${alias_local}  Throughput_check_failed
        ...  ELSE  Fail  Check data transfer failed for UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}!
    END
    Log  Checking call results for all UEs succesful!  console=True
    Log  Detaching UEs if needed  console=True
    FOR  ${ue_index}  IN  @{ue_indexes}
        Run Keyword If  '${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES}' in ${skipped_ues}
        ...  Run Keywords
        ...  Log  UE ${${index_to_techno_dict["${ue_index}"]}_UE_CAPABILITIES} will be skipped!  console=True
        ...  AND  Continue For Loop
        Run Keyword If  '${DETACH_UE}' == 'False'  Continue For Loop
        Taf Ue Detach Single UE  ue_alias=${alias_UE${ue_index}}
        Log  Succesfully released usage of UE: ${alias_UE${ue_index}}  console=True
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Proceed to data transfer start on ${ue}
    ${techno}=  Set Variable If  '${ue}'=='NR_UE'  NR  '${ue}'=='LTE_UE'  LTE  '${ue}'=='WCDMA_UE'  WCDMA  '${ue}'=='GSM_UE'  GSM
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2  '${ue}'=='WCDMA_UE'  3  '${ue}'=='GSM_UE'  4
    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}=  Run Keyword And Return Status  Variable Should Exist  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}
    Set Test Variable  ${current_cell_bw_target_from_config}  False
    Run Keyword If  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}
    ...  Run Keyword If  '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True'
    ...  Set Test Variable  ${current_cell_bw_target_from_config}  True
    Run Keyword If  ${current_cell_bw_target_from_config}  Extract current cell target BW based on cell ID
    ...  ${cell_call_IDs_mapping["UE_${ue_index}"]}  ${techno}
    ${bw}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["Target_Bandwidth"]}
    ...  ELSE  Set Variable  ${BANDWIDTH}
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2  '${ue}'=='WCDMA_UE'  3  '${ue}'=='GSM_UE'  4
    ${packet_size}=  Set Variable If  '${ue}'=='NR_UE'  1400  '${ue}'=='LTE_UE'  1400  '${ue}'=='WCDMA_UE'  1200  '${ue}'=='GSM_UE'  1200
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION_${ue}}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_${ue}}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${CALL_DIRECTION}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    Run Keyword If  '${CALL_DIRECTION}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_${CALL_DIRECTION}
    ...  call_duration=${CALL_DURATION}  call_direction=${CALL_DIRECTION}  throughput=${bw}  protocol=${PROTOCOL}  packet_size=${packet_size}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${bw}  protocol=${PROTOCOL}  packet_size=${packet_size}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${bw}  protocol=${PROTOCOL}  packet_size=${packet_size}

Await data call finish on ${ue}
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2  '${ue}'=='WCDMA_UE'  3  '${ue}'=='GSM_UE'  4
    Translate Call Direction  ${CALL_DIRECTION_${ue}}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_dl

Stop and check data call on ${ue}
    ${techno}=  Set Variable If  '${ue}'=='NR_UE'  NR  '${ue}'=='LTE_UE'  LTE  '${ue}'=='WCDMA_UE'  WCDMA  '${ue}'=='GSM_UE'  GSM
    ${ue_index}=  Set Variable If  '${ue}'=='NR_UE'  1  '${ue}'=='LTE_UE'  2  '${ue}'=='WCDMA_UE'  3  '${ue}'=='GSM_UE'  4
    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}=  Run Keyword And Return Status  Variable Should Exist  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}
    Run Keyword If  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}
    ...  Run Keyword If  '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True'
    ...  Set Test Variable  ${current_cell_bw_target_from_config}  True
    Run Keyword If  ${current_cell_bw_target_from_config}  Extract current cell target BW based on cell ID
    ...  ${cell_call_IDs_mapping["UE_${ue_index}"]}  ${techno}
    ${downlink_MIN_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["DL_min"]}
    ...  ELSE  Set Variable  ${downlink_MIN_TPUT_${ue}}
    ${downlink_MAX_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["DL_max"]}
    ...  ELSE  Set Variable  ${downlink_MAX_TPUT_${ue}}
    ${uplink_MIN_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["UL_min"]}
    ...  ELSE  Set Variable  ${uplink_MIN_TPUT_${ue}}
    ${uplink_MAX_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["UL_max"]}
    ...  ELSE  Set Variable  ${uplink_MAX_TPUT_${ue}}

    Translate Call Direction  ${CALL_DIRECTION_${ue}}
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL_${ue}}
    ...  ${downlink_MIN_TPUT}  ${downlink_MAX_TPUT}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_dl
    ...  tput_min=${downlink_MIN_TPUT}  tput_max=${downlink_MAX_TPUT}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL_${ue}}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    ...  ${uplink_MIN_TPUT}  ${uplink_MAX_TPUT}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    ...  tput_min=${uplink_MIN_TPUT}  tput_max=${uplink_MAX_TPUT}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    Log  Stop and check data call for ${ue} finished succesfully!  console=True

Perform NR Attach
    ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
    ${mbn_profile_used}=  Set Variable if  '${mbn_profile}' == 'None'  False  True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_UE_CAPABILITIES}  ${mbn_profile_used}
    Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
    Run Keyword If  '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
    ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}
    ...  timeout=30
    ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was acquired!  console=True
    ${status1}=  Run Keyword And Return Status  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}
    ...  ue_info=${ue_info}  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_nr_pci_list}  alias_nr=${alias_local}
    Run Keyword If  '${status1}' == 'False' and '${check_nr_attach}' != 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE1}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}
    ...  ${ue_info[5]}  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}  ue_info=${ue_info}
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_nr_pci_list}  alias_nr=${alias_local}
    ...  ELSE IF  '${status1}' == 'False' and '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE1}  timeout=300
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${cells_list_UE1}  ue_info=${ue_info}  second_run=True
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_nr_pci_list}  alias_nr=${alias_local}

Perform non NR attach
    [Arguments]  ${ue_alias}  ${expected_serving_cell_list}  ${call_type}
    ${actual_ue_ip_tmp}  ${actual_cell_id_tmp}=
    ...  Taf Ue Attach Single UE  ue_alias=${ue_alias}  expected_serving_cell_list=${expected_serving_cell_list}  call_type=${call_type}
    Set Test Variable  ${actual_cell_id}  ${actual_cell_id_tmp}

Create lteCell Id NR pci
    [Arguments]  ${lte_anchor}
    ${current_nr_pci_list}=  Create List  @{EMPTY}
    FOR  ${nr_id}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping[${lte_anchor}]}
        Append To List  ${current_nr_pci_list}  ${NRCellid_PCI[${nr_id}]}
        Append To List  ${all_nr_pci_list}  ${NRCellid_PCI[${nr_id}]}
    END
    Set To Dictionary  ${NRpci_lteCellId}  ${lte_anchor}  ${current_nr_pci_list}
    Set Test Variable  ${current_nr_pci_list}

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

Get ${techno} Cells List for RF Split
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${techno.upper()}' in ['LTE', 'WCDMA']
    ...  Get SBTS Cell Ids from admin  ${alias_local}  ${techno}
    ${cells_list}=  Run Keyword If  '${techno.upper()}'=='GSM'  Get Cell Ids for GSM  ${alias_local}
    Log  ${techno} cells list: ${cells_list}  console=True
    Run Keyword If  '${techno.upper()}' == 'LTE'
    ...  Set Test Variable  ${cells_list_UE2}  ${cells_list}
    ...  ELSE IF  '${techno.upper()}' == 'WCDMA'
    ...  Set Test Variable  ${cells_list_UE3}  ${cells_list}
    ...  ELSE IF  '${techno.upper()}' == 'GSM'
    ...  Set Test Variable  ${cells_list_UE4}  ${cells_list}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${SLAVE_TECHNO_UE2.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_${techno}_UE}  cells_list=${cells_list}  techno=${SLAVE_TECHNO_UE2}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Get Cell Ids for GSM
    [Arguments]  ${alias}
    Open connection to BSC
    ${BCF_ID}=  Get From Dictionary  ${${alias.upper()}}  BCF_ID
    ${cells_id_list}=  hran_bsc.get gsm cells ids  ${BCF_ID}
    [Return]  ${cells_id_list}
    [Teardown]  hran_bsc.Close Connection

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Mid Test Snapshot collection
    [Arguments]  ${alias}  ${reason}
    Log  Mid Test Snapshot collection for ${reason} problem found on BTS ${alias}  console=True
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    ${path}=  Set Variable  ${Test Results Dir}/Snapshot
    Log  Snapshot file collection on BTS ${alias} started  console=True
    ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM  ${alias}  ${path}/${timestamp}_BTS_${alias}_${reason}
    Log  Snapshot file collected: ${folder_path}/${Snapshot_filename}  console=True
    Log  Wait static time of ${DELAY_BETWEEN_SNAPSHOTS} seconds between Snapshot collections  console=True
    Sleep  ${DELAY_BETWEEN_SNAPSHOTS}s

Check Test Verdict
    ${number_of_skipped_UEs}=  Get Length  ${skipped_ues}
    Run Keyword If  ${number_of_skipped_UEs}!=0
    ...  Fail  At least one UE was skipped due to at least one failed operation during test execution!

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