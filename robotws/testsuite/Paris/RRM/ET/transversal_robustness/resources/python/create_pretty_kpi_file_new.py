import os
import sys
from taf.analyzer.pmcounter import PMCounterLogReader
import re
import time

constraints = []
oam_ids = []
accumulated_counter_values = {}
kpi_associations = {}

INCLUDE_PATTERNS = ["NRBTS", "NRCELL"]
EXCLUDE_PATTERNS = ["NRPMQAP", "MCC"]

PATTERN1 = re.compile(r"(PLMN\[@id='PLMN'\]/(?:[A-Z]+\[@id='\d+'\]/)+)([A-Z0-9]+/@M55\d+C\d+)")


def extract_counters_from_formula(kpi_formula):
    import re
    tmp_counters = re.findall(r'M\d+C\d+', kpi_formula)
    counters = list(set(tmp_counters))
    return counters


def get_counter_xpaths(log_entry, counters):
    counter_xpaths = {}
    pm_setup = log_entry.pm_setup
    for path in pm_setup.paths():
        for counter in counters:
            if f"@{counter}" in path:
                if counter not in counter_xpaths:
                    counter_xpaths[counter] = []
                counter_xpaths[counter].append(path)
    return counter_xpaths


def sort_counters_by_xpath_depth(counter_xpaths):
    sorted_counter_xpaths = {}
    for counter, paths in counter_xpaths.items():
        sorted_counter_xpaths[counter] = sorted(paths, key=lambda path: path.count('/'))
    return sorted_counter_xpaths


def associate_kpi_with_sorted_oam_ids(log_entry, kpi_line):
    missing_counters = {}
    if kpi_line.startswith("#"):
        return None
    line_split = kpi_line.split(";")
    kpi_id = line_split[0].upper()
    if kpi_id[-1].isalpha():
        kpi_id = kpi_id[:-1]
    kpi_description = line_split[1]
    kpi_formula = line_split[2]
    print(f"kpi_id = {kpi_id}")
    print(f"kpi_description = {kpi_description}")
    print(f"kpi_formula = \n{kpi_formula}")

    expected_counters = extract_counters_from_formula(kpi_formula)
    print(f"expected_counters count = {len(expected_counters)}")
    time.sleep(3)
    print(f"expected_counters = \n{expected_counters}")
    counter_xpaths = get_counter_xpaths(log_entry, expected_counters)
    sorted_counter_xpaths = sort_counters_by_xpath_depth(counter_xpaths)

    # missing counters dictionnary must be filled here
    # ------------------------------------------------
    # TBD

    return {kpi_id: {'description': kpi_description, 'formula': kpi_formula, 'missing_counters': missing_counters,
                     'xpaths': sorted_counter_xpaths}}


def include_oam_ids(oam_ids):
    filtered_list = [oam_id for oam_id in oam_ids if any(pattern in oam_id for pattern in INCLUDE_PATTERNS)]
    return filtered_list


def exclude_oam_ids(oam_ids):
    filtered_list = [oam_id for oam_id in oam_ids if not any(pattern in oam_id for pattern in EXCLUDE_PATTERNS)]
    return filtered_list


def fill_oam_ids(log_entry):
    oam_ids.clear()
    pm_setup = log_entry.pm_setup
    print(f"PM interval start timestamp: {log_entry.timestamp}")
    oam_id_set = set()
    for path in pm_setup.paths():
        end_of_oam_id_from_path = path.rfind("]")
        oam_id_from_path = path[:end_of_oam_id_from_path + 1]
        oam_id_set.add(oam_id_from_path)
    oam_ids.extend(oam_id_set)

    included_oam_ids = include_oam_ids(oam_ids)
    excluded_oam_ids = exclude_oam_ids(included_oam_ids)

    oam_ids.clear()
    oam_ids.extend(excluded_oam_ids)

    print(f"filtered oam_ids list len = {len(oam_ids)}")
    print(f"filtered oam_ids list =\n{oam_ids}")


def evaluate_formula(log_entry, formula, formulas, xpaths, first_path_group1):
    pm_setup = log_entry.pm_setup
    values = {}
    for counter, path in xpaths.items():
        counter_values = pm_setup.xpath(path)
        if len(counter_values) != 1:
            raise ValueError(f"Expected one value for {counter}, but got {len(counter_values)}")
        values[counter] = float(counter_values[0])

    # Évaluer la formule en utilisant les valeurs des compteurs
    evaluated_formula = formula
    for counter, value in values.items():
        evaluated_formula = evaluated_formula.replace(counter, str(value))

    # Évaluer uniquement l'expression mathématique
    evaluated_value = eval(evaluated_formula)
    formulas.append((formula, first_path_group1, evaluated_value))
    return formulas


def check_and_construct_full_formulas_dict(kpi_associations, log_entry):
    full_formula_dict = {}
    for kpi_id, kpi_data in kpi_associations.items():
        xpaths = kpi_data['xpaths']
        kpi_formula = kpi_data['formula']
        kpi_description = kpi_data['description']  # Récupérer la description du KPI
        if not xpaths:
            time.sleep(30)
            continue
        num_items = len(next(iter(xpaths.values())))
        formulas = []
        for i in range(num_items):
            first_paths = {counter: paths[i] for counter, paths in xpaths.items()}
            all_same = True
            first_path_group1 = None
            # Vérifier si tous les chemins XPath sont identiques par rapport au premier chemin XPath
            first_path = next(iter(first_paths.values()))
            first_path_match = PATTERN1.search(next(iter(first_paths.values())))
            if first_path_match:
                first_path_group1 = first_path_match.group(1)
                for path in first_paths.values():
                    if PATTERN1.search(path).group(1) != first_path_group1:
                        all_same = False
                        break
            if all_same:
                evaluate_formula(log_entry, kpi_formula, formulas, first_paths, first_path_group1)
            else:
                evaluate_formula_2(xpaths, log_entry, kpi_formula, formulas, first_path_group1)
        full_formula_dict[kpi_id] = {'description': kpi_description, 'formulas': formulas}
    return full_formula_dict


def evaluate_formula_2(xpaths, log_entry, kpi_formula, formulas, first_path_group1):
    # Additionner les valeurs des compteurs pour les chemins XPath différents
    accumulated_values = {}
    for counter, paths in xpaths.items():
        accumulated_values[counter] = sum(float(log_entry.pm_setup.xpath(path)[0]) for path in paths)

    # Construire la formule avec les valeurs accumulées
    formula = kpi_formula
    for counter, value in accumulated_values.items():
        formula = formula.replace(counter, str(value))

    # Évaluer la formule
    try:
        evaluated_value = eval(formula, {"__builtins__": None}, {})
    except Exception as e:
        raise ValueError(f"Error evaluating formula: {e}")

    # formulas.append((formula, accumulated_values, evaluated_value))
    # formulas.append((kpi_formula, accumulated_values, evaluated_value))
    formulas.append((kpi_formula, first_path_group1, evaluated_value))
    return formulas


def construct_formula(kpi_formula, xpaths):
    formula = kpi_formula
    for counter, paths in xpaths.items():
        # Utiliser le premier chemin pour chaque compteur
        formula = formula.replace(counter, f"{counter}")
    return formula


def create_pretty_kpi_file(counter_file_name_with_path, destination_path, kpi_def_file_name):
    import json
    os.makedirs(destination_path, exist_ok=True)
    log_entry = None
    counter_file_name = counter_file_name_with_path.split('/')[-1]
    pretty_kpi_file_name = counter_file_name.replace(".xml", ".KPI.csv")
    counter_file = open(counter_file_name_with_path, "rb")
    pretty_kpi_file = open(destination_path + "/" + pretty_kpi_file_name, "w")
    log_reader = PMCounterLogReader(file_obj_iterator=[counter_file])
    try:
        log_entry = next(iter(log_reader))
    except StopIteration:
        print("No log entries found.")
    if log_entry is not None:
        fill_oam_ids(log_entry)
        with open(kpi_def_file_name, "r") as kpi_definitions:
            for line in kpi_definitions.readlines():
                kpi_association = associate_kpi_with_sorted_oam_ids(log_entry, line)
                if kpi_association:
                    kpi_associations.update(kpi_association)
        # Save kpi_associations in a JSON file needed for pytests
        # with open("./kpi_associations.json", "w") as json_file:
        #     json.dump(kpi_associations, json_file)

        full_formula_dict = check_and_construct_full_formulas_dict(kpi_associations, log_entry)
        # print(f"full_formula_dict.items() = {full_formula_dict.items()} ")
        for item1, item2 in full_formula_dict.items():
            kpi_id = item1
            description_value = item2['description']
            formulas = item2['formulas']
            for formula, path, value in formulas:
                completed_result_path = str(path) + "@" + str(kpi_id)
                completed_result_line = completed_result_path + ";" + f"{value:.3f}" + ";" + description_value
                pretty_kpi_file.write(completed_result_line + "\n")
    return kpi_associations
