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
Library     taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library     ../../resources/former_l2_sw1/python/common_keywords.py
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     CB008285_resources.py    WITH NAME   local_resources
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${CONF_DIR}=             /home/ute/test_repository/testsuite/Krakow/RRM/Airphone/CB008285/config

*** Keywords ***
Attach UE SA
    [Arguments]  ${ue_id_first}  ${ue_id_last}  ${pdu}  ${nwslice}  ${nwslice_reg}
    FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=set_pdu_param ue=${UE_ID} pdu=${pdu} trf_type=internal
        sleep    2s
        Execute egate command
        ...    cmd=ue_register id=${UE_ID} nwslice=${nwslice_reg}
        sleep    2s
        Execute egate command
        ...    cmd=ue_pdu_session_setup pdu=${pdu} ue=${UE_ID} nwslice=${nwslice} gw=1
        sleep    2s
    END

Detach UE SA
	[Arguments]  ${ue_id_first}  ${ue_id_last}
	FOR    ${UE_ID}     IN RANGE    ${ue_id_first}       ${ue_id_last}
        Execute egate command
        ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    END

Add PDU session
	[Arguments]  ${ue_id}    ${pdu}    ${nwslice}
	logger.log_info_to_console    Adding PDU ${pdu} to UE ${ue_id}
    Execute egate command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute egate command    cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=1

Attach UE NSA
    [Arguments]  ${ue_id_first}  ${ue_id_last}
    Execute egate command    cmd=enb_x2_link_up enb=1 target=2
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

Run traffic SA
	[Arguments]  ${ue_id}    ${dir}    ${loop}    ${mbps}    ${pdu}    ${protocol}
	FOR    ${trf_id}     IN RANGE    1       ${loop}
        Execute egate command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=${dir} mbps=${mbps} trf_id=${trf_id} protocol=${protocol}
        sleep    2s
    END

Check Only Default AMF ngLinkStatus
    [Arguments]     ${status}
    local_resources.check_amf_nglink_status    status=${status}    only_default=${True}

Lock default AMF
    Configure  ${CONF_DIR}/locking_AMF.yaml

Unlock default AMF
    Configure  ${CONF_DIR}/unlocking_AMF.yaml

Check All AMF ngLinkStatus
    [Arguments]     ${status}
    local_resources.check_amf_nglink_status    status=${status}

Prepare test environment 2AMF
	[Arguments]  ${egate_file_AMF}  ${scfc_AMF}  ${ap_xml_AMF}
    Run  sudo ifconfig eth3:AMF2 10.0.1.101/24 up
    Configure env  egate_setup=${egate_file_AMF}  scfc=${scfc_AMF}  ap_xml=${ap_xml_AMF}

Prepare test environment FR1
	[Arguments]  ${egate_file_FR1}  ${scfc_FR1}  ${ap_xml_FR1}
    Configure env  egate_setup=${egate_file_FR1}  scfc=${scfc_FR1}  ap_xml=${ap_xml_FR1}
