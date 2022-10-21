FROM --platform=$TARGETPLATFORM ubuntu:20.04

ARG UID=7000
ARG GID=7000
ARG USERNAME=aptmirror

# update, install prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN		apt-get -qq update \
	&&	apt-get -yqq install apt-utils --no-install-recommends \
	&&	apt-get -yqq install nano software-properties-common wget openssh-server apt-mirror cron --no-install-recommends \
	&&	apt-get -qq clean \
	&&	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# replace apt-mirror binary with git version
RUN 	mv /usr/bin/apt-mirror /usr/bin/apt-mirror.bak \
	&&	wget https://raw.githubusercontent.com/apt-mirror/apt-mirror/master/apt-mirror -O /usr/bin/apt-mirror \
	&&	chmod 755 /usr/bin/apt-mirror \
	&&	mkdir /apt-mirror

# install sshd
RUN		mkdir /var/run/sshd \
	&&	echo 'root:root' | chpasswd \
	&&	sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&&	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# copy files
WORKDIR /
COPY files /

# create nonroot user for mirror
RUN		groupadd -g ${GID} -o ${USERNAME} 
RUN 	useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${USERNAME} \
	&&	id
USER	${USERNAME}

# run configs
VOLUME ["/apt-mirror"]
EXPOSE 22
CMD [ "/usr/sbin/sshd", "-D" ]
ENTRYPOINT [ "/bin/bash", "/startup.sh" ]
