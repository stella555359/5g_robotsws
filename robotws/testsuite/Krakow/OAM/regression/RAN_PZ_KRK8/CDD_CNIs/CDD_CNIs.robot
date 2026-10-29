*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Test cases for CDD features: CNI-105082, CNI-103190, CNI-103193 and CNI-115365


Resource    resources/CDD_CNIs_Keywords.robot

Test Timeout  11 hours 55 minutes

Force Tags    RF50

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown


*** Test Cases ***
CNI-103193_L3_call_with_Nokia_CDD2_using_B66_10MHz
    Get all needed params values
    Reboot UE    ${ue_alias1}
    Set Test Variable    ${dl_throughput}           98 Mbits/sec
    Set Test Variable    ${dl_deviation}            10%
    Set Test Variable    ${ul_throughput}           38 Mbits/sec
    Set Test Variable    ${ul_deviation}            20%

    L3 Call DL and UL    ue_alias=${ue_alias1}    cap=${capabilities1}    earfcn=${earfcn_PCI_98_B66}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}

CNI-97351_L3_call_with_Nokia_CDD_using_FR1_2C-2T2R_70MHz_n41
    [Setup]    Test Setup with configs loading    file_name=${cdd_file_path}/${cdd_configs_list}[1]
               ...                                prefix_tag=${scf_prefix_tags}[1]
    Get all needed params values
    Reboot UE    ${ue_alias1}
    Set Test Variable    ${dl_throughput}           555 Mbits/sec
    Set Test Variable    ${dl_deviation}            10%
    Set Test Variable    ${ul_throughput}           151 Mbits/sec
    Set Test Variable    ${ul_deviation}            35%

    L3 Call DL and UL    ue_alias=${ue_alias1}    cap=${capabilities1}    earfcn=${arfcnSsbPbch_PCI_809_n41}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}
    Set Test Variable    ${ul_deviation}            15%
    L3 Call DL and UL    ue_alias=${ue_alias1}    cap=${capabilities1}    earfcn=${arfcnSsbPbch_PCI_810_n41}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}    prepareUE=${False}

CNI-115365_L3_call_with_Nokia_CDD2_using_FR1_1C-2T2R_40MHz_n77_ATT
    [Setup]    Test Setup with configs loading    file_name=${cdd_file_path}/${cdd_configs_list}[2]
               ...                                prefix_tag=${scf_prefix_tags}[2]
    Get all needed params values
    Reboot UE    ${ue_alias2}
    Set Test Variable    ${dl_throughput}           339 Mbits/sec
    Set Test Variable    ${dl_deviation}            10%
    Set Test Variable    ${ul_throughput}           74 Mbits/sec
    Set Test Variable    ${ul_deviation}            10%

    L3 Call DL and UL    ue_alias=${ue_alias2}    cap=${capabilities2}    earfcn=${arfcnSsbPbch_PCI_149_n77}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}

CNI-105082_L3_call_with_Nokia_CDD_using_FR1_2C-2T2R_80MHz_n78_3450MHz
    [Setup]    Test Setup with configs loading    file_name=${cdd_file_path}/${cdd_configs_list}[3]
               ...                                prefix_tag=${scf_prefix_tags}[3]    radio_unit_id=10
    Get all needed params values
    Reboot UE    ${ue_alias2}
    Set Test Variable    ${dl_throughput}           627 Mbits/sec
    Set Test Variable    ${dl_deviation}            10%
    Set Test Variable    ${ul_throughput}           161 Mbits/sec
    Set Test Variable    ${ul_deviation}            10%

    L3 Call DL and UL    ue_alias=${ue_alias2}    cap=${capabilities2}    earfcn=${arfcnSsbPbch_PCI_809_n78}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}
    Set Test Variable    ${ul_deviation}            40%
    L3 Call DL and UL    ue_alias=${ue_alias2}    cap=${capabilities2}    earfcn=${arfcnSsbPbch_PCI_810_n78}
    ...                  dl_throughput=${dl_throughput}    dl_deviation=${dl_deviation}
    ...                  ul_throughput=${ul_throughput}    ul_deviation=${ul_deviation}    prepareUE=${False}
