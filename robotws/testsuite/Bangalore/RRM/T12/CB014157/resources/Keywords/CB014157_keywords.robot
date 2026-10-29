*** Settings ***
Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         Process
Library         String
Library         XML
Library         re
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Variables       ta5g_global_var
Library         ta5g_pm_counters
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot


Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature Related all common Keywords related to Feature.


*** Variables ***
${TOPOLOGY}                CLOUD_5G_I_LOO_AP_LOOO
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${APCONFIGDIR}             ${CURDIR}/../../config/ap_iphy
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${VLANIF_DISTNAME}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${noise_pow1}        -68,-68,-69,-69,-70,-70,-71,-71,-72,-72,-71,-71,-72,-72,-72
${noise_pow2}        -68,-68,-68,-68,-67,-67,-67,-69,-69,-65,-65,-65,-115,-115,-115,-115,-115
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${RD_PARAM}         0x590072=1;0x66001b=2;0x890001=2;0x890002=2;0x890003=2;0x890004=2;0x890005=2;0x890006=2;0x890008=2;0x890009=2
${FT_RD_PARAM}      0x580581=48;0x58057a=4;0x5a00a5=1;0x5b0234=1


*** Keywords ***
Prepare For CB014157
    [Documentation]    Prepare For CB014157
    ${Log_Path}    Create Log Directory    CB014157
    Link SCOUT SCF To Configuration ID For Reporting
    GNB Delta Commission         ${DELTACONFIGDIR}/14157_Add_Cell_Delta_config.json    timeout=500
    Sleep   30s
    GNB Delta Commission         ${DELTACONFIGDIR}/14157_Addon1_Delta_config.json      timeout=500
    Sleep   15s
    Add RD Parameters To GNB Swconfig File      ${RD_PARAM};${FT_RD_PARAM}
    GNB Graceful Reset
    Sleep   300s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup.cfg
    Basic Bring Up

Common Tear Down For CB014157
    [Documentation]    Common Tear Down For CB014157
    slog.Stop Syslog
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014157_RJIO.zip ${LOG_PATH}
    GNB Graceful Reset
    Sleep   300s
    Wait Coam Site To Be Ready

Set UE Stats NR Type
    [Documentation]      UE Stats NR Type pdsch,pusch
    [Arguments]     ${UEID}=1   ${type}=pdsch,pusch
    UE Stats NR     id=${UEID}  type=${type}
    Log To Console  NR PDSCH and PUSCH Throughput

Get GNB Alarms
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms.
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Verifying The PM Counter For CB014157
    [Documentation]    Verifying The PM Counter For CB014157
    ...     ARGUMENTS   DL_MITG_Flag   expected Value for M55194C00281 and M55194C00003
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]             ${HP_MITG_Flag}=300    ${cell}=1        ${mut}=>
    Log To Console          This is for Cell ${cell}
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55194C00003    ${HP_MITG_Flag}     DUR_DL_SPCL_MUT_RIM_MITG
    ...     M55194C00281    ${HP_MITG_Flag}     DUR_1ST_DL_MUT_RIM_MITG
    ...     M55194C00282    ${HP_MITG_Flag}     DUR_2ND_DL_MUT_RIM_MITG
    ...     M55395C00001    ${mut}     NUM_DL_SYMB_MUT_RIM_MITG
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${pm_counter_file}

Update Feature Flag For CB014157
    [Documentation]     It is updating NIDD Parameters to enable the Feature CB014157
    ...     It will help to remove the interference alarms
    ...     ARGUMENTS   RIM_DL_Mut is true or false actRimSoftDlMuting value default true
    ...     Thres_Load  no values from 0 to 100 for managing Cellload by changing threshold default 0.
    ...     win_load_avg    Windos size of 10 sec or similar values default 10
    ...     HP_Flag     is true or false highPrioRbTransInMutedSlots default is false
    ...     cell        CellId default is Cellid 1
    [Arguments]     ${FeatureFlageDelta}=14157_Feature_Enable.json
    GNB Delta Commission       ${DELTACONFIGDIR}/${FeatureFlageDelta}        timeout=500
    Sleep               60s
    Log To Console      Feature is enabled

Get Alarm By Details
    [Documentation]    Getting Alarm details of GNB List of Fault Ids Active at GNB
    @{alarms}   Get GNB Alarms
    @{Alarm_Fault_Id}       Create List
    FOR  ${alarm}  IN  @{alarms}
        ${current_alarm_info}              Get From Dictionary  ${alarm}                      alarmInformation
        ${current_additional_info}         Get From Dictionary  ${current_alarm_info}         alarmAdditionalInfo
        ${current_additional_fault_id}     Get From Dictionary  ${current_additional_info}    additionalFaultID
        ${current_alarm_detail}            Get From Dictionary  ${current_alarm_info}         alarmDetail
        ${current_fault_description}       Get From Dictionary  ${current_alarm_info}         faultDescription
        Append To List      ${Alarm_Fault_Id}       ${current_additional_fault_id}
    END
    [Return]    ${Alarm_Fault_Id}

Cell On High Threshold
    [Documentation]     High Cellload Meaning (Threshold is set to Low as 0 here to achieve High Celload)
    ...     Muting Will Not Happen if High Cell Load
    ...     PM Counters Value will Be Zero whenever Muting will not Happen
    slog.Start Syslog  ${Log_Path}     En_Flag_High_Thr.LOG
    Enable Feature Flag For CB014157      true     0    10    false   1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      False
    Wait Until Keyword Succeeds       ${TIMEOUT}      ${RETRY_TIME}
    ...        Verifying The PM Counter For CB014157        0      0
    slog.Stop Syslog

Cell On Low Threshold
    [Documentation]     Low Cellload Meaning (Threshold is set to high as 90 here to achieve low Celload)
    ...     Muting Will Happen if low Cell Load
    ...     PM Counters Value will Be Non Zero whenever Muting will Happen
    slog.Start Syslog  ${Log_Path}     En_Flag_Low_Thr.LOG
    Enable Feature Flag For CB014157       true      90     10     true    1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      False
    Wait Until Keyword Succeeds       ${TIMEOUT}      ${RETRY_TIME}
    ...         Verifying The PM Counter For CB014157        >0      >0
    slog.Stop Syslog

Alarm And Counter When Feature Flag Disable
    [Documentation]    actRimSoftDlMuting is disabled where as high priority data is still enabled
    slog.Start Syslog  ${Log_Path}     Dis_Flag.LOG
    Enable Feature Flag For CB014157       false      90     10    true    1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For CB014157        >0      >0

Check Fault Exist In Current Alarm
    [Documentation]    Check Expected Alarm/Fault Exist In Current Active Alarm
    [Arguments]     ${fault}       ${Should_Exist}=True
    ${Fault_id}     Evaluate    int(${fault})
    @{Fault_Ids}   Get Alarm By Details
    IF  ${Should_Exist}==True
        List Should Contain Value       ${Fault_Ids}      ${Fault_id}
        Log To Console      ${fault} Alarm is Active
    ELSE
        List Should Not Contain Value     ${Fault_Ids}    ${Fault_id}
        Log To Console      ${fault} Alarm is not Active
    END

Traffic Should Be Successful CB014157
    [Documentation]    This Keywords helps to start Only DL Data.
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}
    Log to Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Prepare For CB014157 RJIO
    [Documentation]    Prepare For CB014157 in RJIO configuration
    ${Log_Path}    Create Log Directory    CB014157
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    GNB Delta Commission         ${DELTACONFIGDIR}/Delta_RJIO_Initial_Setup.json    timeout=500
    Sleep   30s
    GNB Delta Commission         ${DELTACONFIGDIR}/Delta_RI_based_mitigation_enable.json      timeout=500
    Sleep   15s
    Add RD Parameters To GNB Swconfig File      ${RD_PARAM};${FT_RD_PARAM}
    GNB Graceful Reset
    Sleep   300s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup_RJIO.cfg
    NG Link Should Be UP
    Sleep   90s

