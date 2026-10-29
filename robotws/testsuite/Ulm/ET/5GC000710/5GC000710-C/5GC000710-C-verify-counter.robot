*** Settings ***
Documentation   This is a keyword file for 5GC000710-C, part parameter verify counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

collect pm file and verify counter values t1
    [Documentation]    [PRIVATE]    verify expected counter values for priority test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00036    ${M55157C00036}    M55157C00064    ${M55157C00064}
    ...                             M55124C01501    ${M55124C01501}    M55124C02002    ${M55124C02002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t2
    [Documentation]    [PRIVATE]    verify expected counter values for capabilities test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00037    ${M55157C00037}
    ...                             M55124C01501    ${M55124C01501}    M55124C02002    ${M55124C02002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t3
    [Documentation]    [PRIVATE]    verify expected counter values for rsrpCombined test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00034    ${M55157C00034}
    ...                             M55124C01501    ${M55124C01501}    M55124C02002    ${M55124C02002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t4
    [Documentation]    [PRIVATE]    verify expected counter values for handover test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00036    ${M55157C00036}
    ...                             M55124C01501    ${M55124C01501}    M55124C02002    ${M55124C02002}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


collect pm file and verify counter values t5
    [Documentation]    [PRIVATE]    verify expected counter values for redirect to LTE test
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    &{dict}    Create Dictionary    M55157C00038    ${M55157C00038}    M55124C02002    ${M55124C02002}
    ...                             M55124C01501    ${M55124C01501}    M55124C01502    ${M55124C01502}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END
