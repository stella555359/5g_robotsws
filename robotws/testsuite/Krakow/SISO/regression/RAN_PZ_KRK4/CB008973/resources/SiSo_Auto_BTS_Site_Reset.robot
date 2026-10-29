*** Settings ***
Documentation
...   copyright: Nokia Networks
...   author: Nicol Swierczynska
...   contact: nicol.swierczynska@nokia.com

Library     taf.sbts.oam.coam.admin                 WITH NAME  admin
Library     taf/rfrl/procedures/resources/python/connections.py      WITH NAME  connections
Resource    taf/rfrl/procedures/resources/robot/StatusCheck.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    taf/rfrl/procedures/resources/robot/HWPTA_Logger.robot
Resource    taf/rfrl/procedures/resources/robot/L3Call.robot


*** Keywords ***
General_SiSo_Auto_BTS_Site_Reset
    [Documentation]
    ...             !!! IMPORTANT !! When executing test case with L3 call, if your testline is connected to programmable
    ...                              attenuator please ensure that all relevant ports are unattenuated as this test case
    ...                              will not handle attenuation.
    ...              ARGS:
    ...              - throughputs: dict with throughput and deviation values for each cell identified by
    ...                             it's nrCellIdentity for NR cells, eutranCellId for LTE cells, wnCelId for WCDMA cells;
    ...                             defaults to None (L3 call will not be executed).
    ...                             Example:
    ...                             {
    ...                                 '827736065':
    ...                                      {
    ...                                          'throughput':
    ...                                              {
    ...                                                  'downlink': '100 Mbits/sec',
    ...                                                  'uplink': '15 Mbits/sec'
    ...                                              },
    ...                                          'deviation': '90%'
    ...                                      },
    ...                             }
    ...              - protocol: data transfer protocol; defaults to UDP.
    ...              - udp_buffer: monitoring data buffer; defaults to 4M.
    ...              - tput_verification_via_btslog: True - throughput verification will be performed using btslog
    ...                                          False - throuput verification will be performed using iperf; defaults to False
    ...              - ue_network_modes: dict with UE serial numbers and desired network modes e.g. {"SN1234": "NR_only"}
    ...                                  possible UE network modes: NR_only, LTE_only, NR_LTE
    ...                                  when using more than one UE please make sure that the modes you choose are either all
    ...                                  with "_only" suffix or all "NR_LTE" as it is not yet possible to mix those.
    ...                                  mandatory for SA+NSA setups, defaults to None

    [Arguments]                              ${throughputs}=${None}
    ...                                      ${protocol}=udp
    ...                                      ${udp_buffer}=4M
    ...                                      ${tput_verification_via_btslog}=${False}
    ...                                      ${ue_network_modes}=${None}
    ...                                      ${timeout_bbmod_rmod_check}=600s
    ...                                      ${timeout_bts_and_rat_check}=60s

    ${alias}                                 connections.get_default_admin_connection_alias
    run keyword if                           ${throughputs}
    ...                                      Execute L3 call
    ...                                      throughputs=${throughputs}
    ...                                      protocol=${protocol}
    ...                                      udp_buffer=${udp_buffer}
    ...                                      tput_verification_via_btslog=${tput_verification_via_btslog}
    ...                                      ue_network_modes=${ue_network_modes}
    Robot Log Operation                      Performing reset site...
    Allow DSS Alarms If DSS On Any RMOD
    admin.reset_site                         timeout=300s   connection=${alias}
    Wait Until Keyword Succeeds  ${timeout_bbmod_rmod_check}  5s  Check all BBMODs RMODs and cells states for all RATs
    Wait Until Keyword Succeeds  ${timeout_bts_and_rat_check}  5s  Check BTS state and all RATs states
    Disallow DSS Alarms If DSS On Any RMOD
    run keyword if                           ${throughputs}
    ...                                      Execute L3 call
    ...                                      throughputs=${throughputs}
    ...                                      protocol=${protocol}
    ...                                      udp_buffer=${udp_buffer}
    ...                                      tput_verification_via_btslog=${tput_verification_via_btslog}
    ...                                      ue_network_modes=${ue_network_modes}
