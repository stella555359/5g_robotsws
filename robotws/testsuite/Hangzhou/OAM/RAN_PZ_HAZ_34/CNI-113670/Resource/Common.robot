*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation

Library     BuiltIn
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem

Library     taf.transport.ssh       WITH NAME    csn
Library     taf.collectors.btslog   WITH NAME    btslog
Library     taf.collectors.core     WITH NAME    core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam

# Library     wft.py

Resource    DFE.robot
Resource    COAM.robot
Resource    SerialPort.robot
# Resource    Download.robot
Resource    LogCollection.robot

Resource    ../../common/taf_coam.robot
# Resource    ../../common/L3_Call.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Variables   ../../libraries/global_vars.py
Variables   Config.py


*** Keyword ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    ${testline_no_AEHC}   Set Variable If   "${RANDOM_AEHC}"=="${None}"   ${True}   ${False}

    Run Keyword If   ${testline_no_AEHC}
    ...   Fail   Please Check RU Info In Testline_Configuration File: (ru_hw_group=="AEHC", serial_number!=None, test_pc_addr!="1.1.1.1")

    COAM Login
    COAM Backup Full SCF
    Get RMOD DN
    Get Cell DN List
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Common Suite Teardown
    Wait Until Keyword Succeeds   10m   1m   COAM Login

    FOR   ${index}   IN RANGE   ${3}
        Log To Console   Reset Site: ${index}
        COAM Reset Site
        Wait Until Keyword Succeeds   10m   1m   COAM Check All Cells Onair
    END

    robot_common_operations.Common Suite Teardown

    [Teardown]   Run Keyword And Ignore Error   COAM Logout
