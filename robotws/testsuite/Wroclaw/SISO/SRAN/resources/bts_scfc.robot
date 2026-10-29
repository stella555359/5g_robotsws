*** Settings ***
Documentation
...    Author: slawomir.jastrzebski@nokia.com
...    Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    XML  use_lxml=true
Library    Collections
Library    String

*** Keywords ***
SCFC Create LncelId List For LcrdId List
    [Arguments]  ${scfc_file_path}  ${lcr_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of LncelId based on list of LcrId given from SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_list            | Yes  | List of lcr cell id.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    @{lncel_id_list}=  Create List
    FOR  ${lcr_id}  IN  @{lcr_id_list}
      ${lncel_dist_name}=  Evaluate Xpath  ${scfc_file_path}
      ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='lcrId']='${lcr_id}']/@distName
      ${lncel_id}=  Should Match Regexp  ${lncel_dist_name}[0]  LNCEL-(\\d+)
      Append To List  ${lncel_id_list}  ${lncel_id}[1]
    END
    [Return]  ${lncel_id_list}

SCFC Get LcrId For LncelId
    [Arguments]  ${scfc_file_path}  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns corresponding lcrId for given lncelId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dist_name_part}=  Evaluate Xpath  ${scfc_file_path}
    ...  substring-before(.//managedObject[(@class="LNCEL" or @class="NOKLTE:LNCEL") and p[@name="lcrId"]]/@distName, "LNCEL")
    ${dist_name}=  Set Variable  @distName="${dist_name_part}LNCEL-${lncel_id}" or contains(@distName, "LNCEL-${lncel_id}/LNCEL_")
    ${lcr_id}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(@class, "LNCEL") and (${dist_name})]/p[@name="lcrId"])
    [Return]  ${lcr_id}

SCFC Get LncelId For LcrId
    [Arguments]  ${scfc_file_path}  ${lcr_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns corresponding lncelId for given lncelId.
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
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dist_name}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[(@class="LNCEL" or @class="NOKLTE:LNCEL") and p[@name="lcrId"]="${lcr_id}"]/@distName)
    ${lncel_id}=  Should Match Regexp  ${dist_name}  LNCEL-(\\d+)
    [Return]  ${lncel_id[1]}

SCFC Create LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns cell lcrId list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_list}=  Evaluate Xpath
    ...  ${scfc_file_path}  .//managedObject[@class='LNCEL' or @class='NOKLTE:LNCEL']/p[@name='lcrId']/text()
    [Return]  ${lcr_id_list}

SCFC Create LncelId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns cell LNCEL id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    [Return]  ${lncel_id_list}

SCFC Create Not IoT LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all lcrId(s) without IoT cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  p[@name='cellTechnology']='FDD' or p[@name='cellTechnology']='TDD'
    ${lcr_id_not_iot_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and (${xpath_element})]/p[@name='lcrId']/text()
    [Return]  ${lcr_id_not_iot_list}

SCFC Create IoT LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all IoT lcrId(s).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_iot_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='cellTechnology']='NB-IoT-FDD']/p[@name='lcrId']/text()
    [Return]  ${lcr_id_iot_list}

SCFC Create IoT Inband And Guardband LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all lcrId(s) IoT inband and IoT guardband cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  p[@name='cellTechnology']='NB-IoT-FDD' and (p[@name='nbIoTMode']='inband' or p[@name='nbIoTMode']='guardband')
    ${lcr_id_iot_inband_guardband_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  //managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and ${xpath_element}]/p[@name='lcrId']/text()
    [Return]  ${lcr_id_iot_inband_guardband_list}

SCFC Create Not IoT Inband And Guardband LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all lcrId(s) without IoT inband and IoT guardband cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  p[@name='cellTechnology']='NB-IoT-FDD' and (p[@name='nbIoTMode']='inband' or p[@name='nbIoTMode']='guardband')
    ${lcr_id_not_iot_inband_guardband_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  //managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and not(${xpath_element})]/p[@name='lcrId']/text()
    [Return]  ${lcr_id_not_iot_inband_guardband_list}

SCFC Get Not IoT Inband And Guardband Cells Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns count of all cells without IoT inband and IoT guardband cells defined in given SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  p[@name='cellTechnology']='NB-IoT-FDD' and (p[@name='nbIoTMode']='inband' or p[@name='nbIoTMode']='guardband')
    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}
    ...  count(//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and not(${xpath_element})])
    ${cells_count}=  Convert To Integer  ${cells_count}
    [Return]  ${cells_count}

SCFC Create IoT Linked LcrId List
    [Arguments]  ${scfc_file_path}  ${lcr_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of nbIoT linked lcrId(s) based on ${lcr_id_list}.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_list            | Yes  | List of lcr cell id.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${lcr_id_nbiot_linked_list}=  Create List
    FOR  ${lcr_id}  IN  @{lcr_id_list}
      ${lcr_id_nbiot_linked}=  Evaluate Xpath  ${scfc_file_path}
      ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='lcrId']='${lcr_id}']/p[@name='nbIotLinkedCellId']/text()
      Append To List  ${lcr_id_nbiot_linked_list}  @{lcr_id_nbiot_linked}
    END
    [Return]  ${lcr_id_nbiot_linked_list}

SCFC Create CatM LcrId List
    [Arguments]  ${scfc_file_path}  ${lcr_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all CatM lcrlId(s) for input list of LcrId(s).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_list            | Yes  | List of lcr cell id.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    @{lcr_id_catm_list}=  Create List
    FOR  ${lncel_id}  IN  @{lncel_id_list}
      ${xpath_element}=  Set Variable  @distName, "LNCEL-${lncel_id}"
      ${result_list}=  Evaluate Xpath  ${scfc_file_path}
      ...  string(.//managedObject[(@class='NOKLTE:LNCEL_FDD' or @class='NOKLTE:LNCEL_TDD') and contains(${xpath_element})]/p[@name='actCatM'])
      ${lcr_id}=  SCFC Get LcrId For LncelId  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
      Run Keyword If  '${result_list}'=='true'  Append To List  ${lcr_id_catm_list}  ${lcr_id}
    END
    [Return]  ${lcr_id_catm_list}

SCFC Create IoT Standalone LcrId List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all lcrId(s) IoT standalone cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  p[@name='cellTechnology']='NB-IoT-FDD' and (p[@name='nbIoTMode']='standalone')
    ${lcr_id_iot_standalone_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  //managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and (${xpath_element})]/p[@name='lcrId']/text()
    [Return]  ${lcr_id_iot_standalone_list}

SCFC Get Attribute Value For LncelId
    [Arguments]  ${scfc_file_path}  ${lncel_id}  ${attribute_name}
    [Documentation]
    ...  Keyword returns value of given attribute name for corresponding lncelId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${xpath_element}=  Set Variable  substring-after(@distName, "LNCEL-${lncel_id}")="" or contains(@distName, "LNCEL-${lncel_id}/LNCEL_")
    ${attribute_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(@distName, "LNCEL-${lncel_id}") and (${xpath_element})]/p[@name="${attribute_name}"])
    [Return]  ${attribute_value}

SCFC Get Cells Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Keyword returns count of cells defined in given SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument             |   Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}  count(//managedObject[@class='LNCEL' or @class='NOKLTE:LNCEL'])
    ${cells_count}=  Convert To Integer  ${cells_count}
    [Return]  ${cells_count}

SCFC Get SMOD Count
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns count of SMOD from SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${smod_count}=
    ...  Evaluate Xpath  ${scfc_file_path}  count(.//managedObject[@class="SMOD" or @class="com.nokia.srbts.eqm:SMOD"])
    ${smod_count}=  Convert To Integer  item=${smod_count}
    [Return]  ${smod_count}

SCFC Get Activate Category Alarms Value
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
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result_value}=  Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[@class='com.nokia.srbts.mnl:FMCADM']/p[@name='actCategoryAlarms'])
    ${result_value}=  Convert To Boolean  item=${result_value}
    [Return]  ${result_value}

SCFC Get dlMimoMode For LncelId
    [Arguments]  ${scfc_file_path}  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns value of dlMimoMode attribute for given lncelId.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mimo_mode}=  SCFC Get Attribute Value For LncelId
    ...  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}  attribute_name=dlMimoMode
    [Return]  ${mimo_mode}

SCFC Get SMOD Position In Subrack
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword gets "positionInSubrack" parameter value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${position_insubrack_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, "SMOD")]/p[@name='positionInSubrack']/text()
    [Return]  ${position_insubrack_list}

SCFC Get SMOD Numer Of Position In Subrack
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword gets number of "positionInSubrack" parameters.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${position_insubrack_count}=  Evaluate Xpath  ${scfc_file_path}
    ...    count(.//managedObject[contains(@class, "SMOD")]/p[@name='positionInSubrack'])
    [Return]  ${position_insubrack_count}

SCFC Get Radio Modules Serial Numbers
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns radio modules serial number list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the SCFC file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_list}=  Evaluate Xpath
    ...  ${scfc_file_path}  .//managedObject[@class='com.nokia.srbts.eqmr:RMOD_R']/p[@name='serialNumber']/text()
    [Return]  ${rmod_sn_list}
