*** Settings ***
Documentation
...   author: Ashok Santhanam
...   contact: ashok.santhanam@nokia.com


Library    Python/pmcounters.py     WITH NAME    gnb_pm
Library    Python/utilities.py
Library    Collections

Resource   Log/logcollection.robot

*** Keywords ***
Get Latest PM File From BTS
    [Arguments]   ${pm_files_path}
    [Documentation]    Returns the Path of the Latest PM file from directory.
    Collect PM Files To Path   ${pm_files_path}
    ${latest_pm_file}=   utilities.get_latest_pm_file   ${pm_files_path}
    [Return]   ${latest_pm_file}

Verify NRCell Counter Value in PM File
    [Arguments]   ${pm_file}   ${cell_id}=${1}   ${index}=${0}   &{counters_expected}
    [Documentation]    Validates the counter value from PM File specific to Cell Counters.
    ${counter_names}=   Get Dictionary Keys   ${counters_expected}
    ${counters_in_pm_file}=   gnb_pm.get_all_cell_counters_from_pm_file   ${pm_file}   ${cell_id}
    ...                       ${index}   ${counter_names}
    Dictionaries Should be Equal   ${counters_in_pm_file}   ${counters_expected}

Verify NRCell Counter Value in Latest PM File
    [Arguments]   ${pm_path}   ${cell_id}=${1}   ${index}=${0}   &{counters_expected}
    [Documentation]   Validates the NRCell Counter Value From Latest PM File by downloading it from BTS.
    ${latest_pm_file}=   Get Latest PM File From BTS   ${pm_path}
    Check NRCell Counter Value in PM File   ${latest_pm_file}   ${cell_id}   ${index}   &{counters_expected}

Verify Counter Value in PM File
   [Arguments]   ${pm_file}   ${object_name}   ${object_id}=${1}   ${index}=${0}   &{counters_expected}
   [Documentation]   Generic Keyword to validate the counter for a particular object.
   ...               Eg:Check Counter Value in PM File   pm_file=/tmp/ashok/pm_files/PERFMON_FILES/PM.BTS-72.20191021.040000.ANY.xml
   ...                                                   object_name=ETHIF   object_id=2   M51300C3=39486   M51300C4=3027

   ${counter_names}=   Get Dictionary Keys   ${counters_expected}
   ${counters_in_pm_file}=   gnb_pm.get_all_counters_from_pm_file_for_object   ${pm_file}   ${object_name}
   ...                       ${object_id}   ${index}   ${counter_names}
   Dictionaries Should be Equal   ${counters_in_pm_file}   ${counters_expected}

Verify Counter Value in Latest PM File
    [Arguments]   ${pm_path}   ${object_name}   ${object_id}=${1}   ${index}=${0}   &{counters_expected}
    [Documentation]   Generic Keyword to validate the counter for a particular object from a latest PM File.
    ${latest_pm_file}=   Get Latest PM File From BTS   ${pm_path}
    Check Counter Value in PM File   ${latest_pm_file}   ${object_name}   ${object_id}   ${index}
    ...                              &{counters_expected}

Get Latest Counter value from PM File
    [Arguments]   ${counter_ids}    ${object_name}   ${object_id}=${1}   ${index}=${0}
    [Documentation]   Generic Keyword to validate the counter for a particular object from a latest PM File.
    ...    para: counter_ids: pm counter ids, multiple counter use , ex: M55130C00001,M55310C10003
    ...    para: object_name: object name ex:  NRBTS
    Collect pm files To Path    pm_files_path=${LOG_PATH}
    ${latest_pm_file}=   Get Latest PM File From BTS   ${LOG_PATH}
    ${counter_ids_list}    split string  ${counter_ids}    ,
    ${counter_values}=   gnb_pm.get_all_counters_from_pm_file_for_object   ${latest_pm_file}   ${object_name}
    ...                       ${object_id}   ${index}   ${counter_ids_list}
    [Return]  ${counter_values}