*** Settings ***
Documentation  Call and throughput management
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections

Resource    ./egate_and_uexgate.robot
Resource    ./admin.robot
Resource    ./bts_actions.robot
Resource    ../../resources/Robot/scfc.robot
Resource    ../../resources/operations.robot

*** Keywords ***
Change Cell And Subcell Dictionary
    [Arguments]  ${cell_subcell_dict}
    [Documentation]
    ...  Description:
    ...  Keyword prepares the appropriate dictionaries of cells (subcells) for uexgate purposes.
    ...  Keyword prepares the appropriate dictionaries of cells (subcells) for making call with the
    ...  throughput measurement depending on whether the Supercell or Combined Supercell feature is enabled or not.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_subcell_dict      | Yes  | Cell subcells dictionary.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dict_keys_lcr_ids}=  Get Dictionary Keys  dictionary=${cell_subcell_dict}
    ${dict_keys_lcr_ids}=  Convert List to Integer  list_to_convert=${dict_keys_lcr_ids}
    Sort List  ${dict_keys_lcr_ids}
    ${dict_keys_lcr_ids}=  Convert List to String  list_to_convert=${dict_keys_lcr_ids}
    #CREATE DICTIONARY ${cell_subcell_dict}
    FOR  ${lcr_id}  IN  @{dict_keys_lcr_ids}
      ${subcell_ids}=  Get From Dictionary  dictionary=${cell_subcell_dict}  key=${lcr_id}
      ${subcell_ids_count}=  Get Length  item=${subcell_ids}
      Run Keyword If  ${subcell_ids_count}==0  Set To Dictionary  ${cell_subcell_dict}  ${lcr_id}  1
    END
    #CREATE DICTIONARY ${cell_subcell_dict_uexgate} IF SUBCELLS NOT EXIST
    ${cell_subcell_dict_uexgate}=  Copy Dictionary  dictionary=${cell_subcell_dict}
    FOR  ${lcr_id}  IN  @{dict_keys_lcr_ids}
      ${subcell_ids}=  Get From Dictionary  dictionary=${cell_subcell_dict}  key=${lcr_id}
      ${subcell_ids_count}=  Get Length  item=${subcell_ids}
      ${subcell_id}=  Convert To Integer  item=${lcr_id}
      ${new_subcell_ids}=  Create List  ${subcell_id}
      Set To Dictionary  ${cell_subcell_dict_uexgate}  ${lcr_id}  ${new_subcell_ids}
      Exit For Loop If  ${subcell_ids_count}>1
    END
    Return From Keyword If  ${subcell_ids_count}==1  ${cell_subcell_dict_uexgate}  ${cell_subcell_dict}
    #CREATE DICTIONARY ${cell_subcell_dict_uexgate} IF SUBCELLS EXIST
    ${cell_number}=  Evaluate  0
    ${cell_subcell_dict_uexgate}=  Copy Dictionary  dictionary=${cell_subcell_dict}
    FOR  ${lcr_id}  IN  @{dict_keys_lcr_ids}
      ${subcell_ids}=  Get From Dictionary  dictionary=${cell_subcell_dict_uexgate}  key=${lcr_id}
      ${new_subcell_ids}  ${cell_number}=
      ...  Change Subcells Number  subcell_ids=${subcell_ids}  cell_number=${cell_number}
      Set To Dictionary  ${cell_subcell_dict_uexgate}  ${lcr_id}  ${new_subcell_ids}
    END
    [Return]  ${cell_subcell_dict_uexgate}  ${cell_subcell_dict}

Change Subcells Number
    [Arguments]  ${subcell_ids}  ${cell_number}
    [Documentation]
    ...  Description:
    ...  Keyword renumbering the subcells of cell.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | subcell_ids            | Yes  | List of subcells number.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_number            | Yes  | Cell number.                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${subcell_ids_count}=  Get Length  item=${subcell_ids}
    @{new_subcell_ids}=  Create List
    FOR  ${item}  IN RANGE  ${subcell_ids_count}
      ${cell_number}=  Evaluate  ${cell_number}+1
      Append To List  ${new_subcell_ids}  ${cell_number}
    END
    [Return]  ${new_subcell_ids}  ${cell_number}

CUS Call With Throughput Measurement
    [Arguments]  ${scfc_file_path}  ${lcr_id_list}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword maps the cells and subcells read from the SCFC to those defined for CUS.
    ...  Keyword prepares a list of cells to make a call with throughput measurement.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | number_of_call         |  No  | The number of call.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_list            |  No  | List of cells on which call is performed                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_subcell_dict}=  SCFC Create Cell And Subcell Dictionary  scfc_file_path=${scfc_file_path}
    ${cell_subcell_dict_uexgate}  ${cell_subcell_dict}=
    ...  Change Cell And Subcell Dictionary  cell_subcell_dict=${cell_subcell_dict}
    ${lcr_id_not_iot_list}=  SCFC Create Not IoT LcrId List  scfc_file_path=${scfc_file_path}
    ${lcr_id_iot_list}=  SCFC Create IoT LcrId List  scfc_file_path=${scfc_file_path}
    ${lcr_id_catm_list}=  SCFC Create CatM LcrId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_not_iot_list}
    Run Keyword If  ${lcr_id_catm_list}!=@{EMPTY}
    ...  Set Catm Ue Capabilities  configuration_id_list=${lcr_id_catm_list}
    IF  ${lcr_id_list}==@{EMPTY}
      ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    END
    ${mplane_only_sector_numbers_list}=  CUS Get Mplane Only Sector List  cusini_file_path=${CUSINI_FILE_PATH}
    Remove Values From List  ${lcr_id_list}  @{mplane_only_sector_numbers_list}
    ${rxtx_lcr_id_list}=  SCFC Get RxTx Cells List  scfc_file_path=${scfc_file_path}  cells_list=${lcr_id_list}
    ${rxtx_lcr_id_list}=  Convert List to Integer  list_to_convert=${rxtx_lcr_id_list}
    Sort List  ${rxtx_lcr_id_list}
    Log  ${dots_prefix_green}Call with throughput measurement to the cells (lcrid): ${rxtx_lcr_id_list}
    ...  console=${log_to_console}
    ${rxtx_lcr_id_list}=  Convert List to String  list_to_convert=${rxtx_lcr_id_list}
    FOR  ${lcr_id}  IN  @{rxtx_lcr_id_list}
      ${iot_cell_exists}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_iot_list}  ${lcr_id}
      ${catm_cell_exists}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_catm_list}  ${lcr_id}
      CUS Basic Call
      ...  lcr_id=${lcr_id}
      ...  cell_subcell_dict_uexgate=${cell_subcell_dict_uexgate}
      ...  cell_subcell_dict=${cell_subcell_dict}
      ...  scfc_file_path=${scfc_file_path}
      ...  iot_cell_exists=${iot_cell_exists}
      ...  catm_cell_exists=${catm_cell_exists}
    END

CUS Block Unblock And Call With Throughput Measurement
    [Arguments]  ${scfc_file_path}  ${lcr_id_block_list}=ALL  ${basic_call}=True  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword maps the cells and subcells read from the SCFC to those defined for CUS.
    ...  Keyword prepares a list of cells to perform block and unblock procedure and executes (or not)
    ...  the call with throughput measurement on every cell.
    ...  The cell list is read from the SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_block_list      |  No  | The list of cells to block.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  basic_call            |  No  | Call should be executed or not.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_subcell_dict}=  SCFC Create Cell And Subcell Dictionary  scfc_file_path=${scfc_file_path}
    ${cell_subcell_dict_uexgate}  ${cell_subcell_dict}=
    ...  Change Cell And Subcell Dictionary  cell_subcell_dict=${cell_subcell_dict}
    ${cells_count}=  SCFC Get Cells Count  scfc_file_path=${scfc_file_path}
    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${mplane_only_sector_numbers_list}=  CUS Get Mplane Only Sector List  cusini_file_path=${CUSINI_FILE_PATH}
    Remove Values From List  ${lcr_id_list}  @{mplane_only_sector_numbers_list}
    ${all_list_status}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${lcr_id_block_list}  ALL
    ${random_list_status}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${lcr_id_block_list}  RANDOM
    ${lcr_id_list}=  Run Keyword If  ${all_list_status}
    ...  Copy List  ${lcr_id_list}
    ...  ELSE IF  ${random_list_status}
    ...  Get Random List Based On Input List  list=${lcr_id_list}  length=${lcr_id_block_list[1]}
    ...  ELSE
    ...  Create List  @{lcr_id_block_list}
    ${lcr_id_list}=  Convert List to Integer  list_to_convert=${lcr_id_list}
    Sort List  ${lcr_id_list}
    Log  ${dots_prefix_green}The following cells (lcrid) will be blocked/unblocked: ${lcr_id_list}
    ...  console=${log_to_console}
    ${lcr_id_list}=  Convert List to String  list_to_convert=${lcr_id_list}
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${lcr_id_not_iot_inband_guardband_list}=  SCFC Create Not IoT Inband And Guardband LcrId List
    ...  scfc_file_path=${scfc_file_path}
    ${lcr_id_not_iot_list}=  SCFC Create Not IoT LcrId List  scfc_file_path=${scfc_file_path}
    ${lcr_id_iot_list}=  SCFC Create IoT LcrId List  scfc_file_path=${scfc_file_path}
    ${lcr_id_catm_list}=  SCFC Create CatM LcrId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_not_iot_list}
    Run Keyword If  ${lcr_id_catm_list}!=@{EMPTY}
    ...  Set Catm Ue Capabilities  configuration_id_list=${lcr_id_catm_list}
    ${lcr_id_rx_list}=  SCFC Get RxTx Cells List
    ...  scfc_file_path=${scfc_file_path}  cells_list=${lcr_id_list}
    FOR  ${lcr_id}  IN RANGE  ${cells_count}
      ${result_not_iot_inband_guardband}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_not_iot_inband_guardband_list}  ${lcr_id_list[${lcr_id}]}
      Run Keyword If  ${result_not_iot_inband_guardband}
      ...  BTS Cell Block Unblock And Check  scfc_file_path=${scfc_file_path}
      ...  lcr_id=${lcr_id_list[${lcr_id}]}  lncel_id=${lncel_id_list[${lcr_id}]}
      ...  log_prefix=${info_prefix}
      ${iot_cell_exists}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_iot_list}  ${lcr_id_list[${lcr_id}]}
      ${catm_cell_exists}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_catm_list}  ${lcr_id_list[${lcr_id}]}
      ${result_lcr_id_rx_list}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_rx_list}  ${lcr_id_list[${lcr_id}]}
      Run Keyword If  ${result_lcr_id_rx_list} and ${basic_call}
      ...  CUS Basic Call
      ...  lcr_id=${lcr_id_list[${lcr_id}]}
      ...  cell_subcell_dict_uexgate=${cell_subcell_dict_uexgate}
      ...  cell_subcell_dict=${cell_subcell_dict}
      ...  scfc_file_path=${scfc_file_path}
      ...  iot_cell_exists=${iot_cell_exists}
      ...  catm_cell_exists=${catm_cell_exists}
    END

CUS Basic Call
    [Arguments]  ${lcr_id}  ${cell_subcell_dict_uexgate}  ${cell_subcell_dict}
    ...  ${scfc_file_path}  ${iot_cell_exists}  ${catm_cell_exists}
    [Documentation]
    ...  Description:
    ...  Keyword maps the standalone IoT cells read from the SCFC to those defined for CUS.
    ...  Keyword calculates the number of UEs used for different technologies (LTE, IoT, Catm).
    ...  Keyword starts basic call for the single cells.
    ...
    ...  Arguments:
    ...  +===========================+======+=========================================================================+
    ...  | Argument                  | Man. | Description                                                             |
    ...  +===========================+======+=========================================================================+
    ...  | lcr_id                    | Yes  | Lcr cell id.                                                            |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | cell_subcell_dict_uexgate | Yes  | Cell subcells dictionary for uexgate purposes.                          |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | cell_subcell_dict         | Yes  | Cell subcells dictionary.                                               |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | scfc_file_path            | Yes  | Path to the scfc file.                                                  |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | iot_cell_exists           | Yes  | Information whether there is an IoT cell.                               |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | catm_cell_exists          | Yes  | Information whether there is a CatM cell.                               |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${subcell_uexgate_list}=  Get From Dictionary  dictionary=${cell_subcell_dict_uexgate}  key=${lcr_id}
    ${subcell_list}=  Get From Dictionary  dictionary=${cell_subcell_dict}  key=${lcr_id}
    ${subcell_uexgate_count}=  Get Length  item=${subcell_uexgate_list}
    FOR  ${subcell_index}  IN RANGE  ${subcell_uexgate_count}
      ${ue_id_begin}=  Run Keyword If  ${iot_cell_exists}  Evaluate  ${UE_COUNT}+1
      ...  ELSE  Set Variable  1
      ${ue_id_end}=  Run Keyword If  ${iot_cell_exists}  Evaluate  ${UE_IoT_COUNT}+${UE_COUNT}
      ...  ELSE  Set Variable  ${UE_COUNT}
      ${subcell_uexgate}=  Run Keyword If  ${iot_cell_exists}
      ...  Change CUS IoT Standalone Cell Id  lncell_id=${subcell_uexgate_list[${subcell_index}]}
      ...  ELSE
      ...  Set Variable  ${subcell_uexgate_list[${subcell_index}]}
      ${packet_size}=  Run Keyword If  ${iot_cell_exists}  Set Variable  200
      ...  ELSE  Set Variable  1400
      CUS Basic Call For Single Cell
      ...  lcr_id=${lcr_id}
      ...  subcell_uexgate=${subcell_uexgate}
      ...  subcell=${subcell_list[${subcell_index}]}
      ...  scfc_file_path=${scfc_file_path}
      ...  ue_id_begin=${ue_id_begin}
      ...  ue_id_end=${ue_id_end}
      ...  packet_size=${packet_size}
      ${ue_id_begin}=  Run Keyword If  ${catm_cell_exists}  Evaluate  ${UE_COUNT}+${UE_IoT_COUNT}+1
      ${ue_id_end}=  Run Keyword If  ${catm_cell_exists}  Evaluate  ${UE_IoT_COUNT}+${UE_COUNT}+${UE_CATM_COUNT}
      ${packet_size}=  Run Keyword If  ${catm_cell_exists}  Set Variable  200
      Run Keyword If  ${catm_cell_exists}
      ...  CUS Basic Call For Single Cell
      ...  lcr_id=${lcr_id}
      ...  subcell_uexgate=${subcell_uexgate}
      ...  subcell=${subcell_list[${subcell_index}]}
      ...  scfc_file_path=${scfc_file_path}
      ...  ue_id_begin=${ue_id_begin}
      ...  ue_id_end=${ue_id_end}
      ...  packet_size=${packet_size}
      ...  act_catm=${catm_cell_exists}
    END

CUS Basic Call For Single Cell
    [Arguments]  ${lcr_id}  ${subcell_uexgate}  ${subcell}  ${scfc_file_path}
    ...  ${ue_id_begin}  ${ue_id_end}  ${packet_size}  ${act_catm}=False  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs attach to the single cell, verifies if succeed,
    ...  executes throughput measurement and detaches from the cell.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lcr_id                 | Yes  | Lcr cell id.                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | subcell_uexgate        | Yes  | Cell subcell number for uexgate purposes.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | subcell                | Yes  | Cell subcell number.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | packet_size            | Yes  | Packet size in Bytes per one direction                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | act_catm               | Yes  | Information whether there is a CatM cell.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${dots_prefix_green}Call to cell:${lcr_id} subcell:${subcell} cus cell:${subcell_uexgate}
    ...  console=${log_to_console}
    ${status_carel}=  Run Keyword If  ${CA_ACTIVATED}
    ...  Admin LNCEL CAREL Should Exist  lncel_id=${subcell_uexgate}
    ...  ELSE
    ...  Set Variable  False
    Run Keyword If  ${status_carel} and ${act_catm}==False
    ...  Uexgate Perform CA Attach  subcell_uexgate=${subcell_uexgate}
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}
    ...  ELSE
    ...  Uexgate Perform Attach  subcell_uexgate=${subcell_uexgate}
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}
    # Egate Verify If UE Is In Cell ${subcell_uexgate}
    Log  ${info_prefix}Attach from ue_id=${ue_id_begin} to ue_id=${ue_id_end} to cell ${subcell_uexgate} succeed
    ...  console=${log_to_console}
    ${lncel_id}=  SCFC Get LncelId For LcrId  scfc_file_path=${scfc_file_path}  lcr_id=${lcr_id}
    ${throughput_parameters}  ${bps_throughput}=  Run Keyword If  ${status_carel} and ${act_catm}==False
    ...  SCFC Get CA Cell Throughput Parameters
    ...  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
    ...  ELSE
    ...  SCFC Get Cell Throughput Parameters
    ...  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}  act_catm=${act_catm}
    Run Keyword If  ${act_catm}  Run Keywords
    ...  Uexgate Execute Half Duplex Throughput Measurement  traffic_direction=ul
    ...  throughput=${throughput_parameters[0]}  bps_throughput=${bps_throughput}
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}  packet_size=${packet_size}
    ...  AND
    ...  Uexgate Execute Half Duplex Throughput Measurement  traffic_direction=dl
    ...  throughput=${throughput_parameters[1]}  bps_throughput=${bps_throughput}
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}  packet_size=${packet_size}
    ...  ELSE
    ...  Uexgate Execute Full Duplex Throughput Measurement  ul_throughput=${throughput_parameters[0]}
    ...  dl_throughput=${throughput_parameters[1]}  bps_throughput=${bps_throughput}
    ...  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}  packet_size=${packet_size}
    Uexgate Perform Detach  subcell_uexgate=${subcell_uexgate}  ue_id_begin=${ue_id_begin}  ue_id_end=${ue_id_end}
    Log  ${info_prefix}Detach from ue_id=${ue_id_begin} to ue_id=${ue_id_end} from cell ${subcell_uexgate} succeed
    ...  console=${log_to_console}
    Log  ${ok_prefix_green}Call to cell:${lcr_id} subcell:${subcell} cus cell:${subcell_uexgate} has finished\n
    ...  console=${log_to_console}

CUS Verify Full Duplex Throughput Success Rate
    [Arguments]  ${ue_id_begin}  ${ue_id_end}  ${bps_throughput}
    [Documentation]
    ...  Description:
    ...  Keyword verifies if measured uplink and downlink throughput has success rate.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bps_throughput         | Yes  | Throughput rate unit.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    FOR  ${ue_id}  IN RANGE  ${ue_id_begin}  ${ue_id_end}+1
      Uexgate Verify Throughput Success Rate
      ...  traffic_direction=dl  ue_id=${ue_id}  trf_id=1  bps_throughput=${bps_throughput}
      Uexgate Verify Throughput Success Rate
      ...  traffic_direction=ul  ue_id=${ue_id}  trf_id=2  bps_throughput=${bps_throughput}
    END

CUS Verify Half Duplex Throughput Success Rate
    [Arguments]  ${traffic_direction}  ${ue_id_begin}  ${ue_id_end}  ${bps_throughput}
    [Documentation]
    ...  Description:
    ...  Keyword verifies if measured uplink or downlink throughput has success rate.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ue_id_begin            | Yes  | Initial UE number.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ue_id_end              | Yes  | End UE number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bps_throughput         | Yes  | Throughput rate unit.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    FOR  ${ue_id}  IN RANGE  ${ue_id_begin}  ${ue_id_end}+1
      Uexgate Verify Throughput Success Rate
      ...  traffic_direction=${traffic_direction}  ue_id=${ue_id}
      ...  trf_id=1  bps_throughput=${bps_throughput}
    END

Change CUS IoT Standalone Cell Id
    [Arguments]  ${lncell_id}
    [Documentation]
    ...  Description:
    ...  Keyword changes IoT standalone cell id to CUS IoT standalone id defined in cus.ini file.
    ...  Example: Section [nb_cell_301] in cus.ini file.
    ...           This means that the SCFC IoT standalone lncell id is 1.
    ...           Value 300 is added to the SCFC lncell id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncell_id              | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${parameter_name}=  Admin Get Cell Parameter Value  lncel_id=${lncell_id}  parameter_name=nbIoTMode
    ${cus_lncell_id}=  Run Keyword If  '${parameter_name}'=='standalone'
    ...  Evaluate  ${lncell_id}+300
    ...  ELSE  Set Variable    ${lncell_id}
    [Return]  ${cus_lncell_id}

Get Band Number
    [Arguments]  ${configuration_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns band number based on configuration cell id.
    ...  Example:
    ...  INPUT: configuration_id=2
    ...  RETURN: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-2
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | configuration_id       | Yes  | Configuration cell id.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${lncel_id}=  Get Cell Id By Configuration Id  rat=LTE  configuration_id=${configuration_id}
    ${bts_info}=  Get Bts Info  timeout=240
    ${cells_list}=  Get From Dictionary  dictionary=${bts_info['cells']}  key=lte
    FOR  ${cell_dict}  IN  @{cells_list}
      ${band_number}=  Set Variable If  "${cell_dict['id']['internal']}" == "${lncel_id}"
      ...  ${cell_dict['bandNumber']}
      Exit For Loop If  "${cell_dict['id']['internal']}" == "${lncel_id}"
    END
    [Return]  ${band_number}

Get Band Number List
    [Arguments]  ${configuration_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns band number list based on configuration cell id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | configuration_id_list  | Yes  | List of configuration cell id.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${band_number_list}=  Create List
    FOR  ${configuration_id}  IN  @{configuration_id_list}
      ${band_number}=  Get Band Number  configuration_id=${configuration_id}
      Append To List  ${band_number_list}  ${band_number}
    END
    ${band_number_list}=  Remove Duplicates  ${band_number_list}
    [Return]  ${band_number_list}

Set UL And DL Single TX Throughput Values
    [Arguments]  ${bandwidth}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword assigns proper throughput rate for dl and ul for Single TX cell based on cell bandwidth.
    ...  Ul and Dl throughput rate are returned as list in list "expected_throughput" respectively.
    ...  Keyword assigns proper throughput rate unit.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bandwidth              | Yes  | Bandwidth value.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${info_prefix}MIMO mode OFF  console=${log_to_console}
    @{expected_throughput}=  Create List
    ${expected_throughput_tmp}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Single Ul Value  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Single Ul Value  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Single Ul Value  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Single Ul Value  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Single Ul Value  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Single Ul Value  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Single Ul Value  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Single Ul Value  index_number=7
    Append To List  ${expected_throughput}  ${expected_throughput_tmp}
    ${expected_throughput_tmp}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Single Dl Value  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Single Dl Value  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Single Dl Value  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Single Dl Value  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Single Dl Value  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Single Dl Value  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Single Ul Value  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Single Ul Value  index_number=7
    Append To List  ${expected_throughput}  ${expected_throughput_tmp}
    ${bps_throughput}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Bps Unit  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Bps Unit  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Bps Unit  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Bps Unit  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Bps Unit  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Bps Unit  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Bps Unit  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Bps Unit  index_number=7
    [Return]  ${expected_throughput}  ${bps_throughput}

Set UL And DL MIMO Throughput Values
    [Arguments]  ${bandwidth}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword assigns proper throughput rate for dl and ul for MIMO cell based on cell bandwidth.
    ...  Ul and Dl throughput rate are returned as list in list "expected_throughput" respectively.
    ...  Keyword assigns proper throughput rate unit.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bandwidth              | Yes  | Bandwidth value.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${info_prefix}MIMO mode ON  console=${log_to_console}
    @{expected_throughput}=  Create List
    ${expected_throughput_tmp}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Mimo Ul Value  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Mimo Ul Value  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Mimo Ul Value  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Mimo Ul Value  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Mimo Ul Value  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Mimo Ul Value  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Mimo Ul Value  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Mimo Ul Value  index_number=7
    Append To List  ${expected_throughput}  ${expected_throughput_tmp}
    ${expected_throughput_tmp}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Mimo Dl Value  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Mimo Dl Value  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Mimo Dl Value  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Mimo Dl Value  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Mimo Dl Value  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Mimo Dl Value  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Mimo Dl Value  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Mimo Dl Value  index_number=7
    Append To List  ${expected_throughput}  ${expected_throughput_tmp}
    ${bps_throughput}=  Run Keyword If
    ...           '${bandwidth}'=='1.4 MHz'  Set Bps Unit  index_number=0
    ...  ELSE IF  '${bandwidth}'=='3 MHz'    Set Bps Unit  index_number=1
    ...  ELSE IF  '${bandwidth}'=='5 MHz'    Set Bps Unit  index_number=2
    ...  ELSE IF  '${bandwidth}'=='10 MHz'   Set Bps Unit  index_number=3
    ...  ELSE IF  '${bandwidth}'=='15 MHz'   Set Bps Unit  index_number=4
    ...  ELSE IF  '${bandwidth}'=='20 MHz'   Set Bps Unit  index_number=5
    ...  ELSE IF  '${bandwidth}'=='0.2 MHz'  Set Bps Unit  index_number=6
    ...  ELSE IF  '${bandwidth}'=='catm'     Set Bps Unit  index_number=7
    [Return]  ${expected_throughput}  ${bps_throughput}

Set Mimo Ul Value
    [Arguments]  ${index_number}
    [Documentation]
    ...  Description:
    ...  Keyword gets the throughput rate value based on the index value
    ...  in the ${UL_MIMO_THROUGHPUT} list in the "variables.robot" file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | index_number           | Yes  | List value index.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ul_mimo_transfer}=  Get From List  ${UL_MIMO_THROUGHPUT}  ${index_number}
    [Return]  ${ul_mimo_transfer}

Set Mimo Dl Value
    [Arguments]  ${index_number}
    [Documentation]
    ...  Description:
    ...  Keyword gets the throughput rate value based on the index value
    ...  in the ${DL_MIMO_THROUGHPUT} list in the "variables.robot" file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | index_number           | Yes  | List value index.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dl_mimo_transfer}=  Get From List  ${DL_MIMO_THROUGHPUT}  ${index_number}
    [Return]  ${dl_mimo_transfer}

Set Single Ul Value
    [Arguments]  ${index_number}
    [Documentation]
    ...  Description:
    ...  Keyword gets the throughput rate value based on the index value
    ...  in the ${UL_SINGLE_THROUGHPUT} list in the "variables.robot" file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | index_number           | Yes  | List value index.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ul_single_transfer}=  Get From List  ${UL_SINGLE_THROUGHPUT}  ${index_number}
    [Return]  ${ul_single_transfer}

Set Single Dl Value
    [Arguments]  ${index_number}
    [Documentation]
    ...  Description:
    ...  Keyword gets the throughput rate value based on the index value
    ...  in the ${DL_SINGLE_THROUGHPUT} list in the "variables.robot" file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | index_number           | Yes  | List value index.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dl_single_transfer}=  Get From List  ${DL_SINGLE_THROUGHPUT}  ${index_number}
    [Return]  ${dl_single_transfer}

Set Bps Unit
    [Arguments]  ${index_number}
    [Documentation]
    ...  Description:
    ...  Keyword gets the throughput rate unit based on the index value
    ...  in the ${BPS_THROUGHPUT} list in the "variables.robot" file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | index_number           | Yes  | List value index.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bps_throughput}=  Get From List  ${BPS_THROUGHPUT}  ${index_number}
    [Return]  ${bps_throughput}
