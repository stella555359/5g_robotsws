*** Settings ***

*** Variables ***
# ${bts_host_ip}=   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${bts_host_port}=   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${bts_host_ip}=   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
@{UE_alias} =   UE_3   # UE_1 = Skippable ue & UE_2= Non skippable
@{capabilities} =   Legacy_3
${timeout} =   300
${bts_id} =   11008
${SCF_PATH} =    testsuite/Bangalore/RRM/5GST_BLR/SG02/5G_CRT/SCF
${TEST_PATH} =   testsuite/Bangalore/RRM/5GST_BLR/SG02/5G_CRT
${24R1_scf}=  BTS_CLOUD_5G_CLASSICAL_1ASIB_1ABIO_1ABIN_1AZHA_SBTS00.xml
${scf_commission} =   /home/ute/testline_configuration/7_2_UTE5GCLOUD1008/node1/${24R1_scf}
# ${scf_commission} =   ${SCF_PATH}/common_scf_testing.xml
${BTSLOG} =   btslog
@{PARAMETER_KEY_FOR_FEATURE} =     actTcpBoostPug    actPowerSavingAvoidance 
@{Feature_Values}=  1  0    disabled  allUes  onlySkippableGrantCapableUes
@{Protocol_Type} =  FTP  
@{DIRECTION} =   dl
${ABSTRACT_LIB_CONFIG} =   ${TEST_PATH}/UE/ta_ue_config.yaml
&{BTS_Details} =   bts_host=192.168.255.129
...  bts_port=443   username=Nemuadmin    password=nemuuser
...  use_ssl=True    update_interval=5000
...  admin_api_log_dir= ${TEST_PATH}    name=default
...  bundle_path=None    release= SBTS00
...  timeout=30
&{Dcap_Server_Details} =  host=10.41.209.120  port=443  secure=True  Alias=GNB_1
...  username=dcapuser  password=dcapadmin!

&{Dcap_User_Details} =  host=10.58.239.183  port=443  username=Nemuadmin  password=nemuuser
@{Only_Gnb_custom_profile} =  cp_5g  L2Ps_Component  L2Lo_Component  L2HiRlc_Component  L2HiPdcp_Component   
@{Bts_custom_profile}=   immediateSnapshot  scf  pmFiles  ipCapture
${OUT_SUITE_LOGS_DIR_PATH} =  ${TEMP_DIR}/dcaplog 
@{Dict_MOC_PATH} =  MRBTS-11008/NRBTS-11008/NRCELL-4  
@{VOICE_CALL} =   Normal_call  911_EC_Call  
@{Validation_Check} =   TCP Boost Data Burst detected. TCP Boost PUG state Activated
...  VoNr Proactive Grant elegibility check fail srPeriodity
...  fiveQi: 5
...  fiveQi: 1
...  CS1 Entry for TCP PUG
@{Counters_list} =   M55308C00038  M55308C00039  M55308C00040  M55308C00042	
${BTSLOG_Path_for_validation} =   ${TEST_PATH}/btslog
@{counters_CB010638} =  M55601C00012  M55601C00013  M55601C00014  M55601C00015
@{counters_CB010544} =   M55351C00001  M55351C00002  M55351C01001
@{Validate_bts_status} =  OnAir  Commission   Configured
${power_saving_dict}=   "MRBTS-11008/NRBTS-11008/NRPGRP-0"
${Dict_PA_Feature_Enable_}=  "MRBTS-11008/NRBTS-11008" 
${cellid_4}=   4

${notenergysaving_state}=  EnergySavingState:notEnergySaving
${verify_priority_drb}=    drbRacType: priorityAccess
${verify_lbps_avoidance}=   won't be switched-off (ongoing PWS/EC)
${energysaving}=     energySavingState =energySaving
