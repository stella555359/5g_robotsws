*** Settings ***
Documentation
...            Keywords for collecting and analyzing PM counters on vRAN
...            author:       Mateusz Michalik, mateusz.michalik@nokia.com
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer:   Mateusz Michalik, mateusz.michalik@nokia.com
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com

Resource    configurators_vran.robot
Resource    pm_counters.robot
Library     OperatingSystem
Library    ./Python/VRanPmCountersExtension.py
Library    ./Python/CounterAnalyzerCloud.py

*** Variables ***
${EXPECTED_VDU_YAML}    ./configs/pm_counters_template_vdu_baseline.yaml
${EXPECTED_VCU_YAML}    ./configs/pm_counters_template_vcu_baseline.yaml

*** Keywords ***
Wait for Next vRAN PM Counters Interval
    [Documentation]    Waits for next vRAN PM counters interval
    ...                - ``timeout`` (optional):  default timeout: 60min
    [Arguments]    ${timeout}=3600
    VRanPmCountersExtension.Wait For New Vran Pm Filenames
    ...    timeout=${timeout}

Get Next vRAN XML PM Counters Files
    [Documentation]    Keyword used to get the dictionary containing lists of files for both vdu and vcu
    ...                which will be used for performing verification
    ...                - ``dirpath``: Path to directory for the file, Default: ``$\{OUTPUT DIR\}/Logs/$\{TEST NAME\}/``
    ...                - ``timeout`` (optional):  default timeout: 60min
    ...                [Return]  {'vcu': 'path_to_pm_vcu.xml', 'vdu': 'path_to_pm_vdu.xml'}
    [Arguments]    ${dirpath}=${OUTPUT DIR}/Logs/Test_Cases/${TEST NAME}/    ${timeout}=3600
    ${pm_files_dict}=  VRanPmCountersExtension.get_next_vran_unpacked_full_pm_counters_files
    ...    output_dirpath=${dirpath}
    ...    timeout=3600
    [Return]    ${pm_files_dict}

Set New vRAN PM Interval
    [Documentation]    Keyword used to prepare delta commissioning .json files for vDU and vCU using provided interval
    ...                based on the templates:
    ...                ``testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vdu.json``
    ...                ``testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vcu.json``
    ...                and uploading these files.
    ...                - ``interval``: Length of the interval to be set
    [Arguments]    ${interval}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True      '${interval}' in ('5min','15min','30min','60min')    msg=Invalid KW parameter: interval
    #---------------------------------------------------------------------------------------------------------------
    ${path}    CounterAnalyzerCloud.Prepare Deltas For New Vran Pm Interval    ${interval}
    &{configs}    Create Dictionary    delta_vdu=${path}[0]    delta_vcu=${path}[1]
    Upload Configs    config=${configs}
    ${result}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${interval}    5min
    Run Keyword If    ${result}    Run Keywords
    ...    Log to console    Waiting for delta activation
    ...    AND    Sleep    360s    reason=Wait until the new interval takes effect

