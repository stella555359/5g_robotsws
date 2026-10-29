def remove_lines_with_robot(result):
    result = result.splitlines()
    result_without_robot = [str(line) for line in result if "robot" not in line]
    return result_without_robot
