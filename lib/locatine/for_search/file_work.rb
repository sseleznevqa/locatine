module Locatine
  module ForSearch
    ##
    # Methods about creating, reading and writing files
    module FileWork
      private

      ##
      # Reading data from provided file which is set on init of the class
      # instance
      #
      # If there is no dir or\and file they will be created
      def read_create
        FileUtils.mkdir_p(@folder) unless File.directory?(@folder)
        hash = Hash.new { |h, k| h[k] = Hash.new { |hi, ki| hi[ki] = {} } }
        create_json_file unless File.exist?(@json)
        hash.merge(JSON.parse(File.read(@json))['data'])
      end

      def create_json_file
        f = File.new(@json, 'w')
        f.puts '{"data" : {}}'
        f.close
        send_info "#{@json} is created"
      end

      ##
      # Setting stability
      def set_stability(first, second)
        second = first if second.to_h == {}
        first = second.merge first
        final = Hash.new { |hash, key| hash[key] = [] }
        first.each_pair do |depth, array|
          final[depth] = same_entries(array, second, depth, true).uniq
        end
        final
      end

      def stability_value(name, max, init = 0)
        result = @trust_now.include?(name) ? max.to_s : (init.to_i + 1).to_s
        result = '0' if @untrust_now.include?(name)
        result
      end

      def stability_bump(to_add, hash, max)
        if to_add.empty? # new ones
          hash['stability'] = stability_value(hash['name'], max)
        elsif to_add[0]['stability'].to_i < @stability_limit # old ones
          to_add[0]['stability'] = stability_value(to_add[0]['name'],
                                                   max, to_add[0]['stability'])
        end
        to_add.empty? ? [hash] : to_add
      end

      ##
      # Saving json
      def store(attributes, scope, name)
        @data[scope][name] = {} if @learn
        @data[scope][name] = set_stability(attributes, @data[scope][name])
        to_write = { 'data' => @data }
        File.open(@json, 'w') do |f|
          f.write(JSON.pretty_generate(to_write))
        end
      end
    end
  end
end
