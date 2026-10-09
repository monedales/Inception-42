# Variables -------------------------------------------------------------------

NAME		= inception
SRCS		= ./srcs
COMPOSE		= $(SRCS)/docker-compose.yml
HOST_URL	= maria-ol.42.fr

OBJDIR = obj
OBJ = $(SRC:%.cpp=$(OBJDIR)/%.o)

# Colors ----------------------------------------------------------------------

ESC = \033[
RESET = $(ESC)0m
BOLD = $(ESC)1m
GREEN = $(ESC)32m
YELLOW = $(ESC)33m
BLUE = $(ESC)34m
MAGENTA = $(ESC)35m
CYAN = $(ESC)36m
WHITE = $(ESC)37m
LILAC_TRUE   = \033[38;2;200;162;200m

HIDE		= /dev/null 2>&1
MARK		= $(GREEN)✔$(RESET)
ADDED		= $(GREEN)Added$(RESET)
REMOVED		= $(GREEN)Removed$(RESET)
STARTED		= $(GREEN)Started$(RESET)
STOPPED		= $(GREEN)Stopped$(RESET)
CREATED		= $(GREEN)Created$(RESET)
EXECUTED	= $(GREEN)Executed$(RESET)


# Rules -----------------------------------------------------------------------

# $(NAME) : $(OBJ)
# 	@$(CXX) $(FLAGS) $(OBJ) -o $@
# 	@$(MAKE) banner --no-print-directory

# $(OBJDIR)	
# 	@$(call show_progress,$<)

all : $(NAME)

$(NAME): up

# puts the url in the host files and starts the containers trough docker compose
up: create_dir
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADD)"
	@docker compose -p $(NAME) -f $(COMPOSE) up --build || (echo " $(FAIL)" && exit 1)
	@echo " $(UP)"

# stops the containers through docker compose
down:
	@docker compose -p $(NAME) down
	@echo " $(DOWN)"

create_dir:
	@mkdir -p ~/data/database
	@mkdir -p ~/data/wordpress_files

# creates a backup of the data folder in the home directory
backup:
	@if [ -d ~/data ]; then sudo tar -czvf ~/data.tar.gz -C ~/ data/ > $(HIDE) && echo " $(BKP)" ; fi

# stop the containers, remove the volumes and remove the containers
clean:
	@docker compose -f $(COMPOSE) down -v
	@if [ -n "$$(docker ps -a --filter "name=nginx" -q)" ]; then docker rm -f nginx > $(HIDE) && echo " $(NX_CLN)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=wordpress" -q)" ]; then docker rm -f wordpress > $(HIDE) && echo " $(WP_CLN)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=mariadb" -q)" ]; then docker rm -f mariadb > $(HIDE) && echo " $(DB_CLN)" ; fi

# backups the data and removes the containers, images and the host url from the host file
fclean: clean backup
	@sudo rm -rf ~/data
	@if [ -n "$$(docker image ls $(NAME)-nginx -q)" ]; then docker image rm -f $(NAME)-nginx > $(HIDE) && echo " $(NX_FLN)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-wordpress -q)" ]; then docker image rm -f $(NAME)-wordpress > $(HIDE) && echo " $(WP_FLN)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-mariadb -q)" ]; then docker image rm -f $(NAME)-mariadb > $(HIDE) && echo " $(DB_FLN)" ; fi
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_RM)"

status:
	@clear
	@echo "\nCONTAINERS\n"
	@docker ps -a
	@echo "\nIMAGES\n"
	@docker image ls
	@echo "\nVOLUMES\n"
	@docker volume ls
	@echo "\nNETWORKS\n"
	@docker network ls --filter "name=$(NAME)_all"
	@echo ""

# remove all containers, images, volumes and networks to start with a clean state
prepare:
	@echo "\nPreparing to start with a clean state..."
	@echo "\nCONTAINERS STOPPED\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker stop $$(docker ps -qa) ;	fi
	@echo "\nCONTAINERS REMOVED\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker rm $$(docker ps -qa) ; fi
	@echo "\nIMAGES REMOVED\n"
	@if [ -n "$$(docker images -qa)" ]; then docker rmi -f $$(docker images -qa) ; fi
	@echo "\nVOLUMES REMOVED\n"
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q) ; fi
	@echo "\nNETWORKS REMOVED\n"
	@if [ -n "$$(docker network ls -q) " ]; then docker network rm $$(docker network ls -q) 2> /dev/null || true ; fi 
	@echo ""
	
re: fclean all

# mudar tudo abaixo de acordo com o projeto
banner:
	@echo ""
	@printf '%b\n' "$(LILAC_TRUE) ██████╗██████╗ ██████╗  ██████╗ ██╗  ██╗$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE)██╔════╝██╔══██╗██╔══██╗██╔═████╗██║  ██║$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE)██║     ██████╔╝██████╔╝██║██╔██║███████║$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE)██║     ██╔═══╝ ██╔═══╝ ████╔╝██║╚════██║$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE)╚██████╗██║     ██║     ╚██████╔╝     ██║$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE) ╚═════╝╚═╝     ╚═╝      ╚═════╝      ╚═╝$(RESET)"
	@echo ""
	@printf '%b\n' "$(LILAC_TRUE)           Inception$(RESET)"
	@printf '%b\n' "$(LILAC_TRUE)      made by: mona ✨ — 42 São Paulo, 2026$(RESET)"
	@echo ""
	@printf '%b\n' "$(GREEN)$(BOLD)  Compiled successfully! ✨$(RESET)"
	@echo ""

.PHONY: all up down create_dir clean fclean status backup prepare re


# Messages --------------------------------------------------------------------

UP			= $(MARK) $(NAME)		$(EXECUTED)
DOWN		= $(MARK) $(NAME)		$(STOPPED)
FAIL		= $(RED)✔$(RESET) $(NAME)		$(RED)Failed$(RESET)

HOST_ADD	= $(MARK) Host $(HOST_URL)		$(ADDED)
HOST_RM		= $(MARK) Host $(HOST_URL)		$(REMOVED)

NX_CLN		= $(MARK) Container nginx		$(REMOVED)
WP_CLN		= $(MARK) Container wordpress		$(REMOVED)
DB_CLN		= $(MARK) Container mariadb		$(REMOVED)

NX_FLN		= $(MARK) Image $(NAME)-nginx	$(REMOVED)
WP_FLN		= $(MARK) Image $(NAME)-wordpress	$(REMOVED)
DB_FLN		= $(MARK) Image $(NAME)-mariadb	$(REMOVED)

BKP			= $(MARK) Backup at $(HOME)	$(CREATED)


TERM_WIDTH := $(shell tput cols 2>/dev/null || echo 80)
SAFE_WIDTH := $(shell echo $$(($(TERM_WIDTH) - 10)))
PROGRESS_WIDTH := $(shell echo $$(($(SAFE_WIDTH) > 50 ? 30 : $(SAFE_WIDTH) - 20)))

TOTAL_FILES := $(words $(SRC))
COMPILED_COUNT = 0
VERBOSE ?= 0

define show_progress
    @$(eval COMPILED_COUNT=$(shell echo $$(($(COMPILED_COUNT)+1))))
    @$(eval SHORT_PATH=$(shell echo $(1) | sed 's|^.*/||'))
    @$(eval PERCENT=$(shell echo $$(($(COMPILED_COUNT)*100/$(TOTAL_FILES)))))
    @$(eval BAR_SIZE=20)
    @$(eval BARS=$(shell echo $$(($(COMPILED_COUNT)*$(BAR_SIZE)/$(TOTAL_FILES)))))
    @$(eval REMAINING=$(shell echo $$(($(BAR_SIZE) - $(BARS)))))
    @$(eval PROGRESS=$(shell printf '█%.0s' $$(seq 1 $(BARS))))
    @$(eval EMPTY=$(shell printf '░%.0s' $$(seq 1 $(REMAINING))))

    @if [ $(VERBOSE) -eq 1 ]; then \
        echo "$(CYAN)$(BOLD)📄  Compiling $(RESET)$(CYAN)$(SHORT_PATH)$(RESET) ($(COMPILED_COUNT)/$(TOTAL_FILES))"; \
    else \
        printf "\r\033[K$(YELLOW)$(BOLD)🔄  $(RESET)$(GREEN)$(PROGRESS)$(WHITE)$(EMPTY)$(RESET) $(PERCENT)%% $(CYAN)$(SHORT_PATH)$(RESET)"; \
        if [ $(COMPILED_COUNT) -eq $(TOTAL_FILES) ]; then \
            printf "\n"; \
        fi; \
    fi
endef
