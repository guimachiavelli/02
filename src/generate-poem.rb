require 'treat'

class Poem
    include Treat::Core::DSL

    PRONOUNS = ['I', 'you', 'thou', 'ye', 'he', 'she', 'it', 'they', 'we', 'thee', 'thine', 'its', 'her', 'his', 'yours', 'mine', 'my', 'our', 'us', 'ours']
    THRESHOLD = 20
    EXCLUDED = ['and', 'the', 'or', 'of', 'a', 'that', 'than', 'this', 'then', 'to', 'not', 'as', 'in', 'with', 'of', 'an', 'in', 'by']

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

        #return poem

        if (poem_score > THRESHOLD)
            poem = process poem;
            puts poem.join("\n")
        else
            generate(data, verses)
        end
    end

    def process(poem)
        poem = poem.map { |verse| verse.gsub(/\s+\d+/, '') }
        poem = poem.map { |verse| verse.gsub(/[\^\’\'\[\]\(\){}⟨⟩:,\،\‒\…\.\‐\-\‘\’\“\”\'\"\;\/]?$/,'') }
        poem = poem.map { |verse| close_quotes verse }

        poem
    end

    def close_quotes(verse)
        instances = verse.count('"')
        return verse if instances > 1 || instances == 0
        verse + '"'
    end

    def pick_verses(data, verses, poem)
        if verses <= 0 then return poem end

        chosen_base = data[rand(data.length)]

        poem.push(chosen_base[rand(chosen_base.length)])

        pick_verses data, verses - 1, poem
    end

    def score(poem)
        points = repeated_words(poem)
        points += pronouns_count(poem)
        points += last_punctuation(poem)
        points += verse_connections(poem)


        points
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

    def pronouns_count(poem)
        count = 0

        poem = poem.join(' ').downcase.split(' ')
        count = poem & PRONOUNS

        return 10 if count.length == 1
        return (-5 * count.length)
    end

    def last_punctuation(poem)
        verse = poem[-1]

        return 5 if verse.end_with? '.'
        return 5 if verse.end_with? '?'
        return 5 if verse.end_with? '!'
        return -10 if verse.end_with? ','
        return -10 if verse.end_with? ';'
        return -5
    end

    def verse_connections(poem)
        points = 0
        previous_verse = nil
        poem.each do |verse|
            points -= 5 if repeats_word_category?(verse, previous_verse)
            previous_verse = verse
        end

        points
    end

    def repeats_word_category?(new_verse, old_verse)
        return if new_verse == nil || old_verse == nil
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
