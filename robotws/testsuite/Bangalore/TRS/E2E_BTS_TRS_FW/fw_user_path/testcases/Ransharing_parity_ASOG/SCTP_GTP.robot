*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            ""
...     [Funtion_Hash_Tags]     "sctp & gtp alarm verification"
...     [Procedure]             "sctp & gtp alarm verification"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CNI_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1]LTE3065_R_e_sctp & gtp alarm verification
	Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=3000
	Block Primary Cplane
    Sleep    300
    Verify Alarm        fault_id=${GTP_fault_Num}      should_exist=${True}       timeout=200     occurrences=6
    Verify Alarm        fault_id=${SCTP_fault_Num}       should_exist=${True}              timeout=200     occurrences=6
    Sleep    90
    Verify S1Link status is down for all 6 operators
	Unblock Primary Cplane
	Sleep	300
    Verify Alarm        fault_id=${GTP_fault_Num}       should_exist=${False}
    Verify Alarm        fault_id=${SCTP_fault_Num}       should_exist=${False}
    Sleep    90
    Verify S1Link status is up for all 6 operators


*** keywords ***

Block Primary Cplane
#    Read IP Parameters
	Setup Remote Access      remote_device=bts
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.250.102/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.250.102/32 -j DROP
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.248.38/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.248.38/32 -j DROP
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.248.102/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.248.102/32 -j DROP
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.248.166/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.248.166/32 -j DROP
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.248.230/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.248.230/32 -j DROP
	Remote Command Execute      command=iptables -A OUTPUT -s 10.71.249.38/32 -j DROP
	Remote Command Execute      command=iptables -A INPUT -d 10.71.249.38/32 -j DROP
#	[Teardown]      Teardown Remote Access


Unblock Primary Cplane
#    Read IP Parameters
	Setup Remote Access      remote_device=bts
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.250.102/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.250.102/32 -j DROP
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.248.38/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.248.38/32 -j DROP
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.248.102/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.248.102/32 -j DROP
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.248.166/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.248.166/32 -j DROP
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.248.230/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.248.230/32 -j DROP
	Remote Command Execute      command=iptables -D OUTPUT -s 10.71.249.38/32 -j DROP
	Remote Command Execute      command=iptables -D INPUT -d 10.71.249.38/32 -j DROP
	[Teardown]      Teardown Remote Access

Verify S1Link status is up for all 6 operators

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op1}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       available

Verify S1Link status is down for all 6 operators

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op1}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op2}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op3}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op4}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op5}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable

    ${LNMME_moc}=   Query Admin Infomodel   query=get object ${LNMME_moc_path_op6}
    ${s1Link_status}=  Get From Dictionary     dictionary=${LNMME_moc}     key=s1LinkStatus
    Should Be Equal     ${s1Link_status}       unavailable
