*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite CB012510

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012510/resources/DataTransfer_TL088.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Library     taf.rfrl.bts.commissioning
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     taf.ue


Suite Setup     Common Suite Setup With OnAir Test Line Preparation
     ...     swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
     ...     increase_time_for_checking_radios=2100
     ...     increase_timeout_for_update_sw=1800
     ...     list_of_additional_allowed_alarms=@{additional_allowed_alarms}
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${GNB_ID}       ${tl.gnbs[0].global_bts_id}
@{additional_allowed_alarms} =    EN DSS De-activated on partner side
*** Test Cases ***
[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    require UE  UE  capabilities=REAL_UE
    Run TCP Data Transfer For NR Cells Qualcomm     deviation=20%
    Run TCP Data Transfer For LTE Cells Qualcomm    deviation=20%
    FOR     ${iteration}    IN RANGE    3
    General_SiSo_Auto_BTS_Site_Reset
    Sleep    120
    Run TCP Data Transfer For NR Cells Qualcomm    deviation=20%
    Run TCP Data Transfer For LTE Cells Qualcomm   deviation=20%
    END
