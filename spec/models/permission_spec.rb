require 'rails_helper'

RSpec.describe Permission, :type => :model do
  it { should be_a_kind_of ActiveRecord::Base }
  it { should belong_to :role }
  it { should validate_presence_of :subject }
end
