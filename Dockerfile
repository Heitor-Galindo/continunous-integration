# From Jenkins image.
FROM jenkins/jenkins:2.375.1-jdk11

# Sets the current user to root.
USER root

# Install Docker
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# Install jq, git, Maven, awscli.
RUN apt-get update && apt-get install -y jq git maven awscli

# Copies scripts.
ENV JENKINS_SCRIPT=/opt/jenkins-script
RUN mkdir -p ${JENKINS_SCRIPT}
COPY script ${JENKINS_SCRIPT}
RUN chown -R jenkins:jenkins ${JENKINS_SCRIPT} && \
	ln -s ${JENKINS_SCRIPT}/*.sh /usr/bin && \
	for FILE in /usr/bin/jenkins*.sh; \
	do \
		chown jenkins:jenkins ${FILE} && \	
		mv -- "${FILE}" "${FILE%.sh}"; \
	done

# Sets the user back to jenkins.
USER jenkins
WORKDIR /var/jenkins_home
ENV HOME=/var/jenkins_home

# Settings for Maven
RUN mkdir /var/jenkins_home/.m2/

# Entrypoint.
ENTRYPOINT [ "jenkins_init" ]