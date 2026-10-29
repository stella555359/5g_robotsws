import requests


def report_result(result):
    """
    Report test execution result to management system

    Args:
        result: Dictionary containing test execution information
            - test_name: Test case name
            - test_status: Test status (PASS/FAIL)
            - start_time: Test start time
            - end_time: Test end time
            - customer: Customer name
            - sw_version: Software version
            - failure_reason: Failure reason (empty if PASS)
    """
    if "_9999_" in result.get("sw_version", ""):
        result["branch"] = "SBTS00"
        result["sw_version"] = (
            result.get("sw_version", "")
            .replace(result.get("sw_version", "").split("_")[0], "SBTS00")
        )
    else:
        result["branch"] = result.get("sw_version", "").split("_")[0]
    try:
        url = "http://10.0.176.193:8000/api/e2e-case-status/"
        payload = {
            "customer": result.get("customer", ""),
            "testline": result.get("testline", ""),
            "branch": result.get("branch", ""),
            "sw_version": result.get("sw_version", ""),
            "case_name": result.get("test_name", ""),
            "case_status": result.get("test_status", ""),
            "log_path": result.get("log_path", ""),
            "start_time": result.get("start_time", result.get("end_time", "")),
            "end_time": result.get("end_time", ""),
            "failure_reason": result.get("failure_reason", "")
        }
        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(
            url, json=payload, headers=headers, verify=False
        )

        if response.status_code == 200:
            print("Report submitted successfully.")
            test_info = (
                f"Test: {payload['case_name']}, "
                f"Status: {payload['case_status']}"
            )
            print(test_info)
        else:
            print(
                f"Failed to submit report. "
                f"Status code: {response.status_code}"
            )
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"An error occurred: {e}")
