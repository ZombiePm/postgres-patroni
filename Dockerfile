FROM postgres:15

# Install Patroni and dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-psycopg2 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install patroni[etcd]

# Create directories
RUN mkdir -p /etc/patroni /var/lib/postgresql/data

# Copy configuration
COPY patroni.yml /etc/patroni/

# Set permissions
RUN chown -R postgres:postgres /etc/patroni /var/lib/postgresql/data

USER postgres

EXPOSE 5432 8008

CMD ["patroni", "/etc/patroni/patroni.yml"]