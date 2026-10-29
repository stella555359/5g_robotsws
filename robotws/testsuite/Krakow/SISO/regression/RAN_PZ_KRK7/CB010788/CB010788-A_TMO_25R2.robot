*** Settings ***
Documentation
...   author:
...    - Mateusz Matusik (mateusz.matusik@nokia.com)

Resource   ./resources/CB010788_keywords.robot

Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
#Suite Setup       Setup Test Suite
#Suite Teardown    Common Suite Teardown

*** Variables ***
@{CUSTOMERS_LIST}      TMO US
@{CUSTOM_ALARMS}       61648    7115    4420    4123    4125    8150    4694    6450    4479

${MRBTS_ID}            79030
&{NODE1}               testline_object=${tl.gnbs[0]}
...                    custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}               ${NODE1}

${QC_DOMAIN}=          MN_RAN
${QC_PROJECT}=         RAN_VRF
${RP_CA}               VRF_SiSo
${RP_ORGANIZATION}     VRF_KRK_T07
${RP_LOCATION}         VRF_KRK

${bts_mplane_ip}=   ${tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]}
${bts_username}=    toor4nsn
${bts_password}=    oZPS0POrRieRtu

${VM_USERNAME}=     ute       # vm username used in syslog
${VM_PASSWORD}=     ute       # vm password used in syslog
${BTS_HOST_IP}=     192.168.255.1  #  IP used in admin setup

${test_dir}=                             testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB010788
${scfc_dir}=                             commissionings/Krakow/7_7_UTE5GCLOUDT8SK030/SBTS25R2
${base_scfc}=                            ${scfc_dir}/GNB0_SCF.xml
${delete_notes}=                         ./config/json_delta/TC2_delete_notes.json
${TC2_holdover_enable}=                  ./config/json_delta/TMO_TC2_holdover_enable.json
${TC2_7115_alarm_supp}=                  ${scfc_dir}/CB010788/TC2_7115_alarm_supp_scfc.xml
${TC2_disable_supp}=                     ${scfc_dir}/CB010788/TC2_disable_supp_scfc.xml
${TC2_switch_from_7115_to_4710_supp}=    ${scfc_dir}/CB010788/TC2_switch_from_7115_to_4710_supp_scfc.xml
${TC2_switch_to_warning}=                ${scfc_dir}/CB010788/TC2_switch_to_warning_scfc.xml
${TC2_allow_4710}=                       ${scfc_dir}/CB010788/TC2_allow_4710_scfc.xml
${TC5_allow_4000}=                       ${scfc_dir}/CB010788/TC5_allow_4000_scfc.xml
${TC5_allow_4694}=                       ${scfc_dir}/CB010788/TC5_allow_4694_scfc.xml
${TC5_block_RMOD}=                       ${scfc_dir}/CB010788/TC5_block_RMOD_scfc.xml
${TC5_block_RMOD_CABLINK}=               ${scfc_dir}/CB010788/TC5_block_RMOD_CABLINK_scfc.xml
${TC5_block_CABLINK2}=                   ${scfc_dir}/CB010788/TC5_block_CABLINK2_scfc.xml
${TC5_block_CABLINK1}=                   ${scfc_dir}/CB010788/TC5_block_CABLINK1_scfc.xml

*** Test Cases ***
CB010788_A_2_Alarm_suppression_for_eCPRI_RU_threshold_faults
    [Tags]    TC2    CRT    mm    25R2
    [Setup]    TC2 Test Setup

    Verify that fault 4710 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC2_7115_alarm_supp}
    ## ALARMSUPP.actAlarmsSuppression set to suppressAlarms (2)
    ## ALARMSUPP.suppressedAlarmList.alarmId set to 7115
    ## ALARMSUPP.suppressedAlarmList.alarmSeverity set to MINOR (1)
    Trigger fault 4710 by enabling SyncE Holdover feature
    Verify that fault 4710 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC2_switch_from_7115_to_4710_supp}
    ## ALARMSUPP.suppressedAlarmList is deleted
    ## ALARMSUPP.suppressedFaultList.faultid set to 4710
    ## ALARMSUPP.suppressedAlarmList.alarmSeverity set to MINOR (1)
    Verify that fault 4710 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC2_switch_to_warning}
    ## ALARMSUPP.suppressedAlarmList.alarmSeverity set to WARNING (0)
    Verify that fault 4710 is present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC2_disable_supp}
    ## ALARMSUPP.actAlarmsSuppression set to disabled (0)
    Verify that fault 4710 is present in alarm list
    Delete NOTE connected to CNI-127210
    ## MRBTS/MNL/NOTES/NOTE.attribute.attribName is not set
    ## MRBTS/MNL/NOTES/NOTE.attribute.attribValue is not set
    Verify that fault 4710 is present in alarm list
    Reset gNB and wait for cells to be onAir
    Verify that fault 4710 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC2_allow_4710}
    ## ALARMSUPP.actAlarmsSuppression set to allowAlarms (1)
    ## ALARMSUPP.allowedFaultList.faultid set to 4710
    ## ALARMSUPP allowedFaultList.alarmSeverity: MINOR_AND_WARNING (2)
    Verify that fault 4710 is not present in alarm list

CB010788_A_5_Alarm_suppression_for_FIFO_buffer_monitoring_fault
    [Tags]    TC5    CRT    mm    25R2
    [Setup]    TC5 Test Setup

    Verify that fault 4694 is not present in alarm list
    Trigger fault 4694
    Verify that fault 4694 is present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_allow_4000}
    ## ALARMSUPP.actAlarmsSuppression set to allowAlarms (1)
    ## ALARMSUPP.allowedFaultList.faultid set to 4000
    ## ALARMSUPP allowedFaultList.alarmSeverity set to MINOR_AND_WARNING (2)
    Trigger fault 4694
    Verify that fault 4694 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_allow_4694}
    ## ALARMSUPP.actAlarmsSuppression set to allowAlarms (1)
    ## ALARMSUPP.allowedFaultList.faultid set to 4694
    ## ALARMSUPP allowedFaultList.alarmSeverity: MINOR_AND_WARNING (2)
    Trigger fault 4694
    Verify that fault 4694 is present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_block_RMOD}
    ## ALARMSUPP.actAlarmsSuppression set to suppressAlarms (2)
    ## ALARMSUPP.suppressAlarmsByMOCList.moc set to MRBTS/EQM/APEQM/RMOD
    ## ALARMSUPP.suppressAlarmsByMOCList.alarmSeverity set to MINOR (1)
    Trigger fault 4694
    Verify that fault 4694 is present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_block_RMOD_CABLINK}
    ## ALARMSUPP.suppressAlarmsByMOCList.moc add to list MRBTS/EQM/HWTOP/CABLINK
    Trigger fault 4694
    Verify that fault 4694 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_block_CABLINK2}
    ## ALARMSUPP.suppressAlarmsByMOCList.moc deleted
    ## ALARMSUPP.suppressAlarmsByMOCList.mocDN set to MRBTS-75013/EQM-1/HWTOP-1/CABLINK-2
    Trigger fault 4694
    Verify that fault 4694 is not present in alarm list
    Perform full commissionning to reconfigure ALARMSUPP object    ${TC5_block_CABLINK1}
    ## ALARMSUPP.suppressAlarmsByMOCList.mocDN set to MRBTS-75013/EQM-1/HWTOP-1/CABLINK-1
    Trigger fault 4694
    Verify that fault 4694 is present in alarm list
    Reset gNB and wait for cells to be onAir
    Verify that fault 4694 is not present in alarm list

    [Teardown]    TC5 Test Teardown
