*** Settings ***
Documentation    This file contains examples of the keywords defined in ttitrace.robot

Resource    ./../reporting.robot


*** Test Cases ***


Example 1 with 0.800 in QC File
    Online Reporting to ReP
    ...    tcName=[1]5GC000001_QC_Test_Instance
    ...    tsResult=PASS
    ...    resultDir=/home/ute/test_results/5GC000425-Y/5G_0.800.3303/20210128_235422
    ...    isForDebugging=yes


Example 2 with 5G20B in QC File
    Online Reporting to ReP
    ...    tcName=[1]5GC000002_QC_Test_Instance
    ...    tsResult=passed
    ...    resultDir=/home/ute/test_results/5GC000425-Y/5G20B_10.1800.659/20210128_235422
    ...    isForDebugging=yes


Example 3 with PM Counters
    Online Reporting to ReP
    ...    pmCounters="[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30}, {'piid': 'M55320C00001', 'result': 'Passed', 'value' 30}]"
    ...    tcName=[1]5GC000003_QC_Test_Instance
    ...    tsResult=PASS
    ...    resultDir=/home/ute/test_results/5GC000425-Y/5G_0.800.3303/20210128_235422
    ...    isForDebugging=yes

Example 4 with multiple QC Test Sets
    Online Reporting to ReP
    ...    tcName=[1]5GC000004_QC_Test_Instance_2
    ...    tsResult=passed
    ...    resultDir=/home/ute/test_results/5GC000425-Y/5G20A_9.1800.843/20210128_235422
    ...    isForDebugging=yes

Example 5 with different QC Testlab Paths
    Online Reporting to ReP
    ...    tcName=[1]5GC000005_QC_Test_Instance
    ...    tsResult=PASS
    ...    resultDir=/home/ute/test_results/5GC000425-Y/5G_0.800.3303/20210128_235422
    ...    isForDebugging=yes
    ...    swPostFix=ASIL_Parity
