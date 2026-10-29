import sys
from taf.analyzer.pmcounter import PMCounterLogReader

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


def create_counter_variables(log_entry, oam_id):
    pm_setup = log_entry.pm_setup
    for path in pm_setup.paths():
        end_of_oam_id_from_path = path.rfind("]")
        oam_id_from_path = path[:end_of_oam_id_from_path + 1]
        if oam_id_from_path.endswith(oam_id):
            counter_id = path.split("@")[-1]
            counter_values = pm_setup.xpath(path)
            if len(counter_values) != 1:
                raise ValueError("Should be 1")
            counter_description = "unknown"
            if counter_id in counter_descriptions:
                counter_description = counter_descriptions[counter_id]
            # following print is to be uncomment for debug purpose
            # print(f"Period {log_entry.timestamp}, {oam_id}, {counter_id}, {counter_description}, {counter_values[0]}")
            add_dynamic_variable(counter_id, counter_values[0])


def create_kpi_variables(kpi_def_file_name, timestamp, oam_id):
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
            try:
                kpi_value = eval(kpi_formula)
                # following print is to be uncomment for debug purpose
                # print(f"Period {timestamp}, {oam_id}, {kpi_id}, {kpi_description}, {kpi_value}")
                add_dynamic_variable(kpi_id, kpi_value)
            except NameError:
                pass
            except ZeroDivisionError:
                pass


def read_counter_definitions(counter_def_file_name):
    if counter_def_file_name != "":
        with open(counter_def_file_name, "r") as counter_definitions:
            for line in counter_definitions.readlines():
                if line.startswith("#"):
                    continue
                line_split = line.split(";")
                counter_id = line_split[0].strip()
                counter_descriptions[counter_id] = line_split[1].strip()


def read_constraints(constraint_file_name, topology):
    constraints.clear()
    oam_ids.clear()
    topology_baseband = "unknown"
    # following print is to be uncomment for debug purpose
    # print(f"topology: {topology}")
    if "5G_I_KL" in topology:
        topology_baseband = "ABIL"
    if "5G_I_BO" in topology:
        topology_baseband = "ABIO"
    # following print is to be uncomment for debug purpose
    # print(f"topology_baseband: {topology_baseband}")
    with open(constraint_file_name, "r") as constraint_file:
        for line in constraint_file.readlines():
            if line.startswith("#"):
                continue
            line_split = line.split(";")
            oam_id = line_split[0].strip()
            if oam_id not in oam_ids:
                oam_ids.append(oam_id)
            variant = line_split[4].strip()
            if variant == "ALL" or variant == topology_baseband:
                constraint = {"oam_id": oam_id, "parameter": line_split[1].strip().upper(),
                              "min": float(line_split[2]), "max": float(line_split[3]), "status": "NOT CHECKED"}
                constraints.append(constraint)


def check_oam_object_constraints(oam_id):
    for constraint in constraints:
        if constraint["oam_id"] == oam_id:
            parameter_name = constraint["parameter"]
            try:
                parameter_value = globals()[parameter_name]
                constraint["value"] = parameter_value
                if (parameter_value < constraint["min"]) or (parameter_value > constraint["max"]):
                    constraint["status"] = "FAILED"
                else:
                    constraint["status"] = "passed"
            except KeyError:
                pass


def evaluate_counter_and_kpi_constraints(counter_file_name, constraint_file_name, kpi_def_file_name,
                                         counter_def_file_name, topology):
    read_counter_definitions(counter_def_file_name)
    read_constraints(constraint_file_name, str(topology))

    with open(counter_file_name, "rb") as counter_file:
        for log_entry in PMCounterLogReader(file_obj_iterator=[counter_file]):
            for oam_id in oam_ids:
                create_counter_variables(log_entry, oam_id)
                create_kpi_variables(kpi_def_file_name, log_entry.timestamp, oam_id)
                check_oam_object_constraints(oam_id)
                clean_dynamic_variables()

    # BHR 20/01/2024: To be Used only for debug purpose
    # for constraint in constraints:
    #     print(c onstraint)
    #
    # for constraint in constraints:
    #     if constraint["status"] != "passed":
    #         print(f"Constraint is not passed:\n\t{constraint}")
    # BHR end

    return constraints


if __name__ == '__main__':
    evaluate_counter_and_kpi_constraints(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
