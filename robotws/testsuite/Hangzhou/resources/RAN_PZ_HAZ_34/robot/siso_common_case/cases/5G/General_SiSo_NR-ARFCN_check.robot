*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      ../../step_keywords/5G/nrarfcn_and_gscn.robot


*** Keywords ***
General_SiSo_NR-ARFCN_check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to test SiSo_NR-ARFCN_check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.01.2020    - Created
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1  ${radio_type}=${ru_type_init}  ${variable_from_CFAM}=${Variables_CFAM}    ${expected_faultid}=1900
    Log to console    radio_type: ${radio_type}
    Selenium Login And Disable Screen Lock
    Get Parameters From NR_Frequencies_Band
    get nrarfcn boudary values  radio_type=${ru_type_init}  variable_from_CFAM=${variable_from_CFAM}
    ${nrarfcn}  ${gscn}  get origin nraradcn and gscn    cell_id=${cell_id}
    ${origin_params}  generate nrarfcn gscn modify parameters   nrarfcn=${nrarfcn}   gscn=${gscn}    cell_id=${cell_id}
    verify nrarfcn out of band boundary range  cell_id=${cell_id}
    verify nrarfcn out of TX/RX range    cell_id=${cell_id}    expected_faultid=${expected_faultid}
    Close Start Up View    timeout=60
    modify parameters on webem  modify_params=${origin_params}    timeout=180
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser
