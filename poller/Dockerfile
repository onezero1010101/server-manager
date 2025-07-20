FROM alpine:latest

# Install system dependencies and build tools
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bash \
    openssh-client \
    nut \
    sudo \
    curl \
    jq \
    libffi-dev \
    build-base  \
    openssl-dev

# Allow pip to install packages system-wide in Alpine
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Upgrade pip, setuptools, and wheel to ensure they are current
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install Python packages (cffi will now have the necessary build tools)
RUN pip3 install paramiko wakeonlan

# Create directories
RUN mkdir -p /etc/nut/thresholds /keys /scripts

# Copy scripts into container
#COPY manage-servers.py /etc/nut/
#COPY servers.json /etc/nut/
COPY poll.sh /etc/nut/poll.sh
#COPY onbattery_trigger.sh /etc/nut/
#COPY online_trigger.sh /etc/nut/
#COPY thresholds/*.sh /etc/nut/thresholds/

# Make all scripts executable
#RUN chmod +x /etc/nut/*.sh /etc/nut/thresholds/*.sh
RUN chmod +x /etc/nut/*.sh

# Default command to start poll.sh
CMD ["/bin/bash", "/etc/nut/poll.sh"]