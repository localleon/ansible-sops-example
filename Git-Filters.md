## Hooking into Git 

Export the location of your age key
```bash
export SOPS_AGE_KEY_FILE=~/.sops/keys/sample-env.txt
```

The scripts in the ./sops-scripts can be used to encrypt and decrypt files 

```bash
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

The `.gitattributes` files controls which local file the filter should be applied to automaticly. Our configuration should encrypt every yaml-file that ends with `*secrets.yaml`

```
*secrets.yaml filter=sops
```

You can now commit your changes into the repository -> the Git Filter will encrypt them for you transparently. Files in Git will be encrypted, you're local files will stay unencrypted.

```bash
git add env/
git status
git commit -vm 'Switch to Git Filter for shared secret'
git push
```

You're local repository won't change. You can still see and edit the SOPS File. Looking into the remote repository `env/sample-env/secrets.yaml`, all the secrets are encrypted

```yaml
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
