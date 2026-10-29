*** Settings ***
Library     ../../resources/python_resources/admin_cli.py  WITH NAME  hran_admin_cli
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

Documentation    TC for LOGS__CB009077_EutranAccessPointPosition_Parameters_Check


*** Keywords ***
TC__LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26700
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 0: Preconditions
    ...  Step 1: Create eutranAccessPointPosition
    ...  Step 2: Collct SCF and check if all new parameters exist
    ...  Test case verifies 5 new parameters introduce in CB009077 part C
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26700
    ...


    Set Tags    CA-LOGS    OWNER-jakub.kokoszka@nokia.com    AINTAINER-jakub.kokoszka@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R1    FEATURE-CB009077

    Step 0: Preconditions
    Step 1: Create eutranAccessPointPosition
    Step 2: Collect SCF and check if all new parameters exist



Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.
    ...   test check if LNCELL exist

    Log    Step 0: Preconditions    console=${True}

    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}
    Set Test Variable  ${eutranAccessPointPosition_craete}    ${False}

    ${cell_LNCEL_list}=    coam.Get Ids For All    LNCEL   timeout=120
    ${list_with_LNCEL_number_id}=    Create list
    FOR  ${lncel_cell}  IN  @{cell_LNCEL_list}
         ${LNCEL_cell_number}    Fetch From Right  ${lncel_cell}  -
         Append To List    ${list_with_LNCEL_number_id}    ${LNCEL_cell_number}
    END

    ${isEmpty}  Get length  ${list_with_LNCEL_number_id}
    Run Keyword If  ${isEmpty}!=0    Log    LNCELL exist
    ...    ELSE  verdicts.Set Test Failed  TC need LTE cells  ${TRUE}

    Set Test Variable    ${1_CELL_LNCEL}    ${list_with_LNCEL_number_id}[0]


Step 1: Create eutranAccessPointPosition
    [Documentation]
    ...   In this step eutranAccessPointPosition will be crate for one of LNCELs

    Log    Step 1: Create eutranAccessPointPosition on LNCEL-${1_CELL_LNCEL}    console=${True}

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    ${eutranAccessPointPosition_dict}  Create Dictionary
    ...   altitude=10
    ...   antennaGain=10
    ...   confidence=0
    ...   degreesOfLatitude=10
    ...   degreesOfLongitude=10
    ...   directionOfAltitude=height
    ...   latitudeSign=north
    ...   maxAntRange=10
    ...   sfnInitialisationTime=10
    ...   terrainAverageHeight=10
    ...   terrainHeightStdDeviation=10
    ...   uncertaintyAltitude=0
    ...   uncertaintySemiMajor=0
    ...   uncertaintySemiMinor=0
    ...   orientationOfMajorAxis=0

    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${1_CELL_LNCEL}
    ...  list_name=eutranAccessPointPosition
    ...  &{eutranAccessPointPosition_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/changes.json    skip_parameter_relation_errors=${True}
    Set Test Variable  ${eutranAccessPointPosition_craete}    ${True}


Step 2: Collect SCF and check if all new parameters exist
    [Documentation]
    ...   In this step test verifies 5 new parameters introduce in CB009077 part C

    Log    Step 2: Collect SCF and check if all new parameters exist    console=${True}

    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${file_content}    OperatingSystem.Get File    ${BTS_Files}/scf.xml
    ${parameter_1}    Should Match Regexp    ${file_content}   maxAntRange
    ${parameter_2}    Should Match Regexp    ${file_content}   antennaGain
    ${parameter_3}    Should Match Regexp    ${file_content}   sfnInitialisationTime
    ${parameter_4}    Should Match Regexp    ${file_content}   terrainAverageHeight
    ${parameter_5}    Should Match Regexp    ${file_content}   terrainHeightStdDeviation

Remove eutranAccessPointPosition
    [Documentation]
    ...   KW remoe eutranAccessPointPosition create in Step 1

    Log    Remove eutranAccessPointPosition on LNCEL-${1_CELL_LNCEL}    console=${True}
    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}
    coam.Append Parameter Delete To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${1_CELL_LNCEL}  eutranAccessPointPosition  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If    ${eutranAccessPointPosition_craete}    Remove eutranAccessPointPosition

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown


