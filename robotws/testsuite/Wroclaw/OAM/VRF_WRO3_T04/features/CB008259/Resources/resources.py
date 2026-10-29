import re
from pexpect import pxssh
from robot.api import logger
from aashell_resources import LIST_OF_AVAILABLE_AASHELL_COMMANDS, COMMANDS_WITH_DUPLICATED_OPTIONS, \
    COMMANDS_WITH_DUPLICATED_USAGE, COMMANDS_FOR_SBTS23R4_SPECIFIC


def get_list_of_params_for_crldpconfig_object():
    params_list = [
        {"parameterName": "primaryCRLDP",
         "operation": "update",
         "value": "http://10.42.54.13:8080/crl-as-der/currentcrl-3192890.crl?id=3192890"}
    ]
    return params_list


def get_failure_reason_of_certificate(crl_list):
    for cert in crl_list:
        return cert['stateInfo']['reasoningStatus']
    return False


def create_caSubjectName_parameter_raw_string(caSubjectName_param):
    return r'{param}'.format(param=caSubjectName_param)


def get_restore_vendor_certificate_error_code(error_msg):
    return error_msg[error_msg.index("ErrorCode"):]


def check_cert_error_alarm(alarms_info):
    for alarm in alarms_info:
        if alarm['faultName'] == 'CRL Update Failure':
            return True
    return False


def create_ssh_session_with_system_module(host_ip, username, password):
    ssh_session = pxssh.pxssh()
    ssh_session.login(host_ip, username, password)
    return ssh_session


def kill_ssh_session_with_system_module(ssh_session):
    ssh_session.logout()


def create_telnet_aashell_session_inside_ssh_tunnel(ssh_session):
    ssh_session.sendline('telnet 127.0.0.1 15007')


def kill_telnet_aashell_session_inside_ssh_tunnel(ssh_session):
    ssh_session.sendline('quit\n')


def get_clean_aashell_output(command, output):
    return output[output.rindex("AaShell> " + command) + len("AaShell> " + command):output.rindex("AaShell>")]


def get_output_of_aashell_command(command, ssh_session):
    ssh_session.sendline(command)
    ssh_session.prompt()  # match the prompt
    terminal_output = ssh_session.before.decode('utf-8')
    clean_output = get_clean_aashell_output(command, terminal_output)
    return clean_output


def get_operations_of_aashell_command(command, ssh_session):
    commands_help = get_output_of_aashell_command(command, ssh_session)
    first_part = commands_help[commands_help.index('operations'):]
    operations_section_of_commands_help = first_part[:first_part.index('Examples')]
    list_of_operations = re.findall(" \s+-[a-z]{1,3} ", operations_section_of_commands_help)  # noqa
    list_of_operations = [el.strip() for el in list_of_operations]
    return list(dict.fromkeys(list_of_operations))


def get_usage_of_aashell_command(command, ssh_session):
    commands_help = get_output_of_aashell_command(command, ssh_session)
    first_part = commands_help[commands_help.index('USAGE'):]
    if 'Examples' in first_part:
        operations_section_of_commands_help = first_part[:first_part.index('Examples')]
    else:
        operations_section_of_commands_help = first_part
    list_of_usage = re.findall(" \s+-[a-z]{1,3} ", operations_section_of_commands_help)  # noqa
    list_of_usage = [el.strip() for el in list_of_usage]
    return list(dict.fromkeys(list_of_usage)) if command not in COMMANDS_WITH_DUPLICATED_USAGE else list_of_usage


def get_options_of_aashell_command(command, ssh_session):
    commands_help = get_output_of_aashell_command(command, ssh_session)
    if 'options for' in commands_help:
        first_part = commands_help[commands_help.index('options for'):]
    elif 'options:' in commands_help:
        first_part = commands_help[commands_help.index('options:'):]
    elif 'Options:' in commands_help:
        first_part = commands_help[commands_help.index('Options:'):]
    else:
        first_part = commands_help[commands_help.index('options'):]

    if 'Examples' in first_part:
        options_section_of_commands_help = first_part[:first_part.index('Examples')]
    elif 'Restrictions' in first_part:
        options_section_of_commands_help = first_part[:first_part.index('Restrictions')]
    else:
        options_section_of_commands_help = first_part
    list_of_options = re.findall(" \s+-[a-z]{1,3} ", options_section_of_commands_help)  # noqa
    list_of_options = [el.strip() for el in list_of_options]
    return list(dict.fromkeys(list_of_options)) if command not in COMMANDS_WITH_DUPLICATED_OPTIONS else list_of_options


def get_actions_of_aashell_command(command, ssh_session):
    commands_help = get_output_of_aashell_command(command, ssh_session)
    if 'actions:' in commands_help:
        first_part = commands_help[commands_help.index('actions:'):]
    elif 'Actions:' in commands_help:
        first_part = commands_help[commands_help.index('Actions:'):]
    else:
        first_part = commands_help[commands_help.index('actions'):]

    if 'Options:' in first_part:
        actions_section_of_commands_help = first_part[:first_part.index('Options:')]
    elif 'options for' in first_part:
        actions_section_of_commands_help = first_part[:first_part.index('options for')]
    else:
        actions_section_of_commands_help = first_part
    list_of_actions = re.findall(" \s+-[a-z]{1,3} ", actions_section_of_commands_help)  # noqa
    list_of_actions = [el.strip() for el in list_of_actions]
    return list(dict.fromkeys(list_of_actions))


def get_aashell_commands_list(output):
    result_list = []
    output = output.split("------------------------------------")[1]
    output = output.split("\n")
    for command in output:
        command = command.split(" ")
        if len(command) != 1:
            command = [el for el in command if el != '']
            command_name = command[0]
            command_description = ' '.join(command[1:])
            result_list.append({"Command name": command_name, "Command description": command_description})
    return result_list


def compare_aashell_commands(ssh_session, sbts23r4_release):
    logger.console("\n")
    for index, command in enumerate(LIST_OF_AVAILABLE_AASHELL_COMMANDS):
        separator_string_to_log = str(index + 1) + "." + "-" * 25 + "Checking {command_name} command".format(
            command_name=command['Command name']) + "-" * 25
        logger.console(separator_string_to_log)
        print("Command should contain:\n{command_information}".format(command_information=command))

    # if section, responsible for Trunk specific commands (at this moment contains only 2 commands: sysinfo and atrace)
        if command['Command name'] in COMMANDS_FOR_SBTS23R4_SPECIFIC:
            if sbts23r4_release:
                if command['Command name'] == "sysinfo":
                    LIST_OF_AVAILABLE_AASHELL_COMMANDS[index]['Command options'] \
                        = ['-a', '-c', '-h', '-i', '-l', '-lp', '-n', '-p', '-s', '-x', '-r', '-d']
                elif command['Command name'] == "atrace":
                    LIST_OF_AVAILABLE_AASHELL_COMMANDS[index]['Command usage'] = ['-h', '-m', '-c', '-d', '-s']
                    LIST_OF_AVAILABLE_AASHELL_COMMANDS[index]['Valid flags to check'] = ['-m OFF', '-c', '-d', '-s']
                    LIST_OF_AVAILABLE_AASHELL_COMMANDS[index]['Output for valid flags'] = \
                        ["Disabling tracing",
                         "Configuration:",
                         "Requested to dump allocation traces.",
                         "Requested to dump decoded allocation traces."]

        if 'Command usage' in command:
            command_usage = get_usage_of_aashell_command(command['Command help information'], ssh_session)
            logger.console("Collected command usage flags: {command_usage_collected}".format(
                command_usage_collected=command_usage))
            logger.console("Command usage flags should be: {command_usage_saved}".format(
                command_usage_saved=command['Command usage']))
            assert command_usage == command['Command usage']

        if 'Command options' in command:
            command_options = get_options_of_aashell_command(command['Command help information'], ssh_session)
            logger.console("Collected command options flags: {command_options_collected}".format(
                command_options_collected=command_options))
            logger.console("Command options flags should be: {command_options_saved}".format(
                command_options_saved=command['Command options']))
            assert command_options == command['Command options']

        if 'Command operations' in command:
            command_operations = get_operations_of_aashell_command(command['Command help information'], ssh_session)
            logger.console("Collected command operations flags: {command_operations_collected}".format(
                command_operations_collected=command_operations))
            logger.console("Command operations flags should be: {command_operations_saved}".format(
                command_operations_saved=command['Command operations']))
            assert command_operations == command['Command operations']

        if 'Command actions' in command:
            command_actions = get_actions_of_aashell_command(command['Command help information'], ssh_session)
            logger.console("Collected command actions flags: {command_actions_collected}".format(
                command_actions_collected=command_actions))
            logger.console("Command actions flags should be: {command_actions_saved}".format(
                command_actions_saved=command['Command actions']))
            assert command_actions == command['Command actions']

        if 'Invalid flag to check' in command:
            output_for_invalid_flag = get_output_of_aashell_command(
                command['Command name'] + " " + command['Invalid flag to check'], ssh_session)
            print("Flag output for {command} command with invalid {flag} flag is:\n{flag_output}".format(
                command=command['Command name'], flag=command['Invalid flag to check'],
                flag_output=output_for_invalid_flag))
            if command['Output for invalid flag'] == "help_message":
                command_help_message = get_output_of_aashell_command(command['Command help information'], ssh_session)
                assert command_help_message == output_for_invalid_flag
            elif type(command['Output for invalid flag']) is str:
                assert command['Output for invalid flag'] in output_for_invalid_flag
            else:
                assert len(output_for_invalid_flag) == 2  # escape sequences in output, basically its empty string
            logger.console("Command reacts properly for the invalid tag {invalid_tag}".format(
                invalid_tag=command['Invalid flag to check']))

        if 'Valid flags to check' in command:
            for flag in command['Valid flags to check']:
                output_for_valid_flag = get_output_of_aashell_command(command['Command name'] + " " + flag, ssh_session)
                print("Flag output for {command} command with valid {flag} flag is:\n{flag_output}".format(
                    command=command['Command name'], flag=flag, flag_output=output_for_valid_flag))
                assert bool([valid_flags_output for valid_flags_output in command['Output for valid flags'] if
                             valid_flags_output in output_for_valid_flag])
                logger.console("Command reacts properly for the valid flag {valid_flag}".format(
                    valid_flag=flag))
            logger.console("Command reacts properly for all the valid flags {list_of_valid_flags}".format(
                list_of_valid_flags=command['Valid flags to check']))
