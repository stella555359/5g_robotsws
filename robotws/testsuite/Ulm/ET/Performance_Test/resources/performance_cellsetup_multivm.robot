*** Settings ***
Documentation
...  MultiVM cellsetup kw

Library    taf.sw.wtssim  # taf_sw_wtssim_wrapper dependency

Resource    ../../../resources/Common/gnb.robot

Library   python/wts_multivm_helper.py
Library   python/taf_sw_wtssim_wrapper.py

*** Keywords ***
Wait For MultiVM On Air
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${None}
    taf_sw_wtssim_wrapper.Setup All Egates And Edaemons Connections    tl=${tl}    # Connects to all VMs Egates if not already connected
    Log To Console    Wait For SIB\n
    Run Keyword And Continue On Failure    Wait For MultiVM AP Cellsetup    start_cell=${start_cell}    end_cell=${end_cell}
    ...                                                                     active_cells=${active_cells}
    Wait For MultiVM SIBs            start_cell=${start_cell}    end_cell=${end_cell}    active_cells=${active_cells}
    Log to console    Wait until all gNBs to be onair state\n
    gnb.Wait Until All GNBs To Be Onair State


Wait For MultiVM AP Cellsetup
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${None}
    TRY
        Wait Until Keyword Succeeds   5min   1m
        ...    Assert MultiVM AP Cellsetup    start_cell=${start_cell}    end_cell=${end_cell}    active_cells=${active_cells}
        ${ap_status}    Set Variable    ${True}
    EXCEPT    .*AP Cellsetup Check Failed.*    type=regexp
        ${ap_status}    Set Variable    ${False}
    END
    ${ap_cells}       wts_multivm_helper.Get AP Cell For All VMs    tl=${tl}
    ${ap_cell_str}    wts_multivm_helper.Format AP Cells    ${ap_cells}
    Log To Console    ${ap_cell_str}
    IF    not ${ap_status}    Fail    AP Cellsetup Check Failed


Wait For MultiVM SIBs
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${None}
    TRY
        Wait Until Keyword Succeeds   5min   1m
        ...    Assert MultiVM SIB    start_cell=${start_cell}    end_cell=${end_cell}    active_cells=${active_cells}
        ${sib_status}    Set Variable    ${True}
    EXCEPT    .*SIB Check Failed.*    type=regexp
        ${sib_status}    Set Variable    ${False}
    END
    ${sibs}       wts_multivm_helper.Get SIB For All VMs    tl=${tl}    sibtype=1
    ${sibs_str}    wts_multivm_helper.Format SIBs    ${sibs}
    Log To Console    ${sibs_str}
    IF    not ${sib_status}    Fail    SIB Check Failed


Assert MultiVM AP Cellsetup
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${None}
    ${ap_cells}       wts_multivm_helper.Get AP Cell For All VMs    tl=${tl}
    ${ap_cells_status}    wts_multivm_helper.Is AP Cell Ready    ${ap_cells}    start_cell=${start_cell}    end_cell=${end_cell}
    ...                                                          active_cells=${active_cells}
    Should Be True    ${ap_cells_status}     msg=AP Cellsetup Check Failed


Assert MultiVM SIB
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${None}
    ${sibs}       wts_multivm_helper.Get SIB For All VMs    tl=${tl}    sibtype=1
    TRY
        ${sibs_status}    wts_multivm_helper.Is SIB Ready    ${sibs['enbs']['2']}
        ...                                                  start_cell=${start_cell}
        ...                                                  end_cell=${end_cell}
        ...                                                  active_cells=${active_cells}
    EXCEPT    .*KeyError.*    type=regexp
        Log    SIBS: ${sibs}    level=ERROR
        FAIL    msg=SIB Check Failed due to KeyError
    END
    Should Be True    ${sibs_status}    msg=SIB Check Failed
