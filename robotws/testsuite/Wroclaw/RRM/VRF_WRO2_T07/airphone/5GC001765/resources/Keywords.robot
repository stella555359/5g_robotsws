*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb

*** Keywords ***
Send A1 event for S-Cell Addition
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${scellTechnology}=FDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    scellTechnology=${scellTechnology}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}

    Sleep    3s    reason=ensure A1 event for S-Cell Addition is sent

Send A2 event for HO
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${srsrp}=1    ${srsrq}=1    ${ssinr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    pass_regexp=${pass_regexp}

    Sleep    3s    reason=ensure A2 event for HO is sent

Send A1 event for HO
    [Arguments]    ${pcell_id}=1    ${ue_id}=1    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Handover Cancel SA With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    pass_regexp=${pass_regexp}

    Sleep    3s    reason=ensure A1 event for HO is sent

Send A5 Event For Inter-Frequency HO
    [Arguments]    ${ue_id}=1    ${srsrp}=1    ${ssinr}=1    ${srsrq}=1  ${neigh_phycellid}=54
    ...            ${nrsrp}=127    ${nrsrq}=127    ${nsinr}=127    ${carrier_freq}=518910

    Send Ue Measurement Nr Event A5 With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    carrier_freq=${carrier_freq}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    phycell_id=${neigh_phycellid}
    ...    nrsrp_nr=${nrsrp}
    ...    nrsrq_nr=${nrsrq}
    ...    nsinr_nr=${nsinr}

    Sleep    3s    reason=ensure A5 Event For Inter-Frequency HO is sent
