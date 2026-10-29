*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  CB006733_9059intActA4measCASCellAdditionDuringICS

Resource   ../5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC002640/resources/keywords_mtk.robot
Resource        ../regression/regression_keywords.robot
Library    ../5GC001167/resources/pcap_verifiers.py
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME   python_1167
Library    ute_ue
#Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/resources/keywords.robot
Resource   ./resources/keywords.robot
#Suite Setup     ute_ue.Require Ue  UE_5  capabilities=Mediatek


*** Keywords ***
TC12_CB006733_9059intActA4measCASCellAdditionDuringICS
    Update Parameter   qRxLevMin    -22    MRBTS-55131/NRBTS-55131/NRCELL-211
    Update Parameter   qRxLevMin    -60    MRBTS-55131/NRBTS-55131/NRCELL-212
    ute_ue.Require Ue   UE_5    UE_5
    counters.Wait For Pm Counters Interval    offset=0
    6733 4CC Attach
    6733 counters
    Detach Ue  UE_5
    counters.Wait For Pm Counters Interval    offset=0
    Set cellAggrLevel    cellAggrLevel    Not FR1 CA eligible
    6733 4CC Attach
    Run Keyword And Continue On Failure    Verify Counter Value    M55139C01501    0    212
    Run Keyword And Continue On Failure    Verify Counter Value    M55139C01502    0    212
    Detach Ue  UE_5
    counters.Wait For Pm Counters Interval    offset=0
    Set cellAggrLevel    cellAggrLevel    FR1 CA incompatible
    6733 4CC Attach
    Run Keyword And Continue On Failure    Verify Counter Value    M55139C01501    0    212
    Run Keyword And Continue On Failure    Verify Counter Value    M55139C01502    0    212
    Set cellAggrLevel    cellAggrLevel    FR1 CA eligible
    Update Parameter   qRxLevMin    -22    MRBTS-55131/NRBTS-55131/NRCELL-212
    Update Parameter   qRxLevMin    -60    MRBTS-55131/NRBTS-55131/NRCELL-211
    [Teardown]        Run Keywords    CellAggr Teardown   AND
    ...    ute_ue.Detach Ue  UE_5
