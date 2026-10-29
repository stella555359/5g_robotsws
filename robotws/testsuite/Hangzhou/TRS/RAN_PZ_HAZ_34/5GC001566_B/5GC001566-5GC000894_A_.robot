# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# ...   author: kaijia.chen@nokia-sbell.com
# ...   contact: kaijia.chen@nokia-sbell.com
# ...   squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# Suite Teardown    Tests_suite_Teardown
# 
# Resource          resources/1566_trs_related.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Test Timeout    30 minutes
# 
# *** Test Cases ***
# [1]5GC001566-5GC000894_A_006_Solo IP routing table creation for IPv6
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-B-006:Solo IP routing table creation for IPv6
#     ...    -16.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPV6 Routes Table
#     Add Static IPV6 Route Via Parameters
#     Check IPV6 Route Exist
#     [Teardown]    run keywords    Delete IPV6 Routes Table    AND    CI_interface.Common Case Teardown
# 
# 
# [1]5GC001566-5GC000894_A_012_IP_rule_creation+IP_routing_table_creation_(persistency)_ for_IPv4
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-B-012:IP rule creation+IP routing table creation (persistency) for IPv4
#     ...    -20.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPV4 Routes Table
#     Add static IPv4 route via parameters
#     Add IPV4 Routing Policies
#     Check IPV4 Route Exist
#     Check RoutingPolicies IPV4 added
#     gNB Reset Site
#     Check IPV4 Route Exist
#     Check RoutingPolicies IPV4 added
#     [Teardown]  Run Keywords
#     ...     Delete IPV4 Routing Policies    AND
#     ...     Delete IPV4 Routes Table    AND    CI_interface.Common Case Teardown
# 
# 
# [1]5GC001566-5GC000894_A_014_IP_routing_table_deletion_failure_(reference_by_IP_rule)
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-B-014:IP routing table deletion failure (reference by IP rule)
#     ...    -20.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPV4 Routes Table
#     Add static IPv4 route via parameters
#     Add IPV4 Routing Policies
#     Check IPV4 Route Exist
#     Check RoutingPolicies IPV4 added
#     Delete IPV4 Routes Table
#     Check SCF Error Policies Without RTable
#     [Teardown]    Delete IPV4 Routing Policies
# *** Keywords ***
