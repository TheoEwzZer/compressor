##
## EPITECH PROJECT, 2024
## imageCompressor
## File description:
## imageCompressor
##

NAME		=	imageCompressor

STACK_PATH	=	$(shell stack path --local-install-root)
RM			=	rm -rf

$(NAME):
	stack build
	cp $(STACK_PATH)/bin/$(NAME)-exe ./$(NAME)

all:	$(NAME)

clean:
	stack clean

fclean:	clean
	@$(RM) $(NAME)

re:		fclean all

.PHONY:	all clean fclean re
