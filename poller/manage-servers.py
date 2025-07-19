import json
import subprocess
import paramiko
import argparse
from wakeonlan import send_magic_packet

# Load server list
with open('servers.json') as f:
    servers = json.load(f)

def get_server_by_id(server_id):
    return next((s for s in servers if s["id"] == server_id), None)

def wake_server(server):
    print(f"Waking {server['name']} ({server['mac']})...")
    send_magic_packet(server['mac'])

def shutdown_server(server):
    print(f"Shutting down {server['name']} ({server['ip']})...")

    cmd = server.get("custom_shutdown_script", server["shutdown_cmd"])

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(
        hostname=server["ip"],
        username=server["ssh_user"],
        key_filename=server["ssh_key"]
    )

    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())
    ssh.close()

def list_servers():
    for server in servers:
        print(f"{server['id']}: {server['name']} ({server['ip']})")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--wake", help="Wake server by ID")
    parser.add_argument("--shutdown", help="Shutdown server by ID")
    parser.add_argument("--list", action="store_true", help="List all servers")
    args = parser.parse_args()

    if args.list:
        list_servers()

    if args.wake:
        server = get_server_by_id(args.wake)
        if server:
            wake_server(server)
        else:
            print("Server not found.")

    if args.shutdown:
        server = get_server_by_id(args.shutdown)
        if server:
            shutdown_server(server)
        else:
            print("Server not found.")
