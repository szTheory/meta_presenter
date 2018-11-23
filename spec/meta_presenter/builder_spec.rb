require 'spec_helper'

describe MetaPresenter::Builder do
  describe '#new' do
    subject { described_class.new(controller, action_name) }

    let(:controller) { ApplicationController.new }
    let(:action_name) { 'logs' }

    it { expect(subject.controller).to eql(controller) }
    it { expect(subject.action_name).to eql(action_name) }
  end
end