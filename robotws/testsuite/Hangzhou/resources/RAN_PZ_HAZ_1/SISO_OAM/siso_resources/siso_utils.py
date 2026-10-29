import socket


def get_udp_port(direction):
    host_name = socket.gethostname()
    print(host_name)
    reg_str = "(CLOUD|UTE4G)(\\d+)"
    import re
    result = re.search(reg_str, host_name)
    port = 0
    if result:
        port = int(result.group(2))
    else:
        raise Exception("The hostname is not correct")
    # print(direction, port)
    # print(direction == "UL")
    if direction == "UL":
        return 5000 + port * 2
    elif direction == "DL":
        return 5000 + port * 2 + 1
    else:
        raise Exception("That doesn't  support direction type:{}".format(direction))
