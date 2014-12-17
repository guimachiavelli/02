Start = '*** START OF THIS PROJECT GUTENBERG'
End = '*** END OF THIS PROJECT GUTENBERG'

def get_files
    data_dir = './data'

    Dir.foreach data_dir do |filename|
        unless filename.start_with? '.'
            write_file filename, data_dir
        end
    end
end


def write_file(filename, dir)
    filepath = dir + '/' + filename

    if File.directory? filepath
        return
    end

    text = IO.read(filepath)
        .force_encoding("ISO-8859-1")
        .encode("utf-8", replace: nil)

    text = remove_gutenberg_start text
    text = remove_gutenberg_end text
    text = remove_titles text
    text = remove_end_message text
    text = normalize_whitespace text

    IO.write dir + '/parsed/' + filename, text

end

def remove_end_message(text)
    final_text = ''
    text = text.split "\n"

    text.each do |line|
        unless line.start_with? '[', 'NOTE', 'End of the Project'
            final_text << line + "\n"
        end
    end

    final_text
end

def remove_titles(text)
    final_text = ''
    text = text.split "\n"

    text.each do |line|

        unless line.upcase == line
            final_text << line + "\n"
        end
    end
    final_text
end

def remove_gutenberg_start(text)
    index = text.index Start

    if index == nil
        return text
    end

    text[index..text.length]
end

def remove_gutenberg_end(text)
    index = text.index End

    if index == nil
        return text
    end

    text[0..index]
end

def normalize_whitespace(text)
    final_text = ''
    text = text.split "\n"

    text.each do |line|
        final_text << line.strip + "\n"
    end

    final_text
end

get_files()
