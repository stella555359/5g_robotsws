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


*** Keywords ***
Prepare For CB013350
    [Documentation]    Prepare For CB013350
    ${Log_Path}    Create Log Directory    CB013350
    Link SCOUT SCF To Configuration ID For Reporting
    Backup Scf      ${Log_Path}     LOO_Full_Commissioning.xml
    Add RD Parameters To GNB Swconfig File      0x58057F=262223;0x58057A=4;0x590072=1
    IF   '${STREAM_NR}' == 'SBTS26R1'
        GNB Delta Commission        ${DELTACONFIGDIR}/CB013350_Delta_Branch26R1.json     timeout=500
        Sleep       60s
    ELSE
        GNB Delta Commission    ${DELTACONFIGDIR}/CB013350_updated_Delta_Trunk.json     timeout=500
        Sleep   15s
    END
    GNB Graceful Reset
    Sleep   300s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup.cfg
    Basic Bring Up

Common Tear Down For CB013350
    [Documentation]    Common Tear Down For CB013350
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_13350.zip
    Collect Logs For The Test               ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${Log_Path}
    Run     zip -r ${OUTPUTDIR}/CB013350.zip ${LOG_PATH}
    Full Commission With SCF File For UTE       ${Log_Path}/LOO_Full_Commissioning.xml
    Log To Console      Waiting for 360s After Full Commissioning to revert the changes
    Sleep   360s
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

Verifying The PM Counter For 13350
    [Documentation]    Verifying The PM Counter For 13350
    ...     ARGUMENTS   DL_MITG_Flag   expected Value for M55194C00281 and M55194C00003
    ...     This can be 0 or >0 depending on the Cell load and Feature flag
    ...     HP_MITG_Flag    Expected PM counter value for M55194C00283 and M55194C00284
    ...     This can be 0 or >0 depending on the Cell load and Feature flag
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]         ${DL_MITG_Flag}=0     ${HP_MITG_Flag}=0    ${cell}=1
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55194C00003    ${DL_MITG_Flag}     DUR_DL_SPCL_MUT_RIM_MITG
    ...     M55194C00281    ${DL_MITG_Flag}     DUR_1ST_DL_MUT_RIM_MITG
    ...     M55194C00282    ${DL_MITG_Flag}     DUR_2ND_DL_MUT_RIM_MITG
    ...     M55194C00283    ${HP_MITG_Flag}     PRB_USED_PDSCH_MUT_HI_PRI_DATA
    ...     M55194C00284    ${HP_MITG_Flag}     NUM_MUT_SLOT_SCHD_HI_PRI_DATA
    ...     M55194C00001    >0     NUM_UL_SYMB_IMPACT_RI
    ...     M55308C00043    >0     DL_SLOTS_BELOW_TGT_LOAD
    ...     M55308C00044    >0     DL_SLOTS_ARTIFICIAL_LOAD
    ...     M55308C00045    >0     DL_PRB_ARTIFICIAL_LOAD
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${pm_counter_file}

Enable Feature Flag For 13350
    [Documentation]     It is updating NIDD Parameters to enable the Feature CB013350
    ...     It will help to remove the interference alarms
    ...     ARGUMENTS   RIM_DL_Mut is true or false actRimSoftDlMuting value default true
    ...     Thres_Load  no values from 0 to 100 for managing Cellload by changing threshold default 0.
    ...     win_load_avg    Windos size of 10 sec or similar values default 10
    ...     HP_Flag     is true or false highPrioRbTransInMutedSlots default is false
    ...     cell        CellId default is Cellid 1
    [Arguments]    ${RIM_DL_Mut}=true       ${Thres_Load}=0     ${win_load_avg}=10      ${HP_Flag}=false      ${cell}=1
    Log To Console      Changing Feature Flag to ${RIM_DL_Mut}
    admin.Setup Admin
    Online NIDD Parameter Change    paramName=actRimSoftDlMuting                paramValue=${RIM_DL_Mut}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${cell}/NRRIM_PROFILE-1
    Online NIDD Parameter Change    paramName=cellLoadThreshForRimMitigation    paramValue=${Thres_Load}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${cell}/NRRIM_PROFILE-1
    Online NIDD Parameter Change    paramName=windowDurationForCellLoadAvg      paramValue=${win_load_avg}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${cell}/NRRIM_PROFILE-1
    Online NIDD Parameter Change    paramName=highPrioRbTransInMutedSlots         paramValue=${HP_Flag}
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-${cell}/NRRIM_PROFILE-1
    sleep               60s
    [Teardown]     admin.Teardown admin

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
    Enable Feature Flag For 13350       true     0    10    false   1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      False
    Wait Until Keyword Succeeds       ${TIMEOUT}      ${RETRY_TIME}
    ...         Verifying The PM Counter For 13350        0      0
    slog.Stop Syslog

Cell On Low Threshold
    [Documentation]     Low Cellload Meaning (Threshold is set to high as 90 here to achieve low Celload)
    ...     Muting Will Happen if low Cell Load
    ...     PM Counters Value will Be Non Zero whenever Muting will Happen
    slog.Start Syslog  ${Log_Path}     En_Flag_Low_Thr.LOG
    Enable Feature Flag For 13350       true      90     10     true    1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      False
    Wait Until Keyword Succeeds       ${TIMEOUT}      ${RETRY_TIME}
    ...         Verifying The PM Counter For 13350        >0      >0
    slog.Stop Syslog

Alarm And Counter When Feature Flag Disable
    [Documentation]    actRimSoftDlMuting is disabled where as high priority data is still enabled
    slog.Start Syslog  ${Log_Path}     Dis_Flag.LOG
    Enable Feature Flag For 13350       false      90     10    true    1
    Sleep   30s
    Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For 13350        >0      >0

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

Traffic Should Be Successful 13350
    [Documentation]    This Keywords helps to start Only DL Data.
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}
    Log to Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

