*** Settings ***
Documentation   This is a keyword file for CB013024, part counter
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------
Resource        CB013024-parameter-settings.robot
Library         OperatingSystem
Library         XML
Library         taf.collectors.pmcounters      WITH NAME     tafpmcounters
Library         taf.sw.reporting_portal

*** Keywords ***


Collect Pm Counter File
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam 13024
    ...     :Autor: Shruthi Shivaprasad

    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=sbts
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters


Collect And Filter Last PM Counters File Coam
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam
    ...     :Autor: Shruthi Shivaprasad
    Collect Pm Counter File
    ${rc}    ${all_pm_file}    OperatingSystem.Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF    '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    OperatingSystem.Move File    ${pm_file_name_with_path}    ${resultDir}/
    OperatingSystem.Empty Directory    ${resultDir}/${coam_pm_file_path}
    OperatingSystem.Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${pm_file}   get file     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


Verify Counter CB013024
    [Documentation]    [PRIVATE]   verify counter CB006139
    ...     :Autor: Shruthi Shivaprasad
    Log to console    \nVerify counters
    Collect And Filter Last PM Counters File Coam
    run keyword   Prepare Counters And Expected Values T1
    ${parsed_PmFile}    XML.parse xml    ${pm_file}
    set test variable    ${parsed_PmFile}
    ${range_end}   Evaluate   ${no_counters_to_check}+1
    FOR    ${counter_no}    IN RANGE  1   ${range_end}
       Verify Single Counter    ${counter_no}
    END


Verify Single Counter
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Shruthi Shivaprasad
    [Arguments]    ${counter_no}
    Log to console    \nVerify single counter
    ${counter}    Set Variable    ${counter_${counter_no}}[0]
    ${counter_check}    Set Variable       ${counter_${counter_no}}[1]
    ${counter_cell}    Set Variable        ${counter_${counter_no}}[2]
    ${counter_meastype}    Set Variable    ${counter_${counter_no}}[3]
    ${counter_distName}    Set Variable    PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}

    ${xpath}    replace variables
    ...     *[DN='${counter_distName}']/../NE-WBTS_1.0[@measurementType="${counter_meastype}"]/${counter}
    ${counter_value_from_pm_xml}    XML.get element text     ${parsed_PmFile}        xpath=.//${xpath}
    ${result}       Set Variable If    ${counter_value_from_pm_xml}${counter_check}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${text_${counter}}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} ${counter_check}\n
    IF    '${result}'=='Passed'
        Log to console    ${msg1} passed: ${msg2}
    ELSE
        Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    END
    taf.sw.reporting_portal.report pm counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
