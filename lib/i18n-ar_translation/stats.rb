module I18n

  module ArTranslation

    module Stats

      def self.collect_stats
        stats = []

        default_locale = I18n.default_locale
        stats << collect_counts(default_locale)
        (I18n.available_locales - [default_locale]).each{|locale| stats << collect_counts(locale)}
        max_total = stats.collect{|stat| stat[:total]}.max
        stats.each{|stat| stat[:missing] = max_total - stat[:total]}

        stats
      end

      def self.collect_counts(locale)
        scope = I18n::Backend::ActiveRecord::Translation.locale(locale)
        total = scope.count
        untranslated = scope.where(value: nil).count
        translated = total - untranslated
        unsourced = scope.where(predefined: 0).count
        sourced = total - unsourced
        {:locale => locale, :total => total, :translated => translated, :untranslated => untranslated, :unsourced => unsourced, :sourced => sourced}
      end

    end

  end

end