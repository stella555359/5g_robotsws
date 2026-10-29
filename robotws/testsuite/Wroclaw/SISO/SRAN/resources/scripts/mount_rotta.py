import os
import argparse

parser = argparse.ArgumentParser(description='Mount rotta')
parser.add_argument('username', help="Your Nokia username")
args = parser.parse_args()
rotta_dir = r"/home/ute/rotta"

if not os.path.exists(rotta_dir):
    os.system(r"sudo mkdir -p {}".format(rotta_dir))
os.system(r"sudo mount -t cifs -o user={},sec=ntlmssp //eseefsn50.emea.nsn-net.net/rotta4internal {}"
          .format(args.username, rotta_dir))
