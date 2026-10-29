*** Settings ***
Suite Setup          CB012760 Common case Suite Setup
Suite Teardown       CB012760 Common case Suite Teardown
Test Setup           CB012760 Common case Test Setup
Test Teardown        CB012760 Common case Test Teardown

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012760/resources/keywords_CB012760.robot

Documentation
...    Author: Yang Di
...    contact: di.yang@nokia-sbell.com
...    squad group: Pz3_05

*** Test Cases ***
CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_100M
    [Tags]    100M
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_90M
    [Tags]    90M
    Perform commissioning CB012760    bSRS=3    cSRS=55    msg1FrequencyStart=3    startCRBOfCoreset0=100
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_80M
    [Tags]    80M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-75    chBw=80MHz    cSRS=49    msg1FrequencyStart=3
    ...    startCRBOfCoreset0=86
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_70M
    [Tags]    70M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-74    chBw=70MHz    csirsPower=2    cSRS=38
    ...    ssPbchBlockPower=2    startCRBOfCoreset0=72
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_60M
    [Tags]    60M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-73    chBw=60MHz    csirsPower=3    cSRS=38
    ...    ssPbchBlockPower=3    startCRBOfCoreset0=58
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_50M
    [Tags]    50M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-72    chBw=50MHz    csirsPower=4    cSRS=32
    ...    ssPbchBlockPower=4    startCRBOfCoreset0=44
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_40M
    [Tags]    40M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-71    chBw=40MHz    csirsPower=4
    ...    srsUePeriodicity=slots160    ssPbchBlockPower=4    startCRBOfCoreset0=30
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_30M
    [Tags]    30M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-78    chBw=30MHz    csirsPower=6
    ...    srsUePeriodicity=slots160    ssPbchBlockPower=6    startCRBOfCoreset0=13
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_20M
    [Tags]    20M
    Perform commissioning CB012760    bwpDN=BWP_PROFILE-70    chBw=20MHz    csirsPower=8    msg1FrequencyStart=7
    ...    srsUePeriodicity=slots160    ssPbchBlockPower=8
    Peak throughput on different bandwidth

CB012760_SR_029_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_10M
    [Tags]    10M
    Perform commissioning CB012760    basicBeamSet=beamSet_2    bwpDN_0=BWP_PROFILE-1007    bwpDN=BWP_PROFILE-69
    ...    chBw=10MHz    csirsPower=11    cSRS=7    dmrsTypeAPosition=pos3    msg1FrequencyStart=6
    ...    numberOfTransmittedSsBlocks=2 beams    srsUePeriodicity=slots320    ssPbchBlockPower=11
    ...    type0CoresetConfigurationIndex=1    type0SearchSpaceConfigurationIndex=4
    Peak throughput on different bandwidth

