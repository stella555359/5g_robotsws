*** Settings ***
Documentation

...    This test suite is to cover SFP and QSFP monitoring that is mainly used for troubleshooting purposes or on new
...    instalation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB capacity
...    (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
...    quality between (a) radio and RAU (b) CU & DU. Supports all types of: SFP/SFP+/SFP28/QSFP used by Nokia.
...    Current version of test suite:
...    Author: Marzena Skolucka
...    Contact: marzena.skolucka@nokia.com
...    Original version of test cases:
...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska
...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com

Resource    ../../../procedures/SFP_Monitoring/procedure.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED     CRT     PY36
...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA
...     RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ANDROID_ASOE_AWEUA

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Test Cases ***
[1]CB007539-5G-C_9_CB007539 Retrieve periodic SFP QSFP Snapshot data
    Check Dynamic SFP Parameters Saved Into PM Counters For ABIL
    Check Dynamic SFP Parameters Saved Into PM Counters For RU

[1]CB007539-5G-C_4_CB007539 Initiate SFP Monitoring from WebEM for ASIx(dynamic data)
    Initiate Smod Sfp Monitoring

[1]CB007539-5G-C_8_CB007539 Dynamic SFP Parameters saved into PM counters for RU
    Check Dynamic SFP Parameters Saved Into PM Counters For Ru

[1]CB007539-5G-C_5_CB007539 Dynamic SFP Parameters saved into PM counters for ASIx
    Check Dynamic SFP Parameters Saved Into PM Counters For ABIL
