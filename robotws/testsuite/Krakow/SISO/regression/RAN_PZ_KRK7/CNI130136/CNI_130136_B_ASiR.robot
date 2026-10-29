*** Settings ***
Documentation
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)
...   maintainers:
...    - Jakub Kowalczyk
...   contact:
...    - Jakub Kowalczyk

Library    taf.nms.netact    WITH NAME    netact
Library    resources/netact_custom.py    WITH NAME    netact_custom
Library    resources/cni130136_kw.py    WITH NAME    cni130136_kw
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/sshrmod/Fault_verifier.py
Resource   resources/CNI130136_ASiR_B_kw.robot
Variables  resources/variables/delta.py
Resource     taf/rfrl/procedures/resources/robot/Reset.robot


Suite Setup       Custom Suite ASIR Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000   6327    4293
@{additional_allowed_alarms}=   4293
@{CUSTOM_ALARMS}=       ${CUSTOM_ALLOWED_ALARMS}
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
${TARGET_DIR}                   /home/ute/UUF_SW
${USE_REMOTE_NODE}=             ${False}
@{ADDITIONAL_ALARMS_DURING_PREP}    Setup of X2 connectivity to gNB failed


# __init__.py on testline_configuration must be up to date
${NETACT_NAME}    ${tl.nms.netact.https_main_info.addr}
${HOSTNAME}    ${tl.nms.netact.ssh_connections_info.addr}
${USERNAME}    ${tl.nms.netact.ssh_connections_info.username}
${PASSWORD}    ${tl.nms.netact.ssh_connections_info.password}

${NETACT_DN}       ${tl.netact_dn}
${NETACT_ASIR_DN}  ${tl.netact_asir_dn}
${WORKING_SET}     ${tl.working_set}
${REPORTS_PATH}    /d/oss/global/var/racops/reports
${EXPORT_PATH}     /d/oss/global/var/racops/export
${NETACT_EXPORTS}  ${OUTPUT DIR}/netact_exports

${REPORT_DELETE_LIST}    ${EMPTY}

${SMOD_ADDR}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SMOD_USER}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${SMOD_PASS}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SMOD_SSH}=     ${tl.gnbs[0].cu.oam_ssh_connection_details}
${RMOD_LIST}=    ${tl.gnbs[0].dus[0].airscale.core_units[0].rus}
${MRBTS_ID}=     ${tl.gnbs[0].global_bts_id}

${SW_VERSION_FOR_LEGACY_FID_CONTENT}=    SBTS26R3_ENB_9999_260304_000006

${FAST_TRIGGER}=    ${False}    # call robot -v FASTPASS:True to omit long fault triggering (1932, 1933)
${FAST_CLEAR}=    ${False}    # call robot -v FASTPASS:True to omit long fault and clearing (1932, 1933)
*** Test Cases ***
CNI_130136_A_B_B01_01_HW_information_in_additionalText3_of_alarms_reported_on_detected_and_commissioned_HW_in_BTS
    [Tags]    b01
    [Setup]    Run Keywords
    ...    Prepare Netact Connection
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=0    rmod_list=${RMOD_LIST}
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=1    rmod_list=${RMOD_LIST}
    ...    AND    Set SMOD SFP LANE Variables for Test Case
    ...    AND    Prepare KPI Alarm triggering for TC01
    ...    AND    Set FAN IDs for Test Case
    ...    AND    Prepare SSH connection to Container
    ...    AND    Prepare RMOD APHA with sn:${APHA_0_sn} environment
    ...    AND    Prepare RMOD APHA with sn:${APHA_1_sn} environment
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    1932    1933    4479    4569    4570    4571    4293
    ...    AND    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}



    Log    ${tl}
    Log Variables
    Align Netact additionalText3 Content Based on SW Version on gNB    ${SW_VERSION_FOR_LEGACY_FID_CONTENT}

    Trigger Faults on BTS TC01
    Trigger Faults on ASiR TC01
    Get alarms from BTS
    Get alarms from ASiR
    Builtin.Sleep    10
    Get alarms from Netact
    Get ASiR alarms from Netact
    Trigger and Get Netact Report Snapshot

    Verify Alarms on BTS TC01    rmod_type=APHA
    Verify Alarms on ASiR TC01    rmod_type=APHA
    Verify Alarms on Netact TC01    rmod_type=APHA
    Verify ASiR Alarms on Netact TC01    rmod_type=APHA

    Verify Alarms Netact Snapshot TC01    rmod_type=APHA

    [Teardown]    Run Keywords
    ...    TC01 Teardown
    ...    AND
    ...    Close Netact Connection
    ...    AND
    ...    SSHRMOD.Close Connection
    ...    AND    Test Teardown with Watching Alarms


CNI_130136_A_B_B02_03_HW_info_in_additionalText3_of_alarms_rep_on_commissioned_but_not_detected_HW_connected_to_BTS_before_and_SN_is_known_to_BTS
    [Tags]    b03
    [Setup]    Run Keywords
    ...    Prepare Netact Connection
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=0    rmod_list=${RMOD_LIST}
    ...    AND    Set HUBMOD General Info for TC03
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    10    4293
    ...    AND    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Trigger FID 10 on ${RMOD_0_CONF_DN} by lane locking.
    Get alarms from BTS
    Get alarms from ASiR
    Builtin.Sleep    10
    Get alarms from Netact
    Get ASiR alarms from Netact

    Verify Alarms on BTS TC03
    Verify Alarms on ASiR TC03
    Verify Alarms on Netact TC03
    Verify Asir Alarms on Netact TC03

    [Teardown]    Run Keywords
    ...    Clear FID 10 on ${RMOD_0_CONF_DN} by lane unlocking.
    ...    AND
    ...    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    ...    AND
    ...    Close Netact Connection
    ...    AND    Test Teardown with Watching Alarms
