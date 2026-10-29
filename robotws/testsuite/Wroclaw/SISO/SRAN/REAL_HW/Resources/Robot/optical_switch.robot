*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library with keywords responsible for optical switches interactions.

Library  Collections
Library  String
Library  SSHLibrary
Library  ./../Python/helpers.py
Library  taf.hw.optical_switch  WITH NAME   optical_switch

*** Keywords ***
Optical Switch Set Configuration
  [Arguments]  ${os_conf}
  [Documentation]
  ...  Description:
  ...  description of all optical matrix for specific configuration, it is providewd as a string with | as LEoni separator
  ...  eg: 192.168.255.222:1-2,2-1,3-1,4-1,5-1|192.168.255.33:1-2,2-1,3-1,4-1,5-1
  ...  each Leoni switch is describe its IP address and after a : optical matrix is provided
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | os_conf                | yes  | description of all optical matrix for specific configuration               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${current_os_config}  Split String  ${os_conf}  |
  FOR  ${out_index}  IN  @{current_os_config}
    @{os_config_cmd_index}  Split String  ${out_index}  :
    ${optical_switch}=  Find Init Object Using Attribute Value  ${TL}  ${os_config_cmd_index[0]}
    Optical Switch Setup Configuration
    ...  optical_switch=${optical_switch}
    ...  os_config_cmd=${os_config_cmd_index[1]}
    ...  alias=opt_switch
  END

Optical Switch Setup Configuration
  [Arguments]  ${optical_switch}  ${os_config_cmd}  ${alias}
  [Documentation]
  ...  Description:
  ...  KW prepraes specific configuration from os_config_cmd variable for one specific Leoni Switch
  ...  os_config_cmd variable contains string with all section in this particular Optical Switch
  ...  eg:   1-2,2-1,3-1,4-1,5-1
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | optical_switch         | yes  | python optical class taken from init file                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | os_config_cmd          | yes  | optical definition of all sections for this Leoni switch                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | yes  | Leoni optical switch alias name                                            |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  optical_switch.Setup Optical Switch
  ...  optical_switch=${optical_switch}
  ...  alias=${alias}
  optical_switch.Get Optical Switch Channels  optical_switch_device=${alias}
  ${os_config_settings_list}  Optical Switch Set Configuration Dictionary  ${os_config_cmd}
  optical_switch.Set Optical Switch Channels  settings=${os_config_settings_list}  optical_switch_device=${alias}
  optical_switch.Get Optical Switch Channels  optical_switch_device=${alias}
  [Teardown]  Run Keyword And Ignore Error  optical_switch.teardown  optical_switch_device=${alias}

Optical Switch Setup Settigs
  [Arguments]  ${optical_switch}  ${switch_settings}  ${alias}
  [Documentation]
  ...  Description:
  ...  KW change optical configuration on specific section/sections on particular Leoni switch
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | optical_switch         | yes  | python optical class taken from init file                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | switch_settings        | yes  | optical definition of  sections for this Leoni switch                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | yes  | Leoni optical switch alias name                                            |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  optical_switch.Setup Optical Switch
  ...  optical_switch=${optical_switch}
  ...  alias=${alias}
  optical_switch.Get Optical Switch Channels  optical_switch_device=${alias}
  optical_switch.Set Optical Switch Channels  settings=${switch_settings}  optical_switch_device=${alias}
  optical_switch.Get Optical Switch Channels  optical_switch_device=${alias}
  [Teardown]  Run Keyword And Ignore Error  optical_switch.teardown  optical_switch_device=${alias}

Optical Switch Set Configuration Dictionary
  [Arguments]  ${os_config_cmd}
  [Documentation]
  ...  Description:
  ...  KW modifies string descritpion for particular switch and created dictionary used by taf library
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | os_config_cmd          | yes  | string descritpion for all section in switch                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${os_config_settings_groups}  Split String  ${os_config_cmd}  ,
  ${os_config_settings_list}  Create Dictionary
  ${out_items}  Get Length  ${os_config_settings_groups}
  FOR  ${out_index}  IN RANGE  ${out_items}
    ${os_config_settings_switch}  Split String  ${os_config_settings_groups[${out_index}]}  -
    ${key}=  convert to integer  ${os_config_settings_switch[0]}
    ${value}=  convert to integer   ${os_config_settings_switch[1]}
    set to dictionary  ${os_config_settings_list}  ${key}  ${value}
  END
  [Return]  ${os_config_settings_list}
