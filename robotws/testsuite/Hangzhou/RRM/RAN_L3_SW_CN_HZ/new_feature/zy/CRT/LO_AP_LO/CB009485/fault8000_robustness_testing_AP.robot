*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07

Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Run keywords    stop tce    AND    Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot


*** Variables ***
${CONFIG_WA}    ${False}
@{FAULTS_EXCLUDED_CHECKING}    8000
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
...    0x890004=0
...    0x890003=0

${SYSCOM_FLAG}    ${True}

${DuBearerTraceRecord_mba_F}    (nsetapx.DuVendorExtensionRecordDataType == 13) && (nsetapx.traceActivationType == 0)
${DuBearerTraceRecord_sba_F}    ((nsetapx.DuVendorExtensionRecordDataType == 13)) && (nsetapx.traceActivationType == 1)

${CuUeReleaseTraceRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0
${CuUeReleaseTraceRecord_mba_F}    (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.traceActivationType == 0)
${CuUeReleaseTraceRecord_sba_F}    (nsetapx.CuVendorExtensionRecordDataType == 0) && (nsetapx.traceActivationType == 1)

@{ueReleaseRecord_c2_c3_c4}
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=ueInactivity
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=not_existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=not_existing

*** Test Cases ***
c1_fault 8000 should be cleared after using reachable TCE
    [Tags]    c1
    delta commission parameters    ${clean_trace_mocs}
    fm fault should be cleared    fault_id=8000    timeout=30
    log to console  step0: start TCE but no connection with Gnb now, enable cell trace and pcmd in NRBTS
    Start TCE    ${TCE_PORT}    prompt=listening
    delta commission parameters    ${trace_NRBTS_flags}

    log to console  step1: create TCE-1 with unreachable IP and MTRACECU-1, fault8000 is raised
    delta commission parameters    ${c1_delta_TCE1_MTRACECU1}
    ${fault_8000}    create list    fault_id=8000
    ...                             fault_name=Failure in connection between BTS and 3rd party tool
    ...                             alarming_object=[RE].*MRBTS-1/MNL-1/TCEADM-1/TCE-1
    ...                             supplalarminfo=TCP error: Failed NRBTS-1/NRCTRLTS-1/NRMTRACECU-1 trace connection for 11.11.11.11 and 49100
    ...                             alarm_id=7115
    ...                             severity=Minor
    fm fault should be raised    ${fault_8000}

    log to console  step2: delete TCE-1 and MTRACECU-1, create TCE-2 with reachable IP and MTRACECU-2 with same tceidentifier in one delta plan
    log to console  .......fault8000 should be cleared
    delta commission parameters    ${c1_delta_delete_TCE1_MTRACECU1_add_TCE2_MTRACECU2}
    fm fault should be cleared    fault_id=8000    timeout=30

c2_fault 8000 should be cleared after using reachable TCE
    [Tags]    c2    PR
    delta commission parameters    ${clean_trace_mocs}
    fm fault should be cleared    fault_id=8000    timeout=30
    log to console  step0: start TCE but no connection with Gnb now, enable cell trace and pcmd in NRBTS
    Start TCE    ${TCE_PORT}    prompt=listening
    delta commission parameters    ${trace_NRBTS_flags}

    log to console  step1: create TCE-2 with unreachable IP and MTRACECU-1, fault8000 is raised
    delta commission parameters    ${c2_delta_TCE2_MTRACECU1}
    ${fault_8000}    create list    fault_id=8000
    ...                             fault_name=Failure in connection between BTS and 3rd party tool
    ...                             alarming_object=[RE].*MRBTS-1/MNL-1/TCEADM-1/TCE-2
    ...                             supplalarminfo=TCP error: Failed NRBTS-1/NRCTRLTS-1/NRMTRACECU-1 trace connection for 11.11.11.11 and 49100
    ...                             alarm_id=7115
    ...                             severity=Minor
    fm fault should be raised    ${fault_8000}

    log to console  step2: delete TCE-2 and MTRACECU-1, create TCE-1 with reachable IP and MTRACECU-2 with same tceidentifier in one delta plan
    log to console  .......fault8000 should be cleared
    delta commission parameters    ${c2_delta_delete_TCE2_MTRACECU1_add_TCE1_MTRACECU2}
    fm fault should be cleared    fault_id=8000    timeout=30


