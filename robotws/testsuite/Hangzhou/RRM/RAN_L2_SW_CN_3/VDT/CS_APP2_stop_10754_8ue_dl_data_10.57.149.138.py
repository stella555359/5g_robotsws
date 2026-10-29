#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import paramiko
import sys


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    # ======================
    # SSH 连接信息
    # ======================
    host = "10.57.149.138"
    port = 22
    username = "ute"
    password = "Ut3pa5s#ff97"

    # ======================
    # 目标脚本
    # ======================
    script_name = "APP2_10.57.149.138_10754_8ue_start_dl_data.py"

    # 使用 pkill 按脚本名杀进程（-f 可匹配完整命令行）
    stop_command = f"pkill -f {script_name}"

    # 用于确认是否仍在运行
    check_command = f"ps -ef | grep {script_name} | grep -v grep"

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        print(f"[INFO] 正在连接 {host} ...")
        ssh.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            timeout=10
        )
        print("[INFO] SSH 连接成功")

        print(f"[INFO] 正在停止远程脚本: {script_name}")
        ssh.exec_command(stop_command)

        # 再检查一次是否还存在
        stdin, stdout, stderr = ssh.exec_command(check_command)
        result = stdout.read().decode("utf-8", errors="ignore").strip()

        if result:
            print("[WARN] 仍发现进程，可能停止失败：")
            print(result)
        else:
            print("[SUCCESS] 脚本已成功停止")

    except Exception as e:
        print("[ERROR] 停止脚本失败:", e)
        sys.exit(1)

    finally:
        ssh.close()
        print("[INFO] SSH 连接已关闭")


if __name__ == "__main__":
    main()
