*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../CERTA_Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM

Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes




*** Test Cases ***
# Normal cases
TC01_Main
    Counter Check With RU Reset    product_type=gnb    ue_type=Commercial_phone
    ...    cell_distname_id=MRBTS-37179/LNBTS-2371/LNCEL-1
    ...    counter_rule=${CURDIR}/counter_rule.txt
    ...    tl_descriptor_path=${CURDIR}/TLdescriptor.xml
    ...    ue_index=${0}    ul_tput=9    dl_tput=20    ul_port=5000    dl_port=5001    duration=1000s



