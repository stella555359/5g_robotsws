*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: test robot keywords
...    Command: robot -L TRACE -b debug.log --outputdir /home/ute/logs
...             -V config/Nanjing/7_21_UTE5G031TL073 -v CONFIGURATION:Nanjing.7_21_UTE5G031TL073
...             testsuite/OAM/Nanjing/Resources/robot/_test/DevNJ_epcsim_setup_test.robot

Resource    ../DevNJ_epcsim_setup.robot

*** Test Cases ***
Test Setup EPCSim
    Setup EPCSim
