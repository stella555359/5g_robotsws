*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD_GMC
...             CRT    RAN_5G    5G_RAN     SBTS00   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Kshitij Tyagi
...              :contact: kshitij.tyagi@nokia.com
...         This user scenario describes multiple UEs attach/data transfer with the setup of FDD cell with 35MHz bandwidth followed by system
...         information transmission where max DL and Max UL throughput is verified
...         CB008152_B_B1_TC3_Verify_MultipleUE_with_35Mh_MaxDL_MaxUL_SAMode_ABIP

Resource         ./resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with IPHY file change
...                 AND     Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_35MHZ_gmc.json
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Run Keyword and Ignore Error    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    WTS_Runner_Keywords.MultiUE Deregister should be Successful   1   4
...                 AND      Link SCOUT SCF to Configuration ID for Reporting
...                 AND      Check resource hanging

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TC24.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
#${SCFC}=                  /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD_GMC/scfc.xml
${AP_XML}=                /home/ute/MN/UTE/robotws/custom-config/Bangalore/RRM/ET/CB008152/CB008152_B_TC24_iphy.xml
${st_ue_4}    1
${en_ue_4}    4
${st_ue_high}    5
${en_ue_high}    13
${st_ue_nsa}    15
${en_ue_nsa}    16

*** Test Cases ***
[1]CB008152_B_B1_TC24_Verify_MultipleUE_with_35Mh_MaxDL_MaxUL_SAMode_ABIP
    [Documentation]     This user scenario describes multiple UEs attach/data transfer with the setup of FDD cell with 35MHz
    ...         bandwidth followed by system    information transmission where max DL and Max UL throughput is verified

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...
	#start log     cprt   biptaf    btslog
    ${crnti_list}=      WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_4}  ${en_ue_4}
    sleep   5s
    Trigger MAX DL throughput    ${st_ue_4}    ${en_ue_4}    3
    Trigger MAX UL throughput    ${st_ue_4}    ${en_ue_4}    2
	#Stop Log   cprt   biptaf   btslog    test_scenario=DL_UL_Max_data
    sleep   35s
    Validate DL Traffic For MultiUE for SA      ${st_ue_4}    ${en_ue_4}    170
    Validate UL Traffic For MultiUE for SA      ${st_ue_4}    ${en_ue_4}    100
    sleep   5s
    Attach UE and start data
    WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_high}  ${en_ue_high}
    Trigger MAX DL throughput    ${st_ue_high}    ${en_ue_high}    2
    Trigger MAX UL throughput    ${st_ue_high}    ${en_ue_high}    2
    sleep   45s
    Wait Until Keyword Succeeds    20s    60s    Validate MAX DL throughput   1    ${en_ue_high}   30
	Wait Until Keyword Succeeds    20s    60s    Validate MAX UL throughput   1    ${en_ue_high}    20
	Validate MAX DL throughput NSA    ${st_ue_nsa}    ${en_ue_nsa}    20
	Validate MAX UL throughput NSA    ${st_ue_nsa}    ${en_ue_nsa}    20
	Run Keyword and Ignore Error     WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA     ${st_ue_high}    ${en_ue_high}
    WTS_Runner_Keywords.MultiUE Deregister should be Successful   ${st_ue_high}   ${en_ue_high}
    UE Detach should be Successful    ${st_ue_nsa}
    UE Detach should be Successful    ${en_ue_nsa}
    sleep   45s
    Attach UE and start data
    Wait Until Keyword Succeeds    20s    300s    WTS_Runner_Keywords.MultiUE Register should be Successful    ${st_ue_high}  ${en_ue_high}
    Trigger MAX DL throughput    ${st_ue_high}    ${en_ue_high}    2
    Trigger MAX UL throughput    ${st_ue_high}    ${en_ue_high}    2
    sleep   45s
    Wait Until Keyword Succeeds    20s    60s    Validate MAX DL throughput   ${st_ue_4}    ${en_ue_high}    20
	Wait Until Keyword Succeeds    20s    60s    Validate MAX UL throughput   ${st_ue_4}    ${en_ue_high}    20
	Validate MAX DL throughput NSA    ${st_ue_nsa}    ${en_ue_nsa}    20
	Validate MAX UL throughput NSA    ${st_ue_nsa}    ${en_ue_nsa}    20
    Trigger Bler with pktloss
    Wait Until Keyword Succeeds    120s    5s    Validate MAX DL throughput   3    13    30
    Run Keyword and Ignore Error     WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA     ${st_ue_high}    13
    Run Keyword and Ignore Error     WTS_Runner_Keywords.MultiUE Deregister should be Successful     ${st_ue_high}    13
    UE Detach should be Successful    ${st_ue_nsa}
    UE Detach should be Successful    ${en_ue_nsa}
    sleep    5s
    #Deactivate bler with pktloss    1    2
    sleep   30s
    #Trigger IntraGnb HO cell2    1    2
    #Trigger IntraGnb HO cell1    3    4
    #sleep   20s
    #Wait Until Keyword Succeeds    120s    2    Validate MAX DL throughput free      ${st_ue_4}    ${en_ue_4}    40
    #Trigger IntraGnb HO cell1    1    2
    #Trigger IntraGnb HO cell2    3    4
    #sleep    20s
    #Wait Until Keyword Succeeds    120s    2    Validate MAX DL throughput free      ${st_ue_4}    ${en_ue_4}    40
    Run Keyword and Ignore Error     WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA     1    2
    Run Keyword and Ignore Error    WTS_Runner_Keywords.MultiUE Deregister should be Successful   1   2

*** Keywords ***
Trigger Max TPUT for Multi UE
    Trigger MAX DL throughput    1    12    1
    Trigger MAX UL throughput    1    12    1
    sleep   60
    Validate MAX DL throughput   1    12    70
	Validate MAX UL throughput   1    12    50

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Trigger MAX DL throughput
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=60
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
        sleep   2s
    END

Trigger MAX UL throughput
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=50
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
        sleep   2s
    END

Validate MAX DL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END

Validate MAX UL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END
Validate MAX DL throughput NSA
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=8    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END

Validate MAX UL throughput NSA
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END


Trigger Bler with pktloss
    Add Bler for Ues and activate with pktloss     1   2
    sleep   10s
    Wait Until Keyword Succeeds    60s    20sec    Validate MAX DL throughput   1    2    20
	Wait Until Keyword Succeeds    60s    20sec    Validate MAX UL throughput   1    2    10

Add Bler for Ues and activate with pktloss
    [Arguments]    ${startue}    ${endue}
    wtsrunner.bler_testmode_nr     profile_id=1     dl_bler=100,100,50,50,50,50,50,50
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    wtsrunner.ue_testmode_set_nr     id=${ue_idx}
    ...    testmode=bler     profile_id=1     action=activate
    END

Deactivate bler with pktloss
    [Arguments]    ${startue}    ${endue}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    wtsrunner.ue_testmode_set_nr     id=${ue_idx}
    ...    testmode=bler     profile_id=1     action=deactivate
    END

Trigger IntraGnb HO cell2
    [Arguments]    ${startue}    ${endue}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${ue_idx}    1    51
    END

Trigger IntraGnb HO cell1
    [Arguments]    ${startue}    ${endue}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${ue_idx}    1    50
    END

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Attach UE and start data
    Sleep    30s
    LTE Attach should be Successful  NSA_UE_ID=15
    UE Attach should be Successful  NSA_UE_ID=15
    Sleep    2s
    Trigger DL Traffic for NSA    ue_id=15     Traffic_rate=mbps     dl_rate=60       trf_id=1
    Trigger UL Traffic for NSA    ue_id=15     Traffic_rate=mbps     ul_rate=60       trf_id=1
    sleep    30s
    Wait Until Keyword Succeeds    60s    20sec    LTE Attach should be Successful  NSA_UE_ID=16
    Wait Until Keyword Succeeds    60s    20sec    UE Attach should be Successful  NSA_UE_ID=16    Trgt_Cell=2
    Sleep    15s
    Trigger DL Traffic for NSA    ue_id=16     Traffic_rate=mbps     dl_rate=60       trf_id=1
    Trigger UL Traffic for NSA    ue_id=16     Traffic_rate=mbps     ul_rate=60       trf_id=1
    Sleep    15s

Validate NSA Tput
    Validate DL Traffic For NSA   ue_id=15      dl_rate=20
    Validate UL Traffic For NSA   ue_id=15     ul_rate=10
    Validate DL Traffic For NSA   ue_id=16      dl_rate=20
    Validate UL Traffic For NSA   ue_id=16     ul_rate=10


Check Average Rate free
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (int(${output[0]}) > (${mbps} * 1000000 * 0.9))
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Validate DL Traffic For MultiUE for SA free
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate free      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
   	END

Validate MAX DL throughput free
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.read_wtsemu_output_until    expected=UE-${ue_id}: NR PDSCH Throughput
        ...                     timeout=30
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END