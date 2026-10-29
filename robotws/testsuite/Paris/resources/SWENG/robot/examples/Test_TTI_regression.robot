*** Comments ***
This test suite is used to test the TTI conversion and analysis interfaces.

*** Settings ***
Documentation        A test suite with a single test for testing the TTI conversion and analysis interfaces.
Library                               OperatingSystem
Resource                              ../TtiConvertInterface.robot
Resource                              ../TtiAnalysisInterface.robot
Resource                              ../Tools.robot

Suite Setup                           My Suite setup

*** Variables ***
${path_to_json}                       /home/ute/Downloads/TTITraces/TTI_traffic.json
${path_to_json2}                      /home/ute/Downloads/TTITraces/TTI_traffic_conv.json
${pcap_file_path}                     /home/ute/Downloads/TTITraces/TTI_traffic.pcap
${csv_file_path}                      /home/ute/Downloads/TTITraces/TTI_traffic.csv
${pcap_file_path_copy}                /home/ute/Downloads/TTITraces/TTI_traffic_conv.pcap
@{events_list}                        dlPdcchDciData
@{sfn_list}                           117     623
@{physCellId_list}                    50      51
@{lcrid_list}                         1       2
@{rnti_list}                          0
@{rnti_list2}                         27126
@{rnti_list3}                         27126    23080
&{rnti_dict}                          rnti=${rnti_list2}
&{dico_common_param_to_filter}        sfn=${sfn_list}       rnti=${rnti_list}
&{dico_common_param_to_filter2}       lcrId=${lcrid_list}     rnti=${rnti_list3}     physCellId=${physCellId_list}
&{dico_specif_param_to_filter2}       dlPdcchDciData.ueDciInfoList=${rnti_dict}
@{list_param_to_export}               timeStamp    sfn    slot    rnti    physCellId   dlPdcchDciData.ueDciInfoList

*** Test Cases ***

Test1
    @{events_list}=                   Create List     dlPdcchDciData
    Set Global Variable               ${path_to_json2}
    Set Global Variable               ${events_list}
    Set Global Variable               ${pcap_file_path_copy}
    Tools.Dated Log                         > pcap to decode is ${pcap_file_path_copy}
    Tools.Dated Log                         > for only events: ${events_list}
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${path_to_json2}
    IF   "${status}" == "PASS"
                            Tools.Dated Log            > ${path_to_json2} is already present, removing...
                            OperatingSystem.Remove File    ${path_to_json2}
    END
    TtiConvertInterface.Convert TTI capture    pcap_file_path=${pcap_file_path_copy}
    Compare File Sizes    ${path_to_json}    ${path_to_json2}
    TtiConvertInterface.Convert TTI capture    pcap_file_path=${pcap_file_path_copy}    events_list=${events_list}

Test2
    [Documentation]    Test filtering specific parameters in the DataFrame
    Set Global Variable    ${path_to_json}
    Set Global Variable    ${events_list}
    Set Global Variable    ${pcap_file_path}
    Set Global Variable    ${csv_file_path}
    Tools.Dated Log    > csv to export is ${csv_file_path}
    Tools.Dated Log    > from json input as ${path_to_json}
    Tools.Dated Log    > with only parameters: ${list_param_to_export}
    Tools.Dated Log    > by applying filters: ${dico_common_param_to_filter}
    TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe
    ...    path_to_csv=${csv_file_path}
    ...    parameters=${list_param_to_export}
    ...    common_parameters_filter=${dico_common_param_to_filter}
    ...    specific_parameters_filter=${dico_specif_param_to_filter2}
    ...    use_floats=${True}
    ...    path_to_json=${path_to_json}

Test3
    ${list_of_dicts}    ${count}    TtiAnalysisInterface.Get List Of Dict From Dataframe Column
    ...                 column=dlPdcchDciData.ueDciInfoList
    Log    List of dictionaries: ${list_of_dicts}
    Log    Count of dictionaries: ${count}

Test4
    @{list_param_to_export2}=          Create List    timeStamp    sfn    slot    rnti    lcrId    physCellId
    ...                                                             dlFdSchedData.startCce
    ...                                                             dlFdSchedData.aggregationLevel
    ...                                                             dlFdSchedData.pdcchPowerBoostType
    ...                                                             dlFdSchedData.pdcchStartSymbol
    ...                                                             dlFdSchedData.SLIV
    ...                                                             dlFdSchedData.dciFormat
    ...                                                             dlFdSchedData.searchSpaceId
    ...                                                             dlFdSchedData.cqiAlSelection
    ...                                                             dlFdSchedData.pdcchCqi
    ...                                                             ulFdSchedData.startCce
    ...                                                             ulFdSchedData.aggregationLevel
    ...                                                             ulFdSchedData.pdcchPowerBoostType
    ...                                                             ulFdSchedData.pdcchStartSymbol
    ...                                                             ulFdSchedData.SLIV
    ...                                                             ulFdSchedData.dciFormat
    ...                                                             ulFdSchedData.searchSpaceId
    ...                                                             ulFdSchedData.cqiAlSelection
    ...                                                             ulFdSchedData.pdcchCqi
    TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe    path_to_csv=${csv_file_path}
    ...                         parameters=${list_param_to_export2}
    ...                         common_parameters_filter=${dico_common_param_to_filter2}
    ...                         specific_parameters_filter=${None}
    ...                         use_floats=${False}
    ...                         path_to_json=${path_to_json}

*** Keywords ***

My Suite Setup
    OperatingSystem.Remove File                 ${path_to_json}
    ${git_path}                 set variable    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ${token_name}               set variable    NpsVrfToken
    ${token_access}             set variable    glpat-4yNB_jaBXxz_BsyeAsgL
    ${git_folder}               set variable    SWENG/Test_files
    ${git_file_name}            set variable    TTI_traffic2.json
    Download Package Using Git                  git_path=${git_path}
    ...                                         git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    ...                                         target_dir=/home/ute/Downloads/TTITraces
    ...                                         token_name=${token_name}
    ...                                         token_access=${token_access}
    Move File                                   /home/ute/Downloads/TTITraces/${git_file_name}    ${path_to_json}
    ${git_file_name}            set variable    TTI_traffic.pcap
    Download Package Using Git                  git_path=${git_path}
    ...                                         git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    ...                                         target_dir=/home/ute/Downloads/TTITraces
    ...                                         token_name=${token_name}
    ...                                         token_access=${token_access}
    Move File                                   /home/ute/Downloads/TTITraces/${git_file_name}    ${pcap_file_path_copy}

Compare File Sizes
    [Arguments]    ${file1}    ${file2}
    ${size1}=    Get File Size    ${file1}
    ${size2}=    Get File Size    ${file2}
    Should Be Equal As Numbers    ${size1}    ${size2}    The files ${file1} and ${file2} do not have the same size.
