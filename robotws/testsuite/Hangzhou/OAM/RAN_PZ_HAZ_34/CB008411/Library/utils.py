import socket
import json
import time
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
default_host = tl.ues[1].ssh_connection_details.addr


def operate_spark(host=default_host, port=30999, command="attach"):
    try:
        conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        conn.settimeout(30)
        conn.connect((host, port))
        if command == "attach":
            at_value = 1
        else:
            at_value = 0

        msg = {
            "CMD": "SendAT",
            "EQIndex": 1,
            "Param": {"Command": f"AT+CFUN={at_value}", "Timeout": 5000}
        }
        msg = json.dumps(msg)
        msg = msg.encode('utf-8')
        conn.send(msg)
        recv = conn.recv(1024)
        print(recv)
    except Exception as e:
        print(e)
    finally:
        print("finally")
        conn.close()


if __name__ == "__main__":
    operate_spark(host="10.57.236.162", port=30999, command="attach")
    time.sleep(10)
    operate_spark(host="10.57.236.162", port=30999, command="detach")
