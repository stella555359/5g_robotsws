*** Settings ***
Documentation    Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
Library  OperatingSystem
Library  Collections
Library  String

Resource  ./SSH.robot

*** Variables ***
${GOLDEN_SWCONFIG_PATH}  ${EXEC_DIR}/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/swconfig.txt
${CHECK_SWCONFIG}  True  # True ->(default value) Swconfigs from all system modules will be check against golden swconfig and flags defined in
#  {CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}. In case of discrepancy golden swconfig and additional user flags will be loaded
#  on all system modules
# False -> Swconfigs from system modules will be collected but they won't be compared with golden swconfig and user flags

@{CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}  # list of flags defined by user which should be added to swconfig.txt (use two spaces to separate flags)
# e.g. 0x200A6= 1 #redirect prints from rmods
# e.g. 0x200A6= 1 #redirect prints from rmods  0x1003f = 2  0x45005a=1


*** Keywords ***
#KW do wrzucenia do setup_and_teardown.robot
Swconfig Operations
  [Documentation]
  ...  Description:
  ...  KW collects swconfigs from all system modules.
  ...  If CHECK_SWCONFIG=True KW compares collected swconfigs with golden swconfig and load golden swconfig in case of discrepancy.
  ...  If CHECK_SWCONFIG=True and user defines flags in CUSTOM_ADDITIONAL_SWCONFIG_FLAGS KW compares collected swconfigs with golden swconfig and
  ...  flags defined by user and load combined swconfig (golden swconfig enriched with user flags) in case of discrepancy.
  ...  If CHECK_SWCONFIG=False KW only collects swconfigs from all system modules.
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  Logging With Timestamp  message=:::: Swconfig operations ::::  style=ONGOING
  Run Keyword And Ignore Error
  ...  SWCONFIG Collect Swconfig From All BTSes  swconfig_download_directory=${CFG.test_logs_path}/Setup/BTSFiles  swconfig_name_prefix=native
  IF  '${CHECK_SWCONFIG}'=='True' and ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}==@{EMPTY}
    Logging With Timestamp  message=On user demand swconfigs will be checked against golden swconfig
    Run Keyword And Ignore Error  Compare And Upload Swconfig
  ELSE IF  '${CHECK_SWCONFIG}'=='True' and ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}!=@{EMPTY}
    Logging With Timestamp  message=On user demand swconfigs will be compare with golden swconfig and flags defined by user
    Run Keyword And Ignore Error  Compare And Upload Swconfig
  ELSE IF  '${CHECK_SWCONFIG}'=='False' and ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}==@{EMPTY}
    Logging With Timestamp  message=On user demand swconfig won't be checked against golden swconfig
  ELSE
    Logging With Timestamp  message=[WARNING] If You want to add user flags to swconfig you have to also set CHECK_SWCONFIG to True  level=WARN
  END
  [Teardown]  Logging With Timestamp  message=:::: Swconfig operations finished ::::  style=DONE

Compare And Upload Swconfig
  [Documentation]
  ...  Description:
  ...  KW compares collected native swconfigs with golden swconfig or also with flags defined by user
  ...  Uploads proper swconfig if needed.
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  OperatingSystem.Copy File  ${GOLDEN_SWCONFIG_PATH}  ${CFG.test_logs_path}/Setup/BTSFiles/
  OperatingSystem.Move File  ${CFG.test_logs_path}/Setup/BTSFiles/swconfig.txt  ${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt
  IF  @{CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}!=@{EMPTY}
    SWCONFIG Add Flags To Swconfig
    ...  swconfig_file_path=${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt
    ...  swconfig_flag_list=${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}
  END
  ${reference_swconfig_dict}=  SWCONFIG Create Swconfig Flags Dictionary  swconfig_path=${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt
  @{swconfig_BTSid_for_reset_list}=  Create List
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Logging With Timestamp  Comparing swconfig for bts with BTS_ID ${bts_id}
    IF  '${CFG.NODES['${bts_id}']['dualcore']}'=='False'
      ${status_and_message_for_user_list}=  SWCONFIG Compare Swconfig For Single Core
      ...  reference_swconfig_dict=${reference_swconfig_dict}
      ...  smod_swconfig_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/native_swconfig.txt
    ELSE
      ${status_and_message_for_user_list}=  SWCONFIG Compare Swconfig For Dual Core
      ...  reference_swconfig_dict=${reference_swconfig_dict}
      ...  primarysmod_swconfig_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/native_primarysmod_swconfig.txt
      ...  secondarysmod_swconfig_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/native_secondarysmod_swconfig.txt
    END
    IF  @{CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}!=@{EMPTY}
      ${message_for_user}=  Set Variable If
      ...  ${status_and_message_for_user_list[0]}
      ...  ${status_and_message_for_user_list[1]} and flags set by user. Swconfigs won't be changed.
      ...  ${status_and_message_for_user_list[1]} and flags set by user. Swconfigs will be changed.
    ELSE
      ${message_for_user}=  Set Variable If
      ...  ${status_and_message_for_user_list[0]}
      ...  ${status_and_message_for_user_list[1]}. Swconfigs won't be changed.
      ...  ${status_and_message_for_user_list[1]}. Swconfigs will be changed.
    END
    Logging With Timestamp  ${message_for_user}
    IF  '${status_and_message_for_user_list[0]}'=='False' and '${CFG.NODES['${bts_id}']['dualcore']}'=='False'
      Append To List  ${swconfig_BTSid_for_reset_list}  ${bts_id}
      SWCONFIG Upload Swconfig For Single Core  swconfig_source_path=${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt  bts_id=${bts_id}
    END
    IF  '${status_and_message_for_user_list[0]}'=='False' and '${CFG.NODES['${bts_id}']['dualcore']}'=='True'
      Append To List  ${swconfig_BTSid_for_reset_list}  ${bts_id}
      SWCONFIG Upload Swconfig For Dual Core  swconfig_source_path=${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt  bts_id=${bts_id}
    END
  END
  Set Test Variable  ${SWCONFIG_BTSID_FOR_RESET_LIST}  ${swconfig_BTSid_for_reset_list}
  OperatingSystem.Remove File  ${CFG.test_logs_path}/Setup/BTSFiles/tmp_swconfig.txt

SWCONFIG Create Swconfig Flags Dictionary
  [Arguments]  ${swconfig_path}

  [Documentation]
  ...  Description:
  ...  KW creates dictionary with flags names and values from particular swconfig
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument         | Man. | Description                                                                                       |
  ...  +==================+======+===================================================================================================+
  ...  | swconfig_path      | Yes  | path to swconfig e.g /Setup/BTSFiles/tmp_swconfig.txt                                           |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Return Value     | Type | Description                                                                                       |
  ...  +==================+======+===================================================================================================+
  ...  | swconfig_dict    | dict | Dictionary with flags names and values                                                            |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${out_lines_file}=  OperatingSystem.Get File  ${swconfig_path}
  ${out_lines}=  Get Lines Matching Regexp  ${out_lines_file}  (\\d+.*)
  @{out_lines_list}=  Split To Lines  ${out_lines}
  &{swconfig_dict}=  Create Dictionary
  FOR  ${line}  IN  @{out_lines_list}
    ${swconfig_flag}=  Fetch From Left  ${line}  \#
    ${swconfig_flag}=  Remove String Using Regexp  ${swconfig_flag}  \\s
    @{swconfig_flag_name_value_list}=  Split String  ${swconfig_flag}  =
    Set To Dictionary  ${swconfig_dict}  ${swconfig_flag_name_value_list[0]}=${swconfig_flag_name_value_list[1]}
  END
  [Return]  &{swconfig_dict}

SWCONFIG Add Flags To Swconfig
  [Arguments]  ${swconfig_file_path}  ${swconfig_flag_list}
  [Documentation]
  ...  Description:
  ...  Keyword appends flags to swconfig file.
  ...
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | swconfig_flag_list     | Yes  | List of flags to add.                                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | swconfig_file_path     | Yes  | Path to the swconfig file.                                                 |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  &{reference_swconfig_dict}=  SWCONFIG Create Swconfig Flags Dictionary  swconfig_path=${swconfig_file_path}
  FOR  ${user_swconfig_flag}  IN  @{swconfig_flag_list}
    ${swconfig_flag}=  Fetch From Left  ${user_swconfig_flag}  \#
    ${swconfig_flag}=  Remove String Using Regexp  ${swconfig_flag}  \\s
    @{swconfig_flag_name_value_list}=  Split String  ${swconfig_flag}  =
    ${flag_status}=  Run Keyword And Return Status
    ...  Dictionary Should Not Contain Key  ${reference_swconfig_dict}  ${swconfig_flag_name_value_list[0]}
    IF  ${flag_status}
      Append To File  ${swconfig_file_path}  ${user_swconfig_flag}\n
      Continue For Loop
    END
    ${reference_flag_value}=  Get From Dictionary  ${reference_swconfig_dict}  ${swconfig_flag_name_value_list[0]}
    #zmienna tymczasowa, zosatnie usunieta po modyfikacji KW Loggin With timestamp i dodaniu message2
    ${message}=  Set Variable  ${swconfig_flag_name_value_list[0]}=${reference_flag_value}
    IF  ${reference_flag_value}==${swconfig_flag_name_value_list[1]}
      Logging With Timestamp  User flag ${swconfig_flag} already exists in reference swconfig with the same value.  style=WARNING
    ELSE
      Logging With Timestamp  User flag ${swconfig_flag} already exists in reference swconfig with different value:${message}  style=WARNING
      Logging With Timestamp  message=User can't modify flag values from reference swconfig file. This flag value won't be changed.  style=WARNING
    END
  END

SWCONFIG Compare Swconfig For Single Core
  [Arguments]  ${reference_swconfig_dict}  ${smod_swconfig_path}

  [Documentation]
  ...  Description:
  ...  KW compares flags from swconfig with reference flags gathered in dictionary
  ...
  ...  +========================+======+=============================================================================+
  ...  | Argument               | Man. | Description                                                                 |
  ...  +========================+======+=============================================================================+
  ...  | reference_swconfig_dict| Yes  | Dictionary with reference swconfigs flags and values                        |
  ...  +------------------------+------+-----------------------------------------------------------------------------+
  ...  | smod_swconfig_path     | Yes  | Path to the swconfig file which will be compare with reference_swconfig_dict|
  ...  +------------------------+------+-----------------------------------------------------------------------------+
  ...
  ...  +-----------------------------------+------+----------------------------------------------------------------------------------------------+
  ...  | Return Value                     | Type | Description                                                                                   |
  ...  +==================================+======+===============================================================================================+
  ...  | status_and_message_for_user_list | list | List in which first element is comparison status and second ismessage for user                |
  ...  +----------------------------------+------+-----------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${native_swconfig_dict}=  SWCONFIG Create Swconfig Flags Dictionary  swconfig_path=${smod_swconfig_path}
  ${status}=  Run Keyword And Return Status
  ...  Dictionaries Should Be Equal  ${native_swconfig_dict}  ${reference_swconfig_dict}
  ${message_for_user}=  Set Variable If  ${status}
  ...  Current swconfig is in line with golden swconfig
  ...  Current swconfig is not in line with golden swconfig
  @{status_and_message_for_user_list}=  Create List  ${status}  ${message_for_user}
  [Return]  @{status_and_message_for_user_list}

SWCONFIG Compare Swconfig For Dual Core
  [Arguments]  ${reference_swconfig_dict}  ${primarysmod_swconfig_path}  ${secondarysmod_swconfig_path}

  [Documentation]
  ...  Description:
  ...  KW compares flags from swconfigs for primary and secondary core with reference flags gathered in dictionary
  ...
  ...  +===========================+======+===================================================================================================+
  ...  | Argument                  | Man. | Description                                                                                       |
  ...  +===========================+======+===================================================================================================+
  ...  | reference_swconfig_dict   | Yes  | Dictionary with reference swconfigs flags and values                                              |
  ...  +---------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | primarysmod_swconfig_path | Yes  | Path to the swconfig file from primary smod which will be compare with reference_swconfig_dict    |
  ...  +---------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  |secondarysmod_swconfig_path | Yes  | Path to the swconfig file from secondary smod which will be compare with reference_swconfig_dict |
  ...  +---------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  +-----------------------------------+------+----------------------------------------------------------------------------------------------+
  ...  | Return Value                     | Type | Description                                                                                   |
  ...  +==================================+======+===============================================================================================+
  ...  | status_and_message_for_user_list | list | List in which first element is comparison status and second ismessage for user                |
  ...  +----------------------------------+------+-----------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${native_primarysmod_swconfig_dict}=  SWCONFIG Create Swconfig Flags Dictionary  swconfig_path=${primarysmod_swconfig_path}
  ${status_primary}=  Run Keyword And Return Status
  ...  Dictionaries Should Be Equal  ${native_primarysmod_swconfig_dict}  ${reference_swconfig_dict}
  ${native_secondarysmod_swconfig_dict}=  SWCONFIG Create Swconfig Flags Dictionary  swconfig_path=${secondarysmod_swconfig_path}
  ${status_secondary}=  Run Keyword And Return Status
  ...  Dictionaries Should Be Equal  ${native_secondarysmod_swconfig_dict}  ${reference_swconfig_dict}
  ${status}=  Set Variable If  ${status_primary} and ${status_secondary}  True  False
  ${message_for_user}=  Set Variable If  ${status}
  ...  Current swconfigs for primary and secondary system modules are in line with reference swconfig
  ...  Current swconfigs for primary and/or secondary system modules are not in line with reference swconfig
  @{status_and_message_for_user_list}=  Create List  ${status}  ${message_for_user}
  [Return]  @{status_and_message_for_user_list}

SWCONFIG Collect Swconfig From All BTSes
  [Arguments]  ${swconfig_download_directory}  ${swconfig_name_prefix}

  [Documentation]
  ...  Description:
  ...  KW collects swconfigs from all smods for all BTSes in configuration.
  ...  It creates directories with BTSid in directory path pointed by user and downloads there swconfigs from all smods for particular BTS.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_download_directory | Yes  | Path to directory where all swconfigs will be downloaded e.g. ${CFG.test_logs_path}/Setup/BTSFile |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | swconfig_name_prefix        | Yes  | Prefix which will be added to name of collected swconfig  e.g. native                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Logging With Timestamp  Collecting swconfig for bts with BTS_ID ${bts_id}
    IF  '${CFG.NODES['${bts_id}']['dualcore']}'=='False'
      SWCONFIG Collect Swconfig For Single Core
      ...  swconfig_download_directory=${swconfig_download_directory}
      ...  swconfig_name_prefix=${swconfig_name_prefix}
      ...  bts_id=${bts_id}
    ELSE
      SWCONFIG Collect Swconfig For Dual Core
      ...  swconfig_download_directory=${swconfig_download_directory}
      ...  swconfig_name_prefix=${swconfig_name_prefix}
      ...  bts_id=${bts_id}
    END
  END

SWCONFIG Collect Swconfig For Single Core
  [Arguments]  ${swconfig_download_directory}  ${swconfig_name_prefix}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW collects swconfig from smod for single core BTS.
  ...  It creates directory with BTSid in directory path pointed by user and downloads there swconfig from smod with name:
  ...  ${swconfig_name_prefix}_swconfig.txt
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_download_directory | Yes  | Path to directory where swconfig will be downloaded e.g. ${CFG.test_logs_path}/Setup/BTSFile      |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | swconfig_name_prefix        | Yes  | Prefix which will be added to name of collected swconfig  e.g. native                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${status}  ${result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Download Swconfig From System Module
  ...    path_to_download_swconfig=${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_swconfig.txt
  ...    bts_id=${bts_id}
  #zmienna tymczasowa, zosatnie usunieta po modyfikacji KW Loggin With timestamp i dodaniu message2
  ${path}=  Set Variable  ${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_swconfig.txt
  IF  '${status}'=='PASS'
    Logging With Timestamp  message=swconfig.txt from system module collected and saved as ${path}
  ELSE
    Logging With Timestamp  message=swconfig.txt could not be retrieved from system Module! Error: ${result}  style=WARNING
  END

SWCONFIG Collect Swconfig For Dual Core
  [Arguments]  ${swconfig_download_directory}  ${swconfig_name_prefix}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW collects swconfigs from smods for dual core BTS.
  ...  It creates directory with BTSid in directory path pointed by user and downloads there swconfigs from smods with names:
  ...  ${swconfig_name_prefix}_primarysmod_swconfig.txt and ${swconfig_name_prefix}_secondarysmod_swconfig.txt
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_download_directory | Yes  | Path to directory where swconfig will be downloaded e.g. ${CFG.test_logs_path}/Setup/BTSFile      |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | swconfig_name_prefix        | Yes  | Prefix which will be added to name of collected swconfig  e.g. native                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${primary_status}  ${primary_result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Download Swconfig From System Module
  ...    path_to_download_swconfig=${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_primarysmod_swconfig.txt
  ...    bts_id=${bts_id}
  #zmienna tymczasowa, zosatnie usunieta po modyfikacji KW Loggin With timestamp i dodaniu message2
  ${primary_path}=  Set Variable  ${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_primarysmod_swconfig.txt
  IF  '${primary_status}'=='PASS'
    Logging With Timestamp  message=swconfig.txt from primary system module collected and saved as ${primary_path}
  ELSE
    Logging With Timestamp  message=swconfig.txt could not be retrieved from primary system Module! Error: ${primary_result}  style=WARNING
  END
  ${secondary_status}  ${secondary_result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Download Swconfig From Secondary System Module
  ...    path_to_download_swconfig=${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_secondarysmod_swconfig.txt
  ...    bts_id=${bts_id}
  #zmienna tymczasowa, zosatnie usunieta po modyfikacji KW Loggin With timestamp i dodaniu message2
  ${secondary_path}=  Set Variable  ${swconfig_download_directory}/${bts_id}/${swconfig_name_prefix}_secondarysmod_swconfig.txt
  IF  '${secondary_status}'=='PASS'
    Logging With Timestamp  message=swconfig.txt from secondary system module collected and saved as ${secondary_path}
  ELSE
    Logging With Timestamp  message=swconfig.txt could not be retrieved from secondary system module! Error: ${secondary_result}  style=WARNING
  END

SWCONFIG Upload Swconfig For Single Core
  [Arguments]  ${swconfig_source_path}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW uploads swconfig file to single core BTS and doesn't fail in case operation will be unsuccessful.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_source_path        | Yes  | Path to swconfig file which will be uploaded to system module                                     |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${status}  ${result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Upload Swconfig On System Module  swconfig_source_path=${swconfig_source_path}  bts_id=${bts_id}
  IF  '${status}'=='PASS'
    Logging With Timestamp  message=New swconfig.txt was successfully uploaded on system module.
  ELSE
    Logging With Timestamp  message=swconfig.txt was not successfully uploaded on system module! Error: ${result}  style=WARNING
  END

SWCONFIG Upload Swconfig For Dual Core
  [Arguments]  ${swconfig_source_path}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW uploads swconfig file to dual core BTS and doesn't fail in case operation will be unsuccessful.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_source_path        | Yes  | Path to swconfig file which will be uploaded to primary and secodnary system module               |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${primary_status}  ${primary_result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Upload Swconfig On System Module  swconfig_source_path=${swconfig_source_path}  bts_id=${bts_id}
  IF  '${primary_status}'=='PASS'
    Logging With Timestamp  message=New swconfig.txt was successfully uploaded on primary system module
  ELSE
    Logging With Timestamp  message=swconfig.txt was not successfully uploaded on primary system module! Error: ${primary_result}  style=WARNING
  END
  ${secondary_status}  ${secondary_result}=  Run Keyword And Ignore Error
  ...  SWCONFIG Upload Swconfig On Secondary System Module  swconfig_source_path=${swconfig_source_path}  bts_id=${bts_id}
  IF  '${secondary_status}'=='PASS'
    Logging With Timestamp  message=New swconfig.txt was successfully uploaded on secondary system module
  ELSE
    Logging With Timestamp  message=swconfig.txt was not successfully uploaded on secondary system module! Error: ${secondary_result}  style=WARNING
  END

SWCONFIG Download Swconfig From System Module
  [Arguments]  ${path_to_download_swconfig}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW downloads swconfig file from system module.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | path_to_download_swconfig   | Yes  | Path where swconfig will be downloaded                                                            |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  IF  '${CFG.NODES['${bts_id}']['bts_alias_type']}'=='localhost'
    SSH Get File From System Module  source_path=/ffs/run/swconfig.txt  destination_path=${path_to_download_swconfig}
  ELSE IF  '${CFG.configuration_setup_type}'=='mplane'
    SSH Get File From System Module
    ...  source_path=/ffs/run/swconfig.txt
    ...  destination_path=${path_to_download_swconfig}
    ...  target_ip=${cfg.NODES['${bts_id}']['bts_ip_address']}
  ELSE
    SSH Get File From System Module
    ...  source_path=/ffs/run/swconfig.txt
    ...  destination_path=${path_to_download_swconfig}
    ...  via_ip=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  END

SWCONFIG Download Swconfig From Secondary System Module
  [Arguments]  ${path_to_download_swconfig}  ${bts_id}
  [Documentation]
  ...  Description:
  ...  KW downloads swconfig file from secondary system module.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | path_to_download_swconfig   | Yes  | Path where swconfig will be downloaded                                                            |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  IF  '${CFG.configuration_setup_type}'=='mplane'
    SSH Get File From System Module
    ...  source_path=/ffs/run/swconfig.txt
    ...  destination_path=${path_to_download_swconfig}
    ...  via_ip=${cfg.NODES['${bts_id}']['bts_ip_address']}
    ...  via_username=toor4nsn
    ...  via_password=oZPS0POrRieRtu
    ...  target_ip=192.168.255.7
  ELSE
    SSH Get File From System Module
    ...  source_path=/ffs/run/swconfig.txt
    ...  destination_path=${path_to_download_swconfig}
    ...  via_ip=${cfg.NODES['${bts_id}']['secondary_sm_vm_ip_LMP_address']}
    ...  target_ip=192.168.255.7
  END

SWCONFIG Upload Swconfig On System Module
  [Arguments]  ${swconfig_source_path}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW uploads swconfig file to system module.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_source_path        | Yes  | Path to swconfig file which will be uploaded to system module                                     |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  IF  '${CFG.NODES['${bts_id}']['bts_alias_type']}'=='localhost'
    SSH Upload File On System Module  source_path=${swconfig_source_path}  destination_path=/ffs/run/swconfig.txt
  ELSE IF  '${CFG.configuration_setup_type}'=='mplane'
    SSH Upload File On System Module
    ...  source_path=${swconfig_source_path}
    ...  destination_path=/ffs/run/swconfig.txt
    ...  target_ip=${cfg.NODES['${bts_id}']['bts_ip_address']}
  ELSE
    SSH Upload File On System Module
    ...  source_path=${swconfig_source_path}
    ...  destination_path=/ffs/run/swconfig.txt
    ...  via_ip=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  END

SWCONFIG Upload Swconfig On Secondary System Module
  [Arguments]  ${swconfig_source_path}  ${bts_id}

  [Documentation]
  ...  Description:
  ...  KW uploads swconfig file to secondary system module.
  ...
  ...  +=============================+======+===================================================================================================+
  ...  | Argument                    | Man. | Description                                                                                       |
  ...  +=============================+======+===================================================================================================+
  ...  | swconfig_source_path        | Yes  | Path to swconfig file which will be uploaded to system module                                     |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bts_id                      | Yes  | BTSid                                                                                             |
  ...  +-----------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  IF  '${CFG.configuration_setup_type}'=='mplane'
    SSH Upload File On System Module
    ...  source_path=${swconfig_source_path}
    ...  destination_path=/ffs/run/swconfig.txt
    ...  via_ip=${cfg.NODES['${bts_id}']['bts_ip_address']}
    ...  via_username=toor4nsn
    ...  via_password=oZPS0POrRieRtu
    ...  target_ip=192.168.255.7
  ELSE
    SSH Upload File On System Module
    ...  source_path=${swconfig_source_path}
    ...  destination_path=/ffs/run/swconfig.txt
    ...  via_ip=${cfg.NODES['${bts_id}']['secondary_sm_vm_ip_LMP_address']}
    ...  target_ip=192.168.255.7
  END
