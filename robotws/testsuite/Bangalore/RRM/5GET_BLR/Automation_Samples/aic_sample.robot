*** Settings ***
Resource        ../resources/NPS/SWENG/robot/Connect.robot
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer       WITH NAME       analyze
Resource      ../resources/robot/common_log_collection.robot
Library     OperatingSystem
Suite Setup     Initiate Dcap
*** Variables ***
${log_path}    /home/ute/dcaplogs/
${TS1}          stop1
${TS2}          stop2


@{Component1}   L2PS   L2LO     L2HIRLC
@{Component2}   L2HIPDCP


*** Test Cases ***
Test
    [Setup]    DCAP Connect To gNB
    BuiltIn.Log    without cell argument
    Start Log Via DCAP  vducontrolplane
    sleep    10s
    Stop Log Via DCAP  vducontrolplane  test_scenario=vducontrol

    Start Log Via DCAP  vcucelltrace
    sleep    10s
    Stop Log Via DCAP  vcucelltrace  test_scenario=vcucelltrace

    Start Log Via DCAP  vducelltrace
    sleep    10s
    Stop Log Via DCAP  vducelltrace  test_scenario=vducelltrace

    Start Log Via DCAP  ttitrace    component=${Component1}
    sleep    5s
    Stop Log Via DCAP  ttitrace  test_scenario=ttitracevdu
    Stop Log Via DCAP  snapshot   test_scenario=snap1st

    BuiltIn.Log    with cell argument
    ${Nrcell}   Create List   NRCELL_1
    Start Log Via DCAP  vducontrolplane    CellId=${Nrcell}
    sleep    10s
    Stop Log Via DCAP  vducontrolplane  test_scenario=vducontrol

    Start Log Via DCAP  vcucelltrace    CellId=${Nrcell}
    sleep    10s
    Stop Log Via DCAP  vcucelltrace  test_scenario=vcucelltrace

    Start Log Via DCAP  vducelltrace    CellId=${Nrcell}
    sleep    10s
    Stop Log Via DCAP  vducelltrace  test_scenario=vducelltrace

    Start Log Via DCAP  ttitrace    component=${Component1}    CellId=${Nrcell}
    sleep    5s
    Stop Log Via DCAP  ttitrace  test_scenario=ttitracevdu
    Stop Log Via DCAP  snapshot   CellId=${Nrcell}    test_scenario=snap1st
    [Teardown]     DCAP Disconnect To gNB
