*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   SBTS24R1    CONFIGURED

Resource         ./resources/CB010796_common_resources.robot


Suite Setup     Run Keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with enable_pminterval.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready

Suite Teardown      Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test scenario describes on-line feature activation and deactivation by following NIDD
...                     actMicroDtx= True
...                     disableSchedAssistRfCooling= True/False
...                     allowGBRMutingForRfCooling= On/Off
...                     Verifies below counters
...                     M55601C00016    No of samples when the NR cell is in RF cooling mode0
...                     M55601C00017    No of NR cell state changes to RF cooling mode0
...                     M55601C00018    No of samples when the NR cell is in RF cooling mode2
...                     M55601C00019    No of NR cell state changes to RF cooling mode2
...                     M55601C00020    No of samples when the NR cell is in RF cooling mode1
...                     M55601C00021    No of NR cell state changes to RF cooling mode1
...                     M55601C00022    No of samples when the NR cell is in RF cooling mode3
...                     M55601C00023    No of NR cell state changes to RF cooling mode3
...                     M40008C2        Time of radio unit in NORMAL temperature state
...                     M40008C3        Time of radio unit in INCREASED temperature state
...                     M40008C4        Time of radio unit in HIGH temperature state
...  TEST SET NAME   :  CB010796_A_Validate_NrCell_Samples_cellStateChange_Counters_At_Level1and3
...                     CB010796_A_Validate_NrRmod_rfTemperatureState_Samples_Counters
...  TESTING SPLIT   :  CB010796-A
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_21654,5G_RAN_USR_RRM_21655,5G_RAN_USR_RRM_21656

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
${nwslice_ID}    1
${gw_ID}     1
${pdu_id}    1
${nw_id}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${ue_id}     1
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      1
${en_ue_id}      1
${highMuting}         --db 1 set_temp_rating HIGH
${normalMuting}       --db 1 set_temp_rating NORMAL
${increasedMuting}    --db 1 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 1 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 1 cancel_rf_fault 1936 module
${TEST_NAME}     CB010796_Counters
${SCFC}     ${CURDIR}/config/SBTS24R1/AVQL_SCF.xml
${AP_XML}     ${CURDIR}/config/wts/AVQL_iphy.xml


*** Test Cases ***
[1][1.0] CB010796_A_Validate_NrCell_Samples_cellStateChange_Counters_At_Level1and3
    Set test variable     ${LOG_PATH}

#    Perform SCF Delta Commissioning with CB010796_Activation.json
    Configure ETH And Load CFG      ${wts_cfg_file}
    Sleep    3s
    Wait until the next Measurement Period starts
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Wait until the current Measurement Period stops
    ${pm_files1}     Collect RD Counters
    
    Validate NR CELL RF COOL MODE0 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE0 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE1 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE1 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE2 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE2 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE3 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE3 STATE CHANGE     ${pm_files1}

    Validate NR RMOD RF TEMP NORMAL SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP INCREASED SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP HIGH SAMPLES     ${pm_files1}
    [Teardown]      Link SCOUT SCF to Configuration ID for Reporting

