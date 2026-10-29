*** Settings ***
Documentation
    ...     [Procedure]             "TRS_5GC000986_Verification_of_BFD_Multihop"
    ...     [Date]                  "25-05-20"
    ...     [Author]                "Madhu Chinthakindi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIPR","BFD","IPSEC"
    ...     [Feature_ID]            "5GC000986"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-9008"


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


Variables         ta_e2e_bts_trs_fw
Resource          ${CURDIR}/../resources/Common_BFD.robot
Resource          taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Test Cases ***
TRS_5GC000986_Verification_of_BFD_Multihop
	[Documentation]		This test case verify Multihop BFD session 
    Perform Commissioning    scf_file=${basic_scf}    verify_bts_status=False     timeout=900    alias=default
    Perform Recommissioning      type=delta     delta_file=${bfd_session_jira}   skip_parameter_relation_errors=${True}    timeout=300
    Start Ip traffic capture point A file mode      oam_device
    Verify Alarm        expected_alarms=${expected_alarms}
    Read BFD Details
    Stop Ip traffic capture in file mode
    Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_udpsrcport      filter_file_name=${traffic_filer_file_name} 
    Perform Recommissioning      type=delta     delta_file=${bfd_delta_jira}     timeout=300
	Wait Until Keyword Succeeds    30 min    30       Verify Alarm     faultid=${fault_id}      should_exist=${True}

 

*** Keywords ***
Read BFD Details
    GetBFDCount
    Get_BFD_Src_IPs

Start Ip traffic capture point A file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}    mode=file     measurement_point=NE_Terminated   uplane_capturing=${uplane_val}
    ...    timeout=120    alias=${alias}
    Sleep    10

 

Start Ip traffic capture point B file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}   mode=file  measurement_point=Transport_Interface   uplane_capturing=${uplane_val}
    ...    timeout=120    alias=${alias}
    Sleep    10

 

Stop Ip traffic capture in file mode
    [Arguments]        ${alias}=default
    ${pcap_file}=  Traffic Capture Stop   mode=file   alias=${alias}  timeout=120
    Set Suite Variable     ${pcap_file}