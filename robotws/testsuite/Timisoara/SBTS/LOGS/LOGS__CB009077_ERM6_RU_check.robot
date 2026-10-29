*** Settings ***
Documentation  Test for CB009077

Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/verdicts.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     OperatingSystem
Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***
${SNAPSHOT_TIMEOUT}    1200
@{All_supported_ERM6_RU}    AZQP    AZQW    AZHM    AZHL    AZQS    AZQU    AZQI    AZQJ    AZHN    AZTA

*** Keywords ***
TC_LOGS__CB009077_ERM6_RU_check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27358
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 1: Preparation
    ...  Step 2: Radio check
    ...  Step 3: Snapshot collection
    ...  Step 4: Verify snapshot
    ...  Step 5: Check if permanen file was cleared after feature flag set to false
    ...  Test checks whether a geolocation file is available in the snapshot for each RMOD from ERM6 RU familly
    ...  Test checks if permanen file has moduleDetectedLocation and moduleConfiguredLocation info and if this date will be cleared
    ...  when feature flag set to false
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 10.04.2024 - TC created. version 1.0
    ...

    Set Tags    CA-LOGS    OWNER-jakub.kokoszka@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...         GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3    FEATURE-CB009077


    Step 1: Preparation
    Step 2: Radio check
    Step 3: Snapshot collection
    Step 4: Verify snapshot
    Step 5: Check if permanen file was cleared after feature flag set to false




Step 1: Preparation
    [Documentation]
    ...  in this step test prepare all needed variables
    ...  feature flag actLocInfoStore is set to true, test check if GPS is available

    Log  \nStep 1: Preparation  console=${True}

    ${gps_status}     coam.get_gnsses_statuses
    ${gps_check_1}    Run Keyword and return status    should be equal  ${gps_status['GNSSE_R-1']['administrativeState'].lower()}   unlocked
    ${gps_check_2}    Run Keyword and return status    should be equal  ${gps_status['GNSSE_R-1']['operationalState'].lower()}   enabled

    Run Keyword If  ${gps_check_1}==True and ${gps_check_2}==True    Run Keyword
    ...  Log    GPS available    console=${True}
    ...  ELSE    verdicts.Set Test Failed    BTS must have GPS    ${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${sw}  coam.Get Sw Version
    Set Test Variable  ${SW}  ${sw}
    Run    mkdir -p ${BTS_Files}/RU_permanent_files/OFF
    Get ERM6 RMODs List
    preventParamModifList_OFF
    ${delta_id3}  Set Variable  actLocInfoStore
    coam.Create Delta    ${delta_id3}
    Set Test Variable    ${geolocation_ON}   ${False}
    Set Test Variable    ${FEATCADM_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    coam.Append Parameter Update To Delta  ${FEATCADM_MNLENT_DISTNAME}  actLocInfoStore  true  ${delta_id3}
    coam.Append Parameter Update To Delta  ${FEATCADM_MNLENT_DISTNAME}  accLevSet  High  ${delta_id3}

    ${modulePositionInformation_dict}  Create Dictionary
    ...  altitude=256
    ...  latitude=543000000
    ...  longitude=1432010000

    FOR    ${id}  IN  @{radio_module_id_list}
        coam.Append Complex Item To Delta
        ...  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${id}
        ...  list_name=modulePositionInformation
        ...  &{modulePositionInformation_dict}
        ...  delta_id=${delta_id3}
    END

    coam.Get Delta   ${delta_id3}
    coam.Save Delta   ${BTS Files}/geolocation_ON.json    ${delta_id3}
    coam.Perform Delta Recommissioning    ${BTS Files}/geolocation_ON.json
    Set Test Variable    ${geolocation_ON}   ${True}
    Set Test Variable    @{All_supported_ERM6_RU}


Step 2: Radio check
    [Documentation]
    ...  in this step test check if supported radio from list are available

    Log  \nStep 2: Radio check  console=${True}
    ${isEmpty}  Get length  ${erm6_radios}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  supported RU are not available  ${TRUE}
    ...  ELSE  Radio check


Step 3: Snapshot collection
    [Documentation]
    ...  in this step test collect snapshot

    Log  \nStep 3: Snapshot collection  console=${True}
    Snapshot collection


Step 4: Verify snapshot
    [Documentation]
    ...  in this step test check if permanen file exist in snapshot zip.
    ...  every radio from list should have BTS_${serial_number}_RMOD_*_*_permanen file

    Log  \nStep 4: Verify if collected snapshot includes permanen file  console=${True}
    Verify snapshot


Step 5: Check if permanen file was cleared after feature flag set to false
    [Documentation]
    ...  in this step test check if permanen file does not contains entry: moduleDetectedLocation and moduleConfiguredLocation
    ...  geolocation data was cleared after feature flag set to false

    Log  \nStep 5: Check if permanen file was cleared after feature flag set to false  console=${True}

    Revert Delta Changes actLocInfoStore
    Log  Snapshot collection  console=${True}
    Snapshot collection

    FOR  ${radio_module}  IN  @{erm6_radios}
      ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
      ${product_name}    Get From Dictionary    ${radio_module}    product_name
      ${permanent_xml_file_name}  Set Variable  BTS${bts_id}_${serial_number}_RMOD_*_*_permanent.xml.gz
      Set Test Variable    ${permanent_xml_file_name}
      ${found_permanent_file}    Get Match Count    ${found_file_dict}    ${permanent_xml_file_name}
      Run Keyword If    ${found_permanent_file}==1
      ...   Log    \npermanent.xml file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
      Run Keyword If    ${found_permanent_file}==0  Fail  permanent file for ${product_name} SN ${serial_number} wasn`t found.
      ${zip_part}    ${permanent_file_name_with_bracket}  PermanentPartCheck
      ${zip_part_number_2}  Get Substring  ${zip_part}  8  11
      ${zip_part_number}  Fetch From Left  ${zip_part_number_2}  .
      ${permanent_file_name}  Convert To String  ${permanent_file_name_with_bracket[0]}
      ${SNAPSHOT_LOCATION}  Set Variable  ${BTS_Files}
      unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${SNAPSHOT_LOCATION}/ex
      unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/BTS_part${zip_part_number}.zip  ${SNAPSHOT_LOCATION}/ex/ex2
      unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/ex2/${permanent_file_name}  ${SNAPSHOT_LOCATION}/ex/ex2/ex3
      ${permanent_file_name_without_qz}  Fetch From Left  ${permanent_file_name}  .gz
      ${UnpackedBlackBoXFile}  Set Variable  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz}
      ${file_content}  OperatingSystem.Get File  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz}
      Run  cp ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz} ${BTS_Files}/RU_permanent_files/OFF/${permanent_file_name_without_qz}

      ${contains_moduleDetectedLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleDetectedLocation
      ${contains_moduleConfiguredLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleConfiguredLocation

      Run Keyword If    "${contains_moduleDetectedLocation}"== "False"    Log
      ...    \nFile does not contains entry: moduleDetectedLocation [OK]    console=${TRUE}
      ...    ELSE    Set Test Failed    failed File contain entry: moduleDetectedLocation [NOK]
      Run Keyword If    "${contains_moduleConfiguredLocation}"== "False"    Log
      ...    File does not contains entry: moduleConfiguredLocation [OK]    console=${TRUE}
      ...    ELSE    Set Test Failed    failed File contain entry: moduleConfiguredLocation [NOK]
    END


Verify snapshot
    [Documentation]
    ...  KW check if snapshot contain permanen file ex.
    ...  BTS_${serial_number}_RMOD_*_*_permanen.xml.gz
    ...  all radios on BTS listed on @{All_supported_ERM6_RU} should have permanen.xml file

    FOR  ${radio_module}  IN  @{erm6_radios}
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${permanent_xml_file_name}  Set Variable  BTS${bts_id}_${serial_number}_RMOD_*_*_permanent.xml.gz
        Set Test Variable    ${permanent_xml_file_name}
        ${found_permanent_file}    Get Match Count    ${found_file_dict}    ${permanent_xml_file_name}
        Run Keyword If    ${found_permanent_file}==1
        ...   Log    \npermanent.xml file for ${product_name} SN ${serial_number} was found.    console=${TRUE}
        Run Keyword If    ${found_permanent_file}==0  Fail  permanent file for ${product_name} SN ${serial_number} wasn`t found.
        Check permanent_xml file    ${serial_number}
    END
    Log    \n    console=${TRUE}
    Sleep  10s


Snapshot collection
    [Documentation]
    ...  Kw is responsible for Snapshot collection

    ${timestamp}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${date}=    Convert Date    ${timestamp}    result_format=%Y-%m-%d
    Set Test Variable  ${date}
    ${timestamp}  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${ingnored_error}=  Run Keyword And Ignore Error
    ...     coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...     Set test variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  verdicts.Set Test Failed  Collecting snapshot via Admin failed.  ${TRUE}
    Log    Snapshot was collected    console=${TRUE}
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    Set Test Variable  ${found_file_dict}


Radio check
    [Documentation]
    ...  Kw check if RMOD is Unlocked and Enabled

    FOR  ${radio_module}  IN  @{erm6_radios}
        ${serial_number}    Get From Dictionary    ${radio_module}    serial_number
        ${product_name}    Get From Dictionary    ${radio_module}    product_name
        ${rmod_id}    Get From Dictionary   ${radio_module}    rmod_id
        Wait Until Keyword Succeeds    30 min    10 s    pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled
        Log    ${product_name} with SN ${serial_number} is available    console=${TRUE}
    END


Check permanent_xml file
    [Documentation]
    ...  Kw is responsible for Check permanent_xml file

    [Arguments]    ${serial_number}

    Log  Check permanent_xml file  console=${True}
    ${zip_part}    ${permanent_file_name_with_bracket}  PermanentPartCheck
    ${zip_part_number_2}  Get Substring  ${zip_part}  8  11
    ${zip_part_number}  Fetch From Left  ${zip_part_number_2}  .
    ${permanent_file_name}  Convert To String  ${permanent_file_name_with_bracket[0]}
    ${SNAPSHOT_LOCATION}  Set Variable  ${BTS_Files}
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${SNAPSHOT_LOCATION}/ex
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/BTS_part${zip_part_number}.zip  ${SNAPSHOT_LOCATION}/ex/ex2
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/ex2/${permanent_file_name}  ${SNAPSHOT_LOCATION}/ex/ex2/ex3
    ${permanent_file_name_without_qz}  Fetch From Left  ${permanent_file_name}  .gz
    ${UnpackedBlackBoXFile}  Set Variable  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz}
    ${file_content}  OperatingSystem.Get File  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz}
    Run    cp ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${permanent_file_name_without_qz} ${BTS_Files}/RU_permanent_files/${permanent_file_name_without_qz}

    ${contains_moduleDetectedLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleDetectedLocation
    ${contains_moduleConfiguredLocation}=    Run Keyword And Return Status    Should Contain    ${file_content}    moduleConfiguredLocation
    ${contains_BtsVersion}=    Run Keyword And Return Status    Should Contain    ${file_content}    BtsVersion
    ${contains_SW}=    Run Keyword And Return Status    Should Contain    ${file_content}    ${SW}
    ${contains_Location}=    Run Keyword And Return Status    Should Contain    ${file_content}    Location
    ${contains_ModuleSerialNumberName}=    Run Keyword And Return Status    Should Contain    ${file_content}    ModuleSerialNumber
    ${contains_ModuleSerialNumber}=    Run Keyword And Return Status    Should Contain    ${file_content}    ${serial_number}
    ${contains_Timestamp}=    Run Keyword And Return Status    Should Contain    ${file_content}    Timestamp
    ${contains_date}=    Run Keyword And Return Status    Should Contain    ${file_content}    ${date}

    Run Keyword If    "${contains_moduleDetectedLocation}"== "True"    Log    \nFile contains entry: moduleDetectedLocation    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: moduleDetectedLocation
    Run Keyword If    "${contains_moduleConfiguredLocation}"== "True"    Log    File contains entry: moduleConfiguredLocation    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: moduleConfiguredLocation
    Run Keyword If    "${contains_BtsVersion}"== "True"    Log    File contains entry: BtsVersion    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: BtsVersion
    Run Keyword If    "${contains_SW}"== "True"    Log    File contains entry: ${SW}    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: ${SW}
    Run Keyword If    "${contains_Location}"== "True"    Log    File contains entry: Location    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: Location
    Run Keyword If    "${contains_ModuleSerialNumberName}"== "True"    Log    File contains entry: ModuleSerialNumber    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: ModuleSerialNumber
    Run Keyword If    "${contains_ModuleSerialNumber}"== "True"    Log    File contains entry: ${serial_number}    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: ${serial_number}
    Run Keyword If    "${contains_Timestamp}"== "True"    Log    File contains entry: Timestamp    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: Timestamp
    Run Keyword If    "${contains_date}"== "True"    Log    File contains entry: ${date}    console=${TRUE}
    ...    ELSE    Set Test Failed    failed File does not contain entry: ${date}
    Run    rm -rf ${SNAPSHOT_LOCATION}/ex


PermanentPartCheck
    ${temp}   Create List
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        Append to List   ${temp}    ${log_file}
        ${permanent_zip_file}  Get Matches  ${temp}  ${permanent_xml_file_name}
        Remove From List   ${temp}   0
        ${permanent_zip_file_len}   Get Length   ${permanent_zip_file}
        Exit For Loop If  ${permanent_zip_file_len}>0
    END
    [Return]  ${found_file_dict["${log_file}"][0]}    ${permanent_zip_file}


Get ERM6 RMODs List
    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${erm6_radios}    Create List
    ${radio_module_id_list}    Create List
    Set Test Variable  ${radio_module_id_list}
    ${BTS_parameters}    coam.Get Parameters For All    BTS
    FOR    ${module}  IN  @{BTS_parameters}
        ${bts_id}    Get From Dictionary    ${module}     btsId
    END
    FOR    ${module}  IN  @{list_of_modules}
        ${serial_number}    Get From Dictionary    ${module}    serialNumber
        ${product_name}    Get From Dictionary    ${module}    productName
        ${ip_address}    Get From Dictionary    ${module}    ipAddress
        ${rmod_id}    Get From Dictionary   ${module}    id
        ${supported_rmod_id}  Fetch From Right    ${rmod_id}  -
        ${dist_name}    Fetch From Right    ${rmod_id}    RUNTIME_VIEW-1/
        ${mrbts_r_id}    Fetch From left    ${dist_name}    /
        ${dist_name}    Remove String    ${dist_name}    ${mrbts_r_id}
        ${dist_name}    Set Variable    MRBTS-${bts_id}${dist_name}
        ${radio_module}    Create Dictionary  serial_number=${serial_number}   product_name=${product_name}    dist_name=${dist_name}
        ...    ip_address=${ip_address}    rmod_id=${rmod_id}
        ${found}=    Get Match Count    ${All_supported_ERM6_RU}    ${product_name}
        Run Keyword If    '${found}'=='1'     Run Keywords
        ...  Append To List    ${erm6_radios}    ${radio_module}
        ...  AND  RMOD Distname Check    ${serial_number}
        Set Test Variable  ${erm6_radios}
    END

RMOD Distname Check
    [Arguments]    ${serial_number}

    ${rmod_r} =          Get Infomodel Object  //RMOD_R-* is [serialNumber=${serial_number}]
    ${rmod_distname}=    Get From Dictionary   ${rmod_r}    configDN
    ${distname}    Fetch From Right    ${rmod_distname}    -
    Append To List    ${radio_module_id_list}    ${distname}

preventParamModifList_OFF
    [Documentation]
    ...  this KW disables the parameter preventParamModifList

    Log   disables the parameter preventParamModifList

    ${delta_id4}  Set Variable  preventParamModifList_OFF
    coam.Create Delta   ${delta_id4}
    coam.Append Parameter Delete To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   preventParamModifList    ${delta_id4}
    coam.Get Delta   ${delta_id4}
    coam.Save Delta   ${BTS Files}/preventParamModifList_off.json    ${delta_id4}
    coam.Perform Delta Recommissioning
    ...  ${BTS Files}/preventParamModifList_off.json
    ...  skip_parameter_relation_errors=${True}
    Set Test Variable    ${preventParamModifList}    ${False}

Custom Test Teardown
    Log   \nCustom Test Teardown   console=${True}

    Run Keyword If   ${geolocation_ON}
    ...   Revert Delta Changes actLocInfoStore

Revert Delta Changes actLocInfoStore
    [Documentation]
    ...   KW revert delta changes actLocInfoStore

    Log   revert delta changes actLocInfoStore  console=${True}

    ${delta_id_2}   Set Variable   geolocation_OFF
    coam.Create Delta   ${delta_id_2}
    coam.Append Parameter Update To Delta
    ...   ${FEATCADM_MNLENT_DISTNAME}
    ...   actLocInfoStore
    ...   false
    ...   ${delta_id_2}

    FOR    ${id}  IN  @{radio_module_id_list}
        coam.Append Parameter Delete To Delta
        ...   MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${id}
        ...   modulePositionInformation
        ...   ${delta_id_2}
    END

    coam.Get Delta   ${delta_id_2}
    coam.Save Delta   ${BTS Files}/geolocation_OFF.json   ${delta_id_2}
    coam.Perform Delta Recommissioning   ${BTS Files}/geolocation_OFF.json   skip_parameter_relation_errors=${True}
    Set Test Variable   ${geolocation_ON}   ${False}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
