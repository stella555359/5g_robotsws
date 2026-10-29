*** Settings ***
Documentation    Keywords for CB008055-CR

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/cloud/CB008055/resources/keywords.py    WITH NAME    kw

*** Keywords ***

Verify messages for CB008055-CR
    # 145899772 - 008B240FC0 PCI 252
    # 145900181 - 008B242950 PCI 661
    # 145900182 - 008B242960 PCI 662
    # 145900231 - 008B242C70 PCI 711
    # 145900234 - 008B242CA0 PCI 714
    [Arguments]  ${directory_path}=${None}
    kw.count in all json files  directory_path=${directory_path}  target_identity=008B240FC0  counter=1
    kw.count in all json files  directory_path=${directory_path}  target_identity=008B242950  counter=1
    kw.count in all json files  directory_path=${directory_path}  target_identity=008B242960  counter=1
    kw.count in all json files  directory_path=${directory_path}  target_identity=008B242C70  counter=1
    kw.count in all json files  directory_path=${directory_path}  target_identity=008B242CA0  counter=1

Verify Measurement Report for A2 SCell Release
    [Arguments]  ${directory_path}=${None}
    kw.count measurement reports  directory_path=${directory_path}

Verify DUtoCURRCInformation
    [Arguments]  ${directory_path}=${None}
    kw.check DUtoCURRCInformation  directory_path=${directory_path}