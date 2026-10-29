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
    # 远程执行命令
    # ======================
    remote_dir = "/home/ute"
    script_name = "APP2_10.57.149.138_10754_8ue_start_dl_data.py"

    command = f"cd {remote_dir} && python3 {script_name}"

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

        print("[INFO] 开始执行远程脚本...")
        stdin, stdout, stderr = ssh.exec_command(command)

        # 等待命令执行完成
        exit_status = stdout.channel.recv_exit_status()

        # 读取输出
        out = stdout.read().decode("utf-8", errors="ignore")
        err = stderr.read().decode("utf-8", errors="ignore")

        print("\n===== STDOUT =====")
        if out.strip():
            print(out)
        else:
            print("(无输出)")

        print("===== STDERR =====")
        if err.strip():
            print(err)
        else:
            print("(无错误输出)")

        print(f"[INFO] 远程命令退出码: {exit_status}")

    except Exception as e:
        print("[ERROR] 执行失败:", e)
        sys.exit(1)

    finally:
        ssh.close()
        print("[INFO] SSH 连接已关闭")


if __name__ == "__main__":
    main()
