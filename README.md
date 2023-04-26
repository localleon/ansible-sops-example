# ansible-sops-example 

Repository to demonstrate Moziall SOPS working with Ansible

## Prerequisites


Create the File `env/sample-env/secrets.yaml` locally, but don't commit it into git yet.

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
age-keygen -o ~/.sops/keys/sample-env.txt
cat ~/.sops/keys/sample-env.txt
```

This creates the following key in the textfile
```
# created: 2023-04-26T18:57:20+02:00
# public key: age1rzw9f9dvspwwykddan6ytllraywpume4jqx3enenu9m3ls493sjsr3slew
AGE-SECRET-KEY-1E8KVHD06U5D54L2H3L9H6RF9RED3AMCNQZRMS7K98NSJ6NOT_A_REAL_KEY
```

## Encrypt & Decrypting of Files

Export your recipients key -> e.g your own public key from your ~/.sops/keys/sample-env.txt and encrypt the yaml with sops
```
export SOPS_AGE_RECIPIENTS=age1rzw9f9dvspwwykddan6ytllraywpume4jqx3enenu9m3ls493sjsr3slew
sops --encrypt --age ${SOPS_AGE_RECIPIENTS} ./env/sample-env/secrets.yaml > ./env/sample-env/secrets.yaml.enc
```
Now we successfully encrypted the file and can upload it to git. 

To decrypt our stored files. Export the keyfile you want to use and then decrypt the stored files
```
export SOPS_AGE_KEY_FILE=~/.sops/keys/sample-env.txt
sops --decrypt --input-type yaml --output-type yaml ./env/sample-env/secrets.yaml.enc > ./env/sample-env/secrets.yaml
```

## Hooking into Git 

Export the location of your age key
```
export SOPS_AGE_KEY_FILE=~/.sops/keys/sample-env.txt
```

The scripts in the ./sops-scripts can be used to encrypt and decrypt files 

```
chmod +x ./sops-scripts/*
./sops-scripts/decrypt.sh ./env/sample-env/secrets.yaml.enc > ./env/sample-env/secrets.yaml
./sops-scripts/decrypt.sh ./env/sample-env/secrets.yaml.enc > ./env/sample-env/secrets.yaml
```

Configure your local git config to apply some filters for each repository if an encrypted yaml is detected. 
```
git config --local filter.sops.smudge $(pwd)/sops-scripts/decrypt.sh
git config --local filter.sops.clean $(pwd)/sops-scripts/encrypt.sh
git config --local filter.sops.required true
```

You can now commit your changes into the repository -> the Git Filter will encrypt them for you transparently.
```
git add env/
git status
git commit -vm 'Switch to Git Filter for shared secret'
git push
```

You're local repository won't change. You can still see and edit the SOPS File. 

Looking into the remote repository `env/sample-env/secrets.yaml`, all the secrets are encrypted
```
root_password: MyPassword123!
sops:
    kms: []
    gcp_kms: []
    azure_kv: []
    hc_vault: []
    age:
        - recipient: age1rzw9f9dvspwwykddan6ytllraywpume4jqx3enenu9m3ls493sjsr3slew
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA1Zi9POUJjT3F5RHYxdUVB
            YmNVelFqUytXanhwZmJiQXhSUFExcEVUejJjCjR3L216dE9nYjBvVnRIdzdPbm1M
            eXNBbVRuNHYralp3R0RTVTRXQThWWnMKLS0tIGh1TDg4Rkp0ZVlzeEdRS0IrWUNx
            Rk1PLzZ2VlZqU2l0TTRzMFJFclRQNFkKnldsrJZujqCcNhKAMO6cP6gTo9Vl4vfe
            P3ivkDatKCoFlu0JsyuYj1Vma+NVohTBV4ZZx5qdUnxBxuCh1yHEVg==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2023-04-26T17:37:29Z"
    mac: ENC[AES256_GCM,data:ZyxNsPrVzkYR5UXzQtN8BkA6nnIYfAVj/fiZTRFnb1TZSWUQnaked+KWqVv9diGryR4nayAfYA84YOmMtPkSxqoZk2QpgOJR/xOQF8OF6R6uNwKinaIu2oZVfveEEuqnknW1wA1zdWWYnPtADUPoSncnuQ7+l2wz6b5Dm1ViOUE=,iv:5pAzjvAchON8u89ZCgSqxJE9uyZhj6etZS6h4nc8G4c=,tag:o4zH2e7AqwfBScmESg8/1A==,type:str]
    pgp: []
    encrypted_regex: ^(user|password)$
    version: 3.7.3
```

This concludes encryption and decryption with git. You can check your history for the encrypted file with `git rev-list --objects -g --no-walk --all | grep env/sample-env/secrets.yaml`


## Setup with VS-Code 

VS-Code Setup 

1. Install https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops



## MISC 

You can remove a file from git with `git filter-branch --tree-filter 'rm -f ./env/sample-env/secrets.yaml' HEAD`