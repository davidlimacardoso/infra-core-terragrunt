
### Make a Proxy jump to jenkins

- Add the key pair to your ssh agent
```bash
ssh-add jenkins-key.pem
```

- Make a proxy jump to the jenkins server
```bash
ssh -i jenkins-key.pem -J ec2-user@55.191.8.48 ubuntu@10.248.241.78
```