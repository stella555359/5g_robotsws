from ute_fsmaccess import ute_fsmaccess
import re
import logging
import testsuite.Krakow.resources.from_ulm.Common.python.testline


def generate_command_set_destination_ip(dest_ip, common_unit_type):
    if common_unit_type == "ASIB":
        cmdStr = "cd /opt/trs/bin ; ./vtc 5gicomgw stream_config_add 192.168.253.20 " + str(dest_ip) + " 5678 32"
        return cmdStr
    else:
        cmdStr1 = "cd /opt/trs/bin ; ./trs-vppctl "
        cmdStr2 = "icom set_stream_conf src_ip 192.168.253.20 dst_ip " + str(dest_ip) + " dscp 32 dst_port 5678"
        cmdStr = cmdStr1 + cmdStr2
        return cmdStr


def generate_tti_trace_start_command(pci, eqid, _node_id):
    cmdStr1 = "curl -i -H \"Content-Type: application/json\" -X POST -d '{\"key\":{\"nodeId\":"+str(_node_id)+", "
    cmdStr2 = "\"upSw\":\"l2ps\", \"traceType\":\"component\"},\"data\":{ \"state\":\"start\", \"eqId\":"+str(eqid)
    cmdStr3 = ", \"pciList\":\"["+str(pci)+"]\" }}' http://127.0.0.1:8008/troubleshooting/l2Stream"
    cmdStr = cmdStr1 + cmdStr2 + cmdStr3
    print("TTI Start Command: %s" % cmdStr)
    return cmdStr


def generate_tti_trace_stop_command(pci, eqid, _node_id):
    cmdStr1 = "curl -i -H \"Content-Type: application/json\" -X POST -d '{\"key\":{\"nodeId\":"+str(_node_id)+", "
    cmdStr2 = "\"upSw\":\"l2ps\", \"traceType\":\"component\"},\"data\":{ \"state\":\"stop\", \"eqId\":"+str(eqid)
    cmdStr3 = ", \"pciList\":\"["+str(pci)+"]\" }}' http://127.0.0.1:8008/troubleshooting/l2Stream"
    cmdStr = cmdStr1 + cmdStr2 + cmdStr3
    print("TTI Stop Command: %s" % cmdStr)
    return cmdStr


def startTtiTraces(tl, dest_ip, eqid, node_id, common_unit_type, gnb_id=0, du_id=0, common_unit_id=0, pci=50):
    host = tl.gnbs[int(gnb_id)].dus[int(du_id)].airscale.common_units[int(common_unit_id)].lmp_connection.addr
    _node_id = node_id
    print("============================== Begin startTtiTraces()")
    try:
        fsmAccessObj = ute_fsmaccess()
        fsmAccessObj.setup_enb_fsm_access(host=host, alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        cmd_set_dest_ip = generate_command_set_destination_ip(dest_ip, common_unit_type)
        print(cmd_set_dest_ip)
        outStr = fsmAccessObj.execute_command_on_enb(cmd_set_dest_ip, alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if common_unit_type == "ASIB":
            cmdStr = "cd /opt/trs/bin ; ./vtc 5gicomgw stream_config_show"
        else:
            cmdStr = "cd /opt/trs/bin ; ./trs-vppctl show icom counters"
        outStr = fsmAccessObj.execute_command_on_enb(cmdStr, alias="gnb")
        print(outStr)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        cmd_start_tti_trace = generate_tti_trace_start_command(pci, eqid, _node_id)
        outStr = fsmAccessObj.execute_command_on_enb(cmd_start_tti_trace, alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        fsmAccessObj.teardown_enb_fsm_access(alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        print("TTI Trace started!\n")
        print("============================== End startTtiTraces()")
        return True
    except Exception as e:
        print("TTI Traces NOT started!\n")
        print("============================== End startTtiTraces()")
        return False


def stopTtiTraces(tl, eqid, node_id, common_unit_type, gnb_id=0, du_id=0, common_unit_id=0, pci=50):
    host = tl.gnbs[int(gnb_id)].dus[int(du_id)].airscale.common_units[int(common_unit_id)].lmp_connection.addr
    _node_id = node_id
    print("============================== Begin stopTtiTraces()")
    try:
        fsmAccessObj = ute_fsmaccess()
        fsmAccessObj.setup_enb_fsm_access(host=host, alias="gnb")
        cmd_stop_tti_trace = generate_tti_trace_stop_command(pci, eqid, _node_id)
        outStr = fsmAccessObj.execute_command_on_enb(cmd_stop_tti_trace, alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        fsmAccessObj.teardown_enb_fsm_access(alias="gnb")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        print("TTI Trace stopped!\n")
        print("============================== End stopTtiTraces()")
        return True
    except Exception as e:
        print("TTI Traces NOT stopped!\n")
        print("============================== End stopTtiTraces()")
        return False


def extract_eqid(output_string):
    try:
        result = re.search(r'\'emQueueId\' : (\d+)', output_string)
        ans = result.group(1)
    except IndexError:
        logging.warning("EQID was not extracted from ASIB default EQID used")
        ans = "17304555"
    return ans


def add_File_ending_if_missing(file_path, file_ending):
    if file_ending not in file_path:
        file_path += file_ending
    return file_path


def get_source_IP_address(raw_ip):
    try:
        searchObject = re.search("inet [0-9,.]*", raw_ip)
        source_ip = searchObject.string[searchObject.span()[0]+5:searchObject.span()[1]]
    except AttributeError:
        logging.warning("Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
        source_ip = "10.0.1.2"
    except TypeError:
        logging.warning("Wrong Input Type was given. setting IP to 10.0.1.2")
        source_ip = "10.0.1.2"
    return source_ip


if __name__ == '__main__':
    print(get_source_IP_address(raw_ip=""))
