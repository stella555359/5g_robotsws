import random
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn


BASE_CONTENT = """
*** Settings ***
Resource    ../../resources/Common/wts_ue.robot
Resource    ue_resources.robot
Resource    common_cell_operations.robot


*** Keywords ***
Generated Test Execution with Multiple UEs
    [Documentation]   This is a generated keyword with random added ue procedures.
    ...               Required is that no ue is attached/registered in beginning
    ...               All UEs will get deregistered in the end of the keyword.

    Preload Enb and Cell Information

"""


def create_random_delay():
    delay = random.randint(0, 30) / 10
    return f"Sleep  {delay}s"


def chaotic_on_off(ue_ids, operations, with_delay=False):
    created_content = []
    # states:
    # 0: detached
    # 1: attached
    # 2: traffic started

    # randomly switch on and off

    possible_actions = ["switch_on", "switch_off", "block_cell", "unblock_cell"]

    operations = int(operations)

    random_actions = possible_actions * int(operations / len(possible_actions))
    random_actions += possible_actions[:operations % len(possible_actions)]
    random.shuffle(random_actions)
    # for _ in range(int(operations)):
    #     action = random.choice(["switch_on", "switch_off", "block_cell", "unblock_cell"])

    for action in random_actions:
        if action == "switch_on":
            created_content.append("ue_resources.Execute Random Ue Register")
            if (with_delay):
                created_content.append(create_random_delay())
        elif action == "switch_off":
            created_content.append("ue_resources.Execute Random Ue Deregister")
            if (with_delay):
                created_content.append(create_random_delay())

        elif action == "block_cell":
            created_content.append("Block Random Cell")
            if (with_delay):
                created_content.append(create_random_delay())

        elif action == "unblock_cell":
            created_content.append("Unblock Random Cell")
            if (with_delay):
                created_content.append(create_random_delay())

    # unblock all blocked cells
    created_content.append("Unblock All Blocked Cells")
    return created_content


def create_random_ue_operations_keyword(filename, ue_ids, operations, with_delay=False):
    file_content = BASE_CONTENT
    generated_lines = chaotic_on_off(ue_ids=ue_ids, operations=operations, with_delay=with_delay)

    lines = ["    " + line for line in generated_lines if line]
    file_content += "\n".join(lines)

    file_content += "\n"

    with open(filename, "w") as robot_file:
        robot_file.write(file_content)

    return "Generated Test Execution with Multiple UEs"


if __name__ == "__main__":
    ue_ids = [111, 22, 3333, 44, 5, 666, 7, 8, 9, 10]
    create_random_ue_operations_keyword(
        filename="generated_ue_actions.robot", ue_ids=ue_ids, operations=10, with_delay=True)
