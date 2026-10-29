import os
import subprocess


def get_dcap_bts_id(dcap_bts_info, host):
    for bts in dcap_bts_info:
        if host in bts.values():
            return bts['id']


def get_dcap_trace_id(dcap_bts_info, host):
    for bts in dcap_bts_info:
        for info_trace in bts['latest_trace']['targets']:
            if host in info_trace.values():
                return info_trace['trace_id']


def check_dcap_logs_status(info):
    return info['status']


def create_cell_list(nrCells):
    cell_list = []
    if nrCells:
        nrCells = list(nrCells.split(" "))
        for cell in nrCells:
            cell_list.append(cell)
        return cell_list


def create_custom_profile_list(cp):
    cp_list = []
    if cp:
        cp = list(cp.split(" "))
        for profile in cp:
            cp_list.append(profile)
        return cp_list


def create_msg_list(msgs):
    msgs_list = []
    if msgs:
        msgs = list(msgs.split(" "))
        for msg in msgs:
            msgs_list.append(msg)
        return msgs_list


def Parse_Emil_Csv_File_For_Message(path, msg, log='EMIL'):
    # Validate the message content in EMIL logs
    # Input : Log path, <Message1>::<content1>,<content2>|<Message2>::<content1>,<content2>
    # Output : Msg content, True/False
    # Usage : /home/ute   E2setupRequest::ranFunctionID 11,ORAN-E2SM-RC-CA|E2setupResponse::ranFunctionID 11
    messages = msg.split("|")
    status = []
    if log == 'EMIL':
        filetype = ".csv"
    else:
        filetype = ".pcap"
    End_msg = '}"'
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                file = os.path.join(r, file)
                if log != "EMIL":
                    subprocess.call(
                        'sudo tshark -V -r ' +
                        file +
                        ' > ' +
                        file.replace(
                            'pcap',
                            'txt'),
                        shell=True)
                    file = file.replace('pcap', 'txt')
                src = open(file).readlines()
                remove_list = []
                for i in messages:
                    print(
                        "\nSearching for message",
                        i.split("::")[0],
                        "in file",
                        file)
                    Flag = False
                    try:
                        val, strings = i.split("::")
                        check = strings.split(",")
                    except BaseException:
                        val = i
                        check = []
                    if log == 'EMIL':
                        val = '"' + val + '"'
                    for j in range(0, len(src)):
                        temp = []
                        if (val in src[j] and log == 'EMIL') or (
                                val in src[j] and 'Frame' in src[j]
                                and 'captured' in src[j] and log == 'tshark'):
                            print("\n\tMessage found:\n\t", src[j])
                            for k in range(j, len(src)):
                                temp.append(src[k])
                                if End_msg in src[k] or src[k] in [
                                        '\n', '\r\n']:
                                    break
                            count = []
                            for item in range(0, len(temp)):
                                for m in check:
                                    name = m.split(",")
                                    for n in name:
                                        if n in temp[item]:
                                            print("\tMessage content found :")
                                            count.append(n)
                                            print(temp[item])
                            if all([item in count for item in check]):
                                status.append(i)
                                remove_list.append(i)
                                print("\nMessage: \n")
                                for text in temp:
                                    print(text.strip('\n'))
                                break
                for rem in remove_list:
                    messages.remove(rem)
                if sorted(msg.split("|")) == sorted(status):
                    return True
    print("\nBelow messages or it's content not found :")
    for i in set(msg.split("|")) - set(status):
        print("\t", i)
    return False
