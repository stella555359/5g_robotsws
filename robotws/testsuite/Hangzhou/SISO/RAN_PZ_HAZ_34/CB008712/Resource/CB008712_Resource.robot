*** Settings ***
Documentation    Suite description
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com

Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005845/Resource/CB005845_Resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog

Variables    ./TLConfigurationDefault.py
Variables    ./CaseConfiguration.py

*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

&{condition_ru_same}   rf-FRU6=diff
&{condition_PS_diff}     PS=diff
${PA_INFO}             ${tl.attenuator[0]}

${sbts_addr}        ${WEBUI_IP}
${http_username}    ${WEBUI_USERNAME}
${http_password}    ${WEBUI_PASSWORD}

*** Keywords ***
CommonCase001.Manual_SiSo_STARTUP_BTS_Power_Reset
    [Documentation]   detail steps
    ...    1. Site Power Cycle and wait onair
    ...    2. Do L3Call
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Continue On Failure   DoTputCall

CommonCase002.Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]   detail steps
    ...    1. Site reset and wait onair
    ...    2. Do L3Call
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.reset_site
    sleep    30s
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error     COAM_WebEM.Logout

    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
    ${cell_num}    get length    ${cell_list}
    ${technology}    convert to upper case  ${technology}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}

    Run Keyword And Ignore Error     COAM_Admin.Logout
    Run Keyword And Ignore Error     COAM_WebEM.Logout

CommonCase003.General_SiSo_BTS_reset_with_RF_power_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    ...    ******************
    [Arguments]  ${ru_index}=1
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    KW.COAMAdmin_Login
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait until keyword succeeds    10 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
        sleep    2 sec
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair

CommonCase004.Manual_SiSo_SM_NR_RAT_reset
    [Documentation]   detail steps
    ...    1. RAT reset and wait onair
    ...    2. Do L3Call
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    COAM_WebEM.Login   version=${CASE_INPUT_SISO['SISOCommon']['release']}
    run keyword if    '${is_lte}'=='true'    selenium_coam.reset_lte
    ...    ELSE    selenium_coam.reset_nr
    sleep    180s
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both

    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    ${cell_list}    KW.Get All Cell Id
    ${cell_num}    get length    ${cell_list}
    ${technology}    convert to upper case  ${technology}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}

    Run Keyword And Ignore Error     COAM_WebEM.Logout

CommonCase005.General_SiSo_RU_module_reset_from_GUI
    [Documentation]   detail steps
    ...    1. Site RU Rest and wait onair
    ...    2. Do L3Call
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    KW.COAMAdmin_Login
    ${Active_SW_version}    Get Active SW Version
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}    version=${stream}
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}     alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.reset_ru  ru_index=${ru_index}
    END
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${cell_list}    KW.Get All Cell Id
    ${cell_num}    get length    ${cell_list}
    ${technology}    convert to upper case  ${technology}
    run keyword if    '${technology}'=="LTE" and ${cell_num}>1
    ...    COAM_WEBEM.LockUnlcokCell_LTE    cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}

    Run Keyword And Ignore Error     COAM_WebEM.Logout

CommonCase006.General_SiSo_RF_module_power_reset
    KW.COAMAdmin_Login
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    KW.Power On RU And Check    ru_index_list=${ru_index_list}
    [Teardown]  KW.Power On RU And Check    ru_index_list=${ru_index_list}

CommonCase007.Manual_SiSo_SM_RF_Module_lock_unlock
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    ${technology}    convert to upper case  ${technology}
    KW.COAMAdmin_Login
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    ${cell_list}    get all cell id

    ${cell_num}    get length    ${cell_list}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}

    log to console    \n***prepare ue***
    MultiUE.PrepareUE    UECFG=${TLCommonConfig['MultiUECFG']}
    FOR  ${lock_id}  IN  @{ru_index_list}
        ${operate_list}    create list    ${lock_id}
        log to console    \n***ue attach***
        MultiUE.Attach    UECFG=${TLCommonConfig['MultiUECFG']}
        log to console    \n***start traffic***
        MultiUE.StartDLTraffic    UECFG=${TLCommonConfig['MultiUECFG']}
        MultiUE.StartULTraffic    UECFG=${TLCommonConfig['MultiUECFG']}
        Selenium Logout And Close Browser
        Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
        ...    username=${http_username}    password=${http_password}
        Lock all RUs and check status LTE    ru_index_list=${operate_list}
        Unlock all RUs and check status LTE    ru_index_list=${operate_list}
        log to console    \n***check log***
        MultiUE.CheckThoughput    UECFG=${TLCommonConfig['MultiUECFG']}
        log to console    \n***stop traffic***
        MultiUE.StopDLTraffic        UECFG=${TLCommonConfig['MultiUECFG']}
        MultiUE.StopULTraffic        UECFG=${TLCommonConfig['MultiUECFG']}
        MultiUE.Detach               UECFG=${TLCommonConfig['MultiUECFG']}
        sleep    3s
    END

    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}

    Run Keyword And Ignore Error     COAM_WebEM.Logout

    [Return]  Selenium Logout And Close Browser

CommonCase008.Manual_SiSo_SM_LTE_Cell_block_unblock
    [Documentation]   detail steps
    ...    1. block and unblock cell and wait onair
    ...    2. Do L3Call
    [Arguments]   ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    #    Manual_SiSo_SM_LTE Cell_block_unblock    LTE_cell_id_list=${LTE_cell_id_list}
    #Run Keyword And Continue On Failure   DoTputCall
    ${technology}    convert to upper case    ${technology}
    COAM_WebEM.Login
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
    FOR    ${cell_idx}    IN    @{cell_list}
        COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_idx}    action=block    technology=${technology}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        COAM_WEBEM.BlockUnBlcokCell    cell_idx=${cell_idx}    action=unblock    technology=${technology}
    END

    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    ${cell_num}    get length    ${cell_list}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}
    Run Keyword And Ignore Error     COAM_WebEM.Logout

CommonCase009.Manual_SiSo_SM_LTE_cell_lock_unlock_(administrative_state_change)_from_GUI_1CC
    [Documentation]   detail steps (General_SiSo_Auto_Cell_lock_and_unlock_with_L3call)
    ...    1. lock and unlock cell and wait onair
    ...    2. Do L3Call
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
    ${technology}    convert to upper case  ${technology}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    gNB.FormatBTSID    lte=${is_lte}
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    FOR    ${cell_idx}    IN    @{cell_list}
        COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=lock      technology=${technology}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=unlock    technology=${technology}
    END

    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${cell_num}    get length    ${cell_list}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    [Teardown]   gNB.FormatBTSID    lte=${is_lte}

CommonCase010.BS-RF__LTE_cell_graceful_shutdown_from_WebEm
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    ${technology}    convert to upper case  ${technology}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    gNB.FormatBTSID    lte=${is_lte}
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    KW.COAMAdmin_Login
    ${cell_list}    get all cell id    cell_type=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    FOR    ${cell_idx}    IN    @{cell_list}
        wait until keyword succeeds   5x   30s    COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}    action=shuttingdown    checkstatus=true
        ...    technology=LTE
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        wait until keyword succeeds   5x   30s   COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=true
        ...    technology=LTE
    END

    wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
    ${cell_num}    get length    ${cell_list}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}

    run keyword and ignore error    COAM_WebEM.Logout


CommonCase011.General_SiSo_RF_module_IP_adress_allocation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check RU module IP address allocation and to check optical ports.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    KW.COAMAdmin_Login
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master



CommonCase012.5GC000399_eCPRI_Basic_configuration_over_RP1
    KW.COAMAdmin_Login
    ${Active_SW_version}    Get Active SW Version
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}    version=${stream}

    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}     alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    5s    KW.RU Should Be Power Off    ru_index=${ru_index}
        sleep  3s
        wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
        Close Start Up View    timeout=60
        sleep    60s
        Connect to RU With Allocated IP LTE    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        Verify SOAP RP1 LTE  ru_index=${ru_index}    ru_type=${ru_type}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

CommonCase013.5GC000584_RU_Module_Certificate_Integrity
    [Documentation]   detail steps
    ...    1. Check RU Cert present and correct.
    KW.COAMAdmin_Login
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Ru and check if certificate exists    ru_index=${ru_index}
        KW.Check_Integrity_On_RU    ru_index=${ru_index}
    END


CommonCase014.General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    KW.COAMAdmin_Login
    ${Active_SW_version}    Get Active SW Version
    set test variable    ${Active_SW_version}    ${Active_SW_version}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type  ru_index=${ru_index}
        verify content of TargetBD file LTE   ru_index=${ru_index}    radio_type=${radio_type}
        verify content of BPF file LTE    variable_from_CFAM=${Variables_CFAM}    ru_index=${ru_index}
    END


CommonCase015.5GC000561_eCPRI_sync_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify collecting PM counter data on eCPRI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.5.22 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    ${origin_value}    KW.Change NCPRI PM Interval LTE   interval=5min
    csn.connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=ASIK Master
    KW.Check Sync Counter LTE   change_interval=5
    KW.Change NCPRI PM Interval LTE    interval=15min
    KW.Check Sync Counter LTE   change_interval=15
    [Teardown]  csn.Disconnect    connection=ASIK Master

CommonCase016.5GC000561_eCPRI_sync_generic_startup_at_RAU
        [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RAU synchronization startup for eLLF interface
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.10.2020 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
#    COAM_WebEM.Login
#    Get PM Counter content via Webem    counter_id=ETHLK-2    counter_type=Transport
    COAM_WebEM.Login
    KW.Sync Startup is verified
    ${origin_value}    Change NCPRI PM Interval    interval=5min
    connect to common unit master
    Sync data is verified after startup   origin_interval=${origin_value}    change_interval=5min
    Sync status reported to O&M is verified
    Change NCPRI PM Interval    interval=${origin_value}
    [Teardown]  run keywords  csn.Disconnect  connection=ASIK Master    AND    COAM_WebEM.Logout

CommonCase017.General_SiSo_eCPRI_synchronization_status_NIDD_parameters
    [Documentation]  The purpose of this test is to verify synchronization eCPRI NIDD parameter status in WebUI
    ...    Steps: cell should be on air and ECPRI related Parameters exsit in webui
    ...    Case Input:
    ...    ECPRI related Parameters ,please refer to [Arguments]
    [Arguments]  ${parameters_list}=${TCCB005845_TC53}
    KW.General_SiSo_eCPRI_synchronization_status_NIDD_parameters   parameters_list=${parameters_list}


CommonCase018.General_SiSo_U-plane_Fast_C-plane_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to verify RAU/RU eCPRI U-plane & Fast-C-Plane message reception NetAct/NIDD PM counters
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.02.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    #need raw mrbtsid and nrbtsid
    [Arguments]  ${miNrEcpriUpFCp}=5min
    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=${miNrEcpriUpFCp}
    sleep  ${miNrEcpriUpFCp}
    selenium login and disable screen lock
    Check M55318 Counter    change_interval=${miNrEcpriUpFCp}
    [Teardown]  run keywords  selenium logout and close browser    AND
    ...    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=disabled

CommonCase019.General_SiSo_BTS_startup_with_delayed_RF_link_setup
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    8712 Perform RAC and RAU Power Off LTE    ru_index_list=${ru_index_list}
    8712 Perform RAC Power On LTE    ru_index_list=${ru_index_list}
    [Teardown]  KW.Power On RU_and_check RF Delayed Startup LTE  ${ru_index_list}

8712 Perform RAC and RAU Power Off LTE
    [Arguments]  ${ru_index_list}
    log to console    \n***Perform RAC and RAU Power Off***
    Perform Site Power Off LTE
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off LTE    model=HBTE    ru_pdu_ip=10.68.87.20    ru_pdu_port=4
        sleep    15s
    END

8712 Perform RAC Power On LTE
    [Arguments]  ${ru_index_list}  ${timeout}=30min
    log to console    \n***Perform RAC Power On***
    Perform Site Power On LTE
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    Wait For Expect Fault Present LTE  faultId=10  timeout=${timeout}
    FOR  ${ru_index}  IN  @{ru_index_list}
         RU Should Be Power Off    ru_index=${ru_index}
    END

CommonCase020.General_SiSo_Link_Diagnostic_and_Monitoring
        [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to Check SFP/QSFP data on the Nokia controlled links are displayed
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.20.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    Check if static data SFP QSFP have a valid value for ports for SMOD  ${links}     ${SMOD}
    ${physicalPort}    Check if QSFP or SFP  ${links}    ${BBMOD}
    Check if Tx parameters have a valid value for ports for BBMOD    ${links}    ${BBMOD}    ${physicalPort}
    Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}
    Check if static parameters have a valid value for ports    ${links}    ${RMOD}
    #${parsed_files}    Get snapshot and return parsed RD files
    #${RMOD_SFP_dict}    Get RMODs info
    #Check counters from SFP monitoring- file iteration    ${parsed_files}    ${RMOD_SFP_dict}    SFPRM
    #[Teardown]    Remove Directory    ${unzipped}    recursive=True

CommonCase021.General_SiSo_RU_capabilities_advertisement_towards_OAM
    [Documentation]   detail steps
    ...    1. collect snapshotlog
    ...    2. check oam start up log , ruSupportsExtType6: boolean=true present
#    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    gNB.Connect
    ${result}  Conn.Execute  cmd=xz -d /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz    alias=${ALIAS_ASIK}
    ${startup_btsoam}   set variable if  ${result.count("No such file or directory")}>0    /tmp/startup_BTSOM.log
    ...    /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log
    ${result}  Conn.Execute  cmd=cat ${startup_btsoam}|grep "ruSupportsExtType6:"   alias=${ALIAS_ASIK}
    ${result}  Conn.Execute  cmd=cat ${startup_btsoam}|grep "ruSupportsExtType6: boolean = true"   alias=${ALIAS_ASIK}
    Should Not Be Empty   ${result}
    #TODO actual value false

CommonCase022.General_SiSo_RF_alarms_with_recovery
        [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify RU connection and fault reporting in WebUI.
    ...    RU should be affected by recoverable error triggered during normal BTS run
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 03.18.2020 - - Created
    ...    - 06.28.2020 - - Modified
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        KW.General_SiSo_RF_alarms_with_recovery    ru_index=${ru_index}
    END

CommonCase023.General_SiSo_RF_alarms_without_recovery
    [Arguments]   ${Tdanger_target}=30
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${SW_version}    Get Active SW Version
    @{split_version}    string.split string    ${SW_version}    separator=_
    set test variable    ${stream}    ${split_version}[0]
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${Tdanger_init}    Run keyword if    '${stream}'>'SBTS24R2'    Get Tdanger Value from Json File in SBTS00
        ...    ru_index=${ru_index}    ELSE    Get Tdanger Value from Json File    ru_index=${ru_index}
        log to console   \n init Tdanger value:${Tdanger_init}
        log to console    \n Trigger Alarm 1937
        Run keyword if    '${stream}'>'SBTS24R2'
        ...    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_init}
        ...    target_value=${Tdanger_target}    cmd=touch   ru_index=${ru_index}
        ...    ELSE    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_init}
        ...    target_value=${Tdanger_target}    cmd=touch   ru_index=${ru_index}
        log to console   \n Check Alarm 1937 Appear On WebEM
        Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
        log to console    \n Recovery Alarm 1937
        Run keyword if    '${stream}'>'SBTS24R2'
        ...    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_target}
        ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}
        ...    ELSE    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}
        ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}
        log to console    \n Check Alarm 1937 Disappear On WebEM
        Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
        wait until keyword succeeds   20min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    END
    [Teardown]    KW.Teardown_CommonCase023    stream=${stream}    ru_index=${ru_index_list}

KW.Teardown_CommonCase023
    [Arguments]   ${Stream}    ${Tdanger_target}=30    ${Tdanger_init}=105    ${ru_index}=1
    FOR  ${ru_index_t}  IN  @{ru_index}
        Run keyword if    '${stream}'>'SBTS24R2'
        ...    run keywords    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_target}
        ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index_t}    AND    coam wait gnb and cells ready
        ...    timeout=15min    gnb_type='${gNb_CuType}'
        ...    ELSE    run keywords    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}
        ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index_t}    AND    coam wait gnb and cells ready
        ...    timeout=15min    gnb_type='${gNb_CuType}'
    END

CommonCase024.General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    Set test variable    ${ssh_username}    ${ASIK_username}
    Set test variable    ${ssh_password}    ${ASIK_password}

    ${origin_params}  Modify pMax to tirgger fault LTE    cell_id=${cell_id}  ru_index=${ru_index}  variable_from_CFAM=${variable_from_CFAM}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    Wait Until Keyword Succeeds    10min    30s    Alarm in Given Alarm list Present LTE
    [Teardown]  run keywords    Close Start Up View    timeout=60    AND
    ...    Modify Parameters On Webem LTE    ${origin_params}              AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ...    cell_type=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}

#CommonCase025.Initiate_RF_Statistics_diagnostic_test_withoutL3call
#    [Documentation]   detail steps
#    ...    1. Online Modification and active
#    ...    2. check test result, temprature/Eth/uptime
#    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
#    ...           ${celltype}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
#    ${celltype}    convert to upper case    ${celltype}
#    ${CellType}    Set Variable If  'celltype'=='NR'    NR    LTE
#    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${scf}
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
#    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
#    ${ru_index_list}    get all ru index
#    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1    object_class_name=RFSTATREQ     id_value=1
#    FOR    ${ru_index}    IN    ${ru_index_list}
#        selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1
#    ...    filter_param=Target Radio Module test identifier   new_value=${ru_index}    abbr=targetRModId
#    END
#    COAM_WebEM.ValidateAndActiveParameters
#    ${result}  COAM_WebEM.GetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1/RFSTATRES-1   abbr=RF Statistics Result
#    should be true    '${result}'=='success'
#    ${result}  COAM_WebEM.GetParameterValue  distName=${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFSTATREQ-1/RFSTATRES-1   abbr=Test outcome
#    should be true    '${result}'=='Pass'

CommonCase026.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
    [Documentation]   detail steps
    ...    1. BTS onair and BTS site/ru reset, poweroff/on
    ...    2. snapshot showing the correct reason
    ...    3. for sw upgrade/watchdog/Management please test manually.
#    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    #1. Site Reset
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.reset_site
    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: BTS (4)

    #2. RU WebUI Reset
    ${Active_SW_version}    Get Active SW Version
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}    version=${stream}
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}     alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.reset_ru    ru_index=${ru_index}
    END
    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: BTS (4)

    #RU Power Reset
    FOR    ${index}    IN    @{ru_index_list}
        ${index}    Evaluate    ${index}-1
        Power.Reset5GRU    model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.vendor}
    END

    run keyword and ignore error    KW.RestartSAS
    KW.CaseDestroy
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${log}    KW.CollectSnapshot
    KW.CheckSnapshotLog    log=${log}    string=Last reset cause: PowerOn (1)


CommonCase027.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
    [Documentation]   detail steps
    ...    Precondition: Enable Fault report on target RU by:
    ...         frmonShellClient 127.0.0.1 2000
    ...         / action create ConfigAccess /ca /module
    ...         /ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"
    ...         vi fault_logger. json add 1247 to fault list and save
    ...         /ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"
    ...         /ca action update
    ...         exit frmon shell comand：crtl+c
    ...         sync and reboot ru.
    ...    1.trigger radio failure
    ...    2. full level snapshot, should contain faultLog.zip
    ...    3. trigger radio fault by a list
    ...    4. Collect log, should conatin faultlog.zip
    ...    5. power reset radio, log still there.
#    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    #trigger RU fault
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    KW.GenerateAlarm1901AndClearIt
    run keyword and ignore error    KW.RestartSAS
#    gNB.Connect
#    gNB.ConnectToRU    ru_asias=${ALIAS_RMOD}
#    Conn.Execute  command=rm -rf /tmp/command&&touch /tmp/command    alias=${ALIAS_RMOD}
#    Conn.Execute  command=frmonShellClient 127.0.0.1 2000 /tmp/command   alias=${ALIAS_RMOD}
    #Conn.Execute  command=echo "command" >/tmp/command    alias=${ALIAS_RMOD}
    ${log}    gNB.CollectSnapshot
    run   rm -rf ${LOG_PATH}/SnapShot&&unzip ${log} -d ${LOG_PATH}/SnapShot
    run   rm -rf ${LOG_PATH}/faultlog&&unzip ${LOG_PATH}/SnapShot/*_L_1_faultLogs.zip -d ${LOG_PATH}/faultlog
    ${result}    run   cat ${LOG_PATH}/faultlog/snapshot_status.txt|grep 1247
    should not be empty    ${result}

CommonCase028.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
    [Documentation]   detail steps
    ...    1. Set Pmax from min to max and call   17-24
    [Arguments]   ${loop}=${CASE_INPUT_SISO['Pmax']['count']}
    ...    ${start}=${CASE_INPUT_SISO['Pmax']['start']}
    ...    ${celltype}=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    ...    ${isCBRS}=${CASE_INPUT_SISO['Pmax']['isCBRS']}
    ...    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    FOR    ${index}    IN RANGE    ${loop}
        Run Keyword And Continue On Failure    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
        ${newValue}    Evaluate    ${start}+${1}+${index}
        KW.ModifyPmax    isCBRS=${isCBRS}    newValue=${newValue}    celltype=${celltype}
        Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
        Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=4008    present=false
        run keyword and ignore error    KW.GetAndCheckAlarms
        run keyword and ignore error   COAM_WebEM.Logout

        COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
        ${cell_list}    KW.Get All Cell Id
        ${cell_num}    get length    ${cell_list}
        ${technology}    convert to upper case  ${technology}
        run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
        ...     cell_idx=1      action=lock      technology=${technology}
        Run Keyword And Continue On Failure   DoTputCall
        run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
        ...     cell_idx=1      action=unlock      technology=${technology}

        run keyword and ignore error   COAM_WebEM.Logout
    END
    [Teardown]  gNB.FormatBTSID    lte=${is_lte}

KW.ModifyPmax
    [Arguments]      ${isCBRS}    ${newValue}    ${celltype}
    ${cell_list}    get all cell id    cell_type=${celltype}
    FOR    ${cellid}    IN    @{cell_list}
        run keyword if  '${isCBRS}'=='false'
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}    abbr=Maximum output power    value=${newValue}
        ...    ELSE IF    '${isCBRS}'=='true' and '${celltype}'!='nr'
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}/CBSDCEL-0
        ...    abbr=Desired Maximum Output Power    value=${newValue}
        ...    ELSE
        ...    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
        ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}/NRCBSDCELL-0
        ...    abbr=Desired Maximum Output Power    value=${newValue}
    END

CommonCase029.5GC000399_eCPRI_Carier_activation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify carrier configuration and activation using eLLF RU over RP1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    #need coam admin connected
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Download soap Log0 from RU    log_path=${SAVE LOG DIRECTORY}    ru_alias=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check carier activation by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

CommonCase030.5GC000399_eCPRI_FREERUN_state_handling
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify FREERUN state handling for 5G eCPRI RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.10.2020 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${modify_params}    Generate Modify Parameters      modify_params=${TOP_DOMAIN_NUMBER_MODIFY}
    ${orig_params}  Generate Origion Parameters  modify_params=${modify_params}
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    Wait For Expect Fault Present   faultId=${16}     timeout=180
    Wait For Expect Fault Present   faultId=${4298}     timeout=180
    modify parameters on webem    modify_params=${orig_params}
    Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear   faultId=${4298}     timeout=180
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]   Selenium Logout And Close Browser

CommonCase031.General_SiSo_NR-ARFCN_check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to test SiSo_NR-ARFCN_check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.01.2020    - Created
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1  ${radio_type}=AWHQN  ${variable_from_CFAM}=${Variables_CFAM}
    Selenium Login And Disable Screen Lock
    Get Parameters From NR_Frequencies_Band
    get nrarfcn boudary values  radio_type=${radio_type}  variable_from_CFAM=${variable_from_CFAM}
    ${nrarfcn}  ${gscn}  get origin nraradcn and gscn    cell_id=${cell_id}
    ${origin_params}  generate nrarfcn gscn modify parameters   nrarfcn=${nrarfcn}   gscn=${gscn}    cell_id=${cell_id}
    verify nrarfcn out of band boundary range  cell_id=${cell_id}
    verify nrarfcn out of TX/RX range  cell_id=${cell_id}
    Close Start Up View    timeout=60
    modify parameters on webem  modify_params=${origin_params}    timeout=180
    COAM Wait gnb And Cells ready    timeout=15 min
    [Teardown]  Selenium Logout And Close Browser

CommonCase032.General_SiSo_SOAP_RP1_verification
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify basic configuration of RU using RP1.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.09.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    30s    RU Should Be Offline    ru_index=${ru_index}
        sleep  10
        Wait Until Keyword Succeeds    8min    30s    verify all cells should be onair
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        Verify SOAP RP1  ru_index=${ru_index}    ru_type=${ru_type}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

CommonCase033.General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.25.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_online_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_online_status}
    END
    COAM Check GNB RU status
    COAM Check GNB ABIL status
    COAM Check GNB ASIK status
    ${start_server_times}    Create Dictionary
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${start_server_time}  ${start_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        Set To Dictionary    ${start_server_times}    ${ru_index}    ${start_server_time}
    END
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep  60
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait until keyword succeeds    5 min    5 sec    RU Should Be Offline    ru_index=${ru_index}
        ${RU_offline_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should not be True    ${RU_offline_status}
    END
    COAM Wait gnb And Cells ready    timeout=20 min
    Connect to Common Unit Master
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_recovery_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_recovery_status}
        ${end_server_time}    ${end_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        ${start_server_time}    Get From Dictionary    ${start_server_times}    ${ru_index}
        RU Should Be Reset    start_server_time=${start_server_time}    end_server_time=${end_server_time}
        ...    uptime=${end_uptime}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

CommonCase034.General_SiSo_RF_module_addition_in_BIM_and_WebUI
        [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to check whether configured BTS components are visible in WebUI.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Perform BTS Site Reset
    sleep   2min
    COAM Wait gnb And Cells ready    timeout=15 min
    Check HW modules detection
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Check RF config from webui  ru_index=${ru_index}
    END
    [Teardown]  Selenium Logout And Close Browser


CommonCase035.General_SiSo_Online_Cell_addition_deletion
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that cell addition and cell deletion function works well on WebEM
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.15.2020 - - Created
    ...    *******************
    ...    Notice: addition_deletion_cell: cell id for deletion then addition, more than 1 cell on site
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_idx}=1
    KW.Online Cell addition deletion   addition_deletion_cell=${cell_idx}

CommonCase036.General_SiSo_LED_states_management_basic
   [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.04.2020    - Created
    ...    OWNER_tingting.zhong@nokia-sbell.com
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        KW.General_SiSo_LED_states_management_basic    ru_index=${ru_index}
    END

CommonCase037.General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
        [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check functionality of ALD commissioning
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    SISO ALD Test Setup
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections

CommonCase038.General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
        [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check ALD retrieval and visualization via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    SISO ALD Test Setup
    ALD Details Info Check
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections

CommonCase039.General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
    #[Arguments]   ${ald_type}=${TCCB005845_TC34['ald_type']}   RETU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check ALD handling and visibility via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ald_type}=RETU
    SISO ALD Test Setup
    Repeat 2 Times Enable And Disable DC Voltgae For RET Port ${ald_type}
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections

CommonCase040.General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
    #[Arguments]    ${ald_type}=${TCCB005845_TC35['ald_type']}    RETU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check faulty notification recovery action indication
    ...     and visualization.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.03.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ald_type}=RETU
    SISO ALD Test Setup
    log to console   \n disable HDLC communication
    Modify ALD HDLC Parameter    hdlc_flag=false
    sleep  20
    log to console   \n Check fault 4142 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4142
    log to console   \n disable DC voltage
    Modify ALD DC Voltage Parameter    dcvoltage_flag=false
    sleep  20
    log to console   \n Check fault 4141 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4141
    log to console   \n enable HDLC communication
    Modify ALD HDLC Parameter    hdlc_flag=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4142
    log to console   \n enable DC voltage
    Modify ALD DC Voltage Parameter    dcvoltage_flag=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4141
    log to console   \n Modfiy Antenna operating frequency band value to 99
    Modify ALD antFreqBand Parameter    antFreqBand_value=99    ald_type=${ald_type}
    sleep  20
    log to console   \n Check fault 4282 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4282
    log to console   \n Modfiy Antenna operating frequency band value to 1
    Modify ALD antFreqBand Parameter    antFreqBand_value=1    ald_type=${ald_type}
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4282
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections

CommonCase041.General_SiSo_ALD_SW_Management_Create_ALD_Build_Descriptor_file
    [Documentation]  Aim to test the ALD Vender package generation
    ...    Steps:
    ...    1. Load ALD vender bin file
    ...    2. Fill the corresponding parameters
    ...    3. Save to generate ALD vender package to local.
    ...    Condigurations:
    ...    {CASE_INPUT_CB005845['TC56']['ALDBinFilePath']} path to bin file
   [Arguments]   ${ALDBinFilePath}=${TCCB005845_TC56['ALDBinFilePath']}
    ...          ${TargetSWversion}=1.0.0.
    ${minor_version}    evaluate   random.randint(1,100)   modules=random
    set suite variable    ${ALD_Version}    ${TargetSWversion}.${minor_version}
    COAM_WebEM.Login
    selenium_coam.restore_hw_info    sw_file=${ALDBinFilePath}
    ...    target_sw_version=${ALD_Version}
    ${ALD_FilePath}    selenium_coam.save_ald_sw_file
    COAM_WebEM.Logout
    set suite variable    ${ALD_FilePath}    ${ALD_FilePath}

CommonCase042.General_SiSo_ALD_Configuration_Management_RET_calibration_via_command
    [Documentation]  Aim to test calibration for RETU
    ...    Steps:
    ...    1. login to WebEM and calibration for RETU
    ...    Condigurations:
    ...    ${TCCB005845_TC57['retu_index']} indicate which RETU to calibrate
    [Arguments]  ${retu_index}=${TCCB005845_TC57['retu_index']}
    COAM_WebEM.Login
    Selenium_coam.calibrate_retu   retu_index=${retu_index}
    COAM_WebEM.Logout

CommonCase043.General_SiSo_ALD_SW_Management_ALD_SW_Download_and_Activation
    [Documentation]  Aim to test RETU software download and active
    ...    Steps:
    ...    1. load RETU software package from WebEM
    ...    2. click start button to download.
    ...    3. check the version is correct.
    ...    Condigurations:
    ...    ${TCCB005845_TC58['retu_index']} indicate which RETU to check
    [Arguments]  ${retu_index}=${TCCB005845_TC58['retu_index']}    #${ALDFilePath}=Depend on the output to case56     #${'TC58']['ALDFilePath']}
    KW.UpGradeForRU    filename=${ALDFilePath}
    COAM_WebEM.Login
    ${ALD_info}    selenium_coam.get_ald_info      ald_index=${retu_index}
    log to console    ${ALD_info}
    #should be equal    ${ALD_info[xxx]}   ${ALD_Version}
    COAM_WebEM.Logout

CommonCase044.General_SiSo_ALD_Configuration_Management_RET_tilt_modification
    [Documentation]  Aim to test RETU parameter modification
    ...    Steps:
    ...    1. Mofidy RETU parameters and active
    ...    3. check the parameters is correctly actived.
    ...    Condigurations:
    ...    ${TCCB005845_TC59['retu_index']} indicate which RETU to change
    [Arguments]    ${retu_index}=${TCCB005845_TC59['retu_index']}
    COAM_WebEM.Login
    ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}
    log to console    ${retu_info}
    ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
    ${angle}    get regexp matches    ${angle[0]}    [0-9]+
    FOR  ${i}    IN RANGE    ${10}
        ${min}    get regexp matches    ${retu_info['Angle range']}    from [0-9]+
        ${min}    get regexp matches    ${min[0]}    [0-9]+
        ${max}    get regexp matches    ${retu_info['Angle range']}    to [0-9]+
        ${max}    get regexp matches    ${max[0]}    [0-9]+
        ${angle_value}    evaluate   random.randint(${min[0]},${max[0]})   modules=random
        Exit For Loop If    ${angle[0]}!=${angle_value}
    END
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}
    FOR  ${i}    IN RANGE    ${15}
        Sleep    20
        ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}
        ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
        ${angle}    get regexp matches    ${angle[0]}    [0-9]+
        Exit For Loop If    ${angle[0]}==${angle_value}
    END
    COAM_WebEM.Logout

CommonCase045.5GC000560_eLLF_PTP_Failure
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify when set wrong input sync for RAU
    ...    the syncstatus and lockstatus changed right both on webUI and RU soap log
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_jiangjing.lin@nokia-sbell.com
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
    check sync info of RU    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
    check sync info of RU    status='normal'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

CommonCase046.5GC000560_eLLF_sync_generic_startup_at_RU
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify eCPRI sync generic startup
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.10.2020 - - Created
    ...    *******************
    ...    Owner_jie-jessy.li@nokia-sbell.com
    Check eCPRI PTP State via Btsom Log


#TCNO.52_5GC000399_eCPRI_RP1_Supervision_failure
#    [Documentation]  The purpose of this test is to verify RP1 connection supervision failure detected on RAU
#    ...    Steps:
#    ...    Step1: Supervision failure is raised due to RP1 Specification Chapter 3.11.1 (Figure 6 Supervision)
#    ...    Step2: Cells in WebUI has operational state as disabled and availability status as offline
#    ...    Step3: RU was reset automaticlly
#    ...    Step4: Set back value before step1
#    ...    Step5: check cell on air
#    ...    Case Input:
#    ...    please refer to [Arguments]
##    5GC000399_eCPRI_RP1_Supervision_failure
#    Log    TO BE Implement

CommonCase047.General_SiSo_LED_states_management_additional_scenarios
    #[Arguments]  ${ru_index}=${TCCB005845_TC55['ru_index']}    ${Tdanger_target}=${TCCB005845_TC55['Tdanger_target']}
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that LEDs on radio module works as specified
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.08.2021    - Created
    ...    OWNER_jianhua.1.zhu@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${Tdanger_target}=30.0
    ${Tdanger_init}    Get Tdanger Value from Json File    ru_index=${ru_index}
    log to console   \n init Tdanger value:${Tdanger_init}
    log to console    \n Trigger Alarm 1937
    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_init}    target_value=${Tdanger_target}
    ...    cmd=touch    ru_index=${ru_index}
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
    ${led_status_list}  create list  YELLOW YELLOW   RED RED
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list}    ru_index=${ru_index}   log_name=ru_log_1
    log to console    \n Recovery Alarm 1937
    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}    target_value=${Tdanger_init}
    ...    cmd=rm -rf    ru_index=${ru_index}
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
    coam wait gnb and cells ready    timeout=15min
    ${led_status_list_1}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list_1}    ru_index=${ru_index}   log_name=ru_log_2
    [Teardown]  run keywords    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}
    ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}    AND    coam wait gnb and cells ready
    ...    timeout=15min

CommonCase048.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
    [Documentation]   detail steps
    ...    1. Configrue parameter
    ...    2. Check the message flow to SAS simu
    [Arguments]   ${ts2}=${CASE_INPUT_SISO['CBSD']['TS2']}
    ...           ${celltype}=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    ${celltype}    convert to upper case    ${celltype}
    run keyword if  '${celltype}'!='NR'    gNB.FormatBTSID    lte=true
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts2}    version=1.2
    ${CBRS_PREFIX}    Set Variable If  '${celltype}'=='NR'    NR    ${EMPTY}
    set test variable    ${CBRS_PREFIX}    ${CBRS_PREFIX}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    ${res}    run keyword and ignore error    KW.GetAndCheckCBSD    ts=${ts2['server']}    version=${ts2['version']}    state=Registered
#    run keyword if    '${res[0]}'!='PASS'   KW.SetCBSDParameters    ts=${ts2['server']}    version=${ts2['version']}
    DoTputCall
    [Teardown]   gNB.FormatBTSID    lte=${is_lte}

CommonCase049.LTE_Verify_CBSD_registration_From_TS1_to_TS2
    [Documentation]   detail steps
    ...    1. base scf ts1, Configrue parameter
    ...    2. Check the message flow to SAS simu
    [Arguments]   ${ts1}=${CASE_INPUT_SISO['CBSD']['TS1']}    ${ts2}=${CASE_INPUT_SISO['CBSD']['TS2']}
    ...     ${celltype}=NR
    ...     ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    run keyword if  '${celltype}'!='NR'    gNB.FormatBTSID    lte=true
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts1}    version=1.2
    run keyword if  '${celltype}'!='NR'    Set To Dictionary    ${ts2}    version=1.2
    ${CBRS_PREFIX}    Set Variable If  '${celltype}'=='NR'    NR    ${EMPTY}
    set test variable    ${CBRS_PREFIX}    ${CBRS_PREFIX}
    #${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=CBSD
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${scf}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   5min   1min    KW.GetAndCheckCBSD    ts=${ts2['server']}    version=${ts2['version']}    state=Registered
    COAM_WebEM.Logout
    DoTputCall
    [Teardown]  gNB.FormatBTSID    lte=${is_lte}

CommonCase050.General_SiSo_Static_HW_Capabilities_Validation_001
    [Documentation]   detail steps
    ...    1. Modify SCF
    ...    2. load and error displayed
    ...    3. Modify scf
    ...    4. load and error cleared
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}    ${CASESCF_TCID}=HWValidation
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=${CASESCF_TCID}
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${casescf}
    selenium_coam.validate_plan
    #${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
#    Should Not Be Empty   ${defination_errors}
#    Should contain    ${defination_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    Should Not Be Empty   ${relation_errors}
#    Should contain    ${relation_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    #Should Not Be Empty   ${hardware_errors}
#    Should contain    ${hardware_errors[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf}
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}

CommonCase051.Manual_SiSo_CM_Recommissioning
    [Documentation]   detail steps
    ...    1. Login to WebUI
    ...    2. BtsReset parameter online change
    ...    3. Login to WebUI validate and check error
    ...    4. online parameter change. save report
    ...    5. online change to wrong value, avtive is impossible?
    ...    6. undo change, parameter value back
    #COAM_WebEM.Login
    #Reset Parameter
    #COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    #...    abbr=Administrative state    value=locked
    #COAM_WebEM.ValidateAndActiveParameters
    #run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}
    #online setparametervalue
    ${btsname}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}   abbr=BTS name
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}   abbr=BTS name    value=TL1101_AZQC_NR_1cell_TAA
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
    Should Be Empty   ${defination_errors}
    Should Be Empty   ${relation_errors}
    Should Be Empty   ${hardware_errors}
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}   abbr=BTS name    value=${btsname}
    COAM_WebEM.ValidateAndActiveParameters
    selenium_coam.save_report
    KW.CaseDestroy
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.remove_object    object_name=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    selenium_coam.validate_plan
    ${productCode}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned
    #COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned    value=474157A.101
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${hardware_errors}      selenium_coam.get_hardware_errors
#    Should Be Empty   ${defination_errors}
#    Should Be Empty   ${relation_errors}
    Should Not Be Empty   ${relation_errors}
    #Should Not Be Empty   ${hardware_errors}
    selenium_coam.undo_changes
    ${productCodeAfter}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   abbr=Product code planned
    Should be true    '${productCodeAfter}'=='${productCode}'

CommonCase052.Manual_SiSo_CM_Commissioning_Configuration_reset
    [Documentation]   detail steps
    ...    1. Login to WebUI
    ...    2. reset configuration and check SMOD, RMOD status.
    [Arguments]     ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}  ${ru_index}=1
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    #${scf_backup}    COAM_Admin.BackupSCF
    ${ru_info}       selenium_coam.get_ru_info    ru_index=${ru_index}
    Should Be True   '${ru_info['Status']['Operational state']}'=='enabled'
    Should Be True   '${ru_info['Status']['Usage state']}'=='Active'
    selenium_coam.configuration_reset
    KW.CaseDestroy
#    run keyword and ignore error    COAM_WebEM.Logout
    #TODO Check status
    set suite variable     ${WEBUI_IP}    ${ASIK_IP}
    [Teardown]   KW.Recommission    scf=${scf}

CommonCase053.General_SiSo_Commissioning_BTS_Template_Commissioning
    Set test variable    ${mrbtsID}    ${tl.gnbs[0].instance_id}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${modify_params}  ${origin_params}  Modify TimeZone In Scf And Commissioning LTE
    sleep    120
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${modify_params}
    Modify Parameters On Webem  ${origin_params}
    sleep    180
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${origin_params}
    [Teardown]  Selenium Logout And Close Browser

CommonCase054.General_SiSo_Automatic_factory_RFSW_update
    #[Arguments]  ${target_old_version}=${TCCB005845_TC54['target_old_version']}
    #set test variable    ${target_old_version}
    CommonCase055.General_SiSo_Auto_Automatic_RAT_SW_upgrade

CommonCase055.General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check functionality of the automatic software upgrade of RFSW
    ...    in case of incompatible RFSW.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.16.2020 - https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    - 07.29.2020 - add fault 23
    ...    *******************
    ...    Notice: run this kw can add as -v target_old_version:10.1800.xxxx
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    #need config old version firstly
    ${Old_SW_version}    get old sw version    SW=${Active_SW_version}
    log to console  OLD_SW_PKG:${Old_SW_version}, NEW_SW_PKG:${Active_SW_version}
    ${OLD_SW_PKG}  Download SW  SW=${Old_SW_version}
    ${NEW_SW_PKG}  Download SW  SW=${Active_SW_version}
    log to console  start deploy to OLD_SW_PKG:${OLD_SW_PKG}
    Perform SW Update  ${SAVE LOG DIRECTORY}${OLD_SW_PKG}
    Wait Until Keyword Succeeds    10min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    180s    Check HW modules detection
    Change active partition
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    log to console  start check fault 23 present
    Wait For Expect Fault Present  faultId=23   timeout=1200
    log to console  start deploy to NEW_SW_PKG:${NEW_SW_PKG}
    Perform SW Update  ${SAVE LOG DIRECTORY}${NEW_SW_PKG}
    Wait Until Keyword Succeeds    10min    30s    Connect to gnb coam via ssl
    log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=1200
    COAM Wait gnb And Cells ready    timeout=15 min
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
            ${radio_type}    get ru type  ru_index=${ru_index}
            ${ruSW_expect}    get RFSW version from TargetBD    radio_type=${radio_type}
            ${ruSW_fromModule}    get RFSW version from radio module    ru_index=${ru_index}
            should be true    '${ruSW_fromModule}'=='${ruSW_expect}'
    END
    [Teardown]  run keywords  Selenium Logout And Close Browser    AND    Remove Downloaded Content  ${NEW_SW_PKG}  ${OLD_SW_PKG}

CommonCase056.SWM_Software_Upgrade
    [Arguments]   ${max_num}=500   ${status}=[released ,released_with_restrictions]
    ...           ${conditions}=${condition_PS_diff}
    #TC.5GC002479_SWM_Software_Upgrade    max_num=${max_num}   stream=${stream}    status=${status}    conditions=${conditions}
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
    set suite variable     ${SWM}     ${1}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    ${TargetBuildVersion}=         Set Variable         ${version_Target}
    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${StreamTarget}    status=${status}       conditions=${conditions}
    log to console    original=${OriginalBuildVersion}
    log to console    target=${TargetBuildVersion}
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to  load software
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}
    ${download_startTime}    KW.TimerStart
    log to console   start to software update with active
    selenium_coam.software_update     is_activate=${True}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    ${SW_download_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console   download duration is ${SW_download_duration}
    set suite variable     ${SW_download_duration}
    set suite variable     ${SWM}     ${2}
    ${active_startTime}    KW.TimerStart
    log to console    ckeck bts reset
    Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    log to console    waitAllCellsOnair
    #KW.RestartSAS
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    ${SW_active_duration}     KW.TimerStop    timestart=${active_startTime}
    ${SW_upgrade_duration}     KW.TimerStop    timestart=${download_startTime}
    log to console    active duration is ${SW_active_duration}
    log to console    KPI4 duration is ${SW_upgrade_duration}
    set suite variable     ${SW_active_duration}
    set suite variable     ${SW_upgrade_duration}
    set suite variable     ${SWM}     ${3}

CommonCase057.OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Documentation]  Aim to test RF Reset success rate
    ...    Steps:
    ...    Step1: loop defined times to reset ru on webui and onair
    ...    Step2: check the duration and pass rate of ru reset
    ...    Case Input:
    ...    please refer to [Arguments]
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['RF_reset_times']}
#    ...          ${ru_index}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['ru_index']}
#    ...          ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_MAX']}
#    ...          ${kpi_avg}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG']}
    TC.5GC002479_HA_08_OAM_KPI_51_RU_Reset_Time    RF_reset_times=${retry_times}
    TC.5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate

CommonCase058.OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}
#    ...    ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}
#    ...    ${kpi_avg}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']}
    TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    ...    WebUI_reset_times= ${retry_times}

CommonCase059.OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
    [Documentation]  Aim to test SW upgrade success rate
    ...    Steps:
    ...    Step1: Prepare target sw and intermediate sw
    ...    Step2: loop defined times to Yaft BTS active/passive to intermediate sw, then upgrade to target sw
    ...    Step3: check the duration and password of upgrade to target sw.
    ...    Case Input:
    ...    please refer to [Arguments]
    [Arguments]  ${retry_times}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['SW_update_times']}
#    ...          ${kpi_max}=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}
    KW.CaseStatusInit      retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        set suite variable     ${SWM}                            ${0}
        set suite variable     ${SW_active_duration}             ${18000}
        run keyword and ignore error    KW.SWM.CheckIfSWActiveRun    stream=${TargetBTSStream}   conditions=&{condition_ru_same}
        KW.CaseStatusCaluate    duration=${SW_active_duration}    max=${CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']}
    END
    KW.CaseStatusFinnal    case_avg=${18000}    max_loop=${retry_times}
    KW.PassRateStatusFinal

CommonCase060.General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2020 - - Created
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]    ${is_get_snapshot_via_selenium}=${True}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

CommonCase061.Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
    [Arguments]    ${Manual_SiSo_ALD_SN}=${CASE_INPUT_CB008445['Manual_SiSo_ALD_SN']}
    COAM_WebEM.Login
    ${ALDSN_NO}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1   abbr=serialNumber
    should be equal    ${ALDSN_NO}   ${Manual_SiSo_ALD_SN}

#CommonCase062.LTE_Verify_the_behavior_of_pre_Tx_measurement_when_online_add_CBRS_cell2
#    [Documentation]  2CC TestCase
#    [Arguments]  ${cell_idx}=2
#    KW.Online Cell addition CBSD Cell   BaseSCF1CC=${CFGFILE_PATH}/${TL_BASE_SCF}    addition_deletion_cell=${cell_idx}
CommonCase062.NR_Verify_the switch between non-contiguous and contiguous CA_with_channelSpacing_Update_grantId_change
    [Arguments]    ${BaseSCF2CC}    ${technology}=NR
    COAM_Admin.commission    scf_file=${BaseSCF2CC}
    #run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login
    ${info_0}    selenium_coam.get_cell_info    cell_idx=${1}    technology=${technology}
    ${info_1}    selenium_coam.get_cell_info    cell_idx=${2}    technology=${technology}
    ${spacing}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCBRSPR-1    abbr=Channel spacing between two cells
    ${spacing}    Fetch From Left     ${spacing}    (kHz)
    ${freq0}    Fetch From Left     ${info_0['Carrier frequency']}    MHz
    ${freq1}    Fetch From Left     ${info_1['Carrier frequency']}    MHz
    ${realspcing}    Evaluate    abs(${freq0.strip()}*1000-${freq1.strip()}*1000)
    ${freq0}    Fetch From Left     ${info_0['Channel bandwidth']}    MHz
    ${freq1}    Fetch From Left     ${info_1['Channel bandwidth']}    MHz
    ${bandspace}      Evaluate    abs(${freq0.strip()}*1000+${freq1.strip()}*1000)/2
    run keyword if    ${realspcing}<=${bandspace}    Should Be Equal As Numbers    ${spacing.strip()}    ${realspcing}

    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCBRSPR-1    abbr=Channel spacing between two cells    value=69000
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout

    COAM_WebEM.Login
    ${info_0}    selenium_coam.get_cell_info    cell_idx=${1}    technology=${technology}
    ${info_1}    selenium_coam.get_cell_info    cell_idx=${2}    technology=${technology}
    ${spacing}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCBRSPR-1    abbr=Channel spacing between two cells
    ${spacing}    Fetch From Left     ${spacing}    (kHz)
    ${freq0}    Fetch From Left     ${info_0['Carrier frequency']}    MHz
    ${freq1}    Fetch From Left     ${info_1['Carrier frequency']}    MHz
    ${realspcing}    Evaluate    abs(${freq0.strip()}*1000-${freq1.strip()}*1000)
    ${freq0}    Fetch From Left     ${info_0['Channel bandwidth']}    MHz
    ${freq1}    Fetch From Left     ${info_1['Channel bandwidth']}    MHz
    ${bandspace}      Evaluate    abs(${freq0.strip()}*1000+${freq1.strip()}*1000)/2
    run keyword if    ${realspcing}<=${bandspace}    Should Be Equal As Numbers    ${spacing.strip()}    ${realspcing}
    run keyword and ignore error    COAM_WebEM.Logout

CBRSCase01.NR_check_maxEirp_limitation_with_desiredPmax_and_maxGrantPwrRed
    log to console    Step1: change desiredPmax = 16dBm of cell1 and cells, active SCF
    COAM_WebEM.Login
    KW.ModifyPmax    isCBRS=${CASE_INPUT_SISO['Pmax']['isCBRS']}    newValue=${5}
    ...    celltype=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    10 times    30s    COAM_WebEM.CheckAlarm    id=6828    present=true
    run keyword and ignore error   COAM_WebEM.Logout
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${WEBUI_IP}
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    FOR  ${item}  IN  @{CellsInfonr}
        Should be equal as strings    ${item['status']['operationalState']}    disabled    ignore_case=${True}
    END

    log to console    Step2: change desiredPmax = 25dBm of cell1 and cells, active SCF
    COAM_WebEM.Login
    KW.ModifyPmax    isCBRS=${CASE_INPUT_SISO['Pmax']['isCBRS']}    newValue=${25}
    ...    celltype=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    10 times    30s    COAM_WebEM.CheckAlarm    id=6828    present=true
    run keyword and ignore error   COAM_WebEM.Logout
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${WEBUI_IP}
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    FOR  ${item}  IN  @{CellsInfonr}
        Should be equal as strings    ${item['status']['operationalState']}    disabled    ignore_case=${True}
    END

    log to console    Step3: change desiredPmax = 20dBm, antennaGain = 8dBi, active SCF
    COAM_WebEM.Login
    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
    ...    distName=${MRBTS_ID}/${NRBTS_ID}/NRCBSD-1
    ...    abbr=Antenna gain    value=${8}
    KW.ModifyPmax    isCBRS=${CASE_INPUT_SISO['Pmax']['isCBRS']}    newValue=${20}
    ...    celltype=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=6828    present=true
    run keyword and ignore error   COAM_WebEM.Logout
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${WEBUI_IP}
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    FOR  ${item}  IN  @{CellsInfonr}
        Should be equal as strings    ${item['status']['operationalState']}    disabled    ignore_case=${True}
    END

    log to console    Step4: change maxGrantPwrRed = 5dB of cell1 and cells, active SCF
    ${cell_list}    get all cell id    cell_type=${CASE_INPUT_SISO['SISOCommon']['cell_type']}
    COAM_WebEM.Login
    FOR    ${cellid}    IN    @{cell_list}
         Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
         ...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}/NRCBSDCELL-0
         ...    abbr=Maximum allowed grant power reduction    value=${5}
    END
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=6828    present=false
    sleep  60s
    run keyword and ignore error   COAM_WebEM.Logout
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${WEBUI_IP}
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    FOR  ${item}  IN  @{CellsInfonr}
        Should be equal as strings    ${item['status']['operationalState']}    Enabled    ignore_case=${True}
        ${pMax}=    Set Variable    ${item['maximumOutputPower']}
        Should Be Equal    '${pMax}'    '${18.9}'
    END

CommonCase200.Attach_SR_on_different_PRACH_FreqOffset_chagne
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=PRACH_0
    sleep  120s
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=PRACH_2
    sleep  120s
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=PRACH_3
    sleep  120s
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=PRACH_8

CommonCase201.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_40MHz+100MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_40M_100M
CommonCase202.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_40MHz+40MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_40M_40M
CommonCase203.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+20MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_20M_20M
CommonCase204.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+100MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_20M_100M
CommonCase205.General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+40MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_20M_40M
CommonCase206.CB008712_NR_General_SiSo_commission_with_2CC_70MHz+80MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_70M_80M
CommonCase207.CB008712_NR_General_SiSo_commission_with_2CC_30MHz+60MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_30M_60M
CommonCase208.CB008712_NR_General_SiSo_commission_with_2CC_50MHz+90MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_50M_90M
CommonCase209.Peak throughput with UL 64QAM Modulation on different bandwidth
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM
CommonCase210.Peak throughput with DL 256QAM Modulation on different bandwidth
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM
CommonCase211.Peak throughput with DL 256QAM Modulation on different bandwidth_40M PCell_100M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_40M_100M
CommonCase212.Peak throughput with UL 64QAM Modulation on different bandwidth_40M PCell_100M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_40M_100M
CommonCase213.Manual_SiSo_CALL_LTE_data_call_1CC_20MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=1CC_20M
CommonCase214.Manual_SiSo_CALL_LTE_data_call_2CC_10MHz+10MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_10M_10M
CommonCase215.Manual_SiSo_CALL_LTE_data_call_2CC_20MHz+20MHz
    [Arguments]    ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
#    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_20M_20M
#    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
#    run keyword if  '${wa}'!='NULL'    KW.RestartSAS
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    COAM_WebEM.Login
    ${cell_list}    KW.Get All Cell Id
    ${cell_num}    get length    ${cell_list}
    ${technology}    convert to upper case  ${technology}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=lock      technology=${technology}
    DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=unlock      technology=${technology}
    Run Keyword And Ignore Error     COAM_WebEM.Logout

CommonCase216.Multi Carrier_Commission and Throughpu with DL interference
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=MULTI_TP
CommonCase217.Manual_SiSo_CALL_LTE_data_call_2CC_10MHz+20MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=2CC_10M_20M
CommonCase218.Peak throughput testing with 20Mhz and multiple attach_detach
    KW.SetUEParameter  ul=12   dl=247   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_MULTI_ATTACH
CommonCase219.Peak throughput with UL 64QAM Modulation on different bandwidth_20MHz
    KW.SetUEParameter  ul=12   dl=250   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_20M
CommonCase220.Peak throughput with UL 64QAM Modulation on different bandwidth_10MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_10M
CommonCase221.Peak throughput with DL 256QAM Modulation on different bandwidth_20MHz
    KW.SetUEParameter  ul=12   dl=247   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_20M
CommonCase222.Peak throughput with DL 256QAM Modulation on different bandwidth_10MHz
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_10M
CommonCase223.Peak throughput with UL 64QAM Modulation on different bandwidth_20M PCell_20M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_20M_20M
CommonCase224.Peak throughput with UL 64QAM Modulation on different bandwidth_10M PCell_10M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_10M_10M
CommonCase225.Peak throughput with UL 64QAM Modulation on different bandwidth_10M PCell_20M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_64QAM_10M_20M
CommonCase226.Peak throughput with DL 256QAM Modulation on different bandwidth_20M PCell_20M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_20M_20M
CommonCase227.Peak throughput with DL 256QAM Modulation on different bandwidth_10M PCell_10M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_10M_10M
CommonCase228.Peak throughput with DL 256QAM Modulation on different bandwidth_10M PCell_20M SCell
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=TP_256QAM_10M_20M
CommonCase229.Manual_SiSo_CALL_LTE_data_call_1CC_20MHz_ASIL+ABIN
    KW.SetUEParameter  ul=12   dl=100   ue_index=0
    KW.CommonCall    scf=${CFGFILE_PATH}/${TL_BASE_SCF}    TCID=1CC_20MHz_ASIL_ABIN

CommonCase230.Attach SR on different PRACH configuration recommison
    [Documentation]   detail steps 4Gonly
    ...       1.commission with correct prach parameters
    ...       2.Call and Capture BIP log
    ...       3.Check Prach Message success and no retry
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    # 10M Testing
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC01
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #Log.StartCaptureBip
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=10
    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=10
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall

KW.COAMAdmin_Login
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    15min    30s    Connect to gnb coam via ssl

KW.Get lcrId via webem
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}
    ${orig_value}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...  filter_param=Local cell resource ID
    [Return]  ${orig_value}

KW.Online Cell addition deletion
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${addition_deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${addition_deletion_cell}
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    sleep    60s
    verify all cells should be onair
    [Return]  selenium logout and close browser

KW.Online Cell addition CBSD Cell
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${BaseSCF1CC}    ${addition_deletion_cell}=1${connection}=GNB_OAM
    #load 1cc scf
    COAM_Admin.commission    scf_file=${BaseSCF1CC}
    #run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #start log
    &{logtype}     create dictionary    btslog={"type":"true"}
    Log.Init     logtype=${logtype}
    #add cell 2 need to modify
    log to console  add object
    COAM_WebEM.Login
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${btslog}    Log.Collect
    run    tar xvf ${btslog} -C  ${LOG_PATH}
    ${CBSDTX}    run    cat ${LOG_PATH}/SYSLOG*.LOG |grep  "trigger pre-tx measurement"
    Should be empty    ${CBSDTX}
    [Return]  selenium logout and close browser

KW.General_SiSo_RF_alarms_with_recovery
    [Arguments]  ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${ru_index}
    Wait until keyword succeeds    20min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
	Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1901
    log to console    \n Check GNB cell on air
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    [Teardown]  Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}

KW.General_SiSo_LED_states_management_basic
    [Arguments]  ${ru_index}=1
    set test variable      ${TS_CASE_LOG_PATH}    ${LOG_PATH}
    Perform RU Power reset    ru_index=${ru_index}
    ${led_status_list}  create list  YELLOW YELLOW  YELLOW OFF  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list}    log_name=power_reset    ru_index=${ru_index}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    Perform RU Lock And Unlock    ru_index=${ru_index}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    ${led_status_list_1}  create list  YELLOW YELLOW  GREEN GREEN
    ${new_timestamp}  Check LED Status In RU Log    led_status_list=${led_status_list_1}    log_name=lock_and_unlock    ru_index=${ru_index}
    ...    timestamp=${new_timestamp}
    [Teardown]  Selenium Logout And Close Browser

KW.Sync Startup is verified
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    log to console  \n***Sync Startup is verified***
    ${bts_sync_mode}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1    filter_param=BTS synchronization mode
    ${bts_sync_mode_1}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/CLOCK_R-1
    ...    filter_param=Active synchronization mode
    should be equal as strings    ${bts_sync_mode_1}    ${bts_sync_mode}
    ${eCPRI_Master_clock_state}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...    filter_param=eCPRI Master clock state
    should be equal as strings    ${eCPRI_Master_clock_state}    MASTER_CLOCK_OK
    KW.Check eCPRI Basic configuration via SOAP message

KW.Check eCPRI Basic configuration via SOAP message
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]
    ${output}    KW.Check Btsom Log file on ASIK   filter=API    alias=ASIK Master
    Should Contain    ${output}    Sending API_INET_VLAN_SET_REQ_MSG
    Should Contain    ${output}    Sending API_START_PTP_REQ_MSG
    Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status EeCpriStatus_NoError

KW.Check Btsom Log file on ASIK
    [Documentation]    Author:jie-jessy.li@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn    ${filter}=None
    Connect to Common Unit Master     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${0a}        Run Keyword And Return Status    csn.assert file exists    remote_path=/ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz
    ...          connection=${alias}
    ${logfolder}    Set Variable If    '${0a}'=='True'    fct-0a_aasyslog      fct-4a_aasyslog
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}

KW.Power On RU_and_check RF Delayed Startup LTE
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU_and_check RF Delayed Startup***
    FOR  ${ru_index}  IN  @{ru_index_list}
         Perform RU Power On LTE    ru_index=${ru_index}    model=${tl.enbs[0].rms[0].pdu_port.pdu.vendor}
    END
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589

KW.General_SiSo_eCPRI_synchronization_status_NIDD_parameters
    [Arguments]    ${parameters_list}=parameters_list   ${local_dir}=${OUTPUT_DIR}   ${file_name}=full_commission.xml
    ...   ${connection}=GNB_OAM
    coam wait gnb and cells ready    timeout=15min
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=30
    ${xml}   ParseXML.Parse XML   ${OUTPUT_DIR}/${file_name}
    FOR   ${item}   IN   @{parameters_list}
       ${class_name}   Set Variable   ${item['class_name']}
       ${parameter}   Set Variable   ${item['parameter']}
    run Keyword And continue on failure    ParseXML.Element Should Exist
    ...   ${xml}   cmData/managedObject[@class="${class_name}"]/p[@name="${parameter}"]
    END
    Selenium Logout And Close Browser


KW.Power On RU And Check
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU And Check***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

KW.Modify Tdanger Value In Json File with RU reset
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1
    log to console    \n Modify Tdanger Value In Json File
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/tcs.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs.bin" "/var/tmp/tcs.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    KW.Perform RU Reset     ru_index=${ru_index}
    sleep    300s
    [Teardown]    csn.disconnect    connection=ASIK Master

KW.Perform RU Reset
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}
    ${ru_index}  Convert To Integer    ${ru_index}
    ${index}     Evaluate    ${ru_index}-1
    Power.Reset5GRU    model=${tl.gnbs[0].dus[0].rus[${index}].pdu_port.pdu.vendor}
#    COAM_WebEM.Login
#    selenium_coam.reset_ru  ru_index=${ru_index}
#    [Teardown]  COAM_WebEM.Logout

KW.CollectSnapshot
    COAM_WebEM.Login    version=${CASE_INPUT_SISO['SISOCommon']['release']}
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${snapshot_file}   separator=/     max_split=1
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}/.
    Run Keyword And Ignore Error    run    command=rm ${snapshot_file}
    [Return]    ${LOG_PATH}/${SNAPSHOTNAME}

KW.CheckSnapshotLog
    [Arguments]  ${log}    ${string}=Last reset cause: BTS (4)
    run   rm -rf ${LOG_PATH}/SnapShot
    run   unzip ${log} -d ${LOG_PATH}/SnapShot&&cd ${LOG_PATH}/SnapShot&&unzip -o '*.zip'&&unzip '*_L_1_runtime.zip'&&xz -d runtime_DEFAULT.log.xz
    ${result}    run   cat ${LOG_PATH}/SnapShot/runtime_DEFAULT.log|grep '${string}'
    Should Not Be Empty   ${result}
KW.RestartSAS
    [Arguments]  ${ue_index}=0    ${saspath}=/cygdrive/c/sasserver/
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=UE_PC_${ue_index}
    ${DLPID}  Conn.Execute  cmd=ps -Wef|grep python|awk '{{print $2}}'|xargs /bin/kill -f     alias=UE_PC_${ue_index}
    Conn.Execute  cmd=killall python      alias=UE_PC_${ue_index}
    ssh.send_command    cd ${saspath}&&python -i SAS_Sim.py    connection=UE_PC_${ue_index}
    Wait Until Keyword Succeeds    4min    20sec    ViVi.CheckIperfPresent
    ...    cmd=ps -Wef | grep python    checkpoint=python    alias=UE_PC_${ue_index}

KW.GetSASLog
    [Arguments]  ${ue_index}=0    ${saspath}=/cygdrive/c/sasserver/
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=SAS_PC_${ue_index}
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    ssh.download_file   local_path=${LOG_PATH}/SAS_Sim_${filename}.log    remote_path=${saspath}SAS_Sim.log
    ...    connection=SAS_PC_${ue_index}
    ssh.disconnect    connection=SAS_PC_${ue_index}

KW.RestartSAS_UTE
    [Arguments]   ${saspath}=/opt/ute/tools/sasserver/
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["server"]}
    ...    USERNAME=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["username"]}
    ...    PASSWORD=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["password"]}   alias=SAS_UTE
    Conn.Execute  cmd=ps -ef|grep SAS_Sim|grep -v grep|awk '{print $2}' | xargs kill -9    alias=SAS_UTE
    ssh.send_command    cd ${saspath}&&python SAS_Sim.py    connection=SAS_UTE
    ${result}    run    ps -ef|grep SAS_Sim
    log    ${result}
	Conn.Disconnect   alias=SAS_UTE

KW.GetSASLog_UTE
    [Arguments]  ${saspath}=/opt/ute/tools/sasserver/
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    #run   cp ${saspath}SAS_Sim.log ${LOG_PATH}/SAS_Sim_${filename}.log
	wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["server"]}
    ...    USERNAME=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["username"]}
    ...    PASSWORD=${CASE_INPUT_SISO["CBSD"]["SAS_Sim"]["password"]}   alias=SAS_Log
	Conn.Execute  cmd=scp ${saspath}SAS_Sim.log ${LOG_PATH}/SAS_Sim_${filename}.log   alias=SAS_Log
	ssh.download_file   local_path=${LOG_PATH}/SAS_Sim_${filename}.log
	...    remote_path=${saspath}SAS_Sim.log   connection=SAS_Log
	Conn.Disconnect   alias=SAS_Log

KW.CaseDestroy
    Log to Console    KW.CaseDestroy
    Run Keyword And Ignore error    COAM.Logout
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
KW.GenerateAlarm1901AndClearIt
    [Arguments]  ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk    ru_index=${ru_index}
    run keyword and ignore error    KW.RestartSAS
    Wait until keyword succeeds    20min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    10min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
	Wait until keyword succeeds    20min    120s    Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk
    ...    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1901
    log to console    \n Check GNB cell on air
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    [Teardown]  Modify Calibration File On RU Unit    current_name=calibration_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}
KW.SetCBSDParameters
    [Arguments]     ${ts}    ${version}
    COAM_WebEM.SetParameterValue
    #MRBTS-1101/NRBTS-1101/NRCBRSPR-1
    #...    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cellid}    abbr=Primary SAS server    value=${ts}
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   5min   1min    KW.GetAndCheckCBSD    ts=${ts}    version=${version}    state=Registered
KW.GetAndCheckCBSD
    [Arguments]     ${ts}    ${version}    ${state}=Registered
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBRSPR-1
    ...    abbr=Primary SAS server
    should be true    '${result}'=='${ts}'
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBRSPR-1
    ...    abbr=WINNF technical specification version
    should be true    '${result}'=='${version}'
    ${result}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CBRS_PREFIX}CBSD-1
    ...    abbr=CBSD registration state
    should be true    '${result}'=='${state}'

KW.Recommission
    [Arguments]   ${scf}=${CFGFILE_PATH}/${TL_BASE_SCF}
    COAM_Admin.commission    scf_file=${scf}
    run keyword and ignore error    KW.RestartSAS
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir
    #get_hw_parameters

gNB.ConnectToRU
    [Arguments]    ${ru_ip}    ${ru_username}    ${ru_pasword}    ${ru_asias}=${ALIAS_RMOD}    ${proxy}=${ALIAS_ASIK}
    taf.transport.ssh.Connect To    hostname=${ru_ip}
    ...                             username=${ru_username}
    ...                             password=${ru_pasword}
    ...                             proxy=${proxy}
    ...                             alias=${ru_asias}
DoTputCall
    log    DoTputCall
    log to console    ${TLCommonConfig_8712['MultiUECFG']}
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=157.3M
    MultiUE.L3Call    UECFG=${TLCommonConfig_8712['MultiUECFG']}

COAM_WEBEM.LockUnlcokCell_LTE
    [Documentation]   Lock Cell if cell is unlocked, UnLock cell if cell is locked.
    [Arguments]   ${cell_idx}=1    ${action}=lock    ${checkstatus}=true    ${technology}=NR
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}    technology=${technology}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='lock'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=locked
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='lock'    locked    unlocked
    Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}    technology=${technology}

COAM_WEBEM.shutdownUnlcokCell
    [Documentation]   shuttingdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${action}=shuttingdown    ${checkstatus}=true    ${technology}=NR
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}    technology=${technology}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    ${btsstate}    Convert To Lower Case    ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='shuttingdown'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=shutting down
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='shuttingdown'    	locked    unlocked
    Wait Until Keyword Succeeds    10 times    60s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}    technology=${technology}

COAM_WEBEM.CheckshutdownUnlcokCellStatus
    [Documentation]   shutdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${status}=shuttingdown
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=='${status}'

SCF.GetCaseSCFFromDelta
    [Arguments]   ${InputFile}=NULL    ${TCID}=0
    gNB.GenerateCaseSCF     InputFile=${InputFile}
    ...                     OutputFile=${LOG_PATH}/${TCID}.xml
    ...                     ResourceFolder=${CURDIR}
    ...                     ParameterToDelete=PARAMETER_TO_DELETE_${TCID}
    ...                     MOsToAdd=MOS_TO_ADD_${TCID}
    ...                     ParamterToModify=PARAMETER_TO_MODIFY_${TCID}
    ...                     ListParamterToModify=LIST_PARAMS_TO_MODIFY_${TCID}
    ...                     ListToAdd=LIST_TO_ADD_${TCID}
    [Return]    ${LOG_PATH}/${TCID}.xml

KW.CommonCall
    [Arguments]   ${scf}    ${TCID}=TC01    ${wa}=NULL
    ${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=${TCID}
    run keyword if  '${scf}'!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    run keyword if  '${wa}'!='NULL'    KW.RestartSAS
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    DoTputCall

KW.SetUEParameter
    [Arguments]   ${ul}=NULL    ${dl}=NULL    ${ue_index}=0
    run keyword if    '${ul}'!='NULL'
    ...    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['${ue_index}']['ul']}    target_throughput=${ul}
    run keyword if    '${dl}'!='NULL'
    ...    Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['${ue_index}']['dl']}    target_throughput=${dl}

KW.Change NCPRI PM Interval LTE
    [Arguments]  ${interval}
    log to console   \nChange NCPRI PM Interval to ${interval}
#    Selenium Logout And Close Browser
#    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
#    ...    username=${http_username}    password=${http_password}
    COAM_WebEM.Login
    ${dist_name}    set variable    ${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ${filter_param}    set variable    SBTS eCPRI Master Statistics
    ${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=eCpriMasterStatisticsInterval    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    5s
    [Return]    ${origin_value}
    [Teardown]  COAM_WebEM.Logout
KW.Check Sync Counter LTE
    [Arguments]    ${change_interval}=5
    log to console  \n***Check Sync Counter***
    Wait Until Next Counter Update    counter_period=${change_interval}
    run keyword if    '${change_interval}'=='5'    sleep    300s
    ...    ELSE    sleep    900s
    COAM_WebEM.Login
    ${SyncMsg_Latest_value}    Get Transport Counters    counter_id=M40102C0
    ...                                        full_path=TNL-2/ETHSVC-1/ETHLK-2/SBTS_NCPRI/topTxEcpriMstSyncMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    run keyword and ignore error    selenium_coam.refresh_page
    ${AnnMsg_Latest_value}    Get Transport Counters    counter_id=M40102C1
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topTxEcpriMstAnnounceMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayRespMsg_Latest_value}    Get Transport Counters    counter_id=M40102C2
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topTxEcpriMstDelayRespMessg
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayReqMsg_Latest_value}    Get Transport Counters    counter_id=M40102C3
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/topRxEcpriMstDelayReqMessg
    Should Be True    ${DelayReqMsg_Latest_value}>=${DelayRespMsg_Latest_value}
    run keyword and ignore error    selenium_coam.refresh_page
    ${SsmMsg_Latest_value}    Get Transport Counters    counter_id=M40102C4
    ...                                       full_path=TNL-2/ETHLK/ETHLK-2/SBTS_NCPRI/synceTxEcpriMstSsmMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302
    [Teardown]  COAM_WebEM.Logout

SISO 8712 Suite Setup
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    set suite variable      ${SAVE LOG DIRECTORY}    ${LOG_PATH}
    set suite variable      ${UPDATE_FILE_PATH}      ${LOG_PATH}
    set suite variable      ${SUITE_LOG_PATH}        ${LOG_PATH}
    set suite variable      ${CASE_LOG_PATH}         ${LOG_PATH}

#    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
#    set suite variable    ${TARGETSW}    ${version_Target}
#    set suite variable    ${TargetStream}     ${StreamTarget}
#    set suite variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/${TL_BASE_SCF}

    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true
    ${TL_BASE_SCF}    set variable if    "${is_lte}"=="true"    ${TL_BASE_SCF_LTE}    ${TL_BASE_SCF_NR}
    ${TL_BASE_SCF}    set suite variable    ${TL_BASE_SCF}
    gNB.FormatBTSID    lte=${is_lte}

    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl

KW.RU Should Be Power Off
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    disabled
                                  ...  msg=Current RU operationalStatus is not in Disabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    off line
                                  ...  msg=Current RU availabilityStatus is not in NotInstalled status    ignore_case=${True}

KW.Check_Integrity_On_RU
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  sudo openssl x509 -in /etc/ssl/certs/NokiaRootCA.pem -text -noout
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should contain  ${output}  Signature Algorithm: sha256WithRSAEncryption
    Should contain  ${output}  Digital Signature, Certificate Sign, CRL Sign
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

KW.GetAndCheckAlarms
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459
    COAM_WebEM.Login
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...    append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    COAM_WebEM.Logout

CommonCase.Manual_SiSo_CALL_LTE_data_call
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}

CommonCase.Manual_SiSo_CALL_LTE_data_call_2CC
    [Arguments]   ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
	${technology}    convert to upper case    ${technology}
	COAM_WebEM.Login
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
	${cell_num}    get length    ${cell_list}
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=unlock      technology=${technology}
    Run Keyword And Ignore Error     COAM_WebEM.Logout

KW.Get All Cell Id
    [Arguments]  ${cell_type}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}  ${connection}=GNB_OAM
    ${output}=    coam.get_cells_info    cell_type=${cell_type}    timeout=60       connection=${connection}
    ${cell_list}  create list
    FOR  ${cell}  IN  @{output}
        append to list  ${cell_list}  ${cell['globalCellId']}
    END
    [Return]  ${cell_list}


KW.General_SiSo_Online_Cell_addition_deletion_CBRS
    Run Keyword if    "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"
    ...    KW.General_SiSo_Online_Cell_addition_deletion_CBRS_LTE
    ...    ELSE    KW.General_SiSo_Online_Cell_addition_deletion_CBRS_NR


KW.General_SiSo_Online_Cell_addition_deletion_CBRS_LTE
    [Arguments]   ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
	${technology}    convert to upper case    ${technology}
    COAM_WebEM.Login
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte
    ${SAVE LOG DIRECTORY}    set variable    ${SUITE_LOG_PATH}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
#    ${lcrid}    set variable    2
#    ${phyCellId}    set variable    318

    ${lcrid}    selenium_coam.get_parameter_value  dist_name=${mrbtsID}/${nrbtsID}/LNCEL-2
    ...  filter_param=Local cell resource ID
    ${phyCellId}    selenium_coam.get_parameter_value  dist_name=${mrbtsID}/${nrbtsID}/LNCEL-2
    ...  filter_param=Physical layer cell identity

    selenium_coam.remove_object    object_name=${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2    timeout=15
    selenium_coam.remove_object    object_name=${mrbtsID}/${nrbtsID}/LNCEL-2    timeout=15

    selenium_coam.validate_plan
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte
    Run Keyword And Ignore Error    COAM_WebEM.Logout

    DoTputCall

    log to console    Add Cell
    COAM_WebEM.Login

    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    selenium_coam.add_object    object_name=${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1
    ...    include_subobject=${True}   id_value=2    timeout=15
    selenium_coam.add_object    object_name=${mrbtsID}/${nrbtsID}
    ...    object_class_name=LNCEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${mrbtsID}/${nrbtsID}/LNCEL-1
    ...    include_subobject=${True}   id_value=2    timeout=15

    selenium_coam.set_parameter_value    dist_name=${mrbtsID}/${nrbtsID}/LNCEL-2
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    selenium_coam.set_parameter_value    dist_name=${mrbtsID}/${nrbtsID}/LNCEL-2
    ...    filter_param=Physical layer cell identity    abbr=phyCellId    new_value=${phyCellId}

    selenium_coam.validate_plan
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte

    Run Keyword And Ignore Error    COAM_WebEM.Logout

    COAM_WebEM.Login
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
	${cell_num}    get length    ${cell_list}
	log to console    UE attach to Cell1
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=2      action=unlock      technology=${technology}

    log to console    UE attach to Cell2
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=lock      technology=${technology}
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  '${technology}'=="LTE" and ${cell_num}>1    COAM_WEBEM.LockUnlcokCell_LTE
    ...     cell_idx=1      action=unlock      technology=${technology}
    Run Keyword And Ignore Error    COAM_WebEM.Logout



KW.General_SiSo_Online_Cell_addition_deletion_CBRS_NR
    [Arguments]   ${technology}=${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}
	${technology}    convert to upper case    ${technology}
    ${SAVE LOG DIRECTORY}    set variable    ${SUITE_LOG_PATH}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    !!!!!!Starting!!!!!!
	COAM_WebEM.Login
    ${lcrid}    selenium_coam.get_parameter_value  dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...  filter_param=Local cell resource ID
    ${phyCellId}    selenium_coam.get_parameter_value  dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...  filter_param=Physical cell identifier
    ${nrarfcn}    selenium_coam.get_parameter_value  dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...  filter_param=NR Absolute radio frequency channel number

    selenium_coam.remove_object    object_name=${MRBTSID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    timeout=15
    selenium_coam.remove_object    object_name=${MRBTSID}/${NRBTSID}/NRCELL-2    timeout=15
    selenium_coam.remove_object    object_name=${MRBTSID}/${NRBTSID}/NRCELLGRP-1    timeout=15
    selenium_coam.remove_element   dist_name=${MRBTSID}/${NRBTSID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${1}    timeout=15

    selenium_coam.validate_plan
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    Run Keyword And Ignore Error    COAM_WebEM.Logout

    Run Keyword And Continue On Failure    DoTputCall

    log to console   Add Cell
    COAM_WebEM.Login

    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=${MRBTSID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    selenium_coam.add_object    object_name=${MRBTSID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${MRBTSID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${True}   id_value=2    timeout=15
    selenium_coam.add_object    object_name=${MRBTSID}/${NRBTSID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${MRBTSID}/${NRBTSID}/NRCELL-1
    ...    include_subobject=${True}   id_value=2    timeout=15
    selenium_coam.add_object    object_name=${MRBTSID}/${NRBTSID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${MRBTSID}/${NRBTSID}/NRCELLGRP-0
    ...    include_subobject=${True}   id_value=1    timeout=15

    selenium_coam.set_parameter_value    dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    selenium_coam.set_parameter_value    dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...    filter_param=Physical cell identifier    abbr=physCellId    new_value=${phyCellId}
    selenium_coam.set_parameter_value    dist_name=${MRBTSID}/${NRBTSID}/NRCELL-2
    ...    filter_param=NR Absolute radio frequency channel number    abbr=nrarfcn    new_value=${nrarfcn}
    selenium_coam.set_parameter_value    dist_name=${MRBTSID}/${NRBTSID}/NRCELLGRP-1
    ...    filter_param=List of NR cells assigned to cell group    abbr=nrCellList    new_value=${2}    node_index=${0}
    selenium_coam.add_element    dist_name=${MRBTSID}/${NRBTSID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=${MRBTSID}/${NRBTSID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup    new_value=${1}    node_index=${1}

    selenium_coam.validate_plan
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr

    Run Keyword And Ignore Error    COAM_WebEM.Logout

    COAM_WebEM.Login
    KW.COAMAdmin_Login
    ${cell_list}    KW.Get All Cell Id
	${cell_num}    get length    ${cell_list}
	log to console    UE attach to Cell1
    run keyword if  ${cell_num}>1    COAM_WEBEM.LockUnlcokCell
    ...     cell_idx=2      action=lock
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  ${cell_num}>1    COAM_WEBEM.LockUnlcokCell
    ...     cell_idx=2      action=unlock

    log to console    UE attach to Cell2
    run keyword if  ${cell_num}>1    COAM_WEBEM.LockUnlcokCell
    ...     cell_idx=1      action=lock
    Run Keyword And Continue On Failure   DoTputCall
    run keyword if  ${cell_num}>1    COAM_WEBEM.LockUnlcokCell
    ...     cell_idx=1      action=unlock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
