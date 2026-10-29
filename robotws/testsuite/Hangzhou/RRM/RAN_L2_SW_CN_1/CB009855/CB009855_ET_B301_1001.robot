*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Common parameters ###
#${SWCONFIG_PARAM}
#${SCF_PATH}                    ${CURDIR}/Config
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${WTS_CFG}                     CB9855B.cfg
#${3T3F_IPHY}                   ${CURDIR}/Resources/wts/iphy9855B.xml
#${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
#${FILTER}                      uldata_pucchreceiverespps || uldata_puschreceiverespharqd || uldata_puschreceiverespps
#@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot    3gpp.rnti    uci.pusch.part1bits    data.data
#${PREFERENCE}                  preferences_A009_A013
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#### B1002 And B1001 ###
#${FULL_SCF_CB009855_B_ET_1001}       FULL_CB009855B_IWK8311_scfc_A1_overHeating.xml
#${FULL_SCF_CB009855_B_ET_301}        FULL_CB009855B_IWK9169_SCFC_blind.xml
#${UE1}                         1
#${UE6}                         6
#@{5CC_SCELL_PCI1}               50    52    53    54
#@{5CC_CHECK1}                   ${5CC_SCELL_PCI1}
#@{5CC_SCELL_PCI6}               50    51    53    54
#@{5CC_CHECK6}                   ${5CC_SCELL_PCI6}
#@{5CC_SCELL_IWK9169_1}          50    51    52    53
#@{5CC_CHECK_IWK9169_1}          ${5CC_SCELL_PCI1}
#@{5CC_SCELL_IWK9169_6}          50    51    53    54
#@{5CC_CHECK_IWK9169_6}          ${5CC_SCELL_PCI6}
#${DL_DATA}                     1500
#${UL_DATA}                     100
#${5CC_NUM}                     5
#@{2CC_EXP_UL_TPUT_LIST}        1    1
#@{5CC_EXP_DL_TPUT_LIST}        5    1    5    5    1
#${SRSRP_NR}                    105
#${PCELL_ID}                    55
#${TIMER}                       20s
#${EGATE_FILE}                  ${TEST_LOG_DIRECTORY}/UE1/egate_console.log
#${MSG_ACTIVE}                 activated successfully at airphone
#${MSG_DEACTIVE}               deactivated successfully at airphone
#
#
#*** Test Cases ***
#CB009855-ET-B1001_Verify_2T3F_IWK_CB008311_buffer_based_SCell_addition_with_A1_event
#    [Tags]    Owner_zbu
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_B_ET_1001}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Log To Console     ...MaxNumScellsDlFr1 set to false...
#    Online Change MaxNumScellsDlFr1 Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-6    parameter=maxNumScellsDlFr1    value=3
#    Log To Console     ...MaxNumScellsDlFr1 set to true...
#    Online Change MaxNumScellsDlFr1 Parameter    dist_name=MRBTS-1/NRBTS-1/NRCELL-6    parameter=maxNumScellsDlFr1    value=4
#    5CC UE Attach And A1 Triggered    ${UE1}    ${5CC_SCELL_PCI1}
#    Trigger IWK8311 With A1 Event Mode Check Scells Activated And Scells Deactived And Scells Reactived    ${UE1}
#    Start Gnb BIP Log
#    5CC UE Attach And A1 Triggered    ${UE6}    ${5CC_SCELL_PCI6}
#    Capture Ttitrace No Convert Format    3s
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    Trigger IWK8311 With A1 Event Mode Check Scells Activated And Scells Deactived And Scells Reactived    ${UE6}
##    [Teardown]    Test Teardown Recover Env    scf_file=${SCF_TEST_BAK_FILE}    iphy_file=${IPHY_TEST_BAK_FILE}
#    [Teardown]    Common Test Teardown
#
#CB009855-ET-B301_Verify_2T3F_interworking_with_CB009169_UL_CA_
#    [Tags]    Owner_zbu
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_B_ET_301}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    Start Gnb BIP Log
#    5CC UE Attach And BLind Triggered    ${UE1}    ${5CC_SCELL_IWK9169_1}
#    5CC UE Attach And BLind Triggered    ${UE6}    ${5CC_SCELL_IWK9169_6}
#    Capture Ttitrace No Convert Format    3s
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#5CC UE Attach And A1 Triggered
#    [Arguments]    ${UE_ID}    ${PCI}
#    UE Attach And Start DL UL Big Traffic Via A1 Event
#    ...    ${UE_ID}    ${PCI}   ${5CC_NUM}    ${DL_DATA}    ${UL_DATA}
#    Check 5CC CA UE DL And UL Pcell Scell TP On Target    ${UE_ID}
#
#5CC UE Attach And BLind Triggered
#    [Arguments]    ${UE_ID}    ${PCI}
#    UE Attach And Start DL UL Big Traffic Via Blind
#    ...    ${UE_ID}    ${PCI}    ${5CC_NUM}    ${DL_DATA}    ${UL_DATA}
#    Check 5CC CA UE DL And UL Pcell Scell TP On Target    ${UE_ID}
#
#UE Attach And Start DL UL Big Traffic Via A1 Event
#    [Arguments]    ${UE_ID}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    ${ul_data}
#    SA 5G CA Attach    ${UE_ID}
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${ul_data}
#    Log To Console    ...DL data start...
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${dl_data}
#    Log To Console     ...UL data start...
#    Trigger A1 Scell Addition    ${UE_ID}    ${SRSRP_NR}    ${PCELL_ID}
#    Sleep    ${TIMER}
#    Check SA All Scell PhysicalID With UE ID      ${UE_ID}    ${scell_physical_ids}    ${cc_num}
#
#UE Attach And Start DL UL Big Traffic Via Blind
#    [Arguments]    ${UE_ID}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    ${ul_data}
#    SA 5G CA Attach    ${UE_ID}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${dl_data}
#    Log To Console    ...DL data start...
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${ul_data}
#    Log To Console     ...UL data start...
#    Sleep    ${TIMER}
#    Check SA All Scell PhysicalID With UE ID      ${UE_ID}    ${scell_physical_ids}    ${cc_num}
#
#Check 5CC CA UE DL And UL Pcell Scell TP On Target
#    [Arguments]    ${UE_ID}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${5CC_EXP_DL_TPUT_LIST}    ${5CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE     ${UE_ID}    ${2CC_EXP_UL_TPUT_LIST}    ${5CC_NUM}
#
#Trigger OverHeating
#    [Arguments]    ${UE_ID}
#    Run Keyword And Continue On Failure    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    cmd=ue_assistance_send_nr ue_id=${UE_ID} forOverheating=yes reducedCCsDL=0
#    ...    pass_regexp=deactivated successfully    timeout=60s
#
#Trigger IWK8311 With Blind Mode Check Scells Activated And Scells Deactived And Scells Reactived
#    [Arguments]    ${UE_ID}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_active
#    Check Egate Log With Message      ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_active/egate_console.log       ${MSG_ACTIVE}
#    Trigger OverHeating       ${UE_ID}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_deactive
#    Check Egate Log With Message      ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_deactive/egate_console.log        ${MSG_DEACTIVE}
#    Sleep     ${TIMER}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_Reactive
#    Check Egate Log With Message      ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_deactive/egate_console.log        ${MSG_ACTIVE}
#
#Trigger IWK8311 With A1 Event Mode Check Scells Activated And Scells Deactived And Scells Reactived
#    [Arguments]    ${UE_ID}    ${eventid}=1
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_active
#    Check Egate Log With Message      ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_active/egate_console.log       ${MSG_ACTIVE}
#    A2 Event Released For IWK8311 Several Times       ${UE_ID}
#    A1 Event Addition For Scells Again    ${UE_ID}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_Reactive
#    Check Egate Log With Message      ${TEST_LOG_DIRECTORY}/UE${UE_ID}_scell_Reactive/egate_console.log        ${MSG_ACTIVE}
#
#A2 Event Released For IWK8311 Several Times
#    [Arguments]    ${UE_ID}    ${scell_id}=0    ${scell_rsrp}=40    ${scell_rsrq}=0    ${meas_id}=4
#    :FOR    ${scell_id}    IN RANGE    0    ${meas_id}
#    \    ${output}        ute_wtssim.Execute Egate Command
#        ...       cmd=ue_measurement_send_nr id=${UE_ID} event=A2 meas_id=${${meas_id}+${scell_id}} scell=${${scell_id}+1}
#        ...       scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
#        ...       pass_regexp=sCellToReleaseList    timeout=3s
#
#A1 Event Addition For Scells Again
#    [Arguments]    ${UE_ID}        ${meas_id}=12
#    ${output}        ute_wtssim.Execute Egate Command
#    ...       cmd=ue_measurement_send_nr id=${UE_ID} event=A1 meas_id=${meas_id} srsrp_nr=105 srsrq_nr=105
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${ul_data}
#    Log To Console    ...DL data start...
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${dl_data}
#    Log To Console     ...UL data start...
#    Sleep    ${TIMER}
#    Check SA All Scell PhysicalID With UE ID      ${UE_ID}    ${5CC_SCELL_PCI${UE_ID}}    ${5CC_NUM}
#
#
#Capture Ttitrace No Convert Format
#    [Arguments]    ${capture_time}    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Sleep    ${capture_time}    reason=capture ttitrace
#    common_Log_capture.Stop Ttitrace    log_dir=${log_dir}
#
#Online Change MaxNumScellsDlFr1 Parameter
#    [Arguments]    ${dist_name}    ${parameter}    ${value}
#    COAM.Setup Admin
#    COAM.Perform Parameter Recommissioning
#    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
#    [Teardown]    COAM.Teardown
