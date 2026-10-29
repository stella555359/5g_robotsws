import os
import re
import sys
import shutil


def create_ue_scenario(scenario_file="scenario.txt", path="./"):
    directoryUeScenario = os.path.join(path, "UeScenario")

    # delete directory UeScenario if present
    if os.path.exists(directoryUeScenario):
        shutil.rmtree(directoryUeScenario)

    # create directory UeScenario if necessary
    os.makedirs(directoryUeScenario, exist_ok=True)

    with open(scenario_file, 'r') as file:
        lines = file.readlines()

    for line in lines:
        parts = line.strip().split(', ')
        ue_id = parts[0]
        numeric_part = ue_id[2:]
        padded_numeric_part = numeric_part.zfill(3)
        ue_id = f"UE{padded_numeric_part}"
        template_file = path + parts[1]
        offset = parts[2].split('=')[1]
        duration = int(parts[3].split('=')[1])
        print(f"\nbackground scenario log - {ue_id}: initial offset = {offset} / duration = {duration}")

        # read the template
        with open(template_file, 'r') as template:
            template_lines = template.readlines()

        # compute the sum of the value for each line of template.txt
        total_duration = sum(int(line.split(';')[0]) for line in template_lines)
        print(f"background scenario log - {ue_id}: total duration of the scenario {template_file} is {total_duration}")

        # Calculer la valeur de waitBeforeNextLoop
        wait_before_next_loop = duration - total_duration
        if wait_before_next_loop < 0:
            print(f"background scenario log - {ue_id}: Warning: Negative waitBeforeNextLoop value for {ue_id}.\
                   Setting it to 0.")
            wait_before_next_loop = 0
        print(
              f"background scenario log - {ue_id}: computed value for \"wait before next loop\" "
              f"is {wait_before_next_loop}"
              )

        # create new file UExx.oneIteration in UeScenario directory
        print(f"background scenario log - ue_id={ue_id}")
        ue_file_name = f"{ue_id}.oneIteration"
        # /!\ current limitation with UE id between 000 and 999
        ue_id = re.search(r'UE(\d{3})\.oneIteration', ue_file_name).group(1) if\
            re.search(r'UE(\d{3})\.oneIteration', ue_file_name) else None
        print(f"background scenario log - ue_id={ue_id}")
        with open(os.path.join(directoryUeScenario, ue_file_name), 'w') as ue_file:
            # write the first line with the initial offset
            first_line_parts = template_lines[0].strip().split(';')
            ue_file.write(f"{offset};{build_egate_command(first_line_parts[1].strip(), ue_id)}\n")

            # write the file
            for template_line in template_lines[1:-1]:
                command = template_line.strip().split(';')[1].strip()
                ue_file.write(f"{template_line.split(';')[0]};{build_egate_command(command, ue_id)}\n")

            # write the last line with the wait before next loop
            last_line_parts = template_lines[-1].strip().split(';')
            ue_file.write(f"{wait_before_next_loop};{build_egate_command(last_line_parts[1].strip(), ue_id)}\n")


def build_egate_command(command, ue_id):
    ue_id = ue_id.lstrip('0')
    if "<UEID>" in command:
        command = command.replace("<UEID>", ue_id)
        return f"wts;{command}"
    elif "smf_param" in command:
        return f"wts;{command}"
    elif command == "start scenario":
        return "wait;start scenario"
    elif command == "initial offset":
        return "wait;initial offset"
    elif command == "wait before next loop":
        return "wait;wait before next loop"
    else:
        print(f"ERR: background scenario log - the command : {command} is not managed by the script")
        sys.exit(f"ERR: the command : {command} is not managed by the script")


if __name__ == "__main__":
    if len(sys.argv) > 2:
        create_ue_scenario(sys.argv[1], sys.argv[2])
    else:
        create_ue_scenario()
