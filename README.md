# SOPS Examples for Ansible and isindir/SOPS-Secret-Operator for Kubernetes

Repository to demonstrate Moziall SOPS working with Ansible. All keys and values in this repository are dummy data and are not really used anywhere! You can use the generated dummy key with `export SOPS_AGE_KEY_FILE=./sops-key-sample-env.txt``or generate one for yourself with `age-keygen -o key.txt`

The guides for Ansible and Kubernetes are in seperate files. The main README.md contains general knowledge about age and sops.
- [Ansible Guides](Ansible.md)
- [Kubernetes Notebook](Kubernetes.ipynb)
- [Hooking into Git](Git-Filters.md)

## Prerequisites
Create the File `env/sample-env/secrets.yaml` with a normal text editor locally, but don't commit it into git yet.

```yaml
root_password: MyRootPassword123!
```

## Install of SOPS and AGE

Install the SOPS Binary into your Path and age
```
wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux
mv sops-v3.7.3.linux sops
sudo install ./sops /usr/local/bin
rm ./sops
sudo apt install age
```

## Creating keys

You can create a modern encryption key with the age command line tool
```
age-keygen -o sops-key-sample-env.txt
cat sops-key-sample-env.txt
```

This creates the following key in the textfile
```
# created: 2023-04-26T18:57:20+02:00
# public key: age1rzw9f9dvspwwykddan6ytllraywpume4jqx3enenu9m3ls493sjsr3slew
AGE-SECRET-KEY-1E8KVHD06U5D54L2H3L9H6RF9RED3AMCNQZRMS7K98NSJ6TSXZD0SC7WL5J
```

## Encrypt & Decrypting of Files

Export your recipients key -> e.g your own public key from your `sops-key-sample-env.txt`  and create a `.sops.yaml` with your public key for encrypting your files. 

```
creation_rules:
  - age: age1rzw9f9dvspwwykddan6ytllraywpume4jqx3enenu9m3ls493sjsr3slew
````

The creation_rules specify what should happen for specifiy files and how they should be encrypted. We keep it simple here! 

Now encrypt the yaml with sops
```
sops --encrypt ./env/sample-env/secrets.yaml > ./env/sample-env/secrets.yaml.enc
```

Now we successfully encrypted the file and can upload it to git. 

To decrypt our stored files. Export the keyfile you want to use and then decrypt the stored files
```
export SOPS_AGE_KEY_FILE=~/.sops/keys/sample-env.txt
sops --decrypt --input-type yaml --output-type yaml ./env/sample-env/secrets.yaml.enc > ./env/sample-env/secrets.yaml
```

## Directly working with the editor 

If you configured all of the above variables, you can simply edit the encrypted file with the sops command

```

## Encrypt a new file

You can directly work with the SOPS CLI Tool to decrypt and encrypt files. 

```
./sops-scripts/encrypt.sh ./env/sample-env/secrets.yaml > ./node-playbooks/site-secrets.sops.yaml
# Open an editor in the SOPS-CLI`
sops ./env/sample-env/vscode-test.sops.yaml
```


## Sources 

For more information refere to: 
- https://devops.datenkollektiv.de/using-sops-with-age-and-git-like-a-pro.html
- https://docs.ansible.com/ansible/latest/collections/community/sops/docsite/guide.html
- https://github.com/mozilla/sops#usage
- https://github.com/FiloSottile/age


## MISC 
You can remove a file from git with `git filter-branch --tree-filter 'rm -f ./env/sample-env/secrets.yaml' HEAD`