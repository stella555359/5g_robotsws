*** Settings ***
Documentation
...   Test suite for regression testing of feature LBT27889
...   author:  Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations              WITH NAME    Du
Library         taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations              WITH NAME    Ru
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    Cells
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms
Library         ./resources/AttenuatorManagement.py
Library         ./resources/resources.py
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             list_of_additional_allowed_alarms=${CUSTOM_SETUP_ALARMS}
...             wtd_sfp_wa_support=${True}
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${ATT_access}                ${tl.attenuators[0]}
${DEFAULT_SWCONFIG}          commissionings/Krakow/swconfig/default_swconfig.txt
${BEP_DISABLING_SWCONFIG}    ${CURDIR}/resources/bep_swconfig.txt
${ALARM_UNIT_PATH_ABIO}      [7_7_UTE5GCLOUDT9SK124] MRBTS-80124/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
${ALARM_UNIT_PATH_ABIA}      [7_7_UTE5GCLOUDT9SK124] MRBTS-80124/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-3/LANE-1
@{SFP_ALARMS}                4701   2002
@{ALARMS_ACTIVATION_TIME}    90     480
@{CUSTOM_SETUP_ALARMS}       Receiving failure in Optical Interface
@{CUSTOM_ALLOWED_ALARMS}     Failure in internal BTS connection or connection to 3rd party tool

*** Test Cases ***
[1]LBT27889_WTD_Special_SFP_in_BBMOD-WTD_Special_SFP_in_RMOD-case1
    Setup Attenuator Client       ${ATT_access}
    Du.Verify Cablink Operational State
    Alarms.Allow Alarm            alarm=10
    Du.Lock Sfp Link For Radio Unit       sfp_id=${2}      radio_unit_id=${2}
    Wait After Links Lock
    Cells.Wait For All Cells To Be Onair  timeout=${600}
    Alarms.Disallow Alarm         alarm=10
    Du.Verify Cablink Operational State   cablink_id=${4}  expected_state=disabled
    Alarms.Allow Alarm            ${SFP_ALARMS}
    Set Attenuation               7
    Wait For Alarms Activation    ${SFP_ALARMS}    ${ALARMS_ACTIVATION_TIME}
    Set Attenuation               1
    Wait After Attenuation Change
    Alarms.Disallow Alarm         ${SFP_ALARMS}
    [Teardown]    Run Keywords    Du.Unlock Sfp Link For Radio Unit    sfp_id=${2}    radio_unit_id=${2}
    ...  AND      Common Postconditions With Watching Alarms

[1]LBT27889_WTD_Special_SFP_in_BBMOD-disabling_BEP
    Du.Verify Cablink Operational State
    Alarms.Allow Alarm            alarm=2002
    Du.Upload Swconfig            sw_config_path=${BEP_DISABLING_SWCONFIG}
    Du.Reset BTS
    Wait Until Keyword Succeeds   5min   30s       Ru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds   10min  30s       Run Keywords
    ...           Alarms.Verify Alarm Is Active    fault_name=Receiving failure in Optical Interface
    ...                                            unit_path=${ALARM_UNIT_PATH_ABIO}
    ...  AND      Alarms.Verify Alarm Is Active    fault_name=Receiving failure in Optical Interface
    ...                                            unit_path=${ALARM_UNIT_PATH_ABIA}
    Du.Upload Swconfig            sw_config_path=${DEFAULT_SWCONFIG}
    Du.Reset BTS
    Cells.Wait For All Cells To Be Onair           timeout=${600}
    Alarms.Disallow Alarm         alarm=2002
