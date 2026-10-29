*** Settings ***
Force Tags
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Library    json
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{5G_CB007409_UHIE_3_Cell}=        peak_rate_config={"301":[110,20],"302":[110,20],"303":[110,20]}
...   HW_ID=CB007409    site_mode=SA    ONAIR_TIME=15 min    GG=110:97;99:123
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
##${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G157/swconfig.txt
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
#${INIT_CONFIG_ID}
${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}
${INIT_SW_VERSION}    {'10380': 'SBTS21B_ENB_0000_002023_000000'}
${MIDDLE_SW_VERSION}   {'10380': 'SBTS22R3_ENB_0000_002023_000000'}
${TARGET_SW_VERSION}    {'10380': 'SBTS22R4_ENB_0000_000446_000000'}
${loop}    ${5}
#${TARGET_SW_VERSION}    {'10380': ''} # will used current sbts version as target build
${RB_TO_TARGET}    NO # YES|NO
${YAFT}    NO
${PKG_TYPE}    Normal
${voltage_parameters}    [{'distName': "MRBTS-10324/EQM-1/APEQM-1/RMOD-2", 'paraName': "alVoltHighThreshold", 'paraValue':"570"},
...    {'distName': "MRBTS-10324/EQM-1/APEQM-1/RMOD-2", 'paraName': "alVoltLowThreshold", 'paraValue': "405"},
...    {'distName': "MRBTS-10324/EQM-1/APEQM-1/RMOD-2", 'paraName': "alVoltUnstableThreshold", 'paraValue': "5"},
...    {'distName': "MRBTS-10324/MNL-1/MNLENT-1/FEATCADM-1", 'paraName': "actPowerMeter", 'paraValue': "true"}]
${online_commissioning}    [['MRBTS-2163/LNBTS-2163/LNCEL-1',['dlInterferenceEnable','false']],
...    ['MRBTS-2163/LNBTS-2163/LNCEL-2',['dlInterferenceEnable','true']],
...    ['MRBTS-2163/LNBTS-2163/LNCEL-3',['dlInterferenceEnable','false']]]

${RF_VARIANT_OPTIMIZED}=  True
${RF_fault_info}
${fault_1907}      ${CURDIR}/dpd_dlpath1_1907.json
${fault_1907_file}  dpd_dlpath1_1907.json
${original_fault}     ${CURDIR}/dpd_dlpath1_origin.json
${original_fault_file}     dpd_dlpath1_origin.json
${scfc_config_t3}   BTS_CLOUD_RF_AIL_B1-B3_CRT1_1026_SBTS22R1_AZNA.xml
${SW_CONFIG_FILE_PATH}   ${CURDIR}/swconfig.txt
${GGMAP}     {'L1202005438': {'4' : '2.2.2'}, 'L1214206711': {'3': '2.6.3'}}
#${GGMAP}     {'L1202005438': {'4' : '2.2.2:3.3.2'}, 'L1214206711': {'3': '2.6.3:3.3.3'}}
${GLO_PERFORM_SAVE_LOG}              NONE    # possible settings: FAIL, ALWAYS, NONE
${GLO_RRU_PERFORM}                   True    # True: power off not needed rru; False: not power off not needed rru
${TOP50}                             True    #True: reporting result to scout

${related_paras}    [{'dist_name':'MRBTS-10059/NRBTS-10059/NRCELL-1','para_name':'RB Allocation','para_value':'52RB'}]
${parameters}    [{'dist_name':'MRBTS-10059/NRBTS-10059/NRCELL-1','para_name':'PRACH configuration index',
...    'para_value':'43','require_reset':False},{'dist_name':'MRBTS-10059/NRBTS-10059/NRCELL-1','para_name':'Start RB',
...    'para_value':'4','require_reset':False,'related_paras':${related_paras}}]
${CHANNELGROUP1_DIST_NAME}    MRBTS-10059/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
${RMOD1_DIST_NAME}    MRBTS-10059/EQM-1/APEQM-1/RMOD-1

${objects}    [{"object_name":"${CHANNELGROUP1_DIST_NAME}","object_class_name":"CHANNEL",
...    "plan_to_copy_from":${None},"copy_from":${None},"include_subobject":${False},"id_value":"6",
...    "is_load_default_values":False,"operate":"add"},{"object_name":"${CHANNELGROUP1_DIST_NAME}",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"8","is_load_default_values":False,"operate":"add"}]
#${objects}    [{"object_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-6","operate":"delete"},
#...    {"object_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-8","operate":"delete"}]

${parameters1}    [{"dist_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-6","para_name":"Direction of the channel",
...    "para_value":"RX","require_reset":"False"},{"dist_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-6",
...    "para_name":"Distinguished Name of antenna line","para_value":"${RMOD1_DIST_NAME}/ANTL-3",
...    "require_reset":"False"},{"dist_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-8",
...    "para_name":"Direction of the channel","para_value":"RX","require_reset":"False"},
...    {"dist_name":"${CHANNELGROUP1_DIST_NAME}/CHANNEL-8","para_name":"Distinguished Name of antenna line",
...    "para_value":"${RMOD1_DIST_NAME}/ANTL-4","require_reset":"False"},
...    {"dist_name":"MRBTS-10059/NRBTS-10059/NRCELL-1","para_name":"NR Cell type","para_value":"2DL4UL",
...    "require_reset":"False"}]
#${parameters}    [{"dist_name":"MRBTS-10059/NRBTS-10059/NRCELL-1","para_name":"NR Cell type","para_value":"2DL2UL",
#...    "require_reset":"False"}]

${bts_thresholds_parameters}    {"rFPowerErrorHighThreshold":"60",
...    "rFPowerErrorLowThreshold":"-80","rfTemperatureHighThreshold":"60",
...    "rfTemperatureLowThreshold":"-50","rxAntennaRTWPHighThreshold":"-300",
...    "rxAntennaRTWPLowThreshold":"-1100","txAntennaVSWRHighThreshold":"30"}

${UI_bts_thresholds_parameters}    {"RF power error high threshold":"6",
...    "RF power error low threshold":"-8","RF temperature high threshold":"60",
...    "RF temperature low threshold":"-50","RTWP high threshold":"-30",
...    "RTWP low threshold":"-110","TX antenna VSWR high threshold":"3"}
${UI_band41_thresholds}    [['40','100','30'], ['41',10,'20']]
${band41_thresholds}    [['40','1000','300'],['41','1000','200']]

${bts_thresholds_parameters_all}    {"rFPowerErrorHighThreshold":"60",
...    "rFPowerErrorLowThreshold":"-80","rfTemperatureHighThreshold":"6",
...    "rfTemperatureLowThreshold":"-50","rxAntennaRTWPHighThreshold":"-300",
...    "rxAntennaRTWPLowThreshold":"-1100","txAntennaVSWRHighThreshold":"30"}

${UI_bts_thresholds_parameters_all}    {"RF power error high threshold":"6",
...    "RF power error low threshold":"-8","RF temperature high threshold":"6",
...    "RF temperature low threshold":"-50","RTWP high threshold":"-30",
...    "RTWP low threshold":"-110","TX antenna VSWR high threshold":"3"}

${target_ru_info_fdd_tdd}    [{'serialNo':'1M173634014',
...    'pdu_type': 'facom', 'pdu_ipaddr': '10.108.151.100', 'target_pdu_port': 6}]

${target_ru_info_abic_abia}    [{'serialNo':'6Q181710303',
...    'breaklink':'3.6.6:3.6.2',  'linksec':'3.6.6:1.1.1'}]

${btsids}    [2396]

${pmax_config}    [{"dist_name":"MRBTS-10306/LNBTS-10306/LNCEL-1","para_name":"Maximum output power","para_value":"40.1"},
...    {"dist_name":"MRBTS-10306/LNBTS-10306/LNCEL-2","para_name":"Maximum output power","para_value":"40.1"},
...    {"dist_name":"MRBTS-10306/LNBTS-10306/LNCEL-3","para_name":"Maximum output power","para_value":"40.1"},
...    {"dist_name":"MRBTS-10306/LNBTS-10306/LNCEL-4","para_name":"Maximum output power","para_value":"40.1"}]

${parameter_list}    [{"dist_name": "MRBTS-590/MNL-1/MNLENT-1/FEATCADM-1",  "filter_param": "Transceiver alarm monitoring",
...                    "abbr": "actTransceiverAlarmMonitoring", "default_value": "Transceiver alarms"}]

${NR_TEST_MODEL_UPLINK}     {"1":{"testmodel":["G_FR1_A1_1","G_FR1_A1_4"],"beam_pattern_id":[0]},
...   "2":{"testmodel":["G_FR1_A1_1","G_FR1_A1_4"],"beam_pattern_id":[0],}}

${NR_TEST_MODEL_DOWNLINK}     {"1":{"testmodel":["TM1_1","TM1_2"],"beam_pattern_id":[0]},
...      "2":{"testmodel":["TM1_1","TM1_2"],"beam_pattern_id":[0]}}

${LTE_TEST_MODEL_UPLINK}     {"1":{"testmodel":["A1_1","A1_1"]},
...   "2":{"testmodel":["A1_1","A1_1"]}}

${LTE_TEST_MODEL_DOWNLINK}     {"1":{"testmodel":["E_TM1_1","E_TM1_2"]},
...      "2":{"testmodel":["E_TM1_1","E_TM1_2"]}}
${RFSW_PASSWORD}     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*** Test Cases ***
[1][1.0] Data Transfer
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_CB007409_UHIE_3_Cell
    ${extra_peak_rate_config}    Evaluate    {"301":[140,75],"302":[140,75],"303":[140,75]}
    test_fv.Data Transfer    extra_peak_rate_config=${extra_peak_rate_config}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Data Transfer All
    [Setup]    Testcase Precondition    case_name=L3call    config_id=5G_CB007409_UHIE_3_Cell
    ${extra_peak_rate_config}    Evaluate    {"301":[140,75],"302":[140,75],"303":[140,75]}
    Make Tput All    extra_peak_rate_config=${extra_peak_rate_config}
    [Teardown]    Testcase Postcondition

[1][1.0] L3call
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_CB007409_UHIE_3_Cell
    Make L3Call
    [Teardown]    Testcase Basic Postcondition

[1][1.0] L3call All
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_CB007409_UHIE_3_Cell
    Make L3Call All
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Cell Block And Unblock
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock    config_id=5G_CB007409_UHIE_3_Cell
    #Cell Block And Unblock All    extra_peak_rate_config=${extra_peak_rate_config}
    Cell Block And Unblock Sequential
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Onair
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5G_CB007409_UHIE_3_Cell
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Ru Lock And Unlock
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_And_Unlock    config_id=5G_C001115
    Ru lock And Unlock All    extra_peak_rate_config=${extra_peak_rate_config}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_Earfcn_check
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=Earfcn_check    config_id=5G_C001115
    Earfcn Update And Check    earfcn_config=${EARFCN_CONFIG}
    [Teardown]    Testcase Basic Postcondition

[1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning    config_id=5G_CB007409_UHIE_3_Cell
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    Testcase Basic Postcondition

Automated_SiSo_OnLine_Parameters_Commissioning
    [Tags]    QC_1
    [Setup]    Testcase Basic Precondition    case_name=ParametersCommissioning    config_id=5G_C001115
    Automated SiSo OnLine Parameters Commissioning
    [Teardown]  Testcase Basic Postcondition

[1][1.0] SISO_RF module power reset
    [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset
    SISO_RF module power reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] SISO_RF module power reset without 1815
    [Setup]    Testcase Basic Precondition    case_name=RF_Power_Reset
    SISO_RF module power reset without 1815
    [Teardown]    Testcase Basic Postcondition

[1][1.0] UUF
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase UUF Precondition    case_name=UUF    config_id=5G_C001115
    Update Sw To Target
    [Teardown]    Testcase Basic Postcondition

SISO_Powersaving_Check
   [Setup]    Testcase Basic Precondition    case_name=Voltage    config_id=xxx
   SISO Voltage Set And Powersaving Check    sleep_mode=${True}
   [Teardown]    Testcase Basic Postcondition

[1] SISO_Recovery RF module reset
    [Setup]    Testcase Basic Precondition    case_name=rf_reset
    SISO_Recovery RF module reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Site Reset With Remove HwBin
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin    config_id=5G_C001115
    Site Reset With Remove Hwbin
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Bts Power Reset
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=powerReset    config_id=5G_C001115
    Bts Power Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] RF Fault With Recovery Action
    [Tags]    QC_151745    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=fault_with_recovery_action    config_id=AZNA
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
#   upload the file needed to change
    RF Fault Without Recovery Action AZNA    faultid=1901    required_rfs=6Q173104565
    Upload SWconfig File          ${SW_CONFIG_FILE_PATH}
    [Teardown]    Testcase Basic Postcondition

#${GGMAP}     {'L1202005438': {'4' : '2.2.2'}, 'L1214206711': {'3': '2.6.3'}} parameters is mandatory
[1][1.0] SiSo Recovery Hot Remove And Insert RF Fibers
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=RemovePrimFiber    config_id=5G_C001115
    SiSo Recovery Hot Remove And Insert RF Fibers    rflink={'L1202005438': ['primary', 'seccondary']}
    [Teardown]    Testcase Basic Postcondition

[1]SISO RF Diagnostic Test
    [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest    config_id=5314_2CL1_T4_L_247
    Automated RF Diagnostic Test
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Stability Common_SiSo_Recovery_BTS SiteReset
    [Setup]    Testcase Basic Precondition    case_name=site_reset
    Stability Site Reset    repetition=50
    [Teardown]    Testcase Basic Postcondition

[1][1.1] Hot remove insert fibers between AFAA and RRUs
    [Setup]    Testcase Basic Precondition    case_name=Remove_AFAA_RRUs
    Hot remove insert fibers between AFAA and RRUs
    [Teardown]    Testcase Basic Postcondition

Automated__SiSo__Operational_AFAA_power_off_then_on
    [Setup]       Testcase Basic Precondition    case_name=AFAA_power_reset
    Automated SiSo Operational AFAA power off then on
    [Teardown]    Testcase Basic Postcondition

[1.0] SiSo_Hot_Remove_Insert_Fibers_Between_AFAA_And_BBU
	[Tags]    QC_192820   QCD_MN_RAN    QCP_RAN_ST
    [Setup]  Testcase Basic Precondition     case_name=Remove_AFAA_BBU
    Hot remove insert fibers between AFAA and BBU
    [Teardown]    Testcase Basic Postcondition

BS_FV_AFAA_Epimc_Calibrate_Functional_Verification
    [Setup]  Testcase Basic Precondition     case_name=epimc_function_verify
    AFAA_Epimc_Calibrate_Functional_Verification
    [Teardown]    Testcase Basic Postcondition

BS_FV_AFAA_Epimc_Runtime_Calibrate_Verification
    [Setup]  Testcase Basic Precondition     case_name=epimc_runtime_verify
    AFAA_Epimc_Runtime_Calibrate_Verification
    [Teardown]    Testcase Basic Postcondition

[1]AFAA_support_for_UHLB_UHLC_with_old_FirmWare_version
    [Setup]  Testcase Basic Precondition     case_name=old_FirmWare_version
    AFAA_support_for_UHLB_UHLC_with_old_FirmWare_version
    [Teardown]    Testcase Basic Postcondition

SiSo_CM_Recommissioning_template
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning
    ${parameters}    Evaluate    ${parameters}
    ${objects}    Evaluate    ${objects}
    SiSo Multi Parameters Recommissioning    ${parameters}    ${objects}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_Online_Cell_Addition_Deletion
    [Setup]    Testcase Basic Precondition    case_name=cell_add_delete
    General SISO Online Cell Addition Deletion    addition_deletion_cell=171:172    repetition=2
    [Teardown]    Testcase Basic Postcondition

[1][1.0]Antenna Calibration Check AEQP
    [Setup]    Testcase Basic Precondition    case_name=Calibration
    SISO Antenna Calibration Check AEQP    required_rfs=1M214800861
    [Teardown]    Testcase Basic Postcondition

[1][1.0]Antenna Calibration Check Ecpri
    [Setup]    Testcase Basic Precondition    case_name=Calibration
    SISO Antenna Calibration Check ECPRI    ru_password_user=5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_Online_Sector_Addition_Deletion
    [Setup]    Testcase Basic Precondition    case_name=cell_add_delete
    General SiSo Online Sector Addition Deletion    antl_dict={"AS214618768": "1", "AS214618775": "2"}    repetition=2
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    QC_269829    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=2AEHC_2AZHA_PORT1478_S3333
    Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_BB_sub-unit_reset_with_L3_call
    [Setup]    Testcase Basic Precondition    case_name=BBMOD_Reset
    BBMOD Reset
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Power Reduction With Static DVM Parameters Into AZNA/AZHA
    [Tags]    QC_357568    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Power_Reduction
    Power Reduction With Static DVM Parameters Into AZNA/AZHA   60    12000   12000
    [Teardown]    Testcase Basic Postcondition

[1][1.0] WebEM RF Diagnostic Editing And Saving Thresholds
    [Tags]    QC_357568    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=WebEM_RF_Diagnostic_Editing_And_Saving_Thresholds
    ${UI_bands_thresholds}    Evaluate    ${UI_band41_thresholds}
    ${bands_thresholds}    Evaluate    ${band41_thresholds}
    ${bts_thresholds_parameters}    Evaluate    ${bts_thresholds_parameters}
    ${UI_bts_thresholds_parameters}    Evaluate    ${UI_bts_thresholds_parameters}

    WebEM RF Diagnostic Editing And Saving Thresholds Step    bts_id=10361
    ...    UI_bts_thresholds=${UI_bts_thresholds_parameters}    bts_thresholds=${bts_thresholds_parameters}
    ...    bands_thresholds=${bands_thresholds}    UI_bands_thresholds=${UI_bands_thresholds}
    ...    technology=LTE    cell=LNCEL-1

    ${bts_thresholds_parameters_all}    Evaluate    ${bts_thresholds_parameters_all}
    ${UI_bts_thresholds_parameters_all}    Evaluate    ${UI_bts_thresholds_parameters_all}

    WebEM RF Diagnostic Editing And Saving Thresholds Step    bts_id=10361
    ...   UI_bts_thresholds=${UI_bts_thresholds_parameters_all}    bts_thresholds=${bts_thresholds_parameters_all}
    ...   technology=LTE    cell=All LTE cells
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Check Alarms
    Check Historical Alarms
    [Teardown]    Testcase Basic Postcondition

[1][1.0] FDD_TDD_Fault_4525_EFaultId_UnsupportedRadioConnectionConfigurationAl
    [Setup]    Testcase Basic Precondition    case_name=UnsupportedRadioConnectionConfigurationAl
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    ${target_ru_info_fdd_tdd}    Evaluate    ${target_ru_info_fdd_tdd}
    ${btsids}    Evaluate    ${btsids}
    Unsupported Radio Connection Between FDD And TDD Configuration With Fault 4525
    ...    target_ru_info=${target_ru_info_fdd_tdd}    btsids=${btsids}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] ABIC_ABIA_Fault_4525_EFaultId_UnsupportedRadioConnectionConfigurationAl
    [Setup]    Testcase Basic Precondition    case_name=UnsupportedRadioConnectionConfigurationAl
    ...    config_id=2AEHB_T3_AZQF_AZNB_T4_FXED_T6
    ${target_ru_info_abic_abia}    Evaluate    ${target_ru_info_abic_abia}
    ${btsids}    Evaluate    ${btsids}
    Unsupported Radio Connection Between ABIA And ABIC Configuration With Fault 4525
    ...    target_ru_info=${target_ru_info_abic_abia}    btsids=${btsids}
    [Teardown]    Testcase Basic Postcondition

[2.0] LTE1656-C_Run RF Diagnostic test on block_unblock cells_EV
    [Setup]    Testcase Basic Precondition    case_name=rf_diagnostic
    Run RF Diagnostic Test With Block Unblock Cell    bts_id=2251    technology=LTE
    [Teardown]    Testcase Basic Postcondition

[2.0] LTE1656-C_Run RF Diagnostic test on block_unblock radios_EV
    [Setup]    Testcase Basic Precondition    case_name=rf_diagnostic
    Run RF Diagnostic Test With lock Unlock RU    bts_id=2251    technology=LTE
    [Teardown]    Testcase Basic Postcondition

#${breaklink}=1:2    ${connectlink}=1:3  ${earfcn_config}={'131': {'InRange': {'Dl':'394000'}}}
#${parameter_list1} = [{'dist_name':'MRBTS-10059/NRBTS-10059/NRCELL-1','para_name':'PRACH configuration index',
#...    'para_value':'43','require_reset':False},{'dist_name':'MRBTS-10059/NRBTS-10059/NRCELL-1','para_name':'Start #RB',
#...    'para_value':'4','require_reset':False,'related_paras':${related_paras}}]

[2.0]LTE2745-A-g_OBSAI_CPRI-N_CPRI-FJ_Commissioning_with_fiber_change
    [Setup]    Testcase Basic Precondition    case_name=rf_diagnostic
    OBSAI_CPRI-N_CPRI-FJ_Commissioning_with_fiber_change    ${breaklink}    ${connectlink}
    ...    ${earfcn_config}    ${parameter_list1}    ${parameter_list2}
    [Teardown]    Testcase Basic Postcondition

[3][1.0] LTE5188_Check_SRIO_And_ETH_Connection
    [Tags]    QC_364674   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=srio_eth
    Check SRIO And ETH Connection
    [Teardown]    Testcase Basic Postcondition

[3]SWDL For Incompatible Load SW RRU
    [Documentation]   Auther: nick.1.wu@nokia-sbell.com
    ...    "IMPORTANT"
    ...    This case need add a dict "RF_INCOMPATIBLE_SW_STORAGE" into env.py. More detail about this dict
    ...    can be seen in env.py from this dictionary.
    ...    And tester need to download 23R1 RF package and 22R4 RF package, It's better to download old package.
    ...    And put them into 10.106.211.194 under /home/siso/LTE/Factory_SW/    user/password ---> siso/siso
    [Setup]    Testcase Basic Precondition    case_name=SWDL_For_Incompatible_Load_SW_RRU
    SWDL For Incompatible Load SW RRU    6Q181710303    required_cells=143:144
    [Teardown]    Testcase Basic Postcondition

Validation of power exceeding max allowed power per pipe
    [Setup]    Testcase Basic Precondition    case_name=Onair
    ${pmax_config}    Evaluate    ${pmax_config}
    Validation Of Power Exceeding Max Allowed Power Per Pipe    ${pmax_config}   bts_id=10306
    [Teardown]    Testcase Basic Postcondition


OnAir With CMCC
    [Setup]    Testcase Basic Precondition    case_name=Onair
    Update To CMCC Package    cmcc_sw=SBTS22R2_ENB_0000_000446_000000
    Site Reset
    [Teardown]    Testcase Basic Postcondition


SISO_RF module power reset with check ru startup time
    [Setup]    Testcase Basic Precondition    case_name=Onair
    SISO_RF module power reset with check ru startup time
    [Teardown]    Testcase Basic Postcondition

Site Reset With Check RU Startup Time
    [Setup]    Testcase Basic Precondition    case_name=Onair
    Site Reset With Check RU Startup Time    expected_duration=180
    [Teardown]    Testcase Basic Postcondition

SISO_Recovery RF module reset With Check Startup Time
    [Setup]    Testcase Basic Precondition    case_name=Onair
    SISO_Recovery RF module reset With Check Startup Time
    [Teardown]    Testcase Basic Postcondition

[1] Check Parameter Default Value
    [Setup]    Testcase Basic Precondition    case_name=default_value
    ${parameter_list}    Evaluate    ${parameter_list}
    Check Parameter Default Value    ${parameter_list}
    [Teardown]    Testcase Basic Postcondition

#RF Fault 1907 With recovery Action Rel6
#    [Setup]    Testcase Basic Precondition    case_name=trigger_1907    config_id=test
#    RF Fault With recovery Action Rel6   faultid=1907
#    [Teardown]    Testcase Basic Postcondition
#
#RF Fault 1933 Without recovery Action Rel6
#    [Setup]    Testcase Basic Precondition    case_name=trigger_1933    config_id=test
#    RF Fault Without recovery Action Rel6   faultid=1933
#    [Teardown]    Testcase Basic Postcondition

Manual Siso PM 5G uDTX
    [Setup]    Testcase Basic Precondition   case_name=uDTX    config_id=test
    Manual Siso PM 5G uDTX
    [Teardown]    Testcase Basic Postcondition

# ${MIDDLE_SW_VERSION}
# ${loop}    ${5}
[1][1.0] UUF Stability
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase UUF Precondition    case_name=UUF    config_id=5G_C001115
    test_fv.Update Sw To Target    rollback=NO
    FOR    ${i}    IN RANGE    ${1}    ${loop}
        test_fv.Update Sw To Target    rollback=NO    target_builds=${MIDDLE_SW_VERSION}
        ${index}    Evaluate    ${i} + 1
        Run Keyword IF    "${index}"!="${loop}"    test_fv.Update Sw To Target    rollback=NO
        Run Keyword IF    "${index}"=="${loop}"    test_fv.Update Sw To Target    rollback=YES
    END
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Test_Dedicated_downlink
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=test
    Test Dedicated Downlink With Switch Testmodel
    [Teardown]    Testcase Basic Postcondition

# need define Test Case Variable ${RFSW_PASSWORD}
SISO SFP transceiver temperrature too high on RRU
    [Setup]    Testcase Basic Precondition    case_name=Fault_4698    config_id=xxxx
    RF Fault 4698 SFP transceiver temperrature too high    rf_sn=AH222602968
    [Teardown]    Testcase Basic Postcondition

# need define Test Case Variable ${RFSW_PASSWORD}
CB011039-A_01_Radio_Module_fail_safe_mode_fault_activation
    [Setup]    Testcase Basic Precondition    case_name=Fault_2394    config_id=xxxx
    Radio_Module_fail_safe_mode_fault_activation    rf_sn=L1174407170
    [Teardown]    Testcase Basic Postcondition
