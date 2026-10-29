*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_Configuration_Management_RAE_reading_beamforming_weight_factors
    [Documentation]
    ...  :author  linjiangjing
    ...  :param  RAE_units_detail_list: E.G
    ...          [
    ...              {
    ...                  'frequency': 2575-2675,
    ...                  'vertical': 5,
    ...                  'horizontal': 3,
    ...                  'downtilt': 2,
    ...                  'azimuth': -15,
    ...              }
    ...          ]
    [Arguments]    ${RAE_units_detail_list}=${None}    ${ALD_num}=${1}
    COAM Navigate to login page via webUI
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        ${RAE_unit}    set variable    ALD_R-${i} (RAEU_R-${i})
        log to console    ${RAE_unit}
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.get_beam_widths    rae_unit=${RAE_unit}
        ...    frequency=${RAE_units_detail_list[${i}-1]['frequency']}
        Should Be Equal    ${result}    Beamwidth data downloaded
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.get_angles    rae_unit=${RAE_unit}
        ...    vertical=${RAE_units_detail_list[${i}-1]['vertical']}    horizontal=${RAE_units_detail_list[${i}-1]['horizontal']}
        Should Be Equal    ${result}    Angle data downloaded
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.get_weight_factors    rae_unit=${RAE_unit}
        ...    downtilt=${RAE_units_detail_list[${i}-1]['downtilt']}    azimuth=${RAE_units_detail_list[${i}-1]['azimuth']}
        Should Be Equal    ${result[0]}    Weight factor data downloaded
    END
    [Teardown]    selenium_coam.logout
