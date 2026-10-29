*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot

*** Variables ***

*** Keywords ***
ALD-related_faults_cancellation_and_delta_commissioning_when_radio_is_in_deepsleep
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify if ALD delta commissioning plan activation is successful
    ...    when radio is in deep sleep energy saving mode.BTS cancels fault 4282: EFaultId_ConfigurationAndHardwareMismatchAl
    ...    related to ALD (RET) after entering deep sleep energy saving mode.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.12.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${new_value}=5    ${new_out_value}=78    ${ru_index}=1
    Selenium Login And Disable Screen Lock
    ${default_value}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RETU-1
    ...    filter_param=Antenna operating frequency band
    log to console  \n default value of antFreqBand:${default_value}
    NR update power saving mode via webem    energySavingMode=DEEPSLEEP    actNrLBPowerSaving=true    ru_index=${ru_index}
    Wait until keyword succeeds    15min    30s    All Cells should be Energy Saving State    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=SLEEP
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RETU-1
    ...    filter_param=Antenna operating frequency band    abbr=antFreqBand    new_value=${new_value}
    Wait until keyword succeeds    5min    5s     RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=SLEEP
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=NORMAL
    Wait until keyword succeeds    5min    5s    RU Status Info Should Be as Expect
    ...    operationalState=disabled    availabilityStatus=off line
    Wait until keyword succeeds    5min    5s    RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=AWAKE
    Wait until keyword succeeds    3min    5s    All Cells should be Energy Saving State    ru_index=${ru_index}
    ${currect_value}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RETU-1
    ...    filter_param=Antenna operating frequency band
    Should Be Equal As Strings   '${currect_value}'    '${new_value}'
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RETU-1
    ...    filter_param=Antenna operating frequency band    abbr=antFreqBand    new_value=${new_out_value}
    log to console    \n Check Fault 4282 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4282
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    Wait until keyword succeeds    15min    30s    All Cells should be Energy Saving State    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    RU Status Info Should Be as Expect
    ...    usageState=Idle    powerState=SLEEP
    log to console    \n Check Fault 4282 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4282
    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    [Teardown]  Selenium Logout And Close Browser

All Cells should be Energy Saving State
    [Arguments]  ${ru_index}=1
    ${cell_list}    get all cell id    ru_index=${ru_index}
    FOR    ${cell_id}    IN    @{cell_list}
        Cell Status Info Should Be Energy Saving State    cell_index=${cell_id}
    END
