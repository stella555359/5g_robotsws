*** Settings ***
Documentation
...   author: kefang.sheng
...   contact: kefang.sheng@nokia-sbell.com
...   this is a robot case about TOP DTAC customer basic configuration.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library   taf.selenium.sbts    WITH NAME    selenium_coam_rrm

Force Tags        RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG02_ST_RRM    TA_LEVEL_21    RAN_5G
...               CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_ABILB2_AHPDA_RFS    STAT_SKIP_AGENT    SBTS00
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Case Teardown with Scout
*** Variables ***
${NRCELL_1}             MRBTS-4/NRBTS-10068/NRCELL-72
${LNCE_1}             MRBTS-4/LNBTS-5082/LNCEL-12
${BBMOD_name}           BBMOD_R-2
${RMOD_name}            RMOD_R-1
${index}                0
${site_reset_loop}                 20
${RF_reset_loop}                 20
${BBmod_reset_loop}                 10
${Cell_lock_loop}                 10
*** Test Cases ***
[1] OAM stability_Cell block and unblock
    [Tags]    QC_558089       QCD_MN_RAN      QCP_RAN_ST
    Step1_Block CELL
    Step2_Unblock CELL
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair



[1] OAM stability RF lock and unlock
    [Tags]    QC_558099       QCD_MN_RAN      QCP_RAN_ST
    Step1_lock RF
    Step2_Unlock RF
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair


[1] OAM stability Site reset eNB
    [Tags]    QC_558096       QCD_MN_RAN      QCP_RAN_ST
    FOR   ${index}   IN RANGE   0    ${site_reset_loop}
        ${trigger_start_time}=    Get Time    exclude_millis=yes
        set test variable    ${trigger_start_time}
        Step1_Site Reset
        Sleep    300
        Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
        Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
        ${trigger_stop_time}=     Get Time    exclude_millis=yes
        set test variable    ${trigger_stop_time}
        ${Restart_time_duration}=    Subtract Date From Date    ${trigger_stop_time}    ${trigger_start_time}
        log to console    ${Restart_time_duration}
        COAM_Admin.Login
    END
    ${site_reset_list}    Create List    kpi1a    kpi1b    kpi1c
    Calculate KPI    kpi_list=${site_reset_list}    connection=COAM

[1] OAM stability Site reset KPI eNB
    [Tags]    QC_558093       QCD_MN_RAN      QCP_RAN_ST
	log    upload KPI for Site reset    console=yes
	Sleep    60


[1] OAM stability RF reset
    [Tags]    QC_558098       QCD_MN_RAN      QCP_RAN_ST
    FOR   ${index}   IN RANGE   0    ${RF_reset_loop}
        Step1_RMOD Reset
        COAM_Admin.Reset_RMOD
        Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
        Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
        COAM_Admin.Login
    END
    ${ru_reset_list}    Create List    kpi51a    kpi51b
    Calculate KPI    kpi_list=${ru_reset_list}    connection=COAM


[1] RRM_feature_testing_RSWP
    [Tags]    QC_558091       QCD_MN_RAN      QCP_RAN_ST
    WebUI Selenium Login
    RF Diagnostic Test Setup
    WebUI Selenium Logout

[1]OAM stability_Cell lock and unlock
    [Tags]    QC_558089       QCD_MN_RAN      QCP_RAN_ST
    FOR   ${index}   IN RANGE   0    ${Cell_lock_loop}
        Step1_Lock CELL
        Step2_Unlock CELL
        Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
        Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
        COAM_Admin.Login
    END
	${cell_lock_list}    Create List    kpi1a    kpi1b    kpi1c
    Calculate KPI    kpi_list=${cell_lock_list}    connection=COAM

[1] OAM stability BBMOD Reset
    [Tags]    QC_558095       QCD_MN_RAN      QCP_RAN_ST
    FOR   ${index}   IN RANGE   0    ${BBmod_reset_loop}
        Step1_BBMod Reset
        Sleep    300
        Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
        Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
        COAM_Admin.Login
    END
	${BB_reset_list}    Create List    kpi5
    Calculate KPI    kpi_list=${BB_reset_list}    connection=COAM

[1]RRM_Stability_UE_Attach_Detach
    [Tags]    QC_558088       QCD_MN_RAN      QCP_RAN_ST
    run keyword and ignore error   ute_ue.Require UE    UE_0    capabilities=Qualcomm
    Adjust PA Signal To Attach for 4G
    ute_ue.Attach UE    UE_0
    ute_ue.Log Ue Info    UE_0
    sleep    10s

    Adjust PA Signal To Attach for 5G
    ute_ue.Start Data Transfer    DT_1    UE_0    DL
    ...   duration=60s    throughput=80Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Start Data Transfer    DT_2    UE_0    UL
    ...   duration=60s    throughput=20Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Await Data Transfer Finish    DT_1
    ute_ue.Await Data Transfer Finish    DT_2
    ute_ue.get average throughput    DT_1
    ute_ue.get average throughput    DT_2
    ute_ue.Log Ue Info    UE_0

    ute_ue.verify average throughput    DT_1    8Mbits/sec
    ute_ue.verify average throughput    DT_2    5Mbits/sec
    ute_ue.Detach Ue  UE_0

[1]RRM_basic_UDP_UL_data_traffic
    [Tags]    QC_558092       QCD_MN_RAN      QCP_RAN_ST
	log    RRM_basic_UDP_UL_data_traffic    console=yes
	Sleep    30

[1]RRM_basic_UDP_DL_data_traffic
    [Tags]    QC_558094       QCD_MN_RAN      QCP_RAN_ST
	log    RRM_basic_UDP_DL_data_traffic    console=yes
	Sleep    30

[1] UUF4ALL site stability
    [Tags]    QC_558109       QCD_MN_RAN      QCP_RAN_ST
	log    UUF4ALL site stability    console=yes
	Sleep    30

[1]OAM stability upgrade and rollback
    [Tags]    QC_558090       QCD_MN_RAN      QCP_RAN_ST
    Rollback and upgrade



#[7]OAM stability_Cold Site Reset
#    Step1_Cold Site Reset
#    Sleep    600
#    wait until keyword succeeds    10 min    5 sec    Verify 5G cells should be onair



*** Keywords ***
Step1_Block CELL
    log    Step1: Block CELL    console=yes
    COAM_Admin.Block_CELL    72    nr
	COAM_Admin.Block_CELL    2    lte
	COAM_Admin.Block_CELL    12    lte
    sleep    20s

Step2_Unblock CELL
    log    Step2: Unblock CELL    console=yes
    COAM_Admin.Unblock_CELL     72    nr
	COAM_Admin.Unblock_CELL     2    lte
	COAM_Admin.Unblock_CELL     12    lte
    sleep    60s

Step1_Lock CELL
    log    Step1: Lock NRCELL    console=yes
    COAM_Admin.lock    ${NRCELL_1}
    COAM_Admin.lock    ${LNCE_1}
    sleep    20s

Step2_Unlock CELL
    log    Step2: Unlock NRCELL    console=yes
    COAM_Admin.unlock   ${NRCELL_1}
    COAM_Admin.unlock    ${LNCE_1}
    sleep    60s

Step1_lock RF
    log    Step1: Lock RF    console=yes
    COAM_Admin.lock_RF
    sleep    20s

Step2_Unlock RF
    log    Step2: Unlock RF    console=yes
    COAM_Admin.unlock_RF
    sleep    60s

Step1_Site Reset
    log    Step1: Site Reset    console=yes
    coam.reset_site    600    COAM

Step1_BBMod Reset
    log    Step1: BBMod Reset    console=yes
    COAM_Admin.Reset_BBMOD   3

Step1_RMOD Reset
    log    Step1: RF Reset    console=yes
    COAM_Admin.Reset_RMOD    5

Step1_Cold Site Reset
    log    Step1: Cold Site Reset    console=yes
    Hard Reboot GNB

COAM_Admin.lock_RF
    [Arguments]    ${timeout}=${600}    ${connection}=COAM
    coam.lock    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-9
    ...             timeout=${timeout}    connection=${connection}
	coam.lock    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-5
    ...             timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.unlock_RF
    [Arguments]    ${timeout}=${600}    ${connection}=COAM
    coam.unlock    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-9
    ...             timeout=${timeout}    connection=${connection}
	coam.unlock    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-5
    ...             timeout=${timeout}    connection=${connection}
    Sleep    60

WebUI Selenium Login
    Log To Console  \n *** START:WebUI Login ***
    selenium_coam_rrm.Enable Virtual Display
    selenium_coam_rrm.Login    url=https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    version=sbts23R1   browser=Chrome
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam_rrm.Disable_Message_Box
    Sleep    10s
    Log To Console   \n *** END:WebUI Login! ***
    ${start_exits}    selenium_coam_rrm.start_up_view_window_exists
    Run Keyword If     ${start_exits} == ${TRUE}     selenium_coam_rrm.close_start_up_view_window

WebUI Selenium Logout
    selenium_coam_rrm.logout
    run keyword and ignore error    selenium_coam_rrm.disable_virtual_display

RF Diagnostic Test Setup
    [Arguments]    ${cell}=All NR cells    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}    ${cell_id}=72
    Log To Console    \n *** RF Diagnostic Test Setup ***
    selenium_coam_rrm.configure_rf_diagnostic_test    activate=${True}    cell=${cell}    bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}    technology=NR
    selenium_coam_rrm.start_rf_diagnostic_test    timeout=100
    wait until keyword succeeds    10s    100ms    Check Test Information    cell_id=${cell_id}
    Log To Console    \n *** Check RF Detailed Antenna ***
    ${detail_result}    selenium_coam_rrm.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        should be true    ${value_RTWP} < 0
    END

Check Test Information
    [Arguments]    ${cell_id}
    ${test_information}    selenium_coam_rrm.get_general_test_information    cell_id=${cell_id}
    should not be empty    ${test_information}

Common Test Case Teardown with Scout
    Common Test Teardown For RRM
    scout.setup_scout    10_5_UTESRAN001T5082
    ${scf_id}    scout.request_scf    use_scout_internal_id=${False}

Rollback and upgrade
    Rollback software for SRAN
	sleep    600
    COAM_Admin.Login
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
	${upgrade_reset_list}    Create List    kpi2a    kpi2b    kpi2c    kpi2d
    COAM_Admin.Login
    Calculate KPI    kpi_list=${upgrade_reset_list}    connection=COAM


Verify 3G cells should be onair
    [Arguments]    ${connection}=COAM
    ${cell_info_3g}    coam.get_cells_info    cell_type=wcdma   timeout=10    connection=${connection}
    ${number_of_cell}    get length    ${cell_info_3g}
    FOR    ${index}    IN RANGE    ${number_of_cell}
        ${status}    Set Variable    ${cell_info_3g[${index}]['status']}
        Run Keywords    Should Be True    "${status['operationalState']}"=="enabled" or "${status['operationalState']}"=="Enabled"
        ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
        ...    AND    Should Be True   "${status['blockingState']}"=="Unblocked"
    END

Adjust PA Signal To Attach for 4G
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port
    ${initial_att_values}    Get Initial Attenuation Values   RU_id=0    vendor=RadioRack
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0    ${attenuation_channels[2]}=110    ${attenuation_channels[3]}=110
    ...    ${attenuation_channels[4]}=110   ${attenuation_channels[5]}=110    ${attenuation_channels[6]}=110    ${attenuation_channels[7]}=110
    Modify Attenuation Value    ${channels_to_modify}
    sleep    10s
    Log to console    attenuation change complete

Adjust PA Signal To Attach for 5G
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port
    ${initial_att_values}    Get Initial Attenuation Values   RU_id=0    vendor=RadioRack
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0    ${attenuation_channels[2]}=110    ${attenuation_channels[3]}=110
    ...    ${attenuation_channels[4]}=110   ${attenuation_channels[5]}=110    ${attenuation_channels[6]}=0    ${attenuation_channels[7]}=0
    Modify Attenuation Value    ${channels_to_modify}
    sleep    10s
    Log to console    attenuation change complete
