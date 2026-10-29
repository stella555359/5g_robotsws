*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library  taf.sbts.oam.coam.admin  WITH NAME  admin

*** Keywords ***
BTS_INFO Create ASOG RF Ports With Cell List
    [Arguments]  ${connection}=${BTS_ID}
    [Documentation]
    ...  Create dict of ASOG RF ports with cells lists:
    ...
    ...    Arguments:
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | connection         | No    | alias of connection default value is BTS_ID                                                   |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    Return:
    ...    +--------------------------+-------------------------------------------------------------------------------------------------+
    ...    | Return Value             | Description                                                                                     |
    ...    +==========================+=================================================================================================+
    ...    | used_fsm_port_with_cells | RF port dictionary of cell list.                                                                |
    ...    |                          | 'RF1': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1369/LNCEL_R-35901',                   |
    ...    |                          |         '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1369/NRCELL_R-35904'],                 |
    ...    |                          | 'RF12': [],                                                                                     |
    ...    |                          | 'RF14': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1',|
    ...    |                          |          '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1369/LNCEL_R-35904',                  |
    ...    |                          |          '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1369/NRCELL_R-35907'],                |
    ...    |                          | 'RF2': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1369/LNCEL_R-35902',                   |
    ...    |                          |         '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1369/NRCELL_R-35905'],                 |
    ...    |                          | 'RF3': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1369/LNCEL_R-35903',                   |
    ...    |                          |         '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1369/NRCELL_R-35906']}                 |
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    ${fsm_info}  admin.Get FSM Info  connection=${connection}
    ${sfp_links}  admin.Get Sfp Links  connection=${connection}
    ${connected_sfp_links}  Get From Dictionary  ${sfp_links}  connected
    FOR  ${fsm}  IN  @{fsm_info}
      ${product_name}  Get From Dictionary  ${fsm}  productName
      ${airscale_core}  Run Keyword And Return Status  Should Match Regexp  ${product_name}  AirScale Core
      Run Keyword If  ${airscale_core}  Logging With Timestamp  message=You have right SMOD to test -> AirScale Core
      ...  ELSE  Run Keywords  Log  You have wrong SMOD to test -> ${fsm['productName']}  AND
      ...  Fail  You have wrong SMOD to test -> ${fsm['productName']}
      &{fsm_ports}  Create Dictionary
      ${ports}  Get From Dictionary  ${fsm}  ports
      FOR  ${port}  IN  @{ports}
        ${label}  Get From Dictionary  ${port}  label
        ${RF_label}  Run Keyword And Return Status  Should Match Regexp  ${label}  RF
        Continue For Loop If  not ${RF_label}
        ${internal_dn}  Get From Dictionary  ${port['id']}  internal
        ${sfp_connected}  Run Keyword And Return Status  Should Match Regexp  ${internal_dn}  SFP_R
        FOR  ${sfp}  IN  @{connected_sfp_links}
          Exit For Loop If  "${sfp['destination']}"=="${sfp_connected}"
          ${rmod}  Set Variable If  "${sfp['destination']}"=="${internal_dn}"  ${sfp['parent']['source']['distName']}  ${None}
          ${cablink}  Set Variable If  "${sfp['destination']}"=="${internal_dn}"  ${sfp['link']['distName']}  ${None}
          Exit For Loop If  "${sfp['destination']}"=="${internal_dn}"
        END
        Set To Dictionary  ${fsm_ports}  ${label}=${cablink}
      END
    END
    Log Dictionary  ${fsm_ports}
    ${cablink_cell}  BTS_INFO Create Cablinks Dictionary With Affected Cells Lists  connection=${connection}
    ${rf_ports}  Get Dictionary Keys  ${fsm_ports}
    &{used_fsm_port_with_cells}  Create Dictionary
    FOR  ${rf_port}  IN  @{rf_ports}
      Continue For Loop If  '${fsm_ports['${rf_port}']}'=='None'
      Set To Dictionary  ${used_fsm_port_with_cells}  ${rf_port}=${cablink_cell['${fsm_ports['${rf_port}']}']}
    END
    Log  ${used_fsm_port_with_cells}
    [Return]  ${used_fsm_port_with_cells}

BTS_INFO Create Cablinks Dictionary With Affected Cells Lists
    [Arguments]  ${connection}=${BTS_ID}
    [Documentation]
    ...  Create dict of Cablinks with cells lists:
    ...
    ...    Arguments:
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | connection         | No    | alias of connection default value is BTS_ID                                                   |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    Return:
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                                                        |
    ...    +=======================+====================================================================================================+
    ...    | affected_cablink_dict | Cablink dictionary of cell list.                                                                   |
    ...    |                       | {'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1001':                       |
    ...    |                       |           ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1', |
    ...    |                       |            '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29601',                   |
    ...    |                       |            '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-40801'],                     |
    ...    |                       |  '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1002':                       |
    ...    |                       |           ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-2/GNCEL_R-1', |
    ...    |                       |            '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29604',                   |
    ...    |                       |            '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-40801']}                     |
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    ${devices_list}=  admin.Get Managed Objects  DEVICES_LIST  connection=${connection}
    ${affected_cablink_dict}  Create Dictionary
    FOR  ${distname}  IN  @{devices_list}
      ${cell_distname}  Get From Dictionary  ${distname}  distName
      ${cell_distname}  Fetch From Left  ${cell_distname}  /CHANNEL_GROUP
      ${deviceDN_list}  Get From Dictionary  ${distname['parameters']}  deviceDNs
      @{cablink_list}  Create List
      FOR  ${device}  IN  @{deviceDN_list}
        ${cablink_dn}  Get From Dictionary  ${device}  deviceDN
        ${status}  Run Keyword And Return Status  Should Match Regexp  ${cablink_dn}  CABLINK
        Run Keyword If  ${status}  Append To List  ${cablink_list}  ${cablink_dn}
      END
      @{list}  Create List
      FOR  ${cablink}  IN  @{cablink_list}
        ${status}  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${affected_cablink_dict}  ${cablink}
        Run Keyword If  ${status}  Run Keywords
        ...  Append To List  ${list}  ${cell_distname}  AND
        ...  Set To Dictionary  ${affected_cablink_dict}  ${cablink}=@{list}
        ...  ELSE  Append To List  ${affected_cablink_dict['${cablink}']}  ${cell_distname}
      END
    END
    ${cells_distnames_dict}  BTS_INFO Create Dictionary With All Cells Distnames CELL_M And Runtime  connection=${connection}
    ${cablink_dn_list}  Get Dictionary Keys  ${affected_cablink_dict}
    FOR  ${cablink}  IN  @{cablink_dn_list}
      ${cells_list}  Get From Dictionary  ${affected_cablink_dict}  ${cablink}
      ${cells_list}  Remove Duplicates  ${cells_list}
      @{cells_runtime_list}  Create List
      FOR  ${cell_m}  IN  @{cells_list}
        ${cell_runtime}  Get From Dictionary  ${cells_distnames_dict}  ${cell_m}
        Append To List  ${cells_runtime_list}  ${cell_runtime}
      END
      ${cells_runtime_list}  Remove Duplicates  ${cells_runtime_list}
      Remove From Dictionary  ${affected_cablink_dict}  ${cablink}
      Set To Dictionary  ${affected_cablink_dict}  ${cablink}=@{cells_runtime_list}
    END
    ${all_cablinks_ids}  admin.Get Ids For All  CABLINK  connection=${connection}
    Log  ${cablink_dn_list}
    FOR  ${cablink_id}  IN  @{all_cablinks_ids}
      ${cablink_key_not_exist}  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${affected_cablink_dict}  ${cablink_id}
      Run Keyword If  ${cablink_key_not_exist}  Set To Dictionary  ${affected_cablink_dict}  ${cablink_id}=@{EMPTY}
    END
    Log Dictionary  ${affected_cablink_dict}
    [Return]  &{affected_cablink_dict}

BTS_INFO Create Dictionary With All Cells Distnames CELL_M And Runtime
    [Arguments]  ${connection}=${BTS_ID}
    [Documentation]
    ...  Create dict cell_m distname with cell runtime distname:
    ...
    ...    Arguments:
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | connection         | No    | alias of connection default value is BTS_ID                                                   |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    Return:
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                                                        |
    ...    +=======================+====================================================================================================+
    ...    | cells_distnames       | cell_m distname dictionary with cell runtime distname.                                             |
    ...    |                       | {'/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-10':                                 |
    ...    |                       |                                  '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-5464', |
    ...    |                       |  '/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-3':                                  |
    ...    |                       |                                  '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-5461', |
    ...    |                       |  '/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-4':                                  |
    ...    |                       |                                   '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-5462' |
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    ${all_cells_dict}  admin.Get Cell List  connection=${connection}
    ${nr_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  nr
    ${lte_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  lte
    ${wcdma_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  wcdma
    ${gsm_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  gsm
    ${cells_distnames}  Create Dictionary
    FOR  ${nr_cell}  IN  @{nr_cells_dict}
      ${nr_cell_dn}  Get From Dictionary  ${nr_cell['id']}  internal
      ${nr_cellm_dn}  Get From Dictionary  ${nr_cell['carrierList'][0]['id']}  internal
      ${nr_cellm_dn}  Fetch From Left  ${nr_cellm_dn}  /CHANNEL_GROUP
      Set To Dictionary  ${cells_distnames}  ${nr_cellm_dn}=${nr_cell_dn}
    END
    FOR  ${lte_cell}  IN  @{lte_cells_dict}
      ${lte_cell_dn}  Get From Dictionary  ${lte_cell['id']}  internal
      ${lte_cellm_dn}  Get From Dictionary  ${lte_cell['carrierList'][0]['id']}  internal
      ${lte_cellm_dn}  Fetch From Left  ${lte_cellm_dn}  /CHANNEL_GROUP
      Set To Dictionary  ${cells_distnames}  ${lte_cellm_dn}=${lte_cell_dn}
    END
    FOR  ${wcdma_cell}  IN  @{wcdma_cells_dict}
      ${wcdma_cell_dn}  Get From Dictionary  ${wcdma_cell['id']}  internal
      ${wcdma_cellm_dn}  Get From Dictionary  ${wcdma_cell['carrierList'][0]['id']}  internal
      ${wcdma_cellm_dn}  Fetch From Left  ${wcdma_cellm_dn}  /CHANNEL_GROUP
      Set To Dictionary  ${cells_distnames}  ${wcdma_cellm_dn}=${wcdma_cell_dn}
    END
    FOR  ${gsm_cell}  IN  @{gsm_cells_dict}
      ${gsm_cell_dn}  Get From Dictionary  ${gsm_cell['id']}  internal
      ${gsm_cell_carrier}  Get From Dictionary  ${gsm_cell}  carrierList
      FOR  ${carrier}  IN  @{gsm_cell_carrier}
        ${gsm_cellm_dn}  Get From Dictionary  ${carrier['id']}  internal
        ${gsm_cellm_dn}  Fetch From Left  ${gsm_cellm_dn}  /CHANNEL_GROUP
        Set To Dictionary  ${cells_distnames}  ${gsm_cellm_dn}=${gsm_cell_dn}
      END
    END
    Log Dictionary  ${cells_distnames}
    [Return]  ${cells_distnames}

BTS_INFO Provide ASOG Port 12 Value
    [Arguments]  ${connection}=${BTS_ID}
    [Documentation]
    ...  KK return valuse of port12RATMode for ASOG. If parameter not exist default valuse is 4G5G.
    ...
    ...    Arguments:
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | connection         | No    | alias of connection default value is BTS_ID                                                   |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    Return:
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                                                        |
    ...    +=======================+====================================================================================================+
    ...    | port12RATMode_value   | 2G3G or 4G5G                                                                                       |
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    ${smod_parameter}  admin.Get Parameter By Distname  MRBTS-${connection}/EQM-1/APEQM-1/CABINET-1/SMOD-1  connection=${connection}
    ${port12RATMode_set}  Run Keyword And Return Status  Get From Dictionary  ${smod_parameter[0]['parameters']}  port12RATMode
    ${port12RATMode_value}    Set Variable If  ${port12RATMode_set}  ${smod_parameter[0]['parameters']['port12RATMode']}  4G5G
    [Return]  ${port12RATMode_value}

BTS_INFO Get Ids For Cells
    [Arguments]  ${class}  ${node_id}  ${timeout}=60
    [Documentation]
    ...  KW returned runtime ids of cell for provided class
    ...  Supported Classes: NRCEL, LNCEL, WNCEL, GNCEL
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | class              | Yes   | Class name for which states should be checked: NRCEL, LNCEL, WNCEL, GNCEL                     |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | default value 60s                                                                             |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
        ...    +-----------------------+----------------------------------------------------------------------------------------------------+
    ...    | Return                | Description                                                                                        |
    ...    +=======================+====================================================================================================+
    ...    | ids                   | List of runtime cells distname ids for provided class                                              |
    ...    +-----------------------+----------------------------------------------------------------------------------------------------+

    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    ${bts_cell_list}  admin.Get Cell List  connection=${node_id}  timeout=${timeout}
    @{ids}  Create List
    IF  '${class}'=='NRCEL'
      ${technology}  Set Variable  nr
    ELSE IF  '${class}'=='LNCEL'
      ${technology}  Set Variable  lte
    ELSE IF  '${class}'=='WNCEL'
      ${technology}  Set Variable  wcdma
    ELSE IF  '${class}'=='GNCEL'
      ${technology}  Set Variable  gsm
    ELSE
      Fail  Provided class name -> ${class} NOT included in class NRCEL, LNCEL, WNCEL and GNCEL !!!
    END
    ${cel_list}  Get From Dictionary  ${bts_cell_list['cells']}  ${technology}
    FOR  ${cell}  IN  @{cel_list}
      Append To List  ${ids}  ${cell['id']['internal']}
    END
    [Return]  ${ids}

BTS_INFO Check If RMOD Has Supported SFP vendorPartNumber And Return Details
    [Arguments]  ${sn_rmod}  ${connection}=${BTS_ID}
    [Documentation]
    ...  Description:
    ...  Checking if sfp is included in supported_sfp list, if yes return details of this sfp
    ...  Return dictionary is further used for generating fault 6921 and 4656
    ...
    ...    +--------------------+-------+-----------------------------------------------------+
    ...    | Argument           | Man.  | Description                                         |
    ...    +====================+=======+=====================================================+
    ...    | sn_rmod            | Yes   | Serial number of RMOD                               |
    ...    +--------------------+-------+-----------------------------------------------------+
    ...    | connection         | No    | BTS_ID used as alias                                |
    ...    +--------------------+-------+-----------------------------------------------------+
    ...
    ...    Return: {'OPT_IF1': {'cablink_DN': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1001',
    ...                             'sfp_DN': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-1',
    ...                   'vendorPartNumber': 'FTLF8536W4BTV-NS'},
    ...             'OPT_IF2': {'cablink_DN': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1002',
    ...                             'sfp_DN': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-2',
    ...                   'vendorPartNumber': 'RTXM330-541-C39A'}}
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    @{supported_sfp}  Create List
         #AOME
    ...  LTF8502-BH-NK1+
    ...  RTXM228-554-C20A
    ...  MTRS-1A11-04
         #AOSI
    ...  MTRS-1E21-05
    ...  RTXM228-702-C39A
         #AOMC
    ...  FTLF8536W4BTV-NS
    ...  RTXM330-541-C39B
         #AOSO
    ...  LX6802IDW-C85
         #AOSDA
    ...  SP25ELRIDFENK1
    ${links}  admin.Get SFP Links  connection=${connection}
    &{tested_sfps_rmod}  Create Dictionary
    FOR  ${link}  IN  @{links['connected']}
      IF  '${sn_rmod}'=='${link['parent']['source']['parameters']['serialNumber']}'
        ${link_vendorpart_source}  Strip String  ${link['details']['hardwareParameters']['vendorPartNumber']['source']}
        IF  '${link_vendorpart_source}' in @{supported_sfp}
          &{link_parameters}  Create Dictionary
          Set To Dictionary  ${link_parameters}  cablink_DN=${link['link']['distName']}
          Set To Dictionary  ${link_parameters}  sfp_DN=${link['source']}
          Set To Dictionary  ${link_parameters}  vendorPartNumber=${link_vendorpart_source}
          Set To Dictionary  ${tested_sfps_rmod}  ${link['parent']['source']['physicalPort']}=&{link_parameters}
        END
      END
    END
    Log  ${tested_sfps_rmod}
    IF  "&{tested_sfps_rmod}"=="&{EMPTY}"
      Logging With Timestamp
      ...  message=RMOD ${sn_rmod} has NOT supported sfp!
      ...  message_2=SFP with supported vendorPartNumber ${supported_sfp}
      ...  style=ERROR
      Fail  RMOD ${sn_rmod} has NOT supported sfp! SFP with supported vendorPartNumber ${supported_sfp}
    ELSE
      Logging With Timestamp
      ...  message=RMOD -> ${sn_rmod} has supported SFP.
    END
    [Return]  ${tested_sfps_rmod}
