require 'rails_helper'

RSpec.describe Configuration, type: :model do
  it { is_expected.to belong_to :customer }
end