import os
import sys
import math             # BHR 18/06/2023    ADDED


def cust_print(level, string):
    out_string = f"evaluate_kpi_history/{level} - {string}"
    log_file.write(out_string + "\n")


def log_err(string):
    cust_print("ERR", string)


def log_missing(string):
    cust_print("ERRMIS", string)


def log_wrn(string):
    cust_print("WRN", string)


def log_inf(string):
    cust_print("INF", string)


def log_dbg(string):
    cust_print("DBG", string)


def system_command(the_command):
    log_dbg(f"Launching {the_command}")
    os.system(the_command)


def get_kpi_description(kpi_id, kpi_descriptions):
    kpi_description = "UNKNOWN"
    if kpi_id in kpi_descriptions:
        kpi_description = kpi_descriptions[kpi_id]
    return kpi_description


def eval_avg_and_deviation(num_list):                                      # BHR 18/06/2024  FUNCTION ADDED
    avg = sum(num_list) / len(num_list)
    var = sum([(xi - avg) ** 2 for xi in num_list]) / (len(num_list) - 1)
    sdev = math.sqrt(var)
    # log_inf(f"average of values list : { avg:.3f}")                       # TO BE ADD FOR DEBUG PURPOSE
    # log_inf(f"standard deviation is : {sdev:.3f}")                        # TO BE ADD FOR DEBUG PURPOSE
    return avg, sdev


def fill_history_data(history_data, kpi_file_name, kpi_descriptions):
    with open(kpi_file_name, "r") as kpi_file:
        for line in kpi_file.readlines():
            splitted_line = line.split(";")
            kpi_id = splitted_line[0]
            kpi_value = float(splitted_line[1].strip())
            kpi_descriptions[kpi_id] = splitted_line[-1].strip()
            if kpi_id not in history_data:
                history_data[kpi_id] = {}
            if kpi_file_name in history_data[kpi_id]:
                log_err(f"kpi {kpi_id} already filled for {kpi_file_name}")
            history_data[kpi_id][kpi_file_name] = kpi_value
        kpi_file.close()


def is_kpi_to_be_checked_from_file(test_name, kpi_id):
    list_excluded_missing_kpi = f"Counter/list_excluded_missing_kpi.csv"
    with open(list_excluded_missing_kpi, "r") as excluded_kpi:
        for line in excluded_kpi.readlines():
            splitted_line = line.split(";")
            if splitted_line[0] == "shall not be checked":
                if splitted_line[1] in test_name:
                    if splitted_line[2] in kpi_id:
                        print("kpi_id out of range but white listed = %s" % (kpi_id))
                        return False
    return True


def is_known_as_missing_from_file(kpi_id):
    list_excluded_missing_kpi = f"Counter/list_excluded_missing_kpi.csv"
    missing_list = []
    with open(list_excluded_missing_kpi, "r") as excluded_kpi:
        for line in excluded_kpi.readlines():
            splitted_line = line.split(";")
            if splitted_line[0] == "is known as misssing":
                missing_list.append(splitted_line[1])
    for kpi_pattern in missing_list:
        if kpi_pattern in kpi_id:
            print("kpi_id in known missing list = %s" % (kpi_id))
            return True
    return False


def check_history(history_data, kpi_file_name, kpi_descriptions, test_name):
    last_history_file_name = ""
    sd_dev_thresh_factor = 3.000                             # BHR 18/06/2024 ADDED
    kpi_dev_thresh_factor = 3.000                            # BHR 18/06/2024 ADDED
    s_dev_static = 0.001                                     # BHR 25/10/2024 ADDED
    s_dev = s_dev_static                                     # DTN 10/04/2025 ADDED to avoid reference before assignment
    for kpi_id in history_data:
        nb_of_samples = 0
        kpi_history = history_data[kpi_id]
        # log_dbg(f"kpi_id = {kpi_id}")                      # BHR 18/06/2024 ADDED FOR DEBUG PURPOSE
        initial_list_kpi_values = []                         # BHR 18/06/2024 ADDED
        refined_list_kpi_values = []                         # BHR 18/06/2024 ADDED

        for history_file_name in kpi_history:
            if history_file_name != kpi_file_name:
                if history_file_name > last_history_file_name:
                    last_history_file_name = history_file_name
                kpi_value = kpi_history[history_file_name]

                initial_list_kpi_values.append(kpi_value)    # BHR 18/06/2024 ADDED
                nb_of_samples += 1

        # log_dbg(f"Initial list of kpi values is:")           # BHR 18/06/2024 ADDED FOR DEBUG PURPOSE
        # log_dbg(initial_list_kpi_values)                     # BHR 18/06/2024 ADDED FOR DEBUG PURPOSE
        if nb_of_samples < 10:                                # BHR 25/10/2024 MODIFY FROM 5 --> 10
            log_wrn(f"not enough history samples ({nb_of_samples}) for {kpi_id}")
            continue
        if kpi_file_name not in kpi_history:
            if last_history_file_name in kpi_history:
                if is_known_as_missing_from_file(kpi_id):
                    log_wrn(f"{kpi_id} known as missing for {kpi_file_name}")
                else:
                    log_missing(f"no {kpi_id} for {kpi_file_name} (present in {last_history_file_name})")
            continue

        # BHR 18/06/2024 BEGIN : START SECTION ADDED
        # calculate of initial average standard deviation
        avg, sdev = eval_avg_and_deviation(initial_list_kpi_values)

        # refine list kpi values
        if avg < 0:
            if is_kpi_to_be_checked_from_file(test_name, kpi_id):
                log_err(f"{kpi_id}: avg {avg} is negative  in {test_name}")
                continue
            # BHR begin 25/10/2024 : log commented because not very usefull
            # else:
            # log_inf(f"{kpi_id}: avg {avg} is negative in {test_name}")

        if avg == 0 and sdev > 0:
            log_err(f"{kpi_id}: average of kpi values list {avg} is 0 value whereas "
                    f"standard deviation kpi value list {sdev} is positive  for {test_name}")
            continue

        if avg == 0 and sdev == 0:
            refined_list_kpi_values = initial_list_kpi_values

        # if avg > 0:

        mini = avg - (sd_dev_thresh_factor * sdev)
        maxi = avg + (sd_dev_thresh_factor * sdev)
        # log_inf(f"mini is : {mini:.3f} and maxi is : {maxi:.3f}")      # TO BE ADD FOR DEBUG PURPOSE
        refined_list_kpi_values = [xi for xi in initial_list_kpi_values if xi >= mini and xi <= maxi]

        # log_dbg(f"Refined list of kpi values is:")                         # TO BE ADD FOR DEBUG PURPOSE
        # log_dbg(refined_list_kpi_values)                                   # TO BE ADD FOR DEBUG PURPOSE

        # re calculate of average standard deviation from refined_list_kpi_values
        # BHR begin 25/10/2024 : if s_dev < s_dev_static assign s_dev with s_dev_static value
        avg, sdev = eval_avg_and_deviation(refined_list_kpi_values)
        if s_dev < 0.001:
            s_dev = s_dev_static
        refined_min = avg - (kpi_dev_thresh_factor * sdev)
        refined_max = avg + (kpi_dev_thresh_factor * sdev)
        # BHR 18/06/2024 END : END SECTION ADDED

        now_value = kpi_history[kpi_file_name]
        # log_inf(f"Current value is : {now_value}")               # BHR 18/06/2024 ADDED FOR DEBUG PURPOSE

        # BHR 18/06/2024 BEGIN ADD SECTION
        if now_value < refined_min or now_value > refined_max:
            kpi_description = get_kpi_description(kpi_id, kpi_descriptions)
            debug_string = f"[{refined_min} {nb_of_samples} {refined_max} {avg} {sdev}] ({kpi_description})"
            if is_kpi_to_be_checked_from_file(test_name, kpi_id):
                log_err(f"{kpi_id}: {now_value} out of hist range {debug_string} in {test_name}")
                log_err(F"refined_list_kpi_values = {refined_list_kpi_values}")
            # BHR begin 25/10/2024 : Comment else since not really usefull
            # else:
            # log_inf(f"{kpi_id}: {now_value} would be out of hist range {debug_string} in {test_name}")
            # BHR end
        # BHR end
    log_inf(f"End of {len(history_data)} kpis processing")


def evaluate_kpi_history(user, history_server, root_path, test_name, kpi_file_name):
    global log_file
    log_file = open("kpi_history.log", "a")
    relative_path = f"Counter/{test_name}"
    if os.path.exists("/home/ca_psci5g/.ssh/id_rsa_ute"):
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no -i /home/ca_psci5g/.ssh/id_rsa_ute"
    else:
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no"
    remote_path = f"{user}@{history_server}:{root_path}/{test_name}"
    system_command(f"ssh {options} {user}@{history_server} mkdir -p {root_path}/{test_name}/")
    system_command(f"scp {options} {relative_path}/{kpi_file_name} {remote_path}/")
    system_command(
        f"ssh {options} {user}@{history_server} 'ls -1 {root_path}/{test_name}/' | "
        f"grep ANY.KPI.csv | tail -n 20 > file_list.txt")
    history_dir = f"{relative_path}/history/"
    if not os.path.exists(history_dir):
        system_command(f"mkdir {history_dir}")
    with open("file_list.txt", "r") as file_list:
        history_kpi_file_names = file_list.readlines()
        history_data = {}
        kpi_descriptions = {}
        for line in history_kpi_file_names:
            history_kpi_file_name = line.strip()
            system_command(f"scp {options} {remote_path}/{history_kpi_file_name} {relative_path}/history/")
            fill_history_data(history_data, f"{relative_path}/history/{history_kpi_file_name}",
                              kpi_descriptions)
        check_history(history_data, f"{relative_path}/history/{kpi_file_name}", kpi_descriptions, test_name)
        file_list.close()
    log_file.close()


if __name__ == '__main__':
    evaluate_kpi_history(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
