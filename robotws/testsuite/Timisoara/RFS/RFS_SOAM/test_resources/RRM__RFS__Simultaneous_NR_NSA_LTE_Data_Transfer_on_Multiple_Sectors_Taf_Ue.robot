*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}    None  # for LTE paired with NR; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin;
                                         # Default value: None; if set different than None, external anchor cell mechanism will be used
${SLAVE_TECHNO_UE2}    LTE               # Specified techno used for UE2; possible values: "LTE" or "SBTS_LTE" (if multiple RATs configured on BTS2)
${NR_UE_CAPABILITIES}    None            # For NR_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${LTE_UE_CAPABILITIES}    None           # For LTE_UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CELLS_LIST_NR_UE}    DEFAULT           # Specify the NR cells list (NR PCIs) on which NR_UE will be chekced; Possible values: "DEFAULT" -
                                         # means all cells belonging to NR; "30295 30294 30293" - User provides cells list with space between Cells Id
${CELLS_LIST_LTE_UE}    ANY              # Specify the cells list on which LTE_UE will be checked; Possible values:
                                         # - "DEFAULT" - means all LTE cells belonging to BTS
                                         # - "30295 30294 30293" - User provides cells list with space between Cells Id. LTE Eutran Cell Id is used.
                                         # - "ANY" (default value) - for each NR cell, any LTE cell from same sector call will be covered at least
                                         # once with call
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
${CHECK_NR_ATTACH}    None                    # Flag to check if attach was correctly performed on 5G; Possible values:
                                              # None (default)/ ADB (check performed using
                                              # adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
                                              # primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
                                              # before test!)/QCAT (check performed by analyzing RRC messages - check performed by analyzing
                                              # RRC messages - QCAT license need to be activated/AT
                                              # (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
                                              # before test start, and Ue need to be disconnected from QXDM)
                                              # /aashell - for checking NR attach from BTS based on resources usage
${DETACH_UE}    False                         # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False
${CHECK_ATTACH_ONLY}    False                  # Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
                                              # Default value: False

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25044
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing simultaneous NR NSA and LTE data transfer calls on 2 UEs on multiple sectors.
    ...  Will perform call on all NR cells sent as input argument using attenuator and simultaniously on all LTE cells mapped on the same sectors
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...
    ...  - BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE  ---- for LTE paired with NR; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin
    ...                                            Default value: None; if set different than None, external anchor cell mechanism will be used
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
    ...  - CELLS_LIST_LTE_UE        ----  Specify the cells list on which LTE_UE will be checked; Possible values:
    ...                                  "DEFAULT" - means all LTE cells belonging to BTS
    ...                                  "30295 30294 30293" - User provides cells list with space between Cells Id. LTE Eutran Cell Id is used.
    ...                                  "ANY" (default value) - for each NR cell, any LTE cell from same sector call will be covered at least
    ...                                  once with call
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
    ...  - CHECK_NR_ATTACH ----  Flag to check if attach was correctly performed on 5G; Possible values: None (default)/ADB (check performed using
    ...  adb commands-only applicable for CLASS: AndroidUe, for this check is mandatory to set primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...  before test!)/QCAT (check performed by analyzing RRC messages- check performed by analyzing RRC messages- QCAT license need to be activated
    ...  before test start, and Ue need to be disconnected from QXDM)/AT (check performed using AT command AT+QENG="servingcell")
    ...  for Quectel UEs/aashell - for checking NR attach from BTS based on resources usage
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
    ...  -    Repeat this steps for all sectors
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25044 - Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue call for multiple sectors
    ...  - 30.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26047 - [Calls] In 2 TCs Set Cell Attenuation is called with NR PCI instead of
    ...  nrCellIdentity
    ...  - 08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26075 - Wrong argument for LTE cells list on NSA multiple sector call
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25608 - [5G][Refactoring][CNI-85214] LNRELGNBCELL_R object refactoring -
    ...  RRM_RFS_NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26391 - [Calls] Implement stop data transfer after first sector call for
    ...  Multiple_Sectors_Taf_Ue automated call
    ...  - 13.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26311 - Add attach only option, collateral corrections - SLAVE_TECHNO_UE2 argument
    ...  - 22.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26312 - [Calls][P1]Check attach only option
    ...  - 16.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26605 - [Calls] Adapt Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26606 - [Calls] Remove Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26776 - [Calls] Automation test
    ...  "RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue" option for Admin on external Anchor BTS
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26999 - Data Transfer on Multiple Cells per Sector for LTE
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 25.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27303 -
    ...  [Calls] Adapt RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue for configuration SBTS ? RF Split
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27687 - [Calls] Make call tests independent of Particular Setup
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25044_RRM__RFS__NR_LTE_Simultaneous_NR_NSA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-daniel.barbu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-CR1
    ...    SBTS23R3    CABLING-RFS_01_UE

    Prepare External Admin Sessions
    Step 1: Get Cells List of LTE UE
    Step 2: Get LTE Anchor Cells List and NR Cells Mapping
    Step 3: Perform Simultaneous call for both UEs on multiple sectors
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Get Cells List of LTE UE
    Log  Step ${index}: Get Cells List of LTE UE  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Run Keyword If  ${BTS_nb}==1  Run Keywords
    ...  Get LTE Cells List of LTE UE for RF Split
    ...  AND  Return From Keyword
    ${cells_list}=  Get Cells list  TECHNO=${SLAVE_TECHNO_UE2}  CELLS_LIST=DEFAULT
    Log  ${SLAVE_TECHNO_UE2} cells list: ${cells_list}  console=True
    Set Test Variable  ${cells_list_UE2}  ${cells_list}
    Set Test Variable  ${alias_LTE}  Slave
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
    ${alias_NR}=  Set Variable If  ${BTS_nb}==1  ${alias_local}  Master
    ${alias_anchor}=  Set Variable If  "${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}"!="None"  LTE_EXT_SLAVE  ${BTS_nb}==1  ${alias_local}  Slave
    Set Test Variable  ${alias_NR}
    Set Test Variable  ${alias_anchor}
    Run Keyword If  ${BTS_nb}==1  Get Cells List for RF Split
    ...  ELSE  Get Cells List for RF Sharing
    ${NRCellid_PCI}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRCellid_PCI}
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=${alias_NR}
        Set To Dictionary  ${NRCellid_PCI}  ${NR_cell_params.nrCellIdentity}  ${NR_cell_params.physCellId}
    END
    ${NRpci_lteCellId}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NRpci_lteCellId}
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Create lteCell Id NR pci  ${lte_anchor}
    END
    Log  Mapping LTE anchor cell - NR cell: ${LTE_Anchor_Cell_NR_Cell_mapping}  console=True
    Log  Mapping LTE anchor cell - PCI of NR Cell: ${NRpci_lteCellId}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${nr_ues}  ${ue_list}
    Set Test Variable  ${lte_ues}  ${ue_list}
    ${timeout}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data  call_direction=${CALL_DIRECTION_NR_UE}
    ...  cells_list=${CELLS_LIST_NR_UE}  techno=LTE  attenuator=YES
    Set Test Variable  ${timeout}

Step ${index}: Perform Simultaneous call for both UEs on multiple sectors
    Log  Step ${index}: Perform Simultaneous call for both UEs on multiple sectors  console=True
    ${sector_index}=  Set Variable  0
    ${LTE_cell_ids_Covered}=  Create List
    Set Test Variable  ${LTE_cell_ids_Covered}
    ${NR_Cell_ANTL_mapping}=  Get Cell ANTLN relation  NRCEL  ${alias_NR}
    ${LTE_Cell_ANTL_mapping}=  Get Cell ANTLN relation  LNCEL  ${alias_LTE}
    Set Test Variable  ${NR_Cell_ANTL_mapping}
    Set Test Variable  ${LTE_Cell_ANTL_mapping}
    Create NR mapping for PCI and cellId
    ${NR_PCI_lst}=  Split String  ${CELLS_LIST_NR_UE}  separator=
    ${NR_PCI_lst}=  Set Variable If  '${NR_PCI_lst[0].upper()}'=='DEFAULT'  ${NR_all_PCI_list}  ${NR_PCI_lst}
    Set Test Variable  ${NR_PCI_lst}
    ${LTE_cell_id_list}=  Split String  ${CELLS_LIST_LTE_UE}  separator=
    ${LTE_cell_id_list}=  Set Variable If
    ...  '${LTE_cell_id_list[0].upper()}'=='DEFAULT'  ${LTE_all_cell_id_list}
    ...  '${LTE_cell_id_list[0].upper()}'=='ANY'  ${LTE_all_cell_id_list}
    ...  ${LTE_cell_id_list}
    Set Test Variable  ${LTE_cell_id_list}
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    Set Test Variable  ${alias_UE1}  NR_UE_alias
    Set Test Variable  ${alias_UE2}  LTE_UE_alias
    Taf Ue Require Single UE  ue_alias=${alias_UE1}  capabilities=${NR_UE_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_UE2}  capabilities=${LTE_UE_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_UE1}, ${alias_UE2}  console=True
    ${NR_PCI_NR_cellId_mapping}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NR_PCI_NR_cellId_mapping}
    ${nr_cell_list}=  Get Ids For All  NRCEL  ${alias_NR}
    FOR  ${NR_cell_id_iterator}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id_iterator}  timeout=10  alias=${alias_NR}
        Set To Dictionary  ${NR_PCI_NR_cellId_mapping}  ${NR_cell_params.physCellId}  ${NR_cell_params.nrCellIdentity}
    END
    FOR  ${nr_PCI}  IN   @{NR_PCI_lst}
         ${sector_index}=  Evaluate  ${sector_index}+1
         Log  ==============================================================================  console=True
         Log  Starting NR and LTE calls for sector number ${sector_index}  console=True
         Log  ==============================================================================  console=True
         ${nr_PCI_int}=  Convert To Integer  ${nr_PCI}
         ${nr_cell_ID}=  Get From Dictionary  ${NR_PCI_NR_cellId_mapping}  ${nr_PCI_int}
         ${lte_cell_id_same_sector_list}=  Find cell mapped on same sector  ${nr_cell_ID}  NR  LTE
         Set Test Variable  ${lte_cell_id_same_sector_list}
         ${nr_cell_ID_str}=  Convert to String  ${nr_cell_ID}
         Log  Performing NR and LTE call on sector ${sector_index}  console=True
         Log  NR PCI of the cell where NR call is performed is ${nr_PCI}  console=True
         Log  LTE cell(s) from same sector: ${lte_cell_id_same_sector_list}. LTE UE should be attached on it!  console=True
         Log  Attenuating NR signal on all sectors  console=True
         Cut Cells Signal  tech=NR
         Log  Setting attenuation to zero for current NR PCI: ${nr_PCI}  console=True
         Set Cell Attenuation  ${nr_cell_ID_str}  0  NR  ${alias_NR}
         Perform Simultaneous call for both UEs  ${nr_PCI}  ${lte_cell_id_same_sector_list}  ${lte_cell_id_same_sector_list}
    END
    Run Keyword If  '${CELLS_LIST_LTE_UE}'=='ANY'  Return From Keyword
    ${LTE_cell_ids_Covered}=  Remove Duplicates  ${LTE_cell_ids_Covered}
    Log  Searching for uncovered LTE cells  console=True
    Perform Simultaneous call for uncovered LTE cells

Create NR mapping for PCI and cellId
    ${NR_PCI_NR_cellId_mapping}=  Create Dictionary  @{EMPTY}
    ${NR_cellId_NR_PCI_mapping}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NR_PCI_NR_cellId_mapping}
    Set Test Variable  ${NR_cellId_NR_PCI_mapping}
    ${nr_cell_list}=  Get Ids For All  NRCEL  ${alias_NR}
    FOR  ${NR_cell_id_iterator}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id_iterator}  timeout=10  alias=${alias_NR}
        Set To Dictionary  ${NR_PCI_NR_cellId_mapping}  ${NR_cell_params.physCellId}  ${NR_cell_params.nrCellIdentity}
        Set To Dictionary  ${NR_cellId_NR_PCI_mapping}  ${NR_cell_params.nrCellIdentity}  ${NR_cell_params.physCellId}
    END

Find cell mapped on same sector
    [Arguments]  ${cell_id}  ${TECHNO}  ${peer_TECHNO}
    ${cells_mapped_same_sector}=  Create List  @{EMPTY}
    FOR  ${key}  IN  @{${peer_TECHNO}_Cell_ANTL_mapping}
        ${status}=  Run Keyword And Return Status   Lists Should Be Equal   ${${peer_TECHNO}_Cell_ANTL_mapping["${key}"]}
        ...  ${${TECHNO}_Cell_ANTL_mapping["${cell_id}"]}
        Run Keyword If  ${status}  Run Keywords
        ...  Log  ${peer_TECHNO} cell mapped on same sector found: ${key}  console=True
        ...  AND  Append To List  ${cells_mapped_same_sector}  ${key}
    END
    ${list_len}=  Get length  ${cells_mapped_same_sector}
    Run Keyword If  '${peer_TECHNO}'=='LTE' and ${list_len}==0
    ...  Fail  Could not find ${peer_TECHNO} cell mapped on same sector with ${TECHNO} cell id: ${cell_id}!
    [Return]  ${cells_mapped_same_sector}

Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    [Arguments]  ${nr_cell_id}  ${nr_cell_ids_list}  ${lte_cell_ids_list}

    FOR  ${lte_cell_id}  IN  @{lte_cell_ids_list}
        Run Keyword If
        ...  '${lte_cell_id}' in ${LTE_cell_ids_Covered} and '${CELLS_LIST_LTE_UE}' != 'ANY'
        ...  Run Keyword If   '${lte_cell_id}' != '${lte_cell_ids_list[-1]}'
        ...  Continue For Loop
        Run Keyword If  '${CELLS_LIST_LTE_UE}' != 'ANY'  Append To List  ${LTE_cell_ids_Covered}  ${lte_cell_id}
        Remove Values From List  ${nr_cell_ids_list}  ${nr_cell_id}
        Remove Values From List  ${lte_cell_ids_list}  ${lte_cell_id}

        Run Keyword If  '${CELLS_LIST_LTE_UE}' != 'ANY'
        ...  Set cellBarred value for cells on same sector  ${nr_cell_ids_list}  ${lte_cell_ids_list}  barred

        Perform attach on both UEs  ${nr_cell_id}  ${lte_cell_id}
        Run Keyword If  '${CHECK_ATTACH_ONLY}'== 'True'  Run Keywords
        ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
        ...  AND  Log  Detaching UEs  console=True
        ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
        ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
        ...  AND  Log  Succesfully released usage of UEs  console=True
        ...  ELSE  Perform data call for both UEs
        Run Keyword If  '${CELLS_LIST_LTE_UE}' != 'ANY'
        ...  Set cellBarred value for cells on same sector  ${nr_cell_ids_list}  ${lte_cell_ids_list}  notBarred
        Exit For Loop
    END

    [Teardown]  Run Keyword If  '${CELLS_LIST_LTE_UE}' != 'ANY'
    ...  Set cellBarred value for cells on same sector  ${nr_cell_ids_list}  ${lte_cell_ids_list}  notBarred

Perform attach on both UEs
    [Timeout]  ${timeout}
    [Arguments]  ${nr_cell_id}  ${lte_cell_id}
    Log  Attempting to attach UEs on expected cells  console=True
    Log  Attaching NR UE  console=True
    Perform NR Attach  ${nr_cell_id}
    Log  Succesfully Attached NR UE  console=True
    Log  Attaching LTE UE  console=True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${LTE_UE_CAPABILITIES}
    ${lte_cell_expected_list}=  Create List  ${lte_cell_id}
    ${all_sector_cells_list}=  Combine Lists  ${lte_cell_expected_list}  ${lte_cell_id_same_sector_list}
    ${lte_cell_expected_list}=  Set Variable If  '${CELLS_LIST_LTE_UE}' == 'ANY'    ${all_sector_cells_list}  ${lte_cell_expected_list}
    ${status1}=  Run Keyword And Return Status  Taf Ue Attach Single UE  ue_alias=${alias_UE2}  expected_serving_cell_list=${lte_cell_expected_list}
    ...  call_type=data
    Run Keyword If  '${status1}' == 'False'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE2}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Attach Single UE  ue_alias=${alias_UE2}  expected_serving_cell_list=${lte_cell_expected_list}  call_type=data
    Log  Succesfully Attached LTE UE  console=True
    Log  Succesfully attached both UEs on expected cells  console=True
    Run Keyword If  '${CHECK_ATTACH_ONLY}'== 'True'  Run Keywords
    ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
    ...  AND  Log  Detaching UEs  console=True
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    ...  AND  Log  Succesfully released usage of UEs  console=True
    ...  AND  Return From Keyword

Perform data call for both UEs
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
    Log  Detaching UEs  console=True
    Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    Log  Succesfully released usage of UEs  console=True

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
    ...  AND  taf.ue.Stop Data Transfer  dt_name=data_transfer_UE_${ue_index}_dl
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    ...  ${uplink_MIN_TPUT_${ue}}  ${uplink_MAX_TPUT_${ue}}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    ...  tput_min=${uplink_MIN_TPUT_${ue}}  tput_max=${uplink_MAX_TPUT_${ue}}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue}_alias  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL_${ue}}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=data_transfer_UE_${ue_index}_ul
    Log  Stop and check data call for ${ue} finished succesfully!  console=True

Perform NR Attach
    [Arguments]  ${nr_pci}
    ${all_NR_PCIs}=  Create List  ${nr_pci}
    ${NRpci_lteCellId_keys}=  Get Dictionary Keys  ${NRpci_lteCellId}
    ${current_anchor_cell}=  Set Variable  None
    FOR  ${key}  IN  @{NRpci_lteCellId_keys}
        ${current_anchor_cell}=  Set Variable If  ${nr_pci} in ${NRpci_lteCellId[${key}]}  ${key}  ${current_anchor_cell}
    END
    ${current_anchor_cell_str}=  Convert To String  ${current_anchor_cell}
    Log  Anchor cell for current NR PCI ${nr_pci} identified: ${current_anchor_cell_str}  console=True
    ${current_anchor_cell}=  Create List  ${current_anchor_cell_str}
    ${nr_cell_id}=  Taf Ue Get NR Cell ID Based On PCI  ${nr_pci}
    ${current_nr_pci}=  Create List  ${nr_pci}
    ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
    ${mbn_profile_used}=  Set Variable If  '${mbn_profile}' == 'None'  False  True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_UE_CAPABILITIES}  ${mbn_profile_used}
    Taf Ue Set Target NR Cell From DefaultLnRelGnbCellId  ${current_anchor_cell_str}  ${nr_cell_id}  ${alias_anchor}
    Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
    Run Keyword If  '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
    ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}  timeout=30
    ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was acquired!  console=True
    ${status1}=  Run Keyword And Return Status
    ...  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=Master
    Run Keyword If  '${status1}' == 'False' and '${check_nr_attach}' != 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE1}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=Master
    ...  ELSE IF  '${status1}' == 'False' and '${check_nr_attach}' == 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE1}  timeout=300
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE1}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${check_nr_attach}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=Master

Perform Simultaneous call for uncovered LTE cells
    ${nr_cell_id_same_sector_list}=  Create List  ${EMPTY}
    ${lte_cell_id_same_sector_list}=  Create List  ${EMPTY}
    Set Test Variable  ${nr_cell_id_same_sector_list}
    Set Test Variable  ${lte_cell_id_same_sector_list}
    FOR  ${lte_cell_id}  IN   @{LTE_cell_id_list}
        Continue For Loop If  '${lte_cell_id}' in ${LTE_cell_ids_Covered}
        Log  Found uncovered LTE cell: ${lte_cell_id}  console=True
        ${nr_cell_id_same_sector_list}=  Find cell mapped on same sector  ${lte_cell_id}  LTE  NR
        ${lte_cell_id_same_sector_list}=  Find cell mapped on same sector  ${lte_cell_id}  LTE  LTE
        ${lte_cell_id_str}=  Convert to String  ${lte_cell_id}
        ${nr_cell_id}=  Set Variable  ${nr_cell_id_same_sector_list[0]}
        ${nr_cell_id_int}=  Convert To Integer  ${nr_cell_id}
        ${nr_PCI}=  Get From Dictionary  ${NR_cellId_NR_PCI_mapping}  ${nr_cell_id_int}

        Log  Attenuating NR signal on all sectors  console=True
        Cut Cells Signal  tech=NR
        Log  Setting attenuation to zero for current NR cell: ${nr_PCI}  console=True
        Set Cell Attenuation  ${nr_cell_id}  0  NR  ${alias_NR}

        Remove Values From List  ${nr_cell_id_same_sector_list}  ${nr_cell_id}
        Remove Values From List  ${lte_cell_id_same_sector_list}  ${lte_cell_id_str}

        Set cellBarred value for cells on same sector  ${nr_cell_id_same_sector_list}  ${lte_cell_id_same_sector_list}  barred

        Perform attach on both UEs  ${nr_PCI}  ${lte_cell_id_str}
        Run Keyword If  '${CHECK_ATTACH_ONLY}'== 'True'  Run Keywords
        ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
        ...  AND  Log  Detaching UEs  console=True
        ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
        ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
        ...  AND  Log  Succesfully released usage of UEs  console=True
        ...  ELSE  Perform data call for both UEs
        Set cellBarred value for cells on same sector  ${nr_cell_id_same_sector_list}  ${lte_cell_id_same_sector_list}  notBarred
    END

    [Teardown]  Set cellBarred value for cells on same sector  ${nr_cell_id_same_sector_list}  ${lte_cell_id_same_sector_list}  notBarred

Set cellBarred value for cells on same sector
    [Arguments]  ${nr_cell_id_same_sector_list}  ${lte_cell_id_same_sector_list}  ${cellBarred_value}

    ${alias_cell_id_dict}=  Create Dictionary
    ${nr_cell_dn_list}=  Get cell dn list  ${nr_cell_id_same_sector_list}  NR
    ${lte_cell_dn_list}=  Get cell dn list  ${lte_cell_id_same_sector_list}  LTE
    ${all_cell_dn_list}=  Run Keyword If  '${alias_NR}' == '${alias_LTE}'
    ...   Combine Lists  ${nr_cell_dn_list}  ${lte_cell_dn_list}
    ...   ELSE  Create List

    Run Keyword If  '${alias_NR}' == '${alias_LTE}'
    ...  Set To Dictionary  ${alias_cell_id_dict}  ${alias_NR}  ${all_cell_dn_list}
    ...  ELSE  Run Keywords
    ...  Set To Dictionary  ${alias_cell_id_dict}  ${alias_NR}  ${nr_cell_dn_list}
    ...  AND  Set To Dictionary  ${alias_cell_id_dict}  ${alias_LTE}  ${lte_cell_dn_list}

    Set cellBarred on sector cells  ${alias_cell_id_dict}  ${cellBarred_value}

Create lteCell Id NR pci
    [Arguments]  ${lte_anchor}
    ${current_nr_pci_list}=  Create List  @{EMPTY}
    FOR  ${nr_id}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping[${lte_anchor}]}
        Append To List  ${current_nr_pci_list}  ${NRCellid_PCI[${nr_id}]}
    END
    Set To Dictionary  ${NRpci_lteCellId}  ${lte_anchor}  ${current_nr_pci_list}

Get Cells List for RF Sharing
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=Master
    ${lte_cell_list}=  Get Ids For All  LNCEL  alias=Slave
    ${NR_all_PCI_list}=  Create List
    ${LTE_all_cell_id_list}=  Create List
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=Master
        ${nr_pci_str}=  Convert To String  ${NR_cell_params.physCellId}
        Append to list  ${NR_all_PCI_list}  ${nr_pci_str}
    END
    Set Test Variable  ${NR_all_PCI_list}
    ${LTE_all_cell_id_list}=  Get LTE Eutran Cell Ids from admin  Slave
    Set Test Variable  ${LTE_all_cell_id_list}
    ${LTE_cell_ids_ext}=  Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'  Get Ids For All  LNCEL  alias=LTE_EXT_SLAVE
    Set Test Variable  ${nr_cell_list}
    ${cells_list_UE1}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}' == 'LTE'
    ...  Get Cells list  TECHNO=LTE  CELLS_LIST=${CELLS_LIST_NR_UE}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'SBTS'  Get Cells list  TECHNO=SBTS_LTE  CELLS_LIST=${CELLS_LIST_NR_UE}
    Set Test Variable  ${cells_list_UE1}
    ${LTE_cell_ids}=  Set Variable If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'  ${LTE_cell_ids_ext}  ${lte_cell_list}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_cell_ids}  ${alias_anchor}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get Cells List for RF Split
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=${alias_local}
    ${lte_cell_list}=  Get Ids For All  LNCEL  alias=${alias_local}
    ${NR_all_PCI_list}=  Create List
    ${LTE_all_cell_id_list}=  Create List
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=${alias_local}
        ${nr_pci_str}=  Convert To String  ${NR_cell_params.physCellId}
        Append to list  ${NR_all_PCI_list}  ${nr_pci_str}
    END
    Set Test Variable  ${NR_all_PCI_list}
    ${LTE_all_cell_id_list}=  Get LTE Eutran Cell Ids from admin  ${alias_local}
    Set Test Variable  ${LTE_all_cell_id_list}
    ${SBTS_LTE_cell_ids}=  Get Ids For All  LNCEL  alias=${alias_local}
    Set Test Variable  ${nr_cell_list}
    ${cells_list_UE1}  ${temp_cell_id_internal_id_mapping}=  Get SBTS Cell Ids from admin  ${alias_local}  LTE
    ${cell_count}=  Get Length  ${cells_list_UE1}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No LTE cells are found on BTS!  level=ERROR
    ...  AND  Fail  No LTE cells are found on BTS!
    Sort list  ${cells_list_UE1}
    Set Test Variable  ${cells_list_UE1}
    ${LTE_cell_ids_ext}=  Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'  Get Ids For All  LNCEL  alias=LTE_EXT_SLAVE
    ${SBTS_LTE_cell_ids}=  Set Variable If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  ${SBTS_LTE_cell_ids}  ${LTE_cell_ids_ext}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${SBTS_LTE_cell_ids}  ${alias_local}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get LTE Cells List of LTE UE for RF Split
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Get SBTS Cell Ids from admin  ${alias_local}  LTE
    Set Test Variable  ${alias_LTE}  ${alias_local}
    Log  LTE cells list: ${cells_list}  console=True
    Set Test Variable  ${cells_list_UE2}  ${cells_list}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${SLAVE_TECHNO_UE2.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_LTE_UE}  cells_list=${cells_list}  techno=${SLAVE_TECHNO_UE2}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Get cell dn list
    [Arguments]  ${CellId_list}  ${TECHNO}
    ${cell_dn_list}=  Run Keyword If  '${TECHNO}'=='NR'  Get Ids For All  NRCEL  ${alias_${TECHNO}}
    ...  ELSE  Get Ids For All  LNCEL  ${alias_${TECHNO}}
    ${cell_dn_param_list}=  Create List
    FOR  ${cell_dn}  IN  @{cell_dn_list}
        ${cell_params}=  Run Keyword If  '${TECHNO}'=='NR'  Get Parameters For  class_name=NRCEL  id_num=${cell_dn}  timeout=10
        ...  alias=${alias_${TECHNO}}
        ...  ELSE  Get Parameters For  class_name=LNCEL  id_num=${cell_dn}  timeout=10
        ...  alias=${alias_${TECHNO}}

        ${CellId_param}=  Set Variable If  '${TECHNO}'=='NR'  ${cell_params.nrCellIdentity}  ${cell_params.eutraCelId}
        Run Keyword If  '${CellId_param}' in ${CellId_list}  Append To List  ${cell_dn_param_list}  ${cell_dn}
    END
    [Return]  ${cell_dn_param_list}

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
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  Return From Keyword
    Teardown Admin  alias=LTE_EXT_SLAVE

Prepare External Admin Sessions
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  Return From Keyword
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}  alias=LTE_EXT_SLAVE

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
