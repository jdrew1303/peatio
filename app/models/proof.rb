class Proof < ActiveRecord::Base
  include Currencible

  has_many :partial_trees

  serialize :root, JSON
  serialize :addresses, JSON

  validates_presence_of :root, :currency
  validates_numericality_of :balance, allow_nil: true, greater_than_or_equal_to: 0

  delegate :coin?, to: :currency

  def self.current(code)
    proofs = with_currency(code)
    proofs.where('created_at <= ?', 1.day.ago).last || proofs.last
  end

  def ready!
    self.ready = true
    save!
  end

  def timestamp
    Time.at(root['timestamp']/1000) || updated_at
  end

  def partial_tree_of(account)
    partial_trees.where(account: account).first
  end

  def asset_sum
    addresses.reduce 0 do |memo, address|
      memo + address["balance"]
    end
  end
end

# == Schema Information
# Schema version: 20180227163417
#
# Table name: proofs
#
#  id          :integer          not null, primary key
#  root        :string(255)
#  currency_id :integer
#  ready       :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  sum         :string(255)
#  addresses   :text(65535)
#  balance     :string(30)
#
# Indexes
#
#  index_proofs_on_currency_id  (currency_id)
#
