*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library     ${CURDIR}${/}suite_run.py

*** Keywords ***

Run Suite '${suite}'
    Run Suite   ${suite}
