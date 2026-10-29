*** Settings ***
Documentation
...    [Procedure]             "The test case is planned to Verification of flow control"
...    [Date]                  "07-11-2023"
...    [Author]                "Vinay"
...    [Funtion_Hash_Tags]     "RANSHARING"
...    [Feature_ID]            ""
...    [Validation_status]     "Validated and Passed"
...    [Validated_TestLine]    "2025"
...    [Config]                "NRBTS-1 need to configured with 6 x2clist"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup       Run Keywords    Suite Setup Preconditions
...               AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...               AND    Teardown Oamops

*** Test Cases ***
[1][1.1] CB006540_5G NSA RAN sharing is activated & LTE RAN Sharing is activated simultaneously in SBTS.
    Setup Ems    config_device=netact2005    alias=lab2005
    Cm Upload    config_device=netact2005    alias=lab2005

    ${ran_sharing_moc}=    Configuration Get
    ...    config_device=netact2005
    ...    dist_name=PLMN-PLMN/MRBTS-${bts_id}/NRBTS-${nrbts_id}
    ...    alias=lab2005
    Log    ${ran_sharing_moc['actRanSharing']}
    Should Be Equal    ${ran_sharing_moc['actRanSharing']}    true

    ${amf1_status_dict}=    Configuration Get
    ...    config_device=netact2005
    ...    dist_name=PLMN-PLMN/MRBTS-${bts_id}/NRBTS-${nrbts_id}/SERVEDAMF-${AMF_1_id}
    ...    alias=lab2005
    Convert To Dictionary    ${amf1_status_dict}

    Log    ${amf1_status_dict}
    Log    ${amf1_status_dict['administrativeState']}
    Should Be Equal    ${amf1_status_dict['administrativeState']}    2
    Should Be Equal    ${amf1_status_dict['ngLinkStatus']}    1

    ${amf1_status_dict}=    Configuration Get
    ...    config_device=netact2005
    ...    dist_name=PLMN-PLMN/MRBTS-${bts_id}/NRBTS-${nrbts_id}/SERVEDAMF-${AMF_2_id}
    ...    alias=lab2005
    Convert To Dictionary    ${amf1_status_dict}

    Log    ${amf1_status_dict}
    Log    ${amf1_status_dict['administrativeState']}
    Should Be Equal    ${amf1_status_dict['administrativeState']}    2
    Should Be Equal    ${amf1_status_dict['ngLinkStatus']}    1

    ${keys}=    Get Dictionary Keys    ${amf1_status_dict}
    ${amf_1_list}=    Get Dictionary Values    ${amf1_status_dict}

    Log    ${amf_1_list}[0]
    ${dict}=    Convert To Dictionary    ${amf_1_list}[0]

    Log    ${dict['guAMI']}
    ${lt}=    Get Dictionary Keys    ${dict}

    ${amf1_Status}=    Get From Dictionary
    ...    dictionary=${dict['guAMI']}[0]
    ...    key=guamiStatus
    Should Be Equal    ${amf1_Status}    1

    Make 5g call with traffic

    [Teardown]    Teardown Ems    config_device=netact2005    alias=lab2005

*** Keywords ***
Make 5g call with traffic
    Call Setup    5g=device_1:data    parallel=${False}    verify_attach=${False}

    Call Start    5g=device_1:data
    ...    profile=udp_500M_dl
    ...    iperf_section=device1

    Sleep    100

    Call Stop    5g=device_1:data    profile=udp_500M_dl
    Call Teardown    5g=device_1:data
