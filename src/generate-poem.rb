require 'treat'

class Poem
    PRONOUNS = ['I', 'you', 'thou', 'ye', 'he', 'she', 'it', 'they', 'we']

    include Treat::Core::DSL

    private_constant :PRONOUNS

    def initialize
        generate_poem
    end

    def generate_poem
        data = get_verse_data()
        verses = rand 3..10
        poem = []

        poem = pick_verses data, verses, poem

        puts poem
    end


    def pick_verses(data, verses, poem)
        if verses <= 0 then return poem end

        chosen_base = data[rand(data.length)]
        chosen_verse = chosen_base[rand(chosen_base.length)]

        if good_enough? chosen_verse, poem
            poem.push chosen_verse
            verses -= 1
        end

        pick_verses data, verses, poem
    end

    def good_enough?(chosen_verse, poem)
        last_verse = poem[-1]

        if last_verse == nil
            return true
        end

        if repeats_word_category?(chosen_verse, last_verse) == false
            return true
        end

        if contains_personal_pronoun?(last_verse) == false
            return true
        end

        if contains_same_pronoun?(chosen_verse, last_verse)
            return true
        end

        false
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
