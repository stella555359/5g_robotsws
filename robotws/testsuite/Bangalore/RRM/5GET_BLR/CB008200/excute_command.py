from telnetlib import Telnet
import re


def egate_telnet_session():
    tn = Telnet('127.0.0.1', port=20000)
    tn.read_until("EGATE>".encode(), timeout=None)
    return tn


def excute_egate_command(command, expected_string, tn):
    command = command + '\r'
    tn.write(command.encode())
    output = tn.read_until(expected_string.encode(), timeout=20)
    output = output.decode(encoding='UTF-8', errors="ignore")
    output = re.compile(r'\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])').sub('', output).replace('\r\n', '')
    print(output)
    return output


def verify_data_start(output, expectation):
    if expectation in output:
        return 'Pass'
    else:
        return 'Fail'


def start_data(ue_id, pdu_id, qfi_id, dir, trf_id, rate, desired_string="Started Downlink Internal traffic Receiver"):
    command = ('trf_data_start ' + 'ue=' + str(ue_id) + ' pdu=' + str(pdu_id)+' qfi=' + str(qfi_id) + ' dir=' + dir +
               ' trf_id=' + str(trf_id) + ' kbps=' + str(rate))
    print(command)
    if 'ul' in dir:
        desired_string = "Started Uplink Internal traffic Receiver on Ue:" + str(ue_id)
    elif 'dl' in dir:
        desired_string = "Started Downlink Internal traffic Receiver on Ue:" + str(ue_id)

    session = egate_telnet_session()
    return excute_egate_command(command, desired_string, session)
