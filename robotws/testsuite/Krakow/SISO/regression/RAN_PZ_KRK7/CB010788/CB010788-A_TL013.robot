*** Settings ***
Documentation
...   author:
...    - Mateusz Matusik (mateusz.matusik@nokia.com)

Resource   ./resources/CB010788_keywords.robot

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${SOURCE_SW}           ${None}
${TARGET_SW}           ${None}
@{CUSTOMERS_LIST}      ${None}
@{CUSTOM_ALARMS}       61648    7115    4420    4123    4125    8150    4694    6450    4479

${MRBTS_ID}            85135
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
${scfc_dir}=                             commissionings/Krakow/7_7_T01PY135/SBTS00
${base_scfc}=                            ${scfc_dir}/GNB0_SCF.xml
${delete_notes}=                         ./config/json_delta/TC2_delete_notes.json
${TC3_disable_actTransceiverAlarmMonitoring}=    ./config/json_delta/TC3_disable_actTransceiverAlarmMonitoring.json
${TC3_enable_actTransceiverAlarmMonitoring}=     ./config/json_delta/TC3_enable_actTransceiverAlarmMonitoring.json
${TC3_block_4699_4700_4701}=             ./config/json_delta/TC3_block_4699_4700_4701.json
${TC3_7115_alarm_supp}=                  ./config/json_delta/TC2_7115_alarm_supp.json
${TC3_delete_suppressedAlarmList}=       ./config/json_delta/TC3_delete_suppressedAlarmList.json
${TC3_allow_4698}=                       ./config/json_delta/TC3_allow_4698.json

*** Test Cases ***
CB010788_A_3 Alarm suppression for SFP related faults
    [Tags]    TC3    CRT    mm    TL135    SBTS00
    [Setup]    TC3 Test Setup

    Verify that faults 4698,4699,4700,4701 are not present in alarm list
    Reconfigure ALARMSUPP object    ${TC3_block_4699_4700_4701}
    ## ALARMSUPP.actAlarmsSuppression set to suppressAlarms (2)
    ## ALARMSUPP.suppressedFaultList.faultid set to 4699,4700,4701
    ## ALARMSUPP.suppressAlarmsByMOCList.alarmSeverity set to MINOR (1)
    Setup connection to RFMON interface    ${AHFII_credentials}
    Trigger MAJOR fault 4700 with FRMON interface
    Verify that MAJOR fault 4700 is present in alarm list
    Disable MAJOR fault 4700 with FRMON interface
    Trigger MINOR fault 4699 with FRMON interface
    Verify that MINOR fault 4699 is not present in alarm list
    Disable MINOR fault 4699 with FRMON interface
    Trigger MINOR fault 4698 with FRMON interface
    Verify that MINOR fault 4698 is present in alarm list
    Reconfigure ALARMSUPP object    ${TC3_7115_alarm_supp}
    ## ALARMSUPP.actAlarmsSuppression set to suppressAlarms (2)
    ## ALARMSUPP.suppressedAlarmList.alarmId set to 7115
    ## ALARMSUPP.suppressedAlarmList.alarmSeverity set to MINOR (1)
    Verify that MINOR fault 4698 is not present in alarm list
    Reconfigure ALARMSUPP object    ${TC3_delete_suppressedAlarmList}
    ## ALARMSUPP.suppressedAlarmList is deleted
    Verify that MINOR fault 4698 is present in alarm list
    Delete NOTE connected to CNI-127210
    ## MRBTS/MNL/NOTES/NOTE.attribute.attribName is not set
    ## MRBTS/MNL/NOTES/NOTE.attribute.attribValue is not set
    Verify that MINOR fault 4698 is present in alarm list
    Reconfigure ALARMSUPP object    ${TC3_allow_4698}
    ## ALARMSUPP.actAlarmsSuppression set to allowAlarms (1)
    ## ALARMSUPP.allowedFaultList.faultid set to 4698
    ## ALARMSUPP allowedFaultList.alarmSeverity: MINOR_AND_WARNING (2)
    Verify that MINOR fault 4698 is present in alarm list
    Set FEATCADM.actTransceiverAlarmMonitoring to Off
    Verify that MINOR fault 4698 is not present in alarm list

    [Teardown]    TC3 Test Teardown
