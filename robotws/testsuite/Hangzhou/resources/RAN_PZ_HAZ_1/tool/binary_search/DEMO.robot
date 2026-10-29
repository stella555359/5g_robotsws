*** Settings ***
Documentation    Suite description
...    Author:        xingxin.lou@nokia-sbell.com
...    Maintainer:    Lou Xingxin

#Resource    ../../resources/common_setup.robot
#Resource    ../../resources/test_fv.robot
Resource      /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/tool/binary_search/binary_search_keyword.robot

#Force Tags    CLOUD_5G_CLASSICAL_SA_ASOE_AZNA_AZHA_3xAZHL    CA_RAN_PZ_HAZ_1    SBTS00    RAN_4G    RAN_4G_TDD    CRT
#
#Suite Setup       Suite Precondition
#Suite Teardown    Suite Postcondition

*** Variables ***
${pass_build}       SBTS00_ENB_9999_230401_000001
${fail_build}    	SBTS00_ENB_9999_230405_000001
${package_type}    Normal     #T1/T2/CMCC/E/Normal
${package_variant}   A54
*** Test Cases ***
Test Case
    [Setup]    Precondition
    Binary Search   Your_Case    arg1=${arg1}    arg2=${arg2}   ......   #argument shoule be named.
    [Teardown]     Postcondition






