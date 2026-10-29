*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource with common KW for SWM

Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  XML  use_lxml=true
Library  OperatingSystem
Library  String
Library  Collections


*** Keywords ***
SWM Check HW List SW Version Is Compatible With BTS SW
  [Arguments]  ${class}  ${serial_number_list}  ${targetbd_path}=/home/ute/Downloads/  ${timeout}=${CONFIGURATION_STARTUP_TIMEOUT}  ${alias}=default
  [Documentation]  Keyword returns 'True', if given 'serial_number_list' has compatible SW with BTS SW,
  ...  'False' if it's not compatible, and fails, if verification could not be performed.
  ...  'timeout' defines time to retrieve given serial number HW info.
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | class              | Yes   | class for sw check [RMOD, FHS, ASIRMOD]                                                       |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | serial_number_list | Yes   | serial numbers of hw from choen class                                                         |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | targetbd_path      | No    | path to TargetBD file for SW check                                                            |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | timeout            | No    | timeout for hw parameters gathering                                                           |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | alias              | No    | current bts id as alias                                                                       |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  FOR  ${hw_key}  IN  @{serial_number_list}
    ${assert_status}  ${assert_output}=  Run Keyword And Ignore Error
    ...  admin.Assert Any  class_name=${class}  parameters=buildVersion!=empty, serialNumber=${hw_key}  timeout=${timeout}  connection=${alias}
    IF  '${assert_status}'=='FAIL'
      Logging With Timestamp  message=${class} ${hw_key} not found on BTS-${alias}, test failed  style=FAIL
      Return From Keyword  ${FALSE}
    END
    ${hw_dict}=  _Find Rmod Dict With SerialNumber  ${assert_output}  ${hw_key}
#  ${hw_dict}=  Evaluate  [hw_dict for hw_dict in ${assert_output} if hw_dict['serialNumber']=='${hw_key}'].pop(0)
    ${hw_compatible_sw_list}=  Get Elements
    ...  ${targetbd_path}  //hwResource[contains(@resourceBuildKey, '${hw_dict['productName']}')]/@resourceSWVersion
    ${status}=  Run Keyword And Return Status
    ...  Should Be True  "${hw_compatible_sw_list[0]}"=="${hw_dict['buildVersion']}"
    Exit For Loop If  "${status}"=="False"
  END
  ${sn_count}=  Get Length  ${serial_number_list}
  Return From Keyword If  ${sn_count}==0  ${TRUE}
  [Return]  ${status}

_Find Rmod Dict With SerialNumber
  [Arguments]  ${assert_output}  ${hw_key}
  FOR  ${id}  IN  @{assert_output}
    ${serial_number_status}  ${hw_dict}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${id}  serialNumber
    Continue For Loop If  '${serial_number_status}'=='FAIL'
    IF  '${serial_number_status}'=='PASS'
      ${serial_number_status}=  Run Keyword And Return Status  Should Be Equal  ${id['serialNumber']}  ${hw_key}
    ELSE
      ${serial_number_status}=  Set Variable  ${None}
    END
    IF  ${serial_number_status}
      Exit For Loop
    END
  END
  [Return]  ${id}

SWM Check Main Software Package Availability
  [Arguments]  ${active_sw}  ${bts_id}
  [Documentation]  KW for checking if desired sw is available on server and download it. Kw is divided on two parts: for 5G SW check and rest
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | active_sw          | Yes   | current active software on BTS                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | bts_id             | Yes   | current bts id                                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  +-----------------------+----------------------------------------------------------------------------------------------------+
  ...  | Return Value          | Description                                                                                        |
  ...  +=======================+====================================================================================================+
  ...  | software_package_path | Path to expected SW package downloaded for update purposes                                         |
  ...  +-----------------------+----------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${is_5G}=  Run Keyword And Return Status
  ...  Should Match Regexp  ${active_sw}  5G
  IF  ${is_5G}
    ${software_package_path}=  SWM Check Main Software Package Availability For 5G  ${active_sw}
  ELSE
    ${software_package_path}=  SWM Check Main Software Package Availability For SRAN  ${active_sw}  ${bts_id}
  END
  [Return]  ${software_package_path}

SWM Check Main Software Package Availability For 5G
  [Arguments]  ${active_sw}
  [Documentation]  KW for checking and downloading appropriate 5G SW
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | active_sw          | Yes   | current active software on BTS                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | Return Value            | Description                                                                                      |
  ...  +=========================+==================================================================================================+
  ...  | software_package_dir_5g | Path to expected 5G SW package downloaded for update purposes                                    |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${software_active_package_name}  ${software_active_component}=  SWM Create Software Package Name For 5G  ${active_sw}
  Create Directory  ${SW_BUILDS_DIR_PATH}
  ${software_package_dir_5g}=  SWM Download Software Package From 5G Artifactory
  ...  sw_builds_dir_path=${SW_BUILDS_DIR_PATH}
  ...  software_active_package_name=${software_active_package_name}
  ...  components_to_include=${software_active_component}
  Convert To String  ${software_package_dir_5g}
  [Return]  ${software_package_dir_5g}

SWM Create Software Package Name For 5G
  [Arguments]  ${active_sw}
  [Documentation]  KW creates correct name for 5G SW with expected postfixes
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | active_sw          | Yes   | current active software on BTS                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | Return Value            | Description                                                                                      |
  ...  +=========================+==================================================================================================+
  ...  | software_package_name   | 5G SW name                                                                                       |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | software_component      | postfix for SW name [T1, T2]                                                                     |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${software_component}=  Set Variable If
  ...  "T1" in "${active_sw}"  T1
  ...  "T2" in "${active_sw}"  T2
  ...  ${EMPTY}
  ${active_sw}=  Remove String Using Regexp  ${active_sw}  T[1-2]  count=1
  ${branch}  ${gnb}  @{software_package_name}=  Split String  ${active_sw}  _
  ${first_part}=  Strip String  ${software_package_name[0]}  mode=left  characters=0
  ${first_part}=  Set Variable If  "${first_part}" == "${EMPTY}"  0  ${first_part}
  ${second_part}=  Strip String  ${software_package_name[1]}  mode=left  characters=0
  ${third_part}=  Strip String  ${software_package_name[2]}  mode=left  characters=0
  ${software_package_name_final}=  Set Variable If  "${software_component}" == "T1"  ${branch}_${first_part}.${second_part}.${third_part}
  ...  "${software_component}" == "T2"  ${branch}_${first_part}.${second_part}.${third_part}
  ...  ${branch}_${first_part}.${second_part}.${third_part}
  [Return]  ${software_package_name_final}  ${software_component}

SWM Download Software Package From 5G Artifactory
  [Arguments]  ${sw_builds_dir_path}  ${software_active_package_name}  ${components_to_include}=${EMPTY}
  [Documentation]  KW for downloading 5G SW
  ...  +--------------------------------+-------+---------------------------------------------------------------------------------------+
  ...  | Argument                       | Man.  | Description                                                                           |
  ...  +====================+===========+===============================================================================================+
  ...  | sw_builds_dir_path             | Yes   | directory for download SW                                                             |
  ...  +--------------------------------+-------+---------------------------------------------------------------------------------------+
  ...  | software_active_package_name   | Yes   | Desired 5G SW name                                                                    |
  ...  +--------------------------------+-------+---------------------------------------------------------------------------------------+
  ...  | components_to_include          | No    | postfix for SW name                                                                   |
  ...  +--------------------------------+-------+---------------------------------------------------------------------------------------+
  ...
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | Return Value            | Description                                                                                      |
  ...  +=========================+==================================================================================================+
  ...  | software_path           | path to downloaded 5G SW                                                                         |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${package_name}=  Split String From Right  ${software_active_package_name}  _  1
  ${software_path}=  Normalize Path  ${sw_builds_dir_path}/AirScale-${package_name[1]}${components_to_include}.zip
  ${file_status}=  Run Keyword And Return Status
  ...  OperatingSystem.File Should Not Exist  ${software_path}
  IF  ${file_status}
    Run And Return Rc  wget -P ${sw_builds_dir_path} ${5G_artifactory}${package_name[1]}/AirScale-${package_name[1]}${components_to_include}.zip
  END
  [Return]  ${software_path}

SWM Check Main Software Package Availability For SRAN
  [Arguments]  ${active_sw}  ${bts_id}
  [Documentation]  KW for checking and downloading appropriate SW different than 5G
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | active_sw          | Yes   | current active software on BTS                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | bts_id             | Yes   | current bts id                                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | Return Value            | Description                                                                                      |
  ...  +=========================+==================================================================================================+
  ...  | software_package_dir    | Path to expected SW package different than 5G downloaded for update purposes                     |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${software_package_name}  ${software_active_component}=  SWM Create Software Package Name  ${active_sw}
  Create Directory  ${SW_BUILDS_DIR_PATH}
  ${components_to_include}=  Create List
  ${software_package_type}=  Set Variable If
  ...  "${software_active_component}" == "T1"  T1
  ...  "${software_active_component}" == "T2"  T2
  ...  T0
  ${sw_elements}=  Split String  ${cfg.NODES['${bts_id}']['software_active']}  _
  ${SW_PLATFORM}=  Set Variable If  '${sw_elements[1]}'=='ENB'  ${EMPTY}  _${sw_elements[1]}
  Set Test Variable  ${SW_PLATFORM}
  SWM Get Software For Testing
  ...  path=${SW_BUILDS_DIR_PATH}
  ...  sw_ver=${software_package_name}
  ...  sw_index=${software_package_type}
  ${software_package_dir}=  Set Variable If  "${software_package_type}" == "T0"
  ...  ${SW_BUILDS_DIR_PATH}/${software_package_name}_release_BTSSM_downloadable_A54.zip
  ...  ${SW_BUILDS_DIR_PATH}/${software_package_name}_release_BTSSM_downloadable_testpackage_${software_package_type}_A54.zip
  [Return]  ${software_package_dir}

SWM Create Software Package Name
  [Arguments]  ${active_sw}
  [Documentation]  KW creates correct name for SW different than 5G with expected postfixes
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | active_sw          | Yes   | current active software on BTS                                                                |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | Return Value            | Description                                                                                      |
  ...  +=========================+==================================================================================================+
  ...  | software_package_name   | SW name different than 5G                                                                        |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  | software_component      | postfix for SW name [T1, T2, MAIN]                                                               |
  ...  +-------------------------+--------------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  ${trunk_status}=  Run Keyword And Return Status
  ...  Should Match Regexp  ${active_sw}  .*_999[0-9].*
  IF  ${trunk_status}
    ${software_package_name}=  Replace String Using Regexp  ${active_sw}  ^([A-Z]+)\\d+[A-Z]\\d?  SBTS00
  ELSE
    ${software_package_name}=  Set Variable  ${None}
  END
  ${software_package_name}=  Set Variable If  ${trunk_status}  ${software_package_name}  ${active_sw}
  ${software_component}=  Set Variable If
  ...  "T1" in "${software_package_name}"  T1
  ...  "T2" in "${software_package_name}"  T2
  ...  MAIN
  ${software_package_name}=  Remove String  ${software_package_name}  ${software_component}
  [Return]  ${software_package_name}  ${software_component}

SWM Get Software For Testing
  [Arguments]  ${path}  ${sw_ver}  ${suffix_1}=${EMPTY}  ${suffix_2}=A54  ${knife}=${FALSE}  ${sw_index}=T0  ${timeout}=60m
  [Documentation]  KW downloads SW package different than 5G. When CMCC soft is requested only T0 is allowed.
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | Argument        | Man.  | Description                                                                              |
  ...  +=================+===========+======================================================================================+
  ...  | path            | Yes   | directory for download SW                                                                |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | sw_ver          | Yes   | SW name different than 5G                                                                |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | suffix_1        | Yes   | SW component ex. "CMCC", "DCM" etc, default value ${EMPTY}                               |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | suffix_2        | Yes   | SW component ex. "A54", "A50E" etc, default value "A54"                                  |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | knife           | Yes   | allowed input ${TRUE} or ${FALSE}, default value ${FALSE}                                |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | sw_index        | Yes   | allowed input T0, T1, T2, default is T0, separate with space when several indexes used   |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  | timeout         | Yes   | timeout for downloading single SW package, default 15min                                 |
  ...  +-----------------+-------+------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  Create Directory  ${path}
  ${files_in_dir}=  Run  ls ${path}
  ${sw_split}=  Evaluate  "${sw_ver}".replace("t1", "").replace("t2", "").split("_")
  ${match}=  Get Regexp Matches  ${sw_split}[2]  9\\d{3}
  IF  ${match}
    Set List Value  ${sw_split}  0  SBTS00
  END
  ${sw_ver}=  Evaluate  "_".join(${sw_split})
  Logging With Timestamp
  ...  message=Trying to download ${sw_ver} ver.${suffix_1},${suffix_2}
  ...  logs_dir=${CFG.suite_logs_path}
  ${suffix_1}=  Set Variable If  "${suffix_1}"!="${EMPTY}"  _${suffix_1}  ${EMPTY}
  ${sw_index}=  Evaluate  "${sw_index}".split(" ")
  ${repo_url_1}=  Convert To String  http://knife-results.es-si-s3-z2.eecloud.nsn-net.net
  ${repo_url_2}=  Convert To String  http://files.ute.nsn-rdnet.net/builds/enb/base
  ${repo_url_5}=  Convert To String  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
  ${build_name}=  Convert To String  ${sw_ver}_release_BTSSM_downloadable
  FOR  ${index}  IN  @{sw_index}
    IF  "${index}"!="T0" and "${suffix_1}"=="CMCC"
      Exit For Loop
    END
    ${testpackage}=  Set Variable If  "${index}"=="T0"  ${EMPTY}  _testpackage_${index}
    ${match}=  Get Regexp Matches  ${files_in_dir}  ${sw_ver}_release_BTSSM_downloadable${testpackage}${suffix_1}(?:_${suffix_2})?.zip(?!.\\d)
    IF  ${match}
      Logging With Timestamp  message=${index} -> already exists  logs_dir=${CFG.suite_logs_path}
      Continue For Loop
    END
    IF  ${knife}
      ${status}=  Run And Return Rc
      ...  timeout ${timeout} wget ${repo_url_1}/${sw_split}[4]/${build_name}${testpackage}${suffix_1}_${suffix_2}.zip -P ${path} -T 60
    ELSE
      ${status}=  Set Variable  ${None}
    END
    IF  ${status}==${0}
      Logging With Timestamp  message=${index} -> downloaded successfuly  logs_dir=${CFG.suite_logs_path}
      Continue For Loop
    ELSE
      Run  rm ${path}/${build_name}${testpackage}${suffix_1}_${suffix_2}.zip
    END
    IF  "${suffix_1}"=="${EMPTY}" and "${suffix_2}"=="A54" and "${knife}"=="False"
      ${status}=  Run And Return Rc  timeout ${timeout} wget ${repo_url_2}/${sw_ver}/${build_name}${testpackage}.zip -P ${path} -T 60
    ELSE
      ${status}=  Set Variable  ${None}
    END
    IF  ${status}==${0}
      Logging With Timestamp  message=${index} -> downloaded successfuly  logs_dir=${CFG.suite_logs_path}
      Run  mv ${path}/${build_name}${testpackage}.zip ${path}/${build_name}${testpackage}_${suffix_2}.zip
      Continue For Loop
    ELSE
      Run  rm ${path}/${build_name}${testpackage}.zip
    END
    IF  not ${knife}
      ${wget_sw}=  Set Variable  ${repo_url_5}/${sw_split}[0]${SW_PLATFORM}/${sw_ver}/${build_name}${testpackage}${suffix_1}_${suffix_2}.zip
    ELSE
      ${wget_sw}=  Set Variable  ${None}
    END
    IF  not ${knife}
      ${status}=  Run And Return Rc  timeout ${timeout} wget ${wget_sw} -P ${path} -T 60
    ELSE
      ${status}=  Set Variable  ${None}
    END
    IF  ${status}==${0}
      Logging With Timestamp  message=${index} -> downloaded successfuly  logs_dir=${CFG.suite_logs_path}
      Continue For Loop
    ELSE
      Run  rm ${path}/${build_name}${testpackage}${suffix_1}_${suffix_2}.zip
    END
    Logging With Timestamp
    ...  message=${index} -> download failed, please try manualy!
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    Fail  ${sw_ver}${index} ver.${suffix_1},${suffix_2} download failed
  END

SWM Get SW Build Release
    [Arguments]  ${partition}  ${only_release}=${TRUE}  ${bts_id}=default
    [Documentation]
    ...  KW checks and returns SW release from active or passive partition.
    ...  Argument only_release decides if a full name or only release will be returned.
    ...  KW moved from robotlte_legacy and hran_ta: "Get Software Release"
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | partition        | Yes  | Active or Passive or All                                         |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | only_release     | No   | Only release e.g. SBTS21A or full release name, default True     |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com


    ${all_software}  admin.Get Software Info  alias=${bts_id}
    ${active_sw}  Get From Dictionary  ${all_software}  Active SW version
    ${passive_sw}  Get From Dictionary  ${all_software}  Passive SW version
    ${active_sw_sliced}  Evaluate  ('_'.join('${active_sw}'.split('_')[0:1]))
    ${passive_sw_sliced}  Evaluate  ('_'.join('${passive_sw}'.split('_')[0:1]))

    Run Keyword If  '${partition}'=='Active' and ${only_release}==${TRUE}     Return From Keyword  ${active_sw_sliced}
    ...  ELSE IF    '${partition}'=='Passive' and ${only_release}==${TRUE}    Return From Keyword  ${passive_sw_sliced}
    ...  ELSE IF    '${partition}'=='All' and ${only_release}==${TRUE}        Return From Keyword  ${active_sw_sliced}  ${passive_sw_sliced}
    ...  ELSE IF    '${partition}'=='Active' and ${only_release}==${FALSE}    Return From Keyword  ${active_sw}
    ...  ELSE IF    '${partition}'=='Passive' and ${only_release}==${FALSE}   Return From Keyword  ${passive_sw}
    ...  ELSE IF    '${partition}'=='All' and ${only_release}==${FALSE}       Return From Keyword  ${active_sw}  ${passive_sw}

SWM Check If Current SW Build Is Newer Than
    [Arguments]    ${build}    ${bts_id}=default
    [Documentation]
    ...  KW checks if given build is newer/higher than active software on BTS
    ...  KW moved from robotlte_legacy and hran_ta: "Check If Current Build Is Newer Than"
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                                   |
    ...  +====================+=======+===============================================================================================+
    ...  | build              | Yes   | Sw version to compare with current on BTS                                                     |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | bts_id             | Yes   | current bts id                                                                                |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  +-------------------------+--------------------------------------------------------------------------------------------------+
    ...  | Return Value            | Description                                                                                      |
    ...  +=========================+==================================================================================================+
    ...  | verdict                 | True if current build is newer than pass via argument, False otherwise                           |
    ...  +-------------------------+--------------------------------------------------------------------------------------------------+
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${current_sw}  SWM Get SW Build Release  Active    only_release=False    bts_id=${bts_id}
    ${current_sw}  Get Regexp Matches  ${current_sw}  \\d+
    ${curr}    Evaluate    [int(number) for number in ${current_sw}]

    ${arg_sw_number}    Get Regexp Matches  ${build}  \\d+
    ${arg}    Evaluate    [int(number) for number in ${arg_sw_number}]
    Return From Keyword If    ${curr}[0]>${arg}[0]  ${TRUE}
    Return From Keyword If
    ...  ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[2]==0000 and ${arg}[2]==9999  ${TRUE}
    ${verdict}    Set Variable If
    ...    ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[3]>=${arg}[3]
    ...    ${TRUE}
    ...    ${FALSE}

    Run Keyword If  not ${verdict}
    ...  Return From Keyword  ${verdict}
    ...  ELSE
    ...  Return From Keyword If  ${curr}[3]!=${arg}[3]  ${verdict}

    ${verdict}  Set Variable If  ${curr}[4]>${arg}[4]  ${TRUE}  ${FALSE}

    [Return]    ${verdict}
