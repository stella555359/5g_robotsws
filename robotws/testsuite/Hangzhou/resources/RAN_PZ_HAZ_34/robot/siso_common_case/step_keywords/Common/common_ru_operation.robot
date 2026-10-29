*** Settings ***
Documentation    This is common keywords for NR/LTE common ru operation related keywords
...              Please do not modify the file without notification to author
...              Author: zhihao.shi
...              Contact: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4

Library    OperatingSystem
Library    String
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot

*** Keywords ***
Perform RU Lock And Unlock
    log to console  \n***Perform RU Lock And Unlock ***
    [Arguments]  ${ru_index}=1
    selenium_coam.lock_ru  ru_index=${ru_index}
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
    Close Start Up View Window    timeout=60
    selenium_coam.unlock_ru  ru_index=${ru_index}
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${ru_index}
