*** Settings ***
Documentation
    ...     [Procedure]             "TLS"
    ...     [Date]                  "20-05-21"
    ...     [Author]                "Lavanya V"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "5G in SBTS"
    ...     [Feature_ID]            "CB006758"
    ...     [Validation_status]     "Not Validated"
    ...     [Validated_TestLine]    "SBTS"

variables       ta_e2e_bts_trs_fw
Resource    ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***

[1][1.0] TRS_5GC0001050_TLS_EnableTLSv1.1 downgrade
   Run Keyword And Ignore Error    Perform Commissioning       scf_file=${rp002672_sctp_scf}   timeout=2100
    Sleep   90
    Traffic Capture Start           capture_device=bts
    Perform Recommissioning     type=param  param_path=${Enable_1.2}        value=true    operation=update
    Perform Recommissioning     type=param  param_path=${Enable_1.3}        value=true    operation=update
    Setup Oamops    bts_host=${mplane}    timeout=120  alias=mplane
    ${pcap_name}=   Traffic Capture Stop

    Analyse Pcap    pcap_filename=${pcap_name}    analysis=TLS_hello_client      filter_file_name=${filter_file_name}

    Analyse Pcap    pcap_filename=${pcap_name}    analysis=TLS_hello_server_reply      filter_file_name=${filter_file_name}

    Analyse Pcap    pcap_filename=${pcap_name}    analysis=certificate      filter_file_name=${filter_file_name}





