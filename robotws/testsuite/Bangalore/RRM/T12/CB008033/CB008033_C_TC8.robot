*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           RAN_5G_TDD   RAN_5G   CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Priya
...             :contact  : anandapriya.mani@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008033 as part of enhancing Handover related counters.

Resource    resources/Keywords/8033_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE_ID}        11
${A3MEAS_ID}     1
${PDU_SESSION_MOD_PATTEN}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${PDU_SESSION_QOS_PATTEN}      QoS Routing Table

*** Test Cases ***
[1][1.0] CB008033_C#8 Verify the counters for successful inter-gNB Pscell change procedure for a NSA user when both gNB are of same frequency
    [Documentation]      This testcase is used to make basic NSA Intra DU Intra Freq HO
    [Tags]     QC_28266   QCD_MN_RAN    QCP_RAN_VRF
	[Setup]    Prepare For Testcase CB008033 TC8
    Basic Bring Up With RANSIM
    Wait For Next Full Pm Interval
    Make ENDC Call
	Sleep    10s
	Traffic Should Be Successful For NSA    ${UE_ID}  5   2
    Sleep   10s
    Log To Console      Starting HO
    Trigger A3 Measurement For NSA HO From Real To RANSIM   ${UE_ID}    ${A3MEAS_ID}     55
    Sleep   30s
	Stop Traffic    ${UE_ID}      1
    UE 5GDetach Should Be Successful For NSA    11
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C08001   1     IAF_CHANGE_COMPLETE
    ...     M55179C00001   1     PC_PR_ATT_NSA_NNNRL
    ...     M55179C00002   1     PC_EX_ATT_NSA_NNNRL
    ...     M55179C00003   1     PC_EX_SUC_NSA_NNNRL
    ...     M55112C02501   1     X2_SGNB_CHG_REQD_SENT
    ...     M55112C02502   1     X2_SGNB_CHG_CONF_RECEIVED
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]      Run Keyword And Ignore Error    Teardown For TestCase CB008033 TC8
