*** Settings ***
Documentation
...   author: Wiktor Jarosinski
...   contact: wiktor.jarosinski@nokia.com
...   Description:   Voice Calls for TOL
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/TOL/voice_calls/voice_calls.resource

*** Test Cases ***
Voice_1_Emergency_Call_ASIB_ABIA_AHLOA
    Emergency Call AHLOA

Voice_2_Emergency_Call_ASIB_ABIA_AHFIB
    Emergency Call AHFIB

Voice_7_VoLTE_Call_ASIB_ABIA_AHLOA
    Voice Call AHLOA

Voice_8_VoLTE_Call_ASIB_ABIA_AHFIB
    Voice Call AHFIB