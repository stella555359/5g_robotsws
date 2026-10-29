*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Karol Rybak <karol.rybak@nokia.com>
...      == MAINTAINER ==
...        - Karol Rybak <karol.rybak@nokia.com>

Library     OperatingSystem
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_egate
Library     ta5g_iphy
Library     ta5g_testline_management
Library     ta_emss
Library     ta_messaging
Library     ta_logcollector
Library     taf.sbts.oam.coam.admin    WITH NAME   coam
Library     ../../resources/former_l2_sw1/python/common_keywords.py
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${CONF_9267}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB009267/config
${CONF_DIR}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB009884/config
${RES_DIR}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB009884/resources

*** Keywords ***
Attach UE SA
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${pdu}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=set_pdu_param ue=${UE_ID} pdu=${pdu} trf_type=internal
        sleep    2s
        Execute egate command
        ...    cmd=ue_register id=${UE_ID}
        sleep    2s
        Execute egate command
        ...    cmd=ue_pdu_session_setup pdu=${pdu} ue=${UE_ID} nwslice=1 gw=1
        sleep    2s
    END

Detach UE SA
	[Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    END

Modify PDU session
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${by}  ${pdu}  ${qosflows_to_add}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_pdu_session_modify ue=${UE_ID} by=${by} pdu=${pdu} qosflows_to_add=${qosflows_to_add}
    END

Set release params
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${time_to_wait}  ${pdu}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=amf_ue_ctx_release_param id=1 ue=${UE_ID} action=override_cause cause=RN_radio_connection_with_ue_lost
        ...    cmd=amf_ue_pdu_release_param id=${pdu} action=delay time_to_wait=${time_to_wait}
        ...    cmd=ue_nr_rrc_reconf_param id=${UE_ID} if_contains=any action=reestablish cause=reconfigurationFailure
    END

Release PDU
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${by}  ${pdu}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_pdu_session_release ue=${UE_ID} pdu=${pdu} by=${by}
    END

UE ng ctx release
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${by}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_ng_ctx_release id=${UE_ID} by=${by} cause=RN_radio_connection_with_ue_lost
    END

UE IDLE exit
    [Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_im_exit id=${UE_ID}
       Execute egate command
        ...    cmd=ue_ng_ctx_release id=${UE_ID} by=amf cause=RN_radio_connection_with_ue_lost
    END

Set reconf params
    [Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_nr_rrc_reconf_param id=${UE_ID} if_contains=any delay=2500s
    END

Attach UE NSA
    [Arguments]  ${ue_id_first}  ${ue_id_last}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_attach id=${UE_ID}
        sleep    2s
        Execute egate command
        ...    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
        sleep    2s
    END

Detach UE NSA
	[Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_detach id=${UE_ID}
        sleep    5s
    END

Add bearer
	[Arguments]  ${ue}  ${bearer_id_first}  ${bearer_id_last}
	FOR    ${BEARER_ID}     IN RANGE    ${bearer_id_first}       ${bearer_id_last}
        Execute egate command
        ...    cmd=bearer_add ue=${ue} id=${BEARER_ID} filter=${BEARER_ID} precedence=${BEARER_ID}
        sleep    2s
    END

Modify UEDC session
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${by}  ${bearer_to_add}  ${cause}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=enb_ue_dc_modify ue=${UE_ID} bearer_to_add=${bearer_to_add} by=${by} type=split_scg cause=${cause}
    END

Prepare test environment
    Configure  ${CONF_DIR}/enabling_miNrSSBPM.yaml

Prepare test environment -E
    Configure  ${CONF_DIR}/enabling_actMultiDrbNSA.yaml

Prepare test environment -A
	[Arguments]  ${egate_file}
    Run  sudo ifconfig eth3:GNB3_XN_ADDR 10.0.1.122/24 up
    Run  sudo ifconfig eth3:GNB3_NG_ADDR 10.0.1.123/24 up
    Run  sudo ifconfig eth3:GNB3_X2_ADDR 10.0.1.124/24 up
    Run  sudo ifconfig eth3:GNB3_S1U_ADDR 10.0.1.125/24 up
    Configure env  ${egate_file}

Activate missed rach testmodel
	[Arguments]  ${ue_id_first}  ${ue_id_last}
    Execute egate command
    ...    cmd=cont_res_testmode_nr profile_id=4 missed_ra_resp=5
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_testmode_set_nr id=${UE_ID} action=activate testmode=contention_resolution profile_id=4
        sleep    5s
    END

Activate msg3 retx testmodel
	[Arguments]  ${ue_id_first}  ${ue_id_last}
    Execute egate command
    ...    cmd=cont_res_testmode_nr profile_id=4 msg3_retx=5
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_testmode_set_nr id=${UE_ID} action=activate testmode=contention_resolution profile_id=4
        sleep    5s
    END

Send meas A3
	[Arguments]  ${ue_id_first}  ${ue_id_last}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A3 srsrp_nr=19 phycell_id=51 nrsrp_nr=100
        sleep    2s
    END

RRC reestablish
	[Arguments]  ${ue_id_first}  ${ue_id_last}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_rrc_reestablish id=${UE_ID} gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=972ms
        sleep    2s
    END
