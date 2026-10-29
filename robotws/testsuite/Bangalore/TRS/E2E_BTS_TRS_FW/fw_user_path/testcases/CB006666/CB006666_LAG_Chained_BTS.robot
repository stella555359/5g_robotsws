*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_L2.2809;TT_L2.2936,TT_L2.2932,TT_L2.2979,TT_L2.2795,TT_L2.2823,TT_L2.2722,TT_L2.2817,TT_L2.2738,TT_L2.2725"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213,2212"
...     [Config]    "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]    "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Swithover_By_LOS_With_Chained_BTS

    Continue Keyword Execution On Failure    ${True}
    Configure Slave BTS AS
    Configure Master BTS AS
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave
    Verify LAG Parameters in Master BTS        bts1      bts2      lag_am     lag_sm      lag_active       lag_active_slave
    ...     lag_standby      lag_standby_slave
    Verify BTS Status Master and Slave
    Reset Bts       should_be_onair=${True}       rat=5g
    Check LAG on Master and Slave
    Verify LAG Parameters in Master BTS        bts1      bts2      lag_am     lag_sm      lag_active       lag_active_slave
    ...       lag_standby      lag_standby_slave
    Verify BTS Status Master and Slave
    Check Ping Success
    Setup Mplane Connection with Chained BTS
    Verify Switchover in Master BTS and Restoration
    [TEARDOWN]     Remove LAG From Master and disable lag Slave BTS

[2]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Active_Configurations_And_Swithover_By_LOS_With_Chained_BTS

    Continue Keyword Execution On Failure    ${True}
    Configure Slave BTS AA
    Configure Master BTS AA
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave AA
    Verify LAG Parameters in Master BTS      bts1      bts2      lag_am      lag_a1m       lag_active       lag_active_slave
    ...      lag_active1      lag_active1_slave
    Verify BTS Status Master and Slave
    Reset Bts       should_be_onair=${True}       rat=5g
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave AA
    Verify LAG Parameters in Master BTS      bts1      bts2      lag_am      lag_a1m       lag_active       lag_active_slave
    ...      lag_active1      lag_active1_slave
    Verify BTS Status Master and Slave
    Verify Switchover in Master BTS and Restoration
    Setup Mplane Connection with Chained BTS
    [TEARDOWN]     Remove LAG From Master and disable lag Slave BTS

[3]Automation-CB006666_Verify_Static_Lag_And_Swithover_Using_LOS_With_Chained_BTS

    Continue Keyword Execution On Failure    ${True}
    Configure Slave BTS Static
    Configure Master BTS Static
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave AA
    Verify No LACPDUs      bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Setup Mplane Connection with Chained BTS
    Verify BTS Status Master and Slave
    Reset Bts       should_be_onair=${True}       rat=5g
    Setup Mplane Connection with Chained BTS
    Verify No LACPDUs     bts1     bts2     nolag_a     nolag_s    lag_active_0     lag_standby_0
    Check LAG on Master and Slave AA
    Setup Mplane Connection with Chained BTS
    Verify BTS Status Master and Slave
    Setup Mplane Connection with Chained BTS
    Verify Switchover in Master BTS and Restoration
    [TEARDOWN]     Remove Static LAG From Master and Slave BTS

[4]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Swithover_by_LACP_timeout

    Continue Keyword Execution On Failure    ${True}
    Configure Slave BTS AS
    Configure Master BTS AS
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave
    Verify BTS Status Master and Slave
    Reset Bts       should_be_onair=${True}       rat=5g
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave
    Verify Switchover in Master BTS and Restoration Using LACP Timeout
    Check LAG on Master and Slave
    Remove LAG From Master and Slave BTS

[5]Automation-CB006666_Verify_Enable_Disable_LAG_With_Active_Standby_Configurations_And_Swithover_by_LACP_timeout

    Continue Keyword Execution On Failure    ${True}
    Configure Slave BTS AA
    Configure Master BTS AA
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave AA
    Verify BTS Status Master and Slave
    Reset Bts       should_be_onair=${True}       rat=5g
    Setup Mplane Connection with Chained BTS
    Check LAG on Master and Slave AA
    Verify Switchover in Master BTS and Restoration Using LACP Timeout
    Check LAG on Master and Slave AA
    Remove LAG From Master and Slave BTS
