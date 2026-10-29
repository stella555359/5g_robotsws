*** Settings ***
Documentation    gnb ru info related keywords for both classical and cloud.
...              Please do not modify the file without notification to author
...              Author: Shi ZHihao
...              Contact:zhihao.shi@nokia-sbell.com

Resource   ../coam_gnb_classical.robot

*** Variables ***

*** Keywords ***
Check RU Beamforming Status
    [Arguments]  ${connection}=GNB_OAM
    Connect to Common Unit Master
    ${bfcali_flag}    set variable    ${True}
    ${length}=    Get Length    ${tl.gnbs[0].dus[0].rus}
    FOR    ${raw_ru_index}    IN RANGE    ${length}
        ${ru_index}    Evaluate    ${raw_ru_index}+${1}
        ${actBeamforming}    Check Activate Beamforming for RU   ru_index=${ru_index}    connection=${connection}
        run keyword if    not ${actBeamforming}
        ...    Log to console    \nRU_${ru_index} activate beamforming is false, no need to check beamforming calibration
        continue for loop if    not ${actBeamforming}
        ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}    connection=${connection}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    connection=${connection}
        ${status}    run keyword if    '${radio_protocol}'=='CPRI'    Check CPRI RU Beamforming    ru_alais=RU_${ru_index}
        ...    ELSE    Check ECPRI RU Beamforming    ru_alais=RU_${ru_index}
        run keyword if    ${status}     Log to console    \nRU_${ru_index} Beamforming Calibration -- PASS\n
        csn.Disconnect  connection=RU_${ru_index}
        ${bfcali_flag}    set variable if    ${status}==${False}    ${status}    ${bfcali_flag}
    END
    should be true    ${bfcali_flag}
    [Return]    ${bfcali_flag}
    [Teardown]  csn.Disconnect  connection=ASIK Master

Get RU Beamforming Count
    [Arguments]  ${ru_index}=1    ${get_count}=${False}    ${connection}=GNB_OAM
    Connect to Common Unit Master
    ${bfcali_flag}    set variable    ${True}
    ${actBeamforming}    Check Activate Beamforming for RU   ru_index=${ru_index}    connection=${connection}
    run keyword if    not ${actBeamforming}
    ...    Log to console    \nRU_${ru_index} activate beamforming is false, no need to check beamforming calibration
    return from keyword if    not ${actBeamforming}    ${None}    ${None}
    ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}    connection=${connection}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    connection=${connection}
    ${tx_num}    ${rx_num}    run keyword if    '${radio_protocol}'=='CPRI'    Check CPRI RU Beamforming
    ...    ru_alais=RU_${ru_index}    get_count=${get_count}
    ...    ELSE    Check ECPRI RU Beamforming    ru_alais=RU_${ru_index}    get_count=${get_count}
    csn.Disconnect  connection=RU_${ru_index}
    [Return]    ${tx_num}    ${rx_num}
    [Teardown]    csn.Disconnect  connection=ASIK Master

Check Activate Beamforming for RU
    [Arguments]    ${ru_index}  ${connection}=GNB_OAM
    ${cell_list}    get all cell id    ru_index=${ru_index}    connection=${connection}
    ${get_actBeamforming}    set variable    ${False}
    FOR    ${cell_id}    IN    @{cell_list}
        ${actBeamforming}    get_activate_beamforming_via_admin    cell_id=${cell_id}    connection=${connection}
        ${actBeamforming}    convert to string    ${actBeamforming}
        ${get_actBeamforming}    set variable if    '${actBeamforming.lower()}'=='true'    ${True}    ${get_actBeamforming}
    END
    [Return]    ${get_actBeamforming}

Check CPRI RU Beamforming
    [Arguments]    ${ru_alais}    ${get_count}=${False}
    ${bf_output}    csn.execute    command=sudo bfcali --status    connection=${ru_alais}
    ${all_status}    set variable    ${True}
    ${tx_matchs_1}    Get Regexp Matches    ${bf_output}    Tx[\\s\\S]*Calibration TotalCount: (\\d+)    1
    ${tx_matchs_2}    Get Regexp Matches    ${bf_output}    Tx[\\s\\S]*CompensationCount: (\\d+)    1
    ${tx_num}   set variable if    ${tx_matchs_1[0]}==${tx_matchs_2[0]}    ${tx_matchs_1[0]}
    ${rx_matchs_1}    Get Regexp Matches    ${bf_output}    Rx[\\s\\S]*Calibration TotalCount: (\\d+)    1
    ${rx_matchs_2}    Get Regexp Matches    ${bf_output}    Rx[\\s\\S]*CompensationCount: (\\d+)    1
    ${rx_num}   set variable if    ${rx_matchs_1[0]}==${rx_matchs_2[0]}    ${rx_matchs_1[0]}
    return from keyword if    ${get_count}    ${tx_num}    ${rx_num}
    ${all_status}    set variable if    ${tx_num} and ${rx_num} and ${tx_num}==${rx_num}   ${True}    ${False}
    run keyword and continue on failure    should be true    ${all_status}
    [Return]    ${all_status}

Check ECPRI RU Beamforming
    [Arguments]    ${ru_alais}    ${get_count}=${False}
    ${bf_output}    csn.execute    command=sudo bfcali -stat    connection=${ru_alais}
    ${bf_output}    evaluate    "" if $bf_output is None else $bf_output
    ${matchs}    Get Regexp Matches    ${bf_output}    Calibration statistics are stored for (\\d+) carriers    1
    ${match_len}    Get Length    ${matchs}
    ${match_0}    set variable if    ${match_len}==0    ${0}    ${matchs[0]}
    ${cell_num}    Evaluate    int(${match_0}/${2})
    ${matchs_1}    Get Regexp Matches    ${bf_output}    Calibration attempts: (\\d+)    1
    ${matchs_2}    Get Regexp Matches    ${bf_output}    Successful calibrations: (\\d+)    1
    ${rx_matchs_1}    set variable    ${matchs_1[::2]}
    ${tx_matchs_1}    set variable    ${matchs_1[1::2]}
    ${rx_matchs_2}    set variable    ${matchs_2[::2]}
    ${tx_matchs_2}    set variable    ${matchs_2[1::2]}
    ${all_status}    set variable    ${True}
    FOR    ${index}    IN RANGE    0    ${cell_num}
        ${tx_num}   set variable if    ${tx_matchs_1[${index}]}==${tx_matchs_2[${index}]}    ${tx_matchs_1[${index}]}
        ${rx_num}   set variable if    ${rx_matchs_1[${index}]}==${rx_matchs_2[${index}]}    ${rx_matchs_1[${index}]}
        ${all_status}    set variable if    ${tx_num} and ${rx_num} and ${tx_num}==${rx_num}   ${True}    ${False}
        exit for loop if    ${all_status}==${False}
    END
    sort list    ${rx_matchs_2}
    sort list    ${tx_matchs_2}
    return from keyword if    ${get_count}    ${tx_matchs_2[0]}    ${rx_matchs_2[0]}
    run keyword and continue on failure    should be true    ${all_status}
    [Return]    ${all_status}
