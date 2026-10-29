*** Settings ***
Documentation    this resource is for CB006086
...              Author: qiqi.luo@nokia-sbell.com
...              Please do not edit the existing keywords in this file without testing.
Resource         ./../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${IPHY_ULSINR_PATH}    /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf

*** Keywords ***
Read X2 Pcap Files
    [Arguments]    ${x2_log_name}    ${filter}
    ${pdml_list}    PCAP.Load Pcap File    pcap_file=${test_log_directory}/${x2_log_name}
    ${pdml_list}    PCAP.Filter Packets By Expression    pdml_list=${pdml_list}    filter_expression=${filter}
    ${value}    PCAP.Get Field Value By Name    pdml_list=${pdml_list}    field_name=nr-rrc.nrofSRS_Ports
    Log    ${value}
    [Return]    ${value}

Check Single Msg In X2 Log
    [Arguments]    ${x2_log_name}    ${filter}
    [Documentation]    This Keyword Is Used To Check BIP Log With Filter
    ...    X2_log_name: is the name of x2 log, such as ${x2_log_name}=x2.pcap
    ...    filter: is the filter for x2 log,
    ...    ${filter}=nr-rrc.nrofSRS_Ports == 0
    ${pdml_lst}    Read X2 Pcap Files    ${x2_log_name}    ${filter}
    [Return]    ${pdml_lst}

Check Single Msgs Counts In X2 Log
    [Arguments]    ${x2_log_name}    ${filter}    ${expected_count}
    [Documentation]    This Keyword Is Used To Check BIP Log With Filter
    ${pdml_lst}    Read X2 Pcap Files    ${x2_log_name}    ${filter}
    ${exist_count}    Get Length    ${pdml_lst}
    Should Be True    '${exist_count}'=='${expected_count}'

Copy Const File To AP
    [Arguments]    ${const_file}
    ssh.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=${AP_ASIK.connection}
    ssh.Upload File    ${const_file}    ${IPHY_ULSINR_PATH}    connection=${AP_ASIK.connection}
    [Teardown]    ssh.Disconnect    connection=${AP_ASIK.connection}

NSA NR UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    Example:
    ...    | NSA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
    Log To Console    set UE NR capability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
    Log To Console    set_UE_NR_capability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

NSA NR And Eutra UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}    ${ue_eutra_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    | ue_eutra_nr_cap | Yes | ue_eutra_nr_cap |
    ...    Example:
    ...    | NSA NR And Eutra UE Param Set | 1 | 123 | 456 |
    Log To Console    set UE NR and eutra capability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap} dual_conn=eutra_nr ue_eutra_nr_capabilities\=${ue_eutra_nr_cap}
    Log To Console    set_UE_NR_and_eutra_capability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

SA NR UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    Example:
    ...    | SA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
    Log To Console    set UE NRcapability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
    Log To Console    set_UE_NRcapability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

NSA UE Testmode Set
    [Arguments]    ${ue_id}    ${bearer_id}    ${ul_sinr_profile_index}
    [Documentation]    This keyword is used to set UE Testmode after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearerid |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    Example:
    ...    | NSA UE Testmode Set | 1 | 1 | 1 |
    Log To Console    set UE Testmode...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set id\=${ue_id} bearer\=${bearer_id} testmode=ul_sinr profile_index\=${ul_sinr_profile_index} action=activate
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok

SA UE Testmode Set
    [Arguments]    ${ue_id}    ${ul_sinr_profile_index}
    [Documentation]    This keyword is used to set UE Testmode after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    Example:
    ...    | SA UE Testmode Set | 1 | 1 |
    Log To Console    set UE Testmode...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set id\=${ue_id} testmode=ul_sinr profile_index\=${ul_sinr_profile_index} action=activate
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok

Set X2 Failure
    [Documentation]    set x2 failure
    Log To Console    set X2 Failure...
    ute_wtssim.Execute Egate Command
    ...    cmd=link_x2_management_abnormal_cases sgnb_modification_reqd_rsp=no_rsp id=1 partner=2
    Log To Console    set_X2_Failure_is_ok

Get Default Ue Capabilities
    [Documentation]    This keyword is to get default ue_nr_capabilities and ue_eutra_nr_capabilities values.
    ...    And set the value as suite variables ${default_nr_capabilities} and ${default_eutra_nr_capabilities}.
    ...
    ...    Examples:
    ...    | Get Default Ue Capabilities |
    ...    | Log To Console | ${default_nr_capabilities} |
    ...    | Log To Console | ${default_eutra_nr_capabilities} |
    ...
    ${nr_capabilities_reg}    Set Variable    ue_nr_capabilities\=([0-9A-Za-z]+)
    ${eutra_nr_capabilities_reg}    Set Variable    ue_eutra_nr_capabilities\=([0-9A-Za-z]+)
    ${content}    OperatingSystem.Get File    ${wts_dir}/${wts_cfg}
    ${nr_capabilities}    String.Get Regexp Matches    ${content}    ${nr_capabilities_reg}    1
    Should Not Be Empty    ${nr_capabilities}
    ${eutra_nr_capabilities}    String.Get Regexp Matches    ${content}    ${eutra_nr_capabilities_reg}    1
    Should Not Be Empty    ${eutra_nr_capabilities}
    Set Suite Variable    ${default_nr_capabilities}    ${nr_capabilities[0]}
    Set Suite Variable    ${default_eutra_nr_capabilities}    ${eutra_nr_capabilities[0]}

Set UE Measurement
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_meas_param id=${ue_id} nr_neigh_cell=non_cfgd:50 nr_rsrp=97 nr_rsrq=97


NSA UE Testmode NR Profile
    [Arguments]    ${ul_sinr_profile_index}    ${sinr_target_srs}    ${sinr_target_pusch}    ${sinr_target_pucch}    ${sinr_target_preamble}
    [Documentation]    This keyword is used to set UE Testmode after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    | sinr_target_srs | Yes | sinr_target_srs |
    ...    | sinr_target_pusch | Yes | sinr_target_pusch |
    ...    | sinr_target_pucch | Yes | sinr_target_pucch |
    ...    | sinr_target_preamble | Yes | sinr_target_preamble |
    ...    Example:
    ...    | NSA UE Testmode NR Profile | 1 | 100 | 100 | 100 | 100 |
    Log To Console    add UE testmode NR profile...
    ${cmd}    Catenate    ul_sinr_testmode_nr profile_id=${ul_sinr_profile_index} sinr_target_srs=${sinr_target_srs}
    ...    sinr_target_pusch=${sinr_target_pusch} sinr_target_pucch=${sinr_target_pucch} sinr_target_preamble=${sinr_target_preamble}
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd}
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok

NSA UE Testmode NR Set
    [Arguments]    ${ue_id}    ${ul_sinr_profile_index}
    [Documentation]    This keyword is used to set UE Testmode NR after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    Example:
    ...    | NSA UE Testmode Set | 1 | 1 |
    Log To Console    set UE Testmode NR...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=${ul_sinr_profile_index} scell=5
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok

Add Scell Range To NSA
    Log To Console    add scell range to NSA...
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_endc_param id=1 serving_cell_index_range_scg=5:31


SA UE Testmode NR Profile
    [Arguments]    ${ul_sinr_profile_index}    ${sinr_target_srs}    ${sinr_target_pusch}    ${sinr_target_pucch}    ${sinr_target_preamble}
    [Documentation]    This keyword is used to set UE Testmode after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    | sinr_target_srs | Yes | sinr_target_srs |
    ...    | sinr_target_pusch | Yes | sinr_target_pusch |
    ...    | sinr_target_pucch | Yes | sinr_target_pucch |
    ...    | sinr_target_preamble | Yes | sinr_target_preamble |
    ...    Example:
    ...    | SA UE Testmode NR Profile | 1 | 100 | 100 | 100 | 100 |
    Log To Console    add UE testmode NR profile...
    ${cmd}    Catenate    ul_sinr_testmode_nr profile_id=${ul_sinr_profile_index} sinr_target_srs=${sinr_target_srs}
    ...    sinr_target_pusch=${sinr_target_pusch} sinr_target_pucch=${sinr_target_pucch} sinr_target_preamble=${sinr_target_preamble}
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd}
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok


SA UE Testmode NR Set
    [Arguments]    ${ue_id}    ${ul_sinr_profile_index}
    [Documentation]    This keyword is used to set UE Testmode NR after NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
    ...    Example:
    ...    | SA UE Testmode Set | 1 | 1 |
    Log To Console    set UE Testmode NR...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=${ul_sinr_profile_index}
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_Testmode_is_ok

Check Egate Console Log
    [Arguments]    ${egate_path}    ${posts_list}
    Log To Console    log flush...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable     nrofSRS-Ports\\s+(?P<port>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}    port
    Collections.Lists Should Be Equal    ${matches}    ${ports_list}

Check Egate Console Log Single Port
    [Arguments]    ${egate_path}    ${expected_posts}
    Log To Console    log flush...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable     nrofSRS-Ports\\s+(?P<port>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}    port
    Should Be Equal    ${matches[-1]}    ${expected_posts}

SA Start UL Traffic eGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | pdu_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable
