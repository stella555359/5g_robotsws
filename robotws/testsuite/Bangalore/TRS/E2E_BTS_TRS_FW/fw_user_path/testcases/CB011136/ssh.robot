** Settings ***
Documentation
...     [Author]                    "Abeer Banu"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "09:05:2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB011136"
...     [Validated_TestLine]        "KVM_ST_LMP_TL1004"
...     [Procedure]                 "CB011136"
...     [Precondition]              "vDU"
...     [Config]                    "fronthaul firewall"
...     [Function_Hash_Tags]        "Firewall"

Library    Process
Library    DateTime
variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource         ${CURDIR}/../CB011136/resources/common_keywords_CB011136.robot



Suite Setup     Setup Oamops    dut=vdu_1    alias=vdu
Suite Teardown  Teardown Oamops    dut=vdu_1     alias=vdu

*** Test Cases ***

[1]CB011136_Limit_to_the_number_of_simultaneous_SSH_connections_on_the_fronthaul_interface_to_prevent_brute_force_attack
    Setup Remote Access    remote_device=remote_device_1     alias=default
    ${start}=    Get Current Date    result_format=epoch
    ${count}=    Set Variable    0

    FOR    ${i}    IN RANGE    1    20
        ${now}=    Get Current Date    result_format=epoch
        ${elapsed}=    Evaluate    ${now} - ${start}

        ${result}=    Run Process    ${root_login}    shell=True    stdin=${RANNIC_PASSWORD}\n    timeout=10
        ${count}=    Evaluate    ${count} + 1

        Run Keyword If    ${elapsed} > 60    Exit For Loop
    END

    Should Be True    ${count} <= 10    Established more than 10 SSH sessions in 1 minute! (Count=${count}, Time=${elapsed}s)






