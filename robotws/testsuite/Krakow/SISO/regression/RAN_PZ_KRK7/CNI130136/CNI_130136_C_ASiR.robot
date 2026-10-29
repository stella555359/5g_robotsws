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
Resource   resources/CNI130136_ASiR_C_kw.robot
Variables  resources/variables/delta.py
Resource     taf/rfrl/procedures/resources/robot/Reset.robot


Suite Setup       Custom Suite C ASIR Setup
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


${FAST_TRIGGER}=    ${False}    # call robot -v FASTPASS:True to omit long fault triggering (1932, 1933)
${FAST_CLEAR}=    ${False}    # call robot -v FASTPASS:True to omit long fault and clearing (1932, 1933)
${ASIRMOD_ID_CHANGED}=    ${False}

@{CUSTOM_ALLOWED}=     4479    4293
${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}
&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED}

@{NODES}                            ${NODE1}

*** Test Cases ***
CNI_130136_C_B03_11_New_alarms_ident_in_MantaRay_during_upgrade_from_rel_before_CNI_no_alarms_reported_before_SW_upgrade
    [Tags]    c11
    [Setup]    Run Keywords
    ...    Prepare Netact Connection
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=0    rmod_list=${RMOD_LIST}
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=1    rmod_list=${RMOD_LIST}

    Trigger Initial Faults, Get Netact Snapshot and Upgrade SW if needed
    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    4479    4293    4592
    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Wait For Site To Be Onair  timeout=300
    gnb_asir.wait_for_asir_to_be_onair
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Trigger Fault 4479 on BTS by blocking ASiR Antenna    ${APHA_0_sn}

    Get alarms from BTS
    Builtin.Sleep    10
    Get alarms from Netact
    ${new_snapshot}=    Trigger and Get Netact Report Snapshot    report_ident=new_build_TC09

    ${file_path}=    Netact Get Snapshot Compare    ${old_snapshot[2]}    ${new_snapshot[2]}
                                                                                                                         # ... For partial execution
    Verify Alarms Netact Compare TC11    ${file_path}

    [Teardown]    Run Keywords
    ...    TC11 Teardown    ${APHA_0_sn}
    ...    AND
    ...    Close Netact Connection
    ...    AND    Test Teardown with Watching Alarms

CNI_130136_C_B03_09_New_alarms_ident_in_MantaRay_during_upgrade_from_rel_before_CNI_re-triggered_on_the_same_HW_but_different_conf_path_HW
    [Tags]    c09
    [Setup]    Run Keywords
    ...    Prepare Netact Connection
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=0    rmod_list=${RMOD_LIST}
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=1    rmod_list=${RMOD_LIST}

    Trigger Initial Faults, Get Netact Snapshot and Upgrade SW if needed
    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    1900    4293    4592
    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Change ASIRMOD ID    asir_sn=${APHA_0_sn}    asir_conf_dn=${RMOD_0_CONF_DN}    new_id=10
    Set Suite Variable    ${ASIRMOD_ID_CHANGED}    ${True}

    Wait For Site To Be Onair  timeout=300
    gnb_asir.wait_for_asir_to_be_onair
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Verify Dist Names Change after ASIRMOD ID Change and set New RMOD Variables for Test Case TC09

    Get alarms from BTS
    Builtin.Sleep    10
    Get alarms from Netact
    ${new_snapshot}=    Trigger and Get Netact Report Snapshot    report_ident=new_build_TC09

    ${file_path}=    Netact Get Snapshot Compare    ${old_snapshot[2]}    ${new_snapshot[2]}
    Verify Alarms Netact Compare TC09    ${file_path}




    [Teardown]    Run Keywords
    ...    TC09 Teardown    ${APHA_0_sn}
    ...    AND
    ...    Close Netact Connection
    ...    AND    Test Teardown with Watching Alarms


CNI_130136_C_B03_10_New_alarms_ident_in_MantaRay_during_upgrade_from_rel_before_CNI_re-triggered_on_different_HW_but_the_same_or_diff_conf_path_HW
    [Tags]    c10
    [Setup]    Run Keywords
    ...    Prepare Netact Connection
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=1    rmod_list=${RMOD_LIST}
    ...    AND    Set RMOD Variables for Test Case    rmod_type=APHA    rmod_id=2    rmod_list=${RMOD_LIST}

    Trigger Initial Faults, Get Netact Snapshot and Upgrade SW if needed
    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    10    1900    4293    4592
    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Exchange ASIRMODs    asir_sn1=${APHA_1_sn}    asir_conf_dn1=${RMOD_1_CONF_DN}
                  ...    asir_sn2=${APHA_2_sn}    asir_conf_dn2=${RMOD_2_CONF_DN}
    Set Suite Variable    ${ASIRMOD_ID_CHANGED}    ${True}

    Wait For Site To Be Onair  timeout=300
    gnb_asir.wait_for_asir_to_be_onair
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Verify Dist Names Change after ASIRMOD Exchange and set New RMOD Variables for Test Case TC10

    Trigger FID 10 on ${RMOD_2_CONF_DN} by lane locking.
    Get alarms from BTS
    Builtin.Sleep    20
    Get alarms from Netact
    ${new_snapshot}=    Trigger and Get Netact Report Snapshot    report_ident=new_build_TC10

    ${file_path}=    Netact Get Snapshot Compare    ${old_snapshot[2]}    ${new_snapshot[2]}
                                                                                                                         # ... For partial execution
    Verify Alarms Netact Compare TC10    ${file_path}

    [Teardown]    Run Keywords
    ...    TC10 Teardown
    ...    AND
    ...    Close Netact Connection
    ...    AND    Test Teardown with Watching Alarms
