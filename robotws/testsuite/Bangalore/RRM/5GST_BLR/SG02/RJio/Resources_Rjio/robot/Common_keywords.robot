*** Settings ***

Documentation    BTS 1061 port number 1 should be 0db others should be 120db. 
...    Loging into BTS 1062 block the Cell NR Cell and check on-air status of LTE cell and 
...    Set liner attenuation of port 1 to 50db and LTE cell PVA port-5 into reduced from 120db to 10db. 
...    set those action in loop of 4 times. 
...    

Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.nms.netact    WITH NAME    nms_netact
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library    taf.collectors.core           WITH NAME      core
Library    taf.ul.mobile.ui.android    WITH NAME    mobile
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.hw.rf_attenuator.attenuator  WITH NAME  attenuator
Resource    ../robot/UE_keywords.robot
Resource    ../variables/QC_Variables.robot

*** Variables ***

*** Keywords ***
Configure_QC_ID_for_Reportng_portal
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID}  

Configure_QC_ID_for_Reportng_portal_BTS_1055
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}=    Set Variable    ${${TEST_NAME}}[BTS_1055_QC_ID_${sw_release}]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID}  

Check_Software_version_for_SWUpdate_or_SWRollback
	Run Keyword And Ignore Error    admin.connect_to
	${software_version}=    admin.get_software_info    timeout=30
	${activeSoftwareSBTS}=    Set Variable    ${software_version['Active SW version']}
	${passiveSoftwareSBTS}=    Set Variable    ${software_version['Passive SW version']}
	BuiltIn.Log To Console    \n[ INFO ]: Active SW Version is ${software_version['Active SW version']}
    BuiltIn.Log To Console    \n[ INFO ]: Passive SW Version is ${software_version['Passive SW version']}
	${ActiveSWstr}  BuiltIn.Convert To String    ${activeSoftwareSBTS}
	Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${ActiveSWstr}
	${passive_release}=    Fetch From Left    ${passiveSoftwareSBTS}    _
	${passive_check}=    Split string    ${passive_release}     separator=_    max_split=3
	${passive_branch}=    BuiltIn.Convert To String    ${passive_check[0]}
	${ActiveSWstr}  BuiltIn.Convert To String    ${activeSoftwareSBTS}
	${active_release}=    Fetch From Left    ${ActiveSWstr}    _
	${active_check}=    Split string    ${ActiveSWstr}     separator=_    max_split=3
	${active_branch}=    BuiltIn.Convert To String    ${active_check[0]}
	Run Keyword If    '${passiveSoftwareSBTS}' == '${5G_SOURCE_SW}'  admin.rollback_software
    ...     ELSE IF  '${activeSoftwareSBTS}'=='${5G_SOURCE_SW}' 
    ...     BuiltIn.Log To Console  \n[ INFO ]: SW Rollback Not needed.
	...    	ELSE    BuiltIn.Log To Console   \n[ ERROR ]: Source Build not available in BTS. TEST FAIL    
    Run Keyword If    '${passiveSoftwareSBTS}' == '${5G_SOURCE_SW}'    BuiltIn.Log To Console    
    ...    \n[ INFO ]: SW Rollback is started. Expected start at 60 seconds.     
    Run Keywords   Run Keyword If    '${passiveSoftwareSBTS}' == '${5G_SOURCE_SW}'    Sleep  3m    
    ...    AND   BuiltIn.Log To Console    \n[ INFO ]: Waiting 20 minutes to SW Rollback completion and On-Air State
    [Teardown]    Run Keyword If    '${passiveSoftwareSBTS}' == '${5G_SOURCE_SW}'   
    ...     Wait Until Keyword Succeeds   20 x    1 minute   verify the bts required status onair
    
verify the bts required status onair
    [Arguments]    ${Required_BTS_Status}=OnAir
    ${bts_status}   admin.get_bts_statuses
    Set Suite Variable    ${bts_status}
    Should Be Equal     first="${bts_status}[proceduralState]"  second="${Required_BTS_Status}"

RollBack if passive sw is source build and check onair state
    [Documentation]   Only purpose of UUF pre chec test. Test not need to rollback begins if we used it.
    Check_Software_version_for_SWUpdate_or_SWRollback  
    
    

taf_attenuator_objects
    [Documentation]  Author: Arunkumar A 
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${vendor}=TopYoung    ${attenuation_ports}=@{Attenuation_port_numbers}   ${value}=${None}
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}  
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    FOR  ${port}  IN  @{attenuation_ports}
        ${port_value}  attenuator.read_attenuation  port=${port} 
        # ...     attenuator_device=${Attenuator_device_config}  
        Run Keyword If   ${port_value}==${120}  attenuator.set_attenuation    port=${port}  value=${value}  confirm=${True}
        ...      confirmation_delay=5
    # Attenuator.set_linear_fading_scenario  port=${port}  start_value=${start_value}  end_value=${end_value}  interval=3
    # ...      unit=S  attenuator_device=${attenuator_device}
    # Attenuator.read_ports_attenuation  ports=${all_ports}  attenuator_device=${attenuator_device}
    # Attenuator.set_ports_attenuation  ports=${ports}  values=${values}
    # ...       confirmation_delay=3  attenuator_device=${attenuator_device}
    END

Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
#    Run Keyword If    '${mrbtsID}'=='1061'    RJIO_ANR_EUTRA_AEQZ_1139    check_HO=${False}
    Run Keyword If    '${mrbtsID}'=='1061'    RJIO_SG02_ANR_EUTRA_1061    check_HO=${False}

RJIO_SG02_ANR_EUTRA_1061
    [Arguments]    ${check_HO}=${False}    
    @{NRADJECELL_create_list}=    Create List
    @{NRRELEL_create_list}=    Create List
    log to console    \n*****set All PA port to 120 db...
    # All 16 port should be 120db  
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}    value=${120} 
    log to console    \n***** PVA port 1 set to 0 db *****
    # Port 1 must be 0db
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}[0]    value=${0}  
    log to console    \n*******PA ports are configured for Attuneation ******
    FOR   ${index}   IN RANGE   0    1
        ${NRADJECELL_creat_status}    ${NRRELEL_creat_status}    Rjio_E2E_ANR_EUTRA    check_HO=${check_HO}
        append to list    ${NRADJECELL_create_list}   ${NRADJECELL_creat_status}
        append to list    ${NRRELEL_create_list}   ${NRRELEL_creat_status}
    END
    log to console    ${NRADJECELL_create_list}
    log to console    ${NRRELEL_create_list}
    ${NRADJECELL_fail_status}    get_item_in_list    item_list=${NRADJECELL_create_list}    item=${False}
    ${NRRELEL_fail_status}    get_item_in_list    item_list=${NRRELEL_create_list}    item=${False}
    should be equal    ${NRADJECELL_fail_status}    ${0}
    should be equal    ${NRRELEL_fail_status}    ${0}

Rjio_E2E_ANR_EUTRA
    [Arguments]    ${check_HO}=${False}    ${NRADJECELL_ID}=5000  ${NRCELL_ID}=${0}    ${NRRELE_ID}=256
    ...       ${alias}=${UE_ANDROID_UE1}    ${capabilities}=${Capability}

    log to console    \n******Delete NR-LTE neighbor Object If Exist*****
    RJIO Sbts Login And Disable Screen Lock  
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJECELLL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    ${neighbor_NRRELE}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
    ${neighbor_NRADJECELLL_length}    Get Length    ${neighbor_NRADJECELLL}
    ${neighbor_NRRELE_length}    Get Length    ${neighbor_NRRELE}
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    Run Keyword If    ${neighbor_NRRELE_length}!=${0}    selenium_sbts.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
   
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0} or ${neighbor_NRRELE_length}!=${0}    selenium_sbts.validate_plan
    Run Keyword If    ${neighbor_NRADJECELLL_length}!=${0} or ${neighbor_NRRELE_length}!=${0}    selenium_sbts.activate_plan
    ...    activate_plan_despite_errors=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    RJIO Sbts Logout And Close Browser
    log to console    \n****** Scf activated for ANR feature *****
    Require UE
    Attach Ue via taf ue  alias=${ue_alias}
    log to console   \n***** UE attached performed*****
    FOR   ${index}   IN RANGE   0    4
        Run Keyword If    '${mrbtsID}'=='1061'    ANR_EUTRA_HO_AEQZ_1139    flag_call=${False}
    END
    sleep    3min    wait NR-LTE neighbor create
    log to console    \n***check NR-LTE neighbor if created***
    RJIO Sbts Login And Disable Screen Lock
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${neighbor_NRADJECELLL}    selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJECELL-${NRADJECELL_ID}
    ${neighbor_NRRELE}  selenium_sbts.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_ID}/NRRELE-${NRRELE_ID}
    ${neighbor_NRADJECELLL_length}    Get Length    ${neighbor_NRADJECELLL}
    ${neighbor_NRRELE_length}    Get Length    ${neighbor_NRRELE}
    ${NRADJECELL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRADJECELLL_length}    ${0}
    ${NRRELEL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRRELE_length}    ${0}
    Run Keyword If    ${check_HO}==${True}    Run Keywords
    ...    log to console    +++ check HO from TDD908 to LTE cell81 +++    AND
#    Run Keyword If    '${mrbtsID}'=='2300'    ANR_EUTRA_HO_AQQJ_2300    flag_call=${True}    ue_index=4
    ...    log to console    begin to call...    AND
    ...    Run Keyword If    '${mrbtsID}'=='1139'    ANR_EUTRA_HO_AEQZ_1139    flag_call=${True}
   
    [Return]    ${NRADJECELL_creat_status}    ${NRRELEL_creat_status}
    [Teardown]    Run Keywords    RJIO Sbts Logout And Close Browser    AND    
    # ...    save full snapshot   AND   Detach Ue via taf ue   alias=${ue_alias}

ANR_EUTRA_HO_AEQZ_1139
    [Documentation]    
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}    
    log to console    \n******UE_Attched to NR cell ******
    sleep    15s
    log to console    \n*****change PA port 5 to 0 to attach LTE & PA port 1 to 60*****
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}[4]    value=${0} 
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}[0]    value=${60} 
    log to console    \n**** UE attached to LTE Cell *******
    Sleep  20s
    log to console    \n*****change PA port 1 to 0 to attach LTE & PA port 5 to 60*****
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}[0]    value=${0}
    taf_attenuator_objects    attenuation_ports=@{Attenuation_port_numbers}[4]    value=${60} 
    log to console   \n****** Attached back to NR **********
#    [Teardown]    Run keyword     Ue_detach_specific_cell_sg02    ${alias}    

RJIO Sbts Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS23R3
    ...            ${browser}=Firefox
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    browser=${browser}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

RJIO Sbts Logout And Close Browser
    Run Keyword And Ignore Error    Selenium Close StartUp View    timeout=5
    Run Keyword And Ignore Error    selenium_sbts.logout
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser