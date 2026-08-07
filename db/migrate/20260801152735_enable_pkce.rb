# frozen_string_literal: true

class EnablePkce < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:oauth_access_grants, :code_challenge)
      add_column :oauth_access_grants, :code_challenge, :string, null: true
    end

    unless column_exists?(:oauth_access_grants, :code_challenge_method)
      add_column :oauth_access_grants, :code_challenge_method, :string, null: true
    end
  end
end
