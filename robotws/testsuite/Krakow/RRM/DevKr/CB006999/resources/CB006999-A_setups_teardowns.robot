*** Settings ***
Resource    ./CB006999.robot

*** Keywords ***
Prepare test environment AB203-2
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Wait until PM counters file is ready and saved

Prepare VRAN test environment AB203-2
    Change CU parameter on MRBTS-1/NRBTS-1 drbInactivityTimerSA=15
    Change CU parameter on MRBTS-1/NRBTS-1 srbInactivityTimerSA=15
    Wait until CU PM counters file is ready and saved

Teardown test environment AB203-2
    Restore backup AMFs on AMF1 and verify NG links up
    Restore AMF2 GUAMIs
    Detach UE10
    Wait until alarm with fault ID=7325 disappears
    Restore default gNB radio bearer inactivity timers

Teardown VRAN test environment AB203-2
#    Change CU parameter on MRBTS-1/NRBTS-1 drbInactivityTimerSA=600
#    Change CU parameter on MRBTS-1/NRBTS-1 srbInactivityTimerSA=600
    Execute egate command   cmd=ue_kill id=1

    VRAN_SPECIFIC Restore AMF1 GUAMIs and backupAMFNames
    Restore AMF2 GUAMIs
    Update AMF2 config to restore guamiStatus available

Prepare test environment AB301-1
    Set Planned AMF Removal Timer to 60 seconds in gNB
    Verify that amfplannedremovaltimer is set to 60
    Wait For Next Full Pm Interval

Prepare test environment AB301-2
    Set Planned AMF Removal Timer to 60 seconds in gNB
    Set relative capacity to 100 for AMF2
    Set relative capacity to 1 for AMF3
    Wait For Next Full Pm Interval

Prepare VRAN test environment AB301-2
    Change CU parameter on MRBTS-1/NRBTS-1 amfPlannedRemovalTimer=60
    Execute egate command    cmd=amf_config_update id=2 relative_capacity=100
    Execute egate command    cmd=amf_config_update id=3 relative_capacity=1

Prepare test environment AB001-1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Set Planned AMF Removal feature flag to ${true}

Teardown test environment AB001-1
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment AB001-2
    Prepare test environment AB001-1
    Execute egate command    cmd=amf_config_update id=1 relative_capacity=100

Teardown test environment AB001-2
    Detach UE1
    Detach UE2
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment AB501-1
    Wait until PM counters file is ready and saved
    Set Planned AMF Removal Timer to 30 seconds in gNB
    Verify that amfPlannedRemovalTimer is set to 30
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set relative capacity to 100 for AMF1

Prepare test environment AB501-2
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Verify that amfPlannedRemovalTimer is set to 0
    Cleanup Backup AMF Name from SERVEDAMF-1
    Lock NGAP link to AMF2

Teardown test environment AB501-2
    Detach UE1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Unlock NGAP link to AMF2
    Restore test suite settings on AMF1

Teardown test environment AB501-1
    Wait until PM counters file is ready and saved
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Detach UE2
    Execute egate command  cmd=ue_kill id=1
    Execute egate command  cmd=amf_restore_guamis id=1 guami_index=all
    Execute egate command  cmd=amf_restore_guamis id=2 guami_index=all
    Set relative capacity to 1 for AMF1
    Sleep  2
    Verify SERVEDAMF-1:GUAMI_index-1:guamiStatus is set to available
    Verify SERVEDAMF-1:GUAMI_index-2:guamiStatus is set to available
    Verify SERVEDAMF-2:GUAMI_index-1:guamiStatus is set to available
    Verify SERVEDAMF-2:GUAMI_index-2:guamiStatus is set to available

Prepare test environment AB601-1
    Restore backup AMFs on AMF1 and verify NG links up
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Execute egate command    cmd=amf_config_update id=2 relative_capacity=0
    Wait until PM counters file is ready and saved

Teardown test environment AB601-1
    Detach UE1
    Detach UE2
    Wait until alarm with fault ID=7325 disappears
    Sleep  1
    Restore backup AMFs on AMF1 and verify NG links up
    Execute egate command    cmd=amf_config_update id=2 relative_capacity=1

Prepare test environment AB302-1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 30 seconds in gNB
    Execute egate command    cmd=amf_config_update id=2 relative_capacity=100
    Wait until PM counters file is ready and saved

Teardown test environment AB302-1
    Detach UE1
    Detach UE2
    Restore backup AMFs on AMF1 and verify NG links up
    Execute egate command    cmd=amf_config_update id=2 relative_capacity=1

Prepare test environment AB303-1
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Wait For Next Full Pm Interval
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment AB303-2
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Wait For Next Full Pm Interval
    Restore backup AMFs on AMF1 and verify NG links up

Prepare VRAN test environment AB303-2
    Change CU parameter on MRBTS-1/NRBTS-1 amfPlannedRemovalTimer=60
    Wait until CU PM counters file is ready and saved

Teardown test environment AB303-1
    Restore backup AMFs on AMF1 and verify NG links up
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-2 recovered
    Detach UE1
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB303-2
    Restore backup AMFs on AMF1 and verify NG links up
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-2 recovered
    Detach UE1
    Wait until alarm with fault ID=7325 disappears

Teardown VRAN test environment AB303-2
    VRAN_SPECIFIC Restore AMF1 GUAMIs and backupAMFNames
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-2 recovered
    Detach UE1

Prepare test environment AI002-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Verify that amfplannedremovaltimer is set to 0
    Cleanup Backup AMF Name from SERVEDAMF-1
    Wait until PM counters file is ready and saved

Prepare test environment AI002-2
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Verify that amfplannedremovaltimer is set to 0
    Wait until PM counters file is ready and saved

Prepare test environment AI003-2
    Set Planned AMF Removal Timer to 80 seconds in gNB
    Verify that amfplannedremovaltimer is set to 80
    Set relative capacity to 100 for AMF1
    Wait until PM counters file is ready and saved

Prepare test environment AI003-1
    Set Planned AMF Removal Timer to 60 seconds in gNB
    Verify that amfplannedremovaltimer is set to 60
    Cleanup Backup AMF Name from SERVEDAMF-1
    Wait until PM counters file is ready and saved

Prepare test environment AI003-4
    Set Planned AMF Removal Timer to 60 seconds in gNB
    Verify that amfplannedremovaltimer is set to 60
    Set relative capacity to 10 for AMF1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Wait until PM counters file is ready and saved

Prepare test environment AB701-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Verify that amfplannedremovaltimer is set to 0
    Cleanup Backup AMF Name from SERVEDAMF-1
    Lock NGAP link to AMF2
    Lock NGAP link to AMF3
    Wait For Next Full Pm Interval

Prepare test environment AB701-2
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Verify that amfplannedremovaltimer is set to 0
    Set UE IDLE timers on gNB: drbInactivityTimerSA=60 srbInactivityTimerSA=60
    Set relative capacity to 0 for AMF1
    Wait until PM counters file is ready and saved

Teardown test environment AB701-2
    Detach UE1
    Detach UE2
    Restore default gNB radio bearer inactivity timers
    Restore backup AMFs on AMF1 and verify NG links up
    Restore AMF2 GUAMIs
    Restore AMF3 GUAMIs

Prepare test environment AB901-1
#    Cleanup Backup AMF Name from SERVEDAMF-1  # Pradeep: amf_config_update id=1 relative_capacity=1
                                               # might be causing UE release.
    Set Planned AMF Removal Timer to 30 seconds in gNB
    Set Planned AMF Removal feature flag to True
    Lock NGAP link to AMF3
    Wait For Next Full Pm Interval

Teardown test environment AB901-1
    Detach UE4
    Detach UE5
    Detach UE6
    Wait until alarm with fault ID=7325 disappears
    Sleep  1
    Unlock NGAP link to AMF3
    Restore backup AMFs on AMF1 and verify NG links up

Prepare VRAN test environment AB901-1
    Change CU parameter on MRBTS-1/NRBTS-1 amfPlannedRemovalTimer=30
    Change CU parameter on MRBTS-1/NRBTS-1/SERVEDAMF-3 administrativeState=Locked
    Wait until CU PM counters file is ready and saved

Teardown VRAN test environment AB901-1
    Detach UE4
    Detach UE5
    Detach UE6
    Change CU parameter on MRBTS-1/NRBTS-1/SERVEDAMF-3 administrativeState=Unlocked
    VRAN_SPECIFIC Restore AMF1 GUAMIs and backupAMFNames

Prepare test environment AB901-2
    Execute egate command   cmd=amf_ng_setup_param id=1 ue_retention=on
    Edit object attributes
    ...     object_name=NRBTS-1
    ...     ngUeRetentionEnabled=true
    ...     bts_id=1
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Set relative capacity to 255 for AMF2
    Wait For Next Full Pm Interval

Teardown test environment AB901-2
    Detach UE1
    Detach UE2
    Detach UE7
    Wait until alarm with fault ID=7325 disappears
    Execute egate command   cmd=amf_ng_setup_param id=1 ue_retention=off
    Sleep  1
    Edit object attributes
    ...     object_name=NRBTS-1
    ...     ngUeRetentionEnabled=false
    ...     bts_id=1
    Restore backup AMFs on AMF1 and verify NG links up
    Set relative capacity to 1 for AMF2

Prepare test environment AI001-1
    Wait For Next Full Pm Interval

Teardown test environment AI001-1
    Restore default behavior while sending NR-RRC: RRC Reconfiguration Complete from UE1
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment AB801-1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval

Teardown test environment AB801-1
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up

Prepare test environment AI002-3
    Set relative capacity to 10 for AMF1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval

Teardown test environment AI002-3
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment AI003-3
    Set relative capacity to 10 for AMF1
    Set Planned AMF Removal Timer to 50 seconds in gNB
    Wait For Next Full Pm Interval

Teardown test environment AI003-3
    Detach UE1
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-2 recovered
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment AB101-1
    Set Planned AMF Removal feature flag to ${false}
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait until PM counters file is ready and saved

Prepare test environment AB201-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval

Prepare test environment AB202-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval

Prepare test environment AB202-2
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval

Prepare test environment AB203-1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Wait For Next Full Pm Interval
    Set relative capacity to 100 for AMF2

Prepare test environment AI002-4
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set relative capacity to 100 for AMF1

Prepare test environment AI004-2
    Set Planned AMF Removal Timer to 30 seconds in gNB
    Locate UE1 at real_gNB
    Setup amf_status_indication interaction sent after Handover Required
    Wait For Next Full Pm Interval

Prepare test environment AI004-5
    Set Planned AMF Removal Timer to 80 seconds in gNB
    Locate UE1 at real_gNB
    Set relative capacity to 100 for AMF1
    Wait For Next Full Pm Interval

Prepare test environment A-multiple_plmn
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Set relative capacity to 100 for AMF1

Teardown test environment AB101-1
    Detach UE1
    Detach UE2
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB201-1
    Restore backup AMFs on AMF1 and verify NG links up
    Detach UE1
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB202-1
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB202-2
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Restore AMF2 GUAMIs
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB301-1
    Detach UE1
    Detach UE2
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB301-2
    Detach UE3
    Detach UE4
    Detach UE5
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears
    Set relative capacity to 1 for AMF2
    Set relative capacity to 1 for AMF3

Teardown VRAN test environment AB301-2
    Detach UE1
    Detach UE2
    VRAN_SPECIFIC Restore AMF1 GUAMIs and backupAMFNames
    Update AMF2 config to restore guamiStatus available
    Update AMF3 config to restore guamiStatus available

Teardown test environment AI002-1
    Detach UE1
    Detach UE2
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AI002-2
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AI003-2
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears
    TEMPORARY BYPASS: Reset NG link between AMF1 and gNB
    Verify that NG link to AMF-1 recovered
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-2 recovered
    #Set relative capacity to 1 for AMF1
    #Set relative capacity to 1 for AMF2
    #Set relative capacity to 1 for AMF3

Teardown test environment AI003-1
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AI003-4
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AI004-2
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears
    Execute egate command  cmd=amf_ue_ng_handover_param id=1 reset
    Locate UE1 at real_gNB

Teardown test environment AI004-5
    Detach UE1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears
    Execute egate command  cmd=amf_ue_ng_handover_param id=1 reset
    Locate UE1 at real_gNB

Teardown test environment AB701-1
    Detach UE1
    Unlock NGAP link to AMF2
    Unlock NGAP link to AMF3
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AB203-1
    Restore backup AMFs on AMF1 and verify NG links up
    Detach UE1
    Wait until alarm with fault ID=7325 disappears

Teardown test environment AI002-4
    Detach UE4
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment AI002-5
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set relative capacity to 10 for AMF1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Set UE IDLE timers on gNB: drbInactivityTimerSA=40 srbInactivityTimerSA=40
    Wait For Next Full Pm Interval

Teardown test environment AI002-5
    Detach UE1
    Set relative capacity to 1 for AMF1
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment AI003-5
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set relative capacity to 10 for AMF1
    Set Planned AMF Removal Timer to 60 seconds in gNB
    Set UE IDLE timers on gNB: drbInactivityTimerSA=40 srbInactivityTimerSA=40
    Wait For Next Full Pm Interval

Teardown test environment AI003-5
    Detach UE1
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Set relative capacity to 1 for AMF1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Restore Backup AMFs on AMF1 And Verify NG Links Up
    Wait until alarm with fault ID=7325 disappears

Prepare test environment AI003-6
    Cleanup Backup AMF Name from SERVEDAMF-1
    Set Planned AMF Removal Timer to 30 seconds in gNB
    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established
    Verify that NG link to AMF-3 is established

Teardown test environment AI003-6
    Detach UE9
    Restore backup AMFs on AMF1 and verify NG links up
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Reset NG links

Prepare test environment AI004-4
    Set Planned AMF Removal Timer to 0 seconds in gNB
    Locate UE2 at real_gNB
    Setup successful amf_status_indication interaction sent after Handover Required


Teardown test environment AI004-4
    Detach UE2
    Restore backup AMFs on AMF1 and verify NG links up
    Wait until alarm with fault ID=7325 disappears
    Execute egate command  cmd=amf_ue_ng_handover_param id=1 reset
    Locate UE1 at real_gNB

Teardown test environment A-multiple_plmn
    Detach UE1
    Set relative capacity to 1 for AMF1
    Cleanup Backup AMF Name from SERVEDAMF-1
    Restore Backup AMFs on AMF1 And Verify NG Links Up
    Wait until alarm with fault ID=7325 disappears
