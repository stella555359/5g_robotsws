*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "RP000395"
...     [Funtion_Hash_Tags]     "IPv4 SCTP Multihoming"
...     [Procedure]             "Testcase check LTE - SCTP Multihoming and both primary and secondary MME IPs with proper routes "

*** keywords ***

Block Primary Cplane
    Read IP Parameters
	Setup Remote Access      remote_device=bts
	Remote Command Execute      command= iptables -A OUTPUT -s ${Primary_Cplane}/32 -j DROP
	Remote Command Execute      command= iptables -A INPUT -d ${Primary_Cplane}/32 -j DROP
#	[Teardown]      Teardown Remote Access

Unblock Primary Cplane
    Read IP Parameters
	Setup Remote Access      remote_device=bts
	Remote Command Execute      command= iptables -D OUTPUT -s ${Primary_Cplane}/32 -j DROP
	Remote Command Execute      command= iptables -D INPUT -d ${Primary_Cplane}/32 -j DROP
	[Teardown]      Teardown Remote Access

Verify Captured File
	[Arguments]     ${pcap_filename}
    Read IP Parameters
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_INIT_ACK
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ECHO
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_COOKIE_ACK
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_request
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_MME_TO_CPlane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_S1AP_response
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=verify_SCTP_SACK_ACK_from_CPlane_To_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME_to_prim_Cplane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane_to_prim_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_from_sec_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_ACK_from_sec_Cplane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_from_Sec_Cplane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_ACK_from_sec_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_from_prim_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_Cplane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_from_prim_Cplane
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_HEART_BEAT_ACK_from_prim_MME
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_SHUTDOWN
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_SHUTDOWN_ACK
     Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_SCTP_SHUTDOWN_COMPLETE

Read IP Parameters

    ${Primary_MME}=     Get Parameter      param_path=${Primary_MME_IP}
	Set Suite Variable	     ${Primary_MME}	     ${Primary_MME}
    ${Secondary_MME}=        Get Parameter      param_path=${Secondary_MME_IP}
	Set Suite Variable	     ${Secondary_MME}	      ${Secondary_MME}
    ${Primary_Cplane}=     Get Parameter      param_path=${Primary_Cplane_IP}
	Set Suite Variable	     ${Primary_Cplane}	     ${Primary_Cplane}
    ${Secondary_Cplane}=        Get Parameter      param_path=${Secondary_Cplane_IP}
	Set Suite Variable	     ${Secondary_Cplane}	      ${Secondary_Cplane}

keywords to run at end
     Run     sudo killall egate edaemon
     Run Keyword and Ignore Error     Traffic Capture Stop    mode=file   timeout=120