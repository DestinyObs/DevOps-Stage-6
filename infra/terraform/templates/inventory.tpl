all:
  hosts:
    app_server:
      ansible_host: ${server_ip}
      ansible_user: ${ssh_user}
      ansible_ssh_private_key_file: ${ssh_private_key}
      ansible_python_interpreter: /usr/bin/python3
      
      # Application variables
      deploy_user: ${deploy_user}
      domain_name: ${domain_name}
      app_repo: https://github.com/DestinyObs/DevOps-Stage-6.git
      app_directory: /home/${deploy_user}/DevOps-Stage-6
      
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
