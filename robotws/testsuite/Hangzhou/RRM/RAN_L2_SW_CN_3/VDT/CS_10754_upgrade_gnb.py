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
    host = "10.57.251.84"
    port = 22
    username = "ute"
    password = "uteUTE!"

    # ======================
    # 远程目录 & 命令
    # ======================
    remote_dir = (
        "/home/ute/MN/UTE/robotws/testsuite/"
        "Hangzhou/RRM/RAN_L2_SW_CN_3/VDT"
    )

    pyenv_env = "test_repo"
    robot_cmd = "robot -L trace VDT_tl00_gnb_upgrade.robot"

    # ======================
    # 初始化 pyenv + robot 执行
    # ======================
    full_cmd = f"""
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv activate {pyenv_env}
cd {remote_dir}

# 执行 robot
{robot_cmd}
rc=$?

# 重命名 log.html，根据执行结果加上 _fail
if [ -f log.html ]; then
    if [ $rc -eq 0 ]; then
        mv log.html log_upgrade_$(date +%Y%m%d_%H%M%S).html
    el
        mv log.html log_upgrade_$(date +%Y%m%d_%H%M%S)_fail.html
    fi
fi

exit $rc
"""

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        print(f"[INFO] 连接 {host} ...")
        ssh.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            timeout=10
        )
        print("[INFO] SSH 连接成功")

        stdin, stdout, stderr = ssh.exec_command(full_cmd)

        exit_status = stdout.channel.recv_exit_status()

        out = stdout.read().decode(errors="ignore")
        err = stderr.read().decode(errors="ignore")

        print("\n===== STDOUT =====")
        print(out if out.strip() else "(无输出)")

        print("===== STDERR =====")
        print(err if err.strip() else "(无错误输出)")

        print(f"[INFO] 执行完成，退出码: {exit_status}")

    except Exception as e:
        print("[ERROR] 执行失败:", e)
        sys.exit(1)

    finally:
        ssh.close()
        print("[INFO] SSH 连接已关闭")


if __name__ == "__main__":
    main()
