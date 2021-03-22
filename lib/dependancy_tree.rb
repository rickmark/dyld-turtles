require 'macho'

class DependancyTree
    attr_reader :children, :filename

    @@loaded = {}

    def initialize(file, extra_dirs: [])
        @filename = file

        if File.exists? @filename
            @file = MachO.open(@filename)
        else
            resolved_file_name = extra_dirs.first { |f| File.exists?("#{f}#{file}")}
            abort "Cannot find #{file}" unless resolved_file_name

            @file = MachO.open("#{resolved_file_name}#{@filename}")
        end
        @extra_dirs = extra_dirs
        @children = []

        @@loaded[file] = self
    rescue
        puts "Could not open #{file}"
        raise
    end

    def analyze!
        @file.linked_dylibs.each do |path|
            if @@loaded[path]
                @children << @@loaded[path]
            else
                child = DependancyTree.new(path, extra_dirs: @extra_dirs)
                child.analyze!
                @children << child
            end
        end
    end
end