import os
import sys
import math        # BHR 10/06/2023    ADDED
import re          # DTN 10/04/2025    ADDED


def cust_print(level, string):
    out_string = f"evaluate_load_meas_history/{level} - {string}"
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


def eval_avg_and_deviation(num_list):                                      # BHR 10/06/2024  FUNCTION ADDED
    avg = sum(num_list) / len(num_list)
    var = sum([(xi - avg) ** 2 for xi in num_list]) / (len(num_list) - 1)
    sdev = math.sqrt(var)
    log_inf(f"average of values list : { avg:.3f}")                       # TO BE ADD FOR DEBUG PURPOSE
    log_inf(f"standard deviation is : {sdev:.3f}")                        # TO BE ADD FOR DEBUG PURPOSE
    return avg, sdev


def fill_history_data(history_data, load_meas_file_name):
    separators = [", ", ": "]                                 # BHR 27/09/24 : new variable
    model = '|'.join(map(re.escape, separators))              # BHR 27/09/24 : new variable

    with open(load_meas_file_name, "r") as load_meas_file:
        for line in load_meas_file.readlines():
            # splitted_line = line.split(":")
            splitted_line = re.split(model, line)              # BHR 27/09/24 : replace splitted_line = line.split(":")
            load_meas_id = splitted_line[0]
            load_meas_value = float(splitted_line[1].strip())
            if load_meas_id not in history_data:
                history_data[load_meas_id] = {}
            if load_meas_file_name in history_data[load_meas_id]:
                log_err(f"load_meas {load_meas_id} already filled for {load_meas_file_name}")
            history_data[load_meas_id][load_meas_file_name] = load_meas_value
        load_meas_file.close()


# def is_load_meas_to_be_checked_from_file(test_name, load_meas_id):
#     list_excluded_missing_load_meas = f"Load/list_excluded_missing_load_meas.csv"
#     with open(list_excluded_missing_load_meas, "r") as excluded_load_meas:
#         for line in excluded_load_meas.readlines():
#             splitted_line = line.split(";")
#             if splitted_line[0] == "shall not be checked":
#                 if splitted_line[1] in test_name:
#                     if splitted_line[2] in load_meas_id:
#                         print("load_meas_id out of range but white listed = %s" % (load_meas_id))
#                         return False
#    return True


def is_known_as_missing_from_file(load_meas_id):
    list_excluded_missing_load_meas = f"Load/list_excluded_missing_load_meas.csv"
    missing_list = []
    with open(list_excluded_missing_load_meas, "r") as excluded_load_meas:
        for line in excluded_load_meas.readlines():
            splitted_line = line.split(";")
            if splitted_line[0] == "is known as misssing":
                missing_list.append(splitted_line[1])
    for load_meas_pattern in missing_list:
        if load_meas_pattern in load_meas_id:
            print("load_meas_id in known missing list = %s" % (load_meas_id))
            return True
    return False


def check_history(history_data, load_meas_file_name, test_name):
    last_history_file_name = ""
    sd_dev_thresh_factor = 3.000                                    # BHR 11/06/2024 ADDED
    kpi_dev_thresh_factor = 3.000                                   # BHR 11/06/2024 ADDED
    for load_meas_id in history_data:
        nb_of_samples = 0
        load_meas_history = history_data[load_meas_id]
        log_dbg(f"load_meas_id = {load_meas_id}")                        # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE
        initial_list_load_meas_values = []    # BHR 10/06/2024 ADDED
        refined_list_load_meas_values = []    # BHR 10/06/2024 ADDED

        for history_file_name in load_meas_history:
            if history_file_name != load_meas_file_name:
                if history_file_name > last_history_file_name:
                    last_history_file_name = history_file_name
                load_meas_value = load_meas_history[history_file_name]

                initial_list_load_meas_values.append(load_meas_value)    # BHR 10/06/2024 ADDED
                nb_of_samples += 1

        log_dbg(f"Initial list of load_meas values is:")               # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE
        log_dbg(initial_list_load_meas_values)                         # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE

        if nb_of_samples < 5:                                       # BHR 10/06/2024 MODIFY FROM 5 --> 10
            log_wrn(f"not enough history samples ({nb_of_samples}) for {load_meas_id}")
            continue
        if load_meas_file_name not in load_meas_history:
            if last_history_file_name in load_meas_history:
                if is_known_as_missing_from_file(load_meas_id):
                    log_inf(f"{load_meas_id} known as missing for {load_meas_file_name}")
                else:
                    log_missing(f"no {load_meas_id} for {load_meas_file_name} (present in {last_history_file_name})")
            continue

        # BHR 10/06/2024 BEGIN : START SECTION ADDED
        # calculate of initial average standard deviationload_meas
        avg, sdev = eval_avg_and_deviation(initial_list_load_meas_values)

        # refine list load_meas values
        if avg < 0:
            log_err(f"{load_meas_id}: average of load_meas values list {avg} is negative value for {test_name}")
            continue

        if avg == 0 and sdev > 0:
            log_err(f"{load_meas_id}: average of load_meas values list {avg} is 0 value whereas "
                    f"standard deviation load_meas value list {sdev} is positive  for {test_name}")
            continue

        if avg == 0 and sdev == 0:
            refined_list_load_meas_values = initial_list_load_meas_values

        if avg > 0:
            mini = avg - (sd_dev_thresh_factor * sdev)
            maxi = avg + (sd_dev_thresh_factor * sdev)
            log_inf(f"mini is : {mini:.3f} and maxi is : {maxi:.3f}")      # TO BE ADD FOR DEBUG PURPOSE
            refined_list_load_meas_values = [xi for xi in initial_list_load_meas_values if xi >= mini and xi <= maxi]

        log_dbg(f"Refined list of load_meas values is:")                    # TO BE ADD FOR DEBUG PURPOSE
        log_dbg(refined_list_load_meas_values)                              # TO BE ADD FOR DEBUG PURPOSE

        # re calculate of average standard deviation from refined_list_load_meas_values
        avg, sdev = eval_avg_and_deviation(refined_list_load_meas_values)
        refined_min = avg - (kpi_dev_thresh_factor * sdev)
        refined_max = avg + (kpi_dev_thresh_factor * sdev)
        # BHR 10/06/2024 END : END SECTION ADDED

        now_value = load_meas_history[load_meas_file_name]
        log_inf(f"Current value is : {now_value}")             # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE

        # BHR 10/06/2024 BEGIN ADD SECTION
        if now_value < refined_min or now_value > refined_max:
            description = "refined_min nb_of_samples refined_max avg sdev"
            debug_string = f"[{refined_min} {nb_of_samples} {refined_max} {avg} {sdev}] ({description})"
            # if is_load_meas_to_be_checked_from_file(test_name, load_meas_id):
            #     log_err(f"{load_meas_id}: {now_value} out of hist range {debug_string} in {test_name}")
            # else:
            #     log_inf(f"{load_meas_id}: {now_value} would be out of hist range {debug_string} in {test_name}")
            log_err(f"{load_meas_id}: {now_value} out of hist range {debug_string} in {test_name}")
        # BHR END
    log_inf(f"End of {len(history_data)} load_meass processing")


def evaluate_load_meas_history(user, history_server, root_path, test_name, load_meas_file_name):
    global log_file
    log_file = open("load_meas_history.log", "a")
    relative_path = f"Load/{test_name}"

    if os.path.exists("/home/ca_psci5g/.ssh/id_rsa_ute"):
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no -i /home/ca_psci5g/.ssh/id_rsa_ute"
    else:
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no"
    remote_path = f"{user}@{history_server}:{root_path}/{test_name}"
    system_command(f"ssh {options} {user}@{history_server} mkdir -p {root_path}/{test_name}/")
    system_command(f"scp {options} {relative_path}/{load_meas_file_name} {remote_path}/")

    system_command(
        f"ssh {options} {user}@{history_server} 'ls -1 {root_path}/{test_name}/' | "
        f"grep LOAD_MEASUREMENT | tail -n 20 > file_list.txt")
    history_dir = f"{relative_path}/history/"
    if not os.path.exists(history_dir):
        system_command(f"mkdir {history_dir}")
    with open("file_list.txt", "r") as file_list:
        history_load_meas_file_names = file_list.readlines()
        history_data = {}
        for line in history_load_meas_file_names:
            history_load_meas_file_name = line.strip()
            system_command(f"scp {options} {remote_path}/{history_load_meas_file_name} {relative_path}/history/")
            fill_history_data(history_data, f"{relative_path}/history/{history_load_meas_file_name}")
        check_history(history_data, f"{relative_path}/history/{load_meas_file_name}", test_name)
        file_list.close()
    log_file.close()


if __name__ == '__main__':
    evaluate_load_meas_history(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
