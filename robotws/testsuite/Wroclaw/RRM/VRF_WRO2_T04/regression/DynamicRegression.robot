*** Settings ***
Documentation
...   dyn regression_keywords

Resource        ../DynamicRegression/dynamic_regression.robot
Resource        ./regression_keywords.robot
Library        ./python_functions.py
Library        ../../VRF_WRO2_T07/resources/testline_preparation.py

Suite Setup     Set Global Variables



#Test Setup      Run Keywords
#...    Set TESTNAME without spaces
#...    BTSLOG Start btslog on local machine
#...    Change Configuration If Needed
#...    Check onAir BTS status



#Test Teardown   Run Keywords
#...    Clear cache
#...    Common step trigger
#...    BTSLOG Collect btslog
#...    Make snapshot in case of error

Test Timeout    40 minutes


*** Test Cases ***
#AHFIB_5MHz
#    AHFIB_5MHz
#
#AHFIB_10MHz
#    AHFIB_10MHz
#
#AHFIB_15MHz
#    AHFIB_15MHz
#
#AHFIB_20MHz
#    AHFIB_20MHz

#AHLOA_5MHz
#    AHLOA_5MHz
#
#AHLOA_10MHz
#    AHLOA_10MHz
#
#AHLOA_15MHz
#    AHLOA_15MHz
#
#AHLOA_20MHz
#    AHLOA_20MHz

#AHLOA_10MHz_2
#    AHLOA_10MHz
#
#AHLOA_5MHz_2
#    AHLOA_5MHz
#
#AHLOA_15MHz_2
#    AHLOA_15MHz
#
#AHLOA_5MHz_3
#    AHLOA_5MHz
#
#AHLOA_20MHz_2
#    AHLOA_20MHz
#
#AHLOA_15MHz_3
#    AHLOA_15MHz
#
#AHLOA_10MHz_3
#    AHLOA_10MHz

#AEHC_40MHz
#    AEHC_40MHz
#
AEHC_50MHz
    AEHC_50MHz
#
AEHC_60MHz
    AEHC_60MHz

AEHC_80MHz
    AEHC_80MHz
#
#AEHC_100MHz
#    AEHC_100MHz
