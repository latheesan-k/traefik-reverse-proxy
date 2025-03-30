export COMPOSE_PROJECT_NAME=traefik
export COMPOSE_FILE=docker-compose.yml

.SILENT: up
up: generate-certs
	echo "Starting traefik reverse proxy..."
	docker-compose up -d
	echo "Visit http://localhost:8080 - Traefik dashboard"

.SILENT: down
down:
	echo "Stopping traefik reverse proxy..."
	docker-compose down --remove-orphans

.SILENT: check-mkcert
check-mkcert:
	which mkcert >/dev/null || (\
		echo "Installing mkcert tool..."; \
		curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; \
		chmod +x mkcert-v*-linux-amd64; \
		sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert; \
		mkcert -install; \
	)

.SILENT: generate-certs
generate-certs: check-mkcert
	if [ ! -f "certs/_wildcard.dev.pem" ] || [ ! -f "certs/_wildcard.dev-key.pem" ]; then \
		echo "Generating wildcard certificate for *.dev domain..."; \
		cd certs; \
		mkcert "*.dev"; \
	fi

.SILENT: logs
logs:
	docker-compose logs -f --tail=100

.SILENT: status
status:
	docker-compose ps
