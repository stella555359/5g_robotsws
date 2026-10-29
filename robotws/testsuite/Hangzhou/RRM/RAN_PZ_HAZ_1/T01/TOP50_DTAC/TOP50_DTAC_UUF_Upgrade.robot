*** Settings ***
Documentation
...   author: kefang.sheng
...   contact: kefang.sheng@nokia-sbell.com
...   this is a robot case about TOP DTAC customer basic configuration.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library   taf.selenium.sbts    WITH NAME    selenium_coam_rrm

Force Tags        RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG02_ST_RRM    TA_LEVEL_21    RAN_5G
...               CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_ABILB2_AHPDA_RFS    STAT_SKIP_AGENT    SBTS00
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Case Teardown with Scout


*** Test Cases ***
[1]OAM stability upgrade and rollback
    [Tags]    QC_266867       QCD_MN_RAN      QCP_RAN_ST

	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is other version    console=yes
	log    Now start to prepare the Env for upgrade    console=yes

  Upgrade to 22R1 Version and Check Cell onair
 	log    Now active is SBTS22R1_XXXXXX and passive is SBTS22R1_ENB_0000_002003_000000    console=yes

	Rollback and Check Cell onair
 	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is SBTS22R1_XXXXXX    console=yes

 	log    Now start to do the first upgrade    console=yes
	Upgrade to Target Version and Check Cell onair
 	log    Now active is target version and passive is SBTS22R1_ENB_0000_002003_000000     console=yes

	Rollback and Check Cell onair
 	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is other version     console=yes

	Upgrade to 22R1 Version and Check Cell onair
 	log    Now active is SBTS22R1_XXXXXX and passive is SBTS22R1_ENB_0000_002003_000000    console=yes

	Rollback and Check Cell onair
 	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is SBTS22R1_XXXXXX    console=yes

 	log    Now start to do the second upgrade    console=yes
	Upgrade to Target Version and Check Cell onair
 	log    Now active is target version and passive is SBTS22R1_ENB_0000_002003_000000     console=yes

 	log    Now start to recovery the Env   console=yes
	Rollback and Check Cell onair
 	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is other version     console=yes

	Upgrade to 22R1 Version and Check Cell onair
 	log    Now active is SBTS22R1_XXXXXX and passive is SBTS22R1_ENB_0000_002003_000000    console=yes

	Rollback and Check Cell onair
 	log    Now active is SBTS22R1_ENB_0000_002003_000000 and passive is SBTS22R1_XXXXXX    console=yes


*** Keywords ***

Common Test Case Teardown with Scout
    Common Test Teardown For RRM
    scout.setup_scout    10_5_UTESRAN001T5082
    ${scf_id}    scout.request_scf    use_scout_internal_id=${False}

Rollback and Check Cell onair
    Rollback software for SRAN
	sleep    600
    COAM_Admin.Login
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Upgrade to 22R1 Version and Check Cell onair
    COAM_Admin.Login
    COAM_Admin.UpdateSW_local    /home/ute/SBTS22R1_ENB_0000_002164_000000_release_BTSSM_downloadable_A54.zip
	sleep    300
    COAM_Admin.Login
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Upgrade to Target Version and Check Cell onair
    COAM_Admin.Login
    COAM_Admin.UpdateSW_local    /home/ute/SBTS22R1_ENB_0000_002164_000000_release_BTSSM_downloadable_A54.zip
	sleep    300
    COAM_Admin.Login
    Wait until keyword succeeds    15m    1m   Verify 3G cells should be onair
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Verify 3G cells should be onair
    [Arguments]    ${connection}=COAM
    ${cell_info_3g}    coam.get_cells_info    cell_type=wcdma   timeout=10    connection=${connection}
    ${number_of_cell}    get length    ${cell_info_3g}
    FOR    ${index}    IN RANGE    ${number_of_cell}
        ${status}    Set Variable    ${cell_info_3g[${index}]['status']}
        Run Keywords    Should Be True    "${status['operationalState']}"=="enabled" or "${status['operationalState']}"=="Enabled"
        ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
        ...    AND    Should Be True   "${status['blockingState']}"=="Unblocked"
    END
