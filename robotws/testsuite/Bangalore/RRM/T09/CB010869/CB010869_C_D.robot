*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    VARIANVARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               5G_RAN     SBTS00    CONFIGURED

Documentation
...
...      author:            Geetha    geetha.k_r@nokia.com
...      maintainer:        Geetha    geetha.k_r@nokia.com
...
...      INTRODUCTION:    : This scenario validates that the gNB correctly determines the Cell TX paths Switch Off/On List
...                         for a Power Group when modifying threshold time window related parameters (add, delete, modify)
...                         and varying load during lbpsPeriod.

...       Requirement id -   5G_RAN_USR_COM_26269,5G_RAN_USR_COM_26271, 5G_RAN_USR_COM_26273, 5G_RAN_USR_COM_26272

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Library          ta_emss
Library          ta5g_pm_counters
Resource         ../../5GET_BLR/CB008541/resources/CB008541_Keywords.robot
Resource	     ../../5GET_BLR/CB008278/resources/common_CA.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ../../5GET_BLR/resources/python/BIP_Capture.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND    Update GNB R&D Parameter
...                 AND     Perform SCF Delta Commissioning with CB010869_feature_enable.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    1
...                 AND     Check gNB Bulid

Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}            1
${nwslice_ID}     1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${AP_XML}=         ${CURDIR}/config/iphy_AZQU.xml
${crnti_UE1}      ue_crnti
${SO_state}       switchingOff
${SON_state}      notEnergySaving
${reduseE_state}      reducedEnergySaving
${Energysaving_state}      energySaving
${NotEnergysaving_state}    notEnergySaving
${UE_ID_NSA}      101
${Target_Cells}      1
${exp_precoding}        255
${exp_precoding_SIB}        1 #SCDD
${exp_transscheme}      1
${exp_pdcch_precoding_Msg2}    2
${r&d_parameter}       0x590072=1

*** Test Cases ***
[1][1.0] CB010869_C_D_Robustness_2_Load_Fluctuations_and online_parameter_change_for__5G
    [Documentation]    This scenario validates that the gNB correctly determines the Cell TX paths Switch Off/On List
...                    for a Power Group when modifying threshold time window related parameters (add, delete, modify)
...                    and varying load during lbpsPeriod.

	Trigger ue attach and verify cell entered energysaving
	Verify attached cell entered notenergysaving
	5GC000937_Keywords.Perform SCF Delta Commissioning with CB010869_TX_switchoff_enable.json
	sleep    120s
	Verify cell entered reducedEnergysaving
	Verify cell entered energysaving
	Verify cell entered notenergysaving

*** Keywords ***
Send high data to switchon cell
    [Arguments]   ${Start_trf}   ${End_trf}     ${UE}
    FOR  ${trfid}  IN RANGE   ${Start_trf}   ${End_trf}+${1}
          wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=${trfid}
    END
Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Validate switchoff From Syslog
    [Arguments]    ${syslog}   ${SO_state}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "energySavingState =switchingOff"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   energySavingState =${SO_state}

Validate switchon From Syslog
    [Arguments]    ${syslog}   ${SON_state}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "energySavingState =notEnergySaving"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   energySavingState =${SON_state}

Verify attached cell entered notenergysaving
    Start Collecting Syslog     NAME=syslog_SON
	Send high data to switchon cell    2    9     1
	BuiltIn.Sleep  300s
	Stop Collecting Syslog       NAME=syslog_SON
	Validate switchon From Syslog   syslog_SON    ${SON_state}

Trigger ue attach and verify cell entered energysaving
    Start Collecting Syslog     NAME=syslog_SO
    NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}
    wts_sim_keywords.UE Register should be Successful And Fetch RNTI     1       1       1       1
	wts_sim_keywords.Trigger DL Traffic for SA      1      mbps     175     1      1      1
	BuiltIn.Sleep  300s
	Stop Collecting Syslog       NAME=syslog_SO
	Validate switchoff From Syslog   syslog_SO    ${SO_state}
	BuiltIn.Sleep      50s

Verify cell entered reducedEnergysaving
    NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}
    Start Collecting Syslog     NAME=syslog_rtx
	wts_sim_keywords.UE Register should be Successful And Fetch RNTI     21       1       1       1
	wts_sim_keywords.Trigger DL Traffic for SA      21      mbps     175     1      1      1
	Send high data to switchon cell     1    6     21
	BuiltIn.Sleep  300s
	Stop Collecting Syslog       NAME=syslog_rtx
	Validate reducedEnergySaving From Syslog   syslog_rtx    ${reduseE_state}
	BuiltIn.Sleep  60s
	Start Collecting Syslog     NAME=syslog_rtx_EnergyS

Stop data to move to energysaving
 	[Arguments]        ${ue_id}    ${pdu_id}    ${dir}    ${start_trf_id}     ${end_trf_id}    ${qfi}
    [Documentation]    This keyword starts the uplink data
    Log to Console    Stopping data
    FOR     ${trf_id}   IN RANGE    ${start_trf_id}    ${end_trf_id}+1
	${stop_data_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id}
    ute_wtssim.Execute Egate Command And Wait For Data		${stop_data_cmd}	timeout=${EGATE_COMMAND_TIMEOUT}
	...		pass_regexp=${traffic_stop_pattern}
	END

Verify cell entered energysaving
    Stop data to move to energysaving     21     1      dl     1      5      1
	BuiltIn.Sleep  300s
	BuiltIn.Sleep  300s
	Stop Collecting Syslog       NAME=syslog_rtx_EnergyS
	Validate energySaving From Syslog   syslog_rtx_EnergyS    ${Energysaving_state}
	BuiltIn.Sleep  60s

Verify cell entered notenergysaving
	Start Collecting Syslog     NAME=syslog_rtx_NotEnergyS
	wts_sim_keywords.UE Register should be Successful And Fetch RNTI     1       1       1       1
	wts_sim_keywords.Trigger DL Traffic for SA      1      mbps     175     1      1      1
	Send high data to switchon cell    2    9     1
	BuiltIn.Sleep  300s
	BuiltIn.Sleep  300s
	Stop Collecting Syslog       NAME=syslog_rtx_NotEnergyS
	Validate NotenergySaving From Syslog   syslog_rtx_NotEnergyS    ${NotEnergysaving_state}


Send high data to notenergysaving
    [Arguments]   ${Start_trf}   ${End_trf}
    FOR  ${trfid}  IN RANGE   ${Start_trf}   ${End_trf}+${1}
          wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=${trfid}
    END


Validate reducedEnergySaving From Syslog
    [Arguments]    ${syslog}   ${reduseE_state}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "energySavingState =reducedEnergySaving"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   energySavingState =${reduseE_state}

Validate energySaving From Syslog
    [Arguments]    ${syslog}   ${Energysaving_state}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "energySavingState =energySaving"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   energySavingState =${Energysaving_state}


Validate NotenergySaving From Syslog
    [Arguments]    ${syslog}   ${NotEnergysaving_state}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "energySavingState =notEnergySaving"
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   energySavingState =${NotEnergysaving_state}





