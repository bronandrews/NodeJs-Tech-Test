FROM jenkins/jenkins:lts
USER root

# Install packages 
RUN apt-get update && apt-get install -y\
    git \
    ca-certificates \
    docker.io \
    mailutils \
    curl \
    unzip \
    jq \
    awscli \
    python3 \
    -m pipx \
    && update-ca-certificates
    && rm -rf /var/lib/apt/lists/*

# Install 'less'
RUN apt install less

# Add Jenkins user to docker group
RUN usermod -aG docker jenkins

# Install custom plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

RUN pipx ensurepath

# Install yamllint with pipx for the jenkins user
USER jenkins
RUN pipx install yamllint

# Add pipx binary path to PATH
RUN echo $PATH
ENV PATH="/var/jenkins_home/.local/bin:$PATH"
RUN echo $PATH

# Switch back to root to ensure proper permissions
USER root

# Start docker daemon
RUN dockerd &

# Ensure Jenkins owns its .local directory
RUN chown -R jenkins:jenkins /var/jenkins_home/.local/bin

# Optional: make sure the binaries are executable
RUN chmod -R u+rx /var/jenkins_home/.local/bin

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.33.3/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Node.js (LTS) and npm  - for mock tests
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Change back to Jenkins user
USER jenkins

# test install is ok
RUN yamllint --version