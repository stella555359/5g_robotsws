*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     ../resources/extractor.py
Library     DateTime
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/unpacking.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_TIMEOUT}      600                      #timeout for collect snapshot via Admin (in sec)
${EXPECTED_ERROR}        *Modification of restricted parameter*

*** Keywords ***
TC__LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27103
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 0: Preconditions
    ...  Step 1: Check preventParamModifList mechanism and turn on actLocInfoStore
    ...  Step 2: Snapshot collection
    ...  Step 3: Check geolocation file in snapshot
    ...  Test checks whether a geolocation file is available in the snapshot for each SMOD and BBMOD (excluding ABIA).
    ...  Test also checks preventParamModifList mechanism on example FEATCADM-actLocInfoStore
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 11.03.2024 - TC created. version 1.0
    ...

    Set Tags    CA-LOGS    OWNER-jakub.kokoszka@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3    FEATURE-CB009077


    Step 0: Preconditions
    Step 1: Check preventParamModifList mechanism and turn on actLocInfoStore
    Step 2: Snapshot collection
    Step 3: Check geolocation file in snapshot


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.
    ...   preventParamModifList are set with FEATCADM-actLocInfoStore value
    ...   to check in Step 1 if modification are restricted
    ...   BBMOD (without ABIA) and SMOD are count to check how many geolocation files should exist in snapshot

    Log    \nStep 0: Preconditions    console=${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    Set Test Variable    ${geolocation_ON}   ${False}
    Set Test Variable    ${preventParamModifList}    ${False}
    Set Test Variable    ${TRBL_MNLENT_DISTNAME}   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    ${delta_id}  Set Variable  preventParamModifList_ON
    coam.Create Delta   ${delta_id}
    Log    enables the parameter preventParamModifList    console=${True}

    ${preventParamModifList_list}   Create List
    Append To List   ${preventParamModifList_list}   FEATCADM-actLocInfoStore
    coam.Append List Items To Delta
    ...   ${TRBL_MNLENT_DISTNAME}
    ...   preventParamModifList
    ...   @{preventParamModifList_list}
    ...   delta_id=${delta_id}

    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/preventParamModifList_ON.json   ${delta_id}
    coam.Perform Delta Recommissioning
    ...   ${BTS Files}/preventParamModifList_ON.json
    ...   skip_parameter_relation_errors=${True}
    Set Test Variable    ${preventParamModifList}    ${True}

    Decide if MSM is ASOH ASOG for setting variables

Step 1: Check preventParamModifList mechanism and turn on actLocInfoStore
    [Documentation]
    ...  in this step test Check preventParamModifList mechanism and turn on actLocInfoStore
    ...  modulePositionInformation are added for SMOD1 and if exist SMOD2

    Log  Step 1: Check preventParamModifList mechanism and turn on actLocInfoStore  console=${True}

    ${delta_id3}  Set Variable  actLocInfoStore
    coam.Create Delta   ${delta_id3}

    coam.Append Parameter Update To Delta  ${TRBL_MNLENT_DISTNAME}  actLocInfoStore  true  ${delta_id3}
    coam.Append Parameter Update To Delta  ${TRBL_MNLENT_DISTNAME}  accLevSet  High  ${delta_id3}

    ${modulePositionInformation_dict}  Create Dictionary
    ...  altitude=256
    ...  latitude=543000000
    ...  longitude=1432010000

    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  list_name=modulePositionInformation
    ...  &{modulePositionInformation_dict}
    ...  delta_id=${delta_id3}

    Run Keyword If    ${Dual}    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...  list_name=modulePositionInformation
    ...  &{modulePositionInformation_dict}
    ...  delta_id=${delta_id3}

    coam.Get Delta   ${delta_id3}
    coam.Save Delta   ${BTS Files}/geolocation_ON.json    ${delta_id3}
    Run Keyword And Expect Error   ${EXPECTED_ERROR}   coam.Perform Delta Recommissioning
    ...  ${BTS Files}/geolocation_ON.json
    Log  Modification of restricted parameter FEATCADM-1-[actLocInfoStore] is not allowed: OK  console=${True}
    preventParamModifList_OFF

    coam.Perform Delta Recommissioning
    ...  ${BTS Files}/geolocation_ON.json
    ...  skip_parameter_relation_errors=${True}
    Set Test Variable   ${geolocation_ON}   ${True}
    Log  actLocInfoStore set to true  console=${True}

Step 2: Snapshot collection
    [Documentation]
    ...  in this step test collect snapshot

    Log  Step 2: Snapshot collection  console=${True}

    Snapshot collection


Step 3: Check geolocation file in snapshot
    [Documentation]
    ...  in this step test check geolocation files
    ...  test unpacked snapshot and find geolocation files
    ...  geolocation files are copied to a separate folder and check if not empty

    Log  Step 3: Check geolocation file in snapshot  console=${True}

    ${path_to_extracted_snapshot}    Set Variable  ${BTSFiles}/extract
    ${path_to_geolocation_files}     Set Variable  ${BTSFiles}/geolocation_files
    Run    mkdir ${path_to_extracted_snapshot}
    Run    mkdir ${path_to_geolocation_files}
    extractor.extractor    ${path_to_snapshot}  ${path_to_extracted_snapshot}
    ${files}=    OperatingSystem.List Files In Directory    ${path_to_extracted_snapshot}
    FOR    ${file}    IN    @{files}
        ${matches}=    Run Keyword And Return Status    Should Match Regexp    ${file}    .*BTS${BTS_ID}_.*_blackbox_geolocation.*
        Run Keyword If    ${matches}    OperatingSystem.Copy File   ${file}    ${path_to_geolocation_files}/${file}
    END

   Run    rm -r ${path_to_extracted_snapshot}
   Run    mkdir ${path_to_geolocation_files}/extracted
    ${files}=    OperatingSystem.List Files In Directory    ${path_to_geolocation_files}   *.xz
    FOR    ${file}    IN    @{files}
        Unpack Archive Content To Directory    ${path_to_geolocation_files}/${file}    ${path_to_geolocation_files}/extracted
        ${extracted_files}=    OperatingSystem.List Files In Directory    ${path_to_geolocation_files}/extracted
        ${extracted_files_name}    Fetch From Left    ${file}    .xz
        OperatingSystem.File Should Not Be Empty  ${path_to_geolocation_files}/extracted/${extracted_files_name}
    END

    ${geolocation_files}=       OperatingSystem.List Files In Directory    ${path_to_geolocation_files}/extracted/
    ${geolocation_files_count}=  Get Length    ${geolocation_files}

    Should Be Equal As Integers    ${number_of_SMOD_and_BBMOD}    ${geolocation_files_count}
    Log   Number of HWs supporting geolocation is equal to the number of geolocation files in the snapshot.    console=${True}

preventParamModifList_OFF
    [Documentation]
    ...  this KW disables the parameter preventParamModifList

    Log   disables the parameter preventParamModifList   console=${True}

    ${delta_id4}  Set Variable  preventParamModifList_OFF
    coam.Create Delta   ${delta_id4}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   preventParamModifList    ${delta_id4}
    coam.Get Delta   ${delta_id4}
    coam.Save Delta   ${BTS Files}/preventParamModifList_OFF.json    ${delta_id4}
    coam.Perform Delta Recommissioning
    ...  ${BTS Files}/preventParamModifList_OFF.json
    ...  skip_parameter_relation_errors=${True}
    Set Test Variable    ${preventParamModifList}    ${False}


Snapshot collection
    [Documentation]
    ...  KW collects a snapshot with the current date and sets a test variable for the snapshot location

    Log   snapshot collecting in progress   console=${True}

    ${timestamp}  Get time
    ${timestamp}  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${ingnored_error}=  Run Keyword And Ignore Error
    ...     coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...     Set test variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  verdicts.Set Test Failed  Collecting snapshot via Admin failed.  ${TRUE}
    Log    Snapshot was collected    console=${TRUE}

Decide if MSM is ASOH ASOG for setting variables
    [Documentation]    Sets variables which depend on variant of master SM
    ${sm_variant}=    Get SM variant
    Run Keyword If   '${sm_variant}' == 'ASOH AirScale Core' or '${sm_variant}' == 'ASOG AirScale Core'
                   ...    Case ASOG and ASOH
            ...    ELSE   Case NOT ASOG or ASOH

Case ASOG and ASOH
    [Documentation]    Sets variables for ASOG/ASOH
    pm_logs_general.Check if it is DualCore
    ${count_with_SMOD}=    Evaluate    1
    Set Test Variable    ${number_of_SMOD_and_BBMOD}    ${count_with_SMOD}

Case NOT ASOG or ASOH
    [Documentation]    Sets variables for SMOD different from ASOG/ASOH
    ${bbmod_list}    coam.Assert Any    BBMOD
    ${all_BBMOD}=    Create List
    FOR    ${item}    IN    @{bbmod_list}
        Append To List    ${all_BBMOD}    ${item['productName']}
    END
    ${BBMOD_count_without_ABIA}=    Evaluate    len([item for item in ${all_BBMOD} if 'ABIA' not in item])
    pm_logs_general.Check if it is DualCore
    ${count_with_SMOD}=    Run Keyword If    ${Dual}
    ...    Evaluate    ${BBMOD_count_without_ABIA} + 2
    ...    ELSE
    ...    Evaluate    ${BBMOD_count_without_ABIA} + 1
    Set Test Variable    ${number_of_SMOD_and_BBMOD}    ${count_with_SMOD}

Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is primary core, second (if exist) - secondary core
    ...
    ...  | **Author:** iuliia.taupeka@nokia.com
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (ASIB|ASOE|ASIL|ASIM|ASOF AirScale Core|ASOH AirScale Core|ASOG AirScale Core)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant[0]}

Custom Test Teardown
    Log   \nCustom Test Teardown   console=${True}

    Run Keyword If   ${geolocation_ON}
    ...   Revert Delta Changes actLocInfoStore
    Run Keyword If   ${preventParamModifList}
    ...   Revert Delta Changes preventParamModifList


Revert Delta Changes actLocInfoStore
    [Documentation]
    ...   KW revert delta changes actLocInfoStore

    Log   revert delta changes actLocInfoStore  console=${True}

    ${delta_id_2}   Set Variable   geolocation_OFF
    coam.Create Delta   ${delta_id_2}
    coam.Append Parameter Update To Delta
    ...   ${TRBL_MNLENT_DISTNAME}
    ...   actLocInfoStore
    ...   false
    ...   ${delta_id_2}
    coam.Append Parameter Delete To Delta
    ...   MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...   modulePositionInformation
    ...   ${delta_id_2}
    Run Keyword If    ${Dual}    coam.Append Parameter Delete To Delta
    ...   MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...   modulePositionInformation
    ...   ${delta_id_2}
    coam.Get Delta   ${delta_id_2}
    coam.Save Delta   ${BTS Files}/geolocation_OFF.json   ${delta_id_2}
    coam.Perform Delta Recommissioning   ${BTS Files}/geolocation_OFF.json   skip_parameter_relation_errors=${True}
    Set Test Variable   ${geolocation_ON}   ${False}


Revert Delta Changes preventParamModifList
    [Documentation]
    ...   KW revert delta changes preventParamModifList

    Log   revert delta changes preventParamModifList   console=${True}
    preventParamModifList_OFF


TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
