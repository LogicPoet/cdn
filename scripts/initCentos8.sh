#!bin/bash
yum clean all
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
yum makecache
yum -y update
yum remove docker
yum remove docker-common
curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://8rpyhzt9.mirror.aliyuncs.com"]
}
EOF
systemctl start docker
systemctl enable docker
https://github.com/docker/compose/releases
sudo curl -L https://download.fastgit.org/docker/compose/releases/download/v2.1.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/v2.1.1/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
