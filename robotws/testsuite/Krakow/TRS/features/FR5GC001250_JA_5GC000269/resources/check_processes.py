from taf.transport.ssh import interface
ssh = interface.ssh()

root_services_list_CU = "./testsuite/TRS/Wroclaw/MzOAM/CLOUD/Features/5GC000269/resources/root_services_list.txt"
root_services_list_DU = "./testsuite/TRS/Wroclaw/MzOAM/CLOUD/Features/5GC000269/resources/root_services_list_DU.txt"


def trim_process(process):
    process = str(process)
    if process.endswith("]"):
        return process.strip("[]").split("/")[0]
    else:
        return process.split("/")[-1]


def compare_process(root_services_list, alive_root_processes):
    wrong_process = set()
    for alive_process in alive_root_processes.split():
        for root_service in root_services_list.split():
            alive_process = trim_process(alive_process)
            root_service = trim_process(root_service)
            if root_service in alive_process or alive_process in root_service:
                break
        else:
            wrong_process.add(str(alive_process))
    return wrong_process


def check_processes_on(vm):
    if vm != "BB1":
        root_valid_processes = open(root_services_list_CU).read()
    else:
        root_valid_processes = open(root_services_list_DU).read()

    alive_root_processes = ssh.execute(
        command="ps -aux | awk '($1==\"root\" && $11!=\"ps\" && $11!=\"awk\") {print $11}'",
        connection=vm)

    wrong_process_list = compare_process(root_valid_processes, alive_root_processes)
    assert not wrong_process_list, wrong_process_list
