*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author
...              Author: zhihao.shi
...              Contact: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.selenium.sbts  WITH NAME  selenium_coam
Resource      taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Keywords ***
Get counter latest value
    [Arguments]    ${BTS_or_TRS}    ${counter_id}    ${counter_full_path}    ${connection}=GNB_OAM
    ...    ${counters_info}=&{EMPTY}
    Log to console    Gathering value of counter: "${counter_id}"
    ${counters_info}=    run keyword if    &{counters_info} == &{Empty}
    ...    coam.get_counters_info    connection=${connection}    timeout=120
    ...    ELSE    set variable    ${counters_info}
    set test variable    ${counters_info}
    ${counter_groups} =    Get From Dictionary    ${counters_info}    ${BTS_or_TRS}
    ${counter_group_keys} =    Split String    ${counter_full_path}    /
    ${counter_groups_length} =    Get Length    ${counter_group_keys}
    Remove From List    ${counter_group_keys}    ${counter_groups_length-1}
    FOR    ${group}    IN     @{counter_group_keys}
        ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}
    END
    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${counter_id}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    Reverse List    ${key_list}
    ${latest_value} =    Get From Dictionary    ${counter_values}    ${key_list[0]}
    [Return]    ${latest_value}

Check M5130 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    ${M51301C0_value}    Get counter latest value    BTS_or_TRS=TRS    counter_id=M51301C0
    ...    counter_full_path=TNL-1/ETHLK/ETHLK-1/ETHLK_stats/EthLinkInFrames
    ${M51301C0_value}    convert to integer     ${M51301C0_value}
    Should Be True    ${M51301C0_value} >0
    ${M51301C1_value}    Get counter latest value    BTS_or_TRS=TRS    counter_id=M51301C1
    ...    counter_full_path=TNL-1/ETHLK/ETHLK-1/ETHLK_stats/EthLinkInOctets
    ${M51301C1_value}    convert to integer     ${M51301C1_value}
    should be true    ${M51301C1_value} >0
    ${M51301C2_value}    Get counter latest value    BTS_or_TRS=TRS    counter_id=M51301C2
    ...    counter_full_path=TNL-1/ETHLK/ETHLK-1/ETHLK_stats/EthLinkIfOutFrames
    ${M51301C2_value}    convert to integer     ${M51301C2_value}
    Should Be True    ${M51301C2_value} >0
    ${M51301C3_value}    Get counter latest value    BTS_or_TRS=TRS    counter_id=M51301C3
    ...    counter_full_path=TNL-1/ETHLK/ETHLK-1/ETHLK_stats/EthLinkOutOctets
    ${M51301C3_value}    convert to integer     ${M51301C3_value}
    should be true    ${M51301C3_value} >0

Check M40002 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
	${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${M40002C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
    ${M40002C0_value}    convert to integer     ${M40002C0_value}
    Should Be True    ${M40002C0_value} >0
    ${M40002C1_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C1
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_RF
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C1
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_RF
    ${M40002C1_value}    convert to integer     ${M40002C1_value}
    should be true    ${M40002C1_value} >0
    ${M40002C2_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C2
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_BTS
	...    ELSE   Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C2
	...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_BTS
    ${M40002C2_value}    convert to integer     ${M40002C2_value}
    Should Be True    ${M40002C2_value} >0
    ${M40002C2_value_temp}  Evaluate  ${M40002C0_value}+${M40002C1_value}
    ${p_value}    Evaluate    "%.4f" % ((${M40002C2_value_temp}-${M40002C2_value})/${M40002C2_value_temp})
    should be true      ${p_value} < 0.03

Check M40003 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${M40003C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
    ${M40003C0_value}    convert to integer     ${M40003C0_value}
    Should Be True    ${M40003C0_value} >0
    ${M40003C1_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C1
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/MAX_INPUT_VOLTAGE_IN_RF
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C1
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/MAX_INPUT_VOLTAGE_IN_RF
    ${M40003C1_value}    convert to integer     ${M40003C1_value}
    should be true    ${M40003C1_value} >0
    ${M40003C2_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C2
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C2
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
    ${M40003C2_value}    convert to integer     ${M40003C2_value}
    Should Be True    ${M40003C2_value} >0
    ${M40003C3_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C3
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_MIN_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C3
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_MIN_PWR_USAGE
    ${M40003C3_value}    convert to integer     ${M40003C3_value}
    should be true    ${M40003C3_value} >0
    ${M40003C4_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C4
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_AVG_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C4
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_AVG_PWR_USAGE
    ${M40003C4_value}    convert to integer     ${M40003C4_value}
    Should Be True    ${M40003C4_value} >0
    ${M40003C5_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C5
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_MAX_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C5
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_MAX_PWR_USAGE
    ${M40003C5_value}    convert to integer     ${M40003C5_value}
    Should Be True    ${M40003C5_value} >0

Check M40004 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
	${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${M40004C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
    ${M40004C0_value}    convert to integer     ${M40004C0_value}
    Should Be True    ${M40004C0_value} >0
    ${M40004C1_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C1
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_MIN_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C1
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_MIN_PWR_USAGE
    ${M40004C1_value}    convert to integer     ${M40004C1_value}
    should be true    ${M40004C1_value} >0
    ${M40004C2_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C2
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_AVG_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C2
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_AVG_PWR_USAGE
    ${M40004C2_value}    convert to integer     ${M40004C2_value}
    Should Be True    ${M40004C2_value} >0
    ${M40004C3_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C3
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_MAX_PWR_USAGE
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C3
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_MAX_PWR_USAGE
    ${M40004C3_value}    convert to integer     ${M40004C3_value}
    should be true    ${M40004C3_value} >0
    ${M40004C4_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C4
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_SM
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C4
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_SM
    ${M40004C4_value}    convert to integer     ${M40004C4_value}
    Should Be True    ${M40004C4_value} >0
    ${M40004C5_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C5
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/MAX_INPUT_VOLTAGE_IN_SM
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C5
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/MAX_INPUT_VOLTAGE_IN_SM
    ${M40004C5_value}    convert to integer     ${M40004C5_value}
    Should Be True    ${M40004C5_value} >0

Check M4000X Counter internal relationship
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${M40002C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
    ${M40002C0_value}    convert to integer     ${M40002C0_value}
    ${M40004C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
    ${M40004C0_value}    convert to integer     ${M40004C0_value}
    ${p_value}    Evaluate    "%.4f" % ((${M40004C0_value}-${M40002C0_value})/${M40004C0_value})
    should be true      ${p_value} < 0.03
    ${M40002C1_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C1
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_RF
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C1
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_RF
    ${M40002C1_value}    convert to integer     ${M40002C1_value}
    ${M40003C2_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C2
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C2
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
    ${M40003C2_value}    convert to integer     ${M40003C2_value}
    ${p_value2}    Evaluate    "%.4f" % ((${M40003C2_value}-${M40002C1_value})/${M40003C2_value})
    should be true      ${p_value2} < 0.03
    ${M40002C2_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C2
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_BTS
	...    ELSE   Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C2
	...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_BTS
    ${M40002C2_value}    convert to integer     ${M40002C2_value}
    ${p_value3}    Evaluate    "%.4f" % ((${M40002C2_value}-${M40002C0_value}-${M40002C1_value})/${M40002C2_value})
    should be true      ${p_value3} < 0.03

Check M40002 Counter Not Work
    [Arguments]    ${sleep_time}=10
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
    ${M40002C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
    ${M40002C0_value}    convert to integer     ${M40002C0_value}
    sleep  ${sleep_time}
    ${M40002C0_value1}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40002C0
    ...    counter_full_path=MRBTS-${mrbtsID}/SBTS_Energy_Consumption/ENERGY_CONSUMPTION_IN_SM
	${M40002C0_value1}    convert to integer     ${M40002C0_value1}
    Should Be Equal As Integers   ${M40002C0_value}   ${M40002C0_value1}

Check M40003 Counter Not Work
    [Arguments]    ${sleep_time}=10
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
	${M40003C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
    ${M40003C0_value}    convert to integer     ${M40003C0_value}
    sleep  ${sleep_time}
    ${M40003C0_value1}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
    ...    counter_full_path=BTS/MRBTS-${mrbtsID}/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
	...    ELSE  Get counter latest value    BTS_or_TRS=BTS    counter_id=M40003C0
	...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
    ${M40003C0_value1}    convert to integer     ${M40003C0_value1}
    Should Be Equal As Integers   ${M40003C0_value}   ${M40003C0_value1}

Check M40004 Counter Not Work
    [Arguments]    ${sleep_time}=10
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
	${M40004C0_value}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
    ${M40004C0_value}    convert to integer     ${M40004C0_value}
    sleep  ${sleep_time}
    ${M40004C0_value1}    Run keyword If  ${status}
	...    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
	...    ELSE    Get counter latest value    BTS_or_TRS=BTS    counter_id=M40004C0
    ...    counter_full_path=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SBTS_SM_Energy_Monitoring/SM_ENERGY_CONSUMPTION
    ${M40004C0_value1}    convert to integer     ${M40004C0_value1}
    Should Be Equal As Integers   ${M40004C0_value}   ${M40004C0_value1}

Check M55318 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${change_interval}
    connect to common unit master
    sleep  30
    ${counter_list}    create list    C00002    C00004    C00006    C00008    C00010    C00012
    ${status}    set variable    ${False}
    FOR    ${counter_id}    IN    @{counter_list}
        ${M55318C0000x_value}    Get PM Counter via Webem    counter_id=M55318${counter_id}    interval=${change_interval}
        ${M55318C0000x_value}    convert to integer     ${M55318C0000x_value}
        ${sign}    set variable if    '${counter_id}'=='C00002' or '${counter_id}'=='C00004'    >    ==
        Should Be True    ${M55318C0000x_value} ${sign} 0
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

Check M5140 Counter
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${change_interval}
    connect to common unit master
    sleep  30
    ${M51400C0_value}    Get PM Counter via Webem    counter_id=M51400C0    interval=${change_interval}    counter_type=Transport
    ${M51400C0_value}    convert to integer     ${M51400C0_value}
    Should Be True    ${M51400C0_value} >0
    ${M51400C2_value}    Get PM Counter via Webem    counter_id=M51400C2    interval=${change_interval}    counter_type=Transport
    ${M51400C2_value}    convert to integer     ${M51400C2_value}
    Should Be True    ${M51400C2_value} >0
    [Teardown]  csn.Disconnect  connection=ASIK Master

Sync data is verified after make call
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${change_interval}
    ${interval_seconds}    Get Interval Seconds    ${change_interval}
    ${sum_number}    evaluate    ${interval_seconds}*10
    ${sum_number_min}    evaluate    ${sum_number}-2
    ${sum_number_max}    evaluate    ${sum_number}+2
    ${Number_of_UEs_per_beam_01}    Get PM Counter via Webem    counter_id=M55305C12001    interval=${change_interval}
    ${Number_of_UEs_per_beam_01}    convert to integer     ${Number_of_UEs_per_beam_01}
    should be true      ${sum_number_min} < ${Number_of_UEs_per_beam_01} < ${sum_number_max}
    ${Number_of_UEs_per_beam_02}    Get PM Counter via Webem    counter_id=M55305C12002    interval=${change_interval}
    ${Number_of_UEs_per_beam_02}    convert to integer     ${Number_of_UEs_per_beam_02}
    should be true      ${sum_number_min} < ${Number_of_UEs_per_beam_02} < ${sum_number_max}

Get real time power measurements via Webem
    [Arguments]    ${object_names}    ${interval}    ${measured_object}=${None}
    ${content}    selenium_coam.get_real_time_measurements    object_names=${object_names}
    ...  measured_object=${measured_object}
    ${value_list}    get dictionary values    ${content}
    ${time_list}    get dictionary keys   ${value_list[0]}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    # WESTLAKE-11139 Fixed the time of BBMOD slow than WEBUI measurement.
    ${power_measurement_last_time}    Catenate	SEPARATOR=:    ${last_time}    00
    ${current_bbmod_time}   Get time from bbmod
    ${diff_time}    robot.libraries.DateTime.subtract_date_from_date    ${current_bbmod_time}    ${power_measurement_last_time}
    ${current_time}    Set Variable If    ${diff_time} > 0    ${current_bbmod_time}    ${power_measurement_last_time}
    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<=0
    ${wait_time}    evaluate  ${diff1} + 60
    ${power_voltage}    get_from_dictionary   ${value_list[0]}    ${last_time}
    ${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Power}    ${wait_time}

check the real time power value
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${object_names}    ${interval}    ${sample_size}=${10}    ${measured_object}=${None}
    ${power_list}    create list
    FOR    ${index}    IN RANGE    0    ${sample_size}
	    ${Power}    ${wait_time}    Get real time power measurements via Webem    object_names=${object_names}
        ...  measured_object=${measured_object}
	    ...    interval=${interval}
	    append to list    ${power_list}    ${Power}
	    exit for loop if   ${index} == ${sample_size}-1
	    sleep    ${wait_time}
	    sleep    10
	END
	${power_list}    Remove Duplicates    ${power_list}
    ${power_num}    get length    ${power_list}
    Should be True    ${power_num} > 1

Check M55601 Counter internal relationship
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]    ${cell_id}=${1}
    log to console  \n check:Sum([DENOM_CELL_AVAIL] = Sum([SAMPLES_CELL_AVAIL]) + [NR_CELL_PLAN_UNAVAIL_SAMPLES] + [NR_CELL_UNPLAN_UNAVAIL_SAMPLES])
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
	${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
	${counter_full_path}    set variable if    ${status}    CELLS/NRCELL-${cell_id}/NCAV/DENOM_CELL_AVAIL
	...    MRBTS-${mrbtsID}/NRBTS-${mrbtsID}/NRCELL-${cell_id}/NCAV/DENOM_CELL_AVAIL
    ${denom_cell_avail_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00001
    ...    counter_full_path=${counter_full_path}
    ${denom_cell_avail_value}    convert to integer     ${denom_cell_avail_value}
    ${samples_cell_avail_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C00002
    ...    counter_full_path=${counter_full_path}    counters_info=${counters_info}
    ${samples_cell_avail_value}    convert to integer     ${samples_cell_avail_value}
    ${counter_full_path}    set variable if    ${status}    CELLS/NRCELL-${cell_id}/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
	...    MRBTS-${mrbtsID}/NRBTS-${mrbtsID}/NRCELL-${cell_id}/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
    ${nr_cell_plan_unavail_samples_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01001
    ...    counter_full_path=${counter_full_path}    counters_info=${counters_info}
    ${nr_cell_plan_unavail_samples_value}    convert to integer     ${nr_cell_plan_unavail_samples_value}
    ${counter_full_path}    set variable if    ${status}    CELLS/NRCELL-${cell_id}/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLES
	...    MRBTS-${mrbtsID}/NRBTS-${mrbtsID}/NRCELL-${cell_id}/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLES
    ${nr_cell_unplan_unavail_samples_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55601C01003
    ...    counter_full_path=${counter_full_path}    counters_info=${counters_info}
    ${nr_cell_unplan_unavail_samples_value}    convert to integer     ${nr_cell_unplan_unavail_samples_value}
    ${samples_value}    evaluate  ${samples_cell_avail_value} + ${nr_cell_plan_unavail_samples_value} + ${nr_cell_unplan_unavail_samples_value}
    Should Be Equal As Integers   ${denom_cell_avail_value}   ${samples_value}

Get the real time power value
    [Documentation]  Author: kaihui.fan@nokia-sbell.com
    [Arguments]    ${object_names}    ${interval}    ${sample_size}=${10}    ${measured_object}=${None}
    ${power_list}    create list
    ${power_total}   Set Variable  ${0}
    ${power_avg}   Set Variable  ${0}
    FOR    ${index}    IN RANGE    0    ${sample_size}
	    ${Power}    ${wait_time}    Get real time power measurements via Webem    object_names=${object_names}
        ...  measured_object=${measured_object}
	    ...    interval=${interval}
	    ${power_total}=   evaluate  ${Power} + ${power_total}
#	    append to list    ${power_list}    ${Power}
	    exit for loop if   ${index} == ${sample_size}-1
	    sleep    ${wait_time}
	    sleep    10
	END
	${power_avg}    evaluate  ${power_total}/${sample_size}
	log   \npower_average = ${power_avg}     console=yes
	[Return]    ${power_avg}

