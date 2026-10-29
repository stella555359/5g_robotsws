*** Settings ***
Documentation
...  Library with basic keywords responsible for parsing scf file related to sran setup

Library  BuiltIn
Library  XML  use_lxml=true
Library  Collections
Library  String

Resource  ./../../../resources/operations.robot

*** Keywords ***
SCFC Get RMOD DistName For FR Serial Number
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}
  [Documentation]
  ...  Description:
  ...  Keyword returns value of RMOD distname for specific FR serial number from given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | fr_serial_number       | Yes  | Radio Unit serial number                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${rmod_dist_name_tmp1}=  Evaluate Xpath  ${scfc_file_path}
  ...  .//managedObject[p[@name="serNum"]="${fr_serial_number}"]/@distName
  ${rmod_dist_name_tmp2}=  Evaluate Xpath  ${scfc_file_path}
  ...  .//managedObject[p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="configDN"]/text()
  ${rmod_dist_name_tmp3}=  Evaluate Xpath  ${scfc_file_path}
  ...  .//managedObject[p[@name="serialNumber"]="${fr_serial_number}"]/@distName
  @{rmod_dist_name}=  Set Variable If  ${rmod_dist_name_tmp1}  ${rmod_dist_name_tmp1}
  ...  ${rmod_dist_name_tmp2}  ${rmod_dist_name_tmp2}
  ...  ${rmod_dist_name_tmp3}  ${rmod_dist_name_tmp3}
  ${rmod_dist_name_final}=  Should Match Regexp  ${rmod_dist_name}[0]  (.*(?:RMOD-|RMOD_R-)\\d+)
  [Return]  ${rmod_dist_name_final}[1]

SCFC Get RmodId For FR Serial Number
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}
  [Documentation]
  ...  Description:
  ...  Keyword returns value of RMOD Id for specific FR serial number from given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | fr_serial_number       | Yes  | Radio Unit serial number                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${scf_rmod_dist_name}=  SCFC Get RMOD DistName For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${rmod_id}=  Should Match Regexp  ${scf_rmod_dist_name}  RMOD(?:_R)?-(\\d+)
  [Return]  @{rmod_id}[1]

SCFC Get Cell Type
  [Arguments]  ${scfc_file_path}  ${lcr_id}
  [Documentation]
  ...  Description:
  ...  Returns cell type of given ${lcr_id}.
  ...    Supported types: legacy, inband, guardband, standalone, catm
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | Lcr ID number od cell                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: michal.szajkowski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${object_1}=  Set Variable  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL')
  ${object_2}=  Set Variable  (p[@name='cellTechnology']='FDD' or p[@name='cellTechnology']='TDD') and p[@name='lcrId']='${lcr_id}']
  ${xpath_query}=  Set Variable  ${object_1} and ${object_2}
  ${cell_is_legacy}=  Run Keyword And Return Status  Element Should Exist  ${scfc_file_path}  ${xpath_query}
  ${cell_is_iot_inband}=  Run Keyword And Return Status  Element Should Exist  ${scfc_file_path}
  ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='nbIoTMode']='inband' and p[@name='lcrId']='${lcr_id}']
  ${cell_is_iot_guardband}=  Run Keyword And Return Status  Element Should Exist  ${scfc_file_path}
  ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='nbIoTMode']='guardband' and p[@name='lcrId']='${lcr_id}']
  ${cell_is_iot_guardband-NR}=  Run Keyword And Return Status  Element Should Exist  ${scfc_file_path}
  ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='nbIoTMode']='guardband-NR' and p[@name='lcrId']='${lcr_id}']
  ${object_1}=  Set Variable  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and (p[@name='cellTechnology']='NB-IoT-FDD'
  ${object_2}=  Set Variable  p[@name='cellTechnology']='NB-IoT-TDD') and p[@name='nbIoTMode']='standalone' and p[@name='lcrId']='${lcr_id}']
  ${xpath_query}=  Set Variable  ${object_1} or ${object_2}
  ${cell_is_iot_standalone}=  Run Keyword And Return Status  Element Should Exist  ${scfc_file_path}  ${xpath_query}
  ${cell_is_catm}=  Run Keyword And Return Status  SCFC LcrId Should Be CatM  ${scfc_file_path}  ${lcr_id}
  ${cell_type}=  Set Variable If  ${cell_is_legacy}  legacy
  ...  ${cell_is_iot_inband}  inband
  ...  ${cell_is_iot_guardband}  guardband
  ...  ${cell_is_iot_guardband-NR}  guardband-NR
  ...  ${cell_is_iot_standalone}  standalone
  ...  ${cell_is_catm}  catm
  [Return]  ${cell_type}

SCFC LcrId Should Be CatM
  [Arguments]  ${scfc_file_path}  ${lcr_id}
  [Documentation]
  ...  Description:
  ...  Passes if given ${lcr_id} is a CatM cell.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | Lcr ID number od cell                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: michal.szajkowski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${lncel_dist_name}=  Evaluate Xpath  ${scfc_file_path}
  ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='lcrId']='${lcr_id}']/@distName
  ${lncel_id}=  Should Match Regexp  @{lncel_dist_name}[0]  LNCEL-(\\d+)
  Element Should Exist    ${scfc_file_path}
  ...  .//managedObject[contains(@class, "NOKLTE:LNCEL_") and contains(@distName,"LNCEL-@{lncel_id}[1]") and p[@name='actCatM']='true']

SCFC Create FR Serial Number List
  [Arguments]    ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns list of serial numbers for all RMODs defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${object_1}=  Set Variable  .//managedObject[@class=':RMOD']/p[@name='serNum']/text()
  ${object_2}=  Set Variable  .//managedObject[(contains(@class, ':RMOD_R')) and not(contains(@class, 'PWRMOD_R'))]/p[@name='serialNumber']/text()
  ${sum_object}=  Set Variable  ${object_1} | ${object_2}
  ${rmod_ser_num_list}=  Evaluate Xpath  ${scfc_file_path}  ${sum_object}
  [Return]  ${rmod_ser_num_list}

SCFC Get Attribute Value
  [Arguments]  ${scfc_file_path}  ${dist_name}  ${attribute_name}
  [Documentation]
  ...  Description:
  ...  Checks if given attribute value in the scfc file has expected value, e.g.:
  ...  ${dist_name}=LNCEL-1
  ...  ${attribute_name}=administrativeState
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | dist_name              | Yes  | distname of object, eg: LNCEL-1                                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | attribute_name         | Yes  | attribute name, eg:      administrativeState                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: tomasz.blaszczyszyn@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${attribute_value}=  Evaluate Xpath  ${scfc_file_path}
  ...  string(.//managedObject[contains(@distName,"${dist_name}")]/p[@name="${attribute_name}"])
  [Return]  ${attribute_value}

SCFC Get DistName For LcrId
  [Arguments]  ${scfc_file_path}  ${lcr_id}
  [Documentation]
  ...  Description:
  ...  Returns value of distName attribute for given lcrId.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | Lcr ID number od cell                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${dist_name}=  Evaluate Xpath  ${scfc_file_path}
  ...  string(.//managedObject[contains(@class, "LNCEL") and p[@name="lcrId"]='${lcr_id}']/@distName)
  [Return]  ${dist_name}

SCFC Get EutraCelId For LncelId
  [Arguments]  ${scfc_file_path}  ${lncel_id}
  [Documentation]
  ...  Description:
  ...  Returns value of eutraCelId attribute for given lncelId.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lncel_id               | Yes  | lncel ID number od cell                                            |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${eutra_cel_id}=  SCFC Get Attribute Value For LncelId  ${scfc_file_path}  ${lncel_id}  eutraCelId
  [Return]  ${eutra_cel_id}

SCFC Get Attribute Value For LcrId
  [Arguments]  ${scfc_file_path}  ${lcr_id}  ${attribute_name}
  [Documentation]
  ...  Description:
  ...  Returns value of given attribute name for corresponding
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | Lcr ID number od cell                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | attribute_name         | Yes  | attribute name, eg:      administrativeState                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${dist_name}=  SCFC Get DistName For LcrId  ${scfc_file_path}  ${lcr_id}
  ${object_1}=  Set Variable  string(.//managedObject[@distName="${dist_name}" or contains(@distName, "${dist_name}/LNCEL_")
  ${object_2}=  Set Variable  contains (@distName, "${dist_name}/NBIOT_")]/p[@name="${attribute_name}"])
  ${xpath_query}=  Set Variable  ${object_1} or ${object_2}
  ${attribute_value}=  Evaluate Xpath  ${scfc_file_path}  ${xpath_query}
  [Return]  ${attribute_value}

SCFC Get dlMimoMode For LcrId
  [Arguments]  ${scfc_file_path}  ${lcr_id}
  [Documentation]
  ...  Description:
  ...  Returns value of given attribute name for corresponding
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | Lcr ID number od cell                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${mimo_mode}=  SCFC Get Attribute Value For LcrId  ${scfc_file_path}  ${lcr_id}  dlMimoMode
  [Return]  ${mimo_mode}

SCFC Get RMODs Count
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns value of given attribute name for corresponding
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: tomasz.blaszczyszyn@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${rmods_count_tmp}=  Evaluate Xpath  ${scfc_file_path}  count(.//managedObject[@class="RMOD" or @class="com.nokia.srbts.eqm:RMOD"])
  ${rmods_count}=  Convert To Integer  ${rmods_count_tmp}
  [Return]  ${rmods_count}

SCFC Get Position In Chain For FR Serial Number
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}  ${first_end_point_dn}
  [Documentation]
  ...  Description:
  ...  Returns position in chain and distName of SMOD or SMOD_EXT or BBMOD or FHS (if connected through it) for given FR serial number.
  ...
  ...  Returns value of given attribute name for corresponding
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | fr_serial_number       | Yes  | radio unit serial number                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | first_end_point_dn     | Yes  | distname of first endpoint of cablink                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  Author: artur.dobosz@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${position_in_chain}=  Set Variable
  ${baseband_dist_name}=  Set Variable
  ${first_fr_in_chain_dist_name}=  Set Variable
  ${rmods_count}=  SCFC Get RMODs Count  ${scfc_file_path}
  ${rmod_dist_name}=  SCFC Get RMOD DistName For FR Serial Number  ${scfc_file_path}  ${fr_serial_number}
  ${rmod_dist_name_tmp}  ${rmod_dist_name}=  Split String  ${rmod_dist_name}  /  1
  FOR  ${index}  IN RANGE  1  ${rmods_count+2}
    ${first_fr_in_chain_dist_name}=  Set Variable If  "${index}" == "1"  ${first_end_point_dn}  ${first_end_point}
    ${object_1}=  Set Variable  string(.//managedObject[p[@name="secondEndpointDN" and contains(text(), "${rmod_dist_name}")
    ${object_2}=  Set Variable  not(substring-after(text(), "${rmod_dist_name}"))]
    ${object_3}=  Set Variable  p[@name="firstEndpointDN"]="${first_end_point_dn}"]/p[@name="firstEndpointDN"])
    ${xpath_query}=  Set Variable    ${object_1} and ${object_2} and ${object_3}
    ${first_end_point}=  Run Keyword If  "${index}" == "1"  Evaluate Xpath  ${scfc_file_path}  ${xpath_query}
      ...  ELSE  Evaluate Xpath  ${scfc_file_path}
      ...  string(.//managedObject[p[@name="secondEndpointDN"]="${first_end_point}"]/p[@name="firstEndpointDN"])
    ${first_end_point_mod}=  Should Match Regexp  ${first_end_point}  (SMOD|SMOD_EXT|BBMOD|RMOD|FHS)(?:_R)?-(\\d+)
    ${position_in_chain}=  Set Variable  ${index}
    ${baseband_dist_name}=   Set Variable  ${first_end_point}
    Exit For Loop If  "${first_end_point_mod[1]}" == "SMOD" or "${first_end_point_mod[1]}" == "SMOD_EXT" or "${first_end_point_mod[1]}" == "BBMOD"
  END
  [Return]  ${position_in_chain}  ${baseband_dist_name}  ${first_fr_in_chain_dist_name}

SCFC Get Enb Hw Release
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Gets value "enbHwRelease" of CAPCFG Managed Object.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: marcin.bednarski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${object_1}=  Set Variable  string(.//managedObject[contains(@class, "com.nokia.srbts.mnl:CAPCFG")]/p[@name='enbHwRelease']
  ${object_2}=  Set Variable  .//managedObject[contains(@class, "CAPCFG")]/p[@name='enbHwRelease'])
  ${xpath_query}=  Set Variable  ${object_1} | ${object_2}
  ${enb_hw_release}=  Evaluate Xpath  ${scfc_file_path}  ${xpath_query}
  [Return]  ${enb_hw_release}

SCFC Get Airscale Active NodeId
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Get active nodeId value from configuration file
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${active_smod_count}=  Get Element Count  ${scfc_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="horizontalPosition"]
  ${active_sm_position}=  Run Keyword If  ${active_smod_count} > 1
  ...  Get Element Text  ${scfc_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R'][p[@name="activeRole"]='Primary']/p[@name="horizontalPosition"]
  ...  ELSE IF  ${active_smod_count} == 1  Get Element Text  ${scfc_file_path}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="horizontalPosition"]
  ...  ELSE  Set Variable  1
  ${active_nodeId}=  Set Variable If  ${active_sm_position}==1  1  4
  [Return]  ${active_nodeId}

SCFC Get BtsId
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns value of btsId that is defined in given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${dist_name}=  Evaluate Xpath  ${scfc_file_path}
  ...  string(.//managedObject[contains(@class, ":MRBTS")]/@distName | .//managedObject[contains(@class, ":EQM_R")]/@distName)
  ${bts_id}=  Should Match Regexp  ${dist_name}  (?:MRBTS-)?(\\d+)

  [Return]  ${bts_id}[1]

SCF Check LTE Existence
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status of LTE presence in configuration
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="NOKLTE:LNBTS"])
  [Return]  ${result}

SCF Check WCDMA Existence
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status of WCDMA presence in configuration
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="com.nokia.srbts.wcdma:WNBTS"])
  [Return]  ${result}

SCF Check GSM Existence
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status of GSM presence in configuration
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="com.nokia.srbts.gsm:GNBTS"])
  [Return]  ${result}

SCF Check 5G Existence
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status of 5G presence in configuration
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"])
  [Return]  ${result}

SCF Check LTE Variant
  [Arguments]    ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status of LTE variant, FDD, TDD
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${fdd_result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="NOKLTE:LNCEL_FDD"])
  ${tdd_result}=  Evaluate Xpath  ${scfc_file_path}  boolean(.//managedObject[@class="NOKLTE:LNCEL_TDD"])
  [Return]    ${fdd_result}    ${tdd_result}

SCFC Get Product Name For FR Serial Number
  [Arguments]  ${scfc_file_path}  ${fr_serial_number}
  [Documentation]
  ...  Description:
  ...  Returns value of productName attribute for given FR serial number.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | fr_serial_number       | Yes  | Radio Unit serial number                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...  Maintainer: przemyslaw.kempa@nokia.com

  ${string_cmd}  Catenate  string(.//managedObject[@class="RMOD" and p[@name="serNum"]="${fr_serial_number}"]/p[@name="productName"] |
  ...  .//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R" and p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="productName"] |
  ...  .//managedObject[@class="com.nokia.srbts.eqmr:ASIRMOD_R" and p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="productName"])
  ${product_name}=  Evaluate Xpath  ${scfc_file_path}  ${string_cmd}
  [Return]    ${product_name}

SCFC Get Product Release Code For FR Serial Number
  [Arguments]    ${scfc_file_path}    ${fr_serial_number}
  [Documentation]
  ...  Description:
  ...  Returns value of radioModuleHwReleaseCode attribute for given FR serial number.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | fr_serial_number       | Yes  | Radio Unit serial number                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...  Maintainer: przemyslaw.kempa@nokia.com

  ${string_cmd}  Catenate  string(.//managedObject[@class="RMOD" and p[@name="serNum"]="${fr_serial_number}"]/p[@name="radioModuleHwReleaseCode"] |
  ...  .//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R" and
  ...  p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="radioModuleHwReleaseCode"] |
  ...  .//managedObject[@class="ASIRMOD" and p[@name="serNum"]="${fr_serial_number}"]/p[@name="radioModuleHwReleaseCode"] |
  ...  .//managedObject[@class="com.nokia.srbts.eqmr:ASIRMOD_R" and
  ...  p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="radioModuleHwReleaseCode"])
  ${release_code}=  Evaluate Xpath  ${scfc_file_path}  ${string_cmd}
  [Return]    ${release_code}

SCFC Create NRcelId List
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns list of NRCELL based on scf file
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lcr_id_list}=  SCFC Create NRcel LcrId List  ${scfc_file_path}
  ${nrcel_id_list}=  SCFC Create NRcelId List For LcrdId List  ${scfc_file_path}  ${lcr_id_list}
  [Return]  ${nrcel_id_list}

SCFC Create NRcel LcrId List
  [Arguments]  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns list of all lcrId(s).
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lcr_id_list}=  Evaluate Xpath  ${scfc_file_path}  .//managedObject[@class='com.nokia.srbts.nrbts:NRCELL']/p[@name='lcrId']/text()
  [Return]  ${lcr_id_list}

SCFC Create NRcelId List For LcrdId List
  [Arguments]  ${scfc_file_path}  ${lcr_id_list}
  [Documentation]
  ...  Description:
  ...  Returns list of NRcell(s) for input list of LcrId(s) from given SCFC file stored on local Robot PC.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id_list            | Yes  | list of lcrid for desired NRcell                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  @{nrcel_id_list}=  Create List
  FOR  ${lcr_id}  IN  @{lcr_id_list}
    ${nrcel_dist_name}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and p[@name='lcrId']='${lcr_id}']/@distName
    ${nrcel_id}=  Should Match Regexp  ${nrcel_dist_name}[0]  NRCELL-(\\d+)
    Append To List  ${nrcel_id_list}  ${nrcel_id}[1]
  END
  [Return]  ${nrcel_id_list}

Check RMOD WCDMA Cell
  [Arguments]  ${lcelw}  ${rmod}  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status if provided RU serial number contains WCDMA provided cell
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcelw                  | Yes  | lcelw for desired wcdma cell                                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | rmod                   | Yes  | Radio Unit logical number                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${wcdma_cell_rmod}=  Evaluate Xpath  ${scfc_file_path}
  ...  boolean(.//managedObject[contains(@distName,"LCELW-${lcelw}/") and contains(p[@name="antlDN"], "/${rmod}/")])
  [Return]  ${wcdma_cell_rmod}

Check RMOD LTE Cell
  [Arguments]  ${lcr_id}  ${rmod}  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status if provided RU serial number contains provided WCDMA cell
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | lcr_id                 | Yes  | lcrid for desired LTE                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | rmod                   | Yes  | Radio Unit logical number                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lte_cell_rmod}=  Evaluate Xpath  ${scfc_file_path}
  ...    boolean(.//managedObject[contains(@distName,"LCELL-${lcr_id}/") and contains(p[(@name="antlDN" or @name="resourceDN")], "/${rmod}/")])
  [Return]  ${lte_cell_rmod}

Check RMOD NRCEL Cell
  [Arguments]  ${nrcel}  ${rmod}  ${scfc_file_path}
  [Documentation]
  ...  Description:
  ...  Returns status if provided RU serial number contains provided NR cell
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | nrcel                  | Yes  | lcrid for desired NR cell                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | rmod                   | Yes  | Radio Unit logical number                                          |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${nrcel_cell_rmod}=  Evaluate Xpath  ${scfc_file_path}
  ...  boolean(.//managedObject[contains(@distName,"LCELNR-${nrcel}/") and contains(p[(@name="antlDN" or @name="resourceDN")], "/${rmod}/")])
  [Return]  ${nrcel_cell_rmod}

Scfc Get Lcrid For NRcelid
  [Arguments]  ${scfc_file_path}  ${nrcel_id}
  [Documentation]
  ...  Description:
  ...  Returns corresponding lcrId for given NRcellid
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | nrcel_id               | Yes  | lcrid for desired NRcell                                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${lcr_id}=  Evaluate Xpath  ${scfc_file_path}
  ...  string(.//managedObject[(@class='com.nokia.srbts.nrbts:NRCELL') and (contains(@distName, "NRCELL-${nrcel_id}"))]/p[@name="lcrId"])
  [Return]  ${lcr_id}

SCFC Get RF Sharing Status
    [Arguments]  ${scfc_file_path}  ${serial_number}  ${rf_class}
    [Documentation]    Returns sharing status for RMOD defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc_file_path     | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | serial_number      | Yes   | rmod sn                                                                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | rf_class           | Yes   | Possible values RMOD/ASIRMOD                                                               |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | sharing_status     | Status indicating if rmod is shared or not; True/False                                                |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${condition}=  Set Variable  contains(@class, ':${rf_class}_R') and (p[@name='serialNumber']='${serial_number}')
    ${sharing_status}=  Evaluate Xpath  ${scfc_file_path}
    ...  boolean(.//managedObject[${condition} and p[contains(@name, "radioMasterDN")]])
    [Return]  ${sharing_status}

SCFC Get RF DistName For Serial Number When Rfsharing
    [Arguments]  ${serial_number_rfs}  ${rf_class}
    [Documentation]    Returns distnames for RF when rfsharing defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | serial_number_rfs  | Yes   | Shared rmod sn                                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | rf_class           | Yes   | Possible values RMOD/ASIRMOD                                                                  |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | dist_name_rfs      | Rf rfs config_dn master/slave dictionary                                                              |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${dist_name_rfs}=  Create Dictionary  primary_dn=@{EMPTY}  secondary_dn=@{EMPTY}
    FOR  ${node}  IN  @{cfg['NODES']}
      ${xml}=  Set Variable  ${cfg['NODES']['${node}']['parsed_scf']}
      ${condition}=  Set Variable  contains(@class, ':${rf_class}_R') and (p[@name='serialNumber']='${serial_number_rfs}')
      ${primary_dn}=  Evaluate Xpath  ${xml}
      ...  string(.//managedObject[${condition} and not(p[contains(text(), "SMOD_EXT")])]/p[@name='configDN']/text())
      ${secondary_dn}=  Evaluate Xpath  ${xml}
      ...  string(.//managedObject[${condition} and (p[contains(text(), "SMOD_EXT")])]/p[@name='configDN']/text())
      ${primary_stat}=  Run Keyword And Return Status  Should Not Be Empty  ${primary_dn}
      ${secondary_stat}=  Run Keyword And Return Status  Should Not Be Empty  ${secondary_dn}
      Run Keyword If  ${primary_stat}  Append To List  ${dist_name_rfs['primary_dn']}  ${primary_dn}
      ...  ELSE IF  ${secondary_stat}  Append To List  ${dist_name_rfs['secondary_dn']}  ${secondary_dn}
    END
    [Return]  ${dist_name_rfs}

SCFC Get Cablink DistName For FR Serial Number
    [Arguments]  ${scfc_file_path}  ${serial_number}  ${rf_class}
    [Documentation]    Returns sharing status for FR defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc_file_path     | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | serial_number      | Yes   | rmod sn                                                                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | rf_class           | Yes   | Possible values RMOD/ASIRMOD                                                                  |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | cablinks           | Cablinks list for RMOD/ASIRMOD s/n                                                                    |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${rmod_dn}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(@class, ':${rf_class}_R') and (p[@name='serialNumber']='${serial_number}')]/p[@name='configDN']/text())
    ${cablinks}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, 'CABLINK') and not(contains(@class, '_R')) and (p[@name='secondEndpointDN']='${rmod_dn}')]/@distName
    [Return]  ${cablinks}

SCFC Get Cablink DistNames For FR When Rfsharing
    [Arguments]  ${dist_name_rfs}
    [Documentation]  Returns dictionary of cablinks configuration distnames for RMOD when rfsharing defined in scf.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | dist_name_rfs         | Yes   | Output dictionary from 'SCFC Get RMOD DistName For FR Serial Number When Rfsharing'           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +-----------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value          | Description                                                                                           |
    ...    +=======================+=======================================================================================================+
    ...    | cablinks_rfs          | Rfs dictionary for RMOD links                                                                         |
    ...    +-----------------------+-------------------------------------------------------------------------------------------------------+
    ${cablinks_rfs_primary}=  Create List
    ${cablinks_rfs_secondary}=  Create List
    FOR  ${bts_id}  IN  @{cfg['NODES']}
      ${xml}=  Set Variable  ${cfg['NODES']['${bts_id}']['parsed_scf']}
      ${common_condition_1}=  Set Variable  contains(@class, 'CABLINK') and not(contains(@class, '_R'))
      ${primary_condition}=  Set Variable  (p[@name='secondEndpointDN']='${dist_name_rfs['primary_dn'][0]}')
      ${common_condition_2}=  Set Variable  not(p[contains(@name, 'firstEndpointDN') and contains(text(), 'SMOD_EXT')])
      ${primary_link}=  Evaluate Xpath  ${xml}
      ...  .//managedObject[${common_condition_1} and ${primary_condition} and ${common_condition_2}]/@distName
      ${secondary_dn}=  Get Matches  ${dist_name_rfs['secondary_dn']}  MRBTS-${bts_id}*
      ${tmp_status}=  Run Keyword And Return Status  Should Not Be Empty  ${secondary_dn}
      ${secondary_dn}=  Set Variable If  ${tmp_status}  ${secondary_dn[0]}  ${SPACE}
      ${secondary_condition}=  Set Variable  (p[@name='secondEndpointDN']='${secondary_dn}')
      ${secondary_link}=  Evaluate Xpath  ${xml}
      ...  .//managedObject[${common_condition_1} and ${secondary_condition} and ${common_condition_2}]/@distName
      ${cablinks_rfs_primary}=  Combine Lists  ${cablinks_rfs_primary}  ${primary_link}
      ${cablinks_rfs_secondary}=  Combine Lists  ${cablinks_rfs_secondary}  ${secondary_link}
    END
    ${cablinks_rfs}=  Create Dictionary  primary_link=${cablinks_rfs_primary}  secondary_link=${cablinks_rfs_secondary}
    [Return]  ${cablinks_rfs}

SCFC Get Cablink Count
    [Arguments]  ${scfc_file_path}
    [Documentation]    Returns number of all OPT cablinks defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc_file_path     | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | cablink_num        | number of OPT cablinks in scf                                                                         |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${cablink_num}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(.//managedObject[contains(@class, 'CABLINK') and not(contains(@class, '_R')) and (p[@name="firstEndpointLabel"]="OPT")])
	${cablink_num}=  Convert To Integer  ${cablink_num}
    [Return]  ${cablink_num}

SCFC Create ASIRMOD Serial Number List
    [Arguments]  ${scfc_file_path}
    [Documentation]    Returns list of serial numbers for all ASIRMODs defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc_file_path     | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | asirmod_sn_list    | Asirmod serial numbers list                                                                           |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${asirmod_sn_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, 'ASIRMOD_R')]/p[@name='serialNumber']/text()
    [Return]  ${asirmod_sn_list}

SCFC Create ALD Serial Number List
    [Arguments]  ${scfc_file_path}
    [Documentation]    Returns list of serial numbers for all ALDs defined in given SCFC file stored on local Robot PC.
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc_file_path     | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | ald_sn_num_list   | Ald serial numbers list                                                                                |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ${ald_sn_num_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, 'ALD_R')]/p[@name='serialNumber']/text()
    [Return]  ${ald_sn_num_list}

SCFC Get RU Distname By Serial Number For Chaining
    [Arguments]  ${scfc}  ${class}  ${serial_number}
    [Documentation]    Returns config distname of RU by serial number and class in given SCFC file stored in CFG
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc               | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | class              | Yes   | class RMOD/ASIRMOD possible to use                                                            |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | serial_number      | Yes   | sn of RU                                                                                      |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | dn                 | RU config distname                                                                                    |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author

    ${condition}=  Set Variable  contains(@class, ':${class}_R') and (p[@name='serialNumber']='${serial_number}')
    ${dn}=  Evaluate Xpath  ${scfc}
    ...  string(.//managedObject[contains(@class, ':${class}_R') and (p[@name='serialNumber']='${serial_number}')]/p[@name='configDN']/text())
    [Return]  ${dn}

SCFC Get Cablinks DistNames By RU Serial Number For Chaining
    [Arguments]  ${scfc}  ${ru_dn}
    [Documentation]    Returns two lists. First 'first_end_point_cablinks' contains cablinks where RU is on firstEndPoint position.
    ...    Second 'sec_end_point_cablinks' contains cablinks where RU is on secondEndPoint position. Lists are used for chaing detection.
    ...    Listas are created based on given scf file stored in CFG
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | scfc               | Yes   | scf file path                                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | ru_dn              | Yes   | RU config distnames                                                                           |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | dn                 | RU config distname                                                                                    |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    Author:      daniel.bartkowiak@nokia.com
    ...    Maintainer:  Author

    ${mo_class_condition}=  Set Variable  contains(@class, 'CABLINK') and not(contains(@class, '_R'))
    ${sec_end_point_cablinks}=  Evaluate Xpath  ${scfc}
    ...  .//managedObject[${mo_class_condition} and (p[@name='secondEndpointDN']='${ru_dn}')]/@distName
    ${first_end_point_cablinks}=  Evaluate Xpath  ${scfc}
    ...  .//managedObject[${mo_class_condition} and (p[@name='firstEndpointDN']='${ru_dn}')]/@distName
    [Return]  ${first_end_point_cablinks}  ${sec_end_point_cablinks}
