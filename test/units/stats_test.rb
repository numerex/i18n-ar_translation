require 'test_helper'
require 'i18n-ar_translation/stats'

class StatsTest < ActiveSupport::TestCase

  test 'collect_stats' do
    setup_one_of_each

    assert_equal [{:locale=>:en,
                   :missing=>0,
                   :sourced=>3,
                   :total=>3,
                   :translated=>3,
                   :unsourced=>0,
                   :untranslated=>0},
                  {:locale=>:es,
                   :missing=>1,
                   :sourced=>2,
                   :total=>2,
                   :translated=>1,
                   :unsourced=>0,
                   :untranslated=>1}],I18n::ArTranslation::Stats.collect_stats
  end

end
