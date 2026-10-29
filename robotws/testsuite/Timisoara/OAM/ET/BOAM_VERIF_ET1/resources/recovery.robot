*** Settings ***

Documentation
...    Author: rafal.janik@nokia.com
...    Maintainer: wojciech.hyski@nokia.com
...    Description: Checking WebEM functionalities, HW visible, commissioning, HW resets, alarms, troubleshooting
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS
...    QC Link: tds://5g.mn_5g.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=44005

Resource    admin.robot
Resource    pretest_posttest.robot
Resource    system.robot
Resource    selenium.robot
Resource    pdu.robot
Library     String

*** Variables ***

*** Test Cases ***
[0]Recovery_Test_Line
    Log
    ...    message=Recovery action started
    ...    console=yes
    ADMIN Setup Admin
    ${onair}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds
    ...    300
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword If    '${onair}' == 'False'
    ...    Run Keywords
    ...    PDU Setup Gnb    AND
    ...    PDU Action
    ...    device=gnb
    ...    action=off    AND
    ...    Wait Until Keyword Succeeds
    ...    600
    ...    10
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${SYSTEM_ENB_LOCAL_IP}    AND
    ...    PDU Action
    ...    device=gnb
    ...    action=on    AND
    ...    Wait Until Keyword Succeeds
    ...    600
    ...    10
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${SYSTEM_ENB_LOCAL_IP}    AND
    ...    ADMIN Setup Admin    AND
    ...    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir    AND
    ADMIN Teardown Admin
    Log
    ...    message=Recovery action finished
    ...    console=yes
