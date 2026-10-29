*** Settings ***
Documentation
...   author:  Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py


*** Variables ***
@{counters_6CC}    M55118C00004    M55138C03504     M55118C00001    M55138C03507    M55139C03003    M55139C03006


*** Keywords ***
6CC Counters Loop
     &{counters_values}=     Get Scell Add Counter Values    ${counters_6CC}
     FOR    ${index}    IN    @{counters_6CC}
        Run Keyword And Continue On Failure
        ...    Counter Incremented Successfully    ${index}    cell_id=${pcell}    counter_dict=counters_values    operator=>=
     END
