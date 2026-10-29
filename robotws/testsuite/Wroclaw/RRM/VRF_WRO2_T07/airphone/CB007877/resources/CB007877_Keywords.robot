*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_pm_counters
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_ue_measurements

*** Keywords ***
################### MEASURMENT KEYWORDS ########################
Send A1 Event For S-Cell Addition
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${scellTechnology}=FDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    scellTechnology=${scellTechnology}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    Sleep    3s    reason=ensure A1 event for S-Cell Addition is sent

Send A1 Event For PCell Switch
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${trigger_type}=RSRP    ${scell}=1    ${scell_rsrp}=127    ${scell_rsrq}=127
    ...            ${scell_sinr}=127    ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Pcell Switch With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    trigger_type=${trigger_type}
    ...    scell_id=${scell_id}
    ...    scell=${scell}
    ...    scell_rsrp=${scell_rsrp}
    ...    scell_rsrq=${scell_rsrq}
    ...    scell_sinr=${scell_sinr}
    ...    pass_regexp=${pass_regexp}

    Sleep    3s    reason=ensure A1 Event For PCell Switch is sent

Send A2 Event For S-Cell Release
    [Arguments]    ${ue_id}=1    ${scell}=1    ${scell_id}=1    ${get_ue_meas_cfg}=${True}
    ...            ${scell_rsrq}=1    ${scell_rsrp}=1    ${scell_sinr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A2 Scell Release With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    scell_id=${scell_id}
    ...    pass_regexp=${pass_regexp}
    ...    get_ue_meas_cfg=${get_ue_meas_cfg}
    ...    scell=${scell}
    ...    scell_rsrq=${scell_rsrq}
    ...    scell_rsrp=${scell_rsrp}
    ...    scell_sinr=${scell_sinr}

    Sleep    3s    reason=ensure A2 Event For S-Cell Release is sent

Send A2 Event For A5 Configuration
    [Arguments]    ${ue_id}    ${pcell_id}    ${srsrp_nr}=1    ${srsrq_nr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete    ${get_ue_meas_cfg}=${True}

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    pass_regexp=${pass_regexp}
    ...    get_ue_meas_cfg=${get_ue_meas_cfg}
    ...    srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr}

    Sleep    2s

Send A5 Event For Inter-Frequency HO
    [Arguments]    ${ue_id}=1    ${srsrp}=1    ${ssinr}=1    ${srsrq}=1    ${neigh_phycellid}=54
    ...            ${nrsrp}=127    ${nrsrq}=127    ${nsinr}=127    ${pass_regexp}=message c1 : rrcReconfigurationComplete
    ...            ${carrier_freq}=518910

    Send Ue Measurement Nr Event A5 With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    phycell_id=${neigh_phycellid}
    ...    nrsrp_nr=${nrsrp}
    ...    nrsrq_nr=${nrsrq}
    ...    nsinr_nr=${nsinr}
    Sleep    3s    reason=ensure A5 Event For Inter-Frequency HO is sent

#################### COUNTERS KEYWORDS #########################

Check Counters Related To Scell Addition 3cc
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55138C02501    +1    GNB_SCELL_2_ADMI_REQ_SA
    ...    M55138C02502    +1    GNB_SCELL_2_ADMI_SUCC_SA
    ...    M55118C07004    +1    RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...    M55118C07003    +1    RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...    M55118C07001    >1    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    M55118C07002    >0   UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    M55118C07002    >0   UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Check Counters Related To Partially Successful Scell Addition 3cc
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55138C02501    +1    GNB_SCELL_2_ADMI_REQ_SA
    ...    M55138C01502    +1    GNB_SCELL_1_ADMI_SUCC_SA
    ...    M55118C05505    +1    RRC_RECONF_ADD1DLSCELL_ATT_SA
    ...    M55118C05506    +1    RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...    M55118C05507    >1    UE_PCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Check Counters Related To First Scell Release 3cc
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C06501    1    A2MEAS_REL1DLSCELL_ATT_SA
    ...    M55118C06502    1    A2MEAS_REL1DLSCELL_SUCC_SA
    ...    M55118C07001    >1   UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    >1    UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Check Counters Related To Second Scell Release 3cc
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05507    0    UE_PCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Check Counters Related To Preventive Handover
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55145C02001    1    ATT_A1_IF_INTRA_DU_HO_SA_PLMN
    ...    M55145C02002    1    SUCC_A1_IF_INTRA_DU_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55149C01501    1    ATT_A1_IF_INTRA_DU_HO_SLICE
    ...    M55149C01502    1    SUCC_A1_IF_INTRA_DU_HO_SLICE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

Check Counters Related To RAC Failure Preventive Handover
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55145C02003    1    FAI_A1_IF_INTRA_DU_HOP_AC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
