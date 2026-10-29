import random
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


tl = BuiltIn().get_variable_value("${tl}")
ALL_AEHC_LIST = []
for ru_index in range(len(tl.gnbs[0].dus[0].rus)):
    ru_type = tl.gnbs[0].dus[0].rus[ru_index].ru_hw_group
    ru_addr = tl.gnbs[0].dus[0].rus[ru_index].default_ssh_connection_details.addr
    ru_username = tl.gnbs[0].dus[0].rus[ru_index].default_ssh_connection_details.username
    ru_password = tl.gnbs[0].dus[0].rus[ru_index].default_ssh_connection_details.password
    ru_serial = tl.gnbs[0].dus[0].rus[ru_index].serial_number
    test_pc_addr = tl.gnbs[0].dus[0].rus[ru_index].lmp_connection.addr
    test_pc_username = tl.gnbs[0].dus[0].rus[ru_index].lmp_connection.username
    test_pc_password = tl.gnbs[0].dus[0].rus[ru_index].lmp_connection.password

    ru_details = {
        "ru_type": ru_type,
        "ru_addr": ru_addr,
        "ru_username": ru_username,
        "ru_password": ru_password,
        "ru_serial": ru_serial,
        "test_pc_addr": test_pc_addr,
        "test_pc_username": test_pc_username,
        "test_pc_password": test_pc_password,
    }
    if ru_serial is not None and ru_type == "AEHC" and test_pc_addr != "1.1.1.1":
        ALL_AEHC_LIST.append(ru_details)

if len(ALL_AEHC_LIST) != 0:
    rand_idx = random.randrange(len(ALL_AEHC_LIST))
    RANDOM_AEHC = ALL_AEHC_LIST[rand_idx]
else:
    RANDOM_AEHC = None
print(RANDOM_AEHC)


DFE_IP_DICT = {
    "DFE0": ["192.168.100.3", "192.168.101.3", "192.168.102.3"],
    "DFE1": ["192.168.100.4", "192.168.101.4", "192.168.102.4"],
    "DFE2": ["192.168.100.5", "192.168.101.5", "192.168.102.5"],
    "DFE3": ["192.168.100.6", "192.168.101.6", "192.168.102.6"],
    "DFE4": ["192.168.100.7", "192.168.101.7", "192.168.102.7"],
    "DFE5": ["192.168.100.8", "192.168.101.8", "192.168.102.8"],
    "DFE6": ["192.168.100.9", "192.168.101.9", "192.168.102.9"],
    "DFE7": ["192.168.100.10", "192.168.101.10", "192.168.102.10"],
}

CRITICAL_DFE_LIST = [
    ["DFE7"],
    ["DFE1", "DFE6"],
]
for i in range(0, 8):
    for j in range(i+1, 8):
        for k in range(j+1, 8):
            CRITICAL_DFE = ["DFE" + str(i), "DFE" + str(j), "DFE" + str(k)]
            CRITICAL_DFE_LIST.append(CRITICAL_DFE)
            for x in range(k+1, 8):
                CRITICAL_DFE = [
                    "DFE" + str(i), "DFE" + str(j), "DFE" + str(k), "DFE" + str(x)]
                CRITICAL_DFE_LIST.append(CRITICAL_DFE)
                for m in range(x+1, 8):
                    CRITICAL_DFE = [
                        "DFE" + str(i), "DFE" + str(j), "DFE" + str(k), "DFE" + str(x), "DFE" + str(m)]
                    CRITICAL_DFE_LIST.append(CRITICAL_DFE)
                    for n in range(m+1, 8):
                        CRITICAL_DFE = ["DFE" + str(i), "DFE" + str(j), "DFE" + str(
                            k), "DFE" + str(x), "DFE" + str(m), "DFE" + str(n)]
                        CRITICAL_DFE_LIST.append(CRITICAL_DFE)
                        for y in range(n+1, 8):
                            CRITICAL_DFE = ["DFE" + str(i), "DFE" + str(j), "DFE" + str(
                                k), "DFE" + str(x), "DFE" + str(m), "DFE" + str(n), "DFE" + str(y)]
                            CRITICAL_DFE_LIST.append(CRITICAL_DFE)
                            for z in range(y+1, 8):
                                CRITICAL_DFE = ["DFE" + str(i), "DFE" + str(j), "DFE" + str(k), "DFE" + str(
                                    x), "DFE" + str(m), "DFE" + str(n), "DFE" + str(y), "DFE" + str(z)]
                                CRITICAL_DFE_LIST.append(CRITICAL_DFE)
rand_idx = random.randrange(len(CRITICAL_DFE_LIST))
RANDOM_CRITICAL_DFE = CRITICAL_DFE_LIST[rand_idx]
print(RANDOM_CRITICAL_DFE)
RANDOM_CRITICAL_DFE_IP_LIST = []
for dfe in RANDOM_CRITICAL_DFE:
    RANDOM_CRITICAL_DFE_IP_LIST += DFE_IP_DICT[dfe]
print(RANDOM_CRITICAL_DFE_IP_LIST)


NONE_CRITICAL_DFE_LIST = []
for i in range(0, 7):
    NONE_CRITICAL_DFE = ["DFE" + str(i)]
    NONE_CRITICAL_DFE_LIST.append(NONE_CRITICAL_DFE)
    for j in range(i+1, 7):
        if i == 1 and j == 6:
            continue
        NONE_CRITICAL_DFE = ["DFE" + str(i), "DFE" + str(j)]
        NONE_CRITICAL_DFE_LIST.append(NONE_CRITICAL_DFE)

rand_idx = random.randrange(len(NONE_CRITICAL_DFE_LIST))
RANDOM_NONE_CRITICAL_DFE = NONE_CRITICAL_DFE_LIST[rand_idx]
print(RANDOM_NONE_CRITICAL_DFE)
RANDOM_NONE_CRITICAL_DFE_IP_LIST = []
for dfe in RANDOM_NONE_CRITICAL_DFE:
    RANDOM_NONE_CRITICAL_DFE_IP_LIST += DFE_IP_DICT[dfe]
print(RANDOM_NONE_CRITICAL_DFE_IP_LIST)
