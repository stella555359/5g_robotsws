import os
import sys


def create_full_scenario(path="./", T=1800):
    input_directory = path + "UeScenario"
    output_directory = path + "UeScenario"

    # list files in directory matchig pattern UExx.oneIteration
    for filename in os.listdir(input_directory):
        if filename.startswith("UE") and filename.endswith(".oneIteration"):
            input_filename = os.path.join(input_directory, filename)
            output_filename = os.path.join(output_directory, filename.replace(".oneIteration", ".allIterations"))

            if not os.path.exists(input_filename):
                print(f"background scenario log - File {input_filename} does not exist.")
                continue

            with open(input_filename, 'r') as infile:
                lines = infile.readlines()

            total_duration = 0
            output_lines = []

            # process the first line
            if lines:
                first_line = lines[0].strip().split(';')
                first_delay, first_type, first_command = float(first_line[0]), first_line[1], first_line[2]
                output_lines.append(f"{first_delay};{first_type};{first_command}\n")
                total_duration = first_delay

            # process the remaining lines
            while total_duration <= T:
                for line in lines[1:]:
                    delay, type, command = line.strip().split(';')
                    delay = float(delay)
                    delay = round(delay + total_duration, 3)
                    line = f"{delay};{type};{command}"
                    output_lines.append(line + '\n')
                    total_duration = delay

            with open(output_filename, 'w') as outfile:
                outfile.writelines(output_lines)

            print(f"background scenario log - processed {input_filename} and created {output_filename} \
                  with total duration {total_duration}.")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        T = float(sys.argv[2]) if len(sys.argv) == 3 else 1800
        create_full_scenario(sys.argv[1], T)
    else:
        create_full_scenario()
