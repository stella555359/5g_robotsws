*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com

Force Tags    RF50

Resource    ./resources/keywords.robot
Resource    ./resources-CB013310/keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=900
...              increase_time_for_checking_cells=600
...              prefix_tag=CB010652-F
Suite Teardown   Common Suite Teardown

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions With Watching Alarms    AND
...              Setup Attenuators    AND
...              Verify ASiR Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
${CONFIG}    F

*** Test Cases ***
[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Run Max Throughput On All Cells One By One

[1][1.0] CB010652_ASiR_pRRH_Reset_with_ASiRWebEM
    Log Current Time
    Allow Alarms For ANTMOD Operations
    Reset All ANTMODs On ASiR WebEM
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms After Antenna Reset
    Run Throughput On All Cells One By One
    [Teardown]    Disallow Alarms For ANTMOD Operations With Common Postconditions

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    Allow Alarm For Site Reset
    Reset BTS Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    [Teardown]    Disallow Alarms For Site Reset With Common Postconditions And Logout From Gui

[1]General_SiSo_Auto_RU_module_reset_from_GUI
    Reset All BTS Antennas Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Run Throughput On All Cells One By One
    [Teardown]    Common Postconditions And Logout From Gui

[1][2.0] General_SiSo_Cell_block_and_unblock
    Allow Alarm For Cells Block
    Block And Unblock All Cells One By One Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Run Throughput On All Cells One By One
    [Teardown]    Disallow Alarms For Cells Block With Common Postconditions And Logout From Gui

[1][5.0] CB013310-B-SR-01-Download_and _activate_ASiR_SCF_as_local_application_administrator_with ASiR_WebEM
    admin.setup_admin   bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   username=Nemuadmin   password=nemuuser
    ...   use_ssl=${USE_SSL}
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    admin.set_user_account   old_username=${APP_ADMIN_USERNAME}   old_password=nemuuser
    ...   new_username=${EMPTY}   new_password=${APP_ADMIN_PASSWORD}
    ...   connection=default   timeout=${120}
    admin.change_local_account_state   account_type=BtsApplication   enable=True
    ...   connection=default   timeout=${120}
    AsirWebEM.login   user_name=${APP_ADMIN_USERNAME}   user_password=${APP_ADMIN_PASSWORD}
    AsirWebEM.save_screenshot   screenshot_after_login.png
    keywords_py.verify_if_specified_buttons_are_active_or_greyed_out_in_config_man   ${EXPECTED_GREYED_OUT_BUTTONS_APP_ADMIN}
    Create Directory   ${DIR_WITH_SCF}
    AsirWebEM.save_scf   desired_download_directory=${DIR_WITH_SCF}
    Change ASiR SCF Filename
    AsirWebEM.load_scf   scf_path=${DIR_WITH_SCF}/${SCF_FILE_NAME}
    Sleep   180   reason=waiting for BTS is up and onAir after ASIR reset caused by load_scf keyword
    gnbcell.wait_for_all_cells_to_be_onair   timeout=${2400}
