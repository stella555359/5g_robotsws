*** Settings ***
Documentation
...   author: Ajay K Sofat
...   contact: ajay.k.sofat@nokia.com
...   Description: Test Suite for 5GC000749
Test Setup      Admin Setup
Test Teardown   Admin Teardown
Resource    5GC000749_Keywords.robot
Resource    expected_alarms.robot


Force Tags      QCD_MN_RAN    QCP_RAN_ST

*** Variables ***
${ABSTRACT_LIB_CONFIG}   
${VM_IP}    10.58.238.143
${VM_usn}    ute
${VM_pwd}    ute
${mplane_ip}    10.58.239.200
${MCG_IP}    10.45.150.205
${MCG_usn}    inbabtslabuser
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${emil}    C:\\Emil\\Emil.exe
${profile}    C:\\Emil\\profiles\\5G
${DURATION}    800s
${scf_VoNR_disabled}	  testsuite/Bangalore/RRM/5GST_BLR/SG09/5GC000749/resources/scf/5GC000749_Feature_Disabled.xml
@{UE_alias}=    UE1
${dt_name_v}    VoNR_Call_CB012113
@{capabilities}=    Legacy_1
@{timeout}=    100
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    1000
@{direction_dl}=      dl
${k}    0
${name}
${j}    0
${i}    0
${E}    0
@{adb_cmd_stop_call}    adb -s bc05f4e7 shell input keyevent 6
@{adb_cmd_voice_call}    adb -s bc05f4e7 shell am start -a android.intent.action.CALL -d tel:+123456
${DCAP_host}    10.58.238.143            # DCAP Lite server IP\
${port}    9443                          # Port value for DCAP connection
${secure}    True                        # Secure value for DCAP connection
${rd_version}    dcapv3                  # DCAP version
${uepc_Log_path}    C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}    C:\\Emil                                           # Emil path in UE PC machine
${emil_profile_path}    ${emil_path}\\profiles\\5G                      # Emil profile path in UE PC machine
${Default_DCAP_duration}    12                                                # DCAP log duration
${dcap_log_timeout}    1200                                                    # Timeout for DCAP log collection
&{BTS_INFO}    host=${mplane_ip}	port=443     username=Nemuadmin    password=nemuuser  
@{gnb_custom_filters}    cp_5g         			# gnb custom filters for DCAP
@{bts_custom_filter}    immediateSnapshot    scf    ipCapture                      # BTS custom filters for DCAP
@{collection_timing}    Immediate       TraceEnd                                # Snapshot collect option for DCAP
${path}    C:\\Users\\lesn\\Desktop\\       #in linux   /home/home/log_path
${msg0}    InitialULRRCMessageTransfer:-22970370
${msg1}    rrcReestablishmentRequest:-0
${msg2}    InitialUEMessage:-REGISTRATION REQUEST
${msg3}    InitialContextSetupRequest:-fiveQI 1,fiveQI 5,REGISTRATION ACCEPT,RedirectionVoiceFallback : possible
${msg5}    InitialContextSetupResponse:-pDUSessionResourceSetupUnsuccessfulTransfer,cause radioNetwork :
${msg7}    rrcRelease:-redirectedCarrierInfo eutra,eutraFrequency 1575
${msg4}    InitialContextSetupFailure:-pDUSessionResourceSetupUnsuccessfulTransfer,cause radioNetwork : 
${msg6}    dlInformationTransfer:-REGISTRATION ACCEPT
${msg8}    UEContextSetupRequest:-17317906
${msg9}    PDUSessionResourceModifyRequest:-fiveQI 1
${msg10}    PDUSessionResourceModifyResponse:-ims-voice-eps-fallback-or-rat-fallback-triggered
${msg11}    PDUSessionResourceModifyResponse:-not-supported-5QI-value
${c1}    0
${c2}    0
${c3}    0
${c4}    0
${pva_ip}    10.45.153.203
${QC_DOMAIN}       		  MN_RAN
${QC_PROJECT}       	  RAN_ST
${QC_ID_TRUNK}            657191  


*** Test Cases ***
5GC000749_Verification_With_Feature_Disabled_And_Enabled_With_VoNR_Disable
    Log To Console    \n --- Setting up preconditions for script execution --- \n
    Precondition_5GC000749_VoNR_Disable
    5GC000749_Feature_Disabled_And_PDUModificationRequest_5QI1    DCAPLog1
    EMIL_Log_Validation    ${out}    ${msg9}|${msg11}    DCAPLog1
    EMIL_Log_Validation_msg_notpresent    ${out}    ${msg7}    DCAPLog1
    Validating_counters_for_feature_disable	
    Enable Feature
    5GC000749_Feature_Enabled_And_PDUModificationRequest_5QI1    DCAPLog2
    EMIL_Log_Validation    ${out}    ${msg9}|${msg10}|${msg7}    DCAPLog2
    Validating_counters_for_feature_enable    
    Log To Console    \n --- 5GC000749 feature regression verified successfully --- \n
	[Tags]    CRT    SBTS00    QC_657191    Mark
