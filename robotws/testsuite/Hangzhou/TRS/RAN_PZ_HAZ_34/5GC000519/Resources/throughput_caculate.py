import time
from taf.transport.ssh import ssh
from decimal import *


ssh = ssh()


def Calculate_End2End_throughoutput(alias, port, iperf_path='iperf', size=1000):
    ssh.send_command(iperf_path+' -s -u -i 1 -p '+port+' -P 1 -f m -l 1024B', connection=alias, timeout=60)
    time.sleep(5)
    output = ssh.read_output(size=size, connection=alias).split('\r\n')
    if len(output) == 1:
        output = output[0].split('\n')
    num = 0
    sum = 0
    for element in output:
        if 'Mbits/sec' in element:
            num += 1
            data = element.split('MBytes')
            traffic_data = data[1].split('Mbits/sec')
            traffic_value = traffic_data[0].strip()
            sum += float(traffic_value)
    average_value = round(Decimal(sum)/Decimal(num), 3)
    return average_value


def calculate_e2e_throughoutput(alias, port, iperf_path='iperf', size=1000):
    ssh.send_command(iperf_path+' -s -u -i 1 -p '+port+' -P 1 -f m', connection=alias, timeout=60)
    time.sleep(10)
    output = ssh.read_output(size=size, connection=alias).split('\r\n')
    print(output)
    if len(output) == 1:
        output = output[0].split('\n')
    print(output)
    num = 0
    sum = 0
    for element in output:
        if 'Mbits/sec' in element:
            num += 1
            data = element.split('MBytes')
            traffic_data = data[1].split('Mbits/sec')
            traffic_value = traffic_data[0].strip()
            sum += float(traffic_value)
    average_value = round(Decimal(sum)/Decimal(num), 3)
    return average_value
