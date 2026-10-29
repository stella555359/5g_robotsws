*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    CB008490-common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${nea_nia}=          ${CURDIR}/../config/yaml/B401_nea_nia.yaml
${rtpm_activate}=    ${CURDIR}/../config/yaml/rtpm_activate.yaml
${pmqap_profile}=    ${CURDIR}/../config/yaml/NRPMQAP_profile.yaml
${B104_2}=           ${CURDIR}/../config/yaml/DD_B104_2_SN.yaml
${B104_3}=           ${CURDIR}/../config/yaml/DD_B104_3_SN.yaml
${B104_4}=           ${CURDIR}/../config/yaml/DD_B104_4_MN.yaml
${B104_default}=     ${CURDIR}/../config/yaml/DD_B104_default_SN.yaml

*** Keywords ***
Prepare test environment CB008490-B
    Basic prepare

Prepare test environment CB008490-B_CFRA
    Log To Console    Configuring CFRA in SN gNB
#    Configure    {'MOC': 'NRCELL', 'ID': '2', 'cbraPreamblesPerSsb': 'n32'}  bts_id=2   TILL support of NRDCSN cell reconfigs
    Prepare test environment CB008490-B

Cleanup test environment CB008490-B_CFRA
    Log To Console    Deconfiguring CFRA from SN gNB
#    Configure    {'MOC': 'NRCELL', 'ID': '2', 'cbraPreamblesPerSsb': 'n64'}  bts_id=2    TILL support of NRDCSN cell reconfigs
    Basic cleanup

Prepare test environment CB008490-B201-2
    Log To Console    Configuring params inside x2FlowControlProfForCu in SN gNB
    Configure   ${yaml_B201_2}    bts_id=2
    Prepare test environment CB008490-B

Cleanup test environment CB008490-B201-2
    Log To Console    Deconfiguring params x2FlowControlProfForCu to default in SN gNB
    Configure   ${yaml_B201_2_revert}    bts_id=2
    Basic cleanup

Prepare test environment CB008490-B-B202
    Log To Console    Prepare test
    Configure    {'MOC': 'NRBTS', 'ID': '3', 'activityNotificationLevelSA': 'drb'}  bts_id=2
    Basic prepare

Basic prepare
    Wait 30s for cells [1] operationalState change to [enabled]
    Wait Until Keyword Succeeds  60s  10s
    ...    Object state should be    NRCELL-2    OPERATIONAL    enabled    bts_id=2
    start collecting syslog from gnbs

Basic cleanup
    Trigger UEs from 1 to 20 to send deregister request
    stop collecting syslog and download files
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-C-B1
    Log To Console    Prepare test CB008490-C-B1
    Execute egate command    cmd=amf_ue_ctx_release_param id=1 ue=1 action=override_cause cause=NAS_deregister
    Basic prepare

Prepare test environment CB008490-C-B2
    Log To Console    Prepare test CB008490-C-B2
    Basic prepare

C-B1 cleanup
    Log to console    Cleanup after test C-B1
    Detach and kill UE1
    Execute egate command    cmd=amf_ue_ctx_release_param id=1 ue=1 reset
    stop collecting syslog and download files
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

C-B2 cleanup
    Log to console    Cleanup after test C-B2
    Detach and kill UE1
    Execute egate command   cmd=ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1
    Execute egate command   cmd=rlf_testmode_nr profile_id=1 delete=true
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    stop collecting syslog and download files

Prepare test environment CB008490-E-B3
    Log To Console    Prepare test CB008490-E-B3
    Configure    ${yaml_E_B3}
    discover bts   bts_id=1
    Create AMF device with alias 'AMF2' identified by ip=10.0.1.11
    Create AMF device with alias 'AMF3' identified by ip=10.0.1.12
    Wait 30s for cells [1] operationalState change to [enabled]
    Wait Until Keyword Succeeds    2 min    5 sec    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2
    start collecting syslog from gnbs

E-B3 cleanup
    Log to console    Cleanup after test E-B3
    Detach and kill UE1
    Unlock NG-C link to AMF2
    Unlock NG-C link to AMF1
    stop collecting syslog and download files
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-E-B4
    Log To Console    Prepare test CB008490-E-B4
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB3 and real gNB2
    Object attributes should be    XNLINK-2    xnLinkStatus=available    bts_id=1
    Wait 30s for cells [1] operationalState change to [enabled]
    Activate RTPM    bts_id=1
    short_syslog.start collecting syslog        prefix=CB008490-E-B4

E-B4 cleanup
    Log to console    Cleanup after test E-B4
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-E-B1
    Log To Console    Prepare test CB008490-E-B1
    Basic prepare
    ${config1}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'sameGNB'}, {'MOC': 'NRCELL', 'rlpDetCsiBsiThreshold': '10'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'tRLFindForDUSA': '300ms'}]
    Configure    ${config1}    bts_id=1
    ${config2}    Catenate    [{'MOC': 'NRBTS', 'ID': '3', 'rrcReestabTypeSA': 'sameGNB'}, {'MOC': 'NRCELL', 'rlpDetCsiBsiThreshold': '0'},
    ...                      {'MOC': 'NRCELL', 'rlpDetDlHarqThreshold': '0'}]
    Configure    ${config2}    bts_id=2
    Wait Until Keyword Succeeds  300s  10s
    ...    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2

CB008490-E-B1 cleanup
    Log to console    Cleanup after test E-B1
    stop collecting syslog and download files
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-E-B2
    Log To Console    Prepare test CB008490-E-B2
    Basic prepare
#    Configure    ${yaml_E_B2}    bts_id=1    use_admin=True
    sleep    10

Prepare test environment CB008490-E-B204
    Log To Console    Prepare test CB008490-E-B204
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Wait 30s for cells [2] operationalState change to [enabled]
    short_syslog.start collecting syslog        prefix=CB008490-E-B204
    Execute egate command    cmd=gnb_nrdc_param id=2 allowed_bc_list_mrdc=1:1
    Execute egate command    cmd=ue_gnb_context_release_param id=1 gnb_id=2 action=skip_sending

CB008490-E-B204 cleanup
    Log to console    Cleanup after test E-B204
    short_syslog.stop collecting syslog
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB008490-E-B2 cleanup
    Log to console    Cleanup after test E-B2
    stop collecting syslog and download files
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB008490-E-B2-ErrorIndication cleanup
    Log to console    Cleanup after test E-B2
    stop collecting syslog and download files
    Detach and kill UE1
    Detach and kill UE2
    Execute egate command    cmd=amf_ue_ctx_release_param id=1 ue=1 reset
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

D-B101 cleanup
    Set indexToRFSP for UE1 to 1 using DL NAS Transport message
    Detach and kill UE1
    stop collecting syslog and download files
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-D-B301_CRT
    Log To Console    Configure RAC parameteres on SN gNB
    Configure   ${yaml_B301_CRT_1}    bts_id=2
    Activate RTPM    bts_id=1
    Activate RTPM    bts_id=2
    Basic prepare

Prepare test environment CB008490-D-B301_1
    Log To Console    Configure RAC parameteres on SN gNB
    Configure   ${yaml_B301_1}    bts_id=2
    Basic prepare

Cleanup test environment CB008490-D-B301_1
    Log To Console    Configure default RAC parameteres on SN gNB
    Configure   ${yaml_B301_1_revert}    bts_id=2
    Basic cleanup

Prepare test environment CB008490-D-B301_3
    Log To Console    Configure RAC parameteres on SN gNB
    Configure    {'MOC': 'NRDU', 'ID': '1', 'maxNumOfRrcConUEsPerDU': '1'}  bts_id=2
    Basic prepare

Cleanup test environment CB008490-D-B301_3
    Log To Console    Configure default RAC parameteres on SN gNB
    Configure    {'MOC': 'NRDU', 'ID': '1', 'maxNumOfRrcConUEsPerDU': '26928'}  bts_id=2
    Basic cleanup

Prepare test environment CB008490-D-B301_4
    Log To Console    Configure Load Balancing parameteres on SN gNB
    Configure   ${yaml_B301_4}    bts_id=2
    Basic prepare

Cleanup test environment CB008490-D-B301_4
    Log To Console    Configure default Load Balancing parameteres on SN gNB
    Configure   ${yaml_B301_4_revert}    bts_id=2
    Basic cleanup

Prepare test environment CB008490-D-B301 RAD
    Connect using ssh to    gNB_CLASSICAL_OAM
    Change RandD parameters common keyword
    Backup and modify swconfig file    parameters_list=@{SWCONFIG_FLAGS_LIST}
    Delete HashContainer files    gNB_CLASSICAL_OAM
    Run Keyword And Ignore Error    Trigger site reset
    Wait for testline ICMP Echo replies and SSH services
    sleep    60
    wait_until_given_number_of_radio_modules_is_up    rmod_count=1    # checking only in MN gNB
    Wait for gnb to reach configured state

    Basic prepare

Prepare test environment CB008490-D-B401_1 with security indication set to ${sec_ind}
    Basic prepare
    Set security indication to ${sec_ind} on AMF
    Set nea to [0,3,4,2] and nia to [0,3,4,2] for MN gNB
    Set nea to [0,3,0,0] and nia to [0,3,0,0] for SN gNB

Prepare test environment CB008490-D-B401_2 with security indication set to ${sec_ind}
    Basic prepare
    Set security indication to ${sec_ind} on AMF
    Set nea to [1,0,0,0] and nia to [0,3,0,0] for MN gNB
    Set nea to [1,0,0,0] and nia to [0,0,3,0] for SN gNB
    Set Test Variable    ${encryption}    ${False}

Prepare test environment CB008490-D-B401_5 with security indication set to ${sec_ind}
    Basic prepare
    Set security indication to ${sec_ind} on AMF
    Set nea to [0,1,4,2] and nia to [0,1,4,2] for MN gNB
    Set nea to [0,2,5,1] and nia to [0,2,5,1] for SN gNB

Prepare test environment CB008490-D-B401_5_6 with security indication set to ${sec_ind}
    Basic prepare
    Set security indication to ${sec_ind} on AMF
    Set nea to [1,0,0,0] and nia to [0,1,4,2] for MN gNB
    Set nea to [1,0,0,0] and nia to [0,2,5,1] for SN gNB
    Set Test Variable    ${encryption}    ${False}

Prepare test environment CB008490-D-B401_6 with security indication set to ${sec_ind}
    Basic prepare
    Set security indication to ${sec_ind} on AMF
    Set nea to [0,1,4,2] and nia to [0,1,4,2] for MN gNB
    Set nea to [0,2,5,1] and nia to [0,2,5,1] for SN gNB
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'actUPIPSupportForPreferred': 'false'}  bts_id=1

D-B401_1 cleanup
    Basic cleanup
    Set security indication to not needed on AMF
    Activate UPIP in SN gNB

D-B401_2 cleanup
    Basic cleanup
    Set security indication to not needed on AMF

D-B401_6 cleanup
    Basic cleanup
    Set security indication to not needed on AMF
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'actUPIPSupportForPreferred': 'true'}  bts_id=1

Set nea to [${nea_str}] and nia to [${nia_str}] for ${gnb:MN|SN} gNB
    [Documentation]    Example usage:
    ...    Set nea to [9,0,0,0] and nia to [0,3,4,2] for MN gNB
    ...    Set nea to [1,2,4,3] and nia to [0,2,4,2] for SN gNB

    ${bts_id}=      Set Variable If    '${gnb}'=='MN'    1    2
    ${nrbts_id}=    Set Variable If    '${gnb}'=='MN'    2    3

    @{nea_list}    Split To List    ${nea_str}
    @{nia_list}    Split To List    ${nia_str}

    set enb parameter value    param_path=NRBTS.id        value=${nrbts_id}       bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nea0    value=${nea_list}[0]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nea1    value=${nea_list}[1]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nea2    value=${nea_list}[2]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nea3    value=${nea_list}[3]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nia0    value=${nia_list}[0]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nia1    value=${nia_list}[1]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nia2    value=${nia_list}[2]    bts_id=${bts_id}
    set enb parameter value    param_path=NRBTS.nia3    value=${nia_list}[3]    bts_id=${bts_id}

    Configure   ${nea_nia}    bts_id=${bts_id}

Activate RTPM
    [Arguments]    ${bts_id}=1

    ${nrbts_name}=    get_LNBTS_object_name    bts_id=${bts_id}
    ${nrbts_id}=    get_last_char    ${nrbts_name}
    ${port_num}=    Set Variable If    '${bts_id}'=='1'    39001    39002

    Run keyword and ignore error    rtpm_activate    bts_id=${bts_id}    # needed for emssim to create own files

    set enb parameter value    param_path=NRBTS.id        value=${nrbts_id}       bts_id=${bts_id}
    set enb parameter value    param_path=rTPmCollEntityPortNum      value=${port_num}       bts_id=${bts_id}
    Configure   ${rtpm_activate}    bts_id=${bts_id}    use_admin=True

Configure NRPMQAP profile
    [Arguments]    ${bts_id}=1
    ${nrbts_name}=    get_LNBTS_object_name    bts_id=${bts_id}
    ${nrbts_id}=    get_last_char    ${nrbts_name}
    set enb parameter value    param_path=NRBTS.id        value=${nrbts_id}       bts_id=${bts_id}
    Configure   ${pmqap_profile}    bts_id=${bts_id}    use_admin=True

Set default nea and nia values for ${gnb:MN|SN} gNB
    Set nea to [9,0,0,0] and nia to [0,3,4,2] for ${gnb} gNB

Prepare test environment CB008490-M-B11
    Log To Console    Prepare test CB008490-M-B11
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available

    Execute egate command    cmd=gnb_param measEvent=A3 id=4

    Start observing measurements  UE_1  technology=5G

    Configure   ${yaml_A2_redirection}

    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '2', 'actNrDualConnectivity': 'disabled'},
    ...                       {'MOC': 'NRCELL', 'ID': '2', 'a2MeasRedirectEnabled': 'none'}]

    Configure    ${config}

    short_syslog.start collecting syslog        prefix=CB008490-M

Prepare test environment CB008490-M-B12
    Log to console    Start test M-B12
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    short_syslog.start collecting syslog        prefix=CB008490-M

Prepare test environment CB008490-M-B12-B13
    Log to console    Start test M-B12-B13
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    Configure   ${yaml_A2_redirection}
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'srbInactivityTimerSA': '60'}  bts_id=1

    short_syslog.start collecting syslog        prefix=CB008490-M

Prepare test environment CB008490-M-B12-B13-B102
    Log To Console    Prepare test CB008490-M-MFBI
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actNrDualConnectivity': 'disabled'}
    Configure   ${yaml_A2_redirection}

    short_syslog.start collecting syslog        prefix=CB008490-M

Prepare test environment CB008490-M-B1702
    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'true'},
    ...                       {'MOC': 'NRCELL', 'ID': '1', 'a4PeriodicMeasControlSA': [{'a4RetryTimer': '60'}]}]
    Configure    ${config}    use_admin=True

    short_syslog.start collecting syslog        prefix=CB008490-M-B17

Prepare test environment CB008490-M-B1801
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'a4PeriodicMeasControlSA': [{'a4RetryTimer': '10'}]}
    Basic prepare

Prepare test environment CB008490-M-B101
    Log To Console    Prepare test CB008490-M-B101
    Configure   ${yaml_A2_redirection}

    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '2', 'actNrDualConnectivity': 'disabled'},
    ...                       {'MOC': 'NRCELL', 'ID': '2', 'a2MeasRedirectEnabled': 'none']

    Configure    ${config}

    short_syslog.start collecting syslog        prefix=CB008490-M-B101

Prepare test environment CB008490-M-B102
    Log To Console    Prepare test CB008490-M-102
    Configure    {'MOC': 'NRCELL', 'ID': '2', 'actNrDualConnectivity': 'disabled'}
    short_syslog.start collecting syslog        prefix=CB008490-M-B102

CB008490-M-B1702 cleanup
    Log to console    Cleanup after test M-B1702
    Basic cleanup sim SN
    Activate CB008490 FAF on NRCELL-1
    Modify NRHOIF-1 ssbFrequency to 2071387

Basic cleanup sim SN
    Trigger UEs from 1 to 60 to send deregister request
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-MB-401
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'cuOvlHa': [{'ovlSaMeasDiscard': 'enabled'}]}]
    Configure    ${config}    use_admin=True
    Activate RTPM
    short_syslog.start collecting syslog        prefix=MB-401_

MB-401 cleanup
    Detach and kill UE1
    short_syslog.stop collecting syslog
    Perform CPLANE OVL deactivation via R&D mechanism
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-MB-501 on simMN
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Object attributes should be    XNLINK-1    xnLinkStatus=available    bts_id=2
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '3', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '3', 'cuOvlHa': [{'ovlNsaAddRej': 'enabled'}]}]
    Configure    ${config}    bts_id=2
    Activate RTPM    bts_id=2
    Prepare Sim gNB2
    short_syslog.start collecting syslog        prefix=MB-501_

Prepare test environment CB008490-MB-501 on real gNBs
    Wait Until Keyword Succeeds  60s  10s
    ...    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '3', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '3', 'cuOvlHa': [{'ovlNsaAddRej': 'enabled'}]}]
    Configure    ${config}    bts_id=2
    Activate RTPM    bts_id=1
    Activate RTPM    bts_id=2
    start collecting syslog from gnbs

MB-501 cleanup
    Detach and kill UE1
    short_syslog.stop collecting syslog
    Enable UE Capture On Simulated Enb  enable=${False}
    Perform CPLANE OVL deactivation via R&D mechanism
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-MB-601
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'cuOvlHa': [{'ovlSaA4TimerDiscard': 'enabled'}]}]
    Configure    ${config}

    short_syslog.start collecting syslog        prefix=MB-601_

Prepare test environment CB008490-MB-701
    Basic prepare
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'cuOvlHa': [{'ovlSaA4TimerDiscard': 'enabled'}]},
    ...                       {'MOC': 'NRCELL', 'ID': '1', 'a4PeriodicMeasControlSA': [{'a4RetryTimer': '10'}]}]
    Configure    ${config}    bts_id=1

MB-701 cleanup
    Basic cleanup
    Perform CPLANE OVL deactivation via R&D mechanism
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare Sim gNB${gnb_id}
    Execute Egate Command
    ...    cmd=gnb_nrdc_param id=${gnb_id} allowed_bc_list_mrdc=1:1

Prepare test environment CB008490-DC-B101_1
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'actInterGnbRREPreparedCell': 'true'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'sameGNB'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'actPucchF3BasedTaGrantsRed': 'false'}]
    Configure    ${config}
    Prepare RRC Reestablishment during XN HO from gNB4 for UE1
    Configure ue_history for UE1 to enable handovers from gNB4
    Wait For Next Full Pm Interval
    short_syslog.start collecting syslog        prefix=DC-101_

DC-B101_1 cleanup
    Execute egate command
    ...    cmd=ue_history_information_list id=1 action=reset
    Basic cleanup sim SN

Prepare test environment CB008490-EB-B301
    Log To Console    Prepare test CB008490-EB-B301
    start collecting syslog from gnbs
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'viaRRCSetup'}    bts_id=1
    Basic prepare

EB-B301 cleanup
    Log to console    Cleanup after test EB-B301
    stop collecting syslog and download files
    Detach and kill UE1
    Set NRADJGNB-7.administrativeState to Unlocked on bts-1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-EB-B302_1
    Log To Console    Prepare test CB008490-EB-B302_1
    Basic prepare
    Setup connection to admin  ${ADMIN_CONNECTION}
    set suite variable    ${ADMIN_gNB1}    ${ADMIN_CONNECTION}

EB-B302_1 cleanup
    Log to console    Cleanup after test EB-B302_1
    stop collecting syslog and download files
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-EB-B302_2
    Log To Console    Prepare test CB008490-EB-B302_2
    Basic prepare
    Setup connection to admin  ${ADMIN_CONNECTION}
    ${connection_gnb2}=    coam.setup_admin    bts_host=10.0.1.4    name=gNB2
    set suite variable    ${ADMIN_gNB2}    ${connection_gnb2}

EB-B302_2 cleanup
    Log to console    Cleanup after test EB-B302_2
    stop collecting syslog and download files
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-QBW
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available

    Configure ue_history for UE10 to enable handovers from gNB4
    Execute egate command    cmd=uec_param id=1 srb_reordering_enabled=off
    short_syslog.start collecting syslog        prefix=QBW_

QBW cleanup
    Execute egate command
    ...    cmd=ue_history_information_list id=10 action=reset
    Basic cleanup sim SN

Prepare test environment CB008490-QR
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available
    Configure ue_history for UE13 to enable handovers from gNB4
    short_syslog.start collecting syslog        prefix=QR_

Prepare test environment CB008490-EB-B101
    Log To Console    Prepare test CB008490-EB-B101
    Create GNB device with alias 'gNB4' identified by ip=10.0.1.6
    Create GNB device with alias 'gNB5' identified by ip=10.0.1.8
    Wait 30s for cells [1] operationalState change to [enabled]
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'viaRRCSetup'}    bts_id=1
    short_syslog.start collecting syslog        prefix=CB008490-EB-B101
    execute egate command    cmd=ng_link_reset_param action=none cause=TRANSPORT_transport_resource_unavailable id=1

EB-B101 cleanup
    Log to console    Cleanup after test EB-B101
    Detach and kill UE1
    Detach and kill UE2
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-EB-B201
    Log To Console    Prepare test CB008490-EB-B201
    Wait 30s for cells [1] operationalState change to [enabled]
    Create GNB device with alias 'gNB4' identified by ip=10.0.1.6
    Create GNB device with alias 'gNB5' identified by ip=10.0.1.8
    short_syslog.start collecting syslog        prefix=CB008490-EB-B101

EB-B201 cleanup
    Log to console    Cleanup after test EB-B201
    Restore F1 SCTP connection on MN gNB
    Detach and kill UE1
    Detach and kill UE2
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-EB-B202
    Basic prepare
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'viaRRCSetup'}    bts_id=1

EB-202 cleanup
    Run keyword and ignore error
    ...    Restore F1 SCTP connection on SN gNB
    Trigger UEs from 21 to 55 to send deregister request
    Basic cleanup

Prepare test environment CB008490-EB-B102
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Wait 60s for cells [2, 3, 4] operationalState change to [enabled, enabled, enabled]
    Object attributes should be    XNLINK-1    xnLinkStatus=available    bts_id=2
    Prepare Sim gNB2
    short_syslog.start collecting syslog        prefix=EB-B102_

EB-102 cleanup
    Detach and kill UE2
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-DD-B103_1
    Basic prepare
    Configure inactivity on MN gNB: SRB=5, DRB=10, NotificationLevel=ue
    Configure inactivity on SN gNB: SRB=600, DRB=5, NotificationLevel=ue

Prepare test environment CB008490-DD-B103_2
    Basic prepare
    Configure inactivity on MN gNB: SRB=5, DRB=10, NotificationLevel=drb
    Configure inactivity on SN gNB: SRB=600, DRB=5, NotificationLevel=ue

Prepare test environment CB008490-DD-B103_5
    Basic prepare
    Configure inactivity on MN gNB: SRB=40, DRB=10, NotificationLevel=ue
    Configure inactivity on SN gNB: SRB=600, DRB=5, NotificationLevel=drb

Prepare test environment CB008490-DD-B101
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    short_syslog.start collecting syslog        prefix=DD-B101_1_
    Configure inactivity on MN gNB: SRB=4, DRB=10, NotificationLevel=ue

Prepare test environment CB008490-E-B203
    Log To Console    Prepare test CB008490-E-B203

    Wait 30s for cells [1] operationalState change to [enabled]
    short_syslog.start collecting syslog        prefix=CB008490-E-B203
    Execute egate command    cmd=ue_gnb_snode_release_request_param id=1 action=drop gnb_id=3

CB008490-E-B203 cleanup
    Log to console    Cleanup after test E-B203
    Execute egate command    cmd=ue_gnb_snode_release_request_param id=1 action=none gnb_id=3
    short_syslog.stop collecting syslog
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-DE-EC201
    Log To Console    Prepare test CB008490-DE-EC201
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Wait 30s for cells [2] operationalState change to [enabled]
    short_syslog.start collecting syslog        prefix=CB008490-DE-EC201
    Execute egate command    cmd=gnb_snode_addition_request_param action=override_ie remove_available_drb_ids=on id=2

DE-EC201 cleanup
    Detach and kill UE1
    Execute egate command    cmd=gnb_snode_addition_request_param action=none id=2
    short_syslog.stop collecting syslog
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-DD-B104_2
    Basic prepare
    Configure inactivity on MN gNB: SRB=5, DRB=10, NotificationLevel=ue
    Configure    ${B104_2}    bts_id=2

Prepare test environment CB008490-DD-B104_3
    Basic prepare
    Configure inactivity on MN gNB: SRB=5, DRB=10, NotificationLevel=ue
    Configure    ${B104_3}    bts_id=2

CB008490-DD-B104_2 cleanup
    Basic cleanup
    Configure    ${B104_default}    bts_id=2

Prepare test environment CB008490-DD-104
    Configure inactivity on MN gNB: SRB=4, DRB=10, NotificationLevel=drb
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'actSpidRfspInactTimers': 'true'},
    ...                       {'MOC': 'NRRFSP_PROFILE', 'ID': '1', 'rfsp': '1'},
    ...                       {'MOC': 'NRRFSP_PROFILE', 'ID': '1', 'rfspInactivityTimer': '15'}]

    Configure    ${config}

CB008490-DD-104 cleanup
    Basic cleanup sim SN
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'actSpidRfspInactTimers': 'false'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'actAdditionalSliceSupport ': 'false'},]

    Configure    ${config}

Prepare CB008490-DD-B104_4 part
    Configure    ${B104_4}    bts_id=1

Prepare test environment CB008490-DA
    Wait 30s for cells [1] operationalState change to [enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Create GNB device with alias 'gNB4' identified by ip=10.0.1.6
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'timerRRCGuard': '2500'}    bts_id=1
    Activate RTPM    bts_id=1
    short_syslog.start collecting syslog        prefix=DA_

DA cleanup
    Configure sim SN gNB3 to send correct XNAP:SNodeAdditionRequestAcknowledge message
    Remove delay before sending RRC:RRCReconfigurationComplete from UE3
    Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm without PDUSessionResourceFailedToModifyList for UE4
    Basic cleanup sim SN

Prepare test environment CB008490-DC-B103
    Activate RTPM    bts_id=1
    Activate RTPM    bts_id=2
    Configure    ${yaml_DC}    bts_id=2
    start collecting syslog from gnbs

Prepare test environment CB008490-DB-B101_1
    Wait 30s for cells [1] operationalState change to [enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    short_syslog.start collecting syslog        prefix=CB008490-DB-B101_1
    Set security indication to required on AMF

CB008490-DB-B101_1 cleanup
    short_syslog.stop collecting syslog
    Detach and kill UE1
    Set security indication to not needed on AMF

Prepare test environment CB008490-DB-201
    Wait 30s for cells [1] operationalState change to [enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'tRLFindForDUSA': '500ms'}
    Configure sim SN gNB3 to not send XNAP:SNodeAdditionRequestAcknowledge
    Activate RTPM    bts_id=1
    short_syslog.start collecting syslog        prefix=DB_201_

Prepare test environment CB008490-SR-DB_B201_3_5_B301_1
    Configure    [{'MOC': 'NRBTS', 'ID': '2', 'tRLFindForDUSA': '300ms'}, {'MOC': 'NRBTS', 'ID': '2', 'timerRRCGuard': '4000'}]
    Basic prepare
    Configure UE1 to not send rrcReconfigurationComplete
    Configure UE2 to not send rrcReconfigurationComplete

CB008490-SR-DB_B201_3_5_B301_1 cleanup
    Basic cleanup
    Configure UE1 to send rrcReconfigurationComplete
    Configure UE2 to send rrcReconfigurationComplete
    Execute egate command   cmd=ue_testmode_set_nr id=2 testmode=rlf action=deactivate profile_id=1
    Execute egate command   cmd=rlf_testmode_nr profile_id=1 delete=true

CB008490-DB-201 cleanup
    Basic cleanup sim SN
    Execute egate command   cmd=ue_testmode_set_nr id=4 testmode=rlf action=deactivate profile_id=1
    Execute egate command   cmd=rlf_testmode_nr profile_id=1 delete=true

Prepare test environment CB008490-MA-B101_1
    Wait 30s for cells [1] operationalState change to [enabled]
    Configure    ${CURDIR}/../config/yaml/MA_blockTimer_activate.yaml
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'sameGNB'}    bts_id=1
    short_syslog.start collecting syslog        prefix=CB008490-MA

Prepare test environment CB008490-MA-B101_2
    Wait 30s for cells [1] operationalState change to [enabled]
    Configure    ${CURDIR}/../config/yaml/MA_blockTimer_off.yaml
    short_syslog.start collecting syslog        prefix=CB008490-MA

CB008490-MA-B101 cleanup
    Detach and kill UE1
    Detach and kill UE2
    Deconfigure all
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    short_syslog.stop collecting syslog

Prepare test environment CB008490-MA-B102
    Wait 30s for cells [1] operationalState change to [enabled]
    Configure    ${CURDIR}/../config/yaml/MA_blockTimer_activate.yaml
    Configure    {'MOC': 'NRBTS', 'ID': '2', 'rrcReestabTypeSA': 'sameGNB'}    bts_id=1
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available

    Execute egate command    cmd=gnb_param measEvent=A3 id=4

    Start observing measurements  UE_1  technology=5G

    Configure   ${yaml_A2_redirection}

    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '2', 'actNrDualConnectivity': 'disabled'},
    ...                       {'MOC': 'NRCELL', 'ID': '2', 'a2MeasRedirectEnabled': 'none'}]

    Configure    ${config}

    short_syslog.start collecting syslog        prefix=CB008490-MA

Prepare test environment CB008490-DB-B301
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Wait 30s for cells [2] operationalState change to [enabled]
    short_syslog.start collecting syslog        prefix=CB008490-DB-B301
    Execute egate command    cmd=gnb_nrdc_param id=2 allowed_bc_list_mrdc=1:1
    Activate RTPM    bts_id=2

CB008490-DB-B301 cleanup
    Basic cleanup sim SN
    Configure sim MN gNB2 to send XNAP:XnUAddressIndication with mandatory IE
    Configure sim MN gNB2 to send XNAP:XnUAddressIndication without additional DRB
    Configure sim MN gNB2 to send XNAP:SNodeReconfigurationComplete without Container IE
    Configure sim MN gNB2 to send XNAP:SNStatusTransfer without abstract syntax error
    Configure sim MN gNB2 to send XNAP:XnUAddressIndication
    Configure sim MN gNB2 to send XNAP:SNStatusTransfer

DT-B8 cleanup
    Basic cleanup
    Change eNB parameter value  SNSSAI-1.nguplane.ipV6AddressDN1  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1  bts_id=1
    Change eNB parameter value  SNSSAI-1.nguplane.ipV6AddressDN1  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1  bts_id=2

Prepare test environment CB008490-DF-B501
    Basic prepare
    Activate RTPM    bts_id=2

Prepare test environment CB008490-Q-B101
    Basic prepare for 8CC

Q-B101 cleanup
    Log to console    Cleanup after test Q-B101
    stop collecting syslog and download files
    Detach and kill UE1
    Detach and kill UE2
    Set NRCELL-3.administrativeState to Unlocked on bts-2
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-DF-B301
    Run keyword and ignore error
    ...    Setup Xn link between sim gNB2 and real gNB3
    Object attributes should be    XNLINK-1    xnLinkStatus=available    bts_id=2
    Prepare Sim gNB2
    short_syslog.start collecting syslog        prefix=DF-B301_

Prepare test environment CB008490-Q-B201
    Basic prepare for 8CC
    ${connection}=    coam.setup_admin    bts_host=10.0.1.4    name=admin_SN
    set suite variable    ${ADMIN_CONNECTION}     ${connection}
    coam.block_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-9  timeout=100  connection=${ADMIN_CONNECTION}
    coam.block_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-8  timeout=100  connection=${ADMIN_CONNECTION}
    coam.block_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-7  timeout=100  connection=${ADMIN_CONNECTION}
    coam.block_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-6  timeout=100  connection=${ADMIN_CONNECTION}
    get_ps_config
    Sleep    2
    Configure    ${CURDIR}/../config/yaml/power_saving.yaml    bts_id=2
    Wait 300s for 4CC SN gNB to go on air
    Check that XNlink is up for 10s

Q-B201 cleanup
    Log to console    Cleanup after test Q-B201
    stop collecting syslog and download files
    coam.unblock_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-9  timeout=100  connection=${ADMIN_CONNECTION}
    coam.unblock_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-8  timeout=100  connection=${ADMIN_CONNECTION}
    coam.unblock_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-7  timeout=100  connection=${ADMIN_CONNECTION}
    coam.unblock_cell   dist_name=MRBTS-3/NRBTS-3/NRCELL-6  timeout=100  connection=${ADMIN_CONNECTION}
    get_ps_config    suspended=True
    Sleep    2
    Configure    ${CURDIR}/../config/yaml/power_saving.yaml    bts_id=2
    Wait 300s for 8CC SN gNB to go on air
    set suite variable    ${ADMIN_CONNECTION}    admin_connection
    coam.teardown    connection=admin_SN
    Detach and kill UE1
    Detach and kill UE2
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-Q-B5
    Basic prepare for 8CC
    ${connection}=    coam.setup_admin    bts_host=10.0.1.4    name=admin_SN
    set suite variable    ${ADMIN_CONNECTION}     ${connection}
    get_ps_config
    Sleep    2
    Configure    ${CURDIR}/../config/yaml/PS_order_list.yaml
    Configure    ${CURDIR}/../config/yaml/power_saving.yaml    bts_id=2
    Wait 300s for 8CC SN gNB to go on air
    Check that XNlink is up for 10s

Q-B5 cleanup
    Log to console    Cleanup after test Q-B5
    stop collecting syslog and download files
    get_ps_config    suspended=True
    Sleep    2
    Configure    ${CURDIR}/../config/yaml/power_saving.yaml    bts_id=2
    Deconfigure all
    Wait 300s for 8CC SN gNB to go on air
    set suite variable    ${ADMIN_CONNECTION}    admin_connection
    coam.teardown    connection=admin_SN
    Detach and kill UE1
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Prepare test environment CB008490-Q-B9
    Wait 30s for cells [1] operationalState change to [enabled]
    Configure    ${CURDIR}/../config/yaml/Q-B9_setup.yaml
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available
    Execute egate command    cmd=amf_param id=1 voice_fallback=on
    short_syslog.start collecting syslog        prefix=CB008490-Q-B9

CB008490-Q-B9 cleanup
    Detach and kill UE1
    Deconfigure all
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    short_syslog.stop collecting syslog

Prepare test environment CB008490-Q-B12
    Log to console    Start test Q-B12
    Configure    ${CURDIR}/../config/yaml/emergency_call.yaml    bts_id=1
    Wait 30s for cells [1, 2] operationalState change to [enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    short_syslog.start collecting syslog        prefix=CB008490-M

CB008490-Q-B12 cleanup
    Basic cleanup sim SN
    Deconfigure all

Basic prepare for 8CC
    Wait 30s for cells [1] operationalState change to [enabled]
    Wait 120s for 8CC SN gNB to go on air
    Check that XNlink is up for 10s
    start collecting syslog from gnbs

Wait ${time}s for 8CC SN gNB to go on air
    Wait Until Keyword Succeeds  ${time}s  10s
    ...    Check all 8 cells are operational

Wait ${time}s for 4CC SN gNB to go on air
    Wait Until Keyword Succeeds  ${time}s  10s
    ...    Check all 4 cells are operational

Check all 8 cells are operational
    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-3    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-4    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-5    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-6    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-7    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-8    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-9    operationalState=enabled    bts_id=2

Check all 4 cells are operational
    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-3    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-4    operationalState=enabled    bts_id=2
    Object attributes should be    NRCELL-5    operationalState=enabled    bts_id=2

Prepare test environment CB008490-QR-B201
    Wait 30s for cells [1, 2, 3, 4] operationalState change to [enabled, enabled, enabled, enabled]
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    Object attributes should be    XNLINK-3    xnLinkStatus=available
    short_syslog.start collecting syslog        prefix=QR_B201_

Prepare test environment CB008490-Q-B8_3
    Basic prepare for 8CC
    ${connection}=    coam.setup_admin    bts_host=10.0.1.4    name=admin_SN
    set suite variable    ${ADMIN_CONNECTION}     ${connection}
    Configure    ${CURDIR}/../config/yaml/extended_range_11km.yaml    bts_id=2
    Wait 300s for 8CC SN gNB to go on air

Prepare test environment CB008490-Q-B8_2
    Basic prepare for 8CC
    ${connection}=    coam.setup_admin    bts_host=10.0.1.4    name=admin_SN
    set suite variable    ${ADMIN_CONNECTION}     ${connection}
    Configure    ${CURDIR}/../config/yaml/extended_range_6km.yaml    bts_id=2
    Wait 300s for 8CC SN gNB to go on air

Prepare test environment CB008490-Q-B8_1
    Basic prepare for 8CC
    ${connection}=    coam.setup_admin    bts_host=10.0.1.4    name=admin_SN
    set suite variable    ${ADMIN_CONNECTION}     ${connection}
    Configure    ${CURDIR}/../config/yaml/extended_range_2km.yaml    bts_id=2
    Wait 300s for 8CC SN gNB to go on air

Q-B8 cleanup
    Log to console    Cleanup after test Q-B8
    stop collecting syslog and download files
    Deconfigure all
    Wait 300s for 8CC SN gNB to go on air
    set suite variable    ${ADMIN_CONNECTION}    admin_connection
    coam.teardown    connection=admin_SN
    Detach and kill UE1
    Reset timing advance settings for UE1 and profile id-2
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
