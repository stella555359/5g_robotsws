*** Settings ***
Documentation    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
Variables    tc_variables/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_OAM_IP_ADDRESS_LTE1}    None       # for LTE paired with NR Master; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin
${BTS_OAM_IP_ADDRESS_LTE2}    None       # for LTE paired with NR Slave; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin
${NR_MASTER_UE_CAPABILITIES}    None     # For NR Master UE - label used to identify a specific ue defined in config
${NR_SLAVE_UE_CAPABILITIES}    None      # For NR Slave UE - label used to identify a specific ue defined in config
${LTE_MASTER_ANCHOR_LIST}    DEFAULT      # List of Anchor cells used for NR Master that will be taken into account; Default value: all accepted
${LTE_SLAVE_ANCHOR_LIST}    DEFAULT       # List of Anchor cells used for NR Slave that will be taken into account; Default value: all accepted
${CELLS_LIST_NR_MASTER_UE}    DEFAULT    # Specify the NR Master cells list (NR PCIs) on which NR_UE call will be chekced; Possible values: "DEFAULT"-
                                         # means all cells belonging to it; "30295 30294 30293" - User provides cells list with space between Cells Id
${CELLS_LIST_NR_SLAVE_UE}    ANY         # Specify the NR Slave cells list (NR PCIs) on which NR_UE will call be chekced; Possible values: "DEFAULT" -
                                         # means all cells belonging to it / "30295 30294 30293" - User provides cells list with space
                                         # between Cells Id / "ANY" (default value) - for each NR MASTER Cell any cell from same sector call will be
                                         # considered ok, in case this parameter is different from ANY, all the cells will be covered at least
                                         # once with call
${CALL_DURATION}    100                  # Duration of data call for both UEs (in seconds);
${CALL_DIRECTION_NR_MASTER_UE}    downlink    # Direction of data transfer call for NR MASTER UE;
                                              # Possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_NR_SLAVE_UE}    downlink     # Direction of data transfer call for NR SLAVE UE;
                                              # Possible values: "downlink", "uplink" and "uplink_downlink"
${PROTOCOL_NR_MASTER_UE}    udp                # Data transfer protocol for NR MASTER UE. e.q. udp, tcp, ftp
${PROTOCOL_NR_SLAVE_UE}    udp                 # Data transfer protocol for NR SLAVE UE. e.q. udp, tcp, ftp
${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec  # DL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec  # DL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_MASTER_UE}    50 Mbits/sec     # UL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec     # UL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 3 Mbits/sec;
${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec   # DL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 150 Mbits/sec;
${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec   # DL Minimum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 5 Mbits/sec;
${uplink_MAX_TPUT_NR_SLAVE_UE}    50 Mbits/sec      # UL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 50 Mbits/sec;
${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec      # UL Minimum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 3 Mbits/sec;
${BANDWIDTH}    60 Mbits/sec                  # max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
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
${MBN_PROFILE_NR_MASTER_UE}    None           # For NR Master UE - Full local path to the MBN xml profile;
                                              # Only applicable in case of AT command based UEs;
                                              # Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
${MBN_PROFILE_NR_SLAVE_UE}    None            # For NR Slave UE - Full local path to the MBN xml profile;
                                              # Only applicable in case of AT command based UEs;
                                              # Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
${DETACH_UEs}    False                        # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                              # Default value: False

*** Keywords ***
TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-23658
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing simultaneous NR Master NSA and NR Slave NSA data transfer calls on 2 UEs on multiple sectors.
    ...  Will perform call on all NR Master cells sent as input argument using attenuator and simultaniously on all NR Slave cells mapped on the
    ...  same sectors
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...
    ...  - BTS_OAM_IP_ADDRESS_LTE1     ----  for LTE paired with NR Master; BTS OAM IP address used to get anchor cell relation through
    ...                                      Infomodel/Admin
    ...
    ...  - BTS_OAM_IP_ADDRESS_LTE2     ----  for LTE paired with NR Slave; BTS OAM IP address used to get anchor cell relation through
    ...                                      Infomodel/Admin
    ...  - CELLS_LIST_NR_MASTER_UE     ----  Specify the NR Master cells list (NR PCIs) on which NR_UE will be chekced; Possible values: "DEFAULT" -
    ...                                      means all cells belonging to it; "30295 30294 30293" - User provides cells list with space between
    ...                                      Cells Id
    ...  - CELLS_LIST_NR_SLAVE_UE      ----  Specify the NR Slave cells list (NR PCIs) on which NR_UE will be chekced; Possible values: "DEFAULT" -
    ...                                      means all cells belonging to it / "30295 30294 30293" - User provides cells list with space
    ...                                      between Cells Id / "ANY" (default value) - for each NR MASTER Cell any cell from same sector call will be
    ...                                      considered ok, in case this parameter is different from ANY, all the cells will be covered at least
    ...                                      once with call
    ...
    ...  - NR_MASTER_UE_CAPABILITIES   ----  For LTE_UE - label used to identify a specific ue defined in config
    ...
    ...  - NR_SLAVE_UE_CAPABILITIES    ----  For NR Slave UE - label used to identify a specific ue defined in config
    ...
    ...  - LTE_MASTER_ANCHOR_LIST      ----  For NR Master UE - label used to identify a specific ue defined in config
    ...
    ...  - LTE_SLAVE_ANCHOR_LIST       ----  For NR Slave UE - label used to identify a specific ue defined in config
    ...
    ...  - CALL_DURATION               ----  Duration of data call for both UEs (in seconds)
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
    ...  - downlink_MAX_TPUT_NR_MASTER_UE  ----  DL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_NR_MASTER_UE  ----  DL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_NR_MASTER_UE    ----  UL Maximum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_NR_MASTER_UE    ----  UL Minimum acceptable t-put for NR MASTER UE; acceptable values: e.q.  - 3 Mbits/sec;
    ...
    ...  - downlink_MAX_TPUT_NR_SLAVE_UE   ----  DL Maximum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 150 Mbits/sec;
    ...
    ...  - downlink_MIN_TPUT_NR_SLAVE_UE   ----  DL Minimum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 5 Mbits/sec;
    ...
    ...  - uplink_MAX_TPUT_NR_SLAVE_UE     ----  UL Maximum acceptable t-put for NR SLAVE UEE; acceptable values: e.q.  - 50 Mbits/sec;
    ...
    ...  - uplink_MIN_TPUT_NR_SLAVE_UE     ----  UL Minimum acceptable t-put for NR SLAVE UE; acceptable values: e.q.  - 3 Mbits/sec;
    ...
    ...  - BANDWIDTH                       ----  max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q.  - 60 Mbits/sec;
    ...
    ...  - CHECK_NR_MASTER_ATTACH  ----   For NR Master UE - Flag to check if attach was correctly performed on 5G; Possible values:
    ...                                   None (default) or ADB (check performed using
    ...                                   adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
    ...                                   primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...                                   before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
    ...                                   RRC messages - QCAT license need to be activated or AT
    ...                                   (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
    ...                                   before test start, and Ue need to be disconnected from QXDM) or aashell - for checking NR attach
    ...                                   from BTS based on resources usage
    ...
    ...  - CHECK_NR_SLAVE_ATTACH  ----    For NR Slave UE - Flag to check if attach was correctly performed on 5G; Possible values:
    ...                                   None (default) or ADB (check performed using
    ...                                   adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set
    ...                                   primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS
    ...                                   before test!) or QCAT (check performed by analyzing RRC messages - check performed by analyzing
    ...                                   RRC messages - QCAT license need to be activated or AT
    ...                                   (check performed using AT command AT+QENG="servingcell") - for Quectel UEs
    ...                                   before test start, and Ue need to be disconnected from QXDM) or aashell - for checking NR attach
    ...                                   from BTS based on resources usage
    ...
    ...  - MBN_PROFILE_NR_MASTER_UE   ----  For NR Master UE - Full local path to the MBN xml profile;
    ...                                     Only applicable in case of AT command based UEs;
    ...                                     Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
    ...
    ...  - MBN_PROFILE_NR_SLAVE_UE    ----  For NR Slave UE - Full local path to the MBN xml profile;
    ...                                     Only applicable in case of AT command based UEs;
    ...                                     Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
    ...
    ...
    ...  - DETACH_UEs       ----  Specify whether to dettach the UEs after the test execution; Possible values: True/False. Default value: False
    ...
    ...  Test scenario:
    ...
    ...  -    UE is attached to the cell under test on NR Master. 2nd UE is attached on NR Master
    ...  -    UEs successfully attached to the cell under test on NR Master/NR Slave technology BTSs.
    ...  -    UDP Data transfer is started. DL/UL or both started on 1st UE on NR Master. DL/UL or both started on 2nd UE on NR Slave.
    ...  -    When data transfer is established, throughput is measured for at least 5min to be as expected.
    ...  -    Data transfer is successfully started and throughput levels are acceptable
    ...  -    Data transfer is disconnected. All services are terminated and UE is detached.
    ...  -    Disconnection is successful and resources are released correctly
    ...  -    Repeat this steps for all sectors
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23658 - TC Delivery
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26605 - [Calls] Adapt Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26708 - [Calls] Add aashell check option documentation for
    ...  RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue robot
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26606 - [Calls] Remove Simultaneous call TCs to taf.ue limitation -
    ...  call duration can't be the same on both UEs
    ...  - 01.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26907 - [Calls] Multiple cells per sector -
    ...  RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue - on slave BTS
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27687 - [Calls] Make call tests independent of Particular Setup
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23658_RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.png

    Set Tags    CA-RRM    OWNER-adrian.beta@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com;    PHASE-QT    SW-SBTS23R4

    Prepare External Admin Sessions
    Step 1: Get LTE Anchor Cells List and NR Cells Mapping for NR Master
    Step 2: Get LTE Anchor Cells List and NR Cells Mapping for NR Slave
    Step 3: Perform Simultaneous call for both UEs on multiple sectors
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping for NR ${alias}
    Log  Step ${index}: Get LTE Anchor Cells List and NR Cells Mapping for NR ${alias}  console=True
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=${alias}
    ${cells_list}=  Particular Get Cells list  TECHNO=LTE_${alias.upper()}  CELLS_LIST=DEFAULT
    ${LTE_cell_ids_tmp}=  Admin Get LTE CELL Ids list  LTE_${alias.upper()}
    Set Test Variable  ${LTE_${alias.upper()}_cell_ids}  ${LTE_cell_ids_tmp[0]}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_${alias.upper()}_cell_ids}  LTE_${alias.upper()}
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Run Keyword If  "${LTE_${alias.upper()}_ANCHOR_LIST.upper()}" != "DEFAULT" and "${lte_anchor}" not in "${LTE_${alias.upper()}_ANCHOR_LIST}"
        ...  Remove From Dictionary  ${LTE_Anchor_Cell_NR_Cell_mapping}  ${lte_anchor}
    END
    Set Test Variable  ${LTE_Anchor_Cell_NR_${alias}_Cell_mapping}  ${LTE_Anchor_Cell_NR_Cell_mapping}
    Get nrCellIds anchor mapping  ${alias}
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_${alias}_Cell_mapping}
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
        ${nr_cell_exists}=  Run Keyword and Return Status
        ...  Dictionary Should Contain Key  ${NR_${alias}_Cell_LTE_Anchor_Cell_mapping}  ${nr_cell_id}
        ${lte_cell_id_dictionary}=  Set Variable If  '${nr_cell_exists}'=='True'  ${NR_${alias}_Cell_LTE_Anchor_Cell_mapping[${nr_cell_id}]}
        Run Keyword If  '${nr_cell_exists}'=='True'
        ...  Set To Dictionary  ${NRpci_lteCellId}  ${lte_cell_id_dictionary}  ${pci}
        Append To List  ${NR_all_PCI_list}  ${pci}
    END
    Set Test Variable  ${${alias}_NRpci_lteCellId}  ${NRpci_lteCellId}
    Set Test Variable  ${${alias}_NR_all_PCI_list}  ${NR_all_PCI_list}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Create lteCell Id NR pci mapping  ${lte_anchor}  ${alias}
    END
    Log  Mapping LTE anchor cell - NR ${alias} cell: ${LTE_Anchor_Cell_NR_Cell_mapping}  console=True
    Log  Mapping LTE anchor cell - PCI of NR Cell: ${NRpci_lteCellId}  console=True
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

Step ${index}: Perform Simultaneous call for both UEs on multiple sectors
    Log  Step ${index}: Perform Simultaneous call for both UEs on multiple sectors  console=True
    ${sector_index}=  Set Variable  0
    ${NR_Slave_PCIs_Covered}=  Create List
    Set Test Variable  ${NR_Slave_PCIs_Covered}
    ${NR_Master_Cell_ANTL_mapping}=  Get Cell ANTLN relation  NRCEL  Master
    ${NR_Slave_Cell_ANTL_mapping}=  Get Cell ANTLN relation  NRCEL  Slave
    Set Test Variable  ${NR_Master_Cell_ANTL_mapping}
    Set Test Variable  ${NR_Slave_Cell_ANTL_mapping}
    ${NR_Master_PCI_lst}=  Split String  ${CELLS_LIST_NR_MASTER_UE}  separator=
    ${NR_Master_PCI_lst}=  Set Variable If  '${NR_Master_PCI_lst[0].upper()}'=='DEFAULT'  ${Master_NR_all_PCI_list}  ${NR_Master_PCI_lst}
    ${NR_Slave_PCI_lst}=  Split String  ${CELLS_LIST_NR_SLAVE_UE}  separator=
    ${NR_Slave_PCI_lst}=  Set Variable If
    ...  '${NR_Slave_PCI_lst[0].upper()}'=='DEFAULT'  ${Slave_NR_all_PCI_list}
    ...  '${NR_Slave_PCI_lst[0].upper()}'=='ANY'  ${Slave_NR_all_PCI_list}
    ...  ${NR_Slave_PCI_lst}
    Set Test Variable  ${NR_Master_PCI_lst}
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    Set Test Variable  ${alias_UE1}  NR_Master_UE_alias
    Set Test Variable  ${alias_UE2}  NR_Slave_UE_alias
    Taf Ue Require Single UE  ue_alias=${alias_UE1}  capabilities=${NR_MASTER_UE_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_UE2}  capabilities=${NR_SLAVE_UE_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_UE1}, ${alias_UE2}  console=True

    Create NR PCI cellId mapping  Master
    Create NR PCI cellId mapping  Slave

    FOR  ${nr_PCI}  IN   @{NR_Master_PCI_lst}
         ${sector_index}=  Evaluate  ${sector_index}+1
         Log  ==============================================================================  console=True
         Log  Starting NR Master and NR Slave calls for sector number ${sector_index}  console=True
         Log  ==============================================================================  console=True
         ${nr_PCI_int}=  Convert To Integer  ${nr_PCI}
         ${nr_Master_cell_ID}=  Get From Dictionary  ${Master_NR_PCI_cellId_mapping}  ${nr_PCI_int}
         ${nr_slave_cell_id_same_sector_list}=  Find peer NR cell mapped on same sector  ${nr_Master_cell_ID}  Master
         ${nr_Master_cell_ID_str}=  Convert to String  ${nr_Master_cell_ID}
         Log  Performing NR Master and NR Slave call on sector ${sector_index}  console=True
         Log  NR Master PCI of the cell where NR call is performed is ${nr_PCI}  console=True
         Log  NR Slave cell(s) from same sector: ${nr_slave_cell_id_same_sector_list}. NR Slave UE should be attached on it!  console=True
         Log  Attenuating NR signal on all sectors  console=True
         Cut Cells Signal  tech=NR
         Log  Setting optimal signal level attenuation for current NR Master PCI: ${nr_PCI}  console=True
         Set Cell Attenuation  ${nr_Master_cell_ID_str}  0  NR  Master
         Perform Simultaneous call for both UEs  ${nr_PCI}  ${nr_slave_cell_id_same_sector_list}
    END
    Run Keyword If  '${CELLS_LIST_NR_SLAVE_UE}'=='ANY'  Return From Keyword
    ${NR_Slave_PCIs_Covered}=  Remove Duplicates  ${NR_Slave_PCIs_Covered}
    Log  Searching for uncovered NR Slave cells  console=True
    FOR  ${nr_PCI}  IN   @{NR_Slave_PCI_lst}
        Continue For Loop If  ${nr_PCI} in ${NR_Slave_PCIs_Covered}
        Log  Found uncovered NR Slave cell: ${nr_PCI}  console=True
        ${nr_PCI_int}=  Convert To Integer  ${nr_PCI}
        ${nr_Slave_cell_ID}=  Get From Dictionary  ${Slave_NR_PCI_cellId_mapping}  ${nr_PCI_int}
        ${nr_slave_cell_id_same_sector_list}=  Find peer NR cell mapped on same sector  ${nr_Slave_cell_ID}  Slave
        ${nr_Slave_cell_ID_str}=  Convert to String  ${nr_Slave_cell_ID}
        Log  Attenuating NR signal on all sectors  console=True
        Cut Cells Signal  tech=NR
        Log  Setting optimal signal level attenuation for current NR Slave PCI: ${nr_PCI}  console=True
        Set Cell Attenuation  ${nr_Slave_cell_ID_str}  0  NR  Slave
        Perform NR Attach  Slave  ${nr_PCI}
        Log  Succesfully attached NR Slave UE on ${nr_Slave_cell_ID_str}/${nr_PCI}  console=True
        ${nr_master_cell_id_int}=  Convert To Integer  ${nr_slave_cell_id_same_sector_list[0]}
        ${nr_master_PCI}=  Get From Dictionary  ${Master_NRCellid_PCI}  ${nr_master_cell_id_int}
        Perform NR Attach  Master  ${nr_master_PCI}
        Log  Succesfully attached NR Master UE on ${nr_master_cell_id_int}/${nr_master_PCI}  console=True
        Log  Succesfully attached both UEs on expected cells  console=True
        Perform data call for both NR UEs
    END

Find peer NR cell mapped on same sector
    [Arguments]  ${nr_pci}  ${alias}
    ${peer_alias}=  Set Variable If  '${alias}'=='Master'  Slave  Master
    ${cells_mapped_same_sector}=  Create List  @{EMPTY}
    FOR  ${key}  IN  @{NR_${peer_alias}_Cell_ANTL_mapping}
        ${status}=  Run Keyword And Return Status   Lists Should Be Equal   ${NR_${peer_alias}_Cell_ANTL_mapping["${key}"]}
        ...  ${NR_${alias}_Cell_ANTL_mapping["${nr_pci}"]}
        Run Keyword If  ${status}  Run Keywords
        ...  Log  NR ${peer_alias} cell mapped on same sector found: ${key}  console=True
        ...  AND  Append To List  ${cells_mapped_same_sector}  ${key}
    END
    ${list_len}=    Get length    ${cells_mapped_same_sector}
    Run Keyword If  ${list_len}==0
    ...  Fail  Could not find NR ${peer_alias} cell mapped on same sector with NR ${alias} PCI ${nr_pci}!
    [Return]  ${cells_mapped_same_sector}

Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    [Arguments]  ${nr_cell_id}  ${nr_slave_cell_ids_list}

    Log  Attempting to attach UEs on expected cells  console=True
    ${attach_performed}=  Set Variable  False

    Log  Attaching NR Master UE  console=True
    Perform NR Attach  Master  ${nr_cell_id}
    Log  Succesfully Attached NR Master UE  console=True

    FOR  ${nr_slave_cell_id}  IN  @{nr_slave_cell_ids_list}
        ${nr_slave_cell_id_int}=  Convert To Integer  ${nr_slave_cell_id}
        ${nr_slave_PCI}=  Get From Dictionary  ${Slave_NRCellid_PCI}  ${nr_slave_cell_id_int}
        Run Keyword If
        ...  ${nr_slave_PCI} in ${NR_Slave_PCIs_Covered} and '${CELLS_LIST_NR_SLAVE_UE}' != 'ANY'
        ...  Run Keyword If   '${nr_slave_cell_id}' != '${nr_slave_cell_ids_list[-1]}'
        ...  Continue For Loop
        Log  Attaching NR Slave UE  console=True
        ${status_call_NR_Slave_UE}=  Run Keyword And Return Status  Perform NR Attach  Slave  ${nr_slave_PCI}
        Run Keyword If  ${status_call_NR_Slave_UE}  Run Keywords
        ...  Log  Succesfully Attached NR Slave UE on cell ID: ${nr_slave_cell_id}/${nr_slave_PCI}  console=True
        ...  AND  Run Keyword If  '${CELLS_LIST_NR_SLAVE_UE}' != 'ANY'  Append To List  ${NR_Slave_PCIs_Covered}  ${nr_slave_PCI}
        Run Keyword If  not ${status_call_NR_Slave_UE} and '${CELLS_LIST_NR_SLAVE_UE}' != 'ANY'
        ...  Fail  Cannot perform attach on NR Slave cell ${nr_slave_cell_id}/${nr_slave_PCI}! while NR Master UE attached on ${nr_cell_id}!
        Run Keyword If  not ${status_call_NR_Slave_UE} and '${CELLS_LIST_NR_SLAVE_UE}'=='ANY'
        ...  Continue For Loop
        ${attach_performed}=  Set Variable  True
        Log  Succesfully Attached NR Slave UE  console=True
        Log  Succesfully attached both UEs on expected cells  console=True
        Perform data call for both NR UEs
        Exit For Loop
    END

    Run Keyword If  not ${attach_performed}
    ...  Fail  For NR Master Cell ${nr_cell_id} attach cannot be performed on it and/or peer BTS cells!

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Proceed to data transfer start on NR ${alias} UE
    ${ue_index}=  Set Variable If  '${alias}'=='Master'  1  '${alias}'=='Slave'  2
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_NR_${alias.upper()}_UE}
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

Await data call finish on NR ${alias} UE
    ${ue_index}=  Set Variable If  '${alias}'=='Master'  1  '${alias}'=='Slave'  2
    Translate Call Direction  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_dl

Stop and check data call on NR ${alias} UE
    ${ue_index}=  Set Variable If  '${alias}'=='Master'  1  '${alias}'=='Slave'  2
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_NR_${alias.upper()}_UE}
    Translate Call Direction  ${CALL_DIRECTION_NR_${alias.upper()}_UE}
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_UE${ue_index}}  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL}
    ...  ${downlink_MIN_TPUT_NR_${alias.upper()}_UE}  ${downlink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_dl
    ...  tput_min=${downlink_MIN_TPUT_NR_${alias.upper()}_UE}  tput_max=${downlink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Taf Ue Solution display actual throughput values  ${alias_UE${ue_index}}  data_transfer_UE_${ue_index}_dl  dl  ${PROTOCOL}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=data_transfer_UE_${ue_index}_dl
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keywords
    ...  Taf Ue Solution display expected throughput values  ${alias_UE${ue_index}}  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL}
    ...  ${uplink_MIN_TPUT_NR_${alias.upper()}_UE}  ${uplink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    ...  tput_min=${uplink_MIN_TPUT_NR_${alias.upper()}_UE}  tput_max=${uplink_MAX_TPUT_NR_${alias.upper()}_UE}
    ...  AND  Taf Ue Solution display actual throughput values  ${alias_UE${ue_index}}  data_transfer_UE_${ue_index}_ul  ul  ${PROTOCOL}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=data_transfer_UE_${ue_index}_ul
    Log  Stop and check data call for UE ${alias_UE${ue_index}} finished succesfully!  console=True

Perform NR Attach
    [Arguments]  ${alias}  ${nr_pci}
    ${ue_index}=  Set Variable If  '${alias}'=='Master'  1  '${alias}'=='Slave'  2
    ${all_NR_PCIs}=  Create List  ${nr_pci}
    ${NRpci_lteCellId_keys}=  Get Dictionary Keys  ${${alias}_NRpci_lteCellId}
    ${current_anchor_cell}=  Set Variable  None
    FOR  ${key}  IN  @{NRpci_lteCellId_keys}
        ${current_anchor_cell}=  Set Variable If  ${nr_pci} in ${${alias}_NRpci_lteCellId[${key}]}  ${key}  ${current_anchor_cell}
    END
    ${current_anchor_cell_str}=  Convert To String  ${current_anchor_cell}
    Log  Anchor cell for current NR PCI ${nr_pci} identified: ${current_anchor_cell_str}  console=True
    ${current_anchor_cell}=  Create List  ${current_anchor_cell_str}
    Set Test Variable  ${NRCellid_PCI}  ${${alias}_NRCellid_PCI}
    ${nr_cell_id}=  Taf Ue Get NR cell ID based on PCI  ${nr_pci}
    ${current_nr_pci}=  Create List  ${nr_pci}
    ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
    ${mbn_profile_used}=  Set Variable If  '${mbn_profile}' == 'None'  False  True
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${NR_${alias.upper()}_UE_CAPABILITIES}  ${mbn_profile_used}
    Taf Ue Set target NR cell from defaultLnRelGnbCellId  ${current_anchor_cell_str}  ${nr_cell_id}  LTE_${alias.upper()}
    Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
    Run Keyword If  '${CHECK_NR_${alias.upper()}_ATTACH}' == 'QCAT'  Run Keywords
    ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
    ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}
    ...  timeout=30
    ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
    ...  AND  Log  Qualcomm license was acquired!  console=True
    ${status1}=  Run Keyword And Return Status
    ...  Taf Ue Perform attach and check cell  ue_alias=${alias_UE${ue_index}}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${alias}
    Run Keyword If  '${status1}' == 'False' and '${CHECK_NR_${alias.upper()}_ATTACH}' != 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${alias_UE${ue_index}}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE${ue_index}}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${alias}
    ...  ELSE IF  '${status1}' == 'False' and '${CHECK_NR_${alias.upper()}_ATTACH}' == 'QCAT'  Run Keywords
    ...  Log  First attempt was not successful so the UE will be reseted!  console=True
    ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
    ...  AND  Sleep  60s
    ...  AND  taf.ue.Detach Ue  ue_alias=${alias_UE${ue_index}}  timeout=300
    ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
    ...  ${mbn_profile}
    ...  AND  Taf Ue Perform attach and check cell  ue_alias=${alias_UE${ue_index}}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
    ...  check_nr_attach=${CHECK_NR_${alias.upper()}_ATTACH}
    ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${alias}

Perform data call for both NR UEs
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
    Log  Detaching UEs  console=True
    Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    Log  Succesfully released usage of UEs  console=True

Create lteCell Id NR pci mapping
    [Arguments]  ${lte_anchor}  ${alias}
    ${current_nr_pci_list}=  Create List  @{EMPTY}
    FOR  ${nr_id}  IN  @{LTE_Anchor_Cell_NR_${alias}_Cell_mapping[${lte_anchor}]}
        Append To List  ${current_nr_pci_list}  ${${alias}_NRCellid_PCI[${nr_id}]}
    END
    Set To Dictionary  ${${alias}_NRpci_lteCellId}  ${lte_anchor}  ${current_nr_pci_list}

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Get nrCellIds anchor mapping
    [Arguments]  ${alias}
    ${dict}=  Create Dictionary  @{EMPTY}
    Set Test Variable  ${NR_${alias}_Cell_LTE_Anchor_Cell_mapping}  ${dict}
    ${LTE_anchor_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_${alias}_Cell_mapping}
    FOR  ${LTE_anchor}  IN  @{LTE_anchor_keys}
       ${NRCellid_list}=  Get From Dictionary  ${LTE_Anchor_Cell_NR_${alias}_Cell_mapping}  ${LTE_anchor}
       Mapping anchor to nrCellIds  ${NRCellid_list}  ${LTE_anchor}  ${alias}
    END

Mapping anchor to nrCellIds
    [Arguments]  ${NRCellid_list}  ${LTE_anchor}  ${alias}
    FOR  ${nr_cell_id}  IN  @{NRCellid_list}
       Set To Dictionary  ${NR_${alias}_Cell_LTE_Anchor_Cell_mapping}  ${nr_cell_id}  ${LTE_anchor}
    END

Create NR PCI cellId mapping
    [Arguments]  ${alias}
    ${NR_PCI_cellId_mapping}=  Create Dictionary  @{EMPTY}
    ${nr_cell_list}=  Get Ids For All  NRCEL  ${alias}
    FOR  ${cell_id}  IN  @{nr_cell_list}
        ${NR_cell_params}=  Get Parameters For  class_name=NRCEL  id_num=${cell_id}  timeout=10  alias=${alias}
        Set To Dictionary  ${NR_PCI_cellId_mapping}  ${NR_cell_params.physCellId}  ${NR_cell_params.nrCellIdentity}
    END
    Set Test Variable  ${${alias}_NR_PCI_cellId_mapping}  ${NR_PCI_cellId_mapping}

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
    Teardown Admin  alias=LTE_MASTER
    Teardown Admin  alias=LTE_SLAVE

Prepare External Admin Sessions
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_LTE1}  alias=LTE_MASTER
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_LTE2}  alias=LTE_SLAVE

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
