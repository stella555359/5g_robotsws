from sys import argv
from ipaddress import IPv4Network
from os import devnull
from subprocess import Popen
from taf.config.testline.pdu import ATEN, Gude, APC, SWH
from taf.hw.pdu import pdu
from multiprocessing import Pool
from csv import reader, writer
from datetime import datetime


def get_pdu_type(ip):
    print("Checking type at: " + str(ip))
    _pdu_0 = Gude(
        addr=str(ip),
        port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        model="EPC",
        version="8220-1",
    )
    _pdu_1 = Gude(
        addr=str(ip),
        port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        model="EPC",
        version="8221-1",
    )
    _pdu_2 = Gude(
        addr=str(ip),
        port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        model="EPC",
        version="8226-1",
    )
    _pdu_3 = Gude(
        addr=str(ip),
        port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
        model="EPC",
    )
    _pdu_4 = APC(addr=str(ip), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
    _pdu_5 = SWH(addr=str(ip), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
    _pdu_6 = ATEN(addr=str(ip), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
    api = pdu()
    types = {_pdu_0: "Gude_8220-1", _pdu_1: "Gude_8221-1", _pdu_2: "Gude-8226-1", _pdu_3: "Gude_EPC", _pdu_4: "APC",
             _pdu_5: "IQDG-SWH", _pdu_6: "ATEN"}
    for _pdu, _name in types.items():
        try:
            if _name is "Gude_8221-1":
                api.setup_pdu(_pdu, timeout=5)
            else:
                api.setup_pdu(_pdu, timeout=2)
            status = api.get_port_status(1)
            if status in ["on", "off"]:
                return str(ip) + "," + _name + "\n"

        except Exception as e:
            continue
    return str(ip) + ",unknown\n"


def ping_func(ip):
    with open(devnull, "wb") as limbo:
        return ip, Popen(['ping', '-c', '1', '-W', '2', ip], stdout=limbo, stderr=limbo).wait()


def process_addresses(IP_subnet, out_file):
    print("Looking for responding IP addresses...\n")
    ip_pool = [str(ip) for ip in IPv4Network(IP_subnet)]
    data = []
    with Pool(processes=15) as pool:
        responses = pool.map(ping_func, ip_pool)
        for response in responses:
            if not response[1]:
                data.append(response[0])
    with Pool(processes=30) as pool:
        results = pool.map(get_pdu_type, data)
        for line in results:
            out_file.write(line)


def ports_status(data):
    _pdu = {"Gude_8220-1": Gude(
        addr=str(data[0]),
        port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        model="EPC",
        version="8220-1", ),
        "Gude_8221-1": Gude(
            addr=str(data[0]),
            port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
            model="EPC",
            version="8221-1", ),
        "Gude_8226-1": Gude(
            addr=str(data[0]),
            port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
            model="EPC",
            version="8221-1", ),
        "Gude_EPC": Gude(
            addr=str(data[0]),
            port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
            model="EPC", ),
        "APC": APC(addr=str(data[0]), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]),
        "IQDG-SWH": SWH(addr=str(data[0]), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]),
        "ATEN": ATEN(addr=str(data[0]), port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
    }.get(data[1])
    api = pdu()
    if data[1] == "Gude_8221-1":
        api.setup_pdu(_pdu, timeout=5)
    else:
        api.setup_pdu(_pdu, timeout=2)
    api.setup_pdu(_pdu, timeout=5)
    status = []
    for port in _pdu.port_numbers:
        status.append(api.get_port_status(port))
    return status


if __name__ == "__main__":
    try:
        datetime = datetime.now().strftime("%d%m%y_%H%M%S")
        input_filename = str(argv[1])
        check_ip = "true" if len(argv) <= 2 else str(argv[2])
        output_filename = datetime + "_PDU_status.csv" if len(argv) <= 3 else str(argv[3])
        if check_ip == "true":
            output_filename2 = output_filename[:output_filename.find(".")] + "_types" + \
                               output_filename[output_filename.find("."):] if output_filename.find(
                ".") != -1 else output_filename + "_types"

    except Exception as e:
        raise ValueError("Incorrect arguments")

if check_ip == "true":
    with open(input_filename, "r") as in_file:
        output = open(output_filename2, "w")
        output.write("IP address,PDU type\n")
        for line in in_file:
            if line.find("[") != -1 and line.find("]") != -1:
                output.write(line[line.find("["):line.find("]") + 1] + "\n")
            elif len(line) < 9:
                continue
            else:
                try:
                    x = line.find("/")
                    IP_subnet = line[:x + 2] if len(line) <= x + 2 or not line[x + 2].isdigit() else line[:x + 3]
                    process_addresses(IP_subnet, output)
                    output.flush()

                except Exception as e:
                    print(f'Error in {line}: ' + str(e))

        output.close()

with open(input_filename if check_ip == "false" else output_filename2, "r") as in_file:
    output = open(output_filename, "w")
    csv_file = reader(in_file, delimiter=',')
    col_begin = 0
    write = writer(output)
    max_ports = 12
    print("Getting ports status...\n")
    for row in csv_file:
        if col_begin == 0:
            row.extend(["port " + str(x) for x in range(1, max_ports + 1)])
            write.writerow(row)
            col_begin = 1
        elif row[0].find("[") != -1 and row[0].find("]") != -1:
            output.write(row[0][row[0].find("["):row[0].find("]") + 1] + "\n")
        elif len(row) < 2:
            continue
        elif "unknown" not in row[1]:
            attempts = 2
            for i in range(attempts):
                try:
                    row.extend(ports_status(row))
                    write.writerow(row)
                    output.flush()
                    break

                except Exception as e:
                    if i == attempts - 1:
                        print(f'Error at {row[0]}: ' + str(e))

    output.close()
