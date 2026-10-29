*** Settings ***
Documentation  Optical switch management keywords.
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    Collections
Library    String
Library    taf.hw.optical_switch    WITH NAME    optical_switch

*** Keywords ***
Set Optical Switch
    [Arguments]  ${channel_setup}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword sets the appropriate channel on the optical switch group.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | channel_setup          | Yes  | List of switch channel setup.                                              |
    ...  |                        |      | Example: ['3', '1', '1', '3'].                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show (or not) on the console information about switch channel setup.       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  ${channel_setup}=  Create List  3  1  1  3
    ...  Set Optical Switch  channel_setup=${channel_setup}  log_to_console=True
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Setup Optical Switch  optical_switch=${tl.optical_switches[0]}
    ${optical_switch_init_setup}=  Get Optical Switch Channels
    ${optical_switch_setup}=  Create Optical Switch Channels Settings  channel_setup=${channel_setup}
    Set Optical Switch Channels  settings=${optical_switch_setup}
    ${optical_switch_setup}=  Get Optical Switch Channels
    Log  ${log_prefix}Optical switch setup:  console=${log_to_console}
    Run Keyword If  ${log_to_console}
    ...  Show Optical Switch Setup  optical_switch_setup=${optical_switch_setup}  log_prefix=${info_prefix}
    [Teardown]  optical_switch.Teardown

Show Optical Switch Setup
    [Arguments]  ${optical_switch_setup}  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword converts the standard optical switch response in the form of a dictionary
    ...  to a more human readable one and log to console.
    ...  Dictionary key is the switch number.
    ...  Dictionary value is the switch channel settings.
    ...  Example:
    ...  Input:  {1: 3, 2: 1, 3: 1, 4: 3, 5: 1, 6: 1}
    ...  Output: Switch:  1 2 3 4 5 6
    ...          Channel: 3 1 1 3 1 1
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | optical_switch_setup   | Yes  | Dictionary of switch channel setup.                                        |
    ...  |                        |      | Example: {1: 3, 2: 1, 3: 1, 4: 3, 5: 1, 6: 1}.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  Show Optical Switch Setup  optical_switch_setup=${optical_switch_setup}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${switch_list}=  Get Dictionary Keys  dictionary=${optical_switch_setup}
    ${switch_string}=  Get Substring  '@{switch_list}'  2  -2
    ${switch_string}=  Remove String  ${switch_string}  ,
    ${channel_list}=  Get Dictionary Values  dictionary=${optical_switch_setup}
    ${channel_string}=  Get Substring  '@{channel_list}'  2  -2
    ${channel_string}=  Remove String  ${channel_string}  ,
    Log  ${log_prefix}Switch: ${SPACE}${switch_string}  console=True
    Log  ${log_prefix}Channel: ${channel_string}  console=True

Create Optical Switch Channels Settings
    [Arguments]  ${channel_setup}
    [Documentation]
    ...  Description:
    ...  Keyword converts list of switch channels list to the form of dictionary.
    ...  Dictionary key is the switch number.
    ...  Dictionary value is the switch channel settings.
    ...  Example:
    ...  Input:  ['3', '1', '1', '3']
    ...  Output: {1: 3, 2: 1, 3: 1, 4: 3}
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | channel_setup          | Yes  | List of switch channel setup.                                              |
    ...  |                        |      | Example: ['3', '1', '1', '3'].                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Description                                                                       |
    ...  +========================+======+============================================================================+
    ...  | channel_setup_dict     | Dictionary of switch channel setup.                                               |
    ...  |                        | Example: {1: 3, 2: 1, 3: 1, 4: 3, 5: 1, 6: 1}.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  ${optical_switch_setup}=  Create Optical Switch Channels Settings  channel_setup=${channel_setup}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${channel_setup_dict}=  Create Dictionary
    ${switch_number}=  Evaluate  0
    FOR  ${channel_number}  IN  @{channel_setup}
      ${switch_number}=  Evaluate  ${switch_number}+1
      ${channel_number}=  Convert To Integer  item=${channel_number}
      Set To Dictionary  ${channel_setup_dict}  ${switch_number}  ${channel_number}
    END
    [Return]  ${channel_setup_dict}

