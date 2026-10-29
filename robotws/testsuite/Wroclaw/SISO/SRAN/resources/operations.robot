*** Settings ***

Library    BuiltIn
Library    Collections
Library    String

*** Keywords ***
Combine Lists And Remove Duplicates
    [Arguments]  @{lists}
    [Documentation]
    ...  Description:
    ...  Keyword combines lists and remove duplicates.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lists                  | Yes  | Lists to be combines.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${combined_lists}=  Combine Lists  @{lists}
    ${combined_lists}=  Remove Duplicates  ${combined_lists}
    [Return]    ${combined_lists}

Convert List to Integer
    [Arguments]  ${list_to_convert}
    [Documentation]
    ...  Description:
    ...  Keyword converts all numbers in the list stored as text values to integer values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_to_convert        | Yes  | The list of string values.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${list}=  Copy List  ${list_to_convert}
    ${list_size}=  Get Length  item=${list}
    FOR  ${list_index}  IN RANGE  ${list_size}
      ${value_list}=  Get From List  ${list}  ${list_index}
      ${value_list}=  Convert To Integer  item=${value_list}
      Remove From List  ${list}  ${list_index}
      Insert Into List  ${list}  ${list_index}  ${value_list}
    END
    [Return]  ${list}

Convert List to String
    [Arguments]  ${list_to_convert}
    [Documentation]
    ...  Description:
    ...  Keyword converts all numbers in the list stored as integer values to string values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_to_convert        | Yes  | The list of integer values.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${list}=  Copy List  ${list_to_convert}
    ${list_size}=  Get Length  item=${list}
    FOR  ${list_index}  IN RANGE  ${list_size}
      ${value_list}=  Get From List  ${list}  ${list_index}
      ${value_list}=  Convert To String  item=${value_list}
      Remove From List  ${list}  ${list_index}
      Insert Into List  ${list}  ${list_index}  ${value_list}
    END
    [Return]  ${list}

Get Random List Based On Input List
    [Arguments]  ${list}  ${length}
    [Documentation]
    ...  Description:
    ...  Keyword generates a list with a random number ${length} of elements based on the input list ${list}.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list                   | Yes  | The list from which a random list will be generated.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | length                 | Yes  | The length of the generated random list.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${random_list}=  Evaluate  random.sample(${list}, ${length})  random
    [Return]  ${random_list}

Get Regexp Matches From List
    [Arguments]  ${string}  ${list}
    [Documentation]
    ...  Description:
    ...  Keyword returns a list of all non-overlapping matches in the given list string.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | string                 | Yes  | String to find matches from.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list                   | Yes  | List of patterns (regular expressions).                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${list_value}  IN  @{list}
      ${regexp_result_list}=  Get Regexp Matches  string=${string}  pattern=${list_value}
      Exit For Loop If  ${regexp_result_list}!=@{EMPTY}
    END
    [Return]  ${regexp_result_list}

Get Random List
    [Arguments]  ${begin_range}  ${end_range}  ${length}
    [Documentation]
    ...  Description:
    ...  Keyword generates a list with a random number ${length} of elements based on.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | begin_range            | Yes  | Initial range of the random list.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | end_range              | Yes  | End range of the random list.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | length                 | Yes  | Length of the generated random list.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${random_list}=  Evaluate  random.sample(range(${begin_range}, ${end_range}), ${length})  random
    [Return]  ${random_list}

Generate List Of Numbers Based On Range
    [Arguments]  ${start_value}  ${end_value}  ${convert_to_string}=${False}
    [Documentation]
    ...  Description:
    ...  Keyword generates a list of numbers given as a range from a start value to an end value.
    ...  The list can be a string or integer list.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | start_value            | Yes  | Starting value of the list.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | end_value              | Yes  | Final value of the list.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | convert_to_string      | Yes  | Whether the list should be of type string. The default is integer.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${values_list}=  Create List
    FOR  ${list_element}  IN RANGE  ${start_value}  ${end_value}+1
      ${list_element}=  Run Keyword If  ${convert_to_string}
      ...  Convert To String  ${list_element}
      ...  ELSE
      ...  Set Variable  ${list_element}
      Append To List  ${values_list}  ${list_element}
    END
    [Return]  ${values_list}
