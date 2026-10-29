*** Settings ***
Documentation   This is a keyword file for CB013511, part counter
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
# Resource        ../../../resources/Common/pmcounters.robot

Library          String
Library          Collections
Library          OperatingSystem

Library          taf.collectors.pmcounters      WITH NAME     tafpmcounters
Library          taf.sw.reporting_portal

Resource        CB013511-parameter-settings.robot

*** Keywords ***

Collect Pm Counter File
    [Documentation]    [PRIVATE]   Collect Pm Counter File
    ...     :Author: Sylvia Schneider
    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.Create PM Collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    tafpmcounters.Setup Collectors
    ...    names=gnb_pm_counters
    tafpmcounters.Collect Collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.Teardown Collectors
    ...    names=gnb_pm_counters


Collect And Filter Last PM Counters File Coam
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam
    ...     :Author: Sylvia Schneider
    Collect Pm Counter File

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/gnb_pm_counters/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    String.Split To Lines    ${all_pm_file}
    ${pm_file_name}    Set Variable    ${temp}[0]
    ${pm_file_name_with_path}    Set Variable    ${resultDir}/gnb_pm_counters/${pm_file_name}
    ${pm_file}   Get File     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


Verify Counter A_SE_TC02_B2_ALT1
    [Documentation]    [PRIVATE]   Verify Counter A_SE_TC02_B2_ALT1
    ...     :Author: Sylvia Schneider
    Collect And Filter Last PM Counters File Coam
    Prepare Counters And Expected Values A_SE_TC02_B2_ALT1
    @{dict_keys}         Collections.Get Dictionary Keys    ${dict_miaf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Collections.Get From Dictionary    ${dict_miaf_counter}    ${counterKeyName}
        ${temp}   String.Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Counter 2 Dimension Objects    ${counter}    ${counterList}
    END
    @{dict_keys}         Collections.Get Dictionary Keys    ${dict_mnsa_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Collections.Get From Dictionary    ${dict_mnsa_counter}    ${counterKeyName}
        ${temp}   String.Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Counter 2 Dimension Objects    ${counter}    ${counterList}
    END


Verify Counter 2 Dimension Objects
    [Documentation]    [PRIVATE]   Verify Counter 2 Dimension Objects
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${counter}    ${counterList}
    ${counter_text}             Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}             Set Variable    ${counterList}[2]
    ${counter_distName}         Set Variable    ${bts_distName}/${counter_cell}
    ${counter_id}               Set Variable    ${counterList}[3]
    ${type}                     Set Variable    ${counterList}[4]

    ${counter_search}    Catenate    SEPARATOR=${EMPTY}
    ...   <DN>PLMN-PLMN/${counter_distName}</DN></MO>
    ...   <MO dimension="NR${type}"><DN>PLMN-PLMN/${counter_id}</DN></MO>
    ...   <NE-WBTS_1.0 measurementType="${type}"><${counter}>(\\d+)</${counter}>

    ${string_found}  String.Get Regexp Matches   ${pm_file}   ${counter_search}  1
    ${values_found}  Get Length   ${string_found}
    ${result}        Set Variable If    ${values_found}==1    Passed    Failed
    ${counter_value_from_pm_xml}   Set Variable   ${string_found}[0]
    IF    '${result}'=='Failed'    Fail    counter not found "${counter}", ${counter_cell}, ${counter_id}

    ${result}       Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${counter_text}" for cell ${counter_cell} and ${counter_id}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    taf.sw.reporting_portal.Report Pm Counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
