** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part counter verification
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***


collect pm file and verify counter values
    Sleep     30s
    Collect PM Counters
    Verify counter values coam


Verify counter values coam
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}

    Log To Console    \ncounters for cell ${cell_distName} are verified
    &{dict_cell}   Create Dictionary     M55114C00001    ${M55114C00001}    M55114C00002    ${M55114C00002}
    ...                                  M55114C00003    ${M55114C00003}    M55114C00004    ${M55114C00004}
    ...                                  M55114C00006    ${M55114C00006}    M55114C00007    ${M55114C00007}
    ...                                  M55114C00016    ${M55114C00016}    M55114C00017    ${M55114C00017}
    ...                                  M55114C00018    ${M55114C00018}    M55114C00019    ${M55114C00019}
    ...                                  M55114C00020    ${M55114C00020}    M55115C00002    ${M55115C00002}
    ...                                  M55115C00003    ${M55115C00003}
    Log Dictionary    ${dict_cell}
    @{dict_keys}    Get Dictionary Keys    ${dict_cell}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_cell}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

