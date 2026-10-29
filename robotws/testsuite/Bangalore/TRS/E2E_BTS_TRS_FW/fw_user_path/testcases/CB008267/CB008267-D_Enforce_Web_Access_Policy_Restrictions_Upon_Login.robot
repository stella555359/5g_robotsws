*** Settings ***
Documentation     [Procedure] "CB008267-D_Enforce Web Access Policy Restrictions Upon Login"
...               [Author]             "Kiruthika"
...               [Maintenance]        "TRS ET Bangalore Team"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008267"
...               [Functional_Hash_Tags] "User Management"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] CLOUD_R4A_CUS
...               [Validation Date] 20-06-2023


Resource        ${CURDIR}/resources/CB008267_common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB008267-D_Enforce Web Access Policy Restrictions Upon Login
    Change credentials of user Using 'btsapplication' 'Crypto@262' 'BTSApplication' 'nemuuser' 'BtsApplication'
    Change credentials of user Using 'btssecurity' 'Crypto@262' 'BTSSecurity' 'nemuuser' 'BtsSecurity'

    Enable Restricted Access
    Check for duplicate login and perform recommissioning and expect error
    Check for login as Administrator    system		bts	conn
    Check for login as Administrator	security	bts1	conn1
    Check for login as Administrator	application	bts2	conn2
    Disable Restricted Access

    Enable Restricted Access using mplane
    Check for login as Administrator 	system_mplane		mplane		mplanelogin1
    Check for login as Administrator 	security_mplane		mplane1		mplanelogin2
    Check for login as Administrator 	application_mplane	mplane2		mplanelogin3
    Disable Restricted Access using mplane

    [Teardown]  Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}
    ...     operation=update    value=false     timeout=300	alias=mplanelogin

    Enable Ethernet Port Security
    Ethernet Port Security is Disabled alarm should not be present
    Perform Software Upgrade
    Ethernet Port Security is Disabled alarm should not be present
    Disable Ethernet Port Security
    Ethernet Port Security is Disabled alarm should be present
    Perform Software Rollback
    Ethernet Port Security is Disabled alarm should be present
