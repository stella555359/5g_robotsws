***Settings***
Documentation
...   Keywords which help with loading scf on TL.
...   author: Bartlomiej Bienko
...   contact: bartlomiej.bienko@nokia.com

Library    ./tools/keywords.py

***Keywords***

Load and Activate TC SCF and wait for OnAir
    [Documentation]    Loads and activates SCF and ASiR SCF for desired TC, then waits for OnAir state.
    [Arguments]    ${tc_name}
    ${SCF_PATH}=    Get Commissioning Path For Test Case   test_case_name=${tc_name}
    Perform Full Commissioning on Classical gNB    scf_path=${SCF_PATH}

    ${ASIR_SCF_PATH}=    Get Commissioning Path For Test Case    test_case_name=${tc_name}    scf_type=asir
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir

Load and Activate TC SCF
    [Documentation]    Loads and activates SCF and ASiR SCF for desired TC.
    [Arguments]    ${tc_name}
    ${SCF_PATH}=    Get Commissioning Path For Test Case   test_case_name=${tc_name}
    Perform Full Commissioning on Classical gNB    scf_path=${SCF_PATH}

    ${ASIR_SCF_PATH}=    Get Commissioning Path For Test Case    test_case_name=${tc_name}    scf_type=asir
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
