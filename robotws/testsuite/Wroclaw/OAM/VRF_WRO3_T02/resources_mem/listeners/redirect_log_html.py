import os
import shutil


class RedirectLogHTMLListener:
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, user_path=None):
        self.user_path = user_path
        self.output_dir = os.getcwd()

    def start_suite(self, name, attrs):
        self.output_dir = attrs.get("outputdir", os.getcwd())

    def close(self):
        target_dir = self.user_path or os.environ.get("LOG_TARGET_PATH")
        if not target_dir:
            print("[Listener] No target path defined.")
            return
        source_path = os.path.join(self.output_dir, "log.html")
        if not os.path.exists(source_path):
            print(f"[Listener] log.html not found at: {source_path}")
            return
        try:
            os.makedirs(target_dir, exist_ok=True)
            shutil.copy2(source_path, os.path.join(target_dir, "log.html"))
            print(f"[Listener] log.html successfully copied to: {target_dir}")
        except Exception as e:
            print(f"[Listener] Failed to copy log.html: {e}")
