*** Settings ***
Force Tags    PY27
Documentation
...    author:      Alain Brethereau
...    contact:     alain.brethereau@nokia.com
...    Description: for test keyword


Library     ../python/kw_commissioning_swconfig.py


*** Test Cases ***
Test Commisionning
     Commissioning Classical and Copy SWConfig file     with_on_air_test=True     with_alarm_23=True

