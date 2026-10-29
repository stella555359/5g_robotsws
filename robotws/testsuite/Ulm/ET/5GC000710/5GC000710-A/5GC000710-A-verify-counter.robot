*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part parameter verify counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

collect pm file and verify counter values t1
    [Documentation]    [PRIVATE]    verify expected counter values for default mobility profile test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00032    ${M55157C00032}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t2
    [Documentation]    [PRIVATE]    verify expected counter values for A2 with mobility test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00002    ${M55157C00002}
    ...                             M55157C00003    ${M55157C00003}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t3
    [Documentation]    [PRIVATE]    verify expected counter values for A1 with mobility test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00002    ${M55157C00002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t4
    [Documentation]    [PRIVATE]    verify expected counter values for no SPID test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00004    ${M55157C00004}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t5
    [Documentation]    [PRIVATE]    verify expected counter values for interGnb_interFreq_PSCell_change test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00002    ${M55157C00002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t6
    [Documentation]    [PRIVATE]    verify expected counter values for SgNB_modification test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55114C00001    ${M55114C00001}    M55114C00002    ${M55114C00002}    M55114C00003    ${M55114C00003}
    ...                             M55114C00004    ${M55114C00004}    M55114C00006    ${M55114C00006}    M55114C00007    ${M55114C00007}
    ...                             M55114C00020    ${M55114C00020}    M55115C00002    ${M55115C00002}    M55115C00003    ${M55115C00003}
    ...                             M55112C04001    ${M55112C04001}    M55112C04002    ${M55112C04002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

