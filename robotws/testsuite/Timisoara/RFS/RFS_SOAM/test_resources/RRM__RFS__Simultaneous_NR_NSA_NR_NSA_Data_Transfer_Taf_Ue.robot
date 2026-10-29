*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_OAM_IP_ADDRESS_LTE1}    None       # for LTE paired with NR Master; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin
${BTS_OAM_IP_ADDRESS_LTE2}    None       # for LTE paired with NR Slave; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin
${NR_MASTER_UE_CAPABILITIES}    None     # For NR Master UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${NR_SLAVE_UE_CAPABILITIES}    None      # For NR Slave UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CELLS_LIST_NR_MASTER_UE}    DEFAULT    # Specify the cells list on which NR MASTER UE will be chekced; Possible values: "DEFAULT"-means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
${CELLS_LIST_NR_SLAVE_UE}    DEFAULT     # Specify the cells list on which NR SLAVE UE will be chekced; Possible values: "DEFAULT"-means that UE is
                                         # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                         # with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
${CALL_DURATION}    100                  # Duration of data call for both UEs (in seconds);
${CALL_DIRECTION_NR_MASTER_UE}    downlink    # Direction of data transfer call for NR MASTER UE;
                                              # Possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_NR_SLAVE_UE}    downlink     # Direction of data transfer call for NR SLAVE UE;
                                              # Possible values: "downlink", "uplink" and "uplink_downlink"
${PROTOCOL_NR_MASTER_UE}    udp                # Data transfer protocol for NR MASTER UE. e.q. udp, tcp, ftp
${PROTOCOL_NR_SLAVE_UE}    udp                 # Data transfer protocol for NR SLAVE UE. e.q. udp, tcp, ftp
${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec  # DL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec  # DL Minmum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_MASTER_UE}    50 Mbits/sec     # UL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec     # UL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec   # DL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec   # DL Minmum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_SLAVE_UE}    50 Mbits/sec      # UL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec      # UL Minimum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 3 Mbits/sec;
${CHECK_NR_MASTER_ATTACH}                     # For NR Master UE - Flag to check if attach was correctly performed on 5G; Possible values:
                                              # None (default) or ADB (check performed using
                                              # adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
                                              # primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
                                              # before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
                                              # RRC messages - QCAT license need to be activated or AT
                                              # (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
                                              # before test start, and Ue need to be disconnected from QXDM)
                                              # or aashell - for checking NR attach from BTS based on resources usage
${CHECK_NR_SLAVE_ATTACH}                      # For NR Slave UE - Flag to check if attach was correctly performed on 5G; Possible values:
                                              # None (default) or ADB (check performed using
                                              # adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
                                              # primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
                                              # before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
                                              # RRC messages - QCAT license need to be activated
                                              # before test start, and Ue need to be disconnected from QXDM) or AT
                                              # (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
                                              # or aashell - for checking NR attach from BTS based on resources usage
${BANDWIDTH}    60 Mbits/sec                  # max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
${DETACH_UEs}    False                        # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False
${MBN_PROFILE_NR_MASTER_UE}    None           # For NR Master UE - Full local path to the MBN xml profile;
                                              # Only applicable in case of AT command based UEs;
                                              # Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
${MBN_PROFILE_NR_SLAVE_UE}    None            # For NR Slave UE - Full local path to the MBN xml profile;
                                              # Only applicable in case of AT command based UEs;
                                              # Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
${CHECK_ATTACH_ONLY}    False                  # Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
                                              # Default value: False

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25047
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
    ...  - BTS_OAM_IP_ADDRESS_LTE1     ----  for LTE paired with NR Master; BTS OAM IP address used to get anchor cell relation through
    ...                                    Infomodel/Admin
    ...
    ...  - BTS_OAM_IP_ADDRESS_LTE2     ----  for LTE paired with NR Slave; BTS OAM IP address used to get anchor cell relation through
    ...                                      Infomodel/Admin
    ...
    ...  - NR_MASTER_UE_CAPABILITIES   ----  For NR Master UE - label used to identify a specific ue defined in config
    ...
    ...  - NR_SLAVE_UE_CAPABILITIES    ----  For NR Slave UE - label used to identify a specific ue defined in config
    ...
    ...  - CELLS_LIST_NR_MASTER_UE     ----  Specify the cells list on which NR MASTER UE will be chekced; Possible values: "DEFAULT" - means that UE
    ...                                      is checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                      with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
    ...
    ...  - CELLS_LIST_NR_SLAVE_UE      ----  Specify the cells list on which NR SLAVE UE will be chekced; Possible values: "DEFAULT" - means that UE
    ...                                      is checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
    ...                                      with space between Cells Id. for NR - LTE Eutran cell ids of anchor cell is provided
    ...
    ...  - CALL_DURATION               ----  Duration of data call for both UEs (in seconds);
    ...
    ...  - CALL_DIRECTION_NR_MASTER_UE ----  Direction of data transfer call for NR MASTER UE;
    ...                                      Possible values: "downlink", "uplink" and "uplink_downlink"
    ...
    ...  - CALL_DIRECTION_NR_SLAVE_UE  ----  Direction of data transfer call for NR SLAVE UE;
    ...                                      Possible values: "downlink", "uplink" and "uplink_downlink"
    ...
    ...  - PROTOCOL_NR_MASTER_UE       ----  Data transfer protocol for NR MASTER UE. e.q. udp, tcp, ftp
    ...
    ...  - PROTOCOL_NR_SLAVE_UE        ----  Data transfer protocol for NR SLAVE UE. e.q. udp, tcp, ftp
    ...
    ...  - downlink_MAX_TPUT_NR_MASTER_UE     ----  DL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_NR_MASTER_UE     ----  DL Minmum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_NR_MASTER_UE       ----  UL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_NR_MASTER_UE       ----  UL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 3 Mbits/sec;
    ...
    ...  - downlink_MAX_TPUT_NR_SLAVE_UE      ----  DL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_NR_SLAVE_UE      ----  DL Minmum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_NR_SLAVE_UE        ----  UL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_NR_SLAVE_UE        ----  UL Maximum acceptable t-put for LTE_UE; acceptable values: e.q. - 3 Mbits/sec;
    ...
    ...  - CHECK_NR_MASTER_ATTACH             ----  For NR Master UE - Flag to check if attach was correctly performed on 5G; Possible values:
    ...                                             None (default) or ADB (check performed using
    ...                                             adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
    ...                                             primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...                                             before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
    ...                                             RRC messages - QCAT license need to be activated
    ...                                             before test start, and Ue need to be disconnected from QXDM) or AT
    ...                                             (check performed using AT command AT+QENG="servingcell") for Quectel UEs or aashell - for
    ...                                             checking NR attach
    ...                                   from BTS based on resources usage
    ...
    ...  - CHECK_NR_SLAVE_ATTACH              ----  For NR Slave UE - Flag to check if attach was correctly performed on 5G; Possible values:
    ...                                             None (default) or ADB (check performed using
    ...                                             adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
    ...                                             primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...                                             before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
    ...                                             RRC messages - QCAT license need to be activated
    ...                                             before test start, and Ue need to be disconnected from QXDM) or AT
    ...                                             (check performed using AT command AT+QENG="servingcell") for Quectel UEs or aashell - for
    ...                                             checking NR attach
    ...                                   from BTS based on resources usage
    ...
    ...  - BANDWIDTH                          ----  max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
    ...
    ...
    ...  - DETACH_UE                  ----  Specify whether to dettach UEs after the test execution; Possible values: True/False.Default value: False
    ...
    ...  - MBN_PROFILE_NR_MASTER_UE   ----  For NR Master UE - Full local path to the MBN xml profile;
    ...                                     Only applicable in case of AT command based UEs;
    ...                                     Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
    ...
    ...  - MBN_PROFILE_NR_SLAVE_UE    ----  For NR Slave UE - Full local path to the MBN xml profile;
    ...                                     Only applicable in case of AT command based UEs;
    ...                                     Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
    ...  - CHECK_ATTACH_ONLY          ----  Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
    ...                                     Default value: False
    ...
    ...  Test scenario:
    ...
    ...  -    UE is attached to the cell under test on NR Master technology BTS. 2nd UE is attached on NR Slave technology BTS
    ...  -    UEs successfully attached to the cell under test on NR Master/NR Slave technology BTSs.
    ...  -    UDP Data transfer is started on 1st UE on NR Master. UDP Data transfer is started on 2nd UE on NR Slave.
    ...  -    When data transfer is established, throughput is measured for at least 5min to be as expected.
    ...  -    Data transfer is successfully started and throughput levels are acceptable
    ...  -    Data transfer is disconnected. All services are terminated and UEs are detached.
    ...  -    Disconnection is successful and resources are released correctly
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25047 - Delivery of RRM__RFS__NR_NR_Simultaneous_NR_NSA_Data_Transfer_Taf_Ue
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 30.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25610 - [5G][Refactoring][CNI-85214] LNRELGNBCELL_R object refactoring -
    ...  RRM_RFS_NR_NR_Simultaneous_NR_NSA_Data_Transfer_Taf_Ue
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26605 - [Calls] Adapt Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 11.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26316 - [Calls][P1]Check attach only option
    ...  RRM__RFS__NR_NR_Simultaneous_NR_NSA_Data_Transfer_Taf_Ue
    ...  - 15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26707 - [Calls] Add aashell check option for
    ...  RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_Taf_Ue robot
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26606 - [Calls] Remove Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 30.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26789 - [5G][Automated Calls]New test case
    ...  [RRM__RFS__Simultaneous_SBTS_NSA_SBTS_NSA_Data_Transfer_Taf_Ue_Internal_Anchor]
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27687 - [Calls] Make call tests independent of Particular Setup
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25047_RRM__RFS__NR_NR_Simultaneous_NR_NSA_Data_Transfer_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-adrian.beta@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-CR1
    ...    SBTS23R3       CABLING-RFS_01_UE

    Prepare External Admin Sessions
    Step 1: Get LTE Anchor Cells List and NR Cells Mapping for NR Master
    Step 2: Get LTE Anchor Cells List and NR Cells Mapping for NR Slave
    Step 3: Perform Simultaneous call for both UEs
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping for NR ${alias}
    Log  Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping for NR ${alias}  console=True
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=${alias}
    ${bts_index}=  Set Variable If  '${alias.upper()}'=='MASTER'  1  '${alias.upper()}'=='SLAVE'  2
    ${alias_connection}=   Set Variable If  '${BTS_OAM_IP_ADDRESS_LTE${bts_index}}'=='None'   ${alias}  LTE_${alias}
    ${cells_list}=  Particular Get Cells list  TECHNO=${alias_connection.upper()}  CELLS_LIST=${CELLS_LIST_NR_${alias.upper()}_UE}
    ${LTE_cell_ids_tmp}=  Admin Get LTE CELL Ids list  ${alias_connection.upper()}
    Set Test Variable  ${LTE_${alias.upper()}_cell_ids}  ${LTE_cell_ids_tmp[0]}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_${alias.upper()}_cell_ids}  ${alias_connection.upper()}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}
    Get nrCellIds anchor mapping
    ${NRCellid_PCI}=  Create Dictionary  @{EMPTY}
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=${alias}
        Set To Dictionary  ${NRCellid_PCI}  ${NR_cell_params.nrCellIdentity}  ${NR_cell_params.physCellId}
    END
    Set Test Variable  ${${alias}_NRCellid_PCI}  ${NRCellid_PCI}
    ${PCI_NRCellid}=  Create Dictionary  @{EMPTY}
    FOR  ${NR_cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${NR_cell_id}  timeout=10  alias=${alias}
        Set To Dictionary  ${PCI_NRCellid}  ${NR_cell_params.physCellId}  ${NR_cell_params.nrCellIdentity}
    END
    ${NRpci_lteCellId}=  Create Dictionary  @{EMPTY}
    ${PCI_NRCellid_keys}=  Get Dictionary Keys  ${PCI_NRCellid}
    ${PCI_NRCellid_values}=  Get Dictionary Values  ${PCI_NRCellid}
    ${NR_all_PCI_list}=  Create List
    FOR  ${pci}  ${nr_cell_id}  IN ZIP  ${PCI_NRCellid_keys}  ${PCI_NRCellid_values}
        ${nr_cell_id_str}=  Convert to String  ${nr_cell_id}
        ${nr_cell_exists}=  Run Keyword and Return Status
        ...  Dictionary Should Contain Key  ${NR_Cell_LTE_Anchor_Cell_mapping}   ${nr_cell_id_str}
        ${lte_cell_id_dictionary}=  Set Variable IF  '${nr_cell_exists}'=='True'  ${NR_Cell_LTE_Anchor_Cell_mapping["${nr_cell_id_str}"]}
        Run Keyword If  '${nr_cell_exists}'=='True'
        ...  Set To Dictionary  ${NRpci_lteCellId}  ${lte_cell_id_dictionary}  ${pci}
        Append To List  ${NR_all_PCI_list}  ${pci}
    END
    Set Test Variable  ${${alias}_NRpci_lteCellId}  ${NRpci_lteCellId}
    Set Test Variable  ${${alias}_NR_all_PCI_list}  ${NR_all_PCI_list}
    Log  Mapping LTE anchor cell - NR ${alias} cell: ${LTE_Anchor_Cell_NR_Cell_mapping}  console=True
    Log  Mapping LTE anchor cell - PCI of NR Cell: ${${alias}_NRpci_lteCellId}  console=True
    ${cells_list_tmp}=  Create List  @{EMPTY}
    Log  Omitting non-anchor LTE cells from cells list  console=True
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    FOR  ${cell}  IN  @{cells_list}
        Run Keyword If  ${cell} in ${LTE_Anchor_Cell_NR_Cell_mapping_keys}  Append To List  ${cells_list_tmp}  ${cell}
    END
    Set Test Variable  ${cells_list_UE_NR_${alias}}  ${cells_list_tmp}
    ${cells_list_len}=  Get Length  ${cells_list_UE_NR_${alias}}
    Run Keyword If  '${cells_list_len}' == '0'
    ...  Fail  No anchor cells among cell list eligible for NR LTE NSA call!
    ...  ELSE  Log  List of anchor cells eligible for NR LTE NSA call is: ${cells_list_UE_NR_${alias}}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${lte_ues}  ${ue_list}
    ${timeout}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=data
    ...  call_direction=${CALL_DIRECTION_NR_${alias.upper()}_UE}  cells_list=${cells_list_UE_NR_${alias}}  techno=LTE  attenuator=NO
    Set Test Variable  ${timeout}

Get nrCellIds anchor mapping
    ${NR_Cell_LTE_Anchor_Cell_mapping}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NR_Cell_LTE_Anchor_Cell_mapping}
    ${LTE_anchor_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    FOR  ${LTE_anchor}  IN  @{LTE_anchor_keys}
       ${NRCellid_list}=  Get From Dictionary  ${LTE_Anchor_Cell_NR_Cell_mapping}  ${LTE_anchor}
       Mapping anchor to nrCellIds  ${NRCellid_list}  ${LTE_anchor}
    END

Mapping anchor to nrCellIds
    [Arguments]  ${NRCellid_list}  ${LTE_anchor}
    FOR  ${nr_cell_id}  IN  @{NRCellid_list}
       Set To Dictionary  ${NR_Cell_LTE_Anchor_Cell_mapping}  ${nr_cell_id}  ${LTE_anchor}
    END

Step ${index}: Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    Log  Step ${index}: Perform Simultaneous call for both UEs  console=True
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    Set Test Variable  ${alias_NR_Master_UE}  NR_UE1_alias
    Set Test Variable  ${alias_NR_Slave_UE}  NR_UE2_alias
    Taf Ue Require Single UE  ue_alias=${alias_NR_Master_UE}  capabilities=${NR_MASTER_UE_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_NR_Slave_UE}  capabilities=${NR_SLAVE_UE_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_NR_Master_UE}, ${alias_NR_Slave_UE}  console=True
    Log  Attempting to attach UEs on expected cells  console=True
    Log  Attaching NR Master UE  console=True
    Perform NR Master Attach
    Log  Succesfully Attached NR Master UE  console=True
    Log  Attaching NR Slave UE  console=True
    Perform NR Slave Attach
    Log  Succesfully Attached NR Slave UE  console=True
    Log  Succesfully attached both UEs on expected cells  console=True
    Run Keyword If  '${CHECK_ATTACH_ONLY}' == 'True'  Run Keywords
    ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
    ...  AND  Log  Detaching UEs  console=True
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_NR_Master_UE}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_NR_Slave_UE}
    ...  AND  Log  Succesfully released usage of UEs  console=True
    ...  AND  Return From Keyword
    Log  Attempting start data call on NR Master UE  console=True
    Proceed to data transfer start on NR Master UE
    Log  Succesfully started data call on NR Master UE  console=True
    Log  Attempting start data call on NR Slave UE  console=True
    Proceed to data transfer start on NR Slave UE
    Log  Succesfully started data call on NR Slave UE  console=True
    Log  Wait for the call operations to end  console=True
    Log  Wait for the NR Master UE data call operation to end  console=True
    Await data call finish on NR Master UE
    Log  Wait for the NR Slave UE data call operation to end  console=True
    Await data call finish on NR Slave UE
    Log  Call operations ended succesfully for both UEs  console=True
    Log  Checking call results for both UEs  console=True
    Log  Checking call results for NR Master UE  console=True
    Stop and check data call on NR Master UE
    Log  Checking call results for NR Slave UE  console=True
    Stop and check data call on NR Slave UE
    Log  Checking call results for both UEs succesful!  console=True
    Run Keyword If  '${DETACH_UEs}' == 'True'  Run Keywords
    ...  Taf Ue Detach Single UE  ue_alias=${alias_NR_Master_UE}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_NR_Slave_UE}
    ...  AND  Log  Succesfully released usage of UEs  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Proceed to data transfer start on NR ${alias} UE
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_NR_${alias.upper()}_UE}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set for NR ${alias}: ${CALL_DIRECTION}! Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    Run Keyword If  '${CALL_DIRECTION}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_NR_${alias}_UE}  dt_name=data_transfer_UE_NR_${alias}_${CALL_DIRECTION}
    ...  call_duration=${CALL_DURATION}  call_direction=${CALL_DIRECTION}  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_NR_${alias}_UE}  dt_name=data_transfer_UE_NR_${alias}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_NR_${alias}_UE}  dt_name=data_transfer_UE_NR_${alias}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${BANDWIDTH}  protocol=${PROTOCOL}

Await data call finish on NR ${alias} UE
    Translate Call Direction  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_NR_${alias}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_NR_${alias}_dl

Stop and check data call on NR ${alias} UE
    Translate Call Direction  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_NR_${alias}_UE}  data_transfer_UE_NR_${alias}_dl  dl
    ...  ${PROTOCOL_NR_${alias.upper()}_UE}  ${downlink_MIN_TPUT_NR_${alias.upper()}_UE}  ${downlink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_NR_${alias}_dl
    ...  tput_min=${downlink_MIN_TPUT_NR_${alias.upper()}_UE}  tput_max=${downlink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Taf Ue Solution display actual throughput values  ${alias_NR_${alias}_UE}  data_transfer_UE_NR_${alias}_dl  dl
    ...  ${PROTOCOL_NR_${alias.upper()}_UE}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_NR_${alias}_UE}  data_transfer_UE_NR_${alias}_ul  ul
    ...  ${PROTOCOL_NR_${alias.upper()}_UE}  ${uplink_MIN_TPUT_NR_${alias.upper()}_UE}  ${uplink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_NR_${alias}_ul
    ...  tput_min=${uplink_MIN_TPUT_NR_${alias.upper()}_UE}  tput_max=${uplink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Taf Ue Solution display actual throughput values  ${alias_NR_${alias}_UE}  data_transfer_UE_NR_${alias}_ul  ul
    ...  ${PROTOCOL_NR_${alias.upper()}_UE}
    Log  Stop and check data call for NR ${alias} UE finished succesfully!  console=True

Perform NR ${alias} Attach
    Set Test Variable  ${NRCellid_PCI}  ${${alias}_NRCellid_PCI}
    ${mbn_profile}=  Get Variable Value  ${MBN_PROFILE_NR_${alias.upper()}_UE}  None
    ${mbn_profile_used}=  Set Variable if  '${mbn_profile}' == 'None'  False  True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_${alias.upper()}_UE_CAPABILITIES}  ${mbn_profile_used}
    Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
    Run Keyword If  '${CHECK_NR_${alias.upper()}_ATTACH}' == 'QCAT'  Run Keywords
    ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
    ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}  timeout=30
    ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was acquired!  console=True
    ${status1}=  Run Keyword And Return Status  Taf Ue Perform attach and check cell  ue_alias=${alias_NR_${alias}_UE}
    ...  cell_check=${cells_list_UE_NR_${alias}}  ue_info=${ue_info}
    ...  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${${alias}_NR_all_PCI_list}  alias_nr=${alias}
    Run Keyword If  '${status1}' == 'False' and '${CHECK_NR_${alias.upper()}_ATTACH}' != 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_NR_${alias}_UE}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}
    ...  ${ue_info[5]}  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_NR_${alias}_UE}  cell_check=${cells_list_UE_NR_${alias}}  ue_info=${ue_info}
    ...  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${${alias}_NR_all_PCI_list}  alias_nr=${alias}
    ...  ELSE IF  '${status1}' == 'False' and '${CHECK_NR_${alias.upper()}_ATTACH}' == 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_NR_${alias}_UE}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_NR_${alias}_UE}  timeout=300
    ...  AND  Taf Ue Assure Mbn Profile Presence If AT Commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}
    ...  ${ue_info[5]}  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_NR_${alias}_UE}  cell_check=${cells_list_UE_NR_${alias}}  ue_info=${ue_info}
    ...  second_run=True  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${${alias}_NR_all_PCI_list}  alias_nr=${alias}

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Particular Get Cells list
    [Arguments]  ${TECHNO}  ${CELLS_LIST}
    ${get_bts_cells_list}=  Set Variable If  '${CELLS_LIST}' == 'DEFAULT'  ${True}  ${False}
    ${CELLS_LIST}=  Run Keyword If  '${CELLS_LIST}' != 'DEFAULT'  Split String  ${CELLS_LIST}
    Run Keyword If  not ${get_bts_cells_list}  Return From Keyword  ${CELLS_LIST}
    ${CELLS_LIST}=  Get LTE Eutran Cell Ids from admin  ${TECHNO}
    ${cell_count}=  Get Length  ${CELLS_LIST}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No ${TECHNO} cells are found on BTS!  level=ERROR
    ...  AND  Fail  No ${TECHNO} cells are found on BTS!
    Sort list  ${CELLS_LIST}
    [Return]  ${CELLS_LIST}

Particular Teardown
    Run Keyword If  '${DETACH_UEs}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs
    Run Keyword If  '${CHECK_NR_MASTER_ATTACH}' == 'QCAT' or '${CHECK_NR_SLAVE_ATTACH}' == 'QCAT'  Run Keywords
    ...  Taf Ue Release QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was released!  console=True
    ...  AND  Taf Ue License Keeper Teardown
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_LTE1}'=='None' and '${BTS_OAM_IP_ADDRESS_LTE2}'=='None'  Return From Keyword
    Teardown Admin  alias=LTE_MASTER
    Teardown Admin  alias=LTE_SLAVE

Prepare External Admin Sessions
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_LTE1}'=='None' and '${BTS_OAM_IP_ADDRESS_LTE2}'=='None'  Return From Keyword
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_LTE1}  alias=LTE_MASTER
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_LTE2}  alias=LTE_SLAVE

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
	Run Keyword And Continue On Failure  Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}
	...  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
