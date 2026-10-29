*** Settings ***
Documentation
...    Rework: Ulm SQD 65
...    author: G. Sankaran and L. Medico, Ulm SQD 66
...    maintainer: Jing Liang, Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC000574

Library     Collections
Library     OperatingSystem
Library     taf.sw.reporting_portal
Library     taf.config.wts         WITH NAME    wts_conf

Resource          ../resources/SQD65/sqd65_keywords.robot
Resource          ../../resources/Common/bip_trace.robot
Resource          ../../resources/Common/bip_trace_ap.robot
Resource          5GC000574_Commissioning.robot

*** Variables ***
${TEST_MODE}         auto
${574_WTS_CFG}       basic_setup_574.cfg
${DEFAULT_BEARER}    ${2}
${AP_DL_RATE}        ${13}
${AP_UL_RATE}        ${5}
@{UE_LIST}           ${101}    # NSA UE
@{IP_LIST}    10.0.1.121  10.0.1.131  10.0.1.132  10.0.1.133  10.0.1.134  10.0.1.135  10.0.1.136  10.0.1.137
...           10.0.1.161  10.0.1.162  10.0.1.163  10.0.1.143  10.0.1.144
...           10.0.1.12   10.0.1.102  10.0.1.103  10.0.1.104  10.0.1.105  10.0.1.106
&{5GC000574-A_B2-CellCounters}       M55112C03501=1  M55112C03502=1
&{5GC000574-A_B2-BtsCounters}        M55128C00501=1  M55128C00503=1  M55128C00504=1
${EGATE_CONSOLE_LOG}                 /opt/iphy/latest/egate_console.log
&{plmn}=                             mcc=311  mnc=489  mncLength=3

*** Keywords ***
Suite Setup for 5GC000574
    [Documentation]    Collect all needed configuration to bring TL back to status
    ...    AirphoneConfig.xml, basic.cfg, ap_swconfig, gnb_swconfig, SCF
    ...    Upload needed config file to TL
    Sqd65 Common Setup
    ${SW_BRANCH}=             testline.Get gNB SW Branch
    Set Suite Variable        ${SW_BRANCH}
    Execute Delta Commissioning for 574
    Bring Airphone TL to on Air status

Prepare 574 WTS config
    wts_conf.load_wts_cfg    file_path=${P_ORIG_WTS_CONFIG}
    wts_conf.insert    command=set ENB9_X2_ADDR="10.0.1.161"  location=before    reference=set_enb id=1
    wts_conf.insert    command=set ENB9_X2U_ADDR="10.0.1.162"  location=before    reference=set_enb id=1
    wts_conf.insert    command=set ENB9_S1_ADDR="10.0.1.163"  location=before    reference=set_enb id=1
    wts_conf.insert    command=set SGW_S1U_ADDR_1="10.0.1.143"  location=before    reference=set_enb id=1
    wts_conf.insert    command=set SGW_S1U_ADDR_2="10.0.1.144"  location=before    reference=set_enb id=1
    wts_conf.clone_and_modify    command=set_enb id=1
    ...    modification=id=9 s1=$ENB9_S1_ADDR enb_id_macro=0x12349 x2=$ENB9_X2_ADDR x2u=$ENB9_X2U_ADDR x2_peers=1
    wts_conf.clone_and_modify    command=enb_param id=1    modification=id=9
    wts_conf.clone_and_modify    command=set_cell id=1 enb=1    modification=id=9 enb=9 eci=0x1234901 pci=9:2 proxy=$CONTAINER_IP:12211
    wts_conf.clone_and_modify    command=enb_endc_param id=1    modification=id=9
    wts_conf.modify    command=set_sgw id=1    modification=s1u_if_num=2 s1u=$SGW_S1U_ADDR_1
    wts_conf.insert    command=trace enb=9 protocol=x2 on    location=after    reference=trace enb=1
    wts_conf.save_wts_cfg    file_path=${tl.core.dir_path}/${574_WTS_CFG}

Recover TL to suite setup status
    Execute full commissioning    gnb_id=0    scf_path=${scf_to_be_loaded}    skip_relation_errors=False
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone

Perform Precondition for 5GC000574 testcase
    [Documentation]    prepare testcase log folder, bring TL to pre-condition
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Recover TL to suite setup status
    ...    ELSE       gnb.Wait For Minimum Required State For Cell Setup
    Prepare 574 WTS config
    Bring Airphone TL to on Air status    cfg_file=${574_WTS_CFG}  remove_logs=True  force_cu_type=NSA
    Send Egate Command and verify output    cmd=enb_x2_link_up enb=9 target=2    pass_regexp=X2AP Link .* is up
    Start Logging    pmcounter_enabled=${TRUE}
    Start BIP Tracing

Perform Postconditions for 5GC000574 testcase
    Detach all UEs from LTE
    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting
    Run Keyword and Warn on Failure    Stop Logging
    Stop BIP Tracing
    IF    '${TEST_MODE}'=='auto'   Collect AP Sos Report and Snapshots
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone

Start BIP Tracing
    [Documentation]    start BIP tracing for TC
    Set BIP Trace Filter
    Set AP BIP Trace Filter
    Run Keyword And Ignore Error    Start BIP Traces    option=${bip_filter}
    Run Keyword And Ignore Error    Start Airphone BIP Traces    option=${ap_bip_filter}

Stop BIP Tracing
    Run Keyword And Ignore Error    Stop BIP Traces
    Run Keyword And Ignore Error    Stop Airphone BIP Traces

# UE handling
Detach all UEs from LTE
    [Documentation]    Detaches all the active UEs from LTE network.
    ...    Usually to be included in testcase or suite teardown.
    FOR    ${ue_id}    IN    @{UE_LIST}
         Detach UE from LTE    ue_id=${ue_id}
    END

Perform eNB Handover
    [Documentation]  :Author: G. Sankaran and L. Medico
    ...    Inter MeNB Handover will be triggered.
    ...    :param ue_id:    ue_id configured in WTS configuration
    ...    :param target_enb_id:    eNB towards Ue will be moved
    ...    :param target_cell_id:    cell of eNB to towards Ue will be moved
    [Arguments]    ${ue_id}    ${target_enb_id}    ${target_cell_id}    ${sgw_relocation}=False
    ${exp_for_sgw_ho}=  Set Variable If  ${sgw_relocation}  Fake Inter-SGW X2 Handover .* completed  Intra-SGW X2 Handover .* completed
    Send Egate Command and verify output
    ...    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${target_enb_id} cell=${target_cell_id}
    ...    pass_regexp=${exp_for_sgw_ho}
    Sleep  2s  reason=waiting for HO process

Perform multiple eNB Handovers
    [Documentation]  :Author: G. Sankaran and L. Medico
    ...    Perform eNB Handover function will be called number of times as defined by variable ${number_ho}.
    ...    Variables ${number_ho} and ${ho_is_towards_eNB9} have scope within this keyword.
    ...    Handover will be performed only between two eNBs, in a ping pong manner.
    [Arguments]    ${number_ho}    ${ho_is_towards_eNB9}=True
    FOR  ${_}    IN RANGE    ${number_ho}
            IF    ${ho_is_towards_eNB9}
                ...  Perform eNB Handover    ue_id=${UE_LIST}[0]  target_enb_id=9  target_cell_id=9
                ...  ELSE
                ...  Perform eNB Handover    ue_id=${UE_LIST}[0]  target_enb_id=1  target_cell_id=1
            Log to console  ho towards eNB9 is ${ho_is_towards_eNB9}
            ${ho_is_towards_eNB9}=  Evaluate  not ${ho_is_towards_eNB9}
    END

Verify 5GC000574
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...   check counters to get passed the TC
    [Arguments]    ${number_of_handover}    ${extended_dict_sgw}=False
    Log to console  \nnumber_of_handover is ${number_of_handover}
    &{expected_pm_value}    Create Dictionary
    ...  M55112C03501    ${number_of_handover}
    ...  M55112C03502    ${number_of_handover}
    ...  M55112C03503    ${0}
    ...  M55112C00002    ${1}
    ...  M55112C00003    ${1}
    ...  M55112C00004    ${1}
    ...  M55112C01001    ${0}

    &{expected_pm_value_sgw}    Create Dictionary
    ...  M55112C03501    ${number_of_handover}
    ...  M55112C03502    ${number_of_handover}
    ...  M55112C04001    ${number_of_handover}
    ...  M55112C04002    ${number_of_handover}
    ${expected_pm_value_cell}=  Set Variable If  ${extended_dict_sgw}  &{expected_pm_value_sgw}  &{expected_pm_value}
    &{expected_pm_value_bts}    Create Dictionary
    ...  M55128C00503    ${number_of_handover}
    ...  M55128C00504    ${number_of_handover}
    ...  M55128C00502    ${number_of_handover}
    ...  M55128C00505    ${0}
    ...  M55110C00034    ${1}

    Log Dictionary    ${expected_pm_value_cell}
    Log Dictionary    ${expected_pm_value_bts}
    ${regex_cell}=    Set Variable    MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+
    ${regex_bts}=     Set Variable    MRBTS-\\d+/NRBTS-\\d+
    ${pm_files}=   Collect PM Counter
    ${pm_status_cell}=    Run Keyword and Return Status    Analyze PM Counters
    ...  pi_dir=${pm_files}    pi_expected=${expected_pm_value_cell}    regex=${regex_cell}
    ${pm_status_bts}=     Run Keyword and Return Status    Analyze PM Counters
    ...  pi_dir=${pm_files}    pi_expected=${expected_pm_value_bts}    regex=${regex_bts}
    ${test_result}=  Evaluate  ${pm_status_cell} and ${pm_status_bts}
    Should Be Equal As Strings    ${test_result}    True

Set BIP Trace Filter
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...   Apply filtering to BIP trace to reduce the size of the captire file.
    ...   0xe101    DlData_PatternConfigReq
    ...   0x122     DlData_SlotTypeReq
    ...   0x131     DlData_CsiRsSendReq
    ...   0x127     DlData_SsBlockSendReq
    ...   0x240     UlData_PrachReceiveReq
    ${filterVar1}=    Set variable    'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x127
    ${filterVar2}=    Set variable    && ether[0x18:2]!=0xf2ff && ether[0x18:2]!=0xf31b && ether[0x18:2]!=0x240'
    ${filterVar}=    Catenate    ${filterVar1}    ${filterVar2}
    Set Test Variable    ${bip_filter}    ${filterVar}

Set AP BIP Trace Filter
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...   Apply filtering to AirPhone BIP trace to reduce the size of the captire file.
    ...   0xf1ff    DlDataUe_SyncInd
    ...   0xf322    DlDataUe_SsBurstReceiveResp
    ...   0xf33d    UlDataUe_SlotTypeReq
    ${filterVar}=    Set variable    'ether[0x18:2]!=0xf1ff && ether[0x18:2]!=0xf322 && ether[0x18:2]!=0xf33d'
    Set Test Variable    ${ap_bip_filter}    ${filterVar}

Trigger SGW relocation
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...   To trigger SGW (serving gateway) relocation during Handover
    ...   This WTS command to perform SGW switch needs to be executed in EGATE console before performing Handover.
    Send Egate Command and verify output
    ...    ue_mme_param id=${UE_LIST}[0] sim_inter_sgw_x2_ho=on s1u_ul_teids_change_for_x2_ho=on s1u_ul_ip_change_for_x2_ho=on
    Log to console    \nSGW relocation performed

Verify 5GC000574-A_TC03
    Run Keyword and Ignore Error    Send Egate Command and verify output    cmd=sim_log_set flush
    ${egate_console}=     Get File               ${EGATE_CONSOLE_LOG}
    Should Match Regexp   ${egate_console}       UE101: Proxy \\(eNB 2 cell 2\\) reported successful RA
    ${regex1}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
    ${regex2}=    Set Variable    MRBTS-1/NRBTS-1
    ${pm_files}=   Collect PM Counter
    ${test_status_1}=    Run Keyword and Return Status    Analyze PM Counters
    ...  pi_dir=${pm_files}    pi_expected=${5GC000574-A_B2-CellCounters}    regex=${regex1}
    ${test_status_2}=    Run Keyword and Return Status    Analyze PM Counters
    ...  pi_dir=${pm_files}    pi_expected=${5GC000574-A_B2-BtsCounters}     regex=${regex2}
    ${test_result}=  Evaluate  ${test_status_1} and ${test_status_2}
    Should Be Equal As Strings    ${test_result}    True

Add NRREL to Cell
    [Arguments]      ${cell_id}=1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=NRBTS-1/NRCELL-${cell_id}
    IF    not ${mo_exist}   RETURN
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRREL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    ${nrrel.lcrId}=  IF            '${cell_id}' == '1'
    ...                  Set Variable  2
    ...              ELSE
    ...                  Set Variable  1
    scf.add_object_to_scf     class_name=NRREL          dist_name=${dist_name}                version=NRBTSCL5G21B_2104_100
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualSsbRsrpOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualSsbRsrqOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbId                          value=1
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbIdLength                    value=22
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSA              value=allowed
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                          value=${nrrel.lcrId}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=removeNotAllowed               value=false
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrDcAllowed                    value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false
