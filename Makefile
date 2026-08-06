COMPOSE_FILE := srcs/docker-compose.yml
DATA_DIR := /home/$(LOGIN)/data

GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

all: build up

build: data_dirs
	@echo "$(YELLOW)Building images...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) build

up: data_dirs
	@echo "$(YELLOW)Starting containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Inception is up: https://$(LOGIN).42.fr$(RESET)"

down:
	@docker compose -f $(COMPOSE_FILE) down

start:
	@docker compose -f $(COMPOSE_FILE) start

stop:
	@docker compose -f $(COMPOSE_FILE) stop

restart: down up

data_dirs:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

clean: down
	@docker compose -f $(COMPOSE_FILE) down --rmi all --remove-orphans

fclean: clean
	@docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -af --volumes 2>/dev/null || true

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker compose -f $(COMPOSE_FILE) ps

.PHONY: all build up down start stop restart data_dirs clean fclean re logs ps
```
