*** Settings ***
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.methods.py
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.keywords.py


*** Keywords ***
Common Suite Setup For Feature CB009025
    keywords.Set Act A1 Ho Pref Nr Layer    actA1HoPrefNRLayer=NSA
