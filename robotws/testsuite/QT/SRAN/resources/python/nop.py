import re
import time
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

ssh = ssh()


def check_nop_pod_status(nop_namespace, connection='RM_alias'):
    """
    Check the status of NOP pods in the specified Kubernetes namespace via SSH.

    This function executes a kubectl command to retrieve the status of all pods in
    the given namespace. It analyzes the pod status output and returns a
    dictionary with basic flags and a human-readable message.

    Returned dictionary keys:
        - 'output':  Raw output from the kubectl command (stripped).
        - 'redploy': True if no resources are found (redeploy may be needed),
                     False otherwise.
        - 'recheck': True if any pod is not running (recheck is needed),
                     False otherwise.
        - 'result':  True if all pods are running normally, False otherwise.
        - 'message': Human-readable status/diagnostic message describing the
                     current situation.

    Args:
        nop_namespace (str): Kubernetes namespace where NOP is deployed.
        connection (str, optional): SSH connection alias. Defaults to 'RM_alias'.

    Returns:
        dict: Dictionary with pod status analysis:
            {
                'output':  <str>,
                'redploy': <bool>,
                'recheck': <bool>,
                'result':  <bool>,
                'message': <str>,
            }
    """
    result_dict = {}
    cmd = f"kubectl get pods -n {nop_namespace}|awk 'NR>1{{print $3}}'"
    output = ssh.execute(cmd, connection)

    logger.info(f"NOP Status Output: {output}")

    result_dict['output'] = output.strip()
    result_dict['redploy'] = False
    result_dict['recheck'] = False
    result_dict['result'] = False
    result_dict['message'] = ""

    if re.findall(r"No resources found", output):
        msg = (
            f"NOP deploy failed in namespace '{nop_namespace}': "
            f"no resources found.\n"
            f"kubectl output:\n{result_dict['output']}"
        )
        logger.error(msg)
        result_dict['redploy'] = True
        result_dict['message'] = msg
        return result_dict

    if re.findall(r"ImagePullBackOff|ErrImagePull", output):
        msg = (
            f"NOP deploy failed in namespace '{nop_namespace}': "
            f"ImagePullBackOff / ErrImagePull.\n"
            f"kubectl output:\n{result_dict['output']}"
        )
        logger.error(msg)
        result_dict['message'] = msg
        return result_dict

    for status in output.splitlines():
        if status != "Running":
            msg = (
                f"NOP deploy failed in namespace '{nop_namespace}': "
                f"pods are not in Running state.\n"
                f"kubectl output:\n{result_dict['output']}"
            )
            logger.error(msg)
            result_dict['recheck'] = True
            result_dict['message'] = msg
            return result_dict

    msg = f"NOP in namespace '{nop_namespace}' is running normally."
    logger.info(msg)
    result_dict['result'] = True
    result_dict['message'] = msg
    return result_dict


def deploy_nop(
    nop_name,
    nop_installation_cmd,
    deploy_tries=2,
    connection='RM_alias',
):
    """
    Deploy NOP in the specified namespace.

    Args:
        nop_name (str): The name of the NOP to deploy.
        nop_installation_cmd (str): The command to install NOP.
        deploy_tries (int): The number of deployment attempts.
        connection (str): The connection alias to use for SSH.
    """
    pod_loop_check = 4
    last_nop_status = None

    for attempt in range(deploy_tries):
        logger.console(
            f"-----> {nop_name} installation attempt "
            f"{attempt + 1}/{deploy_tries}\n"
        )

        nop_installation = ssh.execute(nop_installation_cmd, connection)
        if not re.findall(r"STATUS: deployed", nop_installation):
            BuiltIn().fail(
                f"NOP deploy failed: {nop_installation.strip()}"
            )

        check_nop_installation = ssh.execute(
            f"helm list -n {nop_name}|awk 'NR==2'",
            connection,
        )
        if not re.findall(rf"{nop_name}", check_nop_installation):
            BuiltIn().fail(
                f"NOP deploy failed: {check_nop_installation.strip()}"
            )

        for pod_check in range(pod_loop_check):
            logger.console(
                f"-----> Checking {nop_name} pod status, attempt "
                f"{pod_check + 1}/{pod_loop_check}\n"
            )
            time.sleep(30)

            nop_pod_status = check_nop_pod_status(nop_name, connection)
            last_nop_status = nop_pod_status

            if nop_pod_status['result']:
                logger.info(f"{nop_name} deployed successfully.")
                return

            if not nop_pod_status['recheck'] and not nop_pod_status['redploy']:
                logger.console(
                    f"-----> Failing deployment of {nop_name} due to pod status. ImagePullBackOff / ErrImagePull.\n"
                )
                BuiltIn().fail(nop_pod_status['message'])

            elif pod_check == pod_loop_check - 1:
                logger.console(
                    f"-----> Max pod status checks reached for {nop_name}.\n"
                )
                BuiltIn().fail(nop_pod_status['message'])

            elif nop_pod_status['redploy']:
                logger.console(
                    f"-----> Reinstalling {nop_name} due to pod status. No resources found.\n"
                )
                BuiltIn().run_keyword(
                    'Uninstall NOP',
                    nop_name,
                    nop_name,
                )
                break

            elif nop_pod_status['recheck']:
                logger.console(
                    f"-----> Rechecking {nop_name} pod status. Pods are not in Running state.\n"
                )
                continue

    if last_nop_status is not None:
        BuiltIn().fail(last_nop_status['message'])
    else:
        BuiltIn().fail(
            f"NOP deploy failed for {nop_name}: no pod status collected."
        )


if __name__ == "__main__":
    ssh.connect_to(hostname='10.68.144.50', username='core', password='system123', alias='RM_alias')
    print(check_nop_pod_status('ran-nic-sw-controller'))
