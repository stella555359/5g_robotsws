*** Settings ***
Documentation
...    Author: Cristina Nicolae, Andreea Fiterau, Andora Carja, Cristian Dragoescu
...    Maintainer: Cristina Nicolae (cristina.nicolae@nokia.com), Andreea Fiterau (andreea.fiterau@nokia.com),
...                Andora Carja (andora.carja@nokia.com), Cristian Dragoescu (cristian.dragoescu@nokia.com)
...    Group in charge: VERIF_TIM_3_ET_GMS
...    References: DOORS
...    Feature Description: CB007120-A
...    Sample execution: robot -L TRACE -b debug.log -d results/7120-A general.robot

Resource   ./resources/7120-A.robot
Resource   ./resources/7120-A_xpath.robot

Test Setup    Login vDU
Test Teardown    Logout

*** Test Cases ***

[1][1.0] 1.Check if gNB-vDU enters in Test Dedicated State(TDS) via delta commissioning
    OnAir
    Config
    CreatePlan
    DeleteSWRESETREQ-
    CreateNewSWRESETREQ
    SelectValue
    Validate
    Activate
    TDS
    Status
    Reset
