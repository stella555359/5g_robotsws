import subprocess
import sys
import string
import csv
import os
import re
from datetime import datetime
import argparse


def install_and_import(package):
    try:
        __import__(package)
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def list_files_with_pattern(path, pattern):
    try:
        files = [f for f in os.listdir(path) if re.match(pattern, f)]
        return sorted(files)
    except FileNotFoundError:
        print(f"the directory {path} does not exist")
        return []


def get_feature_directories(base_path):
    feature_dirs = []
    for feature_name in os.listdir(base_path):
        feature_path = os.path.join(base_path, feature_name)
        counter_path = os.path.join(feature_path, 'Counter')
        if os.path.isdir(counter_path):
            feature_dirs.append(feature_name)
    return feature_dirs


def extract_param_value(line, param_pattern):
    match = re.match(param_pattern, line)
    if match:
        return match.group(4)
    return None


def extract_nr_entity_v02(line):
    nr_entity_child = ("NRCELL", "NRDU", "NRCUUP", "MNLENT")
    nr_entity_top = ("NRBTS", "MNL")
    parts = re.split(r'/(?=@)', line, maxsplit=1)
    elements = parts[0].split('/')
    default_name = "None"
    default_id_value = "None"

    for element in elements:
        if '@id' in element:
            name, id_part = element.split("[@id='")
            id_value = id_part.rstrip("']")
        else:
            name = element
            id_value = None

        if name in nr_entity_child:
            return name, id_value

        if name in nr_entity_top:
            default_name = name
            default_id_value = id_value

    return default_name, default_id_value


def parse_dictionnary(whichMetric):
    print(f"DBG: date parse_dictionnary début = {datetime.now()}")
    KPI_list = '/home/ute/CrtRoot/robotws/testsuite/Paris/resources/SWENG/config/KPI/SBTS00/KPI_Definitions.csv'
    Counter_list = '/home/ute/CrtRoot/robotws/testsuite/Paris/resources/SWENG/config/KPI/SBTS00/Counter_Definitions.csv'
    kpi_list_all = []
    counter_list_all = []

    if whichMetric in ('kpi', 'all'):
        print(f"DBG: parse_dictionnary kpi/all whichMetric = {whichMetric}")
        with open(KPI_list, 'r') as file:
            lines = file.readlines()
        for line in lines:
            kpi_value = line.split(';')[0]
            if kpi_value.startswith('NR_'):
                if kpi_value[-1].isupper():
                    kpi_list_all.append(kpi_value[:-1])
                else:
                    kpi_list_all.append(kpi_value)

    if whichMetric in ('counter', 'all'):
        print(f"DBG: parse_dictionnary counter/all whichMetric = {whichMetric}")
        with open(Counter_list, 'r') as file:
            lines = file.readlines()
        for line in lines:
            counter_value = line.split(';')[0]
            if counter_value.startswith('M'):
                counter_list_all.append(counter_value)

    return kpi_list_all + counter_list_all


def create_history_csv(metrics_data, times, path):
    print(f"DBG create_history_csv - date = {datetime.now()}")
    print(f"DBG create_history_csv - metrics_data = {metrics_data}")
    print(f"DBG create_history_csv - times = {times}")
    print(f"DBG create_history_csv - path = {path}")
    csv_file = os.path.join(path, 'metrics_data_history.csv')
    excel_file = os.path.join(path, 'metrics_data_history.xlsx')
    print(f"DBG create_history_csv - csv_file = {csv_file}")
    print(f"DBG create_history_csv - excel_file = {excel_file}")
    with open(csv_file, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=';')

        header = ['KPI', 'object'] + times
        print(header)
        csvwriter.writerow(header)

        for metric, nr_entity_groups in metrics_data.items():
            for nr_entity_group, values in nr_entity_groups.items():
                row = [metric, nr_entity_group] + values
                csvwriter.writerow(row)

    print("history has been saved under metrics_data_history.csv.")

    df = pd.read_csv(csv_file, delimiter=';')

    with pd.ExcelWriter(excel_file, engine='xlsxwriter') as writer:
        df.to_excel(writer, index=False, sheet_name='metrics')
        worksheet = writer.sheets['metrics']
        worksheet.freeze_panes(1, 0)
        worksheet.autofilter(0, 0, 0, len(df.columns) - 1)

        left_align_format = writer.book.add_format({'align': 'left'})

        for i, col in enumerate(df.columns):
            max_len = max(df[col].astype(str).map(len).max(), len(col))
            worksheet.set_column(i, i, max_len, left_align_format)

        print("history has been saved under metrics_data_history.xlsx.")
        print(f"DBG date create_history_csv fin = {datetime.now()}")

    return excel_file


def create_plot(metrics, metrics_data, times, feature_and_test):
    for metric in metrics:
        for nr_entity_group, values in metrics_data[metric].items():
            plt.plot(times, values, label=metric + "_" + nr_entity_group)
    plt.xlabel('time')
    plt.ylabel('value')
    plt.title(feature_and_test)
    plt.legend()
    plt.xticks(rotation=45)
    plt.show()
    # plt.savefig('plot.png')  # save the plot


def filter_PM_file_list(files, PM_file_pattern, history_days):
    filtred_PM_files = {}
    now = datetime.now()
    current_date_YYMMDD = now.strftime('%y%m%d')
    current_date_YYMMDD = datetime.strptime(current_date_YYMMDD, '%y%m%d')
    for file in files:
        time_match = re.match(PM_file_pattern, file)
        if time_match:
            time = str(time_match.group(1)) + str(time_match.group(5))
            file_date = time_match.group(2) + time_match.group(3) + time_match.group(4)
            file_date_YYMMDD = datetime.strptime(file_date, '%y%m%d')
            age_file = current_date_YYMMDD - file_date_YYMMDD
            age_file_days = abs(age_file.days)
            if age_file_days > int(history_days):
                continue
        if file not in filtred_PM_files:
            filtred_PM_files[file] = time
            print(f"file '{file}' added to be analysed with time value = {time}.")
        else:
            print(f"ERR: file '{file}' is already present in the list of file to analyse")
            raise ValueError("PM file unicity is mandatory!")
    sorted_PM_files = dict(sorted(filtred_PM_files.items(), key=lambda item: item[1], reverse=True))
    print(f"sorted_PM_files = {sorted_PM_files}")
    return sorted_PM_files


def compare_two_files(pm_history_excel, path, deviation, delta):
    print(f"DBG compare_two_files - date = {datetime.now()} running...")
    result_fail = 'all metrics are passed'
    delta_min = float(delta)
    max_deviation = int(deviation)
    signal_file = os.path.join(path, 'signal_file.txt')
    df = pd.read_excel(pm_history_excel)
    File01 = df.columns[2]
    File02 = df.columns[3]
    df['Delta'] = df.iloc[:, 3] - df.iloc[:, 2]
    # df['Percentage Deviation'] = (df.iloc[:, 2] - df.iloc[:, 3]) / df.iloc[:, 2] * 100
    df['Percentage Deviation'] = df.apply(
        # lambda row: int(round((row.iloc[3] - row.iloc[2]) / row.iloc[2] * 100)) if row.iloc[2] != 0 else None,
        lambda row: int(round((row.iloc[3] - row.iloc[2]) / row.iloc[2] * 100)) if pd.notna(row.iloc[2])
        and pd.notna(row.iloc[3]) and row.iloc[2] != 0 else None,
        axis=1
    )

    # add a new column with 'FAIL' if :
    # - absolute value of deviation above max value AND delta is above delta _min value, else 'PASS'
    # df['Status'] = df['Percentage Deviation'].apply(lambda x: 'FAIL' if x > max_deviation else 'PASS')
    df['Status'] = df.apply(
        lambda row:
        'FAIL' if abs(row['Percentage Deviation']) > max_deviation and abs(row['Delta']) > delta_min else 'PASS',
        axis=1
    )
    # Filtre the lines where the status is 'FAIL'
    failed_items = df[df['Status'] == 'FAIL']
    # get the value with the 'Status'
    result_fail = failed_items.iloc[:, [0, 1, 2, 3, 4, 5, df.columns.get_loc('Status')]]
    # columns_to_select = [0, 1, df.columns.get_loc('Percentage Deviation'), df.columns.get_loc('Status')]
    # result_fail = failed_items.iloc[:, columns_to_select]

    result_fail = result_fail.to_csv(sep=';', index=False)
    print(result_fail)
    result_file = str(File01) + '_delta_' + str(File02) + '_above_' + str(max_deviation) + '_deviation.txt'
    result_file = os.path.join(path, result_file)
    print(f"metrics with deviation > {max_deviation} AND delta > {delta_min} are saved under {result_file}")
    with open(result_file, 'w') as f:
        f.write(result_fail)

    with pd.ExcelWriter(os.path.join(path, 'metrics_data_history_comp.xlsx'), engine='xlsxwriter') as writer:
        df.to_excel(writer, index=False, sheet_name='metrics')
        worksheet = writer.sheets['metrics']
        worksheet.freeze_panes(1, 0)
        worksheet.autofilter(0, 0, 0, len(df.columns) - 1)

    # save the DataFrame modified in a CSV file
    df.to_csv(os.path.join(path, 'metrics_data_history_comp.csv'), index=False)

    print("file 'metrics_data_history_comp.xlsx' has been created")
    print(f"DBG compare_two_files - return result_file = {result_file}")
    with open(signal_file, "w") as signal:
        signal.write(result_file)
    return result_file


def get_two_most_recent_csv_files(directory, extension):
    files = os.listdir(directory)
    # keep only csv files
    csv_files = [file for file in files if file.endswith(extension)]
    # get full path for each csv file
    csv_files_with_time = [(file, os.path.getmtime(os.path.join(directory, file))) for file in csv_files]
    # order files
    csv_files_with_time.sort(key=lambda x: x[1], reverse=True)
    # get the two latest files
    most_recent_csv_files = [file[0] for file in csv_files_with_time[:2]]

    return most_recent_csv_files


def parse_files_and_plot(path, metrics, PM_file_pattern, feature_and_test, history_days, compare, deviation, delta):
    print(f"DBG parse_files_and_plot - date = {datetime.now()}")
    print(f"DBG parse_files_and_plot - path = {path}")
    print(f"DBG parse_files_and_plot - metrics = {metrics}")
    print(f"DBG parse_files_and_plot - PM_file_pattern = {PM_file_pattern}")
    print(f"DBG parse_files_and_plot - feature_and_test = {feature_and_test}")
    print(f"DBG parse_files_and_plot - history_days = {history_days}")
    print(f"DBG parse_files_and_plot - compare = {compare}")
    print(f"DBG parse_files_and_plot - deviation = {deviation}")
    plot_show = True
    print_in_file = True
    compare_pm = False
    files = list_files_with_pattern(path, PM_file_pattern)
    PM_files = filter_PM_file_list(files, PM_file_pattern, history_days)
    values = []
    times = []
    metricsCsv = {}
    matching_metric = next((x for x in ["all", "kpi", "counter"] if x in metrics), None)
    if matching_metric:
        print(f"DBG: metrics = {metrics} - matching_metric = {matching_metric}")
        plot_show = False
        metrics = parse_dictionnary(matching_metric)
    elif os.path.isfile(metrics[0]) and metrics[0].endswith('.csv'):
        with open(metrics[0], 'r') as file:
            for line in file:
                match_kpi = re.match(r'^(NR_\d+)', line.strip())
                if match_kpi:
                    key = match_kpi.group(1)
                    metricsCsv[key] = line.strip()
        metrics = list(metricsCsv.keys())
        print(f"DBG: metrics from csv:\n {metrics}\n")
        print(f"DBG: metric definition:")
        plot_show = False
        for value in metricsCsv.values():
            print(value)
    else:
        print(f"DBG: metrics = {metrics}")
        plot_show = True
    if compare == 'yes':
        plot_show = False
        compare_pm = True
        print(f"DBG: compare = {compare}")
        PM_files_01 = choose_from_list(PM_files, "select a first file:")
        PM_files_02 = choose_from_list(PM_files, "select a second file:")
        print(f"file 01 = {PM_files_01} - file 02 = {PM_files_02}")
        PM_files = {PM_files_01[0]: PM_files_01[1], PM_files_02[0]: PM_files_02[1]}
        print(f"comparing PM files: {PM_files}")
    if compare == 'last':
        plot_show = False
        compare_pm = True
        print(f"DBG: compare = {compare}")
        first_two_items = list(PM_files.items())[:2]
        PM_files = dict(first_two_items)
        print(f"comparing PM files: {PM_files}")
        if len(first_two_items) != 2:
            print(f"WRN: compare needs two pm files to run => comparison canceled !")
            compare_pm = False
            print_in_file = False
            with open(os.path.join(path, 'signal_file.txt'), "w") as signal:
                signal.write(os.path.join(path, 'signal_file.txt'))

    metrics_data = {metric: {} for metric in metrics}
    print(f"parse file with metrics = {metrics}, \nplease wait...")
    print(f"DBG: parse_files_and_plot - date before loop for file in files = {datetime.now()}")

    file_number = 0
    for file, time in PM_files.items():
        file_number = file_number + 1
        print(f"INF: file = {file} - time = {time} - file_number = {file_number}")
        with open(os.path.join(path, file), 'r') as f:
            for line in f:
                for metric in metrics:
                    if f'@{metric};' in line:
                        nr_entity_type, nr_entity_id = extract_nr_entity_v02(line)
                        nr_entity_group = nr_entity_type + "_" + nr_entity_id
                        parts = line.strip().split(';')
                        param_value = float(parts[1])
                        if time not in times:
                            times.append(time)
                        if nr_entity_group in metrics_data[metric]:
                            nombre_elements = len(metrics_data[metric][nr_entity_group])
                            if nombre_elements >= file_number:
                                print(
                                    f"WRN: file = {file} metric = {metric} - nr_entity_type = {nr_entity_type} - "
                                    f"nr_entity_group = {nr_entity_group}: ELEMENT ALREADY EXIST => IGNORED"
                                    )
                                continue
                        if nr_entity_group not in metrics_data[metric]:
                            metrics_data[metric][nr_entity_group] = []
                        metrics_data[metric][nr_entity_group].append(param_value)
                        break
    print(f"all files have been parsed, starting post analyse")
    print(f"DBG: parse_files_and_plot - end of parsing file - date = {datetime.now()}")
    for metric in metrics:
        for nr_entity_group, values in metrics_data[metric].items():
            if len(times) != len(values):
                print(f"ERR: nb of points 'times' ({len(times)}) "
                      f"!= 'values' ({len(values)}) for {nr_entity_group} / {metric}")

    if plot_show:
        create_plot(metrics, metrics_data, times, feature_and_test)
    if print_in_file:
        pm_history_excel = create_history_csv(metrics_data, times, path)
    if compare_pm:
        compare_result = compare_two_files(pm_history_excel, path, deviation, delta)
        print(f"DBG parse_files_and_plot - return compare_result = {compare_result}")
        return compare_result
    return None


def choose_from_list(options, prompt):
    print(prompt)
    if isinstance(options, list):
        for i, option in enumerate(options):
            print(f"{i + 1}. {option}")
        choice = int(input("Choose from the list: ")) - 1
        return options[choice]
    elif isinstance(options, dict):
        keys = list(options.keys())
        for i, key in enumerate(keys):
            print(f"{i + 1}. {key}")
        choice = int(input("Choose from the list: ")) - 1
        file = keys[choice]
        time = options[keys[choice]]
        return file, time
    else:
        raise TypeError("option must be either a list or a dict")


def format_entry(value):
    # remove double quote if any
    value = value.replace('"', '')
    # remove blank if any
    value = value.replace(' ', '')
    # remove blank if any
    value = value.strip()
    return value


def format_entry_regex(value):
    import re
    value = re.sub(r'\s+', ' ', value)
    return value


def main(base_path, feature_name, test_name, history_days, metrics, compare, deviation, delta):
    print(f"DBG main - date = {datetime.now()}")
    print(f"DBG main - feature_name : {feature_name}")
    print(f"DBG main - test_name : {test_name}")
    print(f"DBG main - metrics : {metrics}")
    print(f"DBG main - history_days : {history_days} days")
    print(f"DBG main - comparison tag : {compare}")
    print(f"DBG main - deviation : {deviation}")
#    if "kpi" in metrics:
    if any("kpi" in metric.lower() for metric in metrics):
        PM_file_pattern = r"PM\.BTS-1\.\d{2}((\d{2})(\d{2})(\d{2}))\.(\d{4})\d{2}\.(ANY\.KPI)\.csv"
#    elif "counter" in metrics:
    elif any("counter" in metric.lower() for metric in metrics):
        PM_file_pattern = r"PM\.BTS-1\.\d{2}((\d{2})(\d{2})(\d{2}))\.(\d{4})\d{2}\.(ANY)\.csv"
    elif compare != 'no' and metrics == 'all':
        print(f"WAR if compare = yes or last, comparison is limited to kpi or counter, not both\
                => metrics value 'all' has been changed to 'counter'")
        metrics = ['counter']
        PM_file_pattern = r"PM\.BTS-1\.\d{2}((\d{2})(\d{2})(\d{2}))\.(\d{4})\d{2}\.(ANY)\.csv"
    else:
        PM_file_pattern = r"PM\.BTS-1\.\d{2}((\d{2})(\d{2})(\d{2}))\.(\d{4})\d{2}\.(ANY|ANY\.KPI)\.csv"

    if feature_name is None:
        feature_names = get_feature_directories(base_path)
        feature_name = choose_from_list(feature_names, "Select a feature:")

    if base_path == '/ceph/VRF/COMMON/TranRob':
        feature_path = os.path.join(base_path, feature_name, "Counter/SBTS00")
    else:
        feature_path = os.path.join(base_path, feature_name, "Counter")

    if test_name is None:
        test_names = list_files_with_pattern(feature_path, ".*")
        test_name = choose_from_list(test_names, "Select a test:")

    feature_path = format_entry(feature_path)
    test_name = format_entry(test_name)

    final_path = os.path.join(feature_path, test_name)
    final_path = format_entry(final_path)
    feature_and_test = feature_name + "_" + test_name
    feature_and_test = format_entry(feature_and_test)
    print(f"Parsing files in directory: {final_path}")

    result = parse_files_and_plot(
        final_path, metrics, PM_file_pattern, feature_and_test, history_days, compare, deviation, delta
    )
    return result


if __name__ == "__main__":

    # list of libraries to be installed if not already present
    packages = ['xlsxwriter', 'openpyxl', 'matplotlib', 'pandas']

    for package in packages:
        install_and_import(package)

    # import after install
    import pandas as pd
    import matplotlib.pyplot as plt
    from openpyxl import load_workbook
    from openpyxl.styles import Alignment

    parser = argparse.ArgumentParser(description="Script with eight paramters")

    # following params are optionnal
    parser.add_argument('--path', type=str, default='/ceph/VRF/COMMON/TranRob',
                        help='path to the feature, default = /ceph/VRF/COMMON/TranRob')
    parser.add_argument('--feature', type=str, default=None,
                        help='name of the feature, default = multiple choice')
    parser.add_argument('--test', type=str, default=None,
                        help='name of the test , default = multiple choice')
    parser.add_argument('--history', type=str, default='15',
                        help='number of days for the history, default = 15 days')
    parser.add_argument('--compare', type=str, default='no',
                        help='compare the counter one by one between two PM files: no / yes / last, default = no')
    parser.add_argument('--deviation', type=str, default='10',
                        help='max value for the deviation when compare between two PM files, default = 10')
    parser.add_argument('--delta', type=str, default='0.01',
                        help='min value for the delta when compare between two PM files, default = 0.01')

    # following param is mandatory, it is either a list from 1 to N elements or one of the three possible tags
    parser.add_argument(
                        'metrics', nargs='+',
                        help=f'list of KPIs and/or Counters (M55316C02000 M55316C03001 NR_371 NR_417 NR_5054 ...)\n'
                        f' or tag (all / kpi / counter) to use SWENG/config/KPI/SBTS00/ definition\n'
                        f' or file (my_kpi.csv / my_counter.csv) for specific file\n'
                        )

    args = parser.parse_args()

    # call the main fonction
    main(args.path, args.feature, args.test, args.history, args.metrics, args.compare, args.deviation, args.delta)
