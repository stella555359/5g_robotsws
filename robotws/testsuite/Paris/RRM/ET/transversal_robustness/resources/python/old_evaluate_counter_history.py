import os
import sys


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
    for counter_id in history_data:
        min_value = 100000000000000000
        max_value = 0
        nb_of_samples = 0
        counter_history = history_data[counter_id]
        for history_file_name in counter_history:
            if history_file_name != counter_file_name:
                if history_file_name > last_history_file_name:
                    last_history_file_name = history_file_name
                counter_value = counter_history[history_file_name]
                min_value = min(counter_value, min_value)
                max_value = max(counter_value, max_value)
                nb_of_samples += 1
        if nb_of_samples < 5:
            log_wrn(f"not enough history samples ({nb_of_samples}) for {counter_id}")
            continue
        if counter_file_name not in counter_history:
            if last_history_file_name in counter_history:
                if is_known_as_missing_from_file(counter_id):
                    log_inf(f"{counter_id} known as missing for {counter_file_name}")
                else:
                    log_missing(f"no {counter_id} for {counter_file_name} (present in {last_history_file_name})")
            continue
        now_value = counter_history[counter_file_name]
        tolerance = int(1.0 * (max_value - min_value))
        min_toler = min_value - tolerance
        max_toler = max_value + tolerance
        if now_value < min_toler or now_value > max_toler:
            counter_description = get_counter_description(counter_id, counter_descriptions)
            debug_string = f"[{min_toler} {min_value} {nb_of_samples} {max_value} {max_toler}] ({counter_description})"
            if is_counter_to_be_checked_from_file(test_name, counter_id):
                log_err(f"{counter_id}: {now_value} out of hist range {debug_string} in {test_name}")
            else:
                log_inf(f"{counter_id}: {now_value} would be out of hist range {debug_string} in {test_name}")
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
    system_command(
        f"ssh {options} {user}@{history_server} 'ls -1 {root_path}/{test_name}/' | tail -n 61 > file_list.txt")
    system_command(f"mkdir {relative_path}/history/")
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
