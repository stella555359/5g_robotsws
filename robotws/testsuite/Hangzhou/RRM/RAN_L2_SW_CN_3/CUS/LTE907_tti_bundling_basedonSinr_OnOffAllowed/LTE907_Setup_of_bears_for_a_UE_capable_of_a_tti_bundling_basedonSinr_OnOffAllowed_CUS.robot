*** Settings ***
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        QCD_MN_RAN    QCP_RAN_ET     SBTS00    RAN_4G    RAN_4G_TDD    CLOUD_R4BO9_CUS    CRT    wennan.deng@nokia-sbell.com
#Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot


*** Variable ***
${CONFIG_DIR_PATH}    ${CURDIR}/config/
${scfc_name}   SCFC_1.xml
${cus_yaml}    cus_R4BO9.yaml
${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
@{earfcn}    text|38950|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']
...    text|39150|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']    text|39350|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
@{tdd_configuration}    text|1|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]
@{TM_mode}        text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
@{A2_threshold}    text|enabled|//*[@name\="actIfHo"]    text|52|//*[@name\="threshold2InterFreq"]    text|56|//*[@name\="threshold1"]
@{qciTab1}        text|true|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab1']/item/*[@name='enforceTtiBundling']
@{ttibundling}    text|false|//*[@name\="actTtiBundling"]
@{modify_list}    ${inactivityTimer}    @{earfcn}    @{tdd_configuration}    @{TM_mode}    @{A2_threshold}    @{qciTab1}    @{ttibundling}
${category_professional}    C99FF41034410381FF834626800A00663050381C0E070381C00E000005808000


*** Test Case ***
LTE907-C-c_01_01_04_Setup_of_bears_for_a_UE_capable_of_a_tti_bundling basedonSinrOnOffAllowed
    [Tags]     QC_349749
    Step1:Set parameters as pre-condition. All cells with same modulation scheme and without any background load, and any pre-add attenuation
    Step2:Attach 1 TTI bundling supported UE1 and Create QCI1 DRB and then UL t-put
    Step3:MeasGap interwork with TTI bundling
    Step4:Detach ue
*** Keyword ***
Step1:Set parameters as pre-condition. All cells with same modulation scheme and without any background load, and any pre-add attenuation
    Start enb and cus syslog'1'
    Establish cell with bandwidth 20M 1 7 dl CA
    collect procotol log '1' from egate
    Stop and collect enb and cus syslog

Establish cell with bandwidth 20M 1 7 dl CA
    ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
    ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
    copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
    copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
    Modify SCFC into 3cc CA    ${scfc_path}
    Add parameter in all cell level    ${TEST LOG DIRECTORY()}/scfc.xml    <p name="ttibOperMode">sinrBasedTtibOnOffAllowed</p>
    Add parameter in all cell level    ${TEST LOG DIRECTORY()}/scfc.xml    <p name="ttibSinrThresholdIn">10</p>
    Add parameter in all cell level    ${TEST LOG DIRECTORY()}/scfc.xml    <p name="ttibSinrThresholdOut">16</p>
    Add lnhoif extend parameter on cell'1' ,and set parameter eutraCarrierInfo:'39150'
    Add lnadj extend parameter ,and set adj parameter adjEnbId:'2'cPlaneIpAddr:'192.168.255.1'
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}

Step2:Attach 1 TTI bundling supported UE1 and Create QCI1 DRB and then UL t-put
    Start enb and cus syslog'2'
    setup admin    bts_host=${bts_host}    bts_port=${bts_port}    use_ssl=True    alias=delta_commission
    perform_delta_recommissioning    delta_file=${CURDIR}/cell1_actTtiBundling_ture.json    skip_parameter_relation_errors=${True}
    ...    alias=delta_commission
    teardown admin    alias=delta_commission
    wait_throughput_stable    60s
    start_capture_ttitrace'2'
    Attach assign number single_UE'1' of category'${category_professional}' into cell'1'
    wait_throughput_stable    2s
    Cus Execute Uex Command    bearer_add ue\=1 qci\=1 mbr_ul\=31 mbr_dl\=31 gbr_ul\=31 gbr_dl\=31
    Cus Execute Uex Command    trf_data_start ue\=1 qci\=1 kbps\=1000 trf_id\=1 dir\=ul protocol\=udp
    Cus Execute Uex Command    trf_data_start ue\=1 qci\=9 kbps\=80000 trf_id\=1 dir\=dl protocol\=udp
    wait_throughput_stable   20s
    ${ul_throughput}    cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
    ${dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
    Save_and_Decode_ttitrace_'2'
    Stop and collect enb and cus syslog
    collect procotol log '2' from egate
    #should_be_true    ${ue1_ul_qci1_throughput}>=1
    #should_be_true    ${ue1_dl_qci9_throughput}>=80

Step3:MeasGap interwork with TTI bundling
    Start enb and cus syslog'3'
    start_capture_ttitrace'3'
    iphy_execute_egate_command    ue_measurement_send id\=1 meas_id\=7 srsrp\=50
    cus_execute_uex_command    ue_ul_power_control cell\=current id\=1 pathloss\=115
    cus_execute_uex_command    uec_cell_param id\=1 ul_noise\=-120
    cus_execute_uex_command    uec_cell_param id\=1 ul_noise\=-110
    cus_execute_uex_command    uec_cell_param id\=1 ul_noise\=-105
    wait_throughput_stable    10s
    cus_execute_uex_command    ue_ul_power_control cell\=current id\=1 pathloss\=90
    cus_execute_uex_command    uec_cell_param id\=1 ul_noise\=-120
    wait_throughput_stable    10s
    Save_and_Decode_ttitrace_'3'
    Stop and collect enb and cus syslog
    collect procotol log '3' from egate

Step4:Detach ue
    Start enb and cus syslog'4'
    cus_detach    ue_id_list=1
    Stop and collect enb and cus syslog
    collect procotol log '4' from egate

wait_throughput_stable
    [Arguments]    ${time}
    sleep    ${time}