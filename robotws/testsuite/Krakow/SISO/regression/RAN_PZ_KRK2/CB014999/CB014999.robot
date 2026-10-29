*** Settings ***
Documentation
...    Author: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    CB014999

Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource          ./resources/keywords.robot

Suite Setup       Common suite setup with OnAir test line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common suite teardown


*** Test Cases ***
[1][1.0] CB014999_Veryfing_RTWP_data_in_Blackbox_file
    [Documentation]    Check RTWP histogram incrementation by 1 and 2 samples in RU soft reset scenario.
    ...                This test bases on RUS_INFO variable defined in ./resource/variables.py . Simply update it with your RUs and run this test.
    ...                To have whole BBOX5 files downloaded from RUs into output folder please add ru_manager_CB014999.yml (for csv4all library) into
    ...                testline's folder on testline_configuration repository.
    [Setup]    Run keywords
    ...    python_keywords.Display RUs and cells for verification and fail if empty    AND
    ...    python_keywords.Setup csv4all node    AND
    ...    Common preconditions
    Wait for cells to be OnAir with timeout    timeout=10min
    Reset RUs and wait for cells to be OnAir
    ${rtwp_histograms_1}=    Get RTWP histograms from RUs via SSH
    python_keywords.Download BlackBox    ${OUTPUT_DIR}/Blackbox_files/1
    Sleep    20s    reason=1 new RTWP sample expected for started 15min period since cell became OnAir.
    Reset RUs and wait for cells to be OnAir
    ${rtwp_histograms_2}=    Get RTWP histograms from RUs via SSH
    python_keywords.Download BlackBox    ${OUTPUT_DIR}/Blackbox_files/2
    python_keywords.Verify number of samples appeared in RTWP histograms    ${rtwp_histograms_1}    ${rtwp_histograms_2}
    ...    expected_number_of_new_samples=${1}
    Sleep    15min 20s    reason=2 new RTWP samples expected - 1st for a complete 15min period and 2nd for started new 15min period.
    Reset RUs and wait for cells to be OnAir
    ${rtwp_histograms_3}=    Get RTWP histograms from RUs via SSH
    python_keywords.Download BlackBox    ${OUTPUT_DIR}/Blackbox_files/3
    python_keywords.Verify number of samples appeared in RTWP histograms    ${rtwp_histograms_2}    ${rtwp_histograms_3}
    ...    expected_number_of_new_samples=${2}
    [Teardown]    Run keywords
    ...    python_keywords.Teardown csv4all node    AND
    ...    Common postconditions
