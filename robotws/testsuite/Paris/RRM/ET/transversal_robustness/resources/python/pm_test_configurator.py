"""
PM Test Configurator - Configuration automatique des test cases Robot Framework.

Ce module utilise pm_segment_analyzer pour calculer automatiquement les paramètres
des test cases (Background_IC_XX et Perturbation_XX) à partir des mappings de
configuration (subSce_mapping).

Usage dans Robot Framework:
    Library    ./resources/python/pm_test_configurator.py

    ${config}    Get Test Configuration    ${bkg_map_TMO_SFE_LTD}    ${subSce_map_TMO_SFE_LTD_2SUB_937_001}
"""

from typing import Dict, List, Any, Optional
from pm_segment_analyzer import PMPeriodSegmentAnalyzer


class PMTestConfigurator:
    """
    Configurateur de tests basé sur l'analyse des segments PM.

    Cette classe calcule automatiquement les paramètres pour chaque test case
    (Background_IC et Perturbation) en fonction de la configuration PM.
    """

    ROBOT_SCOPE = 'GLOBAL'

    def __init__(self):
        """Initialize le configurateur."""
        self.analyzer = PMPeriodSegmentAnalyzer()
        self.analysis_result = None
        self.test_configs = {}

    def get_test_configuration(
            self, background_mapping: List[Dict[str, Any]],
            subscenario_mapping: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Génère la configuration complète pour tous les test cases.

        Args:
            background_mapping: Configuration du background (bkg_map)
            subscenario_mapping: Configuration des perturbations (subSce_map)

        Returns:
            Dictionnaire avec la configuration de chaque test

        Example Robot Framework:
            ${config}    Get Test Configuration    ${bkg_map_TMO_SFE_LTD}    ${subSce_map_TMO_SFE_LTD_2SUB_937_001}
            ${bg_config}    Get From Dictionary    ${config}    Background_IC_01
            ${start_pm}     Get From Dictionary    ${bg_config}    start_pm_index
        """
        # Extract background parameters
        if not background_mapping:
            raise ValueError("Background mapping cannot be empty")

        bkg = background_mapping[0]
        initial_offset = bkg.get('offset', 1)
        total_periods = bkg.get('duration', 16)

        # Analyze segments
        self.analysis_result = self.analyzer.analyze_segments(
            initial_offset=initial_offset,
            total_periods=total_periods,
            subscenario_list=subscenario_mapping,
            allow_overlaps=False
        )

        # Generate configuration for each test case
        self.test_configs = self._generate_test_configs(subscenario_mapping)

        return self.test_configs

    def _generate_test_configs(self, subscenario_mapping: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Génère les configurations pour chaque test case.

        Returns:
            Dictionnaire avec la configuration de chaque test case
        """
        configs = {}
        background_counter = 1
        perturbation_counter = 1

        # Process all segments in order
        for segment in self.analysis_result['all_segments_ordered']:
            seg_type = segment['type']
            offset = segment['offset']
            duration = segment['duration']

            if seg_type == 'free':
                # Background test case
                test_name = f"Background_IC_{background_counter:02d}"

                configs[test_name] = {
                    'test_name': test_name,
                    'type': 'background',
                    'start_pm_index': offset,
                    'nb_loop': duration,
                    'perturbation_sce': 'wait',
                    'pm_start': offset,
                    'pm_end': offset + duration - 1,
                    'duration_periods': duration
                }

                background_counter += 1

            else:
                # Perturbation test case
                test_name = f"Perturbation_{perturbation_counter:02d}"

                # Find the scenario file from subscenario mapping
                sce_file = None
                scenario_name = segment.get('name', '')

                for sub in subscenario_mapping:
                    if sub.get('name') == scenario_name and sub.get('offset') == offset:
                        sce_file = sub.get('sce_name', 'unknown.sce')
                        break

                configs[test_name] = {
                    'test_name': test_name,
                    'type': 'perturbation',
                    'start_pm_index': offset,
                    'nb_loop': duration,
                    'perturbation_sce': sce_file,
                    'pm_start': offset,
                    'pm_end': offset + duration - 1,
                    'duration_periods': duration,
                    'scenario_name': scenario_name
                }

                perturbation_counter += 1

        return configs

    def get_background_config(self, test_number: int) -> Dict[str, Any]:
        """
        Récupère la configuration pour un test Background_IC spécifique.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Configuration du test

        Example Robot Framework:
            ${config}    Get Background Config    1
            ${start_pm}  Get From Dictionary    ${config}    start_pm_index
        """
        # Convert to int if needed (Robot Framework may pass as string)
        test_number = int(test_number)
        test_name = f"Background_IC_{test_number:02d}"

        if test_name not in self.test_configs:
            raise ValueError(f"Test {test_name} not found in configuration")

        return self.test_configs[test_name]

    def get_perturbation_config(self, test_number: int) -> Dict[str, Any]:
        """
        Récupère la configuration pour un test Perturbation spécifique.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Configuration du test

        Example Robot Framework:
            ${config}    Get Perturbation Config    1
            ${sce_file}  Get From Dictionary    ${config}    perturbation_sce
        """
        # Convert to int if needed (Robot Framework may pass as string)
        test_number = int(test_number)
        test_name = f"Perturbation_{test_number:02d}"

        if test_name not in self.test_configs:
            raise ValueError(f"Test {test_name} not found in configuration")

        return self.test_configs[test_name]

    def get_start_pm_index_for_background(self, test_number: int) -> int:
        """
        Récupère le start_pm_index pour un test Background_IC.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Indice PM de départ

        Example Robot Framework:
            ${start_pm}    Get Start PM Index For Background    1
        """
        config = self.get_background_config(test_number)
        return config['start_pm_index']

    def get_nb_loop_for_background(self, test_number: int) -> int:
        """
        Récupère le nb_loop pour un test Background_IC.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Nombre de boucles (durée en périodes PM)

        Example Robot Framework:
            ${nb_loop}    Get Nb Loop For Background    1
        """
        config = self.get_background_config(test_number)
        return config['nb_loop']

    def get_start_pm_index_for_perturbation(self, test_number: int) -> int:
        """
        Récupère le start_pm_index pour un test Perturbation.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Indice PM de départ

        Example Robot Framework:
            ${start_pm}    Get Start PM Index For Perturbation    1
        """
        config = self.get_perturbation_config(test_number)
        return config['start_pm_index']

    def get_nb_loop_for_perturbation(self, test_number: int) -> int:
        """
        Récupère le nb_loop pour un test Perturbation.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Nombre de boucles (durée en périodes PM)

        Example Robot Framework:
            ${nb_loop}    Get Nb Loop For Perturbation    1
        """
        config = self.get_perturbation_config(test_number)
        return config['nb_loop']

    def get_perturbation_sce_file(self, test_number: int) -> str:
        """
        Récupère le fichier de scénario pour un test Perturbation.

        Args:
            test_number: Numéro du test (1-based)

        Returns:
            Nom du fichier de scénario

        Example Robot Framework:
            ${sce_file}    Get Perturbation Sce File    1
        """
        config = self.get_perturbation_config(test_number)
        return config['perturbation_sce']

    def print_test_configuration(self):
        """
        Affiche la configuration de tous les tests (pour debug).

        Example Robot Framework:
            Print Test Configuration
        """
        if not self.test_configs:
            print("No test configuration available")
            return

        print("\n" + "=" * 80)
        print("TEST CONFIGURATION FROM PM ANALYSIS")
        print("=" * 80)

        for test_name, config in sorted(self.test_configs.items()):
            test_type = config['type'].upper()
            print(f"\n{test_name} [{test_type}]:")
            print(f"  PM Periods: {config['pm_start']} to {config['pm_end']} ({config['duration_periods']} periods)")
            print(f"  start_pm_index: {config['start_pm_index']}")
            print(f"  nb_loop: {config['nb_loop']}")

            if config['type'] == 'perturbation':
                print(f"  perturbation_sce: {config['perturbation_sce']}")
                print(f"  scenario_name: {config.get('scenario_name', 'N/A')}")
            else:
                print(f"  perturbation_sce: wait (background only)")

        print("\n" + "=" * 80 + "\n")

    def get_number_of_background_tests(self) -> int:
        """
        Retourne le nombre de tests Background_IC.

        Returns:
            Nombre de tests Background

        Example Robot Framework:
            ${nb_bg_tests}    Get Number Of Background Tests
        """
        return len([k for k in self.test_configs.keys() if k.startswith('Background_IC_')])

    def get_number_of_perturbation_tests(self) -> int:
        """
        Retourne le nombre de tests Perturbation.

        Returns:
            Nombre de tests Perturbation

        Example Robot Framework:
            ${nb_pert_tests}    Get Number Of Perturbation Tests
        """
        return len([k for k in self.test_configs.keys() if k.startswith('Perturbation_')])

    def get_total_pm_periods(self) -> int:
        """
        Retourne le nombre total de périodes PM.

        Returns:
            Nombre total de périodes PM

        Example Robot Framework:
            ${total_periods}    Get Total PM Periods
        """
        if not self.analysis_result:
            return 0
        return self.analysis_result['global_segment']['duration']


# Create singleton instance for Robot Framework
_configurator_instance = PMTestConfigurator()


def get_test_configuration(background_mapping, subscenario_mapping):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_test_configuration(background_mapping, subscenario_mapping)


def get_background_config(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_background_config(test_number)


def get_perturbation_config(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_perturbation_config(test_number)


def get_start_pm_index_for_background(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_start_pm_index_for_background(test_number)


def get_nb_loop_for_background(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_nb_loop_for_background(test_number)


def get_start_pm_index_for_perturbation(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_start_pm_index_for_perturbation(test_number)


def get_nb_loop_for_perturbation(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_nb_loop_for_perturbation(test_number)


def get_perturbation_sce_file(test_number):
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_perturbation_sce_file(test_number)


def print_test_configuration():
    """Robot Framework keyword wrapper."""
    _configurator_instance.print_test_configuration()


def get_number_of_background_tests():
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_number_of_background_tests()


def get_number_of_perturbation_tests():
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_number_of_perturbation_tests()


def get_total_pm_periods():
    """Robot Framework keyword wrapper."""
    return _configurator_instance.get_total_pm_periods()
