# Variables -------------------------------------------------------------------

NAME		= inception
LOGIN		= maria-ol
SRCS		= ./srcs
COMPOSE		= $(SRCS)/docker-compose.yml
HOST_URL	= $(LOGIN).42.fr
DATA		= /home/$(LOGIN)/data

HIDE		= /dev/null 2>&1

# Rules -----------------------------------------------------------------------

all: $(NAME)

$(NAME): up

# Creates the host data folders (must exist before the volume mount),
# then builds and starts everything in detached mode. Shows the banner.
up:
	@mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	@docker compose -p $(NAME) -f $(COMPOSE) up -d --build || (echo " $(FAIL)" && exit 1)
	@echo " $(UP)"
	@$(MAKE) banner --no-print-directory

# Stops and removes containers + network (keeps volumes and host data)
down:
	@docker compose -p $(NAME) -f $(COMPOSE) down
	@echo " $(DOWN)"

# Stops the containers WITHOUT removing them
stop:
	@docker compose -p $(NAME) -f $(COMPOSE) stop
	@echo " $(STOPPED_MSG)"

# Starts the existing containers again, no rebuild
start:
	@docker compose -p $(NAME) -f $(COMPOSE) start
	@echo " $(STARTED_MSG)"

# Full overview of the project
status:
	@clear
	@printf '%b\n' "\n$(LILAC)CONTAINERS$(RESET)\n"
	@docker ps -a
	@printf '%b\n' "\n$(LILAC)IMAGES$(RESET)\n"
	@docker image ls
	@printf '%b\n' "\n$(LILAC)VOLUMES$(RESET)\n"
	@docker volume ls
	@printf '%b\n' "\n$(LILAC)NETWORKS$(RESET)\n"
	@docker network ls --filter "name=$(NAME)"
	@echo ""

# Follows the logs of all project containers in real time
logs:
	@docker compose -p $(NAME) -f $(COMPOSE) logs -f

# Stops/removes containers, network AND volumes of the project.
# WARNING: this deletes the Docker named volumes (-v). Host data stays.
clean:
	@docker compose -p $(NAME) -f $(COMPOSE) down -v
	@docker volume rm -f $(NAME)_mariadb $(NAME)_wordpress > $(HIDE) 2>&1 || true
	@echo " $(CLEANED_MSG)"

# Runs clean, then deletes the host data folder AND the project images.
# The rm runs inside a throwaway root container because the data was
# created by root inside the containers (avoids 'permission denied').
# WARNING: permanently deletes everything under $(DATA) and the images.
fclean: clean
	@if [ -d $(DATA) ]; then \
		docker run --rm -v /home/$(LOGIN):/host debian:bookworm rm -rf /host/data > $(HIDE) && echo " $(FCLEANED)" ; \
	fi
	@if [ -n "$$(docker image ls nginx -q)" ]; then docker image rm -f nginx > $(HIDE) && echo " $(NX_FLN)" ; fi
	@if [ -n "$$(docker image ls wordpress -q)" ]; then docker image rm -f wordpress > $(HIDE) && echo " $(WP_FLN)" ; fi
	@if [ -n "$$(docker image ls mariadb -q)" ]; then docker image rm -f mariadb > $(HIDE) && echo " $(DB_FLN)" ; fi

# Full rebuild from scratch (runs fclean, which is destructive)
re: fclean all

# Colors ----------------------------------------------------------------------

ESC			= \033[
RESET		= $(ESC)0m
BOLD		= $(ESC)1m

LILAC		= \033[38;2;200;162;200m
PEACH		= \033[38;2;255;180;140m
MINT		= \033[38;2;152;224;180m
ROSE		= \033[38;2;244;150;160m
CORAL		= \033[38;2;255;95;95m

MARK		= $(MINT)✔$(RESET)
RMMARK		= $(ROSE)✔$(RESET)
FAILMARK	= $(CORAL)✘$(RESET)

# Messages --------------------------------------------------------------------

UP			= $(MARK) $(NAME)		$(MINT)Executed$(RESET)
STARTED_MSG	= $(MARK) $(NAME)		$(MINT)Started$(RESET)
DOWN		= $(MARK) $(NAME)		$(PEACH)Stopped$(RESET)
STOPPED_MSG	= $(MARK) $(NAME)		$(PEACH)Stopped$(RESET)
FAIL		= $(FAILMARK) $(NAME)		$(CORAL)Failed$(RESET)

CLEANED_MSG	= $(RMMARK) $(NAME)		$(ROSE)Removed$(RESET)
FCLEANED	= $(RMMARK) Data folder		$(ROSE)Removed$(RESET)

NX_FLN		= $(RMMARK) Image $(NAME)-nginx	$(ROSE)Removed$(RESET)
WP_FLN		= $(RMMARK) Image $(NAME)-wordpress	$(ROSE)Removed$(RESET)
DB_FLN		= $(RMMARK) Image $(NAME)-mariadb	$(ROSE)Removed$(RESET)

# Banner ----------------------------------------------------------------------

banner:
	@echo ""
	@printf '%b\n' "$(LILAC)██╗███╗   ██╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗$(RESET)"
	@printf '%b\n' "$(LILAC)██║████╗  ██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║$(RESET)"
	@printf '%b\n' "$(LILAC)██║██╔██╗ ██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║$(RESET)"
	@printf '%b\n' "$(LILAC)██║██║╚██╗██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║$(RESET)"
	@printf '%b\n' "$(LILAC)██║██║ ╚████║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║$(RESET)"
	@printf '%b\n' "$(LILAC)╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝$(RESET)"
	@echo ""
	@printf '%b\n' "$(LILAC)      made by: mona ✨ — 42 São Paulo, 2026$(RESET)"
	@echo ""

# Phony -----------------------------------------------------------------------

.PHONY: all up down stop start status logs clean fclean re banner
