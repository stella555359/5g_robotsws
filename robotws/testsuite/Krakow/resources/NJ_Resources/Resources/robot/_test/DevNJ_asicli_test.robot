*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: test robot keywords

Resource    ../DevNJ_asicli.robot

*** Variables ***
${build_name}    5G20A_9.1800.933
${ENB_BUILD}     5G20A_9.1800.933

*** Test Cases ***
Test Install ASI CLI
    Install ASI CLI    ${build_name}

Test Install ASI CLI For UTE Cloud
    Install ASI CLI For UTE Cloud
