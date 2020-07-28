Ansible system management
=========================

Configure your email address and password in the file personal.yml:

    ---
    postfix_sasl_user: "matthew.x.baker@oracle.com"
    postfix_sasl_pass: "p@55w0rd"

Run command to apply host changes:

    make

