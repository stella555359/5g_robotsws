#!/usr/bin/env python3
"""
Script de test pour vérifier la configuration PM automatique.

Ce script valide que pm_test_configurator génère correctement
les paramètres pour les test cases Robot Framework.

Usage:
    python test_pm_configurator.py
"""

import sys
from pathlib import Path
import os

# Ajouter le chemin vers les modules Python
# __file__ donne le chemin absolu du script actuel
script_dir = Path(__file__).resolve().parent  # .../transversal_robustness/test
parent_dir = script_dir.parent                 # .../transversal_robustness
resources_path = parent_dir / "resources" / "python"

# Ajouter au path
sys.path.insert(0, str(resources_path))

# noqa: E402 - imports after path setup
from pm_test_configurator import PMTestConfigurator  # noqa: E402


def test_configuration_1sub():
    """Test avec 1 perturbation (en fait 0 pour 1SUB)."""
    print("\n" + "=" * 80)
    print("TEST CONFIGURATION: TMO_SFE_LTD_1SUB (NO PERTURBATIONS)")
    print("=" * 80)

    # Configuration pour 1SUB (pas de perturbations)
    bkg_map = [
        {
            "name": "bkg",
            "offset": 1,
            "duration": 16,
            "sce_name": "bkg_13UEs_SFE_TMO.txt"
        }
    ]

    subSce_map = []  # Pas de perturbations pour 1SUB

    configurator = PMTestConfigurator()
    config = configurator.get_test_configuration(bkg_map, subSce_map)

    print(f"\nNombre de Background tests: {configurator.get_number_of_background_tests()}")
    print(f"Nombre de Perturbation tests: {configurator.get_number_of_perturbation_tests()}")
    print(f"Total périodes PM: {configurator.get_total_pm_periods()}")

    configurator.print_test_configuration()

    # Vérifications
    assert configurator.get_number_of_background_tests() == 1, \
        "Should have 1 Background test"
    assert configurator.get_number_of_perturbation_tests() == 0, \
        "Should have 0 Perturbation tests"

    # Test Background_IC_01
    bg1_config = configurator.get_background_config(1)
    print(f"\nBackground_IC_01:")
    print(f"  start_pm_index: {bg1_config['start_pm_index']}")
    print(f"  nb_loop: {bg1_config['nb_loop']}")
    print(f"  perturbation_sce: {bg1_config['perturbation_sce']}")

    assert bg1_config['start_pm_index'] == 1, "Should start at PM 1"
    assert bg1_config['nb_loop'] == 16, "Should have 16 loops"
    assert bg1_config['perturbation_sce'] == 'wait', "Should be background only"

    print("\n✅ TEST 1SUB PASSED\n")


def test_configuration_2sub():
    """Test avec 2 perturbations."""
    print("\n" + "=" * 80)
    print("TEST CONFIGURATION: TMO_SFE_LTD_2SUB (2 PERTURBATIONS)")
    print("=" * 80)

    # Configuration pour 2SUB
    bkg_map = [
        {
            "name": "bkg",
            "offset": 1,
            "duration": 16,
            "sce_name": "bkg_13UEs_SFE_TMO.txt"
        }
    ]

    subSce_map = [
        {
            "name": "subSce1",
            "offset": 6,
            "duration": 2,
            "sce_name": "Perturbation_5GC000937_001.sce"
        },
        {
            "name": "subSce2",
            "offset": 12,
            "duration": 2,
            "sce_name": "Perturbation_5GC000937_001.sce"
        }
    ]

    configurator = PMTestConfigurator()
    config = configurator.get_test_configuration(bkg_map, subSce_map)

    nb_bg = configurator.get_number_of_background_tests()
    nb_pert = configurator.get_number_of_perturbation_tests()
    print(f"\nNombre de Background tests: {nb_bg}")
    print(f"Nombre de Perturbation tests: {nb_pert}")
    print(f"Total périodes PM: {configurator.get_total_pm_periods()}")

    configurator.print_test_configuration()

    # Vérifications
    assert configurator.get_number_of_background_tests() == 3, \
        "Should have 3 Background tests"
    assert configurator.get_number_of_perturbation_tests() == 2, \
        "Should have 2 Perturbation tests"

    # Test Background_IC_01 (PM 1-5)
    bg1_config = configurator.get_background_config(1)
    print(f"\nBackground_IC_01:")
    print(f"  start_pm_index: {bg1_config['start_pm_index']}")
    print(f"  nb_loop: {bg1_config['nb_loop']}")
    print(f"  PM range: {bg1_config['pm_start']}-{bg1_config['pm_end']}")

    assert bg1_config['start_pm_index'] == 1, "Should start at PM 1"
    assert bg1_config['nb_loop'] == 5, "Should have 5 loops"
    assert bg1_config['pm_end'] == 5, "Should end at PM 5"

    # Test Perturbation_01 (PM 6-7)
    pert1_config = configurator.get_perturbation_config(1)
    print(f"\nPerturbation_01:")
    print(f"  start_pm_index: {pert1_config['start_pm_index']}")
    print(f"  nb_loop: {pert1_config['nb_loop']}")
    print(f"  PM range: {pert1_config['pm_start']}-{pert1_config['pm_end']}")
    print(f"  perturbation_sce: {pert1_config['perturbation_sce']}")

    assert pert1_config['start_pm_index'] == 6, "Should start at PM 6"
    assert pert1_config['nb_loop'] == 2, "Should have 2 loops"
    assert pert1_config['perturbation_sce'] == "Perturbation_5GC000937_001.sce"

    # Test Background_IC_02 (PM 8-11)
    bg2_config = configurator.get_background_config(2)
    print(f"\nBackground_IC_02:")
    print(f"  start_pm_index: {bg2_config['start_pm_index']}")
    print(f"  nb_loop: {bg2_config['nb_loop']}")
    print(f"  PM range: {bg2_config['pm_start']}-{bg2_config['pm_end']}")

    assert bg2_config['start_pm_index'] == 8, "Should start at PM 8"
    assert bg2_config['nb_loop'] == 4, "Should have 4 loops"
    assert bg2_config['pm_end'] == 11, "Should end at PM 11"

    # Test Perturbation_02 (PM 12-13)
    pert2_config = configurator.get_perturbation_config(2)
    print(f"\nPerturbation_02:")
    print(f"  start_pm_index: {pert2_config['start_pm_index']}")
    print(f"  nb_loop: {pert2_config['nb_loop']}")
    print(f"  PM range: {pert2_config['pm_start']}-{pert2_config['pm_end']}")

    assert pert2_config['start_pm_index'] == 12, "Should start at PM 12"
    assert pert2_config['nb_loop'] == 2, "Should have 2 loops"

    # Test Background_IC_03 (PM 14-16)
    bg3_config = configurator.get_background_config(3)
    print(f"\nBackground_IC_03:")
    print(f"  start_pm_index: {bg3_config['start_pm_index']}")
    print(f"  nb_loop: {bg3_config['nb_loop']}")
    print(f"  PM range: {bg3_config['pm_start']}-{bg3_config['pm_end']}")

    assert bg3_config['start_pm_index'] == 14, "Should start at PM 14"
    assert bg3_config['nb_loop'] == 3, "Should have 3 loops"
    assert bg3_config['pm_end'] == 16, "Should end at PM 16"

    print("\n✅ TEST 2SUB PASSED\n")


def test_robot_keywords():
    """Test des keywords Robot Framework."""
    print("\n" + "=" * 80)
    print("TEST ROBOT FRAMEWORK KEYWORDS")
    print("=" * 80)

    from pm_test_configurator import (
        get_start_pm_index_for_background,
        get_nb_loop_for_background,
        get_start_pm_index_for_perturbation,
        get_nb_loop_for_perturbation,
        get_perturbation_sce_file
    )

    # Configuration - IDENTIQUE à subSce_mapping_001.py
    bkg_map = [
        {
            "name": "bkg",
            "offset": 1,
            "duration": 16,
            "sce_name": "bkg_13UEs_SFE_TMO.txt"
        }
    ]

    subSce_map = [
        {
            "name": "subSce1",
            "offset": 6,
            "duration": 2,
            "sce_name": "Perturbation_5GC000937_001.sce"
        },
        {
            "name": "subSce2",
            "offset": 12,
            "duration": 2,
            "sce_name": "Perturbation_5GC000937_001.sce"
        }
    ]

    # Initialize (comme dans le Prelude)
    from pm_test_configurator import get_test_configuration
    config = get_test_configuration(bkg_map, subSce_map)

    # Test keywords
    print("\nTesting Robot Keywords:")

    start_pm_bg1 = get_start_pm_index_for_background(1)
    nb_loop_bg1 = get_nb_loop_for_background(1)
    print(f"  Background_IC_01: start_pm={start_pm_bg1}, nb_loop={nb_loop_bg1}")
    assert start_pm_bg1 == 1
    assert nb_loop_bg1 == 5

    start_pm_pert1 = get_start_pm_index_for_perturbation(1)
    nb_loop_pert1 = get_nb_loop_for_perturbation(1)
    sce_file_pert1 = get_perturbation_sce_file(1)
    print(f"  Perturbation_01: start_pm={start_pm_pert1}, "
          f"nb_loop={nb_loop_pert1}, sce={sce_file_pert1}")
    assert start_pm_pert1 == 6
    assert nb_loop_pert1 == 2
    assert sce_file_pert1 == "Perturbation_5GC000937_001.sce"

    start_pm_bg2 = get_start_pm_index_for_background(2)
    nb_loop_bg2 = get_nb_loop_for_background(2)
    print(f"  Background_IC_02: start_pm={start_pm_bg2}, nb_loop={nb_loop_bg2}")
    assert start_pm_bg2 == 8
    assert nb_loop_bg2 == 4

    start_pm_pert2 = get_start_pm_index_for_perturbation(2)
    nb_loop_pert2 = get_nb_loop_for_perturbation(2)
    sce_file_pert2 = get_perturbation_sce_file(2)
    print(f"  Perturbation_02: start_pm={start_pm_pert2}, "
          f"nb_loop={nb_loop_pert2}, sce={sce_file_pert2}")
    assert start_pm_pert2 == 12
    assert nb_loop_pert2 == 2
    # Même fichier que subSce1
    assert sce_file_pert2 == "Perturbation_5GC000937_001.sce"

    start_pm_bg3 = get_start_pm_index_for_background(3)
    nb_loop_bg3 = get_nb_loop_for_background(3)
    print(f"  Background_IC_03: start_pm={start_pm_bg3}, nb_loop={nb_loop_bg3}")
    assert start_pm_bg3 == 14
    assert nb_loop_bg3 == 3

    print("\n✅ ROBOT KEYWORDS TEST PASSED\n")


def main():
    """Run all tests."""
    print("\n" + "=" * 80)
    print("TESTING PM TEST CONFIGURATOR")
    print("=" * 80)

    try:
        test_configuration_1sub()
        test_configuration_2sub()
        test_robot_keywords()

        print("\n" + "=" * 80)
        print("✅ ALL TESTS PASSED")
        print("=" * 80 + "\n")
        return 0

    except AssertionError as e:
        print(f"\n❌ TEST FAILED: {e}\n")
        return 1
    except Exception as e:
        print(f"\n❌ ERROR: {e}\n")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
