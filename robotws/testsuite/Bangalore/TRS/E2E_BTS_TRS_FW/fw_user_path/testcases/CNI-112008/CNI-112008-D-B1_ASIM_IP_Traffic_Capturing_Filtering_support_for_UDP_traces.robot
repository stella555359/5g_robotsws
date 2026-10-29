*** Settings ***

Documentation
...	    [Author]	        	    "Kavya M"
...     [Author_Team]               "MN RAN RD VRF BLR2 2"
...     [Email]                     "Kavya M"
... 	[Feature_ID]            	"CNI-112008"
...     [Feature_Name]              "Filtering support for IP traffic capture"
...     [QC_Path]                   "QC_Path in test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
... 	[Description]               "R&D parameter enableTrafficCaptureFiltering has 4 values "
... 	[Hw Supported]    	        "ASIA(supported with limitations)/ASIB/ASIL/ASOE/ASIM/ASOF"

Resource         ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Teardown Oamops

#Suite Setup         Setup Oamops
#Suite Teardown          Teardown oamops
***Variables***

${Traffic_Alarm_id}    61641
${traffic_filter_file_name}      /home/ute/fw_user_path/testcases/CNI-112008/resources/traffic_filters.json
${build}        SBTS00_ENB_9999_250925_000006_release_BTSSM_downloadable_A54.zip


*** Test Cases ***
[1][1.1] CNI-112008-D-B1_ASIM_IP Traffic Capturing Filtering support for UDP traces


    ssh to ipv4 Mplane
    Set value to REMOVE TRAFFIC FILTER
    Start Capture and Verify uplane test
    Perform BTS upgrade and rollback
    Start Capture and Verify uplane test after rollback

*** Keywords ***
Set value to REMOVE TRAFFIC FILTER
      Set Rad Debug Parameters  name=enableTrafficCaptureFiltering      value=0     domain=ERadSwDomain_OamTas      persistency=NotPersistent

Start Capture and Verify uplane test
       Traffic Capture Start           capture_device=vm_eth3_interface      mode=file   uplane_capturing=True    alias=default
       sleep   30
       ${pcap_file}=    Traffic Capture Stop    mode=file   timeout=120
       ssh to ipv4 Mplane
       Analyse Pcap      pcap_filename=${pcap_file}      analysis=verify_uplane_test     filter_file_name=${traffic_filter_file_name}
       [TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop    alias=default

Start Capture and Verify uplane test after rollback
       Traffic Capture Start           capture_device=vm_eth3_interface      mode=file   uplane_capturing=True    alias=new
       sleep   30
       ${pcap_file}=    Traffic Capture Stop    mode=file   timeout=120     alias=new
       ssh to ipv4 Mplane
       Analyse Pcap      pcap_filename=${pcap_file}      analysis=verify_uplane_test     filter_file_name=${traffic_filter_file_name}
       [TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop    alias=new

Perform BTS upgrade and rollback
#     Get the upgrade BTS latest software
#[Arguments]    ${profile}
    ${Build_name}=       Run     ls -lrt /home/ute/${build} | awk 'END{print}' | awk '{print $9}'
    Perform Software Download And Update      package=/home/ute/${build}        activate_sw=true      update_timeout=1200
     Sleep    100
    Rollback BTS Software

Rollback BTS Software
    Rollback Software     dut=bts     verify_bts_status=False     is_config_reset=True     timeout=600     alias=default
    Sleep    360

ssh to ipv4 Mplane

     Setup Remote Access    remote_device=bts
     Teardown Remote Access

