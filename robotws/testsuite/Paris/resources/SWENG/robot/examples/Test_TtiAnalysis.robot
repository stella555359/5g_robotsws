*** Settings ***

Resource                ../Tools.robot
Library                 OperatingSystem

Suite Setup             My Suite Setup

Resource                ../TtiAnalysisInterface.robot
Resource                ../TtiMultiAnalysisInterface.robot

Suite Teardown          My Suite Tear Down

Documentation           Refer to the TtiAnalysis.robot file and the TtiAnalysis.py file for more information
...                     on the TTI analysis and the TTI analysis results.

*** Variables ***

${max_column_name}     dlFdSchedData.numOfPrb
${min_column_name}     dlFdSchedData.numOfPrb
${path_to_json}        /tmp/TTI_A05_3_Traffic.json
${path_to_csv}         /tmp/TTI_A05_3_Traffic.csv
${path_to_csv2}         /tmp/TTI_export.csv
@{parameters}                      timeStamp    sfn    slot    rnti    physCellId     ulPuschReceiveRespPsData.rxPower
@{parameters2}                     timeStamp    sfn    slot    rnti    physCellId     dlFdSchedData.numOfPrb
&{common_parameters_filter}        slot=[1, 2, 3, 4, 5, 6]        rnti=[65521, 21187]
&{specific_parameters_filter}      ulPuschReceiveRespPsData.rxPower=[0, -73.4786, -73.4931, -73.4836]
&{specific_parameters_filter2}     dlFdSchedData.numOfPrb=[208, 273, 274]
@{list_events}                     ulPuschReceiveRespPsData    dlFdSchedData

*** Test Cases ***

Test Some TTI Analysis
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    ${result} =    TtiAnalysisInterface.Check Max For Column     ${max_column_name}
    Log            Retrieved result is ${result}
    Should Be Equal As Numbers    ${result}    273.0    Failure message='The result is not equal to 273.0'

Test Some TTI Analysis 2
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    ${result} =    TtiAnalysisInterface.Check Min For Column     ${min_column_name}
    Log            Retrieved result is ${result}
    Should Be Equal As Numbers    ${result}    16.0    Failure message='The result is not equal to 16.0'

Test Bler
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    ${result} =    TtiAnalysisInterface.Verify Distribution Table Of    dlFdSchedData.effectiveCodeRate
    ...            Scatter
    Log            Retrieved result is ${result}

Test Export To CSV
    [Tags]    DEBUG
    Set Global Variable    ${path_to_csv}
    TtiAnalysisInterface.Export Current Dataframe To CSV    ${path_to_csv}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${path_to_csv}
    Should Be True    ${file_exists}    msg=File does not exist

Test Export Specific Parameters To CSV and Dataframe
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    Set Global Variable    ${path_to_csv2}
    Log    Exporting specific parameters to CSV and Dataframe
    Log    Common parameters filter: ${common_parameters_filter}
    Log    Specific parameters filter: ${specific_parameters_filter}
    Log    Parameters: ${parameters}
    Log    Path to CSV: ${path_to_csv2}
    TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe    ${path_to_csv2}    ${parameters}
    ...                                                ${common_parameters_filter}    ${specific_parameters_filter}
    ...                                                path_to_json=${path_to_json}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${path_to_csv2}
    Should Be True    ${file_exists}    msg=File does not exist

Test Export Specific Parameters To CSV and Dataframe 2
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    Set Global Variable    ${path_to_csv2}
    Log    Exporting specific parameters to CSV and Dataframe
    Log    Common parameters filter: ${common_parameters_filter}
    Log    Specific parameters filter: ${specific_parameters_filter2}
    Log    Parameters: ${parameters2}
    Log    Path to CSV: ${path_to_csv2}
    TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe    ${path_to_csv2}    ${parameters2}
    ...                                                ${common_parameters_filter}    ${specific_parameters_filter2}
    ...                                                path_to_json=${path_to_json}
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${path_to_csv2}
    Should Be True    ${file_exists}    msg=File does not exist

Test Export Multiple Dataframes To CSV
    [Tags]    DEBUG
    Set Global Variable    ${path_to_json}
    Set Global Variable    ${list_events}
    ${res} =          TtiMultiAnalysisInterface.Export Dataframes To CSV
    Log    Exporting multiple dataframes to CSV
    Log    ${res}
    List Files With Sizes    /tmp    pattern=TTI_*.csv
    ${file_exists}    Run Keyword And Return Status    File Should Exist    /tmp/TTI_dlFdSchedData.csv
    Should Be True    ${file_exists}    msg=File does not exist

*** Keywords ***

My Suite Setup
    Download Package Using Git    SWENG/Test_files    TTI_A05_3_Traffic.json    target_dir=/tmp

My Suite Tear Down
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${path_to_csv}
    IF    ${file_exists}
                            List Files With Sizes    /tmp    pattern=TTI_A05_3_Traffic.csv
                            Remove File    ${path_to_csv}
    END
    ${file_exists}    Run Keyword And Return Status    File Should Exist    ${path_to_csv}
    Should Not Be True    ${file_exists}    msg=File still exists

List Files With Sizes
    [Arguments]    ${dir}    ${pattern}=${EMPTY}
    ${files}=    List Files In Directory    ${dir}    ${pattern}
    FOR    ${file}    IN    @{files}
        ${size}=    Get File Size    ${dir}/${file}
        Log    ${file}: ${size}
    END
