*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...              CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_27879
...              :Description:This user scenario describes the case when RLC max retransmission
...              error detected for one bearer after another at gNB-DU, gNB-CU-CP triggers PDU Session
...              Resource Release. The RLC error is for a DRB of a PDU Session which is not the last PDU Session.



Resource         ./basic_resource.robot


Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with TC7.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    120s
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Sleep    60s

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND        Kill WTS processes Using WTS_Runner
...                 AND     Stop Log     snapshot    sosreport

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}       3
${PDU2}        2
${PDU3}         3
${nwslice_ID}    1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${trf_ID}    1
${Timeout_SA}    40
${start_ue_id}      ${1}
${end_ue_id}      ${3}
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
${NG_FLOW_REL_ABNORMAL_INSESSION}       M55125C09026
${NG_FLOW_GNB_REL_RADIO_PROCD_FL}       M55125C09029
${NG_FLOW_GNB_REL_RDPRCDFL_PMQAP}       M55163C00016
${NG_FLOW_SETUP_FAIL_UNSPECIFIED}       M55125C09011
${NG_FLOW_REL}                          M55125C08503
${NG_FLOW_REL_ABNORMAL}                 M55125C09028



*** Test Cases ***
[1]CNI129151_IWK1_TC8_ PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error_one_after_another

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log      btslog     cprt

    ${ue_to_bearer_list}       ${lcid_list}       MultiUE Register should be Successful with lcid     1    3    pdu_id=1
    Log to Console    ${lcid_list}

    sleep   30s
#total 3 UEs and 3 PDUs each and each PDU has 2qfi+default qfi

    UE PDU Addition should be Successful    ue_id=${UE_ID1}     pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID1}     pdu_id=3     nw_id=1    gw_id=3
    sleep   5s
    UE PDU Addition should be Successful     ue_id=${UE_ID2}    pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful     ue_id=${UE_ID2}    pdu_id=3     nw_id=1    gw_id=3
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID3}     pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID3}     pdu_id=3     nw_id=1    gw_id=3

    sleep   10s

    ${lcid_1}      PDU Modfication to add additional qfi    1    3   pdu_id=1    qosflows_to_add=10
    ${lcid_2}      PDU Modfication to add additional qfi    1    3   pdu_id=2    qosflows_to_add=11
    ${lcid_2}      PDU Modfication to add additional qfi    1    3   pdu_id=3    qosflows_to_add=12


    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=1      qfi_id=2
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=3      qfi_id=2

    sleep   10s

    Trigger RLC max retransmission error    1    1     prof=1      lcid=5    sn=1     ##pdu2 UE1
    Sleep      60s
    Trigger RLC max retransmission error    1    1     prof=2      lcid=6    sn=1    ##pdu3 UE1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=3      lcid=5    sn=1   ##pdu2 UE2
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=4      lcid=6    sn=1   ##pdu3 UE2
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=5      lcid=5    sn=1   ##pdu2 UE3
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=6      lcid=6    sn=1   ##pdu3 UE3
    Sleep      60s

    Check MultiUE UE State Display      1    3       ACTIVE

    sleep   30s

    Trigger RLC max retransmission error    1    1     prof=7      lcid=4    sn=1     ##pdu2 UE1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=8      lcid=4    sn=1    ##pdu3 UE1
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=9      lcid=4    sn=1   ##pdu2 UE2
    Sleep      60s

    Check MultiUE UE State Display      1    3       IDLE

    ${path}    Stop Log      btslog     cprt

    MultiUE Deregister should be Successful     1   3

    Verify Packets      ${path}[cprt]     ngap.PDUSessionResourceNotify_element     radioNetwork

    ${Counters}    Create Dictionary     ${NG_FLOW_REL_ABNORMAL_INSESSION}=${18}
    ...        ${NG_FLOW_GNB_REL_RADIO_PROCD_FL}=${12}     ${NG_FLOW_SETUP_FAIL_UNSPECIFIED}=${0}   ${NG_FLOW_REL}=${18}
    ...        ${NG_FLOW_REL_ABNORMAL}=${18}

    Verify Counters    ${Counters}
