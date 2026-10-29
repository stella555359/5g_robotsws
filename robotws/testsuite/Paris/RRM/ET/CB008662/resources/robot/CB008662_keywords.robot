*** Settings ***
Documentation     [SUITE PURPOSE]  Generic keywords for CB008662 
...
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 2-August-2022
...               Last Modified Date          : 9-August-2022
...               Last Modified by            : yann.ah.herve@nokia.com
...               Modification:
...                       2-August-2022      |     Creation
...                       9-August-2022      |     Call teardown in case of failure


Library             taf.sbts.oam.coam.admin     WITH NAME       sbts_coam
Library             taf.wts.runner              WITH NAME       wtsemu
Library             ../../../resources/python/luashark_tools.py
Library             ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter

Resource            ../../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../../resources/SWENG/robot/Tools.robot
Resource            ../../../../../resources/SWENG/robot/Capture.robot
Resource            ../../../../../resources/SWENG/robot/SetConfig.robot
Resource            ../../../../../resources/SWENG/robot/Traffic.robot
Resource            ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource            ../../../../../resources/SWENG/robot/Restart.robot
Resource            ../../../../../resources/SWENG/robot/Counters.robot
Resource            ../../../../../resources/SWENG/robot/Oam.robot
Resource            ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource            ../../../../../resources/SWENG/robot/Setup.robot
Resource            ../../../../../resources/SWENG/robot/Scf.robot
Resource            ../../../../../resources/SWENG/robot/Sherpa.robot

Variables           ../../../../../resources/SWENG/python/Colors.py


*** Variables ***
${gnb_alias}                        gnb_under_test

&{counter_DL_RLCdataPDUvolume}      QCI1=M55310C01001
...                                 QCI6=M55310C01006
...                                 QCI9=M55310C01009

${default_cell_bound}               8

*** Keywords ***

####################  Setup/Teardown KWs  ####################
CB008662 Test Setup
    [Documentation]             Perform needed actions at the begining of a test case
    Init Trace color

CB008662 Test Teardown
    [Documentation]             Perform needed actions at the end of a test case
    Dated Log                   Starting Teardown
    Run Keyword If              ${enable_sherpa}==${True}
    ...                         Sherpa.Deactivate Sherpa and Stop Collect

    Restore Files               listFileDesc=${FD_ALL}

    # "Test Teardown" KW from Setup.robot
    Test Teardown

Init Trace color
    ${trcColor}                 Evaluate    "${CYAN}"
    ${defColor}                 Evaluate    "${NORMAL}"
    ${OkColor}                  Evaluate    "${GREEN}"
    Set Suite Variable          ${trcColor}
    Set Suite Variable          ${defColor}
    Set Suite Variable          ${OkColor}
