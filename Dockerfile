FROM --platform=$TARGETPLATFORM ubuntu:20.04

# update, install prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN		apt-get -qq update \
	&&	apt-get -yqq install apt-utils nano software-properties-common wget openssh-server apt-mirror \
	&&	apt-get -qq clean \
	&&	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# replace apt-mirror binary with git version
RUN 	mv /usr/bin/apt-mirror /usr/bin/apt-mirror.bak \
	&&	wget https://raw.githubusercontent.com/apt-mirror/apt-mirror/master/apt-mirror -O /usr/bin/apt-mirror \
	&&	chmod 755 /usr/bin/apt-mirror \
	&&	mkdir /apt-mirror

# install sshd
RUN		mkdir /var/run/sshd \
	&&	echo 'root:root' |chpasswd \
	&&	sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&&	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# copy files
WORKDIR /
COPY files /

EXPOSE 22
CMD [ "/usr/sbin/sshd", "-D" ]
ENTRYPOINT [ "/bin/bash", "/startup.sh" ]
