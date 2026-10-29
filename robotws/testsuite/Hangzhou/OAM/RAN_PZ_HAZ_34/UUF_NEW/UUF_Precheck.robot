*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot

# Suite Setup   UUF Common Suite Setup
# Suite Teardown   UUF Common Suite Teardown


*** Variables ***
# ${origin_version}   SBTS21B_ENB_0000_002265_000000
# ${upgrade_version}   SBTS23R2_ENB_0000_000480_000000
# ${enb_source_version}   SBTS21B_ENB_0000_002265_000000
# ${enb_target_version}   SBTS23R2_ENB_0000_000480_000000
${origin_version}
${enb_source_version}   ${origin_version}

${log_collection_flag}   NONE


${TEST_MODE}            UUF
${DEBUG}                ${False}
${l3_call}              N
${NETACT_IP}


*** Test Cases ***
#Remove TAF Log Code and Package
#    [Setup]   Run Keyword If   "${PREV_TEST_STATUS}"=="FAIL"   Fatal Error
#    Log To Console   //TODO: Remove TAF Log Code and Package
#    Run Keyword And Ignore Error   OperatingSystem.Run
#    ...   sudo rm -rf /opt/transformers.dynamic.nsn-net.net/workspace/UUF_NEW/Master/Manual/*


Prepare For PreCheck
    Log To Console   ${EMPTY}

    # Set Suite Variable   ${log_collection_flag}   NONE
    # UUF Set Log Collection Flags

    # UUF Get Variables From Testline Configuration
    # UUF Truck Roll Check

    UUF Backup All Testline SCF   scf_prefix=SCF_Prepare
    UUF Get Variables From Backup SCF   scf_prefix=SCF_Prepare

    UUF Get Variables From Others
    UUF Get Testline Type

    # #Prepare Env Check
    UUF Check Env VM
    UUF Check Env Testline
    UUF Prepare Load Build

    UUF Check TMO Decoupling
    UUF Check Independent DU SW Upgrade

    # #Prepare for Source Build
    ${status}   Run keyword and return status   UUF Switch To Specified Load Build   upgrade_sequence=${UPGRADE_SEQUENCE}   package_type=source
    Run Keyword If   '${status}'=='FAIL'   run keyword and ignore error   UUF Catch Snapshot

    # UUF Backup All Testline SCF   scf_prefix=SCF_Source
    # UUF Get Variables From Backup SCF

    UUF ALL WorkAround
    Kill PC Specific Processes    processes_name=nc 192
    UUF Log ALL Suite Variables


Perform SCF in Advance
    [Setup]   Run Keyword If   "${PREV_TEST_STATUS}"=="FAIL"   Fatal Error
    FOR   ${testline}   IN   @{UPGRADE_SEQUENCE}
        Log To Console   //TODO: Perform SCF in Advance
    END

Install NetAct Cert to gNB
    [Setup]   Run Keyword If   "${PREV_TEST_STATUS}"=="FAIL"   Fatal Error
    FOR   ${testline}   IN   @{UPGRADE_SEQUENCE}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb"

        ${oamtls}   Set Variable   ${ALL_CONFIG_SCF["${testline}"]["oamtls"]}
        Continue For Loop If   "${oamtls}"=="off"


        Log To Console   //TODO: Install NetAct Cert to gNB
        # Install NetAct Cert

    END

Integrate NE to NetAct
    [Setup]   Run Keyword If   "${PREV_TEST_STATUS}"=="FAIL"   Fatal Error
    FOR   ${testline}   IN   @{UPGRADE_SEQUENCE}
        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Continue For Loop If   "${testline_type}"=="enb"

        Log To Console   //TODO: Integrate NE to NetAct
    END

Site Status Pre-Check
    [Setup]   Run Keyword If   "${PREV_TEST_STATUS}"=="FAIL"   Fatal Error
    FOR   ${testline}   IN   @{UPGRADE_SEQUENCE}
        Log To Console   //TODO: Site Status Pre-Check
        # UUF Check Cell Status   testline=${testline}
        # UUF Check Active Faults   testline=${testline}
        UUF Check SW Version   testline=${testline}   save_check_point=${False}   package_type=source
        ...   needConnect=${True}   passive_check=${False}
    END


# robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Perform_SCF_TL.robot
# robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Install_NetAct_Cert_to_gNB.robot
# robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Integrating_NE_to_NetAct.robot
# robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Site_Status_precheck.robot
# robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Remove_TAF_Log_Code_Package.robot
