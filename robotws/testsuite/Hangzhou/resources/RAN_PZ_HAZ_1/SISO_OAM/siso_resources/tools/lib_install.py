import os


def lib_install():
    VIRTUAL_ENV_SCRIPT_PATH = "/home/ute/test_repo/bin/activate"
    LIB_INSTALL_COMMAND = "bash -ce \
    'source /home/ute/test_repo/bin/activate; \
    export http_proxy=10.144.1.10:8080; \
    export https_proxy=10.144.1.10:8080; \
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ bokeh; \
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ numpy; \
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ pandas'"

    if os.path.exists(VIRTUAL_ENV_SCRIPT_PATH):
        os.system(LIB_INSTALL_COMMAND)
    else:
        pass


if __name__ == "__main__":
    lib_install()
