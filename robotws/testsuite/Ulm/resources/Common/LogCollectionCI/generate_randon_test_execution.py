import random

BASE_CONTENT = """
*** Settings ***

Resource    ../wts_ue.robot


*** Keywords ***
Test Execution with Multiple UEs
    [Documentation]   This is a generated keyword with random added ue procedures.
    ...               Required is that no ue is attached/registered in beginning
    ...               All UEs will get deregistered in the end of the keyword.


"""


def execute_switch_on(device):
    return f"Ue Register     ue_id={device}"
    # print(f"On: {device}")


def execute_switch_off(device):
    return f"Ue Deregister   ue_id={device}"
    # print(f"Off: {device}")


def create_random_delay():
    delay = random.randint(0, 30) / 10
    return f"Sleep  {delay}s"


def chaotic_on_off(ue_ids, operations, with_delay=False):
    created_content = []
    states = [0] * len(ue_ids)
    # states:
    # 0: detached
    # 1: attached
    # 2: traffic started

    # randomly switch on and off
    for _ in range(int(operations)):
        switch_on = random.choice([False, True])
        if switch_on:
            off_devices = [(index, state)
                           for index, state in enumerate(states) if state == 0]
            if off_devices:
                switch_device = random.choice(off_devices)
                index = switch_device[0]
                states[index] = 1

                created_content.append(execute_switch_on(ue_ids[index]))

                if (with_delay):
                    created_content.append(create_random_delay())
        else:
            on_devices = [(index, state)
                          for index, state in enumerate(states) if state == 1]
            if on_devices:
                switch_device = random.choice(on_devices)
                index = switch_device[0]
                states[index] = 0
                created_content.append(execute_switch_off(ue_ids[index]))
                if (with_delay):
                    created_content.append(create_random_delay())

        print(states)

    # switch off all devices that are still on
    on_devices = [(index, state)
                  for index, state in enumerate(states) if state == 1]
    for device in on_devices:
        states[device[0]] = 0
        created_content.append(execute_switch_off(ue_ids[device[0]]))
        print(states)
    return created_content


def create_random_ue_operations_resource(filename, ue_ids, operations, with_delay=False):
    file_content = BASE_CONTENT
    generated_lines = chaotic_on_off(ue_ids=ue_ids, operations=operations, with_delay=with_delay)

    lines = ["    " + line for line in generated_lines if line]
    file_content += "\n".join(lines)

    file_content += "\n"

    with open(filename, "w") as robot_file:
        robot_file.write(file_content)


if __name__ == "__main__":
    ue_ids = [111, 22, 3333, 44, 5, 666, 7, 8, 9, 10]
    create_random_ue_operations_resource(
        filename="generated_ue_actions.robot", ue_ids=ue_ids, operations=10, with_delay=True)
