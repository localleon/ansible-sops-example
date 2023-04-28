# Ansible - Working with SOPS

Ansibles lookup Plugin can be used to decrypt SOPS files and hooks into our existing configuration and environment variables

```yaml
---
- name: Load sops-encrypted values
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Print out the root password to the console
      debug: 
        var: lookup('community.sops.sops', 'site-secrets.sops.yaml')
```

```bash
$ ansible-playbook node-playbooks/test.yaml -i env/sample-env/hosts.yaml
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not
match 'all'

PLAY [Load sops-encrypted values] *********************************************************************************

TASK [Print out the root password to the console] *****************************************************************
ok: [localhost] => {
    "lookup('community.sops.sops', 'site-secrets.sops.yaml')": "root_password: MyTest123!"
}

PLAY RECAP ********************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

You can now use SOPS encrypted variables in your playbook. The lookup plugin can also be used in all your variables files -> the following in the host_vars/localhost.yaml: 

```
host_var_password: "{{ (lookup('community.sops.sops', 'site-secrets.sops.yaml') | from_yaml).group_var_test }}"
test: Hallo
```

and then try to output your host-var via playbook: 

```
---
- name: Load sops-encrypted values
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Check if lookup works for host_vars
      ansible.builtin.debug:
        var: host_var_password
```