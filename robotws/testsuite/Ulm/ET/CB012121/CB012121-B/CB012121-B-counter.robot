*** Settings ***
Documentation   This is a keyword file for CB012121-B, part counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

collect pm counter file
    [Documentation]    [PRIVATE]   collect pm counter file for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters



collect pm counter file and filter last 2 PM Counters file coam
    [Documentation]    [PRIVATE]   filter last 2 pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    collect pm counter file

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    set test variable    ${pm_file_name_2nd_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[0]}
    set test variable    ${pm_file_name_1st_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[1]}


Collect and Filter last PM Counters file coam
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam
    ...     :Autor: Sylvia Schneider
    collect pm counter file

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${pm_file}   get file     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


verify counters M55142C00523 and M55142C00525
    [Documentation]    [PRIVATE]   verify counters M55142C00523 and M55142C00525
    ...     :Autor: Sylvia Schneider
    [Arguments]   ${nrcell_id}   ${TimeHoTgtSel}   ${parsed_xml}

    @{M55142C00523}  create list   ${text_M55142C00523}    ${TimeHoTgtSel}   NRCELL-${nrcell_id}   NRMO
    @{M55142C00525}  create list   ${text_M55142C00525}    ${TimeHoTgtSel}   NRCELL-${nrcell_id}   NRMO
    Verify Counter    M55142C00523    ${M55142C00523}     ${parsed_xml}
    Verify Counter    M55142C00525    ${M55142C00525}     ${parsed_xml}


verify pm file counters
    [Documentation]    [PRIVATE]    verify counter in pm file using dictionary
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${parsed_xml}
    Log Dictionary    ${dict_pm_counter}
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


verify counter CB012121-B-B1-Alt2
    [Documentation]    [PRIVATE]   Verify Counter CB012121-B-B1-Alt2
    ...     :Autor: Yasir Mehmood
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B-B1-Alt2 NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1}   parsed_xml=${parsed_xml}


verify counter CB012121-B-B6
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B6
    ...     :Autor: Yasir Mehmood
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B-B6 NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=0   parsed_xml=${parsed_xml}


verify counter CB012121-B-B8
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B8
    ...     :Autor: Sylvia Schneider
    Collect and Filter last PM Counters file coam
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B-B8 NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1}   parsed_xml=${parsed_xml}


verify counter CB012121-B-B10
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B10
    ...     :Autor: Sylvia Schneider
    prepare counters and expected values B-B10
    collect pm counter file and filter last 2 PM Counters file coam

    FOR   ${run}    IN   1st    2nd
        Log to console    \nVerify counters of ${run} measurement period
        ${parsed_xml}    parse xml    ${pm_file_name_${run}_with_path}
        verify pm file counters   ${parsed_xml}
        verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_${run}}   parsed_xml=${parsed_xml}
    END


verify counter CB012121-B-B14
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B14
    ...     :Autor: Sylvia Schneider
    Collect and Filter last PM Counters file coam
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B-B14
    verify pm file counters   ${parsed_xml}


verify counter CB012121-B-B2-Alt3
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B2-Alt3
    ...     :Autor: Sylvia Schneider
    Collect and Filter last PM Counters file coam
    ${parsed_xml}   parse xml    ${pm_file}
    FOR   ${NRCELL_id}     IN    1   2
       run keyword   prepare counters and expected values B-B2-Alt3 NRCELL-${NRCELL_id}
       verify pm file counters   ${parsed_xml}
       run keyword and continue on failure
       ...   verify counters M55142C00523 and M55142C00525  nrcell_id=${NRCELL_id}
       ...   TimeHoTgtSel=${TimeHoTgtSel_NRCELL-${NRCELL_id}}   parsed_xml=${parsed_xml}
    END


verify counter CB012121-B-B3-Alt2-Alt3
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B3-Alt2-Alt3
    ...     :Autor: Sylvia Schneider
    prepare counters and expected values B-B3-Alt2-Alt3
    collect pm counter file and filter last 2 PM Counters file coam

    FOR   ${run}    IN   1st    2nd
        Log to console    \nVerify counters of ${run} measurement period
        ${parsed_xml}    parse xml    ${pm_file_name_${run}_with_path}
        verify pm file counters   ${parsed_xml}
        verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_${run}}   parsed_xml=${parsed_xml}
    END


verify counter CB012121-B-B4
    [Documentation]    [PRIVATE]   verify counter CB012121-B-B4
    ...     :Autor: Sylvia Schneider
    Collect and Filter last PM Counters file coam
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B-B4
    verify pm file counters   ${parsed_xml}
