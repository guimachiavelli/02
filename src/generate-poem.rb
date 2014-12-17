def generate_poem
    data = get_verse_data()
    verses = rand 3..10

    test = pick_verses data, verses

    puts test
end


def pick_verses(data, verses)
    poem = []
    while verses > 0
        chosen_base = data[rand(data.length)]
        poem.push chosen_base[rand(chosen_base.length)]
        verses -= 1
    end
    poem
end

def get_verse_data
    data_dir = './data/parsed'
    data = []

    Dir.foreach data_dir do |filename|
        unless filename.start_with? '.'
            data.push get_poem(filename, data_dir)
        end
    end

    data
end


def get_poem(filename, data_dir)
    poem = IO.read data_dir + '/' + filename
    poem.split("\n")
end

generate_poem()
