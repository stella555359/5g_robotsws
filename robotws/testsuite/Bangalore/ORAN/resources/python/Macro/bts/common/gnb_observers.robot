*** Settings ***
Documentation     Keywords for syslog observers

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.observers.GnbObservers    WITH NAME      gnbobservers

*** Keywords ***
Start drop X2 link observer
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]  Start drop X2 link observer on passed gNB and collect snapshot when event occurred.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    Log to console  to jest nasze id ${gnb_id}
    gnbobservers.start_drop_x2_link_observer    gnb_id=${gnb_id}    du_id=${du_id}

Stop drop X2 link observer
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]  Stop drop X2 link observer on passed gNB.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbobservers.stop_drop_x2_link_observer    gnb_id=${gnb_id}    du_id=${du_id}

Verify gNB Responds
    [Arguments]   ${gnb_id}=0   ${bts_ip}=192.168.255.129   ${timeout}=${120}    ${du_id}=${0}
    [Documentation]  Chceck if eNB is on, and response
    ...     :param gnb_id:    gNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param gnb_ip:    gNB ip - related to Test Line configuration.
    gnbobservers.verify_host_response   bts_id=${gnb_id}   bts_ip=${bts_ip}   timeout=${timeout}    du_id=${du_id}

Verify gNB Does Not Respond
    [Arguments]   ${gnb_id}=0   ${bts_ip}=192.168.255.129   ${timeout}=${120}    ${du_id}=${0}
    [Documentation]  Chceck if eNB is off, and response
    ...     :param gnb_id:    gNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param gnb_ip:    gNB ip - related to Test Line configuration.
    gnbobservers.verify_host_no_response   bts_id=${gnb_id}   bts_ip=${bts_ip}   timeout=${timeout}    du_id=${du_id}

Start monitoring gnb online status
    [Arguments]    ${bts_id}=${0}  ${du_id}=${0}
    [Documentation]    Start executing recovery action site reset observer on passed bts.
        ...    Use Verify site reset not occurred keyword to verify if site reset occurred.
        ...    :param bts_id: bts id - related to Test Line configuration.
        ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbobservers.start_monitoring_gnb_online_status    bts_id=${bts_id}    du_id=${du_id}

Verify site reset not occurred
    [Documentation]    Verify if site reset occurred.
        ...    Start monitoring gnb online status keyword should be called firstly.
        ...    :raises: UnexpectedBtsResetOccurred
    gnbobservers.verify_site_reset_not_occurred
