*** Settings ***
Resource    ./CB006999.robot

*** Keywords ***
Prepare test environment BB301
    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established
    Verify that NG link to AMF-3 is established

Prepare test environment BB101-1
    Start PCMD message collection
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Set Planned AMF Removal feature flag to True
    Set relative capacity to 100 for AMF3
    Set relative capacity to 1 for AMF2
    Wait until PM counters file is ready and saved

Teardown test environment BB101-1
    Stop PCMD message collection
    Detach UE1
    Detach UE2
    Set relative capacity to 1 for AMF3
    Restore AMF1 GUAMIs
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment BB101-2
    Start PCMD message collection
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Set Planned AMF Removal feature flag to True
    Wait until PM counters file is ready and saved

Prepare test environment BI001-1
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Set Planned AMF Removal feature flag to True
    Wait until PM counters file is ready and saved

Teardown test environment BI001-1
    Detach UE1
    Detach UE2
    Set Planned AMF Removal Timer to 0 seconds in gNB

Prepare test environment BB101-3
    Start PCMD message collection

Teardown test environment BB101-3
    Stop PCMD message collection
    Restore backup AMFs on AMF1 and verify NG links up
    Detach UE1
    Wait until alarm with fault ID=7325 disappears

    Restore AMF2 guamiStatus and backupAMFs
    Verify SERVEDAMF-2:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=available
    Restore AMF3 guamiStatus and backupAMFs
    Verify SERVEDAMF-3:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=available

Teardown test environment BB301
    Detach UE1
    Detach UE2
    Detach UE3

Prepare test environment BB401
    Set Planned AMF Removal feature flag to ${false}
    Start PCMD message collection
    Wait For Next Full Pm Interval

Teardown test environment BB401
    Set Planned AMF Removal feature flag to ${true}
    Stop PCMD message collection
    Detach UE1

Teardown test environment BB101-2
    Stop PCMD message collection
    Detach UE1
    Detach UE2
    Restore AMF1 GUAMIs
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment BI001-2
    Wait For Next Full Pm Interval

Teardown test environment BI001-2
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment BI002-1
    Start PCMD message collection
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Set Planned AMF Removal feature flag to True
    Set relative capacity to 100 for AMF2

Teardown test environment BI002-1
    Stop PCMD message collection
    Detach UE1
    Detach UE2

Prepare test environment BI002-3
    Cleanup Backup AMF Name from SERVEDAMF-1

Teardown test environment BI002-3
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment BI003-1
    Locate UE1 at real_gNB
    Setup ue_tnla_binding_release_request interaction sent after Handover Required
    Wait For Next Full Pm Interval

Teardown test environment BI003-1
    Detach UE1
    Execute egate command  cmd=amf_ue_ng_handover_param id=1 reset
    Locate UE1 at real_gNB

Prepare test environment BI003-2
    Locate UE1 at real_gNB
    Setup ue_tnla_binding_release_request interaction sent after Handover Required with no response

Teardown test environment BI003-2
    Detach UE1
    Execute egate command  cmd=amf_ue_ng_handover_param id=1 reset
    Locate UE1 at real_gNB
