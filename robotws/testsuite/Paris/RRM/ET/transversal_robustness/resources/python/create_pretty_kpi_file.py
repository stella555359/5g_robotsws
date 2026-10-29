import os
import sys
from taf.analyzer.pmcounter import PMCounterLogReader
import time

dynamic_variable_names = []
constraints = []
oam_ids = []
counter_descriptions = {}


def clean_dynamic_variables():
    for dynamic_variable_name in dynamic_variable_names:
        del (globals()[dynamic_variable_name])
    dynamic_variable_names.clear()


def add_dynamic_variable(name, value):
    dynamic_variable_names.append(name)
    globals()[name] = float(value)


def read_counter_definitions(counter_def_file_name):
    with open(counter_def_file_name, "r") as counter_definitions:
        for line in counter_definitions.readlines():
            if line.startswith("#"):
                continue
            line_split = line.split(";")
            counter_id = line_split[0].strip()
            counter_descriptions[counter_id] = line_split[1].strip()


# Optimisation : prétraiter tous les chemins une seule fois
def preprocess_counters_by_oam_id(log_entry, oam_ids):
    pm_setup = log_entry.pm_setup
    counters_by_oam_id = {oam_id: [] for oam_id in oam_ids}
    for path in pm_setup.paths():
        end_of_oam_id_from_path = path.rfind("]")
        oam_id_from_path = path[:end_of_oam_id_from_path + 1]
        for oam_id in oam_ids:
            if oam_id_from_path.endswith(oam_id):
                counter_id = path.split("@")[-1]
                counter_values = pm_setup.xpath(path)
                if len(counter_values) != 1:
                    raise ValueError("Should be 1")
                counters_by_oam_id[oam_id].append((counter_id, counter_values[0]))
                break  # Un chemin ne correspond qu'à un oam_id
    return counters_by_oam_id


def create_counter_variables_from_dict(counter_tuples):
    for counter_id, value in counter_tuples:
        counter_description = counter_descriptions.get(counter_id, "unknown")
        add_dynamic_variable(counter_id, value)


def create_kpi_variables(kpi_def_file_name, timestamp, oam_id, destination_file):
    # pretty_file = open(destination_path + "/" + destination_file_name, "w")
    with open(kpi_def_file_name, "r") as kpi_definitions:
        for line in kpi_definitions.readlines():
            if line.startswith("#"):
                continue
            line_split = line.split(";")
            kpi_id = line_split[0].upper()
            if kpi_id[-1].isalpha():
                kpi_id = kpi_id[:-1]
            kpi_description = line_split[1]
            kpi_formula = line_split[2]
            # print(f"kpi_id = {kpi_id}, kpi_description = {kpi_description}, kpi_formula = {kpi_formula}")
            try:
                kpi_value = eval(kpi_formula)
                # print(f"Period {timestamp}, {oam_id}, {kpi_id}, {kpi_description}, {kpi_value}")
                destination_file.write(f"{oam_id}/@{kpi_id};{kpi_value};{kpi_description}\n")
                # add_dynamic_variable(kpi_id, kpi_value)
            except NameError:
                pass
            except ZeroDivisionError:
                pass


def get_counter_description(counter_id):
    counter_description = "UNKNOWN"
    counter_nidd = counter_id.split('@')[-1]
    print(f"counter_nidd = {counter_nidd}")
    if counter_nidd in counter_descriptions:
        counter_description = counter_descriptions[counter_nidd]
    return counter_description


include_patterns = ["NRCUUP", "NRDU", "NRCELL"]
exclude_patterns = ["NRPMQAP"]


def include_oam_ids(oam_ids, include_patterns):
    # Filtrer les éléments qui contiennent l'un des motifs dans 'include_patterns'
    filtered_list = [oam_id for oam_id in oam_ids if any(pattern in oam_id for pattern in include_patterns)]
    return filtered_list


def exclude_oam_ids(oam_ids, exclude_patterns):
    # Filtrer les éléments qui ne contiennent pas les motifs dans 'exclude_patterns'
    filtered_list = [oam_id for oam_id in oam_ids if not any(pattern in oam_id for pattern in exclude_patterns)]
    return filtered_list


def fill_oam_ids(log_entry):
    oam_ids.clear()
    pm_setup = log_entry.pm_setup
    print(f"PM interval start timestamp: {log_entry.timestamp}")
    for path in pm_setup.paths():
        end_of_oam_id_from_path = path.rfind("]")
        oam_id_from_path = path[:end_of_oam_id_from_path + 1]
        if oam_id_from_path not in oam_ids:
            oam_ids.append(oam_id_from_path)

    included_oam_ids = include_oam_ids(oam_ids, include_patterns)
    excluded_oam_ids = exclude_oam_ids(included_oam_ids, exclude_patterns)

    oam_ids.clear()
    oam_ids.extend(excluded_oam_ids)

    print(f"filtered oam_ids list len = {len(oam_ids)}")
    print(f"filtered oam_ids list =\n{oam_ids}")


def create_pretty_kpi_file(counter_file_name_with_path, destination_path, counter_def_file_name,
                           kpi_def_file_name):
    print("[TIMER] Début de create_pretty_kpi_file")
    t0 = time.time()
    os.makedirs(destination_path, exist_ok=True)
    print("[TIMER] Après os.makedirs:", time.time() - t0, "s")
    read_counter_definitions(counter_def_file_name)
    print("[TIMER] Après read_counter_definitions:", time.time() - t0, "s")
    counter_file_name = counter_file_name_with_path.split('/')[-1]
    pretty_kpi_file_name = counter_file_name.replace(".xml", ".KPI.csv")
    counter_file = open(counter_file_name_with_path, "rb")
    pretty_kpi_file = open(destination_path + "/" + pretty_kpi_file_name, "w")
    last_log_entry = None
    print("[TIMER] Avant lecture PMCounterLogReader:", time.time() - t0, "s")
    for log_entry in PMCounterLogReader(file_obj_iterator=[counter_file]):
        last_log_entry = log_entry
    print("[TIMER] Après lecture PMCounterLogReader:", time.time() - t0, "s")
    if last_log_entry is not None:
        fill_oam_ids(last_log_entry)
    print("[TIMER] Après fill_oam_ids:", time.time() - t0, "s")
    # Prétraitement des compteurs pour tous les oam_id
    t_pre = time.time()
    counters_by_oam_id = preprocess_counters_by_oam_id(last_log_entry, oam_ids)
    print("[TIMER] Après preprocess_counters_by_oam_id:", time.time() - t_pre, "s")
    for oam_id in oam_ids:
        t1 = time.time()
        create_counter_variables_from_dict(counters_by_oam_id[oam_id])
        print(f"[TIMER] create_counter_variables pour {oam_id}: ", time.time() - t1, "s")
        t2 = time.time()
        create_kpi_variables(kpi_def_file_name, last_log_entry.timestamp, oam_id, pretty_kpi_file)
        print(f"[TIMER] create_kpi_variables pour {oam_id}: ", time.time() - t2, "s")
        clean_dynamic_variables()
    print("[TIMER] Après boucle oam_ids:", time.time() - t0, "s")
    counter_file.close()
    pretty_kpi_file.close()
    print("[TIMER] Fin de create_pretty_kpi_file:", time.time() - t0, "s")
    return pretty_kpi_file_name.replace(".csv", "")


if __name__ == '__main__':
    create_pretty_kpi_file(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
