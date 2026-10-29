*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB007332
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_120db}              ${120}
${PA_NormalValue}        ${1}
${PA_CA}                 ${25}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB007333_02_Automatic X2 setup for existing enbControlled LNADJGNB with IP address retrieval of gNB via S1 interface
    [Documentation]    Author:Chen jiahao
    [Tags]    SCF_10_5_UTESRAN001T2298_CB007333_case02
    Start Multi Bts Log
    Reconnect To FCT
    Start tcpdump by command For Remote
    Start tcpdump by command For Remote    ${2}
    activate lnadjgnb unlocked
    sleep   350s
    Stop tcpdump And download by command For Remote    ${2}
    Stop tcpdump And download by command For Remote    ${0}
    sleep    10s
    ${capture_file_path_target}    Download wireshark log to testvm For Remote    ${2}
    Check SON TRS In Wireshark Log    ${capture_file_path_target}
    ${capture_file_path_source}    Download wireshark log to testvm For Remote    ${0}
    Check gNB IP fill In Wireshark Log    ${capture_file_path_source}

CB007333_03_Automatic removal of LNADJGNB when last NR neighbor is removed
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007333_case03
    Start Multi BTS Log
    Reconnect To FCT
    Start tcpdump by command For Remote    ${0}
    CB007334 LNRELGNBCELL Delete
    sleep  5s
    Stop tcpdump And download by command For Remote    ${0}
    ${capture_file_path_source}    Download wireshark log to testvm For Remote    ${0}
    Check X2 reset In Wireshark Log    ${capture_file_path_source}
    Check LNADJGNB0 AND LNADJGNB1 Not Exist

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Reconnect To FCT
    Connect To One Site FCT    bts_index=${0}
    Connect To One Site FCT    bts_index=${2}
Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    # Run Keyword And Ignore Error    Stop All Bts Log
    # Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Stop tcpdump And download by command For Remote
    # ...    ${0}
    # Run Keyword And Ignore Error    Stop tcpdump And download by command For Remote
    # ...    ${3}
    # # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    # Run Keyword And Ignore Error    Disconnect All VM

# Stop All Bts Log
#     Stop All BTSLog And Download to Local

CB007334 LNRELGNBCELL Delete
    @{parameter_list}    Create List
    coam.perform_object_recommissioning    dist_name=MRBTS-2298/LNBTS-2298/LNCEL-0/LNRELGNBCELL-0
    ...                                    parameter=${parameter_list}
    ...                                    operation=delete
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=COAM_0
    coam.perform_object_recommissioning    dist_name=MRBTS-2298/LNBTS-2298/LNCEL-0/LNRELGNBCELL-1
    ...                                    parameter=${parameter_list}
    ...                                    operation=delete
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=COAM_0
    coam.perform_object_recommissioning    dist_name=MRBTS-2298/LNBTS-2298/LNCEL-0/LNRELGNBCELL-3
    ...                                    parameter=${parameter_list}
    ...                                    operation=delete
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=COAM_0
    Wait One GNB Status    bts_index=${0}

Check LNADJGNB0 AND LNADJGNB1 Not Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNADJGNB_A-0
    ...    connection=commission
    Run Keyword If   '${ret}'=='PASS'    Fail    LNADJGNB_A-0 doesn't deleted
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNADJGNB_A-1
    ...    connection=commission
    Run Keyword If   '${ret}'=='PASS'    Fail    LNADJGNB_A-1 doesn't deleted
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission

activate lnadjgnb unlocked
    ${dict}=    create dictionary    parameterName=administrativeState
    ...                              operation=update
    ...                              value=unlocked
    @{parameter_list}    Create List    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-2298/LNBTS-2298/LNADJGNB-1
    ...                                    parameter=${parameter_list}
    ...                                    operation=update
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=COAM_0
    Wait One GNB Status    bts_index=${0}

Check gNB IP fill In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=s1ap.MMEConfigurationTransfer_element
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    10.108.231.19
    Should Contain    ${output}    MMEConfigurationTransfer

Check SON TRS In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=s1ap||x2ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    10.108.231.24
    Should Contain    ${output}    MMEConfigurationTransfer
    Should Contain    ${output}    ENDCConfigurationTransfer
    Should Contain    ${output}    ENBConfigurationTransfer

Check X2 reset In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=s1ap||x2ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    ResetRequest
