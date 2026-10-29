*** Settings ***
Documentation    TC__RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${LTE_ANCHOR_CELLS_LIST}    DEFAULT       # Specify the anchor cells list on which UE will be checked; Possible values: "DEFAULT" - means checking
                                          # if UE is camped on any anchor cell belonging to BTS; "30295 30294 30293" - User provides cells list with
                                          # space between Cells Id. Eutran Cell Id of anchor cell is used here
${USE_ATTENUATOR}    NO                   # Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
${CALL_DIRECTION}    downlink             # Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
${CALL_DURATION}    100                   # Duration of data call in seconds
${downlink_MAX_TPUT}    150 Mbits/sec     # Downlink Maximum acceptable t-put; acceptable values: e.q. LTE - 150 Mbits/sec
${downlink_MIN_TPUT}    145 Kbits/sec     # Downlink Minmum acceptable t-put; acceptable values: e.q. LTE - 5 Mbits/sec
${uplink_MAX_TPUT}    50 Mbits/sec        # Uplink Maximum acceptable t-put; acceptable values: e.q. LTE - 50 Mbits/sec
${uplink_MIN_TPUT}    78 Kbits/sec        # Uplink Minimum acceptable t-put; acceptable values: e.q. LTE - 3 Mbits/sec
${PROTOCOL}    udp                        # Data transfer protocol. e.q. udp, tcp, ftp
${BANDWIDTH}    60 Mbits/sec              # max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec
${UE_CAPABILITIES}    None                # For UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${CHECK_NR_ATTACH}    None                # Flag to check if attach was correctly performed on 5G; Possible values: None (default)/ADB
                                          # (check performed using adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory
                                          # to set primPlmnUpperLayerIndicationR15 to 1 on all LTE CELLS before test!)
                                          # /QCAT (check performed by analyzing RRC messages - Ue need to be disconnected from QXDM )
                                          # /AT (check performed using AT command AT+QENG="servingcell")- for Quectel UEs
                                          # /aashell - for checking NR attach from BTS based on resources usage
${DETACH_UE}    False                     # Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False
${SEPARATED_4G_5G}    False               # Specify whether modem's 5G and 4G chipsets are separated (For example, for QCT8150 this parameter should
                                          # be set True); This information is necessary in case CHECK_NR_ATTACH is set to QCAT;
                                          # Possible values: True/False. Default value: False
${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}    None  # for LTE paired with NR; BTS OAM IP address used to get anchor cell relation through Infomodel/Admin;
                                          # Default value: None; if set different than None, external anchor cell mechanism will be used
${NR_CELLS_LIST}    None                  # For case USE_ATTENUATOR; NR cells list on which UE will be checked, apart from the anchor cell chek; This
                                          # means also CHECK_NR_ATTACH feature should be used
${CHECK_ATTACH_ONLY}    False              # Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
                                          # Default value: False

*** Keywords ***
TC__RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25043
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing NR LTE NSA data transfer call for one UE.
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - LTE_ANCHOR_CELLS_LIST} ----  DEFAULT  Specify the anchor cells list on which UE will be checked; Possible values: "DEFAULT" - means
    ...
    ...                                      checking if UE is
    ...
    ...                                      camped on any anchor cell belonging to BTS; "30295 30294 30293" - User provides cells list with space
    ...
    ...                                      between Cells Id. Eutran Cell Id of anchor cell is used here
    ...
    ...  - USE_ATTENUATOR  ----  Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
    ...
    ...  - CALL_DIRECTION  ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DURATION   ----  Duration of data call in seconds
    ...
    ...  - downlink_MAX_TPUT     ----  Downlink Maximum acceptable t-put; acceptable values: e.q. LTE - 150 Mbits/sec
    ...
    ...  - downlink_MIN_TPUT     ----  Downlink Minmum acceptable t-put; acceptable values: e.q. LTE - 5 Mbits/sec
    ...
    ...  - uplink_MAX_TPUT     ----  Uplink Maximum acceptable t-put; acceptable values: e.q. LTE - 50 Mbits/sec
    ...
    ...  - uplink_MIN_TPUT     ----  Uplink Minimum acceptable t-put; acceptable values: e.q. LTE - 3 Mbits/sec
    ...
    ...  - PROTOCOL        ----  Data transfer protocol. e.q. udp, tcp, ftp
    ...
    ...  - BANDWIDTH       ----  max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec
    ...
    ...  - UE_CAPABILITIES ----  For UE - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - CHECK_NR_ATTACH ----  Flag to check if attach was correctly performed on 5G; Possible values: None (default)/ADB (check performed using
    ...  adb commands - only applicable for CLASS: AndroidUe, for this check is mandatory to set primPlmnUpperLayerIndicationR15 to 1 on all LTE
    ...  CELLS before test!)/QCAT (check performed by analyzing RRC messages - check performed by analyzing RRC messages - QCAT license need to be
    ...  activated before test start, and Ue need to be disconnected from QXDM)/AT (check performed using AT command AT+QENG="servingcell")
    ...  for Quectel UEs
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False
    ...
    ...  - SEPARATED_4G_5G ---- Specify whether modem's 5G and 4G chipsets are separated (For example, for QCT8150 this parameter should be
    ...
    ...                                   set True); This information is necessary in case CHECK_NR_ATTACH is set to QCAT;
    ...
    ...                                   Possible values: True/False. Default value: False
    ...
    ...  - BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE  ----    for LTE paired with NR; BTS OAM IP address used to get anchor cell relation through
    ...
    ...                                                Infomodel/Admin;
    ...
    ...                                                Default value: None; if set different than None, external anchor cell mechanism will be used
    ...
    ...  - NR_CELLS_LIST                      ----    For case USE_ATTENUATOR; NR cells list on which UE will be checked, apart from the anchor cell
    ...
    ...                                                check; This means also CHECK_NR_ATTACH feature should be used
    ...
    ...  - CHECK_ATTACH_ONLY                  ----  Flag for skipping data transfer part and perform check of attach only; Possible values: True/False
    ...                                             Default value: False
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 08.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25043 - TC Delivery (migration to taf.ue)
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25380 - [Calls] Remove Particular Setup from 3 RRM TCs
    ...  - 02.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25606 - [5G][Refactoring][CNI-85214] LNRELGNBCELL_R object
    ...  refactoring - RRM__RFS__NR_LTE_NSA_Data_Transfer_Taf_Ue
    ...  - 23.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26300 - [5G] RRM__RFS__NR_LTE_NSA_Data_Transfer_Ute_Ue must be updated for
    ...  RF Split case to use the proper variable: SBTS_LTE_cell_ids instead of LTE_cell_ids
    ...  - 26.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23288 - [Calls] Change Call TCs naming convention
    ...  - 13.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26311 - Add attach only option
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27687 - [Calls] Make call tests independent of Particular Setup
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25043_RRM__RFS__NR_LTE_NSA_Data_Transfer_Taf_Ue.png


    Set Tags    CA-RRM    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-CR1
    ...    SBTS23R3    CABLING-RFS_01_UE

    Prepare External Admin Sessions
    Step 1: Get LTE Anchor Cells List and NR Cells Mapping
    Step 2: Start data transfer on NR LTE NSA
    Step 3: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

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
    Log  Mapping LTE anchor cell - NR cell: ${LTE_Anchor_Cell_NR_Cell_mapping}  console=True
    ${LTE_Anchor_Cell_NR_Cell_mapping_keys}=  Get Dictionary Keys  ${LTE_Anchor_Cell_NR_Cell_mapping}
    FOR  ${lte_anchor}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping_keys}
        Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None' and '${lte_anchor}' not in ${cells_list}  Continue For Loop
        Create lteCell Id NR pci  ${lte_anchor}
    END
    Log  Mapping LTE anchor cell - PCI of NR Cell: ${NRpci_lteCellId}  console=True
    ${cells_list_tmp}=  Create List  @{EMPTY}
    Log  Omitting non-anchor LTE cells from cells list  console=True
    FOR  ${cell}  IN  @{cells_list}
        Run Keyword If  ${cell} in ${LTE_Anchor_Cell_NR_Cell_mapping_keys}  Append To List  ${cells_list_tmp}  ${cell}
    END
    Set Test Variable  ${cells_list}  ${cells_list_tmp}
    ${cells_list_len}=  Get Length  ${cells_list}
    Run Keyword If  '${cells_list_len}' == '0'
    ...  Fail  No anchor cells among cell list eligible for NR LTE NSA call!
    ...  ELSE  Log  List of anchor cells eligible for NR LTE NSA call is: ${cells_list}  console=True
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${lte_ues}  ${ue_list}
    ${NR_CELLS_lst}=  Split String  ${NR_CELLS_LIST}  separator=
    ${cells_list_call}=  Set Variable If  '${NR_CELLS_LIST}' != 'None'  ${NR_CELLS_lst}  ${cells_list}
    ${timeout}=  Taf Ue Calculate Call Step Timeout  call_duration=${CALL_DURATION}  call_type=data  call_direction=${CALL_DIRECTION}
    ...  cells_list=${cells_list_call}  techno=LTE  attenuator=${USE_ATTENUATOR}
    Set Test Variable  ${timeout}

Step ${index}: Start data transfer on NR LTE NSA
    [Timeout]   ${timeout}
    Log  Step ${index}: Start data transfer on NR LTE NSA  console=True
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION.lower()}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL.lower()}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    ${ue_index}=  Set Variable  1
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${CALL_DIRECTION}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    ${NR_CELL_lst}=  Split String  ${NR_CELLS_LIST}  separator=
    ${common_args_dict}=  Create Dictionary
    ...  admin_alias=Master
    ...  anchor_alias=${alias_lte}
    ...  TECHNO=NR
    ...  TECHNO_ANCHOR=LTE
    ...  USE_ATTENUATOR=${USE_ATTENUATOR}
    ...  cells_list=${cells_list}
    ...  CALL_DURATION=${CALL_DURATION}
    ...  call_type=data
    ...  PROTOCOL=${PROTOCOL}
    ...  BANDWIDTH=${BANDWIDTH}
    ...  call_direction=${CALL_DIRECTION}
    ...  capabilities=${UE_CAPABILITIES}
    ...  nr_cells_list=${NR_CELL_lst}
    ...  attach_only=${CHECK_ATTACH_ONLY}

    Log  Start data call for NR LTE NSA  console=True
    ${LK_USERNAME}=  Set Variable If  '${CHECK_NR_ATTACH}' != 'QCAT'  ${EMPTY}  ${LK_USERNAME}
    ${LK_PASSWORD}=  Set Variable If  '${CHECK_NR_ATTACH}' != 'QCAT'  ${EMPTY}  ${LK_PASSWORD}
    ${ue_alias}=  Run Keyword If  '${NR_CELLS_LIST}' == 'None'
    ...  Taf Ue Perform taf ue data call with one UE on cell list  ${common_args_dict}  ${ue_index}
    ...  ${DETACH_UE}  ${CHECK_NR_ATTACH}  lk_username=${LK_USERNAME}  lk_password=${LK_PASSWORD}  separated_4g_5g_on_mdm=${SEPARATED_4G_5G}
    ...  ELSE  Taf Ue Perform taf ue data call with one UE on NR cell list  ${common_args_dict}  ${ue_index}  ${DETACH_UE}  ${CHECK_NR_ATTACH}
    ...  lk_username=${LK_USERNAME}  lk_password=${LK_PASSWORD}  separated_4g_5g_on_mdm=${SEPARATED_4G_5G}
    Log  End data call for NR LTE NSA  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Create lteCell Id NR pci
    [Arguments]  ${lte_anchor}
    ${current_nr_pci_list}=  Create List  @{EMPTY}
    FOR  ${nr_id}  IN  @{LTE_Anchor_Cell_NR_Cell_mapping[${lte_anchor}]}
        Append To List  ${current_nr_pci_list}  ${NRCellid_PCI[${nr_id}]}
    END
    Set To Dictionary  ${NRpci_lteCellId}  ${lte_anchor}  ${current_nr_pci_list}

Get Cells List for RF Sharing
    ${alias_lte}=  Set Variable If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  Slave  LTE_EXT_SLAVE
    Set Test Variable  ${alias_lte}
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=Master
    ${LTE_cell_ids}=  Get Ids For All  LNCEL  alias=Slave
    Set Test Variable  ${nr_cell_list}
    ${cells_list}=  Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'
    ...  Particular Get Cells list  TECHNO=LTE_EXT_SLAVE  CELLS_LIST_param=${LTE_ANCHOR_CELLS_LIST}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'LTE'  Get Cells list  TECHNO=LTE  CELLS_LIST=${LTE_ANCHOR_CELLS_LIST}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'SBTS'  Get Cells list  TECHNO=SBTS_LTE  CELLS_LIST=${LTE_ANCHOR_CELLS_LIST}
    Set Test Variable  ${cells_list}
    ${LTE_cell_ids_tmp}=  Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'  Admin Get LTE CELL Ids list  LTE_EXT_SLAVE
    ...  ELSE  Set Variable  ${LTE_cell_ids}
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'!='None'  Set Test Variable  ${LTE_cell_ids}  ${LTE_cell_ids_tmp[0]}
    ...  ELSE  Set Test Variable  ${LTE_cell_ids}  ${LTE_cell_ids_tmp}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_cell_ids}  ${alias_lte}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get Cells List for RF Split
    ${alias_lte}=  Set Variable If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  ${alias_local}  LTE_EXT_SLAVE
    Set Test Variable  ${alias_lte}
    ${nr_cell_list}=  Get Ids For All  NRCEL  alias=${alias_local}
    ${SBTS_LTE_cell_ids}=  Get Ids For All  LNCEL  alias=${alias_lte}
    Set Test Variable  ${nr_cell_list}
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Get SBTS Cell Ids from admin  ${alias_lte}  LTE
    ${cell_count}=  Get Length  ${cells_list}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No LTE cells are found on BTS!  level=ERROR
    ...  AND  Fail  No LTE cells are found on BTS!
    Sort list  ${cells_list}
    Set Test Variable  ${cells_list}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${SBTS_LTE_cell_ids}  ${alias_lte}
    Set Test Variable  ${LTE_Anchor_Cell_NR_Cell_mapping}

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Particular Get Cells list
    [Arguments]  ${TECHNO}  ${CELLS_LIST_param}
    ${get_bts_cells_list}=  Set Variable If  '${CELLS_LIST_param}' == 'DEFAULT'  ${True}  ${False}
    ${cells_list}=  Run Keyword If  '${CELLS_LIST_param}' != 'DEFAULT'  Split String  ${CELLS_LIST_param}
    Run Keyword If  not ${get_bts_cells_list}  Return From Keyword  ${CELLS_LIST_param}
    ${cells_list}=  Get LTE Eutran Cell Ids from admin  ${TECHNO}
    ${cell_count}=  Get Length  ${cells_list}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No ${TECHNO} cells are found on BTS!  level=ERROR
    ...  AND  Fail  No ${TECHNO} cells are found on BTS!
    Sort list  ${cells_list}
    [Return]  ${cells_list}

Prepare External Admin Sessions
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  Return From Keyword
    Wait until keyword succeeds  10 min  5 sec  Start ADMIN On External BTS  bts_mplane_ip=${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}  alias=LTE_EXT_SLAVE

Particular Teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs
    Run Keyword If  '${CHECK_NR_ATTACH}' == 'QCAT'  Run Keywords
    ...  Taf Ue Release QXDM/QCAT 5G License  QCAT
    ...  AND  Log  Qualcomm license was released!  console=True
    ...  AND  Taf Ue License Keeper Teardown
    Run Keyword If  '${BTS_OAM_IP_ADDRESS_ANCHOR_EXT_LTE}'=='None'  Return From Keyword
    Teardown Admin  alias=LTE_EXT_SLAVE

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
