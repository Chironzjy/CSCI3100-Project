class EnablePgSearchForItems < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    enable_extension "unaccent" unless extension_enabled?("unaccent")

    add_index :items, :title, using: :gin, opclass: :gin_trgm_ops
    add_index :items, :description, using: :gin, opclass: :gin_trgm_ops
  end
end
