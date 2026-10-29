import os
import sys
import math        # BHR 10/06/2023    ADDED


def cust_print(level, string):
    out_string = f"evaluate_counter_history/{level} - {string}"
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


def get_counter_description(counter_id, counter_descriptions):
    counter_description = "UNKNOWN"
    if counter_id in counter_descriptions:
        counter_description = counter_descriptions[counter_id]
    return counter_description


def eval_avg_and_deviation(num_list):                                      # BHR 10/06/2024  FUNCTION ADDED
    avg = sum(num_list) / len(num_list)
    var = sum([(xi - avg) ** 2 for xi in num_list]) / (len(num_list) - 1)
    sdev = math.sqrt(var)
    # log_inf(f"average of values list : { avg:.3f}")                       # TO BE ADD FOR DEBUG PURPOSE
    # log_inf(f"standard deviation is : {sdev:.3f}")                        # TO BE ADD FOR DEBUG PURPOSE
    return avg, sdev


def fill_history_data(history_data, counter_file_name, counter_descriptions):
    with open(counter_file_name, "r") as counter_file:
        for line in counter_file.readlines():
            splitted_line = line.split(";")
            counter_id = splitted_line[0]
            counter_value = float(splitted_line[1].strip())
            counter_descriptions[counter_id] = splitted_line[-1].strip()
            if counter_id not in history_data:
                history_data[counter_id] = {}
            if counter_file_name in history_data[counter_id]:
                log_err(f"counter {counter_id} already filled for {counter_file_name}")
            history_data[counter_id][counter_file_name] = counter_value
        counter_file.close()


def is_counter_to_be_checked_from_file(test_name, counter_id):
    list_excluded_missing_counter = f"Counter/list_excluded_missing_counter.csv"
    with open(list_excluded_missing_counter, "r") as excluded_counter:
        for line in excluded_counter.readlines():
            splitted_line = line.split(";")
            if splitted_line[0] == "shall not be checked":
                if splitted_line[1] in test_name:
                    if splitted_line[2] in counter_id:
                        print("counter_id out of range but white listed = %s" % (counter_id))
                        return False
    return True


def is_known_as_missing_from_file(counter_id):
    list_excluded_missing_counter = f"Counter/list_excluded_missing_counter.csv"
    missing_list = []
    with open(list_excluded_missing_counter, "r") as excluded_counter:
        for line in excluded_counter.readlines():
            splitted_line = line.split(";")
            if splitted_line[0] == "is known as misssing":
                missing_list.append(splitted_line[1])
    for counter_pattern in missing_list:
        if counter_pattern in counter_id:
            print("counter_id in known missing list = %s" % (counter_id))
            return True
    return False


def check_history(history_data, counter_file_name, counter_descriptions, test_name):
    last_history_file_name = ""
    sd_dev_thresh_factor = 3.000                                    # BHR 11/06/2024 ADDED
    kpi_dev_thresh_factor = 3.000                                   # BHR 11/06/2024 ADDED
    s_dev_static = 0.001                                            # BHR 25/10/2024 ADDED
    for counter_id in history_data:
        nb_of_samples = 0
        counter_history = history_data[counter_id]
        # log_dbg(f"counter_id = {counter_id}")                        # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE
        initial_list_counter_values = []    # BHR 10/06/2024 ADDED
        refined_list_counter_values = []    # BHR 10/06/2024 ADDED

        for history_file_name in counter_history:
            if history_file_name != counter_file_name:
                if history_file_name > last_history_file_name:
                    last_history_file_name = history_file_name
                counter_value = counter_history[history_file_name]

                initial_list_counter_values.append(counter_value)    # BHR 10/06/2024 ADDED
                nb_of_samples += 1

        # log_dbg(f"Initial list of counter values is:")               # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE
        # log_dbg(initial_list_counter_values)                         # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE

        if nb_of_samples < 10:                                       # BHR 10/06/2024 MODIFY FROM 5 --> 10
            log_wrn(f"not enough history samples ({nb_of_samples}) for {counter_id}")
            continue
        if counter_file_name not in counter_history:
            if last_history_file_name in counter_history:
                if is_known_as_missing_from_file(counter_id):
                    log_wrn(f"{counter_id} known as missing for {counter_file_name}")
                else:
                    log_missing(f"no {counter_id} for {counter_file_name} (present in {last_history_file_name})")
            continue

        # BHR 10/06/2024 BEGIN : START SECTION ADDED
        # calculate of initial average standard deviation
        avg, sdev = eval_avg_and_deviation(initial_list_counter_values)

        # refine list counter values
        if avg < 0:
            log_err(f"{counter_id}: average of counter values list {avg} is negative value for {test_name}")
            continue

        if avg == 0 and sdev > 0:
            log_err(f"{counter_id}: average of counter values list {avg} is 0 value whereas "
                    f"standard deviation counter value list {sdev} is positive  for {test_name}")
            continue

        if avg == 0 and sdev == 0:
            refined_list_counter_values = initial_list_counter_values

        # if avg > 0:
        mini = avg - (sd_dev_thresh_factor * sdev)
        maxi = avg + (sd_dev_thresh_factor * sdev)
        # log_inf(f"mini is : {mini:.3f} and maxi is : {maxi:.3f}")      # TO BE ADD FOR DEBUG PURPOSE
        refined_list_counter_values = [xi for xi in initial_list_counter_values if xi >= mini and xi <= maxi]

        # log_dbg(f"Refined list of counter values is:")                    # TO BE ADD FOR DEBUG PURPOSE
        # log_dbg(refined_list_counter_values)                              # TO BE ADD FOR DEBUG PURPOSE

        # re calculate of average standard deviation from refined_list_counter_values
        # BHR begin 25/10/2024 : if s_dev < s_dev_static assign s_dev with s_dev_static value
        avg, sdev = eval_avg_and_deviation(refined_list_counter_values)
        if sdev < 0.001:
            sdev = s_dev_static
        refined_min = avg - (kpi_dev_thresh_factor * sdev)
        refined_max = avg + (kpi_dev_thresh_factor * sdev)
        # BHR 10/06/2024 END : END SECTION ADDED

        now_value = counter_history[counter_file_name]
        # log_inf(f"Current value is : {now_value}")             # BHR 10/06/2024 ADDED FOR DEBUG PURPOSE

        # BHR 10/06/2024 BEGIN ADD SECTION
        if now_value < refined_min or now_value > refined_max:
            counter_description = get_counter_description(counter_id, counter_descriptions)
            debug_string = f"[{refined_min} {nb_of_samples} {refined_max} {avg} {sdev}] ({counter_description})"
            if is_counter_to_be_checked_from_file(test_name, counter_id):
                log_err(f"{counter_id}: {now_value} out of hist range {debug_string} in {test_name}")
                log_err(f"refined_list_counter_values = {refined_list_counter_values}")
            # BHR begin 25/10/2024 : Comment else since not really usefull
            # else:
            # log_inf(f"{counter_id}: {now_value} would be out of hist range {debug_string} in {test_name}")
            # BHR end
        # BHR end
    log_inf(f"End of {len(history_data)} counters processing")


def evaluate_counter_history(user, history_server, root_path, test_name, counter_file_name):
    global log_file
    log_file = open("counter_history.log", "a")
    relative_path = f"Counter/{test_name}"
    if os.path.exists("/home/ca_psci5g/.ssh/id_rsa_ute"):
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no -i /home/ca_psci5g/.ssh/id_rsa_ute"
    else:
        options = "-o StrictHostKeyChecking=no -o CheckHostIP=no"
    remote_path = f"{user}@{history_server}:{root_path}/{test_name}"
    system_command(f"ssh {options} {user}@{history_server} mkdir -p {root_path}/{test_name}/")
    system_command(f"scp {options} {relative_path}/{counter_file_name} {remote_path}/")
    # BHR begin 12_06_2024 : Transfer also raw .xml pm counter file to archive
    xml_counter_file_name = counter_file_name.replace("csv", "xml")
    system_command(f"scp {options} {relative_path}/{xml_counter_file_name} {remote_path}/")
    # BHR end
    # DTN begin 09_12_2024 : Transfer also .xmlfail if present to archive
    xmlfail_counter_file_name = counter_file_name.replace("csv", "xmlfail")
    xmlfail_path = f"{relative_path}/{xmlfail_counter_file_name}"
    if os.path.exists(xmlfail_path):
        system_command(f"scp {options} {xmlfail_path} {remote_path}/")
    else:
        log_wrn(f"No .xmlfail file found: {xmlfail_counter_file_name}")
    # DTN end
    system_command(
        f"ssh {options} {user}@{history_server} 'ls -1 {root_path}/{test_name}/' | "
        f"grep ANY.csv | tail -n 20 > file_list.txt")
    history_dir = f"{relative_path}/history/"
    if not os.path.exists(history_dir):
        system_command(f"mkdir {history_dir}")
    with open("file_list.txt", "r") as file_list:
        history_counter_file_names = file_list.readlines()
        history_data = {}
        counter_descriptions = {}
        for line in history_counter_file_names:
            history_counter_file_name = line.strip()
            system_command(f"scp {options} {remote_path}/{history_counter_file_name} {relative_path}/history/")
            fill_history_data(history_data, f"{relative_path}/history/{history_counter_file_name}",
                              counter_descriptions)
        check_history(history_data, f"{relative_path}/history/{counter_file_name}", counter_descriptions, test_name)
        file_list.close()
    log_file.close()


if __name__ == '__main__':
    evaluate_counter_history(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
