*** Settings ***

Documentation
...  author:  Krzysztof Michalski, Jakub Bąk, Szymon Mastalski
...  contact: jakub.1.bak@nokia.com, krzysztof.michalski@nokia.com, szymon@mastalski@nokia.com

Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


*** Keywords ***


Small Cell Test Setup
    [Arguments]    ${scf_prefix_tag}
    [Documentation]    Perform gNB and asir commissioning. Prepare UE for testing and make commone preconditions.
    ...                :param scf_prefix_tag:    prefix tag of scf file in testline configuration folder.
    Log Action To Console    Perform gNB Commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=${scf_prefix_tag}
    Log Action To Console    Perform ASiR Commissioning
    Perform Full Commissioning on GNB ASIR hub    prefix_tag=${scf_prefix_tag}
    Wait Until Keyword Succeeds    12min    15s    Verify Setup Of All Cells    gnb_id=0    du_id=0
    Log Action To Console    Common Test Setup
    Common Preconditions
    ue.Require Ue    UE_1  capabilities=REAL_UE
