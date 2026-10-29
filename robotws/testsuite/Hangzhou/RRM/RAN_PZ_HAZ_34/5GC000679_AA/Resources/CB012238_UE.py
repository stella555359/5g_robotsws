import json
import socket
import time
from datetime import datetime
import paramiko
import taf.rfrl.common_resources.python.counters_validation as counters
from taf.sbts.oam.coam.admin import AdminConnection


UE_INITIAL = '''
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'AT+QNWPREFCFG="nr5g_disable_mode",0', 'Timeout': 50000}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'AT+QNWPREFCFG="mode_pref",auto', 'Timeout': 50000}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'AT+QNWPREFCFG="mode_pref",NR5G', 'Timeout': 50000}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'at+cgdcont=1,"IPV4V6","dxdata2"', 'Timeout': 50000}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'at+qnwlock="common/5g",6,503310,30,41', 'Timeout': 50000}}
{'CMD': 'SendAT','EQIndex': 1,'Param': { 'Command': 'AT+CFUN=0', 'Timeout': 50000}}
{'CMD': 'SendAT','EQIndex': 1,'Param': { 'Command': 'AT+CFUN=1', 'Timeout': 50000}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'AT+CGPADDR=1', 'Timeout': 5000,'SuccStr': '+CGPADDR'}}
{'CMD': 'SendAT', 'EQIndex': 1, 'Param': {'Command': 'AT+CGPADDR=1', 'Timeout': 5000,'SuccStr': '+CGPADDR'}}
'''

UE_START_TRAFFIC = "{'CMD': 'StartULtraffic', 'EQIndex': 1, 'Param': {'Protocol': 'UDP', 'Address': '10.57.191.244', \
                  'Port': 52228, 'TestTime': '1900', 'Bandwidth': 102400, 'BufferSize': '1024', 'PacketSize': 1400}}"

UE_STOP = '''
{"CMD": "StopULtraffic", "EQIndex": 1}
'''

iperf_temlete = 'nohup iperf -c ip_address -u -b bandwith -t 1200 -p port > client.log 2>&1 &'
atcmd_templete = "{'CMD': 'SendAT','EQIndex': eq_index,'Param': { 'Command': 'atcmd', 'Timeout': 50000}}"


def create_tcp_connection(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    print(s)
    return s


def tcp_send_json(conn, msg):
    msg = msg.encode('utf-8')
    conn.send(msg)
    result = conn.recv(1024).decode('utf-8')
    print(result)
    return result


def close_tcp_connection(conn):
    conn.close()


def initial_ue(eq_index, conn, apn=None, pci='6', ssb='503310', scs='30', band='41'):
    ue_ip = ''
    cmd = UE_INITIAL.replace("'EQIndex': 1", "'EQIndex': " + eq_index)
    # cmd = cmd.replace("'EQIndex': 1", "'EQIndex': " + eq_index)
    cmd = cmd.replace('at+qnwlock="common/5g",6,503310,30,41', 'at+qnwlock="common/5g",' + pci + ',' +
                      ssb + ',' + scs + ',' + band)
    print(cmd)
    if apn is not None:
        print('apn is not none')
        cmd = cmd.replace("dxdata2", apn)
        print(cmd)
    for i in cmd.splitlines():
        if len(i) > len('\r\n'):
            time.sleep(1)
            # print(i)
            response = tcp_send_json(conn, i)
            if i.find('AT+CFUN=1') > 0:
                print('find AT+CFUN=1')
                time.sleep(10)
            if i.find('AT+CFUN=0') > 0:
                print('find AT+CFUN=1')
                time.sleep(5)
            if i.find('AT+QNWPREFCFG') > 0:
                # print("mode_pref")
                time.sleep(5)
            if i.find("common/5g") > 0:
                # print("common/5g")
                time.sleep(5)
            if i.find("CGPADDR") > 0:
                resp = json.loads(response)
                print(resp)
                for line in resp["Param"]["Back"].splitlines():
                    elems = line.split(',')
                    if len(elems) > 1:
                        ue_ip = elems[1][1:-1]
                        break
    print('ue_ip =', ue_ip)
    return ue_ip


def attach_ue(eq_index, conn):
    cmd = atcmd_templete.replace('eq_index', eq_index).replace('atcmd', 'at+cfun=1')
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(30)


def detach_ue(eq_index, conn):
    cmd = atcmd_templete.replace('eq_index', eq_index).replace('atcmd', 'at+cfun=0')
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(1)


def detach_all_ues(conn):
    time.sleep(1)
    for i in range(1, 9):
        detach_ue(str(i), conn)
        time.sleep(1)


def connect_ue_and_initial(conn, eq_index):
    connect_ue = '{"CMD": "ConnectOneEQ","EQIndex": eq_index}'
    cmd = connect_ue.replace('eq_index', eq_index)
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(60)
    detach_ue(eq_index, conn)
    cmd = (atcmd_templete.replace('eq_index', eq_index).
           replace('atcmd', 'AT+QNWPREFCFG="nr5g_disable_mode",0'))
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(1)
    cmd = (atcmd_templete.replace('eq_index', eq_index).
           replace('atcmd', 'AT+QNWPREFCFG="mode_pref",NR5G'))
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(1)
    attach_ue(eq_index, conn)


def config_ue_apn(conn, eq_index, apn="dxdata2"):
    cmd = (atcmd_templete.replace('eq_index', eq_index).
           replace('atcmd', 'at+cgdcont=1,"IPV4V6",' + '\"' + apn + '\"'))
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(1)


def lock_cell_ssb(conn, eq_index, pci, ssb, scs, band):
    cell = 'at+qnwlock="common/5g",pci,ssb,scs,band'
    cell = cell.replace('pci', pci).replace('ssb', ssb).replace('scs', scs).replace('band', band)
    cmd = atcmd_templete.replace('eq_index', eq_index).replace('atcmd', cell)
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(30)


def unlock_cell_ssb(conn, eq_index):
    cell = 'at+qnwlock="common/5g",0'
    cmd = atcmd_templete.replace('eq_index', eq_index).replace('atcmd', cell)
    print(cmd)
    tcp_send_json(conn, cmd)
    time.sleep(30)


def get_ue_ip(conn, eq_index, apn):
    ue_ip = ''
    cmd_temp = '{"CMD":"GetPDUInfo", "EQIndex": eq_index, "Param": { "APN": "apn" }}'
    cmd = cmd_temp.replace('eq_index', eq_index).replace('apn', apn)
    print(cmd)
    resp = tcp_send_json(conn, cmd)
    time.sleep(1)
    response = json.loads(resp)
    print(response)
    elem = response['Param']['IP'].split(':')
    up_ip = elem[-1]
    print(type(response))
    return up_ip


def ue_stop_traffic(eq_index, conn):
    cmd = UE_STOP.replace('"EQIndex": 1', '"EQIndex": ' + eq_index)
    print(cmd)
    for i in cmd.splitlines():
        if len(i) > len('\r\n'):
            time.sleep(1)
            response = tcp_send_json(conn, i)


def ue_start_ul_traffic(eq_index, conn, bandwith='102400', port='52228'):
    cmd = UE_START_TRAFFIC.replace("'EQIndex': 1", "'EQIndex': " + eq_index)
    cmd = cmd.replace("'Port': 52228", "'Port': " + port)
    cmd = cmd.replace("'Bandwidth': 102400", "'Bandwidth': " + bandwith)
    print(cmd)
    resp = tcp_send_json(conn, cmd)
    time.sleep(5)
    return resp


def create_iperf_cmd(ipaddress, bandwith, port):
    cmd = iperf_temlete.replace('ip_address', ipaddress).replace('bandwith', bandwith).replace('port', port)
    return cmd


def execute_appserver_script(host, username, password, cmd):
    transport = paramiko.Transport((host, 22))
    transport.connect(username=username, password=password)
    chan = transport.open_session()
    chan.get_pty()
    chan.invoke_shell()
    # send command
    chan.send(cmd)
    # close connection
    # time.sleep(60)
    chan.close()
    transport.close()


def ssh_execute_command(hostname, username, password=None, private_key_path=None, command='ls', port=22):
    client = None
    try:
        # create ssh client
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        # connection parameters
        connect_params = {
            'hostname': hostname,
            'port': port,
            'username': username,
            'timeout': 10
        }
        if private_key_path:
            private_key = paramiko.RSAKey.from_private_key_file(private_key_path)
            connect_params['pkey'] = private_key
        elif password:
            connect_params['password'] = password
        else:
            raise ValueError("you must provide password or private_key_path")
        client.connect(**connect_params)
        stdin, stdout, stderr = client.exec_command(command)
        output = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')
        exit_status = stdout.channel.recv_exit_status()
        print(f"command execute result:")
        if output:
            print(f"output:\n{output}")
        if error:
            print(f"error:\n{error}")
        print(f"exit_status: {exit_status}")
        return output, error, exit_status
    except Exception as e:
        print(f"SSH connection or command execute error: {e}")
        return None, str(e), -1
    finally:
        if client:
            client.close()
            print("SSH connection closed")


def excute_process_string(iperf_process):
    PID = []
    process = iperf_process.split(' ')
    for i in process:
        if i != '':
            PID.append(i)
    print("PID:", PID)
    return PID[1]


def get_iperf_process_id(hostname, username, password, ipaddress):
    cmd = 'ps -ef|grep iperf'
    result = ssh_execute_command(hostname=hostname, username=username, password=password, command=cmd)
    output = result[0]
    error = result[1]
    exit_status = result[2]
    iperf = output.split('\n')
    for i in iperf:
        if i.find(ipaddress) > 0:
            print('find')
            return excute_process_string(i)
    return None


def kill_iperf_process(hostname, username, password, ipaddress):
    PID = get_iperf_process_id(hostname=hostname, username=username, password=password, ipaddress=ipaddress)
    if PID is not None:
        cmd = 'kill ' + PID
        result = ssh_execute_command(hostname=hostname, username=username, password=password, command=cmd)
        return result
    else:
        print('no iperf process found')


def verify_ue_attach(conn, eq_index, apn):
    ue_ip = get_ue_ip(conn=conn, eq_index=eq_index, apn=apn)
    if ue_ip != '':
        return True
    else:
        return False


def get_sas_related_counters(cellid, counterid, rgid='1'):
    if counterid == 'M55910C00001':
        path = ['M55910C00001', 'NCUPNRG']
        path.append('NRRESOURCEGROUP-' + rgid)
    elif counterid == 'M55910C00002':
        path = ['M55910C00002', 'NCUPNRG']
        path.append('NRRESOURCEGROUP-' + rgid)
    elif counterid == 'M55910C00003':
        path = ['M55910C00003', 'NCUPNRG']
        path.append('NRRESOURCEGROUP-' + rgid)
    elif counterid == 'M55910C00004':
        path = ['M55910C00004', 'NCUPNRG']
        path.append('NRRESOURCEGROUP-' + rgid)
    elif counterid == 'M55308C10013':
        path = ['M55308C10013', 'NCELA']
    elif counterid == 'M55308C10012':
        path = ['M55308C10012', 'NCELA']
    else:
        path = ['M55308C10013', 'NCELA']
    path.append('NRCELL-' + cellid)
    path.reverse()
    unique_path = tuple(path)
    counter_values = counters.get_counters([counterid])
    rg_counters_value = counters.split_counter_output(counter_values, unique_path)
    return list(list(rg_counters_value[0].values())[0].values())[-1]


def create_spark_cmd(cmd="AutoCheck", eq_index=None, param=None):
    spark_cmd = {}
    if cmd:
        spark_cmd["CMD"] = cmd
    if eq_index:
        spark_cmd["EQIndex"] = eq_index
    if param:
        spark_cmd["Param"] = param
    print("spark_cmd:", spark_cmd)
    return json.dumps(spark_cmd)


def connect_ue(conn, eq_index):
    msg = create_spark_cmd(cmd="ConnectOneEQ", eq_index=eq_index)
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(5)
    return response


def disconnect_ue(conn, eq_index):
    msg = create_spark_cmd(cmd="DisConnectOneEQ", eq_index=eq_index)
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(5)
    return response


def power_on_ue(conn, eq_index):
    msg = create_spark_cmd(cmd="MTUPowerOn", eq_index=eq_index)
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(30)
    return response


def power_off_ue(conn, eq_index):
    msg = create_spark_cmd(cmd="MTUPowerOff", eq_index=eq_index)
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(30)
    return response


def get_ue_imsi(conn, eq_index):
    msg = create_spark_cmd(cmd="SendAT", eq_index=eq_index, param={"Command": "AT+CIMI", "Timeout": 5000})
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(1)
    return response


def verify_ue_status(conn, eq_index):
    response = get_ue_imsi(conn=conn, eq_index=eq_index)
    result = json.loads(response)
    print('result is:')
    print(result)
    if result["Param"]["State"] != 0:
        return False
    else:
        return True


def recover_ue(conn, eq_index):
    power_off_ue(conn=conn, eq_index=eq_index)
    power_on_ue(conn=conn, eq_index=eq_index)
    disconnect_ue(conn=conn, eq_index=eq_index)
    connect_ue(conn=conn, eq_index=eq_index)
    result = verify_ue_status(conn=conn, eq_index=eq_index)
    if result:
        print("UE recovered after power off and power on ,disconnect and connect UE")
    else:
        print("UE recover failed , please manually check UE status")
    return result


def set_ue_pref_mode(conn, eq_index, pref_mode):
    tmp = 'AT+QNWPREFCFG="mode_pref",pref_mode'
    tmp = tmp.replace('pref_mode', pref_mode)
    print(tmp)
    msg = create_spark_cmd(cmd="SendAT", eq_index=eq_index, param={"Command": tmp, "Timeout": 50000})
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(2)
    return response


def get_ue_pref_mode(conn, eq_index):
    pref_mode = ''
    msg = create_spark_cmd(cmd="SendAT", eq_index=eq_index,
                           param={"Command": 'AT+QNWPREFCFG="mode_pref"', "Timeout": 50000})
    response = json.loads(tcp_send_json(conn=conn, msg=msg))
    time.sleep(2)
    if response["Param"]["State"] == 0:
        if response["Param"]["Back"].find('NR5G') != -1:
            pref_mode = 'NR5G'
        elif response["Param"]["Back"].find('auto') != -1:
            pref_mode = 'auto'
        else:
            pref_mode = 'unknown'
        return pref_mode
    else:
        pref_mode = 'abnormal'
        return pref_mode


def get_ue_nr5g_disable_mode(conn, eq_index):
    nr5g_disable_mode = ''
    msg = create_spark_cmd(cmd="SendAT", eq_index=eq_index,
                           param={"Command": 'AT+QNWPREFCFG="nr5g_disable_mode"', "Timeout": 50000})
    response = json.loads(tcp_send_json(conn=conn, msg=msg))
    time.sleep(2)
    if response["Param"]["State"] == 0:
        if response["Param"]["Back"].find('0') != -1:
            nr5g_disable_mode = '0'
        elif response["Param"]["Back"].find('1') != -1:
            nr5g_disable_mode = '1'
        else:
            nr5g_disable_mode = '2'
    else:
        nr5g_disable_mode = 'abnormal'
    return nr5g_disable_mode


def set_ue_nr5g_disable_mode(conn, eq_index, nr5g_disable_mode):
    tmp = 'AT+QNWPREFCFG="nr5g_disable_mode",nr5g_mode'
    tmp = tmp.replace('nr5g_mode', nr5g_disable_mode)
    print(tmp)
    msg = create_spark_cmd(cmd="SendAT", eq_index=eq_index, param={"Command": tmp, "Timeout": 50000})
    response = tcp_send_json(conn=conn, msg=msg)
    time.sleep(2)
    return response


def initial_SA_ue(conn, eq_index):
    pref_mode = get_ue_pref_mode(conn=conn, eq_index=eq_index)
    print('pref_mode', pref_mode)
    if pref_mode == 'NR5G':
        print('ue pref_mode is NR5G now')
    elif pref_mode == 'abnormal':
        print('ue status is abnormal,please manually check UE status')
    else:
        print('will set pref_mode to NR5G')
        set_ue_pref_mode(conn=conn, eq_index=eq_index, pref_mode='NR5G')
    nr5g_disble_mode = get_ue_nr5g_disable_mode(conn, eq_index=eq_index)
    if nr5g_disble_mode == 'abnormal':
        print('ue status is abnormal,please manually check UE status')
    elif nr5g_disble_mode == '0':
        print('Neither SA or NSA is disabled')
    elif nr5g_disble_mode == '1':
        print('SA is disabled,will set nr5g_disable_mode to 0')
        set_ue_nr5g_disable_mode(conn=conn, eq_index=eq_index, nr5g_disable_mode='0')
    else:
        print('NSA is disabled')


def block_cell(host, cellid):
    dist_name = 'MRBTS-20218/NRBTS-20218/NRCELL-' + str(cellid)
    api = AdminConnection(bts_host=host)
    api.block_cell(dist_name=dist_name)
    api.disconnect()


def unblock_cell(host, cellid):
    dist_name = 'MRBTS-20218/NRBTS-20218/NRCELL-' + str(cellid)
    api = AdminConnection(bts_host=host)
    api.unblock_cell(dist_name=dist_name)
    api.disconnect()
