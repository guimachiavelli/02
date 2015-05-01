require 'treat'

class Poem
    include Treat::Core::DSL

    PRONOUNS = ['I', 'you', 'thou', 'ye', 'he', 'she', 'it', 'they', 'we']
    THRESHOLD = 10
    EXCLUDED = ['and', 'the', 'or', 'of', 'a', 'the', 'then', 'to', 'not', 'as', 'in', 'with']

    private_constant :PRONOUNS

    def initialize
        data = get_verse_data()
        verses = rand 3..10

        generate(data, verses)
    end

    def generate(data, verses)
        poem = []
        poem = pick_verses data, verses, poem
        poem_score = score(poem)

        if (poem_score > THRESHOLD)
            puts poem
        else
            generate(data, verses)
        end
    end

    def pick_verses(data, verses, poem)
        if verses <= 0 then return poem end

        chosen_base = data[rand(data.length)]

        poem.push(chosen_base[rand(chosen_base.length)])

        pick_verses data, verses - 1, poem
    end

    def score(poem)
        repeated_words(poem)
    end

    def repeated_words(poem)
        count = 0
        poem = poem.join(' ').downcase
        words = poem.scan(/\w{3,}/).delete_if {|word| EXCLUDED.include? word }
        words = words.group_by { |word| word }
        words.each do |word, instances|
            count += word.size if instances.size > 1
        end

        count
    end

    def contains_repeated_words?(new_verse, poem)
        poem = poem.join(' ').split(' ')
        new_verse =  new_verse.split(' ')

        (poem & new_verse).length
    end

    def repeats_word_category?(new_verse, old_verse)
        verse_first_word_category(new_verse) == verse_last_word_category(old_verse)
    end

    def verse_last_word_category(verse)
        verse = sentence(verse).tokenize();
        category = ''

        verse.reverse_each do |token|
            if token.class != Treat::Entities::Punctuation
                category = token.category
                break
            end
        end

        category
    end

    def verse_first_word_category(verse)
        verse = sentence(verse).tokenize();
        category = ''

        verse.each do |token|
            if token.class != Treat::Entities::Punctuation
                category = token.category
                break
            end
        end

        category
    end

    def contains_same_pronoun?(new_verse, old_verse)
        old_verse = old_verse.split(' ')
        new_verse = new_verse.split(' ')

        old_pronouns = old_verse & PRONOUNS
        new_pronouns = new_verse & PRONOUNS

        result = (old_pronouns & new_pronouns).length

        return result > 0 ? true : false
    end

    def contains_personal_pronoun?(verse)
        result = nil

        verse = verse.split(' ')

        # intersection between array with all verse words and all pronouns
        result = (verse & PRONOUNS).length

        return result > 0 ? true : false
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

end

Poem.new
