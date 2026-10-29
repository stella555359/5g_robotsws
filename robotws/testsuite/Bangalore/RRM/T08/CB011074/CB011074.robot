*** Settings ***
Documentation
...  author: Sanjeev K Anand
...  contact: Sanjeev.kumar_anand@nokia.com
...  Description: Test Suite for CB011074
Test Setup  Test Setup
Test Teardown  Test Teardown
Resource  CB011074_keywords.robot
Resource  expected_alarms.robot
Resource  pva.robot
Force Tags  VRF_BLR1_T08_VRF_ORAN  VRF_BLR1

*** Variables ***
${pva_ip}  10.45.153.212
${vendor}  TOPYOUNG
${model}  TAS16T16-51-120-1N-DEJS
${VM_IP}  10.58.238.143
${VM_usn}  ute
${VM_pwd}  BT5l@bus3rl0g1n
${mplane_ip}  10.58.239.200
${MCG_IP}  10.45.150.205
${MCG_usn}  inbabtslabuser
${MCG_pwd}  BT5l@bus3rl0g1n
${MCG_domain}  NOKLAB
${emil}  C:\\Emil\\Emil.exe
${profile}  C:\\Emil\\profiles\\5G
${DURATION}  800s
${scf1_trunk}  /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/node1/SCF/SCF1.xml
${scf2_trunk}  /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/node1/SCF/SCF2.xml
${scf3_trunk}  /home/ute/testline_configuration/7_2_UTE5GCLOUD1042/node1/SCF/SCF3.xml
@{UE_alias}=  UE1
@{capabilities}=  Legacy_1
@{timeout}=  100
${dt_name_dl}=  iperf_dl_test_1
${dl_name}=  iperf_dl_test_1
@{deviation_dl}=  100
@{throughput_dl}=  1000
@{direction_dl}=  dl
@{CALL_type}  UDP
${k}  0
${name}
${vonr_dist}  MRBTS-1402/NRBTS-1402/NRCELL-0
${vonr_name}  Activation of mobility thresholds for VoNr UEs
${vonr_abbr}  actVoNrMobilityThresholds
${dt_name_v}  test_voice_call
${TC_AP_ON}  test_UE_AP_on
${TC_AP_Off}  test_UE_AP_off
${ABSTRACT_LIB_CONFIG}
${url}  https://10.41.209.23/api/ues?imei=860588055787355
${imei}  860588055787355
${value}  ${EMPTY}


*** Test Cases ***
CB011074_A_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_A_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile

CB011074_B_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_B_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile

CB011074_C_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_C_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    [Teardown]  Run Keywords  Test Teardown

CB011074_D_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_D_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    [Teardown]  Run Keywords  Test Teardown

CB011074_E_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_E_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile

CB011074_F_Functional_verification_of_feature_with_ICS_HO_after_A1_A2_event
    [Setup]  Run Keywords  Test Setup
    log to console  ---CB011074---
    Split_F_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    [Teardown]  Run Keywords  Test Teardown


*** Keywords ***

Split_A_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_A_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_A_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    Prepare UE
    log to console  --UE AP mode turning ON
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    SCF commissioning and check ONAIR  ${scf1_trunk}
    pva.PVA_Attenuator_Cell1  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n ---PVA Port 14 Set to 0 --- \n
    Create dcap session
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    pva.PVA_Attenuator_Cell3  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n ---PVA Port 14 Set to 0 --- \n
    Stop Data Transfer
    Log to Console  \n ---AP Mode On
    Prepare UE
    log to console  --UE AP mode turning ON
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog1
    Log to Console  \n --- EMIL log validation start for CNI
    EMIl log validation  DCAPlog1  ${msg1}|${msg71}|${msg2}|${msg72}|${msg3}|${msg4}|${msg6}

Split_B_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_B_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_B_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    pva.PVA_Attenuator_Cell1  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    pva.PVA_Attenuator_Cell4  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Stop Data Transfer
    Log to Console  \n ---AP Mode On
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog2
    Log to Console  \n --- EMIL log validation start
    EMIl log validation  DCAPlog2  ${msg1}|${msg2}|${msg3}|${msg4}|${msg8}|${msg9}|${msg10}

Split_C_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_C_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_C_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    pva.PVA_Attenuator_Cell2  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 13 Set to 0 --- \n
    CoamAdmin.reset_site  connection=oam
    Wait Until Keyword Succeeds  8min  10s  Check BTS is OnAir
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    pva.PVA_Attenuator_Cell5  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Stop Data Transfer
    Log to Console  \n ---AP Mode On
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog3
    Log to Console  \n --- EMIL log validation start
    EMIl log validation  DCAPlog3  ${msg1}|${msg11}|${msg12}|${msg13}|${msg2}

Split_D_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_D_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_D_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    pva.PVA_Attenuator_Cell1  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Prepare UE
    log to console  --UE AP mode turning ON
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    SCF commissioning and check ONAIR  ${scf2_trunk}
    Create dcap session
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    pva.PVA_Attenuator_Cell6  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Stop Data Transfer
    Log to Console  \n ---AP Mode On
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog4
    Log to Console  \n --- EMIL log validation start
    EMIl log validation  DCAPlog4  ${msg1}|${msg14}|${msg3}


Split_E_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_E_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_E_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    pva.PVA_Attenuator_Cell1  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Prepare UE
    log to console  --UE AP mode turning ON
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    SCF commissioning and check ONAIR  ${scf3_trunk}
    Create dcap session
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    Starting VONR Call
    pva.PVA_Attenuator_Cell3  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Stopping VONR Call
    Log to Console  \n ---AP Mode On
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog5
    Log to Console  \n --- EMIL log validation start
    EMIl log validation  DCAPlog5  ${msg1}|${msg2}|${msg15}|${msg16}|${msg17}|${msg6}|${msg18}

Split_F_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile
    ${out}  set variable
    ...  ${OUTPUT_DIR}/Test11074/Split_F_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile/
    set test variable  ${out}
    create directory  ${out}
    log to console  /n --Split_F_UE_attach_and_verification_of_NRMEASPR_MA_SA_profile--
    pva.PVA_Attenuator_Cell1  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Prepare UE
    log to console  --UE AP mode turning ON
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    CoamAdmin.perform_parameter_recommissioning  dist_name=${vonr_dist}
    ...  parameter=${vonr_abbr}  value=VoNrMobilityThresholds  operation=update
    ...  skip_parameter_relation_errors=False  connection=oam
    CoamAdmin.reset_site  connection=oam
    Wait Until Keyword Succeeds  8min  10s  Check BTS is OnAir
    Create dcap session
    Dcap Start Trace SA
    Start UE detach attach and start throughput
    sleep  10s
    Starting VONR Call
    pva.PVA_Attenuator_Cell7  ${pva_ip}  ${vendor}  ${model}
    Log to Console  \n --- PVA Port 14 Set to 0 --- \n
    Stopping VONR Call
    sleep  10s
    Log to Console  \n ---AP Mode On
    ta_ultracaller.start_voice_call  ue_alias=${UE_alias}  testcasename=${TC_AP_ON}
    Sleep  30
    Dcap Stop Trace and Get results SA  DCAPlog6
    Log to Console  \n --- EMIL log validation start
    EMIl log validation  DCAPlog6  ${msg1}|${msg2}|${msg15}|${msg20}|${msg16}|${msg19}|${msg20}|${msg18}|${msg6}

Set_export_yml
    [Arguments]  ${yml_filepath}
    ssh.Connect_to  ${VM_IP}  ${VM_usn}  ${VM_pwd}  alias=vm
    ssh.Execute  command=${yml_filepath}  connection=vm  timeout=30s
    ssh.Disconnect  connection=vm
