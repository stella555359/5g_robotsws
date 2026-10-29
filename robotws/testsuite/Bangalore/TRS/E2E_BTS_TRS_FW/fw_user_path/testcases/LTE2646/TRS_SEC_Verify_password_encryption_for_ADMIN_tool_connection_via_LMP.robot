** Settings ***
Documentation
    ...        [Procedure]        "TRS_SEC_Verify BTS Security & access mgmt user account Mgmt Raising & Cancelling of alarm for LMP Port Access"
    ...        [Date]             "23-09-2022"
    ...        [Author]           "Mansi"
    ...        [QC_Path]          "QC_Path in Test Plan"
    ...        [QC_ID]            "QC_ID in Test Lab for reporting"
    ...        [Feature_ID]             "SR001063"
    ...       [Validation_status]      "Validated and Passed"


Force Tags      CLOUD_R4P    CA_E2ET_BTSTRSPZ        SBTS00        SBTS23R1     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource         ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/../resources/Admin_Common_Library.robot
Resource    ${CURDIR}/resources/LTE2646_Common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test Cases ***
[1][1.0] 1.0 TRS_SEC_Verify_BTS_Security_&_access_management_Local_user_account_Mgmt_Raising_&_Cancelling_of_alarm_for_LMP_Port_Access
	Fluctuate Backhaul link and verify lte calls
	Fluctuate Backhaul link and verify 5G calls
    Precondition
	LMP_PORT Alarm should exit
    Verify with different credentials
	Setup Oamops	bts_host=${enb_ip}    bts_port=443		use_ssl=True
	Changing service account
    ...    SECADM-1:actServiceAccountSsh
    ...    false
    ...    ${SSH}
    ...    ${False}
	Changing service account
    ...    SECADM-1:actServicePortState
    ...    false
    ...    ${RD_port}
    ...    ${False}
    Changing service account
    ...    SECADM-1:actServiceAccountSsh
    ...    true
    ...    ${SSH}
    ...    True
    Changing service account
    ...    SECADM-1:actServicePortState
    ...    true
    ...    ${RD_port}
    ...    True
#mplane
    Setup Oamops    bts_host=${plain_mplane_ip}    bts_port=443    use_ssl=True

    Changing service account
    ...    SECADM-1:actServiceAccountSsh
    ...    false
    ...    ${SSH}
    ...    ${False}

    Changing service account
    ...    SECADM-1:actServicePortState
    ...    false
    ...    ${RD_port}
    ...    ${False}

    Verify the SSH and R&D status on IMS    ${status2}
    Verify the SSH and R&D status on IMS    ${status1}

    Changing service account
    ...    SECADM-1:actServiceAccountSsh
    ...    true
    ...    ${SSH}
    ...    True

    Changing service account
    ...    SECADM-1:actServicePortState
    ...    true
    ...    ${RD_port}
    ...    True

    Verify the SSH and R&D status on IMS    ${status2}
    Verify the SSH and R&D status on IMS    ${status1}