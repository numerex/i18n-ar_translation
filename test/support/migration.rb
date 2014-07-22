require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3',database: ':memory:')

ActiveRecord::Schema.define(version: 1) do
  create_table :translations, force: true do |t|
    t.string :locale
    t.string :key
    t.text :value
    t.text :interpolations
    t.boolean :is_proc, default: false
    t.boolean :predefined,default: false
  end
  add_index :translations, [:locale, :key], unique: true

  create_table :test_models, force: true do |t|
    t.string :name
  end
end