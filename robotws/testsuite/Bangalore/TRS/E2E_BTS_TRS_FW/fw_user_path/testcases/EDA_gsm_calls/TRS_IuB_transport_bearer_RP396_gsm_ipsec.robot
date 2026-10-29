***Settings ***
Documentation
    ...     [Procedure]             "EDA_GSM_Wcdma"
    ...     [Date]                  "17-06-25"
    ...     [Author]                "Nethra"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Gsm"
    ...     [Feature_ID]            "RP000366,5G000265"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2204"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CDRT_with_maxIPSec_keyword.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Variables ***

${index}                    1
${length}                   40

*** Test Cases ***
[1]RDI-22035 TRS_VRF Improvement Action for 4611589 GSM Calls

	[Documentation]		This test case validates ul/DL Wcdma IPv4/IPv6 Call Validation with DL/UL Traffic
       Continue Keyword Execution On Failure     ${True}
       Perform Commissioning       scf_file=${EDA_wcdma_gsm_v4}   verify_bts_status=False   rat=wcdma
       BuiltIn.Sleep    300
       Verify Bts Status    dut=bts     rat_req=gsm   should_be_onair=${True}
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv4
       Teardown Remote Access     alias=ftp
#      Enable ipsec and verify traffic Ipv4
       Perform Recommissioning      type=delta      delta_file=${delta_ipsec}
       BuiltIn.Sleep    200
       Get Ipsec Status
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv4
       Teardown Remote Access     alias=ftp
#       Load IPv6 scf and run traffic
       Perform Commissioning       scf_file=${EDA_wcdma_gsm_v6}   verify_bts_status=False   rat=wcdma
       BuiltIn.Sleep    300
       Verify Bts Status    dut=bts     rat_req=gsm   should_be_onair=${True}
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv6
       Teardown Remote Access     alias=ftp
#      Verify Calls with IPsec enabled
       Perform Recommissioning      type=delta      delta_file=${delta_ipsec}
       BuiltIn.Sleep    300
       Verify Bts Status    dut=bts     rat_req=gsm    should_be_onair=${True}
       Get Ipsec Status
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv6
       Get Ipsec Status
       Teardown Remote Access     alias=ftp
# Perform Software Upgrade and verify if BTS on-air and IPsec status
       Perform Software Upgrade
       BuiltIn.Sleep    1200
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv6
       Get Ipsec Status
       Teardown Remote Access     alias=ftp
#      Load Ipv4 Scf file and verify traffic after upgrade
       Perform Commissioning       scf_file=${EDA_wcdma_gsm_v4}   verify_bts_status=False   rat=wcdma
       BuiltIn.Sleep    300
       Verify Bts Status    dut=bts     rat_req=gsm   should_be_onair=${True}
       Perform Recommissioning      type=delta      delta_file=${delta_ipsec}
       BuiltIn.Sleep    200
       Get Ipsec Status
       Setup Remote Access     remote_device=ftpserver     alias=ftp
       Execute Interactive Remote Command     command=${change_permission}     alias=ftp
       Run Keyword      Make 2G Calls IPv4
       Teardown Remote Access     alias=ftp
