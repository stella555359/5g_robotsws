*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.tput_curve.TputCurve    WITH NAME   TPUT_CURVE

Suite Setup   TPUT_CURVE.Suite Setup
Suite Teardown   TPUT_CURVE.Suite Teardown

*** Test Cases ***
Throughput Curve
    [Setup]   TPUT_CURVE.Test Setup
    TPUT_CURVE.Run
    [Teardown]   TPUT_CURVE.Test Teardown
