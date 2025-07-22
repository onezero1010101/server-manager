FROM python:3.12-slim

# Install bash, build tools, and dependencies
RUN apt-get update && apt-get install -y \
    bash \
    build-essential \
    libffi-dev \
    libssl-dev \
    curl \
    jq \
    sudo \
    nut-client \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir paramiko wakeonlan

# Create directories
RUN mkdir -p /etc/nut/thresholds /keys /scripts

# Copy your scripts
#COPY poll.sh /etc/nut/poll.sh
#RUN chmod +x /etc/nut/*.sh

# Default command
CMD ["/bin/bash", "/etc/nut/poll.sh"]
