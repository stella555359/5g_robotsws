*** Settings ***
Documentation
  ...  UUF4ALL Remote Keywords
  ...
  ...  Author Szymon Kramczynski
  ...  szymon.kramczynski@nokia.com
  ...
  ...  Remote Keywords for UUF4ALL Upgrade/Reset in loop
  ...  for single/multi node tesltines
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Resource  keywords.robot


Suite Setup  Perform Suite Setup
*** Variables ***
${EXECUTION}=  RUN


*** Test Cases ***
Check Cells
    [Timeout]  10m
    ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=onair_check
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Check Cells  admin_alias=onair_check
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=onair_check

Check Faults
    [Timeout]  10m
     ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=check_faults
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    run keyword if  '${TEST_PHASE}'=='before_upgrade'  Check Faults  ${TL_CONFIG['${THIS_NODE}']['ALLOWED_FAULTS_INITIAL']}  alias=check_faults
    ...  ELSE   Check Faults  ${TL_CONFIG['${THIS_NODE}']['ALLOWED_FAULTS']}  alias=check_faults
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=check_faults


Admin Upgrade
    [Timeout]  120m
    ${setup_status}  ${build}=  Wait Until Keyword Succeeds  4x  1m  Setup admin And Get Active Software
    ...  alias=admin_upgrade
     ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Wait Until Keyword Succeeds  10x  1m  Wait For Radio Modules  admin_alias=admin_upgrade  rm_count=${TL_CONFIG['${THIS_NODE}']['RMOD_COUNT']}
    Admin Upgrade  candidate=${CANDIDATE}  admin_alias=admin_upgrade  wait_for_unavailable=${WAIT_FOR_UNAVAILABLE}
    Wait Until Keyword Succeeds  3x  1s  Wait for software change  expected_active_sw=${CANDIDATE}  expected_passive_sw=${ACTIVE_SW}
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=admin_upgrade

Rollback
    [Timeout]  60m
    ${setup_status}  ${build}=  Wait Until Keyword Succeeds  4x  1m  Setup admin And Get Active Software
    ...  alias=rollback
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Wait Until Keyword Succeeds  10x  1m  Wait For Radio Modules  admin_alias=rollback  rm_count=${TL_CONFIG['${THIS_NODE}']['RMOD_COUNT']}
    Rollback  admin_alias=rollback
    Wait Until Keyword Succeeds  20m  30s  Address Is Pingable  ${ENB_LMP_IP}
    Wait Until Keyword Succeeds  3x  1s  Wait for software change  expected_active_sw=${PASSIVE_SW}  expected_passive_sw=${ACTIVE_SW}
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=rollback

Rollback If Needed
    [Timeout]  120m
    ${setup_status}  ${build}=  Wait Until Keyword Succeeds  4x  1m  Setup admin And Get Active Software
    ...  alias=rollback_if_needed
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    ${active_prefix}     ${active_sw_build_number}=     Split To Prefix and Suffix  ${build}
    ${candidate_prefix}  ${candidate_sw_build_number}=  Split To Prefix and Suffix  ${CANDIDATE}
    ${status}=  Evaluate  '${active_sw_build_number}'=='${candidate_sw_build_number}'

    run keyword if  ${status}  Wait Until Keyword Succeeds  10x  1m
    ...  Wait For Radio Modules
        ...  admin_alias=rollback_if_needed
        ...  rm_count=${TL_CONFIG['${THIS_NODE}']['RMOD_COUNT']}
    run keyword if  ${status}  Rollback  admin_alias=rollback_if_needed
    run keyword if  ${status}  Wait Until Keyword Succeeds  20m  30s
    ...  Address Is Pingable  ${ENB_LMP_IP}
    run keyword if  ${status}  Wait Until Keyword Succeeds  3x  1s
    ...  Wait for software change
        ...  expected_active_sw=${PASSIVE_SW}
        ...  expected_passive_sw=${ACTIVE_SW}
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=rollback_if_needed

Cancel 6450 If Needed
    ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=cancel_6450
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Cancel 6450 If Needed
    ...  fault_list=${TL_CONFIG['${THIS_NODE}']['ALLOWED_FAULTS_INITIAL']}
    ...  admin_alias=cancel_6450
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=cancel_6450


Add Swconfig Flags
    [Timeout]  15m
    ${setup_status}  ${build}=  Wait Until Keyword Succeeds  4x  1m  Setup admin And Get Active Software
    ...  alias=add_swconfig
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}

    Add Swconfig Flags
    ...  flag_list=${TL_CONFIG['${THIS_NODE}']['SWCONFIG_FLAGS']}
    ...  admin_alias=add_swconfig
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    ...  no_hwf=${NO_HWF}
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=add_swconfig


Get SCF From eNB
    [Timeout]  15m
    ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=get_scf
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Get SCF From eNB  scope=${SCOPE}  name=${NAME}  alias=get_scf
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=get_scf

Download Blackbox File
    [Timeout]  10m
    Download Blackbox File  file_name=${FILE_NAME}  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}

Check Blackbox
    [Timeout]  10m
    Check Blackbox  before_upgrade_filename=${NAME_BEFORE}  after_upgrade_filename=${NAME_AFTER}

Check ALD
    [Timeout]  10m
     ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=check_ald
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Check ALD  admin_alias=check_ald
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=check_ald

Check Validation
    [Timeout]  10m
     ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=check_validation
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Check Validation  admin_alias=check_validation
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=check_validation

#setup ute_syslog
#    [Timeout]  10m
#    setup ute_syslog  syslog_backup_dir=${SYSLOG_BACKUP_DIR}  syslog_alias=${SYSLOG_ALIAS}  log_name=${LOG_NAME}

#Collect ute_syslog
#    [Timeout]  10m
#    Collect ute_syslog  destination=${DESTINATION}  syslog_alias=${SYSLOG_ALIAS}

Get Snapshot and IM Snapshot
    [Timeout]  10m
     ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=collect_snapshot
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Get Snapshot and IM Snapshot  test_vm_ip=${TEST_VM_IP}  admin_alias=collect_snapshot
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=collect_snapshot

Address Is Pingable
    [Timeout]  2m
    Address Is Pingable  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}


Download Build
    [Timeout]  90m
    Download Build  build=${CANDIDATE}  path=${SW_CACHE}  soft_build=${True}

Reset Testline
    [Timeout]  30m
     ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=reset_testline
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Reset Testline  admin_alias=reset_testline  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=reset_testline

Downgrade Uboot
    Wait Until Keyword Succeeds  1m  30s  Address Is Pingable  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
#    Wait Until Keyword Succeeds  20m  30s  Address Is Pingable  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    ${setup_status}=  run keyword and return status  Wait Until Keyword Succeeds  4x  1m  Setup Admin For Alias
    ...  alias=uboot_downgrade
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
    Wait Until Keyword Succeeds  20x  1m  Check BBU Status  admin_alias=uboot_downgrade

    ${reset_needed}=  Downgrade Uboot  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}

#    run keyword if  ${reset_needed}  Reset Testline
#    ...  admin_alias=uboot_downgrade
#    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}
#    ...  coverage=Bts
    run keyword if  ${reset_needed}
    ...  No Admin Reboot
        ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}

    [Teardown]  run keyword if  ${setup_status}  admin.teardown_admin  connection=uboot_downgrade

No Admin Reboot
    No Admin Reboot
    ...  lmp_ip=${TL_CONFIG['${THIS_NODE}']['LMP_IP']}




*** Keywords ***
Perform Suite Setup
#    Get Hostname
    Map Variables  tl_config_path_and_name=${TL_CONFIG_PATH}
