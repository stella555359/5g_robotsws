
def add_or_modify_flag_in_swconfig(flag_0x4F0214, swconfig_path):
    file = open(swconfig_path, "r")
    lines = file.readlines()
    flag_0x4F0214_exist = False
    for i in range(len(lines)):
        if not lines[i].startswith("#"):
            if lines[i].startswith("0x4F0214"):
                lines[i] = "0x4F0214=" + str(flag_0x4F0214) + "\n"
                flag_0x4F0214_exist = True
    file = open(swconfig_path, "w")
    file.writelines(lines)
    file.close()
    file = open(swconfig_path, "a")
    if not flag_0x4F0214_exist:
        file.write("0x4F0214=" + str(flag_0x4F0214) + "\n")
    file.close()


def remove_flag_in_swconfig(swconfig_path):
    file = open(swconfig_path, "r")
    lines = file.readlines()
    for i in range(len(lines)):
        if lines[i].startswith("0x4F0214"):
            lines[i] = ""
    file = open(swconfig_path, "w")
    file.writelines(lines)
    file.close()
