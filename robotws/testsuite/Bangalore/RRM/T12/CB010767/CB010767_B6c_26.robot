*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_tshark
Resource    ${CURDIR}/resources/Keywords/CB010767_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Test Cases ***
[1][1.0] CB010767-B B6c_26_1Verify that HO is rejected on target cell, on different gNB when the target cell does not support redcap
    [Documentation]     The case helps verify the counter when target gNB shall not support redcap and validate counters
#    [Tags]    QC_28310   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}=     Set Variable    CB010767_B6c_26
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log to Console      Starting the test
    [Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_8127.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_FeatureEnabled_NoCellBarring.json
    ...     AND     GNB Delta commission     ${CURDIR}/config/gnb_scf/Delta_Configuration_APoABIL_IANG_FDD.json
    ...     AND     GNB Reboot
    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS                basic_setup_redcap_Xn.cfg
    sleep    40s
    Basic Bring up
    Wait For Next Full Pm Interval
    Make a SA call for GBR NonGBR bearer    57      57
    Sleep   30s
    ${measID}   Display Measurement Configuration for UE    57     A3
    Sleep   10s
    wtsrunner.amf_ue_ng_handover_param      id=1     action=ho_preparation_failure      cause=RN_redcap_ue_not_supported
    Run keyword and ignore error    Trigger NG HO from Real to RANSIM with A3    57    ${measID}       55
    Sleep   30s
    Run keyword and ignore error    wtsrunner.ue_deregister         id=57     ue_deregister_type=switch_off
    Sleep   30s
#    Run keyword and ignore error    Trigger NG HO from Real to RANSIM with A3    57    1    55
#    Sleep   30s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C00041   1     NG_HO_PREP_FAIL_1RXRCUE_NA_SRC
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}

