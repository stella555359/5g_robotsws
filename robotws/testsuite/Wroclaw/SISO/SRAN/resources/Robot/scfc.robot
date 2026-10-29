*** Settings ***
Documentation  SCFC file management keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    OperatingSystem
Library    Collections
Library    XML  use_lxml=True

Resource    ../operations.robot
Resource    ../bts_scfc.robot

*** Keywords ***
######################################################## SBTS #########################################################
SCFC Get Object Parameter Value
    [Arguments]  ${scfc_file_path}  ${dist_name}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the parameter value from the SCFC file based on the object distName and the parameter name.
    ...  Example: ${dist_name}=MRBTS-1/LNBTS-1, ${parameter_name}=actCoMp
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | Dist name of the object that contains the parameter.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the parameter whose value is retrieved.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_parameter_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(@distName,"${dist_name}")]/p[@name="${parameter_name}"])
    [Return]  ${scfc_parameter_value}

SCFC Get Cells Count Based On Class
    [Arguments]  ${scfc_file_path}  ${cell_class}
    [Documentation]
    ...  Description:
    ...  Keyword returns count of cells based on the class name defined in given SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_class             | Yes  | Cell class.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}  count(//managedObject[@class='${cell_class}'])
    ${cells_count}=  Convert To Integer  item=${cells_count}
    [Return]  ${cells_count}

SCFC Get LNCEL Bandwidth
    [Arguments]  ${scfc_file_path}  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns cell bandwidth defined in given SCFC file based on lncel_id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${object_1}=  Set Variable  (contains(@class, 'NOKLTE:LNCEL_') or contains(@class, 'NOKLTE:NBIOT_'))
    ${object_2}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}")]/p[@name="dlChBw" or @name="chBw"
    ${cell_bw}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[${object_1} and ${object_2}])
    [Return]  ${cell_bw}

SCFC Get Category Alarms Parameter Value
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns information "False" or "True" about type of alarms reported by the BTS.
    ...  The value of "True" means that new category alarms are raised, otherwise legacy alarms are raised.
    ...  Category alarms have alarm numbers in the range 71XX.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class='com.nokia.srbts.mnl:FMCADM']/p[@name='actCategoryAlarms'])
    ${result_value}=  Convert To Boolean  item=${result_value}
    [Return]  ${result_value}

SCFC Get CA Activation Status
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns status of actDLCAggr and actULCAggr activation parameters.
    ...  These parameters activates uplink/downlink carrier aggregation.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${act_dlcaggr_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class='NOKLTE:LNBTS' and @distName='${mrbts_id}/LNBTS-1']/p[@name='actDLCAggr']/text())
    ${act_dlcaggr_status}=  Convert To Boolean  item=${act_dlcaggr_value}
    ${act_ulcaggr_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class='NOKLTE:LNBTS' and @distName='${mrbts_id}/LNBTS-1']/p[@name='actULCAggr']/text())
    ${act_ulcaggr_status}=  Convert To Boolean  item=${act_ulcaggr_value}
    [Return]  ${act_dlcaggr_status}  ${act_ulcaggr_status}

SCFC Get CA Supporting LncelId List For Prinary LncelId
    [Arguments]  ${scfc_file_path}  ${pcell_lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns supporting LncelId list for prinary cell given by LncelId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pcell_lncel_id         | Yes  | Prinary LncelId.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scell_lncel_id_list}=  Create List
    ${scell_lcr_id_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[@class="NOKLTE:CAREL" and contains(@distName, "LNCEL-${pcell_lncel_id}/CAREL-")]/p[@name="lcrId"]/text()
     FOR  ${scell_lcr_id}  IN  @{scell_lcrid_list}
      ${scell_lncel_id}=  SCFC Get LncelId For LcrId  scfc_file_path=${scfc_file_path}  lcr_id=${scell_lcr_id}
      Append to List  ${scell_lncel_id_list}  ${scell_lncel_id}
    END
    [Return]  ${scell_lncel_id_list}

SCFC Get CA Primary LncelId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns CA primary LncelId list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${pcell_lncel_id_list}=  Get Regexp Matches  ${scfc_file}  \/LNCEL-(\\d+)\/CAREL-  1
    ${pcell_lncel_id_list}=  Remove Duplicates  ${pcell_lncel_id_list}
    [Return]  ${pcell_lncel_id_list}

SCFC Check If CAREL Exist
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks if CAREL objects exist in given SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_xml}=  Parse XML  source=${scfc_file_path}
    Element Should Exist  ${scfc_xml}  .//managedObject[@class='CAREL' or @class='NOKLTE:CAREL']

SCFC Class Should Exist
    [Arguments]  ${scfc_file_path}  ${class_name}
    [Documentation]
    ...  Description:
    ...  Keyword checks if given class objects exist in given SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | class_name             | Yes  | Class name.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_xml}=  Parse XML  source=${scfc_file_path}
    Element Should Exist  ${scfc_xml}  .//managedObject[@class='${class_name}']

SCFC Set File Path
    [Arguments]  ${scfc_default_file_path}  ${enb_sw_release}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword sets scfc file path and scfc file name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_default_file_path | Yes  | Path to the default scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | enb_sw_release         | Yes  | ENB software version.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             | No   | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         | No   | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${enb_sw_release_fetch}=  Fetch From Left  string=${enb_sw_release}  marker=_
    ${sbts00}=  Run Keyword And Return Status  Should Contain  ${enb_sw_release}  _ENB_9999
    IF  ${sbts00}
      ${enb_sw_release_fetch}=  Set Variable  SBTS00
    END
    ${scfc_default_path_and_file}=  Split String From Right  string=${scfc_default_file_path}  separator=/  max_split=1
    ${CONFIG_DIR}=  Set Variable  ${scfc_default_path_and_file[0]}
    ${scfc_list}=  List Files In Directory  ${CONFIG_DIR}  pattern=*.xml
    ${found_match}=  Set Variable  False
    FOR  ${scfc}  IN  @{scfc_list}
        ${scfc_name}=  Set Variable  ${scfc}
        ${match}=  Run Keyword And Return Status  Should Contain  ${scfc_name}  ${enb_sw_release_fetch}
        IF  ${match}
            ${matched_scfc_name}=  Set Variable  ${scfc}
            ${matched_scfc_path}=  Join Path  ${CONFIG_DIR}  ${matched_scfc_name}
            ${found_match}=  Set Variable  True
            Exit For Loop
        END
    END
    IF  ${found_match}
        ${scfc_file_path}=  Set Variable  ${matched_scfc_path}
        ${scfc_file_name}=  Set Variable  ${matched_scfc_name}
        Log  ${log_prefix}${scfc_file_name} - file found.  console=${log_to_console}
    ELSE
        ${scfc_file_path}=  Set Variable  ${scfc_default_file_path}
        ${scfc_file_name}=  Set Variable  ${scfc_default_path_and_file[1]}
        Log  ${log_prefix}SCFC for ${enb_sw_release_fetch} not found.  console=${log_to_console}
        Log  ${log_prefix}Default ${scfc_default_path_and_file[1]} will be used.  console=${log_to_console}
    END
    [Return]  ${scfc_file_path}  ${scfc_file_name}

SCFC Get RxTx Cells List
    [Arguments]  ${scfc_file_path}  ${cells_list}
    [Documentation]
    ...  Description:
    ...  Keyword checks channels direction and return only cells with RX and TX.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_list             | Yes  | List of cell number.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rxtx_cells_list}=  Create List  @{cells_list}
    FOR  ${cell_id}  IN  @{rxtx_cells_list}
      ${object_1}=  Set Variable  @class="com.nokia.srbts.mnl:CHANNEL"
      ${object_2}=  Set Variable  contains(@distName, "/CELLMAPPING-1/LCELL-${cell_id}/CHANNELGROUP-")
      ${channel_directions}=  Evaluate Xpath  ${scfc_file_path}
      ...  .//managedObject[${object_1}][${object_2}]/p[@name="direction"]/text()
      ${result}=  Run Keyword And Return Status  List Should Contain Value  ${channel_directions}  RX
      Run Keyword If  ${result}==False  Remove Values From List  ${rxtx_cells_list}  ${cell_id}
    END
    [Return]  ${rxtx_cells_list}

SCFC Get Subcell List For LncelId
    [Arguments]  ${scfc_file_path}  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns all subcells list based on lncelId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL Id of cell.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${object_1}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}")
    ${object_2}=  Set Variable  (substring-after(@distName, "LNCEL-${lncel_id}")=""
    ${object_3}=  Set Variable  contains(@distName, "LNCEL-${lncel_id}/LNCEL_"))
    ${subcell_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[${object_1} and ${object_2} or ${object_3}]/list/item/p[@name='subCellId']/text()
    ${supercell_state}=  SCFC Get Attribute Value For LncelId
    ...  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}  attribute_name=actSuperCell
    Run Keyword If  '${supercell_state}'=='true'  Should Be Empty  ${subcell_list}
    Run Keyword If  '${supercell_state}'=='true'  Append To List  ${subcell_list}  1  2
    [Return]  ${subcell_list}

SCFC Create Cell And Subcell Dictionary
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns a dictionary of all subcells list for lcr_id based on lncel_id
    ...  Return values: {'lcr_id_1': [subcells], 'lcr_id_2': [subcells], 'lcr_id_3': [subcells], 'lcr_id_4': [subcells]}
    ...  Example: {'1': ['1', '2', '3'], '2': [], '3': ['1', '2', '3'], '4': []}
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${lcr_id_count}=  Get Length  item=${lcr_id_list}
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${cell_subcell_dict}=  Create Dictionary
    FOR  ${cell_index}  IN RANGE  ${lcr_id_count}
      ${subcell_list}=  SCFC Get Subcell List For LncelId
      ...  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id_list[${cell_index}]}
      Set To Dictionary  ${cell_subcell_dict}  ${lcr_id_list[${cell_index}]}  ${subcell_list}
    END
    [Return]  ${cell_subcell_dict}

SCFC Get Cell Throughput Parameters
    [Arguments]  ${scfc_file_path}  ${lncel_id}  ${act_catm}=False  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword assigns proper throughput rate for UL and DL based on cell parameters.
    ...  UL and DL throughput rate are returned as list in expected_throughput respectively.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | act_catm               | Yes  | Information whether there is an CatM cell.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mimo_mode}=  SCFC Get dlMimoMode For Lncelid  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
    ${mimo_status}=  Run Keyword And Return Status  Should Contain  ${mimo_mode}  Loop
    ${bandwidth}=  SCFC Get LNCEL Bandwidth  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
    Run Keyword If  ${act_catm}
    ...  Log  ${info_prefix}bandwidth=${bandwidth} (CatM)  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}bandwidth=${bandwidth}  console=${log_to_console}
    ${bandwidth}=  Run Keyword If  ${act_catm}
    ...  Set Variable  catm
    ...  ELSE
    ...  Set Variable  ${bandwidth}
    ${throughput_parameters}  ${bps_throughput}=  Run Keyword If  ${mimo_status}
    ...  Set UL And DL MIMO Throughput Values  bandwidth=${bandwidth}
    ...  ELSE
    ...  Set UL And DL Single TX Throughput Values  bandwidth=${bandwidth}
    [Return]  ${throughput_parameters}  ${bps_throughput}

SCFC Get CA Cell Throughput Parameters
    [Arguments]  ${scfc_file_path}  ${lncel_id}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword assigns proper throughput rate for UL and DL based on cell parameters.
    ...  UL and DL throughput rate are returned as list in expected_throughput respectively.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${act_dlcaggr_status}  ${act_ulcaggr_status}=
    ...  SCFC Get CA Activation Status  scfc_file_path=${scfc_file_path}
    Log  ${info_prefix}Carrier aggregation enabled  console=${log_to_console}
    Log  ${info_prefix}CA downlink: ${act_dlcaggr_status}  console=${log_to_console}
    Log  ${info_prefix}CA uplink: ${act_ulcaggr_status}  console=${log_to_console}
    ${mimo_mode}=  SCFC Get dlMimoMode For Lncelid  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
    ${bandwidth}=  SCFC Get LNCEL Bandwidth  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
    Log  ${info_prefix}pcell (LNCEL-${lncel_id}) bandwidth=${bandwidth}  console=${log_to_console}
    ${mimo_status}=  Run Keyword And Return Status  Should Contain  container=${mimo_mode}  item=Loop
    ${throughput_parameters}  ${bps_throughput}=  Run Keyword If  ${mimo_status}
    ...  Set UL And DL MIMO Throughput Values  bandwidth=${bandwidth}
    ...  ELSE
    ...  Set UL And DL Single TX Throughput Values  bandwidth=${bandwidth}
    ${ul_throughput}=  Set Variable  ${throughput_parameters[0]}
    ${dl_throughput}=  Set Variable  ${throughput_parameters[1]}
    ${scell_lncel_id_list}=  SCFC Get CA Supporting LncelId List For Prinary LncelId
    ...  scfc_file_path=${scfc_file_path}  pcell_lncel_id=${lncel_id}
    FOR  ${scell_lncel_id}  IN  @{scell_lncel_id_list}
      ${mimo_mode}=  SCFC Get dlMimoMode For Lncelid  scfc_file_path=${scfc_file_path}  lncel_id=${scell_lncel_id}
      ${bandwidth}=  SCFC Get LNCEL Bandwidth  scfc_file_path=${scfc_file_path}  lncel_id=${scell_lncel_id}
      Log  ${info_prefix}scell (LNCEL-${scell_lncel_id}) bandwidth=${bandwidth}  console=${log_to_console}
      ${mimo_status}=  Run Keyword And Return Status  Should Contain  container=${mimo_mode}  item=Loop
      ${throughput_parameters}  ${bps_throughput}=  Run Keyword If  ${mimo_status}
      ...  Set UL And DL MIMO Throughput Values  bandwidth=${bandwidth}
      ...  ELSE
      ...  Set UL And DL Single TX Throughput Values  bandwidth=${bandwidth}
      ${dl_throughput}=  Run Keyword If  ${act_dlcaggr_status}
      ...  Evaluate  ${dl_throughput}+${throughput_parameters[1]}
      ...  ELSE
      ...  Set Variable  ${dl_throughput}
      ${ul_throughput}=  Run Keyword If  ${act_ulcaggr_status}
      ...  Evaluate  ${ul_throughput}+${throughput_parameters[0]}
      ...  ELSE
      ...  Set Variable  ${ul_throughput}
    END
    ${throughput_parameters}=  Create List  ${ul_throughput}  ${dl_throughput}
    [Return]  ${throughput_parameters}  ${bps_throughput}

Get Dist Name Delta Parameters From JSON File
    [Arguments]  ${json_params_dict}  ${delta_params_dict_list}
    [Documentation]
    ...  Description:
    ...  Keyword gets the BTS update parameters associated with distName
    ...  and returns them as a list of parameter dictionaries.
    ...  The distName values are taken from the JSON file.
    ...  This keyword is related to the "Get Delta Parameters From JSON File" keyword.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | json_params_dict       | Yes  | Dictionary of BTS updated parameters of one object.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_params_dict_list | Yes  | Dictionary of list of BTS updated objects.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dist_name_parameters}=  Set Variable  ${json_params_dict['parameters']}
    FOR  ${parameter_dict}  IN  @{dist_name_parameters}
      ${delta_params_dict}=  Create Dictionary
      Set To Dictionary  ${delta_params_dict}  distName  ${json_params_dict['distName']}
      Set To Dictionary  ${delta_params_dict}  parameterName  ${parameter_dict['parameterName']}
      Set To Dictionary  ${delta_params_dict}  value  ${parameter_dict['value']}
      Append To List  ${delta_params_dict_list}  ${delta_params_dict}
    END
    [Return]  ${delta_params_dict_list}

Get Delta Parameters From JSON File
    [Arguments]  ${json_delta_file}
    [Documentation]
    ...  Description:
    ...  Keyword gets BTS update parameters from a JSON file and returns them as a list of parameter dictionaries.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | json_delta_file        | Yes  | Path to the json delta file.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${delta_params_dict_list}=  Create List
    ${json_delta_string}=  OperatingSystem.Get File  path=${json_delta_file}
    ${json_delta_params_list}=  Evaluate  json.loads('''${json_delta_string}''')  json
    FOR  ${json_params_dict}  IN  @{json_delta_params_list}
      ${delta_params_dict_list}=  Get Dist Name Delta Parameters From JSON File
      ...  json_params_dict=${json_params_dict}
      ...  delta_params_dict_list=${delta_params_dict_list}
    END
    [Return]  ${delta_params_dict_list}

SCFC Show Parameters Value Based On JSON File
    [Arguments]  ${scfc_file_path}  ${delta_params_dict_list}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword displays the parameter values from the SCFC file based on
    ...  the parameters provided in the JSON file.
    ...  The parameter values are taken from the list obtained from the keyword
    ...  "Get Delta Parameters From JSON File"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_params_dict_list | Yes  | Dictionary of list of BTS updated objects.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${delta_params_dict}  IN  @{delta_params_dict_list}
      ${scfc_parameter_value}=  SCFC Get Object Parameter Value  scfc_file_path=${scfc_file_path}
      ...  dist_name=${delta_params_dict['distName']}  parameter_name=${delta_params_dict['parameterName']}
      ${name}=  Set Variable  ${delta_params_dict['parameterName']}
      ${dist}=  Set Variable  ${delta_params_dict['distName']}
      ${value}=  Set Variable  ${scfc_parameter_value}
      Log  ${log_prefix}SCFC parameter "${name}" value for "${dist}" dist name is "${green}${value}${nc}"
      ...  console=${log_to_console}
    END

SCFC Verify Parameters Value Obtained From JSON File
    [Arguments]  ${scfc_file_path}  ${delta_params_dict_list}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword verifies whether the parameter values in the SCFC file match the values set in the JSON file.
    ...  The parameter values are taken from the list obtained from the keyword
    ...  "Get Delta Parameters From JSON File".
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_params_dict_list | Yes  | Dictionary of list of BTS updated objects.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${delta_params_dict}  IN  @{delta_params_dict_list}
      ${scfc_parameter_value}=  SCFC Get Object Parameter Value  scfc_file_path=${scfc_file_path}
      ...  dist_name=${delta_params_dict['distName']}  parameter_name=${delta_params_dict['parameterName']}
      ${parameter_result}=  Run Keyword And Return Status
      ...  Should Be Equal  ${delta_params_dict['value']}  ${scfc_parameter_value}
      ${name}=  Set Variable  ${delta_params_dict['parameterName']}
      ${dist}=  Set Variable  ${delta_params_dict['distName']}
      ${value}=  Set Variable  ${scfc_parameter_value}
      Run Keyword And Continue On Failure
      ...  Should Be Equal  ${delta_params_dict['value']}  ${scfc_parameter_value}
      ...  [!] (Fail) SCFC parameter "${name}" value for "${dist}" dist name is "${red}${value}${nc}"
      Run Keyword If  ${parameter_result}
      ...  Log  ${log_prefix}SCFC parameter "${name}" value for "${dist}" dist name is "${green}${value}${nc}"
      ...  console=${log_to_console}
      ${final_result}=  Set Variable If  ${parameter_result}==False  ${parameter_result}
    END
    Run Keyword If  ${final_result}==False  Fail  [!] (Fail) Some parameter values are not as expected.

SCFC Verify If Hardware With Given Product Code Is Used
    [Arguments]  ${scfc_file_path}  ${prod_codes_list}
    [Documentation]
    ...  Description:
    ...  Keyword checks if one of BBMODs or SMODs with given product code is used.
    ...  Keyword returns True if one of BBMODs or SMODs with given product code is used and False otherwise.
    ...  BBMOD or SMOD product code should be given as a list of values.
    ...  Example product codes: ABIO - 475266A, ABIN - 474824A, ASOE - 475587A
    ...  If there are no BBMODs or SMODs, False is returned.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | prod_codes_list        | Yes  | List of product codes of hardware device.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${prod_code_status}=  Set Variable  False
    ${object_1}=  Set Variable  @class="com.nokia.srbts.eqm:BBMOD"
    ${object_2}=  Set Variable  @class="com.nokia.srbts.eqm:SMOD"
    ${scfc_prod_codes_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[${object_1} or ${object_2}]/p[@name='prodCodePlanned']/text()
    FOR  ${scfc_prod_code}  IN  @{scfc_prod_codes_list}
      ${scfc_prod_code}=  Fetch From Left  string=${scfc_prod_code}  marker=.
      ${prod_code_status}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${prod_codes_list}  ${scfc_prod_code}
      Exit For Loop If    ${prod_code_status}
    END
    [Return]    ${prod_code_status}

SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation
    [Arguments]  ${scfc_file_path}  ${lcr_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns corresponding NrcellId for given LTE cell LcrId.
    ...  Dynamic spectrum sharing between LTE and NR should be activated and objects NRDSSLTE should exist.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id                 | Yes  | Lcr cell id.                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dist_name}=  Evaluate Xpath  source=${scfc_file_path}
    ...  expression=string(.//managedObject[(@class="com.nokia.srbts.nrbts:NRDSSLTE") and p[@name="lcrId"]="${lcr_id}"]/@distName)
    ${nrcell_id_list}=  Get Regexp Matches  ${dist_name}  NRCELL-(\\d+)  1
    ${nrcell_id}=  Set Variable If  ${nrcell_id_list}==@{EMPTY}  ${EMPTY}  ${nrcell_id_list[0]}
    [Return]  ${nrcell_id}

SCFC Get MRBTS ID
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword gets MRBTS ID of given configuration.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${scfc_contents}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${pattern}=  Set Variable  <managedObject class="com.nokia.srbts:MRBTS" distName="MRBTS-
    ${mrbts_id_line}=  Get Lines Containing String  ${scfc_contents}  ${pattern}
    ${mrbts_id}=  Fetch From Right  string=${mrbts_id_line}  marker=distName="
    ${mrbts_id}=  Fetch From Left  string=${mrbts_id}  marker=" version
    [Return]  ${mrbts_id}

######################################################## CBTS #########################################################
#RMODS
vDU SCFC Get RMODs Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the count of RMODs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_count}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(.//managedObject[@class='RMOD' or @class='com.nokia.srbts.eqm:RMOD'])
    ${rmods_count}=  Convert To Integer  ${rmods_count}
    [Return]  ${rmods_count}

vDU SCFC Get RMOD Id List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the RMOD id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_id_list}=  Create List
    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${rmod_dist_list}=  Get Elements  source=${scfc_file}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.eqm:RMOD"]/@distName
    FOR  ${rmod_dist}  IN  @{rmod_dist_list}
      ${rmod_id}=  Fetch From Right  string=${rmod_dist}  marker=-
      Append to List  ${rmod_id_list}  ${rmod_id}
    END
    [Return]  ${rmod_id_list}

vDU SCFC Get Serial Number For RMOD Id
    [Arguments]  ${scfc_file_path}  ${rmod_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns corresponding serial number for given RMOD id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_id                | Yes  | RMOD id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

     ${serial_number}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:RMOD" and contains(@distName, "RMOD-${rmod_id}")]/p[@name="serialNumberPlanned"])
    [Return]  ${serial_number}

vDU SCFC Get RMODs Serial Number And Id
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns RMOD serial numbers and ids.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_dict}=  Create Dictionary
    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${rmod_dist_list}=  Get Elements  source=${scfc_file}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.eqm:RMOD"]/@distName
    FOR  ${rmod_dist}  IN  @{rmod_dist_list}
      ${rmod_id}=  Fetch From Right  string=${rmod_dist}  marker=-
      ${rmod_serial_number}=  Evaluate Xpath  ${scfc_file_path}
      ...  string(.//managedObject[@class="com.nokia.srbts.eqm:RMOD" and @distName="${rmod_dist}"]/p[@name="serialNumberPlanned"])
      Set To Dictionary  ${rmods_dict}  ${rmod_id}=${rmod_serial_number}
    END
    [Return]  ${rmods_dict}

vDU SCFC Get RMODs Serial Number And Configuration Id
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns radio modules serial numbers and configuration ids.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary where the key is the radio module serial number and value is configuration id.
    ...  Example:
    ...  {'1M190413180': '4', '1M230816495': '5', 'LR231902254': '3'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_dict}=  Create Dictionary
    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${rmod_dist_list}=  Get Elements  source=${scfc_file}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.eqm:RMOD"]/@distName
    FOR  ${rmod_dist}  IN  @{rmod_dist_list}
      ${rmod_id}=  Fetch From Right  string=${rmod_dist}  marker=-
      ${rmod_serial_number}=  Evaluate Xpath  ${scfc_file_path}
      ...  string(.//managedObject[@class="com.nokia.srbts.eqm:RMOD" and @distName="${rmod_dist}"]/p[@name="serialNumberPlanned"])
      Set To Dictionary  ${rmods_dict}  ${rmod_serial_number}=${rmod_id}
    END
    [Return]  ${rmods_dict}

vDU SCFC Get RMOD Serial Number List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the RMODs serial number list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_list}=  Get Elements  source=${scfc_file_path}
    ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:RMOD']/p[@name='serialNumberPlanned']/text()
    [Return]  ${rmod_sn_list}

SCFC Get Radio Module Serial Number List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the radio module serial number list.
    ...  If there is no radio module serial number in radio module configuration or runtime dist name object,
    ...  an empty list is returned.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Radio module serial number list.
    ...  Example:
    ...  {'CUS001001C7': 'MRBTS-1/EQM-1/APEQM-1/RMOD-6', 'CUS001002C7': 'MRBTS-1/EQM-1/APEQM-1/RMOD-7'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_list}=  Get Elements  source=${scfc_file_path}
    ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:RMOD_R']/p[@name='serialNumber']/text()
    IF  ${rmod_sn_list}==@{EMPTY}
      ${rmod_sn_list}=  Get Elements  source=${scfc_file_path}
      ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:RMOD']/p[@name='serialNumberPlanned']/text()
    END
    [Return]  ${rmod_sn_list}

SCFC Get Radio Module Serial Number And Dist Names
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns radio modules serial numbers and configuration and runtime dist names.
    ...  If radio module runtime dist name object not exist
    ...  an empty dictionary (${rmod_sn_runtime_dn_dict}) is returned.
    ...  If radio module configuration dist name object does not contain radio module serial number,
    ...  an empty dictionary (${rmod_sn_config_dn_dict}) is returned.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary where the key is the radio module serial number and value is configuration dist name.
    ...  Example (rmod_sn_config_dn_dict):
    ...  {'CUS001001C7': 'MRBTS-1/EQM-1/APEQM-1/RMOD-6', 'CUS001002C7': 'MRBTS-1/EQM-1/APEQM-1/RMOD-7'}
    ...  Dictionary where the key is the radio module serial number and value is runtime dist name.
    ...  Example (rmod_sn_runtime_dn_dict):
    ...  {'CUS001001C7': 'MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1', 'CUS001002C7': 'MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-2'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_config_dn_dict}=  Create Dictionary
    ${rmod_sn_runtime_dn_dict}=  Create Dictionary
    ${rmod_runtime_dn_list}=  Get Elements  source=${scfc_file_path}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]/@distName
    IF  ${rmod_runtime_dn_list}!=@{EMPTY}
      FOR  ${rmod_runtime_dn}  IN  @{rmod_runtime_dn_list}
        ${rmod_serial_number}=  Evaluate Xpath  ${scfc_file_path}
        ...  string(.//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R" and @distName="${rmod_runtime_dn}"]/p[@name="serialNumber"])
        ${rmod_config_dn}=  Evaluate Xpath  ${scfc_file_path}
        ...  string(.//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R" and @distName="${rmod_runtime_dn}"]/p[@name="configDN"])
        Set To Dictionary  ${rmod_sn_config_dn_dict}  ${rmod_serial_number}=${rmod_config_dn}
        Set To Dictionary  ${rmod_sn_runtime_dn_dict}  ${rmod_serial_number}=${rmod_runtime_dn}
      END
    ELSE
      ${rmod_config_dn_list}=  Get Elements  source=${scfc_file_path}
      ...  xpath=.//managedObject[@class="com.nokia.srbts.eqm:RMOD"]/@distName
      FOR  ${rmod_config_dn}  IN  @{rmod_config_dn_list}
        ${rmod_serial_number}=  Evaluate Xpath  ${scfc_file_path}
        ...  string(.//managedObject[@class="com.nokia.srbts.eqm:RMOD" and @distName="${rmod_config_dn}"]/p[@name="serialNumberPlanned"])
        Exit For Loop If  '${rmod_serial_number}'=='${EMPTY}'
        Set To Dictionary  ${rmod_sn_config_dn_dict}  ${rmod_serial_number}=${rmod_config_dn}
      END
    END
    [Return]  ${rmod_sn_config_dn_dict}  ${rmod_sn_runtime_dn_dict}

Get Radio Modules Serial Numbers List
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns radio modules serial numbers list based on SCFC file
    ...  or given radio modules serial numbers list
    ...  or randomly selected radio modules serial numbers based on the list obtained from the SCFC file.
    ...  Remark:
    ...  If parameter ${rmod_sn_count} is greater than 0 then the list of specified radio modules (${rmod_sn_list})
    ...  should be empty, because they will not be taken into account anyway.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial numbers of the tested radio modules.                        |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_rmod_sn_list}=  SCFC Get Radio Module Serial Number List  scfc_file_path=${scfc_file_path}
	${rmod_serial_number_list}=  Run Keyword If  ${rmod_sn_count}>0
    ...  Get Random List Based On Input List  list=${scfc_rmod_sn_list}  length=${rmod_sn_count}
    ...  ELSE IF  ${rmod_sn_list}==@{EMPTY}
    ...  Create List  @{scfc_rmod_sn_list}
    ...  ELSE
    ...  Create List  @{rmod_sn_list}
    [Return]  ${rmod_serial_number_list}

Get BTS Controller Role Sharing Configuration
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword return controller role of the BTS for radio modules in sharing configuration.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  List  of  serial number of primary and secondary radio module.
    ...  Example (primary_rmod_sn_list):
    ...  ['K9242639679', 'K9242639680', 'K9245120901', 'K9245120909']
    ...  Example (secondary_rmod_sn_list):
    ...  ['K9242639679', 'K9242639680', 'K9245120901', 'K9245120909']
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_config_dn_dict}  ${rmod_sn_runtime_dn_dict}=  SCFC Get Radio Module Serial Number And Dist Names
    ...  scfc_file_path=${scfc_file_path}
    @{primary_rmod_sn_list}=  Create List
    @{secondary_rmod_sn_list}=  Create List
    ${rmod_sn_list}=  Get Dictionary Keys  dictionary=${rmod_sn_config_dn_dict}
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${rmod_dist_name}=  Get From Dictionary  dictionary=${rmod_sn_config_dn_dict}  key=${rmod_sn}
      ${list_parameters_dict}=  SCFC Get Managed Object Parameter List Values
      ...  scfc_file_path=${scfc_file_path}
      ...  dist_name=${rmod_dist_name}
      ...  list_name=sharingConfig
      IF  ${list_parameters_dict}==&{EMPTY}
        Continue For Loop
      ELSE IF  '${list_parameters_dict['controllerRole']}'=='Primary'
        Append To List  ${primary_rmod_sn_list}  ${rmod_sn}
      ELSE IF  '${list_parameters_dict['controllerRole']}'=='Secondary'
        Append To List  ${secondary_rmod_sn_list}  ${rmod_sn}
      END
    END
    [Return]  ${primary_rmod_sn_list}  ${secondary_rmod_sn_list}

#Cells
vDU SCFC Get NRCELL Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Keyword returns count of NRCELL managed objects defined in given vDU SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(//managedObject[@class='NRCELL' or @class='com.nokia.srbts.nrbts:NRCELL'])
    ${cells_count}=  Convert To Integer  ${cells_count}
    [Return]  ${cells_count}

vDU SCFC Get NRCELL Id List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the NRCELL id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${nrcell_id_list}=  Create List
    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${nrcell_dist_list}=  Get Elements  source=${scfc_file}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/@distName
    FOR  ${nrcell_dist}  IN  @{nrcell_dist_list}
      ${nrcell_id}=  Fetch From Right  string=${nrcell_dist}  marker=-
      Append to List  ${nrcell_id_list}  ${nrcell_id}
    END
    [Return]  ${nrcell_id_list}

SCFC Get NRCELL Id List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns NRCELL ids list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${nrcell_id_list}=  Create List
    ${nrcell_dist_list}=  Get Elements  source=${scfc_file_path}
    ...  xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/@distName
    FOR  ${nrcell_dist}  IN  @{nrcell_dist_list}
      ${nrcell_id}=  Fetch From Right  string=${nrcell_dist}  marker=-
      Append to List  ${nrcell_id_list}  ${nrcell_id}
    END
    [Return]  ${nrcell_id_list}

vDU SCFC Get LCELL Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Keyword returns count of LCELL managed objects defined in given vDU SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcells_count}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(//managedObject[@class='LCELL' or @class='com.nokia.srbts.mnl:LCELL'])
    ${lcells_count}=  Convert To Integer  ${lcells_count}
    [Return]  ${lcells_count}

vCU SCFC Get NRCELL Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Keyword returns count of NRCELL managed objects defined in given vCU SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(//managedObject[@class='NRCELL' or @class='com.nokia.srbts.nrbts:NRCELL'])
    ${cells_count}=  Convert To Integer  ${cells_count}
    [Return]  ${cells_count}

#General
SCFC Get Managed Object Parameter Value
    [Arguments]  ${scfc_file_path}  ${dist_name}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the parameter value from the SCFC file based on the object
    ...  dist name and the parameter name.
    ...  Example: ${dist_name}=MRBTS-1234/MNL-1/MNLENT-1/FEATCADM-1, ${parameter_name}=actCli
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | distName of the object that contains the parameter.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the parameter whose value is retrieved.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_parameter_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(@distName,"${dist_name}")]/p[@name="${parameter_name}"])
    [Return]  ${scfc_parameter_value}

SCFC Get Managed Object Parameter List Values
    [Arguments]  ${scfc_file_path}  ${dist_name}  ${list_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the list parameters values from the SCFC file
    ...  based on the object dist name and the list name.
    ...  Example arguments: ${dist_name}=MRBTS-1111/EQM-1/APEQM-1/RMOD-1  ${parameter_name}=sharingConfig
    ...  Example SCFC list parameters:
    ...  <list name="sharingConfig">
    ...  <item>
    ...  <p name="controllerRole">Primary</p>
    ...  <p name="peerRatInfo">sranSupport</p>
    ...  <p name="sharingEnabled">true</p>
    ...  </item>
    ...  </list>
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | distName of the object that contains the parameter.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_name              | Yes  | The name of the list containing the parameters.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of list (sharingConfig) parameters values.
    ...  Example output (list_parameters_dict):
    ...  {'controllerRole': 'Primary', 'peerRatInfo': 'sranSupport', 'sharingEnabled': 'true'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    &{list_parameters_dict}=  Create Dictionary
    TRY
      ${managed_object_list}=  Get Child Elements  source=${scfc_file_path}
      ...  xpath=.//managedObject[@class="com.nokia.srbts.eqm:RMOD" and @distName="${dist_name}"]/list[@name="${list_name}"]/item
    EXCEPT
      Return From Keyword  ${list_parameters_dict}
    END
    FOR  ${managed_object_parameter}  IN  @{managed_object_list}
      ${parameter_name}=  Get Element Attribute  source=${managed_object_parameter}  name=name
      Set To Dictionary  ${list_parameters_dict}  ${parameter_name}=${managed_object_parameter.text}
    END
    [Return]  ${list_parameters_dict}

SCFC Parameter Should Exist
    [Arguments]  ${scfc_file_path}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the specified parameter exists in the SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the checked parameter.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${parameter_list}=  Get Regexp Matches  string=${scfc_file}  pattern=${parameter_name}
    ${parameter_count}=  Get Length  item=${parameter_list}
    Should Be True  condition=${parameter_count}>0

SCFC Get Regexp Matches Dist Name
    [Arguments]  ${scfc_file_path}  ${dist_name}
    [Documentation]
    ...  Description:
    ...  Keyword gets the list of dist name found in the SCFC file.
    ...  Dist name can be given in the form of a regex.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | Dist name value.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${scfc_file}=  OperatingSystem.Get File  path=${scfc_file_path}
    ${dist_name_list}=  Get Regexp Matches  ${scfc_file}  distName="(${dist_name})"  1
    [Return]  ${dist_name_list}

SCFC Get Delta Parameters
    [Arguments]  ${delta_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword gets delta parameters form the delta SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | delta_file_path        | Yes  | Path to the vDU delta scfc file.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: dawid.bak@nokia.com
    ...  Maintainer: dawid.bak@nokia.com

    ${parsed_delta_file}=  Parse Xml  source=${delta_file_path}
    ${managed_object_list}=  Get Elements  source=${parsed_delta_file}  xpath=.//managedObject
    @{delta_parameter_list}=  Create List
    FOR  ${managed_object_element}  IN  @{managed_object_list}
      ${object}=  Get Element Attribute  source=${managed_object_element}  name=distName
      ${operation}=  Get Element Attribute  source=${managed_object_element}  name=operation
      ${mo_parameters_list}=  Get Elements  source=${managed_object_element}  xpath=.//*
      &{managed_object_parameters}=  Get Delta Managed Object Parameters
      ...  mo_parameters_list=${mo_parameters_list}
      &{delta_parameter_list_entry}=  Create Dictionary  object=${object}  operation=${operation}
      ...  parameters=${managed_object_parameters}
      Append To List  ${delta_parameter_list}  ${delta_parameter_list_entry}
    END
    [Return]  ${delta_parameter_list}

Get Delta Managed Object Parameters
    [Arguments]  ${mo_parameters_list}
    [Documentation]
    ...  Description:
    ...  Keyword gets managed object parameters form the managed object parameters list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | mo_parameters_list     | Yes  | Managed object parameters list.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: dawid.bak@nokia.com
    ...  Maintainer: dawid.bak@nokia.com

    &{managed_object_parameters}=  Create Dictionary
    FOR  ${managed_object_parameter}  IN  @{mo_parameters_list}
      ${parameter_name}=  Get Element Attribute  source=${managed_object_parameter}  name=name
      ${parameter_value}=  Set Variable  ${managed_object_parameter.text}
      Set To Dictionary  ${managed_object_parameters}  ${parameter_name}=${parameter_value}
    END
    [Return]  ${managed_object_parameters}
