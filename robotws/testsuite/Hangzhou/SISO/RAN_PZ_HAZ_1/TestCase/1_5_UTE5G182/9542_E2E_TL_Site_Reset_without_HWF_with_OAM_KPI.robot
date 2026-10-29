*** Settings ***
Documentation    Suite description
...    Author:    Nie Sue

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/l3call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/bts_common_interface.robot
Variables   ./env.py
Library    taf/rfrl/csv4all/CSV4AllTestCases.py

Force Tags    CLOUD_5G_CALSSICAL_SA_ASOF_3xAHWWF    CA_VRF_HAZ1

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M}    HW_ID=AWHHF   site_mode=5G    ONAIR_TIME=15 min
...    GG=89:90;100:101;111:112;122:123;133:134;144:145
${LABEL}                      CLOUD_5G_CALSSICAL_SA_ASOF_3xAHWWF
${HOSTNAME}                   1_5_UTE5G182
${DISABLE_SYSLOG_CHECK}       ${False}
@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
${REMOTE_VM_IP}               ${None}
${REMOTE_MPLANE}              ${None}
${USE_REMOTE_NODE}            ${False}
@{CUSTOM_ALARMS}              @{EMPTY}
@{CRITICAL_FAULTS}            @{EMPTY}
${SHOULD_BE_REPORTED}         ${False}
${REPORT_COMMENT}=            ${None}
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ
${RP_ORGANIZATION}            VRF_HAZ_T08
${EMAIL_RECIPIENTS}           None
${INITIAL_SW}                 None
${TARGET_SW}                  SBTS00_ENB_9999_251118_000007
${ITERATIONS}                 1
&{NODE1}                      testline_object=${tl.gnbs[0]}
...                           source_sw=${INITIAL_SW}
...                           target_sw=${TARGET_SW}
@{NODES}                      ${NODE1}
${customers_list}             Generic

#upgrade
${5G_SOURCE_SW}=                SBTS00_ENB_9999_240409_000004
${5G_TARGET_SW}=                SBTS00_ENB_9999_251118_000007
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS00_ENB_9999_240409_000004
${4G_TARGET_SW}=                SBTS00_ENB_9999_251118_000007
${4G_TARGET_SW_PATH}=           ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${REMOTE_NODE_UPDATE}=      @{EMPTY}
${DOWNLOAD_PATH}=     /home/ute
# Delta Commissioning Parameters
${TEST_ITERATION}=              1
${SHOULD_BE_REPORT}=          ${True}
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    PPS reference missing
...                                   GPS receiver alarm: position questionable
...                                   GPS receiver alarm: not tracking satellites
...                                   GNSS autonomous reset as recovery action
*** Test Cases ***

Onair_Switch Configuration
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB009542_ASOF_3AWHHF_9cell_NR50M_LTE20M
    Verify All Cells OnAir
    Run keyword And Ignore Error    OperatingSystem.Remove File    /home/ute/.netrc
    [Teardown]    Testcase Basic Postcondition

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_58784    QCD_MN_RAN   QCP_RAN_VRF
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=5
#    ...          custom_alarms=${ADDITIONAL_ADMIN_ALLOWED_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORT}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=58784
#    ...          qc_project=${QC_PROJECT}
#    [Teardown]    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5 min    10 sec
#    ...    Get Scout SCF Internal Id    1_5_UTE5G182    ${False}

E2E_TL_ACTIVATION_RESET_TEST
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST   ${NODES}  ${NODE1}   ${ITERATIONS}    customers_list=${customers_list}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=190536
    ...          qc_project=${QC_PROJECT}
