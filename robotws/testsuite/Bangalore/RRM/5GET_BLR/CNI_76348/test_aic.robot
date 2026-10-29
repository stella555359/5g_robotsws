***Settings***
Force Tags          CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                 CONFIGS_Bangalore/RRM/ET/custom/test_config.yaml

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
Library             ../resources/python/IphyUpdate.py

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
    
suite teardown          Run keywords        Kill WTS processes Using WTS_Runner

***Variables***
#${gnb_index}        0
#${vdu_index}        0
${wts_cfg_file}     /opt/iphy/latest/basic_fullstack_sa_call_tdd_cmwv_Working.cfg
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
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/Working_Configuration_scf_MRBTS-3805_DU_3805_20220204-1637.xml
${VCU SCF PATH}     ${CURDIR}/config/SBTS/Working_Configuration_scf_MRBTS-3805_CU_3805_20220204-1701.xml
${iphy_xml}         ${CURDIR}/config/AEQP_ecpri_TDD.xml
${gscn_value}   1

***Test Cases***
First Test Case
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:
    ...  REFERENCES: N/A
    ...  CONTACTS:  vivek.gv@nokia.com
    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
    ...  REQUIRED LOGS:  Syslog, TTI Trace
    ...  TEST ENVIRONMENT:
    ...    - gNB: 1x AirScale
    ...  DEFINITIONS FROM THE TEST PLAN:
    ...  PRECONDITIONS:
    ...  HISTORY:
    ...      v0.1: 14.09.2021:  Vivek GV   : first draft
    ...

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 vDU Send Commission By RestApi       ${VDU_SCF_PATH}
    ...         AND                 CU Full Commssion By Rest      ${VCU SCF PATH}     ${VCU SCF PATH}
    ...         AND                 Update And Copy WTS IPHY XML     ${iphy_xml}   ${gscn_value}    
    ...         AND                 AP Reboot Wait For Connection    ${120}
    ...         AND                 Verify RMODs Online Status      ${800}
    ...         AND                 Clear WTS     ${WTS_DIR}
    ...         AND                 Add WTS Ipaddr At VM
    ...         AND                 Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...         AND                 Collect Alarms on AIC At Start of Test


        Start Syslog Monitoring    
        Start CPIF_CPRT Monitoring    
        Start L1L2 Bip Mon    l1hi
#       l1hi, l2hi, l2rt
        Start TTI Trace Mon
         
        UE Register should be Successful     ue_id=${UE_ID}
        Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=17      trf_id=${TRF_ID}      qfi_id=${QFI_ID}
        sleep   5s
        Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=17       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
 
        log to console      start delay
        Sleep    10s
        log to console      Stop delay

        Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=17     qfi_id=${QFI_ID}
        Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=17     qfi_id=${QFI_ID}
        Stop Data Traffic for SA     ue_id=${UE_ID}
        UE Deregister should be Successful   ue_id=${UE_ID}



    [Teardown]  Suite Teardown

** Keywords **
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----
    run keyword and ignore error        Kill WTS processes Using WTS_Runner
    Stop TTI Trace Collect and decode
    Stop and Collect L1L2 Bip Monitoring    l1hi
    Stop and Collect CPIF_CPRT Monitoring    
    Stop and Collect Syslog Monitoring    
    Collect Journal Logs vDU    consolidate
    Collect Journal Logs vCU    nonconsolidate
    Collect Alarms on AIC At Stop of Test
    Fetch AIC Commissioning File    

