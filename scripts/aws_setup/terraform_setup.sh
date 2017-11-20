#!/bin/sh

TERRAFORM_VERSION="0.11.0"

_usage() {
    echo "terraform_setup.sh <command>"
}

_command() {
    echo "command=user|setup|version"
}

_create_user() {
    sudo useradd terraform_user
    sudo sh -c "echo 'terraform_user   ALL=(ALL)   NOPASSWD:ALL' >> /etc/sudoers"
}

_setup() {
    sudo yum install git -y
    sudo su - terraform_user -c "git clone https://github.com/kamatama41/tfenv.git ~/.tfenv"
    sudo su - terraform_user -c "echo 'export PATH=\$HOME/.tfenv/bin:\$PATH' >> ~/.bash_profile"
}

_version() {
    sudo su - terraform_user -c "tfenv install ${TERRAFORM_VERSION}"
    sudo su - terraform_user -c "tfenv use ${TERRAFORM_VERSION}"
}

if [ $# -ne 1 ]; then
    _usage
    exit 1
fi

if [ $1 == "user" ]; then
    _create_user
elif [ $1 == "setup" ]; then
    _setup
elif [ $1 == "version" ]; then
    _version
else
    _command
    exit 1
fi
