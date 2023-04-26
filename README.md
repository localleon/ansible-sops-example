# ansible-sops-example 

Repository to demonstrate Moziall SOPS working with Ansible


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


```
git config --local filter.sops.smudge $(pwd)/sops-scripts/decrypt.sh
git config --local filter.sops.clean $(pwd)/sops-scripts/encrypt.sh
git config --local filter.sops.required true
```



## Setup with VS-Code 

VS-Code Setup 

1. Install https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops

