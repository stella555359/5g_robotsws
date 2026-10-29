*** Settings ***
Documentation
...            Keywords for collecting and analyzing PM counters
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    ta5g_pm_counters
Resource    pm_counters.robot


*** Keywords ***
Wait for Next PM Counters Interval
    [Documentation]    Waits for next PM counters interval
    ta5g_pm_counters.wait_for_next_full_pm_interval

Get Next XML PM Counters File
    [Documentation]    Waits for next PM counters interval and gets PM counters XML file
    ...                - ``dirpath``: Path to directory for the file, Default: ``$\{TEST_log_dir\}/PM/``
    [Arguments]    ${dirpath}=${TEST_log_dir}/PM/
    Create Directory    ${dirpath}
    ${filepath}    ta5g_pm_counters.get_next_unpacked_full_pm_counters_file    output_dirpath=${dirpath}
    RETURN    ${filepath}
