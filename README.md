Ansible system management
=========================

This project contains the ansible code that configures and installs my Linux Mint workstation.

Usage
-----

Configure your email address and password in the file personal.yml:

    ---
    # Postfix email relay config
    postfix_sasl_user: "matt.baker@example.com"
    postfix_sasl_pass: "p@55w0rd"
    postfix_unix_user: "matt"
    postfix_relayhost: "[smtp.example.com]:465"

    # Home directory files
    username: matt

Run the `make` command to apply host changes, you need a recent version of Python for this to work.

    make

ToDo
----

Apps yet to be added/managed:

* consul
* kubectl, helm and minikube
* magic8
* bfg.jar
* tflint, terragrunt
* pyenv
* hadolint
* rclone, restic
* more...