*** Settings ***
Library           OperatingSystem
Library           Collections
Library           Process
Library           DateTime
Library           String
Library           taf.gnb.oam.megazone_client     WITH NAME    megazone
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/resource.robot

*** Variables ***
${DU_ASIK_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
&{list_parameter_all}    actSUL=@{actSUL_value}    chBw=@{chBw_value}    dlMimoMode=@{dlMimoMode_value}   expectedCellSize=@{expectedCellSize_value}
...    nrofHARQProcessesForPDSCH=@{nrofHARQProcessesForPDSCH_value}    ssbScs=@{ssbScs_value}    lteToNrFrameShift=@{lteToNrFrameShift_value}
...    frameStructureType=@{frameStructureType_value}    guardPeriodLength=@{guardPeriodLength_value}
...    ulDlDataSlotRatio=@{ulDlDataSlotRatio_value}    timingAdvanceOffset=@{timingAdvanceOffset_value}    ulMimoMode=@{ulMimoMode_value}
...    nrCellType=@{nrCellType_value}    chBwSUL=@{chBwSUL_value}

@{actSUL_value}    false    true
@{chBw_value}    100MHz    80MHz
@{dlMimoMode_value}    2x2 Closed Loop Spatial Multiplexing    2x2 Open Loop Spatial Multiplexing
@{expectedCellSize_value}    15km    10km
@{nrofHARQProcessesForPDSCH_value}    8    10
@{ssbScs_value}    240 KHz    120 KHz
@{lteToNrFrameShift_value}    0ms    3ms
@{frameStructureType_value}    semiStatic    flexible
@{guardPeriodLength_value}    2Symbol    1Symbols
@{ulDlDataSlotRatio_value}    1/4    3/7
@{timingAdvanceOffset_value}    n13792    n25600
@{ulMimoMode_value}    Closed loop Spatial Multiplexing (2x2)    Closed loop Spatial Multiplexing (4x4)
@{nrCellType_value}    2DL0UL    2DL2UL
@{chBwSUL_value}    5MHz    10MHz

&{text_parameter_all}    nrarfcn=@{nrarfcn_value}    pMax=@{pMax_value}    ssPbchBlockPower=@{ssPbchBlockPower_value}
...    prachUrootValueSUL=@{prachUrootValueSUL_value}    nrarfcnSUL=@{nrarfcnSUL_value}    rModDNList=@{rModDNList_value}

@{nrarfcn_value}    2071591    2071595
@{pMax_value}    26    25
@{ssPbchBlockPower_value}    0    -1
@{prachUrootValueSUL_value}    2    3
@{nrarfcnSUL_value}    1000    10000
@{rModDNList_value}    MRBTS-1900/EQM-1/APEQM-1/RMOD-1    MRBTS-1900/EQM-1/APEQM-1/RMOD-2

&{ulPowerControlCommonSUL}    P0 nominal SRS on supplemental UL carrier=-80

&{sulConf}    CBRA preambles per SSB on supplemental UL carrier=4
...    Frequency Band Indicator NR for supplemental UL carrier=1
...    NR Absolute radio frequency channel number of supplemental UL carrier=2071591
...    PRACH-uRoot Value on supplemental UL carrier=1
...    RSRP threshold for UE reference to do RACH on supplemental UL or TDD NR carrier=1

#1340-A
#CU
${CU_addr}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}             ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}             ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

#DU
${DU_addr}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_username}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_password}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

@{e_list}

*** Keywords ***

login Gnb
    run keyword and ignore error    selenium_coam.logout
    Wait Until Keyword Succeeds    3min    10s    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}

Obtain mrbtsId and nrbtsId
    ${mrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_text_parameter_value    mrbtsId    mrbtsId
    ${nrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_text_parameter_value    nrBtsId    nrBtsId
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}

ASIK and ABIL LED change to green
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    ${asik_color}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_asik_led_status
    ${abil_color}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_abil_led_status
    Should Be Equal    ${asik_color}    green
    Should Be Equal    ${abil_color}    green

Perform Validate and Activate
    Wait Until Keyword Succeeds    2min    10s    selenium_coam.validate_changes    timeout=40
    sleep    2s
    ${error}    selenium_coam.get_validation_error
    log    ${error}
    #should be empty    ${error}
    run keyword and ignore error    Wait Until Keyword Succeeds    2min    10s    selenium_coam.activate_changes    timeout=40

Check BTS Start Reset
    ${output} =    Run    ping ${DU_ASIK_ip} -c 4
    Should Contain    ${output}    4 packets transmitted, 0 received, 100% packet loss
    #${output}    run keyword and ignore error    connect to ASIK
    #should be equal    ${output[0]}    FAIL
    #run keyword and ignore error    csn.reset_cache

Wait BTS Reset Successfully
    #${output}    run keyword and ignore error    connect to ASIK
    #should be equal    ${output[0]}    PASS
    #run keyword and ignore error    csn.reset_cache
    ${output} =    Run    ping ${DU_ASIK_ip} -c 4
    Should Contain    ${output}    4 packets transmitted, 4 received, 0% packet loss

Case Setup
    selenium_coam.enable_virtual_display
    login Gnb
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${scf_path}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.backup_configuration
    Run Keyword And Ignore Error    set suite variable    ${scf_path}
    sleep    5s
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${scf_path}
    Run Keyword And Ignore Error    Create Directory    ${CURDIR}/backup_scf
    ${file_path}    Set Variable    ${CURDIR}/backup_scf
    Set Suite Variable    ${file_path}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${scf_path}    ${file_path}
    ${file_name}    List Files In Directory    ${file_path}
    ${scf_full_path}    Join Path    ${file_path}    ${file_name[0]}
    Set Suite Variable    ${scf_full_path}
    Wait Until Keyword Succeeds    1min    10s    selenium_coam.logout

Case Teardown
    login Gnb
    Wait Until Keyword Succeeds    2min    10s    selenium_coam.add_commissioning_file   ${scf_full_path}
    Wait Until Keyword Succeeds    2min    10s    selenium_coam.update_configuration
    ${PDL_Result}    Wait Until Keyword Succeeds    2min    10s   selenium_coam.get_validation_error
    should be empty  ${PDL_Result}
    Run Keyword And Ignore Error    Remove File    ${scf_full_path}
    Run Keyword And Ignore Error    Remove Directory    ${file_path}
    sleep    5s
    run keyword and ignore error    selenium_coam.logout
    Wait Until Keyword Succeeds    10min    10s    check ASIK and ABIL LED status
    selenium_coam.disable_virtual_display

Delete Parameter
    [Arguments]    ${dist_name}    ${abbr}    ${object_name}    ${filter_param}
    Wait Until Keyword Succeeds    2min    10s    selenium_coam.delete_parameter    dist_name=${dist_name}    abbr=${abbr}
    ...    object_name=${object_name}    filter_param=${filter_param}
    Perform Validate Activate and Wait BTS recovery
    Check Parameter Deleted    ${dist_name}    ${abbr}    ${filter_param}
    Wait Until Keyword Succeeds    1min    10s    selenium_coam.logout

Check Parameter Deleted
    [Arguments]    ${dist_name}    ${abbr}    ${filter_param}
    ${output}    run keyword and ignore error    selenium_coam.get_list_parameter_value
    ...    dist_name=${dist_name}    abbr=${abbr}    filter_param=${filter_param}
    should be equal    ${output[0]}    FAIL

Get MrbtsId and NrbtsId
    login Gnb
    Obtain MrbtsId and NrbtsId

Perform Validate Activate and Wait BTS recovery
    Perform Validate and Activate
    run keyword and ignore error    selenium_coam.logout
    Wait Until Keyword Succeeds    2min    10s    Check BTS Start Reset
    Wait Until Keyword Succeeds    5min    10s    Wait BTS Reset Successfully
    Wait Until Keyword Succeeds    10min    30s    ASIK and ABIL LED change to green

Commission Backup Scf File
    [Arguments]  ${scf_file}
    log to console    Commission Backup Scf File
    login Gnb
    selenium_coam.add_commissioning_file    file_path=${scf_file}
    ${output}    selenium_coam.check_commissioning_file_load_status
    should be equal    ${output}    file loaded successfully
    selenium_coam.update_configuration
    run keyword and ignore error    selenium_coam.logout
    Wait Until Keyword Succeeds    15min    30s    ASIK and ABIL LED change to green
    run keyword and ignore error    selenium_coam.logout


Change FrameStructureType as Flexible
    log to console    Change FrameStructureType as Flexible
    Change FrameStructureType    fst_value=flexible    gpl_value=1Symbol    uddsr_value=3/7

Change FrameStructureType as SemiStatic
    log to console    Change FrameStructureType as SemiStatic
    Change FrameStructureType    fst_value=semiStatic    gpl_value=2Symbols    uddsr_value=1/4

Change FrameStructureType
    [Arguments]   ${fst_value}    ${gpl_value}    ${uddsr_value}
    selenium_coam.change_list_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    abbr=frameStructureType
    ...    filter_param=Frame Structure Type    new_value=${fst_value}    timeout=25
    selenium_coam.change_list_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    abbr=guardPeriodLength
    ...    filter_param=Guard Period length    new_value=${gpl_value}    timeout=25
    selenium_coam.change_list_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    abbr=ulDlDataSlotRatio
    ...    filter_param=UL to DL logical data slot ratio    new_value=${uddsr_value}    timeout=25

Change ipNodeStatisticsInterval parameter unique
    log to console    Change ipNodeStatisticsInterval parameter unique
    Change ipNodeStatisticsInterval parameter    tnlId=1    value=5min
    Change ipNodeStatisticsInterval parameter    tnlId=2    value=15min
    Change ipNodeStatisticsInterval parameter    tnlId=3    value=30min
    Change ipNodeStatisticsInterval parameter    tnlId=4    value=60min
    Change ipNodeStatisticsInterval parameter    tnlId=5    value=360min
    Change ipNodeStatisticsInterval parameter    tnlId=6    value=720min
    Change ipNodeStatisticsInterval parameter    tnlId=7    value=1440min
    run keyword and ignore error    Perform Validate and Activate

Change ipNodeStatisticsInterval parameter
    [Arguments]    ${tnlId}    ${value}
    ${ipNode}    selenium_coam.get_list_parameter_value
    ...    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-${TNLID}/PMTNL-1    abbr=ipNodeStatisticsInterval    filter_param=IP node measurement interval
    run keyword if    '${ipNode}' != '${value}'
    ...    selenium_coam.change_list_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-${TNLID}/PMTNL-1    abbr=ipNodeStatisticsInterval
    ...    filter_param=IP node measurement interval    new_value=${value}    timeout=25
    sleep    2s

#1340-A
Check fault on WEBUI
    [Arguments]    ${alarm_filter}    ${Severity_CP}    ${Fault_name_CP}    ${Alarm_name_CP}    ${Source_CP}    ${TECH_CP}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_alarms_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${TECH}    set variable    ${fault_dic}[Affected technologies]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    ${Alarm_name}    set variable    ${fault_dic}[Reported alarm]
    ${Severity}    set variable    ${fault_dic}[Severity]
    ${Source}    set variable    ${fault_dic}[Source]
    should be equal     ${TECH}     ${TECH_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    should be equal     ${Severity}     ${Severity_CP}
    should be equal     ${Source}     ${Source_CP}

Check fault disappear on WEBUI
    [Arguments]    ${alarm_filter}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_alarms_info    alarm_filter=${alarm_filter}    timeout=100
    should be equal    ${alarm info}    ${e_list}

Connect to DU
    Connect to gNB    ${DU_addr}    ${DU_username}    ${DU_password}    sshDU
