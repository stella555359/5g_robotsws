from docker import DockerClient, errors
from robot.api import logger


client = DockerClient.from_env()


def is_docker_running():
    try:
        client.ping()
        logger.debug("Docker is running")
        return True
    except errors.DockerException as e:
        logger.debug("Docker is not running")
        return False


def list_containers(all_containers=True):
    containers = client.containers.list(all=all_containers)
    for c in containers:
        logger.debug(f"Container: short_id={c.short_id}, name={c.name}, status={c.status}, image={c.image.tags}")
    return containers


def stop_container(name_or_id, timeout=10):
    try:
        c = client.containers.get(name_or_id)
        logger.debug(f"Stopping container: short_id={c.short_id} name={c.name}")
        c.stop(timeout=timeout)
        logger.debug("Container stopped")
    except errors.NotFound:
        logger.debug(f"Container not found: {name_or_id}")
    except errors.APIError as e:
        logger.debug(f"Error stopping container: {e.explanation}")


def restart_container(name_or_id):
    try:
        c = client.containers.get(name_or_id)
        logger.debug(f"Restarting container: short_id={c.short_id} name={c.name}")
        c.restart()
        print("Container restarted")
    except errors.NotFound:
        logger.debug(f"Container not found: {name_or_id}")
    except errors.APIError as e:
        logger.debug(f"Error restarting container: {e.explanation}")


def is_container_running(name_or_id):
    """
    Check whether a specific container (by name or ID) is currently running.

    Returns:
      True  -> container exists and is running
      False -> container does not exist OR is not running OR an error occurred

    Notes:
    - This uses client.containers.get(name_or_id) which raises docker.errors.NotFound
      if the container doesn't exist.
    - We call c.reload() to ensure we have the latest state before checking status.
    """
    try:
        logger.debug(f"Check if container {name_or_id} is running")
        c = client.containers.get(name_or_id)
        c.reload()
        logger.debug(f"Container is running: short_id={c.short_id} name={c.name}")
        return c.status == "running"
    except errors.NotFound:
        logger.debug(f"Container not found: {name_or_id}")
        return False
    except errors.DockerException as e:
        logger.debug(f"Error checking container: {e}")
        return False


def container_exists(name_or_id):
    """
    Check whether a specific container (by name or ID) exists.

    Returns:
      True  -> container exists
      False -> container does not exist OR an error occurred
    """
    try:
        client.containers.get(name_or_id)
        logger.debug(f"Container found: {name_or_id}")
        return True
    except errors.NotFound:
        logger.debug(f"Container not found: {name_or_id}")
        return False
    except errors.DockerException as e:
        logger.debug(f"Error checking container existence: {e}")
        return False


def remove_container(name_or_id, timeout=10):
    """
    Remove a specific container by name or ID.

    Parameters:
      name_or_id (str): container name or ID
      timeout (int): seconds to wait when stopping a running container if force=False

    Returns:
      True  -> removal succeeded
      False -> removal failed (not found or error)
    """
    try:
        c = client.containers.get(name_or_id)
        c.reload()

        try:
            c.remove(force=True)
            logger.debug(f"Removed container: short_id={c.short_id} name={c.name}")
            return True
        except errors.APIError as e:
            logger.debug(f"API error while removing container: {e.explanation}")
            return False
    except errors.NotFound:
        logger.debug(f"Container not found: {name_or_id}")
        return False
    except errors.DockerException as e:
        logger.debug(f"Error removing container: {e}")
        return False
