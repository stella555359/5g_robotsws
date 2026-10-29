*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: test robot keywords
...    Command: robot -L TRACE --outputdir /home/ute/logs/test_emssim
...             -V /home/ute/testline_configuration/Nanjing/7_21_CLOUD006TL006
...             testsuite/OAM/Nanjing/Resources/robot/_test/DevNJ_ue_test.robot

Resource    ../DevNJ_UE_keywords.robot

*** Test Cases ***
Test Keyword Set UE Variables
    Set UE Variables
