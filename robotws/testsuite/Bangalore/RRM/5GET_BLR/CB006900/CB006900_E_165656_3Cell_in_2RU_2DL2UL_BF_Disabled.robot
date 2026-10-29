*** Settings ***
#Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB006900/CB006900_E_165656_TDD_SA.yml
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1       CONFIGURED
Force Tags        CLOUD_5G_I_LN_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation    :copyright: Nokia
...              :authors: Sunil
...              :contact: sunil.t_kurian@nokia.com
...         The aim of the CB006900 feature is to support 3 cell in ABIN capacity board.
...         This test case is for validating L3 call in below configuration
... 		TDD SA configs NR eCPRI for ABIN up to 3 cells in 2 RU with 2DL2UL 4T4R 8T8R and beamforming disabled E2 3S-1CC-2DL-2UL-FR1-eCPRI
...         Topology need to use in this case is LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...         Bandwidth configured=100 Mhz for all 3 cells & used differnt ARFCN for cells configured in same RU
...         RMOD used is AEQP_I and band used is 78


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB006900_Keywords.robot
Library          ../resources/python/avg_dl_data.py

Suite Setup         Run keywords    Prepare TL with all config files 
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_2X2.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${epc_log_path}    /tmp/
${SCFC}=        Bangalore/RRM/ET/CB006900/CB006900_E_165656_TDD_SA.xml
${AP_XML}=      Bangalore/RRM/ET/CB006900/CB006900_E_165656_TDD_SA_iphy.xml


*** Test Cases ***
[1]TDD SA configs NR eCPRI for ABIN up to 3 cells in 2 RU with 2DL2UL 4T4R 8T8R and beamforming disabled E2 3S-1CC-2DL-2UL-FR1-eCPRI
    [Documentation]    CB006900_CB007378_E_165656_TDD SA configs NR eCPRI for ABIN up to 3 cells in 2 RU with 2DL2UL 4T4R 8T8R
    ...     and beamforming disabled 3S-1CC-2DL-2UL-FR1-eCPRI

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	L3 UniDirectional Call for Specified UE     1
	L3 UniDirectional Call for Specified UE     2
	L3 UniDirectional Call for Specified UE     3

*** Keywords ***
L3 UniDirectional Call for Specified UE
    [Arguments]   ${UE_ID}
    Regiter UE And Start High DL Data Traffic and Verify DL Tput   ${UE_ID}
    Stop Big DL Data Transfer   ${UE_ID}
	Start UL Data Traffic and Verify UL Tput  ${UE_ID}
	UE Deregister should be Successful   ue_id=${UE_ID}

Regiter UE And Start High DL Data Traffic and Verify DL Tput
	[Arguments]    ${UE_ID}
    UE Register should be Successful     ue_id=${UE_ID}
    Start Big DL Data Transfer    ${UE_ID}
    sleep   10s
	Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=790       qfi_id=${QFI_ID}

Start UL Data Traffic and Verify UL Tput
	[Arguments]    ${UE_ID}
    Start Big UL Data Transfer   ${UE_ID}
    sleep   5s
	Run Keyword And Continue on Failure    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=145    qfi_id=${QFI_ID}

Start Big DL Data Transfer
	[Arguments]    ${UE_ID}
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=160       trf_id=1
    sleep   5s	  reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=160       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=160       trf_id=3
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=160       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=160       trf_id=5
    sleep   5s    reason=Wait for successful traffic start

Stop Big DL Data Transfer
	[Arguments]    ${UE_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}
	sleep   20s    reason=Wait for successful traffic stop

Start Big UL Data Transfer
	[Arguments]    ${UE_ID}
	Trigger UL Data Traffic for SA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=110       trf_id=11
    sleep   5s    reason=Wait for successful traffic start
	Trigger UL Data Traffic for SA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=40       trf_id=12
	sleep   10s    reason=Wait for successful traffic start

Stop Big UL Data Transfer
	[Arguments]    ${UE_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=11    dir=ul     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=12    dir=ul     pdu_id=${Pdu_session_ID}
	sleep   5s    reason=Wait for successful traffic stop
