*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
##...             CONFIGS_Bangalore/RRM/ET/CB008541/CB008541_5G_B_B002_1_APoverABIO.yml
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:navin kumar ray
...         This feature releases the change to eCPRI FH interface to support following:
...         DL UP dynamic fragmentation for non-beamforming mode by using section extType 12;
...         Porting of CB007731 and CB008017 to cMAA_Gen4.0_8T8R_eCPRI (spill-over from earlier releases).
...         UL UP dynamic fragmentation for FD-beamforming and non-beamforming mode by using section extType 12;
...         The legacy DL UP dynamic fragmentation for FD-beamforming will be impacted due to introducing the RU's
...         capability reporting via M-plane interface.
...         The RIM RS&RI can be supported by cMAA_Gen4.0_8T8R_eCPRI RU after port CB007731 to cMAA_Gen4.0_8T8R_eCPRI.
...         The RF sharing (NR-NR, NR-LTE) configuration is feasible when UP dynamic fragmentation is activated in one
...         Or both DUs.Feature is supported only by TDD NR eCPRI FR1 RUs.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008941_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Download MCShark To UTE
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=A12_scf.xml
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    240
...                 AND     Perform SCF Delta Commissioning with merged_json.json
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
${RI_LOW_POWER_VALUES}=     SEPARATOR=
...                         -140,-140,-139,-138,-137,-136,-135,-134,-133,-132,-131,-130,-128,-126,-124,-122,-120,
...                         -118,-120,-124,-126,-128,-130,-131,-132,-133,-134,-135,-136,-137,-138,-140
${RI_HIGH_POWER_VALUES}=    SEPARATOR=
...                         -100,-97,-95,-92,-90,-89,-85,-81,-78,-77,-75,-73,-70,-67,-65,-60,-52,-55,-60,-64,-68,
...                         -72,-76,-80,-84,-88,-91,-94,-97,-99,-100,-101
${RI_MONITORING_PERIOD}=    5m

${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_APoABIO_MultiUe_VONR_tdd.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
${IPHY_FILE}                    ${CURDIR}/config/wts/Conf_7752-B-SANSA-TDD-iphy.xml
*** Test Cases ***
[1]CB008941_A12_1_UL_Fragmentaion_and_CB006991_and_CB008249_enabled_and_succesfull_SA_Call_with_multiple_Ues
        [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation is
    ...    activated and CB008249 is enabled together with CB006991 enabled, the data transmission in eCPRI uplink
    ...    contains the NR IQ of scheduled PRBs for TDD FR1 deployments, the NR carrier supports UL PRB dynamic
    ...    fragmentation.

    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}
#    X2AP Link Should be UP

    UE Beamforming Profile And Association For 2 Beams SA    ${3}
    Start Log    biptaf
    Register UE And Send Data    1    3
    ${scen1}     Stop Log     biptaf     test_scenario=attach_1_3
    Generate Remote Interference    2    ${RI_LOW_POWER_VALUES}
    Sleep   600s
    Deactivate Remote Interference Testmode    2
    Generate Remote Interference    3    ${RI_HIGH_POWER_VALUES}
    Sleep   600s
    Check If RI Alarm Is Present
    Deactivate Remote Interference Testmode    3
    log to console   check bearer stats
#    Validate UL Traffic For MultiUE for SA    1  3     ul_rate=40
    Sleep   600s

    Start Log         ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace         test_scenario=data_1_3
    sleep   30s    #run for 5min
    Deregister All UE    1   3

    Decode TTI Trace   data_1_3
    ${rc}   tti_utility.verify_sliv   ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData   SLIV
    Should Contain	${rc}	Pass
    ${rc}   Read pucch boundary      ${scen1}[biptaf]/BIP_L1L2.pcap
    Should Contain	${rc}	pass
    [Teardown]     Link SCOUT SCF to Configuration ID for Reporting
#    ${rc}   Read pucch boundary      ${scen2}[biptaf]/BIP_L1L2.pcap
#    Should Contain	${rc}	pass
#    ${rc}   Read pucch boundary      ${scen3}[biptaf]/BIP_L1L2.pcap
#    Should Contain	${rc}	pass

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE And Send Data
    [Arguments]   ${Start_UE}   ${MAX_UE}
    #Start Collecting Syslog     NAME=syslog_ue_attach
    #Start CPRT Trace Capturing
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    1
        log to console   UE attach triggering now...${UE}
        UE Register should be Successful     ${UE}
        Sleep    5s
        Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps   ul_rate=40      pdu_id=1    trf_id=1
        sleep   5s
        #Validate UL Traffic For SA   ue_id=${UE}     ul_rate=100      qfi_id=1
    END
    ##Stop Collecting Syslog       NAME=syslog_ue_attach
    #Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    #Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap


Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr  profile_id=${ID}    start_symbol_position=0   num_of_symbols=32
    ...     noise_power_values=${RI_PWR}
    Sleep    2s
    wtsrunner.cell_testmode_set_nr    testmode=remote_interference     gnb=2     cell_id=1      profile_id=${ID}
    ...     action=activate
    Sleep    10s

Create RI Profiles
    [Arguments]    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr profile_id=${ID}   start_symbol_position=0   num_of_symbols=32
    ...     noise_power_values=${RI_PWR}

Deactivate Remote Interference Testmode
    [Arguments]    ${ID}
    wtsrunner.cell_testmode_set_nr     testmode=remote_interference     gnb=2     cell_id=1     profile_id=${ID}
    ...      action=deactivate
    Sleep    10s

Check If RI Alarm Is Not Present
     ta5g_enb.Verify If Admin Fault Is Down    fault_id=7525

Check If RI Alarm Is Present
     ta5g_enb.Verify If Admin Fault Is Up    fault_id=7525


Deregister All UE
    [Arguments]   ${Start_UE}   ${MAX_UE}
    #Start Collecting Syslog     NAME=syslog_ue_attach
    #Start CPRT Trace Capturing
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    1
        Stop Data Traffic for SA     ue_id=${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END

