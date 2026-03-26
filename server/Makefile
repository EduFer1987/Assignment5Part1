# Définition du compilateur (par défaut gcc, ou celui de la cross-compilation)
CROSS_COMPILE ?= aarch64-linux-gnu-
CC ?= $(CROSS_COMPILE)gcc
CFLAGS ?= -g -Wall -Werror

# Nom de l'exécutable
TARGET = aesdsocket

# La première cible est la cible par "défaut"
default: $(TARGET)

# La cible "all" fait la même chose ici
all: $(TARGET)

$(TARGET): server.c
	$(CROSS_COMPILE) $(CFLAGS) -o $(TARGET) server.c

clean:
	rm -f $(TARGET) *.o
