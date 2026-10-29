*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: test robot keywords
...    Command: robot -L TRACE --outputdir /home/ute/logs/test_emssim
...             -V /home/ute/testline_configuration_5G/Nanjing/7_21_CLOUD006TL006
...             testsuite/OAM/Nanjing/Resources/robot/_test/DevNJ_emssim_test.robot

Resource    ../DevNJ_emssim.robot

*** Variables ***
${bts_id}       1
${mplane_ip}    172.31.1.57

*** Test Cases ***
Test Prepare EMSSim Setup With Default Parameters
    Prepare ASiR EMSSim Setup

Test Prepare EMSSim Setup With User Parameters
    Prepare ASiR EMSSim Setup    bts_id=${bts_id}    mplane_ip=${mplane_ip}
