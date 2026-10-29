import telnetlib
import time


def wait_for_response(tn, expected_response, timeout=60):
    start_time = time.time()
    while time.time() - start_time < timeout:
        response = tn.read_very_eager().decode('utf-8')
        if expected_response in response:
            return True
        time.sleep(1)
    return False


def execute_cus_command(command):
    HOST = "0"
    PORT = 1234
    TIMEOUT = 60

    try:
        tn = telnetlib.Telnet(HOST, PORT, TIMEOUT)
        print("Connected to Executor console.")
        wait_for_response(tn, "Welcome to Executor console", TIMEOUT)

        # Send the command
        tn.write(command.encode() + b"\n")
        print("Sent '" + command + "' command.")
        if wait_for_response(tn, "<put expected response for the command>", 300):
            print(command + " completed successfully.")
        else:
            print(command + " failed or did not complete in 5 minutes.")

        tn.close()

    except ConnectionRefusedError:
        print("Error: Connection refused.")
