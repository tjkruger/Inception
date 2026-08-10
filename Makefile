# ============================================================================
#  Inception - Makefile
# ============================================================================

# Your 42 login is auto-detected from the current user.
# Override on the command line if needed: make LOGIN=wil
export LOGIN		:= $(shell whoami)

COMPOSE_DIR	:= srcs
COMPOSE_FILE	:= $(COMPOSE_DIR)/docker-compose.yml
DATA_DIR	:= /home/$(LOGIN)/data

# Colors for pretty output
GREEN		:= \033[0;32m
YELLOW		:= \033[0;33m
RESET		:= \033[0m

# ============================================================================
#  Main targets
# ============================================================================

all: build up

build: data_dirs
	@echo "$(YELLOW)Building images...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) build

up: data_dirs
	@echo "$(YELLOW)Starting containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Inception is up. Visit https://$(LOGIN).42.fr$(RESET)"

down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

start:
	@docker compose -f $(COMPOSE_FILE) start

restart: down up

# ============================================================================
#  Data directories (bind location for named volumes)
# ============================================================================

data_dirs:
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb

# ============================================================================
#  Cleaning
# ============================================================================

clean: down
	@echo "$(YELLOW)Removing containers, networks, and images...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down --rmi all --remove-orphans

fclean: clean
	@echo "$(YELLOW)Removing volumes and persisted data...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -af --volumes 2>/dev/null || true

re: fclean all

# ============================================================================
#  Debug helpers
# ============================================================================

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker compose -f $(COMPOSE_FILE) ps

.PHONY: all build up down stop start restart data_dirs clean fclean re logs ps
