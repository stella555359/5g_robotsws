*** Settings ***
Documentation    gnb ru info related keywords for both classical and cloud.
...              Please do not modify the file without notification to author
...              Author: Shi ZHihao
...              Contact:zhihao.shi@nokia-sbell.com

Library    gnb_ru_beamforming.py
Resource   ../../coam_gnb_classical.robot

*** Variables ***

*** Keywords ***
Check RU Beamforming Status
    [Arguments]  ${connection}=GNB_OAM    ${check_count}=${False}    ${check_ru_connect}=${False}
    Connect to Common Unit Master
    ${bfcali_flag}    set variable    ${True}
    ${length_in_init}    Get Length    ${tl.gnbs[0].dus[0].rus}
    ${ru_index_list}    get all ru index    connection=${connection}
    ${length_in_bts}    Get Length    ${ru_index_list}
    run keyword if    ${length_in_init}!=${length_in_bts}    Log to console    \nRU num in init is differ from in bts
    return from keyword if    ${length_in_init}!=${length_in_bts}    ${bfcali_flag}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index_login}    get index from list    ${ru_index_list}    ${ru_index}
        ${status}    run keyword and return status    Connect to RU With Allocated IP    ru_index=${ru_index_login+1}
        ...    ru_alias=RU_${ru_index}    connection=${connection}
        run keyword if    not ${status}    Log to console    \nlogin RU_${ru_index} failed\n
        ${bfcali_flag}    set variable if    not ${status} and ${check_ru_connect}     ${False}    ${bfcali_flag}
        continue for loop if    not ${status}
        ${carrier_flag}    check_ru_beamforing     ru_index=${ru_index}     ru_alias=RU_${ru_index}    connection=${connection}
        ...    check_count=${check_count}
        run keyword if    ${carrier_flag}==${True}
        ...    Log to console    \nRU_${ru_index} Beamforming Calibration -- PASS\n
        ...    ELSE IF    ${carrier_flag}==${False}
        ...    Log to console    \nRU_${ru_index} Beamforming Calibration -- FAIL\n
        ...    ELSE    Log to console    \nno need to check RU_${ru_index} beamforming calibration\n
        ${bfcali_flag}    set variable if    ${carrier_flag}==${False}     ${False}    ${bfcali_flag}
        csn.Disconnect  connection=RU_${ru_index}
    END
    should be true    ${bfcali_flag}
    [Return]    ${bfcali_flag}
    [Teardown]  csn.Disconnect  connection=ASIK Master
