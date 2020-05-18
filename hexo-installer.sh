#!/bin/bash
#-----------------------------------
# Author: Qingxu (huanruomengyun)
# Description: Hexo one-click installation cript for Termux.
# Repository Address: https://github.com/huanruomengyun/Termux-Hexo-installer
# Version: 0.2
# Copyright (c) 2020 Qingxu
#-----------------------------------
clear
#可选，移除 Zsh
while getopts ":r" opt; do
	case $opt in
		r)
			pkg remove zsh
			rm -rf ~/.oh-my-zsh ~/.hushlogin ~/.zshrc
			chsh -s bash
			echo ""
			echo "Done. Restart session to take effect."
			exit
			;;
		\?)
			echo "Usage: ./hexo-installer.sh [-r]"
			exit
			;;
	esac
done
#Start
echo -e "安装开始(づ￣ ³￣)づ\n"
echo -e "请保持网络连接畅通，坐和放宽，等待安装完成"
#更换源为清华源
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
apt update && apt upgrade -y
echo -e "已更换源为清华源"
#安装必需软件包
pkg in nodejs-lts git vim nano openssh unzip neofetch -y
neofetch
#更换 NPM 源为淘宝源
if test -e $PREFIX/bin/npm ; then
                echo -e "默认更换 NPM 源为淘宝源\n"
				echo -e "输入 npm config set registry https://registry.npmjs.org/ 恢复官方源"
				sleep 1
				npm config set registry https://registry.npm.taobao.org
			else
				echo -e "脚本中 Node.js 安装失败，请在确认网络正常连接后输入 ./hexo-installer.sh 重新执行脚本"
			fi
#初始化 NPM 和 Hexo 并安装基础模块
npm install -g npm
npm install -g hexo-cli
cd
mkdir blog && cd blog
hexo init
npm install hexo-deployer-git hexo-generator-feed hexo-generator-sitemap --save
echo "Hexo 已初始化并已安装基础模块，请勿重复进行 hexo init"
#扩展底部小键盘
if test -d ~/.termux/ ; then
	:
else
	mkdir -p ~/.termux/
fi
echo -e "extra-keys = [['TAB','>','-','~','/','*','$'],['ESC','(','HOME','UP','END',')','PGUP'],['CTRL','[','LEFT','DOWN','RIGHT',']','PGDN']]" > ~/.termux/termux.properties
termux-reload-settings
echo -e "Hexo 版本信息如下"
hexo version
echo -e "博客目录默认为 ~/blog"
cd
#Change to zsh
#From https://raw.github.com/mechtifs/termuxtomizer/master/config.sh
while true
do
	read -p "是否安装 Zsh 作为默认 Shell (默认拒绝) [Y/n]: " installzsh
	case $installzsh in
		Y* | y*)
			#init
            dir=$(cd "$(dirname "$0")"; pwd)
            rc=~/.zshrc
            touch ~/.hushlogin
            #Zsh
            pkg in zsh -y
            echo "如果下面需要您进行确认，请输入 y 确认"
            chsh -s zsh
            sh -c "$(sed -e "/exec zsh -l/d" <<< $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"
            #Plugins
            git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
            git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
            sed -i "s/plugins=(git)/plugins=(git extract web-search zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/g" $rc
            sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"af-magic\"/g" $rc
            echo "Zsh 配置完成，你可在 ~/.zshrc 中修改主题"
            echo "如需恢复默认 Shell 为 Bash，请输入 ./hexo-installer.sh -r"
			break
			;;
		N* | n*)
			break
			;;
		"")
			echo "Using default shell."
			sleep 1
			break
			;;
	esac
done
while true
do
	read -p "是否自动下载 Hexo 主题(默认拒绝)。你可以在站点配置文件启用下载的主题。如果你不可以正常连接 GitHub，你可能无法完成主题下载。[Y/n]: " downloadthemes
	case $downloadthemes in
		Y* | y*)
            cd ~/blog
            git clone https://github.com/litten/hexo-theme-yilia.git themes/yilia
            git clone https://github.com/xaoxuu/hexo-theme-volantis themes/volantis
            npm i -S hexo-generator-search hexo-generator-json-content hexo-renderer-less
            git clone https://github.com/theme-next/hexo-theme-next themes/next
			break
			;;
		N* | n*)
			break
			;;
		"")
			echo "Using default theme."
			sleep 1
			break
			;;
	esac
done
echo "Done ! Please restart session."
