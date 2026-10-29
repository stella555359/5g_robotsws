import re


def Win32_PerfRawData_Tcpip_NetworkInterface(inputstr):
    lines = inputstr.strip().replace('\r\nB', "").split("\r\n")
    value = lines[1].replace('\r\n', "")
    value = re.split(r'\s+', value)
    data = {}
    data["BytesReceivedPersec"] = int(value[0])
    data["BytesSentPersec"] = int(value[1])
    data["Frequency_PerfTime"] = int(value[2])
    data["Timestamp_PerfTime"] = int(value[3])
    return data


def check_throughput_on_MTKPC(data1, data2):
    ul_data = data2["BytesSentPersec"] - data1["BytesSentPersec"]
    dl_data = data2["BytesReceivedPersec"] - data1["BytesReceivedPersec"]
    dur = data2["Timestamp_PerfTime"] - data1["Timestamp_PerfTime"]
    timebase = data1["Frequency_PerfTime"]
    ul = ul_data * timebase * 8.0 / dur / 1024.0 / 1024.0
    dl = dl_data * timebase * 8.0 / dur / 1024.0 / 1024.0
    return (ul, dl)
