***Settings***
Force Tags          CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                 CONFIGS_Bangalore/RRM/ET/CNI_76348/CNI_76348_config.yaml
...                 CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation
...     author:         manasa.shankarappa@nokia.com
...     maintainer:     Manasa HS
...     INTRODUCTION:   CNI_76348 AIC cases
...     Feature:

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ./resources/l1hi_bip_analyser.robot
Library             ../resources/python/IphyUpdate.py

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
    
suite teardown          Run keywords        Kill WTS processes Using WTS_Runner

***Variables***
#${gnb_index}        0
#${vdu_index}        0
${wts_cfg_file}     ${CURDIR}/config/basic_setup_AEQK_2cell.cfg
#${WTS_DIR}          /opt/iphy/latest
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${UE_ID}     1
${NSA_UE_ID}     11
${BEARER_ID}     2
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/Working_Configuration_scf_MRBTS-3805_DU_3805_20220204-1637.xml
${VCU SCF PATH}     ${CURDIR}/config/SBTS/Working_Configuration_scf_MRBTS-3805_CU_3805_20220204-1701.xml
${iphy_xml}         ${CURDIR}/config/AEQP_ecpri_TDD.xml
${gscn_value}   1

***Test Cases***
[1]CNI76348_1_TDD_Multi_UE_40M_Througput_validation_SA_256QAM
    [Tags]     QC_278894
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:
    ...  REFERENCES: N/A
    ...  CONTACTS:  manasa.shankarappa@nokia.com
    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
    ...  REQUIRED LOGS:  Syslog, TTI Trace
    ...  TEST ENVIRONMENT:
    ...    - gNB: 1x AirScale
    ...  DEFINITIONS FROM THE TEST PLAN:
    ...  PRECONDITIONS:
    ...  HISTORY:
    ...

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 Verify RMODs Online Status      ${800}
    ...         AND                 Clear WTS     ${WTS_DIR}
    ...         AND                 Add WTS Ipaddr At VM
    ...         AND                 Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...         AND                 X2AP Link Should be UP
    ...          AND                 sleep    120s
    ...         AND                 Collect Alarms on AIC At Start of Test


#        Start Syslog Monitoring    
#        Start CPIF_CPRT Monitoring    
#        Start L1L2 Bip Mon    l1hi
#       l1hi, l2hi, l2rt
#        Start TTI Trace Mon
        Log to console     ------------ Start SA Call ---------------
        Log to console     UE Register
        UE Register should be Successful     ue_id=${UE_ID}
        Log to console     Start DL Traffic for SA
        Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=5      trf_id=${TRF_ID}      qfi_id=${QFI_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA
        Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=5       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
        log to console      start delay of 1 min
        Sleep    60s
        log to console      Stop delay
#       Start Bip traces    
#        Start L1L2 Bip Mon    l1hi
#        sleep   2s
#        Stop and Collect L1L2 Bip Monitoring    l1hi
        Log to console     Validate Traffic
        Run Keyword And Continue on Failure     Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=5     qfi_id=${QFI_ID}
        Run Keyword And Continue on Failure     Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=5     qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID}
        Log to console     UE De-Register
        UE Deregister should be Successful   ue_id=${UE_ID}
#        Run Keyword And Continue on Failure     Verify MCS in uldata_puschreceivereq    ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi.pcap    mcsTable   1 
#        OperatingSystem.Run    command=mv ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi.pcap ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi_SA.pcap

[1]CNI76348_1_TDD_Multi_UE_40M_Througput_validation_NSA_256QAM
        [Tags]   QC_197515
        Log to console     ------------ Start NSA Call ---------------
        Log to console     LTE UE Attach
        LTE Attach should be Successful     ${NSA_UE_ID}
        Log to console     5G UE Attach
        UE Attach should be Successful     ${NSA_UE_ID}
        Log to console     Start DL Traffic for NSA
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     dl_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     ul_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID2}
        log to console      start delay of 1 min
        Sleep    60s
        log to console      Stop delay
#       Start BIP traces        
#        Start L1L2 Bip Mon    l1hi
#        sleep   2s
#        Stop and Collect L1L2 Bip Monitoring    l1hi
        Log to console     Validate Traffic
        Run Keyword And Continue on Failure     Validate DL Traffic For NSA   ue_id=${NSA_UE_ID}     dl_rate=5     id=${BEARER_ID}
        Run Keyword And Continue on Failure     Validate UL Traffic For NSA   ue_id=${NSA_UE_ID}     ul_rate=5     id=${BEARER_ID}
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID}
        Log to console     UE Detach
        UE Detach should be Successful   ${NSA_UE_ID}
#       Run Keyword And Continue on Failure     Verify MCS in dldata_pdschsendreq    ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi.pcap    mcsTable   1
#        OperatingSystem.Run    command=mv ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi.pcap ${TESTCASE_LOG_PATH}/L1L2/bip_log_l1hi_NSA.pcap


##    [Teardown]  Suite Teardown

** Keywords **
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----
    run keyword and ignore error        Kill WTS processes Using WTS_Runner
#    Stop TTI Trace Collect and decode
#    Stop and Collect L1L2 Bip Monitoring    l1hi
#    Stop and Collect CPIF_CPRT Monitoring    
    Stop and Collect Syslog Monitoring    
    Collect Journal Logs vDU    consolidate
    Collect Journal Logs vCU    nonconsolidate
    Collect Alarms on AIC At Stop of Test
#    Fetch AIC Commissioning File    

