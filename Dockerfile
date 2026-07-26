FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake libpcap-dev \
    python3 python3-pip python3-venv \
    curl wget git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Copy project
WORKDIR /app
COPY . .

# Build C++ engine
RUN cd engine && mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# Install Python bridge dependencies
RUN cd bridge && pip3 install -r requirements.txt

# Build React dashboard
RUN cd dashboard && npm install && npm run build

# Install serve for static files
RUN npm install -g serve

# Copy startup script
COPY docker-start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5173 8000

CMD ["/start.sh"]
