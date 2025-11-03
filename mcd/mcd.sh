# npm run build 

source $ANSIBLE_PATH/.venv/bin/activate
cd "$(dirname "$0")"

ansible-playbook -i inventory.ini python.yml --limit mcd-local

# 不备份（默认）
ansible-playbook -i inventory.ini deploy.yml --limit mcd -e "dir=data-model target=/srv/frontend"

# 启用备份
# ansible-playbook -i inventory.ini deploy.yml --limit mcd -e "dir=data-model target=/srv/frontend" bak=true"