# awscli2

This repo can be used as an apt source to install the aws-cli version 2.

> Notice that this repository, nor the owner is affiliated with Amazon, Amazon Web Services or AWS.
> 
> This is not an official repository!

## Usage
```shell
curl -s --compressed "https://eun.github.io/deb-awscli2/key.gpg" | sudo apt-key add -
sudo curl -s --compressed -o /etc/apt/sources.list.d/awscli2.list "https://eun.github.io/deb-awscli2/awscli2.list"
sudo apt update
sudo apt install awscli2
```
