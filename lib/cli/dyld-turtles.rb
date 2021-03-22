require 'optparse'

extra_dirs = []

OptionParser.new do |opts|
  opts.banner = "Usage: dyld-turtles [options]"

  opts.on("--dylib-extra [DIR]", "Alternate path to look up dylibs") do |dir|
    extra_dirs.unshift dir
  end
end.parse!

target_file = ARGV.pop

puts "Turtles all the way down from #{target_file}\n\n"

require 'dependancy_tree'

tree = DependancyTree.new target_file, extra_dirs: extra_dirs

tree.analyze!

def print_tree(node, indent, seen_items)
    return if seen_items.include? node

    tabs = "\t" * indent

    puts "#{tabs} #{node.filename}"
    seen_items.push node

    node.children.each do |child|
        print_tree(child, indent + 1, seen_items)
    end

end

print_tree(tree, 0, [])