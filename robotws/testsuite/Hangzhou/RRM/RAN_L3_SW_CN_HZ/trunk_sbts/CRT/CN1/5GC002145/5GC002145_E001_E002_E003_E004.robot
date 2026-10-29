*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714346
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

*** Test Cases ***
5GC002145-ET-E001_E002_E003_E004 Verify_the_slice_state_is_correct_with_Slice_Addition_Delete_On_AMF_Side
    [Documentation]     This user scenario describes the successful AMF update procedure to add/delete S-NSSAI 
    ...    with GNB is supported or not supported.
    ...    The purpose of this test case is to check following scenarios:
    ...    Slice 1 enable->Add gnb not support slice 2 to AMF (slice 1 is enable)->
    ...    Add gnb support slice 3 to AMF (slice 1 and 3 is enable)->Delete slice 2,3 from AMF
    [Tags]    QC_87030
    Check E001 Slice1 Enable
    Check E002 Slice1 Enable And Slice2 Unsupported
    Check E003 Slice1 And Slice3 Enable And Slice2 Unsupported
    Check E004 Slice1 Enable And Delete Slice2 And Slice3
    Check WireShark Log    ${CURDIR}${/}a2a_E002_E003_E004${/}a2a.ini    wait_string=AMFConfigurationUpdateAcknowledge::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri    # 1cell_ecpri need to modify cfg and 3cells not needed

Perform Steps After Onair
    Check WireShark Log    ${CURDIR}${/}a2a_E001${/}a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::3

Check E001 Slice1 Enable
    Log To Console    \nCheck E001 Slice1 Enable...
    ${snssai1}=    Create List    MRBTS-1/NRBTS-1/SNSSAI-1:operationalState=enabled    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
    ...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
    Object Should Exist    ${snssai1}
    ${snssaiamf}=    Create List    MRBTS-1/NRBTS-1/SERVEDAMF-1:snssaiAMFList:sst=1|sd=13714341
    Object Should Exist    ${snssaiamf}

Check E002 Slice1 Enable And Slice2 Unsupported
    Log To Console    Check E002 Slice1 Enable And Slice2 Unsupported...
    Execute Egate Command    amf_config_update id=1 name=AMF2 nwslice=1,2    Received AMF Configuration Acknowledge from GNB-2
    Sleep    2s    # wait Running Time Configuration to update completely
    Object Should Exist    MRBTS-1/NRBTS-1/SNSSAI-2:operationalState=disabled

Check E003 Slice1 And Slice3 Enable And Slice2 Unsupported
    Log To Console    Check E003 Slice1 And Slice3 Enable And Slice2 Unsupported...
    Execute Egate Command    amf_config_update id=1 name=AMF3 nwslice=1,3    Received AMF Configuration Acknowledge from GNB-2
    Sleep    2s    # wait Running Time Configuration to update completely
    Object Should Exist    MRBTS-1/NRBTS-1/SNSSAI-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/SNSSAI-3:operationalState=enabled
    ${snssaiamf}=    Create List    MRBTS-1/NRBTS-1/SERVEDAMF-1:snssaiAMFList:sst=1|sd=13714341
    ...    MRBTS-1/NRBTS-1/SERVEDAMF-1:snssaiAMFList:sst=1|sd=13714343
    Object Should Exist    ${snssaiamf}

Check E004 Slice1 Enable And Delete Slice2 And Slice3
    Log To Console    Check E004 Slice1 Enable And Delete Slice2 And Slice3...
    Execute Egate Command    amf_config_update id=1 name=AMF1 nwslice=1,2,3    Received AMF Configuration Acknowledge from GNB-2
    Execute Egate Command    amf_config_update id=1 name=AMF1 nwslice=1    Received AMF Configuration Acknowledge from GNB-2
    Sleep    2s    # wait Running Time Configuration to update completely
    Object Should Exist    MRBTS-1/NRBTS-1/SNSSAI-1:operationalState=enabled
    ${snssaiamf}=    Create List    MRBTS-1/NRBTS-1/SERVEDAMF-1:snssaiAMFList:sst=1|sd=13714341
    Object Should Exist    ${snssaiamf}
