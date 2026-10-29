*** Settings ***
Documentation   This is a keyword file for CB008146-E, part parameter verify counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

collect pm file and verify counter values t1
    [Documentation]    [PRIVATE]    verify expected counter values for A2 redirect and HO test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00035    ${M55157C00035}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t2
    [Documentation]    [PRIVATE]    verify expected counter values for A2 with measurement gap test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00035    ${M55157C00035}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t3
    [Documentation]    [PRIVATE]    verify expected counter values for A1 without measurement gap test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00035    ${M55157C00035}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t4
    [Documentation]    [PRIVATE]    verify expected counter values for A1 voice test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00035    ${M55157C00035}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t5
    [Documentation]    [PRIVATE]    verify expected counter values for interGnb interFreq HO test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00036    ${M55157C00036}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t6
    [Documentation]    [PRIVATE]    verify expected counter values for A2 after interGnb intraFreq HO test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00037    ${M55157C00037}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END



collect pm file and verify counter values 2 cell config
    [Documentation]    [PRIVATE]    verify expected counter values for A2 after interGnb intraFreq HO test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00034    ${M55157C00034}    M55157C00035    ${M55157C00035}    M55157C00036    ${M55157C00036}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

