FROM alpine:latest

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bash \
    openssh-client \
    nut \
    sudo \
    curl \
    jq \
    libffi-dev

# Allow pip to install packages system-wide in Alpine
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install Python packages
RUN pip3 install paramiko wakeonlan

# Create directories
RUN mkdir -p /etc/nut/thresholds /keys /scripts

# Copy scripts into container
COPY manage-servers.py /etc/nut/
COPY servers.json /etc/nut/
COPY poll.sh /etc/nut/poll.sh
COPY onbattery_trigger.sh /etc/nut/
COPY online_trigger.sh /etc/nut/
COPY thresholds/*.sh /etc/nut/thresholds/

# Make all scripts executable
RUN chmod +x /etc/nut/*.sh /etc/nut/thresholds/*.sh

# Default command to start poll.sh
CMD ["/bin/bash", "/etc/nut/poll.sh"]
