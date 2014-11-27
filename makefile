books = 27199 261

test = $(foreach book, $(books), http://www.gutenberg.org/files/$(book)/$(book)-h/$(book)-h.htm -o $(book).html)

testa = $(foreach a, $(books), $(a))

all: 

download:
	@curl $(test)

get:
	curl 
