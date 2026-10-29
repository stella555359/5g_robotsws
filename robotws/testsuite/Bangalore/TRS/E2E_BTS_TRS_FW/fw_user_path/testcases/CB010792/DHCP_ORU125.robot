*** Settings ***
Documentation
...     [Procedure]     "ORU DHCP 125 verificatio"
...     [Author]        "Shweta Naikodi"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB0010792"
...     [Requirement ID]   "5G_RAN_USR_COM_14641"
...     [Funtion_Hash_Tags] "Security"
...     [Domain_Hash_Tags] "Fronthaul Mplane in Airscale BBU"
...     [Validated_TestLine]    "2203"
...     [Config]    "this requires ORU configurations"
...     [Runtime param]   "bts_id is provided at run time."

Resource        ${CURDIR}/../CB010792/resources/Common_keyoword10792.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops



*** Test Cases ***
[1]CB010792_O-RU and O-DU shall support DHCPv4 Vendor Specific Information for IPv4
    Perform Commissioning       scf_file=${SCF}   verify_bts_status=True     timeout=400     alias=default
    Sleep  300
    Verfiy option125 with ORANV12
    Verfiy option43 with ORANV12
    [Teardown]  Reload BTS


