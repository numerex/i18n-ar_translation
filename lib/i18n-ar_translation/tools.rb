module I18n

  module ArTranslation

    module Tools

      def self.reset_translations(verbose,truncate = true)
        puts 'BACKUP MISSING TRANSLATIONS...' if verbose
        I18n::ArTranslation::Configuration.translation_locales.each do |locale|
          next if (translations = find_translations(locale,predefined: false)).empty?
          File.open(Rails.root + "config/translations/#{locale}.missing",'w'){|file| file.write translations.to_yaml }
        end

        # NOTE -- truncation will reset the auto-increment ID and is desirable operationally, but it is not recoverable for transactions, so messes up testing
        if truncate
          puts 'TRUNCATE TRANSLATIONS...' if verbose
          ::ActiveRecord::Base.connection.execute 'truncate table translations'
        else
          puts 'DELETE TRANSLATIONS...' if verbose
          I18n::Backend::ActiveRecord::Translation.delete_all
        end

        I18n.locale = I18n.default_locale
        collect_possible_translations(verbose).sort.each_with_index do |key,index|
          placeholders = key.scan(I18n::INTERPOLATION_PATTERN).collect(&:compact).collect(&:first).inject({}){|hash,key| hash[key.to_sym] = nil; hash}
          puts "[#{index}] - KEY:#{key}" if verbose
          I18n.t(key,placeholders)
        end

        (I18n::ArTranslation::Configuration.translation_locales - [:en]).each do |locale|
          puts "ADD PLACEHOLDERS FOR: #{locale}" if verbose
          I18n::Backend::ActiveRecord::Translation.where(locale: I18n.default_locale).each do |translation|
            placeholder = I18n::Backend::ActiveRecord::Translation.new(locale: locale,key: translation.key)
            placeholder.interpolations = translation.interpolations
            placeholder.save!
          end

          puts "ADD TRANSLATIONS FOR: #{locale}" if verbose
          puts "... WARNING: translation file not found for #{locale}" and next unless File.exists?(path = Rails.root + "config/translations/#{locale}.yml")
          YAML.load_file(path).each do |tuple|
            if translation = I18n::Backend::ActiveRecord::Translation.locale(locale).lookup(tuple['key']).first
              puts "... FOUND:  #{tuple['key']}\n    VALUE:  #{tuple['value']}" if verbose
              translation.update_attributes!(value: tuple['value'])
            else
              puts "... MISSING:#{tuple['key']}" if verbose
            end
          end
        end

        puts 'SETTING PREDEFINED FLAG TO TRUE...' if verbose
        I18n::Backend::ActiveRecord::Translation.where('value is not null').update_all(predefined: true)
      end

      def self.collect_possible_translations(verbose,directory = 'app')
        assets = []
        Dir.glob("#{directory}/*").each do |item|
          if File.directory?(item)
            assets += collect_possible_translations(verbose,item)
          elsif item.ends_with?('.rb') || item.ends_with?('.erb') || item.ends_with?('.rhtml')
            puts "SOURCE FILE:#{item}" if verbose
            File.readlines(item).each do |line|
              begin
                matches = line.scan(Regexp.union(
                    /(I18n\.t|\Wt)(\(|\s*)'([^']*)'/,
                    /(I18n\.t|\Wt)(\(|\s*)"([^"]*)"/,
                    /(I18n\.t|\Wt)(\(|\s*)%\(([^\)]*)\)/,
                    /(I18n\.t|\Wt)(\(|\s*)%\[([^\]]*)\]/)).collect(&:compact).collect(&:last)
                matches.each{|key| puts "...KEY:#{key}"} if verbose
                assets += matches
              rescue
                puts "WARNING:#{$!} in file #{item} with line '#{line}'"
              end
            end
          end
        end
        assets.uniq
      end

      def self.collect_flattened_translations(locale)
        raise 'unexpected backend chain found' unless I18n::Backend::Simple === (simple = I18n.backend.backends.last)
        raise 'no translations found' unless (translations = simple.send :translations).any?
        flatten_hash(translations[locale])
      end

      def self.flatten_hash(src,prefix = '',dst = {})
        src.keys.sort.each do |key|
          next_key = "#{prefix}#{key}"
          case value = src[key]
            when String
              dst[next_key] = value
            when Hash
              flatten_hash(value,next_key + '.',dst)
            else
              puts "... skipping flattened #{value.class} for: #{next_key}"
          end
        end
        dst
      end

      def self.find_translations(locale,conditions = nil)
        scope = I18n::Backend::ActiveRecord::Translation.where(locale: locale).where('value is not null')
        scope = scope.where(conditions) if conditions
        scope.all.collect{|translation| translation.attributes.slice('key','value')}
      end

    end

  end

end
