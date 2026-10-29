def parse_node_list_return_pid_application_list(node_list, pid_and_application_regex):
    all_processes_and_applications = []
    for node in node_list:
        match = pid_and_application_regex.match(node)
        if match:
            pid = str(match.group("pid"))
            application = str(match.group("application"))
            all_processes_and_applications.append((pid, application))
    return all_processes_and_applications
