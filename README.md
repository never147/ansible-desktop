Ansible system management
=========================

Configure your email address and password in the file personal.yml:

    ---
    postfix_sasl_user: "matt.baker@example.com"
    postfix_sasl_pass: "p@55w0rd"
    postfix_unix_user: "matt.baker"
    postfix_relayhost: "[smtp.example.com]:465"

Run command to apply host changes:

    make

