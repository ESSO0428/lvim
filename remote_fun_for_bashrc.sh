# 0. ~/.ssh/config format use tab sep
# 1. add to localhost for vscode remote ssh
# 2. (.bashrc) source /.config/lvim/remote_fun_for_bashrc.sh
update_ssh_hostnames() {
  awk '/^Host / { hostname=$2 } /^\tHostName / { print hostname " " $2 }' ~/.ssh/config > ~/.ssh/host_names
}
update_ssh_hostnames
# ex : ssh LabServerDP 'cat > ~/.ssh/host_names' < ~/.ssh/host_names > /dev/null 2>&1

