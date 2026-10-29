*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${DOCUMENTATION_PATH}  /home/ute/btsauto/snapshot_documentation  # Path to snapshot documentation archive directory.
                                                                 # There should be only ONE and CORRECT file: *_snapshot_documentation.tgz
${DELETE_EXTRACTED_FILES}  True                                  # If you want to do not delete extracted files, please set this parameter to False

*** Keywords ***
TC__LOGS__NSA_pdd_Files_Documentation_Availability_Check.robot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18475
    ...  ******************
    ...  Author: Marcin Berkowski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  2020-01-03 - https://jira3.int.net.nokia.com/browse/TAT-18475 - test creation
    ...  2020-04-11 - https://jira3.ext.net.nokia.com/browse/TAT-19935 - add: Download <SW>_snapshot_documentation.tgz file
    ...  2021-12-17 - https://jira3.ext.net.nokia.com/browse/TAT-22366 - cosmetic changes to improve execution in TA/CRT
    ...  2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot_documentation.tgz file contains at least one pdd files for each components
    ...  *******************
    ...  Test case flowchart:
    ...  *******************
    ...  .. image: https://tatools.emea.nsn-net.net/static/hran_doc/LOGS__NSA_pdd_Files_Documentation_Availability_Check.png#

    Set Tags    CA-LOGS    OWNER-marcin.berkowski@nokia.com    AUTHOR-marcin.berkowski@nokia.com    PHASE-CR2    SW-SBTS20

    Step 1: Extract Documentation
    Step 2: Check If Documentation Contains Needed Pdd Files

Step 1: Extract Documentation
     [Documentation]
    ...  In this test step snapshot documentation tgz archive from DOCUMENTATION_PATH, containing trbl.csv and log files documentation, is extracted

    Log    \nStep 0: Get Active Sw Version  console=${true}
    ${SW}  coam.Get Sw Version
    Log    Active Sw Version: ${SW}  console=${true}
    @{SW_splited}    Split String    ${SW}    _
    ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
    ${SW_00}=    Replace String Using Regexp  ${SW}  ${BRANCH}  00
    OperatingSystem.Run  mkdir -p ${DOCUMENTATION_PATH}
    Log  Download <SW>_snapshot_documentation.tgz file  console=${true}
    Run Keyword If  ${SW_splited[2]}==9999
    ...        OperatingSystem.Run
    ...cd ${DOCUMENTATION_PATH} ; wget http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/${SW_00}_snapshot_documentation.tgz
    ...  ELSE  OperatingSystem.Run
    ...cd ${DOCUMENTATION_PATH} ; wget http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/${SW_splited[0]}/${SW}_snapshot_documentation.tgz
    Sleep  30
    Log  \nStep 1: Extract snapshot documentation  console=${true}

    ${files_in_directory}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}
    ${files_in_directory_length}  Get Length  ${files_in_directory}

    Run Keyword If  ${files_in_directory_length}>1
    ...  verdicts.Set Test Failed  There is more than one file in ${DOCUMENTATION_PATH}!!!

    ${documentation_file_name}  Run Keyword And Ignore Error  Should Match Regexp  ${files_in_directory[0]}  .*snapshot_documentation.tgz
    Run Keyword If  '${documentation_file_name[0]}'<>'PASS'  verdicts.Set Test Failed
    ...Documentation file .*snapshot_documentation.tgz is not present under ${DOCUMENTATION_PATH} directory.

    Log  Extracting file: ${DOCUMENTATION_PATH}/${documentation_file_name[1]}  console=${true}
    unpacking.Unpack Archive Content To Directory  ${DOCUMENTATION_PATH}/${documentation_file_name[1]}  ${DOCUMENTATION_PATH}/extracted
    Log  File extracted under directory: ${DOCUMENTATION_PATH}/extracted [OK]  console=${true}

    ${all_extracted_files}  OperatingSystem.Run  find ${DOCUMENTATION_PATH}/extracted -type f | wc -l
    Log  The number of all extracted files: ${all_extracted_files}  console=${true}

    ${files_in_directory}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}/extracted
    ${files_in_directory_length}  Get Length  ${files_in_directory}

    FOR  ${index}  IN RANGE  0  ${files_in_directory_length}
      ${TRBL_FILE_NAME}  Run Keyword And Ignore Error  Should Match Regexp  ${files_in_directory[${index}]}  .*trbl_log_list.csv
      Run Keyword If  '${trbl_file_name[0]}'=='PASS'  Exit For Loop
    END
    Run Keyword If  '${trbl_file_name[0]}'=='FAIL'  verdicts.Set Test Failed
    ...Documentation file .*trbl_log_list.csv is not present under ${DOCUMENTATION_PATH}/extracted directory.
    Log  The trbl file was found: ${DOCUMENTATION_PATH}/extracted/${trbl_file_name[1]} [OK]  console=${true}

    ${trbl}  OperatingSystem.Get File  ${DOCUMENTATION_PATH}/extracted/${trbl_file_name[1]}  encoding_errors=ignore
    Set Test Variable  ${trbl}

    ${TRBL_FILE_NAME}=  Get From List  ${TRBL_FILE_NAME}  1
    Set Test Variable  ${TRBL_FILE_NAME}

Creating Components List
    [Documentation]
    ...  In this keyword all components list is created based on file: DOCUMENTATION_PATH/extracted/.*trbl_log_list.csv

    Log  Creating component list based on file: ${TRBL_FILE_NAME}  console=${true}
    @{lines_from_trbl}  Split To Lines  ${trbl}
    ${components_list}=  Create List
    Remove From List  ${lines_from_trbl}  0
    FOR  ${line}  IN  @{lines_from_trbl}
      @{values}  Split String  ${line}  ;
      ${first_value}  Get First Value  @{values}
      @{levels}  Split String  ${first_value}  /
      ${levels_length}  Get Length  ${levels}
      Run Keyword If  ${levels_length}<2
      ...  Fatal Error  message=Improper component name: ${first_value}
      ${two_levels}  Get Two Levels  @{levels}
      Append To List  ${components_list}  ${two_levels}
    END
    ${components_list}=  Remove Duplicates  ${components_list}
    Sort List  ${components_list}
    ${components_list_length}=  Get Length  ${components_list}
    Log  The components list length is: ${components_list_length}  console=${true}
    Set Test Variable  ${components_list}
    Set Test Variable  ${components_list_length}

Creating Pdd Files List
    [Documentation]
    ...  In this keyword there is for all *_pdd.yaml and *_pdd.xml files two lists is created by using linux command find

    Log  Creating pdd files list  console=${true}
    ${pdd_yaml}  OperatingSystem.Run  find ${DOCUMENTATION_PATH}/extracted -type f -name "*_pdd.yaml"
    @{pdd_yaml_list}  Split To Lines  ${pdd_yaml}
    ${pdd_yaml_length}=  Get Length  ${pdd_yaml_list}
    Log  Number of "*_pdd.yaml" files: ${pdd_yaml_length}  console=${true}

    Set Test Variable  ${pdd_yaml_list}
    Set Test Variable  ${pdd_yaml_length}

    ${pdd_xml}  OperatingSystem.Run  find ${DOCUMENTATION_PATH}/extracted -type f -name "*_pdd.xml"
    @{pdd_xml_list}  Split To Lines  ${pdd_xml}
    ${pdd_xml_length}=  Get Length  ${pdd_xml_list}
    Log  Number of "*_pdd.xml" files: ${pdd_xml_length}  console=${true}

    Set Test Variable  ${pdd_xml_list}
    Set Test Variable  ${pdd_xml_length}

    ${yaml_and_xml}=  Evaluate  ${pdd_yaml_length}+${pdd_xml_length}
    Run Keyword If  ${yaml_and_xml}==0
    ...  verdicts.Set Test Failed  No any pdd files!!!

Step 2: Check If Documentation Contains Needed Pdd Files
    [Documentation]
    ...  In this test step the two lists are created (Components List and Pdd Files List)
    ...  next this two list are compared and result displayed
    Log  \nStep 2: Check If Documentation Contains Needed Pdd Files  console=${true}

    Creating Components List
    Creating Pdd Files List

    Log  Documentation file: ${TRBL_FILE_NAME}  console=${true}
    Log  Check results (for files *_pdd.yaml, *_pdd.xml):  console=${true}

    FOR  ${index}    IN RANGE    ${components_list_length}
      ${index_plus1}=  Evaluate  ${index}+1
      ${compare_yaml}  Check If Pdd.yaml Contains Component  ${components_list[${index}]}
      ${compare_yaml_length}=  Get Length  ${compare_yaml}

      ${compare_xml}  Check If Pdd.xml Contains Component  ${components_list[${index}]}
      ${compare_xml_length}=  Get Length  ${compare_xml}

      ${number_of_yaml_and_xml_files}=  Evaluate  ${compare_yaml_length}+${compare_xml_length}

      Run Keyword If  ${number_of_yaml_and_xml_files}==0  Run Keywords
      ...  Log  ${index_plus1})\tNumber of pdd files (yaml+xml):  console=${true}
      ...  AND  Log  ${compare_yaml_length}+${compare_xml_length}=${number_of_yaml_and_xml_files}  console=${true}
      ...  AND  Log  [NOK]\tin component: ${components_list[${index}]}  console=${true}
      ...  AND  verdicts.Set Test Failed  Lack of pdd file(s) in component: ${components_list[${index}]}.
      ...  ELSE  Run Keywords
      ...  Log  ${index_plus1})\tNumber of pdd files (yaml+xml):  console=${true}
      ...  AND  Log  ${compare_yaml_length}+${compare_xml_length}=${number_of_yaml_and_xml_files}  console=${true}
      ...  AND  Log  [OK]\tin component: ${components_list[${index}]}  console=${true}
    END

Check If Pdd.yaml Contains Component
    [Documentation]
    ...  This keyword check if list with pdd.yaml files contains given value
    ...  Output of this keyword is a list contained paths to pdd.yaml files for given component
    [Arguments]  ${component}
    FOR  ${index}    IN RANGE    ${pdd_yaml_length}
      ${result}  Get Matches  ${pdd_yaml_list}  ${DOCUMENTATION_PATH}/extracted/${component}/*
    END
    [Return]  ${result}

Check If Pdd.xml Contains Component
    [Documentation]
    ...  This keyword check if list with pdd.xml files contains given value
    ...  Output of this keyword is a list contained paths to pdd.xml files for given component
    [Arguments]  ${component}
    FOR  ${index}    IN RANGE    ${pdd_xml_length}
      ${result}  Get Matches  ${pdd_xml_list}  ${DOCUMENTATION_PATH}/extracted/${component}/*
    END
    [Return]  ${result}

Get First Value
    [Documentation]
    ...  This keyword check if given dictionary values is correct and returns first element value from the given dictionary
    [Arguments]  @{values}
    ${values_length}  Get Length  ${values}
    Run Keyword If  ${values_length}<>15
    ...  Log  Incorrect line in trbl: ${values}  WARN  console=yes
    [Return]  ${values[0]}

Get Two Levels
    [Documentation]
    ...  This keyword returns first two elements (levels) value from the given dictionary
    [Arguments]  @{levels}
    ${length}  Get Length  ${levels}
    ${result}=  Evaluate  '${levels[0]}'+'/'+'${levels[1]}'
    [Return]  ${result}

TC Setup
    Common Test Setup  modules_check=${False}   syslog_launch=${False}    cells_check=${False}    alarms_check=${False}  scf_check=${False}

TC Teardown
    [Documentation]
    ...  In this custom teardown the directory with extracted files are deleted if DELETE_EXTRACTED_FILES is set on True
    Run Keyword If  ${DELETE_EXTRACTED_FILES}==True  Run Keywords
    ...  OperatingSystem.Run  rm -rf ${DOCUMENTATION_PATH}
    ...  AND  Log  \nCustom Test Teardown: extracted files will be deleted\n  console=${true}
    ...  ELSE  Log  \nCustom Test Teardown: extracted files will be NOT deleted\n  console=${true}
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown    collect_snapshot=never
