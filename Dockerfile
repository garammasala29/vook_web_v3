FROM amazonlinux:2

RUN yum -y update && \
    yum -y install git make gcc-c++ patch libyaml-devel libffi-devel \
    libicu-devel zlib-devel readline-devel libxml2-devel libxslt-devel \
    ImageMagick ImageMagick-devel openssl-devel libcurl-devel curl wget \
    tar python3 sudo yum-utils

# Install Ruby
ARG RUBY_VERSION=3.2.2

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile && \
    source ~/.bash_profile && \
    # ruby-build(Rubyをバージョンごとにビルドするツール)のインストール
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build  && \
    rbenv rehash && \
    rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION && \
    rbenv rehash  && \
    # nvm(node.js管理ツール)のインストール
    touch ~/.bashrc && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash  && \
    source ~/.bashrc && \
    # nodeのインストール(偶数が安定版) 最新のnodeがサポートできるglibcが搭載されていないので、nodeのバージョンを下げる
    nvm install 16.20.0 && \
    # yarn(JSパッケージマネージャ)をインストール
    npm install -g yarn && \
    # MariaDBのアンインストール NOTE: amazonlinux2にはmariadbは含まれていない?
    # yum list installed | grep mariadb 
    # && \
    sudo yum remove mariadb-libs.x86_64 && \
    # MySQL8.0のリポジトリ追加(https://dev.mysql.com/downloads/repo/yum/で選択した)
    sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm && \
    # MySQL8.0リポジトリの有効可
    sudo yum-config-manager --disable mysql57-community && \
    sudo yum-config-manager --enable mysql80-community && \
    # クライアントツールのインストール
    sudo yum install -y mysql-community-client mysql-devel