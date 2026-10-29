*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4
Library    OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

*** Keywords ***
Check Log File From Snapshot File List
    [Documentation]   Author: Zhong Tingting
    [Arguments]   ${snapshot_zip_file_path}
    log to console    \nCheck Log File From Snapshot File List
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}  ${file}   OperatingSystem.Split Path   ${snapshot_zip_file_path}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${keyword}=  Set variable  \.zip\:
    ${matching_lines}=    Grep file    ${snapshot_unzip_file_path}/snapshot_file_list.txt    ${keyword}
    @{LIST_zips}=  Split To Lines  ${matching_lines}
    FOR  ${index}  IN  @{LIST_zips}
            ${zip_file}=  Strip String  string=${index}  mode=right  characters=:
            ${dir_unzip}=  Get Substring  string=${zip_file}  start=0  end=-4
            Run 	unzip -o ${snapshot_unzip_file_path}/${zip_file} -d ${snapshot_unzip_file_path}/${dir_unzip}
    END
    OperatingSystem.run    rm -rf ${snapshot_unzip_file_path}

Check startup runtime and soap file in ru log
    [Arguments]    ${ru_log}    ${ru_index}=1
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
    ${ru_type}   set variable  ${ru_info}[productName]
    ${ru_unit_num}    Set Variable If
    ...     '${ru_type}'=='AVQE'      2
    ...     '${ru_type}'=='AQQA'       8
    ...     '${ru_type}'=='AQQY'       8
    ...     '${ru_type}'=='AQQC'       8
    ...     '${ru_type}'=='AQQN'       8
    ...     '${ru_type}'=='AQQL'       8
    ...     '${ru_type}'=='AQQJ'       8
    ...     '${ru_type}'=='AQQQ'       8
    ...     '${ru_type}'=='AQQS'       8
    ...     '${ru_type}'=='AQQK'       8
    ...     '${ru_type}'=='AQQV'       8
    ...     '${ru_type}'=='AQHB'       8
    ...     '${ru_type}'=='AZNA'       0
    ...     '${ru_type}'=='AZHA'       0
    ...     '${ru_type}'=='AHPB'       0
    ...     '${ru_type}'=='AZQF'       0
    ...     '${ru_type}'=='AZQD'       0
    ...     '${ru_type}'=='AZQO'       0
    ...     '${ru_type}'=='AZQJ'       0
    ...     '${ru_type}'=='AHLOA'      0
    ...     '${ru_type}'=='AWHKB'      0
    ...     '${ru_type}'=='AWHQX'      0
    ...     '${ru_type}'=='AWHQN'      0
    ...     '${ru_type}'=='AWHQ2'      0
    ...     '${ru_type}'=='AWHHD'      0
    ...     '${ru_type}'=='AWHHF'      0
    ...     '${ru_type}'=='AHPF'       0
    ...     '${ru_type}'=='AHPH'       0
	...     '${ru_type}'=='AWPQZ'      0
    ...     '${ru_type}'=='AHCA'       0
    ...     '${ru_type}'=='AHPJ'       0
    ...     '${ru_type}'=='AWHQU'      0
    ...     '${ru_type}'=='AWPTD'      0
    ...     '${ru_type}'=='AWMFIA'     0
    ...     '${ru_type}'=='AHFII'      0
    ...     '${ru_type}'=='AWHQ3'      0
    ...     '${ru_type}'=='AWHNB'      0
    ...     '${ru_type}'=='AWHNA'      0
    ...     '${ru_type}'=='AVHA'       0
    ...     '${ru_type}'=='AVHQA'      0
    ...     '${ru_type}'=='AVHQB'      0
    ...     '${ru_type}'=='AVQC'       1
    ...     '${ru_type}'=='AVQA'       1
    ...     4
    ${ru_log_path}   Get Substring  ${ru_log}  0  -4
    Extract Zip File    ${ru_log_path}.zip    ${ru_log_path}
#    ${soap_info}    Run    command=ls '${ru_log_path}' | grep "1011_UnitOAM_SOAP_Log.zip"
    ${soap_info}    Run    command=ls '${ru_log_path}' | grep -E "1011_UnitOAM_SOAP_Log\.(zip|tar)"
    ${ru7_type_in_list}=    Run Keyword And Return Status    List Should Contain Value    ${RF7_ru_list}    ${ru_type}
    ${startup_filter}    Set Variable If    ${ru7_type_in_list} or '${ru_type}'=='AQQV'    11_ccsrt-startup    1*startup\.
    ${runtime_filter}    Set Variable If    ${ru7_type_in_list} or '${ru_type}'=='AQQV'    11_ccsrt-runtime    1*runtime\.
    ${startup_info}    Run    command=ls '${ru_log_path}' | grep "${startup_filter}"
    ${runtime_info}    Run    command=ls '${ru_log_path}' | grep "${runtime_filter}"
    Should Contain    ${soap_info}    1011_UnitOAM_SOAP_Log
    FOR    ${index}    IN RANGE    ${ru_unit_num}+1
        Run Keyword If    ${ru7_type_in_list} or '${ru_type}'=='AQQV'    run keywords
        ...    Should Contain    ${startup_info}    1${index}11_ccsrt-startup    AND
        ...    Should Contain    ${runtime_info}    1${index}11_ccsrt-runtime
        ...    ELSE    run keywords
        ...    Should Contain    ${startup_info}    1${index}11    AND
        ...    Should Contain    ${startup_info}    startup        AND
        ...    Should Contain    ${runtime_info}    1${index}11    AND
        ...    Should Contain    ${runtime_info}    runtime
    END
    run keyword if     '${ru_type}'=='AVQE' or '${ru_type}'=='AVQC'
    ...    Should Contain    ${startup_info}    2011
    run keyword if     '${ru_type}'=='AVQE' or '${ru_type}'=='AVQC'
    ...    Should Contain    ${runtime_info}    2011
    Run Keyword If    ${ru7_type_in_list}    run keywords
    ...    Should Contain    ${startup_info}    2011_ccsrt-startup    AND
    ...    Should Contain    ${runtime_info}    2011_ccsrt-runtime
