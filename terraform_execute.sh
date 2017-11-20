#!/bin/sh

_usage() {
    echo "terraform_execute.sh <command> <task> (upgrade)"
    _command
    _task
}

_command() {
    echo "command=plan|apply|destroy|graph|..."
}

_command_apply() {
    echo "applyコマンドを実行します"
    echo "planコマンドを実行して確認しましたか [Y/n]"
    read ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            ;;

        * )
            exit 1;;
    esac
}

_command_destroy() {
    echo "destroyコマンドを実行しますか [Y/n]"
    read ANSWER
    case $ANSWER in
        "Y" | "y" | "yes" | "Yes" | "YES" )
            ;;

        * )
            exit 1;;
    esac
}

_task() {
    echo "task=tasks以下のディレクトリ名を指定"
}

_execute() {
    # 実行ディレクトリ移動
    cd tasks/${TASK}/

    # provider.tf, common.tfをシンボリック化
    ln -s ../../provider.tf ./
    ln -s ../../common.tf ./

    # stateファイル初期化
    if [[ $UPGRADE == "upgrade" ]]; then
        terraform init -upgrade
    else
        terraform init
    fi

    # 実行
    if [ $COMMAND == "graph" ]; then
        terraform ${COMMAND} | dot -Tpng > "${TASK}-graph.png"
    else
        terraform ${COMMAND} -var access_key="../../keys/access.key" -var secret_key="../../keys/secret.key" -var-file="../../common.tfvars"
    fi

    # シンボリックリンク解除
    unlink provider.tf
    unlink common.tf
}

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    _usage
    exit 1
fi

if [ $1 == "apply" ]; then
    _command_apply
fi

if [ $1 == "destroy" ]; then
    _command_destroy
fi

COMMAND=$1
TASK=$2
UPGRADE=$3

_execute
