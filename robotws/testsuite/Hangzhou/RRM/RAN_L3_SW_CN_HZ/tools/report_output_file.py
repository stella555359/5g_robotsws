import sys
import os
import traceback
import json

curdir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, curdir)
sys.path.insert(1, os.path.join(curdir, "../resources/DevHZ5_lib/src/base_lib"))
try:
    from ta_ssh_telnet import ta_ssh_telnet
except Exception:
    raise


def connect_ssh(cmd, timeout=10):
    ssh_obj = ta_ssh_telnet()
    pc_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")
    try:
        ssh_obj.switch_host_connection(pc_conn)
        ssh_obj.set_shell_timeout(int(timeout))
        ssh_obj.execute_shell_command('robot')
        out = ssh_obj.execute_shell_command(cmd)
    except Exception:
        detail = traceback.format_exc()
        try:
            ssh_obj.disconnect_from_host(pc_conn)
        except Exception:
            pass
        pc_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")
        ssh_obj.switch_host_connection(pc_conn)
        ssh_obj.set_shell_timeout(int(timeout))
        ssh_obj.execute_shell_command('robot')
        out = ssh_obj.execute_shell_command(cmd)
    print(out)
    return out


def get_output_file_list(out_put_path):
    dir_file_list = os.listdir(out_put_path)
    new_output_file_list = []

    for filename in dir_file_list:
        if filename.endswith('output.xml'):
            filename_path = os.path.join(out_put_path, filename)
            new_output_file_list.append(filename_path)
    print("all output files list:\n{}".format(new_output_file_list))
    return new_output_file_list


def gernerate_report_cmd(output_filepath_list,
                         sw_version,
                         testline_topology,
                         username='ncommon'):
    report_cmd_list = []
    hostname = connect_ssh('hostname')
    tl = hostname.replace('-', '_')
    print("report cmd of all testcase as below:\n")
    for filename_path in output_filepath_list:
        report_cmd = 'ute_reporting_portal send -ie -ro %s -tl %s --info %s -l %s --sw_version "%s" --username "%s"' % (
            filename_path, tl, testline_topology, testline_topology, sw_version, username)
        report_cmd_list.append(report_cmd)
        print("%s\n" % (report_cmd))
    return report_cmd_list


if __name__ == '__main__':
    if len(sys.argv) == 1 or len(sys.argv) == 2 or len(sys.argv) > 5:
        print("Usages: python %s  <output_file_path> <sw_version> <username> <testline_topology> " % sys.argv[0])
        print("Example 1: use current testline_topology=CLOUD_5G_I_BO_AP_KLLL_SANSA_FS_CPRI_CMWV_FDD"
              "and username=ncommon")
        print("python %s  <output_file_path> <sw_version>" % sys.argv[0])
        print("Example 2: specify all attribution")
        print("python %s  <output_file_path> <sw_version> <testline_topology>" % sys.argv[0])
        print("Example 3: specify all attribution")
        print("python %s  <output_file_path> <sw_version> <testline_topology> <username>" % sys.argv[0])
    else:
        output_file_path = sys.argv[1]
        new_output_file_list = get_output_file_list(output_file_path)
        if len(sys.argv) == 4 or len(sys.argv) == 5:
            testline_topology = sys.argv[3]
        elif len(sys.argv) < 4:
            try:
                with open('/opt/ute/reservation.json', 'r', encoding='utf-8') as f:
                    read_testline_info = json.load(f)
                    testline_topology = read_testline_info['topology']
            except Exception:
                raise ("your testline is local env, please input additional testline topology")
        else:
            testline_topology = 'CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD'
        if not len(new_output_file_list):
            print("there is no output.xml file under %s", sys.argv[1])
        else:  # get output files list
            sw_version = sys.argv[2]
            command_len = len(sys.argv)
            # get list for send report command
            if command_len == 3 or command_len == 4:
                report_cmd_list = gernerate_report_cmd(new_output_file_list, sw_version, testline_topology)
            elif command_len == 5:
                username = sys.argv[4]
                report_cmd_list = gernerate_report_cmd(new_output_file_list, sw_version, testline_topology, username)
                # report command
            n = 0
            try:
                for cmd in report_cmd_list:
                    connect_ssh(cmd)
                    n += 1
                    print("finish %d output file report" % (n))
                print("report %d output file successfully" % (len(report_cmd_list)))
            except Exception as e:
                print(e)
