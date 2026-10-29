*** Settings ***
Documentation
...   Test Suite for testing CB010680 feature
...     Author: Natalia Czech, Bartosz Odziomek
...     Contact: natalia.czech@nokia.com, bartosz.odziomek@nokia.com



Resource             testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010680/resources/CB010680_keywords.robot


Suite Setup          Custom Suite Setup
Suite Teardown       Common Suite Teardown
Test Setup           Common Preconditions With Watching Alarms
Test Teardown        Common Postconditions With Watching Alarms


*** Test Cases ***
CB010680-SR-A_TC02_ABIQ_1_supercell_pos_activation_deactivation
    Cell activation deactivation veryfication
    ...     prefix_tag=${BTS_config_A}
    ...     delta=${delta_parameter_a}

CB010680-SR-B_TC08_RU-Access_normalcell_activation_deactivation
    Cell activation deactivation veryfication
    ...     prefix_tag=${BTS_config_B}
    ...     delta=${delta_parameter_b}

CB010680-SR-C_TC13_ABIP_3_supercell_with_RU-SRS_on_Air
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_C}
    Verify NRPOSITION CELLS status    1

CB010680-SR-D_TC28_ABIP_7_normal_cell_full_ABIP_with_RU-SRS_on_Air
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_F}
    keywords.Reset Cell and check onair    3    2

CB010680-SR-E_TC44_Webem_pos_verify
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_F}
    Verify NRPOSITION CELLS status    3    2

CB010680-SR-F_TC48_Normal_cell_BF_nonBF_mix_on_Air
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_F}

CB010680-SR-G_TC60_RU_block_P-SRS_reception
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_H}
    Block unblock RU with NRPOSCELL    1
    Verify NRPOSITION CELLS status    2    3
    Block unblock RU with NRPOSCELL    3    4
    Verify NRPOSITION CELLS status    2    3

CB010680-SR-H_TC66_Normal_cell_RU-SRS_2Rx_distributed_antenna_on_Air
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_H}

CB010680-SR-I_TC78_cell_mapping_info_snapshot
    Upload Swconfig On Classical Gnb    sw_config_path=${sw_config_path}
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_H}
    Create admin session with custom alias    connection=admin
    coam.collect snapshot    target_file_name=/home/ute/snapshot/SNAPSHOT.zip
    ...    coverage=Full
    ...    connection=admin
    Run    mkdir -p ${path_to_unzip}
    unzip_snapshot  ${path_to_snapshot}
    check nrposition cells

CB010680-SR-J_TC61_No_autonomous_reset_NRPOSCELL_fault
    Load SCF and verify BTS onAir
    ...      prefix_tag=${BTS_config_J}
    Reset NRPOSCELL    2    3
    Sleep    2min
    gnbcell.verify all cells are onair
