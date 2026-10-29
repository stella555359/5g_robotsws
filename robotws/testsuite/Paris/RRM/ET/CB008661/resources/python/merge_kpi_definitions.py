import sys
import time


def step1(mind_kpis_table_file_name, output_file_name):
    mind_kpis_table_file = open(mind_kpis_table_file_name, "r")
    output_file = open(output_file_name, "w")
    number_of_quotes = 0
    for line in mind_kpis_table_file.readlines():
        number_of_quotes += line.count('"')
        if number_of_quotes % 2 == 0:
            output_file.write(line)
        else:
            output_file.write(line.strip() + " ")
    mind_kpis_table_file.close()
    output_file.close()


def step2(input_file_name, output_file_name):
    current_date = time.strftime("%Y%02m%02d", time.localtime())
    input_file = open(input_file_name, "r")
    output_file = open(output_file_name, "w")
    for line in input_file.readlines():
        split_line = line.split(";")
        kpi_id = split_line[0].strip('"').upper()
        kpi_name = split_line[2].strip('"')
        # end_release = split_line[10].strip('"')
        kpi_formula = split_line[14].strip('"').upper()
        if ("LTE" in kpi_id) or ("NN" in kpi_id):
            continue
        if "_" in kpi_formula:
            # print(f"Ignoring KPI {kpi_id} because formula contains '_': {kpi_formula}")
            continue
        if kpi_formula.count("(") != kpi_formula.count(")"):
            # print(f"Ignoring KPI {kpi_id} because inconsistency in numbers of '(' and ')': {kpi_formula}")
            continue
        kpi_formula = kpi_formula.replace("[", "")
        kpi_formula = kpi_formula.replace("]", "")
        kpi_formula = kpi_formula.replace("SUM", "")
        kpi_formula = kpi_formula.replace("AVG", "")
        kpi_formula = kpi_formula.replace("MIN", "")
        kpi_formula = kpi_formula.replace("MAX", "")
        kpi_formula = kpi_formula.replace(" ", "")
        output_file.write(f"{kpi_id};{kpi_name};{kpi_formula};{current_date}\n")
    input_file.close()
    output_file.close()


def load_and_merge(input_file_name, kpi_database):
    input_file = open(input_file_name, "r")
    input_file.readline()
    for line in input_file.readlines():
        split_line = line.split(";", 1)
        kpi_id = split_line[0].upper().strip()
        end_of_line = split_line[1].strip()
        kpi_type = kpi_id.split("_")[0]
        kpi_id_in_type = kpi_id.split("_")[1]
        kpi_iteration = ""
        if kpi_id_in_type[-1] >= 'A':
            kpi_iteration = kpi_id_in_type[-1]
            kpi_id_in_type = kpi_id_in_type[0:-1]
        integer_id_in_type = int(kpi_id_in_type)
        if kpi_type not in kpi_database:
            kpi_database[kpi_type] = {}
        if (integer_id_in_type not in kpi_database[kpi_type]) or \
                (kpi_database[kpi_type][integer_id_in_type]["iter"] < kpi_iteration):
            kpi_database[kpi_type][integer_id_in_type] = {"iter": kpi_iteration, "end_of_line": end_of_line}
    input_file.close()


def dump_database(kpi_database, output_file_name):
    output_file = open(output_file_name, "w")
    output_file.write("#KPI ID;Name;Formula_from_MIND/JUMP\n")
    for kpi_type in kpi_database:
        for kpi_id_in_type in sorted(kpi_database[kpi_type]):
            output_file.write(f"{kpi_type}_{kpi_id_in_type}{kpi_database[kpi_type][kpi_id_in_type]['iter']};")
            output_file.write(f"{kpi_database[kpi_type][kpi_id_in_type]['end_of_line']}\n")
    output_file.close()


def merge_kpi_definitions(mind_kpis_table_file_name, git_kpi_def_file_name):
    mind_step1_file_name = mind_kpis_table_file_name + ".step1"
    step1(mind_kpis_table_file_name, mind_step1_file_name)
    mind_step2_file_name = mind_kpis_table_file_name + ".step2"
    step2(mind_step1_file_name, mind_step2_file_name)
    kpi_database = {}
    load_and_merge(git_kpi_def_file_name, kpi_database)
    load_and_merge(mind_step2_file_name, kpi_database)
    dump_database(kpi_database, git_kpi_def_file_name + ".new")


if __name__ == '__main__':
    merge_kpi_definitions(sys.argv[1], sys.argv[2])
