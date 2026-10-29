*** Settings ***
Documentation   This is a keyword file for CB012121-A, part counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${path_rd_files}     /tmp/RD.*ANY.xml.gz

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


Upload last 2 RD Counters files coam
    [Documentation]    [PRIVATE]   uploadlast 2 rd counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    BuiltIn.Log To Console    \nuploading rd file from coam
    ${alias_commonUnit}    Connect To Node Common Unit
    ssh.execute  ls -r ${path_rd_files} > /tmp/dir_allRDfile.txt  connection=${alias_commonUnit}
    ssh.Download File    /tmp/dir_allRDfile.txt   ${resultDir}/dir_allRDfile.txt      connection=${alias_commonUnit}
    ${rd_file_list}    Get File     ${resultDir}/dir_allRDfile.txt
    ${last_rd_file_name_with_path}   Get Line     ${rd_file_list}     0
    ${last_rd_file_name}    Remove String   ${last_rd_file_name_with_path}  /tmp/
    ssh.Download File    /tmp/${last_rd_file_name}   ${resultDir}/${last_rd_file_name}      connection=${alias_commonUnit}
    Run    gunzip ${resultDir}/${last_rd_file_name}
    ${rd_file_name}    Remove String   ${last_rd_file_name}  .gz
    BuiltIn.Set Test Variable    ${pm_file_name_1st_with_path}    ${resultDir}/${rd_file_name}

    ${2ndlast_rd_file_name_with_path}   Get Line     ${rd_file_list}     1
    ${2ndlast_rd_file_name}    Remove String   ${2ndlast_rd_file_name_with_path}  /tmp/
    ssh.Download File    /tmp/${2ndlast_rd_file_name}   ${resultDir}/${2ndlast_rd_file_name}      connection=${alias_commonUnit}
    Run    gunzip ${resultDir}/${2ndlast_rd_file_name}
    ${2ndlast_rd_file_name}    Remove String   ${2ndlast_rd_file_name}  .gz
    BuiltIn.Set Test Variable    ${pm_file_name_2nd_with_path}    ${resultDir}/${2ndlast_rd_file_name}


verify counter CB012121-A t1
    [Documentation]    [PRIVATE]   verify counter CB012121-A t1
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam

    Log to console    \nVerify counters of 1st measurement period
    prepare counters and expected values 1st measurement period t1
    ${parsed_xml}    parse xml    ${pm_file_name_1st_with_path}
    Verify Counter    M55157C00034    ${M55157C00034}    ${parsed_xml}


    Log to console    \nVerify counters of 2nd measurement period
    prepare counters and expected values 2nd measurement period t1
    ${parsed_xml}    parse xml    ${pm_file_name_2nd_with_path}
    Verify Counter    M55157C00035    ${M55157C00035}    ${parsed_xml}


verify counter CB012121-A B2-Alt5
    [Documentation]    [PRIVATE]   verify counter CB012121-A B2-Alt5
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam
    FOR   ${run}   IN   1st   2nd
       Log to console    \nVerify counters of ${run} measurement period
       ${parsed_xml}   parse xml    ${pm_file_name_${run}_with_path}
       run keyword   prepare counters and expected values B2-Alt5 ${run} measurement period NRCELL-1
       verify pm file counters   ${parsed_xml}
       run keyword   prepare counters and expected values B2-Alt5 ${run} measurement period NRCELL-2
       verify pm file counters   ${parsed_xml}
    END


verify counter CB012121-A B2-Alt4
    [Documentation]    [PRIVATE]   verify counter CB012121-A B2-Alt4
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam
    Log to console    \nVerify counters of 1st measurement period
    ${parsed_xml}   parse xml    ${pm_file_name_1st_with_path}
    run keyword   prepare counters and expected values B2-Alt4 1st measurement period NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1_1st}   parsed_xml=${parsed_xml}
    run keyword   prepare counters and expected values B2-Alt4 1st measurement period NRCELL-2
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=2    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-2_1st}   parsed_xml=${parsed_xml}

    Log to console    \nVerify counters of 2nd measurement period
    ${parsed_xml}   parse xml    ${pm_file_name_2nd_with_path}
    run keyword   prepare counters and expected values B2-Alt4 2nd measurement period NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=0   parsed_xml=${parsed_xml}
    run keyword   prepare counters and expected values B2-Alt4 2nd measurement period NRCELL-2
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=2    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-2_2nd}   parsed_xml=${parsed_xml}


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


verify counter CB012121-A B9
    [Documentation]    [PRIVATE]   verify counter CB012121-A B9
    ...     :Autor: Sylvia Schneider
    Collect and Filter last PM Counters file coam
    ${parsed_xml}   parse xml    ${pm_file}
    prepare counters and expected values B9 NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1}   parsed_xml=${parsed_xml}


verify counter CB012121-A B8
    [Documentation]    [PRIVATE]   verify counter CB012121-A B8
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam
    Log to console    \nVerify counters of 1st measurement period
    ${parsed_xml}   parse xml    ${pm_file_name_1st_with_path}
    prepare counters and expected values B8 1st measurement period NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_UE1}   parsed_xml=${parsed_xml}

    Log to console    \nVerify counters of 2nd measurement period
    ${parsed_xml}   parse xml    ${pm_file_name_2nd_with_path}
    prepare counters and expected values B8 2nd measurement period NRCELL-1
    verify pm file counters   ${parsed_xml}
    run keyword and continue on failure
    ...   verify counters M55142C00523 and M55142C00525   nrcell_id=1    TimeHoTgtSel=${TimeHoTgtSel_UE3}   parsed_xml=${parsed_xml}


verify counter CB012121-A B6
    [Documentation]    [PRIVATE]   verify counter CB012121-A B6
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam
    FOR   ${run}   IN   1st   2nd
       Log to console    \nVerify counters of ${run} measurement period
       ${parsed_xml}   parse xml    ${pm_file_name_${run}_with_path}
       run keyword   prepare counters and expected values B6 ${run} measurement period
       verify pm file counters   ${parsed_xml}
    END


verify counter CB012121-A B3 and B4
    [Documentation]    [PRIVATE]   verify counter CB012121-A B3 and B4
    ...     :Autor: Sylvia Schneider
    [Arguments]   ${counter_expectedValue}
    set test variable    ${counter_name}     M55142C00526
    set test variable    ${counter_id}       TOT_MEASREPORT_RECVD_MEASPRI
    set test variable    ${counter_text}     Total number of measurement reports received for measurement prioritization
    Log to console    \Verify M55142C00526 ${counter_id}
    set test variable    @{M55142C00526}    ${counter_text}     ${counter_expectedValue}    NRCELL-1   NRMO
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    Verify Counter    M55142C00526    ${M55142C00526}    ${parsed_xml}
