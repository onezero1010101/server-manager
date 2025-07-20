FROM python:3.12-slim

# Install bash and other tools
RUN apt-get update && apt-get install -y \
    bash \
    openssh-client \
    curl \
    jq \
    sudo \
    nut-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir paramiko wakeonlan

# Create directories
RUN mkdir -p /etc/nut/thresholds /keys /scripts

# Copy and set permissions
COPY poll.sh /etc/nut/poll.sh
RUN chmod +x /etc/nut/*.sh

# Set default command
CMD ["/bin/bash", "/etc/nut/poll.sh"]
