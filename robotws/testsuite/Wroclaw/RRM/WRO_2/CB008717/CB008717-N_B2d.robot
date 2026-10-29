*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Miłosz Komarczewski, Marta Klukas
...             :contact: milosz.komarczewski@nokia.com, marta.klukas@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}

Test Setup      Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

Test Teardown   Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

Suite Teardown    On failure    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B2d_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${ON_FAILURE}=              IGNORE
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B2d_TC1_Buffering_SCell_Addition_notifications_during_NR-DC_Setup
    Setup devices aliases
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Wait Until ICS is Competed
    Set expected A4 measurement based PSCell Addition with buffer monitoring for SCell Addition for UE1, gNB2

    UE1 sends A1 measurement id=1 for SCell Addition
    Delay RRC Reconfiguration Complete
    Send Data Traffic In Direction For Buffer Filling
    Wait For Data Buffer To Fill
    UE1 sends A4 measurement id=2 for NR-DC PSCell addition
    Send Data Traffic In Direction For Buffer Overflow

    Verify expected A4 measurement based PSCell Addition with buffer monitoring for SCell Addition for UE1, gNB2
    Set expected RRC Complete and UECntxMod for UE1, gNB2 after Private Message Received
    Verify Successfull NRDC setup with discarded Buffer Overflow Notification
    Verify expected RRC Complete and UECntxMod for UE1, gNB2 after Private Message Received
    Verify Successfull RRC Reconfiguration Complete after Private Message Received
    Verify that UE was not released for 60 seconds


*** Keywords ***
Delay RRC Reconfiguration Complete
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=mrdc_scg_setup delay=5500

Verify Successfull NRDC setup with discarded Buffer Overflow Notification
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_1 out of 1 was completed for UE1 with no RRCReconfigurationComplete
    Verify in RRCReconfiguration_1 out of 1 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfiguration_1 out of 1 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_1 out of 1 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_1 out of 1 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_1 out of 1 for UE1 that A4 measurement related to measid-5 is removed

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that SCell-ToBeSetup-Item is not present for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} for 1 PDU session has ${drb:\d+} DRB for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${id}

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for MN context
    Verify in BearerContextModificationResponse_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}

Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was completed for UE${ue_id:\d+} with no RRCReconfigurationComplete
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that MCG modification and SCG setup is present

Verify Successfull RRC Reconfiguration Complete after Private Message Received
    Verify in RRCReconfigurationComplete_1 out of 1 for UE1 that message contains encoded RRCReconfigurationComplete for SCG
    Verify in UECtxModReq_1 out of 1 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_1 out of 1 that GNB-DUConfigurationQuery is set to true for gNB2

Wait For Data Buffer To Fill
    Sleep    2s

Wait Until ICS is Competed
    Sleep    5s

Send Data Traffic In Direction For Buffer Filling
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=dl    ${mbps}=40
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=${dir} mbps=${mbps}

Send Data Traffic In Direction For Buffer Overflow
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=dl    ${mbps}=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2 dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=3 dir=${dir} mbps=${mbps}
