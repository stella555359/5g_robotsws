*** Settings ***
Documentation
...            Keywords for Handover scenario procedures
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections

Resource    procedures.robot

*** Variables ***
# Standard successful handover regexp patterns
${STD_HO_XN_SA_PASS_END}        Setup QosFlow with
${STD_HO_NG_SA_PASS_END}        Received UE Context Release Complete from source
${STD_HO_INTRA_NSA_PASS_END}    Sending SgNB Modification Confirm
${STD_HO_INTER_NSA_PASS_END}    Inter Sgnb Handover is successful
${STD_HO_IR_PASS_END}           IRAT Handover from .* to .* completed
${STD_HO_INTRA_SA_PASS_END}     rrcReconfigurationComplete
${STD_HO_INTRA_LTE_PASS_END}    Intra-eNB handover from ENB.* to ENB.* performed
@{STD_HO_XN_SA_PASS_MID}    Inter-eNB handover from .*ENB.* to .*ENB.* performed    XnAPHANDOVER_REQUEST|UE with Xn
@{STD_HO_NG_SA_PASS_MID}    Inter-eNB handover from .*ENB.* to .*ENB.* performed    NgLink::OnReceiveHandoverRequired
@{STD_HO_INTRA_SA_PASS_MID}     Intra-eNB handover from .*ENB.* to .*ENB.* performed
@{STD_HO_INTRA_LTE_PASS_MID}    SgNBModificationRequestAcknowledge    Proxy \\(eNB \\d+ cell \\d+\\) reported successful RA

*** Keywords ***
Perform Handover To Target PCI
    [Documentation]    Performs generic handover of UE to target PCI using specified measurement event
    ...                with specified RSRP values using ``ue_measurement_send_nr`` egate command.
    ...                Returns egate print.
    ...                - ``ue_id``: UE ID
    ...                - ``target_pci``: PCI of target cell
    ...                - ``event``: Measurement Event to trigger HO
    ...                - ``srsrp_nr``: RSRP value for serving NR cell, Default: 19
    ...                - ``nrsrp_nr``: RSRP value for neighbor NR cell, Default: 100
    ...                - ``target_ssb``: SSB ARFCN of target cell (NIDD param: arfcnSsbPbch), Default: Not used
    ...                - ``pass_regexp``: Mandatory pass regexp
    ...                - ``fail_regexp``: Alternative fail regexp, Default: standard
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: standard
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}    ${srsrp_nr}=19    ${nrsrp_nr}=100
    ...    ${target_ssb}=${Empty}    ${fail_regexp}=${STD_UE_ATTACH_FAIL}    ${timeout}=30s    ${log_msg}=${Empty}
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Match Regexp    ${event}    ^(A[1-6]|B[12])$    msg=Invalid KW parameter: event
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${target_pci}) is int    msg=Invalid KW parameter: target_pci
    Should Be True    type(${srsrp_nr}) is int    msg=Invalid KW parameter: srsrp_nr
    Should Be True    type(${nrsrp_nr}) is int    msg=Invalid KW parameter: nrsrp_nr
    #---------------------------------------------------------------------------------------------------------------
    ${meas_id}    Get Next Meas ID From Egate    ue_id=${ue_id}    event=${event}    target_ssb=${target_ssb}
    ${cmd}    Catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=${srsrp_nr}
    ...    phycell_id=${target_pci} nrsrp_nr=${nrsrp_nr}
    ${log_msg}    Set Variable If   '${log_msg}' == ''
    ...    Performing Generic Handover with UE-${ue_id} to target PCI ${target_pci} using ${event} Event    ${log_msg}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Perform Inter-GNB Xn Handover To Target PCI
    [Documentation]    Performs Inter-GNB Xn handover of UE to target PCI and verifies it by default.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_XN_SA_PASS_END}
    ...    ${should_contain}=@{STD_HO_XN_SA_PASS_MID}    &{kwargs}
    ${log_msg}    Set Variable
    ...    Performing Inter-GNB Xn Handover with UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain}    &{kwargs}
    [Return]    ${output}

Perform Inter-GNB NG Handover To Target PCI
    [Documentation]    Performs Inter-GNB NG handover of UE to target PCI and verifies it by default.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_NG_SA_PASS_END}
    ...    ${should_contain}=@{STD_HO_NG_SA_PASS_MID}    &{kwargs}
    ${log_msg}    Set Variable
    ...    Performing Inter-GNB NG Handover with UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain}    &{kwargs}
    [Return]    ${output}

Perform Intra-GNB X2 NSA Handover To Target PCI
    [Documentation]    Performs Intra-GNB X2 handover of NSA UE to target PCI and verifies it by default.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_INTRA_NSA_PASS_END}    &{kwargs}
    ${log_msg}    Set Variable
    ...    Performing Intra-GNB X2 Handover with NSA UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    &{kwargs}
    [Return]    ${output}

Perform Inter-GNB X2 NSA Handover To Target PCI
    [Documentation]    Performs Inter-GNB X2 handover of NSA UE to target PCI and verifies it by default.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_INTER_NSA_PASS_END}    &{kwargs}
    ${log_msg}    Set Variable
    ...    Performing Inter-GNB X2 Handover with NSA UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    &{kwargs}
    [Return]    ${output}

Perform Inter-RAT SA Handover To Target PCI
    [Documentation]    Performs Inter-RAT handover of SA UE to target PCI and verifies it by default.
    ...                Inter-RAT handover is triggered by B1 or B2 Event.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_IR_PASS_END}    &{kwargs}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Match Regexp    ${event}    ^B[12]$    msg=Invalid KW parameter: event
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable
    ...    Performing Inter-RAT Handover with SA UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    &{kwargs}
    [Return]    ${output}

Perform Intra-GNB Inter-Cell Handover To Target PCI
    [Documentation]    Performs Intra-GNB Inter-Cell handover of UE to target PCI and verifies it by default.
    ...                Returns egate print. For parameter description see KW ``Perform Handover To Target PCI``.
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${STD_HO_INTRA_SA_PASS_END}
    ...    ${should_contain}=@{STD_HO_INTRA_SA_PASS_MID}    &{kwargs}
    ${log_msg}    Set Variable
    ...    Performing Intra-GNB Inter-Cell Handover with UE-${ue_id} to target PCI ${target_pci} using ${event} Event
    ${output}    Perform Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    log_msg=${log_msg}
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain}    &{kwargs}
    [Return]    ${output}

Perform Intra-LTE NSA Handover To Target Cell
    [Documentation]    Performs Intra-LTE Inter-Cell handover of UE to target Cell-ID and verifies it by default.
    ...                Returns egate print.
    ...                - ``ue_id``: UE ID
    ...                - ``target_cell``: Target Cell ID
    ...                - ``enb``: Target eNB ID
    ...                - ``kwargs``: Other parameters of ``Execute Egate Command Ext``
    [Arguments]    ${ue_id}    ${target_cell}    ${enb}=1    ${pass_regexp}=${STD_HO_INTRA_LTE_PASS_END}
    ...    ${should_contain}=@{STD_HO_INTRA_LTE_PASS_MID}    &{kwargs}
    ${cmd}    Set Variable    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb} cell=${target_cell}
    ${log_msg}    Set Variable    Performing Intra-LTE NSA Handover with UE-${ue_id} to Cell ${enb}.${target_cell}
    ${output}    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    log_msg=${log_msg}
    ...    should_contain=${should_contain}    &{kwargs}
    [Return]    ${output}
