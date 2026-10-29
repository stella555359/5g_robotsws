*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/verifiers.robot
Resource    ../../resources/ssh.robot
Resource    ta_messaging/single_message_observer.robot

Library     ../../../resources/Python/utilities.py
Library     ../../resources/python/mock_stop_egate.py
Library     taf.ul.ue.sim.env_setup
Library     taf.ul.generic_tshark_json_parser

*** Variables ***
${lock_nradjgnb-1}=                     ${CURDIR}/../config/NRADJGNB-1_lock.yaml
${unlock_nradjgnb-1}=                   ${CURDIR}/../config/NRADJGNB-1_unlock.yaml
${delete_nradjgnb_and_xnlink}=          ${CURDIR}/../config/DEL_NRADJGNB_and_XNLINK.yaml
${delete_3nradjgnb_and_3xnlink}=        ${CURDIR}/../config/DEL_3NRADJGNB_and_3XNLINK.yaml
${setup_nradjgnb_and_xnlink}=           ${CURDIR}/../config/SETUP_NRADJGNB_and_XNLINK.yaml
${setup_nradjgnb_and_2_xnlink}=         ${CURDIR}/../config/SETUP_NRADJGNB_and_2_XNLINK.yaml
${setup_xnlink-1}=                      ${CURDIR}/../config/SETUP_XNLINK-1.yaml
${setup_xnlink-3}=                      ${CURDIR}/../config/SETUP_XNLINK-3.yaml

*** Keywords ***
Run Setup
    [Arguments]        ${f1ap}=${True}     ${ute-ca}=${False}
    Log To Console    Setup started
    Setup emss    node_id=1
    ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!

    Run Keyword if  ${run_update} != ${False} and ${ute-ca} == ${False}
    ...    Full env setup

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.31
    Create GNB device with alias 'gNB4' identified by ip=10.0.1.33
    Create GNB device with alias 'gNB5' identified by ip=10.0.1.35
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Full env setup
    Log To Console    Configure ENV with LUA
    add 5gc  config=${LUA_CFG}  edaemon_ports=10000
    configure environment       rmod_detection_timeout=300s
    Log To Console    After Configure ENV
    Do not stop egate and daemon

Lock NRADJGNB-${nradjgnb_id:\d+}
    Configure  ${lock_nradjgnb-1}

Unlock NRADJGNB-${cell_id:\d+}
    Configure  ${unlock_nradjgnb-1}

Create sctp json source
    create json source
    ...    tshark_command=tshark -i eth3 -T json -f 'sctp' -l
    ...    source_alias=eth3_sctp
    ...    filter_as_query=sctp.chunk_type is present
    ...    start=${True}

Expect that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} will be terminated
    expect for records
    ...     sctp.chunk_type eq "7" and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq "8" and ip.src eq "${ip_addr_dst}"
    ...     sctp.chunk_type eq "14" and ip.src eq "${ip_addr_src}"
    ...     expect_alias=sctp_shutdown_shutdownack_shutdowncomplete_${ip_addr_dst}
    ...     timeout=60

Expect that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} will be established
    expect for records
    ...     sctp.chunk_type eq '1' and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq '2' and ip.src eq "${ip_addr_dst}"
    ...     sctp.chunk_type eq '10' and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq '11' and ip.src eq "${ip_addr_dst}"
    ...     expect_alias=sctp_init_initack_cookieecho_cookieack_${ip_addr_dst}
    ...     timeout=60

Verify that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} has been terminated
    verify that records occurred
    ...     expect_alias=sctp_shutdown_shutdownack_shutdowncomplete_${ip_addr_dst}

Verify that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} has been established
    verify that records occurred
    ...     expect_alias=sctp_init_initack_cookieecho_cookieack_${ip_addr_dst}

Set XN Setup timers: xnSetupRespTmr=${xn_setup_timer:\d+} retryXnSetupTmr=${xn_setup_retry:\d+}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'xnSetupRespTmr': '${xn_setup_timer}', 'retryXnSetupTmr': '${xn_setup_retry}'}

Trigger gNB${gnb_id:\d+} to NOT respond to ${msg_number:\d+} XN:SetupRequest message
    Execute egate command
    ...     cmd=gnb_xn_setup_param id=${gnb_id} action=drop nth=${msg_number}

Trigger gNB${gnb_id:\d+} to respond to ${msg_number:\d+} XN:SetupRequest message by sending hex with wrong globalGNb
    Execute egate command
    ...     cmd=gnb_xn_setup_param id=${gnb_id} action=override_resp nth=${msg_number} hex=${xnSetupResponse_wrong_globalgNB}

Verify NRADJGNB-${nradjgnb_id:\d+} status is set to ${status}
    Object attributes should be    NRADJGNB-${nradjgnb_id}    administrativeState=${status}

Verify XNLINK-${xnlink_id:\d+} status is set to ${status}
    Object attributes should be    XNLINK-${xnlink_id}    xnLinkStatus=${status}

Verify NRADJGNB-${nradjgnb_id:\d+} amfRegionInformation section is present
    Check if attribute exists      NRADJGNB-${nradjgnb_id}    amfRegionInformation
