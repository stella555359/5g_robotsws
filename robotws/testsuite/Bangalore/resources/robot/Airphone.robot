*** Settings ***

Documentation     [SUITE PURPOSE]  Common Keyword for Airphone side updates
...             author   : Sowrabha.S.M
...             contact  : sowrabha.s_m@nokia.com
...             Creation Date             : 14/09/2021
...             Modified Date             : 14/09/2021

Library         BuiltIn
Library         DateTime
Library         OperatingSystem


Resource        ../NPS/SWENG/robot/WtsXmlConfig.robot

*** Keywords ***
Update GSCN in AP Iphy Xml
    [Arguments]    ${gscn}
    WtsXmlConfig.startSession           file=iphy
    WtsXmlConfig.setListEltText         //GSCN                          ${gscn}
    WtsXmlConfig.stopSession            file=iphy
