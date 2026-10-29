*** Settings ***
Documentation
...  author:      Julia Wijas
...  contact:     julia.wijas@nokia.com
...  description: The test cases about testing the CB010214-A


Resource    ../Resources/CB010214-SR_Resources.robot
Resource    ../../../common_resources/mantaray/mantaray.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/rest_api/rest_api.robot

Library      taf.config.scf    WITH NAME   scf
Library      OperatingSystem
Library      SSHLibrary
Library      BuiltIn
Library      taf.selenium.sbts  WITH NAME    sbts_selenium

*** Variables ***
${release_name}=         SBTS26R1
${MR_2}=                 MRC-COMMON/MR-COMMON_2

*** Keywords ***
CB010214-A_LABM_modification-block_unblock_Ethernet_traffic
    Log        Preconditions: ...                             console=true
    Log        Integrating to Mantaray without TLS            console=True
#    ${release_name}    Get Software Release Name
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Set ethernetPortSecurityEnabled to true        console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=ethernetPortSecurityEnabled
    ...                        param_value=true
    ...                        LAB_NAME=${LAB_NMS}
    Log        Set localAccessBlockingMode to disabled        console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=0
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 4: checking if all Ethernet traffic is allowed.   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 5: Set localAccessBlockingMode to EnabledWithBackup        console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=1
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 6: checking if all Ethernet traffic apart from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 7: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay    LAB_NAME=${LAB_NMS}
    Sleep      180s      reason=Wait for deintegration
    Log        Step 8: Waiting for automatic backup         console=True
    Log        Step 9: checking if all Ethernet traffic is allowed.   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 10: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 11: checking if all Ethernet traffic apart from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 12: Set localAccessBlockingMode to PortBlockedWithBackup           console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=2
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 13: checking if all Ethernet traffic includnig from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=fail
    Log        Step 14: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay     LAB_NAME=${LAB_NMS}
    Sleep       180s      reason=Wait for deintegration
    Log        Step 15: Waiting for automatic backup         console=True
    Log        Step 16: checking if all Ethernet traffic is allowed.   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 17: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 18: checking if all Ethernet traffic includnig from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=fail
    Log        Step 19: Set localAccessBlockingMode to EnabledWithBackup           console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=1
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 20: checking if all Ethernet traffic apart from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 21: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay     LAB_NAME=${LAB_NMS}
    Sleep       180s      reason=Wait for deintegration
    Log        Step 22: Waiting for automatic backup         console=True
    Log        Step 23: checking if all Ethernet traffic apart from SSE is forbidden   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 24: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 25: checking if all Ethernet traffic apart from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 26: Set localAccessBlockingMode to Disabled           console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=0
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 27: checking if all Ethernet traffic is allowed.   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 28: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay     LAB_NAME=${LAB_NMS}
    Sleep       180s      reason=Wait for deintegration
    Log        Step 29: Waiting for automatic backup         console=True
    Log        Step 30: checking if all Ethernet traffic is allowed.   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 31: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 32: checking if all Ethernet traffic is allowed.   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 33: Set localAccessBlockingMode to PortBlockedWithBackup           console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=2
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 34: checking if all Ethernet traffic includnig from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=fail
    Log        Step 35: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay     LAB_NAME=${LAB_NMS}
    Sleep       180s      reason=Wait for deintegration
    Log        Step 36: Waiting for automatic backup         console=True
    Log        Step 37: checking if all Ethernet traffic is allowed.   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 38: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=      Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 39: checking if all Ethernet traffic includnig from SSE is forbidden   console=true
    Send Ping From Test PC     expected_status=fail
    Log        Step 40: Set localAccessBlockingMode to Disabled          console=true
    Change Parameter with NMS  MOC_DN=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=localAccessBlockingMode
    ...                        param_value=0
    ...                        LAB_NAME=${LAB_NMS}
    Log        Step 41: checking if all Ethernet traffic is allowed.   console=true
    Send Ping From Test PC     expected_status=pass
    Log        Step 42: Closes connection to NMS.            console=True
    Deintegrate BTS from MantaRay     LAB_NAME=${LAB_NMS}
    Sleep       180s      reason=Wait for deintegration
    Log        Step 43: Waiting for automatic backup         console=True
    Log        Step 44: checking if all Ethernet traffic is allowed.   console=true
    Wait until keyword succeeds    15m   30s         Send Ping From Test PC
    ...                                              expected_status=pass
    Log        Step 45: Restor connection to MantaRay                 console=True
    ${LAB_NMS}=       Integrate BTS to MantaRay without TLS
    ...        SW_RELEASE=${release_name}
    ...        MR=${MR_2}
    Log        Step 46: checking if all Ethernet traffic is allowed.   console=true
    Send Ping From Test PC     expected_status=pass
    [Teardown]   Run Keyword and Ignore Error   MantaRay Teardown with Restriction       LAB_NMS=${LAB_NMS}
