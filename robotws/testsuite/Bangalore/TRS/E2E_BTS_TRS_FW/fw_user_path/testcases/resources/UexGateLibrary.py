import pexpect


class UexGateLibrary:
    def run_uexgate_script(self, script_path):
        # Start the uexgate shell
        child = pexpect.spawn('uexgate')

        # Wait for the UExGate> prompt
        child.expect('UExGate>')

        # Send the command
        command = "script file={}".format(script_path)
        child.sendline(command)

        # Wait for the UExGate> prompt to appear again
        # indicating that the script has finished executing
        child.expect('UExGate>', timeout=360)  # adjust timeout as per your requirements

        # Get the output
        output = child.before

        # Decode the output from bytes to string
        output = output.decode('utf-8')

        # Return the output
        return output
