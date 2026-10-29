import os
import sys
import time


def create_master_scenario(path="./", result_file="master_scenario.txt"):
    commands = []
    path = os.path.join(path, 'UeScenario')
    print(f"background scenario log - path = {path} - result_file = {result_file}")
    file_list = [os.path.join(path, f) for f in os.listdir(path) if f.endswith('.allIterations')]
    print(f"background scenario log - File {file_list}")
    # read the commands fomr the files and save them with their delay
    for file_name in file_list:
        with open(file_name, 'r') as file:
            lines = file.readlines()
            for line in lines:
                parts = line.strip().split(';')
                if len(parts) == 3:
                    print(f"background scenario log - current line {line}")
                    delay, type, command = parts
                    delay = float(delay)
                    # command_with_file = f"{command} {os.path.basename(file_name).split('.')[0]}"
                    commands.append((delay, type, command))

    # order the commands per delay
    commands.sort(key=lambda x: x[0])

    # print the command and save the result
    with open(os.path.join(path, result_file), 'w') as result:
        # start_time = time.time()
        for delay, type, command in commands:
            result.write(f"{delay};{type};{command}\n")
            print(f"background scenario log - {delay};{type};{command}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        create_master_scenario(sys.argv[1], sys.argv[2])
    else:
        create_master_scenario()
