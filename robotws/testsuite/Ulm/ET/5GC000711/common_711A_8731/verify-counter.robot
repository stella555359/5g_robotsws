*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part verify counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${path_rd_files}     /tmp/RD.*ANY.xml.gz

*** Keywords ***

Upload last RD Counters file coam
    [Documentation]    [PRIVATE]   filter last rd counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Log To Console    \nuploading rd file from coam
    ${alias_commonUnit}    Connect to Node Common Unit
    ssh.execute  ls -r ${path_rd_files} > /tmp/dir_allRDfile.txt  connection=${alias_commonUnit}
    ssh.Download File    /tmp/dir_allRDfile.txt   ${resultDir}/dir_allRDfile.txt      connection=${alias_commonUnit}
    ${rd_file_list}    Get File     ${resultDir}/dir_allRDfile.txt
    ${last_rd_file_name_with_path}   Get Line     ${rd_file_list}     0
    ${last_rd_file_name}    Remove String   ${last_rd_file_name_with_path}  /tmp/
    ssh.Download File    /tmp/${last_rd_file_name}   ${resultDir}/${last_rd_file_name}      connection=${alias_commonUnit}
    Run    gunzip ${resultDir}/${last_rd_file_name}
    ${rd_file_name}    Remove String   ${last_rd_file_name}  .gz

    ${rd_file}  get file  ${resultDir}/${rd_file_name}
    ${rd_file}  replace string   ${rd_file}     ><  >\n<   count=-1
    Create File    ${resultDir}/rd.xml    ${rd_file}
    Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/rd.xml


get and parse RD file with counters
    [Documentation]    [PRIVATE]    get and parse RD file with counters
    ...       :Autor: Sylvia Schneider
    Upload last RD Counters file coam
    ${rd_counter_xml}    parse xml    ${pmCounter_xml_file}
    Set test variable    ${rd_counter_xml}


verify RD file counters
    [Documentation]    [PRIVATE]    verify RD file counters
    ...       :Autor: Sylvia Schneider
    &{dict}    Create Dictionary    I_LTE_HO_RES_ALC_ATT            ${I_LTE_HO_RES_ALC_ATT}
    ...                             I_LTE_HO_RES_ALC_SUCC           ${I_LTE_HO_RES_ALC_SUCC}
    ...                             I_LTE_HO_RES_ALC_F_AC           ${I_LTE_HO_RES_ALC_F_AC}
    ...                             I_LTE_HO_RES_ALC_F_OVLCP        ${I_LTE_HO_RES_ALC_F_OVLCP}
    ...                             I_LTE_HO_FAIL_TIME_EXP          ${I_LTE_HO_FAIL_TIME_EXP}
    ...                             I_LTE_HO_RES_ALC_F_OTHER        ${I_LTE_HO_RES_ALC_F_OTHER}
    ...                             I_LTE_HO_EXEC_NOTIFY            ${I_LTE_HO_EXEC_NOTIFY}

    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${rd_counter_xml}
    END


verify RD file counters VONR
    [Documentation]    [PRIVATE]    verify RD file counters VONR
    ...       :Autor: Sylvia Schneider
    &{dict}    Create Dictionary    I_LTE_HO_RES_ALC_ATT_VONR       ${I_LTE_HO_RES_ALC_ATT_VONR}
    ...                             I_LTE_HO_RES_ALC_SUCC_VONR      ${I_LTE_HO_RES_ALC_SUCC_VONR}
    ...                             I_LTE_HO_RES_ALC_F_AC_VONR      ${I_LTE_HO_RES_ALC_F_AC_VONR}
    ...                             I_LTE_HO_RES_ALC_F_OVLCP_VONR   ${I_LTE_HO_RES_ALC_F_OVLCP_VONR}
    ...                             I_LTE_HO_FAIL_TIME_EXP_VONR     ${I_LTE_HO_FAIL_TIME_EXP_VONR}
    ...                             I_LTE_HO_RES_ALC_F_OTHER_VONR   ${I_LTE_HO_RES_ALC_F_OTHER_VONR}
    ...                             I_LTE_HO_EXEC_NOTIFY_VONR       ${I_LTE_HO_EXEC_NOTIFY_VONR}

    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${rd_counter_xml}
    END


verify rd counters NNGCC
    [Documentation]    [PRIVATE]    verify rd counters NNGCC
    ...       :Autor: Sylvia Schneider
    Verify Counter    NNGCC_HO_REQ_LOC_REQ    ${NNGCC_HO_REQ_LOC_REQ}    ${rd_counter_xml}


verify all RD counters
    [Documentation]    [PRIVATE]    verify all RD counters
    ...       :Autor: Sylvia Schneider
    get and parse RD file with counters
    verify RD file counters
    verify RD file counters VONR


collect pm file and verify counter values
    [Documentation]    [PRIVATE]    verify expected counter values in pm and rd file
    ...       :Autor: Sylvia Schneider
    verify pm file counters


collect pm file and verify counter values without VONR
    [Documentation]    [PRIVATE]    verify expected counter values in pm and rd file part VONR only
    ...       :Autor: Sylvia Schneider
    verify pm file counters
    get and parse RD file with counters
    verify RD file counters


verify pm file counters
    [Documentation]    [PRIVATE]    verify counter in pm file using dictionary
    ...       :Autor: Sylvia Schneider
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    Log Dictionary    ${dict_pm_counter}
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END
