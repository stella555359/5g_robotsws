*** Settings ***

Documentation    :copyright: Nokia
...              :author: Shaheena Parveen
...              :contact: shaheena.parveen@nokia.com
...
...             TEST SET NAME:    CB009025-SR
...             TESTING SPLIT:    Refer CB009025 Test Plan
...             CONTACTS:         I_MI_MN_RAN_RD_VRF_BLR1_T03_GMS <I_MI_MN_RAN_RD_VRF_BLR1_T03@internal.nsn.com>
...             REFERENCES:       CB009025_CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.ul.ue.sim.env_setup
Library          taf.wts.runner              WITH NAME    wtsrunner
Library         Process
Library         Collections
Library         taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin
Library         ta_emss
Library         ta5g_pm_counters
Library         String
Library         OperatingSystem
Library         Telnet


*** Variables ***
${artifactory_location}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/BSR/
${BSR_FILEPATH}=    ${artifactory_location}/${BSR_FILENAME}
${ARTI_USER}=    holowins
${ARTI_PASS}=    cmVmdGtuOjAxOjAwMDAwMDAwMDA6YWc5ZVlqZksxVEtDTWJoaFN6U2xwMGFWR0py
${bsr_iphy_folder}     ${CURDIR}/config/
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_folder}     ${CURDIR}/config/
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${LOG_DIR}      /home/ute/logs

*** Keywords ***

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Create Log Directory
    [Documentation]    Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${LOG_PATH}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    Set Test Variable       ${LOG_PATH}
    [Return]    ${LOG_PATH}

start Data call on ue
    wtsrunner.UE TA NR    profile_id=1     nb_reps_ta_sim=100     ue_speed=10     ue_p_delay_max=50
    ...    ue_p_delay_min=30     ue_p_delay_initial=39
    sleep    5s
    wtsrunner.UE Testmode Set NR    id=1    testmode=ta    profile_id=1    action=activate
    sleep    5s
    wtsrunner.ue_register    id=1
    sleep    2s
   	wtsrunner.set_pdu_param    ue=1  pdu=1    trf_type=internal
   	sleep    10s
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=1    nwslice=1  gw=1
    sleep   5s
    wtsrunner.trf_data_start    ue=1    pdu=1    qfi=1    trf_id=1
    ...                         dir=dl    mbps=10    seconds=3600
    sleep     2s

detach_ue_with_power_off
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_deregister   id=${ue_id}   ue_deregister_type=switch_off
    log to console  \nUE-${ue_id} Detached!

Configure Routes in WTS
     Run    sudo ip addr add 10.0.1.131/24 dev eth3
     Run    sudo ip addr add 10.0.1.132/24 dev eth3
     Run    sudo ip addr add 10.0.1.133/24 dev eth3
     Run    sudo ip addr add 10.0.1.134/24 dev eth3
     Run    sudo ip addr add 10.0.1.135/24 dev eth3
     Run    sudo ip addr add 10.0.1.136/24 dev eth3
     Run    sudo ip addr add 10.0.1.137/24 dev eth3
     Run    sudo ip addr add 10.0.1.138/24 dev eth3
     Run    sudo ip addr add 10.0.1.139/24 dev eth3
     Run    sudo ip addr add 10.0.1.140/24 dev eth3
     Run    sudo ip addr add 10.0.1.112/24 dev eth3
     Run    sudo ip addr add 10.0.1.113/24 dev eth3
     Run    sudo ip addr add 10.0.1.102/24 dev eth3
     Run    sudo ip addr add 10.0.1.101/24 dev eth3
     Run    sudo ip addr add 10.0.1.200/24 dev eth3

Update bsr package
    Run Process  wget --user ${ARTI_USER} --password ${ARTI_PASS} -P ${bsr_iphy_folder} ${BSR_FILEPATH}    shell=yes
    CoamAdmin.Setup Admin
    CoamAdmin.Update Software    sw_package=${bsr_iphy_folder}/${BSR_FILENAME}

Delta file commissioning for Feature Activation
	CoamAdmin.Setup Admin
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_commission}    skip_parameter_relation_errors=True
    CoamAdmin.Teardown admin

Delta file de-commissioning for Feture Deactivation
    CoamAdmin.Setup Admin      name=ABC
    CoamAdmin.perform_delta_recommissioning    delta_file=${delta_configuration_decommission}    skip_parameter_relation_errors=True
    ...     connection=ABC
    CoamAdmin.Teardown admin     connection=ABC


Run cfg file
    [Arguments]    ${wts_cfg_file_TC1}
    Stop Edaemon and Egate process
    Stop Sim_enb
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000

    wtsrunner.configure                   file=${wts_cfg_file_TC1}
    Sleep    30s
    wtsrunner.Gnb Param    id=3    xn_listening_socket=1    send_xn_setup=true
    wtsrunner.Gnb Xn Link Up    gnb=3    target=2
    sleep    30s


Check SIB messagges for all cells_RJIO
      Sleep    10s
      ${file_content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
      Should Contain    ${file_content}          eNB 2 cell 1: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 2: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 3: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 4: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 5: SystemInformationBlockType1-NR updated
      Should Contain    ${file_content}          eNB 2 cell 6: SystemInformationBlockType1-NR updated
