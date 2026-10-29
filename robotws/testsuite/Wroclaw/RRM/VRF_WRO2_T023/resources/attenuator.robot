*** Settings ***
Documentation
...  contact: Szymon Startek

Library  taf.hw.rf_attenuator

*** Variables ***
&{ATTENUATORS}             # Dictionary with loaded attenuators data from .yaml
&{ATTENUATORS_CHANNELS}    # Dictionary with attenuator channels loaded from .yaml
&{CELLS_ATTENUATION}       # Dictionary with loaded cells data from .yaml

*** Keywords ***
Set Attenuation
    [Documentation]
    ...  Sets attenuation of cell or cells included in list of aliases.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Set attenuation of cell or cells included in list of aliases from ${CELLS_ATTENUATION} loaded from yaml configuration file.
    ...  Value of attenuation is string like '20dB' or '10%' or int or float.
    ...  Aliases of cells must be loaded with 'Load Attenuation Config And Require Attenuator' Setup before use.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | cell_alias            | Yes  | Alias of cell or list of aliases of the cells from dictionary       |
    ...  |                       |      | @{CELLS_ATTENUATION} to change attenuation on them.                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | value                 | Yes  | Value to set attenuation.                                           |
    ...  |                       |      | It should be string like 20dB, 10% or int or float.                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/resources/ta_ue_config.yaml
    ...    Load Attenuation Config And Require Attenuator Setup  ${attenuator_yaml_path}
    ...
    ...    @{alias_list}=  Create List  GNB_1_CELL_1  GNB_1_CELL_2  GNB_1_CELL_3
    ...    Set Attenuation  ${alias_list}  90db

    [Arguments]  ${cell_alias}  ${value}
    ${cell_aliases}=  Create List
    ${is_list}=  Evaluate  isinstance($cell_alias, list)
    Run Keyword If  ${is_list}  Append To List  ${cell_aliases}  @{cell_alias}
    ...             ELSE        Append To List  ${cell_aliases}  ${cell_alias}

    ${cell_aliases_length}=  Get Length  ${cell_aliases}
    Run Keyword If  ${cell_aliases_length} == 0
    ...  Log  Warning: No attenuation was performed for Set Attenuation due to empty cell list  console=True

    FOR  ${cell_alias}  IN  @{cell_aliases}
        ${attenuation_data}=  Set Variable  ${CELLS_ATTENUATION}[${cell_alias}][rf_paths_of_cell][0]
        ${port_count}=  Get Length  ${attenuation_data}[rf_paths_at_attenuator]
        ${port_values}=  Evaluate  ['${value}'] * ${port_count}
        ${attenuator_alias}=  Set Variable  ${attenuation_data}[used_attenuator]

        Set Attenuation With Value And Channel Number
        ...  channel_number=${attenuation_data}[rf_paths_at_attenuator]
        ...  value=${port_values}
        ...  alias=${attenuator_alias}
        ...  max_attenuation=${ATTENUATORS}[${attenuator_alias}][CONSTRUCTOR_PARAMETERS][max_attenuation]
    END


Set Attenuation For All Cells
    [Documentation]
    ...  Sets attenuation on all cells that were loaded from yaml.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Sets attenuation on all cells that were loaded from yaml to ${CELLS_ATTENUATION}.
    ...  Value of attenuation is string like '20dB' or '10%' or int or float.
    ...  Aliases of cells must be loaded with 'Load Attenuation Config And Require Attenuator Setup' before use.
    ...  Displays warning if dictionary ${ATTENUATORS} is empty and no attenuation was perfromed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | value                 | Yes  | Value to set attenuation.                                           |
    ...  |                       |      | It should be string like 20dB, 10% or int or float.                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/resources/ta_ue_config.yaml
    ...     Load Attenuation Config And Require Attenuator Setup  ${attenuator_yaml_path}
    ...     Set Attenuation For All Cells  100%

    [Arguments]  ${value}

    ${attenuators_length}=  Get Length  ${ATTENUATORS}
    Run Keyword If  ${attenuators_length} == 0
    ...  Log  Warning: No attenuation was performed for Set Attenuation For All Cells due to empty global variable ATTENUATORS  console=True

    FOR  ${attenuator_name}  IN  @{ATTENUATORS}
        ${attenuator}=  Set Variable  ${ATTENUATORS}[${attenuator_name}]
        ${port_count}=  Get Length  ${ATTENUATORS_CHANNELS}[${attenuator_name}]
        ${port_values}=  Evaluate  ['${value}'] * ${port_count}
        Set Attenuation With Value And Channel Number
        ...  channel_number=${ATTENUATORS_CHANNELS}[${attenuator_name}]
        ...  value=${port_values}
        ...  alias=${attenuator_name}
        ...  max_attenuation=${ATTENUATORS}[${attenuator_name}][CONSTRUCTOR_PARAMETERS][max_attenuation]
    END


Load Attenuation Config And Require Attenuator Setup
    [Documentation]
    ...  Loads configuration from yaml file to global variables and prepares resource to work with attenuators.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Uses '_load attenuation config helper' and '_require attenuator setup helper'.
    ...  Loads configuration from yaml file to global variables ${ATTENUATORS} and ${CELLS_ATTENUATION}
    ...  then prepares resource to work with attenuators loaded from yaml.
    ...  Argument is a path to yaml file with attenuator and cells configuration.
    ...  For more infromation about yaml file see Full Description of '_load attenuation config helper'.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | attenuator_yaml       | Yes  | Path to yaml file with configuration.                               |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/resources/ta_ue_config.yaml
    ...    Load Attenuation Config And Require Attenuator Setup  ${attenuator_yaml_path}

    [Arguments]  ${attenuator_yaml}
    _load attenuation config helper  ${attenuator_yaml}
    _require attenuator setup helper


Read Attenuation
    [Documentation]
    ...  Reads attenuation of cell with given alias and returns list of values on ports of it.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Reads attenuation of cell with given alias included in aliases list from ${CELLS_ATTENUATION} loaded from yaml configuration file.
    ...  Values in retured list are int or float.
    ...  Aliases of cells must be loaded with 'Load Attenuation Config And Require Attenuator' Setup before use.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | cell_alias            | Yes  | Alias of cell from dictionary @{CELLS_ATTENUATION} to read          |
    ...  |                       |      | its attenuation.                                                    |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/resources/ta_ue_config.yaml
    ...    Load Attenuation Config And Require Attenuator Setup  ${attenuator_yaml_path}
    ...
    ...    Read Attenuation  GNB_1_CELL_1

    [Arguments]  ${cell_alias}
    ${attenuation_data}=  Set Variable  ${CELLS_ATTENUATION}[${cell_alias}][rf_paths_of_cell][0]
    ${port_count}=  Get Length  ${attenuation_data}[rf_paths_at_attenuator]
    ${current_values}=  Read Ports Attenuation
	...  ports=${attenuation_data}[rf_paths_at_attenuator]  attenuator_device=${attenuation_data}[used_attenuator]
    [Return]  ${current_values}


Read Attenuation As Single Value
    [Documentation]
    ...  Reads attenuation of cell with given alias and returns values as one if all read values are the same.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Reads attenuation of cell with given alias included in aliases list from ${CELLS_ATTENUATION} loaded from yaml configuration file.
    ...  Value is retured as int or float.
    ...  If values of cell are not the same on all ports it fails.
    ...  Aliases of cells must be loaded with 'Load Attenuation Config And Require Attenuator' Setup before use.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | cell_alias            | Yes  | Alias of cell from dictionary @{CELLS_ATTENUATION} to read          |
    ...  |                       |      | its attenuation.                                                    |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/resources/ta_ue_config.yaml
    ...    Load Attenuation Config And Require Attenuator Setup  ${attenuator_yaml_path}
    ...
    ...    Read Attenuation As Single Value  GNB_1_CELL_1

    [Arguments]  ${cell_alias}
    ${ports_values}=  Read Attenuation  ${cell_alias}
    ${all_same}=  Evaluate  all(attenuation == ${ports_values}[0] for attenuation in ${ports_values})
    Should Be True  ${all_same}  msg=Not all attenuation values for cell ${cell_alias} are the same. Values: ${ports_values}.
    [Return]  ${ports_values}[0]


Set Attenuation With Value And Channel Number
    [Documentation]
    ...  Sets attenuation on specified attenuator channel on attenuator of specified alias.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Sets attenuation on specified attenuator channel on attenuator of specified alias.
    ...  Attenuator has to be setup before using this keyword with 'Load Attenuation Config And Require Attenuator Setup' or
    ...  'Setup Attenuator And Check Status'
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                              |
    ...  +=======================+======+==========================================================================+
    ...  | channel_number        | Yes  | Ports on the attenuator to set. Ports as single number or list of them.  |
    ...  +-----------------------+------+--------------------------------------------------------------------------+
    ...  | value                 | Yes  | Value or list of values to set attenuation.                              |
    ...  |                       |      | It should be string like 20dB, 10%, int, float or list of them.          |
    ...  +-----------------------+------+--------------------------------------------------------------------------+
    ...  | alias                 | Yes  | Alias of attenuator to set the attenuation value.                        |
    ...  +-----------------------+------+--------------------------------------------------------------------------+
    ...  | max_attenuation       | No   | Maximum attenuation value. Value as int or float. Default value 90.      |
    ...  +-----------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Set Attenuation With Value And Channel Number  1  90db  TOPYOUNG  90

    [Arguments]  ${channel_number}  ${value}  ${alias}  ${max_attenuation}=${90}

    ${channel_numbers}=  Create List
    ${is_list}=  Evaluate  isinstance($channel_number, list)
    Run Keyword If  ${is_list}  Append To List  ${channel_numbers}  @{channel_number}
    ...             ELSE        Append To List  ${channel_numbers}  ${channel_number}

    ${channel_numbers_length}=  Get Length  ${channel_numbers}

    ${values}=  Create List
    ${is_list}=  Evaluate  isinstance($value, list)
    Run Keyword If  ${is_list}  Append To List  ${values}  @{value}
    ...             ELSE        Append To List  ${values}  ${value}

    ${db_values}=  Values To dB List  ${values}  ${max_attenuation}

    Length Should Be  ${values}  ${channel_numbers_length}  msg=Length of attenuation values is different than list of ports

    Set Ports Attenuation  ports=${channel_numbers}
    ...  values=${db_values}
    ...  confirm=${True}
    ...  attenuator_device=${alias}

    ${current_values}=  Read Ports Attenuation  ports=${channel_numbers}  attenuator_device=${alias}
    Lists Should Be Equal  ${current_values}  ${db_values}  msg=Attenuation not set correctly


Setup Attenuator And Check Status
    [Documentation]
    ...  Prepares resource to work with a specified attenuator of given IP Adress, port, attenuation ports, vendor, model and alias.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Prepares resource to work with a specified attenuator of given IP Adress, port, attenuation ports, vendor, model and alias.
    ...  If setup not finished correctly keyword will fail.
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | Parameter                | Man. | Description                                                         |
    ...  +==========================+======+=====================================================================+
    ...  | ip_address               | Yes  | IP address of the attenuator.                                       |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | port                     | Yes  | Attenuator's port for management, commonly is 23, 30000 or 3001.    |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | attenuation_port_numbers | Yes  | List of port numbers on the attenuator.                             |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | vendor                   | Yes  | Vendor of the attenuator, e.g. JFW or TOPYOUNG.                     |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | model                    | Yes  | Model of the Attenuator,                                            |
    ...  |                          |      | e.g. '50P-0033' or 'TAS_24T24_04G6_90_1S_EJS'.                      |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | min_attenuation          | Yes  | Minimum attenuation value. Value as int or float.                   |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | max_attenuation          | Yes  | Maximum attenuation value. Value as int or float.                   |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...  | alias                    | Yes  | Alias of attenuator to be used in keywords.                         |
    ...  +--------------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${port_list}=  Create List  1  2  3  4  17  18  19  20
    ...    Setup Attenuator And Check Status  1.2.3.4  30001  ${port_list}  TOPYOUNG  TAS_24T24_04G6_90_1S_EJS  0  90  topyoung

    [Arguments]  ${ip_address}  ${port}  ${attenuation_port_numbers}  ${vendor}  ${model}  ${min_attenuation}  ${max_attenuation}  ${alias}
    Log  Setting attenuator  console=true
    ${status}=  Run Keyword And Return Status  Setup Attenuator
    ...  ip_addr=${ip_address}
    ...  port=${port}
    ...  attenuation_port_numbers=${attenuation_port_numbers}
    ...  vendor=${vendor}
    ...  model=${model}
    ...  min_attenuation=${min_attenuation}
    ...  max_attenuation=${max_attenuation}
    ...  alias=${alias}
    Should Be True  ${status}  msg=Attenuator not setup properly


_load attenuation config helper
    [Documentation]
    ...  Loads configuration from yaml file to global variables ${ATTENUATORS} and ${CELLS_ATTENUATION}.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Loads configuration from yaml file to global variables ${ATTENUATORS} and ${CELLS_ATTENUATION}.
    ...  Argument is a path to yaml file with attenuator and cells configuration.
    ...  Yaml should contain two dictionaries: ATTENUATORS and CELLS_ATTENUATION.
    ...  ATTENUATORS should contain aliases of attenuators as keys and dictionary with that attenuator data.
    ...  That dictionaries should contain:
    ...  -- 'VENDOR' as a key and name of vendor of that attenuator as a value.
    ...  -- 'MODEL' as a key and name of model of that attenuator as a value.
    ...  -- 'CONSTRUCTOR_PARAMETERS' as a key and dictionary of other attenuator data.
    ...     That dictionary should contain:
    ...     -- 'ip' as a key and adress ip of attenuator as a value.
    ...     -- 'port' as a key and port of attenuator as a value.
    ...     -- 'min_attenuation' as a key and value of minimal attenuation on atteuator as a value. Should be int or float.
    ...     -- 'max_attenuation' as a key and value of maximal attenuation on atteuator as a value. Should be int or float.
    ...
    ...  CELLS_ATTENUATION should contain aliases of cells as keys and dictionary with data of attenuators of that cell.
    ...  That dictionaries should contain:
    ...  -- 'rf_paths_of_cell' as a key and list containing another dicionary as a value.
    ...     That dictionary should contain:
    ...     -- 'used_attenuator' as a key and as a value an alias of the attenuator that was used in ATTENUATORS as a key.
    ...     -- 'rf_paths_at_attenuator' as a key and list of corresponding ports on the attenuator as a value
    ...
    ...  Example of yaml:
    ...  ATTENUATORS:
    ...     TOPYOUNG:
    ...        VENDOR: TOPYOUNG
    ...        MODEL: TAS_24T24_02G6_90_1C_EJS
    ...        CONSTRUCTOR_PARAMETERS:
    ...           ip: '10.42.54.1'
    ...           port: 3001
    ...           min_attenuation: 0
    ...           max_attenuation: 90
    ...
    ...  CELLS_ATTENUATION:
    ...     GNB_1_CELL_1:
    ...        rf_paths_of_cell:
    ...        -   used_attenuator: TOPYOUNG
    ...            rf_paths_at_attenuator:
    ...            - 1
    ...            - 2
    ...     GNB_1_CELL_2:
    ...         rf_paths_of_cell:
    ...         -   used_attenuator: TOPYOUNG
    ...             rf_paths_at_attenuator:
    ...             - 5
    ...             - 6
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | attenuator_yaml       | Yes  | Path to yaml file with configuration.                               |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/ta_ue_config.yaml
    ...    _load attenuation config helper  ${attenuator_yaml_path}

    [Arguments]  ${attenuator_yaml}
    Import Variables  ${attenuator_yaml}

    Set Suite Variable  &{ATTENUATORS_CHANNELS}
    FOR  ${value}  IN  @{ATTENUATORS}
        ${channels}=  Create List
        Set To Dictionary  ${ATTENUATORS_CHANNELS}  ${value}  ${channels}
    END

    FOR  ${value}  IN  @{CELLS_ATTENUATION}
        ${attenuator_name}=  Set Variable  ${CELLS_ATTENUATION}[${value}][rf_paths_of_cell][0][used_attenuator]
        ${rf_paths_at_attenuator}=  Set Variable  ${CELLS_ATTENUATION}[${value}][rf_paths_of_cell][0][rf_paths_at_attenuator]
        Append To List  ${ATTENUATORS_CHANNELS}[${attenuator_name}]  @{rf_paths_at_attenuator}
    END


_require attenuator setup helper
    [Documentation]
    ...  Prepares resource to work with a specified attenuators loaded from yaml.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Prepares resource to work with a specified attenuators loaded from yaml to global variables
    ...  ${ATTENUATORS} and ${CELLS_ATTENUATION}. Setup attenuator that can be refered by alias later.
    ...  '_load attenuation config helper' is required before using this KW.
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${attenuator_yaml_path}=  Set Variable  testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Karlowice/ta_ue_config.yaml
    ...    _load attenuation config helper  ${attenuator_yaml_path}
    ...    _require attenuator setup helper

    ${attenuators_length}=  Get Length  ${ATTENUATORS}
    Should Be True  ${attenuators_length} > 0  msg=No attenuator was loaded to dictionary ATTENUATORS

    FOR  ${attenuator_name}  IN  @{ATTENUATORS}
        ${attenuator}=  Set Variable  ${ATTENUATORS}[${attenuator_name}]
        Setup Attenuator And Check Status
        ...  ip_address=${attenuator}[CONSTRUCTOR_PARAMETERS][ip]
        ...  port=${attenuator}[CONSTRUCTOR_PARAMETERS][port]
        ...  attenuation_port_numbers=${ATTENUATORS_CHANNELS}[${attenuator_name}]
        ...  vendor=${attenuator}[VENDOR]
        ...  model=${attenuator}[MODEL]
        ...  min_attenuation=${attenuator}[CONSTRUCTOR_PARAMETERS][min_attenuation]
        ...  max_attenuation=${attenuator}[CONSTRUCTOR_PARAMETERS][max_attenuation]
        ...  alias=${attenuator_name}
    END


Value To dB
    [Documentation]
    ...  Converts any value of attenuation like '90', '90dB' or '100%' to float value in dB like 90.0.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Converts any value of attenuation like '90', '90dB' or '100%' to float value in dB like 90.0.
    ...  List of allowed formats (where '*' is a number):
    ...  '*', '*.*',
    ...  '*db', '*.*db', '* db', '*.* db',      (where 'db' can be also 'dB', 'DB' or even 'Db')
    ...  '*%', '*.*%', '* %', '*.* %'           (it needs a proper max_attenuation, defaut is 90)
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | value                 | Yes  | Value to convert.                                                   |
    ...  |                       |      | It should be string like 20dB, 10% or int or float.                 |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | max_attenuation       | No   | Maximum attenuation value which can be sent to device in dB.        |
    ...  |                       |      | It is needed when used with value that contains '%'.                |
    ...  |                       |      | Value as int or float. Default value: 90                            |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Value To dB  70%  90

    [Arguments]  ${value}  ${max_attenuation}=${90}
    ${has_percent}=  Evaluate  $value[-1] == '%'
    ${has_db}=  Evaluate  $value[-2:].lower() == 'db'

    ${db_value}=  Run Keyword IF  ${has_percent}  Evaluate  float($value[:-1]) * float($max_attenuation) / 100
    ...           ELSE IF         ${has_db}       Evaluate  float($value[:-2])
    ...                           ELSE            Evaluate  float($value)

    [Return]  ${db_value}


Values To dB List
    [Documentation]
    ...  Returns converted list of values of attenuation to list of float in dB.
    ...
    ...  | **Author:** szymon.startek@nokia.com
    ...  | **Maintainer:** szymon.startek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Returns converted list of values of attenuation like ['90dB', '80dB', '100dB'] to list of float in dB
    ...  like [90.0, 80.0, 100.0]. Values in input list can be in the same format as in Full Description of Value To dB.
    ...  Proper max_attenuation is needed for values with percent.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                         |
    ...  +=======================+======+=====================================================================+
    ...  | values                | Yes  | List of value to convert.                                           |
    ...  |                       |      | It should cointain string like 20dB, 10% or int or float.           |
    ...  |                       |      | Example ['90dB', '80dB', '60dB'] or ['100%', '80%', '90%']          |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...  | max_attenuation       | No   | Maximum attenuation value which can be sent to device in dB.        |
    ...  |                       |      | It is needed when used with value that contains '%'.                |
    ...  |                       |      | Value as int or float. Default value: 90                            |
    ...  +-----------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${list_of_values}=  Create List  40%  90%  30db  40db
    ...     Values To dB List  ${list_of_values}  90

    [Arguments]  ${values}  ${max_attenuation}=${90}

    ${db_values}  Create List
    FOR  ${value}  IN  @{values}
        ${db_value}=  Value To dB  ${value}  ${max_attenuation}
        Append To List  ${db_values}  ${db_value}
    END
    [Return]  ${db_values}
