*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate 5G IPSec IPv4 IKE and IPSec Rekeying"
    ...     [Date]                  "28-07-17"
    ...     [Author]                "Nadig Sushma"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "IPSEC IPv4 IKE IPSec Rekeying"
    ...     [Feature_ID]            "5GC000392"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-420"
    ...     [Requirement ID]    "TT_TTSEC.896,TT_TTSEC.897,TT_TTSEC.644,TT_TTSEC.699,TT_TTSEC.654,TT_TTSEC.907"
    ...     [Scfc File]    "Configuration_scf_MRBTS-420_ASOD_TL65_20201105-1221_IP_certificate_modi_20201117-0605.xml"
    ...     [Config]    "This script requires IPV4 IPSec with single ipsecp configuration"
    ...     [RunTime Parameters]    "[bts_id]"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown        Teardown Oamops

***Test Cases***
[1][1.0] TRS_5GC000264_Verification_of_IPv4_IKE_and_IPSec_Rekeying
     Perform Commissioning       scf_file=${IPSec_IP_certificate_commisioning}      verify_bts_status=False      timeout=400      alias=default
     Sleep    300
    Verify Alarm        faultid=61645     rat=lte     should_exist=${False}
    Get Ipsec Tunnels Status
    Perform Recommissioning     type=param     param_path=${SaMaxTime_moc_path}     operation=update        value=300     timeout=120
    Execute Command On ENodeB       ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
    Set Suite Variable     ${Key_value}       ${stdout}
    Sleep     200
    Execute Command On ENodeB        ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
    Set Suite Variable     ${Key_value_new}       ${stdout}
    Should Be Equal     ${Key_value}            ${Key_value_new}
    Sleep     60
    Execute Command On ENodeB        ipsec statusall | grep "conn${default_policy}" | tail -3 | head -1 | awk '{ print $8 }''{ print $9 }'
    Set Suite Variable     ${Key_value_new1}       ${stdout}
    Should Not Be Equal     ${Key_value}            ${Key_value_new1}

    Perform Recommissioning     type=param     param_path=${Wrong_GTP}    operation=update        value=60     timeout=300
    Sleep   60
    Verify GTP alarm
    Wait Until Keyword Succeeds    3    100s    Reset Bts
    Sleep   60
    Verify GTP alarm
    Perform Recommissioning     type=param     param_path=${GTP}    operation=update        value=0     timeout=300
    Sleep   60
    Verify No GTP alarm

*** Keywords ***
Verify GTP alarm
    Verify Alarm        faultid=6150     rat=lte     should_exist=True   occurrences=2

Verify No GTP alarm
    Verify Alarm        faultid=6150     rat=lte     should_exist=${False}
