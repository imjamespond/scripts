source $ANSIBLE_PATH/.venv/bin/activate

ansible -i hosts.ini db13 -m ping

ansible -i hosts.ini all -m command -a "uptime"

ansible -i hosts.ini --limit vps -m ping

ansible -i hosts.ini vps -m command -a "ls ~"